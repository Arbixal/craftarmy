local _, NS = ...
local C, S = NS.Core, {}
NS.Storage = S

-- Runtime handles, catalogue indexes and active tokens are never SavedVariables.
local handles = setmetatable({}, {__mode="k"})
local POLICY = "native-rank-reconciled-v1"
local PIN = "297d7aaaa736f346b3e036f38ee088eaf7f8c07f"
local ids = {"skillLineID","parentID","profession","expansionID"}
local successful = {observed=true,empty=true,not_applicable=true}
local function plain(v) return type(v)=="table" and getmetatable(v)==nil end
local function need(v,why) if not v then error(why or "Invalid storage record",0) end; return v end
local function copy(v) local out,why=C.Copy(v); need(out~=nil,why); return out end
local function int(v,low) return C.Integer(v,low or 0) end
local function native(v,low) return int(v,low) and v<=2147483647 end
local function text(v) return type(v)=="string" and #v<=4096 end
local function name(v)
    return type(v)=="string" and #v<=256 and v:match("%S")~=nil and not v:find("[%c|]")
end
local function optional(v,predicate) return v==nil or predicate(v) end
local function bool(v) return type(v)=="boolean" end
local function exact(v,keys)
    need(plain(v),"Expected plain storage table")
    for k in pairs(v) do need(keys[k],"Unknown structural key: "..tostring(k):sub(1,128)) end
