local _, NS = ...
local C, Collectors = NS.Core, NS.Collectors
local Check = {}
NS.KnowledgeCheck = Check
local MAX = 2147483647
local PIN = "297d7aaaa736f346b3e036f38ee088eaf7f8c07f"
local WARNING = "Evidence only / provisional; NOT verified all-rank costs; no snapshot writes."
local BOUNDS = "Bounds: tabs8 paths/tree64 children16 node entry lists/maps32 currencies/tree64 costs16; text262144 bytes/4096 lines; summary reserve4096 bytes."
local function integer(v, low) return C.Integer(v, low or 0) and v<=MAX end
local function plain(v) return type(v)=="table" and getmetatable(v)==nil end
local function clean(v, limit)
    if type(v)~="string" then return nil end
    return (v:sub(1,limit or 256):gsub("[%c|]"," "))
end
local function observation(v, status, valid)
    if status~="observed" then return {status=status} end
    if v==nil then return {status="nil"} end
    if not valid(v) then return {status="invalid"} end
    return {status="observed",value=v}
end
local function number(v, low) return observation(v,"observed",function(x) return integer(x,low) end) end
local function boolean(v) return observation(v,"observed",function(x) return type(x)=="boolean" end) end
local function good(o) return o and o.status=="observed" end
local function value(o) if good(o) then return o.value end end
-- Unlike Collectors.Call, this never constructs/retains an error payload.
local function read(env,path,...)
    local fn=Collectors.Resolve(env,path)
    if type(fn)~="function" then return nil,"unsupported" end
    local ok,v=pcall(fn,...)
    if not ok then return nil,"error" end
    if v==nil then return nil,"nil" end
    return v,"observed"
end
local function scalar(env,path,low,...)
    local v,s=read(env,path,...)
    return observation(v,s,function(x) return integer(x,low) end)
