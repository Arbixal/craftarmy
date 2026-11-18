local _, NS = ...
local Core = {}
NS.Core = Core
Core.statuses = { observed=true, empty=true, unknown=true, unsupported=true,
    error=true, not_applicable=true }
local success = { observed=true, empty=true, not_applicable=true }

function Core.Finite(value, optionalMathLibrary)
    if type(value)~="number" then return false end
    local library=optionalMathLibrary
    if library==nil then library=math end
    if type(library)~="table" then return false end
    local native=rawget(library,"isfinite")
    if native~=nil then
        if type(native)~="function" then return false end
        local ok,result=pcall(native,value)
        return ok and type(result)=="boolean" and result
    end
    -- Portable IEEE Lua fallback ONLY when no native predicate is present.
    -- WoW NaN comparisons are not IEEE evidence; its native result takes priority.
    return value==value and value>-math.huge and value<math.huge
end

function Core.Integer(n, minimum)
    local lower=minimum or 0
    return Core.Finite(n) and Core.Finite(lower) and n % 1 == 0 and n >= lower
end

-- Private to the two whole-walk pcall scopes below. Never use these guards from
-- an unprotected caller: native exceptions are handled by that walk's boundary.
-- State belongs to this walk, including when a predicate reenters another walk.
local function protectedWalkNumbers(valueFailure, keyFailure)
    local pending
    local function finite(value, failure)
        if type(value)~="number" then return false end
        local library=math
        if type(library)~="table" then return false end
        local native=rawget(library,"isfinite")
        if native~=nil then
            if type(native)~="function" then return false end
            pending=failure or valueFailure
            local result=native(value)
            pending=nil
            return type(result)=="boolean" and result
        end
        return Core.Finite(value)
    end
    local function integer(n)
        return finite(n,keyFailure) and finite(0,keyFailure) and n % 1 == 0 and n >= 0
    end
    return finite, integer, function() return pending end
end

-- Rejection-only lower bound: one plain table plus 50000 own children cannot fit
-- the existing 50000-visit walk. Sparse length is ONLY a hint to count raw keys.
-- Every miss/cap defers to the full walker; search dedup never changes its counts.
-- Multiply-invalid graphs may now report budget before type/native/cycle errors.
local function provesOverBudget(value)
    local visited, tables, edges, probes, exhausted = {}, 0, 0, 0, false
    local function search(v, depth)
        if type(v)~="table" or getmetatable(v)~=nil or visited[v] then return false end
        if tables>=64 then exhausted=true; return false end
        visited[v]=true; tables=tables+1
        if #v>=50000 then
            local key, own=nil,0
            while probes<50001 do
                key=next(v,key); probes=probes+1
                if key==nil then break end
                own=own+1
                if own>=50000 then return true end
            end
            if probes>=50001 then exhausted=true; return false end
        end
        -- A container at depth4 can prove rejection, but cannot extend the search.
        if depth>=4 then return false end
        local key, child
        while edges<256 do
            key,child=next(v,key)
            if key==nil then return false end
            edges=edges+1
            if search(child,depth+1) then return true end
            if exhausted then return false end
        end
        exhausted=true
        return false
    end
    return search(value,0)
end