end
local function array(v,limit,fn)
    need(plain(v) and #v<=limit,"Invalid bounded array")
    local count=0
    for k,x in pairs(v) do
        need(int(k,1) and k<=#v,"Sparse/keyed array"); count=count+1; fn(x,k)
    end
    need(count==#v,"Sparse array")
end
local function identity(v,id,strict)
    need(plain(v),"Invalid profession identity")
    if strict then exact(v,{skillLineID=true,parentID=true,profession=true,expansionID=true}) end
    for _,key in ipairs(ids) do need(int(v[key],1),"Invalid profession identity") end
    need(v.skillLineID==id and optional(v.name,text) and optional(v.expansionName,text),"Identity owner mismatch")
end
local function sameIdentity(a,b)
    for _,key in ipairs(ids) do if a[key]~=b[key] then return false end end
    return true
end
local function four(v)
    local out={}; for _,key in ipairs(ids) do out[key]=v[key] end; return out
end
local function attempt(a)
    exact(a,{status=true,attemptedAt=true,source=true,reason=true})
    need(C.statuses[a.status] and int(a.attemptedAt) and text(a.source) and optional(a.reason,text),"Invalid field attempt")
end
local function rootHeader(root)
    exact(root,{schema=true,nextCatalog=true,catalogs=true,characters=true})
    need(root.schema==2 and int(root.nextCatalog,1) and plain(root.catalogs) and plain(root.characters),"Invalid schema2 header")
end
local function characterHeader(c)
    exact(c,{name=true,realm=true,classToken=true,professions=true})
    need(text(c.name) and text(c.realm) and optional(c.classToken,C.ValidClassToken) and plain(c.professions),"Invalid character directory")
end
local function professionHeader(p)
    exact(p,{nextGeneration=true,active=true,archives=true})
    need(int(p.nextGeneration,1) and plain(p.archives),"Invalid profession directory")
end
local function guidKey(guid) return type(guid)=="string" and #guid>0 and #guid<=128 end
local function treeKey(key) return type(key)=="string" and tonumber(key:match("^tree:([1-9]%d*)$")) end
local function equipment(key)
    return key=="tool" or key=="accessory1" or key=="accessory2" or
        (type(key)=="string" and key:match("^slot[1-9]%d*$")~=nil)
end

-- Exact typed canonical content, not a hash and never executable/persisted.
local function canonical(v)
    local kind=type(v)
    if kind=="nil" then return "z" end
    if kind=="boolean" then return v and "b1" or "b0" end
    if kind=="number" then return "n"..(v==0 and "0" or string.format("%.17g",v))..";" end
    if kind=="string" then return "s"..#v..":"..v end
    local keys={}; for k in pairs(v) do keys[#keys+1]=k end
    table.sort(keys,function(a,b) if type(a)~=type(b) then return type(a)<type(b) end; return a<b end)
    local out={"t",tostring(#keys),":"}
    for _,k in ipairs(keys) do out[#out+1]=canonical(k); out[#out+1]=canonical(v[k]) end
    return table.concat(out)
end
local function treeDefinition(d)
    exact(d,{id=true,name=true,root=true,paths=true})
    need(int(d.id,1) and int(d.root,1) and optional(d.name,text),"Invalid tree definition")
    local byID={}
    array(d.paths,64,function(p)
        exact(p,{id=true,name=true,capacity=true,children=true})
        need(int(p.id,1) and not byID[p.id] and int(p.capacity) and optional(p.name,name),"Invalid path definition")
        byID[p.id]=p
        local seen={}
        array(p.children,16,function(id)
            need(int(id,1) and not seen[id],"Invalid/duplicate child"); seen[id]=true
        end)
    end)
    local seen,count={},0
    local function visit(id)
        need(byID[id] and not seen[id],"Cyclic/shared/missing tree path")
        seen[id]=true; count=count+1
        for _,child in ipairs(byID[id].children) do visit(child) end
    end
    visit(d.root); need(count==#d.paths,"Unreachable tree path")
    return byID
end
local function detailsDefinition(d)
    exact(d,{trees=true})
    -- Validate text/topology/requirements by the original Details validator using
    -- an unearned zero allocation. Actual personal states are validated separately.
    local v={version=1,skillLineID=2913,configID=1,sourceScanAt=0,trees={}}
    array(d.trees,8,function(t)
        exact(t,{id=true,name=true,root=true,capacity=true,paths=true})
        local out={id=t.id,name=t.name,root=t.root,capacity=t.capacity,purchased=0,paths={}}
        v.trees[#v.trees+1]=out
        array(t.paths,64,function(p)
            exact(p,{id=true,name=true,capacity=true,description=true,perks=true})
            local path={id=p.id,name=p.name,capacity=p.capacity,description=p.description,purchased=0,locked=true,perks={}}
            out.paths[#out.paths+1]=path
            array(p.perks,32,function(k)
                exact(k,{id=true,rank=true,isMajorPerk=true,description=true})
                local perk=copy(k); perk.state=0; path.perks[#path.perks+1]=perk
            end)
        end)
    end)
    need(C.ValidPayload("professionDetails",v,"observed"),"Invalid Details definition")
end
local function catalogue(cat)
    copy(cat) -- Original primitive/depth/visit/key/string guards, one unit only.
    exact(cat,{kind=true,identity=true,build=true,locale=true,definition=true})
    need(text(cat.build) and optional(cat.locale,text),"Invalid catalogue context")
    identity(cat.identity,cat.identity and cat.identity.skillLineID,true)
    if cat.kind=="tree" then return treeDefinition(cat.definition)
    elseif cat.kind=="details" then
        need(cat.identity.skillLineID==2913 and cat.identity.parentID==773 and
            cat.identity.profession==13 and cat.identity.expansionID==11,"Invalid Details catalogue owner")
        detailsDefinition(cat.definition)
    else error("Invalid catalogue kind",0) end
end
local function reference(root,value,owner,build,kind,staged,registry)
    need(int(value.catalog,1) and value.catalog<root.nextCatalog,"Invalid catalogue reference")
    local prepared=registry and registry[value.catalog]
    local cat=prepared and prepared.cat or not registry and (staged and staged[value.catalog] or root.catalogs[value.catalog])
    need(cat,"Dangling/unprepared catalogue reference")
    local paths=prepared and prepared.paths or not registry and catalogue(cat)
    need(cat.kind==kind and cat.build==build and sameIdentity(cat.identity,owner),"Catalogue owner/build mismatch")
    return cat,paths
end
local function mapCoverage(map,expected,validator)
    need(plain(map),"Invalid personal map")
    for key,value in pairs(map) do need(expected[key] and validator(value,key),"Invalid personal map entry") end
end
local function expandTree(root,v,owner,build,id,staged,registry)
    exact(v,{format=true,catalog=true,purchased=true,capacity=true,points=true,locked=true,available=true,
        accountingPolicy=true,accountingEvidence=true})
    need(v.format=="tree-ref-v1","Invalid compact tree format")
    local cat,expected=reference(root,v,owner,build,"tree",staged,registry); local d=cat.definition
    need(d.id==id,"Tree field/catalogue mismatch")
    mapCoverage(v.points,expected,function(n) return int(n) end)
    mapCoverage(v.locked,expected,bool); mapCoverage(v.available,expected,bool)
    local out={id=d.id,name=d.name,root=d.root,paths={},purchased=v.purchased,capacity=v.capacity,
        complete=true,compactSnapshot=true,coverage={discovered=#d.paths,captured=#d.paths,limit=false},
        accountingPolicy=v.accountingPolicy,accountingEvidence=copy(v.accountingEvidence or {})}
    if v.accountingEvidence==nil then out.accountingEvidence=nil end
    local policy=v.accountingPolicy
    need(policy==nil or policy==POLICY,"Invalid compact accounting policy")
    local sum,cap=0,0
    for _,p in ipairs(d.paths) do
        local points,locked,available=v.points[p.id],v.locked[p.id],v.available[p.id]
        need(int(points) and points<=p.capacity,"Missing/out-of-range path points")
        if policy then need(native(d.id,1) and native(d.root,1) and (not locked or points==0) and bool(locked) and bool(available) and native(p.id,1) and
            native(p.capacity) and p.capacity>0 and native(points),"Missing native personal state") end
        sum=sum+points; cap=cap+p.capacity
        out.paths[#out.paths+1]={id=p.id,name=p.name,capacity=p.capacity,purchased=points,
            children=copy(p.children),childrenComplete=true,locked=locked,available=available}
    end
    need(int(v.purchased) and int(v.capacity) and sum==v.purchased and cap==v.capacity,"Compact tree totals mismatch")
    if v.accountingEvidence~=nil then
        local e=v.accountingEvidence
        exact(e,{currencyID=true,spent=true,quantity=true,totalPurchased=true,sourcePin=true})
        need(policy==POLICY and e.currencyID==C.NativeKnowledgeCurrency(owner) and native(e.currencyID,1) and
            native(e.spent) and native(e.quantity) and native(e.totalPurchased) and e.totalPurchased==e.spent and
            v.purchased<=e.totalPurchased and e.sourcePin==PIN,"Invalid compact accounting evidence")
    end
    need(not policy or v.accountingEvidence~=nil,"Missing compact accounting evidence")
    return out
end
local function rawSummary(v,owner)
    exact(v,{format=true,policy=true,configID=true,sourceCounter=true,tabsComplete=true,nativeComplete=true,
        stagedStart=true,stagedEnd=true,stable=true,identity=true,tabs=true})
    need(v.format=="raw-summary-v1" and optional(v.configID,function(n) return int(n,1) end) and
        optional(v.sourceCounter,function(n) return native(n) end) and bool(v.tabsComplete) and
        optional(v.nativeComplete,bool) and optional(v.stagedStart,bool) and optional(v.stagedEnd,bool) and
        optional(v.stable,bool),"Invalid raw summary")
    if v.identity~=nil then
        exact(v.identity,{skillLineID=true,parentID=true,profession=true,expansionID=true})
        for _,key in ipairs(ids) do need(optional(v.identity[key],function(n) return native(n,1) end),"Invalid raw identity") end
    end
    if v.policy~=nil then
        need(v.policy==POLICY and C.NativeKnowledgeCurrency(owner) and v.identity and
            sameIdentity(v.identity,owner) and bool(v.nativeComplete) and
            optional(v.configID,function(n) return native(n,1) end),"Raw summary owner/policy mismatch")
        if v.nativeComplete then need(native(v.configID,1) and native(v.sourceCounter),"Incomplete native context") end
    end
    array(v.tabs,8,function(t)
        exact(t,{id=true,name=true,root=true,coverageComplete=true})
        need(int(t.id,1) and optional(t.name,text) and optional(t.root,function(n) return int(n,1) end) and
            bool(t.coverageComplete),"Invalid raw tab summary")
        if v.policy then need(native(t.id,1) and optional(t.root,function(n) return native(n,1) end) and
            (not v.nativeComplete or t.coverageComplete),"Invalid native tab summary") end
    end)
    return copy(v)
end
local function expandDetails(root,v,owner,build,staged,registry)
    exact(v,{format=true,catalog=true,version=true,skillLineID=true,configID=true,sourceScanAt=true,
        points=true,locked=true,states=true})
    need(v.format=="details-ref-v1","Invalid compact Details format")
    local cat=reference(root,v,owner,build,"details",staged,registry)
    local out={version=v.version,skillLineID=v.skillLineID,configID=v.configID,sourceScanAt=v.sourceScanAt,trees={}}
    local paths,perks={},{}
    for _,t in ipairs(cat.definition.trees) do
        local tree={id=t.id,name=t.name,root=t.root,capacity=t.capacity,purchased=0,paths={}}
        out.trees[#out.trees+1]=tree
        for _,p in ipairs(t.paths) do
            paths[p.id]=true
            local path=copy(p); path.purchased=v.points and v.points[p.id]; path.locked=v.locked and v.locked[p.id]
            tree.paths[#tree.paths+1]=path
            if type(path.purchased)=="number" then tree.purchased=tree.purchased+path.purchased end
            for _,k in ipairs(path.perks) do perks[k.id]=true; k.state=v.states and v.states[k.id] end
        end
    end
    mapCoverage(v.points,paths,function(n) return native(n) end); mapCoverage(v.locked,paths,bool)
    mapCoverage(v.states,perks,function(n) return n==0 or n==2 end)
    need(C.ValidPayload("professionDetails",out,"observed"),"Invalid personal Details snapshot")
    copy(out); return out
end
local function generation(root,g,id,archived,staged,registry)
    local owned=copy(g)
    exact(owned,{generation=true,identity=true,scannedAt=true,fields=true,archivedAt=true,archiveReason=true})
    need(int(owned.generation,1) and int(owned.scannedAt) and plain(owned.fields),"Invalid generation")
    identity(owned.identity,id)
    if archived then need(int(owned.archivedAt) and text(owned.archiveReason),"Invalid archive metadata")
    else need(owned.archivedAt==nil and owned.archiveReason==nil,"Archive metadata on active generation") end
    for key,f in pairs(owned.fields) do
        need(type(key)=="string" and C.ValidPayload(key,nil,"unknown"),"Unregistered field")
        exact(f,{attempt=true,last=true}); attempt(f.attempt)
        local l=f.last
        if l~=nil then
            exact(l,{status=true,value=true,observedAt=true,build=true,generation=true})
            need(successful[l.status] and int(l.observedAt) and text(l.build) and l.generation==owned.generation,"Invalid successful field envelope")
            if l.value~=nil then
                local tid=treeKey(key)
                if tid then l.value=expandTree(root,l.value,owned.identity,l.build,tid,staged,registry)
                elseif key=="knowledgeRaw" then l.value=rawSummary(l.value,owned.identity)
                elseif key=="professionDetails" then l.value=expandDetails(root,l.value,owned.identity,l.build,staged,registry)
                else need(C.ValidPayload(key,l.value,l.status),"Invalid generic payload") end
            else need(l.status~="observed","Missing observed payload") end
        end
        if key=="professionDetails" then need(owned.identity.skillLineID==2913 and owned.identity.parentID==773 and
            owned.identity.profession==13 and owned.identity.expansionID==11,"Invalid Details scope") end
    end
    copy(owned) -- bounded presentation roundtrip; never feed compact evidence to Core.
    return owned
end
local function state(db)
    local h=handles[db]; need(h and h.ready,"Storage handle is not ready"); rootHeader(h.root)
    need(h.root.nextCatalog==h.nextCatalog and h.root.catalogs==h.catalogs and h.root.characters==h.characters and
        h.root.catalogs~=h.root.characters and (h.owners[h.root.catalogs]==nil or h.owners[h.root.catalogs]=="catalogs") and
        (h.owners[h.root.characters]==nil or h.owners[h.root.characters]=="characters"),"Directory ownership drift")
    return h
end
local function recordOwner(guid,id,number) return "r"..#guid..":"..guid..":"..id..":"..number end
local function characterOwned(h,c,guid)
    characterHeader(c)
    need(h.owners[c]=="char:"..guid and h.owners[c.professions]=="professions:"..guid,"Character ownership drift")
end
local function professionOwned(h,p,guid,id)
    professionHeader(p)
    need(h.owners[p]=="profession:"..guid..":"..id and h.owners[p.archives]=="archives:"..guid..":"..id and
        h.counters[p]==p.nextGeneration,"Profession ownership/counter drift")
end
local function audit(owners,t,owner,register)
    copy(t)
    local seen={}
    local function walk(v)
        if type(v)~="table" then return end
        local registered=owners[v]
        need(plain(v) and not seen[v] and (registered==owner or (register and registered==nil)),"Aliased/unregistered record/catalogue ownership")
        seen[v]=true
        if register then owners[v]=owner end
        for _,child in pairs(v) do walk(child) end
    end
    walk(t)
end
local function selected(h,guid,id,number,archived,prepareOnly)
    need(guidKey(guid) and int(id,1),"Invalid selected owner")
    local c=h.root.characters[guid]; if c==nil then return nil,"Character not found" end
    characterOwned(h,c,guid)
    local p=c.professions[id]; if p==nil then return nil,"Profession not found" end
    professionOwned(h,p,guid,id)
    local g
    if archived then g=p.archives[number] else g=p.active end
    if not g or (number~=nil and g.generation~=number) then return nil,"Generation not found" end
    need((h.counters[p]==nil or h.counters[p]==p.nextGeneration) and int(g.generation,1) and g.generation<p.nextGeneration and
        (not archived or g.generation==number) and
        (archived or p.archives[g.generation]==nil),"Invalid generation ownership/counter")
    need(h.owners[g]==recordOwner(guid,id,g.generation),"Selected record ownership drift")
    audit(h.owners,g,recordOwner(guid,id,g.generation))
    local metadata={name=c.name,realm=c.realm,classToken=c.classToken}
    if prepareOnly then return copy(g),metadata,p,g end
    for key,f in pairs(g.fields) do
        local v=f.last and f.last.value
        if (treeKey(key) or key=="professionDetails") and plain(v) and h.root.catalogs[v.catalog] then
            local cat=h.root.catalogs[v.catalog]
            need(h.owners[cat]=="c"..v.catalog,"Catalogue ownership drift")
            audit(h.owners,cat,"c"..v.catalog)
            need(canonical(cat)==h.contents[v.catalog],"Immutable catalogue content drift")
        end
    end
    return generation(h.root,g,id,archived),metadata,p,g
end
local function guarded(fn,...)
    local ok,a,b=pcall(fn,...)
    if not ok then return nil,"Storage rejected: "..tostring(a):sub(1,256) end
    return a,b
end
function S.IsHandle(db) return handles[db]~=nil end
local function ready(root,index,owners,counters,contents)
    local db={}; handles[db]={root=root,index=index or {},ready=true,revision=0,tokens={},
        nextCatalog=root.nextCatalog,catalogs=root.catalogs,characters=root.characters,
        contents=contents or {},
        owners=owners or setmetatable({}, {__mode="k"}),counters=counters or setmetatable({}, {__mode="k"})}
    local o=handles[db].owners; o[root]="root"; o[root.catalogs]="catalogs"; o[root.characters]="characters"
    return db,root
end
function S.New() return ready({schema=2,nextCatalog=1,catalogs={},characters={}}) end
function S.Check(db)
    if not S.IsHandle(db) then return C.Open(db) end
    return guarded(function() state(db); return db end)
end
function S.Revision(db)
    local h=handles[db]; return h and h.ready and h.revision or nil
end
function S.Read(db,guid,id,number,archived)
    if not S.IsHandle(db) then
        local valid,why=C.Open(db); if not valid then return nil,why end
        local c=db.characters[guid]; local p=c and c.professions[id]
        if not p then return nil,"Profession not found" end
        if not archived then return p.active and (number==nil or p.active.generation==number) and p.active or nil,c end
        for _,g in ipairs(p.archives) do if g.generation==number then return g,c end end
        return nil,"Generation not found"
    end
    return guarded(function() return selected(state(db),guid,id,number,archived==true) end)
end
function S.Active(db,guid,id) return S.Read(db,guid,id,nil,false) end
function S.Token(db,guid,id)
    local h=handles[db]; if not h or not h.ready then return nil end
    if not guidKey(guid) or not int(id,1) then return nil end
    local byID=h.tokens[guid]
    if not byID then byID={}; h.tokens[guid]=byID end
    if not byID[id] then byID[id]={} end
    return byID[id]
end

local function localeFor(g,l)
    local e=g.fields.environment; e=e and e.last
    if e and e.status=="observed" and e.observedAt==l.observedAt and e.build==l.build and
        type(e.value)=="table" then return e.value.locale end
end
local function stageCatalog(h,staged,cat)
    local paths=catalogue(cat)
    local key=canonical(cat)
    local id=staged.index[key] or h.index[key]
    if id then
        local prior=staged.catalogs[id] or h.root.catalogs[id]
        need(prior,"Catalogue index drift")
        if not h.validated then
            if not staged.catalogs[id] then
                need(h.owners[prior]=="c"..id,"Catalogue ownership drift")
                audit(h.owners,prior,"c"..id)
            end
            catalogue(prior)
        end
        need(canonical(prior)==key,"Catalogue content drift")
        if h.contents and not staged.catalogs[id] then need(h.contents[id]==key,"Immutable catalogue content drift") end
        if h.validated then need(h.validated[id] and h.validated[id].cat==prior,"Unprepared private catalogue") end
        return id
    end
    id=staged.nextCatalog
    need(int(id,1) and int(id+1,1) and id+1>id,"Catalogue counter overflow")
    need(h.root.catalogs[id]==nil and staged.catalogs[id]==nil,"Catalogue allocation slot occupied")
    staged.nextCatalog=id+1; staged.catalogs[id]=cat; staged.index[key]=id
    if h.validated then h.validated[id]={cat=cat,paths=paths} end
    return id
end
local function compactValue(h,staged,key,v,g,l)
    local tid=treeKey(key)
    if tid then
        local d={id=v.id,name=v.name,root=v.root,paths={}}
        local out={format="tree-ref-v1",purchased=v.purchased,capacity=v.capacity,points={},locked={},available={},
            accountingPolicy=v.accountingPolicy}
        if v.accountingEvidence then
            out.accountingEvidence={}
            for _,k in ipairs({"currencyID","spent","quantity","totalPurchased","sourcePin"}) do
                out.accountingEvidence[k]=v.accountingEvidence[k]
            end
        end
        for _,p in ipairs(v.paths) do
            d.paths[#d.paths+1]={id=p.id,name=p.name,capacity=p.capacity,children=copy(p.children)}
            out.points[p.id]=p.purchased; out.locked[p.id]=p.locked
            out.available[p.id]=p.node and p.node.isAvailable
        end
        out.catalog=stageCatalog(h,staged,{kind="tree",identity=four(g.identity),build=l.build,
            locale=localeFor(g,l),definition=d})
        return out
    elseif key=="knowledgeRaw" then
        local out={format="raw-summary-v1",tabs={}}
        for _,k in ipairs({"policy","configID","sourceCounter","tabsComplete","nativeComplete","stagedStart","stagedEnd","stable"}) do out[k]=v[k] end
        if v.identity then out.identity=four(v.identity) end
        for _,t in ipairs(v.tabs) do out.tabs[#out.tabs+1]={id=t.id,name=t.name,root=t.root,coverageComplete=t.coverageComplete} end
        return out
    elseif key=="professionDetails" then
        local d={trees={}}
        local out={format="details-ref-v1",version=v.version,skillLineID=v.skillLineID,configID=v.configID,
            sourceScanAt=v.sourceScanAt,points={},locked={},states={}}
        for _,t in ipairs(v.trees) do
            local tree={id=t.id,name=t.name,root=t.root,capacity=t.capacity,paths={}}; d.trees[#d.trees+1]=tree
            for _,p in ipairs(t.paths) do
                local path={id=p.id,name=p.name,capacity=p.capacity,description=p.description,perks={}}
                tree.paths[#tree.paths+1]=path; out.points[p.id]=p.purchased; out.locked[p.id]=p.locked
                for _,k in ipairs(p.perks) do
                    path.perks[#path.perks+1]={id=k.id,rank=k.rank,isMajorPerk=k.isMajorPerk,description=k.description}
                    out.states[k.id]=k.state
                end
            end
        end
        out.catalog=stageCatalog(h,staged,{kind="details",identity=four(g.identity),build=l.build,
            locale=localeFor(g,l),definition=d})
        return out
    end
    return copy(v)
end
local function stagedRoot(h,staged)
    return {schema=2,nextCatalog=staged.nextCatalog,catalogs=h.root.catalogs,characters=h.root.characters}
end
local function newStage(h) return {nextCatalog=h.root.nextCatalog,catalogs={},index={}} end
local function write(db,fn)
    local h=handles[db]
    if not h or h.writing then return nil,"Storage write is not ready or is reentrant" end
    h.writing=true
    local a,b=guarded(fn)
    h.writing=nil
    return a,b
end
local function retire(h,guid,id)
    h.revision=h.revision+1
    local t=h.tokens[guid]; if t then if id then t[id]={} else h.tokens[guid]=nil end end
end
function S.Apply(db,character,ident,observations,at,build)
    if not S.IsHandle(db) then return C.Apply(db,character,ident,observations,at,build) end
    return write(db,function()
        local h=state(db)
        -- Actual production preflight, including generation attribution and the entire
        -- rich input's primitive budgets. No compact/native validator substitution.
        local rich,why=C.Apply({schema=1,characters={}},character,ident,observations,at,build)
        need(rich,why)
        local pack=copy({character,ident,observations}); character,ident,observations=pack[1],pack[2],pack[3]
        need(guidKey(character.guid),"Invalid character key")
        local guid,id=character.guid,ident.skillLineID
        local c=h.root.characters[guid]; if c then characterOwned(h,c,guid) end
        local p=c and c.professions[id]
        if p then professionOwned(h,p,guid,id) end
        local old=p and p.active
        if old then selected(h,guid,id,nil,false); need(sameIdentity(old.identity,ident),"Profession identity changed") end
        local number=old and old.generation or p and p.nextGeneration or 1
        need(not p or p.archives[number]==nil,"Generation already archived")
        local nextGeneration=p and p.nextGeneration or 1
        if not old then
            need(int(nextGeneration+1,1) and nextGeneration+1>nextGeneration,"Generation counter overflow")
            nextGeneration=nextGeneration+1
        end
        need(int(h.revision+1) and h.revision+1>h.revision,"Runtime revision overflow")
        local g=old and copy(old) or {generation=number,fields={}}
        g.identity=copy(ident); g.scannedAt=at
        local staged=newStage(h)
        -- Locale must come from the field's own successful interval, never a newer
        -- scan environment paired with a retained old tree/Details field.
        local context={identity=ident,fields={environment=rich.fields.environment}}
        for key,o in pairs(observations) do
            local merge=equipment(key) and C.MergeEquipment or C.Merge
            local f,err=merge(g.fields[key],o,build,number); need(f,err)
            if successful[o.status] and f.last and f.last.value~=nil then
                f.last.value=compactValue(h,staged,key,f.last.value,context,f.last)
            end
            g.fields[key]=f
        end
        local result=generation(stagedRoot(h,staged),g,id,false,staged.catalogs)
        local ownership=setmetatable({}, {__mode="k"})
        audit(ownership,g,recordOwner(guid,id,number),true)
        for cid,cat in pairs(staged.catalogs) do audit(ownership,cat,"c"..cid,true) end
        -- Every possible rejecting/callback operation is above this boundary.
        for cid,cat in pairs(staged.catalogs) do h.root.catalogs[cid]=cat end
        h.root.nextCatalog=staged.nextCatalog
        h.nextCatalog=staged.nextCatalog
        for key,cid in pairs(staged.index) do h.index[key]=cid; h.contents[cid]=key end
        if not c then c={professions={}}; h.root.characters[guid]=c end
        c.name=character.name; c.realm=character.realm
        if character.classToken~=nil then c.classToken=character.classToken end
        if not p then p={archives={}}; c.professions[id]=p end
        p.nextGeneration=nextGeneration; p.active=g
        h.counters[p]=nextGeneration
        h.owners[c]="char:"..guid; h.owners[c.professions]="professions:"..guid
        h.owners[p]="profession:"..guid..":"..id; h.owners[p.archives]="archives:"..guid..":"..id
        for t,owner in pairs(ownership) do h.owners[t]=owner end
        retire(h,guid,id)
        return result
    end)
end
function S.Archive(db,guid,id,at,reason)
    if not S.IsHandle(db) then return C.Archive(db,guid,id,at,reason) end
    local result=write(db,function()
        local h=state(db); need(int(at) and text(reason),"Invalid archive metadata")
        local g,_,p=selected(h,guid,id,nil,false); need(g,"No active generation")
        need(p.archives[g.generation]==nil,"Archive generation occupied")
        local archived=copy(p.active); archived.archivedAt=at; archived.archiveReason=reason
        generation(h.root,archived,id,true)
        local ownership=setmetatable({}, {__mode="k"}); audit(ownership,archived,recordOwner(guid,id,g.generation),true)
        need(int(h.revision+1) and h.revision+1>h.revision,"Runtime revision overflow")
        p.archives[archived.generation]=archived; p.active=nil
        for t,owner in pairs(ownership) do h.owners[t]=owner end
        retire(h,guid,id); return true
    end)
    return result==true
end
function S.Delete(db,scope,confirmed)
    if not S.IsHandle(db) then return C.Delete(db,scope,confirmed) end
    local result=write(db,function()
        need(confirmed==true and plain(scope) and guidKey(scope.guid),"Deletion not confirmed")
        local h=state(db); local c=h.root.characters[scope.guid]; need(c,"Character not found"); characterOwned(h,c,scope.guid)
        need(int(h.revision+1) and h.revision+1>h.revision,"Runtime revision overflow")
        if scope.character==true then h.root.characters[scope.guid]=nil; retire(h,scope.guid); return true end
        need(int(scope.id,1) and int(scope.generation,1),"Invalid delete selection")
        local p=c.professions[scope.id]; need(p,"Profession not found"); professionHeader(p)
        local active=p.active and p.active.generation==scope.generation
        local g=selected(h,scope.guid,scope.id,scope.generation,not active); need(g,"Generation not found")
        if active then p.active=nil else p.archives[scope.generation]=nil end
        retire(h,scope.guid,scope.id); return true
    end)
    return result==true
end

-- Directory work never invokes the primitive whole-graph copier. Unit work does.
-- The ownership registry includes wrappers as well as every nested unit table.
local function claim(seen,t)
    need(plain(t) and not seen[t],"Cyclic/aliased storage ownership"); seen[t]=true
end
local function claimUnit(seen,t)
    copy(t)
    local function walk(v)
        if type(v)~="table" then return end
        claim(seen,v); for _,child in pairs(v) do walk(child) end
    end
    walk(t)
end
local function legacyStructure(g)
    exact(g,{generation=true,identity=true,scannedAt=true,fields=true,archivedAt=true,archiveReason=true})
    for _,f in pairs(g.fields) do
        exact(f,{attempt=true,last=true}); attempt(f.attempt)
        if f.last then exact(f.last,{status=true,value=true,observedAt=true,build=true,generation=true}) end
    end
end
local function migrationRecord(h,input)
    local g,out,staged,cursor
    return function()
        if not g then
            legacyStructure(input); g=copy(input); out=copy(g); staged=newStage(h)
        end
        local key,f=next(g.fields,cursor)
        if key~=nil then
            cursor=key
            if f.last and f.last.value~=nil then
                out.fields[key].last.value=compactValue(h,staged,key,f.last.value,g,f.last)
            end
            return nil -- one field, at most one catalogue, this Step
        end
        local presentation=generation(stagedRoot(h,staged),out,g.identity.skillLineID,g.archivedAt~=nil,staged.catalogs,h.validated)
        need(g.generation==presentation.generation and g.scannedAt==presentation.scannedAt and
            g.archivedAt==presentation.archivedAt and g.archiveReason==presentation.archiveReason and
            canonical(g.identity)==canonical(presentation.identity),"Generation migration mismatch")
        -- Compare the retained semantic projection, not omitted native proof.
        for key,f in pairs(g.fields) do
            local l=f.last; local expanded=presentation.fields[key].last
            need(canonical(f.attempt)==canonical(presentation.fields[key].attempt) and (l==nil)==(expanded==nil),"Field migration mismatch")
            if l then need(l.status==expanded.status and l.observedAt==expanded.observedAt and
                l.build==expanded.build and l.generation==expanded.generation,"Independent field time migration mismatch") end
            if l and l.value~=nil then
                if treeKey(key) then
                    local a,b=l.value,expanded.value
                    need(a.id==b.id and a.name==b.name and a.root==b.root and a.purchased==b.purchased and
                        a.capacity==b.capacity and a.accountingPolicy==b.accountingPolicy and #a.paths==#b.paths,"Tree migration mismatch")
                    if a.accountingEvidence then
                        need(b.accountingEvidence,"Missing migrated accounting summary")
                        for _,key in ipairs({"currencyID","spent","quantity","totalPurchased","sourcePin"}) do
                            need(a.accountingEvidence[key]==b.accountingEvidence[key],"Accounting summary migration mismatch")
                        end
                    else need(b.accountingEvidence==nil,"Invented accounting summary") end
                    for i,p in ipairs(a.paths) do
                        local q=b.paths[i]
                        need(p.id==q.id and p.name==q.name and p.capacity==q.capacity and p.purchased==q.purchased and
                            p.locked==q.locked and (p.node and p.node.isAvailable)==q.available and
                            canonical(p.children)==canonical(q.children),"Path migration mismatch")
                    end
                elseif key=="knowledgeRaw" then
                    need(canonical(compactValue(h,staged,key,l.value,g,l))==canonical(expanded.value),"Raw migration mismatch")
                else need(canonical(l.value)==canonical(expanded.value),"Payload migration mismatch") end
            end
        end
        for id,cat in pairs(staged.catalogs) do h.root.catalogs[id]=cat end
        for key,id in pairs(staged.index) do h.index[key]=id end
        h.root.nextCatalog=staged.nextCatalog
        return out
    end
end

function S.NewOpenJob(raw)
    local job={status="running",completed=false,steps=0,work={directories=0,edges=0,units=0,maxEdges=0,maxUnits=0}}
    local candidate,index,source,seen,stack,directories,verify,busy,child,wrappers,wrapperIndex,owners,counters,validated,contents
    local migration=false
    local function stop(status,why)
        job.status=status; job.reason=why; job.completed=status=="complete"
        if status~="complete" then job.result=nil; job.savedRoot=nil end
        if child and child.status=="running" then child:Cancel() end
        candidate=nil; index=nil; source=nil; seen=nil; stack=nil; directories=nil; child=nil; wrappers=nil; owners=nil; counters=nil; validated=nil; contents=nil
        return job
    end
    function job:Cancel()
        if self.status=="running" then stop("cancelled","Storage initialization cancelled; original saved data retained") end
        return self
    end
    local function directory(input,output,visit)
        claim(seen,input)
        local d={input=input,output=output,visit=visit,entries={}}
        directories[#directories+1]=d; stack[#stack+1]=d
    end
    local function wrapper(input)
        local entries={}; for k,v in pairs(input) do entries[k]=v end
        wrappers[#wrappers+1]={input=input,entries=entries}
    end
    local function record(input,p,id,archived,key,guid)
        local migrate
        stack[#stack+1]={unit=function()
            local g
            if migration then
                migrate=migrate or migrationRecord({root=candidate,index=index,validated=validated},input)
                g=migrate()
                if not g then return false end
            else
                claimUnit(seen,input); g=copy(input); generation(candidate,g,id,archived,nil,validated)
            end
            need(g.generation<p.nextGeneration and (not archived or key==g.generation),"Invalid record counter/archive key")
            audit(owners,g,recordOwner(guid,id,g.generation),true)
            if archived then need(not p.active or p.active.generation~=key,"Duplicate generation"); p.archives[key]=g
            else need(p.archives[g.generation]==nil,"Duplicate generation"); p.active=g end
        end}
    end
    local function professions(input,out,guid)
        directory(input,out,function(id,p)
            need(int(id,1),"Invalid profession key"); professionHeader(p); claim(seen,p); wrapper(p)
            local target={nextGeneration=p.nextGeneration,archives={}}; out[id]=target
            counters[target]=p.nextGeneration
            owners[target]="profession:"..guid..":"..id; owners[target.archives]="archives:"..guid..":"..id
            if p.active~=nil then record(p.active,target,id,false,nil,guid) end
            directory(p.archives,target.archives,function(key,g)
                need(int(key,1),"Invalid archive key")
                record(g,target,id,true,migration and g.generation or key,guid)
            end)
        end)
    end
    local function setup()
        if raw==nil then job.result,job.savedRoot=S.New(); return stop("complete") end
        need(plain(raw),"Unsupported or invalid CraftArmyDB; writes disabled (no reset)")
        if raw.schema==1 then
            local valid,why=C.Open(raw); need(valid,why) -- required immediate legacy failure
            exact(raw,{schema=true,characters=true})
            source=copy(raw); migration=true
            candidate={schema=2,nextCatalog=1,catalogs={},characters={}}
        elseif raw.schema==2 then rootHeader(raw); source=raw
            candidate={schema=2,nextCatalog=raw.nextCatalog,catalogs={},characters={}}
        else error("Unsupported or invalid CraftArmyDB; writes disabled (no reset)",0) end
        index={}; seen={}; stack={}; directories={}; wrappers={}; validated={}; contents={}; owners=setmetatable({}, {__mode="k"}); counters=setmetatable({}, {__mode="k"}); claim(seen,source); wrapper(source)
        directory(source.characters,candidate.characters,function(guid,c)
            need(guidKey(guid),"Invalid character key"); characterHeader(c); claim(seen,c); wrapper(c)
            local out={name=c.name,realm=c.realm,classToken=c.classToken,professions={}}; candidate.characters[guid]=out
            owners[out]="char:"..guid; owners[out.professions]="professions:"..guid
            professions(c.professions,out.professions,guid)
        end)
        -- Catalogues finish before any record references are validated (LIFO stack).
        if not migration then directory(source.catalogs,candidate.catalogs,function(id,cat)
            need(int(id,1) and id<source.nextCatalog,"Invalid catalogue key/counter")
            stack[#stack+1]={unit=function()
                claimUnit(seen,cat); local owned=copy(cat); local paths=catalogue(owned); candidate.catalogs[id]=owned
                validated[id]={cat=owned,paths=paths}
                audit(owners,owned,"c"..id,true)
                local key=canonical(owned); contents[id]=key; if not index[key] then index[key]=id end
            end}
        end) end
    end
    local ok,why=pcall(setup)
    if not ok then return stop("failed","Storage initialization rejected: "..tostring(why):sub(1,256)) end
    local function unit()
        if child then
            child:Step()
            if child.status=="complete" then
                job.work.candidate=child.work
                job.result=child.result; job.savedRoot=child.savedRoot; return stop("complete")
            elseif child.status~="running" then error(child.reason or "Candidate validation failed",0) end
            return
        end
        local item=stack[#stack]
        if item then
            if item.unit then
                job.work.units=job.work.units+1; job.work.maxUnits=1
                if item.unit()~=false then stack[#stack]=nil end
                return
            end
            local n=0
            -- A child queued by this directory is processed on a later Step.
            while n<128 do
                local k,v=next(item.input,item.cursor)
                if k==nil then
                    for i=#stack,1,-1 do if stack[i]==item then table.remove(stack,i); break end end
                    job.work.directories=job.work.directories+1; break
                end
                n=n+1; item.cursor=k; item.entries[k]=v; item.count=(item.count or 0)+1; item.visit(k,v)
            end
            job.work.edges=job.work.edges+n; job.work.maxEdges=math.max(job.work.maxEdges,n); return
        end
        -- Revisit directory edges incrementally to reject key/pointer drift during open.
        verify=verify or 1
        local d=directories[verify]
        if d then
            local n=0
            while n<128 do
                local k,v=next(d.input,d.verifyCursor)
                if k==nil then need((d.verifyCount or 0)==(d.count or 0),"Directory drift"); verify=verify+1; break end
                n=n+1; d.verifyCursor=k; d.verifyCount=(d.verifyCount or 0)+1
                need(d.entries[k]==v,"Directory drift")
            end
            job.work.edges=job.work.edges+n; job.work.maxEdges=math.max(job.work.maxEdges,n); return
        end
        wrapperIndex=wrapperIndex or 1
        local w=wrappers[wrapperIndex]
        if w then
            need(plain(w.input),"Wrapper drift")
            for k,v in pairs(w.entries) do need(w.input[k]==v,"Wrapper drift") end
            for k,v in pairs(w.input) do need(w.entries[k]==v,"Wrapper drift") end
            wrapperIndex=wrapperIndex+1; return
        end
        if migration then
            child=S.NewOpenJob(candidate); need(child.status=="running","Candidate opening failed")
            job.phase="candidate-validation"; return
        end
        job.result,job.savedRoot=ready(candidate,index,owners,counters,contents); return stop("complete")
    end
    function job:Step()
        if self.status~="running" then return self end
        if busy then return stop("failed","Reentrant storage initialization") end
        busy=true; self.steps=self.steps+1
        local ok,why=pcall(unit)
        busy=false
        if not ok and self.status=="running" then stop("failed","Storage initialization rejected: "..tostring(why):sub(1,256)) end
        if self.status=="failed" or self.status=="cancelled" then stop(self.status,self.reason) end
        return self
    end
    return job
end

function S.NewIterator(db,archived)
    local job={status="running",steps=0,work={edges=0,maxEdges=0,items=0}}
    local h,revision,stack,busy,pending
    local function stop(status,why)
        job.status=status; job.reason=why; job.item=nil; h=nil; stack=nil; pending=nil; return job
    end
    function job:Cancel() if self.status=="running" then stop("cancelled","Iterator cancelled") end; return self end
    local ok=pcall(function()
        h=state(db); revision=h.revision; stack={{kind="characters",input=h.root.characters}}
    end)
    if not ok then return stop("failed","Ready storage handle required") end
    local function prepare(guid,id,number)
        local g,c=selected(h,guid,id,number,archived==true,true)
        need(g,"Selected generation unavailable")
        local dependencies,seen={},{}
        need(plain(g.fields),"Invalid record fields")
        for key,f in pairs(g.fields) do
            local v=f.last and f.last.value
            if (treeKey(key) or key=="professionDetails") and v~=nil then
                need(plain(v) and int(v.catalog,1),"Invalid catalogue reference")
                if not seen[v.catalog] then dependencies[#dependencies+1]=v.catalog; seen[v.catalog]=true end
            end
        end
        pending={guid=guid,id=id,g=g,c=c,registry={},dependencies=dependencies,cursor=1}
    end
    function job:Step()
        self.item=nil
        if self.status~="running" then return self end
        if busy then return stop("failed","Reentrant storage iterator") end
        busy=true; self.steps=self.steps+1
        local ok,why=pcall(function()
            need(state(db)==h and h.revision==revision,"Iterator revision changed")
            if pending then
                local p=pending
                local id=p.dependencies[p.cursor]
                if id~=nil then
                    p.cursor=p.cursor+1
                    local cat=h.root.catalogs[id]; need(cat,"Missing catalogue reference")
                    need(h.owners[cat]=="c"..id,"Catalogue ownership drift")
                    audit(h.owners,cat,"c"..id)
                    local owned=copy(cat); local paths=catalogue(owned)
                    need(canonical(owned)==h.contents[id],"Immutable catalogue content drift")
                    p.registry[id]={cat=owned,paths=paths}
                    return
                end
                local g=generation(h.root,p.g,p.id,archived==true,nil,p.registry)
                self.item={guid=p.guid,c=p.c,id=p.id,g=g,archived=archived==true}
                self.work.items=self.work.items+1; pending=nil; return
            end
            local edges=0
            while edges<128 do
                local d=stack[#stack]
                if not d then self.status="complete"; stack=nil; h=nil; break end
                local key,v=next(d.input,d.cursor)
                if key==nil then stack[#stack]=nil
                else
                    d.cursor=key; edges=edges+1
                    if d.kind=="characters" then
                        need(guidKey(key),"Invalid character key"); characterHeader(v)
                        stack[#stack+1]={kind="professions",input=v.professions,guid=key}
                    elseif d.kind=="professions" then
                        need(int(key,1),"Invalid profession key"); professionHeader(v)
                        if archived then stack[#stack+1]={kind="archives",input=v.archives,guid=d.guid,id=key}
                        elseif v.active then
                            prepare(d.guid,key,nil); break
                        end
                    else
                        need(int(key,1),"Invalid archive key")
                        prepare(d.guid,d.id,key); break
                    end
                end
            end
            self.work.edges=self.work.edges+edges; self.work.maxEdges=math.max(self.work.maxEdges,edges)
        end)
        busy=false
        if not ok and self.status=="running" then return stop("failed","Iterator rejected: "..tostring(why):sub(1,256)) end
        if self.status=="failed" or self.status=="cancelled" then return stop(self.status,self.reason) end
        return self
    end
    return job
end

-- A frame budget is an observed boundary BETWEEN indivisible job units, not
-- preemption or a promise that a native callback finishes within two milliseconds.
function S.NewFrameBatch(env)
    local batch={mode="clockless-one-step",status="ready",
        work={frames=0,steps=0,lastSteps=0,maxSteps=0}}
    local clock,seconds,lastTime,busy,failed,site
    local function fail(reason)
        failed=true; batch.status="failed"; batch.reason=reason
        return false,reason
    end
    local setup=pcall(function()
        if type(env.debugprofilestop)=="function" then clock=env.debugprofilestop; batch.mode="profile-ms"
        elseif type(env.GetTimePreciseSec)=="function" then clock=env.GetTimePreciseSec; seconds=true; batch.mode="precise-seconds"
        end
    end)
    if not setup then fail("Frame batch clock selection failed") end
    local function alive() need(not failed,"Frame batch reentry/failure") end
    local function readClock()
        site="clock"; local value=clock(); alive(); site=nil
        need(C.Finite(value),"Frame batch clock invalid")
        if seconds then value=value*1000; need(C.Finite(value),"Frame batch clock overflow") end
        need(lastTime==nil or (value>=lastTime and C.Finite(value-lastTime)),"Frame batch clock backward/overflow")
        lastTime=value; return value
    end
    function batch:Step(job,guard)
        if failed then return false,self.reason end
        if busy then return fail("Frame batch reentry") end
        busy=true; self.status="running"; self.work.frames=self.work.frames+1
        self.work.lastSteps=0; self.work.lastElapsed=nil
        local ok,reason=pcall(function()
            need(type(job)=="table" and type(job.Step)=="function" and type(guard)=="function","Frame batch invalid job/guard")
            local function allowed()
                site="guard"; local value=guard(); alive(); site=nil
                if value~=true then self.status="paused"; return false end
                return true
            end
            if not allowed() then return end
            local started=clock and readClock()
            local limit=clock and 16 or 1
            for _=1,limit do
                if job.status~="running" then self.status="terminal"; return end
                if not allowed() then return end
                if clock then
                    local elapsed=readClock()-started
                    need(C.Finite(elapsed),"Frame batch elapsed overflow")
                    self.work.lastElapsed=elapsed
                    if elapsed>=2 then self.status="budget"; return end
                    -- A clock may reenter cancellation/context handling.
                    if not allowed() then return end
                end
                self.work.lastSteps=self.work.lastSteps+1; self.work.steps=self.work.steps+1
                self.work.maxSteps=math.max(self.work.maxSteps,self.work.lastSteps)
                site="job"; job:Step(); alive(); site=nil
                if clock then
                    local elapsed=readClock()-started
                    need(C.Finite(elapsed),"Frame batch elapsed overflow")
                    self.work.lastElapsed=elapsed
                end
                if not allowed() then return end
                if job.status~="running" then self.status="terminal"; return end
                if clock and self.work.lastElapsed>=2 then self.status="budget"; return end
            end
            self.status=clock and "unit-cap" or "clockless-one-step"
        end)
        busy=false
        if not ok or failed then
            return fail(failed and self.reason or (site and ("Frame batch "..site.." failure") or
                ("Frame batch rejected: "..tostring(reason):sub(1,160))))
        end
        return true,self.work.lastSteps
    end
    return batch
end
