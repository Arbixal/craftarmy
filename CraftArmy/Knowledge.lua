local _, NS = ...
local K, C = {}, NS.Core
NS.Knowledge = K

local function denseList(t, limit)
    if type(t) ~= "table" or #t > limit then return false end
    local count=0
    for key in pairs(t) do
        if not C.Integer(key,1) or key>#t then return false end
        count=count+1
    end
    return count==#t
end

local function pathPoints(p)
    if type(p) ~= "table" or type(p.node) ~= "table" then return nil, "missing node" end
    local n, u = p.node, type(p.unlock)=="table" and p.unlock.maxRanks or nil
    if not C.Integer(p.unlockEntryID, 1) or not (u == 0 or u == 1) then
        return nil, "missing/unexpected unlock-entry metadata"
    end
    if p.costRule ~= "verified-unit-spend" or type(p.costEvidence) ~= "string" or
        p.costEvidence == "" then return nil, "unverified/variable spend costs" end
    if n.ranksIncreased ~= 0 then return nil, "free/increased ranks unknown" end
    if not C.Integer(n.ranksPurchased) or not C.Integer(n.currentRank) or
        not C.Integer(n.maxRanks) or n.currentRank ~= n.ranksPurchased then return nil, "invalid/ambiguous ranks" end
    local bought = n.ranksPurchased > 0 and n.ranksPurchased - u or 0
    local cap = n.maxRanks - u
    if bought < 0 or cap < 0 or bought > cap then return nil, "ranks exceed capacity" end
    return {purchased=bought, capacity=cap}
end
K.PathPoints = pathPoints

local POLICY="native-rank-reconciled-v1"
local PIN="297d7aaaa736f346b3e036f38ee088eaf7f8c07f"
local function integer(v,low) return C.Integer(v,low or 0) and v<=2147483647 end
local function plain(v) return type(v)=="table" and getmetatable(v)==nil end
local function nativeList(v,limit,check)
    if not plain(v) then return false end
    local count,max=0,0
    for key,x in pairs(v) do
        count=count+1
        if count>limit or not integer(key,1) or key>limit or not check(x) then return false end
        if key>max then max=key end
    end
    return count==max
end
local function nativeIDs(v,limit)
    local seen={}
    return nativeList(v,limit,function(id)
        if not integer(id,1) or seen[id] then return false end
        seen[id]=true; return true
    end)
end
local function currencyRows(tab)
    if not plain(tab) or tab.currenciesComplete~=true then return nil end
    local rows={}
    if not nativeList(tab.currencies,64,function(v)
        if not plain(v) or not integer(v.traitCurrencyID,1) or rows[v.traitCurrencyID] or
            not integer(v.quantity) or not integer(v.spent) or
            (v.maxQuantity~=nil and not integer(v.maxQuantity)) then return false end
        rows[v.traitCurrencyID]=v; return true
    end) then return nil end
    return rows