-- Both modes walk every occurrence (including aliases), with ancestor-only seen.
-- Check-only omits output allocations, never traversal or plain-data guards.
local function boundedData(value, makeCopy)
    local seen, count = {}, 0
    local finite, integer, pendingFailure = protectedWalkNumbers("invalid/cyclic data", "invalid key")
    local function copy(v, depth)
        count = count + 1
        if count > 50000 or depth > 20 then error("data traversal limit") end
        local kind = type(v)
        if kind == "nil" or kind == "boolean" then return v end
        if kind == "number" and finite(v) then return v end
        if kind == "string" and #v <= 4096 then return v end
        if kind ~= "table" or getmetatable(v) or seen[v] then error("invalid/cyclic data") end
        seen[v] = true
        local out = makeCopy and {} or nil
        for k, x in pairs(v) do
            if not ((type(k) == "string" and #k <= 128) or integer(k)) then
                error("invalid key")
            end
            local child = copy(x, depth + 1)
            if makeCopy then out[k] = child end
        end
        seen[v] = nil
        return out
    end
    local function root(v)
        if provesOverBudget(v) then error("data traversal limit") end
        return copy(v,0)
    end
    local ok, result = pcall(root, value)
    if ok then
        if makeCopy then return result end
        return true
    end
    return nil, pendingFailure() or tostring(result)
end

-- Copy only bounded finite, plain data. Never retain caller-owned tables.
function Core.Copy(value)
    return boundedData(value, true)
end

function Core.Observation(status, value, at, source, reason)
    return { status=status, value=value, attemptedAt=at, source=source, reason=reason }
end

local function validAttempt(a)
    return type(a) == "table" and Core.statuses[a.status] and
        Core.Integer(a.attemptedAt) and type(a.source) == "string" and
        (a.reason == nil or type(a.reason) == "string")
end
function Core.ValidObservation(a)
    if type(a)~="table" or not Core.Copy(a) then return false end
    if not validAttempt(a) then return false end
    if a.status == "observed" and a.value == nil then return false end
    return true
end

function Core.Merge(previous, observation, build, generation)
    if not Core.ValidObservation(observation) or not Core.Integer(generation, 1) or
        type(build) ~= "string" or #build>4096 then return nil, "malformed observation" end
    local out = previous and Core.Copy(previous) or {}
    if not out then return nil, "malformed prior field" end
    out.attempt = {status=observation.status, attemptedAt=observation.attemptedAt,
        source=observation.source, reason=observation.reason}
    if success[observation.status] then
        out.last = {status=observation.status, value=Core.Copy(observation.value),
            observedAt=observation.attemptedAt, build=build, generation=generation}
    end
    return out
end

local function equipmentKey(key)
    return key=="tool" or key=="accessory1" or key=="accessory2" or
        (type(key)=="string" and key:match("^slot[1-9]%d*$")~=nil)
end
local function sameInstance(a,b)
    return type(a)=="table" and type(b)=="table" and a.exists==true and b.exists==true and
        Core.Integer(a.slot,1) and a.slot==b.slot and Core.Integer(a.itemID,1) and a.itemID==b.itemID and
        type(a.link)=="string" and a.link:match("item:%d+:%d*:")~=nil and a.link==b.link
end
-- Apply-only: the full input pack and whole old character were cloned THIS call.
-- No yield, external callback or real write occurs while these owned tables merge.
-- Public ValidObservation/Merge deliberately retain their independent deep guards.
local function validOwnedObservation(a)
    if type(a)~="table" or not validAttempt(a) then return false end
    if a.status == "observed" and a.value == nil then return false end
    return true
end
local function mergeOwned(previous, observation, build, generation)
    if not validOwnedObservation(observation) or not Core.Integer(generation, 1) or
        type(build) ~= "string" or #build>4096 then return nil, "malformed observation" end
    local out = previous or {}
    out.attempt = {status=observation.status, attemptedAt=observation.attemptedAt,
        source=observation.source, reason=observation.reason}
    if success[observation.status] then
        out.last = {status=observation.status, value=observation.value,
            observedAt=observation.attemptedAt, build=build, generation=generation}
    end
    return out
end

local function mergeEquipment(previous, observation, build, generation, merge)
    merge = merge or Core.Merge
    if success[observation.status] then
        -- mergeOwned replaces previous.last in place: capture old unit references
        -- before calling it, and never lend those references to the new snapshot.
        local old=previous and previous.last and previous.last.value
        local same=sameInstance(old,observation.value)
        local expansion= same and old.itemExpansion
        local tool= same and old.toolStat
        local out,why=merge(previous,observation,build,generation)
        if not out then return nil,why end
        local value=out.last and out.last.value
        if same and value then
            for key,prior in pairs({itemExpansion=expansion,toolStat=tool}) do
                local current=value[key]
                if prior.value~=nil and (not current or current.status~="observed") then
                    value[key]={status=current and current.status or "unknown",
                        attemptedAt=current and current.attemptedAt or observation.attemptedAt,
                        source=prior.source,value=prior.value,observedAt=prior.observedAt}
                end
            end
        end
        if value then
            for _,key in ipairs({"itemExpansion","toolStat"}) do
                if value[key] and value[key].value==nil then value[key]=nil end
            end
        end
        return out
    end
    local last=previous and previous.last
    if last and sameInstance(last.value,observation.value) then
        -- Whole unit and successful timestamp remain coherent; no subfield borrowing.
        return merge(previous,observation,build,generation)
    end
    -- A changed/removed/unidentifiable instance cannot inherit the prior metadata.
    -- Keep only this scan's known existence/partial evidence, with a failed attempt.
    local out,why=merge(nil,observation,build,generation)
    if not out then return nil,why end
    if observation.value~=nil then
        local current=merge(nil,Core.Observation("observed",observation.value,
            observation.attemptedAt,observation.source),build,generation)
        if not current then return nil,"Invalid current equipment unit" end
        out.last=current.last
    end
    return out
end
Core.MergeEquipment = mergeEquipment

-- Registered schema-1 payload validation, shared by load and atomic write paths.
-- Generic Merge remains a primitive utility; it is NOT a production schema bypass.
local function finite(v) return Core.Finite(v) end
local function label(v) return type(v)=="string" and #v<=4096 end
local function optional(v,validator) return v==nil or validator(v) end
local function boolean(v) return type(v)=="boolean" end
local function positive(v) return Core.Integer(v,1) end
local function array(v,limit,validator)
    if type(v)~="table" or #v>limit then return false end
    local count=0
    for key,x in pairs(v) do
        if not positive(key) or key>#v or not validator(x) then return false end
        count=count+1
    end
    return count==#v
end
local function idList(v,limit) return array(v,limit,positive) end
local function stats(v)
    if type(v)~="table" then return false end
    local count=0
    for key,n in pairs(v) do
        count=count+1
        if count>32 or type(key)~="string" or not key:match("^ITEM_MOD_[A-Z0-9_]+$") or not finite(n) then return false end
    end
    return true
end
local function status(v) return type(v)=="string" and Core.statuses[v]==true end
local function enchant(v)
    if type(v)~="table" or not status(v.status) or not optional(v.reason,label) or
        not optional(v.category,label) or not optional(v.id,Core.Integer) then return false end
    if v.status=="observed" then
        return boolean(v.present) and Core.Integer(v.id) and ((v.present and v.id>0) or (not v.present and v.id==0))
    end
    return v.present==nil and v.id==nil and v.category==nil
end
local function quality(v)
    if type(v)~="table" or not optional(v.quality,function(n) return positive(n) and n<=5 end) then return false end
    for _,key in ipairs({"icon","iconSmall","iconInventory","iconChat"}) do
        if not optional(v[key],label) then return false end
    end
    return true
end
local metadataSources={itemExpansion="C_Item.GetItemInfo",toolStat="C_Item.GetItemStats:unenchant-link-v1"}
local toolCategories={Multicraft=true,Resourcefulness=true,Ingenuity=true,["Crafting Speed"]=true}
local metadataSlots={[20]="tool",[21]="accessory1",[22]="accessory2",[23]="tool",[24]="accessory1",[25]="accessory2"}
local function gearMetadata(v,key)
    if type(v)~="table" or getmetatable(v)~=nil or v.source~=metadataSources[key] or
        not Core.Integer(v.attemptedAt) or
        (v.status~="observed" and v.status~="unknown" and v.status~="error" and v.status~="unsupported") then return false end
    for k in pairs(v) do
        if k~="status" and k~="attemptedAt" and k~="source" and k~="value" and k~="observedAt" then return false end
    end
    if v.value==nil then return v.status~="observed" and v.observedAt==nil end
    if not Core.Integer(v.observedAt) then return false end
    if key=="itemExpansion" then return Core.Integer(v.value) and v.value<=2147483647 end
    return type(v.value)=="string" and toolCategories[v.value]==true
end
local function gear(v,key)
    if type(v)~="table" or not positive(v.slot) or not boolean(v.exists) or not boolean(v.metadataReady) then return false end
    if key=="tool" or key=="accessory1" or key=="accessory2" then
        if v.role~=key then return false end
    elseif v.role~=nil or tonumber(key:match("^slot(%d+)$"))~=v.slot then return false end
    if not optional(v.itemID,positive) or not optional(v.link,label) or not optional(v.icon,positive) or
        not optional(v.rank,function(n) return positive(n) and n<=5 end) or
        not optional(v.rarity,function(n) return Core.Integer(n) and n<=8 end) or
        not optional(v.stats,stats) or not optional(v.quality,quality) or not optional(v.enchant,enchant) or
        not optional(v.statAttribution,label) or not optional(v.loadReason,label) then return false end
    for _,name in ipairs({"statsStatus","rarityStatus","rankStatus"}) do
        if not optional(v[name],status) then return false end
    end
    if v.enchantLines~=nil and not array(v.enchantLines,8,function(line)
        return type(line)=="table" and optional(line.leftText,label) and optional(line.rightText,label)
    end) then return false end
    if v.link~=nil then
        local id=tonumber(v.link:match("item:(%d+):"))
        if not positive(id) or (v.itemID~=nil and v.itemID~=id) then return false end
    end
    for _,name in ipairs({"itemExpansion","toolStat"}) do
        if v[name]~=nil and (v.exists~=true or not v.metadataReady or not positive(v.itemID) or v.link==nil or
            metadataSlots[v.slot]~=key or (name=="toolStat" and key~="tool") or not gearMetadata(v[name],name)) then return false end
    end
    if not v.exists then
        return not v.metadataReady and v.link==nil and v.itemID==nil and v.rarity==nil and
            v.rank==nil and v.icon==nil and v.stats==nil and v.quality==nil and v.enchant==nil and v.enchantLines==nil
    end
    if v.metadataReady and (not positive(v.itemID) or v.link==nil) then return false end
    return true
end
local NATIVE="native-rank-reconciled-v1"
local SOURCE_PIN="297d7aaaa736f346b3e036f38ee088eaf7f8c07f"
local function nativeInteger(v) return Core.Integer(v) and v<=2147483647 end
local function nativeID(v) return nativeInteger(v) and v>0 end
local function detailsScope(v)
    return type(v)=="table" and v.skillLineID==2913 and v.parentID==773 and v.profession==13 and v.expansionID==11
end
-- Q03: focused Retail 12.1.5/build70783 trait-spend evidence, not Moxie IDs
-- or universal/all-rank cost proof. Private scalar catalogue; Core also runs alone.
local nativeCurrencies={
    [2906]={171,3,4030}, [2907]={164,1,3750}, [2909]={333,9,4056},
    [2910]={202,8,3903}, [2913]={773,13,3902}, [2914]={755,12,3989},
    [2915]={165,2,4085}, [2918]={197,7,3736},
}
function Core.NativeKnowledgeCurrency(v)
    if type(v)~="table" or getmetatable(v)~=nil then return nil end
    for _,key in ipairs({"skillLineID","parentID","profession","expansionID"}) do
        if not nativeID(v[key]) then return nil end
    end
    local row=nativeCurrencies[v.skillLineID]
    if row and v.parentID==row[1] and v.profession==row[2] and v.expansionID==11 then return row[3] end
end
local function uniqueIDs(v,limit)
    local seen={}
    return array(v,limit,function(id)
        if not nativeID(id) or seen[id] then return false end
        seen[id]=true; return true
    end)
end
local function costs(v)
    local seen={}
    return array(v,16,function(row)
        if type(row)~="table" or not nativeID(row.ID) or not nativeInteger(row.amount) or seen[row.ID] then return false end
        seen[row.ID]=true; return true
    end)
end
local function entry(v)
    return type(v)=="table" and optional(v.maxRanks,nativeInteger) and optional(v.type,nativeInteger) and
        optional(v.definitionID,nativeID) and optional(v.entryCostComplete,boolean) and optional(v.entryCost,costs) and
        (v.entryCostComplete~=true or v.entryCost~=nil)
end
local function entryRank(v)
    return type(v)=="table" and nativeID(v.entryID) and nativeInteger(v.rank)
end
local function increasedMap(v)
    if type(v)~="table" then return false end
    local count=0
    for id,ranks in pairs(v) do
        count=count+1
        if count>32 or not nativeID(id) or not nativeInteger(ranks) then return false end
    end
    return true
end
local function traitCurrencies(v)
    local seen={}
    return array(v,64,function(row)
        if type(row)~="table" or not nativeID(row.traitCurrencyID) or seen[row.traitCurrencyID] or
            not nativeInteger(row.quantity) or not nativeInteger(row.spent) or not optional(row.maxQuantity,nativeInteger) then return false end
        seen[row.traitCurrencyID]=true; return true
    end)
end
local function node(v)
    if type(v)~="table" or not optional(v.ID,positive) or not optional(v.isAvailable,boolean) then return false end
    for _,name in ipairs({"ranksPurchased","ranksIncreased","currentRank","maxRanks"}) do
        if not optional(v[name],function(n) return finite(n) and n%1==0 end) then return false end
    end
    for _,name in ipairs({"type","flags","activeRank","totalMaxRanks"}) do
        if not optional(v[name],nativeInteger) then return false end
    end
    return optional(v.activeEntry,entryRank) and optional(v.nextEntry,entryRank) and
        optional(v.entryIDs,function(x) return uniqueIDs(x,32) end) and
        optional(v.entryIDsWithCommittedRanks,function(x) return uniqueIDs(x,32) end) and
        optional(v.entryIDToRanksIncreased,increasedMap)
end
local function path(v)
    if type(v)=="table" and v.name~=nil and (type(v.name)~="string" or #v.name>256 or
        not v.name:match("%S") or v.name:find("[%c|]")) then return false end
    if type(v)~="table" or not optional(v.node,node) or not optional(v.unlockEntryID,positive) or
        not optional(v.costRule,label) or not optional(v.costReason,label) or not optional(v.costEvidence,label) or
        not boolean(v.childrenComplete) or not optional(v.metadataComplete,boolean) or
        not optional(v.locked,boolean) or not optional(v.spendEntryID,nativeID) or
        not optional(v.spendCurrencyID,nativeID) or not optional(v.spend,entry) then return false end
    if v.children~=nil and not idList(v.children,16) then return false end
    if v.childrenComplete and v.children==nil then return false end
    if not optional(v.unlock,entry) then return false end
    if v.metadataComplete~=nil then
        if not optional(v.costs,costs) or not optional(v.unlockEntryID,nativeID) or
            not optional(v.children,function(x) return uniqueIDs(x,16) end) then return false end
        if v.node then
            for _,name in ipairs({"ID","ranksPurchased","ranksIncreased","currentRank","maxRanks"}) do
                if not optional(v.node[name],name=="ID" and nativeID or nativeInteger) then return false end
            end
        end
        if v.metadataComplete then
            if not v.node or not nativeID(v.node.ID) or not nativeID(v.unlockEntryID) or not nativeID(v.spendEntryID) or
                not nativeID(v.spendCurrencyID) or not v.unlock or not v.spend or
                not nativeInteger(v.unlock.type) or not nativeInteger(v.unlock.maxRanks) or
                not nativeInteger(v.spend.type) or not nativeInteger(v.spend.maxRanks) or
                v.unlock.entryCostComplete~=true or v.spend.entryCostComplete~=true or not costs(v.costs) or
                type(v.node.isAvailable)~="boolean" or not uniqueIDs(v.node.entryIDs,32) or
                not uniqueIDs(v.node.entryIDsWithCommittedRanks,32) or not increasedMap(v.node.entryIDToRanksIncreased) then return false end
            for _,key in ipairs({"type","flags","ranksPurchased","ranksIncreased","currentRank","activeRank","maxRanks","totalMaxRanks"}) do
                if not nativeInteger(v.node[key]) then return false end
            end
        end
    elseif v.costs~=nil and not array(v.costs,16,function(cost)
        return type(cost)=="table" and optional(cost.ID,positive) and optional(cost.amount,finite)
    end) then return false end
    return optional(v.id,positive) and optional(v.purchased,Core.Integer) and optional(v.capacity,Core.Integer)
end
local function tabIdentity(v)
    return type(v)=="table" and positive(v.id) and optional(v.name,label) and optional(v.root,positive)
end
local function rawKnowledge(v)
    if type(v)~="table" or not optional(v.configID,positive) or not optional(v.stagedStart,boolean) or
        not optional(v.stagedEnd,boolean) or not optional(v.stable,boolean) or not boolean(v.tabsComplete) or
        not optional(v.nativeComplete,boolean) or not optional(v.sourceCounter,nativeInteger) then return false end
    local expected=v.policy==NATIVE and Core.NativeKnowledgeCurrency(v.identity)
    if v.policy~=nil and (v.policy~=NATIVE or not expected or not boolean(v.nativeComplete) or
        not optional(v.configID,nativeID)) then return false end
    if v.policy==NATIVE and v.nativeComplete and (not nativeID(v.configID) or not nativeInteger(v.sourceCounter)) then return false end
    if v.identity~=nil then
        if type(v.identity)~="table" then return false end
        for _,key in ipairs({"skillLineID","parentID","profession","expansionID"}) do
            if not optional(v.identity[key],nativeID) then return false end
        end
    end
    return array(v.tabs,8,function(t)
        if not tabIdentity(t) or not boolean(t.coverageComplete) or type(t.paths)~="table" then return false end
        local count=0
        for id,p in pairs(t.paths) do
            count=count+1
            if count>64 or not positive(id) or not path(p) or (p.node and p.node.ID and p.node.ID~=id) then return false end
        end
        if not optional(t.currenciesComplete,boolean) or not optional(t.currencyStatus,label) or
            not optional(t.currencyCount,nativeInteger) then return false end
        if v.policy==NATIVE then
            if not nativeID(t.id) or not optional(t.root,nativeID) or not boolean(t.currenciesComplete) or not traitCurrencies(t.currencies) then return false end
            for id,p in pairs(t.paths) do
                if not nativeID(id) or not boolean(p.metadataComplete) or
                    (p.spendCurrencyID~=nil and p.spendCurrencyID~=expected) then return false end
            end
            if v.nativeComplete then
                if not t.coverageComplete or not t.currenciesComplete then return false end
                for _,p in pairs(t.paths) do if not p.metadataComplete or not p.childrenComplete then return false end end
            end
            return true
        end
        return t.currencies==nil or array(t.currencies,64,function(currency)
            return type(currency)=="table" and optional(currency.traitCurrencyID,positive) and
                optional(currency.quantity,finite) and optional(currency.maxQuantity,finite) and optional(currency.spent,finite)
        end)
    end)
end
local function tree(v,id)
    if not tabIdentity(v) or v.id~=id or not positive(v.root) or v.complete~=true or
        not Core.Integer(v.purchased) or not Core.Integer(v.capacity) or v.purchased>v.capacity or
        type(v.coverage)~="table" or not Core.Integer(v.coverage.discovered) or not Core.Integer(v.coverage.captured) or
        not boolean(v.coverage.limit) then return false end
    if v.accountingPolicy~=nil and v.accountingPolicy~=NATIVE then return false end
    local native=v.accountingPolicy==NATIVE
    if v.accountingEvidence~=nil then
        local e=v.accountingEvidence
        if type(e)~="table" or not nativeID(e.currencyID) or not nativeInteger(e.spent) or
            not nativeInteger(e.quantity) or not nativeInteger(e.totalPurchased) or e.totalPurchased~=e.spent or
            e.sourcePin~=SOURCE_PIN or not native then return false end
    end
    if not optional(v.currenciesComplete,boolean) or not optional(v.currencies,traitCurrencies) then return false end
    if native and (not nativeID(v.id) or v.accountingEvidence==nil or v.purchased>v.accountingEvidence.totalPurchased or
        v.currenciesComplete~=true or not traitCurrencies(v.currencies)) then return false end
    local seen, sum, cap={},0,0
    if not array(v.paths,64,function(p)
        if not path(p) or not positive(p.id) or seen[p.id] or not Core.Integer(p.purchased) or
            not Core.Integer(p.capacity) or p.purchased>p.capacity or p.childrenComplete~=true or
            type(p.node)~="table" or not positive(p.unlockEntryID) or type(p.unlock)~="table" then return false end
        for _,key in ipairs({"ranksPurchased","ranksIncreased","currentRank","maxRanks"}) do
            if not Core.Integer(p.node[key]) then return false end
        end
        if p.unlock.maxRanks~=0 and p.unlock.maxRanks~=1 then return false end
        if native then
            local n,u,s=p.node,p.unlock,p.spend
            if p.metadataComplete~=true or p.costRule~="unknown" or not nativeID(p.spendCurrencyID) or
                p.spendCurrencyID~=v.accountingEvidence.currencyID or not nativeID(p.spendEntryID) or
                p.spendEntryID==p.unlockEntryID or not entry(s) or s.type~=7 or u.type~=9 or
                not nativeInteger(s.maxRanks) or s.maxRanks==0 or n.maxRanks~=u.maxRanks+s.maxRanks or
                n.ranksIncreased~=0 or n.currentRank~=n.ranksPurchased or n.activeRank~=n.currentRank or
                n.totalMaxRanks~=n.maxRanks or n.type~=1 or n.flags~=0 or type(n.isAvailable)~="boolean" or
                p.purchased~=(n.ranksPurchased>0 and n.ranksPurchased-u.maxRanks or 0) or
                p.capacity~=n.maxRanks-u.maxRanks or type(p.locked)~="boolean" or
                p.locked~=(n.ranksPurchased==0 and u.maxRanks==1) or not nativeID(n.ID) or n.ID~=p.id or
                not uniqueIDs(n.entryIDs,32) or #n.entryIDs~=2 or not uniqueIDs(n.entryIDsWithCommittedRanks,32) or
                not increasedMap(n.entryIDToRanksIncreased) or not entryRank(n.activeEntry) or
                not costs(p.costs) or #p.costs~=1 or p.costs[1].amount~=1 then return false end
            local pair={[p.unlockEntryID]=true,[p.spendEntryID]=true}
            for _,entryID in ipairs(n.entryIDs) do if not pair[entryID] then return false end end
            local count=0
            for entryID,ranks in pairs(n.entryIDToRanksIncreased) do
                count=count+1; if not pair[entryID] or ranks~=0 then return false end
            end
            if count~=2 then return false end
            local committed={}
            for _,entryID in ipairs(n.entryIDsWithCommittedRanks) do
                if not pair[entryID] then return false end; committed[entryID]=true
            end
            local rp=n.ranksPurchased
            local active=n.activeEntry
            if rp>u.maxRanks then
                if active.entryID~=p.spendEntryID or active.rank~=p.purchased then return false end
            elseif active.entryID~=p.unlockEntryID or active.rank~=rp then return false end
            if (rp==0 and #n.entryIDsWithCommittedRanks~=0) or (rp>0 and not committed[active.entryID]) then return false end
            if rp==n.maxRanks then if n.nextEntry~=nil then return false end
            elseif not entryRank(n.nextEntry) or not pair[n.nextEntry.entryID] or n.nextEntry.rank==0 or
                n.nextEntry.entryID~=(p.locked and p.unlockEntryID or p.spendEntryID) then return false end
            for _,e in ipairs({u,s}) do
                if e.entryCostComplete~=true or not costs(e.entryCost) or #e.entryCost~=0 then return false end
            end
            local rows={}
            for _,row in ipairs(v.currencies) do rows[row.traitCurrencyID]=row end
            local shared=rows[p.spendCurrencyID]
            if not shared or shared.quantity~=v.accountingEvidence.quantity or shared.spent~=v.accountingEvidence.spent or
                (p.locked and (p.costs[1].ID==p.spendCurrencyID or not rows[p.costs[1].ID])) or
                (not p.locked and p.costs[1].ID~=p.spendCurrencyID) then return false end
        end
        seen[p.id]=p; sum=sum+p.purchased; cap=cap+p.capacity
        return true
    end) then return false end
    if not seen[v.root] or v.coverage.captured~=#v.paths or v.coverage.discovered~=#v.paths or
        v.coverage.limit or sum~=v.purchased or cap~=v.capacity then return false end
    local visited, count={},0
    local function visit(id)
        if visited[id] or not seen[id] then return false end
        visited[id]=true; count=count+1
        for _,child in ipairs(seen[id].children) do if not visit(child) then return false end end
        return true
    end
    return visit(v.root) and count==#v.paths
end
-- U03: optional, independently timed coherent client-description snapshot.
local function professionDetails(v)
    local function name(x)
        return type(x)=="string" and #x>=1 and #x<=256 and x:match("%S")~=nil and not x:find("[%c|]")
    end
    if type(v)~="table" or not nativeID(v.version) or v.version~=1 or not nativeID(v.skillLineID) or v.skillLineID~=2913 or not nativeID(v.configID) or
        not Core.Integer(v.sourceScanAt) then return false end
    local trees,paths,perks={}, {}, {}
    local pathCount,perkCount,bytes=0,0,0
    local function description(x,required)
        if type(x)~="string" or #x>4096 or (required and not x:match("%S")) then return false end
        bytes=bytes+#x; return bytes<=32768
    end
    return array(v.trees,8,function(t)
        if type(t)~="table" or not nativeID(t.id) or trees[t.id] or not optional(t.name,name) or
            not nativeID(t.root) or not nativeInteger(t.purchased) or not nativeID(t.capacity) or
            t.purchased>t.capacity then return false end
        trees[t.id]=true
        local sum,cap,root=0,0,false
        if not array(t.paths,64,function(p)
            pathCount=pathCount+1
            if pathCount>64 or type(p)~="table" or not nativeID(p.id) or paths[p.id] or
                not optional(p.name,name) or not nativeInteger(p.purchased) or not nativeID(p.capacity) or
                p.purchased>p.capacity or not boolean(p.locked) or (p.locked and p.purchased~=0) or
                not description(p.description,false) then return false end
            paths[p.id]=true; root=root or p.id==t.root
            sum=sum+p.purchased; cap=cap+p.capacity
            return array(p.perks,32,function(k)
                perkCount=perkCount+1
                if perkCount>512 or type(k)~="table" or not nativeID(k.id) or perks[k.id] or
                    not nativeInteger(k.rank) or k.rank>p.capacity or not nativeInteger(k.state) or (k.state~=0 and k.state~=2) or
                    not boolean(k.isMajorPerk) or not description(k.description,true) or
                    (k.state==2 and (p.locked or k.rank>p.purchased)) then return false end
                perks[k.id]=true; return true
            end)
        end) then return false end
        return root and sum==t.purchased and cap==t.capacity
    end) and #v.trees>0
end
local validators={
    professionDetails=professionDetails,
    skill=function(v)
        return type(v)=="table" and Core.Integer(v.skillLevel) and Core.Integer(v.maxSkillLevel) and finite(v.skillModifier)
    end,
    unspent=Core.Integer,
    slots=function(v) return type(v)=="table" and boolean(v.complete) and idList(v.indices,16) end,
    knowledgeIndex=function(v) return array(v,8,tabIdentity) end,
    knowledgeRaw=rawKnowledge,
    environment=function(v) return type(v)=="table" and label(v.version) and optional(v.locale,label) end,
}
local function currency(v)
    return type(v)=="table" and positive(v.id) and Core.Integer(v.quantity) and optional(v.name,label) and
        optional(v.maxQuantity,Core.Integer) and optional(v.rechargingCycleDurationMS,function(n) return finite(n) and n>=0 end) and
        optional(v.rechargingAmountPerCycle,function(n) return finite(n) and n>=0 end)
end
validators.concentration=currency; validators.moxie=currency
local function registered(key)
    if type(key)~="string" then return nil end
    if validators[key] then return validators[key] end
    if equipmentKey(key) then return function(v) return gear(v,key) end end
    local id=tonumber(key:match("^tree:([1-9]%d*)$"))
    if positive(id) then return function(v) return tree(v,id) end end
end
function Core.ValidPayload(key,value,statusName)
    local validate=registered(key)
    if not validate then return false end
    if value==nil then return statusName~="observed" end
    return validate(value)==true
end
local function validIdentity(v,id)
    return type(v)=="table" and positive(v.skillLineID) and v.skillLineID==id and positive(v.parentID) and
        positive(v.profession) and positive(v.expansionID) and optional(v.name,label) and optional(v.expansionName,label)
end

local function validFields(fields, generation)
    if type(fields) ~= "table" then return false end
    for key, f in pairs(fields) do
        if not registered(key) or type(f) ~= "table" or not validAttempt(f.attempt) then return false end
        local l = f.last
        if l ~= nil and (type(l) ~= "table" or not success[l.status] or not Core.Integer(l.observedAt) or
            type(l.build) ~= "string" or l.generation ~= generation or
            not Core.ValidPayload(key,l.value,l.status)) then return false end
    end
    return true
end
local function validGeneration(g, id)
    if not (type(g) == "table" and Core.Integer(g.generation, 1) and
        validIdentity(g.identity,id) and Core.Integer(g.scannedAt) and
        validFields(g.fields, g.generation)) then return false end
    for key,f in pairs(g.fields) do
        local v=f.last and f.last.value
        if type(v)=="table" and (v.policy==NATIVE or v.accountingPolicy==NATIVE) then
            local expected=Core.NativeKnowledgeCurrency(g.identity)
            if not expected then return false end
            -- Attribution belongs to registered Knowledge fields, not tolerated
            -- extension metadata on unrelated typed payloads (e.g. skill.policy).
            if key=="knowledgeRaw" and v.policy==NATIVE then
                for _,key in ipairs({"skillLineID","parentID","profession","expansionID"}) do
                    if v.identity[key]~=g.identity[key] then return false end
                end
            end
            if key:match("^tree:") and v.accountingPolicy==NATIVE and
                v.accountingEvidence.currencyID~=expected then return false end
        end
    end
    if g.fields.professionDetails~=nil and not detailsScope(g.identity) then return false end
    return true
end
function Core.ValidClassToken(value)
    return type(value)=="string" and #value>=1 and #value<=32 and value:match("^[A-Z]+$")~=nil
end
function Core.Open(db)
    if db == nil then return {schema=1, characters={}}, nil end
    if type(db) ~= "table" or getmetatable(db) or db.schema ~= 1 or type(db.characters) ~= "table" then
        return nil, "Unsupported or invalid CraftArmyDB; writes disabled. Back up saved data."
    end
    if not boundedData(db, false) then return nil, "Invalid saved data; writes disabled (no reset)." end
    for guid, c in pairs(db.characters) do
        if type(guid) ~= "string" or guid == "" or type(c) ~= "table" or
            type(c.name) ~= "string" or type(c.realm) ~= "string" or
            (c.classToken~=nil and not Core.ValidClassToken(c.classToken)) or
            type(c.professions) ~= "table" then return nil, "Invalid character; writes disabled." end
        for id, p in pairs(c.professions) do
            if not Core.Integer(id, 1) or type(p) ~= "table" or
                not Core.Integer(p.nextGeneration, 1) or not array(p.archives,50000,function(v) return type(v)=="table" end) then
                return nil, "Invalid profession; writes disabled."
            end
            local highest, used = 0, {}
            if p.active ~= nil then
                if not validGeneration(p.active, id) then return nil, "Invalid active generation; writes disabled." end
                highest = p.active.generation; used[highest] = true
            end
            for i, g in pairs(p.archives) do
                if not Core.Integer(i, 1) or i > #p.archives or not validGeneration(g, id) or
                    not Core.Integer(g.archivedAt) or type(g.archiveReason) ~= "string" or used[g.generation] then
                    return nil, "Invalid archive; writes disabled."
                end
                used[g.generation] = true; highest = math.max(highest, g.generation)
            end
            if p.nextGeneration <= highest then return nil, "Invalid generation counter; writes disabled." end
        end
    end
    return db
end

-- Preflight-only mirror of an already Open-validated graph. Unlike Core.Copy,
-- memoization retains aliases so a simulated map-key write reaches every alias
-- of that map, without rewriting aliases of the old character object.
local function candidateMirror(db)
    local memo,count={},0
    local finite,integer=protectedWalkNumbers("invalid mirror value", "invalid mirror key")
    local function mirror(value,depth)
        count=count+1
        if count>50000 or depth>20 then error("mirror traversal limit") end
        local kind=type(value)
        if kind=="nil" or kind=="boolean" then return value end
        if kind=="number" and finite(value) then return value end
        if kind=="string" and #value<=4096 then return value end
        if kind~="table" or getmetatable(value) then error("invalid mirror value") end
        if memo[value] then return memo[value] end
        local out={}; memo[value]=out
        for key,child in pairs(value) do
            if not ((type(key)=="string" and #key<=128) or integer(key)) then error("invalid mirror key") end
            out[key]=mirror(child,depth+1)
        end
        return out
    end
    local ok,result=pcall(mirror,db,0)
    if ok then return result end
    return nil
end

function Core.Apply(db, character, identity, observations, at, build)
    if type(db) ~= "table" then return nil, "Open/validate saved data before applying a scan" end
    local valid, reason = Core.Open(db)
    if not valid then return nil, reason end
    local incoming = Core.Copy({character, identity, observations})
    if not incoming then return nil, "Invalid scan data" end
    character, identity, observations = incoming[1], incoming[2], incoming[3]
    if type(character) ~= "table" or type(character.guid) ~= "string" or character.guid == "" or
        type(character.name) ~= "string" or type(character.realm) ~= "string" or
        (character.classToken~=nil and not Core.ValidClassToken(character.classToken)) or
        type(identity) ~= "table" or type(observations) ~= "table" or not validIdentity(identity,identity.skillLineID) or
        not Core.Integer(at) or not label(build) then
        return nil, "Invalid scan identity"
    end
    local old = db.characters[character.guid]
    local c = old and Core.Copy(old) or {professions={}}
    c.name, c.realm = character.name, character.realm
    if character.classToken~=nil then c.classToken=character.classToken end
    local id = identity.skillLineID
    local p = c.professions[id] or {nextGeneration=1, archives={}}
    local g = p.active
    if g and (g.identity.parentID ~= identity.parentID or g.identity.profession ~= identity.profession or
        g.identity.expansionID ~= identity.expansionID) then return nil, "Profession identity changed" end
    if not g then
        g = {generation=p.nextGeneration, identity=identity, fields={}}
        p.nextGeneration = p.nextGeneration + 1
    end
    g.identity = identity
    for key, observation in pairs(observations) do
        if not validOwnedObservation(observation) or not Core.ValidPayload(key,observation.value,observation.status) then
            return nil,"Invalid production field payload: "..tostring(key)
        end
        local merge=equipmentKey(key) and mergeEquipment or mergeOwned
        local field, why = merge(g.fields[key], observation, build, g.generation, mergeOwned)
        if not field then return nil, why end
        g.fields[key] = field
    end
    g.scannedAt = at
    if not validGeneration(g,id) then return nil,"Invalid candidate generation/scope" end
    p.active = g; c.professions[id] = p
    -- Simulate exactly the single real write on an alias-preserving mirror. A
    -- shallow root or ordinary Copy would undercount aliased characters maps.
    local proposal=candidateMirror(db)
    if not proposal then return nil,"Bounded saved data mirror unavailable; scan not applied" end
    proposal.characters[character.guid]=c
    if not boundedData(proposal, false) then return nil,"Assembled snapshot exceeds bounded saved data limits" end
    db.characters[character.guid] = c
    return g
end

function Core.Archive(db, guid, id, at, reason)
    if type(db) ~= "table" or not Core.Open(db) or not Core.Integer(at) or
        type(reason) ~= "string" or #reason>4096 then return false end
    local c = db.characters[guid]
    local p = c and c.professions[id]
    if not p or not p.active then return false end
    local archived = Core.Copy(p.active)
    archived.archivedAt, archived.archiveReason = at, reason
    p.archives[#p.archives+1] = archived; p.active = nil
    return true
end

-- Only a source-proven complete roster may archive by absence. Production currently
-- does not assert that contract; nil/partial/closed UI cannot establish unlearning.
function Core.CompareRoster(db, guid, learned, authoritative, at)
    if authoritative ~= true or type(learned) ~= "table" or not Core.Integer(at) then return false end
    if type(db) ~= "table" then return false end
    if not Core.Open(db) then return false end
    local c = db.characters[guid]
    if c then
        for id, p in pairs(c.professions) do
            if p.active and learned[p.active.identity.parentID] ~= true then
                Core.Archive(db, guid, id, at, "unlearned (complete roster)")
            end
        end
    end
    return true
end

function Core.Delete(db, scope, confirmed)
    if confirmed ~= true or type(db) ~= "table" or not Core.Open(db) or type(scope) ~= "table" then return false end
    local c = db.characters[scope.guid]
    if not c then return false end
    if scope.character == true then db.characters[scope.guid] = nil; return true end
    local p = c.professions[scope.id]
    if not p or not Core.Integer(scope.generation, 1) then return false end
    if p.active and p.active.generation == scope.generation then p.active = nil; return true end
    for i, g in ipairs(p.archives) do
        if g.generation == scope.generation then table.remove(p.archives, i); return true end
    end
    return false
end