end
-- Inspect at most limit+1 keys, then a bounded dense prefix. Never use # on API lists.
local function array(raw,status,limit,project,unique)
    local out={items={},complete=true,flags={},inspected=0,count=0}
    local function bad(why) out.flags[why]=true; out.complete=false end
    if status~="observed" then bad(status); out.status=status; return out end
    if raw==nil then bad("nil"); out.status="nil"; return out end
    if type(raw)~="table" then bad("invalid"); out.status="invalid"; return out end
    if getmetatable(raw)~=nil then bad("metatable"); out.status="metatable"; return out end
    local key,maxIndex=nil,0
    while true do
        key=next(raw,key)
        if key==nil then break end
        out.inspected=out.inspected+1
        if out.inspected>limit then bad("truncated"); break end
        if not integer(key,1) or key>limit then
            bad("keyed"); if integer(key,1) and key>limit then bad("truncated") end
        elseif key>maxIndex then maxIndex=key end
    end
    out.count=out.inspected -- Exact only when not truncated; otherwise a lower bound.
    local seen={}
    for i=1,limit do
        local v=rawget(raw,i)
        if v==nil then
            if i<=maxIndex then bad("sparse") end
        else
            local item,valid,identity=project(v)
            out.items[#out.items+1]={index=i,value=item,status=valid and "observed" or "invalid"}
            if not valid then bad("invalid") end
            if unique and identity~=nil then
                if seen[identity] then bad("duplicate") end
                seen[identity]=true
            end
        end
    end
    out.status=out.complete and (#out.items==0 and "empty" or "observed") or "incomplete"
    return out
end
local function ids(raw,status,limit)
    return array(raw,status,limit,function(v)
        local ok=integer(v,1); return ok and v or nil,ok,ok and v or nil
    end,true)
end
local function costs(raw,status)
    return array(raw,status,16,function(v)
        if not plain(v) then return {},false end
        local o={ID=number(v.ID,1),amount=number(v.amount)}
        return o,good(o.ID) and good(o.amount),value(o.ID)
    end,true)
end
local function increased(raw)
    local out={items={},complete=true,status="observed",inspected=0}
    if not plain(raw) then
        out.complete=false
        out.status=raw==nil and "nil" or type(raw)=="table" and getmetatable(raw)~=nil and "metatable" or "invalid"
        return out
    end
    local key=nil
    while true do
        local v; key,v=next(raw,key)
        if key==nil then break end
        out.inspected=out.inspected+1
        if out.inspected>32 then out.complete=false; out.status="truncated"; break end
        if not integer(key,1) or not integer(v) then out.complete=false; out.status="invalid"
        else out.items[#out.items+1]={entryID=key,ranks=v} end
    end
    table.sort(out.items,function(a,b) return a.entryID<b.entryID end)
    if out.complete and #out.items==0 then out.status="empty" end
    return out
end
local function entryRank(raw)
    if raw==nil then return {status="nil",nullable=true} end
    if not plain(raw) then return {status="invalid"} end
    local o={entryID=number(raw.entryID,1),rank=number(raw.rank)}
    o.status=good(o.entryID) and good(o.rank) and "observed" or "invalid"
    return o
end
local nodeNumbers={"ID","type","flags","currentRank","activeRank","ranksPurchased","ranksIncreased","maxRanks","totalMaxRanks"}
local function node(raw,status)
    local o={status=status,complete=false}
    if status~="observed" or not plain(raw) then
        if status=="observed" then o.status="invalid" end
        return o
    end
    o.complete=true
    for _,key in ipairs(nodeNumbers) do o[key]=number(raw[key],key=="ID" and 1 or 0); if not good(o[key]) then o.complete=false end end
    o.isAvailable=boolean(raw.isAvailable); if not good(o.isAvailable) then o.complete=false end
    o.activeEntry=entryRank(raw.activeEntry); o.nextEntry=entryRank(raw.nextEntry)
    if o.activeEntry.status=="invalid" or o.nextEntry.status=="invalid" then o.complete=false end
    o.entryIDs=ids(raw.entryIDs,"observed",32)
    o.entryIDsWithCommittedRanks=ids(raw.entryIDsWithCommittedRanks,"observed",32)
    o.entryIDToRanksIncreased=increased(raw.entryIDToRanksIncreased)
    if not o.entryIDs.complete or not o.entryIDsWithCommittedRanks.complete or not o.entryIDToRanksIncreased.complete then o.complete=false end
    return o
end
local function entry(env,config,id)
    if not good(id) then return {status="blocked",complete=false} end
    local raw,s=read(env,"C_Traits.GetEntryInfo",config,id.value)
    local o={status=s,complete=false}
    if s~="observed" or not plain(raw) then if s=="observed" then o.status="invalid" end; return o end
    o.maxRanks=number(raw.maxRanks); o.type=number(raw.type); o.definitionID=number(raw.definitionID,1)
    o.entryCost=costs(raw.entryCost,raw.entryCost==nil and "nil" or "observed")
    o.complete=good(o.maxRanks) and good(o.type) and good(o.definitionID) and o.entryCost.complete
    return o
end
local function candidate(p)
    local n,u,s=p.node,p.unlock,p.spend
    if not n.complete or not u.complete or not s.complete or not p.children.complete or not p.costs.complete or not good(p.spendCurrency) then return nil,"missing dependent data" end
    local un,sp=value(p.unlockID),value(p.spendID)
    if not un or not sp or un==sp or #n.entryIDs.items~=2 then return nil,"not exactly distinct unlock/spend entries" end
    local found={}
    for _,row in ipairs(n.entryIDs.items) do found[row.value]=true end
    if not found[un] or not found[sp] then return nil,"unlock/spend absent from node entries" end
    for _,row in ipairs(n.entryIDsWithCommittedRanks.items) do
        if not found[row.value] then return nil,"committed entry absent from node entries" end
    end
    for _,row in ipairs(n.entryIDToRanksIncreased.items) do
        if not found[row.entryID] then return nil,"increased entry absent from node entries" end
    end
    for _,rank in ipairs({n.activeEntry,n.nextEntry}) do
        if rank.status=="observed" and not found[value(rank.entryID)] then return nil,"active/next entry absent from node entries" end
    end
    local unlock,spend=value(u.maxRanks),value(s.maxRanks)
    local purchased,current,inc,max=value(n.ranksPurchased),value(n.currentRank),value(n.ranksIncreased),value(n.maxRanks)
    if (unlock~=0 and unlock~=1) or inc~=0 or current~=purchased or max~=unlock+spend then return nil,"rank guards failed" end
    for _,row in ipairs(n.entryIDToRanksIncreased.items) do if row.ranks~=0 then return nil,"increased entry ranks" end end
    local points=purchased>0 and purchased-unlock or 0
    local capacity=max-unlock
    if not integer(points) or not integer(capacity) or points>capacity then return nil,"rank candidate outside capacity" end
    return {points=points,capacity=capacity},"candidate rank points/capacity; NOT verified all-rank costs"
end
local function unitCost(p)
    if not p.costs.complete or not p.unlock.entryCost or not p.spend.entryCost or
        not p.unlock.entryCost.complete or not p.spend.entryCost.complete or not good(p.spendCurrency) then return "unknown: unavailable cost/currency evidence" end
    local zero,multiple,alternate,nonUnit=false,false,false,false
    for _,list in ipairs({p.costs,p.unlock.entryCost,p.spend.entryCost}) do
        if #list.items>1 then multiple=true end
        for _,row in ipairs(list.items) do
            if value(row.value.amount)==0 then zero=true end
            if value(row.value.amount)~=1 then nonUnit=true end
            if value(row.value.ID)~=value(p.spendCurrency) then alternate=true end
        end
    end
    local flags=""
    if zero then flags=flags.."; zero amount observed" end
    if multiple then flags=flags.."; multiple costs observed" end
    if alternate then flags=flags.."; alternate currency observed" end
    if nonUnit then flags=flags.."; non-unit amount observed" end
    -- This intentionally narrow consistency observation is NOT a cost rule.
    if #p.unlock.entryCost.items>0 or #p.spend.entryCost.items>0 then return "unknown: alternate/entry-specific costs (possibly variable)"..flags end
    if #p.costs.items~=1 then return "unknown: multiple or empty node costs"..flags end
    local cost=p.costs.items[1].value
    if value(cost.amount)==0 then return "inconsistent: zero current node cost"..flags end
    if value(cost.ID)~=value(p.spendCurrency) or value(cost.amount)~=1 then return "inconsistent: alternate currency or non-unit current cost"..flags end
    return "consistent current unit cost only; other ranks UNVERIFIED"
end
local function boundary(env,ctx)
    if not ctx then return {status="blocked"} end
    local out={status="observed",stagingAPI="C_Traits.ConfigHasStagedChanges",configID=number(ctx.config,1),sourceCounter=number(ctx.sourceCounter),
        staged=boolean(ctx.staged),skillLineID=number(ctx.identity.skillLineID,1),
        parentID=number(ctx.identity.parentID,1),profession=number(ctx.identity.profession,1),expansionID=number(ctx.identity.expansionID)}
    -- Context supplies the attribution token; keep the explicit staging API status
    -- as well (Context intentionally discards that status).
    if good(out.configID) then
        local v,s=read(env,"C_Traits.ConfigHasStagedChanges",ctx.config)
        out.stagingRead=observation(v,s,function(x) return type(x)=="boolean" end)
    end
    return out
end
local PROFESSION_MODE={}
local function validContext(ctx,mode)
    if mode==PROFESSION_MODE then
        if not ctx or not integer(ctx.config,1) or not integer(ctx.sourceCounter) or not plain(ctx.identity) then return false end
        local i=ctx.identity
        local map=NS.Data.expansions[i.skillLineID]
        return map~=nil and NS.Data.families[i.profession]~=nil and i.parentID==map.parentID and
            i.profession==map.profession and i.expansionID==11 and map.expansionID==11
    end
    return ctx and integer(ctx.config,1) and integer(ctx.sourceCounter) and ctx.identity.skillLineID==2913 and
        ctx.identity.parentID==773 and ctx.identity.profession==13 and ctx.identity.expansionID==11
end
local function blank()
    return {version=1,sourcePin=PIN,tabs={},captureComplete=false,stable=false,outputTruncated=false,
        start={status="not attempted"},finish={status="not attempted"},
        runtimeStart={status="unavailable"},runtimeEnd={status="not attempted"},
        discovered=0,captured=0,reconciliation={status="unknown",reason="capture incomplete"},allRankCosts="unverified"}
end
-- unit returns to the outer Step, never through any of the per-API pcalls.
local function capture(env,runtime,r,unit,mode)
    if not plain(runtime) or not integer(runtime.revision) or not integer(runtime.serial) then r.reason="Existing runtime collector token unavailable"; unit("metadata","runtime unavailable"); return end
    r.runtimeStart={status="observed",revision=runtime.revision,serial=runtime.serial}
    local localCollector=Collectors.New(env,nil)
    local start=localCollector:Context() -- The only reused collector operation, with Same below.
    r.start=boundary(env,start)
    if not validContext(start,mode) then
        r.runtimeEnd={status="observed",revision=integer(runtime.revision) and runtime.revision or nil,serial=integer(runtime.serial) and runtime.serial or nil}
        r.reason=mode==PROFESSION_MODE and "Own ready Midnight crafting context/config/sourceCounter unavailable" or "Own ready Midnight Inscription context/config/sourceCounter unavailable"; unit("metadata","context unavailable"); return
    end
    r.timeStart=scalar(env,"GetServerTime",0)
    local locale,ls=read(env,"GetLocale"); r.locale={status=ls,value=clean(locale,32)}
    if ls=="observed" and not r.locale.value then r.locale.status="invalid" end
    local fn=Collectors.Resolve(env,"GetBuildInfo")
    r.build={status="unsupported"}
    if type(fn)=="function" then
        local ok,v,b,date,interface=pcall(fn)
        if ok then
            r.build={status="observed",version=clean(v,64),build=clean(b,64),interface=number(interface,1)}
            if not r.build.version or not r.build.build then r.build.status="invalid" end
        else r.build.status="error" end
    end
    local complete=true
    if not good(r.timeStart) or r.locale.status~="observed" or r.build.status~="observed" or not good(r.build.interface) then complete=false end
    local tabIDs,ts=read(env,"C_ProfSpecs.GetSpecTabIDsForSkillLine",start.identity.skillLineID)
    r.tabIDs=ids(tabIDs,ts,8)
    if not r.tabIDs.complete or #r.tabIDs.items==0 then complete=false end
    local globalSeen={}
    unit("metadata","start boundary and metadata")
    for _,tabRow in ipairs(r.tabIDs.items) do
        local id=tabRow.value
        if id then
            local t={id=id,paths={},discovered=0,captured=0,coverageComplete=true,flags={}}
            r.tabs[#r.tabs+1]=t
            local info,is=read(env,"C_ProfSpecs.GetTabInfo",id)
            t.infoStatus=is; t.name=plain(info) and clean(info.name) or nil
            if not t.name then t.infoStatus=is=="observed" and "invalid" or is; t.coverageComplete=false end
            t.root=scalar(env,"C_ProfSpecs.GetRootPathForTab",1,id)
            local raw,cs=read(env,"C_Traits.GetTreeCurrencyInfo",start.config,id,true)
            t.currencies=array(raw,cs,64,function(row)
                if not plain(row) then return {},false end
                local v={traitCurrencyID=number(row.traitCurrencyID,1),quantity=number(row.quantity),spent=number(row.spent),maxQuantity=number(row.maxQuantity)}
                return v,good(v.traitCurrencyID) and good(v.quantity) and good(v.spent) and (row.maxQuantity==nil or good(v.maxQuantity)),value(v.traitCurrencyID)
            end,true)
            if not t.currencies.complete or not good(t.root) then t.coverageComplete=false end
            local queue,localSeen={},{}
            local function discover(pathID)
                if localSeen[pathID] then t.flags.cycleOrDuplicate=true; t.coverageComplete=false; return end
                localSeen[pathID]=true; t.discovered=t.discovered+1
                if globalSeen[pathID] then
                    local owner=globalSeen[pathID]
                    t.flags.sharedOwnership=true; t.coverageComplete=false
                    owner.flags.sharedOwnership=true; owner.coverageComplete=false
                    complete=false; return
                end
                globalSeen[pathID]=t
                r.discovered=r.discovered+1
                if #queue>=64 then t.flags.pathLimit=true; t.coverageComplete=false; return end
                queue[#queue+1]=pathID
            end
            if good(t.root) then discover(t.root.value) end
            local cursor=1
            unit("tab","currency and root")
            while cursor<=#queue do
                local pathID=queue[cursor]; cursor=cursor+1
                local p={id=pathID}; t.paths[#t.paths+1]=p; t.captured=t.captured+1; r.captured=r.captured+1
                local children,chs=read(env,"C_ProfSpecs.GetChildrenForPath",pathID)
                p.children=ids(children,chs,16)
                local n,ns=read(env,"C_Traits.GetNodeInfo",start.config,pathID); p.node=node(n,ns)
                if value(p.node.ID)~=pathID then p.node.complete=false end
                p.unlockID=scalar(env,"C_ProfSpecs.GetUnlockEntryForPath",1,pathID)
                p.spendID=scalar(env,"C_ProfSpecs.GetSpendEntryForPath",1,pathID)
                p.unlock=entry(env,start.config,p.unlockID); p.spend=entry(env,start.config,p.spendID)
                local nc,ncs=read(env,"C_Traits.GetNodeCost",start.config,pathID); p.costs=costs(nc,ncs)
                p.spendCurrency=scalar(env,"C_ProfSpecs.GetSpendCurrencyForPath",1,pathID)
                p.complete=p.children.complete and p.node.complete and p.unlock.complete and p.spend.complete and p.costs.complete and good(p.spendCurrency)
                if not p.complete then t.coverageComplete=false end
                p.candidate,p.candidateReason=candidate(p); p.currentUnitCost=unitCost(p)
                for _,row in ipairs(p.children.items) do if row.value then discover(row.value) end end
                unit("path","complete path",1)
            end
            if not t.coverageComplete then complete=false end
        end
    end
    local finish=localCollector:Context()
    r.finish=boundary(env,finish); r.timeEnd=scalar(env,"GetServerTime",0)
    r.runtimeEnd={status="observed",revision=integer(runtime.revision) and runtime.revision or nil,serial=integer(runtime.serial) and runtime.serial or nil}
    r.stable=validContext(finish,mode) and localCollector:Same(start,finish)==true and
        r.runtimeStart.revision==r.runtimeEnd.revision and r.runtimeStart.serial==r.runtimeEnd.serial and
        start.staged==false and finish.staged==false and value(r.start.stagingRead)==false and value(r.finish.stagingRead)==false or false
    r.captureComplete=complete and r.stable and good(r.timeEnd)
    r.reason=r.captureComplete and "bounded data captured; cost semantics still unverified" or "incomplete data or unstable/staged boundaries"
    unit("boundary","finish boundary")
    -- Stage candidates only after *all* ownership/coverage/boundary checks finish.
    local eligible=r.captureComplete
    local points,capacity,common=0,0,nil
    for _,t in ipairs(r.tabs) do
        local tp,tc=0,0
        local te=r.captureComplete
        for _,p in ipairs(t.paths) do
            if p.candidate then tp=tp+p.candidate.points; tc=tc+p.candidate.capacity else te=false end
            local currency=value(p.spendCurrency)
            if not common then common=currency elseif currency~=common then eligible=false end
        end
        if te then t.candidate={points=tp,capacity=tc} else eligible=false end
        points=points+tp; capacity=capacity+tc
        unit("reconciliation","tab candidates")
    end
    if eligible and common then
        r.candidate={points=points,capacity=capacity}
        local shared
        for _,t in ipairs(r.tabs) do
            local found,count=nil,0
            for _,row in ipairs(t.currencies.items) do
                if value(row.value.traitCurrencyID)==common then found=row.value; count=count+1 end
            end
            if count~=1 or not good(found.quantity) or not good(found.spent) then eligible=false
            elseif not shared then shared={id=common,quantity=found.quantity.value,spent=found.spent.value}
            elseif shared.quantity~=found.quantity.value or shared.spent~=found.spent.value then eligible=false end
            unit("reconciliation","tab shared currency")
        end
        if eligible and shared then r.shared=shared; r.reconciliation={status=points==shared.spent and "provisional match" or "provisional mismatch",reason="shared spent compared ONCE; other currencies excluded; all-rank costs UNVERIFIED"}
        else r.reconciliation.reason="missing/duplicate/conflicting shared currency rows" end
    else r.reconciliation.reason="candidate guards, coverage, common path currency or stable unstaged boundaries unavailable" end
    unit("reconciliation","collection finished")
end

-- Only module-owned projections reach this serializer. Strings/keys remain sanitized;
-- depth/key/byte caps also protect Format from malformed caller-supplied tables.
local function encode(v,depth,seen,budget)
    if v==nil then return "nil" end
    if type(v)=="boolean" then return tostring(v) end
    if type(v)=="number" then return C.Finite(v) and tostring(v) or "invalid-number" end
    if type(v)=="string" then return clean(v,256) end
    if not plain(v) or depth>8 or seen[v] then budget.clipped=true; return "invalid-table" end
    seen[v]=true
    local keys,key={},nil
    for _=1,129 do
        key=next(v,key); if key==nil then break end
        if #keys>=128 then seen[v]=nil; budget.clipped=true; return "format-key-limit" end
        if type(key)=="string" or integer(key) then keys[#keys+1]=key end
    end
    table.sort(keys,function(a,b) if type(a)==type(b) then return a<b end; return type(a)<type(b) end)
    local parts,bytes={},0
    for _,k in ipairs(keys) do
        local s=clean(tostring(k)).."="..encode(v[k],depth+1,seen,budget); bytes=bytes+#s
        if bytes>16384 then budget.clipped=true; parts[#parts+1]="format-line-limit"; break end
        parts[#parts+1]=s
    end
    seen[v]=nil
    return "{"..table.concat(parts,";").."}"
end
local function format(r,unit)
    local lines,bytes,clipped={},0,false
    local attempts=0
    local function add(label,v)
        -- Clipped no-ops still count: traversing the rest is bounded work too.
        if not clipped then
            local budget={}
            local s=label..(v~=nil and (" "..encode(v,0,{},budget)) or "")
            if budget.clipped then clipped=true
            elseif #lines>=4080 or bytes+#s+1>262144-4096 then clipped=true
            else lines[#lines+1]=s; bytes=bytes+#s+1 end
        end
        attempts=attempts+1
        if attempts==8 then unit("format","eight line attempts",0,attempts); attempts=0 end
    end
    add("CraftArmy knowledgecheck version1 BEGIN"); add(WARNING); add(BOUNDS)
    add("Sources: protected GetBuildInfo (version/build/interface), GetLocale, GetServerTime; C_ProfSpecs tab/root/children/unlock/spend/currency; C_Traits node/entry/current costs/committed tree currencies. Context/Same use a new ephemeral collector only.")
    for _,key in ipairs({"sourcePin","build","locale","timeStart","timeEnd","start","finish","runtimeStart","runtimeEnd","tabIDs"}) do add(key,r[key]) end
    for _,t in ipairs(r.tabs or {}) do
        add("TAB",{id=t.id,name=t.name,infoStatus=t.infoStatus,root=t.root,discovered=t.discovered,captured=t.captured,coverageComplete=t.coverageComplete,flags=t.flags})
        local rows=t.currencies or {status="unavailable",complete=false,items={}}
        add("GetTreeCurrencyInfo(config,tab,true)",{status=rows.status,complete=rows.complete,flags=rows.flags,count=rows.count,inspected=rows.inspected})
        for _,row in ipairs(rows.items) do add("currency row",row) end
        for _,p in ipairs(t.paths or {}) do
            add("PATH",{id=p.id,complete=p.complete,children=p.children})
            add("GetNodeInfo",p.node)
            add("GetUnlockEntryForPath / GetEntryInfo unlock",{id=p.unlockID,info=p.unlock})
            add("GetSpendEntryForPath / GetEntryInfo spend",{id=p.spendID,info=p.spend})
            add("GetNodeCost / GetSpendCurrencyForPath",{costs=p.costs,currency=p.spendCurrency})
            add("current cost consistency (NOT all-rank verification)",p.currentUnitCost)
            add("candidate rank points/capacity (NOT verified all-rank costs)",{candidate=p.candidate,reason=p.candidateReason})
        end
    end
    -- Separate body from bounded summary/footer encoding and final concat.
    unit("format","body finished",0,attempts)
    clipped=clipped or r.outputTruncated==true
    local effective={captureComplete=r.captureComplete==true and not clipped,outputTruncated=clipped,
        stable=r.stable==true,discovered=r.discovered,captured=r.captured,reason=r.reason,
        allRankCosts="UNVERIFIED",reconciliation=clipped and {status="unknown",reason="output clipped; no passing totals"} or r.reconciliation}
    if effective.captureComplete then
        effective.candidate=r.candidate; effective.shared=r.shared
        effective.trees={}
        local count=0
        for _,t in ipairs(r.tabs or {}) do
            effective.trees[#effective.trees+1]={id=t.id,candidate=t.candidate}
            count=count+1
            if count==8 then unit("format","summary trees"); count=0 end
        end
    end
    local ending="CraftArmy knowledgecheck version1 END - "..WARNING
    local summaryText="END SUMMARY version1 "..encode(effective,0,{},{})
    if #summaryText+#BOUNDS+#ending+128>4096 then
        clipped=true
        effective={captureComplete=false,outputTruncated=true,stable=r.stable==true,
            discovered=r.discovered,captured=r.captured,allRankCosts="UNVERIFIED",
            reconciliation={status="unknown",reason="summary reserve exceeded; no passing totals"}}
        summaryText="END SUMMARY version1 "..encode(effective,0,{},{})
    end
    table.insert(lines,2,"captureComplete="..tostring(effective.captureComplete).." outputTruncated="..tostring(clipped))
    lines[#lines+1]=summaryText
    lines[#lines+1]=BOUNDS
    lines[#lines+1]=ending
    return table.concat(lines,"\n"),effective
end
-- Jobs own only their coroutine while running. No closures on the job retain the
-- borrowed env/runtime/report after cancellation, failure or completion.
local Job={}
Job.__index=Job
local UNIT_TOKEN={}
local function stop(job,reason)
    job.status="incomplete"; job.completed=false; job.reason=reason
    job.phase="incomplete"; job.label=reason; job.worker=nil
    job.report=nil; job.text=nil; job.summary=nil
end
function Job:Cancel(reason)
    if self.status=="running" then stop(self,"cancelled: "..(clean(reason,96) or "requested")) end
    return self
end
function Job:Step()
    if self.status~="running" then return self end
    if self.steps>=self.stepLimit then stop(self,"job step limit reached"); return self end
    self.steps=self.steps+1; self.pathUnits=0; self.lineAttempts=0
    -- Native resume, not pcall around a yielding worker. API pcalls finish before
    -- unit yields; unexpected private graph/format errors never escape or leak.
    local ok,a,b,label,paths,attempts=coroutine.resume(self.worker)
    if not ok then stop(self,"job failure (payload omitted)"); return self end
    if coroutine.status(self.worker)=="dead" then
        self.worker=nil; self.status="complete"; self.completed=true
        self.phase="complete"; self.label="job complete"
        if self.kind=="capture" then self.report=a else self.text=a; self.summary=b end
    else
        if a~=UNIT_TOKEN then stop(self,"unexpected job yield (payload omitted)"); return self end
        self.phase=b; self.label=label; self.pathUnits=paths or 0; self.lineAttempts=attempts or 0
    end
    return self
end
local function newJob(kind,options)
    local job=setmetatable({kind=kind,status="running",completed=false,steps=0,
        stepLimit=10000,phase=kind=="capture" and "metadata" or "format",label="not started",
        pathUnits=0,lineAttempts=0},Job)
    if options~=nil then
        if not plain(options) then stop(job,"invalid job options"); return job end
        -- Only one recognized key; inspect at most two, not an unbounded options graph.
        local key=next(options)
        if key~=nil and (key~="stepLimit" or next(options,key)~=nil) then stop(job,"invalid job options"); return job end
        local limit=options.stepLimit
        if limit~=nil then
            if not integer(limit,1) or limit>10000 then stop(job,"invalid job step limit"); return job end
            job.stepLimit=limit
        end
    end
    return job
end
local function unit(phase,label,paths,attempts) coroutine.yield(UNIT_TOKEN,phase,label,paths,attempts) end
local function newCaptureJob(env,runtime,options,mode)
    local job=newJob("capture",options)
    if job.status~="running" then return job end
    job.worker=coroutine.create(function()
        local r=blank()
        capture(env,runtime,r,unit,mode)
        local _,summary=format(r,unit)
        if summary.outputTruncated then
            r.outputTruncated=true; r.captureComplete=false; r.candidate=nil; r.shared=nil
            r.reconciliation={status="unknown",reason="output clipped; no passing totals"}
            for _,t in ipairs(r.tabs) do t.candidate=nil end
        end
        return r
    end)
    return job
end
function Check.NewCaptureJob(env,runtime,options)
    return newCaptureJob(env,runtime,options)
end
function Check.NewProfessionCaptureJob(env,runtime,options)
    return newCaptureJob(env,runtime,options,PROFESSION_MODE)
end
-- Caller-owned immutable borrowed input until terminal. Never Core.Copy this graph:
-- a full read-only report can legitimately exceed the snapshot copy budget.
function Check.NewFormatJob(report,options)
    local job=newJob("format",options)
    if job.status=="running" then job.worker=coroutine.create(function() return format(report,unit) end) end
    return job
end
local function drain(job)
    while job.status=="running" do job:Step() end
    return job
end
local function failedReport(reason)
    local r=blank()
    r.reason=reason; r.reconciliation={status="unknown",reason="protected capture failure"}
    return r
end
function Check.Capture(env,runtime)
    local job=drain(Check.NewCaptureJob(env,runtime))
    return job.report or failedReport("protected capture failure (payload omitted)")
end
function Check.Format(report)
    local job=drain(Check.NewFormatJob(report))
    if job.status=="complete" then return job.text,job.summary end
    -- A fresh tiny version1 fallback, never a clipped prefix or borrowed candidates.
    local r=failedReport("format incomplete (payload omitted)")
    r.outputTruncated=true
    local fallback=drain(Check.NewFormatJob(r))
    return fallback.text,fallback.summary
end

function Check.Show(env,text,previous)
    if read(env,"InCombatLockdown")~=false then return nil,"Combat/unknown safety: run /ca knowledgecheck again out of combat" end
    if type(env.CreateFrame)~="function" then return nil,"Copy window unavailable (native frames missing); report returned to caller" end
    local window=previous
    local ok=pcall(function()
        if not window then
            window={}
            local frame=env.CreateFrame("Frame",nil,env.UIParent,"BasicFrameTemplateWithInset")
            window.frame=frame; frame:SetSize(780,540); frame:SetPoint("CENTER")
            frame.TitleText:SetText("Knowledge evidence only - select all and copy manually")
            local scroll=env.CreateFrame("ScrollFrame",nil,frame,"UIPanelScrollFrameTemplate")
            window.scroll=scroll; scroll:SetPoint("TOPLEFT",16,-36); scroll:SetSize(740,450)
            local edit=env.CreateFrame("EditBox",nil,scroll)
            window.edit=edit; edit:SetMultiLine(true); edit:SetAutoFocus(false); edit:SetFontObject("ChatFontNormal")
            -- Multiline native EditBox sizes its content vertically; do not pin it
            -- to the viewport height and make the long report unreachable.
            edit:SetWidth(720); edit:SetMaxLetters(0); scroll:SetScrollChild(edit)
            edit:SetScript("OnEscapePressed",function() edit:ClearFocus(); frame:Hide() end)
            edit:SetScript("OnTextChanged",function()
                if not window.restoring and edit:GetText()~=window.text then
                    window.restoring=true; edit:SetText(window.text or ""); window.restoring=false
                end
            end)
            local close=env.CreateFrame("Button",nil,frame,"UIPanelButtonTemplate")
            window.close=close; close:SetSize(100,24); close:SetPoint("BOTTOMRIGHT",-16,12); close:SetText("Close")
            close:SetScript("OnClick",function() edit:ClearFocus(); frame:Hide() end)
            frame:SetScript("OnHide",function() edit:ClearFocus() end)
        end
        window.text=(text:gsub("|"," "))
        window.edit:SetText(window.text); window.frame:Show(); window.edit:SetFocus(); window.edit:HighlightText()
    end)
    if not ok then if window and window.frame then pcall(window.frame.Hide,window.frame) end; return nil,"Copy window unavailable (native UI capability failure); report returned to caller" end
    return window
end