end
function K.NativePathPoints(p,tab)
    local function bad() return nil,"Native path metadata/state/current-cost guard failed" end
    if not plain(p) or p.metadataComplete~=true or p.childrenComplete~=true or
        not nativeIDs(p.children,16) or p.costRule~="unknown" or not plain(p.node) then return bad() end
    local n,u,s=p.node,p.unlock,p.spend
    if not integer(n.ID,1) or (p.id~=nil and n.ID~=p.id) or n.type~=1 or n.flags~=0 or
        type(n.isAvailable)~="boolean" then return bad() end
    for _,key in ipairs({"currentRank","activeRank","ranksPurchased","ranksIncreased","maxRanks","totalMaxRanks"}) do
        if not integer(n[key]) then return bad() end
    end
    if n.ranksIncreased~=0 or n.currentRank~=n.ranksPurchased or n.activeRank~=n.currentRank or
        n.totalMaxRanks~=n.maxRanks then return bad() end
    local un,sp=p.unlockEntryID,p.spendEntryID
    if not integer(un,1) or not integer(sp,1) or un==sp or not nativeIDs(n.entryIDs,32) or
        #n.entryIDs~=2 or not nativeIDs(n.entryIDsWithCommittedRanks,32) then return bad() end
    local pair={[un]=true,[sp]=true}
    for _,id in ipairs(n.entryIDs) do if not pair[id] then return bad() end end
    if not plain(n.entryIDToRanksIncreased) then return bad() end
    local count=0
    for id,ranks in pairs(n.entryIDToRanksIncreased) do
        count=count+1
        if count>2 or not pair[id] or ranks~=0 then return bad() end
    end
    if count~=2 then return bad() end
    if not plain(u) or not plain(s) or u.type~=9 or s.type~=7 or (u.maxRanks~=0 and u.maxRanks~=1) or
        not integer(s.maxRanks,1) or n.maxRanks~=u.maxRanks+s.maxRanks then return bad() end
    for _,e in ipairs({u,s}) do
        if e.entryCostComplete~=true or not nativeList(e.entryCost,16,function() return false end) then return bad() end
    end
    local rp=n.ranksPurchased
    local points=rp>0 and rp-u.maxRanks or 0
    local cap=n.maxRanks-u.maxRanks
    if not integer(points) or not integer(cap,1) or points>cap then return bad() end
    local function rank(e)
        return plain(e) and integer(e.entryID,1) and pair[e.entryID] and integer(e.rank) and
            e.rank<=(e.entryID==un and u.maxRanks or s.maxRanks)
    end
    if not rank(n.activeEntry) then return bad() end
    local active=n.activeEntry
    if rp>u.maxRanks then
        if active.entryID~=sp or active.rank~=points then return bad() end
    elseif active.entryID~=un or active.rank~=(rp>0 and u.maxRanks or 0) then return bad() end
    local committed={}
    for _,id in ipairs(n.entryIDsWithCommittedRanks) do
        if not pair[id] then return bad() end
        committed[id]=true
    end
    if (rp==0 and #n.entryIDsWithCommittedRanks~=0) or (rp>0 and not committed[active.entryID]) then return bad() end
    if rp==n.maxRanks then
        if n.nextEntry~=nil then return bad() end
    elseif not plain(n.nextEntry) or not integer(n.nextEntry.entryID,1) or
        not pair[n.nextEntry.entryID] or not integer(n.nextEntry.rank,1) then return bad() end
    local rows=currencyRows(tab)
    if not integer(p.spendCurrencyID,1) or not rows or not rows[p.spendCurrencyID] or
        not nativeList(p.costs,16,function(v)
            return plain(v) and integer(v.ID,1) and integer(v.amount) and v.amount==1
        end) or #p.costs~=1 then return bad() end
    local cost=p.costs[1]
    local locked=rp==0 and u.maxRanks==1
    if locked then
        if n.nextEntry.entryID~=un or cost.ID==p.spendCurrencyID or not rows[cost.ID] then return bad() end
    else
        if cost.ID~=p.spendCurrencyID or (rp<n.maxRanks and n.nextEntry.entryID~=sp) then return bad() end
    end
    return {purchased=points,capacity=cap,locked=locked}
end

local function nativeEvaluate(scan)
    local out={trees={},complete=false}
    if not plain(scan) then out.reason="Malformed native scan"; return out end
    local expected=C.NativeKnowledgeCurrency(scan.identity)
    local all=expected~=nil and integer(scan.configID,1) and
        integer(scan.sourceCounter) and scan.nativeComplete==true and scan.tabsComplete==true and
        scan.stable==true and scan.stagedStart==false and scan.stagedEnd==false
    local tabsValid=nativeList(scan.tabs,8,function(v) return plain(v) end) and #scan.tabs>0
    if not tabsValid then all=false end
    local owners,tabs,common,shared,sum={}, {},nil,nil,0
    local function fail(reason) all=false; out.reason=out.reason or reason end
    for i=1,plain(scan.tabs) and math.min(#scan.tabs,8) or 0 do
        local t=scan.tabs[i]
        if not plain(t) or not integer(t.id,1) then fail("Invalid tab") else
            local r={id=t.id,name=t.name,root=t.root,paths={},complete=false,purchased=0,capacity=0,
                coverage={discovered=0,captured=0,limit=false},accountingPolicy=POLICY}
            out.trees[#out.trees+1]=r
            if tabs[t.id] or not integer(t.root,1) or t.coverageComplete~=true or not plain(t.paths) or
                (t.name~=nil and (type(t.name)~="string" or #t.name>256)) then fail("Incomplete/duplicate native tab") end
            tabs[t.id]=true
            local rows=currencyRows(t)
            if not rows then fail("Incomplete native currencies") end
            r.currencies=rows and C.Copy(t.currencies) or nil
            r.currenciesComplete=rows~=nil
            local seen={}
            local function visit(id)
                if not integer(id,1) or seen[id] or owners[id] then fail("Cycle/shared native path"); return end
                if r.coverage.discovered>=64 then r.coverage.limit=true; fail("Native path limit"); return end
                seen[id]=true; owners[id]=true; r.coverage.discovered=r.coverage.discovered+1
                local p=plain(t.paths) and t.paths[id]
                if not plain(p) or not plain(p.node) or p.node.ID~=id then fail("Missing native path"); return end
                local points,why=K.NativePathPoints(p,t)
                local raw=C.Copy(p)
                if not raw then fail("Malformed native path"); return end
                raw.id=id; r.paths[#r.paths+1]=raw; r.coverage.captured=r.coverage.captured+1
                if points then
                    raw.purchased,raw.capacity,raw.locked=points.purchased,points.capacity,points.locked
                    r.purchased=r.purchased+points.purchased; r.capacity=r.capacity+points.capacity
                else fail(why) end
                if integer(p.spendCurrencyID,1) then
                    if p.spendCurrencyID~=expected then fail("Wrong profession native spend currency") end
                    if common and common~=p.spendCurrencyID then fail("Different native spend currencies") end
                    common=common or p.spendCurrencyID
                else fail("Missing native spend currency") end
                if nativeIDs(p.children,16) then for _,child in ipairs(p.children) do visit(child) end
                else fail("Invalid native children") end
            end
            if integer(t.root,1) then visit(t.root) end
            local count=0
            if plain(t.paths) then
                for id in pairs(t.paths) do
                    count=count+1; if count>64 then fail("Native path map limit"); break end
                    if not integer(id,1) or not seen[id] then fail("Unreachable native path") end
                end
            end
            if count~=r.coverage.captured then fail("Native coverage mismatch") end
            sum=sum+r.purchased
        end
    end
    for i=1,plain(scan.tabs) and math.min(#scan.tabs,8) or 0 do
        local t=scan.tabs[i]
        local rows=currencyRows(t)
        local row=rows and common and rows[common]
        if not row then fail("Missing shared-spend row")
        elseif shared and (shared.spent~=row.spent or shared.quantity~=row.quantity) then fail("Conflicting shared-spend rows")
        else shared=row end
    end
    if not shared or sum~=shared.spent then fail("Shared spent reconciliation unknown/mismatch") end
    if all and #out.trees>0 then
        out.complete=true; out.sharedSpent=shared.spent
        for _,r in ipairs(out.trees) do
            r.complete=true
            r.accountingEvidence={currencyID=common,spent=shared.spent,quantity=shared.quantity,
                totalPurchased=sum,sourcePin=PIN}
        end
    else
        out.reason=out.reason or "Native scope/staging/source coverage incomplete"
        for _,r in ipairs(out.trees) do r.purchased=nil; r.capacity=nil; r.reason=out.reason end
    end
    return out
end

function K.Evaluate(scan)
    if type(scan)=="table" and scan.policy~=nil then
        if scan.policy==POLICY then return nativeEvaluate(scan) end
        return {trees={},complete=false,reason="Unsupported knowledge accounting policy"}
    end
    local out = {trees={}, complete=true, sharedSpent=nil}
    if type(scan) ~= "table" or type(scan.tabs) ~= "table" or not C.Integer(scan.configID, 1) then
        out.complete=false; out.reason="missing config/tabs"; return out
    end
    local boundary = scan.stagedStart == false and scan.stagedEnd == false and scan.stable == true
    local owners, tabSeen, sum, all = {}, {}, 0, true
    local count = #scan.tabs
    local tabsValid=denseList(scan.tabs,8) and count>0 and scan.tabsComplete==true
    if not tabsValid then all=false end
    for i=1, math.min(count, 8) do
        local t = type(scan.tabs[i])=="table" and scan.tabs[i] or {}
        local r = {id=t.id, name=t.name, root=t.root, paths={}, complete=boundary,
            coverage={discovered=0, captured=0, limit=false}, purchased=0, capacity=0}
        out.trees[#out.trees+1] = r
        local function fail(reason)
            r.complete=false; r.reason=r.reason or reason
        end
        if not boundary then fail("staged/unknown staging or unstable scan") end
        if not C.Integer(t.id, 1) or tabSeen[t.id] then fail("invalid/duplicate tab") end
        if t.id then tabSeen[t.id]=true end
        if not C.Integer(t.root, 1) or type(t.paths) ~= "table" then fail("missing root/path data") end
        local seen = {}
        local function visit(id, depth)
            if not C.Integer(id, 1) then fail("invalid child ID"); return end
            if seen[id] then fail("cycle/duplicate child ownership"); return end
            if r.coverage.discovered >= 64 or depth > 64 then
                r.coverage.limit=true; fail("path limit"); return
            end
            seen[id]=true; r.coverage.discovered=r.coverage.discovered+1
            if owners[id] then
                fail("shared path across trees"); owners[id].complete=false
                owners[id].reason="shared path across trees"
            else owners[id]=r end
            local p = t.paths and t.paths[id]
            if type(p) ~= "table" then fail("missing child metadata"); return end
            local raw = C.Copy(p)
            if not raw then fail("malformed path"); return end
            raw.id=id; r.paths[#r.paths+1]=raw
            r.coverage.captured=r.coverage.captured+1
            local points, reason = pathPoints(p)
            if not points then fail(reason) else
                raw.purchased, raw.capacity=points.purchased, points.capacity
                r.purchased=r.purchased+points.purchased; r.capacity=r.capacity+points.capacity
            end
            if type(p.children) ~= "table" or p.childrenComplete ~= true then fail("missing children/coverage"); return end
            if not denseList(p.children,16) then fail("invalid/limited children list") end
            if #p.children > 16 then r.coverage.limit=true; fail("child limit") end
            for j=1, math.min(#p.children,16) do visit(p.children[j], depth+1) end
        end
        if C.Integer(t.root, 1) then visit(t.root, 0) end
        if t.coverageComplete ~= true then fail("incomplete source coverage") end
    end
    for _, r in ipairs(out.trees) do
        if not r.complete then all=false else sum=sum+r.purchased end
    end
    -- A capped tab list might hide shared ownership, so no partial denominators.
    if not tabsValid then
        for _, r in ipairs(out.trees) do r.complete=false; r.reason="incomplete tab coverage" end
    end
    local shared = scan.shared
    if shared and shared.applicable == true then
        if not C.Integer(shared.spent) or not all or sum ~= shared.spent then
            for _, r in ipairs(out.trees) do r.complete=false; r.reason="shared spent reconciliation unknown/mismatch" end
            all=false
        else out.sharedSpent=shared.spent end
    end
    for _, r in ipairs(out.trees) do
        if not r.complete then r.purchased=nil; r.capacity=nil end
    end
    out.complete=all
    out.reason = not all and "At least one tree is incomplete/ineligible" or nil
    return out
end
