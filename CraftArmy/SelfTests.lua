local _, NS = ...
local Tests = {cases={}}
NS.SelfTests = Tests
local function case(name, fn) Tests.cases[#Tests.cases+1]={name=name, fn=fn} end
local function eq(a,b,context) assert(a == b, (context and context..": " or "")..tostring(a).." ~= "..tostring(b)) end
local C, K, I = NS.Core, NS.Knowledge, NS.ViewModel.index
local function clean(value, limit)
    if type(value)~="string" then return "unspecified" end
    return (value:gsub("[%c|]"," "):sub(1,limit or 128))
end
local function pause(checkpoint,label) if checkpoint then checkpoint(label) end end

-- K4: fixture-only, synchronous observation. No checkpoints/output under wrappers.
-- Reports contain only fixed keys/reasons and scalar timings, never fixture graphs.
local timingTags={"O","A","C","K","E","G","B"}
local timingReasons={
    ["clock missing"]=true,["clock error"]=true,["clock nonfinite"]=true,
    ["clock backward"]=true,["probe cap"]=true,["depth cap"]=true,
    ["invalid partition"]=true,["invalid report"]=true,
}
local function pack(...) return {n=select("#",...),...} end
function Tests.MeasureScan(collector,clock)
    local bindings,stages,stack={}, {}, {}
    local reason,last,probes,root= nil,nil,0,nil
    local function unavailable(why) if not reason then reason=why end end
    local function readClock()
        if reason then return nil end
        if type(clock)~="function" then unavailable("clock missing"); return nil end
        if probes>=10000 then unavailable("probe cap"); return nil end
        probes=probes+1
        local ok,value=pcall(clock)
        if not ok then unavailable("clock error"); return nil end
        if not C.Finite(value) then unavailable("clock nonfinite"); return nil end
        if last and value<last then unavailable("clock backward"); return nil end
        last=value
        return value
    end
    local function nonnegative(value)
        if not C.Finite(value) or value<0 then unavailable("invalid partition"); return false end
        return true
    end
    local function restore()
        for i=#bindings,1,-1 do
            local b=bindings[i]; rawset(b.target,b.key,b.original); bindings[i]=nil
        end
    end
    local function wrap(target,key,tag)
        local original=target[key]
        assert(type(original)=="function")
        bindings[#bindings+1]={target=target,key=key,original=rawget(target,key)}
        rawset(target,key,function(...)
            if reason then return original(...) end
            -- The root Scan frame counts toward the 64 active-frame cap.
            if #stack>=64 then unavailable("depth cap"); return original(...) end
            local started=readClock()
            if not started then return original(...) end
            local frame={started=started,children=0}
            stack[#stack+1]=frame
            local values=pack(original(...)) -- preserve trailing/interior nils
            local finished=readClock()
            stack[#stack]=nil
            if finished then
                local inclusive=finished-frame.started
                local exclusive=inclusive-frame.children
                local s=stages[tag]; local parent=stack[#stack]
                if nonnegative(inclusive) and nonnegative(exclusive) then
                    s.calls=s.calls+1
                    s.inclusiveMs=s.inclusiveMs+inclusive
                    s.exclusiveMs=s.exclusiveMs+exclusive
                    parent.children=parent.children+inclusive
                    nonnegative(s.inclusiveMs); nonnegative(s.exclusiveMs); nonnegative(parent.children)
                end
            end
            return unpack(values,1,values.n)
        end)
    end
    local ok,first,second,report=pcall(function()
        if readClock() then
            for _,tag in ipairs(timingTags) do stages[tag]={calls=0,inclusiveMs=0,exclusiveMs=0} end
            wrap(C,"Open","O"); wrap(C,"Apply","A"); wrap(C,"Copy","C")
            wrap(K,"Evaluate","E"); wrap(collector,"Knowledge","K")
            wrap(collector,"Gear","G"); wrap(collector,"Context","B")
            root=readClock() -- bracket Scan, not wrapper installation/cleanup
            if root then stack[1]={started=root,children=0} else restore() end
        end
        -- An initially unusable clock executes this same original Scan unwrapped.
        local a,b=collector:Scan()
        if not reason then
            local finished=readClock()
            if finished then
                local total=finished-root; local other=total-stack[1].children
                local partition=other
                for _,tag in ipairs(timingTags) do partition=partition+stages[tag].exclusiveMs end
                if nonnegative(total) and nonnegative(other) and nonnegative(partition)
                    and math.abs(partition-total)<=0.000001 then
                    return a,b,{status="observed",totalMs=total,otherMs=other,stages=stages}
                end
                unavailable("invalid partition")
            end
        end
        return a,b,{status="unavailable",reason=reason}
    end)
    -- Reverse installation order, including on original errors and mid-clock failure.
    restore()
    if not ok then error("timed scan failed (payload omitted)",0) end
    return first,second,report
end
function Tests.FormatScanTiming(report)
    local function unknown(reason)
        return "scan2 timings unavailable ("..(timingReasons[reason] and reason or "invalid report")..")"
    end
    if type(report)~="table" or getmetatable(report)~=nil then return unknown() end
    if report.status~="observed" then return unknown(report.reason) end
    if not C.Finite(report.totalMs) or report.totalMs<0 then return unknown() end
    local values={report.totalMs}
    if type(report.stages)~="table" or getmetatable(report.stages)~=nil then return unknown() end
    for _,tag in ipairs(timingTags) do
        local s=report.stages[tag]
        if type(s)~="table" or getmetatable(s)~=nil then return unknown() end
        values[#values+1]=s.exclusiveMs
        if not C.Finite(s.exclusiveMs) or s.exclusiveMs<0 then return unknown() end
    end
    values[9]=report.otherMs
    local parts={"scan2 ms excl"}
    for i,tag in ipairs({"T","O","A","C","K","E","G","B","R"}) do
        local value=values[i]
        if not C.Finite(value) or value<0 then return unknown() end
        parts[#parts+1]=tag.."="..(value>99999 and ">99999" or string.format("%.1f",value))
    end
    return table.concat(parts," ")
end

-- Only native Lua resumes/yields: never wrap a case in pcall (Lua 5.1 cannot
-- yield through that C boundary). Protected fixture helpers finish before pausing.
function Tests.NewRunner(cases)
    local r={passed=0,failed=0,lines={},total=0,index=0,steps=0,status="running",completed=false}
    local list,thread,apply,evaluate,note
    local token={}
    local function stop(reason)
        r.status="incomplete"; r.completed=false; r.reason=clean(reason,256)
        list=nil; thread=nil; apply=nil; evaluate=nil; note=nil
        return r
    end
    function r:Cancel(reason)
        if self.status=="running" then return stop(reason or "cancelled") end
        return self
    end
    local source=cases
    if source==nil then source=Tests.cases end
    list={}
    if type(source)~="table" or getmetatable(source)~=nil then stop("malformed cases")
    else
        local count=0
        for k,t in pairs(source) do
            count=count+1
            if count>512 or not C.Integer(k,1) or k>512 or type(t)~="table" or getmetatable(t)~=nil
                or type(t.name)~="string" or type(t.fn)~="function" then
                stop("malformed cases or 512 case cap"); break
            end
            list[k]={name=clean(t.name),fn=t.fn}
        end
        if r.status=="running" then
            for i=1,count do if not list[i] then stop("sparse cases"); break end end
            r.total=count
        end
    end
    function r:Step()
        self.lastLine=nil
        if self.status~="running" then return self end
        if self.steps>=10000 then return stop("10000 step cap") end
        if not thread then
            if self.index>=self.total then
                self.status="complete"; self.completed=true; list=nil; return self
            end
            self.index=self.index+1; self.name=list[self.index].name
            self.label="case entry"; self.unit=0; note=nil
            apply,evaluate=C.Apply,K.Evaluate
            local fn=list[self.index].fn
            thread=coroutine.create(function()
                fn(function(label)
                    if C.Apply~=apply or K.Evaluate~=evaluate then
                        error("unsafe checkpoint: fixture overrides still active",0)
                    end
                    coroutine.yield(token,clean(label or "checkpoint"))
                end,function(label)
                    if C.Apply~=apply or K.Evaluate~=evaluate then
                        error("unsafe annotation: fixture overrides still active",0)
                    end
                    note=clean(label,128) -- non-yielding, last note only
                end)
            end)
        end
        -- Unexpected shared-function drift between frames is not ours to restore.
        if C.Apply~=apply or K.Evaluate~=evaluate then return stop("function identity drift; reload required") end
        self.steps=self.steps+1; self.unit=self.unit+1
        local ok,value,label=coroutine.resume(thread)
        if C.Apply~=apply or K.Evaluate~=evaluate then return stop("function identity drift; reload required") end
        if coroutine.status(thread)~="dead" then
            if not ok or value~=token then return stop("unexpected coroutine yield") end
            self.label=label
            return self
        end
        self.label=note and clean("case return; "..note,128) or "case return"
        if ok then self.passed=self.passed+1 else self.failed=self.failed+1 end
        self.lastLine=(ok and "PASS " or "FAIL ")..self.name..(ok and "" or ": "..clean(type(value)=="string" and value or "case error",256))
        if note then self.lastLine=self.lastLine.."; "..note end
        self.lines[#self.lines+1]=self.lastLine
        thread=nil; apply=nil; evaluate=nil; note=nil
        if self.index==self.total then self.status="complete"; self.completed=true; list=nil end
        return self
    end
    return r
end
local function nonfiniteSamples()
    -- Actual arithmetic NaN; never gate this sample on self-equality in WoW.
    return {{name="NaN (0/0)",value=0/0},{name="+infinity",value=math.huge},{name="-infinity",value=-math.huge}}
end
local function path(u, purchased, max)
    return {children={}, childrenComplete=true, unlockEntryID=100,
        unlock={maxRanks=u}, costRule="verified-unit-spend", costEvidence="synthetic exact rule",
        node={ranksPurchased=purchased, currentRank=purchased, ranksIncreased=0, maxRanks=max}}
end
local function scan()
    return {configID=1, stagedStart=false, stagedEnd=false, stable=true, tabsComplete=true,
        tabs={{id=11, name="Synthetic tree", root=72, coverageComplete=true,
            paths={[72]=path(1,1,11), [73]=path(0,5,10)}}}}
end
case("knowledge mixed unlock sizes, locked zero and children", function()
    local s=scan(); s.tabs[1].paths[72].children={73,74}; s.tabs[1].paths[74]=path(1,0,6)
    local r=K.Evaluate(s); eq(r.complete,true); eq(r.trees[1].purchased,5); eq(r.trees[1].capacity,25)
    eq(K.PathPoints(path(0,10,10)).purchased,10)
end)
case("knowledge missing/invalid/free/cost/staging inputs never total", function()
    local changes={
        function(s) s.tabs[1].paths[72].unlock=nil end,
        function(s) s.tabs[1].paths[72].node.ranksPurchased=-1 end,
        function(s) s.tabs[1].paths[72].node.ranksIncreased=1 end,
        function(s) s.tabs[1].paths[72].costRule="variable" end,
        function(s) s.tabs[1].paths[72].costRule=nil end,
        function(s) s.stagedStart=true end, function(s) s.stagedEnd=nil end,
        function(s) s.tabs[1].paths[72].unlock.maxRanks=2 end,
        function(s) s.tabs[1].paths[72].unlock=false end,
    }
    for _, change in ipairs(changes) do local s=scan(); change(s); eq(K.Evaluate(s).trees[1].purchased,nil) end
end)
case("knowledge cycles, duplicate/shared, missing children, limits", function()
    for _, children in ipairs({{72},{73,73},{999}}) do
        local s=scan(); s.tabs[1].paths[72].children=children; eq(K.Evaluate(s).complete,false)
    end
    local s=scan(); local t=C.Copy(s.tabs[1]); t.id=12; s.tabs[2]=t
    local r=K.Evaluate(s); eq(r.trees[1].purchased,nil); eq(r.trees[2].capacity,nil)
    s=scan(); s.tabs[1].paths[72].children={}
    for i=1,17 do s.tabs[1].paths[72].children[i]=100+i end
    eq(K.Evaluate(s).trees[1].coverage.limit,true)
end)
case("knowledge four tabs 35 paths and shared currency once", function()
    local s=scan(); s.tabs={}; local spent=0
    for tab,n in ipairs({9,4,9,13}) do
        local t={id=tab, root=tab*100+72, paths={}, coverageComplete=true}
        s.tabs[tab]=t
        for i=1,n do
            local id=tab*100+71+i; t.paths[id]=path(i%2,2,6)
            if i<n then t.paths[id].children={id+1} end
            spent=spent+2-i%2
        end
    end
    s.shared={applicable=true, spent=spent}; local r=K.Evaluate(s)
    eq(r.complete,true); eq(r.sharedSpent,spent); eq(r.trees[4].coverage.captured,13)
    s.shared.spent=spent+1; r=K.Evaluate(s); eq(r.trees[1].purchased,nil)
end)
local identity={skillLineID=2913,parentID=773,profession=13,expansionID=11,name="Inscription",expansionName="Midnight"}
local character={guid="Player-Fixture-A",name="Fixture",realm="Synthetic"}
local function treeValue(id,purchased,capacity)
    local p=path(0,purchased,capacity); p.id=id+100; p.purchased=purchased; p.capacity=capacity
    return {id=id,name="Synthetic tree",root=p.id,paths={p},complete=true,purchased=purchased,capacity=capacity,
        coverage={discovered=1,captured=1,limit=false}}
end
local function dbWith(fields,guid)
    local db=C.Open(nil)
    local c=C.Copy(character); c.guid=guid or c.guid
    local obs={}
    for key,value in pairs(fields or {}) do obs[key]=C.Observation("observed",value,10,"fixture") end
    local g,why=C.Apply(db,c,identity,obs,10,"fixture-build")
    assert(g,why)
    return db,g,c
end
local function fixtureAPI()
    local state={at=100,shown=true,combat=false,linked=false,guild=false,npc=false,changing=false,
        ready=true,staged=false,requests=0,reads=0,slots={22,20,21},timers={}}
    local env={Enum={TooltipDataLineType={ItemEnchantmentPermanent=15}},C_TradeSkillUI={},C_ProfSpecs={},C_Traits={},C_Item={},C_CurrencyInfo={}}
    local info={profession=13,professionID=2913,parentProfessionID=773,isPrimaryProfession=true,
        professionName="Inscription",expansionName="Midnight",sourceCounter=1,
        skillLevel=0,maxSkillLevel=100,skillModifier=40}
    state.info=info
    env.GetServerTime=function() return state.at end
    env.GetBuildInfo=function() return "fixture-version","fixture-build" end
    env.GetLocale=function() return "fixture-locale" end
    env.UnitGUID=function(unit) eq(unit,"player"); state.reads=state.reads+1; return character.guid end
    env.UnitName=function(unit) eq(unit,"player"); return character.name end
    env.GetRealmName=function() return character.realm end
    env.InCombatLockdown=function() return state.combat end
    env.GetProfessions=function() return 1,nil end
    env.GetProfessionInfo=function(index) eq(index,1); return "Inscription",0,100,100,0,0,773 end
    env.ProfessionsFrame={IsShown=function() return state.shown end}
    local t=env.C_TradeSkillUI
    t.IsTradeSkillLinked=function() return state.linked end
    t.IsTradeSkillGuild=function() return state.guild end
    t.IsTradeSkillGuildMember=function() return false end
    t.IsNPCCrafting=function() return state.npc end
    t.IsDataSourceChanging=function() return state.changing end
    t.IsTradeSkillReady=function() return state.ready end
    t.GetChildProfessionInfo=function() return state.info end
    t.GetBaseProfessionInfo=function() return {professionID=773} end
    t.GetProfessionSlots=function(profession) eq(profession,13); return state.slots end
    t.GetConcentrationCurrencyID=function(id) eq(id,2913); return 50001 end
    t.GetItemCraftedQualityByItemInfo=function() return state.rank or 5 end
    t.GetItemCraftedQualityInfo=function() return {quality=5,iconSmall="fixture-atlas"} end
    env.C_CurrencyInfo.GetCurrencyInfo=function(id)
        assert(id==50001 or id==3261)
        return {quantity=0,maxQuantity=id==50001 and 1000 or 0,rechargingCycleDurationMS=1000,rechargingAmountPerCycle=1}
    end
    env.ItemLocation={CreateFromEquipmentSlot=function(_,slot) return {slot=slot} end}
    local item=env.C_Item
    item.DoesItemExist=function(loc) return state.empty~=loc.slot end
    item.GetItemID=function(loc) return state.itemID or (90000+loc.slot) end
    item.GetItemLink=function(loc)
        if state.noLink then return nil end
        return "item:"..(state.itemID or 90000+loc.slot)..":"..(state.enchantID or 0)..":0:0"
    end
    item.IsItemDataCached=function() return not state.loading end
    item.GetItemQuality=function() return state.rarity or 3 end
    item.GetItemIcon=function() return 1234 end
    item.GetItemStats=function() return {ITEM_MOD_MULTICRAFT_SHORT=152,ITEM_MOD_RESOURCEFULNESS_SHORT=12} end
    item.RequestLoadItemData=function() state.requests=state.requests+1 end
    env.C_TooltipInfo={GetInventoryItem=function(unit) eq(unit,"player"); return {lines=state.positive and {{type=15,leftText="Synthetic enchant"}} or {}} end}
    local p=env.C_ProfSpecs
    p.GetConfigIDForSkillLine=function() return 1001 end
    p.GetSpecTabIDsForSkillLine=function() return {1002} end
    p.GetTabInfo=function() return {name="Synthetic tree"} end
    p.GetRootPathForTab=function() return 1072 end
    p.GetChildrenForPath=function() return {} end
    p.GetUnlockEntryForPath=function() return 1100 end
    p.GetCurrencyInfoForSkillLine=function() return {numAvailable=0} end
    local traits=env.C_Traits
    traits.ConfigHasStagedChanges=function() return state.staged end
    traits.GetNodeInfo=function() return {ranksPurchased=1,currentRank=1,ranksIncreased=0,maxRanks=31} end
    traits.GetEntryInfo=function() return {maxRanks=1} end
    traits.GetNodeCost=function() return {{ID=3902,amount=1}} end
    traits.GetTreeCurrencyInfo=function() return {{traitCurrencyID=3902,quantity=0,spent=0}} end
    env.C_Timer={After=function(seconds,fn) state.timers[#state.timers+1]={seconds=seconds,fn=fn} end}
    local function forbidden() error("Forbidden gameplay/other-addon call") end
    env.CraftRecipe=forbidden; env.EquipItemByName=forbidden; env.Auctionator={API={v1={GetShoppingListItems=forbidden}}}
    env.CraftArmyDiagnosticsDB={sentinel=true}
    -- U13 READ_ACCOUNTING BEGIN
    state.u13GUIDReads=0; state.u13AcquisitionReads=0
    do
        local guid=env.UnitGUID
        env.UnitGUID=function(...)
            state.u13GUIDReads=state.u13GUIDReads+1
            return guid(...) -- Original unit assertion and total-read increment remain intact.
        end
        local function wrap(owner,key)
            local original=owner and owner[key]
            if type(original)~="function" then return end
            owner[key]=function(...)
                state.u13AcquisitionReads=state.u13AcquisitionReads+1
                return original(...) -- Tail forwarding preserves arguments, all results and errors.
            end
        end
        for _,name in ipairs({"C_TradeSkillUI","C_Item","C_CurrencyInfo","C_ProfSpecs","C_Traits","C_TooltipInfo"}) do
            local api=env[name]
            for key in pairs(api or {}) do wrap(api,key) end
        end
        wrap(env,"GetProfessions"); wrap(env,"GetProfessionInfo"); wrap(env.ItemLocation,"CreateFromEquipmentSlot")
    end
    -- U13 READ_ACCOUNTING END
    return env,state
end
-- U13 READ_GUARD BEGIN
local function u13NoAcquisition(state,fromStart)
    local reads=fromStart and 0 or state.reads
    local guid=fromStart and 0 or state.u13GUIDReads
    local acquired=fromStart and 0 or state.u13AcquisitionReads
    return function()
        eq(state.u13AcquisitionReads,acquired,"U13 no profession/gear/currency/Knowledge acquisition")
        eq(state.reads-reads,state.u13GUIDReads-guid,"U13 total-read delta equals own-GUID delta")
    end
end
-- U13 READ_GUARD END
case("field zero false nil error; attempt time distinct; GUID isolation",function()
    -- U11 LABELS BEGIN
    do
        local neutral=NS.Collectors.ToolStatLink
        local payload="item:90020:7977:0:0:0:0:0:0:100:0:0:13:2:9001:9002:2:29:1:38:5:0:0:0:Player-0-00000001:"
        local expected=payload:gsub("^item:90020:7977:","item:90020:0:",1)
        local labels={"[Synthetic Tool]","[Outil épatant |A:Professions-ChatIcon-Quality-Tier5:17:23::1|a]",
            "[工具 |TInterface\\Icons\\INV_Hammer_20:16:16|t]","[|cffff0000Tool|r]",
            "[|cffaabbcc工具|r |A:Professions-ChatIcon-Quality-Tier5:17:23::1|a |T1234:16|t]"}
        local function wrap(p,label,form)
            local link="|H"..p.."|h"..label.."|h"
            if form==2 then return "|cffaabbcc"..link.."|r" end
            if form==3 then return "|cnIQ5:"..link.."|r" end
            if form==4 then return "|cnIQ5"..link.."|r" end
            return link
        end
        local rejected={}
        for form=1,4 do for n,label in ipairs(labels) do
            if neutral(wrap(payload,label,form))~=expected then rejected[#rejected+1]=form.."/"..n end
        end end
        assert(#rejected==0,"U11 decorated-label rejection: "..table.concat(rejected,", "))
        for form=1,4 do
            local valid=wrap(payload,labels[2],form)
            local bounded=wrap(payload,string.rep("x",4096-#wrap(payload,"",form)),form)
            eq(#bounded,4096); eq(neutral(bounded),expected); eq(neutral(bounded.."x"),nil)
            for _,label in ipairs({"[nested |Hitem:1:0:0|h[x]|h]","[nested |Hitem:1:0:0]","[extra |h]",
                "[bad\n]","[bad\0]","[bad\127]"}) do eq(neutral(wrap(payload,label,form)),nil,"U11 unsafe label") end
            for _,bad in ipairs({valid.."garbage",valid..valid,"prefix"..valid,
                wrap(payload,labels[2],form):gsub("|h", "",1),
                wrap(payload.."_",labels[2],form),wrap(payload.."|A:unsafe|a",labels[2],form),
                wrap(payload.." ",labels[2],form),wrap("item:0:7977:0",labels[2],form),
                wrap("item:90020:-1:0",labels[2],form),wrap("item:2147483648:0:0",labels[2],form)}) do
                eq(neutral(bad),nil,"U11 invalid bounds/wrapper/payload")
            end
        end
        for _,bad in ipairs({"|cxyz|H"..payload.."|h[x]|h|r","|cnIQx|H"..payload.."|h[x]|h|r",
            "|cnIQ5::|H"..payload.."|h[x]|h|r",wrap(payload,labels[2],2):sub(1,-3)}) do eq(neutral(bad),nil) end
        local function open(raw)
            local job=NS.Storage.NewOpenJob(raw); while job.status=="running" do job:Step() end
            eq(job.status,"complete",job.reason); return job.result,job.savedRoot
        end
        -- Each wrapper independently exercises equipped-only and returned-only markup.
        -- Begin with old observations without either optional unit; use ordinary scans.
        for form=1,4 do for _,decoratedEquipped in ipairs({false,true}) do for _,decoratedReturned in ipairs({false,true}) do
            local env,state=fixtureAPI(); state.enchantID=7977
            local legacy=C.Open(nil); assert(NS.Collectors.New(env,legacy):Scan())
            local old=C.Copy(legacy)
            local db,root=open(legacy)
            local unknown=NS.ViewModel.NewBuildJob(db,{}, {},100)
            while unknown.status=="running" do unknown:Step() end
            eq(unknown.status,"complete")
            for _,role in ipairs({"accessory1","accessory2","tool"}) do
                eq(unknown.rows[1].gear[role].olderExpansion,false); eq(unknown.rows[1].gear[role].toolLetter,nil)
            end
            local links,infoArgs,statsArgs={},{},{}
            for _,slot in ipairs({20,21,22}) do
                local p=payload:gsub("^item:90020:","item:"..(90000+slot)..":",1)
                links[slot]=wrap(p,labels[decoratedEquipped and 5 or 1],form)
            end
            env.C_Item.GetItemLink=function(loc) return links[loc.slot] end
            env.C_Item.GetItemInfo=function(link)
                infoArgs[#infoArgs+1]=link
                local p=link:match("|H(item:[^|]+)|h")
                return nil,wrap(p,labels[decoratedReturned and 5 or 1],form),nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,10
            end
            env.C_Item.GetItemStats=function(link)
                statsArgs[#statsArgs+1]=link
                if link==expected then return {ITEM_MOD_MULTICRAFT_SHORT=100} end
                return {ITEM_MOD_MULTICRAFT_SHORT=100,ITEM_MOD_RESOURCEFULNESS_SHORT=12}
            end
            local collector=NS.Collectors.New(env,db); assert(collector:Scan())
            eq(#infoArgs,3); eq(#statsArgs,4); eq(state.requests,0); eq(#state.timers,0)
            local infoLinks={}
            for _,query in ipairs(infoArgs) do infoLinks[query]=(infoLinks[query] or 0)+1 end
            for _,link in pairs(links) do eq(infoLinks[link],1) end
            local neutralQueries=0
            for _,query in ipairs(statsArgs) do if query==expected then neutralQueries=neutralQueries+1 end end
            eq(neutralQueries,1)
            local current=NS.Storage.Active(db,character.guid,2913)
            for _,role in ipairs({"accessory1","accessory2","tool"}) do
                local gear=current.fields[role].last.value
                eq(gear.link,links[gear.slot]); eq(gear.itemExpansion.value,10); eq(gear.itemExpansion.observedAt,100)
                eq(gear.enchant.category,"Resourcefulness"); eq(gear.enchant.present,true); eq(gear.rank,5)
                if role=="tool" then eq(gear.toolStat.value,"Multicraft") else eq(gear.toolStat,nil) end
            end
            local reloaded=open(root)
            for _,source in ipairs({db,reloaded}) do
                local job=NS.ViewModel.NewBuildJob(source,{}, {},100)
                while job.status=="running" do job:Step() end
                eq(job.status,"complete",job.reason); eq(#job.rows,1)
                for _,role in ipairs({"accessory1","accessory2","tool"}) do
                    local gear=job.rows[1].gear[role]
                    eq(gear.olderExpansion,true); eq(gear.borderColor[1],.90); eq(gear.borderColor[2],.15)
                    eq(gear.toolLetter,role=="tool" and "M" or nil); eq(gear.enchanted,true); assert(gear.qualityAtlas)
                end
            end
            -- Also apply the ordinary collector reads through schema1/Core directly.
            local reads={}
            for _,role in ipairs({"accessory1","accessory2","tool"}) do
                local slot=({accessory1=21,accessory2=22,tool=20})[role]
                local gear,status=collector:Gear(slot,role); eq(status,"observed")
                reads[role]=C.Observation(status,gear,100,"U11")
            end
            local applied=assert(C.Apply(legacy,character,identity,reads,100,"fixture"))
            eq(C.Open(legacy),legacy); eq(applied.fields.tool.last.value.toolStat.value,"Multicraft")
            local schema2=open(legacy); eq(NS.Storage.Active(schema2,character.guid,2913).fields.tool.last.value.itemExpansion.value,10)
            for _,role in ipairs({"accessory1","accessory2","tool"}) do
                local prior=old.characters[character.guid].professions[2913].active.fields[role]
                if prior and prior.last then eq(prior.last.value.itemExpansion,nil); eq(prior.last.value.toolStat,nil) end
            end
        end end end
    end
    -- U11 LABELS END
    -- U10 METADATA BEGIN
    do
        local neutral=assert(NS.Collectors.ToolStatLink,"U10 missing ToolStatLink")
        do
            local crafted="item:90020:8005:0:0:0:0:0:0:100:0:0:13:2:9001:9002:2:29:1:38:5:0:0:0:Player-0-00000001:"
            local minimal="item:90020:8005:0:0"
            local function wrap(payload,form)
                if form==1 then return payload end
                local item="|H"..payload.."|h[Synthetic Tool]|h"
                if form==2 then return item end
                if form==3 then return "|cffaabbcc"..item.."|r" end
                if form==4 then return "|cnIQ3:"..item.."|r" end
                return "|cnIQ3"..item.."|r"
            end
            local rejected={}
            for _,payload in ipairs({minimal,crafted}) do for form=1,5 do
                local expected=payload:gsub("^item:90020:8005:","item:90020:0:",1)
                if neutral(wrap(payload,form))~=expected then
                    rejected[#rejected+1]=(payload==crafted and "craftedGUID" or "minimal").."/form"..form
                end
            end end
            assert(#rejected==0,"U10 parser-format rejection: "..table.concat(rejected,", "))
            local maxPayload="item:90020:8005:"..string.rep("a",4096-#"item:90020:8005:")
            eq(#maxPayload,4096); eq(neutral(maxPayload),maxPayload:gsub("^item:90020:8005:","item:90020:0:",1))
            for _,bad in ipairs({maxPayload.."a",crafted.."_",crafted.."/",crafted..".",crafted.." ",crafted.."\n",
                crafted.."\0",crafted.."|",crafted.."<x>",crafted.."[x]",crafted.."\"",crafted.."é",
                crafted.."item:90021:0:0",crafted.."|Hitem:90021:0:0|h[Second]|h",
                "item:x90020:8005:0:Player-0-1:","item:90020x:8005:0:Player-0-1:",
                "item:0:8005:0:Player-0-1:","item:2147483648:8005:0:Player-0-1:",
                "item:90020:-1:0:Player-0-1:","item:90020:8005x:0:Player-0-1:",
                "item:90020:2147483648:0:Player-0-1:","item:90020:8005",
                "|cnIQx|H"..crafted.."|h[Tool]|h|r","|cnIQ3::|H"..crafted.."|h[Tool]|h|r",
                wrap(crafted,5)..wrap(minimal,5),"|cnIQ3|H"..crafted.."|h[Tool|Hitem:1:0:0]|h|r"}) do
                eq(neutral(bad),nil,"unsafe/malformed extended item payload")
            end
            for _,payload in ipairs({minimal,crafted}) do for form=1,5 do
                local env,state=fixtureAPI()
                local equipped=wrap(payload,form); local returned=wrap(payload,form%5+1)
                local expected=payload:gsub("^item:90020:8005:","item:90020:0:",1)
                local statsArgs,infoArgs={},{}
                env.C_Item.GetItemLink=function(loc) eq(loc.slot,20); return equipped end
                env.C_Item.GetItemInfo=function(link)
                    infoArgs[#infoArgs+1]=link
                    return nil,returned,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,10
                end
                env.C_Item.GetItemStats=function(link)
                    statsArgs[#statsArgs+1]=link
                    if link==expected then return {ITEM_MOD_MULTICRAFT_SHORT=100} end
                    eq(link,equipped); return {ITEM_MOD_MULTICRAFT_SHORT=100,ITEM_MOD_RESOURCEFULNESS_SHORT=12}
                end
                local gear,status=NS.Collectors.New(env,C.Open(nil)):Gear(20,"tool")
                eq(status,"observed"); eq(gear.metadataReady,true); eq(gear.link,equipped)
                eq(#statsArgs,2); eq(statsArgs[1],equipped); eq(statsArgs[2],expected)
                eq(#infoArgs,1); eq(infoArgs[1],equipped)
                eq(gear.itemExpansion.value,10); eq(gear.itemExpansion.status,"observed"); eq(gear.itemExpansion.observedAt,100)
                eq(gear.toolStat.value,"Multicraft"); eq(gear.toolStat.status,"observed"); eq(gear.toolStat.observedAt,100)
                local db=C.Open(nil)
                local g=assert(C.Apply(db,character,identity,{tool=C.Observation("observed",gear,100,"U10")},100,"fixture"))
                eq(C.Open(db),db); eq(g.fields.tool.last.value.link,equipped)
                eq(g.fields.tool.last.value.toolStat.value,"Multicraft"); eq(g.fields.tool.last.value.itemExpansion.value,10)
                eq(state.requests,0); eq(#state.timers,0)
            end end
        end
        eq(neutral("item:90020:7977:0:0:-7:0:0:80:0:0:2:123:456:1:29:42"),
            "item:90020:0:0:0:-7:0:0:80:0:0:2:123:456:1:29:42")
        local env,optionalState=fixtureAPI(); optionalState.enchantID=7977
        env.C_Item.GetItemInfo=function(link) return "item",link,3,1,1,"","",1,"",1234,0,0,0,0,10 end
        env.C_Item.GetItemStats=function() return {ITEM_MOD_MULTICRAFT_SHORT=152} end
        local gear,status=NS.Collectors.New(env,C.Open(nil)):Gear(20,"tool")
        eq(status,"observed"); eq(gear.itemExpansion.value,10); eq(gear.toolStat.value,"Multicraft")
        eq(gear.itemExpansion.observedAt,100); eq(gear.toolStat.source,"C_Item.GetItemStats:unenchant-link-v1")
        local payload="item:90020::0:0:-7:0:0:80:0:0:2:123:456:1:29:42"
        for _,link in ipairs({payload,"|cffaabbcc|H"..payload.."|h[Tool]|h|r","|cnIQ4:|H"..payload.."|h[Tool]|h|r",
            "|H"..payload.."|h[Tool]|h"}) do
            eq(neutral(link),payload:gsub("90020::","90020:0:"))
        end
        for _,link in ipairs({"item:0:1:0","item:1:-1:0","item:1:x:0","item:1:0:|bad","item:1:0:\n",
            "item:1:0:0|Hitem:2:0:0|h[x]|h",string.rep("1",4097),"90020"}) do eq(neutral(link),nil) end
        local original=env.C_Item.GetItemStats
        local exact=env.C_Item.GetItemLink({slot=20}); local calls={}
        env.C_Item.GetItemStats=function(link) calls[#calls+1]=link; return original(link) end
        local c=NS.Collectors.New(env,C.Open(nil)); local ready=assert(c:Gear(20,"tool"))
        eq(calls[1],exact); eq(calls[2],neutral(exact)); eq(#calls,2)
        for _,stats in ipairs({{}, {ITEM_MOD_MULTICRAFT_SHORT=0},{ITEM_MOD_MULTICRAFT_SHORT=-1},
            {ITEM_MOD_MULTICRAFT_SHORT=1,ITEM_MOD_RESOURCEFULNESS_SHORT=2}, {ITEM_MOD_FUTURE_SHORT=1},
            {ITEM_MOD_MULTICRAFT_SHORT=math.huge},{ITEM_MOD_MULTICRAFT_SHORT=0/0},
            setmetatable({ITEM_MOD_MULTICRAFT_SHORT=1},{}),{bad=1}}) do
            env.C_Item.GetItemStats=function(link) if link==neutral(exact) then return stats end return original(link) end
            eq(assert(c:Gear(20,"tool")).toolStat.value,nil)
        end
        for _,failure in ipairs({false,"nil","throw"}) do
            env.C_Item.GetItemInfo=failure==false and nil or function() if failure=="throw" then error("U10_PRIVATE") end end
            if failure==false then env.C_Item.GetItemInfo=nil end
            env.C_Item.GetItemStats=function(link) if link==neutral(exact) then
                if failure=="throw" then error("U10_PRIVATE") end return nil end return original(link) end
            -- enchant-zero exact and neutral coincide: optional stats failure also is
            -- a base failure in this synthetic fixture, so use an enchanted instance.
            local env2,state2=fixtureAPI(); state2.enchantID=7977
            env2.C_Item.GetItemInfo=env.C_Item.GetItemInfo
            env2.C_Item.GetItemStats=function(link)
                if link:match("^item:%d+:0:") then if failure=="throw" then error("U10_PRIVATE") end return nil end
                return {ITEM_MOD_RESOURCEFULNESS_SHORT=2}
            end
            local g,s=NS.Collectors.New(env2,C.Open(nil)):Gear(20,"tool")
            eq(s,"observed"); eq(g.metadataReady,true); eq(g.toolStat.value,nil); eq(g.itemExpansion.value,nil)
            eq(g.toolStat.status,failure=="throw" and "error" or "unknown")
            eq(g.itemExpansion.status,failure=="throw" and "error" or failure==false and "unsupported" or "unknown")
            local applied=assert(C.Apply(C.Open(nil),character,identity,{tool=C.Observation("observed",g,100,"U10")},100,"fixture"))
            eq(applied.fields.tool.last.value.toolStat,nil); eq(applied.fields.tool.last.value.itemExpansion,nil)
            assert(not table.concat(NS.ViewModel.Tool(g,{text="fixture"}).tooltip,"\n"):find("U10_PRIVATE",1,true))
        end
        env.C_Item.GetItemStats=original
        env.C_Item.GetItemInfo=function() return "item","item:999:0:0",3,1,1,"","",1,"",1234,0,0,0,0,10 end
        eq(assert(c:Gear(20,"tool")).itemExpansion.value,nil)
        env.C_Item.GetItemInfo=function(link) return "item",link,3,1,1,"","",1,"",1234,0,0,0,0,10 end
        local oldLink=env.C_Item.GetItemLink; local reads=0
        env.C_Item.GetItemLink=function(loc) reads=reads+1; if reads>1 then return "item:999:0:0" end return oldLink(loc) end
        local drift=assert(c:Gear(20,"tool")); eq(drift.toolStat.value,nil); eq(drift.itemExpansion.value,nil); eq(drift.metadataReady,true)
        env.C_Item.GetItemLink=oldLink
        local function unit(key,value,at,status)
            return {source=key=="toolStat" and "C_Item.GetItemStats:unenchant-link-v1" or "C_Item.GetItemInfo",
                status=status or "observed",attemptedAt=at or 100,value=value,observedAt=value~=nil and 100 or nil}
        end
        ready.toolStat=unit("toolStat","Multicraft"); ready.itemExpansion=unit("itemExpansion",10)
        eq(C.ValidPayload("tool",ready,"observed"),true)
        for _,change in ipairs({function(g) g.toolStat.value="Perception" end,function(g) g.itemExpansion.value=-1 end,
            function(g) g.itemExpansion.value=2147483648 end,function(g) g.toolStat.source="wrong" end,
            function(g) g.toolStat.observedAt=nil end,function(g) g.toolStat.extra=true end,
            function(g) g.toolStat.status="empty" end,function(g) g.toolStat.attemptedAt=0.5 end,
            function(g) g.toolStat.value=nil end,function(g) g.exists=false end,function(g) g.metadataReady=false end}) do
            local bad=C.Copy(ready); change(bad); eq(C.ValidPayload("tool",bad,"observed"),false)
        end
        local accessory=C.Copy(ready); accessory.role="accessory1"; accessory.slot=21
        eq(C.ValidPayload("accessory1",accessory,"observed"),false)
        accessory.toolStat=nil; eq(C.ValidPayload("accessory1",accessory,"observed"),true)
        local legacy=assert(C.Open(nil)); local known=assert(C.Apply(legacy,character,identity,
            {tool=C.Observation("observed",ready,100,"U10")},100,"fixture"))
        local function open(raw)
            local job=NS.Storage.NewOpenJob(raw); while job.status=="running" do job:Step() end
            eq(job.status,"complete",job.reason); return job.result,job.savedRoot
        end
        local migrated,root=open(legacy); local reloaded=open(root)
        for _,db in ipairs({legacy,migrated,reloaded}) do
            local function active() return NS.Storage.IsHandle(db) and NS.Storage.Active(db,character.guid,2913) or
                db.characters[character.guid].professions[2913].active end
            local prior=active().fields.tool.last.value; local old=prior.toolStat
            local incoming=C.Copy(ready); incoming.toolStat=unit("toolStat",nil,120,"error"); incoming.itemExpansion=nil
            local g=assert(NS.Storage.Apply(db,character,identity,{tool=C.Observation("observed",incoming,120,"U10")},120,"fixture"))
            local retained=g.fields.tool.last.value
            eq(retained.toolStat.value,"Multicraft"); eq(retained.toolStat.observedAt,100); eq(retained.toolStat.attemptedAt,120)
            eq(retained.toolStat.status,"error"); eq(retained.itemExpansion.status,"unknown"); eq(retained.itemExpansion.value,10)
            assert(retained.toolStat~=old and retained.toolStat~=incoming.toolStat); eq(old.status,"observed")
            local bad=C.Copy(incoming); bad.toolStat.source="wrong"
            eq(NS.Storage.Apply(db,character,identity,{tool=C.Observation("observed",bad,121,"U10")},121,"fixture"),nil)
            eq(active().fields.tool.last.value.toolStat.value,"Multicraft")
            incoming.link=incoming.link..":999"; incoming.toolStat=nil
            g=assert(NS.Storage.Apply(db,character,identity,{tool=C.Observation("observed",incoming,130,"U10")},130,"fixture"))
            eq(g.fields.tool.last.value.toolStat,nil); eq(g.fields.tool.last.value.itemExpansion,nil)
            local empty={slot=20,role="tool",exists=false,metadataReady=false}
            g=assert(NS.Storage.Apply(db,character,identity,{tool=C.Observation("observed",empty,140,"U10")},140,"fixture"))
            eq(g.fields.tool.last.value.toolStat,nil)
            assert(NS.Storage.Archive(db,character.guid,2913,150,"U10"))
        end
        -- Migration owns its copy, leaving the original legacy observation intact.
        eq(known.fields.tool.last.value.toolStat.value,"Multicraft")
        do
            local env,state=fixtureAPI(); state.enchantID=7977
            local queries={}; local toolPayload="item:90020:7977:0:0:-3:0:0:80:0:0:2:123:456:1:29:42"
            local links=env.C_Item.GetItemLink
            env.C_Item.GetItemLink=function(loc) return loc.slot==20 and toolPayload or links(loc) end
            env.C_Item.GetItemInfo=function(link) queries[#queries+1]=link; return nil,link,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,10 end
            env.C_Item.GetItemStats=function(link)
                if link==neutral(toolPayload) then queries[#queries+1]=link; return {ITEM_MOD_MULTICRAFT_SHORT=100} end
                return {ITEM_MOD_RESOURCEFULNESS_SHORT=2,ITEM_MOD_MULTICRAFT_SHORT=100}
            end
            local db,root=NS.Storage.New(); local collector=NS.Collectors.New(env,db); assert(collector:Scan())
            local old=NS.Storage.Active(db,character.guid,2913).fields.tool.last.value
            eq(old.toolStat.value,"Multicraft"); eq(old.enchant.category,"Resourcefulness")
            eq(old.itemExpansion.value,10); eq(#queries,4); eq(state.requests,0); eq(#state.timers,0)
            for _,role in ipairs({"accessory1","accessory2"}) do
                local a=NS.Storage.Active(db,character.guid,2913).fields[role].last.value
                eq(a.toolStat,nil); eq(a.itemExpansion.value,10)
            end
            env.C_Item.GetItemInfo=function() error("U10_PRIVATE") end
            local fullStats=env.C_Item.GetItemStats
            env.C_Item.GetItemStats=function(link) if link==neutral(toolPayload) then error("U10_PRIVATE") end return fullStats(link) end
            state.at=120; assert(collector:Scan())
            local retained=NS.Storage.Active(db,character.guid,2913).fields.tool.last.value
            eq(retained.toolStat.status,"error"); eq(retained.toolStat.value,"Multicraft"); eq(retained.toolStat.observedAt,100)
            eq(retained.toolStat.attemptedAt,120); eq(retained.itemExpansion.status,"error"); eq(retained.itemExpansion.observedAt,100)
            eq(old.toolStat.status,"observed"); assert(old.toolStat~=retained.toolStat)
            assert(NS.Storage.Archive(db,character.guid,2913,130,"U10"))
            local archived=open(root)
            local historical=NS.Storage.Read(archived,character.guid,2913,1,true)
            eq(historical.fields.tool.last.value.toolStat.observedAt,100)
            local verify=C.Copy(historical)
            local job=NS.ViewModel.NewBuildJob(archived,{}, {archived=true},140)
            while job.status=="running" do job:Step() end
            eq(job.status,"complete",job.reason); local rows=job.rows
            eq(rows[1].gear.tool.toolLetter,"M"); eq(rows[1].gear.tool.olderExpansion,true)
            -- U15 ADAPT METADATA_CHANNEL BEGIN
--[============[U15 ORIGINAL BEGIN
            assert(table.concat(rows[1].gear.tool.summaryTooltip,"\n"):find("retained after error",1,true))
U15 ORIGINAL END]============]
            assert(table.concat(rows[1].gear.tool.tooltip,"\n"):find("retained after error",1,true))
            eq(#rows[1].gear.tool.summaryTooltip,0)
            -- U15 ADAPT METADATA_CHANNEL END
            assert(C.Open(legacy)); eq(historical.fields.tool.last.value.toolStat.value,verify.fields.tool.last.value.toolStat.value)
        end
    end
    -- U10 METADATA END
    local db,g=dbWith({unspent=0})
    eq(g.fields.unspent.last.value,0)
    local generic=C.Merge(nil,C.Observation("observed",false,10,"fixture"),"fixture",1)
    eq(generic.last.value,false)
    local old=C.Copy(g.fields.unspent)
    local updated=C.Merge(old,C.Observation("error",nil,20,"fixture","transient"),"fixture",1)
    eq(updated.last.value,0); eq(updated.last.observedAt,10); eq(updated.attempt.attemptedAt,20)
    eq(C.Merge(nil,C.Observation("observed",nil,20,"fixture"),"fixture",1),nil)
    local c=C.Copy(character); c.guid="Player-Fixture-B"
    C.Apply(db,c,identity,{unspent=C.Observation("observed",7,30,"fixture")},30,"fixture")
    eq(db.characters[character.guid].professions[2913].active.fields.unspent.last.value,0)
end)
case("invalid future schemas and bounded primitive sanitization do not reset",function()
    for i,db in ipairs({{schema=2,characters={}},{schema=1,characters=false},{schema=1,characters={bad={}}}}) do
        local before=db.schema; eq(C.Open(db),nil,"invalid DB subcase "..i); eq(db.schema,before,"DB not reset "..i)
    end
    local loop={}; loop.self=loop
    eq(C.Copy(loop),nil,"cycle rejection"); eq(C.Copy({bad=function() end}),nil,"function rejection")
    eq(C.Copy({x=0/0}),nil,"actual NaN value rejected by current runtime guard (mandatory)")
    eq(C.Copy(setmetatable({},{__index={}})),nil,"metatable rejection")
    eq(C.ValidObservation(C.Observation("observed",0,-1,"fixture")),false,"negative attempt time")
    local db,g=dbWith({unspent=1}); g.fields.unspent.last.generation=99; eq(C.Open(db),nil,"wrong field generation")
end)
case("R4 finite native dispatch strict failures and capability-aware portable branch",function()
    local originalNative=math.isfinite
    local calls=0
    local native={isfinite=function(v) calls=calls+1; eq(v,17,"native scalar argument"); return true end}
    for _,sample in ipairs({{value=nil},{value=false},{value="17"},{value={}}}) do
        eq(C.Finite(sample.value,native),false,"type gate before native predicate")
    end
    eq(calls,0,"native must not receive nonnumeric values")
    eq(C.Finite(17,native),true,"native true result"); eq(calls,1,"one native call")
    eq(C.Finite(17,{isfinite=function() return false end}),false,"native false must not fall back")
    eq(C.Finite(17,{isfinite=function() error("fixture native failure") end}),false,"native exception fails closed")
    for _,result in ipairs({{value=nil},{value=1},{value="true"},{value={}}}) do
        eq(C.Finite(17,{isfinite=function() return result.value end}),false,"nonboolean native result fails closed")
    end
    for _,bad in ipairs({false,1,"true",{}}) do
        eq(C.Finite(17,{isfinite=bad}),false,"present nonfunction is not absent-native fallback")
    end
    eq(C.Finite(17,false),false,"invalid injected library fails closed")
    for _,n in ipairs({0,-17,1.25}) do eq(C.Finite(n,{}),true,"absent-native portable finite scalar") end
    -- Portable IEEE non-finite assertions apply on a native-absent Lua host. WoW
    -- explicitly demonstrated non-IEEE NaN comparisons, so an injected empty library
    -- is NOT a supported client guard. Actual default-path rejection is mandatory
    -- below on EVERY host, with no self-equality check or NaN-sample suppression.
    if type(originalNative)~="function" and originalNative==nil then
        for _,sample in ipairs(nonfiniteSamples()) do
            eq(C.Finite(sample.value,{}),false,"native-absent IEEE fallback: "..sample.name)
        end
    end
    for _,sample in ipairs(nonfiniteSamples()) do
        eq(C.Finite(sample.value),false,"mandatory actual runtime predicate: "..sample.name)
    end
    eq(math.isfinite,originalNative,"fixtures never modify real math predicate")
end)
case("R4 actual nonfinite copy keys and pre-arithmetic integer rejection",function()
    for _,n in ipairs({0,-2,0.25}) do
        eq(C.Finite(n),true,"actual finite scalar"); eq(C.Copy(n),n,"finite primitive preserved")
    end
    eq(C.Integer(0),true,"integer zero"); eq(C.Integer(-2,-3),true,"explicit negative lower bound")
    eq(C.Integer(-2),false,"default nonnegative bound retained"); eq(C.Integer(0.25),false,"fraction is not integer")
    eq(C.Integer("1"),false,"no arithmetic coercion before type gate")
    eq(C.Integer(setmetatable({},{__mod=function() error("integer arithmetic before type gate") end})),false,"table rejected before modulo")
    eq(C.Copy({[0]="zero"})[0],"zero","legitimate bounded numeric key")
    eq(C.Copy({[0.25]="fractional key"}),nil,"fractional numeric key rejected")
    for _,sample in ipairs(nonfiniteSamples()) do
        eq(C.Finite(sample.value),false,"actual nonfinite scalar: "..sample.name)
        eq(C.Integer(sample.value),false,"nonfinite rejected before modulo: "..sample.name)
        eq(C.Integer(0,sample.value),false,"nonfinite lower bound: "..sample.name)
        eq(C.Copy(sample.value),nil,"nonfinite primitive: "..sample.name)
        eq(C.Copy({value=sample.value}),nil,"nonfinite table value: "..sample.name)
        local t={}
        local inserted=pcall(function() t[sample.value]="bad numeric key" end)
        if inserted then
            eq(C.Copy(t),nil,"runtime allowed nonfinite key, copier must reject: "..sample.name)
        else eq(next(t),nil,"VM rejected nonfinite key before storage: "..sample.name) end
    end
end)
case("retire immutable archive; relearn fresh generation; scoped deletion cancel",function()
    local db,g=dbWith({moxie={id=3261,quantity=601}})
    eq(C.CompareRoster(db,character.guid,{},false,15),false); assert(db.characters[character.guid].professions[2913].active)
    eq(C.Archive(db,character.guid,2913,20,"retired"),true)
    local p=db.characters[character.guid].professions[2913]
    eq(p.active,nil); eq(p.archives[1].fields.moxie.last.value.quantity,601)
    local fresh=C.Apply(db,character,identity,{skill=C.Observation("observed",{skillLevel=1,maxSkillLevel=100,skillModifier=0},30,"fixture")},30,"fixture")
    eq(fresh.generation,2); eq(fresh.fields.moxie,nil); eq(p.archives[1].fields.moxie.last.value.quantity,601)
    local scope={guid=character.guid,id=2913,generation=1}
    eq(C.Delete(db,scope,false),false); eq(C.Delete(db,scope,true),true)
    eq(db.characters[character.guid].professions[2913].active.generation,2)
    eq(C.CompareRoster(db,character.guid,{},true,40),true)
    eq(db.characters[character.guid].professions[2913].active,nil)
end)
case("known empty vs unloaded; rarity and all crafted ranks independent",function()
    local env,s=fixtureAPI(); local collector=NS.Collectors.New(env,C.Open(nil))
    s.empty=21; local v=collector:Gear(21,"accessory1"); eq(v.exists,false)
    s.empty=nil; s.loading=true; v=collector:Gear(21,"accessory1"); eq(v.exists,true); eq(v.rank,nil)
    s.loading=false
    for _,rarity in ipairs({2,3,4}) do
        s.rarity=rarity
        for rank=1,5 do s.rank=rank; v=collector:Gear(20,"tool"); eq(v.rarity,rarity); eq(v.rank,rank) end
    end
    s.rank=6; v=collector:Gear(20,"tool"); eq(v.rank,nil)
end)
case("enchant zero positive unmapped conflicting unready with no invented amounts",function()
    local E=NS.Collectors.Enchant
    eq(E("item:90000:0:0",false,true).present,false)
    local v=E("item:90000:8005:0",true,true); eq(v.present,true); eq(v.category,"Multicraft"); eq(v.amount,nil); eq(v.rank,nil)
    eq(E("item:90000:9999:0",false,true).category,nil)
    eq(E("item:90000:0:0",true,true).status,"unknown")
    local empty=E("item:90000::0",false,true); eq(empty.status,"observed"); eq(empty.present,false); eq(empty.id,0)
    eq(E("item:90000:8005:0",true,false).status,"unknown")
end)
case("guarded scan only own player; dynamic concentration and zero unspent",function()
    local env,s=fixtureAPI(); local db=C.Open(nil); local collector=NS.Collectors.New(env,db)
    eq(collector:Scan(),true)
    local g=db.characters[character.guid].professions[2913].active
    eq(g.fields.concentration.last.value.id,50001); eq(g.fields.concentration.last.value.quantity,0)
    eq(g.fields.unspent.last.value,0); eq(g.fields["tree:1002"].last,nil)
    eq(g.fields.knowledgeRaw.last.value.stagedStart,false)
    eq(g.fields.tool.last.value.stats.ITEM_MOD_MULTICRAFT_SHORT,152)
    eq(env.CraftArmyDiagnosticsDB.sentinel,true); eq(s.requests,0)
end)
case("per-field protected errors preserve values without turning nil into zero",function()
    local env,s=fixtureAPI(); local collector=NS.Collectors.New(env,C.Open(nil)); collector:Scan()
    env.C_CurrencyInfo.GetCurrencyInfo=function() error("synthetic currency failure") end
    env.C_ProfSpecs.GetCurrencyInfoForSkillLine=function() return nil end
    env.C_Item.GetItemStats=function() error("synthetic stat failure") end
    s.at=110; eq(collector:Scan(),true)
    local g=collector.db.characters[character.guid].professions[2913].active
    eq(g.fields.moxie.last.value.quantity,0); eq(g.fields.moxie.last.observedAt,100)
    eq(g.fields.moxie.attempt.status,"error"); eq(g.fields.unspent.attempt.status,"unknown")
    eq(g.fields.unspent.last.value,0); eq(g.fields.tool.attempt.status,"error")
    eq(g.fields.tool.last.value.stats.ITEM_MOD_MULTICRAFT_SHORT,152)
    eq(g.fields.tool.last.observedAt,100)
end)
case("R4 nonfinite collector metadata preserves coherent values time and nonfresh presentation",function(checkpoint)
    for _,sample in ipairs(nonfiniteSamples()) do
        for _,mode in ipairs({"stats","rarity","rank","modifier","quantity"}) do
            pause(checkpoint,"R4 collector variant")
            local env,s=fixtureAPI(); local collector=NS.Collectors.New(env,C.Open(nil)); eq(collector:Scan(),true,"initial fixture scan")
            local key=(mode=="modifier" and "skill") or (mode=="quantity" and "moxie") or "tool"
            if mode=="stats" then env.C_Item.GetItemStats=function() return {ITEM_MOD_MULTICRAFT_SHORT=sample.value} end
            elseif mode=="rarity" then env.C_Item.GetItemQuality=function() return sample.value end
            elseif mode=="rank" then env.C_TradeSkillUI.GetItemCraftedQualityByItemInfo=function() return sample.value end
            elseif mode=="modifier" then s.info.skillModifier=sample.value
            else
                local currency=env.C_CurrencyInfo.GetCurrencyInfo
                env.C_CurrencyInfo.GetCurrencyInfo=function(id)
                    if id==3261 then return {quantity=sample.value} end
                    return currency(id)
                end
            end
            s.at=120; eq(collector:Scan(),true,"guarded partial scan: "..mode.." "..sample.name)
            local g=collector.db.characters[character.guid].professions[2913].active
            local f=g.fields[key]
            eq(f.attempt.status,"unknown","bad numeric metadata attempt: "..mode.." "..sample.name)
            eq(f.attempt.attemptedAt,120,"failed attempt timestamp")
            eq(f.last.observedAt,100,"successful timestamp not advanced")
            if key=="tool" then
                eq(f.last.value.stats.ITEM_MOD_MULTICRAFT_SHORT,152,"actual prior stat retained")
                eq(f.last.value.rarity,3,"actual prior rarity retained"); eq(f.last.value.rank,5,"actual prior rank retained")
            elseif key=="skill" then eq(f.last.value.skillModifier,40,"prior modifier retained")
            else eq(f.last.value.quantity,0,"actual observed zero retained, not fabricated from NaN") end
            eq(C.Open(collector.db),collector.db,"no bad numeric value serialized")
            local _,state=NS.ViewModel.Field(g,key,collector.fresh[character.guid..":2913"])
            eq(state.fresh,false,"bad metadata is not fresh"); eq(state.stale,true,"retained metadata is stale")
            assert(NS.ViewModel.Build(collector.db,collector.fresh,nil,120)[1].snapshot:find("stale",1,true),"visible stale marker")
        end
    end
end)
case("R1 same-instance stats rarity rank nil error unsupported retain coherent unit and time",function(checkpoint)
    local readers={
        {table="C_Item",key="GetItemStats"}, {table="C_Item",key="GetItemQuality"},
        {table="C_TradeSkillUI",key="GetItemCraftedQualityByItemInfo"},
    }
    for _,reader in ipairs(readers) do
        for _,failure in ipairs({"unknown","error","unsupported"}) do
            pause(checkpoint,"R1 same-instance variant")
            local env,s=fixtureAPI(); local collector=NS.Collectors.New(env,C.Open(nil))
            eq(collector:Scan(),true)
            local api=env[reader.table]
            if failure=="unknown" then api[reader.key]=function() return nil end
            elseif failure=="error" then api[reader.key]=function() error("synthetic gear metadata failure") end
            else api[reader.key]=nil end
            s.at=120; eq(collector:Scan(),true)
            local g=collector.db.characters[character.guid].professions[2913].active
            local field=g.fields.tool
            eq(field.last.value.stats.ITEM_MOD_MULTICRAFT_SHORT,152)
            eq(field.last.value.stats.ITEM_MOD_RESOURCEFULNESS_SHORT,12)
            eq(field.last.value.rarity,3); eq(field.last.value.rank,5)
            eq(field.last.value.enchant.present,false); eq(field.last.observedAt,100)
            eq(field.attempt.status,failure); eq(field.attempt.attemptedAt,120)
            assert(field.attempt.reason:find(reader.key,1,true))
            local row=NS.ViewModel.Build(collector.db,collector.fresh,nil,120)[1]
            eq(row.gear.tool.state.fresh,false); eq(row.gear.tool.state.stale,true)
            assert(row.snapshot:find("stale",1,true)); eq(row.gear.tool.state.observedAt,100)
        end
    end
end)
case("R1 failed gear replacement removal and unidentifiable items never inherit metadata",function(checkpoint)
    for _,mode in ipairs({"replacement","removal","noLink","noLocation","noItemID"}) do
        pause(checkpoint,"R1 replacement variant")
        local env,s=fixtureAPI(); local collector=NS.Collectors.New(env,C.Open(nil)); collector:Scan()
        s.at=120
        if mode=="replacement" then s.itemID=99001; env.C_Item.GetItemStats=function() return nil end
        elseif mode=="removal" then s.empty=20
        elseif mode=="noLink" then s.noLink=true
        elseif mode=="noItemID" then env.C_Item.GetItemID=function() return nil end
        else env.ItemLocation=nil end
        eq(collector:Scan(),true)
        local f=collector.db.characters[character.guid].professions[2913].active.fields.tool
        if mode=="noLocation" then eq(f.last,nil)
        elseif mode=="removal" then
            eq(f.last.value.exists,false); eq(f.last.value.stats,nil); eq(f.last.value.enchant,nil)
            eq(f.last.value.rank,nil); eq(f.last.observedAt,120)
        else
            eq(f.last.observedAt,120); eq(f.last.value.stats,nil)
            if mode=="replacement" then eq(f.last.value.itemID,99001) else
                eq(f.last.value.rank,nil); eq(f.last.value.rarity,nil); eq(f.last.value.enchant,nil)
            end
            eq(NS.ViewModel.Build(collector.db,collector.fresh,nil,120)[1].gear.tool.state.fresh,false)
        end
    end
end)
case("closed linked guild NPC changing combat unready/missing APIs fail closed",function()
    for _,key in ipairs({"shown","linked","guild","npc","changing","combat","ready"}) do
        local env,s=fixtureAPI(); local collector=NS.Collectors.New(env,C.Open(nil))
        s[key]=(key~="shown" and key~="ready")
        eq(collector:Scan(),false); eq(next(collector.db.characters),nil)
    end
    local env=fixtureAPI(); env.C_TradeSkillUI.IsTradeSkillLinked=nil
    eq(NS.Collectors.New(env,C.Open(nil)):Scan(),false)
end)
case("profession switch and trait invalidation discard scan attribution",function()
    for _,mode in ipairs({"switch","invalidate","close"}) do
        local env,s=fixtureAPI(); local db=C.Open(nil); local collector=NS.Collectors.New(env,db)
        env.C_Traits.GetNodeInfo=function()
            if mode=="switch" then s.info=C.Copy(s.info); s.info.professionID=99999
            elseif mode=="close" then s.shown=false else collector:Invalidate("synthetic trait event") end
            return {ranksPurchased=1,currentRank=1,ranksIncreased=0,maxRanks=30}
        end
        eq(collector:Scan(),false); eq(next(db.characters),nil)
    end
end)
case("unknown role cannot become tool by sorted slot index",function()
    local env,s=fixtureAPI(); s.slots={33,35,34}; local collector=NS.Collectors.New(env,C.Open(nil))
    eq(collector:Scan(),true)
    local g=collector.db.characters[character.guid].professions[2913].active
    eq(g.fields.tool.last,nil); eq(g.fields.slot33.last.value.role,nil)
end)
case("replacement invalidates all old gear metadata; late callbacks discarded",function()
    local env,s=fixtureAPI(); local db=C.Open(nil); local collector=NS.Collectors.New(env,db)
    collector:Scan(); s.loading=true; s.itemID=99000; collector:Invalidate("gear changed"); collector:Scan()
    local g=db.characters[character.guid].professions[2913].active
    eq(g.fields.tool.last.value.rank,nil); eq(g.fields.tool.last.value.enchant,nil)
    local oldToken=collector.pending[99000].token
    s.loading=false; s.itemID=99001; collector:Invalidate("new item"); collector:Scan()
    collector:ItemResult(99000,true); collector:Expire(oldToken)
    eq(db.characters[character.guid].professions[2913].active.fields.tool.last.value.itemID,99001)
end)
local function assertMissingFresh(collector,expected)
    local session=collector.fresh[character.guid..":2913"]
    eq(session~=nil and session.fields.tool==true,expected)
    local row=NS.ViewModel.Build(collector.db,collector.fresh,nil,collector:Now())[1]
    eq(row.gear.tool.state.fresh,expected)
    local warning
    for _,w in ipairs(row.warnings) do if w.category=="Missing enchant" then warning=w end end
    assert(warning,"Expected confirmed or historical missing-enchant evidence")
    eq(warning.fresh,expected)
    eq(warning.label,(expected and "confirmed " or "last observed ").."Missing enchant")
    return row
end
case("async one request per ID, single retry, timeout and context close",function()
    local env,s=fixtureAPI(); s.loading=true; s.itemID=99000
    local collector=NS.Collectors.New(env,C.Open(nil)); collector:Scan(); eq(s.requests,1)
    local token=collector.pending[99000].token
    s.loading=false; collector:ItemResult(99000,true); eq(collector.pending[99000],nil)
    local session=collector.fresh[character.guid..":2913"]
    eq(session.generation,1); eq(session.fields.tool,true)
    eq(session.fields.accessory1,true); eq(session.fields.accessory2,true)
    eq(session.fields.concentration,true); eq(session.fields.skill,true)
    assertMissingFresh(collector,true)
    collector:ItemResult(99000,true); eq(s.requests,1)
    eq(collector.fresh[character.guid..":2913"],session); assertMissingFresh(collector,true)
    collector:Expire(token); assertMissingFresh(collector,true) -- An old timeout cannot demote a completed retry.
    local g=collector.db.characters[character.guid].professions[2913].active
    eq(g.fields.tool.last.value.rank,5)
    s.loading=true; collector:Scan(); token=collector.pending[99000].token; s.at=105; collector:Expire(token)
    eq(collector.pending[99000],nil)
    local timed=collector.db.characters[character.guid].professions[2913].active.fields.tool
    assert(timed.attempt.reason:find("timeout",1,true)); eq(timed.last.value.rank,5)
    eq(timed.last.observedAt,100); eq(timed.attempt.attemptedAt,105)
    assertMissingFresh(collector,false); eq(collector.fresh[character.guid..":2913"].fields.concentration,true)
    collector:Scan(); s.shown=false; collector:ItemResult(99000,true)
    eq(collector.db.characters[character.guid].professions[2913].active.fields.tool.last.value.rank,5)
    assertMissingFresh(collector,false)
end)
case("R2 async failed event retry timeout apply and mixed statuses cannot promote failed fields",function(checkpoint)
    for _,mode in ipairs({"event","retry","timeout","apply","mixed"}) do
        pause(checkpoint,"R2 failed async variant")
        local env,s=fixtureAPI(); s.itemID=99000
        local collector=NS.Collectors.New(env,C.Open(nil)); eq(collector:Scan(),true)
        s.loading=true; s.at=101; eq(collector:Scan(),true)
        local pending=collector.pending[99000]
        local session=collector.fresh[character.guid..":2913"]
        eq(session.fields.tool,nil); eq(session.fields.concentration,true)
        assertMissingFresh(collector,false)
        -- Also prove failure clears an affected session flag rather than merely
        -- declining to set one; unrelated successful fields must survive.
        session.fields.tool=true
        s.at=102; s.loading=false
        if mode=="event" then collector:ItemResult(99000,false)
        elseif mode=="timeout" then s.at=106; collector:Expire(pending.token)
        else
            if mode=="retry" then env.C_Item.GetItemStats=function() return nil end
            elseif mode=="apply" then
                -- Actual atomic Core.Apply rejection, no production function stub.
                pending.token.build=false
            elseif mode=="mixed" then
                env.C_Item.GetItemQuality=function(location) if location.slot==20 then return nil end return 3 end
            end
            collector:ItemResult(99000,true)
        end
        eq(collector.pending[99000],nil); eq(collector.fresh[character.guid..":2913"],session)
        eq(session.fields.tool,nil); eq(session.fields.concentration,true); eq(session.fields.skill,true)
        assertMissingFresh(collector,false)
        local g=collector.db.characters[character.guid].professions[2913].active
        eq(g.fields.tool.last.value.enchant.present,false); eq(g.fields.tool.last.observedAt,100)
        if mode=="mixed" then eq(session.fields.accessory1,true); eq(session.fields.accessory2,true)
        else eq(session.fields.accessory1,nil); eq(session.fields.accessory2,nil) end
        if mode=="apply" then
            eq(g.fields.tool.attempt.attemptedAt,101); assert(collector.reason:find("Invalid",1,true))
        end
    end
end)
case("R2 late mismatched invalidated generation and duplicate completions cannot restore freshness",function(checkpoint)
    for _,mode in ipairs({"late","mismatch","duringRead","afterApply","generation","duplicate"}) do
        pause(checkpoint,"R2 late async variant")
        local env,s=fixtureAPI(); s.itemID=99000
        local collector=NS.Collectors.New(env,C.Open(nil)); collector:Scan()
        s.loading=true; s.at=101; collector:Scan()
        local pending=collector.pending[99000]
        s.at=102; s.loading=false
        if mode=="late" then collector:Invalidate("fixture context invalidated")
        elseif mode=="mismatch" then s.enchantID=8005
        elseif mode=="duringRead" then
            env.C_Item.GetItemStats=function()
                collector:Invalidate("fixture trait event during retry")
                return {ITEM_MOD_MULTICRAFT_SHORT=152}
            end
        elseif mode=="afterApply" then
            local reads=0
            env.C_TradeSkillUI.GetChildProfessionInfo=function()
                reads=reads+1
                if reads==3 then collector:Invalidate("fixture invalidation after commit") end
                return s.info
            end
        elseif mode=="generation" then
            C.Archive(collector.db,character.guid,2913,102,"fixture retirement")
            collector:Scan() -- Fresh generation2 replaces the generation1 pending token.
            eq(collector.db.characters[character.guid].professions[2913].active.generation,2)
            collector:Invalidate("fixture new generation context lost")
            collector.pending[99000]=pending -- An old token cannot promote generation2.
        elseif mode=="duplicate" then
            collector:ItemResult(99000,true); assertMissingFresh(collector,true)
            collector:Invalidate("fixture invalidation before duplicate callback")
        end
        collector:ItemResult(99000,true)
        assertMissingFresh(collector,false)
        local current=collector.db.characters[character.guid].professions[2913].active
        if mode=="afterApply" or mode=="duplicate" or mode=="generation" then
            eq(current.fields.tool.last.observedAt,102)
        else eq(current.fields.tool.last.observedAt,100) end
        local session=collector.fresh[character.guid..":2913"]
        if mode=="mismatch" then eq(session.fields.concentration,true) else eq(next(collector.fresh),nil) end
        if mode=="afterApply" then eq(current.fields.tool.attempt.status,"observed") end
    end
end)
case("async at most16 requests and event bursts coalesce, no periodic scan",function()
    local env,s=fixtureAPI(); local collector=NS.Collectors.New(env,C.Open(nil))
    local loads={}
    for i=1,20 do loads[i]={key="fixture"..i,value={itemID=80000+i,slot=20},location={slot=20}} end
    collector:StartLoads(loads,{serial=1}); eq(s.requests,16); eq(#s.timers,1); eq(s.timers[1].seconds,5)
    s.timers={}; collector:Request("burst1"); collector:Request("burst2"); collector:Request("burst3")
    eq(#s.timers,1); eq(s.timers[1].seconds,0); s.timers[1].fn(); eq(collector.scheduled,false)
end)
case("knowledge path/tab limits and missing metadata preserve coherent tree",function()
    local s=scan(); local t=s.tabs[1]; t.root=100
    for i=100,164 do t.paths[i]=path(0,0,5); if i<164 then t.paths[i].children={i+1} end end
    local r=K.Evaluate(s); eq(r.complete,false); eq(r.trees[1].capacity,nil)
    s=scan(); for i=2,9 do s.tabs[i]=C.Copy(s.tabs[1]); s.tabs[i].id=i end
    r=K.Evaluate(s); eq(r.trees[1].capacity,nil)
    local db,g=dbWith({["tree:11"]=treeValue(11,7,10)})
    local merged=C.Merge(g.fields["tree:11"],C.Observation("unknown",nil,20,"fixture","incomplete"),"fixture",1)
    eq(merged.last.value.purchased,7); eq(merged.last.value.capacity,10)
    s=scan(); s.tabs[1].paths[72].childrenComplete=nil; eq(K.Evaluate(s).trees[1].capacity,nil)
    s=scan(); s.tabs[1].paths[72].children={bogus=73}; eq(K.Evaluate(s).complete,false)
    s=scan(); s.tabs={false}; eq(K.Evaluate(s).complete,false)
end)
case("missing tab API preserves prior index/tree and records failed attempt",function()
    local env,s=fixtureAPI(); local collector=NS.Collectors.New(env,C.Open(nil)); collector:Scan()
    local g=collector.db.characters[character.guid].professions[2913].active
    g.fields["tree:1002"]=C.Merge(nil,C.Observation("observed",treeValue(1002,3,10),s.at,"fixture"),"fixture",1)
    env.C_ProfSpecs.GetSpecTabIDsForSkillLine=function() return nil end
    s.at=101; collector:Scan()
    g=collector.db.characters[character.guid].professions[2913].active
    eq(g.fields.knowledgeIndex.last.value[1].id,1002)
    eq(g.fields["tree:1002"].last.value.purchased,3)
    eq(g.fields["tree:1002"].attempt.status,"unknown")
    eq(g.fields["tree:1002"].last.observedAt,100)
end)
case("shared missing/reconciliation cannot borrow another tree's ranks",function()
    local s=scan(); local second={id=12,root=100,paths={[100]=path(0,3,4)},coverageComplete=true}
    s.tabs[2]=second; s.shared={applicable=true}
    eq(K.Evaluate(s).trees[1].purchased,nil)
    s.shared=nil; second.paths[100].unlock=nil
    local r=K.Evaluate(s); eq(r.trees[1].purchased,0); eq(r.trees[2].purchased,nil)
end)
case("Moxie599/600/601 and concentration899/900/1000 verified boundaries",function()
    local V=NS.ViewModel
    -- U13 MOXIE_MODEL BEGIN
    do
        for _,quantity in ipairs({0,600,601}) do
            local db,g=dbWith({moxie={id=3261,quantity=quantity}})
            local session={[character.guid..":2913"]={generation=1,fields={moxie=true}}}
            for _,fresh in ipairs({false,true}) do
                local row=V.Build(db,fresh and session or {},{},100)[1]
                eq(row.cells[I.Moxie],tostring(quantity),"U13 plain Moxie rejection")
                eq(row.moxieState.fresh,fresh); eq(row.moxieState.observedAt,10)
                eq(row.sortValues[I.Moxie],quantity); eq(row.priority,quantity>600 and (fresh and 1 or 2) or 3)
                eq(#V.Build(db,fresh and session or {},{attention="Moxie"},100),quantity>600 and 1 or 0)
            end
            g.fields.moxie=C.Merge(g.fields.moxie,C.Observation("error",nil,20,"U13","transient"),"fixture",1)
            local row=V.Build(db,session,{},100)[1]
            eq(row.cells[I.Moxie],tostring(quantity)); eq(row.moxieState.fresh,false); eq(row.moxieState.stale,true)
            assert(C.Archive(db,character.guid,2913,30,"U13"))
            row=V.Build(db,session,{archived=true},100)[1]
            eq(row.cells[I.Moxie],tostring(quantity)); eq(row.moxieState.fresh,false); eq(#row.warnings,0)
        end
        local row=V.Build(dbWith({}),{},nil,100)[1]
        eq(row.cells[I.Moxie],"?"); eq(row.moxieState.known,false)
    end
    -- U13 MOXIE_MODEL END
    for _,mox in ipairs({599,600,601}) do
        for _,conc in ipairs({899,900,1000}) do
            local db,g=dbWith({moxie={id=3261,quantity=mox},concentration={id=50001,quantity=conc,maxQuantity=1000}})
            local rows=V.Build(db,{},nil,100)
            local found={}; for _,w in ipairs(rows[1].warnings) do found[w.category]=true; eq(w.fresh,false) end
            eq(found.Moxie==true,mox>600); eq(found.Concentration==true,conc>=900)
        end
    end
    for _,cap in ipairs({0}) do
        local db=dbWith({concentration={id=50001,quantity=1000,maxQuantity=cap}})
        eq(#V.Build(db,{},nil,100)[1].warnings,0)
    end
    local db=dbWith({concentration={id=50001,quantity=1000}}); eq(#V.Build(db,{},nil,100)[1].warnings,0)
end)
case("fresh vs historical alerts, failed attempt stale, no offline projection",function()
    -- U09 MODEL BEGIN
    do
        local V=NS.ViewModel
        local function deepEqual(a,b)
            if type(a)~=type(b) then return false end
            if type(a)~="table" then return a==b end
            for k,v in pairs(a) do if not deepEqual(v,b[k]) then return false end end
            for k in pairs(b) do if a[k]==nil then return false end end
            return true
        end
        local value={id=50001,quantity=100,maxQuantity=1000,rechargingCycleDurationMS=2000,rechargingAmountPerCycle=2}
        local function estimate(v,at,now,q,seconds)
            local copy=assert(C.Copy(v)); local e=assert(V.ConcentrationEstimate(v,at,now))
            eq(e.quantity,q); eq(e.maxQuantity,v.maxQuantity)
            assert(math.abs(e.secondsToFull-seconds)<1e-9); assert(deepEqual(v,copy))
        end
        estimate(value,10,10,100,900); estimate(value,10,11,101,899)
        estimate(value,10,910,1000,0); estimate(value,10,100000,1000,0)
        local fractional={quantity=0,maxQuantity=10,rechargingCycleDurationMS=3000,rechargingAmountPerCycle=2}
        estimate(fractional,10,11,0,14); estimate(fractional,10,12,1,13)
        estimate({quantity=1000,maxQuantity=1000,rechargingCycleDurationMS=2000,rechargingAmountPerCycle=2},0,0,1000,0)
        estimate({quantity=0,maxQuantity=1000,rechargingCycleDurationMS=1000,rechargingAmountPerCycle=1e300},0,1e300,1000,0)
        local function reject(v,at,now)
            local e,why=V.ConcentrationEstimate(v,at,now); eq(e,nil)
            assert(type(why)=="string" and #why<100 and not why:find("PRIVATE",1,true))
        end
        reject(nil,10,20); reject(false,10,20); reject("PRIVATE",10,20)
        reject(setmetatable({}, {__index=function() error("PRIVATE") end}),10,20)
        for _,key in ipairs({"quantity","maxQuantity","rechargingCycleDurationMS","rechargingAmountPerCycle"}) do
            for _,bad in ipairs({false,"PRIVATE",-1,math.huge,-math.huge,0/0}) do
                local v=assert(C.Copy(value)); v[key]=bad; reject(v,10,20)
            end
            local v=assert(C.Copy(value)); v[key]=nil; reject(v,10,20)
        end
        for _,key in ipairs({"quantity","maxQuantity"}) do
            local v=assert(C.Copy(value)); v[key]=.5; reject(v,10,20)
        end
        for _,key in ipairs({"maxQuantity","rechargingCycleDurationMS","rechargingAmountPerCycle"}) do
            local v=assert(C.Copy(value)); v[key]=0; reject(v,10,20)
        end
        local v=assert(C.Copy(value)); v.quantity=1001; reject(v,10,20)
        for _,bad in ipairs({false,"PRIVATE",-1,.5,math.huge,-math.huge,0/0}) do
            reject(value,bad,20); reject(value,10,bad)
        end
        reject(value,nil,20); reject(value,10,nil); reject(value,20,10)
        for _,pair in ipairs({{1e-320,1},{1e300,1e-300},{1e-300,1e300},{1000,1e-320}}) do
            reject({quantity=0,maxQuantity=1000,rechargingCycleDurationMS=pair[1],rechargingAmountPerCycle=pair[2]},0,1)
        end
        local db,g=dbWith({concentration=value})
        local row=V.Build(db,{},nil,100)[1]
        eq(row.concentrationValue,g.fields.concentration.last.value); eq(row.concentrationState.observedAt,10)
        local before=assert(C.Copy({db,row})); local lines=V.ConcentrationTooltip(row,910)
        assert(table.concat(lines,"\n"):find("Estimated now: ~1000/1000",1,true))
        eq(row.concentration,100); eq(row.sortValues[I.Concentration],100); eq(#row.warnings,0); eq(row.priority,3)
        eq(#V.Build(db,{}, {attention="Concentration"},910),0)
        assert(deepEqual({db,row},before),"estimate must not mutate actual snapshot/model")
        local observations={concentration=C.Observation("observed",{id=50001,quantity=900,maxQuantity=1000,
            rechargingCycleDurationMS=4000,rechargingAmountPerCycle=1},20,"U09")}
        assert(C.Apply(db,{guid="U09-sort",name="Second",realm="Test"},identity,observations,20,"fixture"))
        for _,desc in ipairs({false,true}) do
            local rows=V.Build(db,{}, {sortColumn=I.Concentration,sortDescending=desc},100000)
            eq(rows[1].concentration,desc and 900 or 100); eq(rows[2].concentration,desc and 100 or 900)
        end
        eq(V.Build(db,{},nil,100000)[1].concentration,900)
        eq(#V.Build(db,{}, {attention="Concentration"},100000),1)
    end
    -- U09 MODEL END
    local db,g=dbWith({moxie={id=3261,quantity=601},concentration={id=50001,quantity=900,maxQuantity=1000}})
    local session={[character.guid..":2913"]={generation=1,fields={moxie=true,concentration=true}}}
    local row=NS.ViewModel.Build(db,session,nil,100000)[1]; eq(row.priority,1); eq(row.concentration,900)
    -- U13 ADAPT MOXIE_FRESH BEGIN
--[==========[U13 ORIGINAL BEGIN
    assert(row.cells[I.Moxie]:find("|cffffbb00!|r ",1,true)); eq(row.cells[I.Concentration],"900/1000")
U13 ORIGINAL END]==========]
    eq(row.cells[I.Moxie],"601"); eq(row.cells[I.Concentration],"900/1000")
    -- U13 ADAPT MOXIE_FRESH END
    row=NS.ViewModel.Build(db,{},nil,100000)[1]; eq(row.priority,2); eq(row.concentration,900)
    -- U13 ADAPT MOXIE_HISTORICAL BEGIN
--[==========[U13 ORIGINAL BEGIN
    assert(row.cells[I.Moxie]:find("|cff999999!|r ",1,true)); eq(row.cells[I.Concentration],"900/1000")
U13 ORIGINAL END]==========]
    eq(row.cells[I.Moxie],"601"); eq(row.cells[I.Concentration],"900/1000")
    -- U13 ADAPT MOXIE_HISTORICAL END
    g.fields.moxie=C.Merge(g.fields.moxie,C.Observation("error",nil,20,"fixture","transient"),"fixture",1)
    row=NS.ViewModel.Build(db,session,nil,100)[1]
    for _,w in ipairs(row.warnings) do if w.category=="Moxie" then eq(w.fresh,false) end end
    assert(row.snapshot:find("stale",1,true))
end)
case("R6 accessory-first fourteen-column gear Stat Enchant split; unknown bars not zero",function()
    local V=NS.ViewModel
    eq(V.columns[I.Accessory1],"Accessory #1"); eq(V.columns[I.Accessory2],"Accessory #2"); eq(V.columns[I.Tool],"Tool"); eq(V.columns[I.Unspent],"Unspent KP")
    eq(#V.columns,14); eq(V.columns[I.Stat],"Stat"); eq(V.columns[I.Enchant],"Enchant")
    local db,g=dbWith({tool={slot=20,exists=true,role="tool",rarity=4,rank=5,metadataReady=true,itemID=90020,link="item:90020:8005:0:0",
        stats={ITEM_MOD_MULTICRAFT_SHORT=152,ITEM_MOD_RESOURCEFULNESS_SHORT=12},
        enchant={status="observed",present=true,id=8005,category="Multicraft"}},
        knowledgeIndex={{id=11,name="Tree"}},unspent=0})
    local row=V.Build(db,{},nil,100)[1]
    eq(row.cells[I.Tool],row.gear.tool.text); eq(row.cells[I.Stat],"Multicraft, Resourcefulness"); eq(row.cells[I.Enchant],"Multicraft")
    eq(row.gear.tool.enchant.amount,nil); eq(row.trees[1].ratio,nil); eq(row.unspent,0)
    eq(row.enchantMissing,false)
    local empty=V.Gear({exists=false},{text="fixture"}); eq(empty.text,"")
    local unknown=V.Gear({exists=true,rarity=3},{text="fixture"}); eq(unknown.text,"?")
end)
case("R6 full crafting names share Stat and category display with numeric tooltip names",function()
    for _,stat in ipairs({
        {key="ITEM_MOD_CRAFTING_SPEED_SHORT",short="C",full="Crafting Speed"},
        {key="ITEM_MOD_INGENUITY_SHORT",short="I",full="Ingenuity"},
        {key="ITEM_MOD_MULTICRAFT_SHORT",short="M",full="Multicraft"},
        {key="ITEM_MOD_RESOURCEFULNESS_SHORT",short="R",full="Resourcefulness"},
    }) do
        -- Category-only synthetic renderer input, not new enchant-ID evidence.
        local tool=NS.ViewModel.Tool({exists=true,stats={[stat.key]=17},
            enchant={status="observed",present=true,category=stat.full}}, {text="fixture"})
        eq(NS.Data.statNames[stat.key][1],stat.short,"historical label registry unchanged")
        eq(tool.statsText,stat.full); eq(tool.enchantText,stat.full)
        assert(not tool.statsText:find("17",1,true) and not tool.statsText:find("*",1,true),"no amount/asterisk in main Stat")
        local tooltip=table.concat(tool.tooltip,"\n")
        assert(tooltip:find(stat.full..": 17 (observed total)",1,true))
        assert(tooltip:find("; stat "..stat.full.."; amount/rank unknown",1,true))
        eq(tool.enchant.amount,nil); eq(tool.enchant.rank,nil)
    end
    local enchant=NS.Collectors.Enchant("item:90020:8005:0",true,true)
    local tool=NS.ViewModel.Tool({exists=true,stats={ITEM_MOD_MULTICRAFT_SHORT=152},enchant=enchant},{text="fixture"})
    eq(tool.statsText,"Multicraft"); eq(tool.enchantText,"Multicraft")
    assert(table.concat(tool.tooltip,"\n"):find("ID 8005; stat Multicraft; amount/rank unknown",1,true))
    local expected={[7977]="Resourcefulness",[8005]="Multicraft",[8035]="Ingenuity",[8033]="Deftness",[8003]="Finesse",[7975]="Perception"}
    local count=0; for id,entry in pairs(NS.Data.enchants) do assert(expected[id]); eq(entry.category,expected[id]); count=count+1 end; eq(count,6)
end)
case("R6 multiple full stats preserve values attribution and unknown states in hover",function()
    local stats={ITEM_MOD_CRAFTING_SPEED_SHORT=11,ITEM_MOD_INGENUITY_SHORT=22,
        ITEM_MOD_MULTICRAFT_SHORT=33,ITEM_MOD_RESOURCEFULNESS_SHORT=44}
    local tool=NS.ViewModel.Tool({exists=true,stats=stats,
        enchant={status="observed",present=true,category="Fixture unknown category"}},{text="fixture"})
    eq(tool.statsText,"Crafting Speed, Ingenuity, Multicraft, Resourcefulness"); eq(tool.enchantText,"?")
    local tooltip=table.concat(tool.tooltip,"\n")
    assert(tooltip:find("base/enchant attribution unknown",1,true))
    assert(tooltip:find("stat Fixture unknown category",1,true))
    for key,value in pairs(stats) do
        assert(tooltip:find(NS.Data.statNames[key][2]..": "..value.." (observed total); key "..key,1,true),"all amounts/raw keys remain on hover")
    end
    tool=NS.ViewModel.Tool({exists=true,stats={ITEM_MOD_FIXTURE_UNKNOWN_SHORT=0},
        enchant={status="unknown",reason="unready"}},{text="fixture"})
    eq(tool.statsText,"?"); eq(tool.enchantText,"?")
    assert(table.concat(tool.tooltip,"\n"):find("ITEM_MOD_FIXTURE_UNKNOWN_SHORT: 0",1,true))
    tool=NS.ViewModel.Tool({exists=true,enchant={status="observed",present=false,id=0}},{text="fixture"})
    eq(tool.statsText,"?"); eq(tool.enchantText,"")
    tool=NS.ViewModel.Tool({exists=true,enchant={status="observed",present=true}},{text="fixture"})
    eq(tool.enchantText,"?")
end)
case("sorting ties unknown last filters archived isolation; no wallet sum",function()
    local db,g=dbWith({moxie={id=3261,quantity=601}})
    local b=C.Copy(character); b.guid="Player-Fixture-B"
    C.Apply(db,b,identity,{},10,"fixture")
    local rows=NS.ViewModel.Build(db,{}, {sort="moxie"},100); eq(rows[1].guid,character.guid)
    eq(#NS.ViewModel.Build(db,{}, {attention="Moxie"},100),1)
    eq(#NS.ViewModel.Build(db,{}, {profession="2913",character="Fixture"},100),2)
    C.Archive(db,character.guid,2913,20,"fixture")
    eq(#NS.ViewModel.Build(db,{},nil,100),1)
    rows=NS.ViewModel.Build(db,{}, {archived=true},100); eq(#rows,1); eq(#rows[1].warnings,0)
    eq(rows.moxieTotal,nil)
end)
case("commands/help and rendering factories cannot mutate gameplay or real DB",function()
    local env,s=fixtureAPI(); env.CraftArmyDB={schema=999,sentinel=true}
    env.DEFAULT_CHAT_FRAME={AddMessage=function() end}
    local commands=NS.Commands.New(env); commands:Run("help")
    eq(env.CraftArmyDB.schema,999); eq(env.CraftArmyDB.sentinel,true); eq(commands.collector.db,nil)
    local dashboard=NS.Dashboard.New(env,NS.Collectors.New(env,C.Open(nil)))
    eq(dashboard.frame,nil); dashboard:Refresh(); eq(s.requests,0)
    local before=env.CraftArmyDiagnosticsDB; eq(before.sentinel,true)
end)

local function mockWidgets(env)
    local methods,created={},{}
    local function widget(kind,parent,template)
        local w={kind=kind,parent=parent,template=template,shown=true,width=0,
            height=kind=="FontString" and 14 or 0,scripts={},points={},style={},labelText="",scale=1,lines={},calls={}}
        created[#created+1]=w
        return setmetatable(w,{__index=methods}) -- Unknown methods fail instead of silently succeeding.
    end
    function methods:CreateFontString(_,_,font) return widget("FontString",self,font) end
    function methods:CreateTexture() return widget("Texture",self) end
    -- U08 MOCK BEGIN
    local createTexture=methods.CreateTexture
    function methods:CreateTexture(name,layer,...)
        local texture=createTexture(self,name,layer,...)
        texture.drawLayer=layer
        return texture
    end
    function methods:SetTexture(path)
        eq(self.kind,"Texture","SetTexture requires Texture")
        eq(type(path),"string","SetTexture requires path")
        self.texturePath=path
        return true
    end
    -- U08 MOCK END
    function methods:SetScript(event,fn) self.scripts[event]=fn end
    function methods:SetText(value)
        assert(type(value)=="string","fake SetText needs real text"); self.labelText=value
        if self.multiline then local _,n=value:gsub("\n",""); self.height=(n+1)*14 end
        if self.multiline and self.scripts.OnTextChanged then self.scripts.OnTextChanged(self,false) end
    end
    function methods:GetText() return self.labelText end
    function methods:SetSize(x,y)
        assert(C.Finite(x) and x>0 and C.Finite(y) and y>0,"invalid fake widget size")
        self.width=x; self.height=y
    end
    -- U10 MOCK BEGIN
    local oldTexture,oldSize=methods.SetTexture,methods.SetSize
    function methods:SetTexture(value)
        if type(value)=="number" then
            eq(self.kind,"Texture"); assert(C.Integer(value,1)); self.texturePath=value; return true
        end
        return oldTexture(self,value)
    end
    function methods:SetSize(x,y)
        if self.hiddenColumn==true and x==0 then
            assert(C.Finite(x) and C.Finite(y) and y>0,"invalid hidden column size"); self.width=x; self.height=y; return
        end
        return oldSize(self,x,y)
    end
    function methods:SetAtlas(atlas)
        eq(self.kind,"Texture"); assert(type(atlas)=="string" and atlas:match("^[%w_%-]+$")); self.atlas=atlas
    end
    function methods:SetFont(path,height,flags)
        eq(self.kind,"FontString"); eq(type(path),"string"); assert(C.Finite(height) and height>0)
        eq(type(flags),"string"); self.font={path,height,flags}; return true
    end
    -- U10 MOCK END
    function methods:SetWidth(x) assert(C.Finite(x) and x>0,"invalid width"); self.width=x end
    function methods:SetHeight(y) assert(C.Finite(y) and y>0,"invalid height"); self.height=y end
    function methods:GetWidth() return self.width end
    function methods:GetHeight() return self.height end
    function methods:SetScale(value) assert(C.Finite(value) and value>0 and value<=1,"unsafe frame scale"); self.scale=value end
    function methods:GetScale() return self.scale end
    function methods:GetFrameLevel() return self.level or 1 end
    function methods:SetFrameLevel(value) self.level=value end
    function methods:SetPoint(point,a,b,c,d)
        local relative,anchor,x,y
        if type(a)=="table" then relative=a; anchor=b; x=c or 0; y=d or 0
        else relative=self.parent; anchor=point; x=a or 0; y=b or 0 end
        assert(type(point)=="string" and type(anchor)=="string" and C.Finite(x) and C.Finite(y),"bad anchor")
        self.points[#self.points+1]={point=point,relative=relative,anchor=anchor,x=x,y=y}
    end
    function methods:ClearAllPoints() self.points={}; self.allPoints=nil end
    function methods:SetAllPoints(target) self.allPoints=target or self.parent end
    function methods:Show() self.shown=true end
    function methods:Hide() self.shown=false end
    function methods:SetShown(value) self.shown=value end
    function methods:IsShown() return self.shown end
    function methods:GetStatusBarTexture() if not self.fill then self.fill=widget("Texture",self) end; return self.fill end
    function methods:SetValue(value) self.value=value end
    function methods:ClearLines() self.lines={}; self.nativeLink=nil; self.calls[#self.calls+1]="clear" end
    function methods:SetOwner(owner,anchor) self.owner=owner; self.ownerAnchor=anchor; self.calls[#self.calls+1]="owner" end
    function methods:SetHyperlink(link)
        self.nativeLink=link; self.calls[#self.calls+1]="hyperlink"
        self.lines[#self.lines+1]="Native item: "..link
        self.lines[#self.lines+1]="Third-party BIS |A:Native-BIS:12:12|a"
    end
    function methods:AddLine(line) assert(type(line)=="string","tooltip line not text"); self.lines[#self.lines+1]=line; self.calls[#self.calls+1]="append" end
    for _,name in ipairs({"SetMovable","EnableMouse","RegisterForDrag","StartMoving","StopMovingOrSizing",
        "EnableMouseWheel","SetAutoFocus","ClearFocus","SetHighlightTexture","SetJustifyH","SetWordWrap",
        "SetStatusBarTexture","SetStatusBarColor","SetMinMaxValues","SetColorTexture","SetBackdrop","SetBackdropColor",
        "SetTextColor","SetFrameStrata","SetToplevel","Raise","SetBackdropBorderColor"}) do
        local key=name
        methods[key]=function(self,...) self.style[key]={...} end
    end
    function methods:SetMultiLine(v) eq(type(v),"boolean"); self.multiline=v end
    function methods:SetFontObject(v) eq(type(v),"string"); self.fontObject=v end
    function methods:SetMaxLetters(v) assert(C.Integer(v)); self.maxLetters=v end
    function methods:SetScrollChild(v) eq(v.parent,self); self.scrollChild=v end
    function methods:SetFocus() self.focused=true end
    function methods:ClearFocus() self.focused=false end
    function methods:HighlightText(a,b) self.selection={a or 0,b or #self.labelText} end
    -- U12 MOCK BEGIN
    -- Call constraints only: default width0/FontString height14 are NOT native metrics.
    for _,name in ipairs({"SetSize","SetWidth","SetHeight","SetAllPoints","SetFont","SetText"}) do
        local key,original=name,methods[name]
        methods[key]=function(self,...)
            if self.kind=="FontString" then
                self.u12Calls=self.u12Calls or {}
                self.u12Calls[#self.u12Calls+1]=key
            end
            return original(self,...)
        end
    end
    -- U12 MOCK END
    -- U13 SLIDER_MOCK BEGIN
    do
        local range,value=methods.SetMinMaxValues,methods.SetValue
        function methods:SetMinMaxValues(low,high)
            if self.kind~="Slider" then return range(self,low,high) end
            assert(C.Finite(low) and C.Finite(high) and low<=high,"invalid Slider range")
            self.minimum=low; self.maximum=high; self.style.SetMinMaxValues={low,high}
            self:SetValue(math.max(low,math.min(high,self.value or low)))
        end
        function methods:SetValue(n)
            if self.kind~="Slider" then return value(self,n) end
            assert(C.Finite(n),"invalid Slider value")
            self.value=math.max(self.minimum or 0,math.min(self.maximum or 0,n))
            if self.scripts.OnValueChanged then self.scripts.OnValueChanged(self,self.value) end
        end
        function methods:SetOrientation(direction) eq(self.kind,"Slider"); eq(direction,"VERTICAL"); self.orientation=direction end
        function methods:SetValueStep(step) eq(self.kind,"Slider"); eq(step,1); self.valueStep=step end
        function methods:SetObeyStepOnDrag(obey) eq(self.kind,"Slider"); eq(obey,true); self.obeyStep=obey end
        function methods:SetThumbTexture(path)
            -- U14 ADAPT THUMB_ASSET BEGIN
--[===========[U14 ORIGINAL BEGIN
            eq(self.kind,"Slider"); eq(path,"Interface\\Buttons\\UI-ScrollBar-Knob")
U14 ORIGINAL END]===========]
            eq(self.kind,"Slider"); eq(path,"Interface\\Buttons\\WHITE8X8")
            -- U14 ADAPT THUMB_ASSET END
            self.thumb=widget("Texture",self); self.thumb:SetTexture(path)
        end
        function methods:GetThumbTexture() eq(self.kind,"Slider"); return assert(self.thumb) end
        function methods:SetEnabled(enabled) eq(type(enabled),"boolean"); self.enabled=enabled end
    end
    -- U13 SLIDER_MOCK END
    -- U13 NAME_MOCK BEGIN
    function methods:GetStringWidth()
        eq(self.kind,"FontString")
        return self.fixtureStringWidth or #self.labelText*6 -- Synthetic metrics, NOT native fit.
    end
    -- U13 NAME_MOCK END
    local anchors={TOPLEFT={0,0},TOP={0.5,0},TOPRIGHT={1,0},LEFT={0,0.5},CENTER={0.5,0.5},RIGHT={1,0.5},
        BOTTOMLEFT={0,1},BOTTOM={0.5,1},BOTTOMRIGHT={1,1}}
    local function rect(w)
        if w.allPoints then return rect(w.allPoints) end
        -- Assertions use unscaled local frame coordinates; screen fit is tested
        -- separately from width/height multiplied by the recorded local scale.
        if w==env.UIParent or w.template=="BasicFrameTemplateWithInset" or
            (w.template=="BackdropTemplate" and w.parent==env.UIParent) then return {x=0,y=0,w=w.width,h=w.height} end
        local p=w.points[1]
        if not p then return {x=0,y=0,w=w.width,h=w.height} end
        local opposite=w.points[2]
        if p.point=="TOPLEFT" and opposite and opposite.point=="BOTTOMRIGHT" then
            local a=rect(p.relative); local b=rect(opposite.relative)
            local x,y=a.x+p.x,a.y-p.y
            return {x=x,y=y,w=b.x+b.w+opposite.x-x,h=b.y+b.h-opposite.y-y}
        end
        local r=rect(p.relative); local a=assert(anchors[p.point]); local b=assert(anchors[p.anchor])
        return {x=r.x+r.w*b[1]+p.x-w.width*a[1],y=r.y+r.h*b[2]-p.y-w.height*a[2],w=w.width,h=w.height}
    end
    env.UIParent=widget("Frame"); env.UIParent.width=1920; env.UIParent.height=1080
    env.GameTooltip=widget("Tooltip")
    env.CreateFrame=function(kind,_,parent,template)
        if template=="WowStyle1DropdownTemplate" and env.fixtureNoDropdownCreation then error("fixture native dropdown unavailable") end
        local w=widget(kind,parent,template)
        if template=="BasicFrameTemplateWithInset" then w.TitleText=widget("FontString",w,"GameFontHighlightSmall") end
        if template=="WowStyle1DropdownTemplate" then
            eq(kind,"DropdownButton","real native menu widget kind")
            w.Background=widget("Texture",w)
            w.Background:SetPoint("TOPLEFT",-8,7); w.Background:SetPoint("BOTTOMRIGHT",8,-9)
            function w:fixtureGenerate()
                self.radios={}
                local root={}
                if not env.fixtureNoCreateRadio then
                    function root:CreateRadio(label,isSelected,onSelect,data)
                        if env.fixtureRadioError then error("fixture native CreateRadio failure") end
                        eq(self,root,"root menu inserter forwarding")
                        assert(type(label)=="string" and type(isSelected)=="function" and type(onSelect)=="function","native radio signature")
                        local item={label=label,isSelected=isSelected,onSelect=onSelect,data=data}
                        function item:Click() self.onSelect(self.data); w:fixtureGenerate() end
                        w.radios[#w.radios+1]=item
                    end
                end
                self.generator(self,root)
                self.selectedText=self.defaultText
                for _,radio in ipairs(self.radios) do
                    local selected=radio.isSelected(radio.data)
                    assert(type(selected)=="boolean","radio isSelected result")
                    if selected then self.selectedText=radio.label end
                end
            end
            if not env.fixtureNoSetup then function w:SetupMenu(generator)
                if env.fixtureSetupError then error("fixture SetupMenu failure") end
                assert(type(generator)=="function"); self.generator=generator; self:fixtureGenerate()
            end end
            if not env.fixtureNoDefaultText then function w:SetDefaultText(value) self.defaultText=value end end
        end
        return w
    end
    env.fixtureRect=rect; env.fixtureWidgets=created
end
local function deepEqual(a,b)
    if type(a)~="table" or type(b)~="table" then return a==b end
    for k,v in pairs(a) do if not deepEqual(v,b[k]) then return false end end
    for k in pairs(b) do if a[k]==nil then return false end end
    return true
end
local function payloadFixtures()
    local raw=scan()
    return {
        skill={skillLevel=0,maxSkillLevel=100,skillModifier=0}, moxie={id=3261,quantity=0},
        concentration={id=50001,quantity=0,maxQuantity=0}, unspent=0,
        tool={slot=20,role="tool",exists=true,metadataReady=true,itemID=90020,link="item:90020:0:0",
            rarity=3,rank=5,stats={ITEM_MOD_MULTICRAFT_SHORT=0},enchant={status="observed",present=false,id=0}},
        slot33={slot=33,exists=false,metadataReady=false},
        slots={indices={20,21,22},complete=true}, knowledgeIndex={{id=11,name="Tree",root=72}},
        knowledgeRaw=raw, ["tree:11"]=treeValue(11,0,10), environment={version="fixture",locale="fixture"},
    }
end
local function numericLeaf(value,path)
    for _,key in ipairs(path) do value=value[key] end
    return value
end
local function replaceNumericLeaf(value,path,number)
    if #path==0 then return number end
    local parent=value
    for i=1,#path-1 do parent=parent[path[i]] end
    parent[path[#path]]=number
    return value
end
case("R4 typed active archive and incoming nonfinite payloads reject without mutation or attention",function(checkpoint)
    local fields={
        {key="skill",path={"skillModifier"}}, {key="moxie",path={"quantity"}},
        {key="concentration",path={"maxQuantity"}}, {key="unspent",path={}},
        {key="tool",path={"stats","ITEM_MOD_MULTICRAFT_SHORT"}},
        {key="knowledgeIndex",path={1,"id"}},
        {key="knowledgeRaw",path={"tabs",1,"paths",72,"node","currentRank"}},
        {key="tree:11",path={"paths",1,"purchased"}},
    }
    for _,sample in ipairs(nonfiniteSamples()) do
        for _,descriptor in ipairs(fields) do
            local context=descriptor.key.." / "..sample.name
            for _,archived in ipairs({false,true}) do
                pause(checkpoint,"R4 typed active/archive variant")
                local db,g=dbWith(payloadFixtures())
                if archived then
                    eq(C.Archive(db,character.guid,2913,20,"fixture"),true,"archive setup")
                    g=db.characters[character.guid].professions[2913].archives[1]
                end
                local before=C.Copy(db)
                local characters,field=db.characters,g.fields[descriptor.key]
                local last,attempt=field.last,field.attempt
                local previous=numericLeaf(last.value,descriptor.path)
                last.value=replaceNumericLeaf(last.value,descriptor.path,sample.value)
                local representation=tostring(numericLeaf(last.value,descriptor.path))
                eq(C.ValidPayload(descriptor.key,last.value,"observed"),false,"typed validator rejects "..context)
                eq(C.Open(db),nil,"invalid existing numeric payload: "..context)
                eq(db.characters,characters,"character table unchanged: "..context)
                eq(g.fields[descriptor.key],field,"field unchanged: "..context)
                eq(field.last,last,"successful envelope unchanged: "..context)
                eq(field.attempt,attempt,"attempt unchanged: "..context)
                eq(type(numericLeaf(last.value,descriptor.path)),"number","invalid value not erased: "..context)
                eq(tostring(numericLeaf(last.value,descriptor.path)),representation,"invalid scalar unchanged: "..context)
                local rows,why=NS.ViewModel.Build(db,{}, {archived=archived},200)
                eq(#rows,0,"invalid numeric DB has no rendered rows: "..context)
                assert(why:find("writes disabled",1,true),"numeric DB disable explanation: "..context)
                if descriptor.key=="moxie" then
                    -- Direct pure row input exercises the view's scalar attention
                    -- predicate too; production Build rejects this DB above.
                    local row=NS.ViewModel.Row(character.guid,db.characters[character.guid],2913,g,nil,200,archived)
                    for _,warning in ipairs(row.warnings) do assert(warning.category~="Moxie","nonfinite quantity cannot confirm attention") end
                end
                last.value=replaceNumericLeaf(last.value,descriptor.path,previous)
                assert(deepEqual(db,before),"no other mutation on invalid DB open/view: "..context)
            end
            local db=dbWith(payloadFixtures()); local before=C.Copy(db)
            local value=replaceNumericLeaf(payloadFixtures()[descriptor.key],descriptor.path,sample.value)
            local observations={unspent=C.Observation("observed",7,30,"fixture")}
            observations[descriptor.key]=C.Observation("observed",value,30,"fixture")
            local g,why=C.Apply(db,character,identity,observations,30,"fixture")
            eq(g,nil,"incoming nonfinite payload: "..context); assert(type(why)=="string","rejection reason")
            assert(deepEqual(db,before),"atomic rejection leaves valid DB unchanged: "..context)
        end
    end
end)
local function invalidPayloads()
    return {
        {key="skill",value=true}, {key="skill",value={skillLevel=0,maxSkillLevel="100",skillModifier=0}},
        {key="moxie",value=false}, {key="concentration",value={id=50001,quantity=true}},
        {key="concentration",value={id=50001,quantity=0,maxQuantity=-1}},
        {key="unspent",value=false}, {key="unspent",value=-1},
        {key="tool",change=function(v) v.stats=true end},
        {key="tool",change=function(v) v.rarity="rare" end},
        {key="tool",change=function(v) v.rank=6 end},
        {key="tool",change=function(v) v.exists="yes" end},
        {key="tool",change=function(v) v.link=12 end},
        {key="tool",change=function(v) v.itemID=90021 end},
        {key="tool",change=function(v) v.quality={iconSmall=true} end},
        {key="tool",change=function(v) v.enchantLines={false} end},
        {key="tool",change=function(v) v.enchant={status="observed",present="no",id=0} end},
        {key="tool",change=function(v) v.enchant.category=true end},
        {key="slot33",change=function(v) v.slot=34 end},
        {key="slots",change=function(v) v.indices={false} end},
        {key="knowledgeIndex",value=false},
        {key="knowledgeIndex",change=function(v) v[1].name=true end},
        {key="knowledgeIndex",change=function(v) v[1].root="72" end},
        {key="knowledgeIndex",change=function(v) v[1]=true end},
        {key="tree:11",change=function(v) v.name=true end},
        {key="tree:11",change=function(v) v.paths={false} end},
        {key="tree:11",change=function(v) v.paths[1].node=true end},
        {key="tree:11",change=function(v) v.paths[1].children={true} end},
        {key="tree:11",change=function(v) v.paths[1].children={99999} end},
        {key="tree:11",change=function(v) v.paths[1].children={v.root} end},
        {key="tree:11",change=function(v) v.paths[1].childrenComplete=false end},
        {key="tree:11",change=function(v) v.coverage.captured="1" end},
        {key="knowledgeRaw",value=true},
        {key="knowledgeRaw",change=function(v) v.tabs=false end},
        {key="knowledgeRaw",change=function(v) v.tabs[1].name=true end},
        {key="knowledgeRaw",change=function(v) v.tabs[1].paths[72].node=true end},
        {key="knowledgeRaw",change=function(v) v.tabs[1].paths[72].unlock=true end},
        {key="knowledgeRaw",change=function(v) v.tabs[1].paths[72].children={false} end},
        {key="knowledgeRaw",change=function(v) v.tabs[1].currencies={true} end},
        {key="environment",value={version=true}},
    }
end
case("R1 typed active and archived payload validation rejects every consumed malformed shape untouched",function(checkpoint)
    for _,bad in ipairs(invalidPayloads()) do
        for _,archived in ipairs({false,true}) do
            pause(checkpoint,"R1 typed active/archive variant")
            local db,g=dbWith(payloadFixtures())
            if archived then
                C.Archive(db,character.guid,2913,20,"fixture")
                g=db.characters[character.guid].professions[2913].archives[1]
            end
            if bad.change then bad.change(g.fields[bad.key].last.value) else g.fields[bad.key].last.value=bad.value end
            local before=C.Copy(db)
            local opened,reason=C.Open(db); eq(opened,nil); assert(reason:find("writes disabled",1,true))
            assert(deepEqual(db,before))
            local rows,explanation=NS.ViewModel.Build(db,{}, {archived=archived},100)
            eq(#rows,0); assert(explanation:find("writes disabled",1,true))
        end
    end
end)
case("R1 malformed incoming production scans rejected atomically including dynamic keys",function(checkpoint)
    for _,bad in ipairs(invalidPayloads()) do
        pause(checkpoint,"R1 incoming payload variant")
        local db=dbWith(payloadFixtures()); local before=C.Copy(db)
        local value=C.Copy(payloadFixtures()[bad.key])
        if bad.change then bad.change(value) else value=bad.value end
        local observations={unspent=C.Observation("observed",7,30,"fixture")}
        observations[bad.key]=C.Observation("observed",value,30,"fixture")
        local g,why=C.Apply(db,character,identity,observations,30,"fixture")
        eq(g,nil); assert(why:find("payload",1,true)); assert(deepEqual(db,before))
    end
    for _,key in ipairs({"slot0","slotx","tree:0","tree:bad","unregistered"}) do
        local db=dbWith(payloadFixtures()); local before=C.Copy(db)
        eq(C.Apply(db,character,identity,{[key]=C.Observation("observed",0,30,"fixture")},30,"fixture"),nil)
        assert(deepEqual(db,before))
    end
end)
case("R1 invalid identity labels fail load and incoming writes; zero false values remain typed",function()
    for _,name in ipairs({"name","expansionName"}) do
        for _,archived in ipairs({false,true}) do
            local db,g=dbWith(payloadFixtures())
            if archived then C.Archive(db,character.guid,2913,20,"fixture"); g=db.characters[character.guid].professions[2913].archives[1] end
            g.identity[name]=true
            local before=C.Copy(db); eq(C.Open(db),nil); assert(deepEqual(db,before))
        end
        local db=dbWith(payloadFixtures()); local before=C.Copy(db)
        local bad=C.Copy(identity); bad[name]=true
        eq(C.Apply(db,character,bad,{},30,"fixture"),nil); assert(deepEqual(db,before))
    end
    for _,name in ipairs({"name","realm"}) do
        local db=dbWith(payloadFixtures()); db.characters[character.guid][name]=true
        local before=C.Copy(db); eq(C.Open(db),nil); assert(deepEqual(db,before))
        db=dbWith(payloadFixtures()); before=C.Copy(db)
        local bad=C.Copy(character); bad[name]=true
        eq(C.Apply(db,bad,identity,{},30,"fixture"),nil); assert(deepEqual(db,before))
    end
    local db,g=dbWith(payloadFixtures())
    eq(C.Open(db),db); eq(g.fields.unspent.last.value,0)
    eq(g.fields.tool.last.value.enchant.present,false); eq(g.fields.slot33.last.value.exists,false)
    eq(g.fields.knowledgeRaw.last.value.stagedStart,false)
    g.fields.skill.last.value=true
    local env=fixtureAPI(); mockWidgets(env); env.CraftArmyDB=db
    env.DEFAULT_CHAT_FRAME={AddMessage=function() end}
    local before=C.Copy(db); local commands=NS.Commands.New(env); commands:Run("")
    eq(env.CraftArmyDB,db); assert(deepEqual(db,before)); eq(commands.collector.db,nil)
    eq(#commands.dashboard.rows,0); assert(commands.dashboard.reason.labelText:find("writes disabled",1,true))
    eq(commands.dashboard.frame:IsShown(),true)
end)
case("injected UI compact reusable rows; unknown fill hidden; scoped confirm cancel",function()
    local env,s=fixtureAPI(); mockWidgets(env)
    local collector=NS.Collectors.New(env,C.Open(nil)); collector:Scan()
    local ui=NS.Dashboard.New(env,collector); eq(ui:Create(),true); ui:Refresh()
    -- U14 MOXIE BEGIN
    do
        local db,fresh=collector.db,collector.fresh
        for _,archived in ipairs({false,true}) do
            for _,quantity in ipairs({0,600,601}) do
                collector.db=dbWith({moxie={id=3261,quantity=quantity}}); collector.fresh={}
                if archived then assert(C.Archive(collector.db,character.guid,2913,30,"U14")) end
                ui.options.archived=archived; ui:Refresh()
                local row=ui.rows[1]; local before=C.Copy({collector.db,collector.fresh,row})
                local label=ui.widgets[1].cells[I.Moxie].label
                local rgb=label.style.SetTextColor
                eq(rgb[1],quantity>600 and .20 or 1,"U14 uniform historical Moxie")
                eq(rgb[2],quantity>600 and .78 or 1); eq(rgb[3],quantity>600 and .30 or 1)
                ui:Retain("U14"); ui:Render(); rgb=label.style.SetTextColor
                eq(rgb[1],quantity>600 and .20 or 1); eq(rgb[2],quantity>600 and .78 or 1)
                assert(deepEqual({collector.db,collector.fresh,row},before),"U14 presentation data unchanged")
            end
        end
        collector.db=db; collector.fresh=fresh; ui.options.archived=nil; ui:Refresh()
    end
    -- U14 MOXIE END
    -- U13 MOXIE_UI BEGIN
    do
        local db,fresh=collector.db,collector.fresh
        local function color(r,g,b)
            local label=ui.widgets[1].cells[I.Moxie].label
            eq(label.style.SetJustifyH[1],"CENTER","U13 centered Moxie rejection")
            eq(label.style.SetTextColor[1],r); eq(label.style.SetTextColor[2],g); eq(label.style.SetTextColor[3],b)
        end
        for _,quantity in ipairs({0,600,601}) do
            local g
            collector.db,g=dbWith({moxie={id=3261,quantity=quantity}})
            collector.fresh={[character.guid..":2913"]={generation=1,fields={moxie=true}}}
            ui:Refresh(); color(quantity>600 and .20 or 1,quantity>600 and .78 or 1,quantity>600 and .30 or 1)
            -- U14 ADAPT MOXIE_SAVED BEGIN
--[===========[U14 ORIGINAL BEGIN
            collector.fresh={}; ui:Refresh(); color(quantity>600 and .38 or 1,quantity>600 and .58 or 1,quantity>600 and .42 or 1)
U14 ORIGINAL END]===========]
            collector.fresh={}; ui:Refresh(); color(quantity>600 and .20 or 1,quantity>600 and .78 or 1,quantity>600 and .30 or 1)
            -- U14 ADAPT MOXIE_SAVED END
            g.fields.moxie=C.Merge(g.fields.moxie,C.Observation("error",nil,20,"U13","transient"),"fixture",1)
            -- U14 ADAPT MOXIE_STALE BEGIN
--[===========[U14 ORIGINAL BEGIN
            ui:Refresh(); color(quantity>600 and .38 or 1,quantity>600 and .58 or 1,quantity>600 and .42 or 1)
U14 ORIGINAL END]===========]
            ui:Refresh(); color(quantity>600 and .20 or 1,quantity>600 and .78 or 1,quantity>600 and .30 or 1)
            -- U14 ADAPT MOXIE_STALE END
            assert(C.Archive(collector.db,character.guid,2913,30,"U13")); ui.options.archived=true; ui:Refresh()
            -- U14 ADAPT MOXIE_ARCHIVE BEGIN
--[===========[U14 ORIGINAL BEGIN
            color(.45,.50,.58); ui.options.archived=nil
U14 ORIGINAL END]===========]
            color(quantity>600 and .20 or 1,quantity>600 and .78 or 1,quantity>600 and .30 or 1); ui.options.archived=nil
            -- U14 ADAPT MOXIE_ARCHIVE END
        end
        collector.db=dbWith({}); ui:Refresh(); color(.45,.50,.58)
        collector.db=db; collector.fresh=fresh; ui:Refresh()
    end
    -- U13 MOXIE_UI END
    -- U13 SCROLL_UI BEGIN
    do
        -- U14 SCROLL_VISIBILITY BEGIN
        local u14Shown=ui.frame:IsShown()
        -- U14 SCROLL_VISIBILITY END
        local function near(a,b) assert(math.abs(a-b)<1e-9,tostring(a).." ~= "..tostring(b)) end
        local slider=assert(ui.scrollbar,"U13 native scrollbar rejection")
        eq(slider.kind,"Slider"); eq(slider.orientation,"VERTICAL"); eq(slider.width,12)
        eq(slider.valueStep,1); eq(slider.obeyStep,true); eq(#ui.footer,3)
        local originalRows=ui.rows; local row=originalRows[1]; local widgets={unpack(ui.widgets)}
        local render=ui.Render; local renders=0
        ui.Render=function(w) renders=renders+1; assert(renders<100,"U13 Slider feedback recursion"); return render(w) end
        for _,count in ipairs({0,1,12,13,37,5000}) do
            local rows={}; for n=1,count do rows[n]=row end
            ui.rows=rows; ui.offset=0; renders=0; assert(ui:Render()); eq(renders,1)
            eq(slider.minimum,0); eq(slider.maximum,math.max(0,count-12)); eq(slider.value,0)
            eq(slider:IsShown(),count>12); eq(slider.enabled,count>12)
            eq(slider.height,ui.viewport.height)
            eq(ui.rowRange:GetText(),count==0 and "No matching rows" or "Rows 1–"..math.min(count,12).." of "..count)
            near(ui.scrollThumb.height,math.max(18,math.min(ui.viewport.height,ui.viewport.height*12/math.max(12,count))))
            if count>12 then
                -- U14 ADAPT DRAG_BOTTOM BEGIN
--[===========[U14 ORIGINAL BEGIN
                slider:SetValue(count); eq(ui.offset,count-12); eq(slider.value,count-12)
U14 ORIGINAL END]===========]
                ui.frame:Show(); slider:SetValue(count); ui.frame.scripts.OnUpdate(ui.frame,0)
                eq(ui.offset,count-12); eq(slider.value,count-12)
                -- U14 ADAPT DRAG_BOTTOM END
                eq(ui.rowRange:GetText(),"Rows "..(count-11).."–"..count.." of "..count)
                -- U14 ADAPT DRAG_ROUND BEGIN
--[===========[U14 ORIGINAL BEGIN
                slider:SetValue(.6); eq(ui.offset,1); eq(slider.value,1)
U14 ORIGINAL END]===========]
                local previous=ui.offset
                slider:SetValue(.6); ui.frame.scripts.OnUpdate(ui.frame,0); eq(ui.offset,1)
                eq(slider.value,previous==1 and .6 or 1) -- Same integer: no redundant normalization paint.
                -- U14 ADAPT DRAG_ROUND END
                -- U14 ADAPT WHEEL_NORMALIZATION BEGIN
--[===========[U14 ORIGINAL BEGIN
                ui.viewport.scripts.OnMouseWheel(ui.viewport,-1); eq(ui.offset,math.min(4,count-12)); eq(slider.value,ui.offset)
U14 ORIGINAL END]===========]
                ui.viewport.scripts.OnMouseWheel(ui.viewport,-1); eq(ui.offset,math.min(4,count-12))
                eq(slider.value,count==13 and .6 or ui.offset) -- Native mock substep stays put when integer offset unchanged.
                -- U14 ADAPT WHEEL_NORMALIZATION END
                for _,bad in ipairs({0/0,math.huge,-math.huge,false,"3"}) do
                    local old=ui.offset; slider.scripts.OnValueChanged(slider,bad); eq(ui.offset,old)
                end
            end
            for n,w in ipairs(widgets) do eq(ui.widgets[n],w) end
        end
        ui.rows={row}; assert(ui:Render()); eq(ui.offset,0); eq(slider.value,0)
        ui.Render=render; ui.rows=originalRows; ui:Render()
        local viewport,rail=env.fixtureRect(ui.viewport),env.fixtureRect(slider)
        eq(ui.frame.width,1184); eq(viewport.w,1138); near(rail.x-viewport.x-viewport.w,4)
        eq(ui.rowRange.style.SetJustifyH[1],"RIGHT")
        -- U14 SCROLL_VISIBILITY_RESTORE BEGIN
        if not u14Shown then ui.frame:Hide() end
        -- U14 SCROLL_VISIBILITY_RESTORE END
    end
    -- U13 SCROLL_UI END
    -- U13 READ_CANARY BEGIN
    do
        local guard=u13NoAcquisition(s)
        local before=s.u13AcquisitionReads
        eq(env.C_TradeSkillUI.GetChildProfessionInfo(),s.info)
        eq(s.u13AcquisitionReads,before+1)
        local ok,why=pcall(guard)
        eq(ok,false); assert(why:find("U13 no profession/gear/currency/Knowledge acquisition",1,true),
            "U13 injected direct profession query must trip the no-acquisition guard")
        eq(select("#",env.GetProfessionInfo(1)),7)
        eq(env.C_TradeSkillUI.GetProfessionSlots(13),s.slots)
        local bad=pcall(env.C_CurrencyInfo.GetCurrencyInfo,-1); eq(bad,false)
        local check=u13NoAcquisition(s); local reads=s.reads; local guid=s.u13GUIDReads
        ui:Refresh(); eq(s.reads,reads+1); eq(s.u13GUIDReads,guid+1); check()
        reads=s.reads; guid=s.u13GUIDReads
        ui:Render(); ui.viewport.scripts.OnMouseWheel(ui.viewport,-1)
        ui.frame:Show(); ui.frame.scripts.OnUpdate(ui.frame,30)
        eq(s.reads,reads,"U13 pure Render/wheel/timer must not query own GUID")
        eq(s.u13GUIDReads,guid); check()
    end
    -- U13 READ_CANARY END
    -- U12 CONSTRAINTS BEGIN
    do
        for _,col in ipairs({I.Accessory1,I.Accessory2,I.Tool}) do
            local cell=ui.widgets[1].cells[col]; local letter=cell.statLetter
            for _,method in ipairs(letter.u12Calls or {}) do
                assert(method~="SetSize" and method~="SetWidth" and method~="SetHeight" and method~="SetAllPoints",
                    "U12 natural-letter rejection: explicit "..method)
            end
            eq(letter.allPoints,nil); eq(#letter.points,1)
            local p=letter.points[1]
            eq(p.point,"CENTER"); eq(p.anchor,"CENTER"); eq(p.relative,cell.itemBorder); eq(p.x,0); eq(p.y,-2)
            eq(letter.style.SetJustifyH[1],"CENTER")
            eq(letter.font[1],"Fonts\\FRIZQT__.TTF"); eq(letter.font[2],14); eq(letter.font[3],"OUTLINE")
            letter.u12Calls={}; assert(ui:Render())
            eq(table.concat(letter.u12Calls,","),"SetFont,SetText","U12 Render font before text")
            eq(letter.style.SetTextColor[1],1); eq(letter.style.SetTextColor[2],1); eq(letter.style.SetTextColor[3],1)
        end
        local row=ui.widgets[1]; local a,b,t=row.cells[I.Accessory1],row.cells[I.Accessory2],row.cells[I.Tool]
        eq(a.width,34); eq(b.width,28); eq(t.width,34)
        eq(a.itemBorder.points[1].x,3); eq(b.itemBorder.points[1].x,0); eq(t.itemBorder.points[1].x,-3)
        local left,right=env.fixtureRect(a.itemIcon),env.fixtureRect(t.itemIcon)
        local lb,rb=env.fixtureRect(a.itemBorder),env.fixtureRect(t.itemBorder)
        local group=env.fixtureRect(ui.headers[I.Accessory1])
        local skill,conc=env.fixtureRect(row.cells[I.Skill].bar),env.fixtureRect(row.cells[I.Concentration].bar)
        eq(group.w,96); eq(left.x-group.x,8); eq(group.x+group.w-right.x-right.w,8)
        eq(lb.x-group.x,7); eq(group.x+group.w-rb.x-rb.w,7)
        eq(left.x-skill.x-skill.w,10); eq(conc.x-right.x-right.w,10)
        eq(lb.x-skill.x-skill.w,9); eq(conc.x-rb.x-rb.w,9)
        eq(left.x-skill.x-skill.w-4,6,"U12 left icon/bar gap gains6")
        eq(conc.x-right.x-right.w-4,6,"U12 right icon/bar gap gains6")
        eq(lb.x-skill.x-skill.w-3,6,"U12 left border/bar gap gains6")
        eq(conc.x-rb.x-rb.w-3,6,"U12 right border/bar gap gains6")
        eq(skill.w,60); eq(conc.w,92); eq(row.cells[I.Skill].width,64); eq(row.cells[I.Concentration].width,96)
        -- U13 ADAPT U12_WINDOW BEGIN
--[==========[U13 ORIGINAL BEGIN
        eq(ui.viewport.width,1138); eq(ui.frame.width,1168)
U13 ORIGINAL END]==========]
        eq(ui.viewport.width,1138); eq(ui.frame.width,1184)
        -- U13 ADAPT U12_WINDOW END
        eq(#row.cells,14)
        local sortable=0
        for _,header in ipairs(ui.headers) do if header.scripts.OnClick then sortable=sortable+1 end end
        eq(sortable,9); eq(ui.headers[I.Accessory1].scripts.OnClick,nil)
    end
    -- U12 CONSTRAINTS END
    -- U11 GEOMETRY BEGIN
    do
        local failures={}
        -- U12 ADAPT COMPACT_GEOMETRY BEGIN
--[========[U12 ORIGINAL BEGIN
        for _,test in ipairs({{ui.widgets[1].height==28,"28px rows"},{ui.frame.width==1156,"1156px window"},
            {ui.headers[I.Accessory1].width==84,"84px Gear"},
            {ui.widgets[1].cells[I.Tool].width==28,"28px role cell"},
U12 ORIGINAL END]========]
        -- U13 ADAPT COMPACT_WINDOW BEGIN
--[==========[U13 ORIGINAL BEGIN
        for _,test in ipairs({{ui.widgets[1].height==28,"28px rows"},{ui.frame.width==1168,"1168px window"},
U13 ORIGINAL END]==========]
        for _,test in ipairs({{ui.widgets[1].height==28,"28px rows"},{ui.frame.width==1184,"1184px window"},
        -- U13 ADAPT COMPACT_WINDOW END
            {ui.headers[I.Accessory1].width==96,"96px Gear"},
            {ui.widgets[1].cells[I.Tool].width==34,"34px outer role cell"},
        -- U12 ADAPT COMPACT_GEOMETRY END
            {ui.widgets[1].cells[I.Tool].itemIcon.width==24,"24px icon"},
            {ui.widgets[1].cells[I.Tool].itemBorder.width==26,"26px border"}}) do
            if not test[1] then failures[#failures+1]=test[2] end
        end
        assert(#failures==0,"U11 compact-geometry rejection: "..table.concat(failures,", "))
        for _,col in ipairs({I.Accessory1,I.Accessory2,I.Tool}) do
            local cell=ui.widgets[1].cells[col]
            eq(cell.qualityFrame.width,10); eq(cell.qualityFrame.height,10)
            eq(cell.qualityDigit.font[2],10); eq(cell.statLetter.font[2],14)
            -- U12 ADAPT COMPACT_GLYPH BEGIN
--[========[U12 ORIGINAL BEGIN
            eq(cell.statBacking.width,16); eq(cell.statLetter.width,18); eq(cell.statLetter.points[1].y,-2)
U12 ORIGINAL END]========]
            eq(cell.statBacking.width,16); eq(cell.statLetter.allPoints,nil); eq(#cell.statLetter.points,1)
            eq(cell.statLetter.points[1].y,-2)
            -- U12 ADAPT COMPACT_GLYPH END
            local icon,border=env.fixtureRect(cell.itemIcon),env.fixtureRect(cell.itemBorder)
            local nextRow=ui.widgets[2].cells[col]
            local vi,vb=env.fixtureRect(nextRow.itemIcon),env.fixtureRect(nextRow.itemBorder)
            eq(vi.y-icon.y-icon.h,4); eq(vb.y-border.y-border.h,2)
            if col<I.Tool then
                local nextCell=ui.widgets[1].cells[col+1]
                local hi,hb=env.fixtureRect(nextCell.itemIcon),env.fixtureRect(nextCell.itemBorder)
                eq(hi.x-icon.x-icon.w,4); eq(hb.x-border.x-border.w,2)
            end
            eq(cell.enchantBadge.width,9); eq(cell.enchantBadge.height,11)
        end
    end
    -- U11 GEOMETRY END
    -- U10 REJECTION BEGIN
    do
        local tool=ui.widgets[1].cells[I.Tool]
        local failures={}
        -- U11 ADAPT REJECTION_ROWS BEGIN
--[======[U11 ORIGINAL BEGIN
        for _,test in ipairs({{ui.widgets[1].height==32,"32px rows"},{ui.frame.width==1204,"1204px window"},
U11 ORIGINAL END]======]
        -- U12 ADAPT REJECTION_WINDOW BEGIN
--[========[U12 ORIGINAL BEGIN
        for _,test in ipairs({{ui.widgets[1].height==28,"28px rows"},{ui.frame.width==1156,"1156px window"},
U12 ORIGINAL END]========]
        -- U13 ADAPT REJECTION_WINDOW BEGIN
--[==========[U13 ORIGINAL BEGIN
        for _,test in ipairs({{ui.widgets[1].height==28,"28px rows"},{ui.frame.width==1168,"1168px window"},
U13 ORIGINAL END]==========]
        for _,test in ipairs({{ui.widgets[1].height==28,"28px rows"},{ui.frame.width==1184,"1184px window"},
        -- U13 ADAPT REJECTION_WINDOW END
        -- U12 ADAPT REJECTION_WINDOW END
        -- U11 ADAPT REJECTION_ROWS END
            {ui.headers[I.Accessory1].label.labelText=="Gear" and ui.headers[I.Accessory1].kind=="Frame" and
                ui.headers[I.Accessory1].scripts.OnClick==nil,"static merged Gear"},
            {ui.widgets[1].cells[I.Stat].width==0 and not ui.widgets[1].cells[I.Stat].shown and
                ui.widgets[1].cells[I.Enchant].width==0 and not ui.widgets[1].cells[I.Enchant].shown,"hidden Stat/Enchant"},
            -- U11 ADAPT REJECTION_ICON BEGIN
--[======[U11 ORIGINAL BEGIN
            {tool.itemIcon and tool.itemIcon.width==28,"28px item icon"}}) do
U11 ORIGINAL END]======]
            {tool.itemIcon and tool.itemIcon.width==24,"24px item icon"}}) do
            -- U11 ADAPT REJECTION_ICON END
            if not test[1] then failures[#failures+1]=test[2] end
        end
        assert(#failures==0,"U10 layout rejection: "..table.concat(failures,", "))
    end
    -- U11 ADAPT INITIAL_SIZE BEGIN
--[======[U11 ORIGINAL BEGIN
    eq(ui.widgets[1].height,32,"U10 row height"); eq(ui.frame.width,1204,"U10 narrow window")
U11 ORIGINAL END]======]
    -- U12 ADAPT INITIAL_WINDOW BEGIN
--[========[U12 ORIGINAL BEGIN
    eq(ui.widgets[1].height,28,"U10 row height"); eq(ui.frame.width,1156,"U10 narrow window")
U12 ORIGINAL END]========]
    -- U13 ADAPT INITIAL_WINDOW BEGIN
--[==========[U13 ORIGINAL BEGIN
    eq(ui.widgets[1].height,28,"U10 row height"); eq(ui.frame.width,1168,"U10 narrow window")
U13 ORIGINAL END]==========]
    eq(ui.widgets[1].height,28,"U10 row height"); eq(ui.frame.width,1184,"U10 narrow window")
    -- U13 ADAPT INITIAL_WINDOW END
    -- U12 ADAPT INITIAL_WINDOW END
    -- U11 ADAPT INITIAL_SIZE END
    eq(ui.headers[I.Accessory1].label.labelText,"Gear"); eq(ui.headers[I.Accessory1].kind,"Frame")
    -- U11 ADAPT INITIAL_HEADER BEGIN
--[======[U11 ORIGINAL BEGIN
    eq(ui.headers[I.Accessory1].scripts.OnClick,nil); eq(ui.headers[I.Accessory1].width,132)
U11 ORIGINAL END]======]
    -- U12 ADAPT INITIAL_HEADER BEGIN
--[========[U12 ORIGINAL BEGIN
    eq(ui.headers[I.Accessory1].scripts.OnClick,nil); eq(ui.headers[I.Accessory1].width,84)
U12 ORIGINAL END]========]
    eq(ui.headers[I.Accessory1].scripts.OnClick,nil); eq(ui.headers[I.Accessory1].width,96)
    -- U12 ADAPT INITIAL_HEADER END
    -- U11 ADAPT INITIAL_HEADER END
    for _,col in ipairs({I.Stat,I.Enchant}) do
        eq(ui.widgets[1].cells[col].width,0); eq(ui.widgets[1].cells[col].shown,false)
    end
    -- U11 ADAPT INITIAL_ICON BEGIN
--[======[U11 ORIGINAL BEGIN
    eq(ui.widgets[1].cells[I.Tool].itemIcon.width,28)
U11 ORIGINAL END]======]
    eq(ui.widgets[1].cells[I.Tool].itemIcon.width,24)
    -- U11 ADAPT INITIAL_ICON END
    -- U10 REJECTION END
    -- U10 WIDGETS BEGIN
    do
        local env,state=fixtureAPI(); mockWidgets(env)
        local createFrame=env.CreateFrame
        env.CreateFrame=function(...)
            local w=createFrame(...); local font=w.CreateFontString
            w.CreateFontString=function(host,name,layer,template)
                local label=font(host,name,layer,template); label.u10Layer=layer; return label
            end
            return w
        end
        local function qualityLayers(cell)
            local quality,border=cell.qualityFrame,cell.itemBorder
            assert(quality and quality.parent==border and quality:GetFrameLevel()==border:GetFrameLevel()+1 and
                cell.qualityIcon.parent==quality and cell.qualityDigit.parent==quality,
                "U10 quality foreground layer must be a higher-level child for atlas AND fallback digit")
            eq(quality.kind,"Frame"); eq(quality.style.EnableMouse[1],false); eq(next(quality.scripts),nil)
            -- U11 ADAPT QUALITY_FRAME BEGIN
--[======[U11 ORIGINAL BEGIN
            eq(quality.style.SetBackdrop,nil); eq(quality.width,12); eq(quality.height,12)
U11 ORIGINAL END]======]
            eq(quality.style.SetBackdrop,nil); eq(quality.width,10); eq(quality.height,10)
            -- U11 ADAPT QUALITY_FRAME END
            eq(quality.points[1].point,"TOPLEFT"); eq(quality.points[1].relative,border)
            eq(quality.points[1].x,1); eq(quality.points[1].y,-1)
            eq(cell.statLetter.parent,border); eq(cell.statBacking.parent,border)
            eq(cell.statBacking.drawLayer,"ARTWORK"); eq(cell.itemIcon.drawLayer,"ARTWORK")
            eq(cell.statLetter.u10Layer,"OVERLAY"); eq(cell.qualityIcon.drawLayer,"OVERLAY"); eq(cell.qualityDigit.u10Layer,"OVERLAY")
            assert(quality:GetFrameLevel()>cell.statLetter.parent:GetFrameLevel())
            assert(quality:GetFrameLevel()>cell.statBacking.parent:GetFrameLevel())
            local backingIndex,iconIndex
            for n,w in ipairs(env.fixtureWidgets) do
                if w==cell.statBacking then backingIndex=n elseif w==cell.itemIcon then iconIndex=n end
            end
            assert(backingIndex>iconIndex,"ARTWORK backing remains above item by creation order")
            for _,visual in ipairs({cell.qualityIcon,cell.qualityDigit}) do
                local rect,borderRect=env.fixtureRect(visual),env.fixtureRect(border)
                -- U11 ADAPT QUALITY_RECT BEGIN
--[======[U11 ORIGINAL BEGIN
                eq(rect.x,borderRect.x+1); eq(rect.y,borderRect.y+1); eq(rect.w,12); eq(rect.h,12)
U11 ORIGINAL END]======]
                eq(rect.x,borderRect.x+1); eq(rect.y,borderRect.y+1); eq(rect.w,10); eq(rect.h,10)
                -- U11 ADAPT QUALITY_RECT END
            end
        end
        local values=payloadFixtures()
        local function unit(key,value,status)
            return {source=key=="toolStat" and "C_Item.GetItemStats:unenchant-link-v1" or "C_Item.GetItemInfo",
                status=status or "observed",attemptedAt=10,observedAt=10,value=value}
        end
        for _,role in ipairs({"accessory1","accessory2","tool"}) do
            local slot=({accessory1=21,accessory2=22,tool=20})[role]
            values[role]=values[role] or {slot=slot,role=role,exists=true,metadataReady=true,itemID=90000+slot,rank=5}
            local gear=values[role]
            gear.rarity=2
            gear.itemExpansion=unit("itemExpansion",10)
            gear.enchant={status="observed",present=true,id=7977,category="Resourcefulness"}
            gear.link="item:"..gear.itemID..":7977:0:0"
            gear.quality={quality=gear.rank,iconSmall="U10Quality"}; gear.icon=1234
        end
        values.tool.toolStat=unit("toolStat","Multicraft")
        local db=dbWith(values); local collector=NS.Collectors.New(env,db)
        local ui=NS.Dashboard.New(env,collector); ui:Toggle()
        local widgets=#env.fixtureWidgets; local first=ui.widgets[1]; local before=C.Copy(db)
        -- U13 ADAPT COMPACT_READ_SNAPSHOT BEGIN
--[==========[U13 ORIGINAL BEGIN
        local originalReads=state.reads
U13 ORIGINAL END]==========]
        local originalReads=state.reads; local u13VerifyReads=u13NoAcquisition(state)
        -- U13 ADAPT COMPACT_READ_SNAPSHOT END
        for _,api in ipairs({env.C_Item,env.C_TradeSkillUI}) do
            for key in pairs(api) do api[key]=function() error("U10 forbidden live hover/model/render read") end end
        end
        for _,col in ipairs({I.Accessory1,I.Accessory2,I.Tool}) do
            local cell=first.cells[col]; local border=cell.itemBorder
            qualityLayers(cell); eq(cell.qualityFrame.shown,true)
            -- U11 ADAPT WIDGET_CELL BEGIN
--[======[U11 ORIGINAL BEGIN
            eq(cell.width,44); eq(cell.height,32); eq(border.width,30); eq(border.height,30)
U11 ORIGINAL END]======]
            -- U12 ADAPT ROLE_CELL BEGIN
--[========[U12 ORIGINAL BEGIN
            eq(cell.width,28); eq(cell.height,28); eq(border.width,26); eq(border.height,26)
U12 ORIGINAL END]========]
            eq(cell.width,col==I.Accessory2 and 28 or 34); eq(cell.height,28); eq(border.width,26); eq(border.height,26)
            -- U12 ADAPT ROLE_CELL END
            -- U11 ADAPT WIDGET_CELL END
            eq(border.points[1].point,"CENTER"); eq(border.style.EnableMouse[1],false); eq(next(border.scripts),nil)
            eq(border.style.SetBackdrop[1].edgeSize,1); eq(border.style.SetBackdrop[1].edgeFile,"Interface\\Buttons\\WHITE8X8")
            -- U11 ADAPT WIDGET_ICON BEGIN
--[======[U11 ORIGINAL BEGIN
            eq(cell.itemIcon.width,28); eq(cell.itemIcon.height,28); eq(cell.itemIcon.drawLayer,"ARTWORK")
U11 ORIGINAL END]======]
            eq(cell.itemIcon.width,24); eq(cell.itemIcon.height,24); eq(cell.itemIcon.drawLayer,"ARTWORK")
            -- U11 ADAPT WIDGET_ICON END
            eq(cell.itemIcon.points[1].point,"CENTER"); eq(cell.itemIcon.texturePath,1234)
            eq(cell.itemIcon.style.SetTexCoord,nil); eq(cell.itemIcon.style.SetVertexColor,nil)
            -- U11 ADAPT WIDGET_QUALITY BEGIN
--[======[U11 ORIGINAL BEGIN
            eq(cell.qualityIcon.width,12); eq(cell.qualityIcon.height,12); eq(cell.qualityIcon.points[1].x,0); eq(cell.qualityIcon.points[1].y,0)
U11 ORIGINAL END]======]
            eq(cell.qualityIcon.width,10); eq(cell.qualityIcon.height,10); eq(cell.qualityIcon.points[1].x,0); eq(cell.qualityIcon.points[1].y,0)
            -- U11 ADAPT WIDGET_QUALITY END
            eq(cell.enchantBadge.points[1].point,"TOPRIGHT"); eq(cell.enchantBadge.points[1].x,-1); eq(cell.enchantBadge.points[1].y,-1)
            eq(cell.enchantBadge.label:GetText(),"E"); eq(cell.enchantBadge.shown,true); eq(next(cell.enchantBadge.scripts),nil)
            eq(cell.enchantBadge.style.EnableMouse[1],false)
            local color=border.style.SetBackdropBorderColor; eq(color[1],.90); eq(color[2],.15); eq(color[3],.15)
            eq(cell.fill.style.SetColorTexture[4],0); eq(cell.statLetter.shown,col==I.Tool)
            eq(cell.statBacking.shown,col==I.Tool); eq(cell.statLetter:GetText(),col==I.Tool and "M" or "")
            -- U11 ADAPT WIDGET_GLYPH BEGIN
--[======[U11 ORIGINAL BEGIN
            eq(cell.statLetter.font[1],"Fonts\\FRIZQT__.TTF"); eq(cell.statLetter.font[2],16); eq(cell.statLetter.font[3],"OUTLINE")
            eq(cell.statLetter.points[1].x,0); eq(cell.statLetter.points[1].y,-1)
U11 ORIGINAL END]======]
            eq(cell.statLetter.font[1],"Fonts\\FRIZQT__.TTF"); eq(cell.statLetter.font[2],14); eq(cell.statLetter.font[3],"OUTLINE")
            eq(cell.statLetter.points[1].x,0); eq(cell.statLetter.points[1].y,-2)
            -- U11 ADAPT WIDGET_GLYPH END
            -- U11 READABILITY BEGIN
            do
                eq(cell.qualityDigit.font[1],"Fonts\\FRIZQT__.TTF"); eq(cell.qualityDigit.font[2],10)
                eq(cell.qualityDigit.font[3],"OUTLINE")
                local q,b,l,back=env.fixtureRect(cell.qualityFrame),env.fixtureRect(border),
                    env.fixtureRect(cell.statLetter),env.fixtureRect(cell.statBacking)
                -- U12 ADAPT GLYPH_RECT BEGIN
--[========[U12 ORIGINAL BEGIN
                eq(l.w,18); eq(l.h,18); eq(back.w,16); eq(back.h,16)
U12 ORIGINAL END]========]
                -- Mock rectangles express anchors, NOT measured natural glyph extents.
                eq(cell.statLetter.allPoints,nil); eq(#cell.statLetter.points,1)
                local p=cell.statLetter.points[1]
                eq(p.point,"CENTER"); eq(p.anchor,"CENTER"); eq(p.relative,border); eq(p.x,0); eq(p.y,-2)
                for _,method in ipairs(cell.statLetter.u12Calls) do
                    assert(method~="SetSize" and method~="SetWidth" and method~="SetHeight" and method~="SetAllPoints")
                end
                eq(back.w,16); eq(back.h,16)
                -- U12 ADAPT GLYPH_RECT END
                eq(l.x+l.w/2,b.x+b.w/2); eq(l.y+l.h/2,b.y+b.h/2+2)
                eq(back.x+back.w/2,l.x+l.w/2); eq(back.y+back.h/2,l.y+l.h/2)
                eq(q.w,10); eq(q.h,10); eq(q.x,b.x+1); eq(q.y,b.y+1)
                eq(cell.statBacking.style.SetColorTexture[4],.65)
                eq(cell.enchantBadge.width,9); eq(cell.enchantBadge.height,11)
            end
            -- U11 READABILITY END
            -- U15 ADAPT WIDGET_METADATA BEGIN
--[============[U15 ORIGINAL BEGIN
            cell.scripts.OnEnter(cell); eq(env.GameTooltip.nativeLink,values[({[5]="accessory1",[6]="accessory2",[7]="tool"})[col]].link)
U15 ORIGINAL END]============]
            env.IsShiftKeyDown=function() return false end
            cell.scripts.OnEnter(cell); eq(#env.GameTooltip.lines,2)
            env.IsShiftKeyDown=function() return true end
            cell.scripts.OnEnter(cell); eq(env.GameTooltip.nativeLink,values[({[5]="accessory1",[6]="accessory2",[7]="tool"})[col]].link)
            env.IsShiftKeyDown=nil
            -- U15 ADAPT WIDGET_METADATA END
            local text=table.concat(env.GameTooltip.lines,"\n"); assert(text:find("Item expansion: 10 (older)",1,true))
            if col==I.Tool then assert(text:find("Tool's own stat: Multicraft",1,true)); assert(text:find("Resourcefulness",1,true)) end
            cell.scripts.OnMouseDown(cell,"LeftButton"); eq(ui.selected,first.row); eq(ui.details,nil)
        end
        -- U13 ADAPT COMPACT_READ_CHECK BEGIN
--[==========[U13 ORIGINAL BEGIN
        assert(deepEqual(db,before)); eq(state.reads,originalReads); eq(state.requests,0)
U13 ORIGINAL END]==========]
        assert(deepEqual(db,before)); eq(state.reads,originalReads); u13VerifyReads(); eq(state.requests,0)
        -- U13 ADAPT COMPACT_READ_CHECK END
        -- U12 SAVED_CATEGORIES BEGIN
        do
            local tool=first.cells[I.Tool]
            for n,sample in ipairs({{"Multicraft","M","Resourcefulness"},{"Resourcefulness","R","Ingenuity"},
                {"Ingenuity","I","Crafting Speed"},{"Crafting Speed","C","Multicraft"}}) do
                local saved=C.Copy(values.tool)
                saved.toolStat=unit("toolStat",sample[1])
                saved.enchant.category=sample[3]
                assert(C.Apply(db,character,identity,{tool=C.Observation("observed",saved,10+n,"U12")},10+n,"fixture"))
                local unchanged=C.Copy(db); ui:Refresh()
                eq(ui.widgets[1],first); eq(first.cells[I.Tool],tool)
                eq(tool.statLetter:GetText(),sample[2]); eq(tool.statLetter.shown,true); eq(tool.statBacking.shown,true)
                eq(tool.enchantBadge.shown,true); eq(tool.qualityIcon.shown,true); qualityLayers(tool)
                eq(tool.itemBorder.style.SetBackdropBorderColor[1],.90)
                for _,col in ipairs({I.Accessory1,I.Accessory2}) do
                    eq(first.cells[col].statLetter:GetText(),""); eq(first.cells[col].statLetter.shown,false)
                end
                tool.statLetter.u12Calls={}; assert(ui:Render())
                eq(table.concat(tool.statLetter.u12Calls,","),"SetFont,SetText")
                -- U15 ADAPT WIDGET_CATEGORIES BEGIN
--[============[U15 ORIGINAL BEGIN
                tool.scripts.OnEnter(tool)
U15 ORIGINAL END]============]
                env.IsShiftKeyDown=function() return false end
                tool.scripts.OnEnter(tool); eq(#env.GameTooltip.lines,2)
                env.IsShiftKeyDown=function() return true end
                tool.scripts.OnEnter(tool); env.IsShiftKeyDown=nil
                -- U15 ADAPT WIDGET_CATEGORIES END
                local tip=table.concat(env.GameTooltip.lines,"\n")
                assert(tip:find("Tool's own stat: "..sample[1],1,true)); assert(tip:find(sample[3],1,true))
                eq(env.GameTooltip.nativeLink,saved.link)
                -- U13 ADAPT COMPACT_REFRESH_READ_CHECK BEGIN
--[==========[U13 ORIGINAL BEGIN
                assert(deepEqual(db,unchanged)); eq(state.reads,originalReads); eq(state.requests,0)
U13 ORIGINAL END]==========]
                assert(deepEqual(db,unchanged)); u13VerifyReads(); eq(state.requests,0)
                -- U13 ADAPT COMPACT_REFRESH_READ_CHECK END
            end
            -- Restore the existing M scenario, including its original observation clock.
            assert(C.Apply(db,character,identity,{tool=C.Observation("observed",values.tool,10,"U12")},10,"fixture"))
            ui:Refresh(); eq(tool.statLetter:GetText(),"M"); eq(#env.fixtureWidgets,widgets)
        end
        -- U12 SAVED_CATEGORIES END
        local cell=first.cells[I.Tool]
        local qualityFrame=cell.qualityFrame
        local model=first.row.gear.tool; local atlas=model.qualityAtlas
        model.qualityAtlas=nil; ui:Render(); qualityLayers(cell)
        eq(cell.qualityFrame,qualityFrame); eq(qualityFrame.shown,true)
        eq(cell.qualityIcon.shown,false); eq(cell.qualityDigit.shown,true); eq(cell.statLetter:GetText(),"M")
        model.qualityAtlas=atlas; ui:Render(); qualityLayers(cell)
        eq(cell.qualityIcon.shown,true); eq(cell.qualityDigit.shown,false); eq(cell.statBacking.shown,true)
        for _,expansion in ipairs({11,12,false}) do
            local v=C.Copy(values.tool); v.link=v.link..":"..tostring(expansion)
            -- Links remain valid item payloads even when optional metadata is absent.
            if expansion==false then v.link=values.tool.link..":0" end
            v.itemExpansion=expansion~=false and unit("itemExpansion",expansion) or nil
            v.toolStat=nil; v.quality=nil; v.enchant={status="unknown"}
            assert(C.Apply(db,character,identity,{tool=C.Observation("observed",v,20,"U10")},20,"fixture")); ui:Refresh()
            eq(cell.itemBorder.style.SetBackdropBorderColor[1],30/255); eq(cell.itemBorder.style.SetBackdropBorderColor[2],1)
            eq(cell.statLetter.shown,false); eq(cell.statLetter:GetText(),""); eq(cell.enchantBadge.shown,false)
            -- U11 UNKNOWN_CLEAR BEGIN
            eq(cell.statBacking.shown,false)
            -- U11 UNKNOWN_CLEAR END
            eq(cell.qualityIcon.shown,false); eq(cell.qualityDigit.shown,true)
            eq(cell.qualityFrame,qualityFrame); eq(qualityFrame.shown,true); qualityLayers(cell)
            -- U15 ADAPT WIDGET_UNAVAILABLE BEGIN
--[============[U15 ORIGINAL BEGIN
            cell.scripts.OnEnter(cell); assert(table.concat(env.GameTooltip.lines,"\n"):find("Tool's own stat: unavailable",1,true))
U15 ORIGINAL END]============]
            env.IsShiftKeyDown=function() return false end
            cell.scripts.OnEnter(cell); eq(#env.GameTooltip.lines,2)
            env.IsShiftKeyDown=function() return true end
            cell.scripts.OnEnter(cell); assert(table.concat(env.GameTooltip.lines,"\n"):find("Tool's own stat: unavailable",1,true))
            env.IsShiftKeyDown=nil
            -- U15 ADAPT WIDGET_UNAVAILABLE END
        end
        local unknownQuality=C.Copy(values.tool); unknownQuality.link=unknownQuality.link..":99"
        unknownQuality.quality=nil; unknownQuality.rank=nil; unknownQuality.toolStat=nil
        assert(C.Apply(db,character,identity,{tool=C.Observation("observed",unknownQuality,25,"U10")},25,"fixture")); ui:Refresh()
        eq(qualityFrame.shown,false); eq(cell.qualityIcon.shown,false); eq(cell.qualityDigit.shown,false); eq(cell.itemIcon.shown,true)
        local empty={slot=20,role="tool",exists=false,metadataReady=false}
        assert(C.Apply(db,character,identity,{tool=C.Observation("observed",empty,30,"U10")},30,"fixture")); ui:Refresh()
        eq(cell.label:GetText(),""); eq(cell.itemBorder.shown,false); eq(cell.itemIcon.shown,false)
        eq(cell.qualityIcon.shown,false); eq(cell.qualityDigit.shown,false); eq(cell.enchantBadge.shown,false); eq(cell.statLetter.shown,false)
        eq(cell.qualityFrame,qualityFrame); eq(qualityFrame.shown,false)
        -- U11 EMPTY_CLEAR BEGIN
        eq(cell.statBacking.shown,false); eq(cell.statLetter:GetText(),""); eq(cell.qualityDigit:GetText(),"")
        -- U11 EMPTY_CLEAR END
        local other={guid="U10-other-owner",name="Other",realm="Synthetic"}
        assert(C.Apply(db,other,identity,{unspent=C.Observation("observed",0,40,"U10")},40,"fixture"))
        ui.options.character="Other"; ui:Refresh(); eq(ui.widgets[1],first); eq(cell.label:GetText(),"?")
        eq(cell.itemBorder.shown,false); eq(cell.enchantBadge.shown,false); eq(cell.statLetter.shown,false)
        -- U11 OWNER_CLEAR BEGIN
        eq(cell.statBacking.shown,false); eq(cell.statLetter:GetText(),""); eq(cell.qualityDigit:GetText(),"")
        -- U11 OWNER_CLEAR END
        eq(cell.qualityFrame,qualityFrame); eq(qualityFrame.shown,false)
        eq(#env.fixtureWidgets,widgets); eq(#ui.widgets,12)
        for _,col in ipairs({I.Stat,I.Enchant}) do
            local hidden=first.cells[col]; eq(hidden.shown,false); eq(hidden.label.shown,false)
            eq(hidden.width,0); eq(hidden.style.EnableMouse[1],false); eq(ui.headers[col].width,0)
        end
        -- Retained metadata has its own earlier clock, not the new base observation.
        local stale=C.Copy(values.tool); stale.toolStat.status="error"; stale.toolStat.attemptedAt=40
        stale.itemExpansion.status="unknown"; stale.itemExpansion.attemptedAt=40
        assert(C.Apply(db,character,identity,{tool=C.Observation("observed",stale,40,"U10")},40,"fixture"))
        -- U15 ADAPT WIDGET_RETAINED BEGIN
--[============[U15 ORIGINAL BEGIN
        ui.options.character=character.name; state.at=100; ui:Refresh(); cell.scripts.OnEnter(cell)
U15 ORIGINAL END]============]
        ui.options.character=character.name; state.at=100; ui:Refresh()
        env.IsShiftKeyDown=function() return false end; cell.scripts.OnEnter(cell); eq(#env.GameTooltip.lines,2)
        env.IsShiftKeyDown=function() return true end; cell.scripts.OnEnter(cell)
        -- U15 ADAPT WIDGET_RETAINED END
        local text=table.concat(env.GameTooltip.lines,"\n")
        assert(text:find("retained after error",1,true)); assert(text:find("last observed 1m ago",1,true))
        env.IsShiftKeyDown=function() return true end; cell.scripts.OnEnter(cell)
        text=table.concat(env.GameTooltip.lines,"\n"); assert(text:find("observed 10; attempted 40; status error",1,true))
        eq(cell.statLetter:GetText(),"M"); eq(cell.enchantBadge.shown,true)
        eq(cell.qualityFrame,qualityFrame); eq(qualityFrame.shown,true); qualityLayers(cell)
    end
    -- U10 WIDGETS END
    -- U10 ADAPT INITIAL_HEIGHT BEGIN
--[====[U10 ORIGINAL BEGIN
    eq(#ui.widgets,12); eq(ui.widgets[1].height,22); eq(#ui.widgets[1].cells,14)
U10 ORIGINAL END]====]
    -- U11 ADAPT INITIAL_HEIGHT BEGIN
--[======[U11 ORIGINAL BEGIN
    eq(#ui.widgets,12); eq(ui.widgets[1].height,32); eq(#ui.widgets[1].cells,14)
U11 ORIGINAL END]======]
    eq(#ui.widgets,12); eq(ui.widgets[1].height,28); eq(#ui.widgets[1].cells,14)
    -- U11 ADAPT INITIAL_HEIGHT END
    -- U10 ADAPT INITIAL_HEIGHT END
    eq(ui.widgets[1].bars[1].height,14); eq(ui.widgets[1].bars[1].fill.shown,false)
    eq(ui.widgets[1].cells[I.Unspent].label.labelText,"0")
    eq(ui.widgets[1].cells[I.Enchant].label.labelText,"")
    -- U10 ADAPT INITIAL_ENCHANT BEGIN
--[====[U10 ORIGINAL BEGIN
    eq(ui.widgets[1].cells[I.Enchant].fill.style.SetColorTexture[4],0.12,"blank missing enchant highlight")
U10 ORIGINAL END]====]
    eq(ui.widgets[1].cells[I.Enchant].fill.style.SetColorTexture[4],0,"hidden missing enchant cell")
    eq(ui.widgets[1].cells[I.Enchant].shown,false)
    -- U10 ADAPT INITIAL_ENCHANT END
    ui.selected=ui.rows[1]; ui:Lifecycle("retire"); eq(ui:FinishConfirmation(false),false)
    assert(collector.db.characters[character.guid].professions[2913].active)
    ui.selected=ui.rows[1]; ui:Lifecycle("retire"); eq(ui:FinishConfirmation(true),true)
    eq(collector.db.characters[character.guid].professions[2913].active,nil)
    ui.options.archived=true; ui:Refresh(); ui.selected=ui.rows[1]
    local second=C.Copy(character); second.guid="Player-Fixture-B"
    C.Apply(collector.db,second,identity,{},s.at,"fixture")
    ui:Lifecycle("delete",true); eq(ui:FinishConfirmation(true),true)
    eq(collector.db.characters[character.guid],nil); assert(collector.db.characters[second.guid])
end)
case("combat defers UI creation and event scans; no unsafe side effects",function()
    local env,s=fixtureAPI(); mockWidgets(env); s.combat=true
    local commands=NS.Commands.New(env); commands:Run("")
    eq(commands.dashboard.frame,nil); eq(commands.dashboard.wantOpen,true)
    commands:Event("PLAYER_EQUIPMENT_CHANGED",20,true); eq(#s.timers,0)
    s.combat=false; commands:Event("PLAYER_REGEN_ENABLED")
    assert(commands.dashboard.frame); eq(#s.timers,1); eq(s.timers[1].seconds,0)
    eq(env.CraftArmyDiagnosticsDB.sentinel,true)
end)

local function dashboardRows(count,checkpoint)
    local env,state=fixtureAPI(); mockWidgets(env)
    local db=C.Open(nil)
    for i=1,count do
        local who={guid=string.format("Player-Layout-%03d",i),name=string.format("Fixture %02d",i),realm="Synthetic"}
        assert(C.Apply(db,who,identity,{unspent=C.Observation("observed",0,10,"fixture")},10,"fixture"),"layout row setup")
        pause(checkpoint,"K3a layout row applied")
    end
    pause(checkpoint,"K3a before layout UI construction")
    local collector=NS.Collectors.New(env,db)
    local ui=NS.Dashboard.New(env,collector)
    pause(checkpoint,"K3a layout UI constructed before Toggle")
    ui:Toggle()
    pause(checkpoint,"K3a layout Toggle complete")
    return ui,env,collector,state
end
local function contained(env,child,parent,context)
    local a,b=env.fixtureRect(child),env.fixtureRect(parent)
    assert(a.x>=b.x-0.000001 and a.y>=b.y-0.000001 and a.x+a.w<=b.x+b.w+0.000001 and
        a.y+a.h<=b.y+b.h+0.000001,"out of bounds: "..context)
end
local function below(env,lower,upper,context)
    local a,b=env.fixtureRect(lower),env.fixtureRect(upper)
    assert(a.y>=b.y+b.h-0.000001,"overlapping vertical bands: "..context)
end
case("R5 geometry 0 1 2 12 13 many rows has exact compact bounds and canonical hover headers",function(checkpoint)
    -- U10 ADAPT R5_WIDTHS BEGIN
--[====[U10 ORIGINAL BEGIN
    local expected={110,100,150,64,44,44,44,140,110,96,56,292,74,100}
U10 ORIGINAL END]====]
    -- U11 ADAPT R5_WIDTHS BEGIN
--[======[U11 ORIGINAL BEGIN
    local expected={110,100,150,64,44,44,44,0,0,96,56,292,74,100}
U11 ORIGINAL END]======]
    -- U12 ADAPT R5_WIDTHS BEGIN
--[========[U12 ORIGINAL BEGIN
    local expected={110,100,150,64,28,28,28,0,0,96,56,292,74,100}
U12 ORIGINAL END]========]
    local expected={110,100,150,64,34,28,34,0,0,96,56,292,74,100}
    -- U12 ADAPT R5_WIDTHS END
    -- U11 ADAPT R5_WIDTHS END
    -- U10 ADAPT R5_WIDTHS END
    for _,count in ipairs({0,1,2,12,13,37}) do
        pause(checkpoint,"R5 geometry variant")
        local ui,env=dashboardRows(count,checkpoint)
        local visible=math.min(12,math.max(1,count))
        -- U10 ADAPT R5_FRAME BEGIN
--[====[U10 ORIGINAL BEGIN
        eq(ui.frame.width,1454,"fixed outer width"); eq(ui.frame.height,194+22*visible,"dynamic window height")
        eq(ui.viewport.width,1424,"shared content width"); eq(ui.viewport.height,22*visible,"no empty 12-row viewport")
U10 ORIGINAL END]====]
        -- U11 ADAPT R5_FRAME BEGIN
--[======[U11 ORIGINAL BEGIN
        eq(ui.frame.width,1204,"fixed outer width"); eq(ui.frame.height,194+32*visible,"dynamic window height")
        eq(ui.viewport.width,1174,"shared content width"); eq(ui.viewport.height,32*visible,"no empty 12-row viewport")
U11 ORIGINAL END]======]
        -- U12 ADAPT R5_FRAME BEGIN
--[========[U12 ORIGINAL BEGIN
        eq(ui.frame.width,1156,"fixed outer width"); eq(ui.frame.height,194+28*visible,"dynamic window height")
        eq(ui.viewport.width,1126,"shared content width"); eq(ui.viewport.height,28*visible,"no empty 12-row viewport")
U12 ORIGINAL END]========]
        -- U13 ADAPT R5_WINDOW BEGIN
--[==========[U13 ORIGINAL BEGIN
        eq(ui.frame.width,1168,"fixed outer width"); eq(ui.frame.height,194+28*visible,"dynamic window height")
U13 ORIGINAL END]==========]
        eq(ui.frame.width,1184,"fixed outer width"); eq(ui.frame.height,194+28*visible,"dynamic window height")
        -- U13 ADAPT R5_WINDOW END
        eq(ui.viewport.width,1138,"shared content width"); eq(ui.viewport.height,28*visible,"no empty 12-row viewport")
        -- U12 ADAPT R5_FRAME END
        -- U11 ADAPT R5_FRAME END
        -- U10 ADAPT R5_FRAME END
        eq(ui.visibleRows,visible); eq(#ui.widgets,12,"fixed reusable row pool"); eq(ui.empty.shown,count==0)
        local x=15
        for col,width in ipairs(expected) do
            local header=ui.headers[col]; local r=env.fixtureRect(header)
            -- U10 ADAPT R5_HEADERS BEGIN
--[====[U10 ORIGINAL BEGIN
            eq(r.x,x,"header offset "..col); eq(header.width,width,"header width "..col)
            eq(header.label.labelText,col==I.Accessory1 and "A1" or col==I.Accessory2 and "A2" or NS.ViewModel.columns[col],"short header "..col)
            eq(header.label.template,"GameFontHighlightSmall","native small font not shrunk")
            header.scripts.OnEnter(header); eq(env.GameTooltip.lines[1],NS.ViewModel.columns[col],"full canonical header hover")
            contained(env,header,ui.frame,"header"); contained(env,header.label,header,"header label")
U10 ORIGINAL END]====]
            eq(r.x,x,"header offset "..col)
            -- U11 ADAPT R5_HEADER BEGIN
--[======[U11 ORIGINAL BEGIN
            eq(header.width,col==I.Accessory1 and 132 or header.hiddenColumn and 0 or width,"header width "..col)
U11 ORIGINAL END]======]
            -- U12 ADAPT R5_HEADER BEGIN
--[========[U12 ORIGINAL BEGIN
            eq(header.width,col==I.Accessory1 and 84 or header.hiddenColumn and 0 or width,"header width "..col)
U12 ORIGINAL END]========]
            eq(header.width,col==I.Accessory1 and 96 or header.hiddenColumn and 0 or width,"header width "..col)
            -- U12 ADAPT R5_HEADER END
            -- U11 ADAPT R5_HEADER END
            eq(header.label.labelText,col==I.Accessory1 and "Gear" or NS.ViewModel.columns[col],"header "..col)
            eq(header.label.template,"GameFontHighlightSmall","native small font not shrunk")
            if header.hiddenColumn then eq(header.shown,false); eq(header.label.shown,false); eq(header.style.EnableMouse[1],false)
            else
                header.scripts.OnEnter(header); eq(env.GameTooltip.lines[1],col==I.Accessory1 and "Gear" or NS.ViewModel.columns[col],"canonical hover")
                contained(env,header,ui.frame,"header"); contained(env,header.label,header,"header label")
            end
            -- U10 ADAPT R5_HEADERS END
            x=x+width
        end
        -- U10 ADAPT R5_RIGHT BEGIN
--[====[U10 ORIGINAL BEGIN
        eq(x,1439,"right margin15")
U10 ORIGINAL END]====]
        -- U11 ADAPT R5_RIGHT BEGIN
--[======[U11 ORIGINAL BEGIN
        eq(x,1189,"right margin15")
U11 ORIGINAL END]======]
        -- U12 ADAPT R5_RIGHT BEGIN
--[========[U12 ORIGINAL BEGIN
        eq(x,1141,"right margin15")
U12 ORIGINAL END]========]
        eq(x,1153,"right margin15")
        -- U12 ADAPT R5_RIGHT END
        -- U11 ADAPT R5_RIGHT END
        -- U10 ADAPT R5_RIGHT END
        for i,w in ipairs(ui.widgets) do
            -- U10 ADAPT R5_ROW BEGIN
--[====[U10 ORIGINAL BEGIN
            eq(w.width,1424); eq(w.height,22); eq(w.shown,i<=count and i<=12,"row visibility")
U10 ORIGINAL END]====]
            -- U11 ADAPT R5_ROW BEGIN
--[======[U11 ORIGINAL BEGIN
            eq(w.width,1174); eq(w.height,32); eq(w.shown,i<=count and i<=12,"row visibility")
U11 ORIGINAL END]======]
            -- U12 ADAPT R5_ROW BEGIN
--[========[U12 ORIGINAL BEGIN
            eq(w.width,1126); eq(w.height,28); eq(w.shown,i<=count and i<=12,"row visibility")
U12 ORIGINAL END]========]
            eq(w.width,1138); eq(w.height,28); eq(w.shown,i<=count and i<=12,"row visibility")
            -- U12 ADAPT R5_ROW END
            -- U11 ADAPT R5_ROW END
            -- U10 ADAPT R5_ROW END
            if w.shown then contained(env,w,ui.viewport,"visible row") end
            local left=env.fixtureRect(w).x
            for col,cell in ipairs(w.cells) do
                eq(cell.width,expected[col]); eq(env.fixtureRect(cell).x,left,"column adjacency")
                contained(env,cell,w,"cell"); left=left+expected[col]
            end
            local tool=w.cells[I.Tool]
            eq(tool.gear,nil); eq(tool.stats,nil); eq(tool.enchant,nil,"no nested Tool summaries")
        end
        contained(env,ui.statusArea,ui.frame,"status width"); contained(env,ui.selectionArea,ui.frame,"selection footer")
        below(env,ui.selectionArea,ui.viewport,"selection below viewport")
        for _,w in ipairs(ui.toolbar) do contained(env,w,ui.frame,"toolbar button") end
        for _,w in pairs(ui.filters) do contained(env,w,ui.frame,"one-line filter") end
        contained(env,ui.professionControl,ui.frame,"profession dropdown")
        if ui.professionAvailable then
            local d=env.fixtureRect(ui.professionControl); local status=env.fixtureRect(ui.statusArea); local h=env.fixtureRect(ui.headers[1])
            local background=env.fixtureRect(ui.professionControl.Background)
            eq(d.y,55); eq(d.h,25); assert(d.y-7>=status.y+status.h,"native dropdown top decoration clear of status")
            assert(d.y+d.h+9<=h.y,"native dropdown bottom decoration clear of header")
            -- U10 ADAPT R5_DROPDOWN BEGIN
--[====[U10 ORIGINAL BEGIN
            assert(d.x-8>=15 and d.x+d.w+8<=1439,"native decoration inside content margins")
U10 ORIGINAL END]====]
            -- U11 ADAPT R5_DROPDOWN BEGIN
--[======[U11 ORIGINAL BEGIN
            assert(d.x-8>=15 and d.x+d.w+8<=1189,"native decoration inside content margins")
U11 ORIGINAL END]======]
            -- U12 ADAPT R5_DROPDOWN BEGIN
--[========[U12 ORIGINAL BEGIN
            assert(d.x-8>=15 and d.x+d.w+8<=1141,"native decoration inside content margins")
U12 ORIGINAL END]========]
            assert(d.x-8>=15 and d.x+d.w+8<=1153,"native decoration inside content margins")
            -- U12 ADAPT R5_DROPDOWN END
            -- U11 ADAPT R5_DROPDOWN END
            -- U10 ADAPT R5_DROPDOWN END
            eq(background.x,d.x-8); eq(background.y,d.y-7); eq(background.w,d.w+16); eq(background.h,d.h+16)
            contained(env,ui.professionControl.Background,ui.frame,"native dropdown decoration")
        end
        for _,w in ipairs(ui.footer) do contained(env,w,ui.frame,"footer button"); below(env,w,ui.selectionArea,"footer below selection") end
        ui:Confirm({guid="fixture"},"delete","Fixture scope")
        eq(ui.confirmPanel.shown,true); contained(env,ui.confirmPanel,ui.frame,"confirmation band")
        for _,w in ipairs(ui.footer) do below(env,ui.confirmPanel,w,"confirmation below active footer/paging") end
        contained(env,ui.confirmText,ui.confirmPanel,"confirmation label")
        for _,w in ipairs(ui.confirmButtons) do contained(env,w,ui.confirmPanel,"confirmation buttons") end
        local label=env.fixtureRect(ui.confirmText); local yes=env.fixtureRect(ui.confirmButtons[1])
        assert(label.x+label.w<=yes.x,"confirmation text does not cover buttons")
        ui:FinishConfirmation(false)
    end
end)
case("R5 filter shrink grow archive paging selection and confirmation stay reachable",function(checkpoint)
    local ui,env,collector=dashboardRows(37,checkpoint)
    local first=ui.widgets[1]
    -- U10 ADAPT PAGE_INITIAL BEGIN
--[====[U10 ORIGINAL BEGIN
    eq(ui.frame.height,458); eq(ui.widgets[1].row.name,"Fixture 01")
U10 ORIGINAL END]====]
    -- U11 ADAPT PAGE_INITIAL BEGIN
--[======[U11 ORIGINAL BEGIN
    eq(ui.frame.height,578); eq(ui.widgets[1].row.name,"Fixture 01")
U11 ORIGINAL END]======]
    eq(ui.frame.height,530); eq(ui.widgets[1].row.name,"Fixture 01")
    -- U11 ADAPT PAGE_INITIAL END
    -- U10 ADAPT PAGE_INITIAL END
    pause(checkpoint,"K3a paging initial state")
    -- U13 ADAPT PAGE_13 BEGIN
--[==========[U13 ORIGINAL BEGIN
    ui.footer[5].scripts.OnClick(ui.footer[5]); eq(ui.offset,12); eq(ui.widgets[1].row.name,"Fixture 13")
U13 ORIGINAL END]==========]
    -- U14 ADAPT PAGE13 BEGIN
--[===========[U14 ORIGINAL BEGIN
    ui.scrollbar:SetValue(12); eq(ui.offset,12); eq(ui.widgets[1].row.name,"Fixture 13")
U14 ORIGINAL END]===========]
    ui.scrollbar:SetValue(12); ui.frame.scripts.OnUpdate(ui.frame,0); eq(ui.offset,12); eq(ui.widgets[1].row.name,"Fixture 13")
    -- U14 ADAPT PAGE13 END
    -- U13 ADAPT PAGE_13 END
    pause(checkpoint,"K3a next page 12")
    -- U13 ADAPT PAGE_25 BEGIN
--[==========[U13 ORIGINAL BEGIN
    ui.footer[5].scripts.OnClick(ui.footer[5]); eq(ui.offset,24); eq(ui.widgets[1].row.name,"Fixture 25")
U13 ORIGINAL END]==========]
    -- U14 ADAPT PAGE25 BEGIN
--[===========[U14 ORIGINAL BEGIN
    ui.scrollbar:SetValue(24); eq(ui.offset,24); eq(ui.widgets[1].row.name,"Fixture 25")
U14 ORIGINAL END]===========]
    ui.scrollbar:SetValue(24); ui.frame.scripts.OnUpdate(ui.frame,0); eq(ui.offset,24); eq(ui.widgets[1].row.name,"Fixture 25")
    -- U14 ADAPT PAGE25 END
    -- U13 ADAPT PAGE_25 END
    pause(checkpoint,"K3a next page 24")
    -- U13 ADAPT PAGE_37 BEGIN
--[==========[U13 ORIGINAL BEGIN
    ui.footer[5].scripts.OnClick(ui.footer[5]); eq(ui.offset,25); eq(ui.widgets[12].row.name,"Fixture 37")
U13 ORIGINAL END]==========]
    -- U14 ADAPT PAGE37 BEGIN
--[===========[U14 ORIGINAL BEGIN
    ui.scrollbar:SetValue(25); eq(ui.offset,25); eq(ui.widgets[12].row.name,"Fixture 37")
U14 ORIGINAL END]===========]
    ui.scrollbar:SetValue(25); ui.frame.scripts.OnUpdate(ui.frame,0); eq(ui.offset,25); eq(ui.widgets[12].row.name,"Fixture 37")
    -- U14 ADAPT PAGE37 END
    -- U13 ADAPT PAGE_37 END
    pause(checkpoint,"K3a next page clamped25")
    ui.selected=ui.widgets[12].row
    ui:Lifecycle("delete"); eq(ui.confirmPanel.shown,true)
    pause(checkpoint,"K3a selected delete confirmation")
    ui.filters.character:SetText("Fixture 01"); ui.filters.character.scripts.OnTextChanged(ui.filters.character)
    -- U10 ADAPT PAGE_ONE BEGIN
--[====[U10 ORIGINAL BEGIN
    eq(#ui.rows,1); eq(ui.offset,0); eq(ui.frame.height,216); eq(ui.selected,nil)
U10 ORIGINAL END]====]
    -- U11 ADAPT PAGE_ONE BEGIN
--[======[U11 ORIGINAL BEGIN
    eq(#ui.rows,1); eq(ui.offset,0); eq(ui.frame.height,226); eq(ui.selected,nil)
U11 ORIGINAL END]======]
    eq(#ui.rows,1); eq(ui.offset,0); eq(ui.frame.height,222); eq(ui.selected,nil)
    -- U11 ADAPT PAGE_ONE END
    -- U10 ADAPT PAGE_ONE END
    eq(ui.confirmPanel.shown,true); contained(env,ui.confirmButtons[2],ui.frame,"cancel after shrink")
    pause(checkpoint,"K3a character filter shrink")
    ui.confirmButtons[2].scripts.OnClick(ui.confirmButtons[2]); eq(ui.confirmPanel.shown,false)
    pause(checkpoint,"K3a confirmation cancel")
    ui.filters.character:SetText(""); ui.filters.character.scripts.OnTextChanged(ui.filters.character)
    -- U10 ADAPT PAGE_GROW BEGIN
--[====[U10 ORIGINAL BEGIN
    eq(#ui.rows,37); eq(ui.frame.height,458); eq(ui.widgets[1],first,"widgets reused across filter growth")
U10 ORIGINAL END]====]
    -- U11 ADAPT PAGE_GROW BEGIN
--[======[U11 ORIGINAL BEGIN
    eq(#ui.rows,37); eq(ui.frame.height,578); eq(ui.widgets[1],first,"widgets reused across filter growth")
U11 ORIGINAL END]======]
    eq(#ui.rows,37); eq(ui.frame.height,530); eq(ui.widgets[1],first,"widgets reused across filter growth")
    -- U11 ADAPT PAGE_GROW END
    -- U10 ADAPT PAGE_GROW END
    pause(checkpoint,"K3a character filter growth")
    ui.offset=999; ui:Refresh(); eq(ui.offset,25,"refresh clamps old offset")
    pause(checkpoint,"K3a Refresh clamps offset")
    ui.viewport.scripts.OnMouseWheel(ui.viewport,100); eq(ui.offset,0)
    pause(checkpoint,"K3a mousewheel first page")
    ui.viewport.scripts.OnMouseWheel(ui.viewport,-100); eq(ui.offset,25)
    pause(checkpoint,"K3a mousewheel last page")
    -- U13 ADAPT PAGE_PREVIOUS BEGIN
--[==========[U13 ORIGINAL BEGIN
    ui.footer[4].scripts.OnClick(ui.footer[4]); eq(ui.offset,13)
U13 ORIGINAL END]==========]
    -- U14 ADAPT PAGE_PREV BEGIN
--[===========[U14 ORIGINAL BEGIN
    ui.scrollbar:SetValue(13); eq(ui.offset,13)
U14 ORIGINAL END]===========]
    ui.scrollbar:SetValue(13); ui.frame.scripts.OnUpdate(ui.frame,0); eq(ui.offset,13)
    -- U14 ADAPT PAGE_PREV END
    -- U13 ADAPT PAGE_PREVIOUS END
    eq(ui.filters.profession,nil,"profession text input removed")
    pause(checkpoint,"K3a previous page")
    ui.professionDropdown.radios[2].onSelect(ui.professionDropdown.radios[2].data) -- Alchemy; fixtures are Inscription.
    -- U10 ADAPT PAGE_EMPTY BEGIN
--[====[U10 ORIGINAL BEGIN
    eq(#ui.rows,0); eq(ui.frame.height,216); eq(ui.offset,0); eq(ui.empty.shown,true)
U10 ORIGINAL END]====]
    -- U11 ADAPT PAGE_EMPTY BEGIN
--[======[U11 ORIGINAL BEGIN
    eq(#ui.rows,0); eq(ui.frame.height,226); eq(ui.offset,0); eq(ui.empty.shown,true)
U11 ORIGINAL END]======]
    eq(#ui.rows,0); eq(ui.frame.height,222); eq(ui.offset,0); eq(ui.empty.shown,true)
    -- U11 ADAPT PAGE_EMPTY END
    -- U10 ADAPT PAGE_EMPTY END
    pause(checkpoint,"K3a profession filter Alchemy")
    ui.professionDropdown.radios[1].onSelect(ui.professionDropdown.radios[1].data)
    pause(checkpoint,"K3a profession filter All")
    C.Archive(collector.db,"Player-Layout-001",2913,120,"fixture")
    pause(checkpoint,"K3a archive first fixture")
    C.Archive(collector.db,"Player-Layout-002",2913,120,"fixture")
    pause(checkpoint,"K3a archive second fixture")
    -- U10 ADAPT PAGE_ARCHIVE BEGIN
--[====[U10 ORIGINAL BEGIN
    ui.archived.radios[2]:Click(); eq(#ui.rows,2); eq(ui.frame.height,238); eq(ui.offset,0)
U10 ORIGINAL END]====]
    -- U11 ADAPT PAGE_ARCHIVE BEGIN
--[======[U11 ORIGINAL BEGIN
    ui.archived.radios[2]:Click(); eq(#ui.rows,2); eq(ui.frame.height,258); eq(ui.offset,0)
U11 ORIGINAL END]======]
    ui.archived.radios[2]:Click(); eq(#ui.rows,2); eq(ui.frame.height,250); eq(ui.offset,0)
    -- U11 ADAPT PAGE_ARCHIVE END
    -- U10 ADAPT PAGE_ARCHIVE END
    eq(#ui.rows[1].warnings,0,"archive warnings remain excluded")
    pause(checkpoint,"K3a archived view")
    -- U10 ADAPT PAGE_ACTIVE BEGIN
--[====[U10 ORIGINAL BEGIN
    ui.archived.radios[1]:Click(); eq(#ui.rows,35); eq(ui.frame.height,458)
U10 ORIGINAL END]====]
    -- U11 ADAPT PAGE_ACTIVE BEGIN
--[======[U11 ORIGINAL BEGIN
    ui.archived.radios[1]:Click(); eq(#ui.rows,35); eq(ui.frame.height,578)
U11 ORIGINAL END]======]
    ui.archived.radios[1]:Click(); eq(#ui.rows,35); eq(ui.frame.height,530)
    -- U11 ADAPT PAGE_ACTIVE END
    -- U10 ADAPT PAGE_ACTIVE END
    pause(checkpoint,"K3a active view")
end)
case("R5 screen fit uses shared Finite and positive local scale on small invalid screens",function(checkpoint)
    local ui,env=dashboardRows(13,checkpoint)
    for _,sample in ipairs({{w=800,h=600},{w=1920,h=200},{w=31,h=31},{w=0,h=0},
        {w=-1,h=math.huge},{w=0/0,h="invalid"},{w=20,h=20}}) do
        env.UIParent.width=sample.w; env.UIParent.height=sample.h; ui:Refresh()
        local scale=ui.frame.scale
        assert(C.Finite(scale) and scale>0 and scale<=1,"invalid local scale")
        -- U10 ADAPT SCREEN_FIT BEGIN
--[====[U10 ORIGINAL BEGIN
        if C.Finite(sample.w) and sample.w>30 then assert(1454*scale<=sample.w-30+0.000001,"width fit margin") end
        if C.Finite(sample.h) and sample.h>30 then assert(458*scale<=sample.h-30+0.000001,"height fit margin") end
U10 ORIGINAL END]====]
        -- U11 ADAPT SCREEN_FIT BEGIN
--[======[U11 ORIGINAL BEGIN
        if C.Finite(sample.w) and sample.w>30 then assert(1204*scale<=sample.w-30+0.000001,"width fit margin") end
        if C.Finite(sample.h) and sample.h>30 then assert(578*scale<=sample.h-30+0.000001,"height fit margin") end
U11 ORIGINAL END]======]
        -- U12 ADAPT SCREEN_WIDTH BEGIN
--[========[U12 ORIGINAL BEGIN
        if C.Finite(sample.w) and sample.w>30 then assert(1156*scale<=sample.w-30+0.000001,"width fit margin") end
U12 ORIGINAL END]========]
        -- U13 ADAPT SCREEN_WIDTH BEGIN
--[==========[U13 ORIGINAL BEGIN
        if C.Finite(sample.w) and sample.w>30 then assert(1168*scale<=sample.w-30+0.000001,"width fit margin") end
U13 ORIGINAL END]==========]
        if C.Finite(sample.w) and sample.w>30 then assert(1184*scale<=sample.w-30+0.000001,"width fit margin") end
        -- U13 ADAPT SCREEN_WIDTH END
        -- U12 ADAPT SCREEN_WIDTH END
        if C.Finite(sample.h) and sample.h>30 then assert(530*scale<=sample.h-30+0.000001,"height fit margin") end
        -- U11 ADAPT SCREEN_FIT END
        -- U10 ADAPT SCREEN_FIT END
        eq(env.UIParent.scale,1,"global UI scale unchanged")
        pause(checkpoint,"K3a screen fit variant complete")
    end
    env.UIParent.GetWidth=false; env.UIParent.GetHeight=function() error("fixture screen unavailable") end
    ui:Refresh(); eq(ui.frame.scale,1,"unusable dimensions use safe default")
    pause(checkpoint,"K3a unavailable screen Refresh complete")
    env.UIParent.GetWidth=function() return 900 end; env.UIParent.GetHeight=function() return 400 end
    -- U10 ADAPT SCREEN_REFRESH BEGIN
--[====[U10 ORIGINAL BEGIN
    ui:Refresh(); eq(ui.frame.scale,math.min(870/1454,370/458),"fit recomputed on refresh")
U10 ORIGINAL END]====]
    -- U11 ADAPT SCREEN_REFRESH BEGIN
--[======[U11 ORIGINAL BEGIN
    ui:Refresh(); eq(ui.frame.scale,math.min(870/1204,370/578),"fit recomputed on refresh")
U11 ORIGINAL END]======]
    -- U12 ADAPT SCREEN_REFRESH BEGIN
--[========[U12 ORIGINAL BEGIN
    ui:Refresh(); eq(ui.frame.scale,math.min(870/1156,370/530),"fit recomputed on refresh")
U12 ORIGINAL END]========]
    -- U13 ADAPT SCREEN_REFRESH BEGIN
--[==========[U13 ORIGINAL BEGIN
    ui:Refresh(); eq(ui.frame.scale,math.min(870/1168,370/530),"fit recomputed on refresh")
U13 ORIGINAL END]==========]
    ui:Refresh(); eq(ui.frame.scale,math.min(870/1184,370/530),"fit recomputed on refresh")
    -- U13 ADAPT SCREEN_REFRESH END
    -- U12 ADAPT SCREEN_REFRESH END
    -- U11 ADAPT SCREEN_REFRESH END
    -- U10 ADAPT SCREEN_REFRESH END
    pause(checkpoint,"K3a recomputed screen Refresh complete")
end)
case("R5 friendly status keeps raw unknown error block reasons and does not mutate collector",function(checkpoint)
    local ui,env,collector=dashboardRows(1,checkpoint)
    env.IsShiftKeyDown=function() return true end -- U01 legacy diagnostic fixture
    for _,sample in ipairs({
        {raw="TRADE_SKILL_CLOSE",part="showing saved snapshots"},
        {raw="TRADE_SKILL_DATA_SOURCE_CHANGING",part="wait for your own ready profession"},
        {raw="PLAYER_REGEN_DISABLED",part="collection deferred"},
        {raw="Guarded snapshot collected; knowledge cost eligibility pending evidence.",part="knowledge totals pending verification"},
        {raw="Unknown event or reason"},{raw="unsupported: readiness API missing"},
        {raw="error: TRADE_SKILL_CLOSE inside an API failure"},{raw="Invalid saved data; writes disabled (no reset)."},
        {raw="Guarded snapshot collected; knowledge cost eligibility pending evidence.",block="Future schema: writes disabled"},
    }) do
        collector.reason=sample.raw; collector.blockReason=sample.block
        local before={db=C.Copy(collector.db),fresh=C.Copy(collector.fresh),revision=collector.revision,serial=collector.serial,pending=C.Copy(collector.pending)}
        local db=collector.db; ui:Refresh()
        if sample.block then eq(ui.reason.labelText,sample.block,"blocking reason wins over success")
        elseif sample.part then assert(ui.reason.labelText:find(sample.part,1,true),"friendly context status")
        else eq(ui.reason.labelText,sample.raw,"unknown/precise failures not hidden") end
        ui.statusArea.scripts.OnEnter(ui.statusArea)
        assert(table.concat(env.GameTooltip.lines,"\n"):find("Raw status: "..sample.raw,1,true),"raw reason hover")
        eq(collector.reason,sample.raw); eq(collector.blockReason,sample.block); eq(collector.db,db)
        assert(deepEqual(collector.db,before.db) and deepEqual(collector.fresh,before.fresh) and deepEqual(collector.pending,before.pending),"presentation never edits snapshots/session")
        eq(collector.revision,before.revision); eq(collector.serial,before.serial)
        pause(checkpoint,"K3a status Refresh variant complete")
    end
end)
case("R5 plain tooltip removes complete icons only and escapes malformed hostile markup",function()
    local plain=NS.Dashboard.PlainTooltip
    eq(plain("Enchanted: |A:Rank-3:16:16|a Haranir"),"Enchanted:  Haranir")
    eq(plain("M |T1234:12:12|t 152*"),"M  152*")
    eq(plain("before |TInterface\\Icons\\Fixture:16|t after"),"before  after")
    eq(plain("left |A:Rank:16|a|T123:16|t right"),"left  right")
    for _,raw in ipairs({"|A:Rank:16","|A:|a","|A: |a","|T|t","|T:16|t","|A:Rank|t","|T123|a",
        "|A:Rank\nNext|a","||A:Literal:16|a","|cffff0000red|r","|Hitem:90020|h[hostile]|h","literal | pipe"}) do
        eq(plain(raw),raw:gsub("|","||"),"malformed/unrecognized/literal pipes escaped")
    end
    eq(plain("|A:outer|T123:16|t|a"),"||A:outer||a","stripped inner token cannot activate malformed outer markup")
end)
case("R5 native item tooltip plus clean appended evidence and full identities survive rebuild",function()
    local env=fixtureAPI(); mockWidgets(env)
    env.IsShiftKeyDown=function() return true end -- U01 legacy diagnostic fixture
    local values=payloadFixtures()
    values.tool.link="|cffa335ee|Hitem:90020:8005:0:0|h[Fixture tool]|h|r"
    values.tool.enchant={status="observed",present=true,id=8005,category="Multicraft"}
    values.tool.stats={ITEM_MOD_MULTICRAFT_SHORT=152,ITEM_MOD_RESOURCEFULNESS_SHORT=12}
    values.tool.enchantLines={{leftText="Enchanted: |A:Rank-3:16:16|a Haranir Multicrafting"}}
    local db=dbWith(values)
    db.characters[character.guid].name=string.rep("LongCharacter",20)
    db.characters[character.guid].professions[2913].active.identity.name=string.rep("LongProfession ",20)
    local before=C.Copy(db)
    local collector=NS.Collectors.New(env,db); local ui=NS.Dashboard.New(env,collector); ui:Toggle()
    local tip=env.GameTooltip; tip:AddLine("STALE previous header"); tip.calls={}
    local cell=ui.widgets[1].cells[I.Tool]; cell.scripts.OnEnter(cell)
    eq(tip.calls[1],"clear"); eq(tip.calls[2],"owner"); eq(tip.calls[3],"hyperlink")
    eq(tip.nativeLink,values.tool.link,"native hyperlink input unchanged")
    eq(tip.lines[1],"Native item: "..values.tool.link)
    eq(tip.lines[2],"Third-party BIS |A:Native-BIS:12:12|a","native/third-party content not stripped")
    local appended=table.concat(tip.lines,"\n",3)
    assert(appended:find("Multicraft: 152 (observed total)",1,true),"full tool stat retained")
    assert(appended:find("stat Multicraft; amount/rank unknown",1,true),"full enchant category retained")
    assert(appended:find("base/enchant attribution unknown",1,true),"attribution explanation retained")
    assert(appended:find("observed 10",1,true),"exact field timestamp retained")
    assert(appended:find("Slot 20",1,true),"slot metadata retained")
    assert(appended:find("Enchanted:  Haranir Multicrafting",1,true),"enchant label survives icon removal")
    assert(not appended:find("|A:",1,true) and not appended:find("STALE previous",1,true),"no raw icons/stale header appended")
    local nameCell=ui.widgets[1].cells[I.Name]; nameCell.scripts.OnEnter(nameCell)
    assert(#ui.rows[1].cells[I.Name]>nameCell.width and #ui.rows[1].cells[I.Profession]>ui.widgets[1].cells[I.Profession].width,"long label fixture exceeds cell bounds")
    eq(tip.lines[1],ui.rows[1].cells[I.Name].."-"..ui.rows[1].cells[I.Realm],"full character identity hover")
    eq(tip.lines[2],ui.rows[1].cells[I.Profession],"full profession label hover")
    -- U10 ADAPT R5_GEAR_HOVER BEGIN
--[====[U10 ORIGINAL BEGIN
    ui.headers[I.Accessory1].scripts.OnEnter(ui.headers[I.Accessory1]); eq(#tip.lines,1); eq(tip.lines[1],"Accessory #1")
U10 ORIGINAL END]====]
    ui.headers[I.Accessory1].scripts.OnEnter(ui.headers[I.Accessory1]); eq(#tip.lines,1); eq(tip.lines[1],"Gear")
    -- U10 ADAPT R5_GEAR_HOVER END
    eq(tip.nativeLink,nil,"no stale native item in header rebuild")
    assert(deepEqual(db,before),"render/tooltip cleanup never edits raw observations")
end)

case("R6 fourteen values separate identity and age-only scanned time with independent hover state",function()
    local db,g=dbWith(payloadFixtures())
    local canonical={"Name","Realm","Profession","Skill","Accessory #1","Accessory #2","Tool","Stat","Enchant",
        "Concentration","Moxie","Knowledge trees","Unspent KP","Last Updated"}
    for col,name in ipairs(canonical) do eq(NS.ViewModel.columns[col],name,"canonical column order") end
    eq(NS.ViewModel.columns[I.Name],"Name"); eq(NS.ViewModel.columns[I.Realm],"Realm")
    eq(NS.ViewModel.columns[I.LastUpdated],"Last Updated"); eq(#NS.ViewModel.columns,14)
    C.Apply(db,character,identity,{unspent=C.Observation("observed",0,70,"fixture")},70,"fixture")
    C.Apply(db,character,identity,{moxie=C.Observation("error",nil,80,"fixture","fixture transient currency error")},80,"fixture")
    local sessions={[character.guid..":2913"]={generation=1,fields={unspent=true,moxie=true}}}
    local row=NS.ViewModel.Build(db,sessions,nil,140)[1]
    eq(#row.cells,14)
    eq(row.cells[I.Name],character.name); eq(row.cells[I.Realm],character.realm); eq(row.cells[I.Profession],identity.name)
    eq(row.cells[I.Stat],"Multicraft"); eq(row.cells[I.Enchant],""); eq(row.cells[I.Unspent],"0")
    eq(row.cells[I.LastUpdated],"1m"); assert(row.snapshot:find("stale",1,true),"model retains stale context")
    local hover=table.concat(row.tooltip,"\n")
    assert(hover:find("scan timestamp 80",1,true)); assert(hover:find("moxie: error; attempted 80; observed 10",1,true))
    assert(hover:find("fixture transient currency error",1,true)); assert(hover:find("snapshot/last observed",1,true))
    assert(hover:find("unspent: observed; attempted 70; observed 70; fresh guarded read",1,true))
    C.Archive(db,character.guid,2913,130,"fixture archived later than scan")
    row=NS.ViewModel.Build(db,sessions,{archived=true},140)[1]
    eq(row.cells[I.LastUpdated],"1m","main age is scan80, never retirement130")
    assert(table.concat(row.tooltip,"\n"):find("Archived 130: fixture archived later than scan",1,true))
    eq(#row.warnings,0)
end)
case("R6 quality glyphs bare rank fallbacks rarity RGB and reused cell transparency",function(checkpoint)
    local env=fixtureAPI(); mockWidgets(env)
    local values=payloadFixtures()
    local db=dbWith(values); local collector=NS.Collectors.New(env,db); local ui=NS.Dashboard.New(env,collector); ui:Toggle()
    local first=ui.widgets[1]
    local rgb={[2]={30/255,1,0},[3]={0,112/255,221/255},[4]={163/255,53/255,238/255}}
    for rarity=2,4 do for rank=1,5 do
        pause(checkpoint,"R6 rarity/rank variant")
        local v=C.Copy(values.tool); v.icon=1234; v.rarity=rarity; v.rank=rank
        v.quality={quality=rank,iconSmall="FixtureQuality"..rank}
        C.Apply(db,character,identity,{tool=C.Observation("observed",v,100,"fixture")},100,"fixture"); ui:Refresh()
        eq(ui.widgets[1],first)
        -- U10 ADAPT R6_RARITY BEGIN
--[====[U10 ORIGINAL BEGIN
        eq(first.cells[I.Tool].label.labelText,"|T1234:14:14|t|A:FixtureQuality"..rank..":14:14|a","no redundant R#")
        local color=first.cells[I.Tool].fill.style.SetColorTexture
        for i=1,3 do eq(color[i],rgb[rarity][i],"verified rarity RGB") end; eq(color[4],0.18)
U10 ORIGINAL END]====]
        eq(first.cells[I.Tool].label.labelText,""); eq(first.cells[I.Tool].itemIcon.texturePath,1234)
        eq(first.cells[I.Tool].qualityIcon.atlas,"FixtureQuality"..rank); eq(first.cells[I.Tool].qualityIcon.shown,true)
        eq(first.cells[I.Tool].qualityDigit.shown,false,"no redundant R#")
        local color=first.cells[I.Tool].itemBorder.style.SetBackdropBorderColor
        for i=1,3 do eq(color[i],rgb[rarity][i],"verified rarity RGB") end; eq(color[4],1)
        eq(first.cells[I.Tool].fill.style.SetColorTexture[4],0)
        -- U10 ADAPT R6_RARITY END
        v.quality=nil
        C.Apply(db,character,identity,{tool=C.Observation("observed",v,101,"fixture")},101,"fixture"); ui:Refresh()
        -- U10 ADAPT R6_NO_ATLAS BEGIN
--[====[U10 ORIGINAL BEGIN
        eq(first.cells[I.Tool].label.labelText,"|T1234:14:14|t"..rank,"bare known rank when atlas unavailable")
U10 ORIGINAL END]====]
        eq(first.cells[I.Tool].qualityDigit.labelText,tostring(rank),"bare known rank when atlas unavailable")
        eq(first.cells[I.Tool].qualityDigit.shown,true); eq(first.cells[I.Tool].qualityIcon.shown,false)
        -- U10 ADAPT R6_NO_ATLAS END
        v.quality={quality=rank%5+1,iconSmall="FixtureMismatch"}
        C.Apply(db,character,identity,{tool=C.Observation("observed",v,102,"fixture")},102,"fixture"); ui:Refresh()
        -- U10 ADAPT R6_BAD_ATLAS BEGIN
--[====[U10 ORIGINAL BEGIN
        eq(first.cells[I.Tool].label.labelText,"|T1234:14:14|t"..rank,"mismatched quality atlas not used")
U10 ORIGINAL END]====]
        eq(first.cells[I.Tool].qualityDigit.labelText,tostring(rank),"mismatched quality atlas not used")
        eq(first.cells[I.Tool].qualityDigit.shown,true); eq(first.cells[I.Tool].qualityIcon.shown,false)
        -- U10 ADAPT R6_BAD_ATLAS END
    end end
    local observations={}
    for _,entry in ipairs({{key="accessory1",slot=21,rarity=2},{key="accessory2",slot=22,rarity=4}}) do
        local itemID=90000+entry.slot
        observations[entry.key]=C.Observation("observed",{role=entry.key,slot=entry.slot,exists=true,metadataReady=true,
            itemID=itemID,link="item:"..itemID..":0:0:0",rarity=entry.rarity,rank=3,icon=4321},110,"fixture")
    end
    local function seedAccessories()
        local g,why=C.Apply(db,character,identity,observations,110,"fixture")
        assert(g,why); eq(g,db.characters[character.guid].professions[2913].active,"read current applied generation")
        collector.fresh={[character.guid..":2913"]={generation=g.generation,fields={accessory2=true}}}
        ui:Refresh()
        return g
    end
    local function retryAccessory(value,reason)
        local g,why=C.Apply(db,character,identity,{accessory2=C.Observation("unknown",value,115,"fixture",reason)},115,"fixture")
        assert(g,why); eq(g,db.characters[character.guid].professions[2913].active,"read retry's current generation")
        ui:Refresh(); eq(ui.widgets[1],first,"same row widget reused for retry")
        local field=g.fields.accessory2
        eq(field.attempt.status,"unknown"); eq(field.attempt.attemptedAt,115); eq(field.attempt.reason,reason)
        eq(first.row.gear.accessory2.state.fresh,false,"failed attempt cannot be fresh even with session flag")
        return field,first.row.gear.accessory2
    end
    seedAccessories()
    -- U10 ADAPT R6_ACCESSORY_BORDER BEGIN
--[====[U10 ORIGINAL BEGIN
    eq(first.cells[I.Accessory1].fill.style.SetColorTexture[4],0.18); eq(first.cells[I.Accessory2].fill.style.SetColorTexture[4],0.18)
U10 ORIGINAL END]====]
    for _,col in ipairs({I.Accessory1,I.Accessory2}) do
        eq(first.cells[col].fill.style.SetColorTexture[4],0); eq(first.cells[col].itemBorder.style.SetBackdropBorderColor[4],1)
    end
    -- U10 ADAPT R6_ACCESSORY_BORDER END
    local same={slot=22,role="accessory2",exists=true,metadataReady=false,itemID=90022,link="item:90022:0:0:0"}
    local retained,gear=retryAccessory(same,"transient failure")
    eq(retained.last.status,"observed"); eq(retained.last.observedAt,110,"same-instance success timestamp retained")
    eq(retained.last.value.rarity,4); eq(retained.last.value.rank,3); eq(retained.last.value.icon,4321)
    eq(retained.last.value.itemID,same.itemID); eq(retained.last.value.link,same.link)
    eq(gear.state.observedAt,110); eq(gear.state.attemptedAt,115); eq(gear.state.stale,true)
    eq(gear.state.reason,"transient failure"); assert(first.row.snapshot:find("stale",1,true))
    -- U10 ADAPT R6_RETAIN_BORDER BEGIN
--[====[U10 ORIGINAL BEGIN
    eq(first.cells[I.Accessory2].fill.style.SetColorTexture[4],0.18,"failed attempt retains last-observed rarity, not invented unknown")
U10 ORIGINAL END]====]
    for i=1,3 do eq(first.cells[I.Accessory2].itemBorder.style.SetBackdropBorderColor[i],rgb[4][i],"failed attempt retains last-observed rarity") end
    eq(first.cells[I.Accessory2].fill.style.SetColorTexture[4],0)
    -- U10 ADAPT R6_RETAIN_BORDER END
    for _,sample in ipairs({
        {name="nil identity"},
        {name="unidentified instance",value={slot=22,role="accessory2",exists=true,metadataReady=false}},
        {name="changed ID",value={slot=22,role="accessory2",exists=true,metadataReady=false,itemID=90023,link="item:90023:0:0:0"}},
        {name="changed link",value={slot=22,role="accessory2",exists=true,metadataReady=false,itemID=90022,link="item:90022:0:0:1"}},
    }) do
        seedAccessories() -- Each negative starts from a known coloured, identified instance.
        -- U10 ADAPT R6_RESEED_BORDER BEGIN
--[====[U10 ORIGINAL BEGIN
        eq(first.cells[I.Accessory2].fill.style.SetColorTexture[4],0.18,"negative subcase reseeded: "..sample.name)
U10 ORIGINAL END]====]
        for i=1,3 do eq(first.cells[I.Accessory2].itemBorder.style.SetBackdropBorderColor[i],rgb[4][i],"negative subcase reseeded: "..sample.name) end
        eq(first.cells[I.Accessory2].fill.style.SetColorTexture[4],0)
        -- U10 ADAPT R6_RESEED_BORDER END
        local field,unknown=retryAccessory(sample.value,sample.name)
        if sample.value then
            assert(field.last,"current partial instance evidence remains")
            eq(field.last.observedAt,115,"old success time must not survive changed/unverified identity")
            eq(field.last.value.itemID,sample.value.itemID); eq(field.last.value.link,sample.value.link)
            for _,key in ipairs({"rarity","rank","icon","quality","stats"}) do eq(field.last.value[key],nil,"no inherited "..key..": "..sample.name) end
            eq(unknown.exists,true)
        else eq(field.last,nil,"nil identity cannot retain any prior equipment unit"); eq(unknown.exists,nil) end
        eq(unknown.rarity,nil); eq(unknown.rank,nil); assert(not unknown.empty,"unknown instance is not a confirmed missing item")
        eq(first.cells[I.Accessory2].label.labelText,"?","unverified metadata stays unknown, not empty")
        eq(first.cells[I.Accessory2].fill.style.SetColorTexture[4],0,"unverified/changed identity clears old colour: "..sample.name)
    end
    for _,v in ipairs({
        {slot=20,role="tool",exists=true,metadataReady=false,icon=1234},
        {slot=20,role="tool",exists=true,metadataReady=false,rank=5,icon=1234},
        {slot=20,role="tool",exists=false,metadataReady=false},
    }) do
        local obs={tool=C.Observation("observed",v,120,"fixture"),
            accessory1=C.Observation("observed",{slot=21,role="accessory1",exists=false,metadataReady=false},120,"fixture"),
            accessory2=C.Observation("observed",{slot=22,role="accessory2",exists=true,metadataReady=false},120,"fixture")}
        C.Apply(db,character,identity,obs,120,"fixture"); ui:Refresh()
        for _,col in ipairs({I.Accessory1,I.Accessory2,I.Tool}) do eq(first.cells[col].fill.style.SetColorTexture[4],0,"reused cell transparent") end
        -- U10 ADAPT R6_UNKNOWN_ICON BEGIN
--[====[U10 ORIGINAL BEGIN
        if v.exists then eq(first.cells[I.Tool].label.labelText,"|T1234:14:14|t"..(v.rank and "5" or "?"))
        else eq(first.cells[I.Tool].label.labelText,"") end
U10 ORIGINAL END]====]
        if v.exists then
            eq(first.cells[I.Tool].label.labelText,""); eq(first.cells[I.Tool].itemIcon.texturePath,1234)
            eq(first.cells[I.Tool].itemIcon.shown,true); eq(first.cells[I.Tool].qualityDigit.labelText,v.rank and "5" or "")
        else eq(first.cells[I.Tool].label.labelText,""); eq(first.cells[I.Tool].itemIcon.shown,false) end
        -- U10 ADAPT R6_UNKNOWN_ICON END
    end
end)
case("R6 Enchant known absent no-tool unloaded unknown unmapped and blank attention",function(checkpoint)
    for _,mode in ipairs({"known","absent","empty","notApplicable","unloaded","unknown","unmapped"}) do
        pause(checkpoint,"R6 enchant variant")
        local env=fixtureAPI(); mockWidgets(env); local values=payloadFixtures()
        env.IsShiftKeyDown=function() return true end -- U01 legacy diagnostic fixture
        if mode=="known" then values.tool.enchant={status="observed",present=true,id=8005,category="Multicraft"}; values.tool.link="item:90020:8005:0"
        elseif mode=="empty" then values.tool={slot=20,role="tool",exists=false,metadataReady=false}
        elseif mode=="unloaded" then values.tool={slot=20,role="tool",exists=true,metadataReady=false,itemID=90020}
        elseif mode=="unknown" then values.tool.enchant={status="unknown",reason="fixture conflicting/unready"}
        elseif mode=="unmapped" then values.tool.enchant={status="observed",present=true,id=9999}; values.tool.link="item:90020:9999:0" end
        local db=dbWith(values)
        if mode=="notApplicable" then C.Apply(db,character,identity,{tool=C.Observation("not_applicable",nil,20,"fixture")},20,"fixture") end
        local collector=NS.Collectors.New(env,db)
        collector.fresh={[character.guid..":2913"]={generation=1,fields={tool=true}}}
        local ui=NS.Dashboard.New(env,collector); ui:Toggle()
        local expected=(mode=="known" and "Multicraft") or ((mode=="absent" or mode=="empty" or mode=="notApplicable") and "") or "?"
        eq(ui.rows[1].cells[I.Enchant],expected); eq(ui.widgets[1].cells[I.Enchant].label.labelText,expected)
        local missing=mode=="absent"
        -- U10 ADAPT R6_ENCHANT_ATTENTION BEGIN
--[====[U10 ORIGINAL BEGIN
        eq(ui.rows[1].enchantAttention==true,missing); eq(ui.widgets[1].cells[I.Enchant].fill.style.SetColorTexture[4],missing and 0.12 or 0)
U10 ORIGINAL END]====]
        eq(ui.rows[1].enchantAttention==true,missing); eq(ui.widgets[1].cells[I.Enchant].fill.style.SetColorTexture[4],0)
        eq(ui.widgets[1].cells[I.Tool].enchantBadge.shown,mode=="known" or mode=="unmapped")
        -- U10 ADAPT R6_ENCHANT_ATTENTION END
        eq(#NS.ViewModel.Build(db,collector.fresh,{attention="Missing enchant"},100),missing and 1 or 0)
        if missing then
            eq(ui.rows[1].enchantMissing,true); assert(not expected:find("!",1,true))
            local found=false; for _,warning in ipairs(ui.rows[1].warnings) do if warning.category=="Missing enchant" then found=true; eq(warning.fresh,true) end end; eq(found,true)
        end
        for _,col in ipairs({I.Tool,I.Stat,I.Enchant}) do
            ui.widgets[1].cells[col].scripts.OnEnter(ui.widgets[1].cells[col])
            assert(#env.GameTooltip.lines>0,"each separated column exposes full evidence")
            if missing then assert(table.concat(env.GameTooltip.lines,"\n"):find("confirmed Missing enchant",1,true)) end
        end
        if missing then
            collector.fresh={}; ui:Refresh()
            -- U10 ADAPT R6_BLANK_ENCHANT BEGIN
--[====[U10 ORIGINAL BEGIN
            eq(ui.rows[1].cells[I.Enchant],""); eq(ui.widgets[1].cells[I.Enchant].fill.style.SetColorTexture[4],0.12)
U10 ORIGINAL END]====]
            eq(ui.rows[1].cells[I.Enchant],""); eq(ui.widgets[1].cells[I.Enchant].fill.style.SetColorTexture[4],0)
            eq(ui.widgets[1].cells[I.Enchant].shown,false)
            -- U10 ADAPT R6_BLANK_ENCHANT END
            ui.widgets[1].cells[I.Enchant].scripts.OnEnter(ui.widgets[1].cells[I.Enchant])
            assert(table.concat(env.GameTooltip.lines,"\n"):find("last observed Missing enchant",1,true))
            C.Archive(db,character.guid,2913,120,"fixture archive"); ui.options.archived=true; ui:Refresh()
            eq(ui.rows[1].cells[I.Enchant],""); eq(ui.rows[1].enchantAttention,nil)
            eq(ui.widgets[1].cells[I.Enchant].fill.style.SetColorTexture[4],0,"archived row is not active missing attention")
        end
    end
    local db=dbWith({tool=payloadFixtures().tool})
    local b=C.Copy(character); b.guid="Player-Fixture-B"
    C.Apply(db,b,identity,{},10,"fixture")
    eq(NS.ViewModel.Build(db,{}, {sort="enchant"},100)[1].guid,character.guid,"confirmed missing sorts before unknown")
end)
case("R6 name realm family filters and real native radio generator selection fallback",function()
    local function setup(flags)
        local env,s=fixtureAPI(); mockWidgets(env)
        for k,v in pairs(flags or {}) do env[k]=v end
        local db=dbWith({unspent=0})
        local second={guid="Player-Family-B",name="Second",realm="OtherRealm"}
        local synthetic={skillLineID=100001,parentID=100002,profession=3,expansionID=11,name="Localized specialty",expansionName="Fixture expansion"}
        assert(C.Apply(db,second,synthetic,{unspent=C.Observation("observed",0,10,"fixture")},10,"fixture"))
        local collector=NS.Collectors.New(env,db); local ui=NS.Dashboard.New(env,collector); ui:Toggle()
        return ui,env,collector,s,second,synthetic
    end
    local ui,env,collector,s,second,synthetic=setup()
    for _,query in ipairs({character.name,character.realm,character.name.."-"..character.realm,character.guid}) do
        eq(NS.ViewModel.Build(collector.db,{}, {character=query},100)[1].guid,character.guid,"identity text filter")
    end
    eq(#NS.ViewModel.Build(collector.db,{}, {professionFamily=3},100),1)
    eq(NS.ViewModel.Build(collector.db,{}, {professionFamily=3},100)[1].profession,"Localized specialty","enum not localized-name inference")
    eq(#NS.ViewModel.Build(collector.db,{}, {profession=tostring(synthetic.skillLineID)},100),1,"legacy pure ID filter")
    eq(NS.Data.expansions[synthetic.skillLineID],nil,"no production mapping added for fixture identity")
    local dropdown=ui.professionDropdown
    eq(dropdown.kind,"DropdownButton"); eq(dropdown.template,"WowStyle1DropdownTemplate"); eq(dropdown.defaultText,"All professions")
    eq(#dropdown.radios,9); eq(dropdown.radios[1].data,nil); eq(dropdown.radios[1].isSelected(nil),true)
    local alchemy
    for i,radio in ipairs(dropdown.radios) do
        if i>1 then eq(radio.label,NS.Data.families[radio.data]); if i>2 then assert(dropdown.radios[i-1].label<radio.label,"deterministic labels") end end
        if radio.data==3 then alchemy=radio end
    end
    local before=C.Copy(collector.db); local rawReason=collector.reason
    ui.offset=99; alchemy:Click(); eq(ui.options.professionFamily,3); eq(ui.offset,0); eq(#ui.rows,1); eq(dropdown.selectedText,"Alchemy")
    eq(ui.rows[1].guid,second.guid); assert(deepEqual(collector.db,before),"menu selection never writes snapshots")
    -- U13 ADAPT R6_READ_CHECK BEGIN
--[==========[U13 ORIGINAL BEGIN
    eq(s.requests,0); eq(#s.timers,0); eq(s.reads,0); eq(collector.reason,rawReason)
U13 ORIGINAL END]==========]
    eq(s.requests,0); eq(#s.timers,0); u13NoAcquisition(s,true)(); eq(collector.reason,rawReason)
    -- U13 ADAPT R6_READ_CHECK END
    C.Archive(collector.db,second.guid,synthetic.skillLineID,120,"fixture archive")
    ui.archived.radios[2]:Click(); eq(#ui.rows,1); eq(ui.rows[1].archived,true)
    dropdown.radios[1]:Click(); eq(ui.options.professionFamily,nil); eq(dropdown.selectedText,"All professions")
    ui.archived.radios[1]:Click(); eq(#ui.rows,1)
    env.fixtureNoCreateRadio=true; ui.options.professionFamily=3; ui.options.profession="hidden"; dropdown:fixtureGenerate()
    eq(ui.professionAvailable,false); eq(ui.options.professionFamily,nil); eq(ui.options.profession,nil); eq(#ui.rows,1)
    alchemy.onSelect(3); eq(ui.options.professionFamily,nil,"stale menu callback cannot restore hidden selection")
    for _,flag in ipairs({"fixtureNoDropdownCreation","fixtureNoSetup","fixtureNoDefaultText","fixtureSetupError","fixtureNoCreateRadio","fixtureRadioError"}) do
        local view,e,c,state=setup({[flag]=true})
        eq(view.professionAvailable,false); eq(view.professionControl,view.professionFallback); eq(view.professionControl.shown,true)
        eq(view.professionControl.scripts.OnClick,nil,"disabled placeholder has no selection action")
        eq(view.options.professionFamily,nil); eq(view.options.profession,nil); eq(#view.rows,2)
        view.professionControl.scripts.OnEnter(view.professionControl)
        assert(table.concat(e.GameTooltip.lines,"\n"):find("showing All professions",1,true),"capability explanation")
        eq(state.requests,0); eq(#state.timers,0); eq(c.reason,"Log into each alt and open its profession.")
    end
end)

-- K1 fixtures deliberately differ from API ordering and keep the shared row last.
-- These are synthetic inputs, NOT evidence of installed-client cost semantics.
local function knowledgeFixture(shape,checkpoint)
    local env,state=fixtureAPI()
    shape=shape or {9,4,9,13}
    local f={tabs={},nodes={},entries={},children={},costs={},currencies={},unlock={},spend={},currency={}}
    env.GetBuildInfo=function() return "fixture-version","70783","fixture-date",120105 end
    env.UnitGUID=function() return "Player-PRIVATE-GUID" end
    env.UnitName=function() return "PRIVATE-NAME" end
    env.GetRealmName=function() return "PRIVATE-REALM" end
    local index=0
    for ti,n in ipairs(shape) do
        local tab={id=1100+ti,root=100000+ti*1000+1,ids={}}
        f.tabs[ti]=tab
        for i=1,n do
            index=index+1
            local id=100000+ti*1000+i
            tab.ids[i]=id
            local u=index%2
            local points=(index==1 or index==2) and 0 or 8
            local bought=points+u
            if index==2 then bought=0 end -- A locked, uninvested path still contributes capacity.
            local un,sp=id*2,id*2+1
            f.unlock[id]=un; f.spend[id]=sp; f.currency[id]=3902
            f.entries[un]={maxRanks=u,type=9,definitionID=un+100,entryCost={}}
            f.entries[sp]={maxRanks=30,type=7,definitionID=sp+100,entryCost={}}
            local committed={}
            if bought>0 and u==1 then committed[#committed+1]=un end
            if points>0 then committed[#committed+1]=sp end
            f.nodes[id]={ID=id,type=1,flags=0,currentRank=bought,activeRank=bought,ranksPurchased=bought,
                ranksIncreased=0,maxRanks=30+u,totalMaxRanks=30+u,isAvailable=index~=2,
                activeEntry={entryID=points>0 and sp or un,rank=points>0 and points or u},nextEntry={entryID=sp,rank=points+1},
                entryIDs={un,sp},entryIDsWithCommittedRanks=committed,entryIDToRanksIncreased={[un]=0,[sp]=0}}
            f.children[id]=i<n and {id+1} or {}
            f.costs[id]={{ID=3902,amount=1}}
            pause(checkpoint,"K3b synthetic path setup")
        end
        local rows={{traitCurrencyID=3900,quantity=0,spent=4}}
        local count=({11,6,11,15})[ti] or 15
        for j=2,count-1 do rows[j]={traitCurrencyID=5000+ti*100+j,quantity=0,spent=0} end
        rows[count]={traitCurrencyID=3902,quantity=0,spent=264}
        f.currencies[tab.id]=rows
        pause(checkpoint,"K3b synthetic tab setup")
    end
    local p,t=env.C_ProfSpecs,env.C_Traits
    p.GetSpecTabIDsForSkillLine=function(id)
        eq(id,2913); local out={}; for i,tab in ipairs(f.tabs) do out[i]=tab.id end; return out
    end
    p.GetTabInfo=function(id) return {name="Synthetic tree "..id.." |cffff0000\n\001"} end
    p.GetRootPathForTab=function(id) for _,tab in ipairs(f.tabs) do if tab.id==id then return tab.root end end end
    p.GetChildrenForPath=function(id) return f.children[id] end
    p.GetUnlockEntryForPath=function(id) return f.unlock[id] end
    p.GetSpendEntryForPath=function(id) return f.spend[id] end
    p.GetSpendCurrencyForPath=function(id) return f.currency[id] end
    t.GetNodeInfo=function(config,id) eq(config,1001); return f.nodes[id] end
    t.GetEntryInfo=function(config,id) eq(config,1001); return f.entries[id] end
    t.GetNodeCost=function(config,id) eq(config,1001); return f.costs[id] end
    t.GetTreeCurrencyInfo=function(config,id,exclude) eq(config,1001); eq(exclude,true); return f.currencies[id] end
    local runtime=NS.Collectors.New(env,{schema=999,private="PRIVATE-SAVED-DATA"})
    runtime.roster={sentinel=true}; runtime.fresh={sentinel=true}; runtime.pending={sentinel=true}
    runtime.revision=7; runtime.serial=9; runtime.reason="PRIVATE-RUNTIME-REASON"
    env.CraftArmyDB=runtime.db
    return env,state,f,runtime
end
-- Record the complete reachable graph, including function/table identity and cycles;
-- no copier that drops methods or a handpicked subset can conceal runtime mutation.
local function unchangedGraph(root)
    local saved={}
    local function visit(t)
        if type(t)~="table" or saved[t] then return end
        local record={}; saved[t]=record
        for k,v in pairs(t) do record[k]=v; visit(k); visit(v) end
    end
    visit(root)
    return function()
        for t,record in pairs(saved) do
            for k,v in pairs(record) do eq(t[k],v,"retained graph edge") end
            for k in pairs(t) do assert(record[k]~=nil,"no new runtime/DB graph edge") end
        end
    end
end
local function trappedCapture(env,runtime,fn)
    local function forbidden() error("PRIVATE-FORBIDDEN-PAYLOAD") end
    for _,key in ipairs({"Scan","Request","Login","Roster","Invalidate","StartLoads","ItemResult","Expire","Knowledge"}) do runtime[key]=forbidden end
    for _,key in ipairs({"PurchaseRank","RefundRank","CommitConfig","StageConfig","SetSelection","GetTreeNodes"}) do env.C_Traits[key]=forbidden end
    env.C_Timer.After=forbidden; env.C_Item.RequestLoadItemData=forbidden
    env.CraftRecipe=forbidden; env.EquipItemByName=forbidden
    local apply,evaluate=C.Apply,K.Evaluate
    C.Apply=forbidden; K.Evaluate=forbidden
    local verify=unchangedGraph(runtime)
    local ok,why=pcall(function() fn(); verify() end)
    C.Apply=apply; K.Evaluate=evaluate
    assert(ok,why)
end
local function firstPath(report) return report.tabs[1].paths[1] end
local function incomplete(report)
    eq(report.captureComplete,false); eq(report.candidate,nil); eq(report.reconciliation.status,"unknown")
end
case("K1 complete 35 paths full currencies provisional264 once privacy and immutable runtime",function(checkpoint)
    local env,s,f,runtime=knowledgeFixture()
    pause(checkpoint,"K4a report fixture ready")
    for _=1,2 do
        local r,text,summary
        trappedCapture(env,runtime,function()
            r=NS.KnowledgeCheck.Capture(env,runtime)
            eq(r.captureComplete,true); eq(r.stable,true); eq(r.captured,35); eq(r.discovered,35)
            eq(r.candidate.points,264); eq(r.shared.spent,264); eq(r.shared.quantity,0)
            eq(r.reconciliation.status,"provisional match"); eq(r.allRankCosts,"unverified")
            for ti,n in ipairs({9,4,9,13}) do
                local tab=r.tabs[ti]; eq(tab.captured,n); eq(tab.discovered,n); eq(tab.coverageComplete,true)
                eq(tab.paths[n].id,f.tabs[ti].ids[n],"late path included")
                local rows=tab.currencies.items; eq(#rows,({11,6,11,15})[ti]); eq(rows[#rows].value.traitCurrencyID.value,3902)
            end
            local p=firstPath(r)
            eq(p.node.currentRank.value,1); eq(p.node.maxRanks.value,31); eq(p.unlock.maxRanks.value,1); eq(p.spend.maxRanks.value,30)
            eq(p.candidate.points,0); eq(p.candidate.capacity,30); eq(p.node.nextEntry.rank.value,1,"not purchased")
            eq(r.tabs[1].paths[2].node.isAvailable.value,false); eq(r.tabs[1].paths[2].candidate.capacity,30)
            eq(p.unlock.entryCost.status,"empty"); eq(p.spend.entryCost.status,"empty"); eq(p.children.status,"observed")
            eq(r.tabs[4].paths[13].children.status,"empty")
        end)
        pause(checkpoint,"K4a capture checked")
        trappedCapture(env,runtime,function()
            local before=C.Copy(r); text,summary=NS.KnowledgeCheck.Format(r)
            assert(deepEqual(before,r),"Format is pure")
        end)
        pause(checkpoint,"K4a first format checked")
        trappedCapture(env,runtime,function()
            eq(text,NS.KnowledgeCheck.Format(r),"deterministic formatting")
            eq(summary.captureComplete,true); assert(#text<=262144)
            for _,secret in ipairs({"PRIVATE-GUID","PRIVATE-NAME","PRIVATE-REALM","PRIVATE-SAVED-DATA","PRIVATE-RUNTIME-REASON","PRIVATE-FORBIDDEN-PAYLOAD","|","\001"}) do assert(not text:find(secret,1,true),secret) end
            assert(text:find("NOT verified all-rank costs",1,true)); assert(text:find("compared ONCE",1,true))
            eq(r.build.interface.value,120105); eq(r.build.build,"70783"); eq(s.requests,0); eq(#s.timers,0)
        end)
        pause(checkpoint,"K1 protected capture and format")
    end
    trappedCapture(env,runtime,function()
        f.entries[f.unlock[f.tabs[1].root]].entryCost=nil
        incomplete(NS.KnowledgeCheck.Capture(env,runtime))
    end)
end)
case("K1 empty missing alternate multiple zero and variable current costs stay distinct",function(checkpoint)
    local changes={
        {run=function(f,id) f.entries[f.unlock[id]].entryCost=nil end,complete=false,word="unavailable"},
        {run=function(f,id) f.entries[f.spend[id]].entryCost={{ID=3902,amount=2}} end,complete=true,word="entry-specific"},
        {run=function(f,id) f.entries[f.unlock[id]].entryCost={{ID=3902,amount=0}} end,complete=true,word="zero amount"},
        {run=function(f,id) f.entries[f.spend[id]].entryCost={{ID=3902,amount=1},{ID=3900,amount=1}} end,complete=true,word="multiple costs"},
        {run=function(f,id) f.costs[id]={{ID=3902,amount=2}} end,complete=true,word="non-unit"},
        {run=function(f,id) f.costs[id]={{ID=3902,amount=0}} end,complete=true,word="zero"},
        {run=function(f,id) f.costs[id]={{ID=3902,amount=1},{ID=3900,amount=1}} end,complete=true,word="multiple"},
        {run=function(f,id) f.costs[id]={} end,complete=true,word="empty"},
        {run=function(f,id) f.costs[id]={{ID=3900,amount=1}} end,complete=true,word="alternate"},
    }
    for _,change in ipairs(changes) do
        pause(checkpoint,"K1 cost variant")
        local env,_,f,c=knowledgeFixture(); local id=f.tabs[1].root; change.run(f,id)
        local r=NS.KnowledgeCheck.Capture(env,c); eq(r.captureComplete,change.complete)
        assert(firstPath(r).currentUnitCost:find(change.word,1,true)); eq(r.allRankCosts,"unverified")
        if not change.complete then incomplete(r); eq(firstPath(r).unlock.entryCost.status,"nil") end
    end
end)
case("K1 currency reconciliation mismatch conflicts duplicates absent and path currency disagreement",function(checkpoint)
    for mode=1,7 do
        pause(checkpoint,"K1 currency variant")
        local env,_,f,c=knowledgeFixture(); local rows=f.currencies[f.tabs[4].id]
        if mode==1 then for _,tab in ipairs(f.tabs) do local rr=f.currencies[tab.id]; rr[#rr].spent=265 end
        elseif mode==2 then rows[#rows].spent=265
        elseif mode==3 then rows[#rows].quantity=1
        elseif mode==4 then rows[#rows+1]={traitCurrencyID=3902,quantity=0,spent=264}
        elseif mode==5 then rows[#rows]=nil
        elseif mode==6 then f.currency[f.tabs[4].ids[13]]=3900
        else rows[1].spent=999 end
        local r=NS.KnowledgeCheck.Capture(env,c)
        if mode==1 then eq(r.reconciliation.status,"provisional mismatch"); eq(r.candidate.points,264); eq(r.shared.spent,265)
        elseif mode==7 then eq(r.reconciliation.status,"provisional match"); eq(r.shared.spent,264)
        else eq(r.reconciliation.status,"unknown"); eq(r.shared,nil) end
        if mode==4 then incomplete(r) end
    end
end)
case("K1 candidate entry and rank guards never borrow next rank or assume unlock one",function(checkpoint)
    local changes={
        function(f,id) f.nodes[id].ranksIncreased=1 end,
        function(f,id) f.nodes[id].currentRank=2 end,
        function(f,id) f.entries[f.unlock[id]].maxRanks=2 end,
        function(f,id) f.nodes[id].entryIDs={f.unlock[id]} end,
        function(f,id) f.nodes[id].entryIDs[3]=999 end,
        function(f,id) f.spend[id]=f.unlock[id] end,
        function(f,id) f.nodes[id].maxRanks=32 end,
        function(f,id) f.nodes[id].currentRank=40; f.nodes[id].ranksPurchased=40 end,
        function(f,id) f.nodes[id].entryIDToRanksIncreased[f.spend[id]]=1 end,
        function(f,id) f.nodes[id].entryIDToRanksIncreased[999]=0 end,
        function(f,id) f.nodes[id].entryIDsWithCommittedRanks={999} end,
        function(f,id) f.nodes[id].nextEntry.entryID=999 end,
    }
    for _,change in ipairs(changes) do
        pause(checkpoint,"K1 rank variant")
        local env,_,f,c=knowledgeFixture(); change(f,f.tabs[1].root)
        local r=NS.KnowledgeCheck.Capture(env,c); eq(firstPath(r).candidate,nil); eq(r.candidate,nil); eq(r.reconciliation.status,"unknown")
    end
end)
case("K1 explicit staging false required at both context and protected read boundaries",function(checkpoint)
    for _,bad in ipairs({{v=nil},{v=true},{v="false"},{throws=true}}) do
        for _,atEnd in ipairs({false,true}) do
            pause(checkpoint,"K1 staging variant")
            local env,_,_,c=knowledgeFixture(); local count=0
            env.C_Traits.ConfigHasStagedChanges=function()
                count=count+1
                if not atEnd or count>=3 then if bad.throws then error("PRIVATE-STAGING-ERROR") end; return bad.v end
                return false
            end
            local r=NS.KnowledgeCheck.Capture(env,c); incomplete(r); eq(r.stable,false)
            local text=NS.KnowledgeCheck.Format(r); assert(not text:find("PRIVATE-STAGING-ERROR",1,true))
            local b=atEnd and r.finish or r.start
            eq(b.stagingRead.status,bad.throws and "error" or bad.v==nil and "nil" or type(bad.v)=="boolean" and "observed" or "invalid")
        end
    end
end)
case("K1 blocked own ready primary Inscription contexts and unavailable runtime tokens",function(checkpoint)
    for _,key in ipairs({"shown","ready","linked","guild","npc","changing","combat"}) do
        pause(checkpoint,"K1 context variant")
        local env,s,_,c=knowledgeFixture()
        s[key]=(key~="shown" and key~="ready")
        local verify=unchangedGraph(c); incomplete(NS.KnowledgeCheck.Capture(env,c)); verify()
    end
    local changes={
        function(e,s) e.C_TradeSkillUI.IsTradeSkillGuildMember=function() return true end end,
        function(e,s) s.info.isPrimaryProfession=false end,
        function(e,s) s.info.professionID=999 end,
        function(e,s) s.info.sourceCounter=nil end,
        function(e) e.GetProfessions=nil end,
        function(e) e.C_ProfSpecs.GetConfigIDForSkillLine=function() return nil end end,
        function(e) e.InCombatLockdown=nil end,
    }
    for _,change in ipairs(changes) do pause(checkpoint,"K1 unavailable context"); local e,s,_,c=knowledgeFixture(); change(e,s); incomplete(NS.KnowledgeCheck.Capture(e,c)) end
    local env,_,_,c=knowledgeFixture()
    incomplete(NS.KnowledgeCheck.Capture(env,nil)); c.revision=nil; incomplete(NS.KnowledgeCheck.Capture(env,c))
    c.revision=0; c.serial=0/0; incomplete(NS.KnowledgeCheck.Capture(env,c))
end)
case("K1 identity config source counter revision serial and closing races invalidate all aggregates",function(checkpoint)
    for mode=1,6 do
        pause(checkpoint,"K1 race variant")
        local env,s,_,c=knowledgeFixture(); local original=env.C_Traits.GetNodeCost; local once=false
        env.C_Traits.GetNodeCost=function(...)
            if not once then
                once=true
                if mode==1 then env.UnitGUID=function() return "Player-OTHER-PRIVATE" end
                elseif mode==2 then env.C_ProfSpecs.GetConfigIDForSkillLine=function() return 1002 end
                elseif mode==3 then s.info.sourceCounter=2
                elseif mode==4 then c.revision=c.revision+1
                elseif mode==5 then c.serial=c.serial+1
                else s.shown=false end
            end
            return original(...)
        end
        local r=NS.KnowledgeCheck.Capture(env,c); incomplete(r); eq(r.stable,false)
        for _,t in ipairs(r.tabs) do eq(t.candidate,nil) end
        assert(not NS.KnowledgeCheck.Format(r):find("Player-OTHER-PRIVATE",1,true))
    end
end)
case("K1 unavailable throwing APIs and unexpected failures return private incomplete evidence",function(checkpoint)
    local paths={
        {"C_ProfSpecs","GetSpecTabIDsForSkillLine"},{"C_ProfSpecs","GetTabInfo"},{"C_ProfSpecs","GetRootPathForTab"},
        {"C_ProfSpecs","GetChildrenForPath"},{"C_ProfSpecs","GetUnlockEntryForPath"},{"C_ProfSpecs","GetSpendEntryForPath"},
        {"C_ProfSpecs","GetSpendCurrencyForPath"},{"C_Traits","GetNodeInfo"},{"C_Traits","GetEntryInfo"},
        {"C_Traits","GetNodeCost"},{"C_Traits","GetTreeCurrencyInfo"},{"C_TradeSkillUI","GetChildProfessionInfo"},
    }
    for _,pathSpec in ipairs(paths) do
        for _,mode in ipairs({"missing","nil","error"}) do
            pause(checkpoint,"K1 protected API variant")
            local env,_,_,c=knowledgeFixture()
            env[pathSpec[1]][pathSpec[2]]=function()
                if mode=="error" then error("PRIVATE-ERROR-PAYLOAD |Hattack|h") end
                return nil
            end
            if mode=="missing" then env[pathSpec[1]][pathSpec[2]]=nil end
            trappedCapture(env,c,function()
                local r=NS.KnowledgeCheck.Capture(env,c); incomplete(r)
                assert(not NS.KnowledgeCheck.Format(r):find("PRIVATE-ERROR-PAYLOAD",1,true))
            end)
        end
    end
    local env,_,_,c=knowledgeFixture()
    env.C_ProfSpecs=setmetatable({},{__index=function() error("PRIVATE-UNEXPECTED") end})
    local r=NS.KnowledgeCheck.Capture(env,c); incomplete(r)
    assert(not NS.KnowledgeCheck.Format(r):find("PRIVATE-UNEXPECTED",1,true))
end)
case("K1 actual nonfinite malformed IDs ranks cost currency and entry maps fail closed",function(checkpoint)
    local values={{v=-1},{v=0.5},{v="1"},{v=false},{v=2147483648}}
    for _,sample in ipairs(nonfiniteSamples()) do values[#values+1]={v=sample.value} end
    for _,sample in ipairs(values) do
        for mode=1,8 do
            pause(checkpoint,"K1 malformed scalar variant")
            local env,_,f,c=knowledgeFixture(); local id=f.tabs[1].root; local v=sample.v
            if mode==1 then f.nodes[id].ranksPurchased=v
            elseif mode==2 then f.unlock[id]=v
            elseif mode==3 then f.nodes[id].maxRanks=v
            elseif mode==4 then f.costs[id][1].amount=v
            elseif mode==5 then f.currencies[f.tabs[1].id][1].quantity=v
            elseif mode==6 then f.nodes[id].entryIDToRanksIncreased[f.spend[id]]=v
            elseif mode==7 then f.nodes[id].nextEntry.rank=v
            else f.currency[id]=v end
            incomplete(NS.KnowledgeCheck.Capture(env,c))
        end
    end
end)
case("K1 dense typed arrays bounded key inspection sparse keyed metatable invalid duplicate",function(checkpoint)
    local changes={
        function(e,f,id) f.children[id]={[2]=id+1} end,
        function(e,f,id) f.children[id]={named=id+1} end,
        function(e,f,id) f.children[id]={id+1,id+1} end,
        function(e,f,id) f.children[id]=setmetatable({},{__index=function() error("must not index") end}) end,
        function(e,f,id) f.nodes[id].entryIDs={f.unlock[id],"bad"} end,
        function(e,f,id) f.nodes[id].entryIDsWithCommittedRanks={[2]=f.unlock[id]} end,
        function(e,f,id) f.nodes[id].entryIDToRanksIncreased={named=1} end,
        function(e,f,id) f.currencies[f.tabs[1].id]={[2]={traitCurrencyID=3902,quantity=0,spent=264}} end,
        function(e,f,id) f.currencies[f.tabs[1].id][1]=false end,
        function(e,f,id) f.costs[id]={named={ID=3902,amount=1}} end,
        function(e,f,id) f.entries[f.unlock[id]].entryCost=false end,
        function(e,f,id) e.C_ProfSpecs.GetSpecTabIDsForSkillLine=function() return {1101,1101} end end,
    }
    for _,change in ipairs(changes) do pause(checkpoint,"K1 list variant"); local e,_,f,c=knowledgeFixture(); change(e,f,f.tabs[1].root); incomplete(NS.KnowledgeCheck.Capture(e,c)) end
end)
case("K1 every fixed collection limit is explicit and inspection stops at limit plus one",function(checkpoint)
    for mode=1,7 do
        pause(checkpoint,"K1 bound variant")
        local env,_,f,c=knowledgeFixture(); local id=f.tabs[1].root; local data={}; local limit
        if mode==1 then limit=8; for i=1,100 do data[i]=1100+i end; env.C_ProfSpecs.GetSpecTabIDsForSkillLine=function() return data end
        elseif mode==2 then limit=16; for i=1,100 do data[i]=id+i end; f.children[id]=data
        elseif mode==3 or mode==4 then limit=32; for i=1,100 do data[i]=id+i end; f.nodes[id][mode==3 and "entryIDs" or "entryIDsWithCommittedRanks"]=data
        elseif mode==5 then limit=64; for i=1,100 do data[i]={traitCurrencyID=5000+i,quantity=0,spent=0} end; f.currencies[f.tabs[1].id]=data
        elseif mode==6 then limit=16; for i=1,100 do data[i]={ID=5000+i,amount=1} end; f.costs[id]=data
        else limit=32; for i=1,100 do data[5000+i]=0 end; f.nodes[id].entryIDToRanksIncreased=data end
        local r=NS.KnowledgeCheck.Capture(env,c); incomplete(r)
        local p=firstPath(r)
        local bounded=mode==1 and r.tabIDs or mode==2 and p.children or mode==3 and p.node.entryIDs or
            mode==4 and p.node.entryIDsWithCommittedRanks or mode==5 and r.tabs[1].currencies or mode==6 and p.costs or p.node.entryIDToRanksIncreased
        eq(bounded.inspected,limit+1); eq(bounded.complete,false); assert(#bounded.items<=limit)
        if bounded.flags then eq(bounded.flags.truncated,true) else eq(bounded.status,"truncated") end
    end
    local env,_,f,c=knowledgeFixture({65})
    pause(checkpoint,"K1 path bound")
    local r=NS.KnowledgeCheck.Capture(env,c); incomplete(r); eq(r.tabs[1].captured,64); eq(r.tabs[1].discovered,65); eq(r.tabs[1].flags.pathLimit,true)
    local e,_,ff,cc=knowledgeFixture(); local entry=ff.entries[ff.unlock[ff.tabs[1].root]]; entry.entryCost={}
    for i=1,17 do entry.entryCost[i]={ID=5000+i,amount=0} end
    local rr=NS.KnowledgeCheck.Capture(e,cc); incomplete(rr); eq(firstPath(rr).unlock.entryCost.inspected,17)
    pause(checkpoint,"K1 entry bound")
end)
case("K1 cycles duplicate children and shared tab ownership visit every discovered ID at most once",function(checkpoint)
    for mode=1,3 do
        pause(checkpoint,"K1 graph variant")
        local env,_,f,c=knowledgeFixture(); local root=f.tabs[1].root
        if mode==1 then f.children[root]={root}
        elseif mode==2 then f.children[root]={root+1,root+1}
        else f.children[f.tabs[2].root]={root} end
        local original=env.C_Traits.GetNodeInfo; local seen={}
        env.C_Traits.GetNodeInfo=function(config,id) assert(not seen[id],"query each path once globally"); seen[id]=true; return original(config,id) end
        local r=NS.KnowledgeCheck.Capture(env,c); incomplete(r)
        eq(mode==3 and r.tabs[2].flags.sharedOwnership or r.tabs[1].flags.cycleOrDuplicate,true)
    end
end)
-- Outside protected helpers/namespace overrides: each returned job unit gets its
-- own existing runner checkpoint. Completion of work is not data completeness.
local function steppedJob(job,checkpoint)
    while job.status=="running" do
        eq(job.report,nil); eq(job.text,nil); eq(job.summary,nil)
        job:Step()
        assert(job.pathUnits<=1,"one complete path per Step")
        assert(job.lineAttempts<=8,"eight attempts including clipped no-ops")
        pause(checkpoint,"K3b "..job.phase.." "..job.label)
    end
    eq(job.status,"complete"); eq(job.completed,true); eq(job.worker,nil)
    return job
end
case("K1 byte and line budgets retain reserved end summary never clipped success and pure format",function(checkpoint)
    local env,_,_,c=knowledgeFixture({64,64,64,64,64,64,64,64},checkpoint)
    local r=steppedJob(NS.KnowledgeCheck.NewCaptureJob(env,c),checkpoint).report; incomplete(r); eq(r.outputTruncated,true)
    eq(#r.tabs,8); eq(r.captured,512); eq(r.discovered,512)
    for _,tab in ipairs(r.tabs) do eq(tab.captured,64); eq(tab.discovered,64); eq(#tab.paths,64) end
    pause(checkpoint,"K1 maximum capture")
    local formatted=steppedJob(NS.KnowledgeCheck.NewFormatJob(r),checkpoint)
    local text,summary=formatted.text,formatted.summary
    pause(checkpoint,"K1 byte budget format")
    eq(summary.outputTruncated,true); eq(summary.captureComplete,false); eq(summary.reconciliation.status,"unknown")
    assert(#text<=262144); local _,lines=text:gsub("\n",""); assert(lines+1<=4096)
    assert(text:find("version1 END",1,true)); assert(text:find("END SUMMARY version1",1,true)); assert(not text:find("provisional match",1,true))
    for _,secret in ipairs({"PRIVATE-GUID","PRIVATE-NAME","PRIVATE-REALM","PRIVATE-SAVED-DATA","PRIVATE-RUNTIME-REASON","|","\001"}) do assert(not text:find(secret,1,true),secret) end
    -- Minimal records isolate the line budget from the byte budget.
    local report={tabs={{paths={},currencies={items={},complete=true}}},captureComplete=true,stable=true,
        reconciliation={status="provisional match"},captured=600,discovered=600}
    for i=1,600 do
        report.tabs[1].paths[i]={id=i}
        if i%8==0 then pause(checkpoint,"K3b minimal record setup") end
    end
    local verify=unchangedGraph(report)
    formatted=steppedJob(NS.KnowledgeCheck.NewFormatJob(report),checkpoint)
    text,summary=formatted.text,formatted.summary; verify()
    pause(checkpoint,"K1 line budget format")
    eq(summary.outputTruncated,true); eq(summary.captureComplete,false); assert(#text<=262144)
    local _,n=text:gsub("\n",""); assert(n+1<=4096); assert(n>4000,"line bound actually exercised")
    assert(not text:find("provisional match",1,true))
end)
case("K1 command bypasses Login real DB and dashboard even when invalid or runtime missing",function(checkpoint)
    local env,_,f,c=knowledgeFixture(); local chat={}
    env.DEFAULT_CHAT_FRAME={AddMessage=function(_,line) chat[#chat+1]=line end}
    local commands=NS.Commands.New(env); commands.collector=c
    commands.Login=function() error("knowledgecheck must bypass Login") end
    commands.dashboard={Refresh=function() error("no refresh") end,Toggle=function() error("no dashboard") end}
    pause(checkpoint,"K3e command setup")
    trappedCapture(env,c,function()
        local report,text,why=commands:Run("knowledgecheck")
        eq(report.captureComplete,true); eq(commands.knowledgeText,text); assert(why:find("frames missing",1,true))
    end)
    pause(checkpoint,"K3e valid command complete")
    trappedCapture(env,c,function()
        f.costs[f.tabs[1].root]=nil
        incomplete(commands:Run("knowledgecheck"))
    end)
    pause(checkpoint,"K3e invalid command complete")
    local fresh=NS.Commands.New(env); fresh.Login=commands.Login
    local before=unchangedGraph(env.CraftArmyDB)
    incomplete(fresh:Run("knowledgecheck")); before(); eq(fresh.collector,nil); assert(#chat<=6,"brief messages only")
    pause(checkpoint,"K3e missing runtime complete")
    local e=fixtureAPI(); local help={}; e.DEFAULT_CHAT_FRAME={AddMessage=function(_,line) help[#help+1]=line end}
    NS.Commands.New(e):Run("help"); assert(table.concat(help):find("/ca knowledgecheck",1,true))
end)
case("K1 strict native copy window repeat close Escape immutable text and UI failure",function()
    local env,_,_,c=knowledgeFixture(); mockWidgets(env)
    eq(#env.fixtureWidgets,2,"no copy frame at module/factory load")
    local text=NS.KnowledgeCheck.Format(NS.KnowledgeCheck.Capture(env,c))
    local w,why=NS.KnowledgeCheck.Show(env,text); eq(why,nil); assert(w)
    eq(w.edit.multiline,true); eq(w.edit.fontObject,"ChatFontNormal"); eq(w.edit.maxLetters,0)
    eq(w.scroll.scrollChild,w.edit); eq(w.edit.width,720); eq(w.scroll.height,450)
    assert(w.edit.height>w.scroll.height,"tracked multiline content exceeds scroll viewport")
    eq(w.edit.focused,true); eq(w.edit.selection[1],0); eq(w.edit.selection[2],#text)
    eq(w.edit:GetText(),text); w.edit:SetText("tampered |Hsecret|h"); eq(w.edit:GetText(),text,"original text restored")
    w.close.scripts.OnClick(); eq(w.frame.shown,false); eq(w.edit.focused,false)
    local count=#env.fixtureWidgets
    eq(NS.KnowledgeCheck.Show(env,"replacement |Hhostile|h",w),w); eq(#env.fixtureWidgets,count)
    eq(w.edit:GetText(),"replacement  Hhostile h"); eq(w.frame.shown,true); eq(w.edit.focused,true)
    w.edit.scripts.OnEscapePressed(); eq(w.frame.shown,false); eq(w.edit.focused,false)
    w.edit:SetFocus(); w.frame.scripts.OnHide(); eq(w.edit.focused,false,"native frame close also clears focus")
    env.CreateFrame=function() error("PRIVATE-UI-ERROR") end
    local window,reason=NS.KnowledgeCheck.Show(env,text); eq(window,nil); assert(reason:find("capability failure",1,true)); assert(not reason:find("PRIVATE-UI-ERROR",1,true))
end)
case("K1 combat command does no capture UI focus timer or deferred automatic work",function(checkpoint)
    local env,s,_,c=knowledgeFixture(); mockWidgets(env); local chat={}
    env.DEFAULT_CHAT_FRAME={AddMessage=function(_,line) chat[#chat+1]=line end}
    local commands=NS.Commands.New(env); commands.collector=c
    local before=unchangedGraph(c); local count=#env.fixtureWidgets; s.combat=true
    eq(commands:Run("knowledgecheck"),nil); before(); eq(#env.fixtureWidgets,count); eq(#s.timers,0); eq(s.requests,0)
    eq(commands.knowledgeWindow,nil); eq(commands.knowledgeText,nil); eq(c.deferred,nil); eq(c.scheduled,nil)
    eq(NS.KnowledgeCheck.Show(env,"test"),nil); eq(#env.fixtureWidgets,count)
    pause(checkpoint,"K3c first combat checks")
    s.combat=false; eq(#env.fixtureWidgets,count,"leaving combat does not auto-open")
    pause(checkpoint,"K3c before first command")
    local r=commands:Run("knowledgecheck"); eq(r.captureComplete,true); assert(commands.knowledgeWindow)
    local window=commands.knowledgeWindow; local text=commands.knowledgeText; count=#env.fixtureWidgets
    pause(checkpoint,"K3c first command complete")
    local second=commands:Run("knowledgecheck"); eq(second.captureComplete,true); eq(commands.knowledgeWindow,window)
    eq(commands.knowledgeText,text); eq(window.edit:GetText(),text); eq(#env.fixtureWidgets,count,"repeat reuses copy widgets")
    pause(checkpoint,"K3c repeat command complete")
    s.combat=true
    eq(commands:Run("knowledgecheck"),nil); eq(commands.knowledgeWindow,window); eq(commands.knowledgeText,text)
    eq(window.edit.focused,true,"combat command makes no focus call"); eq(#env.fixtureWidgets,count); eq(#s.timers,0)
end)

-- K2 fixtures are separate additions. The complete K1 suite above stays unchanged.
-- Numeric IDs/topology/currencies below are sanitized native evidence, NEVER seeds
-- or defaults for production. Active/committed states model the adopted guards.
local function k2Fixture()
    local env,state=fixtureAPI()
    local f={tabs={},nodes={},entries={},children={},costs={},currencies={},unlock={},spend={},currency={}}
    local data={
        {1122,106192,{106191,106187},1,31,130942,130933,30,3902},
        {1122,106191,{106190,106189,106188},1,31,130941,130925,30,3902},
        {1122,106187,{106186,106185,106184},0,31,130937,130893,30,3912},
        {1122,106190,{},0,31,130940,130917,30,3911},
        {1122,106189,{},1,31,130939,130909,30,3902},
        {1122,106188,{},0,31,130938,130901,30,3911},
        {1122,106186,{},0,31,130936,130885,30,3907},
        {1122,106185,{},0,31,130935,130877,30,3907},
        {1122,106184,{},0,31,130934,130869,30,3907},
        {1124,106280,{106279,106278,106277},11,11,131041,131037,10,3902},
        {1124,106279,{},1,21,131040,131029,20,3902},
        {1124,106278,{},21,21,131039,131021,20,3902},
        {1124,106277,{},21,21,131038,131013,20,3902},
        {1182,109660,{109659,109655},31,31,135911,135902,30,3902},
        {1182,109659,{109658,109657,109656},31,31,135910,135894,30,3902},
        {1182,109655,{109654,109653,109652},31,31,135906,135862,30,3902},
        {1182,109658,{},31,31,135909,135886,30,3902},
        {1182,109657,{},1,31,135908,135878,30,3902},
        {1182,109656,{},5,31,135907,135870,30,3902},
        {1182,109654,{},31,31,135905,135854,30,3902},
        {1182,109653,{},31,31,135904,135846,30,3902},
        {1182,109652,{},31,31,135903,135838,30,3902},
        {1125,106358,{106357,106354,106351,106348},1,21,131132,131119,20,3902},
        {1125,106357,{106356,106355},0,21,131131,131113,20,3936},
        {1125,106354,{106353,106352},0,21,131128,131095,20,3936},
        {1125,106351,{106350,106349},0,21,131125,131077,20,3936},
        {1125,106348,{106347,106346},0,21,131122,131059,20,3936},
        {1125,106356,{},0,21,131130,131107,20,3935},
        {1125,106355,{},0,21,131129,131101,20,3935},
        {1125,106353,{},0,21,131127,131089,20,3932},
        {1125,106352,{},0,21,131126,131083,20,3932},
        {1125,106350,{},0,21,131124,131071,20,3929},
        {1125,106349,{},0,21,131123,131065,20,3929},
        {1125,106347,{},0,21,131121,131053,20,3926},
        {1125,106346,{},0,21,131120,131047,20,3926},
    }
    local tabs={}
    for _,row in ipairs(data) do
        local ti,id,ch,rp,max,un,sp,cap,cost=unpack(row)
        if not tabs[ti] then
            tabs[ti]={id=ti,root=id}; f.tabs[#f.tabs+1]=tabs[ti]
        end
        f.children[id]=ch; f.unlock[id]=un; f.spend[id]=sp; f.currency[id]=3902
        f.entries[un]={type=9,maxRanks=1,entryCost={}}
        f.entries[sp]={type=7,maxRanks=cap,entryCost={}}
        f.costs[id]={{ID=cost,amount=1}}
        local active={entryID=rp>1 and sp or un,rank=rp>1 and rp-1 or rp}
        local nextEntry
        if rp<max then nextEntry={entryID=rp==0 and un or sp,rank=rp==0 and 1 or rp==1 and 1 or rp+1} end
        local committed=rp==0 and {} or rp==max and {sp} or rp>1 and {un,sp} or {un}
        f.nodes[id]={ID=id,type=1,flags=0,isAvailable=true,ranksPurchased=rp,currentRank=rp,activeRank=rp,
            ranksIncreased=0,maxRanks=max,totalMaxRanks=max,activeEntry=active,nextEntry=nextEntry,
            entryIDs={un,sp},entryIDsWithCommittedRanks=committed,entryIDToRanksIncreased={[un]=0,[sp]=0}}
    end
    local currencyData={
        [1122]={{3902,0,264},{3900,0,4},{3912,0,1},{3911,0,1},{3910,0,0},{3909,0,0},{3908,0,0},{3907,0,0},{3906,0,0},{3905,0,0},{3904,0,0}},
        [1124]={{3902,0,264},{3900,0,4},{3923,0,3},{3922,0,0},{3921,0,0},{3920,0,0}},
        [1182]={{3902,0,264},{3900,0,4},{4204,0,2},{4203,0,3},{4202,0,0},{4201,0,0},{4200,0,0},{4199,0,3},{4198,0,0},{4197,0,0},{4196,0,0}},
        [1125]={{3902,0,264},{3900,0,4},{3936,1,0},{3935,0,0},{3934,0,0},{3933,0,0},{3932,0,0},{3931,0,0},{3930,0,0},{3929,0,0},{3928,0,0},{3927,0,0},{3926,0,0},{3925,0,0},{3924,0,0}},
    }
    for id,rows in pairs(currencyData) do
        f.currencies[id]={}
        for i,row in ipairs(rows) do f.currencies[id][i]={traitCurrencyID=row[1],quantity=row[2],spent=row[3]} end
    end
    local p,t=env.C_ProfSpecs,env.C_Traits
    p.GetSpecTabIDsForSkillLine=function() local out={}; for i,tab in ipairs(f.tabs) do out[i]=tab.id end; return out end
    p.GetTabInfo=function(id) return {name="Native fixture "..id} end
    p.GetRootPathForTab=function(id) return tabs[id] and tabs[id].root end
    p.GetChildrenForPath=function(id) return f.children[id] end
    p.GetUnlockEntryForPath=function(id) return f.unlock[id] end
    p.GetSpendEntryForPath=function(id) return f.spend[id] end
    p.GetSpendCurrencyForPath=function(id) return f.currency[id] end
    t.GetNodeInfo=function(_,id) return f.nodes[id] end
    t.GetEntryInfo=function(_,id) return f.entries[id] end
    t.GetNodeCost=function(_,id) return f.costs[id] end
    t.GetTreeCurrencyInfo=function(_,id,exclude) eq(exclude,true); return f.currencies[id] end
    local function forbidden() error("K2 forbidden gameplay") end
    for _,key in ipairs({"PurchaseRank","RefundRank","CommitConfig","SetSelection","GetTreeNodes"}) do t[key]=forbidden end
    env.CraftRecipe=forbidden; env.EquipItemByName=forbidden
    return env,state,f,NS.Collectors.New(env,C.Open(nil))
end
local function k2Raw(c)
    local ctx=assert(c:Context()); local raw=c:Knowledge(ctx)
    raw.stagedEnd=false; raw.stable=true
    return raw
end
local function k2Fail(raw,context)
    local result=K.Evaluate(raw)
    eq(result.complete,false,context); eq(result.sharedSpent,nil,context)
    for _,tree in ipairs(result.trees) do
        eq(tree.complete,false,context); eq(tree.purchased,nil,context); eq(tree.capacity,nil,context)
    end
end
local function k2Observations(raw,result,at)
    local obs={knowledgeRaw=C.Observation("observed",raw,at,"K2 fixture"),
        knowledgeIndex=C.Observation("observed",{},at,"K2 fixture"),unspent=C.Observation("observed",0,at,"K2 fixture")}
    for i,tree in ipairs(result.trees) do
        obs.knowledgeIndex.value[i]={id=tree.id,name=tree.name,root=tree.root}
        obs["tree:"..tree.id]=C.Observation("observed",tree,at,"K2 fixture")
    end
    return obs
end
case("K2 native35 real topology all18 unlock tokens and17 opened paths reconcile264 once",function()
    local _,_,_,c=k2Fixture(); local raw=k2Raw(c); local r=K.Evaluate(raw)
    eq(r.complete,true); eq(r.sharedSpent,264); eq(raw.policy,"native-rank-reconciled-v1")
    eq(raw.identity.expansionID,11); eq(raw.sourceCounter,1); eq(raw.nativeComplete,true)
    eq(C.ValidPayload("knowledgeRaw",raw,"observed"),true)
    local opened,locked,entries,rawRanks=0,0,0,0
    for i,t in ipairs(r.trees) do
        eq(t.purchased,({0,50,214,0})[i]); eq(t.capacity,({270,70,270,260})[i])
        eq(t.coverage.captured,({9,4,9,13})[i]); eq(#t.currencies,({11,6,11,15})[i])
        eq(t.accountingPolicy,raw.policy); eq(t.accountingEvidence.totalPurchased,264)
        eq(C.ValidPayload("tree:"..t.id,t,"observed"),true)
        for _,p in ipairs(t.paths) do
            eq(p.costRule,"unknown"); eq(p.node.isAvailable,true); rawRanks=rawRanks+p.node.ranksPurchased
            entries=entries+2; eq(#p.unlock.entryCost,0); eq(#p.spend.entryCost,0)
            if p.locked then locked=locked+1; assert(p.costs[1].ID~=p.spendCurrencyID)
            else opened=opened+1; eq(p.costs[1].ID,3902) end
            if p.id==109656 then eq(p.purchased,4); eq(p.node.activeEntry.rank,4); eq(p.node.nextEntry.rank,6) end
            if p.node.ranksPurchased==p.node.maxRanks then eq(#p.node.entryIDsWithCommittedRanks,1); eq(p.node.nextEntry,nil) end
        end
    end
    eq(opened,17); eq(locked,18); eq(entries,70); eq(rawRanks,281)
end)
case("K2 dynamic balances ranks caps currency IDs ordering and mixed zero unlock spend-ready",function()
    local _,_,_,c=k2Fixture(); local raw=k2Raw(c)
    local p=raw.tabs[1].paths[106192]
    p.unlock.maxRanks=0; p.node.maxRanks=32; p.node.totalMaxRanks=32; p.spend.maxRanks=32
    p.node.ranksPurchased=0; p.node.currentRank=0; p.node.activeRank=0
    p.node.activeEntry.rank=0; p.node.entryIDsWithCommittedRanks={}
    p.node.nextEntry={entryID=p.spendEntryID,rank=1}
    local other=raw.tabs[1].paths[106189]
    other.node.ranksPurchased=3; other.node.currentRank=3; other.node.activeRank=3
    other.node.activeEntry={entryID=other.spendEntryID,rank=2}
    other.node.entryIDsWithCommittedRanks={other.spendEntryID}
    for _,tab in ipairs(raw.tabs) do
        for _,pathValue in pairs(tab.paths) do
            pathValue.spendCurrencyID=3902
            if pathValue.costs[1].ID==3902 then pathValue.costs[1].ID=3902 end
        end
        for _,row in ipairs(tab.currencies) do
            if row.traitCurrencyID==3902 then row.traitCurrencyID=3902; row.spent=266; row.quantity=7 end
            if row.traitCurrencyID==3900 then row.spent=999 end
        end
        local shared=table.remove(tab.currencies,1); tab.currencies[#tab.currencies+1]=shared
    end
    raw.tabs[1],raw.tabs[4]=raw.tabs[4],raw.tabs[1]
    local r=K.Evaluate(raw); eq(r.complete,true); eq(r.sharedSpent,266)
    eq(r.trees[4].purchased,2); eq(r.trees[4].capacity,272)
    eq(r.trees[4].accountingEvidence.currencyID,3902); eq(r.trees[4].accountingEvidence.quantity,7)
    eq(K.NativePathPoints(p,raw.tabs[4]).purchased,0)
    local observed=k2Observations(raw,r,10); local db=C.Open(nil)
    assert(C.Apply(db,character,identity,observed,10,"fixture")); eq(C.Open(db),db)
end)
case("K2 every node rank type flag cap availability entry list and map guard fails all trees",function(checkpoint)
    local _,_,_,c=k2Fixture(); local base=k2Raw(c)
    local changes={
        function(p) p.metadataComplete=false end,function(p) p.childrenComplete=false end,
        function(p) p.costRule="verified-unit-spend" end,function(p) p.node.ID=999 end,
        function(p) p.node.type=2 end,function(p) p.node.flags=1 end,function(p) p.node.isAvailable=nil end,
        function(p) p.node.isAvailable=0 end,function(p) p.node.totalMaxRanks=32 end,
        function(p) p.node.activeRank=0 end,function(p) p.node.currentRank=0 end,
        function(p) p.node.ranksPurchased=-1 end,function(p) p.node.ranksPurchased=32 end,
        function(p) p.node.ranksIncreased=1 end,function(p) p.node.maxRanks=30 end,
        function(p) p.unlock.type=7 end,function(p) p.unlock.maxRanks=2 end,
        function(p) p.spend.type=9 end,function(p) p.spend.maxRanks=0 end,
        function(p) p.spendEntryID=p.unlockEntryID end,function(p) p.unlockEntryID=nil end,
        function(p) p.node.entryIDs={} end,function(p) p.node.entryIDs[3]=999 end,
        function(p) p.node.entryIDs[2]=p.unlockEntryID end,
        function(p) p.node.entryIDToRanksIncreased={} end,
        function(p) p.node.entryIDToRanksIncreased[p.unlockEntryID]=1 end,
        function(p) p.node.entryIDToRanksIncreased[999]=0 end,
        function(p) p.node.entryIDsWithCommittedRanks={} end,
        function(p) p.node.entryIDsWithCommittedRanks={999} end,
        function(p) p.node.entryIDsWithCommittedRanks={p.unlockEntryID,p.unlockEntryID} end,
    }
    for i,change in ipairs(changes) do
        pause(checkpoint,"K2 node guard "..i)
        local raw=C.Copy(base); change(raw.tabs[1].paths[106192]); k2Fail(raw,"node guard "..i)
    end
    local raw=C.Copy(base); raw.tabs[1].paths[106192].node.isAvailable=false
    eq(K.Evaluate(raw).complete,true,"availability boolean is not lock state")
end)
case("K2 active next committed locked and zero unlock state plus current and entry costs",function(checkpoint)
    local _,_,_,c=k2Fixture(); local base=k2Raw(c)
    local changes={
        {106192,function(p) p.node.activeEntry=nil end},
        {106192,function(p) p.node.activeEntry.entryID=p.spendEntryID end},
        {106192,function(p) p.node.activeEntry.rank=0 end},
        {106192,function(p) p.node.nextEntry=nil end},
        {106192,function(p) p.node.nextEntry.entryID=p.unlockEntryID end},
        {106192,function(p) p.node.nextEntry.rank=0 end},
        {106192,function(p) p.node.nextEntry.rank=2147483648 end},
        {106192,function(p) p.node.nextEntry.entryID=999 end},
        {106192,function(p) p.costs={} end},
        {106192,function(p) p.costs[1].amount=0 end},
        {106192,function(p) p.costs[1].amount=2 end},
        {106192,function(p) p.costs[1].ID=3900 end},
        {106192,function(p) p.costs[2]={ID=3900,amount=1} end},
        {106192,function(p) p.unlock.entryCostComplete=false end},
        {106192,function(p) p.spend.entryCost=nil end},
        {106192,function(p) p.unlock.entryCost={{ID=3902,amount=1}} end},
        {106192,function(p) p.spend.entryCost={{ID=3902,amount=1}} end},
        {106187,function(p) p.node.activeEntry.rank=1 end},
        {106187,function(p) p.node.activeEntry.entryID=p.spendEntryID end},
        {106187,function(p) p.node.nextEntry.entryID=p.spendEntryID end},
        {106187,function(p) p.node.entryIDsWithCommittedRanks={p.unlockEntryID} end},
        {106187,function(p) p.costs[1].ID=3902 end},
        {106187,function(p) p.costs[1].ID=999 end},
    }
    for i,item in ipairs(changes) do
        pause(checkpoint,"K2 state guard "..i)
        local raw=C.Copy(base); item[2](raw.tabs[1].paths[item[1]]); k2Fail(raw,"state/cost "..i)
    end
    for _,change in ipairs({
        function(p) p.node.activeEntry.rank=5 end,
        function(p) p.node.activeEntry.entryID=p.unlockEntryID end,
        function(p) p.node.entryIDsWithCommittedRanks={p.unlockEntryID} end,
    }) do pause(checkpoint,"K2 partial active variant"); local raw=C.Copy(base); change(raw.tabs[3].paths[109656]); k2Fail(raw,"partial active") end
    local raw=C.Copy(base); raw.tabs[2].paths[106280].node.nextEntry={entryID=131037,rank=10}; k2Fail(raw,"max next")
end)
case("K2 complete64 currencies sharedlast beyond8 and all shared mismatches excluded once",function(checkpoint)
    local _,_,_,c=k2Fixture(); local base=k2Raw(c)
    for _,tab in ipairs(base.tabs) do
        local row=table.remove(tab.currencies,1)
        while #tab.currencies<63 do tab.currencies[#tab.currencies+1]={traitCurrencyID=9000+#tab.currencies,quantity=0,spent=0} end
        tab.currencies[64]=row
    end
    eq(K.Evaluate(base).complete,true); eq(#base.tabs[4].currencies,64)
    local changes={
        function(s) s.tabs[1].currenciesComplete=false end,
        function(s) s.tabs[1].currencies[64].spent=265 end,
        function(s) s.tabs[1].currencies[64].quantity=1 end,
        function(s) for _,t in ipairs(s.tabs) do t.currencies[64].spent=265 end end,
        function(s) s.tabs[1].currencies[64]=nil end,
        function(s) s.tabs[1].currencies[63]=C.Copy(s.tabs[1].currencies[64]) end,
        function(s) s.tabs[1].currencies[65]={traitCurrencyID=99999,quantity=0,spent=0} end,
        function(s) s.tabs[1].paths[106192].spendCurrencyID=3900 end,
        function(s) s.tabs[1].currencies[64].spent=nil end,
    }
    for i,change in ipairs(changes) do pause(checkpoint,"K2 shared guard "..i); local raw=C.Copy(base); change(raw); k2Fail(raw,"shared guard "..i) end
    base.shared={applicable=true,spent=999}; eq(K.Evaluate(base).sharedSpent,264,"ignore K1/raw supplied match authority")
end)
case("K2 unsupported policy scope source config and boundary flags cannot fall through legacy",function(checkpoint)
    local _,_,_,c=k2Fixture(); local base=k2Raw(c)
    for _,value in ipairs({false,true,1,"unknown","verified-unit-spend"}) do
        pause(checkpoint,"K2 policy variant")
        local raw=C.Copy(base); raw.policy=value; k2Fail(raw,"policy")
        eq(C.ValidPayload("knowledgeRaw",raw,"observed"),false)
    end
    local changes={
        function(s) s.identity.skillLineID=999 end,function(s) s.identity.parentID=999 end,
        function(s) s.identity.profession=999 end,function(s) s.identity.expansionID=10 end,
        function(s) s.configID=nil end,function(s) s.configID=0 end,function(s) s.configID=2147483648 end,
        function(s) s.sourceCounter=nil end,function(s) s.sourceCounter=-1 end,
        function(s) s.nativeComplete=false end,function(s) s.tabsComplete=false end,function(s) s.stable=false end,
        function(s) s.stagedStart=nil end,function(s) s.stagedStart=true end,
        function(s) s.stagedEnd=nil end,function(s) s.stagedEnd=true end,
    }
    for i,change in ipairs(changes) do pause(checkpoint,"K2 boundary "..i); local raw=C.Copy(base); change(raw); k2Fail(raw,"boundary "..i) end
    local legacy=scan(); legacy.tabs[1].paths[72].children={73}
    eq(K.Evaluate(legacy).complete,true); legacy.policy=false; k2Fail(legacy,"no policy bypass")
end)
case("K2 graph coverage cycles shared paths duplicate tabs unreachable and all list bounds",function(checkpoint)
    local _,_,_,c=k2Fixture(); local base=k2Raw(c)
    local changes={
        function(s) s.tabs[1].coverageComplete=false end,
        function(s) s.tabs[1].paths[106192].children={106192} end,
        function(s) s.tabs[1].paths[106192].children={106191,106191} end,
        function(s) s.tabs[1].paths[106192].children={999} end,
        function(s) s.tabs[1].paths[999]=C.Copy(s.tabs[1].paths[106192]) end,
        function(s) s.tabs[1].paths[106191]=nil end,
        function(s) s.tabs[2].root=106192; s.tabs[2].paths[106192]=C.Copy(s.tabs[1].paths[106192]) end,
        function(s) s.tabs[2].id=s.tabs[1].id end,
        function(s) for i=5,9 do s.tabs[i]=C.Copy(s.tabs[1]) end end,
        function(s) s.tabs.extra={} end,
        function(s) s.tabs[2]=nil end,
        function(s) s.tabs[1].paths[106192].children[17]=999 end,
        function(s) s.tabs[1].paths[106192].node.entryIDs[33]=999 end,
        function(s) s.tabs[1].paths[106192].costs[17]={ID=999,amount=1} end,
        function(s) s.tabs[1].paths[106192].node.entryIDToRanksIncreased[999]=0 end,
    }
    for i,change in ipairs(changes) do pause(checkpoint,"K2 graph/list "..i); local raw=C.Copy(base); change(raw); k2Fail(raw,"graph/list "..i) end
    for _,where in ipairs({"children","costs"}) do
        local raw=C.Copy(base); setmetatable(raw.tabs[1].paths[106192][where],{}); k2Fail(raw,"metatable "..where)
    end
    local raw=C.Copy(base); setmetatable(raw.tabs,{}); k2Fail(raw,"metatable tabs")
end)
case("K2 raw projection omits malformed fields with false flags and always typed Core input",function(checkpoint)
    local changes={
        function(f) f.nodes[106192].ID=false end,
        function(f) f.nodes[106192].ID=999 end,
        function(f) f.nodes[106192].type="1" end,
        function(f) f.nodes[106192].flags=-1 end,
        function(f) f.nodes[106192].ranksPurchased=nil end,
        function(f) f.nodes[106192].isAvailable=1 end,
        function(f) f.nodes[106192].activeEntry={entryID=130942,rank="1"} end,
        function(f) f.nodes[106192].nextEntry=false end,
        function(f) f.entries[130942].maxRanks=-1 end,
        function(f) f.entries[130933].type=false end,
        function(f) f.entries[130933].entryCost=nil end,
        function(f) f.costs[106192]={{ID=3902,amount=false}} end,
        function(f) f.currency[106192]=false end,
        function(f) f.unlock[106192]=2147483648 end,
        function(f) f.spend[106192]=0 end,
        function(f) f.nodes[106192].entryIDs={130942,130942} end,
        function(f) f.nodes[106192].entryIDToRanksIncreased={[130942]=0,[130933]=false} end,
        function(f) f.currencies[1122][1].quantity=-1 end,
    }
    for i,change in ipairs(changes) do
        pause(checkpoint,"K2 projection variant "..i)
        local _,_,f,c=k2Fixture(); change(f); local raw=k2Raw(c)
        eq(raw.nativeComplete,false,"project failure "..i); k2Fail(raw,"project failure "..i)
        eq(C.ValidPayload("knowledgeRaw",raw,"observed"),true,"sanitized typed raw "..i)
        local obs={knowledgeRaw=C.Observation("observed",raw,100,"fixture")}
        assert(C.Apply(c.db,character,identity,obs,100,"fixture"),"safe partial raw is persistable "..i)
    end
end)
case("K2 protected missing nil throwing APIs sanitize without secrets and mark all trees unknown",function(checkpoint)
    for _,pathName in ipairs({"GetNodeInfo","GetEntryInfo","GetNodeCost","GetTreeCurrencyInfo"}) do
        for _,mode in ipairs({"missing","nil","error"}) do
            pause(checkpoint,"K2 protected API variant")
            local env,_,_,c=k2Fixture()
            env.C_Traits[pathName]=mode=="missing" and nil or function()
                if mode=="error" then error("K2-PRIVATE-ERROR") end
            end
            -- Lua's and/or cannot represent nil; explicitly remove missing functions.
            if mode=="missing" then env.C_Traits[pathName]=nil end
            local raw=k2Raw(c); eq(raw.nativeComplete,false); k2Fail(raw,pathName..mode)
            eq(C.ValidPayload("knowledgeRaw",raw,"observed"),true)
            assert(c:Scan()); local g=c.db.characters[character.guid].professions[2913].active
            for _,t in ipairs(raw.tabs) do eq(g.fields["tree:"..t.id].last,nil) end
            assert(not c.reason:find("K2-PRIVATE-ERROR",1,true)); eq(g.fields.skill.last.value.skillLevel,0)
        end
    end
end)
case("K2 every projection list boundary dense malformed and inspection limited prefix",function(checkpoint)
    local function makeIDs(n) local a={}; for i=1,n do a[i]=800000+i end; return a end
    for _,n in ipairs({16,17}) do
        pause(checkpoint,"K2 cost boundary")
        local _,_,f,c=k2Fixture(); f.costs[106192]={}
        for i=1,n do f.costs[106192][i]={ID=800000+i,amount=1} end
        local raw=k2Raw(c); eq(#raw.tabs[1].paths[106192].costs,math.min(n,16))
        eq(raw.tabs[1].paths[106192].metadataComplete,n==16); k2Fail(raw,"multiple cost not eligible")
        eq(C.ValidPayload("knowledgeRaw",raw,"observed"),true)
        local _,_,entryFixture,entryCollector=k2Fixture()
        entryFixture.entries[130933].entryCost=C.Copy(f.costs[106192])
        local entryRaw=k2Raw(entryCollector); local entryPath=entryRaw.tabs[1].paths[106192]
        eq(#entryPath.spend.entryCost,math.min(n,16)); eq(entryPath.spend.entryCostComplete,n==16)
        eq(C.ValidPayload("knowledgeRaw",entryRaw,"observed"),true); k2Fail(entryRaw,"entry-specific costs")
    end
    for _,n in ipairs({32,33}) do
        pause(checkpoint,"K2 entry boundary")
        local _,_,f,c=k2Fixture(); f.nodes[106192].entryIDs=makeIDs(n)
        f.nodes[106192].entryIDsWithCommittedRanks=makeIDs(n); f.nodes[106192].entryIDToRanksIncreased={}
        for i=1,n do f.nodes[106192].entryIDToRanksIncreased[800000+i]=0 end
        local raw=k2Raw(c); local p=raw.tabs[1].paths[106192]
        eq(#p.node.entryIDs,math.min(n,32)); eq(p.metadataComplete,n==32)
        eq(C.ValidPayload("knowledgeRaw",raw,"observed"),true); k2Fail(raw,"unexpected entry structure")
    end
    for _,n in ipairs({64,65}) do
        pause(checkpoint,"K2 currency boundary")
        local _,_,f,c=k2Fixture()
        for _,rows in pairs(f.currencies) do
            local shared=table.remove(rows,1)
            while #rows<n-1 do rows[#rows+1]={traitCurrencyID=800000+#rows,quantity=0,spent=0} end
            rows[n]=shared
        end
        local raw=k2Raw(c); eq(#raw.tabs[4].currencies,64); eq(raw.tabs[4].currenciesComplete,n==64)
        eq(K.Evaluate(raw).complete,n==64); eq(C.ValidPayload("knowledgeRaw",raw,"observed"),true)
    end
    for _,malform in ipairs({
        function(a) a[3]=C.Copy(a[1]); a[2]=nil end,function(a) a.extra=true end,function(a) a[1]=false end,
        function(a) a[2]=a[1] end,function(a) setmetatable(a,{}) end,
    }) do
        for _,kind in ipairs({"children","entries","currencies","costs"}) do
            pause(checkpoint,"K2 malformed list variant")
            local _,_,f,c=k2Fixture()
            local a=kind=="children" and f.children[106192] or kind=="entries" and f.nodes[106192].entryIDs or
                kind=="currencies" and f.currencies[1122] or f.costs[106192]
            if #a==1 then a[2]=C.Copy(a[1]) end
            malform(a); local raw=k2Raw(c); k2Fail(raw,kind)
            eq(C.ValidPayload("knowledgeRaw",raw,"observed"),true,"bounded sanitized "..kind)
        end
    end
end)
case("K2 path children and tab projection bounds cycles and shared ownership never partial totals",function(checkpoint)
    for _,n in ipairs({64,65}) do
        pause(checkpoint,"K2 path boundary")
        local env,_,f,c=k2Fixture()
        f.tabs={f.tabs[1]}; local template=f.nodes[106192]
        for i=1,n do
            local id=600000+i; local node=C.Copy(template); node.ID=id; f.nodes[id]=node
            f.unlock[id]=130942; f.spend[id]=130933; f.currency[id]=3902; f.costs[id]={{ID=3902,amount=1}}
            f.children[id]=i<n and {id+1} or {}
        end
        env.C_ProfSpecs.GetRootPathForTab=function() return 600001 end
        f.currencies[1122][1].spent=0
        local raw=k2Raw(c); local count=0; for _ in pairs(raw.tabs[1].paths) do count=count+1 end
        eq(count,64); eq(raw.tabs[1].coverageComplete,n==64); eq(K.Evaluate(raw).complete,n==64)
    end
    for _,n in ipairs({8,9}) do
        pause(checkpoint,"K2 tab boundary")
        local env,_,_,c=k2Fixture()
        env.C_ProfSpecs.GetSpecTabIDsForSkillLine=function() local a={}; for i=1,n do a[i]=1000+i end; return a end
        local raw=k2Raw(c); eq(#raw.tabs,8); eq(raw.tabsComplete,n==8); k2Fail(raw,"tab bound no roots")
    end
    for _,n in ipairs({16,17}) do
        pause(checkpoint,"K2 child boundary")
        local _,_,f,c=k2Fixture(); f.children[106192]={}
        for i=1,n do f.children[106192][i]=700000+i end
        local raw=k2Raw(c); eq(#raw.tabs[1].paths[106192].children,math.min(n,16))
        eq(raw.tabs[1].paths[106192].childrenComplete,n==16); k2Fail(raw,"unknown child metadata")
    end
    for _,change in ipairs({
        function(f) f.children[106192]={106192} end,
        function(f) f.children[106192]={106191,106191} end,
        function(f) f.children[106280]={106191} end,
    }) do pause(checkpoint,"K2 graph ownership variant"); local _,_,f,c=k2Fixture(); change(f); local raw=k2Raw(c); eq(raw.nativeComplete,false); k2Fail(raw) end
end)
case("K2 actual nonfinite projection and direct raw or provenance payloads reject atomically",function(checkpoint)
    for _,sample in ipairs(nonfiniteSamples()) do
        for _,target in ipairs({"rank","cost","currency","entry","map","source"}) do
            pause(checkpoint,"K2 nonfinite projection variant")
            local _,s,f,c=k2Fixture(); local v=sample.value
            if target=="rank" then f.nodes[106192].ranksPurchased=v
            elseif target=="cost" then f.costs[106192][1].amount=v
            elseif target=="currency" then f.currencies[1122][1].spent=v
            elseif target=="entry" then f.entries[130942].maxRanks=v
            elseif target=="map" then f.nodes[106192].entryIDToRanksIncreased[130942]=v
            else s.info.sourceCounter=v end
            local raw=k2Raw(c); k2Fail(raw,target..sample.name)
            eq(C.ValidPayload("knowledgeRaw",raw,"observed"),true,"sanitized nonfinite "..target)
        end
        local _,_,_,c=k2Fixture(); local raw=k2Raw(c); local r=K.Evaluate(raw)
        for _,target in ipairs({"raw","tree"}) do
            pause(checkpoint,"K2 nonfinite payload variant")
            local obs=k2Observations(raw,r,100); local db=C.Open(nil); local verify=unchangedGraph(db)
            if target=="raw" then obs.knowledgeRaw.value.sourceCounter=sample.value
            else obs["tree:1122"].value.accountingEvidence.quantity=sample.value end
            eq(C.Apply(db,character,identity,obs,100,"fixture"),nil,target..sample.name); verify()
            -- Inputs are caller-owned; recreate them after deliberately corrupting raw.
            raw=k2Raw(c); r=K.Evaluate(raw)
        end
    end
end)
case("K2 Core typed new raw metadata and complete tree evidence rejects malformed direct scans",function(checkpoint)
    local _,_,_,c=k2Fixture(); local base=k2Raw(c); local result=K.Evaluate(base)
    local changes={
        function(o) o.knowledgeRaw.value.nativeComplete=1 end,
        function(o) o.knowledgeRaw.value.sourceCounter="1" end,
        function(o) o.knowledgeRaw.value.sourceCounter=nil end,
        function(o) o.knowledgeRaw.value.identity.parentID=false end,
        function(o) o.knowledgeRaw.value.tabs[1].currenciesComplete="true" end,
        function(o) o.knowledgeRaw.value.tabs[1].currencyCount=false end,
        function(o) o.knowledgeRaw.value.tabs[1].currencyStatus=false end,
        function(o) o.knowledgeRaw.value.tabs[1].paths[106192].metadataComplete="true" end,
        function(o) o.knowledgeRaw.value.tabs[1].paths[106192].node.activeRank=false end,
        function(o) o.knowledgeRaw.value.tabs[1].paths[106192].node.entryIDsWithCommittedRanks={false} end,
        function(o) o.knowledgeRaw.value.tabs[1].paths[106192].node.nextEntry={entryID=130933,rank=false} end,
        function(o) o.knowledgeRaw.value.tabs[1].paths[106192].node.entryIDToRanksIncreased={[130942]=false} end,
        function(o) o.knowledgeRaw.value.tabs[1].paths[106192].spendEntryID=0 end,
        function(o) o.knowledgeRaw.value.tabs[1].paths[106192].spendCurrencyID=2147483648 end,
        function(o) o.knowledgeRaw.value.tabs[1].paths[106192].spend.entryCost=nil end,
        function(o) o.knowledgeRaw.value.tabs[1].paths[106192].unlock.entryCost={{ID=3902,amount=false}} end,
        function(o) o["tree:1122"].value.accountingPolicy="unknown" end,
        function(o) o["tree:1122"].value.accountingEvidence=nil end,
        function(o) o["tree:1122"].value.accountingEvidence.sourcePin="wrong" end,
        function(o) o["tree:1122"].value.accountingEvidence.spent=265 end,
        function(o) o["tree:1122"].value.accountingEvidence.currencyID=0 end,
        function(o) o["tree:1122"].value.paths[1].purchased=1; o["tree:1122"].value.purchased=1 end,
        function(o) o["tree:1122"].value.paths[1].capacity=31; o["tree:1122"].value.capacity=271 end,
        function(o) o["tree:1122"].value.paths[1].node.entryIDs={999,130933} end,
        function(o) o["tree:1122"].value.currencies[1].quantity=1 end,
    }
    for i,change in ipairs(changes) do
        pause(checkpoint,"K2 typed payload variant "..i)
        local obs=C.Copy(k2Observations(base,result,100)); change(obs)
        local db=dbWith({unspent=8}); local verify=unchangedGraph(db)
        eq(C.Apply(db,character,identity,obs,100,"fixture"),nil,"atomic malformed new "..i); verify()
    end
end)
case("K2 Core reload archive wrong-scope native values reject untouched and legacy schema1 stays valid",function(checkpoint)
    local _,_,_,c=k2Fixture(); local raw=k2Raw(c); local r=K.Evaluate(raw)
    pause(checkpoint,"K3d raw evaluated")
    local db=C.Open(nil); assert(C.Apply(db,character,identity,k2Observations(raw,r,100),100,"fixture"))
    pause(checkpoint,"K3d applied")
    eq(C.Open(db),db);
    pause(checkpoint,"K3d active reopened")
    assert(C.Archive(db,character.guid,2913,110,"fixture"));
    pause(checkpoint,"K3d archived")
    eq(C.Open(db),db)
    pause(checkpoint,"K3d archive reopened")
    for _,mode in ipairs({"active","archive"}) do
        for _,target in ipairs({"scope","raw","tree"}) do
            pause(checkpoint,"K2 scope variant")
            local copy=C.Copy(db); local p=copy.characters[character.guid].professions[2913]
            local g=p.archives[1]
            if mode=="active" then p.active=g; p.archives={}; g.archivedAt=nil; g.archiveReason=nil end
            if target=="scope" then g.identity.expansionID=10
            elseif target=="raw" then g.fields.knowledgeRaw.last.value.tabs[1].paths[106192].spend.type=false
            else g.fields["tree:1122"].last.value.accountingEvidence.totalPurchased=0 end
            local verify=unchangedGraph(copy); eq(C.Open(copy),nil,mode..target); verify()
        end
    end
    for _,key in ipairs({"skillLineID","parentID","profession","expansionID"}) do
        pause(checkpoint,"K3d incoming scope variant")
        local wrong=C.Copy(identity); wrong[key]=999
        local empty=C.Open(nil); local verify=unchangedGraph(empty)
        eq(C.Apply(empty,character,wrong,k2Observations(raw,r,100),100,"fixture"),nil,"incoming scope "..key); verify()
    end
    pause(checkpoint,"K3d before legacy")
    local old=dbWith({knowledgeRaw=scan(),["tree:11"]=treeValue(11,0,10)})
    eq(C.Open(old),old,"old schema1 no migration or native inference")
end)
case("K2 successful scan reload archive hover keeps native zero own evidence time and unspent separate",function(checkpoint,annotate)
    local _,s,_,c=k2Fixture();
    pause(checkpoint,"K3f scan fixture ready")
    assert(c:Scan())
    local g=c.db.characters[character.guid].professions[2913].active
    eq(g.fields["tree:1122"].last.value.purchased,0); eq(g.fields["tree:1122"].last.observedAt,100)
    eq(g.fields.unspent.last.value,0); assert(c.reason:find("shared-spent reconciled",1,true))
    pause(checkpoint,"K3f first scan verified")
    local rows=NS.ViewModel.Build(c.db,c.fresh,{},100); eq(#rows,1); eq(rows[1].trees[1].ratio,0)
    eq(rows[1].trees[1].state.fresh,true); local text=table.concat(rows[1].trees[1].tooltip,"\n")
    assert(text:find("NOT verified future/all-rank costs",1,true)); assert(text:find("compared ONCE",1,true))
    assert(text:find("locked; unlock token 3912 distinct from spend currency 3902",1,true))
    pause(checkpoint,"K3f fresh view verified")
    local reopened=C.Copy(c.db);
    pause(checkpoint,"K3f database copied")
    eq(C.Open(reopened),reopened)
    pause(checkpoint,"K3f database reopened")
    rows=NS.ViewModel.Build(reopened,{}, {},101); eq(rows[1].trees[1].state.fresh,false); eq(rows[1].trees[1].purchased,0)
    pause(checkpoint,"K3f historical view verified")
    assert(C.Archive(reopened,character.guid,2913,110,"fixture"));
    pause(checkpoint,"K3f database archived")
    eq(C.Open(reopened),reopened)
    pause(checkpoint,"K3f archive reopened")
    eq(#NS.ViewModel.Build(reopened,{}, {},111),0)
    pause(checkpoint,"K3f archive hidden verified")
    rows=NS.ViewModel.Build(reopened,{}, {archived=true},111); eq(#rows,1); eq(rows[1].trees[1].purchased,0)
    eq(rows[1].trees[1].state.fresh,false); eq(rows[1].trees[1].state.observedAt,100)
    pause(checkpoint,"K3f archived view verified")
    s.at=120
    -- Resolve only here, never at load/setup or from the synthetic fixture's time.
    local clock
    if type(_G.debugprofilestop)=="function" then clock=_G.debugprofilestop
    elseif type(_G.GetTimePreciseSec)=="function" then
        local seconds=_G.GetTimePreciseSec
        clock=function()
            local value=seconds()
            if not C.Finite(value) then error("invalid seconds clock",0) end
            return value*1000
        end
    end
    local success,why,report=Tests.MeasureScan(c,clock)
    assert(success,why); eq(g.fields["tree:1122"].last.observedAt,100,"old returned generation not mutated")
    if annotate then annotate(Tests.FormatScanTiming(report)) end
end)
case("K2 failed scan preserves ALL coherent trees omitted prior tabs index and nonfresh timestamps",function(checkpoint)
    for _,mode in ipairs({"mismatch","missingtab","partialtabs","metadata"}) do
        pause(checkpoint,"K2 stale variant")
        local env,s,f,c=k2Fixture();
        pause(checkpoint,"K3f stale fixture ready")
        assert(c:Scan())
        local old=c.db.characters[character.guid].professions[2913].active
        pause(checkpoint,"K3f stale baseline scanned")
        local saved=C.Copy(old); s.at=120
        pause(checkpoint,"K3f stale baseline copied")
        if mode=="mismatch" then f.currencies[1124][1].spent=999
        elseif mode=="metadata" then f.entries[130933].entryCost=nil
        elseif mode=="partialtabs" then env.C_ProfSpecs.GetSpecTabIDsForSkillLine=function() return nil end
        else f.tabs={f.tabs[1]}; f.currencies[1122][1].spent=264 end
        pause(checkpoint,"K3f failure injected")
        assert(c:Scan()); local g=c.db.characters[character.guid].professions[2913].active
        for _,id in ipairs({1122,1124,1182,1125}) do
            local field=g.fields["tree:"..id]; eq(field.last.observedAt,100,mode)
            eq(field.last.value.purchased,saved.fields["tree:"..id].last.value.purchased,mode)
            eq(field.attempt.status,"unknown"); eq(field.attempt.attemptedAt,120)
            eq(c.fresh[character.guid..":2913"].fields["tree:"..id],nil)
        end
        if mode=="partialtabs" then eq(g.fields.knowledgeIndex.last.observedAt,100); eq(#g.fields.knowledgeIndex.last.value,4) end
        pause(checkpoint,"K3f stale scan verified")
        local rows=NS.ViewModel.Build(c.db,c.fresh,{},120)
        eq(rows[1].trees[1].state.stale,true); eq(rows[1].trees[1].state.fresh,false)
        local text=table.concat(rows[1].trees[1].tooltip,"\n")
        assert(text:find("Observed tree at 100",1,true)); assert(text:find("spent 264",1,true))
        assert(not text:find("spent 999",1,true),"retained tree never borrows latest raw")
        assert(c.reason:find("unknown or stale",1,true))
    end
    local _,_,f,c=k2Fixture(); f.currencies[1124][1].spent=999;
    pause(checkpoint,"K3f unknown fixture ready")
    assert(c:Scan())
    pause(checkpoint,"K3f unknown scan complete")
    local rows=NS.ViewModel.Build(c.db,c.fresh,{},100)
    for _,t in ipairs(rows[1].trees) do eq(t.purchased,nil); eq(t.ratio,nil); eq(t.state.known,false) end
end)
case("K2 changing identity source config revision and serial discard including reentrant scan",function(checkpoint)
    for _,mode in ipairs({"identity","source","config","revision","serial","closed"}) do
        pause(checkpoint,"K2 race variant")
        local env,s,_,c=k2Fixture(); local original=env.C_Traits.GetNodeCost; local once=false
        env.C_Traits.GetNodeCost=function(...)
            if not once then
                once=true
                if mode=="identity" then env.UnitGUID=function() return "Player-Changed" end
                elseif mode=="source" then s.info.sourceCounter=s.info.sourceCounter+1
                elseif mode=="config" then env.C_ProfSpecs.GetConfigIDForSkillLine=function() return 2001 end
                elseif mode=="revision" then c.revision=c.revision+1
                elseif mode=="serial" then c.serial=c.serial+1
                else s.shown=false end
            end
            return original(...)
        end
        eq(c:Scan(),false,mode); eq(next(c.db.characters),nil,mode); eq(next(c.fresh),nil,mode)
    end
    local env,s,_,c=k2Fixture(); local original=env.C_Traits.GetNodeInfo; local nested=false
    env.C_Traits.GetNodeInfo=function(...)
        if not nested then nested=true; s.at=101; assert(c:Scan()); s.at=102 end
        return original(...)
    end
    eq(c:Scan(),false,"outer reentrant scan discarded")
    local g=c.db.characters[character.guid].professions[2913].active
    eq(g.scannedAt,101,"only coherent inner scan committed"); eq(g.fields["tree:1122"].last.observedAt,101)
    eq(next(c.fresh),nil,"outer invalidation cannot revive fresh tree")
end)
case("K2 staged unknown unavailable source and unsafe contexts stay nonnumeric without harming gear",function(checkpoint)
    for _,mode in ipairs({"starttrue","startnil","endtrue","endnil","stageerror","sourcenil","sourcefalse"}) do
        pause(checkpoint,"K2 staging variant")
        local env,s,_,c=k2Fixture(); local calls=0
        env.C_Traits.ConfigHasStagedChanges=function()
            calls=calls+1
            if mode=="stageerror" then error("K2 private staging") end
            if mode=="startnil" and calls==1 or mode=="endnil" and calls==2 then return nil end
            if mode=="starttrue" and calls==1 or mode=="endtrue" and calls==2 then return true end
            return false
        end
        if mode=="sourcenil" then s.info.sourceCounter=nil elseif mode=="sourcefalse" then s.info.sourceCounter=false end
        assert(c:Scan(),mode)
        local g=c.db.characters[character.guid].professions[2913].active
        for _,id in ipairs({1122,1124,1182,1125}) do eq(g.fields["tree:"..id].last,nil,mode) end
        eq(g.fields.tool.last.value.rarity,3); eq(g.fields.moxie.last.value.quantity,0)
        eq(g.fields.concentration.last.value.quantity,0); eq(g.fields.skill.last.value.skillLevel,0)
    end
    for _,key in ipairs({"combat","linked","guild","npc","changing","ready","shown"}) do
        local _,s,_,c=k2Fixture(); s[key]=not s[key]; local verify=unchangedGraph(c.db)
        eq(c:Scan(),false,key); verify(); eq(s.requests,0); eq(#s.timers,0)
    end
    local _,_,_,c=k2Fixture(); c.db=nil; eq(c:Scan(),false,"missing DB no reset")
    local env,_,_,known=k2Fixture(); env.C_ProfSpecs.GetCurrencyInfoForSkillLine=function() return nil end
    assert(known:Scan()); local g=known.db.characters[character.guid].professions[2913].active
    eq(g.fields.unspent.last,nil,"no unspent fabrication"); eq(g.fields["tree:1122"].last.value.purchased,0)
end)

case("K2 finite scalar ranges nullable failures and metatable node entry map projection",function(checkpoint)
    local setters={
        function(f,v) f.nodes[106192].ID=v end,
        function(f,v) f.nodes[106192].ranksPurchased=v end,
        function(f,v) f.nodes[106192].activeRank=v end,
        function(f,v) f.nodes[106192].activeEntry.rank=v end,
        function(f,v) f.nodes[106192].nextEntry.entryID=v end,
        function(f,v) f.nodes[106192].entryIDToRanksIncreased[130942]=v end,
        function(f,v) f.entries[130933].maxRanks=v end,
        function(f,v) f.costs[106192][1].amount=v end,
        function(f,v) f.costs[106192][1].ID=v end,
        function(f,v) f.currencies[1122][1].quantity=v end,
        function(f,v) f.currencies[1122][1].spent=v end,
        function(f,v) f.currencies[1122][1].maxQuantity=v end,
        function(f,v) f.unlock[106192]=v end,
        function(f,v) f.spend[106192]=v end,
        function(f,v) f.currency[106192]=v end,
    }
    for i,set in ipairs(setters) do
        for _,value in ipairs({-1,0.5,2147483648,"1",false}) do
            pause(checkpoint,"K2 range variant")
            local _,_,f,c=k2Fixture(); set(f,value); local raw=k2Raw(c)
            eq(raw.nativeComplete,false,"range projection "..i); k2Fail(raw,"range projection "..i)
            eq(C.ValidPayload("knowledgeRaw",raw,"observed"),true,"range sanitization "..i)
        end
    end
    for _,change in ipairs({
        function(f) setmetatable(f.nodes[106192],{}) end,
        function(f) setmetatable(f.entries[130942],{}) end,
        function(f) setmetatable(f.nodes[106192].entryIDToRanksIncreased,{}) end,
    }) do
        local _,_,f,c=k2Fixture(); change(f); local raw=k2Raw(c); k2Fail(raw)
        eq(C.ValidPayload("knowledgeRaw",raw,"observed"),true)
    end
    for _,sample in ipairs(nonfiniteSamples()) do
        local _,_,_,c=k2Fixture(); c.serial=sample.value; eq(c:Scan(),false); eq(next(c.db.characters),nil)
    end
end)
case("K2 missing nil throwing specialization reads remain bounded typed unknown not observed empty",function(checkpoint)
    for _,name in ipairs({"GetSpecTabIDsForSkillLine","GetTabInfo","GetRootPathForTab","GetChildrenForPath",
        "GetUnlockEntryForPath","GetSpendEntryForPath","GetSpendCurrencyForPath"}) do
        for _,mode in ipairs({"missing","nil","error"}) do
            pause(checkpoint,"K2 specialization variant")
            local env,_,_,c=k2Fixture()
            env.C_ProfSpecs[name]=function() if mode=="error" then error("K2-PRIVATE-API") end end
            if mode=="missing" then env.C_ProfSpecs[name]=nil end
            local raw=k2Raw(c); eq(raw.nativeComplete,false,name..mode); k2Fail(raw,name..mode)
            eq(C.ValidPayload("knowledgeRaw",raw,"observed"),true,name..mode)
            assert(c:Scan(),name..mode); assert(not c.reason:find("K2-PRIVATE-API",1,true))
        end
    end
end)

case("K2 global copy budget rejects oversized payload atomically and scan retains failed tree history",function(checkpoint)
    local _,s,_,c=k2Fixture(); assert(c:Scan()); s.at=120
    local raw=k2Raw(c); raw.oversized={}
    for i=1,50001 do raw.oversized[i]=0 end
    local verify=unchangedGraph(c.db)
    pause(checkpoint,"oversized fixture construction")
    eq(C.Apply(c.db,character,identity,{knowledgeRaw=C.Observation("observed",raw,120,"fixture")},120,"fixture"),nil)
    pause(checkpoint,"oversized Apply")
    verify()
    c.Knowledge=function() return raw end
    pause(checkpoint,"oversized graph verified")
    assert(c:Scan()); local g=c.db.characters[character.guid].professions[2913].active
    pause(checkpoint,"oversized scan")
    eq(g.fields.knowledgeRaw.last.observedAt,100); eq(g.fields.knowledgeRaw.attempt.status,"unknown")
    for _,id in ipairs({1122,1124,1182,1125}) do
        local f=g.fields["tree:"..id]; eq(f.last.observedAt,100); eq(f.attempt.status,"unknown")
        eq(c.fresh[character.guid..":2913"].fields["tree:"..id],nil)
    end
end)

-- K2 review corrections: next rank uses its observed bounded units, not active
-- entry-local purchased-point units. This is a synthetic boundary, not client proof.
local function k2NearCapFixture()
    local env,s,f,c=k2Fixture()
    local n=f.nodes[106192]
    n.ranksPurchased=30; n.currentRank=30; n.activeRank=30
    n.activeEntry={entryID=f.spend[106192],rank=29}
    n.nextEntry={entryID=f.spend[106192],rank=31}
    n.entryIDsWithCommittedRanks={f.spend[106192]}
    for _,rows in pairs(f.currencies) do rows[1].spent=293 end
    return env,s,f,c
end
case("K2 correction near-cap next31 and MAX are separate evidence in pure Core and collector",function(checkpoint)
    for _,nextRank in ipairs({31,2147483647}) do
        pause(checkpoint,"K2 next rank boundary")
        local _,_,f,c=k2NearCapFixture(); f.nodes[106192].nextEntry.rank=nextRank
        local raw=k2Raw(c); local p=raw.tabs[1].paths[106192]
        eq(p.node.ranksPurchased,30); eq(p.node.maxRanks,31); eq(p.spend.maxRanks,30)
        eq(p.node.activeEntry.rank,29); eq(p.node.nextEntry.rank,nextRank)
        eq(K.NativePathPoints(p,raw.tabs[1]).purchased,29)
        local result=K.Evaluate(raw); eq(result.complete,true); eq(result.sharedSpent,293)
        eq(result.trees[1].purchased,29); eq(result.trees[1].capacity,270)
        local db=C.Open(nil); assert(C.Apply(db,character,identity,k2Observations(raw,result,100),100,"fixture"))
        eq(C.Open(db),db)
        assert(c:Scan()); eq(C.Open(c.db),c.db)
        local tree=c.db.characters[character.guid].professions[2913].active.fields["tree:1122"]
        eq(tree.last.value.purchased,29); eq(tree.last.value.paths[1].node.nextEntry.rank,nextRank)
        eq(c.fresh[character.guid..":2913"].fields["tree:1122"],true)
    end
end)
case("K2 correction next zero nonfinite overflow foreign or wrong-state still fails without relaxing active",function(checkpoint)
    local changes={
        function(p) p.node.nextEntry.rank=0 end,
        function(p) p.node.nextEntry.rank=-1 end,
        function(p) p.node.nextEntry.rank=0.5 end,
        function(p) p.node.nextEntry.rank=2147483648 end,
        function(p) p.node.nextEntry.entryID=999 end,
        function(p) p.node.nextEntry.entryID=p.unlockEntryID end,
        function(p) p.node.activeEntry.rank=30 end,
        function(p) p.node.activeEntry.rank=31 end,
    }
    for _,sample in ipairs(nonfiniteSamples()) do
        local value=sample.value
        changes[#changes+1]=function(p) p.node.nextEntry.rank=value end
    end
    for i,change in ipairs(changes) do
        pause(checkpoint,"K2 next guard "..i)
        local _,_,_,c=k2NearCapFixture(); local raw=k2Raw(c); local result=K.Evaluate(raw)
        local originalRaw=C.Copy(raw)
        change(raw.tabs[1].paths[106192]); k2Fail(raw,"next/active guard "..i)
        change(result.trees[1].paths[1])
        local db=C.Open(nil); local verify=unchangedGraph(db)
        eq(C.Apply(db,character,identity,k2Observations(originalRaw,result,100),100,"fixture"),nil,"direct next/active reject "..i)
        verify()
    end
end)
case("K2 correction every failed native index retains four visible stale trees own names and evidence",function(checkpoint)
    for _,mode in ipairs({"reduced","nilname","errorname","changedname"}) do
        pause(checkpoint,"K2 failed index variant")
        local env,s,f,c=k2Fixture(); assert(c:Scan())
        local prior=c.db.characters[character.guid].professions[2913].active
        -- Deliberately distinct index labels exercise the own-tree name preference.
        for _,row in ipairs(prior.fields.knowledgeIndex.last.value) do row.name="Index alias "..row.id end
        local saved=C.Copy(prior); s.at=120
        if mode=="reduced" then f.tabs={f.tabs[1]} end
        if mode=="nilname" then env.C_ProfSpecs.GetTabInfo=function() return nil end
        elseif mode=="errorname" then env.C_ProfSpecs.GetTabInfo=function() error("PRIVATE-NAME-ERROR") end
        else env.C_ProfSpecs.GetTabInfo=function() return {name="Failed new label"} end end
        if mode=="changedname" then f.currencies[1124][1].spent=999 end
        assert(c:Scan(),mode); local g=c.db.characters[character.guid].professions[2913].active
        local index=g.fields.knowledgeIndex
        eq(index.attempt.status,"unknown"); eq(index.attempt.attemptedAt,120); eq(index.last.observedAt,100)
        assert(deepEqual(index.last.value,saved.fields.knowledgeIndex.last.value),"whole index retained "..mode)
        eq(c.fresh[character.guid..":2913"].fields.knowledgeIndex,nil)
        local rows=NS.ViewModel.Build(c.db,c.fresh,{},120); eq(#rows[1].trees,4,mode)
        for _,tree in ipairs(rows[1].trees) do
            local before=saved.fields["tree:"..tree.id].last
            local after=g.fields["tree:"..tree.id]
            eq(after.attempt.status,"unknown"); eq(after.attempt.attemptedAt,120)
            eq(after.last.observedAt,100); assert(deepEqual(after.last.value,before.value),"whole tree retained")
            eq(tree.name,before.value.name); eq(tree.tooltip[1],before.value.name)
            eq(tree.purchased,before.value.purchased); eq(tree.capacity,before.value.capacity)
            eq(tree.state.stale,true); eq(tree.state.fresh,false); eq(tree.state.observedAt,100)
            eq(c.fresh[character.guid..":2913"].fields["tree:"..tree.id],nil)
            local text=table.concat(tree.tooltip,"\n")
            assert(not text:find("Failed new label",1,true)); assert(not text:find("PRIVATE-NAME-ERROR",1,true))
            assert(text:find("Observed tree at 100",1,true))
        end
    end
end)
case("K2 correction failed native scan with no prior index shows only safe unknown identities",function(checkpoint)
    for _,mode in ipairs({"reduced","nilname","errorname"}) do
        pause(checkpoint,"K2 no prior index variant")
        local env,_,f,c=k2Fixture()
        if mode=="reduced" then f.tabs={f.tabs[1]}
        elseif mode=="nilname" then env.C_ProfSpecs.GetTabInfo=function() return nil end
        else env.C_ProfSpecs.GetTabInfo=function() error("PRIVATE-NAME-ERROR") end end
        assert(c:Scan()); eq(C.Open(c.db),c.db)
        local rows=NS.ViewModel.Build(c.db,c.fresh,{},100)
        eq(#rows[1].trees,mode=="reduced" and 1 or 4)
        for _,tree in ipairs(rows[1].trees) do
            eq(tree.purchased,nil); eq(tree.capacity,nil); eq(tree.ratio,nil)
            eq(tree.state.known,false); eq(tree.state.fresh,false)
        end
    end
end)

-- Match Core.Copy's value count for these acyclic plain fixtures (keys are not
-- visited values). Derive padding from the actual native payload, not guessed size.
local function k2ValueCount(value)
    local count=1
    if type(value)=="table" then for _,child in pairs(value) do count=count+k2ValueCount(child) end end
    return count
end
local function k2CumulativeFixture(extra,checkpoint)
    local _,_,_,collector=k2Fixture(); local raw=k2Raw(collector); local result=K.Evaluate(raw)
    assert(result.complete)
    local observations=k2Observations(raw,result,100)
    local db=dbWith({unspent=8})
    db.characters["Player-Fixture-Other"]={name="Other",realm="Synthetic",professions={}}
    db.characters[character.guid].userMetadata={note="preserve character metadata"}
    db.userMetadata={padding={},note="preserve unknown root data",flag=false,zero=0}
    db.userFlag=false
    local small=C.Copy(db)
    pause(checkpoint,"budget small Copy")
    assert(C.Apply(small,character,identity,observations,100,"fixture-build"))
    pause(checkpoint,"budget small Apply")
    local growth=k2ValueCount(small.characters[character.guid])-k2ValueCount(db.characters[character.guid])
    assert(growth>1,"native payload increases assembled value count")
    local padding=50000-k2ValueCount(db)-growth+extra
    assert(C.Integer(padding,1),"positive boundary padding")
    for i=1,padding do db.userMetadata.padding[i]=0 end
    eq(k2ValueCount(db)+growth,50000+extra,"assembled boundary derived from actual candidate")
    pause(checkpoint,"budget padding and count")
    assert(C.Copy(db),"old data fits independently")
    pause(checkpoint,"budget old Copy")
    eq(C.Open(db),db)
    pause(checkpoint,"budget old Open")
    assert(C.Copy({character,identity,observations}),"incoming native scan fits independently")
    pause(checkpoint,"budget incoming Copy")
    return db,observations
end
case("K2 correction assembled candidate over global budget rejects atomically preserving every reference",function(checkpoint)
    local db,observations=k2CumulativeFixture(1,checkpoint)
    local root,characters,old,metadata,other=db,db.characters,db.characters[character.guid],db.userMetadata,db.characters["Player-Fixture-Other"]
    local generation=old.professions[2913].active
    local verify=unchangedGraph(db)
    pause(checkpoint,"budget graph snapshot")
    local applied,why=C.Apply(db,character,identity,observations,100,"fixture-build")
    pause(checkpoint,"budget rejecting Apply")
    eq(applied,nil); assert(why:find("Assembled snapshot",1,true),"clear bounded assembled-budget error")
    verify(); eq(db,root); eq(db.characters,characters); eq(db.characters[character.guid],old)
    eq(db.userMetadata,metadata); eq(db.userFlag,false); eq(db.userMetadata.flag,false); eq(db.userMetadata.zero,0)
    eq(db.characters["Player-Fixture-Other"],other); eq(old.professions[2913].active,generation)
    eq(generation.scannedAt,10); eq(generation.fields.unspent.last.value,8)
    pause(checkpoint,"budget rejection graph verified")
    eq(C.Open(db),db,"old DB still opens after rejection")
    pause(checkpoint,"budget rejected Open")
    local rows=NS.ViewModel.Build(db,{}, {},100); eq(#rows,1); eq(rows[1].unspent,8)
    pause(checkpoint,"budget active ViewModel")
    assert(C.Archive(db,character.guid,2913,110,"fixture management after rejection"))
    pause(checkpoint,"budget Archive")
    eq(C.Open(db),db)
    pause(checkpoint,"budget archived Open")
    eq(#NS.ViewModel.Build(db,{}, {},111),0)
    pause(checkpoint,"budget hidden ViewModel")
    eq(#NS.ViewModel.Build(db,{}, {archived=true},111),1)
    pause(checkpoint,"budget archived ViewModel")
    assert(C.Delete(db,{guid=character.guid,id=2913,generation=1},true))
    pause(checkpoint,"budget Delete")
    eq(C.Open(db),db)
    pause(checkpoint,"budget deleted Open")
    eq(db.userMetadata,metadata); eq(db.characters["Player-Fixture-Other"],other)
end)
case("K2 correction assembled exact-budget native candidate fits reopens and preserves unrelated root keys",function(checkpoint)
    local db,observations=k2CumulativeFixture(0,checkpoint)
    local characters,metadata,other=db.characters,db.userMetadata,db.characters["Player-Fixture-Other"]
    local g,why=C.Apply(db,character,identity,observations,100,"fixture-build"); assert(g,why)
    pause(checkpoint,"exact budget Apply")
    eq(k2ValueCount(db),50000)
    pause(checkpoint,"exact budget count")
    eq(C.Open(db),db,"new native snapshot immediately reopens")
    pause(checkpoint,"exact budget Open")
    eq(db.characters,characters); eq(db.userMetadata,metadata); eq(db.userFlag,false)
    eq(db.characters["Player-Fixture-Other"],other); eq(db.characters[character.guid].userMetadata.note,"preserve character metadata")
    eq(g.scannedAt,100); eq(g.fields["tree:1122"].last.value.purchased,0)
    local rows=NS.ViewModel.Build(db,{}, {},100); eq(#rows,1); eq(#rows[1].trees,4)
    pause(checkpoint,"exact budget ViewModel")
    eq(rows[1].trees[1].purchased,0); eq(rows[1].trees[1].state.fresh,false)
end)

-- Alias-safe assembly fixtures retain all prior93 cases. Count every reachable
-- alias occurrence just as Core.Copy does, while preserving original graph identity.
local function k2AliasedCumulativeFixture(mode,extra,checkpoint)
    local db,observations=k2CumulativeFixture(0,checkpoint)
    db.userMetadata.padding={}
    local old=db.characters[character.guid]
    db.savedCharacter=old
    local aliases=0
    if mode=="root" or mode=="both" then db.userAlias=db.characters; aliases=aliases+1 end
    if mode=="nested" or mode=="both" then
        db.userMetadata.nested={charactersMap=db.characters}; aliases=aliases+1
    end
    db.sharedLabels={text="preserve shared primitive values",flag=false,zero=0}
    db.secondaryLabels=db.sharedLabels
    local small=C.Copy(db)
    pause(checkpoint,"alias small Copy")
    assert(C.Apply(small,character,identity,observations,100,"fixture-build"))
    pause(checkpoint,"alias small Apply")
    local growth=k2ValueCount(small.characters[character.guid])-k2ValueCount(old)
    assert(growth>1)
    local expandedGrowth=growth*(aliases+1)
    local padding=50000-k2ValueCount(db)-expandedGrowth+extra
    assert(C.Integer(padding,1))
    for i=1,padding do db.userMetadata.padding[i]=0 end
    eq(k2ValueCount(db)+expandedGrowth,50000+extra,"all map aliases see the new candidate")
    pause(checkpoint,"alias expanded boundary count")
    if aliases>0 then
        assert(k2ValueCount(db)+growth<=50000,"old shallow/alias-duplicating preflight would undercount and fit")
    end
    pause(checkpoint,"alias padding and counts")
    assert(C.Copy(db),"aliased old data fits independently")
    pause(checkpoint,"alias old Copy")
    eq(C.Open(db),db)
    pause(checkpoint,"alias old Open")
    assert(C.Copy({character,identity,observations}),"incoming scan fits independently")
    pause(checkpoint,"alias incoming Copy")
    return db,observations
end
case("K2 alias mirror root nested and multiple map aliases reject cumulative expansion graph-identically",function(checkpoint)
    for _,mode in ipairs({"root","nested","both"}) do
        local db,observations=k2AliasedCumulativeFixture(mode,1,checkpoint)
        local root,characters,old,metadata,other=db,db.characters,db.characters[character.guid],db.userMetadata,db.characters["Player-Fixture-Other"]
        local verify=unchangedGraph(db)
        pause(checkpoint,"alias graph snapshot "..mode)
        local result,why=C.Apply(db,character,identity,observations,100,"fixture-build")
        pause(checkpoint,"alias rejecting Apply "..mode)
        eq(result,nil,mode); assert(why:find("Assembled snapshot",1,true),mode)
        verify(); eq(db,root); eq(db.characters,characters); eq(db.characters[character.guid],old)
        eq(db.userMetadata,metadata); eq(db.savedCharacter,old); eq(old.professions[2913].active.scannedAt,10)
        eq(db.characters["Player-Fixture-Other"],other)
        if mode~="nested" then eq(db.userAlias,characters) end
        if mode~="root" then eq(db.userMetadata.nested.charactersMap,characters) end
        eq(db.sharedLabels,db.secondaryLabels); eq(db.sharedLabels.flag,false); eq(db.sharedLabels.zero,0)
        pause(checkpoint,"alias graph verified "..mode)
        eq(C.Open(db),db)
        pause(checkpoint,"alias rejected Open "..mode)
        local rows=NS.ViewModel.Build(db,{}, {},100)
        eq(#rows,1); eq(rows[1].unspent,8)
        pause(checkpoint,"alias rejected ViewModel "..mode)
    end
end)
case("K2 alias mirror fitting root nested and multiple map aliases retain real identity and reopen",function(checkpoint)
    for _,mode in ipairs({"root","nested","both"}) do
        local db,observations=k2AliasedCumulativeFixture(mode,0,checkpoint)
        local characters,old,metadata,labels,other=db.characters,db.characters[character.guid],db.userMetadata,db.sharedLabels,db.characters["Player-Fixture-Other"]
        local oldUnchanged=unchangedGraph(old)
        local g,why=C.Apply(db,character,identity,observations,100,"fixture-build"); assert(g,why)
        pause(checkpoint,"alias fitting Apply "..mode)
        eq(k2ValueCount(db),50000,mode)
        pause(checkpoint,"alias fitting count "..mode)
        eq(C.Open(db),db)
        pause(checkpoint,"alias fitting Open "..mode)
        eq(db.characters,characters); eq(db.userMetadata,metadata); eq(db.characters["Player-Fixture-Other"],other)
        assert(db.characters[character.guid]~=old,"only the map key changes to the cloned candidate")
        if mode~="nested" then eq(db.userAlias,characters); eq(db.userAlias[character.guid].professions[2913].active,g) end
        if mode~="root" then eq(db.userMetadata.nested.charactersMap,characters); eq(db.userMetadata.nested.charactersMap[character.guid].professions[2913].active,g) end
        eq(db.savedCharacter,old); oldUnchanged(); eq(old.professions[2913].active.scannedAt,10)
        eq(db.sharedLabels,labels); eq(db.secondaryLabels,labels); eq(labels.flag,false); eq(labels.zero,0)
        eq(g.scannedAt,100); eq(g.fields["tree:1122"].last.value.purchased,0)
        local rows=NS.ViewModel.Build(db,{}, {},100); eq(#rows,1); eq(#rows[1].trees,4)
        pause(checkpoint,"alias fitting ViewModel "..mode)
    end
end)
case("K2 alias mirror old-character aliases remain old rather than rewritten to the candidate",function(checkpoint)
    local db,observations=k2AliasedCumulativeFixture("old-character-only",0,checkpoint)
    local old=db.characters[character.guid]; db.nestedOld={character=old}
    -- Account for this additional unchanged alias without changing the fit target.
    local remove=k2ValueCount(db.nestedOld)
    for _=1,remove do db.userMetadata.padding[#db.userMetadata.padding]=nil end
    eq(C.Open(db),db)
    pause(checkpoint,"old alias Open")
    local before=unchangedGraph(old); local characters=db.characters; local nested=db.nestedOld
    local g,why=C.Apply(db,character,identity,observations,100,"fixture-build"); assert(g,why)
    pause(checkpoint,"old alias Apply")
    eq(k2ValueCount(db),50000)
    pause(checkpoint,"old alias count")
    eq(C.Open(db),db)
    pause(checkpoint,"old alias final Open")
    eq(db.characters,characters); eq(db.savedCharacter,old); eq(db.nestedOld,nested); eq(nested.character,old)
    assert(db.characters[character.guid]~=old); before()
    eq(old.professions[2913].active.fields.unspent.last.value,8)
    eq(g.fields.unspent.last.value,0); eq(g.fields["tree:1122"].last.value.purchased,0)
end)

-- K3 fixtures use ONLY small isolated cases, never recursively execute this suite.
local function tinyCases(log)
    return {
        {name="tiny multi",fn=function(checkpoint)
            log[#log+1]="a"; checkpoint("first|\nunit")
            log[#log+1]="b"; checkpoint(string.rep("x",200))
            log[#log+1]="c"
        end},
        {name="tiny error",fn=function() log[#log+1]="error"; error("synthetic failure") end},
        {name="tiny last",fn=function() log[#log+1]="last" end},
    }
end
case("K3 runner counts only whole cases and exactly one safe unit per Step",function()
    local log={}; local r=Tests.NewRunner(tinyCases(log))
    eq(r.total,3); eq(r.passed,0); eq(r.failed,0); eq(#log,0)
    r:Step(); eq(#log,1); eq(r.index,1); eq(r.unit,1); eq(r.passed,0); eq(#r.lines,0)
    assert(not r.label:find("[|%c]")); eq(r.label,"first  unit")
    r:Step(); eq(#log,2); eq(r.unit,2); eq(#r.label,128); eq(r.passed,0)
    r:Step(); eq(#log,3); eq(r.passed,1); eq(#r.lines,1); assert(r.lastLine:find("PASS tiny multi",1,true))
    r:Step(); eq(r.failed,1); eq(#r.lines,2); assert(r.lastLine:find("synthetic failure",1,true))
    r:Step(); eq(r.passed,2); eq(r.status,"complete"); eq(r.completed,true); eq(#r.lines,3)
    r:Step(); eq(r.lastLine,nil); eq(#log,5); eq(r.failed,1)
end)
case("K3 Run drains same units assertions and snapshots cases independent of caller edits",function()
    local a,b={},{}; local cases=tinyCases(a); local r=Tests.NewRunner(cases)
    cases[1].fn=function() error("mutated caller") end; cases[1].name="mutated"
    while r.status=="running" do r:Step() end
    local sync=Tests.Run(tinyCases(b))
    eq(table.concat(a,","),table.concat(b,",")); eq(r.passed,sync.passed); eq(r.failed,sync.failed)
    eq(r.total,sync.total); eq(table.concat(r.lines,"\n"),table.concat(sync.lines,"\n"))
    eq(sync.completed,true); eq(sync.steps,5); eq(r.lines[1],"PASS tiny multi")
    local empty=Tests.Run({}); eq(empty.completed,true); eq(empty.passed,0); eq(empty.total,0)
    local incompleteRun=Tests.Run(false); eq(incompleteRun.completed,false)
    assert(incompleteRun.lines[1]:find("INCOMPLETE",1,true))
end)
case("K3 cancel midcase releases work and cannot resume or manufacture pass",function()
    local log={}; local r=Tests.NewRunner(tinyCases(log))
    r:Step(); r:Cancel(); eq(r.status,"incomplete"); eq(r.completed,false)
    eq(r.passed,0); eq(r.failed,0); eq(#r.lines,0)
    for _=1,3 do r:Step(); r:Cancel() end
    eq(#log,1); eq(r.steps,1); eq(r.reason,"cancelled")
end)
case("K3 malformed cases unexpected yield and case cap are explicit incomplete",function()
    for _,value in ipairs({false,1,"bad",{false},{[2]={name="sparse",fn=function() end}},
        {{name=false,fn=function() end}},{{name="bad",fn=false}},setmetatable({},{})}) do
        local r=Tests.NewRunner(value); eq(r.status,"incomplete"); eq(r.completed,false)
        r:Step(); eq(r.passed,0)
    end
    local cases={}; for i=1,512 do cases[i]={name="cap",fn=function() end} end
    local r=Tests.NewRunner(cases); eq(r.total,512); eq(r.status,"running"); r:Cancel()
    cases[513]={name="too many",fn=function() end}
    eq(Tests.NewRunner(cases).status,"incomplete")
    cases={[513]={name="out of range",fn=function() end}}
    eq(Tests.NewRunner(cases).status,"incomplete")
    r=Tests.NewRunner({{name="unexpected",fn=function() coroutine.yield("foreign") end}})
    r:Step(); eq(r.status,"incomplete"); eq(r.failed,0); eq(r.passed,0); eq(#r.lines,0)
    eq(r.reason,"unexpected coroutine yield")
end)
case("K3 step cap bounds neverending fake case without truncating success",function(checkpoint)
    local reached=0
    local r=Tests.NewRunner({{name="many units",fn=function(cp) while true do reached=reached+1; cp("bounded") end end}})
    for i=1,10000 do
        r:Step()
        if i%100==0 then pause(checkpoint,"K3 isolated step cap chunk") end
    end
    eq(reached,10000); eq(r.status,"running"); r:Step()
    eq(r.status,"incomplete"); eq(r.reason,"10000 step cap"); eq(r.completed,false)
    r:Step(); eq(reached,10000); eq(r.passed,0); eq(r.failed,0)
end)
case("K3 unsafe checkpoint throws before yield and protected finally restores overrides",function()
    local apply,evaluate=C.Apply,K.Evaluate; local restored=false; local continued=false
    local r=Tests.NewRunner({{name="unsafe cleanup",fn=function(cp)
        C.Apply=function() error("trap") end; K.Evaluate=function() error("trap") end
        local ok,why=pcall(function() cp("must not yield"); continued=true end)
        C.Apply=apply; K.Evaluate=evaluate; restored=true
        assert(ok,why)
    end},{name="after cleanup",fn=function() eq(C.Apply,apply); eq(K.Evaluate,evaluate) end}})
    r:Step(); eq(restored,true); eq(continued,false); eq(r.failed,1); eq(r.status,"running")
    assert(r.lines[1]:find("unsafe checkpoint",1,true)); eq(C.Apply,apply); eq(K.Evaluate,evaluate)
    r:Step(); eq(r.completed,true); eq(r.passed,1)
end)
case("K3 unexpected function drift at return or between frames stops without overwriting",function()
    local original=C.Apply
    local replacement=function() end
    local ok,why=pcall(function()
        local r=Tests.NewRunner({{name="drift return",fn=function() C.Apply=replacement end}})
        r:Step(); eq(r.status,"incomplete"); eq(r.passed,0); eq(C.Apply,replacement)
        C.Apply=original
        r=Tests.NewRunner({{name="drift between",fn=function(cp) cp(); error("must not resume") end}})
        r:Step(); C.Apply=replacement; r:Step()
        eq(r.status,"incomplete"); eq(r.steps,1); eq(C.Apply,replacement); eq(#r.lines,0)
        assert(r.reason:find("reload required",1,true))
    end)
    C.Apply=original -- only this fixture's known override; runner never restores it
    assert(ok,why)
end)

local function schedulerFixture(cases)
    local s={now=10,frames={},chat={},log={}}
    local function forbidden() error("selftest touched DB/Login/timer/gameplay") end
    local db={sentinel=true}
    local env={CraftArmyDB=db,InCombatLockdown=function() return s.combat or false end,
        debugprofilestop=function() return s.now end,
        C_Timer={After=forbidden},UnitGUID=forbidden,CraftRecipe=forbidden,EquipItemByName=forbidden}
    env.DEFAULT_CHAT_FRAME={AddMessage=function(_,line)
        if s.chatError then error("synthetic output failure") end
        s.chat[#s.chat+1]=line
    end}
    env.CreateFrame=function(kind,name,parent,template)
        eq(kind,"Frame"); eq(name,nil); eq(parent,nil); eq(template,nil)
        if s.frameError=="create" then error("synthetic frame failure") end
        local frame={scripts={},shown=false}
        s.frames[#s.frames+1]=frame
        function frame:SetScript(key,fn)
            eq(key,"OnUpdate")
            if s.frameError=="script" then error("synthetic script failure") end
            self.scripts[key]=fn
        end
        function frame:Show() if s.frameError=="show" then error("synthetic Show failure") end; self.shown=true end
        function frame:Hide() self.shown=false end
        return frame
    end
    local commands=NS.Commands.New(env,function() return Tests.NewRunner(cases or tinyCases(s.log)) end)
    commands.Login=forbidden
    function s:Tick()
        local frame=self.frames[#self.frames]; local fn=frame and frame.scripts.OnUpdate
        if fn then fn(frame,0.016) end
    end
    function s:CheckStopped(status)
        eq(commands.selftest,nil); eq(commands.selftestFrame,nil)
        eq(commands.selftestSummary.status,status or "incomplete")
        local frame=self.frames[#self.frames]
        if frame then eq(frame.shown,false); eq(frame.scripts.OnUpdate,nil) end
        eq(env.CraftArmyDB,db); eq(db.sentinel,true); eq(commands.collector,nil); eq(commands.dashboard,nil)
    end
    return commands,env,s
end
case("K3 command explicit start one unit per OnUpdate repeat status cancel restart preLogin",function()
    local cmd,env,s=schedulerFixture()
    eq(#s.frames,0); eq(#s.log,0)
    local r=cmd:Run(" selftest "); eq(#s.frames,1); eq(#s.log,0); eq(r.steps,0)
    eq(cmd:Run("selftest"),r); eq(#s.frames,1); eq(#s.log,0)
    s:Tick(); eq(#s.log,1); eq(r.steps,1); eq(r.passed,0)
    s:Tick(); eq(#s.log,2); eq(r.steps,2)
    cmd:Run("selftest cancel"); s:CheckStopped(); eq(r.completed,false); eq(r.passed,0)
    s:Tick(); eq(#s.log,2)
    cmd:Run("selftest cancel"); eq(#s.frames,1)
    cmd:Run("selftest"); eq(#s.frames,2); s:Tick(); eq(#s.log,3)
    cmd:Run("selftest cancel"); s:CheckStopped()
    eq(env.C_Timer.After~=nil,true)
end)
case("K3 command normal completion errors once bounded output elapsed max and no extra callbacks",function()
    local cmd,_,s=schedulerFixture(); local r=cmd:Run("selftest")
    for i=1,5 do s.now=s.now+2; s:Tick(); eq(r.steps,i) end
    s:CheckStopped("complete"); eq(cmd.selftestSummary.completed,true)
    eq(cmd.selftestSummary.passed,2); eq(cmd.selftestSummary.failed,1); eq(cmd.selftestSummary.elapsed,10)
    local text=table.concat(s.chat,"\n"); local _,passes=text:gsub("PASS tiny multi","")
    local _,failures=text:gsub("FAIL tiny error",""); eq(passes,1); eq(failures,1)
    assert(text:find("COMPLETE: 2 passed; 1 failed of 3",1,true)); assert(text:find("not client API evidence",1,true))
    local n=#s.chat; s:Tick(); eq(#s.chat,n); eq(r.steps,5)
end)
case("K3 command bad arguments absent clock frames and combat never start or Login",function()
    for _,mode in ipairs({"args","combat","unknown","clockmissing","clockthrow","nan","infinity","frames"}) do
        local cmd,env,s=schedulerFixture()
        if mode=="combat" then s.combat=true
        elseif mode=="unknown" then env.InCombatLockdown=function() return nil end
        elseif mode=="clockmissing" then env.debugprofilestop=nil
        elseif mode=="clockthrow" then env.debugprofilestop=function() error("clock") end
        elseif mode=="nan" then env.debugprofilestop=function() return 0/0 end
        elseif mode=="infinity" then env.debugprofilestop=function() return math.huge end
        elseif mode=="frames" then env.CreateFrame=nil end
        cmd:Run(mode=="args" and "selftest bad extra" or "selftest")
        eq(cmd.selftest,nil); eq(#s.frames,0); eq(#s.log,0); eq(cmd.collector,nil)
        if mode=="args" then assert(table.concat(s.chat):find("Usage:",1,true)) end
    end
    for _,bad in ipairs({{v=nil},{v="1"},{v=false},{v=0/0},{v=math.huge},{v=1e308},{throws=true}}) do
        local cmd,env,s=schedulerFixture(); env.debugprofilestop=nil
        env.GetTimePreciseSec=function() if bad.throws then error("seconds source") end; return bad.v end
        cmd:Run("selftest"); eq(cmd.selftest,nil); eq(#s.frames,0); eq(#s.log,0)
    end
end)
case("K3 command clock seconds fallback finite monotonic and failure stops before next unit",function()
    local cmd,env,s=schedulerFixture(); env.debugprofilestop=nil
    env.GetTimePreciseSec=function() return s.now/1000 end
    cmd:Run("selftest"); s.now=20; s:Tick(); eq(#s.log,1)
    s.now=30; cmd:Run("selftest cancel"); s:CheckStopped()
    for _,mode in ipairs({"backward","nan","infinity","throw","badtype"}) do
        cmd,env,s=schedulerFixture(); cmd:Run("selftest"); s:Tick(); eq(#s.log,1)
        if mode=="backward" then s.now=9
        else env.debugprofilestop=nil -- captured clock still calls s.now through its original closure
            if mode=="nan" then s.now=0/0 elseif mode=="infinity" then s.now=math.huge
            elseif mode=="badtype" then s.now="bad" else
                -- A fresh session captures a throwing source after its first read.
                cmd:Run("selftest cancel"); local calls=0
                env.debugprofilestop=function() calls=calls+1; if calls>1 then error("late clock") end; return 10 end
                cmd:Run("selftest")
            end
        end
        s:Tick(); s:CheckStopped(); eq(#s.log,1)
    end
    for _,bad in ipairs({9,0/0,math.huge,"bad"}) do
        local state
        local cases={{name="clock breaks in final unit",fn=function() state.now=bad end}}
        cmd,env,s=schedulerFixture(cases); state=s
        cmd:Run("selftest"); s:Tick(); s:CheckStopped()
        eq(cmd.selftestSummary.completed,false)
        assert(not table.concat(s.chat):find("PASS clock breaks",1,true))
    end
end)
case("K3 command slow unit including LAST passing callback is incomplete not completed PASS",function()
    for _,mode in ipairs({"yield","lastpass","lastfail"}) do
        local last=mode~="yield"
        local sref
        local cases={{name="slow atomic",fn=function(cp)
            sref.now=sref.now+101
            if not last then cp("slow boundary") end
            if mode=="lastfail" then error("last slow failure") end
        end}}
        local cmd,_,s=schedulerFixture(cases); sref=s
        local r=cmd:Run("selftest"); s:Tick(); s:CheckStopped()
        eq(r.completed,false); eq(r.status,"incomplete"); eq(r.passed,mode=="lastpass" and 1 or 0)
        eq(r.failed,mode=="lastfail" and 1 or 0)
        eq(cmd.selftestSummary.maxUnit,101); eq(cmd.selftestSummary.elapsed,101)
        eq(cmd.selftestSummary.name,"slow atomic"); assert(cmd.selftestSummary.reason:find("101.0ms",1,true))
        local text=table.concat(s.chat,"\n"); assert(text:find("INCOMPLETE",1,true))
        assert(not text:find("PASS slow atomic",1,true)); assert(not text:find("\nCraftArmy: COMPLETE",1,true))
    end
end)
case("K3 command progress per ten cases and per second in long case has bounded metadata",function()
    local cases={}; for i=1,11 do cases[i]={name="progress"..i,fn=function() end} end
    local cmd,_,s=schedulerFixture(cases); cmd:Run("selftest")
    for _=1,10 do s:Tick() end
    assert(table.concat(s.chat):find("PROGRESS: 10 passed",1,true)); s:Tick(); s:CheckStopped("complete")
    cmd,_,s=schedulerFixture(); cmd:Run("selftest"); s.now=1010; s:Tick()
    assert(table.concat(s.chat):find("PROGRESS: 0 passed",1,true))
    eq(cmd.selftest.elapsed,1000); eq(cmd.selftest.maxUnit,0)
    cmd:Run("selftest cancel"); s:CheckStopped()
end)
case("K3 command entering combat stops before work event preLogin and no automatic resume",function()
    for _,mode in ipairs({"poll","event","unknown"}) do
        local cmd,env,s=schedulerFixture(); local r=cmd:Run("selftest"); s:Tick(); eq(#s.log,1)
        if mode=="event" then cmd:Event("PLAYER_REGEN_DISABLED")
        else
            if mode=="unknown" then env.InCombatLockdown=function() error("combat unavailable") end else s.combat=true end
            s:Tick()
        end
        s:CheckStopped(); eq(r.steps,1); eq(#s.log,1)
        s.combat=false; env.InCombatLockdown=function() return false end
        cmd:Event("PLAYER_REGEN_ENABLED"); s:Tick(); eq(#s.log,1); eq(#s.frames,1)
    end
end)
case("K3 command frame setup runner callback and output exceptions release active driver",function()
    for _,mode in ipairs({"create","script","show","step","output"}) do
        local cmd,_,s=schedulerFixture()
        if mode=="create" or mode=="script" or mode=="show" then s.frameError=mode end
        local r=cmd:Run("selftest")
        if mode=="step" then r.Step=function() error("synthetic Step failure") end; s:Tick()
        elseif mode=="output" then s.chatError=true; s:Tick(); s:Tick(); s:Tick() end
        -- Setup SetScript itself may be unavailable; that failed call never installed a callback.
        s:CheckStopped(); eq(cmd.selftestSummary.completed,false)
    end
    local cmd,env,s=schedulerFixture()
    cmd=NS.Commands.New(env,function() error("factory exception") end)
    cmd.Login=function() error("no Login") end
    cmd:Run("selftest"); eq(cmd.selftest,nil); eq(cmd.selftestFrame,nil); eq(#s.frames,0)
    assert(table.concat(s.chat):find("INCOMPLETE",1,true))
    cmd,env,s=schedulerFixture(); cmd:Run("selftest"); s.chatError=true
    cmd:Run("selftest"); s:CheckStopped(); eq(#s.log,0)
end)

-- K3b additions only: original111 cases above keep their order/assertions/stress.
case("K3b stepped capture and format synchronous parity on fresh normal zero API error mismatch and clipped inputs",function(checkpoint)
    for _,mode in ipairs({"normal","zero","error","mismatch","clipped"}) do
        local function input()
            local shape
            if mode~="normal" then shape={3,2} end
            local e,s,f,c=knowledgeFixture(shape)
            if mode=="zero" then
                for _,n in pairs(f.nodes) do n.currentRank=0; n.ranksPurchased=0 end
                for _,rows in pairs(f.currencies) do rows[#rows].spent=0 end
            elseif mode=="error" then e.C_Traits.GetNodeCost=function() error("PRIVATE-JOB-API-ERROR") end
            elseif mode=="mismatch" then for _,rows in pairs(f.currencies) do rows[#rows].spent=1 end
            elseif mode=="clipped" then e.C_ProfSpecs.GetTabInfo=function() return {name="clip input"} end end
            return e,c
        end
        local e,c=input(); local synchronous=NS.KnowledgeCheck.Capture(e,c)
        pause(checkpoint,"K3b synchronous parity capture")
        local ee,cc=input(); local job=steppedJob(NS.KnowledgeCheck.NewCaptureJob(ee,cc),checkpoint)
        assert(deepEqual(synchronous,job.report),"same fresh synthetic data")
        if mode=="normal" or mode=="zero" then eq(job.report.captureComplete,true)
        elseif mode=="error" then incomplete(job.report)
        elseif mode=="mismatch" then eq(job.report.reconciliation.status,"provisional mismatch") end
        -- A borrowed format input can be explicitly clipped without reusing a
        -- prior candidate. This is separate from the full512 byte stress in case63.
        if mode=="clipped" then synchronous.outputTruncated=true; job.report.outputTruncated=true end
        local text,summary=NS.KnowledgeCheck.Format(synchronous)
        pause(checkpoint,"K3b synchronous parity format")
        local formatted=steppedJob(NS.KnowledgeCheck.NewFormatJob(job.report),checkpoint)
        eq(text,formatted.text); assert(deepEqual(summary,formatted.summary))
        assert(not text:find("PRIVATE-JOB-API-ERROR",1,true))
        if mode=="clipped" then eq(summary.captureComplete,false); eq(summary.candidate,nil); eq(summary.shared,nil); eq(summary.trees,nil) end
    end
end)
case("K3b capture units independently count actual node reads and hide every partial result",function(checkpoint)
    local e,_,_,c=knowledgeFixture({5,3}); local reads=0
    local original=e.C_Traits.GetNodeInfo
    e.C_Traits.GetNodeInfo=function(...) reads=reads+1; return original(...) end
    local job=NS.KnowledgeCheck.NewCaptureJob(e,c); local paths=0
    while job.status=="running" do
        eq(job.report,nil); eq(job.text,nil); eq(job.summary,nil)
        local before=reads; job:Step()
        assert(reads-before<=1,"actual reads, not just a job counter")
        eq(reads-before,job.pathUnits); paths=paths+job.pathUnits
        pause(checkpoint,"K3b actual path unit")
    end
    eq(job.status,"complete"); eq(paths,8); eq(reads,8); eq(job.report.captured,8); eq(job.worker,nil)
end)
case("K3b format units count eight attempts even after early clipping with immutable input",function(checkpoint)
    for _,clip in ipairs({false,true}) do
        local report={tabs={{paths={},currencies={items={}}}},captureComplete=true,stable=true,
            candidate={points=0,capacity=0},shared={spent=0},reconciliation={status="provisional match"}}
        for i=1,20 do report.tabs[1].paths[i]={id=i} end
        if clip then report.sourcePin={}; report.sourcePin.loop=report.sourcePin end
        local verify=unchangedGraph(report)
        local job=NS.KnowledgeCheck.NewFormatJob(report); local attempts,chunks=0,0
        while job.status=="running" do
            eq(job.text,nil); eq(job.summary,nil); job:Step()
            assert(job.lineAttempts<=8); attempts=attempts+job.lineAttempts
            if job.lineAttempts==8 then chunks=chunks+1 end
            verify(); pause(checkpoint,"K3b eight format attempts")
        end
        eq(attempts,14+2+20*7); eq(chunks,19); eq(job.completed,true); eq(job.worker,nil)
        eq(job.summary.outputTruncated,clip)
        if clip then eq(job.summary.candidate,nil); eq(job.summary.shared,nil); eq(job.summary.trees,nil); assert(not job.text:find("provisional match",1,true)) end
        assert(#job.text<=262144); assert(job.text:find("END SUMMARY version1",1,true)); verify()
    end
end)
local function terminalJob(job)
    eq(job.status,"incomplete"); eq(job.completed,false); eq(job.worker,nil)
    eq(job.report,nil); eq(job.text,nil); eq(job.summary,nil)
    for _,key in ipairs({"env","runtime","input","work","buffer"}) do eq(job[key],nil) end
    local steps,reason=job.steps,job.reason
    job:Step(); job:Cancel("repeat"); job:Step(); eq(job.steps,steps); eq(job.reason,reason)
end
case("K3b cancellation before capture between paths and during private formatting releases work",function(checkpoint)
    for _,phase in ipairs({"before","path","format"}) do
        local e,_,_,c=knowledgeFixture({4}); local job=NS.KnowledgeCheck.NewCaptureJob(e,c)
        if phase~="before" then
            while job.status=="running" and job.phase~=phase do
                job:Step(); pause(checkpoint,"K3b reach capture cancellation")
            end
            eq(job.status,"running"); eq(job.phase,phase)
        end
        job:Cancel("requested\001|cancel"); terminalJob(job)
        assert(not job.reason:find("|",1,true)); assert(not job.reason:find("\001",1,true))
        pause(checkpoint,"K3b cancelled capture")
    end
end)
case("K3b independent jobs repeated terminal calls and format cancellation retain only results",function(checkpoint)
    local e,_,_,c=knowledgeFixture({2})
    local a=NS.KnowledgeCheck.NewCaptureJob(e,c); local b=NS.KnowledgeCheck.NewCaptureJob(e,c)
    a:Step(); b:Step(); a:Cancel(); terminalJob(a)
    b=steppedJob(b,checkpoint); local result=b.report; local steps=b.steps
    b:Step(); b:Cancel(); eq(b.report,result); eq(b.steps,steps); eq(b.status,"complete"); eq(b.worker,nil)
    local verify=unchangedGraph(result)
    local x=NS.KnowledgeCheck.NewFormatJob(result); local y=NS.KnowledgeCheck.NewFormatJob(result)
    x:Step(); y:Step(); x:Cancel(); terminalJob(x); verify()
    y=steppedJob(y,checkpoint); local text,summary=y.text,y.summary; steps=y.steps
    y:Step(); y:Cancel(); eq(y.text,text); eq(y.summary,summary); eq(y.steps,steps); eq(y.worker,nil); verify()
end)
case("K3b lowered job cap and invalid options fail closed without starting API work",function(checkpoint)
    local e,_,_,c=knowledgeFixture({2}); local reads=0; local original=e.GetServerTime
    e.GetServerTime=function() reads=reads+1; return original() end
    local bad={{v=false},{v=3},{v="bad"},{v=setmetatable({},{})},{v={unknown=1}},
        {v={stepLimit=0}},{v={stepLimit=-1}},{v={stepLimit=1.5}},{v={stepLimit=10001}},{v={stepLimit="1"}},
        {v={stepLimit=false}},{v={stepLimit=1,extra=1}}}
    for _,sample in ipairs(nonfiniteSamples()) do bad[#bad+1]={v={stepLimit=sample.value}} end
    for _,options in ipairs(bad) do
        terminalJob(NS.KnowledgeCheck.NewCaptureJob(e,c,options.v))
        terminalJob(NS.KnowledgeCheck.NewFormatJob({},options.v))
        eq(reads,0); pause(checkpoint,"K3b invalid options")
    end
    for _,kind in ipairs({"capture","format"}) do
        local job=kind=="capture" and NS.KnowledgeCheck.NewCaptureJob(e,c,{stepLimit=1}) or NS.KnowledgeCheck.NewFormatJob({},{stepLimit=1})
        eq(job.stepLimit,1); job:Step(); eq(job.status,"running"); eq(job.steps,1)
        job:Step(); terminalJob(job); eq(job.steps,1); pause(checkpoint,"K3b lowered cap")
    end
    local job=NS.KnowledgeCheck.NewCaptureJob(e,c,{stepLimit=10000}); eq(job.stepLimit,10000); job:Cancel(); terminalJob(job)
    job=NS.KnowledgeCheck.NewFormatJob({},{}); eq(job.stepLimit,10000); job:Cancel(); terminalJob(job)
end)
case("K3b private capture and format exceptions are payload-free incomplete compatibility evidence",function(checkpoint)
    local e,_,_,c=knowledgeFixture({2})
    e.C_ProfSpecs=setmetatable({},{__index=function() error("PRIVATE-UNEXPECTED-JOB |Hbad|h") end})
    local job=NS.KnowledgeCheck.NewCaptureJob(e,c); job:Step(); terminalJob(job)
    assert(not job.reason:find("PRIVATE-UNEXPECTED-JOB",1,true))
    local r=NS.KnowledgeCheck.Capture(e,c); incomplete(r); eq(r.stable,false); eq(#r.tabs,0)
    pause(checkpoint,"K3b exception compatibility capture")
    e.C_ProfSpecs=setmetatable({},{__index=function() coroutine.yield("PRIVATE-UNEXPECTED-YIELD") end})
    job=NS.KnowledgeCheck.NewCaptureJob(e,c); job:Step(); terminalJob(job)
    assert(not job.reason:find("PRIVATE-UNEXPECTED-YIELD",1,true))
    pause(checkpoint,"K3b unexpected yield isolated")
    local bad=setmetatable({},{__index=function() error("PRIVATE-FORMAT-ERROR") end})
    job=NS.KnowledgeCheck.NewFormatJob(bad); job:Step(); terminalJob(job)
    assert(not job.reason:find("PRIVATE-FORMAT-ERROR",1,true))
    local text,summary=NS.KnowledgeCheck.Format(bad)
    eq(summary.captureComplete,false); eq(summary.outputTruncated,true); eq(summary.candidate,nil); eq(summary.shared,nil); eq(summary.trees,nil)
    assert(text:find("version1 BEGIN",1,true)); assert(text:find("END SUMMARY version1",1,true)); assert(text:find("version1 END",1,true))
    assert(text:find("format incomplete",1,true)); assert(not text:find("PRIVATE-FORMAT-ERROR",1,true)); assert(#text<=262144)
end)
case("K3b between-slice identity source config revision serial staging and close invalidate whole interval",function(checkpoint)
    for mode=1,8 do
        local e,s,_,c=knowledgeFixture({4,2}); local job=NS.KnowledgeCheck.NewCaptureJob(e,c)
        repeat job:Step(); pause(checkpoint,"K3b reach first path race") until job.phase=="path" or job.status~="running"
        eq(job.status,"running")
        if mode==1 then e.UnitGUID=function() return "Player-PRIVATE-OTHER" end
        elseif mode==2 then s.info.sourceCounter=2
        elseif mode==3 then e.C_ProfSpecs.GetConfigIDForSkillLine=function() return 1002 end
        elseif mode==4 then c.revision=c.revision+1
        elseif mode==5 then c.serial=c.serial+1
        elseif mode==6 then e.C_Traits.ConfigHasStagedChanges=function() return true end
        elseif mode==7 then s.shown=false
        else s.info.professionID=999 end
        job=steppedJob(job,checkpoint); incomplete(job.report); eq(job.report.stable,false)
        for _,t in ipairs(job.report.tabs) do eq(t.candidate,nil) end
        local formatted=steppedJob(NS.KnowledgeCheck.NewFormatJob(job.report),checkpoint)
        eq(formatted.summary.candidate,nil); assert(not formatted.text:find("PRIVATE-OTHER",1,true))
    end
end)
case("K3b completed work differs from data completeness protected statuses and empty versus nil",function(checkpoint)
    for _,mode in ipairs({"empty","nil","error","unsupported"}) do
        local e,_,_,c=knowledgeFixture({1})
        e.C_Traits.GetNodeCost=function() if mode=="error" then error("PRIVATE-COST-ERROR") end; if mode=="empty" then return {} end end
        if mode=="unsupported" then e.C_Traits.GetNodeCost=nil end
        local job=steppedJob(NS.KnowledgeCheck.NewCaptureJob(e,c),checkpoint)
        eq(job.completed,true); eq(firstPath(job.report).costs.status,mode)
        eq(job.report.captureComplete,mode=="empty")
        local formatted=steppedJob(NS.KnowledgeCheck.NewFormatJob(job.report),checkpoint)
        assert(not formatted.text:find("PRIVATE-COST-ERROR",1,true))
        assert(formatted.text:find("all-rank costs",1,true))
    end
end)
case("K3b formatting does not refresh context or capture time after collection finishes",function(checkpoint)
    local e,s,_,c=knowledgeFixture({2}); local times=0
    e.GetServerTime=function() times=times+1; return 100+times end
    local job=NS.KnowledgeCheck.NewCaptureJob(e,c)
    repeat job:Step(); pause(checkpoint,"K3b collection before pure formatting") until job.phase=="format" or job.status~="running"
    eq(job.status,"running"); eq(times,2)
    s.shown=false; c.revision=c.revision+1; c.serial=c.serial+1
    e.C_ProfSpecs=setmetatable({},{__index=function() error("must not requery") end})
    e.GetServerTime=function() error("must not retime") end
    job=steppedJob(job,checkpoint); eq(job.report.captureComplete,true); eq(job.report.stable,true)
    eq(job.report.timeStart.value,101); eq(job.report.timeEnd.value,102); eq(times,2)
    local formatted=steppedJob(NS.KnowledgeCheck.NewFormatJob(job.report),checkpoint)
    eq(formatted.summary.captureComplete,true); eq(times,2)
end)
case("K3b stepped jobs retain read-only traps without yielding across namespace overrides",function(checkpoint)
    local e,s,_,c=knowledgeFixture({2}); local job=NS.KnowledgeCheck.NewCaptureJob(e,c)
    e.CreateFrame=function() error("PRIVATE-NO-UI") end
    while job.status=="running" do
        -- Step returns before trappedCapture restores the temporary namespace.
        trappedCapture(e,c,function() job:Step() end)
        pause(checkpoint,"K3b protected unit returned")
    end
    eq(job.status,"complete"); eq(job.report.captureComplete,true); eq(s.requests,0); eq(#s.timers,0)
    local formatted=steppedJob(NS.KnowledgeCheck.NewFormatJob(job.report),checkpoint)
    for _,secret in ipairs({"PRIVATE-GUID","PRIVATE-NAME","PRIVATE-REALM","PRIVATE-SAVED-DATA","PRIVATE-RUNTIME-REASON","PRIVATE-NO-UI","PRIVATE-FORBIDDEN-PAYLOAD","|","\001"}) do assert(not formatted.text:find(secret,1,true),secret) end
end)
case("K3b summary reserve overflow is incomplete and immutable in synchronous and stepped formatting",function(checkpoint)
    local report={tabs={{paths={},currencies={items={}}}},captureComplete=true,stable=true,
        candidate={},shared={spent=0},reconciliation={status="provisional match"}}
    for i=1,24 do report.candidate[i]=string.rep("x",256) end
    local verify=unchangedGraph(report)
    local text,summary=NS.KnowledgeCheck.Format(report); verify()
    pause(checkpoint,"K3b synchronous summary reserve")
    local job=steppedJob(NS.KnowledgeCheck.NewFormatJob(report),checkpoint); verify()
    eq(job.text,text); assert(deepEqual(job.summary,summary))
    eq(summary.outputTruncated,true); eq(summary.captureComplete,false)
    eq(summary.candidate,nil); eq(summary.shared,nil); eq(summary.trees,nil)
    eq(summary.reconciliation.reason,"summary reserve exceeded; no passing totals")
    assert(not text:find("provisional match",1,true)); assert(text:find("END SUMMARY version1",1,true)); assert(text:find("version1 END",1,true))
    assert(#text<=262144); local _,n=text:gsub("\n",""); assert(n+1<=4096)
end)

-- K4 additions: small stubs exercise instrumentation only, never the old Scan cases.
local function timingFixture(run)
    local open,apply,copy,evaluate=C.Open,C.Apply,C.Copy,K.Evaluate
    local c={}
    local function noop(...) return ... end
    C.Open=noop; C.Apply=noop; C.Copy=noop; K.Evaluate=noop
    c.Context=noop; c.Gear=noop; c.Knowledge=noop
    c.Scan=function(self)
        C.Open(); self:Context(); self:Gear(); self:Knowledge(); K.Evaluate(); C.Copy(); C.Apply()
        return true,"PRIVATE-REASON"
    end
    local ok,why=pcall(run,c)
    K.Evaluate=evaluate; C.Copy=copy; C.Apply=apply; C.Open=open
    assert(ok,why)
end
local function timingRestoration(c)
    local o,a,v,e,k,g,b=C.Open,C.Apply,C.Copy,K.Evaluate,c.Knowledge,c.Gear,c.Context
    return function()
        eq(C.Open,o); eq(C.Apply,a); eq(C.Copy,v); eq(K.Evaluate,e)
        eq(c.Knowledge,k); eq(c.Gear,g); eq(c.Context,b)
    end
end
local function tickClock()
    local at=0
    return function() at=at+1; return at end
end
local function privateTimingReport(report)
    local keys={status=true,reason=true,totalMs=true,otherMs=true,stages=true,
        O=true,A=true,C=true,K=true,E=true,G=true,B=true,calls=true,inclusiveMs=true,exclusiveMs=true}
    local function visit(t)
        eq(getmetatable(t),nil)
        for key,value in pairs(t) do
            assert(keys[key],"unexpected report key")
            if type(value)=="table" then visit(value)
            elseif type(value)=="number" then assert(C.Finite(value)); assert(value>=0)
            else assert(value=="observed" or value=="unavailable" or timingReasons[value],"unexpected report value") end
        end
    end
    visit(report)
end
case("K4 nested stage calls inclusive exclusive and root residual partition",function()
    timingFixture(function(c)
        C.Apply=function() C.Open(); C.Copy(); K.Evaluate() end
        c.Knowledge=function() C.Copy() end
        c.Scan=function(self)
            self:Context(); C.Apply(); self:Knowledge(); self:Gear(); self:Gear()
            return true,"PRIVATE-REASON"
        end
        local restored=timingRestoration(c)
        local a,b,r=Tests.MeasureScan(c,tickClock()); restored()
        eq(a,true); eq(b,"PRIVATE-REASON"); eq(r.status,"observed")
        eq(r.totalMs,19); eq(r.otherMs,6)
        local expected={O={1,1,1},A={1,7,4},C={2,2,2},K={1,3,2},E={1,1,1},G={2,2,2},B={1,1,1}}
        local sum=r.otherMs
        for tag,v in pairs(expected) do
            eq(r.stages[tag].calls,v[1],tag); eq(r.stages[tag].inclusiveMs,v[2],tag)
            eq(r.stages[tag].exclusiveMs,v[3],tag); sum=sum+r.stages[tag].exclusiveMs
        end
        eq(sum,r.totalMs); privateTimingReport(r)
        eq(Tests.FormatScanTiming(r),"scan2 ms excl T=19.0 O=1.0 A=4.0 C=2.0 K=2.0 E=1.0 G=2.0 B=1.0 R=6.0")
    end)
end)
case("K4 wrappers preserve original argument identities and all nil return positions",function()
    timingFixture(function(c)
        local marker={}; local calls=0
        local function original(...)
            local args=pack(...); eq(args.n,4); eq(args[1],marker); eq(args[2],nil)
            eq(args[3],false); eq(args[4],nil); calls=calls+1
            return nil,marker,nil,false,nil
        end
        C.Open=original; C.Apply=original; C.Copy=original; K.Evaluate=original
        local function method(self,...) eq(self,c); return original(...) end
        c.Knowledge=method; c.Gear=method; c.Context=method
        local function check(...)
            local values=pack(...); eq(values.n,5); eq(values[1],nil); eq(values[2],marker)
            eq(values[3],nil); eq(values[4],false); eq(values[5],nil)
        end
        c.Scan=function(self)
            check(C.Open(marker,nil,false,nil)); check(C.Apply(marker,nil,false,nil))
            check(C.Copy(marker,nil,false,nil)); check(K.Evaluate(marker,nil,false,nil))
            check(self:Knowledge(marker,nil,false,nil)); check(self:Gear(marker,nil,false,nil))
            check(self:Context(marker,nil,false,nil)); return false,nil
        end
        local restored=timingRestoration(c)
        local a,b,r=Tests.MeasureScan(c,tickClock()); restored()
        eq(a,false); eq(b,nil); eq(calls,7); eq(r.status,"observed"); privateTimingReport(r)
    end)
end)
case("K4 success false and private original errors restore all bindings before return",function()
    timingFixture(function(c)
        for _,mode in ipairs({"success","false","throw","stage throw","unwrapped throw"}) do
            local scans=0
            c.Scan=function(self)
                scans=scans+1; C.Apply(); self:Knowledge()
                if mode=="throw" or mode=="unwrapped throw" then error("PRIVATE-SCAN-PAYLOAD|\001") end
                return mode=="success","PRIVATE-REASON"
            end
            local knowledge=c.Knowledge
            if mode=="stage throw" then c.Knowledge=function() error({secret="PRIVATE-STAGE"}) end end
            local restored=timingRestoration(c)
            local clock=mode~="unwrapped throw" and tickClock() or nil
            local ok,a,b,r=pcall(Tests.MeasureScan,c,clock); restored(); eq(scans,1)
            if mode=="throw" or mode=="stage throw" or mode=="unwrapped throw" then
                eq(ok,false); eq(a,"timed scan failed (payload omitted)"); eq(b,nil); eq(r,nil)
            else
                eq(ok,true); eq(a,mode=="success"); eq(b,"PRIVATE-REASON")
                eq(r.status,"observed"); privateTimingReport(r)
            end
            c.Knowledge=knowledge
        end
    end)
end)
case("K4 missing invalid backward and mid-clock failures continue one unchanged Scan",function()
    timingFixture(function(c)
        local scan=c.Scan
        for _,mode in ipairs({"missing","throw","nan","infinity","type","start throw","backward","mid throw","mid nan","end throw"}) do
            local probes,scans,work=0,0,0
            local unwrapped=timingRestoration(c)
            c.Scan=function(self)
                scans=scans+1
                if mode~="backward" and mode~="mid throw" and mode~="mid nan" and mode~="end throw" then unwrapped() end
                local a,b=scan(self); work=work+1; C.Copy(); return a,b
            end
            local clock=function()
                probes=probes+1
                if mode=="throw" or (mode=="start throw" and probes==2) or
                    (mode=="mid throw" and probes==4) or (mode=="end throw" and probes==19) then
                    error("PRIVATE-CLOCK-PAYLOAD")
                end
                if mode=="nan" or (mode=="mid nan" and probes==4) then return 0/0 end
                if mode=="infinity" then return math.huge end
                if mode=="type" then return "PRIVATE-CLOCK-TYPE" end
                if mode=="backward" and probes==4 then return -1 end
                return probes
            end
            local restored=timingRestoration(c)
            local a,b,r=Tests.MeasureScan(c,mode~="missing" and clock or nil); restored()
            eq(a,true); eq(b,"PRIVATE-REASON"); eq(scans,1); eq(work,1)
            eq(r.status,"unavailable"); eq(r.totalMs,nil); eq(r.otherMs,nil); eq(r.stages,nil)
            local expected=mode=="missing" and "clock missing" or
                ((mode=="throw" or mode=="start throw" or mode=="mid throw" or mode=="end throw") and "clock error" or
                (mode=="backward" and "clock backward" or "clock nonfinite"))
            eq(r.reason,expected); eq(probes,mode=="missing" and 0 or
                (mode=="start throw" and 2 or (mode=="end throw" and 19 or
                ((mode=="backward" or mode=="mid throw" or mode=="mid nan") and 4 or 1))))
            eq(Tests.FormatScanTiming(r),"scan2 timings unavailable ("..expected..")"); privateTimingReport(r)
        end
    end)
end)
case("K4 zero-resolution clock is observed but finite arithmetic overflow is unavailable",function()
    timingFixture(function(c)
        local restored=timingRestoration(c)
        local a,b,r=Tests.MeasureScan(c,function() return 0 end); restored()
        eq(a,true); eq(b,"PRIVATE-REASON"); eq(r.status,"observed"); eq(r.totalMs,0)
        for _,tag in ipairs(timingTags) do eq(r.stages[tag].calls,1); eq(r.stages[tag].exclusiveMs,0) end
        c.Scan=function() return true end
        local reads=0
        a,b,r=Tests.MeasureScan(c,function() reads=reads+1; return reads<=2 and -1e308 or 1e308 end)
        restored(); eq(a,true); eq(b,nil); eq(r.status,"unavailable"); eq(r.reason,"invalid partition")
        eq(r.totalMs,nil); eq(r.stages,nil); privateTimingReport(r)
    end)
end)
case("K4 probe cap stops observation at 10000 without skipping original tiny calls",function()
    timingFixture(function(c)
        local calls,probes=0,0
        C.Copy=function() calls=calls+1 end
        c.Scan=function() for _=1,5001 do C.Copy() end; return true,"PRIVATE-CAP" end
        local restored=timingRestoration(c)
        local a,b,r=Tests.MeasureScan(c,function() probes=probes+1; return probes end); restored()
        eq(a,true); eq(b,"PRIVATE-CAP"); eq(calls,5001); eq(probes,10000)
        eq(r.status,"unavailable"); eq(r.reason,"probe cap"); eq(r.stages,nil); privateTimingReport(r)
    end)
end)
case("K4 depth cap bounds active frames and original recursive stub still finishes",function()
    timingFixture(function(c)
        local calls=0
        C.Copy=function(n) calls=calls+1; if n>1 then return C.Copy(n-1) end; return "leaf",nil,false end
        local depth=63
        c.Scan=function() local a,b,d=C.Copy(depth); eq(a,"leaf"); eq(b,nil); eq(d,false); return true end
        local restored=timingRestoration(c)
        local a,_,r=Tests.MeasureScan(c,tickClock()); restored()
        eq(a,true); eq(calls,63); eq(r.status,"observed"); eq(r.stages.C.calls,63)
        depth=70; calls=0
        a,_,r=Tests.MeasureScan(c,tickClock()); restored()
        eq(a,true); eq(calls,70); eq(r.status,"unavailable"); eq(r.reason,"depth cap")
        eq(r.totalMs,nil); eq(r.stages,nil); privateTimingReport(r)
    end)
end)
case("K4 repeated measurements have independent primitive reports and bounded private notes",function()
    timingFixture(function(c)
        local restored=timingRestoration(c)
        local _,_,a=Tests.MeasureScan(c,tickClock()); restored()
        local _,_,b=Tests.MeasureScan(c,tickClock()); restored()
        assert(a~=b); assert(a.stages~=b.stages); assert(a.stages.C~=b.stages.C)
        eq(a.totalMs,b.totalMs); eq(a.stages.C.calls,1); eq(b.stages.C.calls,1)
        a.stages.C.calls=999; eq(b.stages.C.calls,1); privateTimingReport(b)
        for _,n in ipairs({99999,99999.01,1e308}) do
            b.totalMs=n; b.otherMs=n
            for _,tag in ipairs(timingTags) do b.stages[tag].exclusiveMs=n end
            local note=Tests.FormatScanTiming(b)
            assert(#note<=112); assert(not note:find("[|%c]")); assert(not note:find("PRIVATE",1,true))
            assert(note:find(n>99999 and "T=>99999" or "T=99999.0",1,true))
        end
        for _,bad in ipairs({false,{status="unavailable",reason="PRIVATE|\001"},{status="observed"},
            setmetatable({status="observed"},{})}) do
            local note=Tests.FormatScanTiming(bad); eq(note,"scan2 timings unavailable (invalid report)")
        end
        b.totalMs=0/0; eq(Tests.FormatScanTiming(b),"scan2 timings unavailable (invalid report)")
    end)
end)
case("K4 runner annotations last clean note normal fail reset and unchanged unannotated output",function()
    local r=Tests.NewRunner({
        {name="noted",fn=function(cp,annotate) annotate("discard"); cp("boundary"); annotate("last|\001note") end},
        {name="plain",fn=function() end},
        {name="noted fail",fn=function(_,annotate) annotate(string.rep("z",200)); error("fixture failure",0) end},
    })
    r:Step(); eq(r.steps,1); eq(r.label,"boundary"); eq(r.passed,0)
    r:Step(); eq(r.steps,2); eq(r.passed,1); eq(r.lastLine,"PASS noted; last  note")
    eq(r.label,"case return; last  note")
    r:Step(); eq(r.steps,3); eq(r.lastLine,"PASS plain"); eq(r.label,"case return")
    r:Step(); eq(r.steps,4); eq(r.failed,1); eq(r.passed,2); eq(r.completed,true)
    eq(#r.label,128); eq(r.lastLine,"FAIL noted fail: fixture failure; "..string.rep("z",128))
    r:Step(); eq(r.steps,4); eq(r.lastLine,nil)
    r=Tests.NewRunner({{name="cancel note",fn=function(cp,annotate) annotate("retired"); cp("paused") end}})
    r:Step(); r:Cancel(); r:Step(); eq(r.label,"paused"); eq(r.passed,0); eq(#r.lines,0)
end)
case("K4 annotation rejects shared overrides and measurement restores before note without extra steps",function()
    for _,which in ipairs({"apply","evaluate"}) do
        local apply,evaluate=C.Apply,K.Evaluate; local continued=false
        local r=Tests.NewRunner({{name="guard",fn=function(_,annotate)
            if which=="apply" then C.Apply=function() end else K.Evaluate=function() end end
            local ok,why=pcall(function() annotate("must not escape"); continued=true end)
            C.Apply=apply; K.Evaluate=evaluate
            assert(ok,why)
        end}})
        r:Step(); eq(C.Apply,apply); eq(K.Evaluate,evaluate)
        eq(continued,false); eq(r.failed,1); eq(r.steps,1); eq(r.label,"case return")
        assert(r.lastLine:find("unsafe annotation",1,true))
    end
    local r=Tests.NewRunner({{name="after cleanup",fn=function(_,annotate)
        local report
        timingFixture(function(c)
            local restored=timingRestoration(c)
            local a,b; a,b,report=Tests.MeasureScan(c,tickClock()); restored(); eq(a,true)
        end)
        annotate(Tests.FormatScanTiming(report))
    end}})
    r:Step(); eq(r.steps,1); eq(r.passed,1); eq(r.completed,true)
    assert(r.label:find("case return; scan2 ms excl T=",1,true)); assert(r.lastLine:find("; scan2 ms excl T=",1,true))
end)
case("K4 unchanged command normal fail and slow-stop retain annotated final identity counts",function()
    for _,mode in ipairs({"normal","fail","slow","slow fail"}) do
        local state; local calls=0; local note="scan2 timings unavailable (clock missing)"
        local cmd,_,s=schedulerFixture({{name="annotated atomic",fn=function(_,annotate)
            calls=calls+1; annotate(note)
            if mode=="slow" or mode=="slow fail" then state.now=state.now+101 end
            if mode=="fail" or mode=="slow fail" then error("fixture failure",0) end
        end}})
        state=s; local r=cmd:Run("selftest"); s:Tick()
        local slow=mode=="slow" or mode=="slow fail"
        local fail=mode=="fail" or mode=="slow fail"
        s:CheckStopped(slow and "incomplete" or "complete")
        eq(calls,1); eq(r.steps,1); eq(r.passed,fail and 0 or 1); eq(r.failed,fail and 1 or 0)
        eq(cmd.selftestSummary.total,1); eq(cmd.selftestSummary.index,1); eq(cmd.selftestSummary.unit,1)
        eq(cmd.selftestSummary.label,"case return; "..note)
        assert(cmd.selftestSummary.maxIdentity:find("[case return; "..note.."]",1,true))
        local text=table.concat(s.chat,"\n")
        assert(text:find("[case return; "..note.."]",1,true))
        if mode=="slow" then assert(not text:find("PASS annotated atomic",1,true))
        else assert(text:find((fail and "FAIL " or "PASS ").."annotated atomic",1,true)) end
        eq(cmd.selftestSummary.maxUnit,slow and 101 or 0)
        local n=#s.chat; s:Tick(); eq(#s.chat,n); eq(calls,1); eq(r.steps,1)
    end
end)

-- K5 additions ONLY: all preceding 134 definitions/helpers remain byte-frozen.
do
local Core=C
-- Exact pre-K5 Copy body, with only the declaration renamed; TEST-ONLY oracle.
local function k5OldCopy(value)
    local seen, count = {}, 0
    local function copy(v, depth)
        count = count + 1
        if count > 50000 or depth > 20 then error("data traversal limit") end
        local kind = type(v)
        if kind == "nil" or kind == "boolean" then return v end
        if kind == "number" and Core.Finite(v) then return v end
        if kind == "string" and #v <= 4096 then return v end
        if kind ~= "table" or getmetatable(v) or seen[v] then error("invalid/cyclic data") end
        seen[v] = true
        local out = {}
        for k, x in pairs(v) do
            if not ((type(k) == "string" and #k <= 128) or Core.Integer(k, 0)) then
                error("invalid key")
            end
            out[k] = copy(x, depth + 1)
        end
        seen[v] = nil
        return out
    end
    local ok, result = pcall(copy, value, 0)
    if ok then return result end
    return nil, tostring(result)
end
-- Exact pre-K5 gear algorithm, only declaration/callee names renamed. Its merge
-- oracle is the unchanged PUBLIC Core.Merge, never the new private owned path.
local function k5SameInstance(a,b)
    return type(a)=="table" and type(b)=="table" and a.exists==true and b.exists==true and
        Core.Integer(a.slot,1) and a.slot==b.slot and Core.Integer(a.itemID,1) and a.itemID==b.itemID and
        type(a.link)=="string" and a.link:match("item:%d+:%d+:")~=nil and a.link==b.link
end
local k5Success={observed=true,empty=true,not_applicable=true}
local function k5OldGear(previous, observation, build, generation)
    if k5Success[observation.status] then return Core.Merge(previous,observation,build,generation) end
    local last=previous and previous.last
    if last and k5SameInstance(last.value,observation.value) then
        -- Whole unit and successful timestamp remain coherent; no subfield borrowing.
        return Core.Merge(previous,observation,build,generation)
    end
    -- A changed/removed/unidentifiable instance cannot inherit the prior metadata.
    -- Keep only this scan's known existence/partial evidence, with a failed attempt.
    local out,why=Core.Merge(nil,observation,build,generation)
    if not out then return nil,why end
    if observation.value~=nil then
        local current=Core.Merge(nil,Core.Observation("observed",observation.value,
            observation.attemptedAt,observation.source),build,generation)
        if not current then return nil,"Invalid current equipment unit" end
        out.last=current.last
    end
    return out
end
local function k5Parity(value,invalid)
    local old,oldWhy=k5OldCopy(value)
    local new,newWhy=C.Copy(value)
    eq(type(new),type(old)); assert(deepEqual(new,old),"frozen Copy result parity")
    if invalid then
        eq(new,nil); assert(oldWhy:find(invalid,1,true)); assert(newWhy:find(invalid,1,true))
    else eq(oldWhy,nil); eq(newWhy,nil) end
    return new
end
local function k5Graph(value,invalid)
    k5Parity(value,invalid)
    local db={schema=1,characters={},extra=value}
    local verify=unchangedGraph(db)
    local old=k5OldCopy(db)
    local opened=C.Open(db)
    eq(opened~=nil,old~=nil,"Open vs frozen graph acceptance")
    verify()
end
local function k5Fill(t,n,checkpoint)
    for i=1,n do
        t[i]=0
        if i%1000==0 then pause(checkpoint,"K5 bounded fixture setup") end
    end
end
local function k5WithCopy(replacement,fn)
    local original=C.Copy
    C.Copy=replacement
    local ok,why=pcall(fn) -- NEVER checkpoint while this binding is installed.
    C.Copy=original
    assert(ok,why)
end
local function k5CountCopies(fn)
    local original,calls=C.Copy,{}
    k5WithCopy(function(value)
        calls[#calls+1]=value
        return original(value)
    end,fn)
    return calls
end

case("K5 frozen Copy oracle preserves public nil false zero alias expansion and isolation",function()
    eq(k5Parity(nil),nil); eq(k5Parity(false),false); eq(k5Parity(0),0)
    k5Parity(true); k5Parity(""); k5Parity(-3.5)
    local shared={flag=false,zero=0,nested={label="owned"}}
    local input={a=shared,b=shared,[0]="zero key",[2.5e1]="integer key"}
    local copy=k5Parity(input)
    assert(copy~=input and copy.a~=shared and copy.a~=copy.b and copy.a.nested~=copy.b.nested)
    input.a.nested.label="caller"; eq(copy.a.nested.label,"owned")
    copy.a.nested.label="candidate"; eq(copy.b.nested.label,"owned"); eq(shared.nested.label,"caller")
end)

case("K5 frozen graph oracle string key type metatable and cycle guards match check-only Open",function(checkpoint)
    local variants={
        {function() return string.rep("s",4096) end},
        {function() return string.rep("s",4097) end,"invalid/cyclic data"},
        {function() return {[string.rep("k",128)]=false} end},
        {function() return {[string.rep("k",129)]=false} end,"invalid key"},
        {function() return {[-1]=0} end,"invalid key"},
        {function() return {[1.5]=0} end,"invalid key"},
        {function() return {[true]=0} end,"invalid key"},
        {function() return {[{}]=0} end,"invalid key"},
        {function() return {[math.huge]=0} end,"invalid key"},
        {function() return function() end end,"invalid/cyclic data"},
        {function() return coroutine.create(function() end) end,"invalid/cyclic data"},
        {function() return setmetatable({},{}) end,"invalid/cyclic data"},
        {function() return setmetatable({},{__metatable="locked"}) end,"invalid/cyclic data"},
        {function() return setmetatable({},{__metatable=false}) end}, -- frozen truthiness semantics
        {function() local t={}; t.self=t; return t end,"invalid/cyclic data"},
        {function() local a,b={},{}; a.b=b; b.a=a; return a end,"invalid/cyclic data"},
    }
    for _,variant in ipairs(variants) do
        pause(checkpoint,"K5 graph guard variant")
        k5Graph(variant[1](),variant[2])
    end
end)

case("K5 actual native nonfinite samples reject Copy Open and owned incoming without mutation",function(checkpoint)
    for _,sample in ipairs(nonfiniteSamples()) do
        pause(checkpoint,"K5 actual nonfinite variant")
        k5Parity(sample.value,"invalid/cyclic data")
        local db={schema=1,characters={},extra=sample.value}; local characters=db.characters
        local text=tostring(db.extra); eq(C.Open(db),nil); eq(db.characters,characters); eq(tostring(db.extra),text)
        local clean=C.Open(nil); local verify=unchangedGraph(clean)
        local obs={unspent=C.Observation("observed",sample.value,20,"fixture")}
        local observation=obs.unspent
        eq(C.Apply(clean,character,identity,obs,20,"fixture"),nil); verify()
        eq(obs.unspent,observation); eq(tostring(observation.value),text)
    end
end)

case("K5 frozen walker exact50000 and50001 visits agree with Copy and check-only Open",function(checkpoint)
    local db={schema=1,characters={},padding={}}
    k5Fill(db.padding,49996,checkpoint) -- root + schema + characters + padding = 4
    eq(k2ValueCount(db),50000); pause(checkpoint,"K5 exact count")
    assert(k5OldCopy(db)); pause(checkpoint,"K5 exact old Copy")
    assert(C.Copy(db)); pause(checkpoint,"K5 exact public Copy")
    eq(C.Open(db),db); pause(checkpoint,"K5 exact check-only Open")
    db.padding[49997]=0
    local old,why=k5OldCopy(db); eq(old,nil); assert(why:find("data traversal limit",1,true))
    pause(checkpoint,"K5 excess old Copy")
    local new,why=C.Copy(db); eq(new,nil); assert(why:find("data traversal limit",1,true))
    pause(checkpoint,"K5 excess public Copy")
    eq(C.Open(db),nil); eq(#db.padding,49997)
end)

case("K5 frozen walker counts repeated aliases per occurrence at50000 and50001",function(checkpoint)
    local shared={}; k5Fill(shared,12000,checkpoint)
    local db={schema=1,characters={},a=shared,b=shared,padding={}}
    k5Fill(db.padding,25994,checkpoint) -- 6 + 2*12000 + 25994
    eq(k2ValueCount(db),50000); pause(checkpoint,"K5 expanded alias count")
    local old=k5OldCopy(db); assert(old); assert(old.a~=old.b)
    pause(checkpoint,"K5 expanded alias old Copy")
    local new=C.Copy(db); assert(new); assert(new.a~=new.b and new.a~=shared)
    pause(checkpoint,"K5 expanded alias public Copy")
    eq(C.Open(db),db); pause(checkpoint,"K5 expanded alias Open")
    db.padding[25995]=0
    eq(k5OldCopy(db),nil); pause(checkpoint,"K5 expanded alias excess oracle")
    eq(C.Copy(db),nil); pause(checkpoint,"K5 expanded alias excess Copy")
    eq(C.Open(db),nil); eq(db.a,shared); eq(db.b,shared)
end)

case("K5 frozen walker depth20 fits and21 fails in public and check-only modes",function()
    local extra=0
    for _=1,19 do extra={extra} end
    local db={schema=1,characters={},extra=extra}
    assert(k5OldCopy(db)); assert(C.Copy(db)); eq(C.Open(db),db)
    db.extra={extra}
    k5Parity(db,"data traversal limit"); eq(C.Open(db),nil); eq(db.extra[1],extra)
end)

case("K5 Open needs no discarded Copy output but still rejects graph typed and archive damage",function()
    local db=dbWith({unspent=0}); local verify=unchangedGraph(db)
    local original=C.Copy
    k5WithCopy(function() error("discarded Copy must not be called",0) end,function()
        eq(C.Open(db),db); verify()
        db.extra={}; db.extra.loop=db.extra; eq(C.Open(db),nil); db.extra=nil
        local g=db.characters[character.guid].professions[2913].active
        g.fields.unspent.last.value=false; eq(C.Open(db),nil); g.fields.unspent.last.value=0
        local p=db.characters[character.guid].professions[2913]
        local archives=p.archives
        p.archives={g}; eq(C.Open(db),nil); p.archives=archives
        eq(C.Open(db),db); verify()
    end)
    eq(C.Copy,original)
    local ok=pcall(function()
        k5WithCopy(function() error("trap",0) end,function() error("intentional finally exercise",0) end)
    end)
    eq(ok,false); eq(C.Copy,original); eq(C.Open(db),db)
end)

case("K5 small Apply retains exactly inputpack and whole oldcharacter clones not per-field copies",function(checkpoint)
    local values=payloadFixtures()
    for _,count in ipairs({1,6}) do
        for _,existing in ipairs({false,true}) do
            pause(checkpoint,"K5 clone-count setup")
            local db=existing and dbWith(values) or C.Open(nil)
            local old=db.characters[character.guid]
            local observations={}
            for i,key in ipairs({"unspent","skill","moxie","tool","slots","environment"}) do
                if i<=count then observations[key]=C.Observation("observed",values[key],20,"fixture") end
            end
            local g
            local calls=k5CountCopies(function() g=assert(C.Apply(db,character,identity,observations,20,"fixture")) end)
            eq(#calls,existing and 2 or 1,"constant ownership clones")
            eq(calls[1][1],character); eq(calls[1][2],identity); eq(calls[1][3],observations)
            if existing then eq(calls[2],old) end
            assert(g.identity~=identity); eq(C.Open(db),db)
        end
    end
end)

case("K5 whole candidate input identity observation archive and otherprofession ownership is bidirectional",function(checkpoint)
    local db,archivedReturned=dbWith(payloadFixtures())
    assert(C.Archive(db,character.guid,2913,15,"fixture"))
    pause(checkpoint,"K5 ownership archive")
    local oldg=assert(C.Apply(db,character,identity,{unspent=C.Observation("observed",8,20,"fixture")},20,"fixture"))
    local old=db.characters[character.guid]
    old.userMetadata={nested={note="old"}}
    old.professions[2914]={nextGeneration=1,archives={},note={text="other profession"}}
    db.savedCharacter=old
    local ch=C.Copy(character); ch.extra={note="character input"}
    local id=C.Copy(identity); id.extra={note="identity input"}
    local obs={skill=C.Observation("observed",payloadFixtures().skill,30,"fixture")}
    local oldVerify,inputVerify=unchangedGraph(old),unchangedGraph({ch,id,obs})
    pause(checkpoint,"K5 ownership inputs ready")
    local g=assert(C.Apply(db,ch,id,obs,30,"new-build"))
    oldVerify(); inputVerify(); eq(db.savedCharacter,old)
    local candidate=db.characters[character.guid]; local p=candidate.professions[2913]
    assert(candidate~=old and g~=oldg and g.identity~=id and p.archives~=old.professions[2913].archives)
    assert(p.archives[1]~=old.professions[2913].archives[1])
    assert(candidate.professions[2914]~=old.professions[2914])
    ch.name="caller"; id.name="caller"; id.extra.note="caller"
    obs.skill.value.skillLevel=99; obs.skill.status="error"; obs.skill.attemptedAt=99
    oldg.fields.unspent.last.value=9
    old.userMetadata.nested.note="caller"; old.professions[2914].note.text="caller"
    old.professions[2913].archives[1].fields.unspent.last.value=7
    archivedReturned.fields.unspent.last.value=6
    eq(candidate.name,"Fixture"); eq(g.identity.name,"Inscription"); eq(g.identity.extra.note,"identity input")
    eq(g.fields.skill.last.value.skillLevel,0); eq(g.fields.unspent.last.value,8)
    eq(g.fields.skill.attempt.status,"observed"); eq(g.fields.skill.attempt.attemptedAt,30)
    eq(candidate.userMetadata.nested.note,"old"); eq(candidate.professions[2914].note.text,"other profession")
    eq(p.archives[1].fields.unspent.last.value,0)
    g.identity.extra.note="candidate"; g.fields.skill.last.value.skillLevel=22
    g.fields.skill.attempt.status="unknown"; g.fields.skill.attempt.attemptedAt=31
    g.fields.unspent.last.value=3; candidate.userMetadata.nested.note="candidate"
    candidate.professions[2914].note.text="candidate"; p.archives[1].fields.unspent.last.value=2
    eq(id.extra.note,"caller"); eq(obs.skill.value.skillLevel,99); eq(oldg.fields.unspent.last.value,9)
    eq(obs.skill.status,"error"); eq(obs.skill.attemptedAt,99)
    eq(old.userMetadata.nested.note,"caller"); eq(old.professions[2914].note.text,"caller")
    eq(old.professions[2913].archives[1].fields.unspent.last.value,7)
    eq(C.Open(db),db)
end)

case("K5 cross-input and cross-field aliases expand independently including retained prior fields",function()
    local shared={version="fixture",locale="fixture",skillLevel=0,maxSkillLevel=100,skillModifier=0,nested={flag=false}}
    local observation=C.Observation("observed",shared,20,"fixture")
    local id=C.Copy(identity); id.extra=shared
    local db=C.Open(nil)
    local g=assert(C.Apply(db,character,id,{skill=observation,environment=observation},20,"fixture"))
    local a,b=g.fields.skill.last.value,g.fields.environment.last.value
    assert(a~=b and a~=shared and a.nested~=b.nested and g.identity.extra~=a and g.identity.extra~=b)
    a.nested.flag=true; eq(b.nested.flag,false); eq(shared.nested.flag,false); eq(g.identity.extra.nested.flag,false)
    -- Legal old DB aliases must ALSO expand in the retained whole-character clone.
    g.fields.environment=g.fields.skill
    local old=g.fields.skill
    local nextg=assert(C.Apply(db,character,identity,{},30,"fixture"))
    assert(nextg.fields.skill~=nextg.fields.environment and nextg.fields.skill~=old)
    nextg.fields.skill.last.value.nested.flag=false
    eq(nextg.fields.environment.last.value.nested.flag,true); eq(old.last.value.nested.flag,true)
end)

case("K5 owned scalar merge parity with unchanged public Merge for every status zero nil and stale",function(checkpoint)
    for _,status in ipairs({"observed","empty","not_applicable","unknown","unsupported","error"}) do
        for _,hasValue in ipairs({false,true}) do
            for _,hasPrevious in ipairs({false,true}) do
                pause(checkpoint,"K5 scalar Merge oracle variant")
                local db,g=dbWith(hasPrevious and {unspent=8} or {})
                local obs=C.Observation(status,hasValue and 0 or nil,30,"fixture","reason")
                local verify=unchangedGraph({g,obs})
                local expected=C.Merge(g.fields.unspent,obs,"new-build",g.generation)
                local result=C.Apply(db,character,identity,{unspent=obs},30,"new-build")
                verify()
                if expected then
                    assert(result); assert(deepEqual(result.fields.unspent,expected))
                else eq(result,nil) end
            end
        end
    end
    -- Generic public false/nil behavior remains independent of typed Apply rules.
    local observed=C.Merge(nil,C.Observation("observed",false,1,"fixture"),"fixture",1)
    eq(observed.last.value,false)
    local retained=C.Merge(observed,C.Observation("unknown",nil,2,"fixture"),"fixture",1)
    eq(retained.last.value,false); eq(retained.last.observedAt,1); eq(retained.attempt.attemptedAt,2)
end)

case("K5 every gear status same changed removed unidentified and nil branch matches frozen gear Merge oracle",function(checkpoint)
    for _,key in ipairs({"tool","accessory1","accessory2","slot33"}) do
        for _,status in ipairs({"observed","empty","not_applicable","unknown","unsupported","error"}) do
            for _,mode in ipairs({"same","changed ID","changed link","unidentified","removed","nil"}) do
                for _,hasPrevious in ipairs({false,true}) do
                pause(checkpoint,"K5 gear Merge oracle variant")
                local value=C.Copy(payloadFixtures().tool)
                value.slot=key=="slot33" and 33 or 20; value.role=key
                if key=="slot33" then value.role=nil end
                local db,g=dbWith(hasPrevious and {[key]=value} or {}); local previous=g.fields[key]
                local incoming=C.Copy(value); incoming.stats=nil; incoming.rarity=nil; incoming.rank=nil
                incoming.metadataReady=false
                if mode=="changed ID" then incoming.itemID=90021; incoming.link="item:90021:0:0"
                elseif mode=="changed link" then incoming.link="item:90020:1:0"
                elseif mode=="unidentified" then incoming.itemID=nil; incoming.link=nil
                elseif mode=="removed" then incoming={slot=value.slot,role=value.role,exists=false,metadataReady=false}
                elseif mode=="nil" then incoming=nil end
                local obs=C.Observation(status,incoming,30,"fixture","pending")
                local verify=unchangedGraph({previous,obs})
                local expected=k5OldGear(previous,obs,"new-build",1)
                local result=C.Apply(db,character,identity,{[key]=obs},30,"new-build")
                verify()
                if status=="observed" and incoming==nil then eq(result,nil)
                else assert(result); assert(deepEqual(result.fields[key],expected),key.." / "..status.." / "..mode) end
                end
            end
        end
    end
end)

case("K5 malformed owned input shape identity generation build and typed guards reject graph-identically",function(checkpoint)
    local mutations={
        function(p) p[1].guid="" end,
        function(p) p[1].name=true end,
        function(p) p[2].expansionID=0 end,
        function(p) p[2].name=false end,
        function(p) p[2].parentID=774 end,
        function(p) p[3].unspent.status="bad" end,
        function(p) p[3].unspent.attemptedAt=-1 end,
        function(p) p[3].unspent.source=false end,
        function(p) p[3].unspent.reason={} end,
        function(p) p[3].unspent.value=nil end,
        function(p) p[3].unspent.value=false end,
        function(p) p[3].unspent.value=function() end end,
        function(p) p[3].unspent.loop=p[3].unspent end,
        function(p) setmetatable(p[3].unspent,{}) end,
        function(p) p[4]=-1 end,
        function(p) p[5]=false end,
        function(p) p[5]=string.rep("b",4097) end,
        function(_,db) db.characters[character.guid].professions[2913].nextGeneration=1 end,
        function(_,db) db.characters[character.guid].professions[2913].active.generation=0 end,
        function(_,db) db.characters[character.guid].professions[2913].active.fields.unspent.last.value=false end,
    }
    for _,mutate in ipairs(mutations) do
        pause(checkpoint,"K5 atomic invalid variant")
        local db=dbWith({unspent=8})
        local input={C.Copy(character),C.Copy(identity),{unspent=C.Observation("observed",0,30,"fixture")},30,"fixture"}
        mutate(input,db)
        local verify=unchangedGraph({db,input})
        eq(C.Apply(db,input[1],input[2],input[3],input[4],input[5]),nil); verify()
    end
end)

case("K5 owned candidate still enforces native scope after individually typed raw payload passes",function()
    local raw={policy="native-rank-reconciled-v1",identity=C.Copy(identity),nativeComplete=false,tabsComplete=false,tabs={}}
    eq(C.ValidPayload("knowledgeRaw",raw,"observed"),true)
    local foreign=C.Copy(identity); foreign.skillLineID=2914
    local db=C.Open(nil); local obs={knowledgeRaw=C.Observation("observed",raw,30,"fixture")}
    local verify=unchangedGraph({db,obs,foreign})
    local result,why=C.Apply(db,character,foreign,obs,30,"fixture")
    eq(result,nil); eq(why,"Invalid candidate generation/scope"); verify()
end)

case("K5 Archive retains actual generation Copy and relearn reload isolates old returned generations",function(checkpoint)
    local db,g=dbWith({unspent=0,slots={indices={20},complete=false}})
    local calls=k5CountCopies(function() assert(C.Archive(db,character.guid,2913,20,"fixture")) end)
    eq(#calls,1); eq(calls[1],g)
    local archive=db.characters[character.guid].professions[2913].archives[1]
    assert(archive~=g and archive.fields~=g.fields)
    g.fields.unspent.last.value=9; eq(archive.fields.unspent.last.value,0)
    archive.fields.slots.last.value.indices[1]=21; eq(g.fields.slots.last.value.indices[1],20)
    eq(C.Open(db),db); pause(checkpoint,"K5 archived reload")
    local nextg=assert(C.Apply(db,character,identity,{},30,"fixture"))
    eq(nextg.generation,2); eq(next(nextg.fields),nil)
    local retained=db.characters[character.guid].professions[2913].archives[1]
    assert(retained~=archive); archive.fields.unspent.last.value=7; eq(retained.fields.unspent.last.value,0)
    retained.fields.slots.last.value.complete=true; eq(archive.fields.slots.last.value.complete,false)
    eq(C.Open(db),db)
end)
end

-- U01 BEGIN: additive focused-hover regressions; old cases/runner stay intact.
do
local V=NS.ViewModel
local function uiFixture(values)
    local env,state=fixtureAPI(); mockWidgets(env)
    local db,g=dbWith(values or payloadFixtures())
    local collector=NS.Collectors.New(env,db)
    local ui=NS.Dashboard.New(env,collector); ui:Toggle()
    return ui,env,collector,g,state
end
local function contains(text,part) assert(text:find(part,1,true),"missing hover text: "..part.." in "..text) end
local function excludes(text,part) assert(not text:find(part,1,true),"unexpected hover text: "..part.." in "..text) end
local function hover(ui,env,target,shift)
    env.IsShiftKeyDown=function() return shift end
    local widget=type(target)=="number" and ui.widgets[1].cells[target] or target
    widget.scripts.OnEnter(widget)
    local tip=env.GameTooltip
    local first=tip.nativeLink and 3 or 1
    local text=table.concat(tip.lines,"\n",first)
    if not shift then
        assert(#tip.lines-first+1<=(widget.tree and 65 or 16),"default addon line budget")
        for _,part in ipairs({"Raw status:","Generation ","Source pin:","Slot 20","key ITEM_","Shared currency ",
            "attempted ","scan timestamp ","Path 106","TRADE_SKILL_CLOSE"}) do excludes(text,part) end
    end
    return text,widget
end
-- U02: these summaries still test model semantics, NOT rendered normal tooltips.
local function normalSummary(ui,env,col)
    if col~=I.Moxie and col~=I.Unspent and col~=I.LastUpdated and col~=I.Stat and col~=I.Enchant then
        return hover(ui,env,col,false)
    end
    env.GameTooltip.calls={}
    eq(hover(ui,env,col,false),""); eq(env.GameTooltip.shown,false)
    eq(#env.GameTooltip.calls,1); eq(env.GameTooltip.calls[1],"clear")
    local lines={}
    for _,line in ipairs(ui.rows[1].cellTooltips[col]) do lines[#lines+1]=NS.Dashboard.PlainTooltip(line) end
    return table.concat(lines,"\n")
end
local function stableGraph(root)
    local records={}
    local function visit(t)
        if type(t)~="table" or records[t] then return end
        local saved={}; records[t]=saved
        for k,v in pairs(t) do saved[k]=v; visit(v) end
    end
    visit(root)
    return function()
        for t,saved in pairs(records) do
            for k,v in pairs(saved) do eq(t[k],v,"source value/reference unchanged") end
            for k in pairs(t) do assert(saved[k]~=nil,"no source key added") end
        end
    end
end
case("U01 status concise default raw Shift and unknown blocking reasons stay truthful",function()
    local ui,env,c=uiFixture()
    for _,sample in ipairs({{raw="TRADE_SKILL_CLOSE",friendly="Profession closed"},
        {raw="unsupported: readiness API missing",friendly="unsupported: readiness API missing"},
        {raw="Guarded snapshot collected; knowledge cost eligibility pending evidence.",block="Future schema: writes disabled",friendly="Future schema: writes disabled"}}) do
        c.reason=sample.raw; c.blockReason=sample.block
        local verify=stableGraph({c.db,c.fresh})
        local normal=hover(ui,env,ui.statusArea,false)
        -- U15 ADAPT STATUS_HINT BEGIN
--[============[U15 ORIGINAL BEGIN
        contains(normal,sample.friendly); contains(normal,"Shift-hover for diagnostics.")
        eq(#env.GameTooltip.lines,2); excludes(normal,"Blocked:")
U15 ORIGINAL END]============]
        contains(normal,sample.friendly); excludes(normal,"Shift-hover for diagnostics.")
        eq(#env.GameTooltip.lines,1); excludes(normal,"Blocked:")
        -- U15 ADAPT STATUS_HINT END
        local diagnostic=hover(ui,env,ui.statusArea,true)
        contains(diagnostic,"Raw status: "..sample.raw)
        if sample.block then contains(diagnostic,"Blocked: "..sample.block) end
        eq(c.reason,sample.raw); eq(c.blockReason,sample.block); verify()
    end
end)
case("U01 full identity default and original row diagnostic Shift are separate",function()
    -- U15 ADD LITERAL_LABELS BEGIN
    do
        local values=payloadFixtures()
        values.knowledgeIndex[1].name="Observed Attention tree"
        values["tree:11"].name="Observed Attention tree"
        values["tree:11"].paths[1].name="Attention: Observed branch"
        local ui,env,c=uiFixture(values)
        local char=c.db.characters[character.guid]
        char.name="Observed Attention"; char.realm="Attention: Observed"
        char.professions[2913].active.identity.name="Observed Attention profession"
        ui:Refresh()
        local verify=stableGraph({c.db,c.fresh,ui.rows})
        for _,col in ipairs({I.Name,I.Realm,I.Profession}) do
            local text=hover(ui,env,col,false)
            eq(#env.GameTooltip.lines,3)
            contains(text,"Observed Attention"); contains(text,"Attention: Observed")
            excludes(text,"Shift-hover")
        end
        local text=hover(ui,env,I.Knowledge,false)
        contains(text,"Observed Attention tree: 0/10"); excludes(text,"ago."); excludes(text,"Shift-hover")
        eq(hover(ui,env,ui.widgets[1].bars[1],false),"Attention: Observed branch: 0/10")
        verify()
    end
    -- U15 ADD LITERAL_LABELS END
    local ui,env,c=uiFixture()
    local char=c.db.characters[character.guid]
    char.name=string.rep("LongCharacter",20); char.realm=string.rep("LongRealm",20)
    char.professions[2913].active.identity.name=string.rep("LongProfession ",20)
    ui:Refresh(); local r=ui.rows[1]; local verify=stableGraph({c.db,c.fresh,r.tooltip})
    for _,col in ipairs({I.Name,I.Realm,I.Profession}) do
        local normal=hover(ui,env,col,false)
        eq(env.GameTooltip.lines[1],r.name); eq(env.GameTooltip.lines[2],r.realm); eq(env.GameTooltip.lines[3],r.profession)
        excludes(normal,"concentration:"); excludes(normal,"Skill modifier:")
        local diagnostic=hover(ui,env,col,true)
        contains(diagnostic,r.name.."-"..r.realm); contains(diagnostic,"Generation 1; scan timestamp 10")
        contains(diagnostic,"unspent: observed; attempted 10; observed 10")
        eq(env.GameTooltip.nativeLink,nil)
    end
    verify()
end)
case("U01 numeric fields show own observed amounts modifier cap freshness and warning only",function()
    -- U15 ADD CONCISE BEGIN
    do
        local ui,env,c=uiFixture({skill={skillLevel=37,maxSkillLevel=100,skillModifier=40},
            concentration={id=50001,quantity=950,maxQuantity=1000,rechargingCycleDurationMS=1000,rechargingAmountPerCycle=1}})
        local verify=stableGraph({c.db,c.fresh,ui.rows})
        for _,target in ipairs({ui.statusArea,I.Name,I.Realm,I.Profession,I.Skill,I.Knowledge,I.Concentration}) do
            local normal=hover(ui,env,target,false)
            for _,text in ipairs({"Shift-hover for diagnostics.","Attention:","Observed 1m ago.","Approximate; assumes"}) do excludes(normal,text) end
        end
        local diagnostic=hover(ui,env,I.Concentration,true)
        contains(diagnostic,"Approximate; assumes no spending and unchanged recharge rate. Not a live read.")
        contains(diagnostic,"concentration: observed; attempted 10; observed 10")
        verify()
    end
    -- U15 ADD CONCISE END
    -- U15 ADD CONC_MODES BEGIN
    do
        for _,mode in ipairs({"gain","noGain","full","projectedFull","invalidRate","archive"}) do
            local value={id=50001,quantity=100,maxQuantity=1000,rechargingCycleDurationMS=1000,rechargingAmountPerCycle=1}
            if mode=="full" then value.quantity=1000
            elseif mode=="invalidRate" then value.rechargingAmountPerCycle=0 end
            local ui,env,c,_,state=uiFixture({concentration=value})
            if mode=="noGain" then state.at=10 elseif mode=="projectedFull" then state.at=10000 end
            if mode=="archive" then assert(C.Archive(c.db,character.guid,2913,90,"U15")); ui.options.archived=true; ui:Refresh() end
            local verify=stableGraph({c.db,c.fresh,ui.rows})
            local cell=ui.widgets[1].cells[I.Concentration]
            local label,bar=cell.label:GetText(),cell.bar.value
            local text=hover(ui,env,I.Concentration,false)
            contains(text,"Concentration: "..value.quantity.."/1000")
            excludes(text,"Approximate;"); excludes(text,"Attention:"); excludes(text,"Shift-hover"); excludes(text,"ago.")
            if mode=="invalidRate" or mode=="archive" then contains(text,"Estimate unavailable:")
            else
                contains(text,"Estimated now: ~"..((mode=="full" or mode=="projectedFull") and "1000" or mode=="noGain" and "100" or "190").."/1000")
                contains(text,"Estimated full in:")
            end
            local function forbidden() error("U15 Shift must not read clock or estimate") end
            c.Now=forbidden; local helper=V.ConcentrationEstimate; V.ConcentrationEstimate=forbidden
            local ok,why=pcall(function()
                for n=1,3 do
                    local detail=hover(ui,env,I.Concentration,true)
                    contains(detail,"Approximate; assumes no spending and unchanged recharge rate. Not a live read.")
                    contains(detail,"concentration: observed; attempted 10; observed 10")
                    excludes(detail,"Estimated now:")
                end
            end)
            V.ConcentrationEstimate=helper; assert(ok,why)
            eq(cell.label:GetText(),label); eq(cell.bar.value,bar)
            eq(ui.rows[1].sortValues[I.Concentration],value.quantity); eq(ui.rows[1].concentration,value.quantity)
            verify()
        end
    end
    -- U15 ADD CONC_MODES END
    -- U09 HOVER BEGIN
    do
        local ui,env,c,g,s=uiFixture({concentration={id=50001,quantity=100,maxQuantity=1000,
            rechargingCycleDurationMS=2000,rechargingAmountPerCycle=2}})
        local row=ui.rows[1]; local cell=ui.widgets[1].cells[I.Concentration]
        local verify=stableGraph({c.db,c.fresh,row}); local reads,requests,timers=s.reads,s.requests,#s.timers
        local function forbidden() error("U09 hover cannot collect") end
        c.Scan=forbidden; c.Request=forbidden; c.Context=forbidden; c.Login=forbidden
        local now=c.Now; local clocks=0
        c.Now=function(self) clocks=clocks+1; return now(self) end
        local text=hover(ui,env,I.Concentration,false)
        contains(text,"Concentration: 100/1000"); contains(text,"Estimated now: ~190/1000")
        -- U15 ADAPT CONC_ASSUMPTIONS BEGIN
--[============[U15 ORIGINAL BEGIN
        contains(text,"Estimated full in: 14m"); contains(text,"Approximate"); contains(text,"no spending")
        contains(text,"unchanged recharge rate"); contains(text,"Not a live read")
U15 ORIGINAL END]============]
        contains(text,"Estimated full in: 14m"); excludes(text,"Approximate"); excludes(text,"no spending")
        excludes(text,"unchanged recharge rate"); excludes(text,"Not a live read")
        local assumptions=hover(ui,env,I.Concentration,true)
        contains(assumptions,"Approximate; assumes no spending and unchanged recharge rate. Not a live read.")
        -- U15 ADAPT CONC_ASSUMPTIONS END
        s.at=110; text=hover(ui,env,I.Concentration,false); contains(text,"Estimated now: ~200/1000")
        s.at=910; text=hover(ui,env,I.Concentration,false); contains(text,"Estimated now: ~1000/1000")
        -- U15 ADAPT CONC_AGE BEGIN
--[============[U15 ORIGINAL BEGIN
        contains(text,"Estimated full in: 0m"); contains(text,"Observed 15m ago.")
U15 ORIGINAL END]============]
        contains(text,"Estimated full in: 0m"); excludes(text,"Observed 15m ago.")
        contains(hover(ui,env,I.Concentration,true),"observed 10")
        -- U15 ADAPT CONC_AGE END
        -- U13 ADAPT U09_HOVER_LABEL BEGIN
--[==========[U13 ORIGINAL BEGIN
        eq(cell.bar.value,.1); eq(cell.label:GetText(),"100/1000"); eq(row.concentration,100)
U13 ORIGINAL END]==========]
        eq(cell.bar.value,.1); eq(cell.label:GetText(),"~190/1000"); eq(row.concentration,100)
        -- U13 ADAPT U09_HOVER_LABEL END
        eq(row.sortValues[I.Concentration],100); eq(row.priority,3); eq(#row.warnings,0)
        local beforeClocks=clocks; local diagnostic=hover(ui,env,I.Concentration,true)
        eq(clocks,beforeClocks); excludes(diagnostic,"Estimated now:"); contains(diagnostic,"observed 10")
        for _,mode in ipairs({"nil","throw","backward","fraction","infinite"}) do
            c.Now=function()
                if mode=="throw" then error("U09_PRIVATE_CLOCK") end
                return ({backward=9,fraction=10.5,infinite=math.huge})[mode]
            end
            local normal=hover(ui,env,I.Concentration,false)
            contains(normal,"Concentration: 100/1000"); contains(normal,"Estimate unavailable:")
            excludes(normal,"U09_PRIVATE_CLOCK"); excludes(normal,"Estimated now:")
        end
        c.Now=now
        local helper=V.ConcentrationTooltip
        V.ConcentrationTooltip=function() error("U09_PRIVATE_HELPER") end
        local ok,why=pcall(function()
            local normal=hover(ui,env,I.Concentration,false)
            contains(normal,"Concentration: 100/1000"); excludes(normal,"U09_PRIVATE_HELPER")
        end)
        V.ConcentrationTooltip=helper; assert(ok,why)
        verify(); eq(s.reads,reads); eq(s.requests,requests); eq(#s.timers,timers)
        -- Successful field time10 remains the baseline after an independent failed attempt80.
        assert(C.Apply(c.db,character,identity,{concentration=C.Observation("error",nil,80,"U09","PRIVATE")},80,"fixture"))
        s.at=140; ui:Refresh(); local normal=hover(ui,env,I.Concentration,false)
        -- U15 ADAPT CONC_STALE BEGIN
--[============[U15 ORIGINAL BEGIN
        contains(normal,"Estimated now: ~230/1000"); contains(normal,"Stale: refresh unavailable; last observed 2m ago.")
U15 ORIGINAL END]============]
        contains(normal,"Estimated now: ~230/1000"); contains(normal,"Stale: refresh unavailable.")
        contains(hover(ui,env,I.Concentration,true),"attempted 80; observed 10")
        -- U15 ADAPT CONC_STALE END
        excludes(normal,"PRIVATE"); eq(ui.rows[1].concentrationState.observedAt,10)
        local replacement={id=50001,quantity=400,maxQuantity=1000,rechargingCycleDurationMS=4000,rechargingAmountPerCycle=1}
        assert(C.Apply(c.db,character,identity,{concentration=C.Observation("observed",replacement,130,"U09")},130,"fixture"))
        ui:Refresh(); normal=hover(ui,env,I.Concentration,false); contains(normal,"Estimated now: ~402/1000")
        -- U15 ADAPT CONC_REPLACEMENT_AGE BEGIN
--[============[U15 ORIGINAL BEGIN
        contains(normal,"Estimated full in: 40m"); contains(normal,"Observed 10s ago.")
U15 ORIGINAL END]============]
        contains(normal,"Estimated full in: 40m"); excludes(normal,"Observed 10s ago.")
        contains(hover(ui,env,I.Concentration,true),"observed 130")
        -- U15 ADAPT CONC_REPLACEMENT_AGE END
        assert(C.Archive(c.db,character.guid,2913,139,"U09")); ui.options.archived=true; ui:Refresh()
        normal=hover(ui,env,I.Concentration,false); contains(normal,"Estimate unavailable: archived snapshot")
        -- U15 ADAPT CONC_ARCHIVE BEGIN
--[============[U15 ORIGINAL BEGIN
        contains(normal,"Archived snapshot; last observed 10s ago."); excludes(normal,"Estimated now:")
U15 ORIGINAL END]============]
        contains(normal,"Archived snapshot."); excludes(normal,"Estimated now:")
        contains(hover(ui,env,I.Concentration,true),"Archived 139: U09")
        -- U15 ADAPT CONC_ARCHIVE END
        local noRate,env2=uiFixture({concentration={id=50002,quantity=0,maxQuantity=1000}})
        contains(hover(noRate,env2,I.Concentration,false),"Estimate unavailable: recharge metadata unavailable")
        eq(noRate.widgets[1].cells[I.Concentration].label:GetText(),"0/1000")
        local unknown,env3=uiFixture({})
        contains(hover(unknown,env3,I.Concentration,false),"Concentration: Not observed")
        contains(hover(unknown,env3,I.Concentration,false),"Estimate unavailable:")
        -- ETA rounds positive seconds UP, retaining unrounded full time after display floor.
        for _,sample in ipairs({{quantity=0,maxQuantity=1,rechargingCycleDurationMS=1000,rechargingAmountPerCycle=2,eta="1m"},
            {quantity=0,maxQuantity=3601,rechargingCycleDurationMS=1000,rechargingAmountPerCycle=1,eta="1h 1m"},
            {quantity=0,maxQuantity=86401,rechargingCycleDurationMS=1000,rechargingAmountPerCycle=1,eta="1d 0h 1m"}}) do
            local v=assert(C.Copy(sample)); v.eta=nil; v.id=50001
            local u,e,_,_,state=uiFixture({concentration=v}); state.at=10
            contains(hover(u,e,I.Concentration,false),"Estimated full in: "..sample.eta)
        end
    end
    -- U09 HOVER END
    local values=payloadFixtures(); values.skill={skillLevel=37,maxSkillLevel=100,skillModifier=40}
    values.concentration={id=50001,quantity=950,maxQuantity=1000}; values.moxie={id=3261,quantity=601}
    local ui,env,c,g=uiFixture(values)
    c.fresh={[character.guid..":2913"]={generation=g.generation,fields={skill=true,concentration=true,moxie=true,unspent=true}}}
    ui:Refresh(); local verify=stableGraph({c.db,c.fresh})
    for _,sample in ipairs({{I.Skill,"37/100","Skill modifier: 40","Progression"},
        {I.Concentration,"Concentration: 950/1000",nil,"Concentration"},
        {I.Moxie,"Moxie: 601",nil,"Moxie"},{I.Unspent,"Unspent knowledge: 0"}}) do
        local normal=normalSummary(ui,env,sample[1])
        contains(normal,sample[2]); if sample[3] then contains(normal,sample[3]) end
        -- U15 ADAPT NUMERIC_NORMAL BEGIN
--[============[U15 ORIGINAL BEGIN
        contains(normal,"Current observation; observed 1m ago.")
        if sample[4] then contains(normal,"Attention: confirmed "..sample[4]) end
U15 ORIGINAL END]============]
        excludes(normal,"Current observation; observed 1m ago."); excludes(normal,"Attention:")
        if sample[4] then contains(hover(ui,env,sample[1],true),"confirmed "..sample[4]) end
        -- U15 ADAPT NUMERIC_NORMAL END
        for _,other in ipairs({"Moxie: 601","Concentration: 950/1000","Profession skill: 37/100","Unspent knowledge: 0"}) do
            if not other:find(sample[2],1,true) then excludes(normal,other) end
        end
        local diagnostic=hover(ui,env,sample[1],true)
        contains(diagnostic,"observed 10; fresh guarded read"); contains(diagnostic,"scan timestamp 10")
    end
    local normal=normalSummary(ui,env,I.LastUpdated); contains(normal,"Last scan: 1m ago."); contains(normal,"Current guarded observations.")
    contains(hover(ui,env,I.LastUpdated,true),"scan timestamp 10"); verify()
end)
case("U01 independent stale saved archived field ages never use attempt or retirement times",function()
    -- U15 ADD COMPACT_STATUS BEGIN
    do
        local ui,env,c,g=uiFixture(payloadFixtures())
        local row=ui.rows[1]
        for _,col in ipairs({I.Skill,I.Concentration,I.Moxie,I.Unspent,I.Knowledge}) do
            local lines=row.cellTooltips[col]; local count=0
            for _ in pairs(lines) do count=count+1 end
            eq(count,#lines,"U15 dense known summary")
            local text=table.concat(lines,"\n")
            excludes(text,"ago."); excludes(text,"Attention:"); excludes(text,"unavailable")
        end
        assert(C.Apply(c.db,character,identity,{skill=C.Observation("error",nil,80,"U15","U15_STATUS_FAILURE"),
            ["tree:11"]=C.Observation("error",nil,80,"U15","U15_TREE_FAILURE")},80,"fixture"))
        ui:Refresh()
        contains(hover(ui,env,I.Skill,false),"Stale: refresh unavailable.")
        contains(hover(ui,env,I.Knowledge,false),"0/10; Stale: refresh unavailable.")
        contains(hover(ui,env,I.Skill,true),"U15_STATUS_FAILURE")
        contains(hover(ui,env,ui.widgets[1].bars[1],true),"U15_TREE_FAILURE")
        assert(C.Archive(c.db,character.guid,2913,90,"U15")); ui.options.archived=true; ui:Refresh()
        contains(hover(ui,env,I.Skill,false),"Archived snapshot.")
        contains(hover(ui,env,I.Knowledge,false),"0/10; Archived snapshot.")
        local u,e=uiFixture({})
        for _,col in ipairs({I.Skill,I.Knowledge,I.Concentration}) do
            contains(hover(u,e,col,false),"Observation unavailable.")
        end
    end
    -- U15 ADD COMPACT_STATUS END
    local values=payloadFixtures(); values.moxie.quantity=601
    local ui,env,c,_,s=uiFixture(values)
    assert(C.Apply(c.db,character,identity,{unspent=C.Observation("observed",0,70,"fixture")},70,"fixture"))
    assert(C.Apply(c.db,character,identity,{moxie=C.Observation("error",nil,80,"fixture","PRIVATE_RAW_FAILURE")},80,"fixture"))
    s.at=140; c.fresh={[character.guid..":2913"]={generation=1,fields={unspent=true,moxie=true}}}; ui:Refresh()
    local text=normalSummary(ui,env,I.Moxie)
    -- U15 ADAPT MOXIE_STALE BEGIN
--[============[U15 ORIGINAL BEGIN
    contains(text,"Stale: refresh unavailable; last observed 2m ago."); contains(text,"last observed Moxie")
U15 ORIGINAL END]============]
    contains(text,"Stale: refresh unavailable."); excludes(text,"last observed Moxie")
    contains(hover(ui,env,I.Moxie,true),"last observed Moxie")
    -- U15 ADAPT MOXIE_STALE END
    excludes(text,"PRIVATE_RAW_FAILURE"); excludes(text,"Current")
    -- U15 ADAPT UNSPENT_FRESH BEGIN
--[============[U15 ORIGINAL BEGIN
    contains(normalSummary(ui,env,I.Unspent),"Current observation; observed 1m ago.")
U15 ORIGINAL END]============]
    excludes(normalSummary(ui,env,I.Unspent),"Current observation; observed 1m ago.")
    contains(hover(ui,env,I.Unspent,true),"observed 70; fresh guarded read")
    -- U15 ADAPT UNSPENT_FRESH END
    text=normalSummary(ui,env,I.LastUpdated); contains(text,"Last scan: 1m ago."); contains(text,"Stale snapshot")
    text=hover(ui,env,I.Moxie,true); contains(text,"attempted 80; observed 10"); contains(text,"PRIVATE_RAW_FAILURE")
    -- U15 ADAPT UNSPENT_SAVED BEGIN
--[============[U15 ORIGINAL BEGIN
    c.fresh={}; ui:Refresh(); contains(normalSummary(ui,env,I.Unspent),"Observed 1m ago.")
U15 ORIGINAL END]============]
    c.fresh={}; ui:Refresh(); excludes(normalSummary(ui,env,I.Unspent),"Observed 1m ago.")
    contains(hover(ui,env,I.Unspent,true),"observed 70; snapshot/last observed")
    -- U15 ADAPT UNSPENT_SAVED END
    assert(C.Archive(c.db,character.guid,2913,130,"fixture retirement")); ui.options.archived=true; ui:Refresh()
    local verify=stableGraph({c.db,c.fresh})
    -- U15 ADAPT MOXIE_ARCHIVE BEGIN
--[============[U15 ORIGINAL BEGIN
    text=normalSummary(ui,env,I.Moxie); contains(text,"Archived snapshot; last observed 2m ago."); excludes(text,"Attention:")
U15 ORIGINAL END]============]
    text=normalSummary(ui,env,I.Moxie); contains(text,"Archived snapshot."); excludes(text,"Attention:")
    contains(hover(ui,env,I.Moxie,true),"attempted 80; observed 10")
    -- U15 ADAPT MOXIE_ARCHIVE END
    text=normalSummary(ui,env,I.LastUpdated); contains(text,"Last scan: 1m ago."); contains(text,"Archived snapshot.")
    -- U15 ADAPT GEAR_ARCHIVE BEGIN
--[============[U15 ORIGINAL BEGIN
    contains(hover(ui,env,I.Accessory2,false),"Archived snapshot; not observed.")
U15 ORIGINAL END]============]
    eq(hover(ui,env,I.Accessory2,false),"Item unknown; data unavailable.")
    contains(hover(ui,env,I.Accessory2,true),"Archived snapshot; not observed.")
    -- U15 ADAPT GEAR_ARCHIVE END
    contains(hover(ui,env,I.LastUpdated,true),"Archived 130: fixture retirement"); eq(#ui.rows[1].warnings,0); verify()
end)
case("U01 unknown zero confirmed empty and independent quality rarity remain distinct",function()
    local ui,env=uiFixture({unspent=0,concentration={id=50001,quantity=0},moxie={id=3261,quantity=0},
        accessory1={slot=21,role="accessory1",exists=false,metadataReady=false},
        tool={slot=20,role="tool",exists=true,metadataReady=false,itemID=90020,rank=5}})
    contains(normalSummary(ui,env,I.Unspent),"Unspent knowledge: 0")
    contains(hover(ui,env,I.Concentration,false),"Concentration: 0"); excludes(hover(ui,env,I.Concentration,false),"0/0")
    contains(hover(ui,env,I.Skill,false),"Not observed")
    contains(hover(ui,env,I.Accessory1,false),"Empty slot (confirmed)")
    contains(hover(ui,env,I.Accessory2,false),"Item unknown")
    -- U15 ADAPT NO_LINK BEGIN
--[============[U15 ORIGINAL BEGIN
    local tool=hover(ui,env,I.Tool,false); contains(tool,"Rarity: Unknown"); contains(tool,"Crafted quality: 5")
U15 ORIGINAL END]============]
    eq(hover(ui,env,I.Tool,false),"Item link unavailable.")
    local tool=hover(ui,env,I.Tool,true); contains(tool,"Rarity: Unknown"); contains(tool,"Crafted quality: 5")
    -- U15 ADAPT NO_LINK END
    contains(normalSummary(ui,env,I.Enchant),"Enchant unknown; item data unavailable.")
    contains(hover(ui,env,I.Knowledge,false),"Tree observations unavailable.")
    for _,col in ipairs({I.Skill,I.Accessory1,I.Accessory2,I.Tool,I.Enchant,I.Concentration,I.Moxie,I.Unspent,I.Knowledge}) do
        assert(#hover(ui,env,col,true)>0)
    end
    local unknown,otherEnv=uiFixture({})
    -- U15 ADAPT UNKNOWN_CURRENCY BEGIN
--[============[U15 ORIGINAL BEGIN
    contains(normalSummary(unknown,otherEnv,I.Unspent),"Not observed."); excludes(normalSummary(unknown,otherEnv,I.Unspent),"knowledge: 0")
U15 ORIGINAL END]============]
    contains(normalSummary(unknown,otherEnv,I.Unspent),"Observation unavailable."); excludes(normalSummary(unknown,otherEnv,I.Unspent),"knowledge: 0")
    contains(hover(unknown,otherEnv,I.Unspent,true),"No snapshot: unspent")
    -- U15 ADAPT UNKNOWN_CURRENCY END
end)
case("U01 native gear only preserves third party content order hide and clears stale links",function()
    -- U15 ADD NATIVE_ONLY BEGIN
    do
        local values=payloadFixtures()
        for _,role in ipairs({"accessory1","accessory2"}) do
            values[role]=C.Copy(values.tool); values[role].role=role; values[role].slot=role=="accessory1" and 21 or 22
        end
        local ui,env,c=uiFixture(values)
        local verify=stableGraph({c.db,c.fresh,ui.rows})
        for _,col in ipairs({I.Accessory1,I.Accessory2,I.Tool}) do
            local tip=env.GameTooltip; tip.calls={}
            local text=hover(ui,env,col,false)
            eq(text,"","U15 normal equipped gear adds zero lines")
            eq(#tip.lines,2); eq(#tip.calls,3)
            eq(tip.calls[1],"clear"); eq(tip.calls[2],"owner"); eq(tip.calls[3],"hyperlink")
            eq(tip.lines[1],"Native item: "..values.tool.link)
            eq(tip.lines[2],"Third-party BIS |A:Native-BIS:12:12|a")
            local diagnostic=hover(ui,env,col,true)
            contains(diagnostic,"Rarity: Rare"); contains(diagnostic,"Crafted quality: 5")
            contains(diagnostic,"attempted 10; observed 10")
        end
        verify()
    end
    -- U15 ADD NATIVE_ONLY END
    -- U15 ADD GEAR_STATES BEGIN
    do
        local columns={I.Accessory1,I.Accessory2,I.Tool}
        for index,role in ipairs({"accessory1","accessory2","tool"}) do
            local values=payloadFixtures(); local item=C.Copy(values.tool)
            item.role=role; item.slot=({21,22,20})[index]; values[role]=item
            local ui,env,c,_,state=uiFixture(values); local cell=ui.widgets[1].cells[columns[index]]
            local reads,requests,timers=state.reads,state.requests,#state.timers
            local queries=0
            local function forbidden() queries=queries+1; error("U15 gear hover acquisition") end
            c.Scan=forbidden; c.Request=forbidden; c.Context=forbidden; c.Login=forbidden
            env.UnitGUID=forbidden; env.GetProfessions=forbidden
            for _,api in ipairs({env.C_Item,env.C_ProfSpecs,env.C_Traits}) do for key in pairs(api) do api[key]=forbidden end end
            local tip=env.GameTooltip; local native=tip.SetHyperlink
            tip.SetHyperlink=function(w,link)
                native(w,link)
                w.lines[1]="Observed native Attention: |A:Native-Quality:12:12|a "..link
                w.lines[2]="Attention: third-party Observed |A:Native-BIS:12:12|a"
            end
            for n,mode in ipairs({"equipped","empty","noLink","notApplicable","equipped"}) do
                if mode~="equipped" or n>1 then
                    local value=C.Copy(item); local status="observed"
                    if mode=="empty" then value={slot=item.slot,role=role,exists=false,metadataReady=false}
                    elseif mode=="noLink" then value.link=nil; value.metadataReady=false; value.itemExpansion=nil; value.toolStat=nil
                    elseif mode=="notApplicable" then status="not_applicable"; value=nil end
                    assert(C.Apply(c.db,character,identity,{[role]=C.Observation(status,value,20+n,"U15")},20+n,"fixture"))
                    ui:Refresh()
                end
                eq(ui.widgets[1].cells[columns[index]],cell,"U15 reused gear widget")
                local verify=stableGraph({c.db,c.fresh,ui.rows})
                local queriesBefore=queries
                local normal=hover(ui,env,columns[index],false)
                if mode=="equipped" then
                    eq(normal,""); eq(#tip.lines,2)
                    eq(tip.lines[1],"Observed native Attention: |A:Native-Quality:12:12|a "..item.link)
                    eq(tip.lines[2],"Attention: third-party Observed |A:Native-BIS:12:12|a")
                else
                    eq(tip.nativeLink,nil); eq(#tip.lines,1)
                    contains(normal,({empty="Empty slot (confirmed).",noLink="Item link unavailable.",notApplicable="Not applicable."})[mode])
                end
                local detail=hover(ui,env,columns[index],true)
                contains(detail,"attempted "); contains(detail,"observed ")
                if mode=="equipped" or mode=="noLink" then
                    contains(detail,"Rarity: Rare"); contains(detail,"Crafted quality: 5"); contains(detail,"Item expansion: unknown")
                    if role=="tool" then contains(detail,"Multicraft: 0"); contains(detail,"Enchant: no") end
                end
                if mode=="equipped" then
                    eq(tip.nativeLink,item.link)
                    eq(tip.lines[1],"Observed native Attention: |A:Native-Quality:12:12|a "..item.link)
                    eq(tip.lines[2],"Attention: third-party Observed |A:Native-BIS:12:12|a")
                end
                verify(); eq(queries,queriesBefore); cell.scripts.OnLeave(cell); eq(tip.shown,false)
            end
            -- Restore query spies only for Refresh; no hover may invoke them.
            env.UnitGUID=nil; ui:Refresh()
            assert(C.Archive(c.db,character.guid,2913,40,"U15")); ui.options.archived=true; ui:Refresh()
            local queriesBefore=queries
            eq(hover(ui,env,columns[index],false),"")
            contains(hover(ui,env,columns[index],true),"Archived snapshot;")
            eq(queries,queriesBefore)
            eq(state.reads,reads); eq(state.requests,requests); eq(#state.timers,timers)
            local u,e=uiFixture({}); eq(hover(u,e,columns[index],false),"Item unknown; data unavailable.")
            eq(e.GameTooltip.nativeLink,nil); eq(#e.GameTooltip.lines,1)
        end
    end
    -- U15 ADD GEAR_STATES END
    local values=payloadFixtures()
    for _,role in ipairs({"accessory1","accessory2"}) do
        values[role]=C.Copy(values.tool); values[role].role=role; values[role].slot=role=="accessory1" and 21 or 22
    end
    local ui,env=uiFixture(values); local tip=env.GameTooltip
    for _,shift in ipairs({false,true}) do
        for _,col in ipairs({I.Accessory1,I.Accessory2,I.Tool}) do
            tip.calls={}; local text=hover(ui,env,col,shift)
            -- U15 ADAPT GEAR_NORMAL_CHANNEL BEGIN
--[============[U15 ORIGINAL BEGIN
            if not shift then contains(text,"Rarity: Rare"); contains(text,"Crafted quality: 5") end
            eq(tip.calls[1],"clear"); eq(tip.calls[2],"owner"); eq(tip.calls[3],"hyperlink"); eq(tip.calls[4],"append")
U15 ORIGINAL END]============]
            if shift then contains(text,"Rarity: Rare"); contains(text,"Crafted quality: 5"); eq(tip.calls[4],"append")
            else eq(text,""); eq(#tip.calls,3); eq(#tip.lines,2) end
            eq(tip.calls[1],"clear"); eq(tip.calls[2],"owner"); eq(tip.calls[3],"hyperlink")
            -- U15 ADAPT GEAR_NORMAL_CHANNEL END
            eq(tip.nativeLink,values.tool.link); eq(tip.lines[2],"Third-party BIS |A:Native-BIS:12:12|a")
            for _,nextCol in ipairs({I.Stat,I.Enchant,I.Name}) do
                tip.calls={}; local _,widget=hover(ui,env,nextCol,shift)
                eq(tip.nativeLink,nil); eq(tip.calls[1],"clear")
                if not shift and nextCol~=I.Name then eq(#tip.calls,1); eq(tip.shown,false)
                else eq(tip.calls[2],"owner"); eq(tip.calls[3],"append"); eq(tip.owner,widget) end
                widget.scripts.OnLeave(widget); eq(tip.shown,false)
            end
        end
        hover(ui,env,I.Tool,shift); local header=ui.headers[I.Accessory1]; header.scripts.OnEnter(header)
        -- U10 ADAPT U01_GEAR_HOVER BEGIN
--[====[U10 ORIGINAL BEGIN
        eq(tip.nativeLink,nil); eq(#tip.lines,1); eq(tip.lines[1],"Accessory #1"); header.scripts.OnLeave(header); eq(tip.shown,false)
U10 ORIGINAL END]====]
        eq(tip.nativeLink,nil); eq(#tip.lines,1); eq(tip.lines[1],"Gear"); header.scripts.OnLeave(header); eq(tip.shown,false)
        -- U10 ADAPT U01_GEAR_HOVER END
    end
end)
case("U01 tool stats full names amounts unknown keys and enchant observed text attribution",function()
    local values=payloadFixtures()
    values.tool.stats={ITEM_MOD_MULTICRAFT_SHORT=152,ITEM_MOD_RESOURCEFULNESS_SHORT=12,ITEM_MOD_PRIVATE_STAT=7}
    values.tool.enchant={status="observed",present=true,id=8005,category="Multicraft"}
    values.tool.enchantLines={{leftText="Enchanted: |A:Rank-3:16|a Haranir",rightText=" "},
        {leftText="Observed second text",rightText="Observed third text"},{leftText="Observed fourth text"}}
    local ui,env=uiFixture(values)
    for _,col in ipairs({I.Tool,I.Stat}) do
        -- U15 ADAPT STAT_CHANNEL BEGIN
--[============[U15 ORIGINAL BEGIN
        local text=normalSummary(ui,env,col)
        contains(text,"Multicraft: 152"); contains(text,"Resourcefulness: 12"); contains(text,"Unknown stat: 7")
        contains(text,"Observed totals; base/enchant split unknown."); excludes(text,"ITEM_MOD_PRIVATE_STAT")
U15 ORIGINAL END]============]
        local text=col==I.Tool and hover(ui,env,col,true) or normalSummary(ui,env,col)
        contains(text,"Multicraft: 152"); contains(text,"Resourcefulness: 12"); contains(text,"Unknown stat: 7")
        contains(text,"Observed totals; base/enchant split unknown.")
        if col==I.Tool then eq(hover(ui,env,col,false),"") else excludes(text,"ITEM_MOD_PRIVATE_STAT") end
        -- U15 ADAPT STAT_CHANNEL END
        contains(hover(ui,env,col,true),"key ITEM_MOD_PRIVATE_STAT")
    end
    for _,col in ipairs({I.Tool,I.Enchant}) do
        -- U15 ADAPT ENCHANT_CHANNEL BEGIN
--[============[U15 ORIGINAL BEGIN
        local text=normalSummary(ui,env,col)
        contains(text,"Enchanted: Multicraft; amount/rank unknown."); contains(text,"Enchanted:  Haranir")
        contains(text,"Observed second text"); contains(text,"2 more enchant text lines on Shift-hover.")
        excludes(text,"Observed third text"); excludes(text,"8005"); excludes(text,"Rank-3")
U15 ORIGINAL END]============]
        local text=col==I.Tool and hover(ui,env,col,true) or normalSummary(ui,env,col)
        contains(text,"Enchanted: Multicraft; amount/rank unknown."); contains(text,"Enchanted:  Haranir")
        contains(text,"Observed second text"); contains(text,"2 more enchant text lines on Shift-hover.")
        if col==I.Tool then eq(hover(ui,env,col,false),""); contains(text,"Observed third text"); contains(text,"8005")
        else excludes(text,"Observed third text"); excludes(text,"8005") end
        excludes(text,"Rank-3")
        -- U15 ADAPT ENCHANT_CHANNEL END
        text=hover(ui,env,col,true); contains(text,"ID 8005"); contains(text,"Observed fourth text"); contains(text,"observed 10")
    end
end)
case("U01 enchant states unknown unmapped absent no tool never infer amounts or ranks",function(checkpoint)
    for _,mode in ipairs({"known","absent","empty","notApplicable","unloaded","unknown","unmapped"}) do
        pause(checkpoint,"U01 focused enchant variant")
        local values=payloadFixtures()
        if mode=="known" then values.tool.enchant={status="observed",present=true,id=8005,category="Multicraft"}
        elseif mode=="empty" then values.tool={slot=20,role="tool",exists=false,metadataReady=false}
        elseif mode=="unloaded" then values.tool.metadataReady=false
        elseif mode=="unknown" then values.tool.enchant={status="unknown",reason="PRIVATE_ENCHANT_REASON"}
        elseif mode=="unmapped" then values.tool.enchant={status="observed",present=true,id=9999} end
        local ui,env,c=uiFixture(values)
        if mode=="notApplicable" then assert(C.Apply(c.db,character,identity,{tool=C.Observation("not_applicable",nil,20,"fixture")},20,"fixture")); ui:Refresh() end
        local text=normalSummary(ui,env,I.Enchant)
        if mode=="known" then contains(text,"Enchanted: Multicraft; amount/rank unknown.")
        -- U15 ADAPT ENCHANT_ATTENTION BEGIN
--[============[U15 ORIGINAL BEGIN
        elseif mode=="absent" then contains(text,"No enchant (confirmed)."); contains(text,"Attention: last observed Missing enchant")
U15 ORIGINAL END]============]
        elseif mode=="absent" then contains(text,"No enchant (confirmed)."); excludes(text,"Attention:")
            contains(hover(ui,env,I.Enchant,true),"Attention: last observed Missing enchant")
        -- U15 ADAPT ENCHANT_ATTENTION END
        elseif mode=="empty" or mode=="notApplicable" then contains(text,"No tool; enchant not applicable."); excludes(text,"Attention:")
        elseif mode=="unmapped" then contains(text,"Enchanted: Unknown stat; amount/rank unknown."); excludes(text,"9999")
        else contains(text,"Enchant unknown"); excludes(text,"No enchant (confirmed)."); excludes(text,"PRIVATE_ENCHANT_REASON") end
        contains(hover(ui,env,I.Enchant,true),"tool:")
    end
end)
case("U01 native tree all individual branches without default prose full Shift evidence",function()
    local env,_,_,c=k2Fixture(); mockWidgets(env); assert(c:Scan())
    local ui=NS.Dashboard.New(env,c); ui:Toggle(); local verify=stableGraph({c.db,c.fresh})
    for n,tree in ipairs(ui.rows[1].trees) do
        local bar=ui.widgets[1].bars[n]
        local normal=hover(ui,env,bar,false)
        excludes(normal,"Purchased/capacity:"); excludes(normal,"Future point costs are unverified.")
        excludes(normal,"Main branch:"); excludes(normal,"Shift-hover")
        local paths=c.db.characters[character.guid].professions[2913].active.fields["tree:"..tree.id].last.value.paths
        eq(#env.GameTooltip.lines,#paths)
        local depths={[paths[1].id]=0}
        for i,p in ipairs(paths) do
            local depth=assert(depths[p.id])
            eq(env.GameTooltip.lines[i],string.rep("  ",depth).."Unknown branch: "..p.purchased.."/"..p.capacity)
            for _,child in ipairs(p.children or {}) do depths[child]=depth+1 end
        end
        if n==1 then
            contains(normal,"Unknown branch: 0/30"); eq(#paths,9)
            excludes(normal,"106192"); excludes(normal,"3902")
        end
        local detail=hover(ui,env,bar,true)
        contains(detail,"Source pin:"); contains(detail,"Shared currency 3902"); contains(detail,"Observed tree at 100")
        if n==1 then contains(detail,"Path 106184"); assert(#env.GameTooltip.lines>16,"diagnostics not truncated") end
        bar.scripts.OnLeave(bar); eq(env.GameTooltip.shown,false)
    end
    local normal=hover(ui,env,I.Knowledge,false); contains(normal,"Knowledge trees: 4"); contains(normal,"Unspent knowledge is shown separately.")
    contains(hover(ui,env,I.Knowledge,true),"knowledgeRaw:"); verify()
end)
case("U01 stale tree keeps old totals name and age while unknown raw stays unknown",function()
    local values=payloadFixtures(); values["tree:11"].name="Last known tree"; values["tree:11"].purchased=4
    values["tree:11"].paths[1].purchased=4
    local ui,env,c=uiFixture(values)
    local currentRaw=C.Copy(values.knowledgeRaw); currentRaw.tabs[1].paths[72].node.ranksPurchased=29
    assert(C.Apply(c.db,character,identity,{["tree:11"]=C.Observation("unknown",nil,90,"fixture","PRIVATE_TREE_FAILURE"),
        knowledgeRaw=C.Observation("observed",currentRaw,90,"fixture"),
        knowledgeIndex=C.Observation("observed",{{id=11,name="Current invalid raw label",root=111}},90,"fixture")},90,"fixture"))
    ui:Refresh(); local verify=stableGraph({c.db,c.fresh})
    local text=hover(ui,env,ui.widgets[1].bars[1],false)
    eq(ui.rows[1].trees[1].name,"Last known tree"); contains(text,"Unknown branch: 4/10"); contains(text,"Stale data")
    excludes(text,"29/")
    excludes(text,"Current invalid raw label"); excludes(text,"PRIVATE_TREE_FAILURE")
    contains(hover(ui,env,ui.widgets[1].bars[1],true),"PRIVATE_TREE_FAILURE"); verify()
    values["tree:11"]=nil; values.knowledgeRaw=currentRaw
    local other,e=uiFixture(values)
    text=hover(other,e,other.widgets[1].bars[1],false)
    contains(text,"Unknown branch: ?/?"); contains(text,"Branch observations unavailable."); excludes(text,"0/10"); excludes(text,"raw purchased")
    contains(hover(other,e,other.widgets[1].bars[1],true),"raw purchased=29")
end)
case("U01 absent false throwing nonboolean modifier always selects safe concise OnEnter",function()
    local ui,env=uiFixture()
    local targets={ui.statusArea,ui.widgets[1].cells[I.Name],ui.widgets[1].cells[I.Stat],ui.widgets[1].cells[I.Enchant],
        ui.widgets[1].cells[I.Tool],ui.widgets[1].bars[1]}
    for _,target in ipairs(targets) do
        hover(ui,env,target,false); local expected=C.Copy(env.GameTooltip.lines)
        for _,mode in ipairs({"absent","false","throw","number","string","table","noncallable"}) do
            if mode=="absent" then env.IsShiftKeyDown=nil
            elseif mode=="false" then env.IsShiftKeyDown=function() return false end
            elseif mode=="throw" then env.IsShiftKeyDown=function() error("PRIVATE_MODIFIER_ERROR") end
            elseif mode=="noncallable" then env.IsShiftKeyDown=true
            else local value=mode=="number" and 1 or mode=="string" and "true" or {}; env.IsShiftKeyDown=function() return value end end
            target.scripts.OnEnter(target); assert(deepEqual(env.GameTooltip.lines,expected),"safe modifier fallback: "..mode)
        end
    end
end)
case("U01 repeated hovers rebuilds preserve arrays state DB session and never accumulate",function()
    local ui,env,c,g=uiFixture()
    c.fresh={[character.guid..":2913"]={generation=1,fields={unspent=true}}}; ui:Refresh()
    local _,state=V.Field(g,"unspent",c.fresh[character.guid..":2913"])
    local verify=stableGraph({c.db,c.fresh,ui.rows[1].tooltip,ui.rows[1].gear.tool.tooltip,ui.rows[1].trees[1].tooltip})
    local originals={row=C.Copy(ui.rows[1].tooltip),tool=C.Copy(ui.rows[1].gear.tool.tooltip),tree=C.Copy(ui.rows[1].trees[1].tooltip)}
    for iteration=1,3 do
        for col=1,14 do
            local first=hover(ui,env,col,false); hover(ui,env,col,true); eq(hover(ui,env,col,false),first)
        end
        hover(ui,env,ui.widgets[1].bars[1],false); hover(ui,env,ui.widgets[1].bars[1],true)
        ui:Refresh(); verify()
        assert(deepEqual(ui.rows[1].tooltip,originals.row) and deepEqual(ui.rows[1].gear.tool.tooltip,originals.tool) and
            deepEqual(ui.rows[1].trees[1].tooltip,originals.tree),"diagnostic arrays stable across rebuild")
        local _,after=V.Field(g,"unspent",c.fresh[character.guid..":2913"]); assert(deepEqual(after,state),"V.Field diagnostic state unchanged")
    end
end)
case("U01 missing observation and scan times stay unknown rather than becoming now",function()
    local ui,env,c,g=uiFixture()
    local copy=C.Copy(g); copy.scannedAt=nil; copy.fields.unspent.last.observedAt=nil
    ui.rows={V.Row(character.guid,c.db.characters[character.guid],2913,copy,nil,100,false)}; ui:Render()
    local text=normalSummary(ui,env,I.LastUpdated); contains(text,"? age"); excludes(text,"0s")
    -- U15 ADAPT UNSPENT_UNKNOWN_TIME BEGIN
--[============[U15 ORIGINAL BEGIN
    text=normalSummary(ui,env,I.Unspent); contains(text,"? age"); excludes(text,"0s")
U15 ORIGINAL END]============]
    text=normalSummary(ui,env,I.Unspent); eq(text,"Unspent knowledge: 0"); excludes(text,"0s")
    -- U15 ADAPT UNSPENT_UNKNOWN_TIME END
    contains(hover(ui,env,I.Unspent,true),"observed ?")
end)
case("U01 all32 observed stat amounts remain within addon line budget without evidence loss",function()
    local values=payloadFixtures(); values.tool.stats={}
    for n=1,32 do values.tool.stats["ITEM_MOD_UNMAPPED_"..n]=1000+n end
    local ui,env=uiFixture(values)
    for _,col in ipairs({I.Tool,I.Stat}) do
        -- U15 ADAPT MANY_STATS_CHANNEL BEGIN
--[============[U15 ORIGINAL BEGIN
        local text=normalSummary(ui,env,col)
        for n=1,32 do contains(text,"Unknown stat: "..(1000+n)) end
        excludes(text,"ITEM_MOD_UNMAPPED_")
U15 ORIGINAL END]============]
        local text=col==I.Tool and hover(ui,env,col,true) or normalSummary(ui,env,col)
        for n=1,32 do contains(text,"Unknown stat: "..(1000+n)) end
        if col==I.Tool then eq(hover(ui,env,col,false),"") else excludes(text,"ITEM_MOD_UNMAPPED_") end
        -- U15 ADAPT MANY_STATS_CHANNEL END
        local diagnostic=hover(ui,env,col,true)
        contains(diagnostic,"key ITEM_MOD_UNMAPPED_32"); assert(#env.GameTooltip.lines>32,"diagnostics retain all stats")
    end
end)
case("U01 branch unknown availability missing observations zero capacity and archive stay honest",function()
    local values=payloadFixtures(); local tree=values["tree:11"]
    tree.capacity=0; tree.paths[1].capacity=0; tree.paths[1].node.isAvailable=nil
    values.knowledgeIndex[1].name=nil; tree.name=nil
    local ui,env,c,g=uiFixture(values)
    local text=hover(ui,env,ui.widgets[1].bars[1],false)
    eq(text,"Unknown branch: 0/0"); excludes(text,"availability")
    excludes(text,"999999"); excludes(text,"unlocked"); excludes(text,"spend-ready")
    -- A bounded projection-only missing-path input, never inserted into the valid DB.
    local projection=C.Copy(g); projection.fields["tree:11"].last.value.paths[1].children={999999}
    ui.rows={V.Row(character.guid,c.db.characters[character.guid],2913,projection,nil,100,false)}; ui:Render()
    text=hover(ui,env,ui.widgets[1].bars[1],false); contains(text,"Branch observations unavailable."); excludes(text,"999999")
    contains(hover(ui,env,ui.widgets[1].bars[1],true),"Missing path 999999")
    assert(C.Archive(c.db,character.guid,2913,95,"fixture")); ui.options.archived=true; ui:Refresh()
    text=hover(ui,env,ui.widgets[1].bars[1],false); contains(text,"Archived"); excludes(text,"last observed")
    excludes(text,"Current observation"); eq(#ui.rows[1].warnings,0)
end)
end
-- U01 END

-- U02 BEGIN: optional observed labels and real normal/Shift handler regressions.
do
local V=NS.ViewModel
local PRIVATE="U02_PRIVATE_API_PAYLOAD"
local function has(text,part) assert(text:find(part,1,true),"missing U02 text: "..part.." in "..text) end
local function lacks(text,part) assert(not text:find(part,1,true),"unexpected U02 text: "..part) end
local function enter(env,widget,shift)
    env.IsShiftKeyDown=function() return shift end
    widget.scripts.OnEnter(widget)
    return table.concat(env.GameTooltip.lines,"\n")
end
local function namedFixture()
    local env,s,f,c=k2Fixture()
    for id,e in pairs(f.entries) do e.definitionID=id+500000 end
    env.C_Traits.GetDefinitionInfo=function(id) return {overrideName="Observed label "..id} end
    return env,s,f,c
end
local function oneName()
    local env,s,f,c=k2Fixture()
    f.entries[130942].definitionID=700001
    return env,s,f,c
end
local function numericParity(raw,baseline)
    local copy=C.Copy(raw)
    for _,tab in ipairs(copy.tabs) do
        for _,p in pairs(tab.paths) do
            p.name=nil
            if p.unlock then p.unlock.definitionID=nil end
            if p.spend then p.spend.definitionID=nil end
        end
    end
    assert(deepEqual(copy,baseline),"optional label data cannot change numeric/staging/coverage metadata")
    eq(raw.nativeComplete,baseline.nativeComplete)
    local r,b=K.Evaluate(raw),K.Evaluate(baseline)
    eq(r.complete,b.complete); eq(r.sharedSpent,b.sharedSpent)
    for i,t in ipairs(r.trees) do
        eq(t.purchased,b.trees[i].purchased); eq(t.capacity,b.trees[i].capacity)
        eq(t.complete,b.trees[i].complete)
    end
    eq(C.ValidPayload("knowledgeRaw",raw,"observed"),true)
end
case("U02 active unlock and spend IDs select existing entries exact arguments no extra entry reads",function()
    local env,_,f,c=namedFixture()
    local entries,definitions,spells={},{},0
    env.C_Traits.GetEntryInfo=function(config,id)
        eq(config,1001); entries[#entries+1]=id; return f.entries[id]
    end
    env.C_Traits.GetDefinitionInfo=function(id)
        definitions[#definitions+1]=id; return {overrideName="  Observed | label\n"..id.."  ",spellID=800001}
    end
    env.C_Spell={GetSpellName=function() spells=spells+1; error("override must win") end}
    local raw=k2Raw(c); eq(#entries,70); eq(#definitions,35); eq(spells,0)
    local index=0
    local function visit(tab,id)
        index=index+1
        local p=tab.paths[id]; local active=p.node.activeEntry.entryID
        eq(entries[index*2-1],p.unlockEntryID); eq(entries[index*2],p.spendEntryID)
        eq(definitions[index],f.entries[active].definitionID)
        eq(p.name,"Observed   label "..f.entries[active].definitionID)
        eq(p.unlock.definitionID,f.entries[p.unlockEntryID].definitionID)
        eq(p.spend.definitionID,f.entries[p.spendEntryID].definitionID)
        -- Collection is breadth-first; traversal for expectations follows its queue.
    end
    for _,tab in ipairs(raw.tabs) do
        local queue={tab.root}; local at=1
        while at<=#queue do
            local id=queue[at]; at=at+1; visit(tab,id)
            for _,child in ipairs(tab.paths[id].children) do queue[#queue+1]=child end
        end
    end
    eq(index,35)
    eq(raw.tabs[1].paths[106192].node.activeEntry.entryID,130942)
    eq(raw.tabs[2].paths[106280].node.activeEntry.entryID,131037)
    local _,_,_,plain=k2Fixture(); numericParity(raw,k2Raw(plain))
end)
case("U02 absent nonmatching or invalid active entry never borrows another definition",function(checkpoint)
    for _,mode in ipairs({"missing","nonmatching","malformed","missingActiveDefinition"}) do
        pause(checkpoint,"U02 active label selection")
        local env,_,f,c=oneName(); f.entries[130933].definitionID=700002
        if mode=="missing" then f.nodes[106192].activeEntry=nil
        elseif mode=="nonmatching" then f.nodes[106192].activeEntry={entryID=999999,rank=1}
        elseif mode=="malformed" then f.nodes[106192].activeEntry={entryID="130942",rank=1}
        else f.entries[130942].definitionID=nil end
        local baseline=k2Raw(c); local calls=0
        env.C_Traits.GetDefinitionInfo=function() calls=calls+1; return {overrideName="Wrong fallback"} end
        local raw=k2Raw(c); eq(calls,0); eq(raw.tabs[1].paths[106192].name,nil)
        -- The baseline includes the other optional definition, but no label.
        baseline.tabs[1].paths[106192].unlock.definitionID=nil
        baseline.tabs[1].paths[106192].spend.definitionID=nil
        numericParity(raw,baseline)
    end
end)
case("U02 valid names sanitize controls pipes trim and preserve full localized byte boundaries",function(checkpoint)
    local samples={{"  Calm Hands  ","Calm Hands"},{"A\000B\127C|D\tE\nF","A B C D E F"},
        {"Écriture tranquille — 静かな手","Écriture tranquille — 静かな手"},
        {string.rep("a",256),string.rep("a",256)},{string.rep("é",128),string.rep("é",128)}}
    for _,sample in ipairs(samples) do
        pause(checkpoint,"U02 valid name bytes")
        local env,_,_,c=oneName(); local calls=0
        env.C_Traits.GetDefinitionInfo=function(id) eq(id,700001); return {overrideName=sample[1],spellID=800001} end
        env.C_Spell={GetSpellName=function() calls=calls+1; error(PRIVATE) end}
        local raw=k2Raw(c); eq(raw.tabs[1].paths[106192].name,sample[2]); eq(calls,0)
        local _,_,_,plain=k2Fixture(); numericParity(raw,k2Raw(plain))
    end
end)
case("U02 invalid override falls back once to guarded spell ID and valid localized spell name",function(checkpoint)
    for _,value in ipairs({{},{value=false},{value=42},{value={}},{value=""},{value=" \t|\n "},
        {value=string.rep("x",257)},{value=string.rep("é",128).."é"}}) do
        pause(checkpoint,"U02 spell fallback")
        local env,_,_,c=oneName(); local definitions,spells=0,0
        env.C_Traits.GetDefinitionInfo=function(id)
            definitions=definitions+1; eq(id,700001); return {overrideName=value.value,spellID=800001}
        end
        env.C_Spell={GetSpellName=function(id) spells=spells+1; eq(id,800001); return "  静かな手 | Écriture\n " end}
        local raw=k2Raw(c); eq(raw.tabs[1].paths[106192].name,"静かな手   Écriture")
        eq(definitions,1); eq(spells,1)
        local _,_,_,plain=k2Fixture(); numericParity(raw,k2Raw(plain))
    end
end)
case("U02 optional definition missing throwing malformed and metatable getters never fail numerics",function(checkpoint)
    for _,mode in ipairs({"missing","nonfunction","nil","throw","false","number","string","table","metatable"}) do
        pause(checkpoint,"U02 definition failures")
        local env,_,_,c=oneName(); local calls,metacalls,spells=0,0,0
        local function getter()
            calls=calls+1
            if mode=="throw" then error(PRIVATE) end
            if mode=="false" then return false elseif mode=="number" then return 700001
            elseif mode=="string" then return "name" elseif mode=="table" then return {}
            elseif mode=="metatable" then return setmetatable({overrideName="Do not trust"},{__index=function() metacalls=metacalls+1; error(PRIVATE) end}) end
        end
        env.C_Traits.GetDefinitionInfo=getter
        if mode=="missing" then env.C_Traits.GetDefinitionInfo=nil elseif mode=="nonfunction" then env.C_Traits.GetDefinitionInfo=true end
        env.C_Spell={GetSpellName=function() spells=spells+1; error(PRIVATE) end}
        local raw=k2Raw(c); eq(raw.tabs[1].paths[106192].name,nil); eq(metacalls,0); eq(spells,0)
        eq(calls,(mode=="missing" or mode=="nonfunction") and 0 or 1)
        local _,_,_,plain=k2Fixture(); numericParity(raw,k2Raw(plain))
        lacks(c.reason,PRIVATE)
    end
end)
case("U02 optional definition and spell IDs use existing integer bounds without numeric failure",function(checkpoint)
    for _,field in ipairs({"definitionID","spellID"}) do
        for _,sample in ipairs({{},{value=0},{value=-1},{value=1.5},{value="700001"},{value=false},
            {value={}},{value=2147483648},{value=math.huge},{value=0/0}}) do
            pause(checkpoint,"U02 optional ID guard")
            local env,_,f,c=oneName(); local calls,spells=0,0
            if field=="definitionID" then f.entries[130942].definitionID=sample.value end
            env.C_Traits.GetDefinitionInfo=function(id)
                calls=calls+1; eq(id,700001); return {spellID=sample.value}
            end
            env.C_Spell={GetSpellName=function() spells=spells+1; error(PRIVATE) end}
            local raw=k2Raw(c); local p=raw.tabs[1].paths[106192]
            eq(p.name,nil); eq(spells,0); eq(calls,field=="definitionID" and 0 or 1)
            if field=="definitionID" then eq(p.unlock.definitionID,nil) end
            local _,_,_,plain=k2Fixture(); numericParity(raw,k2Raw(plain))
        end
    end
end)
case("U02 optional definition and spell ID endpoints accepted with no numeric labels",function()
    for _,id in ipairs({1,2147483647}) do
        local env,_,f,c=oneName(); f.entries[130942].definitionID=id
        local definitions,spells=0,0
        env.C_Traits.GetDefinitionInfo=function(arg) definitions=definitions+1; eq(arg,id); return {overrideName=id,spellID=id} end
        env.C_Spell={GetSpellName=function(arg) spells=spells+1; eq(arg,id); return "Observed endpoint label" end}
        local raw=k2Raw(c); eq(raw.tabs[1].paths[106192].name,"Observed endpoint label"); eq(definitions,1); eq(spells,1)
        local _,_,_,plain=k2Fixture(); numericParity(raw,k2Raw(plain))
    end
end)
case("U02 spell getter missing nil throwing malformed blank long values leave only label absent",function(checkpoint)
    for _,mode in ipairs({"namespace","missing","nonfunction","nil","throw","false","number","table","blank","controls","long","utfLong","max","utfMax"}) do
        pause(checkpoint,"U02 spell name failures")
        local env,_,_,c=oneName(); local calls=0
        env.C_Traits.GetDefinitionInfo=function() return {spellID=800001} end
        env.C_Spell={GetSpellName=function(id)
            calls=calls+1; eq(id,800001)
            if mode=="throw" then error(PRIVATE) elseif mode=="false" then return false
            elseif mode=="number" then return 800001 elseif mode=="table" then return {}
            elseif mode=="blank" then return "  " elseif mode=="controls" then return "\000|\127\n"
            elseif mode=="long" then return string.rep("a",257) elseif mode=="utfLong" then return string.rep("é",129)
            elseif mode=="max" then return string.rep("a",256) elseif mode=="utfMax" then return string.rep("é",128) end
        end}
        if mode=="namespace" then env.C_Spell=nil elseif mode=="missing" then env.C_Spell.GetSpellName=nil
        elseif mode=="nonfunction" then env.C_Spell.GetSpellName=true end
        local raw=k2Raw(c); local expected
        if mode=="max" then expected=string.rep("a",256) elseif mode=="utfMax" then expected=string.rep("é",128) end
        eq(raw.tabs[1].paths[106192].name,expected)
        eq(calls,(mode=="namespace" or mode=="missing" or mode=="nonfunction") and 0 or 1)
        local _,_,_,plain=k2Fixture(); numericParity(raw,k2Raw(plain))
        local db=C.Open(nil); local r=K.Evaluate(raw)
        assert(C.Apply(db,character,identity,k2Observations(raw,r,100),100,"fixture"))
        eq(C.Open(db),db); lacks(c.reason,PRIVATE)
    end
end)
case("U02 optional name calls bounded to one definition and spell per 64 paths and eight trees",function()
    local env,_,f,c=oneName(); local template=C.Copy(f.nodes[106192]); f.tabs={}
    for t=1,8 do
        f.tabs[t]={id=8000+t,root=600000+t*1000+1}
        f.currencies[8000+t]={{traitCurrencyID=3902,quantity=0,spent=0}}
        for i=1,64 do
            local id=600000+t*1000+i; local n=C.Copy(template); n.ID=id; f.nodes[id]=n
            f.unlock[id]=130942; f.spend[id]=130933; f.currency[id]=3902; f.costs[id]={{ID=3902,amount=1}}
            f.children[id]=i<64 and {id+1} or {}
        end
    end
    env.C_ProfSpecs.GetRootPathForTab=function(id) return f.tabs[id-8000].root end
    local entries,definitions,spells=0,0,0
    env.C_Traits.GetEntryInfo=function(config,id) eq(config,1001); entries=entries+1; return f.entries[id] end
    env.C_Traits.GetDefinitionInfo=function(id) eq(id,700001); definitions=definitions+1; return {spellID=800001} end
    env.C_Spell={GetSpellName=function(id) eq(id,800001); spells=spells+1; return "Captured branch" end}
    local raw=k2Raw(c); eq(#raw.tabs,8); eq(raw.nativeComplete,true)
    for _,tab in ipairs(raw.tabs) do
        local count=0; for _,p in pairs(tab.paths) do count=count+1; eq(p.name,"Captured branch"); eq(p.metadataComplete,true) end
        eq(count,64); eq(tab.coverageComplete,true)
    end
    eq(entries,1024); eq(definitions,512); eq(spells,512)
end)
case("U02 Core optional name rejection is atomic raw and tree old nameless snapshots stay valid",function(checkpoint)
    local db,g=dbWith(payloadFixtures()); eq(C.Open(db),db); local verify=unchangedGraph(db)
    for _,key in ipairs({"knowledgeRaw","tree:11"}) do
        for _,sample in ipairs({{value=""},{value=" \t "},{value="a|b"},{value="a\000b"},{value="a\127b"},
            {value=string.rep("a",257)},{value=string.rep("é",129)},{value=123},{value=false},{value={}}}) do
            pause(checkpoint,"U02 atomic name validator")
            local value=C.Copy(payloadFixtures()[key]); local p=key=="knowledgeRaw" and value.tabs[1].paths[72] or value.paths[1]
            p.name=sample.value
            eq(C.ValidPayload(key,value,"observed"),false)
            eq(C.Apply(db,character,identity,{[key]=C.Observation("observed",value,20,"fixture"),
                unspent=C.Observation("observed",9,20,"fixture")},20,"fixture"),nil); verify()
            local bad=C.Copy(db); local last=bad.characters[character.guid].professions[2913].active.fields[key].last
            last.value=value; local checkBad=unchangedGraph(bad); eq(C.Open(bad),nil); checkBad()
            local archived=C.Copy(db); assert(C.Archive(archived,character.guid,2913,30,"fixture"))
            archived.characters[character.guid].professions[2913].archives[1].fields[key].last.value=value
            local checkArchive=unchangedGraph(archived); eq(C.Open(archived),nil); checkArchive()
        end
        for _,name in ipairs({"Branch",string.rep("a",256),string.rep("é",128)}) do
            local value=C.Copy(payloadFixtures()[key]); local p=key=="knowledgeRaw" and value.tabs[1].paths[72] or value.paths[1]
            p.name=name; eq(C.ValidPayload(key,value,"observed"),true)
        end
    end
    eq(g.fields["tree:11"].last.value.paths[1].name,nil); verify()
end)
case("U02 real Copy Evaluate Apply Open reload and archive preserve names and independent ownership",function()
    local _,_,_,c=namedFixture(); local raw=k2Raw(c); local copy=C.Copy(raw)
    local r=K.Evaluate(raw); eq(r.complete,true)
    local original=raw.tabs[1].paths[106192].name
    eq(copy.tabs[1].paths[106192].name,original); assert(copy.tabs[1].paths[106192]~=raw.tabs[1].paths[106192])
    local db=C.Open(nil); local obs=k2Observations(raw,r,100)
    local returned=assert(C.Apply(db,character,identity,obs,100,"fixture"))
    local saved=db.characters[character.guid].professions[2913].active
    eq(returned,saved); local returnedCopy=C.Copy(returned)
    eq(saved.fields["tree:1122"].last.value.paths[1].name,original)
    raw.tabs[1].paths[106192].name="caller raw"; r.trees[1].paths[1].name="caller evaluated"
    copy.tabs[1].paths[106192].name="caller copied"; returnedCopy.fields["tree:1122"].last.value.paths[1].name="caller returned copy"
    eq(saved.fields["tree:1122"].last.value.paths[1].name,original)
    eq(saved.fields.knowledgeRaw.last.value.tabs[1].paths[106192].name,original)
    local reloaded=C.Copy(db); eq(C.Open(reloaded),reloaded)
    reloaded.characters[character.guid].professions[2913].active.fields["tree:1122"].last.value.paths[1].name="other DB"
    eq(saved.fields["tree:1122"].last.value.paths[1].name,original)
    assert(C.Archive(db,character.guid,2913,120,"fixture")); eq(C.Open(db),db)
    local archive=db.characters[character.guid].professions[2913].archives[1]
    eq(archive.fields["tree:1122"].last.value.paths[1].name,original)
    local archiveCopy=C.Copy(archive); archiveCopy.fields["tree:1122"].last.value.paths[1].name="copy"
    eq(archive.fields["tree:1122"].last.value.paths[1].name,original)
end)
case("U02 failed numeric refresh retains coherent old names points not latest raw labels",function(checkpoint)
    local env,s,f,c=namedFixture(); mockWidgets(env); assert(c:Scan())
    pause(checkpoint,"U02 named snapshot collected")
    local before=C.Copy(c.db.characters[character.guid].professions[2913].active.fields["tree:1122"].last)
    env.C_Traits.GetDefinitionInfo=function() return {overrideName="New raw invalid label"} end
    f.nodes[106192].ranksPurchased=29; s.at=120; assert(c:Scan())
    local g=c.db.characters[character.guid].professions[2913].active
    assert(deepEqual(g.fields["tree:1122"].last,before)); eq(g.fields["tree:1122"].attempt.status,"unknown")
    eq(g.fields.knowledgeRaw.last.value.tabs[1].paths[106192].name,"New raw invalid label")
    local ui=NS.Dashboard.New(env,c); ui:Toggle()
    local text=enter(env,ui.widgets[1].bars[1],false)
    has(text,before.value.paths[1].name..": 0/30"); has(text,"Stale data"); lacks(text,"New raw invalid label"); lacks(text,"29/")
    eq(ui.rows[1].trees[1].purchased,0); eq(ui.rows[1].trees[1].capacity,270)
    local diagnostic=enter(env,ui.widgets[1].bars[1],true)
    has(diagnostic,"NOT verified future/all-rank costs"); has(diagnostic,"Observed tree at 100")
end)
case("U02 label only refresh failure is fresh numerics Unknown branch without history fallback",function(checkpoint)
    local env,s,_,c=namedFixture(); mockWidgets(env); assert(c:Scan())
    pause(checkpoint,"U02 label-only retry")
    env.C_Traits.GetDefinitionInfo=function() error(PRIVATE) end
    s.at=120; assert(c:Scan()); local g=c.db.characters[character.guid].professions[2913].active
    local t=g.fields["tree:1122"]; eq(t.attempt.status,"observed"); eq(t.last.observedAt,120)
    eq(t.last.value.paths[1].name,nil); eq(t.last.value.purchased,0); eq(t.last.value.capacity,270)
    local ui=NS.Dashboard.New(env,c); ui:Toggle(); eq(ui.rows[1].trees[1].state.fresh,true)
    local text=enter(env,ui.widgets[1].bars[1],false); has(text,"Unknown branch: 0/30"); lacks(text,"Stale"); lacks(text,"Observed label")
    lacks(text,PRIVATE); lacks(c.reason,PRIVATE)
end)
case("U02 real named localized duplicate branches individual points full traversal and legacy diagnostics",function()
    local env,_,_,c=namedFixture(); mockWidgets(env)
    env.C_Traits.GetDefinitionInfo=function(id)
        return {overrideName=(id==630942 or id==630941) and "静かな手" or "Écriture tranquille"}
    end
    assert(c:Scan()); local ui=NS.Dashboard.New(env,c); ui:Toggle()
    local g=c.db.characters[character.guid].professions[2913].active
    local verify=unchangedGraph({c.db,c.fresh,ui.rows,env.CraftArmyDiagnosticsDB})
    for i,tree in ipairs(ui.rows[1].trees) do
        local value=g.fields["tree:"..tree.id].last.value
        local text=enter(env,ui.widgets[1].bars[i],false); eq(#env.GameTooltip.lines,#value.paths)
        local depths={[value.root]=0}
        for n,p in ipairs(value.paths) do
            local depth=assert(depths[p.id])
            eq(env.GameTooltip.lines[n],string.rep("  ",depth)..p.name..": "..p.purchased.."/"..p.capacity)
            for _,child in ipairs(p.children or {}) do depths[child]=depth+1 end
        end
        for _,prose in ipairs({"Purchased/capacity","Future point","observed","Shift-hover","locked","available",tree.name,"Source pin","Path "}) do lacks(text,prose) end
        if i==1 then eq(#env.GameTooltip.lines,9); eq(env.GameTooltip.lines[1],"静かな手: 0/30"); eq(env.GameTooltip.lines[2],"  静かな手: 0/30") end
        if i==2 then eq(env.GameTooltip.lines[1],"Écriture tranquille: 10/10"); eq(tree.purchased,50); eq(tree.capacity,70) end
        local diagnostic=enter(env,ui.widgets[1].bars[i],true)
        has(diagnostic,"Native rank points / shared-spent reconciled; NOT verified future/all-rank costs")
        has(diagnostic,"Source pin: 297d7"); has(diagnostic,"Tree purchased/capacity: "..value.purchased.."/"..value.capacity)
    end
    local overview=enter(env,ui.widgets[1].cells[I.Knowledge],false)
    has(overview,ui.rows[1].trees[2].name..": 50/70"); lacks(overview,"Last observed snapshot")
    verify()
end)
case("U02 all64 default paths unknown labels totals and single stale archive exception footer",function()
    local values=payloadFixtures(); local t=values["tree:11"]; local template=C.Copy(t.paths[1]); t.paths={}
    t.root=1001; t.purchased=0; t.capacity=64; t.coverage={discovered=64,captured=64,limit=false}
    for n=1,64 do
        local p=C.Copy(template); p.id=1000+n; p.purchased=0; p.capacity=1; p.name="静かな手 "..n
        p.children=n<64 and {1001+n} or {}; t.paths[n]=p
    end
    t.paths[2].name=nil; values.knowledgeIndex[1].root=t.root
    local db,g=dbWith(values); local env=fixtureAPI(); mockWidgets(env)
    local c=NS.Collectors.New(env,db); local ui=NS.Dashboard.New(env,c); ui:Toggle()
    local text=enter(env,ui.widgets[1].bars[1],false); eq(#env.GameTooltip.lines,64)
    eq(env.GameTooltip.lines[1],"静かな手 1: 0/1"); eq(env.GameTooltip.lines[2],"  Unknown branch: 0/1")
    eq(env.GameTooltip.lines[64],string.rep("  ",63).."静かな手 64: 0/1"); lacks(text,"observed"); lacks(text,"Shift-hover")
    for n=1,64 do
        eq(env.GameTooltip.lines[n],string.rep("  ",n-1)..(n==2 and "Unknown branch" or "静かな手 "..n)..": 0/1")
    end
    assert(C.Apply(db,character,identity,{["tree:11"]=C.Observation("error",nil,110,"fixture")},110,"fixture"))
    ui:Refresh(); enter(env,ui.widgets[1].bars[1],false); eq(#env.GameTooltip.lines,65); eq(env.GameTooltip.lines[65],"Stale data")
    assert(C.Archive(db,character.guid,2913,120,"fixture")); ui.options.archived=true; ui:Refresh()
    enter(env,ui.widgets[1].bars[1],false); eq(#env.GameTooltip.lines,65); eq(env.GameTooltip.lines[65],"Archived")
    -- Pure projection with no eligible last tree; never borrow raw ranks or labels.
    local projection=C.Copy(g); projection.fields["tree:11"].last=nil
    projection.fields.knowledgeRaw.last.value.tabs[1].paths[72].name="Ineligible raw label"
    ui.rows={V.Row(character.guid,db.characters[character.guid],2913,projection,nil,130,false)}; ui:Render()
    text=enter(env,ui.widgets[1].bars[1],false)
    eq(text,"Unknown branch: ?/?\nBranch observations unavailable."); lacks(text,"0/64"); lacks(text,"Ineligible raw label")
end)
case("U02 five silent normal cells clear hide existing gear then exact Shift diagnostic selection leave",function()
    local env=fixtureAPI(); mockWidgets(env); local db=dbWith(payloadFixtures())
    local c=NS.Collectors.New(env,db); local ui=NS.Dashboard.New(env,c); ui:Toggle(); local tip=env.GameTooltip
    local counts={}; local functions={}
    for _,key in ipairs({"ClearLines","Hide","SetOwner","AddLine","Show","SetHyperlink"}) do
        local original=tip[key]; functions[key]=original
        tip[key]=function(self,...) counts[key]=(counts[key] or 0)+1; return original(self,...) end
    end
    local verify=unchangedGraph({c.db,c.fresh,ui.rows,env.CraftArmyDiagnosticsDB})
    for _,col in ipairs({I.Moxie,I.Unspent,I.LastUpdated,I.Stat,I.Enchant}) do
        local cell=ui.widgets[1].cells[col]
        enter(env,ui.widgets[1].cells[I.Tool],false); eq(tip.shown,true); assert(tip.nativeLink)
        local owner=tip.owner; counts={}; local modifiers=0
        env.IsShiftKeyDown=function() modifiers=modifiers+1; return false end
        cell.scripts.OnEnter(cell); eq(modifiers,1); eq(tip.shown,false); eq(tip.nativeLink,nil); eq(#tip.lines,0)
        eq(counts.ClearLines,1); eq(counts.Hide,1); eq(counts.SetOwner,nil); eq(counts.AddLine,nil); eq(counts.Show,nil); eq(counts.SetHyperlink,nil); eq(tip.owner,owner)
        counts={}; modifiers=0
        env.IsShiftKeyDown=function() modifiers=modifiers+1; return modifiers==1 end
        cell.scripts.OnEnter(cell); eq(modifiers,1); eq(counts.SetOwner,1); eq(counts.Show,1); eq(counts.SetHyperlink,nil)
        local r=ui.rows[1]; local expected=(col==I.Stat or col==I.Enchant) and C.Copy(r.gear.tool.tooltip) or
            {r.cells[I.Name].."-"..r.cells[I.Realm],r.cells[I.Profession],unpack(r.tooltip)}
        for n,line in ipairs(expected) do expected[n]=NS.Dashboard.PlainTooltip(line) end
        assert(deepEqual(tip.lines,expected),"exact existing diagnostic array for column "..col)
        eq(tip.owner,cell); eq(tip.shown,true); cell.scripts.OnLeave(cell); eq(tip.shown,false)
        -- U10 ADAPT U02_HIDDEN_MOUSE BEGIN
--[====[U10 ORIGINAL BEGIN
        eq(cell.style.EnableMouse[1],true); cell.scripts.OnMouseDown(cell); eq(ui.selected,ui.widgets[1].row)
U10 ORIGINAL END]====]
        eq(cell.style.EnableMouse[1],col~=I.Stat and col~=I.Enchant); cell.scripts.OnMouseDown(cell); eq(ui.selected,ui.widgets[1].row)
        -- U10 ADAPT U02_HIDDEN_MOUSE END
    end
    verify()
end)
case("U02 protected modifier fallbacks sampled once silent five normal cells no collection or mutation",function()
    local env=fixtureAPI(); mockWidgets(env); local db=dbWith(payloadFixtures())
    local c=NS.Collectors.New(env,db); local ui=NS.Dashboard.New(env,c); ui:Toggle()
    local reads=0
    local function forbidden() reads=reads+1; error(PRIVATE) end
    for _,namespace in ipairs({env.C_Traits,env.C_ProfSpecs,env.C_Item}) do for key in pairs(namespace) do namespace[key]=forbidden end end
    env.C_Spell={GetSpellName=forbidden}; c.Knowledge=forbidden; c.Scan=forbidden
    local verify=unchangedGraph({c.db,c.fresh,ui.rows,env.CraftArmyDiagnosticsDB})
    for _,col in ipairs({I.Moxie,I.Unspent,I.LastUpdated,I.Stat,I.Enchant}) do
        local cell=ui.widgets[1].cells[col]
        for _,mode in ipairs({"absent","noncallable","false","nil","throw","number","string","table"}) do
            enter(env,ui.widgets[1].cells[I.Tool],false)
            local calls=0
            env.IsShiftKeyDown=function()
                calls=calls+1
                if mode=="throw" then error(PRIVATE) elseif mode=="false" then return false
                elseif mode=="number" then return 1 elseif mode=="string" then return "true" elseif mode=="table" then return {} end
            end
            if mode=="absent" then env.IsShiftKeyDown=nil elseif mode=="noncallable" then env.IsShiftKeyDown=true end
            env.GameTooltip.calls={}; cell.scripts.OnEnter(cell)
            eq(calls,(mode=="absent" or mode=="noncallable") and 0 or 1)
            eq(env.GameTooltip.shown,false); eq(#env.GameTooltip.lines,0); eq(env.GameTooltip.nativeLink,nil)
            eq(#env.GameTooltip.calls,1); eq(env.GameTooltip.calls[1],"clear")
        end
        enter(env,cell,true); has(table.concat(env.GameTooltip.lines,"\n"),"observed 10")
    end
    eq(reads,0); verify()
end)
end
-- U02 END

-- U03 BEGIN: only additive fixtures; existing 181 cases and helpers are frozen.
do
local Details=NS.Details
local RULE="Improve the efficiency of all Inscription crafts, gaining +1 Multicraft, +1 Ingenuity, and +1 Resourcefulness per point in this specialization."
local PERK="Learn to craft an Thalassian Treatise on Inscription.\n\nLearn a sub-specialization of your choice."
local function reportFixture()
    return {version=1,skillLineID=2913,configID=1001,sourceScanAt=100,trees={
        {id=1124,name="Calm Hands",root=106280,purchased=10,capacity=10,paths={
            {id=106280,name="Calm Hands",purchased=10,capacity=10,locked=false,description=RULE,perks={
                {id=106276,rank=0,state=2,isMajorPerk=true,description=PERK}}}}}}}
end
local function fixture()
    local env,s=fixtureAPI()
    local n={ID=106280,type=1,flags=0,isAvailable=true,ranksPurchased=11,currentRank=11,activeRank=11,
        ranksIncreased=0,maxRanks=11,totalMaxRanks=11,activeEntry={entryID=131037,rank=10},
        entryIDs={131041,131037},entryIDsWithCommittedRanks={131037},entryIDToRanksIncreased={[131041]=0,[131037]=0}}
    env.C_ProfSpecs.GetSpecTabIDsForSkillLine=function() return {1124} end
    env.C_ProfSpecs.GetTabInfo=function() return {name="Calm Hands"} end
    env.C_ProfSpecs.GetRootPathForTab=function() return 106280 end
    env.C_ProfSpecs.GetSpendEntryForPath=function() return 131037 end
    env.C_ProfSpecs.GetUnlockEntryForPath=function() return 131041 end
    env.C_ProfSpecs.GetSpendCurrencyForPath=function() return 3902 end
    env.C_Traits.GetNodeInfo=function(config,id) eq(config,1001); eq(id,106280); return n end
    env.C_Traits.GetEntryInfo=function(_,id) return {type=id==131041 and 9 or 7,maxRanks=id==131041 and 1 or 10,entryCost={}} end
    env.C_Traits.GetNodeCost=function() return {{ID=3902,amount=1}} end
    env.C_Traits.GetTreeCurrencyInfo=function() return {{traitCurrencyID=3902,quantity=0,spent=10}} end
    local c=NS.Collectors.New(env,C.Open(nil))
    local raw=k2Raw(c); local result=K.Evaluate(raw); eq(result.complete,true)
    result.trees[1].paths[1].name="Calm Hands"
    local g=assert(C.Apply(c.db,character,identity,k2Observations(raw,result,100),100,"fixture"))
    c.fresh[character.guid..":2913"]={generation=g.generation,fields={unspent=true,["tree:1124"]=true}}
    local calls={}
    local function log(name,...)
        calls[#calls+1]={name,...}
    end
    local old=env.C_Traits.GetNodeInfo
    env.C_Traits.GetNodeInfo=function(...) log("node",...); return old(...) end
    env.C_ProfSpecs.GetDescriptionForPath=function(id) eq(id,106280); log("path",id); return RULE end
    env.C_ProfSpecs.GetPerksForPath=function(id) eq(id,106280); log("list",id); return {{perkID=106276,isMajorPerk=true}} end
    env.C_ProfSpecs.GetUnlockRankForPerk=function(id) eq(id,106276); log("rank",id); return 0 end
    env.C_ProfSpecs.GetStateForPerk=function(id,config) eq(id,106276); eq(config,1001); log("state",id,config); return 2 end
    env.C_ProfSpecs.GetDescriptionForPerk=function(id) eq(id,106276); log("perk",id); return PERK end
    s.at=200
    return env,s,c,{guid=character.guid,id=2913,generation=g.generation,archived=false},n,calls
end
local function finish(job,checkpoint)
    while job.status=="running" do job:Step(); pause(checkpoint,"U03 capture unit") end
    return job
end
local function active(c) return c.db.characters[character.guid].professions[2913].active end
local function widgets(env)
    local created=mockWidgets(env)
    local old=env.CreateFrame
    env.UISpecialFrames={}
    env.CreateFrame=function(...)
        local w=old(...)
        w.SetEnabled=function(self,v) self.enabled=v end
        w.SetVerticalScroll=function(self,v) self.scrollOffset=v end
        w.SetTextInsets=function(self,...) self.insets={...} end
        w.EnableKeyboard=function(self,v) self.keyboard=v end
        w.SetPropagateKeyboardInput=function(self,v) self.propagate=v end
        local hide=w.Hide
        w.Hide=function(self)
            local shown=self.shown; hide(self)
            if shown and self.scripts.OnHide then self.scripts.OnHide(self) end
        end
        return w
    end
    return created
end
case("U03 typed optional field native sample rank0 multiline exact and independent copy",function()
    local r=reportFixture(); eq(C.ValidPayload("professionDetails",r,"observed"),true)
    local db,g=dbWith({professionDetails=r}); eq(C.Open(db),db)
    r.trees[1].paths[1].perks[1].description="mutated"
    eq(g.fields.professionDetails.last.value.trees[1].paths[1].perks[1].description,PERK)
    local copy=C.Copy(db); eq(C.Open(copy),copy)
    eq(C.Archive(copy,character.guid,2913,20,"fixture"),true); eq(C.Open(copy),copy)
    eq(C.Open(dbWith({unspent=0}))~=nil,true)
end)
case("U03 malformed scalar types bounds names descriptions and earned contradictions reject",function(checkpoint)
    local mutations={
        function(r) r.version=2 end,function(r) r.skillLineID=773 end,function(r) r.configID=0 end,
        function(r) r.sourceScanAt=nil end,function(r) r.sourceScanAt=0/0 end,
        function(r,t) t.id=2147483648 end,function(r,t) t.root=1 end,function(r,t) t.capacity=0 end,
        function(r,t) t.purchased=9 end,function(r,t) t.name=" " end,function(r,t) t.name="bad|name" end,
        function(r,t) t.name=string.rep("x",257) end,function(r,t) t.name="bad\nname" end,
        function(r,t,p) p.id=0 end,function(r,t,p) p.purchased=false end,function(r,t,p) p.capacity=9 end,
        function(r,t,p) p.locked=nil end,function(r,t,p) p.locked=true end,
        function(r,t,p) p.description=nil end,function(r,t,p) p.description=string.rep("x",4097) end,
        function(r,t,p,k) k.id=0 end,function(r,t,p,k) k.rank=nil end,function(r,t,p,k) k.rank=11 end,
        function(r,t,p,k) k.state=1 end,function(r,t,p,k) k.state=3 end,function(r,t,p,k) k.state=false end,
        function(r,t,p,k) k.isMajorPerk=1 end,function(r,t,p,k) k.description="\n \t" end,
        function(r,t,p,k) k.description=string.rep("x",4097) end,
    }
    for i,change in ipairs(mutations) do
        local r=reportFixture(); local t=r.trees[1]; local p=t.paths[1]; change(r,t,p,p.perks[1])
        eq(C.ValidPayload("professionDetails",r,"observed"),false,"mutation "..i)
        pause(checkpoint,"U03 malformed payload")
    end
    local r=reportFixture(); r.sourceScanAt=0; r.trees[1].paths[1].description=""
    eq(C.ValidPayload("professionDetails",r,"observed"),true)
end)
case("U03 dense caps duplicate identities and total description byte boundary",function(checkpoint)
    local changes={
        function(r) r.trees[2]=C.Copy(r.trees[1]) end,
        function(r) r.trees[3]=C.Copy(r.trees[1]) end,
        function(r,t,p) t.paths[2]=C.Copy(p) end,
        function(r,t,p) p.perks[2]=C.Copy(p.perks[1]) end,
        function(r,t,p) p.perks[3]=C.Copy(p.perks[1]) end,
        function(r,t,p) for i=2,33 do p.perks[i]={id=i,rank=0,state=0,isMajorPerk=false,description="x"} end end,
        function(r,t) for i=2,9 do local x=C.Copy(t); x.id=i; r.trees[i]=x end end,
    }
    for _,change in ipairs(changes) do
        local r=reportFixture(); change(r,r.trees[1],r.trees[1].paths[1]); eq(C.ValidPayload("professionDetails",r,"observed"),false)
        pause(checkpoint,"U03 payload list bounds")
    end
    local r=reportFixture(); local p=r.trees[1].paths[1]; p.description=""; p.perks={}
    for i=1,8 do p.perks[i]={id=i,rank=0,state=0,isMajorPerk=false,description=string.rep("x",4096)} end
    eq(C.ValidPayload("professionDetails",r,"observed"),true)
    p.description="x"; eq(C.ValidPayload("professionDetails",r,"observed"),false)
end)
case("U03 scope guard optional missing field old DB and invalid generation atomic rejection",function()
    local r=reportFixture(); local db,g=dbWith({unspent=0}); local before=db.characters[character.guid]
    local bad=C.Copy(identity); bad.expansionID=10
    eq(C.Apply(db,character,bad,{professionDetails=C.Observation("observed",r,20,"fixture")},10,"fixture"),nil)
    eq(db.characters[character.guid],before); eq(g.scannedAt,10)
    g.fields.professionDetails=C.Merge(nil,C.Observation("observed",r,20,"fixture"),"fixture",1)
    g.identity.expansionID=10; eq(C.Open(db),nil); eq(db.characters[character.guid],before)
end)
case("U03 job exact arguments one metadata perk verify commit unit and independent timestamps",function(checkpoint)
    local env,s,c,scope,n,calls=fixture(); local g=active(c); local old=C.Copy(g.fields)
    local job=Details.NewCaptureJob(env,c,scope); eq(job.status,"running"); eq(#calls,0)
    job:Step(); eq(job.phase,"perk"); eq(#calls,3); eq(calls[1][1],"node"); eq(calls[1][2],1001)
    eq(calls[1][3],106280); eq(calls[2][1],"path"); eq(calls[3][1],"list"); eq(active(c),g)
    pause(checkpoint,"U03 metadata")
    job:Step(); eq(job.phase,"verify"); eq(#calls,6); eq(calls[5][1],"state"); eq(calls[5][3],1001); eq(active(c),g)
    job:Step(); eq(job.phase,"commit"); eq(#calls,7); eq(active(c),g)
    s.at=300; job:Step(); eq(job.status,"complete"); eq(job.steps,4); eq(#calls,8)
    eq(calls[8][1],"node"); eq(calls[8][2],1001); eq(calls[8][3],106280)
    local new=active(c); eq(new.scannedAt,100); eq(new.fields.professionDetails.last.observedAt,300)
    eq(new.fields.professionDetails.last.value.sourceScanAt,100); eq(new.fields.professionDetails.attempt.attemptedAt,300)
    eq(new.fields.professionDetails.last.value.trees[1].paths[1].description,RULE)
    eq(new.fields.professionDetails.last.value.trees[1].paths[1].perks[1].description,PERK)
    eq(deepEqual(old,new.fields)==false,true)
    for k,v in pairs(old) do assert(deepEqual(v,new.fields[k]),"unrelated field "..k) end
    eq(c.fresh[character.guid..":2913"].fields.unspent,true); eq(c.fresh[character.guid..":2913"].fields.professionDetails,true)
    job:Step(); eq(active(c),new); eq(#calls,8)
end)
case("U03 API failures pending unknown contradictory ranks preserve old whole snapshot",function(checkpoint)
    for _,mode in ipairs({"pending","unknown","nil","throw","locked","rank","blank","long","pathlong","missing"}) do
        local env,s,c,scope=fixture(); eq(finish(Details.NewCaptureJob(env,c,scope)).status,"complete")
        local before=active(c).fields.professionDetails.last; local old=C.Copy(before); s.at=400
        if mode=="pending" then env.C_ProfSpecs.GetStateForPerk=function() return 1 end
        elseif mode=="unknown" then env.C_ProfSpecs.GetStateForPerk=function() return 9 end
        elseif mode=="nil" then env.C_ProfSpecs.GetStateForPerk=function() end
        elseif mode=="throw" then env.C_ProfSpecs.GetDescriptionForPerk=function() error("PRIVATE SECRET") end
        elseif mode=="rank" then env.C_ProfSpecs.GetUnlockRankForPerk=function() return 11 end
        elseif mode=="blank" then env.C_ProfSpecs.GetDescriptionForPerk=function() return " \n" end
        elseif mode=="long" then env.C_ProfSpecs.GetDescriptionForPerk=function() return string.rep("x",4097) end
        elseif mode=="pathlong" then env.C_ProfSpecs.GetDescriptionForPath=function() return string.rep("x",4097) end
        elseif mode=="missing" then env.C_ProfSpecs.GetPerksForPath=nil
        elseif mode=="locked" then env.C_ProfSpecs.GetUnlockRankForPerk=function() return -1 end end
        local job=finish(Details.NewCaptureJob(env,c,scope),checkpoint); eq(job.status,"failed",mode)
        local g=active(c); assert(deepEqual(g.fields.professionDetails.last,old),mode)
        eq(g.fields.professionDetails.attempt.status,"unknown"); eq(g.fields.professionDetails.attempt.attemptedAt,400)
        eq(g.scannedAt,100); eq(c.fresh[character.guid..":2913"].fields.professionDetails,nil)
        eq(c.fresh[character.guid..":2913"].fields.unspent,true); assert(not job.reason:find("PRIVATE",1,true))
        pause(checkpoint,"U03 failure retained")
    end
end)
case("U03 bounded raw perk lists reject holes keys malformed duplicate and overflow without prefix",function(checkpoint)
    for _,mode in ipairs({"hole","key","duplicate","overflow","id","major","meta"}) do
        local env,s,c,scope=fixture(); local g=active(c)
        env.C_ProfSpecs.GetPerksForPath=function()
            local k={perkID=106276,isMajorPerk=true}
            if mode=="hole" then return {[2]=k} elseif mode=="key" then return {bad=k}
            elseif mode=="duplicate" then return {k,k} elseif mode=="overflow" then local t={}; for i=1,33 do t[i]=k end; return t
            elseif mode=="id" then k.perkID=0 elseif mode=="major" then k.isMajorPerk=nil
            elseif mode=="meta" then return setmetatable({k},{}) end
            return {k}
        end
        local job=finish(Details.NewCaptureJob(env,c,scope),checkpoint); eq(job.status,"failed",mode)
        eq(active(c).fields.professionDetails.last,nil); eq(g.fields.professionDetails,nil)
        pause(checkpoint,"U03 raw list rejected")
    end
end)
case("U03 every yield scope safety cancellation source object and no-event point changes discard",function(checkpoint)
    for _,boundary in ipairs({0,1,2,3}) do
        for _,mode in ipairs({"combat","staged","closed","linked","offline","serial","revision","pointer","deleted","clock","points","cancel"}) do
            local env,s,c,scope,n=fixture(); local job=Details.NewCaptureJob(env,c,scope)
            for i=1,boundary do job:Step() end
            local before=c.db.characters[character.guid]
            if mode=="combat" then s.combat=true elseif mode=="staged" then s.staged=true
            elseif mode=="closed" then s.shown=false elseif mode=="linked" then s.linked=true
            elseif mode=="offline" then env.UnitGUID=function() return "other" end
            elseif mode=="serial" then c.serial=c.serial+1 elseif mode=="revision" then c.revision=c.revision+1
            elseif mode=="pointer" then before.professions[2913].active=C.Copy(active(c))
            elseif mode=="deleted" then before.professions[2913].active=nil
            elseif mode=="clock" then s.at=nil elseif mode=="points" then n.currentRank=10
            elseif mode=="cancel" then job:Cancel() end
            finish(job,checkpoint)
            assert(job.status~="complete",mode..boundary)
            eq(c.db.characters[character.guid],before); eq(active(c) and active(c).fields.professionDetails,nil)
            pause(checkpoint,"U03 guarded yield")
        end
    end
end)
case("U03 startup unsafe archived foreign invalid DB missing source and clocks never write",function(checkpoint)
    for _,mode in ipairs({"archived","foreign","otherprofession","generation","invaliddb","raw","index","config","staged","clock","combat","closed"}) do
        local env,s,c,scope=fixture()
        if mode=="archived" then scope.archived=true elseif mode=="foreign" then scope.guid="other"
        elseif mode=="otherprofession" then scope.id=1 elseif mode=="generation" then scope.generation=2
        elseif mode=="invaliddb" then c.db.schema=2 elseif mode=="raw" then active(c).fields.knowledgeRaw=nil
        elseif mode=="index" then active(c).fields.knowledgeIndex=nil
        elseif mode=="config" then env.C_ProfSpecs.GetConfigIDForSkillLine=function() return 1002 end
        elseif mode=="staged" then s.staged=true elseif mode=="clock" then s.at=0/0
        elseif mode=="combat" then s.combat=true elseif mode=="closed" then s.shown=false end
        local before=c.db.characters[character.guid]
        local job=Details.NewCaptureJob(env,c,scope); eq(job.status,"blocked",mode); job:Step()
        eq(c.db.characters[character.guid],before); eq(active(c).fields.professionDetails,nil)
        pause(checkpoint,"U03 startup guard")
    end
end)
case("U03 API boundary reentrancy cancel and context changes sanitized no writes",function(checkpoint)
    for _,mode in ipairs({"reenter","cancel","stage","replace","throwcontext"}) do
        local env,s,c,scope=fixture(); local job=Details.NewCaptureJob(env,c,scope); local before=c.db.characters[character.guid]
        env.C_ProfSpecs.GetDescriptionForPath=function()
            if mode=="reenter" then job:Step() elseif mode=="cancel" then job:Cancel()
            elseif mode=="stage" then s.staged=true elseif mode=="replace" then before.professions[2913].active=C.Copy(active(c))
            elseif mode=="throwcontext" then c.Context=function() error("PRIVATE SECRET") end end
            return RULE
        end
        finish(job,checkpoint); assert(job.status~="complete"); eq(c.db.characters[character.guid],before)
        eq(active(c).fields.professionDetails,nil); assert(not job.reason:find("PRIVATE",1,true))
        pause(checkpoint,"U03 callback safety")
    end
end)
case("U03 stepcap invalid DB before commit and assembled alias budget fail atomically",function(checkpoint)
    local env,s,c,scope=fixture(); local job=Details.NewCaptureJob(env,c,scope); job.steps=10000
    local before=c.db.characters[character.guid]; job:Step(); eq(job.status,"failed"); eq(c.db.characters[character.guid],before)
    pause(checkpoint,"U03 stepcap")
    env,s,c,scope=fixture(); job=Details.NewCaptureJob(env,c,scope); job:Step(); job:Step(); job:Step()
    before=c.db.characters[character.guid]; c.db.schema=2; job:Step(); eq(job.status,"discarded"); eq(c.db.characters[character.guid],before)
    pause(checkpoint,"U03 invalid DB")
    -- Small aliased graph, filled to the unchanged actual Copy visit boundary.
    env,s,c,scope=fixture(); c.db.alias=c.db.characters
    c.db.padding={}; local count=0
    local function visits(v) count=count+1; if type(v)=="table" then for _,x in pairs(v) do visits(x) end end end
    visits(c.db); local used=count
    for i=1,50000-used do c.db.padding[i]=false end
    eq(C.Open(c.db),c.db); before=c.db.characters[character.guid]
    job=finish(Details.NewCaptureJob(env,c,scope),checkpoint); eq(job.status,"failed")
    eq(c.db.characters[character.guid],before); eq(c.db.alias,c.db.characters); eq(active(c).fields.professionDetails,nil)
    eq(active(c).scannedAt,100)
end)
case("U03 cached model owns coherent old points unknown versus empty and archived reload",function(checkpoint)
    local env,s,c,scope=fixture(); local model=Details.Model(c,scope)
    eq(#model.branches,1); assert(Details.Branch(model,1).body:find("Perks not observed",1,true))
    finish(Details.NewCaptureJob(env,c,scope),checkpoint); model=Details.Model(c,scope)
    assert(model.status:find("Fresh",1,true)); eq(model.branches[1].title,"Calm Hands: 10/10")
    assert(Details.Branch(model,1).body:find(RULE,1,true)); assert(Details.Branch(model,1).body:find("Required rank 0",1,true))
    assert(Details.Branch(model,1).body:find(PERK,1,true)); assert(not Details.Branch(model,1).body:find("learned",1,true))
    c.fresh={}; active(c).scannedAt=101; model=Details.Model(c,scope)
    assert(model.status:find("not current",1,true)); eq(model.branches[1].title,"Calm Hands: 10/10")
    local currentTree=active(c).fields["tree:1124"].last.value; local currentPath=currentTree.paths[1]
    currentTree.purchased=0; currentTree.accountingEvidence.spent=0; currentTree.accountingEvidence.totalPurchased=0
    currentTree.currencies[1].spent=0; currentPath.purchased=0
    local node=currentPath.node
    node.ranksPurchased=1; node.currentRank=1; node.activeRank=1
    node.activeEntry={entryID=currentPath.unlockEntryID,rank=1}
    node.nextEntry={entryID=currentPath.spendEntryID,rank=1}; node.entryIDsWithCommittedRanks={currentPath.unlockEntryID}
    local tab=active(c).fields.knowledgeRaw.last.value.tabs[1]
    tab.paths[106280].node=C.Copy(node); tab.currencies[1].spent=0
    eq(C.Open(c.db),c.db); model=Details.Model(c,scope)
    eq(currentTree.purchased,0); eq(model.branches[1].title,"Calm Hands: 10/10","old perks never borrow newer zero points")
    local db=C.Copy(c.db); eq(C.Archive(db,character.guid,2913,500,"fixture"),true)
    c.db=db; scope.archived=true; model=Details.Model(c,scope); assert(model.status:find("Archived",1,true))
    eq(model.branches[1].title,"Calm Hands: 10/10"); eq(Details.NewCaptureJob(env,c,scope).status,"blocked")
end)
case("U03 display markup preserves labels paragraphs and escapes unknown not source mutation",function()
    eq(Details.Plain("|cffaabbccColor|r |Hspell:1|hVisible|h |Ticon:12|t|A:atlas:12|a\n\n|bad"),"Color Visible \n\n||bad")
    eq(Details.Plain("|r |Tbroken |c1234"),"||r ||Tbroken ||c1234")
    eq(Details.Plain("||Tliteral|t"),"||Tliteral||t")
    local r=reportFixture(); local old=C.Copy(r); Details.Plain(r.trees[1].paths[1].perks[1].description); assert(deepEqual(r,old))
end)
case("U03 profession click left only lazy cached UI readonly wrapping navigation no auto collect",function(checkpoint)
    local env,s,c,scope,n,calls=fixture(); widgets(env)
    local ui=NS.Dashboard.New(env,c); ui:Toggle(); eq(ui.details,nil)
    local w=ui.widgets[1]; local cell=w.cells[I.Profession]
    cell.scripts.OnMouseDown(cell,"RightButton"); eq(ui.selected,w.row); eq(ui.details,nil)
    cell.scripts.OnMouseDown(cell,"LeftButton"); local view=assert(ui.details); eq(view.frame.shown,true)
    eq(#calls,0); eq(view.body.multiline,true); eq(view.body.style.SetAutoFocus[1],false); eq(view.body.focused,false)
    eq(view.scroll.scrollChild,view.body); eq(view.body.width,710); eq(view.frame.width,780); eq(view.frame.height,540)
    eq(view.driver.scripts.OnUpdate,nil); assert(view.body:GetText():find("Perks not observed",1,true))
    local text=view.body:GetText(); view.body:SetText("editable?"); eq(view.body:GetText(),text)
    view.refresh.scripts.OnClick(); local job=view.job; local old=active(c)
    for i=1,3 do
        local update=assert(view.driver.scripts.OnUpdate); local before=#calls; update()
        eq(job.steps,i); assert(#calls-before<=3); eq(active(c),old); eq(view.body:GetText(),text)
        pause(checkpoint,"U03 real UI frame")
    end
    local notified=0; c.changed=function() eq(view.job,nil); eq(view.driver.scripts.OnUpdate,nil); notified=notified+1 end
    view.driver.scripts.OnUpdate(); eq(job.status,"complete"); eq(notified,1)
    assert(view.body:GetText():find(PERK,1,true)); eq(view.footer:GetText(),"Recipe learning not checked in this slice.")
    local before=#calls; ui:Refresh(); ui:Render(); view:Open(scope); eq(#calls,before)
    view:Start(); local cancelled=view.job; local stale=view.driver.scripts.OnUpdate
    view:Start(); eq(cancelled.status,"cancelled"); local current=view.job; stale(); eq(current.steps,0)
    view.close.scripts.OnClick(); eq(current.status,"cancelled"); eq(view.driver.scripts.OnUpdate,nil)
end)
case("U03 panel Escape hide reopen combat cancellation parent fit and stable deleted scope",function(checkpoint)
    for _,mode in ipairs({"escape","hide","reopen","combat"}) do
        local env,s,c,scope=fixture(); widgets(env); local view=Details.NewView(env,c); assert(view:Open(scope)); view:Start()
        local job=view.job; local callback=view.driver.scripts.OnUpdate
        if mode=="escape" then view.frame.scripts.OnKeyDown(view.frame,"ESCAPE")
        elseif mode=="hide" then view.frame:Hide() elseif mode=="reopen" then view:Open(scope)
        elseif mode=="combat" then s.combat=true; callback() end
        eq(job.status,"cancelled"); eq(view.driver.scripts.OnUpdate,nil); callback(); eq(job.steps,0)
        s.combat=false; view:Open(scope); eq(view.driver.scripts.OnUpdate,nil)
        pause(checkpoint,"U03 UI cancellation")
    end
    local env,s,c,scope=fixture(); widgets(env); local view=Details.NewView(env,c)
    s.combat=true; eq(view:Open(scope),false); eq(view.frame,nil); s.combat=false
    env.UIParent.width=400; env.UIParent.height=300; assert(view:Open(scope)); assert(view.frame.scale<1)
    env.UIParent.width=0/0; env.UIParent.height=math.huge; view:Open(scope); eq(view.frame.scale,1)
    C.Delete(c.db,scope,true); view:Refresh(); eq(#view.model.branches,0); eq(view.refresh.enabled,false)
    local ctx=c:Context(); C.Apply(c.db,ctx.character,ctx.identity,{unspent=C.Observation("observed",0,300,"fixture")},300,"fixture")
    view:Refresh(); eq(#view.model.branches,0); eq(view.refresh.enabled,false)
end)
case("U03 long scroll branch nav zero locked earned-empty and unsupported read-only",function(checkpoint)
    local env,s,c,scope=fixture(); widgets(env); finish(Details.NewCaptureJob(env,c,scope),checkpoint)
    local g=active(c); local r=g.fields.professionDetails.last.value; local t=r.trees[1]; local p=t.paths[1]
    p.description=string.rep("Conditions apply to these crafts.\n\n",100); p.perks={}
    local second=C.Copy(p); second.id=106279; second.name="Locked"; second.locked=true; second.purchased=0
    second.description=""; t.paths[2]=second; t.capacity=20
    eq(C.Open(c.db),c.db)
    local view=Details.NewView(env,c); view:Open(scope); assert(view.body.height>view.scroll.height)
    eq(view.next.enabled,true); eq(view.previous.enabled,false); assert(view.body:GetText():find("None earned",1,true))
    view.next.scripts.OnClick(); eq(view.index,2); eq(view.title:GetText(),"Locked: 0/10")
    assert(view.body:GetText():find("Locked",1,true)); eq(view.next.enabled,false)
    view.previous.scripts.OnClick(); eq(view.index,1)
    local other=C.Copy(identity); other.skillLineID=999; other.parentID=164; other.profession=2
    local ctx=c:Context(); local new=assert(C.Apply(c.db,ctx.character,other,{unspent=C.Observation("observed",0,400,"fixture")},400,"fixture"))
    view:Open({guid=character.guid,id=999,generation=new.generation,archived=false})
    eq(view.refresh.enabled,false); assert(view.status:GetText():find("unavailable",1,true))
end)
case("U03 ordinary Scan never invokes new capture APIs cached offline open has no live reads",function()
    local env,s,c,scope,n,calls=fixture(); eq(c:Scan(),true); eq(#calls,1) -- ordinary existing GetNodeInfo only
    eq(calls[1][1],"node")
    widgets(env)
    local function forbidden() error("unexpected live cached read") end
    c.Context=forbidden; c.Now=forbidden
    for _,space in ipairs({env.C_ProfSpecs,env.C_Traits}) do for k in pairs(space) do space[k]=forbidden end end
    local view=Details.NewView(env,c); eq(view:Open(scope),true); view:Refresh(); eq(view.driver.scripts.OnUpdate,nil)
end)

-- Additional amended-contract fixtures use small selected native source projections,
-- not repeated large Scan workloads. No shared fixtures/widgets or host clocks change.
local function multiFixture(count,perks)
    local env,s,c,scope=fixture(); local g=active(c)
    local raw=g.fields.knowledgeRaw.last.value; local template=C.Copy(g.fields["tree:1124"].last.value)
    local rawTemplate=C.Copy(raw.tabs[1]); local nodes,calls={},{}
    raw.tabs={}; g.fields.knowledgeIndex.last.value={}; g.fields["tree:1124"]=nil
    local cursor=1
    while cursor<=count do
        local size=math.min(32,count-cursor+1); local id=1123+#raw.tabs+1
        local t=C.Copy(template); local tab=C.Copy(rawTemplate)
        t.id=id; t.root=106279+cursor; t.paths={}; t.purchased=10*size; t.capacity=10*size
        t.coverage.captured=size; t.coverage.discovered=size
        t.accountingEvidence.spent=10*count; t.accountingEvidence.totalPurchased=10*count
        t.currencies[1].spent=10*count
        tab.id=id; tab.root=t.root; tab.paths={}; tab.currencies[1].spent=10*count
        for j=1,size do
            local pid=106279+cursor; cursor=cursor+1
            local p=C.Copy(template.paths[1]); p.id=pid; p.node.ID=pid; p.name="Branch "..pid
            p.children=j<size and {pid+1} or {}
            t.paths[#t.paths+1]=p; tab.paths[pid]=C.Copy(p); nodes[pid]=p.node
        end
        raw.tabs[#raw.tabs+1]=tab
        g.fields.knowledgeIndex.last.value[#raw.tabs]={id=id,name=t.name,root=t.root}
        g.fields["tree:"..id]=C.Merge(nil,C.Observation("observed",t,100,"fixture"),"fixture",g.generation)
    end
    eq(C.Open(c.db),c.db)
    local function log(kind,...) calls[#calls+1]={kind,...} end
    env.C_Traits.GetNodeInfo=function(config,id) eq(config,1001); assert(nodes[id]); log("node",config,id); return nodes[id] end
    env.C_ProfSpecs.GetDescriptionForPath=function(id) assert(nodes[id]); log("path",id); return "" end
    env.C_ProfSpecs.GetPerksForPath=function(id)
        assert(nodes[id]); log("list",id); local out={}
        for i=1,perks or 0 do out[i]={perkID=id*100+i,isMajorPerk=i%2==0} end
        return out
    end
    env.C_ProfSpecs.GetUnlockRankForPerk=function(id) log("rank",id); return 0 end
    env.C_ProfSpecs.GetStateForPerk=function(id,config) eq(config,1001); log("state",id,config); return 2 end
    env.C_ProfSpecs.GetDescriptionForPerk=function(id) log("perk",id); return "Conditional milestone.\n\nApplies only to these crafts." end
    return env,s,c,scope,nodes,calls
end
local function boundedReport(paths,perks)
    local r=reportFixture(); r.trees={}
    local id=1
    while id<=paths do
        local t={id=100+#r.trees,name="Tree",root=id,purchased=0,capacity=0,paths={}}
        for j=1,math.min(32,paths-id+1) do
            local p={id=id,name="Branch",purchased=0,capacity=10,locked=false,description="",perks={}}
            for k=1,perks or 0 do p.perks[k]={id=id*100+k,rank=0,state=0,isMajorPerk=false,description="x"} end
            t.paths[#t.paths+1]=p; t.capacity=t.capacity+10; id=id+1
        end
        r.trees[#r.trees+1]=t
    end
    return r
end
case("U03 global64 paths512 perks exact fit overflow cross-tree duplicate identities and zero boundaries",function(checkpoint)
    local r=boundedReport(64,8); eq(C.ValidPayload("professionDetails",r,"observed"),true)
    r.trees[2].paths[1].perks[9]={id=99999,rank=0,state=0,isMajorPerk=false,description="x"}
    eq(C.ValidPayload("professionDetails",r,"observed"),false,"513 global perks")
    pause(checkpoint,"U03 global typed limits")
    eq(C.ValidPayload("professionDetails",boundedReport(65,0),"observed"),false,"65 global paths")
    r=boundedReport(33,1); r.trees[2].paths[1].id=r.trees[1].paths[1].id
    r.trees[2].root=r.trees[2].paths[1].id; eq(C.ValidPayload("professionDetails",r,"observed"),false)
    r=boundedReport(33,1); r.trees[2].paths[1].perks[1].id=r.trees[1].paths[1].perks[1].id
    eq(C.ValidPayload("professionDetails",r,"observed"),false)
    r=boundedReport(1,0); local p=r.trees[1].paths[1]; p.name=string.rep("n",256); r.trees[1].name=p.name
    eq(C.ValidPayload("professionDetails",r,"observed"),true); p.locked=true
    eq(C.ValidPayload("professionDetails",r,"observed"),true)
    p.perks={{id=1,rank=0,state=2,isMajorPerk=false,description="x"}}
    eq(C.ValidPayload("professionDetails",r,"observed"),false,"locked rank0 not earned")
    p.locked=false; eq(C.ValidPayload("professionDetails",r,"observed"),true,"unlocked zero rank0 earned")
    p.perks[1].rank=1; eq(C.ValidPayload("professionDetails",r,"observed"),false,"earned above investment")
    p.perks[1].state=0; eq(C.ValidPayload("professionDetails",r,"observed"),true)
end)
case("U03 compact final64 scalar batch exact counts source order no pernode Context or DB walk",function(checkpoint)
    local env,s,c,scope,nodes,calls=multiFixture(64,0)
    local originalOpen,originalCopy=C.Open,C.Copy
    local opens,copies,contexts=0,0,0; local originalContext=c.Context
    local job
    -- Wrappers are restored before each checkpoint, including on assertion errors.
    local function measured(fn)
        C.Open=function(...) opens=opens+1; return originalOpen(...) end
        C.Copy=function(...) copies=copies+1; return originalCopy(...) end
        c.Context=function(...) contexts=contexts+1; return originalContext(...) end
        local ok,why=pcall(fn)
        C.Open=originalOpen; C.Copy=originalCopy; c.Context=originalContext
        assert(ok,why)
    end
    measured(function() job=Details.NewCaptureJob(env,c,scope) end)
    eq(job.status,"running"); eq(opens,1); eq(copies,0); eq(#calls,0)
    for i=1,128 do
        local before=#calls; local oldOpen,oldCopy=opens,copies
        measured(function() job:Step() end)
        eq(opens,oldOpen); eq(copies,oldCopy)
        eq(#calls-before,i<=64 and 3 or 1); eq(job.status,"running")
        pause(checkpoint,"U03 bounded normal unit")
    end
    eq(job.phase,"commit"); local before=#calls; local oldContext=contexts; local oldOpen=opens
    measured(function() job:Step() end)
    eq(job.status,"complete"); eq(job.steps,129); eq(#calls-before,64)
    eq(contexts-oldContext,2,"only bracketing Contexts in final batch")
    eq(opens-oldOpen,1,"only unchanged Apply opens the DB")
    local r=active(c).fields.professionDetails.last.value; local i=before+1
    for _,t in ipairs(r.trees) do for _,p in ipairs(t.paths) do
        eq(calls[i][1],"node"); eq(calls[i][2],1001); eq(calls[i][3],p.id); i=i+1
    end end
    eq(#r.trees,2); eq(#r.trees[1].paths,32); eq(#r.trees[2].paths,32)
    local saved=C.Copy(r); nodes[106280].currentRank=0
    assert(deepEqual(r,saved),"raw native node not retained by report")
end)
case("U03 first path changed after prior verify and final gap across every source path discards",function(checkpoint)
    for _,boundary in ipairs({4,5,6}) do
        for _,id in ipairs({106280,106281,106282}) do
            local env,s,c,scope,nodes=multiFixture(3,0); local job=Details.NewCaptureJob(env,c,scope)
            for i=1,boundary do job:Step() end
            local before=c.db.characters[character.guid]; nodes[id].activeEntry.rank=9
            finish(job,checkpoint); eq(job.status,"discarded"); eq(c.db.characters[character.guid],before)
            eq(active(c).fields.professionDetails,nil)
            pause(checkpoint,"U03 late multipath point change")
        end
    end
end)
case("U03 final batch missing errors malformed nodes and callback invalidation terminal no retry",function(checkpoint)
    for _,mode in ipairs({"missing","nil","throw","bad","reenter","cancel","stage","pointer","schema","time"}) do
        local env,s,c,scope,nodes,calls=multiFixture(3,0); local job=Details.NewCaptureJob(env,c,scope)
        for i=1,6 do job:Step() end
        local before=c.db.characters[character.guid]; local original=env.C_Traits.GetNodeInfo
        env.C_Traits.GetNodeInfo=function(config,id)
            if id==106281 then
                if mode=="nil" then return nil elseif mode=="throw" then error("PRIVATE FINAL")
                elseif mode=="bad" then return {ID=id} elseif mode=="reenter" then job:Step()
                elseif mode=="cancel" then job:Cancel() elseif mode=="stage" then s.staged=true
                elseif mode=="pointer" then before.professions[2913].active=C.Copy(active(c))
                elseif mode=="schema" then c.db.schema=2 elseif mode=="time" then s.at=199 end
            end
            return original(config,id)
        end
        if mode=="missing" then env.C_Traits.GetNodeInfo=nil end
        job:Step(); assert(job.status~="running"); assert(job.status~="complete")
        local count=#calls; job:Step(); eq(#calls,count); eq(c.db.characters[character.guid],before)
        eq(active(c).fields.professionDetails,nil); assert(not job.reason:find("PRIVATE",1,true))
        pause(checkpoint,"U03 terminal final batch")
    end
end)
case("U03 every raw node scalar and activeEntry uses actual native integer guard before compare",function(checkpoint)
    local keys={"ID","type","flags","currentRank","activeRank","ranksPurchased","ranksIncreased","maxRanks","totalMaxRanks","entryID","rank","isAvailable"}
    for _,phase in ipairs({"metadata","verify","commit"}) do
        for _,key in ipairs(keys) do
            local env,s,c,scope,n=fixture(); local job=Details.NewCaptureJob(env,c,scope)
            if phase~="metadata" then job:Step(); job:Step() end
            if phase=="commit" then job:Step() end
            local before=c.db.characters[character.guid]
            if key=="entryID" or key=="rank" then n.activeEntry[key]=0/0
            elseif key=="isAvailable" then n[key]=1 else n[key]=0/0 end
            finish(job,checkpoint); assert(job.status~="complete",key..phase); eq(c.db.characters[character.guid],before)
            pause(checkpoint,"U03 actual runtime numeric rejection")
        end
    end
    for _,bad in ipairs({math.huge,-math.huge,-1,0.5,"11",false}) do
        local env,s,c,scope,n=fixture(); local job=Details.NewCaptureJob(env,c,scope); n.currentRank=bad
        finish(job,checkpoint); assert(job.status~="complete")
        pause(checkpoint,"U03 typed current node")
    end
end)
case("U03 backwards clocks within jobs prior good time and actual final validated time",function(checkpoint)
    for _,boundary in ipairs({0,1,2,3}) do
        local env,s,c,scope=fixture(); eq(finish(Details.NewCaptureJob(env,c,scope)).status,"complete")
        local old=C.Copy(active(c).fields.professionDetails); s.at=300
        local job=Details.NewCaptureJob(env,c,scope)
        for i=1,boundary do job:Step() end
        local before=c.db.characters[character.guid]; s.at=299
        finish(job,checkpoint); assert(job.status~="complete"); eq(c.db.characters[character.guid],before)
        assert(deepEqual(old,active(c).fields.professionDetails))
    end
    local env,s,c,scope=fixture(); eq(finish(Details.NewCaptureJob(env,c,scope)).status,"complete")
    s.at=199; eq(Details.NewCaptureJob(env,c,scope).status,"blocked","older than previous good details")
    s.at=300; local job=Details.NewCaptureJob(env,c,scope); job:Step(); job:Step(); job:Step()
    local original=c.Context; local contexts=0
    c.Context=function(self) contexts=contexts+1; if contexts==2 then s.at=305 end; return original(self) end
    job:Step(); eq(job.status,"complete"); eq(active(c).fields.professionDetails.last.observedAt,305)
    eq(active(c).scannedAt,100)
end)
case("U03 failed attempt also final verifies points or writes nothing and preserves successful freshness",function(checkpoint)
    for _,mode in ipairs({"points","unavailable","safe"}) do
        local env,s,c,scope,n=fixture(); eq(finish(Details.NewCaptureJob(env,c,scope)).status,"complete")
        local before=c.db.characters[character.guid]; local last=C.Copy(active(c).fields.professionDetails.last)
        s.at=400; env.C_ProfSpecs.GetStateForPerk=function() return 1 end
        local job=Details.NewCaptureJob(env,c,scope); job:Step(); job:Step(); eq(job.phase,"commit")
        if mode=="points" then n.currentRank=9 elseif mode=="unavailable" then env.C_Traits.GetNodeInfo=nil end
        job:Step(); assert(job.status~="running"); eq(job.status=="complete",false)
        if mode=="safe" then
            eq(job.committed,true); eq(active(c).fields.professionDetails.attempt.status,"unknown")
            eq(c.fresh[character.guid..":2913"].fields.professionDetails,nil)
        else eq(c.db.characters[character.guid],before); eq(c.fresh[character.guid..":2913"].fields.professionDetails,true) end
        assert(deepEqual(last,active(c).fields.professionDetails.last)); eq(active(c).scannedAt,100)
        pause(checkpoint,"U03 failure final fingerprint")
    end
end)
case("U03 capture512 perks global count and32768 text fits caps reject whole report no truncation",function(checkpoint)
    local env,s,c,scope=multiFixture(16,32); local job=finish(Details.NewCaptureJob(env,c,scope),checkpoint)
    eq(job.status,"complete"); eq(job.steps,545); local r=active(c).fields.professionDetails.last.value
    local count=0; for _,t in ipairs(r.trees) do for _,p in ipairs(t.paths) do count=count+#p.perks end end
    eq(count,512)
    pause(checkpoint,"U03 max perks captured")
    env,s,c,scope=multiFixture(17,32); job=finish(Details.NewCaptureJob(env,c,scope),checkpoint)
    eq(job.status,"failed"); eq(active(c).fields.professionDetails.last,nil)
    env,s,c,scope=multiFixture(65,0); eq(Details.NewCaptureJob(env,c,scope).status,"blocked")
    for _,overflow in ipairs({false,true}) do
        env,s,c,scope=multiFixture(1,8)
        env.C_ProfSpecs.GetDescriptionForPerk=function() return string.rep("x",4096) end
        env.C_ProfSpecs.GetDescriptionForPath=function() return overflow and "x" or "" end
        job=finish(Details.NewCaptureJob(env,c,scope),checkpoint)
        eq(job.status,overflow and "failed" or "complete")
        if not overflow then eq(#active(c).fields.professionDetails.last.value.trees[1].paths[1].perks[8].description,4096) end
        pause(checkpoint,"U03 byte cap capture")
    end
end)
case("U03 source pointer root schema identity config and complete metadata stay guarded no writes",function(checkpoint)
    for _,mode in ipairs({"root","map","char","profession","fields","schema","identity","config","source","rawstale","treegap","rawnode"}) do
        local env,s,c,scope=fixture(); local before=c.db.characters[character.guid]
        if mode=="rawstale" then active(c).fields.knowledgeRaw.last.observedAt=99
        elseif mode=="treegap" then active(c).fields["tree:1124"].attempt.status="unknown"
        elseif mode=="rawnode" then active(c).fields.knowledgeRaw.last.value.tabs[1].paths[106280].node.currentRank=10 end
        local job=Details.NewCaptureJob(env,c,scope)
        if mode=="rawstale" or mode=="treegap" or mode=="rawnode" then eq(job.status,"blocked")
        else
            job:Step()
            if mode=="root" then c.db=C.Copy(c.db)
            elseif mode=="map" then c.db.characters=C.Copy(c.db.characters)
            elseif mode=="char" then c.db.characters[character.guid]=C.Copy(before)
            elseif mode=="profession" then before.professions[2913]=C.Copy(before.professions[2913])
            elseif mode=="fields" then active(c).fields.unspent.last.value=false
            elseif mode=="schema" then c.db.schema=2
            elseif mode=="identity" then s.info.profession=2
            elseif mode=="config" then env.C_ProfSpecs.GetConfigIDForSkillLine=function() return 1002 end
            elseif mode=="source" then s.info.sourceCounter=s.info.sourceCounter+1 end
            local current=c.db.characters[character.guid]; finish(job,checkpoint); assert(job.status~="complete",mode)
            eq(c.db.characters[character.guid],current); eq(active(c).fields.professionDetails,nil)
        end
        pause(checkpoint,"U03 source ownership guards")
    end
end)
case("U03 nested repeated and hostile display wrappers preserve visible labels and conditions",function()
    local nested="|cffaabbcc|Hspell:123|h|cff112233Visible|r |Ticon:12|tlabel|h|r\n\nOnly these crafts."
    eq(Details.Plain(nested),"Visible label\n\nOnly these crafts.")
    eq(Details.Plain("|Hspell:1|h|cffffffffLink|r|A:atlas:12|a|h"),"Link")
    eq(Details.Plain(string.rep("|cffffffff|Hspell:1|hA|h|r",100)),string.rep("A",100))
    eq(Details.Plain("|Hbad|hmissing |r |T:bad|t"),"||Hbad||hmissing ||r ||T:bad||t")
    local hostile=string.rep("|cffffffff",64).."Visible\n\nConditions"..string.rep("|r",64)
    local out=Details.Plain(hostile); assert(out:find("Visible\n\nConditions",1,true)); assert(#out<2*#hostile)
    -- Every pipe that survives is escaped; no executable unknown markup remains.
    eq((out:gsub("||","")):find("|",1,true),nil)
    local r=reportFixture(); r.trees[1].paths[1].description=nested; local old=C.Copy(r)
    local db=dbWith({professionDetails=r}); local c=NS.Collectors.New({},db)
    local model=Details.Model(c,{guid=character.guid,id=2913,generation=1,archived=false})
    assert(Details.Branch(model,1).body:find("Visible label",1,true)); assert(deepEqual(r,old))
end)
case("U03 own relative age unknown clocks current versus stale saved and returned model ownership",function(checkpoint)
    local env,s,c,scope=fixture(); finish(Details.NewCaptureJob(env,c,scope),checkpoint)
    local now=active(c).fields.professionDetails.last.observedAt
    for _,sample in ipairs({{now,"0s ago"},{now+61,"1m ago"},{now+3601,"1h ago"},{now+86401,"1d ago"}}) do
        s.at=sample[1]; assert(Details.Model(c,scope).status:find(sample[2],1,true))
    end
    for _,bad in ipairs({now-1,0/0,math.huge,false}) do
        s.at=bad; assert(Details.Model(c,scope).status:find("age unknown",1,true))
    end
    c.Now=function() error("private clock") end
    assert(Details.Model(c,scope).status:find("age unknown",1,true))
    local before=C.Copy(active(c)); local model=Details.Model(c,scope)
    model.branches[1].path.perks[1].description="changed"; assert(deepEqual(before,active(c)))
    eq(model.branches[1].body,nil,"only selected body is formatted")
    active(c).scannedAt=101; assert(Details.Model(c,scope).status:find("not current",1,true))
end)
case("U03 combat retirement refreshes saved status no progress leftovers or autoresume",function(checkpoint)
    local env,s,c,scope=fixture(); widgets(env); finish(Details.NewCaptureJob(env,c,scope),checkpoint)
    local view=Details.NewView(env,c); view:Open(scope); local saved=view.body:GetText()
    view:Start(); local job=view.job; view.driver.scripts.OnUpdate(); assert(view.status:GetText():find("unit",1,true))
    local callback=view.driver.scripts.OnUpdate; s.combat=true; callback()
    eq(job.status,"cancelled"); eq(view.driver.scripts.OnUpdate,nil); eq(view.job,nil)
    assert(view.status:GetText():find("cancelled",1,true)); assert(view.status:GetText():find("saved",1,true))
    assert(not view.status:GetText():find("unit",1,true)); eq(view.body:GetText(),saved)
    s.combat=false; callback(); eq(view.driver.scripts.OnUpdate,nil)
end)
case("U03 all required payload scalar native bounds reject nil nonnumbers fractions infinities NaN",function(checkpoint)
    local sites={
        {"version"},{"skillLineID"},{"configID"},{"sourceScanAt"},
        {"trees",1,"id"},{"trees",1,"root"},{"trees",1,"purchased"},{"trees",1,"capacity"},
        {"trees",1,"paths",1,"id"},{"trees",1,"paths",1,"purchased"},{"trees",1,"paths",1,"capacity"},
        {"trees",1,"paths",1,"perks",1,"id"},{"trees",1,"paths",1,"perks",1,"rank"},{"trees",1,"paths",1,"perks",1,"state"},
    }
    for _,site in ipairs(sites) do
        for _,mode in ipairs({"nil","false","string","fraction","negative","inf","nan"}) do
            local r=reportFixture(); local parent=r
            for i=1,#site-1 do parent=parent[site[i]] end
            local v
            if mode=="false" then v=false elseif mode=="string" then v="1" elseif mode=="fraction" then v=0.5
            elseif mode=="negative" then v=-1 elseif mode=="inf" then v=math.huge elseif mode=="nan" then v=0/0 end
            parent[site[#site]]=v
            eq(C.ValidPayload("professionDetails",r,"observed"),false,table.concat(site,"/").." "..mode)
        end
        pause(checkpoint,"U03 required payload numbers")
    end
    local r=boundedReport(1,1); local t=r.trees[1]; local p=t.paths[1]; local k=p.perks[1]
    t.id=2147483647; t.root=2147483647; p.id=2147483647; k.id=2147483647
    p.capacity=2147483647; t.capacity=p.capacity; k.rank=p.capacity; r.configID=2147483647
    eq(C.ValidPayload("professionDetails",r,"observed"),true,"inclusive native ID/rank/cap endpoints")
    p.capacity=p.capacity+1; t.capacity=p.capacity; eq(C.ValidPayload("professionDetails",r,"observed"),false)
    r=boundedReport(1,8); p=r.trees[1].paths[1]
    for _,perk in ipairs(p.perks) do perk.description=string.rep("é",2048) end
    eq(C.ValidPayload("professionDetails",r,"observed"),true,"32768 bytes not characters")
    p.description="é"; eq(C.ValidPayload("professionDetails",r,"observed"),false)
end)
case("U03 capture getter boundaries context invalidation discard and completed jobs never resume",function(checkpoint)
    for _,getter in ipairs({"GetDescriptionForPath","GetPerksForPath","GetUnlockRankForPerk","GetStateForPerk","GetDescriptionForPerk"}) do
        for _,mode in ipairs({"closed","combat","foreign","revision","db"}) do
            local env,s,c,scope=fixture(); local job=Details.NewCaptureJob(env,c,scope)
            local old=env.C_ProfSpecs[getter]
            env.C_ProfSpecs[getter]=function(...)
                local v=old(...)
                if mode=="closed" then s.shown=false elseif mode=="combat" then s.combat=true
                elseif mode=="foreign" then s.linked=true elseif mode=="revision" then c.revision=c.revision+1
                elseif mode=="db" then c.db=C.Copy(c.db) end
                return v
            end
            local before=c.db.characters[character.guid]; finish(job,checkpoint)
            eq(job.status,"discarded",getter..mode); eq(active(c).fields.professionDetails,nil)
            s.shown=true; s.combat=false; s.linked=false
            local step=job.steps; job:Step(); eq(job.steps,step)
            if mode~="db" then eq(c.db.characters[character.guid],before) end
            pause(checkpoint,"U03 native getter context boundary")
        end
    end
end)
case("U03 saved report uses own investment offline archive navigation filter reorder scope and zero gained wording",function(checkpoint)
    local env,s,c,scope=fixture(); widgets(env); finish(Details.NewCaptureJob(env,c,scope),checkpoint)
    local ui=NS.Dashboard.New(env,c); ui:Toggle(); local cell=ui.widgets[1].cells[I.Profession]
    cell.scripts.OnMouseDown(cell,"LeftButton"); local view=ui.details
    local text=view.body:GetText(); local copy=C.Copy(c.db)
    local another=C.Copy(copy.characters[character.guid]); another.name="Another"
    c.db.characters["Player-Other"]=another; ui:Refresh()
    ui.options.character="No matching character"; ui:Refresh(); eq(#ui.rows,0)
    eq(view.scope.guid,scope.guid); eq(view.title:GetText(),"Calm Hands: 10/10"); eq(view.body:GetText(),text)
    ui.options.character=nil; ui.options.sort="concentration"; ui:Refresh(); eq(view.scope.guid,scope.guid)
    s.shown=false; c:Invalidate("closed"); ui:Refresh()
    assert(view.status:GetText():find("Saved / stale",1,true)); eq(view.body:GetText(),text)
    local calls=0; c.Context=function() calls=calls+1; error("offline context not allowed") end
    c.db=copy; c.fresh={}; view:Open(scope); eq(calls,0)
    eq(view.body:GetText(),text)
    eq(C.Archive(c.db,scope.guid,scope.id,500,"fixture"),true); view:Refresh()
    assert(view.status:GetText():find("unavailable",1,true)); eq(view.refresh.enabled,false)
    scope.archived=true; view:Open(scope); eq(view.refresh.enabled,false); eq(view.body:GetText(),text)
    local archived=c.db.characters[scope.guid].professions[scope.id].archives[1]
    local r=archived.fields.professionDetails.last.value; local t=r.trees[1]; local p=t.paths[1]
    p.purchased=0; t.purchased=0; p.perks[1].state=2; p.perks[1].rank=0
    view:Refresh(); assert(view.body:GetText():find("0 invested",1,true))
    assert(view.body:GetText():find("not a flat earned gain",1,true)); assert(view.body:GetText():find(PERK,1,true))
    eq(calls,0)
end)
case("U03 locked native source unearned is observed not earned rank0 contradiction preserves unknown",function(checkpoint)
    for _,state in ipairs({0,2}) do
        local env,s,c,scope,n=fixture(); local g=active(c); local tree=g.fields["tree:1124"].last.value
        local p=tree.paths[1]
        p.purchased=0; p.locked=true; tree.purchased=0
        n.ranksPurchased=0; n.currentRank=0; n.activeRank=0
        n.activeEntry={entryID=131041,rank=0}; n.nextEntry={entryID=131041,rank=1}; n.entryIDsWithCommittedRanks={}
        p.node=C.Copy(n); p.costs={{ID=3912,amount=1}}
        tree.accountingEvidence.spent=0; tree.accountingEvidence.totalPurchased=0
        tree.currencies={{traitCurrencyID=3902,quantity=0,spent=0},{traitCurrencyID=3912,quantity=1,spent=0}}
        local tab=g.fields.knowledgeRaw.last.value.tabs[1]
        tab.paths[106280]=C.Copy(p); tab.currencies=C.Copy(tree.currencies)
        eq(C.Open(c.db),c.db)
        env.C_ProfSpecs.GetStateForPerk=function() return state end
        local job=finish(Details.NewCaptureJob(env,c,scope),checkpoint)
        eq(job.status,state==0 and "complete" or "failed")
        local last=active(c).fields.professionDetails.last
        if state==0 then
            eq(last.value.trees[1].paths[1].perks[1].state,0)
            local body=Details.Branch(Details.Model(c,scope),1).body
            assert(body:find("Locked",1,true)); assert(body:find("None earned",1,true)); assert(not body:find(PERK,1,true))
        else eq(last,nil) end
        pause(checkpoint,"U03 locked native source")
    end
end)
end
-- U03 END

-- U04 BEGIN: presentation-only regressions; fixture helpers are local to this block.
do
local V=NS.ViewModel
local function unchanged(root)
    local records={}
    local function visit(t)
        if type(t)~="table" or records[t] then return end
        local saved={}; records[t]=saved
        for k,v in pairs(t) do saved[k]=v; visit(v) end
    end
    visit(root)
    return function()
        for t,saved in pairs(records) do
            for k,v in pairs(saved) do eq(t[k],v,"U04 source value/reference unchanged") end
            for k in pairs(t) do assert(saved[k]~=nil,"U04 no source key added") end
        end
    end
end
local function forbidReads(env,c)
    local function forbidden() error("U04 render/hover must not collect") end
    for _,api in ipairs({env.C_TradeSkillUI,env.C_ProfSpecs,env.C_Traits,env.C_Item,env.C_CurrencyInfo}) do
        for k,v in pairs(api) do if type(v)=="function" then api[k]=forbidden end end
    end
    for _,key in ipairs({"Scan","Request","Knowledge","Gear","Context"}) do c[key]=forbidden end
end
local function fixture(values)
    local env,s=fixtureAPI(); mockWidgets(env)
    env.CraftArmyDiagnosticsDB={sentinel={points=17}}
    local db,g=dbWith(values or payloadFixtures())
    local c=NS.Collectors.New(env,db); local ui=NS.Dashboard.New(env,c); ui:Toggle()
    return ui,env,c,g,s
end
local function enter(env,bar,shift)
    env.IsShiftKeyDown=function() return shift end
    bar.scripts.OnEnter(bar)
    return env.GameTooltip.lines
end
local function exactLines(actual,expected)
    eq(#actual,#expected,"full hover line count")
    for n,line in ipairs(expected) do eq(actual[n],NS.Dashboard.PlainTooltip(line),"hover line "..n) end
end
local function hierarchy()
    local values=payloadFixtures(); local t=values["tree:11"]; local template=C.Copy(t.paths[1])
    t.root=111; t.paths={}; t.purchased=8; t.capacity=40
    t.coverage={discovered=4,captured=4,limit=false}
    local names={"静かな手","静かな手","Écriture tranquille","Sibling"}
    local points={3,5,0,0}; local children={{112,114},{113},{},{}}
    for n=1,4 do
        local p=C.Copy(template); p.id=110+n; p.name=names[n]; p.purchased=points[n]
        p.capacity=10; p.children=children[n]; p.locked=n==3; t.paths[n]=p
    end
    values.knowledgeIndex[1].root=111
    return values
end
case("U04 real bars numeric zero full unknown labels and built in flat texture",function(checkpoint)
    for _,mode in ipairs({"zero","full","unknown"}) do
        local values=payloadFixtures()
        values.knowledgeIndex[1].name="Blu Cal Per Dar"
        if mode=="full" then values["tree:11"]=treeValue(11,10,10)
        elseif mode=="unknown" then values["tree:11"]=nil end
        local ui,env,c,_,s=fixture(values); local bar=ui.widgets[1].bars[1]
        local verify=unchanged({c.db,c.fresh,ui.rows,env.CraftArmyDiagnosticsDB,s})
        forbidReads(env,c); ui:Render()
        eq(bar.label:GetText(),mode=="unknown" and "?" or mode=="full" and "10/10" or "0/10")
        assert(not bar.label:GetText():find("[:]"),"no name or colon prefix")
        eq(bar.style.SetStatusBarTexture[1],"Interface\\Buttons\\WHITE8X8")
        for n,value in ipairs({0.45,0.50,0.58}) do eq(bar.style.SetStatusBarColor[n],value) end
        eq(bar.style.SetMinMaxValues[1],0); eq(bar.style.SetMinMaxValues[2],1)
        eq(bar.height,14); eq(bar.background.style.SetColorTexture[1],0.15)
        eq(bar.background.style.SetColorTexture[2],0.15); eq(bar.background.style.SetColorTexture[3],0.15)
        eq(bar.background.style.SetColorTexture[4],1)
        eq(bar.value,mode=="full" and 1 or 0); eq(bar:GetStatusBarTexture().shown,mode~="unknown")
        exactLines(enter(env,bar,false),bar.tree.summaryTooltip)
        exactLines(enter(env,bar,true),bar.tree.tooltip)
        bar.scripts.OnLeave(bar); eq(env.GameTooltip.shown,false); verify()
        pause(checkpoint,"U04 numeric bar mode")
    end
end)
case("U04 real render geometry one four eight trees uses full column and reuses widgets",function()
    local ui,env,c,_,s=fixture(); local row=ui.rows[1]; local source=row.trees[1]
    local pool={}; for n,b in ipairs(ui.widgets[1].bars) do pool[n]=b end
    local verify=unchanged({c.db,c.fresh,env.CraftArmyDiagnosticsDB,s})
    forbidReads(env,c)
    -- U10 ADAPT U04_FRAME BEGIN
--[====[U10 ORIGINAL BEGIN
    local expected={110,100,150,64,44,44,44,140,110,96,56,292,74,100}
    eq(ui.frame.width,1454); eq(ui.frame.height,216); eq(ui.viewport.width,1424)
U10 ORIGINAL END]====]
    -- U11 ADAPT U04_FRAME BEGIN
--[======[U11 ORIGINAL BEGIN
    local expected={110,100,150,64,44,44,44,0,0,96,56,292,74,100}
    eq(ui.frame.width,1204); eq(ui.frame.height,226); eq(ui.viewport.width,1174)
U11 ORIGINAL END]======]
    -- U12 ADAPT U04_FRAME BEGIN
--[========[U12 ORIGINAL BEGIN
    local expected={110,100,150,64,28,28,28,0,0,96,56,292,74,100}
    eq(ui.frame.width,1156); eq(ui.frame.height,222); eq(ui.viewport.width,1126)
U12 ORIGINAL END]========]
    local expected={110,100,150,64,34,28,34,0,0,96,56,292,74,100}
    -- U13 ADAPT U04_WINDOW BEGIN
--[==========[U13 ORIGINAL BEGIN
    eq(ui.frame.width,1168); eq(ui.frame.height,222); eq(ui.viewport.width,1138)
U13 ORIGINAL END]==========]
    eq(ui.frame.width,1184); eq(ui.frame.height,222); eq(ui.viewport.width,1138)
    -- U13 ADAPT U04_WINDOW END
    -- U12 ADAPT U04_FRAME END
    -- U11 ADAPT U04_FRAME END
    -- U10 ADAPT U04_FRAME END
    local x=15
    for col,width in ipairs(expected) do
        local header,cell=ui.headers[col],ui.widgets[1].cells[col]
        eq(env.fixtureRect(header).x,x); eq(env.fixtureRect(cell).x,x)
        -- U10 ADAPT U04_CELL BEGIN
--[====[U10 ORIGINAL BEGIN
        eq(header.width,width); eq(cell.width,width); eq(cell.height,22); eq(header.height,18)
U10 ORIGINAL END]====]
        -- U11 ADAPT U04_CELL BEGIN
--[======[U11 ORIGINAL BEGIN
        eq(header.width,col==I.Accessory1 and 132 or header.hiddenColumn and 0 or width)
        eq(cell.width,width); eq(cell.height,32); eq(header.height,18)
U11 ORIGINAL END]======]
        -- U12 ADAPT U04_HEADER BEGIN
--[========[U12 ORIGINAL BEGIN
        eq(header.width,col==I.Accessory1 and 84 or header.hiddenColumn and 0 or width)
U12 ORIGINAL END]========]
        eq(header.width,col==I.Accessory1 and 96 or header.hiddenColumn and 0 or width)
        -- U12 ADAPT U04_HEADER END
        eq(cell.width,width); eq(cell.height,28); eq(header.height,18)
        -- U11 ADAPT U04_CELL END
        -- U10 ADAPT U04_CELL END
        eq(header.label.template,"GameFontHighlightSmall"); eq(cell.label.template,"GameFontHighlightSmall")
        x=x+width
    end
    -- U10 ADAPT U04_RIGHT BEGIN
--[====[U10 ORIGINAL BEGIN
    eq(x,1439)
U10 ORIGINAL END]====]
    -- U11 ADAPT U04_RIGHT BEGIN
--[======[U11 ORIGINAL BEGIN
    eq(x,1189)
U11 ORIGINAL END]======]
    -- U12 ADAPT U04_RIGHT BEGIN
--[========[U12 ORIGINAL BEGIN
    eq(x,1141)
U12 ORIGINAL END]========]
    eq(x,1153)
    -- U12 ADAPT U04_RIGHT END
    -- U11 ADAPT U04_RIGHT END
    -- U10 ADAPT U04_RIGHT END
    for _,count in ipairs({8,4,1,0,1,0}) do
        -- Bounded model-only projection; the valid saved DB is never expanded to eight trees.
        row.trees={}; row.cells[I.Knowledge]=count==0 and "?" or ""
        for n=1,count do row.trees[n]=C.Copy(source) end
        if count==1 then row.trees[1].purchased=nil; row.trees[1].capacity=nil; row.trees[1].ratio=nil end
        ui:Render(); eq(#ui.widgets[1].bars,8)
        local right=env.fixtureRect(ui.widgets[1].cells[I.Knowledge]).x
        for n,b in ipairs(pool) do
            eq(ui.widgets[1].bars[n],b,"same bar widget"); eq(b.shown,n<=count)
            eq(b.tree,row.trees[n],"hidden bars release old tree")
            if n<=count then
                local width=288/count-2; local r=env.fixtureRect(b)
                eq(b.width,width); eq(b.label.width,width); eq(b.label.allPoints,b); eq(b.height,14)
                eq(r.x,right); contained(env,b,ui.widgets[1].cells[I.Knowledge],"knowledge bar")
                if count==4 then eq(width,70); assert(width>53,"old cap removed") end
                if count==1 then eq(width,286); eq(b.label:GetText(),"?"); eq(b.fill.shown,false)
                else eq(b.label:GetText(),"0/10"); eq(b.value,0); eq(b.fill.shown,true) end
                right=r.x+r.w+2
            end
        end
        eq(ui.widgets[1].cells[I.Knowledge].label:GetText(),count==0 and "?" or "")
        -- U10 ADAPT U04_REUSE BEGIN
--[====[U10 ORIGINAL BEGIN
        eq(ui.frame.width,1454); eq(ui.frame.height,216); verify()
U10 ORIGINAL END]====]
        -- U11 ADAPT U04_REUSE BEGIN
--[======[U11 ORIGINAL BEGIN
        eq(ui.frame.width,1204); eq(ui.frame.height,226); verify()
U11 ORIGINAL END]======]
        -- U12 ADAPT U04_REUSE BEGIN
--[========[U12 ORIGINAL BEGIN
        eq(ui.frame.width,1156); eq(ui.frame.height,222); verify()
U12 ORIGINAL END]========]
        -- U13 ADAPT U04_REUSE BEGIN
--[==========[U13 ORIGINAL BEGIN
        eq(ui.frame.width,1168); eq(ui.frame.height,222); verify()
U13 ORIGINAL END]==========]
        eq(ui.frame.width,1184); eq(ui.frame.height,222); verify()
        -- U13 ADAPT U04_REUSE END
        -- U12 ADAPT U04_REUSE END
        -- U11 ADAPT U04_REUSE END
        -- U10 ADAPT U04_REUSE END
    end
end)
case("U04 real hierarchy hover root child grandchild sibling UTF duplicate locked zero exact Shift",function()
    local ui,env,c,g,s=fixture(hierarchy()); local row=ui.rows[1]; local bar=ui.widgets[1].bars[1]
    local verify=unchanged({c.db,c.fresh,ui.rows,env.CraftArmyDiagnosticsDB,s})
    local detail={}; for n,line in ipairs(row.trees[1].tooltip) do detail[n]=line end
    forbidReads(env,c); ui:Render()
    eq(bar.label:GetText(),"8/40"); eq(bar.value,0.2)
    exactLines(enter(env,bar,false),{"静かな手: 3/10","  静かな手: 5/10",
        "    Écriture tranquille: 0/10","  Sibling: 0/10"})
    eq(g.fields["tree:11"].last.value.paths[3].locked,true)
    exactLines(enter(env,bar,true),detail); exactLines(row.trees[1].tooltip,detail)
    bar.scripts.OnLeave(bar); eq(env.GameTooltip.shown,false); verify()
end)
case("U04 missing child projection and stale archived footers retain indentation and diagnostics",function(checkpoint)
    local ui,env,c,g=fixture(hierarchy()); local db=c.db
    local function check(expected)
        local bar=ui.widgets[1].bars[1]; local verify=unchanged({db,c.fresh,ui.rows,env.CraftArmyDiagnosticsDB})
        exactLines(enter(env,bar,false),expected); exactLines(enter(env,bar,true),bar.tree.tooltip); verify()
    end
    local base={"静かな手: 3/10","  静かな手: 5/10","    Écriture tranquille: 0/10","  Sibling: 0/10"}
    assert(C.Apply(db,character,identity,{["tree:11"]=C.Observation("error",nil,110,"fixture")},110,"fixture"))
    ui:Refresh(); base[5]="Stale data"; check(base)
    pause(checkpoint,"U04 stale hierarchy")
    assert(C.Archive(db,character.guid,2913,120,"fixture")); ui.options.archived=true; ui:Refresh()
    base[5]="Archived"; check(base)
    -- Missing child is deliberately only a projection; no malformed snapshot enters DB.
    local projection=C.Copy(g); local paths=projection.fields["tree:11"].last.value.paths
    table.remove(paths,3)
    ui.rows={V.Row(character.guid,db.characters[character.guid],2913,projection,nil,130,false)}
    local verify=unchanged({db,c.fresh,ui.rows,projection,env.CraftArmyDiagnosticsDB})
    forbidReads(env,c); ui:Render()
    check({"静かな手: 3/10","  静かな手: 5/10","    Unknown branch: ?/?","  Sibling: 0/10",
        "Branch observations unavailable."}); verify()
end)
case("U04 all64 hierarchy depths rendered without truncation or Shift mutation",function()
    local values=payloadFixtures(); local t=values["tree:11"]; local template=C.Copy(t.paths[1])
    t.paths={}; t.root=1001; t.purchased=0; t.capacity=64
    t.coverage={discovered=64,captured=64,limit=false}; values.knowledgeIndex[1].root=t.root
    for n=1,64 do
        local p=C.Copy(template); p.id=1000+n; p.purchased=0; p.capacity=1; p.name="静かな手"
        p.children=n<64 and {1001+n} or {}; t.paths[n]=p
    end
    local ui,env,c,_,s=fixture(values); local bar=ui.widgets[1].bars[1]
    local verify=unchanged({c.db,c.fresh,ui.rows,env.CraftArmyDiagnosticsDB,s})
    forbidReads(env,c); ui:Render(); local lines=enter(env,bar,false); eq(#lines,64)
    for n=1,64 do eq(lines[n],string.rep("  ",n-1).."静かな手: 0/1") end
    exactLines(enter(env,bar,true),bar.tree.tooltip); verify()
end)
case("U04 collected four tree render hover preserve native points session and complete Shift arrays",function()
    local env,s,f,c=k2Fixture(); mockWidgets(env); assert(c:Scan())
    env.CraftArmyDiagnosticsDB={sentinel={points=19}}
    local ui=NS.Dashboard.New(env,c); ui:Toggle()
    local verify=unchanged({c.db,c.fresh,ui.rows,s,f,env.CraftArmyDiagnosticsDB})
    local expected={"0/270","50/70","214/270","0/260"}
    local details={}; for n,t in ipairs(ui.rows[1].trees) do details[n]=C.Copy(t.tooltip) end
    forbidReads(env,c)
    for _=1,2 do
        ui:Render(); eq(#ui.rows[1].trees,4)
        for n,bar in ipairs(ui.widgets[1].bars) do
            if n<=4 then
                eq(bar.width,70); eq(bar.label:GetText(),expected[n]); eq(bar.tree.shortName~=nil,true)
                exactLines(enter(env,bar,false),bar.tree.summaryTooltip)
                exactLines(enter(env,bar,true),details[n]); exactLines(bar.tree.tooltip,details[n])
            else eq(bar.shown,false); eq(bar.tree,nil) end
        end
        verify()
    end
end)
end
-- U04 END

-- E01 BEGIN: additive identity/guard regressions; all non-native values below are
-- synthetic fixture data, NOT Enchanting API/gear/currency/Knowledge evidence.
do
local V,D=NS.ViewModel,NS.Data
local function same(a,b)
    eq(type(a),type(b),"E01 same value type")
    if type(a)~="table" then eq(a,b,"E01 same value"); return end
    for k,v in pairs(a) do same(v,b[k]) end
    for k in pairs(b) do assert(a[k]~=nil,"E01 no extra saved key") end
end
local function enchanting(env,s)
    -- Only 2909/333/9 and skill81/max100 are user-evidenced. The modifier, localized
    -- labels, roster, slots/items, currency59001/432/1000 and unspent7 are synthetic.
    s.info={professionID=2909,parentProfessionID=333,profession=9,isPrimaryProfession=true,
        professionName="Enchantement synthétique",expansionName="Extension synthétique",
        sourceCounter=1,skillLevel=81,maxSkillLevel=100,skillModifier=0}
    s.currencyQueries={}
    env.GetProfessions=function() return 1,2 end
    env.GetProfessionInfo=function(index)
        assert(index==1 or index==2)
        return index==1 and "Inscription" or "Enchantement synthétique",0,100,100,0,0,index==1 and 773 or 333
    end
    local t=env.C_TradeSkillUI
    t.GetBaseProfessionInfo=function() return {professionID=s.info.parentProfessionID} end
    t.GetProfessionSlots=function(profession) eq(profession,s.info.profession); return s.slots end
    t.GetConcentrationCurrencyID=function(id) eq(id,s.info.professionID); return 59001 end
    env.C_CurrencyInfo.GetCurrencyInfo=function(id)
        s.currencyQueries[id]=(s.currencyQueries[id] or 0)+1
        -- Moxie17 is synthetic, not the user's observed native balance415.
        assert(id==59001 or id==3261 or id==3258,"E01 only synthetic concentration or mapped Moxie query")
        return {quantity=id==59001 and 432 or 17,maxQuantity=id==59001 and 1000 or 0}
    end
    env.C_ProfSpecs.GetCurrencyInfoForSkillLine=function(id)
        eq(id,s.info.professionID); return {numAvailable=7}
    end
end
local function fixture()
    local env,s=fixtureAPI(); enchanting(env,s)
    return env,s,NS.Collectors.New(env,C.Open(nil))
end
local function active(c,id) return c.db.characters[character.guid].professions[id or 2909].active end
local function row(c,now,options)
    local rows=V.Build(c.db,c.fresh,options or {professionFamily=9},now or 100)
    eq(#rows,1); return rows[1]
end
local function noMoxie(r)
    eq(r.moxie,nil); eq(r.cells[I.Moxie],"?")
    for _,w in ipairs(r.warnings) do assert(w.category~="Moxie","E01 no confirmed Moxie attention") end
end

case("E01 exact Enchanting identity preserves localized labels independently of IDs",function()
    local map=D.expansions[2909]
    eq(map.parentID,333); eq(map.profession,9); eq(map.expansionID,11)
    assert(map.provenance:find("child-profession query 2026-11-10",1,true))
    local _,s=fixture(); local id=assert(D.Identity(s.info))
    eq(id.skillLineID,2909); eq(id.parentID,333); eq(id.profession,9); eq(id.expansionID,11)
    eq(id.name,"Enchantement synthétique"); eq(id.expansionName,"Extension synthétique")
    s.info.professionName="Inscription" -- Labels never select a numeric identity.
    id=assert(D.Identity(s.info)); eq(id.profession,9); eq(id.skillLineID,2909); eq(id.name,"Inscription")
    s.info.professionName="附魔"; eq(assert(D.Identity(s.info)).name,"附魔")
end)
case("E01 Inscription identity unchanged and unknown expansion identities still unmapped",function()
    local map=D.expansions[2913]
    eq(map.parentID,773); eq(map.profession,13); eq(map.expansionID,11); eq(map.provenance,"T01 user 70783")
    local _,s=fixtureAPI(); local id=assert(D.Identity(s.info))
    eq(id.skillLineID,2913); eq(id.parentID,773); eq(id.profession,13); eq(id.expansionID,11); eq(id.name,"Inscription")
    eq(D.moxie[2913].id,3261); eq(D.moxie[2909].id,3258)
    local mapped={[2913]=true,[2909]=true,[2906]=true,[2907]=true,[2910]=true,[2914]=true,[2915]=true,[2918]=true}
    local count=0; for key in pairs(D.expansions) do assert(mapped[key]); count=count+1 end
    eq(count,8)
    for family in pairs(D.families) do
        -- 60000+family is an explicitly synthetic UNMAPPED skill line, not a proposed ID.
        local value,why=D.Identity({professionID=60000+family,parentProfessionID=333,
            profession=family,professionName="Enchanting"})
        eq(value,nil); assert(why:find("mapping pending",1,true))
    end
    eq(D.Identity({professionID=333,parentProfessionID=333,profession=9}),nil,"base is not child")
end)
case("E01 conflicting Enchanting parent family base and own roster reject without writes",function(checkpoint)
    for _,change in ipairs({
        function(_,s) s.info.parentProfessionID=773 end,
        function(_,s) s.info.profession=13 end,
        function(env) env.C_TradeSkillUI.GetBaseProfessionInfo=function() return {professionID=773} end end,
        function(env) env.GetProfessions=function() return 1,nil end end,
        function(_,s) s.info.isPrimaryProfession=false end,
    }) do
        pause(checkpoint,"E01 conflicting identity variant")
        local env,s,c=fixture(); change(env,s); local verify=unchangedGraph(c.db)
        eq(c:Scan(),false); eq(next(c.db.characters),nil); eq(next(c.fresh),nil); verify()
    end
end)
case("E01 guarded synthetic Enchanting scan observes generic fields with Details unsupported",function()
    local _,s,c=fixture(); eq(c:Scan(),true)
    local g=active(c); eq(g.identity.skillLineID,2909); eq(g.identity.parentID,333); eq(g.identity.profession,9)
    eq(g.fields.skill.last.value.skillLevel,81); eq(g.fields.skill.last.value.maxSkillLevel,100)
    eq(g.fields.skill.last.value.skillModifier,0); eq(g.fields.skill.last.observedAt,100)
    eq(g.fields.concentration.last.value.id,59001); eq(g.fields.concentration.last.value.quantity,432)
    eq(g.fields.concentration.last.value.maxQuantity,1000); eq(g.fields.unspent.last.value,7)
    for role,slot in pairs({tool=20,accessory1=21,accessory2=22}) do
        local f=g.fields[role]; eq(f.attempt.status,"observed"); eq(f.last.observedAt,100)
        eq(f.last.value.slot,slot); eq(f.last.value.role,role); eq(f.last.value.exists,true)
        eq(f.last.value.itemID,90000+slot); eq(f.last.value.rarity,3); eq(f.last.value.rank,5)
    end
    eq(g.fields.tool.last.value.stats.ITEM_MOD_MULTICRAFT_SHORT,152)
    local r=row(c); eq(r.profession,"Enchantement synthétique"); eq(r.skill.skillLevel,81)
    eq(r.skillState.fresh,true); eq(r.concentration,432); eq(r.unspent,7)
    eq(s.currencyQueries[59001],1); eq(s.currencyQueries[3261],nil); eq(s.requests,0)
    local verify=unchangedGraph(c.db)
    local details=NS.Details.Model(c,{guid=character.guid,id=2909,generation=g.generation,archived=false})
    eq(details.supported,false); assert(details.status:find("read-only",1,true)); eq(#details.branches,0); verify()
end)
case("E01 synthetic missing Moxie mapping never queries mapped currencies invents zero or flags attention",function(checkpoint)
    local env,s,c=fixture()
    -- Project this isolated collector's already-guarded Context only. 60009 is an
    -- explicitly synthetic unmapped skill line; no live/global registry is changed.
    local collectorContext=c.Context
    c.Context=function(self)
        local ctx,why=collectorContext(self)
        if ctx then ctx.identity=C.Copy(ctx.identity); ctx.identity.skillLineID=60009 end
        return ctx,why
    end
    env.C_TradeSkillUI.GetConcentrationCurrencyID=function(id) eq(id,60009); return 59001 end
    env.C_ProfSpecs.GetCurrencyInfoForSkillLine=function(id) eq(id,60009); return {numAvailable=7} end
    eq(D.expansions[60009],nil); eq(D.moxie[60009],nil); eq(c:Scan(),true)
    for n=1,2 do
        local field=active(c,60009).fields.moxie
        eq(field.attempt.status,"unsupported"); eq(field.last,nil); eq(s.currencyQueries[3261],nil)
        eq(s.currencyQueries[3258],nil)
        noMoxie(row(c,s.at)); eq(#V.Build(c.db,c.fresh,{professionFamily=9,attention="Moxie"},s.at),0)
        if n==1 then pause(checkpoint,"E01 repeat unsupported Moxie scan"); s.at=110; eq(c:Scan(),true) end
    end
end)
case("E01 fully valid synthetic Inscription Knowledge relabeled Enchanting retains nil numeric totals",function(checkpoint)
    local env,s,_,c=k2Fixture(); local raw=k2Raw(c); local verify=unchangedGraph(raw)
    local valid=K.Evaluate(raw); eq(valid.complete,true); eq(valid.sharedSpent,264); eq(#valid.trees,4)
    local relabeled=C.Copy(raw); relabeled.identity={skillLineID=2909,parentID=333,profession=9,expansionID=11}
    eq(relabeled.nativeComplete,true); eq(relabeled.tabsComplete,true); eq(relabeled.stable,true)
    eq(relabeled.stagedStart,false); eq(relabeled.stagedEnd,false)
    local rejected=K.Evaluate(relabeled); eq(rejected.complete,false); eq(rejected.sharedSpent,nil); eq(#rejected.trees,4)
    for _,tree in ipairs(rejected.trees) do eq(tree.complete,false); eq(tree.purchased,nil); eq(tree.capacity,nil) end
    verify()
    pause(checkpoint,"E01 Enchanting scan with valid relabeled synthetic Knowledge")
    enchanting(env,s); eq(c:Scan(),true)
    local g=active(c); eq(g.fields.knowledgeRaw.attempt.status,"unknown")
    eq(g.fields.knowledgeRaw.last,nil)
    assert(g.fields.knowledgeRaw.attempt.reason:find("wrong profession spend currency",1,true))
    eq(#g.fields.knowledgeIndex.last.value,4)
    for _,tree in ipairs(g.fields.knowledgeIndex.last.value) do
        eq(g.fields["tree:"..tree.id].attempt.status,"unknown"); eq(g.fields["tree:"..tree.id].last,nil)
    end
    local r=row(c); eq(#r.trees,4)
    for _,tree in ipairs(r.trees) do eq(tree.purchased,nil); eq(tree.capacity,nil); eq(tree.aggregateText,"?/?") end
end)
case("E01 same character Inscription and Enchanting coexist and filter without changing Inscription",function(checkpoint)
    local env,s=fixtureAPI(); local c=NS.Collectors.New(env,C.Open(nil)); eq(c:Scan(),true)
    local before=C.Copy(active(c,2913)); local original=active(c,2913); local verify=unchangedGraph(original)
    pause(checkpoint,"E01 switch isolated fixture to Enchanting")
    enchanting(env,s); s.at=110; eq(c:Scan(),true)
    same(active(c,2913),before); verify(); eq(active(c).scannedAt,110)
    eq(active(c,2913).fields.moxie.last.value.id,3261); eq(active(c,2913).fields.moxie.last.observedAt,100)
    local rows=V.Build(c.db,c.fresh,{},110); eq(#rows,2); eq(rows[1].guid,rows[2].guid)
    assert(rows[1].id~=rows[2].id); eq(row(c,110,{professionFamily=13}).id,2913)
    eq(row(c,110,{professionFamily=9}).id,2909); eq(row(c,110,{profession="2909"}).id,2909)
    eq(row(c,110,{profession="Enchantement"}).id,2909); eq(row(c,110,{profession="Inscription"}).id,2913)
    eq(#V.Build(c.db,c.fresh,{professionFamily=3},110),0); same(active(c,2913),before)
end)
case("E01 closed combat linked guild NPC changing and unready contexts preserve Enchanting snapshot",function(checkpoint)
    local _,s,c=fixture(); eq(c:Scan(),true); local before=C.Copy(active(c))
    for _,variant in ipairs({{"shown",false},{"combat",true},{"linked",true},{"guild",true},
        {"npc",true},{"changing",true},{"ready",false}}) do
        pause(checkpoint,"E01 unsafe context variant")
        local key,value=unpack(variant); local old=s[key]; s[key]=value; s.at=110
        c:Invalidate("E01 synthetic context lost"); local verify=unchangedGraph(c.db)
        eq(c:Scan(),false); verify(); same(active(c),before); eq(next(c.fresh),nil)
        local r=row(c,110); eq(r.skill.skillLevel,81); eq(r.concentration,432); eq(r.unspent,7)
        eq(r.skillState.fresh,false); eq(r.gear.tool.state.fresh,false); eq(r.lastUpdated,"10s")
        s[key]=old
    end
end)
case("E01 failed Enchanting field reads retain old observed values and independent times",function(checkpoint)
    local env,s,c=fixture(); eq(c:Scan(),true); local before=C.Copy(active(c))
    pause(checkpoint,"E01 failed synthetic field reads")
    s.at=110; s.info.skillModifier=nil
    env.C_CurrencyInfo.GetCurrencyInfo=function() error("E01 synthetic currency failure") end
    env.C_ProfSpecs.GetCurrencyInfoForSkillLine=function() return nil end
    env.C_Item.GetItemStats=function() error("E01 synthetic stats failure") end
    eq(c:Scan(),true); local g=active(c); eq(g.scannedAt,110)
    for key,status in pairs({skill="unknown",concentration="error",unspent="unknown",tool="error"}) do
        same(g.fields[key].last,before.fields[key].last)
        eq(g.fields[key].last.observedAt,100); eq(g.fields[key].attempt.attemptedAt,110)
        eq(g.fields[key].attempt.status,status)
    end
    eq(g.fields.moxie.last.value.id,3258); eq(g.fields.moxie.last.value.quantity,17)
    same(g.fields.moxie.last,before.fields.moxie.last)
    eq(g.fields.moxie.last.observedAt,100); eq(g.fields.moxie.attempt.attemptedAt,110)
    eq(g.fields.moxie.attempt.status,"error")
    local r=row(c,110); eq(r.skill.skillLevel,81); eq(r.concentration,432); eq(r.unspent,7)
    eq(r.skillState.fresh,false); eq(r.skillState.stale,true)
    eq(r.gear.tool.state.fresh,false); eq(r.gear.tool.state.observedAt,100)
    eq(r.moxie,17); eq(r.cells[I.Moxie],"17")
    for _,w in ipairs(r.warnings) do assert(w.category~="Moxie","E01 no Moxie attention at17") end
    local _,ms=V.Field(g,"moxie",c.fresh[character.guid..":2909"])
    eq(ms.fresh,false); eq(ms.stale,true); eq(ms.observedAt,100)
    eq(C.Open(c.db),c.db)
end)
case("E01 reopened saved Enchanting DB renders last observations without session freshness or collection",function(checkpoint)
    local env,s,c=fixture(); eq(c:Scan(),true)
    pause(checkpoint,"E01 reopen synthetic saved DB")
    local saved=C.Copy(c.db); local reopened=assert(C.Open(saved)); s.shown=false; s.at=130
    local fresh=NS.Collectors.New(env,reopened); eq(next(fresh.fresh),nil)
    local function forbidden() error("E01 saved rendering must not collect") end
    for _,api in ipairs({env.C_TradeSkillUI,env.C_ProfSpecs,env.C_Traits,env.C_Item,env.C_CurrencyInfo}) do
        for key,value in pairs(api) do if type(value)=="function" then api[key]=forbidden end end
    end
    fresh.Scan=forbidden; fresh.Context=forbidden; fresh.Knowledge=forbidden; fresh.Gear=forbidden
    local verify=unchangedGraph({saved,fresh.fresh})
    mockWidgets(env); local ui=NS.Dashboard.New(env,fresh); ui:Toggle(); eq(#ui.rows,1)
    local r=ui.rows[1]; eq(r.id,2909); eq(r.profession,"Enchantement synthétique")
    eq(r.skill.skillLevel,81); eq(r.skill.maxSkillLevel,100); eq(r.concentration,432); eq(r.unspent,7)
    eq(r.skillState.fresh,false); eq(r.gear.tool.state.fresh,false); eq(r.gear.tool.state.observedAt,100)
    eq(r.gear.tool.value.stats.ITEM_MOD_MULTICRAFT_SHORT,152); eq(r.lastUpdated,"30s")
    assert(r.snapshot:find("snapshot",1,true)); eq(r.moxie,17); eq(r.cells[I.Moxie],"17")
    for _,w in ipairs(r.warnings) do assert(w.category~="Moxie","E01 no Moxie attention at17") end
    local _,state=V.Field(active(fresh),"moxie",fresh.fresh[character.guid..":2909"])
    eq(state.fresh,false); eq(state.observedAt,100)
    ui:Refresh(); ui:Render(); eq(next(fresh.fresh),nil); verify(); same(saved,c.db)
end)
case("E01 Core rejects out of scope native raw payload and active archived generations without mutation",function(checkpoint)
    local _,_,_,inscription=k2Fixture(); local raw=k2Raw(inscription)
    eq(C.ValidPayload("knowledgeRaw",raw,"observed"),true)
    local relabeled=C.Copy(raw); relabeled.identity={skillLineID=2909,parentID=333,profession=9,expansionID=11}
    eq(C.ValidPayload("knowledgeRaw",relabeled,"observed"),false)
    local _,_,c=fixture(); local identity=assert(c:Context()).identity
    pause(checkpoint,"E01 direct Core payload rejection")
    local observations={knowledgeRaw=C.Observation("observed",relabeled,100,"E01 synthetic raw")}
    local verify=unchangedGraph({c.db,identity,observations})
    local applied,why=C.Apply(c.db,character,identity,observations,100,"E01 synthetic build")
    eq(applied,nil); eq(why,"Invalid production field payload: knowledgeRaw"); verify()
    pause(checkpoint,"E01 direct Core candidate scope rejection")
    -- Even valid Inscription raw cannot be placed in an Enchanting generation.
    observations={knowledgeRaw=C.Observation("observed",raw,100,"E01 synthetic raw")}
    verify=unchangedGraph({c.db,identity,observations})
    applied,why=C.Apply(c.db,character,identity,observations,100,"E01 synthetic build")
    eq(applied,nil); eq(why,"Invalid candidate generation/scope"); verify()
    pause(checkpoint,"E01 seed Enchanting generation for saved scope rejection")
    eq(c:Scan(),true)
    for _,archived in ipairs({false,true}) do
        pause(checkpoint,"E01 saved active or archived scope rejection")
        local saved=C.Copy(c.db); local generation=saved.characters[character.guid].professions[2909].active
        generation.fields.knowledgeRaw=C.Merge(nil,C.Observation("observed",raw,100,"E01 synthetic raw"),
            "E01 synthetic build",generation.generation)
        if archived then
            local p=saved.characters[character.guid].professions[2909]
            generation.archivedAt=110; generation.archiveReason="E01 synthetic archive"
            p.active=nil; p.archives[1]=generation
        end
        local unchanged=unchangedGraph(saved)
        local opened,reason=C.Open(saved); eq(opened,nil)
        eq(reason,archived and "Invalid archive; writes disabled." or "Invalid active generation; writes disabled.")
        unchanged()
    end
end)
end
-- E01 END

-- E02 BEGIN: supplied catalogue/mapping regressions. All balances, concentration
-- IDs and failure scenarios here are synthetic, NOT target-client API evidence.
do
local D,V=NS.Data,NS.ViewModel
local function selectProfession(s,id)
    local enchanting=id==2909
    s.info={professionID=id,parentProfessionID=enchanting and 333 or 773,
        profession=enchanting and 9 or 13,isPrimaryProfession=true,
        professionName=enchanting and "附魔 synthétique" or "Inscription synthétique",
        expansionName="Synthetic expansion",sourceCounter=1,
        skillLevel=81,maxSkillLevel=100,skillModifier=0}
end
local function fixture()
    local env,s=fixtureAPI(); selectProfession(s,2909)
    s.balances={[3258]=17,[3261]=83}; s.queries={}; s.failure=nil
    env.GetProfessions=function() return 1,2 end
    env.GetProfessionInfo=function(index)
        assert(index==1 or index==2); return "Synthetic primary",0,100,100,0,0,index==1 and 773 or 333
    end
    env.C_TradeSkillUI.GetBaseProfessionInfo=function() return {professionID=s.info.parentProfessionID} end
    env.C_TradeSkillUI.GetProfessionSlots=function(id) eq(id,s.info.profession); return s.slots end
    env.C_TradeSkillUI.GetConcentrationCurrencyID=function(id)
        eq(id,s.info.professionID); return id==2909 and 59001 or 50001
    end
    env.C_CurrencyInfo.GetCurrencyInfo=function(id)
        -- A query to ANY dormant catalogue ID (or any unexpected currency) fails.
        assert(id==3258 or id==3261 or id==59001 or id==50001,"E02 no dormant currency queries")
        s.queries[id]=(s.queries[id] or 0)+1
        if id==3258 or id==3261 then
            eq(id,s.info.professionID==2909 and 3258 or 3261,"E02 profession-specific Moxie")
            if s.failure then return s.failure() end
            return {quantity=s.balances[id]}
        end
        return {quantity=432,maxQuantity=1000}
    end
    env.C_ProfSpecs.GetCurrencyInfoForSkillLine=function(id) eq(id,s.info.professionID); return {numAvailable=7} end
    return env,s,NS.Collectors.New(env,C.Open(nil))
end
local function active(c,id) return c.db.characters[character.guid].professions[id or 2909].active end
local function row(c,now,id)
    local rows=V.Build(c.db,c.fresh,{profession=tostring(id or 2909)},now or 100)
    eq(#rows,1); return rows[1]
end
local function state(c,id)
    id=id or 2909
    return V.Field(active(c,id),"moxie",c.fresh[character.guid..":"..id])
end
local function attention(r,expected,fresh)
    local n=0
    for _,w in ipairs(r.warnings) do
        if w.category=="Moxie" then
            n=n+1; eq(w.fresh,fresh)
            assert(w.label:find(fresh and "confirmed " or "last observed ",1,true))
        end
    end
    eq(n,expected and 1 or 0)
end
local failures={
    {name="nil",status="unknown",read=function() return nil end},
    {name="error",status="error",read=function() error("E02 synthetic failure") end},
    {name="missing quantity",status="unknown",read=function() return {} end},
    {name="negative",status="unknown",read=function() return {quantity=-1} end},
    {name="fraction",status="unknown",read=function() return {quantity=1.5} end},
    {name="string",status="unknown",read=function() return {quantity="601"} end},
    {name="NaN",status="unknown",read=function() return {quantity=0/0} end},
    {name="infinite",status="unknown",read=function() return {quantity=math.huge} end},
}
case("E02 exact eleven-entry catalogue provenance unique IDs and unchanged active scope",function()
    local expected={Alchemy=3256,Blacksmithing=3257,Enchanting=3258,Engineering=3259,
        Herbalism=3260,Inscription=3261,Jewelcrafting=3262,Leatherworking=3263,
        Mining=3264,Skinning=3265,Tailoring=3266}
    local count,seen=0,{}
    for name,entry in pairs(D.moxieCatalog) do
        count=count+1; eq(entry.id,expected[name]); eq(seen[entry.id],nil); seen[entry.id]=true
        local keys=0; for key in pairs(entry) do assert(key=="id" or key=="provenance"); keys=keys+1 end; eq(keys,2)
        local provenance=name=="Inscription" and "T01 user currency query; 70783" or
            (name=="Enchanting" and "User native currency query/UI agreement 2026-11-10" or
            "User-supplied list 2026-11-10; not native-verified")
        eq(entry.provenance,provenance)
    end
    eq(count,11); for name,id in pairs(expected) do eq(D.moxieCatalog[name].id,id) end
    count=0
    local active={[2913]="Inscription",[2909]="Enchanting",[2906]="Alchemy",[2907]="Blacksmithing",
        [2910]="Engineering",[2914]="Jewelcrafting",[2915]="Leatherworking",[2918]="Tailoring"}
    for id,entry in pairs(D.moxie) do
        assert(active[id]); count=count+1
        eq(entry,D.moxieCatalog[active[id]])
    end
    eq(count,8)
    local identities={[2913]={773,13,"T01 user 70783"},[2909]={333,9,"E01 user child-profession query 2026-11-10"},
        [2906]={171,3},[2907]={164,1},[2910]={202,8},[2914]={755,12},[2915]={165,2},[2918]={197,7}}
    count=0; for id,map in pairs(D.expansions) do
        assert(identities[id]); count=count+1; eq(map.expansionID,11)
        eq(map.parentID,identities[id][1]); eq(map.profession,identities[id][2])
        eq(map.provenance,identities[id][3] or "E03 user batch child-profession query 2026-11-10")
    end; eq(count,8)
    local families={[1]="Blacksmithing",[2]="Leatherworking",[3]="Alchemy",[7]="Tailoring",
        [8]="Engineering",[9]="Enchanting",[12]="Jewelcrafting",[13]="Inscription"}
    count=0; for id,name in pairs(D.families) do eq(name,families[id]); count=count+1 end; eq(count,8)
    for _,family in ipairs({4,5,6}) do eq(D.families[family],nil) end
end)
case("E02 injected Enchanting collector uses3258 dynamic balances zero and strict greater than600",function(checkpoint)
    local _,s,c=fixture()
    for n,balance in ipairs({17,0,600,601,29}) do
        pause(checkpoint,"E02 dynamic balance scan")
        s.at=100+n; s.balances[3258]=balance; eq(c:Scan(),true)
        local g=active(c); local f=g.fields.moxie
        eq(f.attempt.status,"observed"); eq(f.last.value.id,3258); eq(f.last.value.quantity,balance)
        eq(f.last.observedAt,s.at); eq(f.attempt.attemptedAt,s.at)
        local value,ms=state(c); eq(value.quantity,balance); eq(ms.fresh,true); eq(ms.stale,false)
        local r=row(c,s.at); eq(r.moxie,balance)
        -- U13 ADAPT E02_THRESHOLD BEGIN
--[==========[U13 ORIGINAL BEGIN
        eq(r.cells[I.Moxie],(balance>600 and "|cffffbb00!|r " or "")..tostring(balance))
U13 ORIGINAL END]==========]
        eq(r.cells[I.Moxie],tostring(balance))
        -- U13 ADAPT E02_THRESHOLD END
        attention(r,balance>600,true)
        eq(#V.Build(c.db,c.fresh,{profession="2909",attention="Moxie"},s.at),balance>600 and 1 or 0)
        eq(s.queries[3258],n); eq(s.queries[3261],nil); eq(s.queries[59001],n)
    end
end)
case("E02 nil error invalid Moxie retries preserve last601 and observation time without fresh attention",function(checkpoint)
    local _,s,c=fixture(); s.balances[3258]=601; eq(c:Scan(),true)
    local before=C.Copy(active(c).fields.moxie.last)
    for n,failure in ipairs(failures) do
        pause(checkpoint,"E02 retained failure "..failure.name)
        s.at=110+n; s.failure=failure.read; eq(c:Scan(),true)
        local f=active(c).fields.moxie
        eq(f.attempt.status,failure.status); eq(f.attempt.attemptedAt,s.at)
        eq(f.last.value.id,3258); eq(f.last.value.quantity,601); eq(f.last.observedAt,before.observedAt)
        local _,ms=state(c); eq(ms.known,true); eq(ms.fresh,false); eq(ms.stale,true)
        -- U13 ADAPT E02_RETRY BEGIN
--[==========[U13 ORIGINAL BEGIN
        local r=row(c,s.at); eq(r.moxie,601); eq(r.cells[I.Moxie],"|cff999999!|r 601"); attention(r,true,false)
U13 ORIGINAL END]==========]
        local r=row(c,s.at); eq(r.moxie,601); eq(r.cells[I.Moxie],"601"); attention(r,true,false)
        -- U13 ADAPT E02_RETRY END
        eq(s.queries[3261],nil); eq(C.Open(c.db),c.db)
    end
    pause(checkpoint,"E02 recover dynamic observed balance")
    s.failure=nil; s.at=130; s.balances[3258]=42; eq(c:Scan(),true)
    local value,ms=state(c); eq(value.quantity,42); eq(ms.observedAt,130); eq(ms.fresh,true)
    attention(row(c,130),false,true)
end)
case("E02 first failed Moxie reads remain unknown not zero and never confirmed attention",function(checkpoint)
    for _,failure in ipairs(failures) do
        pause(checkpoint,"E02 first failure "..failure.name)
        local _,s,c=fixture(); s.failure=failure.read; eq(c:Scan(),true)
        local f=active(c).fields.moxie; eq(f.last,nil); eq(f.attempt.status,failure.status)
        local value,ms=state(c); eq(value,nil); eq(ms.known,false); eq(ms.fresh,false); eq(ms.observedAt,nil)
        local r=row(c); eq(r.moxie,nil); eq(r.cells[I.Moxie],"?"); attention(r,false,false)
        eq(#V.Build(c.db,c.fresh,{profession="2909",attention="Moxie"},100),0)
        eq(s.queries[3258],1); eq(s.queries[3261],nil)
    end
end)
case("E02 Inscription3261 and Enchanting3258 coexist and isolate dynamic observations",function(checkpoint)
    local _,s,c=fixture(); selectProfession(s,2913); eq(c:Scan(),true)
    local inscription=active(c,2913); local verify=unchangedGraph(inscription)
    local value,ms=state(c,2913); eq(value.id,3261); eq(value.quantity,83); eq(ms.observedAt,100)
    pause(checkpoint,"E02 switch to Enchanting")
    selectProfession(s,2909); s.at=110; s.balances[3258]=601; eq(c:Scan(),true); verify()
    eq(row(c,110,2913).moxie,83); eq(row(c,110).moxie,601)
    eq(active(c,2913).fields.moxie.last.observedAt,100)
    local enchanting=active(c); local verifyEnchanting=unchangedGraph(enchanting)
    pause(checkpoint,"E02 return to Inscription")
    selectProfession(s,2913); s.at=120; s.balances[3261]=0; eq(c:Scan(),true); verifyEnchanting()
    eq(row(c,120,2913).moxie,0); eq(row(c,120).moxie,601)
    eq(active(c).fields.moxie.last.observedAt,110)
    eq(s.queries[3261],2); eq(s.queries[3258],1); eq(s.queries[50001],2); eq(s.queries[59001],1)
    eq(#V.Build(c.db,c.fresh,{},120),2)
end)
case("E02 closed context high Moxie remains last observed never fresh confirmed attention",function(checkpoint)
    local _,s,c=fixture(); s.balances[3258]=601; eq(c:Scan(),true)
    pause(checkpoint,"E02 close native fixture context")
    s.shown=false; s.at=120; c:Invalidate("E02 synthetic closure")
    local verify=unchangedGraph(c.db); eq(c:Scan(),false); verify()
    local value,ms=state(c); eq(value.quantity,601); eq(ms.fresh,false); eq(ms.observedAt,100)
    local r=row(c,120); eq(r.moxie,601); attention(r,true,false)
    eq(s.queries[3258],1); eq(s.queries[3261],nil)
end)
case("E02 reload and offline dashboard render never query dormant or active currencies",function(checkpoint)
    local env,s,c=fixture(); s.balances[3258]=601; eq(c:Scan(),true)
    pause(checkpoint,"E02 reopen saved DB without native reads")
    local saved=C.Copy(c.db); s.shown=false; s.at=140
    local function forbidden() error("E02 reload/render must not collect") end
    for _,api in ipairs({env.C_TradeSkillUI,env.C_ProfSpecs,env.C_Traits,env.C_Item,env.C_CurrencyInfo}) do
        for key,value in pairs(api) do if type(value)=="function" then api[key]=forbidden end end
    end
    local reopened=assert(C.Open(saved)); local fresh=NS.Collectors.New(env,reopened)
    fresh.Scan=forbidden; fresh.Context=forbidden; fresh.Knowledge=forbidden; fresh.Gear=forbidden
    local verify=unchangedGraph({saved,fresh.fresh,s.queries})
    -- U13 ADAPT E02_CLOSED BEGIN
--[==========[U13 ORIGINAL BEGIN
    local r=row(fresh,140); eq(r.moxie,601); eq(r.cells[I.Moxie],"|cff999999!|r 601"); attention(r,true,false)
U13 ORIGINAL END]==========]
    local r=row(fresh,140); eq(r.moxie,601); eq(r.cells[I.Moxie],"601"); attention(r,true,false)
    -- U13 ADAPT E02_CLOSED END
    local value,ms=state(fresh); eq(value.id,3258); eq(ms.fresh,false); eq(ms.observedAt,100)
    mockWidgets(env); local ui=NS.Dashboard.New(env,fresh); ui:Toggle(); eq(#ui.rows,1)
    eq(ui.rows[1].moxie,601); attention(ui.rows[1],true,false)
    ui:Refresh(); ui:Render(); eq(next(fresh.fresh),nil); verify()
    eq(s.queries[3258],1); eq(s.queries[3261],nil)
end)
end
-- E02 END

-- E03 BEGIN: six user-evidenced identity tuples and supplied Moxie IDs only.
-- ALL other data here (GUIDs, labels, skill/gear, balances, concentration/config/tab/
-- path IDs and failure scenarios) is synthetic, NOT native field/API evidence.
do
local D,V=NS.Data,NS.ViewModel
local specs={
    {"Alchemy",2906,171,3,3256}, {"Blacksmithing",2907,164,1,3257},
    {"Engineering",2910,202,8,3259}, {"Jewelcrafting",2914,755,12,3262},
    {"Leatherworking",2915,165,2,3263}, {"Tailoring",2918,197,7,3266},
}
local verifyRegistry=unchangedGraph(D)
local function configure(env,s,spec,n)
    s.guid="Player-E03-synthetic-"..spec[4]; s.label="合成 métier "..n
    s.info={professionID=spec[2],parentProfessionID=spec[3],profession=spec[4],
        isPrimaryProfession=true,professionName=s.label,expansionName="Synthetic E03",
        sourceCounter=1,skillLevel=20+n,maxSkillLevel=100,skillModifier=n}
    s.concentrationID=65000+n; s.balance=41*n+11; s.concentration=210+n; s.unspent=3+n
    s.queries={}; s.config=68000+n; s.tab=69000+n; s.path=70000+n
    env.UnitGUID=function(unit) eq(unit,"player"); return s.guid end
    env.UnitName=function(unit) eq(unit,"player"); return "Synthetic E03 "..n end
    env.GetProfessions=function() return 1,nil end -- One primary per synthetic GUID.
    env.GetProfessionInfo=function(index) eq(index,1); return s.label,0,100,100,0,0,spec[3] end
    local t,p=env.C_TradeSkillUI,env.C_ProfSpecs
    t.GetBaseProfessionInfo=function() return {professionID=s.info.parentProfessionID} end
    t.GetProfessionSlots=function(id) eq(id,spec[4]); return s.slots end
    t.GetConcentrationCurrencyID=function(id) eq(id,spec[2]); return s.concentrationID end
    env.C_CurrencyInfo.GetCurrencyInfo=function(id)
        assert(id==s.concentrationID or id==spec[5],"E03 only this profession's currencies")
        s.queries[id]=(s.queries[id] or 0)+1
        if s.failure then return s.failure() end
        if id==spec[5] then return {quantity=s.balance} end
        return {quantity=s.concentration,maxQuantity=1000}
    end
    p.GetCurrencyInfoForSkillLine=function(id) eq(id,spec[2]); return {numAvailable=s.unspent} end
    p.GetConfigIDForSkillLine=function(id) eq(id,spec[2]); return s.config end
    env.C_Item.GetItemID=function(loc) return 91000+n*100+loc.slot end
    env.C_Item.GetItemLink=function(loc) return "item:"..(91000+n*100+loc.slot)..":0:0:0" end
end
local function fixture(spec,n,db)
    local env,s=fixtureAPI(); configure(env,s,spec,n)
    -- Dynamic synthetic IDs, deliberately not the observed native configs/tabs.
    local p=env.C_ProfSpecs
    p.GetSpecTabIDsForSkillLine=function(id) eq(id,spec[2]); return {s.tab} end
    p.GetTabInfo=function(id) eq(id,s.tab); return {name="Synthetic E03 tree "..n} end
    p.GetRootPathForTab=function(id) eq(id,s.tab); return s.path end
    return env,s,NS.Collectors.New(env,db or C.Open(nil))
end
local function active(c,s,spec) return c.db.characters[s.guid].professions[spec[2]].active end
local function row(c,s,spec,at)
    local rows=V.Build(c.db,c.fresh,{professionFamily=spec[4]},at or s.at)
    eq(#rows,1); eq(rows[1].guid,s.guid); eq(rows[1].id,spec[2]); return rows[1]
end
local function unknownKnowledge(c,s,spec,trees)
    local g=active(c,s,spec); local f=g.fields.knowledgeRaw
    eq(f.attempt.value,nil)
    if trees==1 then
        eq(f.attempt.status,"observed"); eq(C.ValidPayload("knowledgeRaw",f.last.value,"observed"),true)
        local raw=f.last.value; eq(raw.nativeComplete,false)
        eq(raw.identity.skillLineID,spec[2]); eq(raw.identity.parentID,spec[3])
        eq(raw.identity.profession,spec[4]); eq(raw.identity.expansionID,11)
        for _,tab in ipairs(raw.tabs) do for _,path in pairs(tab.paths) do eq(path.spendCurrencyID,nil) end end
    else
        eq(f.attempt.status,"unknown"); eq(f.last,nil)
        assert(f.attempt.reason:find("wrong profession spend currency",1,true))
    end
    eq(#g.fields.knowledgeIndex.last.value,trees)
    for _,tree in ipairs(g.fields.knowledgeIndex.last.value) do
        local field=g.fields["tree:"..tree.id]; eq(field.attempt.status,"unknown"); eq(field.last,nil)
    end
    local r=row(c,s,spec); eq(#r.trees,trees)
    for _,tree in ipairs(r.trees) do eq(tree.purchased,nil); eq(tree.capacity,nil); eq(tree.aggregateText,"?/?") end
    local verify=unchangedGraph({c.db,c.fresh,s.queries})
    local details=NS.Details.Model(c,{guid=s.guid,id=spec[2],generation=g.generation,archived=false})
    eq(details.supported,false); assert(details.status:find("read-only",1,true)); eq(#details.branches,0)
    verify()
end
local function noFreshMoxie(r)
    for _,w in ipairs(r.warnings) do if w.category=="Moxie" then eq(w.fresh,false) end end
end

case("E03 exact six tuples and localized labels never select identities or currency mappings",function()
    for n,spec in ipairs(specs) do
        local map=D.expansions[spec[2]]
        eq(map.parentID,spec[3]); eq(map.profession,spec[4]); eq(map.expansionID,11)
        eq(map.provenance,"E03 user batch child-profession query 2026-11-10")
        eq(D.moxie[spec[2]],D.moxieCatalog[spec[1]]); eq(D.moxie[spec[2]].id,spec[5])
        eq(D.moxie[spec[2]].provenance,"User-supplied list 2026-11-10; not native-verified")
        local _,s=fixture(spec,n); local id=assert(D.Identity(s.info))
        eq(id.skillLineID,spec[2]); eq(id.parentID,spec[3]); eq(id.profession,spec[4]); eq(id.expansionID,11)
        eq(id.name,s.label); eq(id.expansionName,"Synthetic E03")
        s.info.professionName="Inscription"; id=assert(D.Identity(s.info)); eq(id.skillLineID,spec[2]); eq(id.name,"Inscription")
    end
    verifyRegistry()
end)
case("E03 all six conflicting parent family own roster unknown and gathering identities fail closed",function(checkpoint)
    for n,spec in ipairs(specs) do
        for _,change in ipairs({
            function(_,s) s.info.parentProfessionID=99999 end,
            function(_,s) s.info.profession=13 end,
            function(env) env.C_TradeSkillUI.GetBaseProfessionInfo=function() return {professionID=773} end end,
            function(env) env.GetProfessions=function() return nil,nil end end,
            function(_,s) s.info.professionID=60000+spec[4] end,
            function(_,s) s.info.profession=4 end,
        }) do
            pause(checkpoint,"E03 rejected identity variant "..spec[1])
            local env,s,c=fixture(spec,n); change(env,s); eq(D.Identity(s.info)==nil,
                s.info.parentProfessionID==99999 or s.info.profession~=spec[4] or s.info.professionID~=spec[2])
            local verify=unchangedGraph(c.db); eq(c:Scan(),false); eq(next(c.fresh),nil); verify()
        end
    end
    for _,family in ipairs({4,5,6}) do
        eq(D.Identity({professionID=60000+family,parentProfessionID=171,profession=family}),nil)
        eq(D.families[family],nil)
    end
    eq(D.expansions[60009],nil); eq(D.moxie[60009],nil); verifyRegistry()
end)
for index,value in ipairs(specs) do
    local n,spec=index,value -- Stable closures for each separately reported family.
    case("E03 injected "..spec[1].." scan saves own generic fields Moxie and unsupported Knowledge Details",function(checkpoint)
        local _,s,c=fixture(spec,n); eq(c:Scan(),true)
        local g=active(c,s,spec)
        eq(g.identity.skillLineID,spec[2]); eq(g.identity.parentID,spec[3]); eq(g.identity.profession,spec[4])
        eq(g.scannedAt,100); eq(g.fields.skill.last.value.skillLevel,20+n)
        eq(g.fields.skill.last.value.maxSkillLevel,100); eq(g.fields.skill.last.value.skillModifier,n)
        eq(g.fields.concentration.last.value.id,65000+n); eq(g.fields.concentration.last.value.quantity,210+n)
        eq(g.fields.concentration.last.value.maxQuantity,1000); eq(g.fields.unspent.last.value,3+n)
        for role,slot in pairs({tool=20,accessory1=21,accessory2=22}) do
            local f=g.fields[role]; eq(f.attempt.status,"observed"); eq(f.last.observedAt,100)
            eq(f.last.value.role,role); eq(f.last.value.slot,slot); eq(f.last.value.exists,true)
            eq(f.last.value.itemID,91000+n*100+slot); eq(f.last.value.rarity,3); eq(f.last.value.rank,5)
        end
        eq(g.fields.tool.last.value.stats.ITEM_MOD_MULTICRAFT_SHORT,152)
        local f=g.fields.moxie; eq(f.attempt.status,"observed"); eq(f.last.value.id,spec[5])
        eq(f.last.value.quantity,41*n+11); eq(f.last.observedAt,100)
        local r=row(c,s,spec); eq(r.profession,s.label); eq(r.skill.skillLevel,20+n); eq(r.skillState.fresh,true)
        eq(r.concentration,210+n); eq(r.unspent,3+n); eq(r.moxie,41*n+11)
        eq(r.cells[I.Moxie],tostring(41*n+11)); eq(s.queries[spec[5]],1); eq(s.queries[65000+n],1)
        eq(s.queries[3261],nil); eq(s.queries[3258],nil); eq(s.requests,0)
        eq(g.fields.knowledgeIndex.last.value[1].id,69000+n); unknownKnowledge(c,s,spec,1)
        pause(checkpoint,"E03 dynamic second balance "..spec[1])
        s.at=110; s.balance=41*n+13; eq(c:Scan(),true)
        eq(active(c,s,spec).fields.moxie.last.value.quantity,41*n+13)
        eq(active(c,s,spec).fields.moxie.last.observedAt,110); eq(s.queries[spec[5]],2)
        verifyRegistry()
    end)
end
case("E03 fully eligible Inscription graph relabeled to every new identity fails policy and Core raw scope",function(checkpoint)
    for n,spec in ipairs(specs) do
        pause(checkpoint,"E03 eligible Inscription control "..spec[1])
        local env,s,_,c=k2Fixture(); local raw=k2Raw(c)
        local valid=K.Evaluate(raw); eq(valid.complete,true); eq(valid.sharedSpent,264); eq(#valid.trees,4)
        eq(C.ValidPayload("knowledgeRaw",raw,"observed"),true)
        local verifyRaw=unchangedGraph(raw); local relabeled=C.Copy(raw)
        relabeled.identity={skillLineID=spec[2],parentID=spec[3],profession=spec[4],expansionID=11}
        eq(relabeled.nativeComplete,true); eq(relabeled.tabsComplete,true); eq(relabeled.stable,true)
        eq(relabeled.stagedStart,false); eq(relabeled.stagedEnd,false)
        k2Fail(relabeled,"E03 no numeric policy leak "..spec[1]); eq(#K.Evaluate(relabeled).trees,4)
        eq(C.ValidPayload("knowledgeRaw",relabeled,"observed"),false); verifyRaw()
        configure(env,s,spec,n)
        local id=assert(c:Context()).identity; local who={guid=s.guid,name="Synthetic",realm="Test"}
        for _,attempt in ipairs({{relabeled,"Invalid production field payload: knowledgeRaw"},
            {raw,"Invalid candidate generation/scope"}}) do
            pause(checkpoint,"E03 direct Core rejecting scope "..spec[1])
            local obs={knowledgeRaw=C.Observation("observed",attempt[1],100,"E03 synthetic raw")}
            local verify=unchangedGraph({c.db,who,id,obs})
            local applied,why=C.Apply(c.db,who,id,obs,100,"E03 synthetic")
            eq(applied,nil); eq(why,attempt[2]); verify()
        end
        pause(checkpoint,"E03 scan relabeled eligible graph "..spec[1])
        eq(c:Scan(),true); unknownKnowledge(c,s,spec,4)
        for _,archived in ipairs({false,true}) do
            pause(checkpoint,"E03 saved Core scope rejecting "..spec[1])
            local saved=C.Copy(c.db); local p=saved.characters[s.guid].professions[spec[2]]; local g=p.active
            g.fields.knowledgeRaw=C.Merge(nil,C.Observation("observed",raw,100,"E03 synthetic raw"),"E03 synthetic",g.generation)
            if archived then g.archivedAt=110; g.archiveReason="E03 synthetic"; p.active=nil; p.archives[1]=g end
            local verify=unchangedGraph(saved); local opened,why=C.Open(saved)
            eq(opened,nil); eq(why,archived and "Invalid archive; writes disabled." or "Invalid active generation; writes disabled.")
            verify()
        end
        verifyRegistry()
    end
end)
case("E03 distinct characters isolate six families and leave saved Inscription Enchanting untouched",function(checkpoint)
    local db=C.Open(nil); local controls={
        {"Inscription",2913,773,13,3261},{"Enchanting",2909,333,9,3258},
    }
    for n,spec in ipairs(controls) do
        pause(checkpoint,"E03 seed existing identity "..spec[1])
        local _,_,c=fixture(spec,n+10,db); eq(c:Scan(),true)
    end
    local oldInscription=db.characters["Player-E03-synthetic-13"]
    local oldEnchanting=db.characters["Player-E03-synthetic-9"]
    local verifyControls=unchangedGraph({oldInscription,oldEnchanting}); local last
    for n,spec in ipairs(specs) do
        pause(checkpoint,"E03 isolated character scan "..spec[1])
        local prior={}; for guid,value in pairs(db.characters) do prior[guid]=value end
        local verifyPrior=unchangedGraph(prior)
        local _,s,c=fixture(spec,n,db); eq(c:Scan(),true); verifyControls(); verifyPrior()
        -- The shared characters map gains one key, but every prior character graph
        -- stays untouched. Check its entries independently from the growing map.
        for guid,value in pairs(prior) do eq(db.characters[guid],value) end
        eq(db.characters["Player-E03-synthetic-13"],oldInscription); eq(db.characters["Player-E03-synthetic-9"],oldEnchanting)
        local r=row(c,s,spec); eq(r.moxie,41*n+11)
        local count=0; for id in pairs(db.characters[s.guid].professions) do eq(id,spec[2]); count=count+1 end; eq(count,1)
        last=c
    end
    local verify=unchangedGraph(db); eq(#V.Build(db,last.fresh,{},100),8)
    for n,spec in ipairs(specs) do
        local rows=V.Build(db,last.fresh,{professionFamily=spec[4]},100); eq(#rows,1)
        eq(rows[1].guid,"Player-E03-synthetic-"..spec[4]); eq(rows[1].id,spec[2]); eq(rows[1].moxie,41*n+11)
        eq(rows[1].skillState.fresh,n==#specs)
    end
    mockWidgets(last.env); local ui=NS.Dashboard.New(last.env,last); ui:Toggle(); eq(#ui.rows,8)
    ui:Refresh(); ui:Render(); verify(); verifyControls(); verifyRegistry()
end)
case("E03 all six transient generic currency and gear failures preserve coherent values and timestamps",function(checkpoint)
    for n,spec in ipairs(specs) do
        pause(checkpoint,"E03 failure seed "..spec[1])
        local env,s,c=fixture(spec,n); s.balance=601+n; eq(c:Scan(),true)
        local before=C.Copy(active(c,s,spec))
        pause(checkpoint,"E03 failed reads "..spec[1])
        s.at=120; s.info.skillModifier=nil; s.failure=function() error("E03 synthetic currency failure") end
        env.C_ProfSpecs.GetCurrencyInfoForSkillLine=function() return nil end
        env.C_Item.GetItemStats=function() error("E03 synthetic gear failure") end
        eq(c:Scan(),true); local g=active(c,s,spec); eq(g.scannedAt,120)
        for key,status in pairs({skill="unknown",concentration="error",moxie="error",unspent="unknown",
            tool="error",accessory1="error",accessory2="error"}) do
            local f=g.fields[key]; local verify=unchangedGraph(f.last)
            -- Compare content without requiring retained snapshots to share references.
            local function same(a,b)
                eq(type(a),type(b)); if type(a)~="table" then eq(a,b); return end
                for k,v in pairs(a) do same(v,b[k]) end; for k in pairs(b) do assert(a[k]~=nil) end
            end
            same(f.last,before.fields[key].last); verify()
            eq(f.last.observedAt,100); eq(f.attempt.attemptedAt,120); eq(f.attempt.status,status)
        end
        local r=row(c,s,spec); eq(r.skill.skillLevel,20+n); eq(r.skillState.fresh,false); eq(r.skillState.stale,true)
        eq(r.concentration,210+n); eq(r.unspent,3+n); eq(r.moxie,601+n)
        -- U13 ADAPT E03_HISTORICAL BEGIN
--[==========[U13 ORIGINAL BEGIN
        eq(r.cells[I.Moxie],"|cff999999!|r "..(601+n)); noFreshMoxie(r)
U13 ORIGINAL END]==========]
        eq(r.cells[I.Moxie],tostring(601+n)); noFreshMoxie(r)
        -- U13 ADAPT E03_HISTORICAL END
        eq(r.gear.tool.state.fresh,false); eq(r.gear.tool.state.observedAt,100)
        local _,ms=V.Field(g,"moxie",c.fresh[s.guid..":"..spec[2]])
        eq(ms.fresh,false); eq(ms.stale,true); eq(ms.observedAt,100); eq(C.Open(c.db),c.db)
        verifyRegistry()
    end
end)
case("E03 first currency failures for all six remain unknown not fabricated zero or attention",function(checkpoint)
    for n,spec in ipairs(specs) do
        for _,failure in ipairs({function() return nil end,function() error("E03 synthetic failure") end,
            function() return {quantity=-1} end}) do
            pause(checkpoint,"E03 first failure "..spec[1])
            local _,s,c=fixture(spec,n); s.failure=failure; eq(c:Scan(),true)
            local g=active(c,s,spec); eq(g.fields.moxie.last,nil); eq(g.fields.concentration.last,nil)
            local r=row(c,s,spec); eq(r.moxie,nil); eq(r.concentration,nil); eq(r.cells[I.Moxie],"?")
            for _,w in ipairs(r.warnings) do assert(w.category~="Moxie" and w.category~="Concentration") end
            eq(#V.Build(c.db,c.fresh,{professionFamily=spec[4],attention="Moxie"},100),0)
            eq(s.queries[spec[5]],1); eq(s.queries[3261],nil); eq(s.queries[3258],nil)
        end
    end
    verifyRegistry()
end)
case("E03 closed and reopened six character saved dashboard renders without collection or fabricated freshness",function(checkpoint)
    local db=C.Open(nil); local last,env,s
    for n,spec in ipairs(specs) do
        pause(checkpoint,"E03 cache seed "..spec[1])
        env,s,last=fixture(spec,n,db); s.balance=601+n; eq(last:Scan(),true)
        pause(checkpoint,"E03 closed context "..spec[1])
        s.shown=false; s.at=130; last:Invalidate("E03 synthetic closure")
        local verify=unchangedGraph(db); eq(last:Scan(),false); verify()
        local r=row(last,s,spec); eq(r.moxie,601+n); eq(r.skillState.fresh,false); eq(r.lastUpdated,"30s")
        noFreshMoxie(r); eq(s.queries[spec[5]],1)
    end
    pause(checkpoint,"E03 reopen complete saved six-character DB")
    local saved=C.Copy(db); local reopened=assert(C.Open(saved)); s.at=150
    local function forbidden() error("E03 cached dashboard must not collect") end
    for _,api in ipairs({env.C_TradeSkillUI,env.C_ProfSpecs,env.C_Traits,env.C_Item,env.C_CurrencyInfo}) do
        for key,value in pairs(api) do if type(value)=="function" then api[key]=forbidden end end
    end
    local fresh=NS.Collectors.New(env,reopened)
    fresh.Scan=forbidden; fresh.Context=forbidden; fresh.Knowledge=forbidden; fresh.Gear=forbidden
    local verify=unchangedGraph({saved,fresh.fresh,s.queries})
    mockWidgets(env); local ui=NS.Dashboard.New(env,fresh); ui:Toggle(); eq(#ui.rows,6)
    local byID={}; for _,r in ipairs(ui.rows) do byID[r.id]=r end
    for n,spec in ipairs(specs) do
        local r=assert(byID[spec[2]]); eq(r.guid,"Player-E03-synthetic-"..spec[4]); eq(r.profession,"合成 métier "..n)
        eq(r.skill.skillLevel,20+n); eq(r.concentration,210+n); eq(r.unspent,3+n); eq(r.moxie,601+n)
        eq(r.gear.tool.value.itemID,91000+n*100+20); eq(r.gear.tool.state.fresh,false)
        eq(r.skillState.fresh,false); eq(r.skillState.observedAt,100); eq(r.lastUpdated,"50s")
        assert(r.snapshot:find("snapshot",1,true)); noFreshMoxie(r)
        local g=saved.characters[r.guid].professions[r.id].active
        local _,ms=V.Field(g,"moxie",fresh.fresh[r.guid..":"..r.id]); eq(ms.fresh,false); eq(ms.observedAt,100)
        local raw,rs=V.Field(g,"knowledgeRaw",fresh.fresh[r.guid..":"..r.id])
        eq(C.ValidPayload("knowledgeRaw",raw,"observed"),true); eq(raw.nativeComplete,false)
        eq(raw.identity.skillLineID,spec[2]); eq(raw.identity.parentID,spec[3])
        eq(raw.identity.profession,spec[4]); eq(raw.identity.expansionID,11)
        eq(rs.observedAt,100); eq(rs.fresh,false); eq(r.trees[1].aggregateText,"?/?")
    end
    ui:Refresh(); ui:Render(); eq(next(fresh.fresh),nil); verify(); verifyRegistry()
end)
end
-- E03 END

-- E04 BEGIN: exact supplied enchant IDs; all item/scan values below are synthetic.
-- D/F/P rendering exercises labels only, NOT gathering support/equipped compatibility.
do
local D,V=NS.Data,NS.ViewModel
local supplied={{7977,"Resourcefulness"},{8005,"Multicraft"},{8035,"Ingenuity"},
    {8033,"Deftness"},{8003,"Finesse"},{7975,"Perception"}}
local verifyRegistry=unchangedGraph(D)
local function fixture(id)
    local env,s=fixtureAPI()
    s.guid="Player-E04-synthetic-engineer"; s.enchantID=id; s.positive=id~=0
    s.info={professionID=2910,parentProfessionID=202,profession=8,isPrimaryProfession=true,
        professionName="Engineering",expansionName="Synthetic E04",sourceCounter=1,
        skillLevel=37,maxSkillLevel=100,skillModifier=6}
    env.UnitGUID=function(unit) eq(unit,"player"); return s.guid end
    env.UnitName=function(unit) eq(unit,"player"); return "Synthetic E04 engineer" end
    env.GetProfessionInfo=function(index) eq(index,1); return "Engineering",0,100,100,0,0,202 end
    local t,p=env.C_TradeSkillUI,env.C_ProfSpecs
    t.GetBaseProfessionInfo=function() return {professionID=202} end
    t.GetProfessionSlots=function(family) eq(family,8); return s.slots end
    t.GetConcentrationCurrencyID=function(skill) eq(skill,2910); return 74001 end
    env.C_CurrencyInfo.GetCurrencyInfo=function(currency)
        assert(currency==74001 or currency==3259,"E04 own Engineering currencies only")
        return {quantity=currency==3259 and 73 or 289,maxQuantity=currency==74001 and 1000 or 0}
    end
    p.GetConfigIDForSkillLine=function(skill) eq(skill,2910); return 74002 end
    p.GetSpecTabIDsForSkillLine=function(skill) eq(skill,2910); return {} end
    p.GetCurrencyInfoForSkillLine=function(skill) eq(skill,2910); return {numAvailable=9} end
    env.C_Item.GetItemID=function(loc) return 94000+loc.slot end
    env.C_Item.GetItemLink=function(loc)
        if s.noLink then return nil end
        return "item:"..(94000+loc.slot)..":"..(loc.slot==20 and s.enchantID or 0)..":0:0"
    end
    env.C_Item.GetItemStats=function() return {ITEM_MOD_RESOURCEFULNESS_SHORT=47} end
    env.C_TooltipInfo.GetInventoryItem=function(unit,slot)
        eq(unit,"player")
        return {lines=slot==20 and s.positive and {{type=15,leftText="Synthetic E04 enchant",rightText="Synthetic detail"}} or {}}
    end
    return env,s,NS.Collectors.New(env,C.Open(nil))
end
local function active(c,s) return c.db.characters[s.guid].professions[2910].active end
local function row(c,s,at)
    local rows=V.Build(c.db,c.fresh,{professionFamily=8},at or s.at)
    eq(#rows,1); eq(rows[1].guid,s.guid); eq(rows[1].id,2910); return rows[1]
end
local function noAmounts(enchant)
    eq(enchant.amount,nil); eq(enchant.rank,nil); eq(enchant.quality,nil)
end
local function diagnostic(tool,id,category)
    local text=table.concat(tool.tooltip,"\n")
    assert(text:find("ID "..id.."; stat "..category.."; amount/rank unknown",1,true))
    assert(text:find("Synthetic E04 enchant",1,true)); assert(text:find("Synthetic detail",1,true))
    assert(text:find("Resourcefulness: 47 (observed total)",1,true))
    assert(text:find("base/enchant attribution unknown",1,true))
end
case("E04 exact six enchant categories provenance and no inferred amounts ranks or extra IDs",function()
    local expected={}; for _,spec in ipairs(supplied) do expected[spec[1]]=spec[2] end
    local count=0
    for id,entry in pairs(D.enchants) do
        assert(expected[id]); eq(entry.category,expected[id]); noAmounts(entry)
        local fields=0; for key in pairs(entry) do assert(key=="category" or key=="provenance"); fields=fields+1 end
        eq(fields,2); count=count+1
        if id==8005 then eq(entry.provenance,"T01 user ID + typed line; 70783")
        elseif id==7977 then eq(entry.provenance,"Engineering equipped diagnostic + user category 2026-11-10")
        else eq(entry.provenance,"User-supplied list 2026-11-10; not native-verified here") end
    end
    eq(count,6); eq(D.enchants[9999],nil); eq(D.enchants[7978],nil); verifyRegistry()
end)
case("E04 D F P full labels without new stat API keys or gathering identities",function()
    local categories={["Crafting Speed"]="C",Ingenuity="I",Multicraft="M",Resourcefulness="R",
        Deftness="D",Finesse="F",Perception="P"}
    local count=0
    for name,labels in pairs(D.statCategories) do
        eq(labels[1],assert(categories[name])); eq(labels[2],name); eq(#labels,2); count=count+1
    end
    eq(count,7)
    local keys={ITEM_MOD_CRAFTING_SPEED_SHORT="Crafting Speed",ITEM_MOD_INGENUITY_SHORT="Ingenuity",
        ITEM_MOD_MULTICRAFT_SHORT="Multicraft",ITEM_MOD_RESOURCEFULNESS_SHORT="Resourcefulness"}
    count=0; for key,labels in pairs(D.statNames) do eq(labels,D.statCategories[assert(keys[key])]); count=count+1 end
    eq(count,4)
    local families={[1]="Blacksmithing",[2]="Leatherworking",[3]="Alchemy",[7]="Tailoring",
        [8]="Engineering",[9]="Enchanting",[12]="Jewelcrafting",[13]="Inscription"}
    count=0; for id,name in pairs(D.families) do eq(name,assert(families[id])); count=count+1 end; eq(count,8)
    local skills={[2906]=true,[2907]=true,[2909]=true,[2910]=true,[2913]=true,[2914]=true,[2915]=true,[2918]=true}
    count=0; for id in pairs(D.expansions) do assert(skills[id]); count=count+1 end; eq(count,8)
    for _,family in ipairs({4,5,6}) do eq(D.Identity({professionID=75000+family,parentProfessionID=202,profession=family}),nil) end
    verifyRegistry()
end)
for _,value in ipairs(supplied) do
    local id,category=value[1],value[2]
    case("E04 ready enchant "..id.." collector gear snapshot renders full "..category,function(checkpoint)
        local _,s,c=fixture(id)
        local enchant=NS.Collectors.Enchant("item:94020:"..id..":0",true,true)
        eq(enchant.status,"observed"); eq(enchant.present,true); eq(enchant.id,id); eq(enchant.category,category); noAmounts(enchant)
        local gear,status=c:Gear(20,"tool")
        eq(status,"observed"); eq(gear.metadataReady,true); eq(gear.enchant.id,id); eq(gear.enchant.category,category)
        noAmounts(gear.enchant); eq(C.ValidPayload("tool",gear,"observed"),true)
        pause(checkpoint,"E04 commit ready synthetic gear "..id)
        local ctx=assert(c:Context())
        local g=assert(C.Apply(c.db,ctx.character,ctx.identity,{tool=C.Observation("observed",gear,100,"E04 synthetic gear")},100,"E04 fixture"))
        eq(g.fields.tool.last.value.enchant.category,category); eq(g.fields.tool.last.value.enchant.id,id)
        local r=row(c,s); eq(r.cells[I.Enchant],category); eq(r.cells[I.Stat],"Resourcefulness")
        eq(r.enchantMissing,false); noAmounts(r.gear.tool.enchant); diagnostic(r.gear.tool,id,category)
        eq(r.cells[I.Enchant]:find("47",1,true),nil); eq(r.cells[I.Stat]:find("47",1,true),nil)
        eq(C.Open(c.db),c.db); verifyRegistry()
    end)
end
case("E04 own ready Engineering scan saves 7977 Resourcefulness and normal row",function(checkpoint)
    local _,s,c=fixture(7977); eq(c:Scan(),true)
    local g=active(c,s); eq(g.identity.skillLineID,2910); eq(g.identity.parentID,202); eq(g.identity.profession,8)
    local f=g.fields.tool; eq(f.attempt.status,"observed"); eq(f.last.observedAt,100)
    eq(f.last.value.itemID,94020); eq(f.last.value.enchant.id,7977); eq(f.last.value.enchant.category,"Resourcefulness")
    noAmounts(f.last.value.enchant)
    local r=row(c,s); eq(r.profession,"Engineering"); eq(r.cells[I.Enchant],"Resourcefulness")
    eq(r.cells[I.Stat],"Resourcefulness"); eq(r.gear.tool.state.fresh,true); eq(r.enchantMissing,false)
    eq(r.skill.skillLevel,37); eq(r.moxie,73); eq(r.concentration,289); eq(r.unspent,9)
    eq(g.fields.knowledgeRaw.attempt.status,"observed")
    local raw=g.fields.knowledgeRaw.last.value
    eq(C.ValidPayload("knowledgeRaw",raw,"observed"),true); eq(#raw.tabs,0)
    eq(raw.tabsComplete,false); eq(raw.nativeComplete,false)
    eq(raw.identity.skillLineID,2910); eq(raw.identity.parentID,202)
    eq(raw.identity.profession,8); eq(raw.identity.expansionID,11)
    diagnostic(r.gear.tool,7977,"Resourcefulness")
    pause(checkpoint,"E04 repeated own Engineering scan")
    s.at=111; eq(c:Scan(),true); eq(active(c,s).fields.tool.last.observedAt,111)
    eq(row(c,s).cells[I.Enchant],"Resourcefulness"); verifyRegistry()
end)
case("E04 unknown positive absent missing unready and conflicting enchants stay distinct",function(checkpoint)
    local unknown=NS.Collectors.Enchant("item:94020:9999:0",true,true)
    eq(unknown.status,"observed"); eq(unknown.present,true); eq(unknown.id,9999); eq(unknown.category,nil); noAmounts(unknown)
    local absent=NS.Collectors.Enchant("item:94020:0:0",false,true)
    eq(absent.status,"observed"); eq(absent.present,false); eq(absent.id,0)
    for _,spec in ipairs({{9999,"?",false},{0,"",true}}) do
        pause(checkpoint,"E04 positive unknown versus absent scan")
        local _,s,c=fixture(spec[1]); eq(c:Scan(),true)
        local r=row(c,s); eq(r.cells[I.Enchant],spec[2]); eq(r.enchantMissing,spec[3])
        eq(active(c,s).fields.tool.last.value.enchant.present,not spec[3])
    end
    for _,args in ipairs({{false,false,true},{"item:94020:",false,true},
        {"item:94020:7977:0",true,false},{"item:94020:0:0",true,true}}) do
        local enchant=NS.Collectors.Enchant(args[1],args[2],args[3])
        eq(enchant.status,"unknown"); eq(enchant.present,nil); eq(enchant.id,nil); noAmounts(enchant)
        eq(V.Tool({exists=true,metadataReady=true,enchant=enchant},{text="fixture"}).enchantText,"?")
    end
    for _,change in ipairs({function(_,s) s.noLink=true end,function(_,s) s.loading=true end,
        function(_,s) s.enchantID=0; s.positive=true end}) do
        pause(checkpoint,"E04 missing unready conflicting first scan")
        local env,s,c=fixture(7977); change(env,s); eq(c:Scan(),true)
        local r=row(c,s); eq(r.cells[I.Enchant],"?"); assert(r.enchantMissing~=true,"unknown is not confirmed missing")
    end
    eq(NS.Collectors.Enchant(nil,false,true).status,"unknown"); verifyRegistry()
end)
case("E04 Engineering enchant survives gear and same item metadata failures without fresh promotion",function(checkpoint)
    for _,failure in ipairs({function(env) env.C_Item.GetItemStats=function() error("E04 synthetic gear failure") end end,
        function(env) env.C_Item.GetItemQuality=function() return nil end end,
        function(_,s) s.loading=true end}) do
        pause(checkpoint,"E04 seed known Engineering enchant")
        local env,s,c=fixture(7977); eq(c:Scan(),true)
        local old=active(c,s).fields.tool.last; local verify=unchangedGraph(old)
        pause(checkpoint,"E04 transient same item failure")
        failure(env,s); s.at=123; eq(c:Scan(),true)
        local f=active(c,s).fields.tool
        assert(f.attempt.status~="observed"); eq(f.attempt.attemptedAt,123); eq(f.last.observedAt,100)
        eq(f.last.value.itemID,94020); eq(f.last.value.enchant.id,7977); eq(f.last.value.enchant.category,"Resourcefulness")
        local r=row(c,s); eq(r.cells[I.Enchant],"Resourcefulness"); eq(r.enchantMissing,false)
        eq(r.gear.tool.state.fresh,false); eq(r.gear.tool.state.stale,true); eq(r.gear.tool.state.observedAt,100)
        noAmounts(r.gear.tool.enchant); diagnostic(r.gear.tool,7977,"Resourcefulness"); verify(); verifyRegistry()
    end
end)
case("E04 reopened Engineering dashboard uses saved enchant with no API collection or freshness mutation",function(checkpoint)
    local env,s,c=fixture(7977); eq(c:Scan(),true)
    pause(checkpoint,"E04 reopen Engineering saved DB")
    local saved=assert(C.Copy(c.db)); eq(C.Open(saved),saved); s.at=145
    local calls=0; local function forbidden() calls=calls+1; error("E04 offline API forbidden") end
    for _,api in ipairs({env.C_TradeSkillUI,env.C_ProfSpecs,env.C_Traits,env.C_Item,env.C_CurrencyInfo,env.C_TooltipInfo}) do
        for key,value in pairs(api) do if type(value)=="function" then api[key]=forbidden end end
    end
    -- U13 E04_GUID_COUNTER BEGIN
    local guidCalls=0
    -- U13 E04_GUID_COUNTER END
    -- U13 ADAPT E04_GUID_SPY BEGIN
--[==========[U13 ORIGINAL BEGIN
    env.UnitGUID=forbidden; env.GetProfessions=forbidden
U13 ORIGINAL END]==========]
    env.UnitGUID=function(unit)
        eq(unit,"player"); guidCalls=guidCalls+1; error("E04 offline API forbidden")
    end
    env.GetProfessions=forbidden
    -- U13 ADAPT E04_GUID_SPY END
    local reopened=NS.Collectors.New(env,saved)
    reopened.Scan=forbidden; reopened.Context=forbidden; reopened.Gear=forbidden; reopened.Knowledge=forbidden
    local verify=unchangedGraph({saved,reopened.fresh})
    mockWidgets(env); local ui=NS.Dashboard.New(env,reopened); ui:Toggle(); eq(#ui.rows,1)
    local r=ui.rows[1]; eq(r.profession,"Engineering"); eq(r.id,2910); eq(r.cells[I.Enchant],"Resourcefulness")
    eq(r.gear.tool.state.fresh,false); eq(r.gear.tool.state.observedAt,100); eq(r.lastUpdated,"45s")
    diagnostic(r.gear.tool,7977,"Resourcefulness"); noAmounts(r.gear.tool.enchant)
    -- U13 ADAPT E04_GUID_CHECK BEGIN
--[==========[U13 ORIGINAL BEGIN
    ui:Refresh(); ui:Render(); eq(calls,0); eq(next(reopened.fresh),nil); verify(); verifyRegistry()
U13 ORIGINAL END]==========]
    eq(guidCalls,1,"U13 E04 Toggle makes one protected own-GUID attempt")
    eq(ui.options.currentPlayerGUID,nil)
    ui:Refresh(); eq(guidCalls,2,"U13 E04 Refresh makes one protected own-GUID attempt")
    ui:Render(); eq(guidCalls,2,"U13 E04 Render makes no identity attempt")
    eq(ui.options.currentPlayerGUID,nil)
    for _,widget in ipairs(ui.widgets) do eq(widget.cells[I.Name].currentDot:IsShown(),false) end
    eq(calls,0); eq(next(reopened.fresh),nil); verify(); verifyRegistry()
    -- U13 ADAPT E04_GUID_CHECK END
end)
case("E04 saved unmapped category stays unknown until ordinary Engineering rescan not cached migration",function(checkpoint)
    local env,s,c=fixture(7977); eq(c:Scan(),true)
    -- Reconstruct the pre-E04 saved shape in this private DB only, never Data.
    local saved=assert(C.Copy(c.db)); local enchant=saved.characters[s.guid].professions[2910].active.fields.tool.last.value.enchant
    enchant.category=nil; eq(C.Open(saved),saved)
    local verify=unchangedGraph(saved); local cached=NS.Collectors.New(env,saved)
    local r=row(cached,s); eq(r.cells[I.Enchant],"?"); eq(r.enchantMissing,false); eq(enchant.id,7977); verify()
    pause(checkpoint,"E04 normal own scan updates old saved category")
    s.at=152; eq(cached:Scan(),true)
    eq(active(cached,s).fields.tool.last.value.enchant.category,"Resourcefulness")
    eq(active(cached,s).fields.tool.last.observedAt,152); eq(row(cached,s).cells[I.Enchant],"Resourcefulness")
    eq(enchant.category,nil); verifyRegistry()
end)
end
-- E04 END

-- E05 BEGIN: explicit-empty enchant encoding; all instance/scan values are synthetic.
do
local E,V=NS.Collectors.Enchant,NS.ViewModel
local verifyRegistry=unchangedGraph(NS.Data)
local function noAmounts(v) eq(v.amount,nil); eq(v.rank,nil); eq(v.quality,nil) end
local function absent(v)
    eq(v.status,"observed"); eq(v.present,false); eq(v.id,0); eq(v.category,nil); eq(v.reason,nil); noAmounts(v)
end
local function unknown(v,reason)
    eq(v.status,"unknown"); eq(v.present,nil); eq(v.id,nil); eq(v.category,nil); eq(v.reason,reason); noAmounts(v)
    eq(V.Tool({exists=true,metadataReady=true,enchant=v},{text="E05 synthetic"}).enchantText,"?")
end
local function fixture(field)
    local env,s=fixtureAPI()
    s.guid="Player-E05-synthetic-enchanter"; s.field=field or ""; s.positive=false
    s.info={professionID=2909,parentProfessionID=333,profession=9,isPrimaryProfession=true,
        professionName="Enchanting",expansionName="Synthetic E05",sourceCounter=1,
        skillLevel=43,maxSkillLevel=100,skillModifier=7}
    env.UnitGUID=function(unit) eq(unit,"player"); return s.guid end
    env.UnitName=function(unit) eq(unit,"player"); return "Synthetic E05 enchanter" end
    env.GetProfessionInfo=function(index) eq(index,1); return "Enchanting",0,100,100,0,0,333 end
    local t,p=env.C_TradeSkillUI,env.C_ProfSpecs
    t.GetBaseProfessionInfo=function() return {professionID=333} end
    t.GetProfessionSlots=function(family) eq(family,9); return s.slots end
    t.GetConcentrationCurrencyID=function(skill) eq(skill,2909); return 75001 end
    t.GetItemCraftedQualityByItemInfo=function() return 3 end
    t.GetItemCraftedQualityInfo=function() return {quality=3,iconSmall="E05-synthetic-atlas"} end
    env.C_CurrencyInfo.GetCurrencyInfo=function(currency)
        assert(currency==75001 or currency==3258,"E05 own Enchanting currencies only")
        return {quantity=currency==3258 and 87 or 317,maxQuantity=currency==75001 and 1000 or 0}
    end
    p.GetConfigIDForSkillLine=function(skill) eq(skill,2909); return 75002 end
    p.GetSpecTabIDsForSkillLine=function(skill) eq(skill,2909); return {} end
    p.GetCurrencyInfoForSkillLine=function(skill) eq(skill,2909); return {numAvailable=6} end
    env.C_Item.GetItemID=function(loc) return 95000+loc.slot end
    env.C_Item.GetItemLink=function(loc)
        if s.noLink then return nil end
        return "item:"..(95000+loc.slot)..":"..(loc.slot==20 and s.field or "0")..":0:0"
    end
    env.C_Item.GetItemQuality=function() return 2 end
    env.C_Item.GetItemStats=function() return {ITEM_MOD_RESOURCEFULNESS_SHORT=53} end
    env.C_TooltipInfo.GetInventoryItem=function(unit,slot)
        eq(unit,"player")
        return {lines=slot==20 and s.positive and {{type=15,leftText="E05 synthetic enchant"}} or {}}
    end
    return env,s,NS.Collectors.New(env,C.Open(nil))
end
local function active(c,s) return c.db.characters[s.guid].professions[2909].active end
local function row(c,s)
    local rows=V.Build(c.db,c.fresh,{professionFamily=9},s.at)
    eq(#rows,1); eq(rows[1].guid,s.guid); eq(rows[1].id,2909); return rows[1]
end
case("E05 explicit empty and zero equivalent in plain legacy and modern full links",function()
    for _,wrap in ipairs({function(v) return v end,
        function(v) return "|cffa335ee|H"..v.."|h[Synthetic legacy tool]|h|r" end,
        function(v) return "|cnIQ3:|H"..v.."|h[Synthetic modern tool]|h|r" end}) do
        -- Full synthetic suffix exercises zero omission beyond the enchant field too.
        for _,tail in ipairs({"0",":0:0:0:0:100:9:0:0:0:2:111:222:0:0:0"}) do
            local empty=E(wrap("item:95020::"..tail),false,true)
            local zero=E(wrap("item:95020:0:"..tail),false,true)
            absent(empty); absent(zero)
            for k,v in pairs(empty) do eq(zero[k],v) end
            for k,v in pairs(zero) do eq(empty[k],v) end
        end
    end
    verifyRegistry()
end)
case("E05 truly missing malformed negative nonnumeric and overflow fields remain unknown",function()
    for _,link in ipairs({"", "item:95020", "item:95020:", "item:95020:0", "item:95020:8005",
        "item:::", "item:abc::0", "item:95020:garbage:0", "item:95020: :0",
        "item:95020:-1:0", "item:95020:+0:0", "item:95020:1.5:0", "item:95020:0x1:0",
        "item:95020:"..string.rep("9",400)..":0", "|cnIQ3:|Hitem:95020:|h[Missing delimiter]|h|r"}) do
        unknown(E(link,false,true),"invalid/missing enchant field")
    end
    for _,value in ipairs({{},false,95020}) do unknown(E(value,false,true),"instance link unready") end
    unknown(E(nil,false,true),"instance link unready"); verifyRegistry()
end)
case("E05 explicit empty and zero retain typed positive conflict and strict readiness guards",function()
    for _,field in ipairs({"","0"}) do
        local link="item:95020:"..field..":0"
        unknown(E(link,true,true),"link/typed-line conflict")
        unknown(E(link,false,false),"instance link unready")
        unknown(E(link,false,nil),"instance link unready")
        unknown(E(link,false,1),"instance link unready")
        absent(E(link,false,true)); absent(E(link,nil,true))
    end
    verifyRegistry()
end)
case("E05 positive exact categories and unmapped IDs preserve presence without amounts ranks",function()
    for _,spec in ipairs({{7977,"Resourcefulness"},{8005,"Multicraft"},{8035,"Ingenuity"},
        {8033,"Deftness"},{8003,"Finesse"},{7975,"Perception"},{9999}}) do
        for _,positive in ipairs({false,true}) do
            local link="|cnIQ3:|Hitem:95020:"..spec[1].."::::0:0:100:9:0:0:0|h[Synthetic tool]|h|r"
            local v=E(link,positive,true)
            eq(v.status,"observed"); eq(v.present,true); eq(v.id,spec[1]); eq(v.category,spec[2]); noAmounts(v)
            eq(V.Tool({exists=true,metadataReady=true,enchant=v},{text="E05 synthetic"}).enchantText,spec[2] or "?")
            unknown(E(link,positive,false),"instance link unready")
        end
    end
    verifyRegistry()
end)
case("E05 isolated own ready Enchanting empty field normal scan saves absence and blank",function()
    local _,s,c=fixture(); eq(c:Scan(),true)
    local g=active(c,s); eq(g.identity.skillLineID,2909); eq(g.identity.parentID,333); eq(g.identity.profession,9)
    local f=g.fields.tool; eq(f.attempt.status,"observed"); eq(f.last.observedAt,100)
    eq(f.last.value.link,"item:95020::0:0"); eq(f.last.value.itemID,95020); eq(f.last.value.metadataReady,true)
    eq(f.last.value.rarity,2); eq(f.last.value.rank,3); absent(f.last.value.enchant)
    local r=row(c,s); eq(r.profession,"Enchanting"); eq(r.cells[I.Enchant],""); eq(r.enchantMissing,true)
    eq(r.cells[I.Stat],"Resourcefulness"); eq(r.gear.tool.state.fresh,true)
    assert(table.concat(r.gear.tool.tooltip,"\n"):find("Enchant: no; ID 0",1,true))
    eq(r.skill.skillLevel,43); eq(r.moxie,87); eq(r.concentration,317); eq(r.unspent,6)
    eq(g.fields.knowledgeRaw.attempt.status,"observed")
    local raw=g.fields.knowledgeRaw.last.value
    eq(C.ValidPayload("knowledgeRaw",raw,"observed"),true); eq(#raw.tabs,0)
    eq(raw.tabsComplete,false); eq(raw.nativeComplete,false)
    eq(raw.identity.skillLineID,2909); eq(raw.identity.parentID,333)
    eq(raw.identity.profession,9); eq(raw.identity.expansionID,11)
    local n=0; for guid in pairs(c.db.characters) do eq(guid,s.guid); n=n+1 end; eq(n,1)
    n=0; for id in pairs(c.db.characters[s.guid].professions) do eq(id,2909); n=n+1 end; eq(n,1)
    eq(s.requests,0); eq(C.Open(c.db),c.db); verifyRegistry()
end)
case("E05 later observed empty field clears prior known enchant without stale category borrowing",function(checkpoint)
    local _,s,c=fixture("8035"); s.positive=true; eq(c:Scan(),true)
    local old=active(c,s); local verify=unchangedGraph(old)
    eq(row(c,s).cells[I.Enchant],"Ingenuity"); eq(old.fields.tool.last.value.enchant.id,8035)
    pause(checkpoint,"E05 known to observed empty own scan")
    s.at=121; s.field=""; s.positive=false; eq(c:Scan(),true)
    local g=active(c,s); eq(g.generation,old.generation); eq(g.scannedAt,121)
    local f=g.fields.tool; eq(f.last.observedAt,121); eq(f.attempt.attemptedAt,121); eq(f.attempt.status,"observed")
    absent(f.last.value.enchant); eq(f.last.value.enchant.category,nil)
    eq(f.last.value.link,"item:95020::0:0"); eq(row(c,s).cells[I.Enchant],""); eq(row(c,s).enchantMissing,true)
    eq(row(c,s).gear.tool.state.fresh,true); verify(); verifyRegistry()
end)
case("E05 unavailable reads preserve identifiable known history and closed empty snapshot time",function(checkpoint)
    -- Core's exact-link same-instance guard is deliberately unchanged; use its
    -- established numeric link for same-instance metadata failure preservation.
    for _,failure in ipairs({function(env) env.C_Item.GetItemStats=function() error("E05 synthetic read error") end end,
        function(env) env.C_Item.GetItemQuality=function() return nil end end,
        function(_,s) s.loading=true end}) do
        pause(checkpoint,"E05 seed identifiable known history")
        local env,s,c=fixture("8035"); s.positive=true; eq(c:Scan(),true)
        local old=active(c,s).fields.tool.last; local verify=unchangedGraph(old)
        pause(checkpoint,"E05 unavailable same instance metadata")
        failure(env,s); s.at=132; eq(c:Scan(),true)
        local f=active(c,s).fields.tool; assert(f.attempt.status~="observed")
        eq(f.attempt.attemptedAt,132); eq(f.last.observedAt,100); eq(f.last.value.enchant.id,8035)
        local r=row(c,s); eq(r.cells[I.Enchant],"Ingenuity"); eq(r.enchantMissing,false)
        eq(r.gear.tool.state.fresh,false); eq(r.gear.tool.state.stale,true); eq(r.gear.tool.state.observedAt,100)
        verify()
    end
    pause(checkpoint,"E05 seed ready empty before context unavailable")
    local _,s,c=fixture(); eq(c:Scan(),true); local verify=unchangedGraph(c.db)
    pause(checkpoint,"E05 unavailable own profession context")
    s.shown=false; s.at=144; c:Invalidate("E05 synthetic closure"); eq(c:Scan(),false)
    local r=row(c,s); eq(r.cells[I.Enchant],""); eq(r.gear.tool.state.observedAt,100)
    eq(r.gear.tool.state.fresh,false); eq(r.lastUpdated,"44s"); absent(active(c,s).fields.tool.last.value.enchant)
    verify(); verifyRegistry()
end)
case("E05 initial failed conflicting malformed and metadata unready scans never fabricate absence",function(checkpoint)
    for _,change in ipairs({function(_,s) s.noLink=true end,function(_,s) s.loading=true end,
        function(_,s) s.positive=true end,function(_,s) s.field="garbage" end,
        function(env) env.C_Item.GetItemQuality=function() return nil end end}) do
        pause(checkpoint,"E05 initial unknown not absent scan")
        local env,s,c=fixture(); change(env,s); eq(c:Scan(),true)
        local r=row(c,s); eq(r.cells[I.Enchant],"?"); assert(r.enchantMissing~=true)
        local tool=active(c,s).fields.tool.last.value
        if tool.enchant and tool.enchant.status=="observed" then
            -- Valid empty parsing does not relax the whole-tool display gate.
            absent(tool.enchant); eq(tool.metadataReady,false); eq(r.gear.tool.enchant,nil)
        else assert(not tool.enchant or tool.enchant.status=="unknown") end
    end
    local value={exists=true,metadataReady=false,enchant=E("item:95020::0",false,true)}
    absent(value.enchant); eq(V.Tool(value,{text="E05 synthetic"}).enchantText,"?"); verifyRegistry()
end)
case("E05 old saved unknown stays unknown without cached API migration then normal scan becomes blank",function(checkpoint)
    local env,s,c=fixture(); eq(c:Scan(),true)
    pause(checkpoint,"E05 reconstruct private pre-fix unknown snapshot")
    local saved=assert(C.Copy(c.db)); local old=saved.characters[s.guid].professions[2909].active.fields.tool.last
    old.value.enchant={status="unknown",reason="invalid/missing enchant field"}; eq(C.Open(saved),saved)
    local restore,calls={},0
    local function trap() calls=calls+1; error("E05 cached API forbidden") end
    for _,api in ipairs({env.C_TradeSkillUI,env.C_ProfSpecs,env.C_Traits,env.C_Item,env.C_CurrencyInfo,env.C_TooltipInfo}) do
        for key,value in pairs(api) do
            if type(value)=="function" then restore[#restore+1]={api,key,value}; api[key]=trap end
        end
    end
    local cached=NS.Collectors.New(env,saved); s.at=156
    local verify=unchangedGraph({saved,cached.fresh})
    mockWidgets(env); local ui=NS.Dashboard.New(env,cached); ui:Toggle(); eq(#ui.rows,1)
    local r=ui.rows[1]; eq(r.cells[I.Enchant],"?"); assert(r.enchantMissing~=true)
    eq(r.gear.tool.state.fresh,false); eq(r.gear.tool.state.observedAt,100); eq(r.lastUpdated,"56s")
    ui:Refresh(); ui:Render(); eq(calls,0); eq(old.value.enchant.status,"unknown"); verify()
    for _,entry in ipairs(restore) do entry[1][entry[2]]=entry[3] end
    pause(checkpoint,"E05 normal ready own scan replaces cached unknown")
    s.at=160; eq(cached:Scan(),true); absent(active(cached,s).fields.tool.last.value.enchant)
    eq(active(cached,s).fields.tool.last.observedAt,160); eq(row(cached,s).cells[I.Enchant],"")
    eq(row(cached,s).gear.tool.state.fresh,true); eq(old.value.enchant.status,"unknown"); eq(old.observedAt,100)
    eq(calls,0); verifyRegistry()
end)
-- E05 amendment: regression first; same explicit-empty instance must preserve the
-- WHOLE prior unit, never a partial new/old metadata mixture, on unavailable reads.
for _,spec in ipairs({
    {name="stats error",status="error",change=function(env) env.C_Item.GetItemStats=function() error("E05 empty-link stats failure") end end},
    {name="quality nil",status="unknown",change=function(env) env.C_Item.GetItemQuality=function() return nil end end},
    {name="loading",status="unknown",change=function(_,s) s.loading=true end},
}) do
    local failure=spec
    case("E05 same explicit empty link preserves coherent absence on "..failure.name,function(checkpoint)
        local env,s,c=fixture(); eq(c:Scan(),true)
        local before=active(c,s); local old=before.fields.tool.last; local verify=unchangedGraph(before)
        eq(old.value.link,"item:95020::0:0"); eq(old.value.metadataReady,true); absent(old.value.enchant)
        eq(row(c,s).cells[I.Enchant],""); eq(row(c,s).gear.tool.state.fresh,true)
        pause(checkpoint,"E05 same empty-link retry "..failure.name)
        s.at=173; failure.change(env,s); eq(c:Scan(),true)
        local g=active(c,s); local f=g.fields.tool
        eq(f.attempt.status,failure.status); eq(f.attempt.attemptedAt,173); eq(g.scannedAt,173)
        eq(f.last.observedAt,100,"same valid-empty instance retains successful time on "..failure.name)
        local function same(a,b)
            eq(type(a),type(b)); if type(a)~="table" then eq(a,b); return end
            for key,value in pairs(a) do same(value,b[key]) end
            for key in pairs(b) do assert(a[key]~=nil,"no new last-snapshot field") end
        end
        same(f.last,old); eq(g.generation,before.generation)
        eq(f.last.value.slot,20); eq(f.last.value.itemID,95020); eq(f.last.value.link,old.value.link)
        eq(f.last.value.metadataReady,true); eq(f.last.value.rarity,2); eq(f.last.value.rank,3)
        eq(f.last.value.stats.ITEM_MOD_RESOURCEFULNESS_SHORT,53); absent(f.last.value.enchant)
        local r=row(c,s); eq(r.cells[I.Enchant],""); eq(r.enchantMissing,true)
        eq(r.gear.tool.state.fresh,false); eq(r.gear.tool.state.stale,true); eq(r.gear.tool.state.observedAt,100)
        eq(r.lastUpdated,"0s"); eq(C.Open(c.db),c.db); verify(); verifyRegistry()
    end)
end
case("E05 empty-link history cannot leak into changed item link slot missing or malformed instance",function(checkpoint)
    for _,change in ipairs({
        function(v) v.itemID=96020; v.link="item:96020::0:0" end,
        function(v) v.link="item:95020:0:0:0" end,
        function(v) v.slot=21 end,
        function(v) v.link="item:95020:garbage:0" end,
        function(v) v.link="item:95020:" end,
        function(v) v.link=nil end,
        function(v) v.exists=false; v.itemID=nil; v.link=nil end,
    }) do
        pause(checkpoint,"E05 empty-link identity negative seed")
        local env,s,c=fixture(); eq(c:Scan(),true)
        local ctx=assert(c:Context()); local old=active(c,s).fields.tool.last; local verify=unchangedGraph(old)
        -- Failed, partial unit from an independently unavailable read. Its identity
        -- must not inherit any old rank/stat/enchant even if some IDs match.
        local partial={slot=20,role="tool",exists=true,metadataReady=false,itemID=95020,link=old.value.link}
        change(partial)
        pause(checkpoint,"E05 empty-link identity negative apply")
        local g=assert(C.Apply(c.db,ctx.character,ctx.identity,
            {tool=C.Observation("unknown",partial,181,"E05 synthetic failed unit")},181,"E05 fixture"))
        local f=g.fields.tool; eq(f.attempt.status,"unknown"); eq(f.attempt.attemptedAt,181)
        eq(f.last.observedAt,181); eq(f.last.value.metadataReady,false)
        eq(f.last.value.enchant,nil); eq(f.last.value.stats,nil); eq(f.last.value.rank,nil); eq(f.last.value.rarity,nil)
        for key,value in pairs(partial) do eq(f.last.value[key],value) end
        s.at=181; local r=row(c,s); eq(r.gear.tool.state.fresh,false)
        eq(r.cells[I.Enchant],partial.exists and "?" or ""); assert(r.enchantMissing~=true)
        eq(C.Open(c.db),c.db); verify(); verifyRegistry()
    end
end)
end
-- E05 END

-- K08 BEGIN
do
local Check=NS.KnowledgeCheck
local identities={{2906,171,3},{2907,164,1},{2909,333,9},{2910,202,8},
    {2913,773,13},{2914,755,12},{2915,165,2},{2918,197,7}}
local PRIVATE="K08_PRIVATE_FAILURE_PAYLOAD"
local function fixture(id,shape,checkpoint)
    id=id or identities[3]
    local e,s,f,r=knowledgeFixture(shape or {3,2},checkpoint)
    s.info.professionID=id[1]; s.info.parentProfessionID=id[2]; s.info.profession=id[3]
    s.config=876543; s.ms=0; s.pathReads=0; s.entries=0; s.tabReads=0; s.chat={}
    e.GetProfessionInfo=function() return "Synthetic",0,0,100,0,0,id[2] end
    e.C_TradeSkillUI.GetBaseProfessionInfo=function() return {professionID=id[2]} end
    e.C_ProfSpecs.GetConfigIDForSkillLine=function(skill) eq(skill,s.info.professionID); return s.config end
    e.C_ProfSpecs.GetSpecTabIDsForSkillLine=function(skill)
        eq(skill,s.info.professionID); s.tabReads=s.tabReads+1
        local out={}; for i=#f.tabs,1,-1 do out[#out+1]=f.tabs[i].id end; return out
    end
    for _,key in ipairs({"GetNodeInfo","GetEntryInfo","GetNodeCost","GetTreeCurrencyInfo"}) do
        local original=e.C_Traits[key]
        e.C_Traits[key]=function(config,...)
            eq(config,s.config,"queried live config, not fixed observation")
            if key=="GetNodeInfo" then s.pathReads=s.pathReads+1 end
            if key=="GetEntryInfo" then s.entries=s.entries+1 end
            return original(1001,...)
        end
    end
    mockWidgets(e)
    e.debugprofilestop=function() return s.ms end
    e.DEFAULT_CHAT_FRAME={AddMessage=function(_,line) s.chat[#s.chat+1]=line end}
    local commands=NS.Commands.New(e); commands.collector=r
    commands.Login=function() error(PRIVATE.." Login") end
    return e,s,f,r,commands
end
local function tick(c)
    local frame=assert(c.knowledgeCaptureFrame)
    local fn=assert(frame.scripts.OnUpdate); fn(frame,0.016)
end
local function pump(c,checkpoint,phase)
    local n=0
    while c.knowledgeCapture and (not phase or c.knowledgeCapture.phase~=phase) do
        tick(c); n=n+1; assert(n<=10001,"driver bounded")
        if n%8==0 then pause(checkpoint,"K08 eight synthetic callbacks (one unit each)") end
    end
end
local function frozenRuntime(r)
    -- Native copy widgets/chat and synthetic clock/read counters are expected to
    -- change. Freeze every runtime edge and all reachable non-env production state.
    local edges,values={},{}
    for key,value in pairs(r) do edges[key]=value; if key~="env" then values[key]=value end end
    local verify=unchangedGraph({values,NS.Data,r.db})
    return function()
        for key,value in pairs(edges) do eq(r[key],value,"runtime edge "..key) end
        for key in pairs(r) do assert(edges[key]~=nil,"no new runtime field") end
        verify()
    end
end
local function retired(c,s,fn)
    eq(c.knowledgeCapture,nil); eq(c.knowledgeCaptureFrame,nil)
    for _,key in ipairs({"frame","runtime","guard","context","clock","dispose"}) do eq(s[key],nil,"released "..key) end
    local summary=c.knowledgeCaptureSummary; assert(summary)
    if fn then fn(); eq(c.knowledgeCaptureSummary,summary) end
end
-- Test-local factory interception, always restored BEFORE a pause/outer runner yield.
local function factories(capture,format,fn)
    local a,b=Check.NewProfessionCaptureJob,Check.NewFormatJob
    if capture then Check.NewProfessionCaptureJob=capture end
    if format then Check.NewFormatJob=format end
    local ok,why=pcall(fn)
    Check.NewProfessionCaptureJob=a; Check.NewFormatJob=b
    assert(ok,why)
end
local function fake(kind,work)
    return {status="running",completed=false,Step=function(j)
        if work then work(j) end
        if j.status=="running" then
            j.status="complete"; j.completed=true
            if kind=="capture" then j.report={tabs={},captureComplete=false}
            else j.text="Synthetic evidence"; j.summary={captureComplete=false} end
        end
    end,Cancel=function(j) j.cancelled=true; j.status="incomplete"; j.report=nil; j.text=nil; j.summary=nil end}
end
for _,id in ipairs(identities) do
    case("K08 exact crafting identity "..id[1].." live config native order complete guarded graph",function(checkpoint)
        local e,s,f,r=fixture(id,nil,checkpoint)
        local verify=unchangedGraph({r,NS.Data,e.CraftArmyDB})
        local job=Check.NewProfessionCaptureJob(e,r); eq(s.pathReads,0); eq(s.tabReads,0)
        local report=steppedJob(job,checkpoint).report
        eq(report.captureComplete,true); eq(report.captured,5); eq(s.entries,10)
        eq(report.start.skillLineID.value,id[1]); eq(report.start.parentID.value,id[2]); eq(report.start.profession.value,id[3])
        eq(report.start.configID.value,876543); eq(report.tabs[1].id,f.tabs[2].id); eq(report.tabs[2].id,f.tabs[1].id)
        eq(report.tabs[2].paths[2].node.isAvailable.value,false,"locked capacity is still counted")
        eq(report.candidate.capacity,150); eq(report.reconciliation.status,"provisional mismatch")
        eq(report.shared.id,3902); eq(report.shared.spent,264)
        eq(#report.tabs[2].currencies.items,11,"late shared currency retained")
        local formatted=steppedJob(Check.NewFormatJob(report),checkpoint)
        for _,secret in ipairs({"PRIVATE-GUID","PRIVATE-NAME","PRIVATE-REALM","PRIVATE-SAVED-DATA",PRIVATE,"|"}) do
            assert(not formatted.text:find(secret,1,true))
        end
        assert(formatted.text:find("UNVERIFIED",1,true)); verify()
    end)
end
case("K08 unsupported malformed parent family older gathering and caller overrides rejected legacy frozen",function(checkpoint)
    local variants={function(s) s.info.professionID=9999 end,function(s) s.info.parentProfessionID=999 end,
        function(s) s.info.profession=13 end,function(s) s.info.profession=4 end,
        function(s) s.info.professionID=2823 end,function(s) s.info.professionID="2909" end,
        function(s) s.info.professionID=nil end,function(s) s.info=false end}
    for _,change in ipairs(variants) do
        pause(checkpoint,"K08 rejected identity")
        local e,s,_,r=fixture(); change(s)
        incomplete(steppedJob(Check.NewProfessionCaptureJob(e,r),checkpoint).report); eq(s.pathReads,0)
    end
    for _,id in ipairs(identities) do
        local e,s,_,r=fixture(id)
        local report=steppedJob(Check.NewCaptureJob(e,r),checkpoint).report
        eq(report.captureComplete,id[1]==2913); if id[1]~=2913 then eq(s.pathReads,0) end
    end
    for _,options in ipairs({{config=1},{identity={}},{tabs={}},{currency=1},{mode=true},{stepLimit=10001}}) do
        local e,s,_,r=fixture(); local job=Check.NewProfessionCaptureJob(e,r,options)
        eq(job.status,"incomplete"); eq(job.worker,nil); eq(s.pathReads,0)
    end
    local e,_,_,r=fixture(); local job=Check.NewProfessionCaptureJob(e,r,{stepLimit=1})
    job:Step(); job:Step(); eq(job.status,"incomplete"); eq(job.report,nil)
end)
case("K08 all-crafting metadata errors duplicates staged and currency guards not weakened",function(checkpoint)
    local variants={
        function(e) e.C_Traits.GetEntryInfo=nil end,
        function(e) e.C_Traits.GetNodeCost=function() error(PRIVATE) end end,
        function(_,s) s.staged=true end,
        function(e,_,f) local id=f.tabs[1].root; f.children[id]={id+1,id+1} end,
        function(_,_,f) local row=f.currencies[f.tabs[1].id]; row[#row+1]=row[#row] end,
        function(_,_,f) f.nodes[f.tabs[1].root].entryIDs={1,1} end,
    }
    for _,change in ipairs(variants) do
        pause(checkpoint,"K08 evidence guard")
        local e,s,f,r=fixture(); change(e,s,f)
        local report=steppedJob(Check.NewProfessionCaptureJob(e,r),checkpoint).report
        eq(report.reconciliation.status,"unknown"); eq(report.shared,nil)
        local text=steppedJob(Check.NewFormatJob(report),checkpoint).text
        assert(not text:find(PRIVATE,1,true)); assert(not text:find("provisional match",1,true))
    end
    local e,_,f,r=fixture(); local rows=f.currencies[f.tabs[1].id]; rows[#rows].spent=8
    local report=steppedJob(Check.NewProfessionCaptureJob(e,r),checkpoint).report
    eq(report.captureComplete,true); eq(report.reconciliation.status,"unknown"); eq(report.shared,nil)
end)
case("K08 slash does no Step or traversal one unit per capture format frame and publication gap",function(checkpoint)
    local e,s,_,r,c=fixture(); local verify=frozenRuntime(r)
    local units={capture=0,format=0}; local originalCapture,originalFormat=Check.NewProfessionCaptureJob,Check.NewFormatJob
    factories(function(...)
        local j=originalCapture(...); local step=j.Step
        j.Step=function(self) units.capture=units.capture+1; return step(self) end; return j
    end,function(...)
        local j=originalFormat(...); local step=j.Step
        j.Step=function(self) units.format=units.format+1; return step(self) end; return j
    end,function()
        local session=c:Run(" knowledgecapture "); assert(session)
        eq(units.capture,0); eq(units.format,0); eq(s.pathReads,0); eq(s.tabReads,0)
        eq(c:Run("knowledgecapture"),session); eq(c:Run("knowledgecapture status"),session)
        while c.knowledgeCapture do
            local before=units.capture+units.format; local phase=session.phase
            tick(c); local delta=units.capture+units.format-before
            eq(delta,phase=="publish" and 0 or 1,"one job Step only")
            if phase=="capture" and session.phase=="format" then eq(units.format,0); eq(c.knowledgeCaptureReport,nil) end
            if session.phase=="publish" then eq(c.knowledgeCaptureReport,nil); eq(c.knowledgeCaptureWindow,nil) end
        end
        assert(units.capture>10 and units.format>5); retired(c,session)
    end)
    eq(c.knowledgeCaptureSummary.completed,true); eq(c.knowledgeCaptureSummary.captureComplete,true)
    eq(c.knowledgeText,nil); eq(c.knowledgeWindow,nil); verify(); eq(#s.timers,0); eq(s.requests,0)
    pause(checkpoint,"K08 factories restored")
end)
case("K08 explicit cancel terminal references stale callback restart no automatic resume",function(checkpoint)
    local _,s,_,_,c=fixture(); local session=c:Run("knowledgecapture")
    local stale=c.knowledgeCaptureFrame.scripts.OnUpdate; tick(c); c:Run("knowledgecapture cancel")
    retired(c,session,stale); eq(c.knowledgeCaptureSummary.completed,false); eq(s.pathReads,0)
    c:Run("knowledgecapture status"); c:Run("knowledgecapture nonsense"); eq(c.knowledgeCapture,nil)
    local nextSession=c:Run("knowledgecapture"); assert(nextSession~=session)
    pump(c,checkpoint); eq(c.knowledgeCaptureSummary.completed,true)
    c:Run("knowledgecapture cancel"); eq(c.knowledgeCapture,nil)
end)
case("K08 missing pending malformed runtime unknown arguments never Login scan or DB validation",function(checkpoint)
    local variants={function(_,_,_,c) c.collector=nil end,function(_,_,r) r.scheduled=true end,
        function(_,_,r) r.deferred=true end,function(_,_,r) r.revision=nil end,
        function(_,_,r) r.serial=1.5 end,function(e) e.CreateFrame=nil end,
        function(e) e.debugprofilestop=nil end,function(_,s) s.staged=true end}
    for _,change in ipairs(variants) do
        pause(checkpoint,"K08 start refusal")
        local e,s,_,r,c=fixture(); change(e,s,r,c)
        local verify=unchangedGraph(r)
        eq(c:Run("knowledgecapture"),nil); eq(c.knowledgeCapture,nil); eq(s.pathReads,0); eq(s.tabReads,0); verify()
        eq(c:Run("knowledgecapture start"),nil); eq(c:Run("knowledgecapture status extra"),nil)
        eq(#s.timers,0); eq(s.requests,0)
    end
end)
case("K08 data-incomplete evidence report can finish scheduler without passing accounting",function(checkpoint)
    local e,_,_,_,c=fixture(); e.C_Traits.GetEntryInfo=nil
    assert(c:Run("knowledgecapture")); pump(c,checkpoint)
    eq(c.knowledgeCaptureSummary.completed,true); eq(c.knowledgeCaptureSummary.captureComplete,false)
    eq(c.knowledgeCaptureReport.captureComplete,false); assert(c.knowledgeCaptureWindow)
    assert(c.knowledgeCaptureText:find("captureComplete=false",1,true))
    eq(c.knowledgeCaptureReport.reconciliation.status,"unknown")
end)
local drifts={
    {"revision",function(_,_,r) r.revision=r.revision+1 end},
    {"serial",function(_,_,r) r.serial=r.serial+1 end},
    {"object",function(_,_,r,c) local new={}; for k,v in pairs(r) do new[k]=v end; c.collector=new end},
    {"config",function(_,s) s.config=s.config+1 end},
    {"source",function(_,s) s.info.sourceCounter=2 end},
    {"character",function(e) e.UnitGUID=function() return "OTHER-PRIVATE-GUID" end end},
    {"name",function(e) e.UnitName=function() return "OTHER-PRIVATE-NAME" end end},
    {"realm",function(e) e.GetRealmName=function() return "OTHER-PRIVATE-REALM" end end},
    {"profession",function(_,s) s.info.professionID=2913 end},
    {"closed",function(_,s) s.shown=false end}, {"linked",function(_,s) s.linked=true end},
    {"guild",function(_,s) s.guild=true end}, {"guildmember",function(e) e.C_TradeSkillUI.IsTradeSkillGuildMember=function() return true end end},
    {"npc",function(_,s) s.npc=true end}, {"unready",function(_,s) s.ready=false end},
    {"changing",function(_,s) s.changing=true end}, {"staged",function(_,s) s.staged=true end},
    {"unknownstage",function(_,s) s.staged=nil end}, {"unknowncombat",function(_,s) s.combat=nil end},
    {"combat",function(_,s) s.combat=true end}, {"scheduled",function(_,_,r) r.scheduled=true end},
    {"deferred",function(_,_,r) r.deferred=true end},
}
case("K08 every context and runtime drift stops BEFORE next path work no private payload",function(checkpoint)
    for _,variant in ipairs(drifts) do
        pause(checkpoint,"K08 drift "..variant[1])
        local e,s,_,r,c=fixture(); local session=c:Run("knowledgecapture"); tick(c); tick(c)
        local before=s.pathReads; variant[2](e,s,r,c); tick(c)
        eq(s.pathReads,before,variant[1]); retired(c,session); eq(c.knowledgeCaptureSummary.completed,false)
        eq(c.knowledgeCaptureWindow,nil); eq(c.knowledgeCaptureReport,nil)
        assert(not table.concat(s.chat):find("PRIVATE",1,true)); eq(#s.timers,0)
    end
end)
case("K08 guard remains live throughout format and completed format to UI frame gap",function(checkpoint)
    for _,phase in ipairs({"format","publish"}) do
        for _,variant in ipairs(drifts) do
            pause(checkpoint,"K08 "..phase.." drift "..variant[1])
            local e,s,_,r,c=fixture(); local session=c:Run("knowledgecapture"); pump(c,checkpoint,phase)
            eq(session.phase,phase); local before=s.pathReads; local widgets=#e.fixtureWidgets
            variant[2](e,s,r,c); tick(c)
            eq(s.pathReads,before); eq(#e.fixtureWidgets,widgets,"no copy UI after failed guard")
            retired(c,session); eq(c.knowledgeCaptureReport,nil); eq(c.knowledgeCaptureSummary.completed,false)
        end
    end
end)
case("K08 post-Step drift inside final capture and final format unit cannot publish",function(checkpoint)
    for _,phase in ipairs({"capture","format"}) do
        local e,s,_,r,c=fixture(); local original=phase=="capture" and Check.NewProfessionCaptureJob or Check.NewFormatJob
        local function wrapped(...)
            local j=original(...); local step=j.Step
            j.Step=function(self) step(self); if self.status=="complete" then r.serial=r.serial+1 end end
            return j
        end
        factories(phase=="capture" and wrapped or nil,phase=="format" and wrapped or nil,function()
            local session=c:Run("knowledgecapture"); pump(c)
            retired(c,session); eq(c.knowledgeCaptureSummary.completed,false); eq(c.knowledgeCaptureReport,nil)
        end)
        pause(checkpoint,"K08 final drift factories restored")
    end
end)
case("K08 ANY event retires capture BEFORE preserved normal processing explicit scan too",function(checkpoint)
    local events={"UNREGISTERED_TEST_EVENT"}; for _,event in ipairs(NS.Collectors.events) do events[#events+1]=event end
    for _,event in ipairs(events) do
        pause(checkpoint,"K08 event "..event)
        local _,_,_,r,c=fixture(); local session=c:Run("knowledgecapture"); local calls=0
        local function normal() eq(c.knowledgeCapture,nil); calls=calls+1 end
        c.Login=normal; r.Request=normal; r.ItemResult=normal; r.Invalidate=normal
        c.dashboard={Refresh=normal}
        c:Event(event,123,true); assert(calls>0); retired(c,session)
    end
    local _,_,_,r,c=fixture(); local session=c:Run("knowledgecapture"); local scanned=false
    c.Login=function() eq(c.knowledgeCapture,nil) end
    r.Scan=function() eq(c.knowledgeCapture,nil); scanned=true end
    c:Run("scan"); eq(scanned,true); retired(c,session)
end)
case("K08 selftest and legacy mutual exclusion new command separately advertised",function(checkpoint)
    local e,_,_,_,c=fixture(); local session=c:Run("knowledgecapture")
    eq(c:Run("selftest"),nil); eq(c.selftest,nil); eq(c:Run("knowledgecheck"),nil); eq(c.knowledgeCapture,session)
    c:Run("knowledgecapture cancel")
    c.selftest={sentinel=true}; eq(c:Run("knowledgecapture"),nil); eq(c.selftest.sentinel,true); c.selftest=nil
    local help={}; e.DEFAULT_CHAT_FRAME.AddMessage=function(_,line) help[#help+1]=line end
    c.Login=function() end; c:Run("help")
    local text=table.concat(help); assert(text:find("/ca knowledgecapture",1,true)); assert(text:find("Inscription",1,true))
    pause(checkpoint,"K08 conflict cleanup")
end)
case("K08 clocks absent throwing nonfinite backward and seconds fallback explicit100ms boundary",function(checkpoint)
    for _,bad in ipairs({function() error(PRIVATE) end,function() return math.huge end,function() return 0/0 end}) do
        local e,_,_,_,c=fixture(); e.debugprofilestop=bad; eq(c:Run("knowledgecapture"),nil)
        pause(checkpoint,"K08 invalid start clock")
    end
    for _,bad in ipairs({function() error(PRIVATE) end,function() return math.huge end,function() return -1 end}) do
        local e,_,_,_,c=fixture(); local session=c:Run("knowledgecapture"); e.debugprofilestop=bad
        -- The session retains its clock function: redirect the fixture's private clock source instead.
        session.clock=bad; tick(c); retired(c,session); eq(c.knowledgeCaptureSummary.completed,false)
    end
    local e,s,_,_,c=fixture(); e.debugprofilestop=nil; e.GetTimePreciseSec=function() return s.ms/1000 end
    assert(c:Run("knowledgecapture")); pump(c,checkpoint); eq(c.knowledgeCaptureSummary.completed,true)
    local e2,s2,_,_,c2=fixture(); local original=Check.NewProfessionCaptureJob
    factories(function(...)
        local j=original(...); local step=j.Step
        j.Step=function(self) step(self); s2.ms=s2.ms+100 end; return j
    end,nil,function() assert(c2:Run("knowledgecapture")); pump(c2); eq(c2.knowledgeCaptureSummary.completed,true); eq(c2.knowledgeCaptureSummary.maxCallback,100) end)
end)
case("K08 slow first final capture final format and copy publication are INCOMPLETE old success retained",function(checkpoint)
    for _,phase in ipairs({"first","capture","format","publish"}) do
        pause(checkpoint,"K08 slow "..phase)
        local e,s,_,_,c=fixture(); assert(c:Run("knowledgecapture")); pump(c,checkpoint)
        local oldReport,oldText,oldWindow=c.knowledgeCaptureReport,c.knowledgeCaptureText,c.knowledgeCaptureWindow
        local original=phase=="format" and Check.NewFormatJob or Check.NewProfessionCaptureJob
        local function wrapped(...)
            local j=original(...); local step=j.Step; local count=0
            j.Step=function(self)
                step(self); count=count+1
                if (phase=="first" and count==1) or (phase~="first" and self.status=="complete") then s.ms=s.ms+101 end
            end; return j
        end
        if phase=="publish" then
            local set=oldWindow.edit.SetText
            oldWindow.edit.SetText=function(self,...) s.ms=s.ms+101; return set(self,...) end
        end
        factories((phase=="first" or phase=="capture") and wrapped or nil,phase=="format" and wrapped or nil,function()
            local session=c:Run("knowledgecapture"); eq(oldWindow.frame.shown,false); pump(c)
            retired(c,session); eq(c.knowledgeCaptureSummary.completed,false); assert(c.knowledgeCaptureSummary.reason:find("slow",1,true))
            eq(c.knowledgeCaptureReport,oldReport); eq(c.knowledgeCaptureText,oldText); eq(c.knowledgeCaptureWindow,oldWindow); eq(oldWindow.frame.shown,false)
        end)
    end
end)
case("K0810000 total callbacks cap across capture and format never implicit success",function(checkpoint)
    local _,_,_,_,c=fixture(); local count=0; local a,b
    factories(function()
        a=fake("capture",function(j) count=count+1; if count<5000 then j.status="waiting" end end)
        local step=a.Step; a.Step=function(j) j.status="running"; step(j); if j.status=="waiting" then j.status="running" end end
        return a
    end,function()
        b={status="running",completed=false,Step=function() count=count+1 end,Cancel=function(j) j.cancelled=true end}; return b
    end,function()
        local session=c:Run("knowledgecapture"); pump(c)
        retired(c,session); eq(count,10000); eq(c.knowledgeCaptureSummary.callbacks,10000)
        eq(c.knowledgeCaptureSummary.completed,false); assert(c.knowledgeCaptureSummary.reason:find("10000",1,true)); eq(b.cancelled,true)
    end)
    pause(checkpoint,"K08 callback cap factories restored")
end)
case("K08 factory Step frame chat UI failures sanitized terminal cleanup even throwing native cleanup",function(checkpoint)
    for _,kind in ipairs({"factory","Step","formatFactory","frame","chat","UI","cleanup"}) do
        pause(checkpoint,"K08 exception "..kind)
        local e,s,_,_,c=fixture(); local original=Check.NewProfessionCaptureJob
        local function wrapped(...)
            if kind=="factory" then error(PRIVATE) end
            local j=original(...)
            if kind=="Step" then j.Step=function() error(PRIVATE) end end
            return j
        end
        if kind=="frame" then e.CreateFrame=function() error(PRIVATE) end end
        if kind=="chat" then e.DEFAULT_CHAT_FRAME.AddMessage=function() error(PRIVATE) end end
        factories(wrapped,kind=="formatFactory" and function() error(PRIVATE) end or nil,function()
            local session=c:Run("knowledgecapture")
            if kind=="UI" then
                pump(c,nil,"publish"); e.CreateFrame=function() error(PRIVATE) end
            end
            if kind=="cleanup" then
                local frame=c.knowledgeCaptureFrame; local stale=frame.scripts.OnUpdate
                frame.SetScript=function() error(PRIVATE) end; frame.Hide=function() error(PRIVATE) end
                c:Run("knowledgecapture cancel"); retired(c,session,stale)
            else pump(c); if session then retired(c,session) end end
            eq(c.knowledgeCaptureSummary.completed,false); eq(c.knowledgeCaptureReport,nil)
            assert(not table.concat(s.chat):find(PRIVATE,1,true))
        end)
    end
end)
case("K08 final publication guard and UI failure preserves last success hidden not current",function(checkpoint)
    for _,mode in ipairs({"drift","throw","combat","cancel"}) do
        pause(checkpoint,"K08 UI "..mode)
        local e,s,_,r,c=fixture(); assert(c:Run("knowledgecapture")); pump(c,checkpoint)
        local report,text,window=c.knowledgeCaptureReport,c.knowledgeCaptureText,c.knowledgeCaptureWindow
        local session=c:Run("knowledgecapture"); pump(c,checkpoint,"publish")
        local set=window.edit.SetText
        window.edit.SetText=function(self,...)
            if mode=="drift" then r.serial=r.serial+1
            elseif mode=="throw" then error(PRIVATE)
            elseif mode=="combat" then s.combat=true
            else c:Run("knowledgecapture cancel") end
            return set(self,...)
        end
        tick(c); retired(c,session)
        eq(c.knowledgeCaptureSummary.completed,false); eq(c.knowledgeCaptureReport,report)
        eq(c.knowledgeCaptureText,text); eq(c.knowledgeCaptureWindow,window); eq(window.frame.shown,false)
    end
end)
case("K08 successful replacement window reused copy immutable close escape no saved data changes",function(checkpoint)
    local e,s,_,r,c=fixture(); local verify=frozenRuntime(r)
    assert(c:Run("knowledgecapture")); pump(c,checkpoint)
    local old=c.knowledgeCaptureReport; local window=c.knowledgeCaptureWindow
    window.edit:SetText("attempted edit"); eq(window.edit:GetText(),c.knowledgeCaptureText)
    window.close.scripts.OnClick(); eq(window.frame.shown,false); eq(window.edit.focused,false)
    assert(c:Run("knowledgecapture")); pump(c,checkpoint)
    eq(c.knowledgeCaptureWindow,window); assert(c.knowledgeCaptureReport~=old); eq(window.frame.shown,true)
    window.edit.scripts.OnEscapePressed(); eq(window.frame.shown,false); eq(window.edit.focused,false)
    verify(); eq(#s.timers,0); eq(s.requests,0)
end)
case("K08 actual new graph truncation cannot advertise passing totals full workload retained",function(checkpoint)
    local outer,units=checkpoint,0
    checkpoint=function(label)
        units=units+1
        if units%8==0 then pause(outer,"K08 eight bounded fixture units: "..label) end
    end
    local e,_,_,r=fixture(nil,{64,64,64,64,64,64,64,64},checkpoint)
    local report=steppedJob(Check.NewProfessionCaptureJob(e,r),checkpoint).report
    eq(report.captured,512); incomplete(report); eq(report.outputTruncated,true)
    local output=steppedJob(Check.NewFormatJob(report),checkpoint)
    eq(output.summary.captureComplete,false); eq(output.summary.reconciliation.status,"unknown")
    assert(#output.text<=262144); assert(output.text:find("version1 END",1,true))
    assert(not output.text:find("provisional match",1,true))
    local malformed={tabs={},captureComplete=true,reconciliation={status="provisional match"},sourcePin={}}
    for n=1,129 do malformed.sourcePin[n]=n end
    local output2=steppedJob(Check.NewFormatJob(malformed),checkpoint)
    eq(output2.summary.captureComplete,false); eq(output2.summary.reconciliation.status,"unknown")
end)
case("K08 whole callback guard factory and publication clock work measured not Step alone",function(checkpoint)
    for _,part in ipairs({"guard","phaseFactory","publicationClock"}) do
        pause(checkpoint,"K08 whole callback "..part)
        local e,s,_,_,c=fixture(); local original=Check.NewFormatJob
        factories(nil,part=="phaseFactory" and function(...) s.ms=s.ms+101; return original(...) end or nil,function()
            local session=c:Run("knowledgecapture")
            if part=="guard" then
                local base=e.C_TradeSkillUI.GetBaseProfessionInfo
                e.C_TradeSkillUI.GetBaseProfessionInfo=function() s.ms=s.ms+101; return base() end
            elseif part=="publicationClock" then
                pump(c,nil,"publish")
                session.clock=function() error(PRIVATE) end
            end
            pump(c); retired(c,session); eq(c.knowledgeCaptureSummary.completed,false); eq(c.knowledgeCaptureReport,nil)
        end)
    end
end)
case("K08 failed retry factory Step and final chat retain old success without stale visible report",function(checkpoint)
    for _,mode in ipairs({"factory","Step","finalChat"}) do
        pause(checkpoint,"K08 retry "..mode)
        local e,s,_,_,c=fixture(); assert(c:Run("knowledgecapture")); pump(c,checkpoint)
        local report,text,window=c.knowledgeCaptureReport,c.knowledgeCaptureText,c.knowledgeCaptureWindow
        local original=Check.NewProfessionCaptureJob
        factories(function(...)
            if mode=="factory" then error(PRIVATE) end
            local job=original(...); if mode=="Step" then job.Step=function() error(PRIVATE) end end
            return job
        end,nil,function()
            local session=c:Run("knowledgecapture")
            if mode=="finalChat" then
                pump(c,nil,"publish"); e.DEFAULT_CHAT_FRAME.AddMessage=function() error(PRIVATE) end
            end
            pump(c); if session then retired(c,session) end
            eq(c.knowledgeCaptureSummary.completed,false); eq(c.knowledgeCaptureReport,report)
            eq(c.knowledgeCaptureText,text); eq(c.knowledgeCaptureWindow,window); eq(window.frame.shown,false)
            assert(not table.concat(s.chat):find(PRIVATE,1,true))
        end)
    end
end)
case("K08 unknown safety source counter and staging read errors refuse before traversal",function(checkpoint)
    local variants={function(e) e.InCombatLockdown=nil end,function(e) e.InCombatLockdown=function() error(PRIVATE) end end,
        function(e) e.C_Traits.ConfigHasStagedChanges=function() error(PRIVATE) end end,
        function(_,s) s.info.sourceCounter=nil end,function(_,s) s.info.sourceCounter=1.5 end,
        function(_,s) s.config=math.huge end,function(e) e.C_TradeSkillUI.GetChildProfessionInfo=function() error(PRIVATE) end end}
    for _,change in ipairs(variants) do
        pause(checkpoint,"K08 malformed attribution")
        local e,s,_,_,c=fixture(); change(e,s); eq(c:Run("knowledgecapture"),nil)
        eq(s.pathReads,0); eq(s.tabReads,0); eq(c.knowledgeCaptureFrame,nil)
        assert(not table.concat(s.chat):find(PRIVATE,1,true))
    end
end)
case("K08 reentrant frame setup still never Steps on slash stack and100ms publication accepted",function(checkpoint)
    local e,s,_,_,c=fixture(); local create=e.CreateFrame
    e.CreateFrame=function(...)
        local frame=create(...); local set,show=frame.SetScript,frame.Show
        frame.SetScript=function(self,event,fn)
            set(self,event,fn); if event=="OnUpdate" and fn then fn(self,0) end
        end
        frame.Show=function(self)
            if self.scripts.OnUpdate then self.scripts.OnUpdate(self,0) end
            return show(self)
        end
        return frame
    end
    local session=c:Run("knowledgecapture"); eq(session.callbacks,0); eq(s.pathReads,0); eq(s.tabReads,0)
    pump(c,checkpoint,"publish")
    local create2=e.CreateFrame
    e.CreateFrame=function(...)
        local frame=create2(...)
        if frame.template=="BasicFrameTemplateWithInset" then
            local show=frame.Show; frame.Show=function(self) s.ms=s.ms+100; return show(self) end
        end
        return frame
    end
    tick(c); retired(c,session); eq(c.knowledgeCaptureSummary.completed,true); eq(c.knowledgeCaptureSummary.maxCallback,100)
end)
case("K08 final clock reentry cancellation event or runtime drift cannot replace old success",function(checkpoint)
    for _,mode in ipairs({"cancel","event","serial"}) do
        pause(checkpoint,"K08 final clock "..mode)
        local _,s,_,r,c=fixture(); assert(c:Run("knowledgecapture")); pump(c,checkpoint)
        local report,text,window=c.knowledgeCaptureReport,c.knowledgeCaptureText,c.knowledgeCaptureWindow
        local session=c:Run("knowledgecapture"); pump(c,checkpoint,"publish"); local calls=0
        session.clock=function()
            calls=calls+1
            if calls==2 then
                if mode=="cancel" then c:Run("knowledgecapture cancel")
                elseif mode=="event" then
                    r.Request=function() eq(c.knowledgeCapture,nil) end; c:Event("K08_CLOCK_EVENT")
                else r.serial=r.serial+1 end
            end
            return s.ms
        end
        tick(c); retired(c,session); eq(c.knowledgeCaptureSummary.completed,false)
        eq(c.knowledgeCaptureReport,report); eq(c.knowledgeCaptureText,text)
        eq(c.knowledgeCaptureWindow,window); eq(window.frame.shown,false)
    end
end)
case("K08 frozen production Core Knowledge Collectors reject non-Inscription raw and numbers",function(checkpoint)
    local e,s,f,r=fixture(nil,nil,checkpoint)
    local verify=unchangedGraph(NS.Data)
    e.C_TradeSkillUI.GetProfessionSlots=function(id) eq(id,9); return {} end
    e.C_TradeSkillUI.GetConcentrationCurrencyID=function() return nil end
    e.C_CurrencyInfo.GetCurrencyInfo=function() return {quantity=0} end
    local collector=NS.Collectors.New(e,{schema=1,characters={}})
    eq(collector:Scan(),true)
    local generation=collector.db.characters["Player-PRIVATE-GUID"].professions[2909].active
    eq(generation.fields.knowledgeRaw.last,nil); eq(generation.fields.knowledgeRaw.attempt.status,"unknown")
    local _,_,_,r2=k2Fixture(); local target=C.Copy(k2Raw(r2))
    target.identity={skillLineID=2909,parentID=333,profession=9,expansionID=11}
    local numeric=K.Evaluate(target); eq(numeric.complete,false)
    eq(C.ValidPayload("knowledgeRaw",target,"observed"),false)
    local db={schema=1,characters={}}
    local observed=C.Observation("observed",target,100,"K08 synthetic rejection")
    eq(C.Apply(db,character,target.identity,{knowledgeRaw=observed},100,"K08 fixture"),nil)
    eq(next(db.characters),nil)
    local report=steppedJob(Check.NewProfessionCaptureJob(e,r),checkpoint).report
    eq(report.captureComplete,true); verify(); eq(#s.timers,0)
end)
end
-- K08 END

-- K09 BEGIN
do
local V,D=NS.ViewModel,NS.Data
-- Q03 full build70783 projections: all193 paths, native tab/child order, entry
-- IDs, ranks/caps, current costs and complete auxiliary currency rows. These are
-- observations, NOT production defaults. Branch labels, definitionIDs, configs,
-- GUIDs and all explicitly varied states below are SYNTHETIC fixture plumbing.
-- Row: tab path children unlock spend purchased/max currentCost; unlockmax=1.
local specs={
{2909,333,9,4056,443,27,{83,120,120,120},{270,140,120,120},4055,
{"Elevating Equipment","Transitories, Tonics, and Tools","Disenchanting Delegate","Spellbound Shatterer"},[[
1155 107769 107768,107764,107760 133105 133092 31/31 4056
1155 107768 107767,107766,107765 133104 133084 21/21 4056
1155 107764 107763,107762,107761 133100 133060 19/21 4056
1155 107760 107759,107758,107757 133096 133036 16/21 4056
1155 107767 - 133103 133078 1/21 4056
1155 107766 - 133102 133072 1/21 4056
1155 107765 - 133101 133066 1/21 4056
1155 107763 - 133099 133054 1/21 4056
1155 107762 - 133098 133048 1/21 4056
1155 107761 - 133097 133042 0/21 4078
1155 107759 - 133095 133030 1/21 4056
1155 107758 - 133094 133024 1/21 4056
1155 107757 - 133093 133018 0/21 4074
1154 107689 107688,107687,107684 133012 133006 31/31 4056
1154 107688 - 133011 132998 1/21 4056
1154 107687 107686,107685 133010 132992 21/21 4056
1154 107684 - 133007 132974 31/31 4056
1154 107686 - 133009 132986 21/21 4056
1154 107685 - 133008 132980 21/21 4056
1153 107649 107648,107647,107646 132966 132962 31/31 4056
1153 107648 - 132965 132954 31/31 4056
1153 107647 - 132964 132946 31/31 4056
1153 107646 - 132963 132938 31/31 4056
1152 107617 107616,107615,107614 132930 132926 31/31 4056
1152 107616 - 132929 132918 31/31 4056
1152 107615 - 132928 132910 31/31 4056
1152 107614 - 132927 132902 31/31 4056
]],[[
1155 4083:0/3/3,4082:0/3/3,4081:0/0/0,4080:0/0/0,4079:0/0/0,4078:0/2/2,4077:0/0/0,4076:0/0/0,4075:0/0/0,4074:0/2/2,4073:0/0/0,4072:0/0/0,4071:0/0/0
1154 4070:0/3/3,4069:0/0/0,4068:0/2/2,4067:0/0/0,4066:0/0/0,4065:0/0/0
1153 4064:0/3/3,4063:0/0/0,4062:0/0/0,4061:0/0/0
1152 4060:0/3/3,4059:0/0/0,4058:0/0/0,4057:0/0/0
]]},
{2906,171,3,4030,401,22,{170,141,90,0},{170,170,90,90},4031,
{"Potion Prowess","Fluent in Flasks","Alchemical Mastery","Transmutation Authority"},[[
1140 107107 107106,107103 131980 131973 31/31 4030
1140 107106 107105,107104 131979 131965 31/31 4030
1140 107103 107102,107101 131976 131945 31/31 4030
1140 107105 - 131978 131957 21/21 4030
1140 107104 - 131977 131951 21/21 4030
1140 107102 - 131975 131937 21/21 4030
1140 107101 - 131974 131931 21/21 4030
1142 107214 107213,107210 132109 132102 31/31 4030
1142 107213 107212,107211 132108 132094 31/31 4030
1142 107210 107209,107208 132105 132074 22/31 4030
1142 107212 - 132107 132086 21/21 4030
1142 107211 - 132106 132080 21/21 4030
1142 107209 - 132104 132066 0/21 4042
1142 107208 - 132103 132060 21/21 4030
1144 107284 107283,107282,107281 132187 132183 31/31 4030
1144 107283 - 132186 132175 21/21 4030
1144 107282 - 132185 132169 21/21 4030
1144 107281 - 132184 132163 21/21 4030
1143 107257 107256,107255,107254 132156 132152 1/31 4030
1143 107256 - 132155 132144 0/21 4050
1143 107255 - 132154 132138 0/21 4050
1143 107254 - 132153 132132 0/21 4050
]],[[
1140 4038:0/2/2,4037:0/2/2,4036:0/0/0,4035:0/0/0,4034:0/2/2,4033:0/0/0,4032:0/0/0
1142 4046:0/2/2,4045:0/2/2,4044:0/0/0,4043:0/0/0,4042:0/1/1,4041:0/0/0,4040:0/0/0
1144 4054:0/3/3,4053:0/0/0,4052:0/0/0,4051:0/0/0
1143 4050:0/0/0,4049:0/0/0,4048:0/0/0,4047:0/0/0
]]},
{2907,164,1,3750,293,30,{80,33,0,180},{105,120,345,205},3751,
{"Craftsmithing","The Old Ways","Armorsmithing","Weaponsmithing"},[[
1068 104258 104257,104256,104255 128862 128858 31/31 3750
1068 104257 - 128861 128850 26/26 3750
1068 104256 - 128860 128843 26/26 3750
1068 104255 - 128859 128836 1/26 3750
1069 104292 104291,104290,104289,104288 128901 128896 34/41 3750
1069 104291 - 128900 128886 1/21 3750
1069 104290 - 128899 128880 1/21 3750
1069 104289 - 128898 128874 1/21 3750
1069 104288 - 128897 128868 1/21 3750
1075 104576 104575,104571,104567 129221 129208 1/31 3750
1075 104575 104574,104573,104572 129220 129200 0/31 3803
1075 104571 104570,104569,104568 129216 129171 0/31 3803
1075 104567 104566,104565,104564 129212 129142 1/31 3750
1075 104574 - 129219 129192 0/26 3802
1075 104573 - 129218 129185 0/26 3802
1075 104572 - 129217 129178 0/26 3802
1075 104570 - 129215 129163 0/26 3798
1075 104569 - 129214 129156 0/26 3798
1075 104568 - 129213 129149 0/26 3798
1075 104566 - 129211 129134 0/26 3794
1075 104565 - 129210 129127 1/26 3750
1075 104564 - 129209 129120 0/26 3794
1076 104633 104632,104629,104626 129286 129278 31/31 3750
1076 104632 104631,104630 129285 129270 26/26 3750
1076 104629 104628,104627 129282 129249 26/26 3750
1076 104626 - 129279 129228 1/26 3750
1076 104631 - 129284 129263 26/26 3750
1076 104630 - 129283 129256 26/26 3750
1076 104628 - 129281 129242 26/26 3750
1076 104627 - 129280 129235 26/26 3750
]],[[
1068 3759:0/3/3,3758:0/0/0,3757:0/0/0,3756:0/0/0
1069 3764:0/4/4,3763:0/0/0,3762:0/0/0,3761:0/0/0,3760:0/0/0
1075 3803:0/1/1,3802:0/0/0,3801:0/0/0,3800:0/0/0,3799:0/0/0,3798:0/0/0,3797:0/0/0,3796:0/0/0,3795:0/0/0,3794:0/1/1,3793:0/0/0,3792:0/0/0,3791:0/0/0
1076 3811:0/3/3,3810:0/2/2,3809:0/0/0,3808:0/0/0,3807:1/2/3,3806:0/0/0,3805:0/0/0,3804:0/0/0
]]},
{2914,755,12,3989,223,35,{73,0,150,0},{120,310,150,194},3990,
{"Thoughtful Throughput","Glamorous Gems","Alluring Accessories","Proficient Processor"},[[
1138 107015 107014,107013,107012 131877 131873 31/31 3989
1138 107014 - 131876 131865 31/31 3989
1138 107013 - 131875 131857 14/31 3989
1138 107012 - 131874 131849 1/31 3989
1136 106901 106900,106896,106891,106887 131749 131731 1/31 3989
1136 106900 106899,106898,106897 131748 131723 0/26 4008
1136 106896 106895,106894,106893 131744 131701 0/26 4008
1136 106891 106890,106889,106888 131739 131669 0/26 4008
1136 106887 106886,106885,106884 131735 131647 0/26 4008
1136 106899 - 131747 131716 0/16 4007
1136 106898 - 131746 131711 0/16 4007
1136 106897 - 131745 131706 0/16 4007
1136 106895 - 131743 131694 0/16 4003
1136 106894 - 131742 131689 0/16 4003
1136 106893 - 131741 131684 0/16 4003
1136 106890 - 131738 131662 0/16 3998
1136 106889 - 131737 131657 0/16 3998
1136 106888 - 131736 131652 0/16 3998
1136 106886 - 131734 131640 0/16 3994
1136 106885 - 131733 131635 0/16 3994
1136 106884 - 131732 131630 0/16 3994
1139 107059 107058,107057,107056 131925 131921 31/31 3989
1139 107058 - 131924 131913 41/41 3989
1139 107057 - 131923 131903 41/41 3989
1139 107056 - 131922 131893 41/41 3989
1137 106983 106982,106977,106976 131841 131831 1/31 3989
1137 106982 106981,106980,106979,106978 131840 131823 0/31 4018
1137 106977 - 131835 131783 0/41 4018
1137 106976 106975,106974 131834 131773 0/31 4018
1137 106981 - 131839 131815 0/2 4017
1137 106980 - 131838 131807 0/2 4017
1137 106979 - 131837 131799 0/2 4017
1137 106978 - 131836 131791 0/2 4017
1137 106975 - 131833 131765 0/31 4011
1137 106974 - 131832 131757 0/31 4011
]],[[
1138 4022:0/3/3,4021:0/0/0,4020:0/0/0,4019:0/0/0
1136 4008:1/0/1,4007:0/0/0,4006:0/0/0,4005:0/0/0,4004:0/0/0,4003:0/0/0,4002:0/0/0,4001:0/0/0,4000:0/0/0,3998:0/0/0,3997:0/0/0,3996:0/0/0,3995:0/0/0,3994:0/0/0,3993:0/0/0,3992:0/0/0,3991:0/0/0
1139 4029:0/3/3,4028:0/0/0,4027:0/0/0,4026:0/0/0
1137 4018:0/0/0,4017:0/0/0,4016:0/0/0,4015:0/0/0,4014:0/0/0,4013:0/0/0,4012:0/0/0,4011:0/0/0,4010:0/0/0,4009:0/0/0
]]},
{2910,202,8,3903,203,21,{103,0,70,30},{225,165,90,90},3901,
{"Market Mobility","Combat Analytics","Recycling","Bits and Bots"},[[
1131 106719 106718,106714 131540 131531 26/26 3903
1131 106718 106717,106716,106715 131539 131524 11/11 3903
1131 106714 106713,106712,106711 131535 131496 1/11 3903
1131 106717 - 131538 131520 31/31 3903
1131 106716 - 131537 131512 31/31 3903
1131 106715 - 131536 131504 1/31 3903
1131 106713 - 131534 131492 0/31 3975
1131 106712 - 131533 131484 0/31 3975
1131 106711 - 131532 131476 9/31 3903
1176 109141 109140,109139,109138,110352 135203 135199 1/26 3903
1176 109140 - 135202 135192 0/36 4177
1176 109139 - 135201 135183 0/36 4177
1176 109138 - 135200 135174 1/36 3903
1176 110352 - 136914 136913 0/36 4177
1132 106755 106754,106753,106752 131580 131576 31/31 3903
1132 106754 - 131579 131564 1/21 3903
1132 106753 - 131578 131556 21/21 3903
1132 106752 - 131577 131548 21/21 3903
1133 106789 106788,106787 131617 131614 1/31 3903
1133 106788 - 131616 131604 31/31 3903
1133 106787 - 131615 131592 0/31 3987
]],[[
1131 3980:0/2/2,3979:0/3/3,3978:0/0/0,3977:0/0/0,3976:0/0/0,3975:0/1/1,3974:0/0/0,3973:0/0/0,3972:0/0/0
1176 4177:0/1/1,4176:0/0/0,4175:0/0/0,4174:0/0/0,4236:0/0/0
1132 3984:0/3/3,3983:1/0/1,3982:0/0/0,3981:0/0/0
1133 3987:0/1/1,3986:0/0/0,3985:0/0/0
]]},
{2915,165,2,4085,323,32,{73,250,0,0},{120,250,250,150},4084,
{"Learned Leatherworker","Lasting Leather","Safeguarding Scales","Flawless Fortes"},[[
1158 107921 107920,107919,107918 133278 133274 31/31 4085
1158 107920 - 133277 133266 31/31 4085
1158 107919 - 133276 133258 1/31 4085
1158 107918 - 133275 133250 14/31 4085
1157 107889 107888,107883 133242 133231 31/31 4085
1157 107888 107887,107886,107885,107884 133241 133223 31/31 4085
1157 107883 107882,107881,107880,107879 133236 133191 31/31 4085
1157 107887 - 133240 133215 21/21 4085
1157 107886 - 133239 133209 21/21 4085
1157 107885 - 133238 133203 21/21 4085
1157 107884 - 133237 133197 21/21 4085
1157 107882 - 133235 133183 21/21 4085
1157 107881 - 133234 133177 21/21 4085
1157 107880 - 133233 133171 21/21 4085
1157 107879 - 133232 133165 21/21 4085
1159 107993 107992,107987 133361 133350 1/31 4085
1159 107992 107991,107990,107989,107988 133360 133342 0/31 4117
1159 107987 107986,107985,107984,107983 133355 133310 0/31 4117
1159 107991 - 133359 133334 0/21 4116
1159 107990 - 133358 133328 0/21 4116
1159 107989 - 133357 133322 0/21 4116
1159 107988 - 133356 133316 0/21 4116
1159 107986 - 133354 133302 0/21 4111
1159 107985 - 133353 133296 0/21 4111
1159 107984 - 133352 133290 0/21 4111
1159 107983 - 133351 133284 0/21 4111
1156 107817 107816,107815 133159 133153 1/31 4085
1156 107816 - 133158 133145 0/31 4091
1156 107815 107814,107813,107812 133157 133137 0/31 4091
1156 107814 - 133156 133129 0/21 4089
1156 107813 - 133155 133123 0/21 4089
1156 107812 - 133154 133117 0/21 4089
]],[[
1158 4106:0/3/3,4105:0/0/0,4104:0/0/0,4103:0/0/0
1157 4102:0/2/2,4101:0/4/4,4100:1/0/1,4099:1/0/1,4098:1/0/1,4097:1/0/1,4096:0/4/4,4095:1/0/1,4094:1/0/1,4093:1/0/1,4092:1/0/1
1159 4117:0/0/0,4116:0/0/0,4115:0/0/0,4114:0/0/0,4113:0/0/0,4112:0/0/0,4111:0/0/0,4110:0/0/0,4109:0/0/0,4108:0/0/0,4107:0/0/0
1156 4091:0/0/0,4090:0/0/0,4089:0/0/0,4088:0/0/0,4087:0/0/0,4086:0/0/0
]]},
{2918,197,7,3736,296,26,{0,130,80,86},{300,130,80,150},3735,
{"Sin'dorei Finery","Nimble Needlework","Fabric Specialist","Fiber Arts"},[[
1067 104216 104215,104211,104207 128816 128803 1/31 3736
1067 104215 104214,104213,104212 128815 128795 0/31 3749
1067 104211 104210,104209,104208 128811 128769 0/31 3749
1067 104207 104206,104205,104204 128807 128743 0/31 3749
1067 104214 - 128814 128787 0/21 3748
1067 104213 - 128813 128781 0/21 3748
1067 104212 - 128812 128775 0/21 3748
1067 104210 - 128810 128761 0/21 3744
1067 104209 - 128809 128755 0/21 3744
1067 104208 - 128808 128749 0/21 3744
1067 104206 - 128806 128735 0/21 3740
1067 104205 - 128805 128729 0/21 3740
1067 104204 - 128804 128723 0/21 3740
1070 104328 104327,104325 128942 128937 31/31 3736
1070 104327 104326 128941 128929 31/31 3736
1070 104325 104324 128939 128915 31/31 3736
1070 104326 - 128940 128921 21/21 3736
1070 104324 - 128938 128907 21/21 3736
1071 104350 104349,104348 128967 128964 31/31 3736
1071 104349 - 128966 128956 26/26 3736
1071 104348 - 128965 128949 26/26 3736
1072 104390 104389,104388,104387,104386 129012 129007 31/31 3736
1072 104389 - 129011 128999 31/31 3736
1072 104388 - 129010 128991 1/31 3736
1072 104387 - 129009 128983 1/31 3736
1072 104386 - 129008 128975 27/31 3736
]],[[
1067 3749:0/0/0,3748:0/0/0,3747:0/0/0,3746:0/0/0,3745:0/0/0,3744:0/0/0,3743:0/0/0,3742:0/0/0,3741:0/0/0,3740:0/0/0,3739:0/0/0,3738:0/0/0,3737:0/0/0
1070 3769:0/2/2,3768:0/1/1,3767:0/0/0,3766:0/1/1,3765:0/0/0
1071 3772:0/2/2,3771:0/0/0,3770:0/0/0
1072 3777:0/4/4,3776:0/0/0,3775:0/0/0,3774:0/0/0,3773:0/0/0
]]},
}
local function ident(s) return {skillLineID=s[1],parentID=s[2],profession=s[3],expansionID=11} end
local function fixture(s,db)
    local env,state=fixtureAPI()
    state.guid="K09-synthetic-"..s[1]; state.config=800000+s[1]; state.unspent=0
    state.info.professionID=s[1]; state.info.parentProfessionID=s[2]; state.info.profession=s[3]
    state.info.professionName="Écriture 静かな手 "..s[1]
    env.UnitGUID=function() return state.guid end
    env.GetProfessionInfo=function() return "Synthetic",0,100,100,0,0,s[2] end
    env.C_TradeSkillUI.GetBaseProfessionInfo=function() return {professionID=s[2]} end
    env.C_TradeSkillUI.GetProfessionSlots=function(id) eq(id,s[3]); return state.slots end
    env.C_TradeSkillUI.GetConcentrationCurrencyID=function(id) eq(id,s[1]); return 50001 end
    env.C_CurrencyInfo.GetCurrencyInfo=function() return {quantity=0,maxQuantity=1000} end
    local f={tabs={},nodes={},entries={},children={},costs={},currencies={},unlock={},spend={},currency={}}
    local tabs={}
    for ti,id,ch,un,sp,rp,max,cost in s[11]:gmatch("(%d+) (%d+) (%S+) (%d+) (%d+) (%d+)/(%d+) (%d+)") do
        ti,id,un,sp,rp,max,cost=tonumber(ti),tonumber(id),tonumber(un),tonumber(sp),tonumber(rp),tonumber(max),tonumber(cost)
        if not tabs[ti] then
            local tab={id=ti,root=id,name=s[10][#f.tabs+1]}; tabs[ti]=tab; f.tabs[#f.tabs+1]=tab
        end
        local children={}; for x in ch:gmatch("%d+") do children[#children+1]=tonumber(x) end
        f.children[id]=children; f.unlock[id]=un; f.spend[id]=sp; f.currency[id]=s[4]
        f.entries[un]={type=9,maxRanks=1,definitionID=un+900000,entryCost={}}
        f.entries[sp]={type=7,maxRanks=max-1,definitionID=sp+900000,entryCost={}}
        f.costs[id]={{ID=cost,amount=1}}
        local active={entryID=rp>1 and sp or un,rank=rp>1 and rp-1 or rp}
        -- Q03 reports partial next ranks explicitly: 19->20,16->17,22->23,
        -- 34->35,14->15,9->10,27->28; this fixture encoding is not API policy.
        local nextEntry=rp<max and {entryID=rp==0 and un or sp,rank=rp<=1 and 1 or rp+1} or nil
        f.nodes[id]={ID=id,type=1,flags=0,isAvailable=true,ranksPurchased=rp,currentRank=rp,activeRank=rp,
            ranksIncreased=0,maxRanks=max,totalMaxRanks=max,activeEntry=active,nextEntry=nextEntry,
            entryIDs={un,sp},entryIDsWithCommittedRanks=rp==0 and {} or {active.entryID},
            entryIDToRanksIncreased={[un]=0,[sp]=0}}
    end
    for ti,text in s[12]:gmatch("(%d+) ([^\n]+)") do
        local rows={{traitCurrencyID=s[4],quantity=0,spent=s[5]},{traitCurrencyID=s[9],quantity=0,spent=4,maxQuantity=4}}
        for id,q,sp,max in text:gmatch("(%d+):(%d+)/(%d+)/(%d+)") do
            rows[#rows+1]={traitCurrencyID=tonumber(id),quantity=tonumber(q),spent=tonumber(sp),maxQuantity=tonumber(max)}
        end
        f.currencies[tonumber(ti)]=rows
    end
    local p,t=env.C_ProfSpecs,env.C_Traits
    p.GetConfigIDForSkillLine=function(id) eq(id,s[1]); return state.config end
    p.GetCurrencyInfoForSkillLine=function(id) eq(id,s[1]); return {numAvailable=state.unspent} end
    p.GetSpecTabIDsForSkillLine=function(id) eq(id,s[1]); local out={}; for i,tab in ipairs(f.tabs) do out[i]=tab.id end; return out end
    p.GetTabInfo=function(id) return {name=tabs[id].name} end
    p.GetRootPathForTab=function(id) return tabs[id] and tabs[id].root end
    p.GetChildrenForPath=function(id) return f.children[id] end
    p.GetUnlockEntryForPath=function(id) return f.unlock[id] end
    p.GetSpendEntryForPath=function(id) return f.spend[id] end
    p.GetSpendCurrencyForPath=function(id) return f.currency[id] end
    t.GetNodeInfo=function(config,id) eq(config,state.config); return f.nodes[id] end
    t.GetEntryInfo=function(config,id) eq(config,state.config); return f.entries[id] end
    t.GetDefinitionInfo=function(id) return {overrideName="静かな手 Écriture "..id} end
    t.GetNodeCost=function(config,id) eq(config,state.config); return f.costs[id] end
    t.GetTreeCurrencyInfo=function(config,id,exclude) eq(config,state.config); eq(exclude,true); return f.currencies[id] end
    local function forbidden() error("K09 forbidden gameplay") end
    for _,key in ipairs({"PurchaseRank","RefundRank","CommitConfig","SetSelection","GetTreeNodes"}) do t[key]=forbidden end
    return env,state,f,NS.Collectors.New(env,db or C.Open(nil))
end
local function active(c,s,id) return c.db.characters[s.guid].professions[id].active end
local function visits(v)
    local n=1; if type(v)=="table" then for _,x in pairs(v) do n=n+visits(x) end end; return n
end
local function hover(env,widget,shift)
    env.IsShiftKeyDown=function() return shift end
    widget.scripts.OnEnter(widget); return table.concat(env.GameTooltip.lines,"\n")
end
for _,s in ipairs(specs) do
case("K09 full native evaluation "..s[1],function()
    local _,_,f,c=fixture(s); local raw=k2Raw(c); local out=K.Evaluate(raw)
    eq(raw.nativeComplete,true); eq(out.complete,true); eq(out.sharedSpent,s[5]); eq(#out.trees,4)
    eq(C.ValidPayload("knowledgeRaw",raw,"observed"),true)
    local count,ranks,points=0,0,0
    for i,t in ipairs(out.trees) do
        eq(t.id,f.tabs[i].id); eq(t.purchased,s[7][i]); eq(t.capacity,s[8][i])
        eq(t.accountingEvidence.currencyID,s[4]); eq(t.accountingEvidence.quantity,0)
        eq(C.ValidPayload("tree:"..t.id,t,"observed"),true)
        for _,p in ipairs(t.paths) do
            count=count+1; ranks=ranks+p.node.ranksPurchased; points=points+p.purchased
            eq(p.capacity,p.spend.maxRanks); eq(p.purchased,math.max(0,p.node.ranksPurchased-1))
            assert(deepEqual(p.children,f.children[p.id])); eq(p.costs[1].ID,f.costs[p.id][1].ID)
        end
    end
    eq(count,s[6]); eq(points,s[5]); assert(ranks>points)
    if s[1]==2914 then for _,id in ipairs({106981,106980,106979,106978}) do
        eq(raw.tabs[4].paths[id].node.maxRanks,2); eq(raw.tabs[4].paths[id].spend.maxRanks,1)
    end end
    if s[1]==2910 then
        assert(deepEqual(f.children[109141],{109140,109139,109138,110352}))
        for _,id in ipairs(f.children[109141]) do eq(f.entries[f.spend[id]].maxRanks,35) end
    end
end)
case("K09 real Scan Apply Open archive offline dashboard hover "..s[1],function(checkpoint)
    local env,state,f,c=fixture(s); mockWidgets(env); eq(c:Scan(),true)
    local g=active(c,state,s[1]); eq(g.identity.name,state.info.professionName)
    eq(g.fields.knowledgeRaw.attempt.status,"observed"); eq(g.fields.unspent.last.value,0)
    eq(C.Open(c.db),c.db); local ui=NS.Dashboard.New(env,c); ui:Toggle(); eq(#ui.rows,1)
    local verify=unchangedGraph(c.db)
    for i,t in ipairs(ui.rows[1].trees) do
        local value=g.fields["tree:"..t.id].last.value
        eq(t.id,f.tabs[i].id); eq(t.purchased,s[7][i]); eq(t.capacity,s[8][i]); eq(t.state.fresh,true)
        eq(g.fields["tree:"..t.id].last.observedAt,100)
        local text=hover(env,ui.widgets[1].bars[i],false); local depth={[value.root]=0}
        for j,p in ipairs(value.paths) do
            eq(env.GameTooltip.lines[j],string.rep("  ",depth[p.id])..p.name..": "..p.purchased.."/"..p.capacity)
            for _,id in ipairs(p.children) do depth[id]=depth[p.id]+1 end
        end
        assert(text:find("静かな手 Écriture",1,true))
        local diagnostic=hover(env,ui.widgets[1].bars[i],true)
        assert(diagnostic:find("NOT verified future/all-rank costs",1,true)); assert(diagnostic:find("Observed tree at 100",1,true))
    end
    eq(NS.Details.Model(c,{guid=state.guid,id=s[1],generation=g.generation,archived=false}).supported,false)
    verify(); pause(checkpoint,"K09 complete native-derived scan/render")
    c.db=assert(C.Copy(c.db)); eq(C.Open(c.db),c.db); c.fresh={}; state.shown=false
    local function forbidden() error("K09 render must not collect") end
    c.Context=forbidden; for _,space in ipairs({env.C_ProfSpecs,env.C_Traits}) do for k in pairs(space) do space[k]=forbidden end end
    ui:Refresh(); eq(ui.rows[1].trees[1].state.fresh,false); eq(ui.rows[1].trees[1].purchased,s[7][1])
    hover(env,ui.widgets[1].bars[1],false)
    local key="tree:"..f.tabs[1].id
    local stale=assert(C.Apply(c.db,{guid=state.guid,name=character.name,realm=character.realm},g.identity,
        {[key]=C.Observation("unknown",nil,105,"K09 synthetic stale projection")},105,"K09 fixture"))
    assert(deepEqual(stale.fields[key].last,g.fields[key].last))
    ui:Refresh(); eq(ui.rows[1].trees[1].state.stale,true)
    assert(hover(env,ui.widgets[1].bars[1],false):find("Stale data",1,true))
    eq(C.Archive(c.db,state.guid,s[1],110,"K09 synthetic archive"),true); eq(C.Open(c.db),c.db)
    ui.options.archived=true; ui:Refresh(); eq(ui.rows[1].archived,true)
    eq(ui.rows[1].trees[1].purchased,s[7][1]); assert(hover(env,ui.widgets[1].bars[1],false):find("Archived",1,true))
end)
case("K09 coherent synthetic config order labels ranks caps positive independent balances "..s[1],function()
    local env,state,f,c=fixture(s)
    state.config=state.config+777; state.info.sourceCounter=37; state.unspent=11
    local id=f.tabs[1].root; local node=f.nodes[id]; local sp=f.spend[id]
    -- Synthetic coherent variant: add capacity, remove one paid point where possible;
    -- unlocked zero remains zero. Neither capacities nor rank values are defaults.
    local removed=node.ranksPurchased>1 and 1 or 0
    node.ranksPurchased=node.ranksPurchased-removed; node.currentRank=node.ranksPurchased; node.activeRank=node.currentRank
    node.maxRanks=node.maxRanks+2; node.totalMaxRanks=node.maxRanks
    f.entries[sp].maxRanks=f.entries[sp].maxRanks+2
    node.activeEntry={entryID=node.ranksPurchased>1 and sp or f.unlock[id],rank=math.max(0,node.ranksPurchased-1)}
    if node.ranksPurchased==1 then node.activeEntry.rank=1 end
    node.entryIDsWithCommittedRanks={node.activeEntry.entryID}
    node.nextEntry={entryID=sp,rank=node.ranksPurchased+1}
    for _,tab in ipairs(f.tabs) do
        tab.name="静かな手 synthetic dynamic "..tab.id
        for _,row in ipairs(f.currencies[tab.id]) do
            if row.traitCurrencyID==s[4] then row.spent=s[5]-removed; row.quantity=7
            else row.quantity=3; row.maxQuantity=math.max(row.maxQuantity or 0,3) end
        end
        local first=table.remove(f.currencies[tab.id],1)
        f.currencies[tab.id][#f.currencies[tab.id]+1]=first
    end
    f.tabs[1],f.tabs[4]=f.tabs[4],f.tabs[1]
    local raw=k2Raw(c); local out=K.Evaluate(raw)
    eq(raw.configID,state.config); eq(raw.sourceCounter,37); eq(out.complete,true)
    eq(out.sharedSpent,s[5]-removed); eq(out.trees[4].capacity,s[8][1]+2)
    eq(out.trees[4].purchased,s[7][1]-removed); eq(out.trees[1].id,f.tabs[1].id)
    eq(out.trees[1].accountingEvidence.quantity,7)
    eq(c:Scan(),true); local g=active(c,state,s[1]); eq(g.fields.unspent.last.value,11)
    eq(g.fields.knowledgeRaw.last.value.configID,state.config)
    eq(C.Open(c.db),c.db); local rows=V.Build(c.db,c.fresh,{},100)
    eq(rows[1].unspent,11); eq(rows[1].trees[1].id,f.tabs[1].id)
    eq(rows[1].trees[4].capacity,s[8][1]+2); assert(rows[1].trees[1].name:find("synthetic dynamic",1,true))
end)
end
case("K09 combined eight complete native-derived snapshots unchanged50000 budget",function(checkpoint,annotate)
    local env,_,_,c=k2Fixture(); eq(c:Scan(),true); local db=c.db
    for _,s in ipairs(specs) do
        local _,state,_,collector=fixture(s,db); eq(collector:Scan(),true,"combined Scan "..s[1])
        local g=active(collector,state,s[1]); eq(g.fields.knowledgeRaw.attempt.status,"observed")
        for i,t in ipairs(g.fields.knowledgeIndex.last.value) do
            eq(g.fields["tree:"..t.id].last.value.purchased,s[7][i])
        end
        pause(checkpoint,"K09 combined full snapshot")
    end
    assert(visits(db)<=50000,"all eight full raw+numeric graphs must fit, actual="..visits(db))
    if annotate then annotate("complete eight raw+numeric snapshots: "..visits(db).."/50000 values") end
    local copy=assert(C.Copy(db)); eq(C.Open(copy),copy)
    local rows=V.Build(copy,{}, {},120); eq(#rows,8)
    local ui=NS.Dashboard.New(env,NS.Collectors.New(env,copy)); mockWidgets(env); ui:Toggle(); eq(#ui.rows,8)
    for _,row in ipairs(rows) do eq(#row.trees,4); eq(row.trees[1].state.fresh,false) end
end)
local function rewriteCurrency(raw,from,to)
    for _,tab in ipairs(raw.tabs) do
        for _,p in pairs(tab.paths) do
            if p.spendCurrencyID==from then p.spendCurrencyID=to end
            for _,cost in ipairs(p.costs) do if cost.ID==from then cost.ID=to end end
        end
        for _,row in ipairs(tab.currencies) do if row.traitCurrencyID==from then row.traitCurrencyID=to end end
    end
end
local function rejected(raw,why)
    local verify=unchangedGraph(raw); k2Fail(raw,why); verify()
end
local function retained(c,state,s,old)
    local g=active(c,state,s[1]); local fields=g.fields
    assert(deepEqual(fields.knowledgeIndex.last,old.fields.knowledgeIndex.last))
    eq(fields.knowledgeIndex.attempt.status,"unknown"); eq(fields.knowledgeIndex.last.observedAt,100)
    for _,t in ipairs(old.fields.knowledgeIndex.last.value) do
        local key="tree:"..t.id
        assert(deepEqual(fields[key].last,old.fields[key].last),key)
        eq(fields[key].last.observedAt,100); eq(fields[key].attempt.status,"unknown")
    end
    local rows=V.Build(c.db,c.fresh,{},state.at); eq(#rows,1)
    for i,t in ipairs(rows[1].trees) do
        eq(t.state.fresh,false); eq(t.state.stale,true); eq(t.purchased,s[7][i]); eq(t.capacity,s[8][i])
    end
    return g
end
case("K09 all eight resolver tuples malformed field matrices registry immutable",function(checkpoint)
    local verify=unchangedGraph(D); local all={}; for _,s in ipairs(specs) do all[#all+1]=s end
    all[#all+1]={2913,773,13,3902}
    for _,s in ipairs(all) do
        local id=ident(s); eq(C.NativeKnowledgeCurrency(id),s[4])
        local row=D.expansions[s[1]]; eq(row.parentID,s[2]); eq(row.profession,s[3]); eq(row.expansionID,11)
        id.name="Unrelated localized 静かな手"; eq(C.NativeKnowledgeCurrency(id),s[4])
        for _,key in ipairs({"skillLineID","parentID","profession","expansionID"}) do
            for _,bad in ipairs({{}, {v=false},{v="11"},{v=0},{v=-1},{v=0.5},{v=99999},{v=math.huge},{v=0/0}}) do
                local wrong=ident(s); wrong[key]=bad.v; eq(C.NativeKnowledgeCurrency(wrong),nil,key)
            end
        end
        for _,lock in ipairs({false,"locked"}) do
            local wrong=setmetatable(ident(s),{__metatable=lock,__index=function() error("identity metamethod") end})
            eq(C.NativeKnowledgeCurrency(wrong),nil)
        end
        pause(checkpoint,"K09 exact resolver tuple")
    end
    for _,bad in ipairs({false,1,"2913",{}, {skillLineID=2913,parentID=773,profession=13,expansionID=10},
        {skillLineID=2912,parentID=186,profession=11,expansionID=11},
        {skillLineID=2822,parentID=773,profession=13,expansionID=10}}) do eq(C.NativeKnowledgeCurrency(bad),nil) end
    eq(C.NativeKnowledgeCurrency(nil),nil); verify()
end)
case("K09 formerly arbitrary coherent Inscription70002 is rejected not defaulted",function()
    local _,_,_,c=k2Fixture(); local raw=k2Raw(c)
    rewriteCurrency(raw,3902,70002)
    for _,tab in ipairs(raw.tabs) do for _,p in pairs(tab.paths) do
        assert(K.NativePathPoints(p,tab),"coherent paths alone still valid")
    end end
    rejected(raw,"coherent arbitrary Inscription currency")
    eq(C.ValidPayload("knowledgeRaw",raw,"observed"),false)
    local db=C.Open(nil); local verify=unchangedGraph(db)
    eq(C.Apply(db,character,identity,{knowledgeRaw=C.Observation("observed",raw,100,"K09 synthetic")},100,"fixture"),nil); verify()
end)
for _,s in ipairs(specs) do
case("K09 evaluator wrong missing conflicting duplicate currencies and auxiliaries "..s[1],function(checkpoint)
    local _,_,_,c=fixture(s); local base=k2Raw(c)
    local raw=assert(C.Copy(base)); rewriteCurrency(raw,s[4],3902)
    for _,tab in ipairs(raw.tabs) do for _,p in pairs(tab.paths) do assert(K.NativePathPoints(p,tab)) end end
    rejected(raw,"internally coherent wrong profession currency"); eq(C.ValidPayload("knowledgeRaw",raw,"observed"),false)
    raw.nativeComplete=false; raw.tabs[1].paths[raw.tabs[1].root].metadataComplete=false
    eq(C.ValidPayload("knowledgeRaw",raw,"observed"),false,"partial wrong currency still rejects")
    for _,mode in ipairs({"missing","conflictingSpent","conflictingQuantity","duplicate","missingPathSpend"}) do
        raw=assert(C.Copy(base)); local t=raw.tabs[4]
        if mode=="missing" then table.remove(t.currencies,1)
        elseif mode=="conflictingSpent" then t.currencies[1].spent=t.currencies[1].spent+1
        elseif mode=="conflictingQuantity" then t.currencies[1].quantity=2
        elseif mode=="duplicate" then t.currencies[#t.currencies+1]=C.Copy(t.currencies[1])
        else
            local p=t.paths[t.root]; p.spendCurrencyID=nil; p.metadataComplete=false
            raw.nativeComplete=false; t.coverageComplete=false
            eq(C.ValidPayload("knowledgeRaw",raw,"observed"),true,"typed missing spend remains partial")
        end
        rejected(raw,mode); pause(checkpoint,"K09 currency rejection")
    end
    raw=assert(C.Copy(base)); for _,t in ipairs(raw.tabs) do for _,row in ipairs(t.currencies) do
        if row.traitCurrencyID~=s[4] then row.quantity=19; row.spent=999; row.maxQuantity=1000 end
    end end
    local out=K.Evaluate(raw); eq(out.complete,true); eq(out.sharedSpent,s[5])
    eq(out.trees[1].accountingEvidence.quantity,0,"positive auxiliaries excluded")
end)
case("K09 full previous-scan failure preservation first-unknown recovery matrix "..s[1],function(checkpoint)
    local modes={"wrongCurrency","missingNode","missingEntry","missingCurrency","nonunit","unlockType","spendType",
        "increased","entryRank","lateChild","cycle","duplicateChild","sharedPath","unreachable","tabs9",
        "paths65","children17","currencies65","costs17","incompleteTabs","staged","unknownStaging",
        "missingShared","conflictingShared","duplicateShared"}
    for _,mode in ipairs(modes) do
        local env,state,f,c=fixture(s); eq(c:Scan(),true)
        local old=assert(C.Copy(active(c,state,s[1]))); local oldGraph=unchangedGraph(active(c,state,s[1]))
        local id=f.tabs[1].root; local n=f.nodes[id]; local originalKnowledge=c.Knowledge
        if mode=="wrongCurrency" then
            for path in pairs(f.currency) do f.currency[path]=3902 end
            for _,costs in pairs(f.costs) do for _,cost in ipairs(costs) do if cost.ID==s[4] then cost.ID=3902 end end end
            for _,rows in pairs(f.currencies) do for _,row in ipairs(rows) do if row.traitCurrencyID==s[4] then row.traitCurrencyID=3902 end end end
        elseif mode=="missingNode" then f.nodes[id]=nil
        elseif mode=="missingEntry" then f.entries[f.spend[id]]=nil
        elseif mode=="missingCurrency" then f.currency[id]=nil
        elseif mode=="nonunit" then f.costs[id][1].amount=2
        elseif mode=="unlockType" then f.entries[f.unlock[id]].type=7
        elseif mode=="spendType" then f.entries[f.spend[id]].type=9
        elseif mode=="increased" then n.ranksIncreased=1
        elseif mode=="entryRank" then n.activeEntry.rank=n.activeEntry.rank+1
        elseif mode=="lateChild" then
            local last
            local function walk(path) for _,child in ipairs(f.children[path]) do last=child; walk(child) end end
            for _,tab in ipairs(f.tabs) do walk(tab.root) end
            f.nodes[s[1]==2910 and 110352 or last]=nil
        elseif mode=="cycle" then f.children[id]={id}
        elseif mode=="duplicateChild" then f.children[id]={f.children[id][1],f.children[id][1]}
        elseif mode=="sharedPath" then f.children[f.tabs[2].root]={id}
        elseif mode=="unreachable" then
            c.Knowledge=function(self,ctx)
                local raw=originalKnowledge(self,ctx); local p=C.Copy(raw.tabs[1].paths[id]); p.node.ID=990001
                raw.tabs[1].paths[990001]=p; return raw
            end
        elseif mode=="tabs9" then
            env.C_ProfSpecs.GetSpecTabIDsForSkillLine=function() local out={}; for i=1,9 do out[i]=990000+i end; return out end
        elseif mode=="paths65" then
            local template=C.Copy(n); f.children[id]={990001}
            for i=1,65 do
                local pid=990000+i; f.nodes[pid]=C.Copy(template); f.nodes[pid].ID=pid
                f.unlock[pid]=f.unlock[id]; f.spend[pid]=f.spend[id]; f.currency[pid]=s[4]
                f.costs[pid]=C.Copy(f.costs[id]); f.children[pid]=i<65 and {pid+1} or {}
            end
        elseif mode=="children17" then f.children[id]={}; for i=1,17 do f.children[id][i]=990000+i end
        elseif mode=="currencies65" then
            local rows=f.currencies[f.tabs[4].id]; for i=#rows+1,65 do rows[i]={traitCurrencyID=990000+i,quantity=0,spent=0} end
        elseif mode=="costs17" then for i=2,17 do f.costs[id][i]={ID=990000+i,amount=1} end
        elseif mode=="incompleteTabs" then env.C_ProfSpecs.GetSpecTabIDsForSkillLine=function() return {[1]=f.tabs[1].id,[3]=f.tabs[3].id} end
        elseif mode=="staged" then state.staged=true
        elseif mode=="unknownStaging" then state.staged=nil end
        if mode=="missingShared" then table.remove(f.currencies[f.tabs[4].id],1)
        elseif mode=="conflictingShared" then f.currencies[f.tabs[4].id][1].quantity=3
        elseif mode=="duplicateShared" then
            local rows=f.currencies[f.tabs[4].id]; rows[#rows+1]=C.Copy(rows[1])
        end
        state.at=120; state.info.skillLevel=61
        eq(c:Scan(),true,mode); local g=retained(c,state,s,old); oldGraph()
        eq(g.fields.skill.last.value.skillLevel,61); eq(g.fields.skill.last.observedAt,120)
        if mode=="wrongCurrency" then
            eq(g.fields.knowledgeRaw.attempt.status,"unknown"); eq(g.fields.knowledgeRaw.attempt.value,nil)
            assert(deepEqual(g.fields.knowledgeRaw.last,old.fields.knowledgeRaw.last))
            assert(#g.fields.knowledgeRaw.attempt.reason<=256)
            assert(g.fields.knowledgeRaw.attempt.reason:find("wrong profession spend currency",1,true))
        end
        -- Same failed APIs on a fresh DB: unknown numeric values, never zero/caps.
        local empty=NS.Collectors.New(env,C.Open(nil)); empty.Knowledge=c.Knowledge
        eq(empty:Scan(),true,mode.." first failure")
        local first=active(empty,state,s[1]); for key,field in pairs(first.fields) do
            if key:match("^tree:") then eq(field.last,nil,mode); eq(field.attempt.status,"unknown") end
        end
        for _,row in ipairs(V.Build(empty.db,empty.fresh,{},120)) do for _,t in ipairs(row.trees) do
            eq(t.purchased,nil); eq(t.capacity,nil); eq(t.aggregateText,"?/?")
        end end
        -- Restore genuine full fixture APIs, retaining the same DB and character.
        local _,recoverState,_,recover=fixture(s,c.db); recoverState.at=130; eq(recover:Scan(),true)
        eq(active(recover,recoverState,s[1]).fields.knowledgeRaw.attempt.status,"observed")
        for _,t in ipairs(V.Build(recover.db,recover.fresh,{},130)[1].trees) do eq(t.state.fresh,true) end
        pause(checkpoint,"K09 full failure and recovery "..mode)
    end
end)
case("K09 previous successful scan source config context serial revision drift discards "..s[1],function(checkpoint)
    for _,mode in ipairs({"source","config","context","serial","revision"}) do
        local env,state,_,c=fixture(s); eq(c:Scan(),true)
        local old=active(c,state,s[1]); local verify=unchangedGraph(c.db); local cost=env.C_Traits.GetNodeCost; local once=false
        env.C_Traits.GetNodeCost=function(...)
            local result=cost(...)
            if not once then
                once=true
                if mode=="source" then state.info.sourceCounter=state.info.sourceCounter+1
                elseif mode=="config" then state.config=state.config+1
                elseif mode=="context" then state.shown=false
                elseif mode=="serial" then c.serial=c.serial+1
                else c:Invalidate("K09 synthetic drift") end
            end
            return result
        end
        state.at=120; eq(c:Scan(),false,mode); verify(); eq(active(c,state,s[1]),old); eq(old.scannedAt,100)
        eq(next(c.fresh),nil)
        local rows=V.Build(c.db,c.fresh,{},120); for _,t in ipairs(rows[1].trees) do eq(t.state.fresh,false) end
        local _,nextState,_,nextCollector=fixture(s,c.db); nextState.at=130; eq(nextCollector:Scan(),true)
        pause(checkpoint,"K09 drift discarded without writes")
    end
end)
end
case("K09 Apply and active archive Open reject cross raw owner tree currencies even without raw",function(checkpoint)
    for i,s in ipairs(specs) do
        local other=specs[i%#specs+1]; local _,state,_,c=fixture(s); eq(c:Scan(),true)
        local _,_,_,foreign=fixture(other); local raw=k2Raw(foreign); local evaluated=K.Evaluate(raw)
        local own=active(c,state,s[1]); local at=120; local who={guid=state.guid,name=character.name,realm=character.realm}
        for _,kind in ipairs({"raw","foreignTree","swappedTree"}) do
            local obs
            if kind=="raw" then obs={knowledgeRaw=C.Observation("observed",raw,at,"K09 foreign raw")}
            else
                local value=kind=="foreignTree" and C.Copy(evaluated.trees[1]) or C.Copy(own.fields["tree:"..own.fields.knowledgeIndex.last.value[1].id].last.value)
                if kind=="swappedTree" then
                    rewriteCurrency({tabs={value}},s[4],other[4]); value.accountingEvidence.currencyID=other[4]
                end
                eq(C.ValidPayload("tree:"..value.id,value,"observed"),true,"standalone has no owner")
                obs={["tree:"..value.id]=C.Observation("observed",value,at,"K09 foreign currency")}
            end
            local verify=unchangedGraph({c.db,obs}); eq(C.Apply(c.db,who,ident(s),obs,at,"fixture"),nil,kind); verify()
            eq(active(c,state,s[1]),own); eq(own.scannedAt,100)
            if kind~="raw" then
                local empty=C.Open(nil); local unchanged=unchangedGraph(empty)
                eq(C.Apply(empty,who,ident(s),obs,at,"fixture"),nil,"tree-only candidate attribution"); unchanged()
            end
            for _,archived in ipairs({false,true}) do
                local copy=C.Copy(c.db); local p=copy.characters[state.guid].professions[s[1]]; local g=p.active
                if kind~="raw" then g.fields.knowledgeRaw=nil end
                for key,o in pairs(obs) do g.fields[key]=C.Merge(nil,o,"fixture",g.generation) end
                if archived then g.archivedAt=130; g.archiveReason="K09 fixture"; p.active=nil; p.archives[1]=g end
                local unchanged=unchangedGraph(copy); eq(C.Open(copy),nil,kind..tostring(archived)); unchanged()
            end
            pause(checkpoint,"K09 attribution rejected")
        end
        local copy=C.Copy(c.db); local g=copy.characters[state.guid].professions[s[1]].active
        g.fields.knowledgeRaw=nil; eq(C.Open(copy),copy,"valid own tree-only schema1")
    end
end)
case("K09 independent successful tree times balances and newer typed partial raw no migration",function()
    local s=specs[1]; local _,state,_,c=fixture(s); eq(c:Scan(),true)
    local g=active(c,state,s[1]); local old=C.Copy(g); local raw=C.Copy(g.fields.knowledgeRaw.last.value)
    raw.nativeComplete=false; raw.tabs[1].coverageComplete=false
    raw.tabs[1].paths[raw.tabs[1].root].metadataComplete=false
    raw.tabs[1].paths[raw.tabs[1].root].spendCurrencyID=nil
    local value=C.Copy(g.fields["tree:"..raw.tabs[1].id].last.value)
    value.accountingEvidence.quantity=8
    for _,row in ipairs(value.currencies) do if row.traitCurrencyID==s[4] then row.quantity=8 end end
    local who={guid=state.guid,name=character.name,realm=character.realm}
    local newer=assert(C.Apply(c.db,who,ident(s),{
        knowledgeRaw=C.Observation("observed",raw,140,"K09 partial"),
        ["tree:"..value.id]=C.Observation("observed",value,130,"K09 independent tree")},140,"fixture"))
    eq(C.Open(c.db),c.db); eq(newer.fields.knowledgeRaw.last.observedAt,140)
    eq(newer.fields["tree:"..value.id].last.observedAt,130)
    for i=2,4 do
        local key="tree:"..raw.tabs[i].id; assert(deepEqual(newer.fields[key].last,old.fields[key].last))
        eq(newer.fields[key].last.observedAt,100)
    end
    local legacy=dbWith({knowledgeRaw=scan(),["tree:11"]=treeValue(11,0,10)})
    eq(C.Open(legacy),legacy)
end)
case("K09 combined payload and assembled DB budgets retain snapshots without generic abort on bad raw",function(checkpoint)
    local s=specs[5]; local _,state,_,c=fixture(s); eq(c:Scan(),true)
    local old=C.Copy(active(c,state,s[1])); local original=c.Knowledge
    c.Knowledge=function(self,ctx)
        local raw=original(self,ctx); raw.syntheticPadding={}
        for i=1,50000 do raw.syntheticPadding[i]=false end
        return raw
    end
    state.at=120; state.info.skillLevel=77; eq(c:Scan(),true)
    local g=retained(c,state,s,old); eq(g.fields.skill.last.value.skillLevel,77)
    eq(g.fields.knowledgeRaw.attempt.status,"unknown"); assert(deepEqual(g.fields.knowledgeRaw.last,old.fields.knowledgeRaw.last))
    local first=NS.Collectors.New(c.env,C.Open(nil)); first.Knowledge=c.Knowledge; eq(first:Scan(),true)
    for key,field in pairs(active(first,state,s[1]).fields) do
        if key:match("^tree:") then eq(field.last,nil); eq(field.attempt.status,"unknown") end
    end
    c.Knowledge=original; state.at=130; eq(c:Scan(),true)
    pause(checkpoint,"K09 combined raw result budget rejection recovered")
    local _,nextState,f,nextCollector=fixture(s); eq(nextCollector:Scan(),true)
    local db=nextCollector.db; db.padding={}; local used=visits(db)
    for i=1,50000-used do db.padding[i]=false end
    eq(visits(db),50000); eq(C.Open(db),db)
    local before=active(nextCollector,nextState,s[1]); local verify=unchangedGraph(db)
    for _,rows in pairs(f.currencies) do rows[1].maxQuantity=1000 end
    nextState.at=140; eq(nextCollector:Scan(),false); verify(); eq(active(nextCollector,nextState,s[1]),before)
    eq(before.scannedAt,100); eq(next(nextCollector.fresh),nil)
    assert(nextCollector.reason:find("bounded saved data limits",1,true))
end)
case("K09 unsupported collector identity has unsupported no-value raw and committable generic fields",function()
    local s=specs[1]; local _,state,_,c=fixture(s); local context=c.Context
    c.Context=function(self)
        local ctx,why=context(self)
        if ctx then ctx.identity=C.Copy(ctx.identity); ctx.identity.skillLineID=99999 end
        return ctx,why
    end
    eq(c:Scan(),true); local g=active(c,state,99999)
    eq(g.fields.knowledgeRaw.attempt.status,"unsupported"); eq(g.fields.knowledgeRaw.last,nil)
    eq(g.fields.knowledgeRaw.attempt.value,nil); eq(g.fields.skill.last.observedAt,100)
    for key,field in pairs(g.fields) do if key:match("^tree:") then eq(field.last,nil) end end
    eq(C.Open(c.db),c.db)
end)
case("K09 native attribution does not reinterpret legacy generic extension markers",function()
    -- Existing typed validators allow extra primitive metadata. A policy-looking
    -- extra on skill is not native Knowledge raw/tree evidence and must not throw.
    for _,marker in ipairs({"policy","accountingPolicy"}) do
        local db=C.Open(nil); local value={skillLevel=1,maxSkillLevel=100,skillModifier=0}
        value[marker]="native-rank-reconciled-v1"
        eq(C.ValidPayload("skill",value,"observed"),true)
        assert(C.Apply(db,character,identity,{skill=C.Observation("observed",value,100,"K09 legacy extension")},100,"fixture"))
        eq(C.Open(db),db)
    end
end)
end
-- K09 END

-- U05 BEGIN: presentation/optional metadata fixtures, NOT native API evidence.
do
local V,D=NS.ViewModel,NS.Data
local maps={
    {2906,{1140,1142,1144,1143}}, {2907,{1068,1069,1075,1076}},
    {2909,{1155,1154,1153,1152}}, {2910,{1131,1176,1132,1133}},
    {2913,{1122,1124,1182,1125}}, {2914,{1138,1136,1139,1137}},
    {2915,{1158,1157,1159,1156}}, {2918,{1067,1070,1071,1072}},
}
local palette={{.20,.65,.95},{.20,.78,.48},{.98,.62,.20},{.70,.42,.92}}
local function rgb(actual,expected)
    for i=1,3 do eq(actual[i],expected[i],"RGB component "..i) end
end
local function uiFixture(db,flags)
    local env,s=fixtureAPI(); mockWidgets(env)
    for key,value in pairs(flags or {}) do env[key]=value end
    local c=NS.Collectors.New(env,db or dbWith(payloadFixtures()))
    local ui=NS.Dashboard.New(env,c); ui:Toggle()
    return ui,env,c,s
end
local function noWrites(ui,env,c,s)
    local verify=unchangedGraph({c.db,c.fresh,env.CraftArmyDiagnosticsDB})
    -- U13 ADAPT NOWRITES_READ_SNAPSHOT BEGIN
--[==========[U13 ORIGINAL BEGIN
    local reads,requests,timers=s.reads,s.requests,#s.timers
U13 ORIGINAL END]==========]
    local reads,requests,timers=s.reads,s.requests,#s.timers; local u13VerifyReads=u13NoAcquisition(s)
    -- U13 ADAPT NOWRITES_READ_SNAPSHOT END
    local function forbidden() error("U05 render/menu must not collect") end
    c.Scan=forbidden; c.Request=forbidden; c.Context=forbidden; c.Login=forbidden
    return function()
        -- U13 ADAPT NOWRITES_READ_CHECK BEGIN
--[==========[U13 ORIGINAL BEGIN
        verify(); eq(s.reads,reads); eq(s.requests,requests); eq(#s.timers,timers)
U13 ORIGINAL END]==========]
        verify(); u13VerifyReads(); eq(s.requests,requests); eq(#s.timers,timers)
        -- U13 ADAPT NOWRITES_READ_CHECK END
    end
end
local function click(widget) widget.scripts.OnClick(widget) end
local function radio(widget,label)
    widget:fixtureGenerate()
    for _,item in ipairs(widget.radios) do if item.label==label then item:Click(); return end end
    error("missing generated radio "..label)
end
local function apply(db,c,values,at,id)
    local obs={}
    for key,value in pairs(values or {}) do obs[key]=C.Observation("observed",value,at or 100,"U05 fixture") end
    return assert(C.Apply(db,c,id or identity,obs,at or 100,"fixture"))
end
for _,sample in ipairs(maps) do
    local profession,tabs=sample[1],sample[2]
    case("U05 stable four-color native-ID visual map "..profession,function()
        local seen={}
        for slot,id in ipairs(tabs) do
            local value={D.TreeRGB(profession,id)}; rgb(value,palette[slot])
            local key=table.concat(value,","); eq(seen[key],nil); seen[key]=true
        end
        -- Render projected rows with localized/identical labels and reordered tabs.
        -- These are visual projections, not fabricated accounting/native graphs.
        local ui,env,c,s=uiFixture(); local row=ui.rows[1]; local source=C.Copy(row.trees[1])
        local pool=ui.widgets[1].bars; local first=pool[1]; local verify=noWrites(ui,env,c,s)
        for alt=1,2 do
            row.id=profession; row.guid="visual-alt-"..alt; row.trees={}
            for _,slot in ipairs({4,2,1,3}) do
                local tree=C.Copy(source); tree.id=tabs[slot]; tree.name="同じ名前"
                row.trees[#row.trees+1]=tree
            end
            ui:Render(); eq(pool[1],first)
            for n,slot in ipairs({4,2,1,3}) do
                rgb(pool[n].style.SetStatusBarColor,palette[slot]); eq(pool[n].tree.id,tabs[slot])
                eq(pool[n].label:GetText(),"0/10"); eq(pool[n].width,70)
                eq(pool[n].style.SetStatusBarTexture[1],"Interface\\Buttons\\WHITE8X8")
            end
        end
        row.trees[1].id=99999; row.trees[1].ratio=nil; row.trees[1].purchased=nil
        ui:Render(); rgb(first.style.SetStatusBarColor,{.45,.50,.58})
        eq(first:GetStatusBarTexture().shown,false); eq(first.label:GetText(),"?")
        verify()
    end)
end
case("U05 visual fallback wrong missing IDs and private scalar palette",function()
    for _,args in ipairs({{2913,1140},{9999,1122},{"2913",1122},{2913,"1122"},{2913,0},{}}) do
        rgb({D.TreeRGB(unpack(args))},{.45,.50,.58})
    end
    local values={D.TreeRGB(2913,1122)}; values[1]=99
    rgb({D.TreeRGB(2913,1122)},palette[1]); eq(D.treePalette,nil); eq(D.treeColors,nil)
end)
case("U05 centered gear header cell padding icons and confirmed empty unchanged",function()
    local env,s=fixtureAPI(); mockWidgets(env); local c=NS.Collectors.New(env,C.Open(nil)); assert(c:Scan())
    local ui=NS.Dashboard.New(env,c); ui:Toggle(); local verify=noWrites(ui,env,c,s)
    for _,column in ipairs({I.Accessory1,I.Accessory2,I.Tool}) do
        local cell,header=ui.widgets[1].cells[column],ui.headers[column]
        eq(header.label.style.SetJustifyH[1],"CENTER"); eq(cell.label.style.SetJustifyH[1],"CENTER")
        -- U10 ADAPT U05_GEAR BEGIN
--[====[U10 ORIGINAL BEGIN
        eq(header.width,44); eq(cell.width,44); eq(cell.label.width,40); eq(cell.label.points[1].x,2)
        assert(cell.label:GetText():find("|T1234:14:14|t",1,true)); assert(cell.label:GetText():find("|A:fixture-atlas",1,true))
        eq(cell.fill.style.SetColorTexture[4],.18)
U10 ORIGINAL END]====]
        -- U11 ADAPT U05_GEAR BEGIN
--[======[U11 ORIGINAL BEGIN
        eq(header.width,column==I.Accessory1 and 132 or 0); eq(cell.width,44); eq(cell.label.width,40); eq(cell.label.points[1].x,2)
U11 ORIGINAL END]======]
        -- U12 ADAPT U05_GEAR BEGIN
--[========[U12 ORIGINAL BEGIN
        eq(header.width,column==I.Accessory1 and 84 or 0); eq(cell.width,28); eq(cell.label.width,24); eq(cell.label.points[1].x,2)
U12 ORIGINAL END]========]
        eq(header.width,column==I.Accessory1 and 96 or 0); eq(cell.width,column==I.Accessory2 and 28 or 34)
        eq(cell.label.width,cell.width-4); eq(cell.label.points[1].x,2)
        -- U12 ADAPT U05_GEAR END
        -- U11 ADAPT U05_GEAR END
        eq(cell.itemIcon.texturePath,1234); eq(cell.qualityIcon.atlas,"fixture-atlas"); eq(cell.qualityIcon.shown,true)
        eq(cell.fill.style.SetColorTexture[4],0); eq(cell.itemBorder.style.SetBackdropBorderColor[4],1)
        -- U10 ADAPT U05_GEAR END
    end
    eq(ui.headers[I.Name].label.style.SetJustifyH[1],"LEFT"); verify()
    local db=dbWith({accessory1={slot=21,role="accessory1",exists=false,metadataReady=false}})
    local empty=uiFixture(db); eq(empty.widgets[1].cells[I.Accessory1].label:GetText(),"")
    eq(empty.widgets[1].cells[I.Accessory2].label:GetText(),"?")
    eq(empty.widgets[1].cells[I.Accessory1].fill.style.SetColorTexture[4],0)
end)
case("U05 class token shared syntax ASCII and boolean result",function()
    for _,value in ipairs({"MAGE","A",string.rep("Z",32)}) do eq(C.ValidClassToken(value),true) end
    for _,value in ipairs({false,0,{},"","Mage","MAGE1","MAGE_","MAGE ","É",string.rep("A",33),"MAGE\n"}) do
        eq(C.ValidClassToken(value),false)
    end
    eq(C.ValidClassToken(nil),false)
end)
case("U05 own normal scan captures only first UnitClassBase player return and owns token",function()
    local env,s=fixtureAPI(); local calls=0
    env.UnitClassBase=function(unit) eq(unit,"player"); calls=calls+1; return "MAGE",8 end
    local c=NS.Collectors.New(env,C.Open(nil)); assert(c:Scan()); assert(calls>0)
    local saved=c.db.characters[character.guid]; eq(saved.classToken,"MAGE"); eq(saved.classID,nil)
    local r=V.Build(c.db,c.fresh,{},s.at)[1]; eq(r.classToken,"MAGE"); eq(r.cells[I.Name],character.name)
    eq(r.name,character.name); assert(not r.name:find("|",1,true))
    local other={guid="U05-other",name="Other",realm="Other"}; apply(c.db,other,{unspent=0})
    eq(c.db.characters[other.guid].classToken,nil); eq(saved.classToken,"MAGE")
end)
case("U05 optional class missing throwing malformed reads preserve known token on real scans",function(checkpoint)
    local env,s=fixtureAPI(); env.UnitClassBase=function() return "DRUID" end
    local c=NS.Collectors.New(env,C.Open(nil)); assert(c:Scan())
    local variants={false,function() error("optional failure") end,function() return nil end,
        function() return "Druid" end,function() return {} end,function() return string.rep("X",33) end}
    for _,fn in ipairs(variants) do
        env.UnitClassBase=fn or nil; s.at=s.at+1; assert(c:Scan())
        eq(c.db.characters[character.guid].classToken,"DRUID")
        eq(c.db.characters[character.guid].professions[2913].active.scannedAt,s.at)
        pause(checkpoint,"U05 optional class read variant")
    end
    env.UnitClassBase=nil; local fresh=NS.Collectors.New(env,C.Open(nil)); assert(fresh:Scan())
    eq(fresh.db.characters[character.guid].classToken,nil)
end)
case("U05 collector protects shared class validation failure without losing generic scan",function()
    local env=fixtureAPI(); env.UnitClassBase=function() return "MAGE" end
    local c=NS.Collectors.New(env,C.Open(nil)); local original=C.ValidClassToken
    local ok,why=pcall(function()
        C.ValidClassToken=function() error("optional validator fault") end
        assert(c:Scan()); eq(c.db.characters[character.guid].classToken,nil)
    end)
    C.ValidClassToken=original; assert(ok,why)
end)
case("U05 Core invalid explicit class Apply atomic graph preservation and owner isolation",function()
    local db=dbWith({unspent=7}); local c=C.Copy(character); c.classToken="MAGE"; apply(db,c,{unspent=8})
    local other={guid="U05-owner-B",name="Other",realm="Other",classToken="DRUID"}; apply(db,other,{unspent=3})
    for _,token in ipairs({false,1,{},"mage","MAGE1","",string.rep("X",33)}) do
        local verify=unchangedGraph(db); local incoming=C.Copy(c); incoming.classToken=token
        eq(C.Apply(db,incoming,identity,{unspent=C.Observation("observed",99,110,"fixture")},110,"fixture"),nil)
        verify()
    end
    apply(db,character,{unspent=9},120); eq(db.characters[c.guid].classToken,"MAGE")
    eq(db.characters[other.guid].classToken,"DRUID")
end)
case("U05 invalid existing class Open active archived graph-identical no reset",function()
    for _,archived in ipairs({false,true}) do
        local db=dbWith({unspent=0}); if archived then assert(C.Archive(db,character.guid,2913,20,"fixture")) end
        for _,bad in ipairs({false,12,"Mage","",string.rep("A",33)}) do
            db.characters[character.guid].classToken=bad
            local verify=unchangedGraph(db); eq(C.Open(db),nil); verify()
        end
    end
end)
case("U05 class native ColorMixin reload archive and white per-cell recycling",function()
    local db=dbWith(payloadFixtures()); local who=C.Copy(character); who.classToken="MAGE"; apply(db,who,{unspent=0},100)
    local copy=assert(C.Open(C.Copy(db))); local ui,env,c,s=uiFixture(copy)
    local lookups=0; env.C_ClassColor={GetClassColor=function(token)
        eq(token,"MAGE"); lookups=lookups+1; return {GetRGB=function() return .1,.3,.7 end}
    end}
    env.UnitClassBase=function() error("offline class query forbidden") end
    local verify=noWrites(ui,env,c,s); ui:Refresh()
    local cell=ui.widgets[1].cells[I.Name]; rgb(cell.label.style.SetTextColor,{.1,.3,.7})
    for col=2,14 do rgb(ui.widgets[1].cells[col].label.style.SetTextColor,{1,1,1}) end
    eq(ui.rows[1].cells[I.Name],who.name); assert(lookups>0); verify()
    assert(C.Archive(copy,who.guid,2913,120,"fixture")); ui.options.archived=true; ui:Refresh()
    eq(ui.rows[1].classToken,"MAGE"); rgb(cell.label.style.SetTextColor,{.1,.3,.7})
    ui.rows[1].classToken=nil; ui:Render(); rgb(cell.label.style.SetTextColor,{1,1,1})
    ui.rows[1].classToken="MAGE"; env.C_ClassColor.GetClassColor=function() return {r=.2,g=.4,b=.6} end
    ui:Render(); rgb(cell.label.style.SetTextColor,{.2,.4,.6})
end)
case("U05 old DB class neutral and protected malformed color matrix never leaks",function()
    local ui,env=uiFixture(); local cell=ui.widgets[1].cells[I.Name]
    env.C_ClassColor={GetClassColor=function() error("no token must not query") end}
    ui:Render(); rgb(cell.label.style.SetTextColor,{1,1,1})
    ui.rows[1].classToken="MAGE"
    for _,fn in ipairs({function() error("color fault") end,function() return nil end,
        function() return {r=0/0,g=0,b=0} end,function() return {r=1,g=2,b=0} end,
        function() return {r=1,g=0} end,function() return {GetRGB=function() error("RGB fault") end} end,
        function() return setmetatable({},{__index=function() error("color access fault") end}) end,
        function() return {GetRGB=function() return 0,-.1,1 end} end}) do
        env.C_ClassColor.GetClassColor=fn; ui:Render(); rgb(cell.label.style.SetTextColor,{1,1,1})
    end
    ui.rows[1].classToken="mage"; env.C_ClassColor.GetClassColor=function() error("invalid token lookup") end
    ui:Render(); rgb(cell.label.style.SetTextColor,{1,1,1})
end)
case("U05 reused row font reset precedes class apply and neutral next owner",function()
    local ui,env=uiFixture(); local widget=ui.widgets[1]; local calls={}
    for col,cell in ipairs(widget.cells) do
        local column=col; local original=cell.label.SetTextColor
        cell.label.SetTextColor=function(self,...)
            calls[#calls+1]={column,{...}}; return original(self,...)
        end
    end
    env.C_ClassColor={GetClassColor=function() return {r=.4,g=.5,b=.6} end}
    ui.rows[1].classToken="MAGE"; ui:Render()
    eq(#calls,15); eq(calls[1][1],I.Name); rgb(calls[1][2],{1,1,1})
    eq(calls[2][1],I.Name); rgb(calls[2][2],{.4,.5,.6})
    for n=3,15 do eq(calls[n][1],n-1); rgb(calls[n][2],{1,1,1}) end
    ui.rows[1].guid="different-owner"; ui.rows[1].classToken=nil; calls={}; ui:Render()
    eq(ui.widgets[1],widget); rgb(widget.cells[I.Name].label.style.SetTextColor,{1,1,1})
    eq(#calls,15); for _,call in ipairs(calls) do rgb(call[2],{1,1,1}) end
end)
local function sortDB()
    local db=C.Open(nil)
    for _,variant in ipairs({"low","high","tie","unknown"}) do
        local high=variant=="high"; local unknown=variant=="unknown"
        local who={guid="U05-"..variant,name=unknown and "Middle" or high and "zeta" or "Alpha",
            realm=unknown and "Middle" or high and "zeta" or "Alpha",classToken=high and "MAGE" or "DRUID"}
        local id=C.Copy(identity); id.name=who.name
        local values={}
        if not unknown then
            values={skill={skillLevel=high and 90 or 2,maxSkillLevel=100,skillModifier=0},
                concentration={id=50001,quantity=high and 900 or 10,maxQuantity=1000},
                moxie={id=3261,quantity=high and 900 or 10},unspent=high and 90 or 2,
                knowledgeIndex={{id=11,name="same",root=111},{id=12,name="same",root=112}},
                ["tree:11"]=treeValue(11,high and 7 or 1,10),["tree:12"]=treeValue(12,high and 0 or 9,high and 2 or 90)}
            for n,role in ipairs(V.roles) do
                values[role]={slot=({21,22,20})[n],role=role,exists=true,metadataReady=true,
                    itemID=90000+n,link="item:"..(90000+n)..":0:0",rarity=high and 4 or 2,rank=high and 5 or 1}
            end
            values.tool.stats={[high and "ITEM_MOD_RESOURCEFULNESS_SHORT" or "ITEM_MOD_CRAFTING_SPEED_SHORT"]=1}
            values.tool.enchant={status="observed",present=true,id=high and 7977 or 8033,
                category=high and "Resourcefulness" or "Deftness"}
        end
        apply(db,who,values,high and 90 or 10,id)
    end
    return db
end
for column,label in ipairs(V.columns) do
    local col=column
    case("U05 typed heading both directions active archived "..label,function()
        local db=sortDB(); local text=col<=I.Profession
        for _,archived in ipairs({false,true}) do
            if archived then
                for guid in pairs(db.characters) do assert(C.Archive(db,guid,2913,120,"fixture")) end
            end
            local verify=unchangedGraph(db)
            for _,descending in ipairs({false,true}) do
                local rows=V.Build(db,{}, {sortColumn=col,sortDescending=descending,archived=archived},100000)
                eq(#rows,4)
                if text then
                    eq(rows[1].guid,descending and "U05-high" or "U05-low")
                    eq(rows[4].guid,descending and "U05-tie" or "U05-high")
                elseif col==I.LastUpdated then
                    eq(rows[1].guid,descending and "U05-high" or "U05-low")
                    eq(rows[4].guid,descending and "U05-unknown" or "U05-high")
                else
                    eq(rows[1].guid,descending and "U05-high" or "U05-low")
                    eq(rows[4].guid,"U05-unknown","unknown last in either direction")
                    local lowPosition=descending and 2 or 1
                    eq(rows[lowPosition].guid,"U05-low"); eq(rows[lowPosition+1].guid,"U05-tie")
                end
            end
            verify()
        end
    end)
end
case("U05 typed numeric zero unknown incomplete Knowledge never borrows raw or skill",function()
    local db=sortDB(); local unknown=db.characters["U05-unknown"]
    apply(db,{guid="U05-zero",name="Zero",realm="Zero"},{skill={skillLevel=0,maxSkillLevel=100,skillModifier=0},
        moxie={id=3261,quantity=0},concentration={id=50001,quantity=0,maxQuantity=1000},unspent=0,
        knowledgeIndex={{id=11,root=111}},["tree:11"]=treeValue(11,0,10)})
    for _,col in ipairs({I.Skill,I.Moxie,I.Concentration,I.Unspent,I.Knowledge}) do
        for _,desc in ipairs({false,true}) do
            local rows=V.Build(db,{}, {sortColumn=col,sortDescending=desc},100)
            eq(rows[#rows].guid,"U05-unknown"); eq(rows[desc and #rows-1 or 1].guid,"U05-zero")
        end
    end
    apply(db,{guid="U05-unknown",name=unknown.name,realm=unknown.realm},
        {skill={skillLevel=100,maxSkillLevel=100,skillModifier=0},knowledgeRaw=scan(),
        knowledgeIndex={{id=11,root=111},{id=12,root=112}},["tree:11"]=treeValue(11,10,10)})
    local rows=V.Build(db,{}, {sortColumn=I.Knowledge},100)
    eq(rows[#rows].guid,"U05-unknown"); eq(rows[#rows].sortValues[I.Knowledge],nil)
    local low=V.Build(db,{}, {character="U05-low"},100)[1]; eq(low.sortValues[I.Knowledge],.1)
end)
case("U05 Knowledge weighted full evidence zero capacity and no trees remain unknown",function()
    local values={skill={skillLevel=100,maxSkillLevel=100,skillModifier=0},
        knowledgeIndex={{id=11,root=111},{id=12,root=112}},
        ["tree:11"]=treeValue(11,9,10),["tree:12"]=treeValue(12,0,90)}
    local db=dbWith(values); local row=V.Build(db,{}, {},100)[1]
    eq(row.sortValues[I.Knowledge],.09,"weighted sum not average ratios or skill")
    values["tree:12"]=treeValue(12,0,0)
    row=V.Build(dbWith(values),{}, {},100)[1]; eq(row.sortValues[I.Knowledge],nil)
    row=V.Build(dbWith({skill=values.skill,knowledgeRaw=scan()}),{}, {},100)[1]
    eq(row.sortValues[I.Knowledge],nil); eq(#row.trees,0)
end)
case("U05 gear rarity rank empty unknown text components and newest timestamp keys",function()
    local db=C.Open(nil)
    local variants={
        {"epic",{exists=true,rarity=4,rank=1}}, {"rareHigh",{exists=true,rarity=3,rank=5}},
        {"rareLow",{exists=true,rarity=3,rank=1}}, {"empty",{exists=false}}, {"unknown",{exists=true,rarity=4}},
    }
    for n,sample in ipairs(variants) do
        local values={}
        for m,role in ipairs(V.roles) do
            local value=C.Copy(sample[2]); value.role=role; value.slot=({21,22,20})[m]
            value.metadataReady=false; values[role]=value
        end
        apply(db,{guid=sample[1],name=sample[1],realm="test"},values,n*60)
    end
    for _,column in ipairs({I.Accessory1,I.Accessory2,I.Tool}) do
        for _,desc in ipairs({false,true}) do
            local rows=V.Build(db,{}, {sortColumn=column,sortDescending=desc},10000)
            local order=desc and {"epic","rareHigh","rareLow","empty","unknown"} or {"empty","rareLow","rareHigh","epic","unknown"}
            for n,guid in ipairs(order) do eq(rows[n].guid,guid) end
        end
    end
    local values=payloadFixtures(); values.tool.stats={ITEM_MOD_MULTICRAFT_SHORT=0,ITEM_MOD_UNMAPPED_SHORT=0}
    values.tool.enchant={status="observed",present=true,id=999}
    local bad=dbWith(values); local row=V.Build(bad,{}, {},100)[1]
    eq(row.sortValues[I.Stat],nil); eq(row.sortValues[I.Enchant],nil)
    local empty=V.Build(db,{}, {character="empty"},100)[1]
    eq(empty.sortValues[I.Stat],""); eq(empty.sortValues[I.Enchant],"")
    local newest=V.Build(db,{}, {sortColumn=I.LastUpdated,sortDescending=true},100000)[1]
    eq(newest.guid,"unknown"); eq(newest.sortValues[I.LastUpdated],300)
end)
case("U05 tie breaks guid profession generation and invalid heading retains legacy sort",function()
    local db=dbWith({unspent=0})
    local synthetic=C.Copy(identity); synthetic.skillLineID=99999
    apply(db,character,{unspent=0},10,synthetic)
    assert(C.Archive(db,character.guid,2913,20,"fixture")); apply(db,character,{unspent=0},10)
    assert(C.Archive(db,character.guid,2913,21,"fixture"))
    local rows=V.Build(db,{}, {sortColumn=I.Unspent,archived=true},100)
    eq(rows[1].generation,1); eq(rows[2].generation,2)
    local both=C.Copy(db); apply(both,character,{unspent=0},10)
    rows=V.Build(both,{}, {sortColumn=I.Unspent},100); eq(rows[1].id,2913); eq(rows[2].id,99999)
    local sorted=sortDB()
    for _,column in ipairs({0,15,1.5,"1",false}) do
        eq(V.Build(sorted,{}, {sortColumn=column,sort="moxie"},100)[1].guid,"U05-high")
    end
    eq(V.Build(sorted,{}, {},100)[1].guid,"U05-high","default attention-first unchanged")
    for _,mode in ipairs({"concentration","moxie","enchant","progression","attention"}) do
        eq(#V.Build(sorted,{}, {sort=mode},100),4)
    end
end)
case("U05 all14 header buttons defaults toggles canonical hovers offset selection rebind",function()
    local ui,env,c,s=uiFixture(sortDB()); local verify=noWrites(ui,env,c,s)
    eq(ui.sort,nil); eq(ui.options.sortColumn,nil)
    -- U10 ADAPT U05_UI_HEADERS BEGIN
--[====[U10 ORIGINAL BEGIN
    for col,header in ipairs(ui.headers) do
        local chosen=ui.rows[1]; ui.selected=chosen; ui.offset=99
        eq(header.kind,"Button"); click(header); eq(ui.offset,0); eq(ui.options.sortColumn,col)
        eq(ui.options.sortDescending,V.SortDescending(col)); eq(ui.selected.key,chosen.key)
        assert(ui.selected~=chosen,"selection rebound to new pure row")
        eq(header.direction:GetText(),V.SortDescending(col) and "v" or "^")
        eq(header.label:GetText(),col==I.Accessory1 and "A1" or col==I.Accessory2 and "A2" or V.columns[col])
        header.scripts.OnEnter(header); eq(env.GameTooltip.lines[1],V.columns[col])
        click(header); eq(ui.options.sortDescending,not V.SortDescending(col))
    end
U10 ORIGINAL END]====]
    local sortedHeaders=0
    for col,header in ipairs(ui.headers) do
        if col>=5 and col<=9 then
            eq(header.kind,"Frame"); eq(header.scripts.OnClick,nil); eq(header.direction:GetText(),"")
            eq(header.shown,col==5); eq(header.label:GetText(),col==5 and "Gear" or V.columns[col])
            ui.options.sortColumn=col; ui.options.sortDescending=true; ui:Refresh()
            eq(ui.options.sortColumn,nil); eq(ui.options.sortDescending,nil)
        else
            sortedHeaders=sortedHeaders+1
            local chosen=ui.rows[1]; ui.selected=chosen; ui.offset=99
            eq(header.kind,"Button"); click(header); eq(ui.offset,0); eq(ui.options.sortColumn,col)
            eq(ui.options.sortDescending,V.SortDescending(col)); eq(ui.selected.key,chosen.key)
            assert(ui.selected~=chosen,"selection rebound to new pure row")
            eq(header.direction:GetText(),V.SortDescending(col) and "v" or "^")
            eq(header.label:GetText(),V.columns[col])
            header.scripts.OnEnter(header); eq(env.GameTooltip.lines[1],V.columns[col])
            click(header); eq(ui.options.sortDescending,not V.SortDescending(col))
        end
    end
    eq(sortedHeaders,9)
    -- U10 ADAPT U05_UI_HEADERS END
    click(ui.headers[I.Name]); eq(ui.options.sortDescending,false)
    verify()
end)
case("U05 historical marker no tilde retains boundaries fresh stale timestamps diagnostics",function()
    local values=payloadFixtures(); values.moxie.quantity=601; values.concentration={id=50001,quantity=900,maxQuantity=1000}
    local db,g=dbWith(values); local session={[character.guid..":2913"]={generation=1,fields={moxie=true,concentration=true}}}
    -- U13 ADAPT MODEL_PRIORITY BEGIN
--[==========[U13 ORIGINAL BEGIN
    local row=V.Build(db,session,{},100)[1]; eq(row.cells[I.Moxie],"|cffffbb00!|r 601"); eq(row.priority,1)
    row=V.Build(db,{}, {},100)[1]; eq(row.cells[I.Moxie],"|cff999999!|r 601"); eq(row.priority,2)
U13 ORIGINAL END]==========]
    local row=V.Build(db,session,{},100)[1]; eq(row.cells[I.Moxie],"601"); eq(row.priority,1)
    row=V.Build(db,{}, {},100)[1]; eq(row.cells[I.Moxie],"601"); eq(row.priority,2)
    -- U13 ADAPT MODEL_PRIORITY END
    local before=g.fields.moxie.last.observedAt
    C.Apply(db,character,identity,{moxie=C.Observation("error",nil,20,"fixture","transient")},20,"fixture")
    -- U13 ADAPT MODEL_STALE BEGIN
--[==========[U13 ORIGINAL BEGIN
    row=V.Build(db,session,{},100)[1]; eq(row.cells[I.Moxie],"|cff999999!|r 601")
U13 ORIGINAL END]==========]
    row=V.Build(db,session,{},100)[1]; eq(row.cells[I.Moxie],"601")
    -- U13 ADAPT MODEL_STALE END
    local _,state=V.Field(db.characters[character.guid].professions[2913].active,"moxie",session[character.guid..":2913"])
    eq(state.fresh,false); eq(state.stale,true); eq(state.observedAt,before); assert(state.text:find("snapshot/last observed",1,true))
    assert(table.concat(row.tooltip,"\n"):find("last observed Moxie",1,true))
    apply(db,character,{moxie={id=3261,quantity=600},concentration={id=50001,quantity=899,maxQuantity=1000}},30)
    row=V.Build(db,{}, {},100)[1]; eq(row.cells[I.Moxie],"600"); eq(row.cells[I.Concentration],"899/1000")
end)
case("U05 generated Attention View all options combined filters no snapshot or collection effects",function()
    local db=sortDB(); for guid in pairs(db.characters) do
        assert(C.Archive(db,guid,2913,100,"fixture"))
        apply(db,{guid=guid,name=db.characters[guid].name,realm=db.characters[guid].realm},{unspent=0},110)
    end
    -- Active warning-bearing rows and archived rows are independently selectable.
    local ui,env,c,s=uiFixture(sortDB()); local verify=noWrites(ui,env,c,s)
    eq(ui.attention.kind,"DropdownButton"); eq(ui.archived.kind,"DropdownButton")
    eq(ui.attention.template,"WowStyle1DropdownTemplate"); eq(#ui.attention.radios,5); eq(#ui.archived.radios,2)
    for _,label in ipairs({"Concentration","Moxie","Missing enchant","Progression","All"}) do
        ui.offset=99; local selected=ui.rows[1]; ui.selected=selected
        radio(ui.attention,label=="Progression" and "Skill below max" or label); eq(ui.options.attention,label); eq(ui.offset,0); eq(ui.attention.selectedText,label=="Progression" and "Skill below max" or label)
        for _,row in ipairs(ui.rows) do
            if label~="All" then local found=false; for _,w in ipairs(row.warnings) do if w.category==label then found=true end end; eq(found,true) end
        end
    end
    ui.filters.character:SetText("Alpha"); ui.filters.character.scripts.OnTextChanged(ui.filters.character)
    radio(ui.professionDropdown,"Inscription"); eq(#ui.rows,2)
    radio(ui.attention,"Moxie"); eq(#ui.rows,0)
    radio(ui.attention,"All"); radio(ui.professionDropdown,"All professions"); eq(#ui.rows,2)
    verify()
    local archived,ae,ac,as=uiFixture(db); local av=noWrites(archived,ae,ac,as)
    for _,label in ipairs({"All","Concentration","Moxie","Missing enchant","Progression"}) do
        radio(archived.attention,label=="Progression" and "Skill below max" or label); archived.selected=archived.rows[1]; archived.offset=99
        radio(archived.archived,"Archived"); eq(archived.options.archived,true); eq(archived.selected,nil); eq(archived.offset,0)
        eq(archived.archived.selectedText,"Archived"); eq(#archived.rows,label=="All" and 4 or 0)
        radio(archived.archived,"Active"); eq(archived.options.archived,false); eq(archived.selected,nil)
    end
    av()
end)
for _,flag in ipairs({"fixtureNoDropdownCreation","fixtureNoSetup","fixtureNoDefaultText","fixtureSetupError","fixtureNoCreateRadio","fixtureRadioError"}) do
    local failure=flag
    case("U05 native menus explained safe fallback "..flag,function()
        local ui,env,c,s=uiFixture(nil,{[failure]=true}); local verify=noWrites(ui,env,c,s)
        for _,alias in ipairs({"attention","archived"}) do
            eq(ui[alias.."Menu"].available,false); eq(ui[alias].kind,"Frame"); eq(ui[alias].shown,true)
            eq(ui[alias].scripts.OnClick,nil); ui[alias].scripts.OnEnter(ui[alias])
            assert(env.GameTooltip.lines[1]:find("unavailable",1,true))
        end
        eq(ui.options.attention,"All"); eq(ui.options.archived,false); verify()
    end)
end
case("U05 delayed native menu failure invalidates stale radios and resets hidden state",function()
    for _,alias in ipairs({"attention","archived"}) do
        local ui,env,c,s=uiFixture(sortDB()); local verify=noWrites(ui,env,c,s)
        local dropdown=ui[alias]; local item=dropdown.radios[2]
        item:Click(); ui.offset=99; ui.selected=ui.rows[1]
        env.fixtureRadioError=true; dropdown:fixtureGenerate()
        eq(ui[alias.."Menu"].available,false); eq(dropdown.shown,false); eq(ui[alias].shown,true)
        eq(ui.offset,0); item.onSelect(item.data)
        eq(ui.options.attention or "All","All"); eq(ui.options.archived or false,false)
        if alias=="archived" then eq(ui.selected,nil) end
        verify()
    end
end)
case("U05 SetDefaultText selection error protected fallback stale callback cannot restore",function()
    local ui,env,c,s=uiFixture(); local verify=noWrites(ui,env,c,s)
    local dropdown=ui.attention; local item=dropdown.radios[3]
    dropdown.SetDefaultText=function() error("late native text fault") end
    item.onSelect(item.data); eq(ui.attentionMenu.available,false); eq(ui.options.attention,"All")
    item.onSelect(item.data); eq(ui.options.attention,"All"); verify()
end)
case("U05 flat chrome HIGH title close drag safe raise owned Details only combat defer",function()
    local ui,env,c,s=uiFixture(); local verify=noWrites(ui,env,c,s); local frame=ui.frame
    -- U08 CHROME BEGIN
    do
        local icon=assert(ui.titleIcon,"U08 missing title icon")
        eq(icon.kind,"Texture"); eq(icon.parent,frame); eq(icon.drawLayer,"ARTWORK")
        eq(icon.texturePath,"Interface\\AddOns\\CraftArmy\\Media\\Icons\\CraftArmy.tga")
        eq(icon.width,22); eq(icon.height,22); eq(icon.shown,true)
        eq(icon.allPoints,nil); eq(icon.style.SetColorTexture,nil)
        eq(icon.style.SetTextColor,nil); eq(icon.style.EnableMouse,nil); eq(next(icon.scripts),nil)
        eq(rawget(icon,"SetTexCoord"),nil); eq(rawget(icon,"SetVertexColor"),nil)
        local function countIcons()
            local n=0
            for _,w in ipairs(env.fixtureWidgets) do
                if w.texturePath==icon.texturePath then n=n+1 end
            end
            return n
        end
        eq(countIcons(),1); ui:Refresh(); click(ui.close); ui:Toggle()
        eq(ui.titleIcon,icon); eq(countIcons(),1); verify()
        -- Fail only the first dashboard-owned texture, using isolated fixture overrides.
        for _,mode in ipairs({"load false","load nil","load throw","create nil","create throw",
            "size throw","anchor throw","cleanup throw"}) do
            local e,state=fixtureAPI(); mockWidgets(e)
            local collector=NS.Collectors.New(e,dbWith(payloadFixtures()))
            local fallback=NS.Dashboard.New(e,collector)
            local unchanged=noWrites(fallback,e,collector,state)
            local create=e.CreateFrame; local attempted,decoration=0,nil
            e.CreateFrame=function(kind,name,parent,template)
                local w=create(kind,name,parent,template)
                if template=="BackdropTemplate" and parent==e.UIParent then
                    local texture=w.CreateTexture
                    w.CreateTexture=function(owner,...)
                        attempted=attempted+1
                        if attempted==1 then
                            if mode=="create nil" then return nil end
                            if mode=="create throw" then error("U08 fixture creation fault") end
                            decoration=texture(owner,...)
                            decoration.SetTexture=function()
                                if mode=="load nil" then return nil end
                                if mode=="load throw" then error("U08 fixture texture fault") end
                                return false
                            end
                            if mode=="size throw" then decoration.SetSize=function() error("U08 fixture size fault") end end
                            if mode=="anchor throw" then decoration.SetPoint=function() error("U08 fixture anchor fault") end end
                            if mode=="cleanup throw" then
                                decoration.Hide=function(self) self.shown=false; error("U08 fixture cleanup fault") end
                            end
                            return decoration
                        end
                        return texture(owner,...)
                    end
                end
                return w
            end
            fallback:Toggle(); eq(attempted,1,mode.." attempted once")
            eq(fallback.frame.shown,true); eq(#fallback.rows,1); eq(fallback.titleIcon,nil)
            eq(fallback.title.points[1].x,15); eq(fallback.title.points[1].y,-8)
            -- U10 ADAPT U08_FALLBACK_WIDTH BEGIN
--[====[U10 ORIGINAL BEGIN
            eq(fallback.title.width,1394); eq(fallback.title:GetText(),"CraftArmy — observed crafting snapshots")
U10 ORIGINAL END]====]
            -- U11 ADAPT U08_FALLBACK BEGIN
--[======[U11 ORIGINAL BEGIN
            eq(fallback.title.width,1144); eq(fallback.title:GetText(),"CraftArmy — observed crafting snapshots")
U11 ORIGINAL END]======]
            -- U12 ADAPT U08_FALLBACK BEGIN
--[========[U12 ORIGINAL BEGIN
            eq(fallback.title.width,1096); eq(fallback.title:GetText(),"CraftArmy — observed crafting snapshots")
U12 ORIGINAL END]========]
            eq(fallback.title.width,1108); eq(fallback.title:GetText(),"CraftArmy — observed crafting snapshots")
            -- U12 ADAPT U08_FALLBACK END
            -- U11 ADAPT U08_FALLBACK END
            -- U10 ADAPT U08_FALLBACK_WIDTH END
            if decoration then eq(decoration.shown,false,mode.." hides failed texture") end
            eq(fallback.frame.style.SetFrameStrata[1],"HIGH")
            fallback.frame.scripts.OnDragStart(fallback.frame); assert(fallback.frame.style.StartMoving)
            fallback.frame.scripts.OnDragStop(fallback.frame); assert(fallback.frame.style.StopMovingOrSizing)
            fallback:Refresh(); click(fallback.close); fallback:Toggle(); eq(attempted,1)
            unchanged()
        end
        for _,unknown in ipairs({false,true}) do
            local e,state=fixtureAPI(); mockWidgets(e)
            if unknown then e.InCombatLockdown=function() return nil end else state.combat=true end
            local delayed=NS.Dashboard.New(e,NS.Collectors.New(e,dbWith(payloadFixtures())))
            delayed:Toggle(); eq(delayed.frame,nil); eq(delayed.titleIcon,nil); eq(delayed.wantOpen,true)
            e.InCombatLockdown=function() return false end
            delayed:Toggle(); assert(delayed.titleIcon); eq(delayed.titleIcon.parent,delayed.frame)
        end
    end
    -- U08 CHROME END
    eq(frame.template,"BackdropTemplate"); eq(frame.TitleText,nil); eq(frame.style.SetFrameStrata[1],"HIGH")
    eq(frame.style.SetToplevel[1],true); rgb(frame.style.SetBackdropColor,{.055,.065,.085})
    eq(frame.style.SetBackdropColor[4],.98); rgb(frame.style.SetBackdropBorderColor,{.18,.21,.26})
    eq(frame.style.SetBackdropBorderColor[4],1); eq(frame.style.SetBackdrop[1].edgeSize,1)
    eq(frame.style.SetBackdrop[1].bgFile,"Interface\\Buttons\\WHITE8X8")
    eq(frame.style.SetBackdrop[1].edgeFile,"Interface\\Buttons\\WHITE8X8")
    eq(ui.title:GetText(),"CraftArmy — observed crafting snapshots"); eq(ui.close:GetText(),"X")
    frame.scripts.OnShow(frame); assert(frame.style.Raise); frame.scripts.OnMouseDown(frame)
    frame.scripts.OnDragStart(frame); assert(frame.style.StartMoving); frame.scripts.OnDragStop(frame); assert(frame.style.StopMovingOrSizing)
    click(ui.close); eq(frame.shown,false); ui:Toggle(); eq(frame.shown,true)
    local unrelated=env.CreateFrame("Frame",nil,env.UIParent); eq(unrelated.style.SetFrameStrata,nil)
    -- Exercise the real existing Details view with only its existing fixture API.
    local create=env.CreateFrame
    env.CreateFrame=function(...)
        local w=create(...)
        w.SetTextInsets=function(self,...) self.insets={...} end
        w.EnableKeyboard=function(self,value) self.keyboard=value end
        w.SetPropagateKeyboardInput=function(self,value) self.propagate=value end
        w.SetEnabled=function(self,value) self.enabled=value end
        w.SetVerticalScroll=function(self,value) self.scrollOffset=value end
        return w
    end
    local profession=ui.widgets[1].cells[I.Profession]; profession.scripts.OnMouseDown(profession,"LeftButton")
    assert(ui.details.frame.shown); eq(ui.details.frame.style.SetFrameStrata[1],"DIALOG"); assert(ui.details.frame.style.Raise)
    eq(unrelated.style.SetFrameStrata,nil); eq(frame.style.SetFrameStrata[1],"HIGH"); verify()
    local combatEnv,state=fixtureAPI(); mockWidgets(combatEnv); state.combat=true
    local deferred=NS.Dashboard.New(combatEnv,NS.Collectors.New(combatEnv,dbWith({unspent=0})))
    deferred:Toggle(); eq(deferred.frame,nil); eq(deferred.wantOpen,true)
end)
case("U05 toolbar native decorations nonoverlap unchanged geometry fit and confirmation reuse",function()
    local ui,env,c,s=uiFixture(); local verify=noWrites(ui,env,c,s)
    -- U08 GEOMETRY BEGIN
    do
        local title=env.fixtureRect(ui.title)
        eq(title.x,43,"U08 title must leave icon plus six-pixel gap"); eq(title.y,8)
        -- U10 ADAPT U08_TITLE_WIDTH BEGIN
--[====[U10 ORIGINAL BEGIN
        eq(title.w,1366); eq(title.h,14); eq(title.x+title.w,1409)
U10 ORIGINAL END]====]
        -- U11 ADAPT U08_TITLE BEGIN
--[======[U11 ORIGINAL BEGIN
        eq(title.w,1116); eq(title.h,14); eq(title.x+title.w,1159)
U11 ORIGINAL END]======]
        -- U12 ADAPT U08_TITLE BEGIN
--[========[U12 ORIGINAL BEGIN
        eq(title.w,1068); eq(title.h,14); eq(title.x+title.w,1111)
U12 ORIGINAL END]========]
        eq(title.w,1080); eq(title.h,14); eq(title.x+title.w,1123)
        -- U12 ADAPT U08_TITLE END
        -- U11 ADAPT U08_TITLE END
        -- U10 ADAPT U08_TITLE_WIDTH END
        local icon=assert(ui.titleIcon,"U08 geometry missing icon")
        local function geometry()
            local r,t,close,status=env.fixtureRect(icon),env.fixtureRect(ui.title),env.fixtureRect(ui.close),env.fixtureRect(ui.statusArea)
            eq(r.x,15); eq(r.y,5); eq(r.w,22); eq(r.h,22)
            eq(icon.points[1].point,"TOPLEFT"); eq(icon.points[1].relative,ui.frame)
            eq(icon.points[1].anchor,"TOPLEFT"); eq(#icon.points,1)
            -- U10 ADAPT U08_CLOSE_GEOMETRY BEGIN
--[====[U10 ORIGINAL BEGIN
            eq(t.x-r.x-r.w,6); eq(t.x+t.w,1409)
            eq(close.x,1417); eq(close.y,5); eq(close.w,22)
U10 ORIGINAL END]====]
            -- U11 ADAPT U08_CLOSE BEGIN
--[======[U11 ORIGINAL BEGIN
            eq(t.x-r.x-r.w,6); eq(t.x+t.w,1159)
            eq(close.x,1167); eq(close.y,5); eq(close.w,22)
U11 ORIGINAL END]======]
            -- U12 ADAPT U08_CLOSE BEGIN
--[========[U12 ORIGINAL BEGIN
            eq(t.x-r.x-r.w,6); eq(t.x+t.w,1111)
            eq(close.x,1119); eq(close.y,5); eq(close.w,22)
U12 ORIGINAL END]========]
            eq(t.x-r.x-r.w,6); eq(t.x+t.w,1123)
            -- U13 ADAPT U08_CLOSE BEGIN
--[==========[U13 ORIGINAL BEGIN
            eq(close.x,1131); eq(close.y,5); eq(close.w,22)
U13 ORIGINAL END]==========]
            eq(close.x,1147); eq(close.y,5); eq(close.w,22)
            -- U13 ADAPT U08_CLOSE END
            -- U12 ADAPT U08_CLOSE END
            -- U11 ADAPT U08_CLOSE END
            -- U10 ADAPT U08_CLOSE_GEOMETRY END
            assert(t.x+t.w<=close.x and r.y+r.h<status.y and t.y+t.h<status.y,"U08 titlebar nonoverlap")
            -- U10 ADAPT U08_STATUS_WIDTH BEGIN
--[====[U10 ORIGINAL BEGIN
            eq(status.x,15); eq(status.y,31); eq(status.w,1424)
U10 ORIGINAL END]====]
            -- U11 ADAPT U08_STATUS BEGIN
--[======[U11 ORIGINAL BEGIN
            eq(status.x,15); eq(status.y,31); eq(status.w,1174)
U11 ORIGINAL END]======]
            -- U12 ADAPT U08_STATUS BEGIN
--[========[U12 ORIGINAL BEGIN
            eq(status.x,15); eq(status.y,31); eq(status.w,1126)
U12 ORIGINAL END]========]
            eq(status.x,15); eq(status.y,31); eq(status.w,1138)
            -- U12 ADAPT U08_STATUS END
            -- U11 ADAPT U08_STATUS END
            -- U10 ADAPT U08_STATUS_WIDTH END
            eq(ui.title:GetText(),"CraftArmy — observed crafting snapshots")
            eq(ui.titleIcon,icon)
        end
        geometry()
        local width,height=env.UIParent.width,env.UIParent.height
        env.UIParent.width=800; env.UIParent.height=300; ui:Refresh(); geometry()
        assert(ui.frame.width*ui.frame.scale<=770 and ui.frame.height*ui.frame.scale<=270)
        click(ui.close); ui:Toggle(); geometry()
        env.UIParent.width=width; env.UIParent.height=height; ui:Refresh(); geometry(); verify()
    end
    -- U08 GEOMETRY END
    -- U10 ADAPT U05_TOOLBAR_FRAME BEGIN
--[====[U10 ORIGINAL BEGIN
    eq(ui.frame.width,1454); eq(ui.viewport.width,1424); eq(ui.frame.height,216)
U10 ORIGINAL END]====]
    -- U11 ADAPT U05_TOOLBAR BEGIN
--[======[U11 ORIGINAL BEGIN
    eq(ui.frame.width,1204); eq(ui.viewport.width,1174); eq(ui.frame.height,226)
U11 ORIGINAL END]======]
    -- U12 ADAPT U05_TOOLBAR BEGIN
--[========[U12 ORIGINAL BEGIN
    eq(ui.frame.width,1156); eq(ui.viewport.width,1126); eq(ui.frame.height,222)
U12 ORIGINAL END]========]
    -- U13 ADAPT U05_WINDOW BEGIN
--[==========[U13 ORIGINAL BEGIN
    eq(ui.frame.width,1168); eq(ui.viewport.width,1138); eq(ui.frame.height,222)
U13 ORIGINAL END]==========]
    eq(ui.frame.width,1184); eq(ui.viewport.width,1138); eq(ui.frame.height,222)
    -- U13 ADAPT U05_WINDOW END
    -- U12 ADAPT U05_TOOLBAR END
    -- U11 ADAPT U05_TOOLBAR END
    -- U10 ADAPT U05_TOOLBAR_FRAME END
    local expected={{ui.toolbar[1],15,60,76},{ui.attention,115,55,176},{ui.archived,315,55,126}}
    local right=0
    for _,entry in ipairs(expected) do
        local widget=entry[1]; local r=env.fixtureRect(widget)
        eq(r.x,entry[2]); eq(r.y,entry[3]); eq(r.w,entry[4]); assert(r.x>=right)
        if widget.Background then
            local b=env.fixtureRect(widget.Background); eq(b.x,r.x-8); eq(b.y,r.y-7)
            assert(b.y>=47 and b.y+b.h<=96); assert(b.x>=right); right=b.x+b.w
        else right=r.x+r.w end
    end
    local filter=env.fixtureRect(ui.filters.character); assert(filter.x-76>=right)
    eq(ui.headers[1].points[1].y,-96); eq(ui.viewport.points[1].y,-118)
    local pool=ui.widgets[1]; env.UIParent.width=800; env.UIParent.height=300; ui:Refresh()
    assert(ui.frame.width*ui.frame.scale<=770); assert(ui.frame.height*ui.frame.scale<=270)
    eq(ui.widgets[1],pool); eq(#ui.widgets,12); eq(env.UIParent.scale,1)
    ui:Confirm({guid=character.guid,id=2913,generation=1},"delete","scope"); eq(ui.confirmPanel.shown,true)
    click(ui.confirmButtons[2]); eq(ui.confirmPanel.shown,false); verify()
end)
end
-- U05 END

-- S01 BEGIN
do
local S,V=NS.Storage,NS.ViewModel
local register=case
local function case(title,fn)
    register(title,function(checkpoint,annotate)
        local units=0
        fn(function(label)
            units=units+1
            if units%64==0 then pause(checkpoint,"S01 grouped NEW fixture work: "..tostring(label)) end
        end,annotate)
    end)
end
local cache,inputs
local function oldCase(title)
    for _,entry in ipairs(Tests.cases) do if entry.name==title then return entry.fn end end
    error("Missing retained fixture "..title)
end
local function seed()
    if not cache then
        local original=C.Apply; local last; local packs={}
        local ok,why=pcall(function()
            C.Apply=function(db,who,id,obs,at,build)
                local g,err=original(db,who,id,obs,at,build)
                if g then last=db; packs[#packs+1]=assert(C.Copy({who,id,obs,at,build})) end
                return g,err
            end
            -- No checkpoint, yield or output while the temporary observer is installed.
            oldCase("K09 combined eight complete native-derived snapshots unchanged50000 budget")()
        end)
        C.Apply=original; assert(ok,why); cache=assert(C.Copy(last)); inputs=packs; eq(#inputs,8)
    end
    return assert(C.Copy(cache)),inputs
end
local function finish(job,checkpoint)
    local units=0
    while job.status=="running" do
        job:Step(); units=units+1
        if units%16==0 then pause(checkpoint,"S01 sixteen bounded "..tostring(job.phase or "unit").." units") end
    end
    return job
end
local function opened(raw,checkpoint)
    local job=finish(S.NewOpenJob(raw),checkpoint)
    eq(job.status,"complete",job.reason); eq(job.completed,true); assert(S.IsHandle(job.result))
    assert(job.work.maxEdges<=128 and job.work.maxUnits<=1)
    return job.result,job.savedRoot,job
end
local function applyPack(db,p,guid,at)
    local who=assert(C.Copy(p[1])); if guid then who.guid=guid end
    local g,why=S.Apply(db,who,p[2],p[3],at or p[4],p[5]); assert(g,why); return g
end
local function visits(v)
    local n=1; if type(v)=="table" then for _,x in pairs(v) do n=n+visits(x) end end; return n
end
local function count(t) local n=0; for _ in pairs(t) do n=n+1 end; return n end
local function frozen(root)
    local records={}
    local function visit(t)
        if type(t)~="table" or records[t] then return end
        local r={meta=getmetatable(t),entries={}}; records[t]=r
        for k,v in pairs(t) do r.entries[k]=v; visit(v) end
    end
    visit(root)
    return function()
        for t,r in pairs(records) do
            eq(getmetatable(t),r.meta)
            for k,v in pairs(r.entries) do
                local actual=rawget(t,k)
                assert(actual==v or (type(v)=="number" and type(actual)=="number" and v~=v and actual~=actual),"S01 graph changed")
            end
            for k in pairs(t) do assert(r.entries[k]~=nil,"S01 added key") end
        end
    end
end
local function build(db,opts,checkpoint)
    local j=finish(V.NewBuildJob(db,{},opts or {},400),checkpoint)
    eq(j.status,"complete",j.reason); eq(j.completed,true); assert(j.work.maxOperations<=128)
    return j.rows,j
end
case("S01 private handle empty initialization and actual schema1 facade compatibility",function()
    local h,root=S.New(); assert(S.IsHandle(h)); eq(root.schema,2); eq(S.IsHandle(root),false)
    eq(S.Check(h),h); eq(S.Check(root),nil); eq(S.Check({ready=true}),nil)
    local job=S.NewOpenJob(nil); eq(job.status,"complete"); assert(S.IsHandle(job.result))
    local db,g=dbWith({unspent=0}); eq(S.Check(db),db)
    eq(S.Active(db,character.guid,2913),g)
    eq(S.Apply(db,character,identity,{},20,"fixture"),db.characters[character.guid].professions[2913].active)
    eq(S.Archive(db,character.guid,2913,30,"fixture"),true)
    eq(S.Read(db,character.guid,2913,1,true),db.characters[character.guid].professions[2913].archives[1])
    eq(S.Delete(db,{guid=character.guid,character=true},true),true)
end)
case("S01 full eight native-derived migration semantic projections independent times and ownership",function(checkpoint,annotate)
    -- U13 GUID_MODEL BEGIN
    do
        local db=C.Open(nil)
        for _,guid in ipairs({"a-other","b-other","z-current"}) do
            for _,id in ipairs({2913,2906}) do
                local who={guid=guid,name=guid=="b-other" and "Éléonore" or "Same",realm=guid=="a-other" and "Other" or "Test"}
                local ident=assert(C.Copy(identity)); ident.skillLineID=id
                if id==2906 then ident.profession=4; ident.name="Alchemy" end
                local obs={}
                if guid~="b-other" then
                    obs.skill=C.Observation("observed",{skillLevel=id==2913 and 20 or 100,maxSkillLevel=100,skillModifier=0},10,"U13")
                    obs.moxie=C.Observation("observed",{id=3261,quantity=guid=="z-current" and 0 or 601},10,"U13")
                end
                assert(C.Apply(db,who,ident,obs,10,"fixture"))
                assert(C.Archive(db,guid,id,20,"U13")); assert(C.Apply(db,who,ident,obs,30,"fixture"))
            end
        end
        local h,root=opened(db,checkpoint); local verify=frozen({db,root})
        local options={{},{sort="moxie"},{sort="concentration"},{sort="enchant"},{sort="progression"},
            {attention="Moxie"},{attention="Progression"},{professionFamily=4},{character="Other"},{character="no match"}}
        for column=1,#V.columns do for _,descending in ipairs({false,true}) do
            options[#options+1]={sortColumn=column,sortDescending=descending}
        end end
        for _,archived in ipairs({false,true}) do for _,opts in ipairs(options) do
            opts.archived=archived
            local baseline=V.Build(db,{},opts,400); local expected={}
            for _,row in ipairs(baseline) do if row.guid=="z-current" then expected[#expected+1]=row end end
            for _,row in ipairs(baseline) do if row.guid~="z-current" then expected[#expected+1]=row end end
            opts.currentPlayerGUID="z-current"
            local legacy=V.Build(db,{},opts,400); local incremental=build(h,opts,checkpoint)
            eq(#legacy,#baseline); eq(#incremental,#legacy)
            for n,row in ipairs(legacy) do
                eq(row.key,expected[n].key,"U13 current GUID group rejection")
                eq(row.isCurrentCharacter,row.guid=="z-current" and true or nil)
                eq(incremental[n].key,row.key); eq(incremental[n].isCurrentCharacter,row.isCurrentCharacter)
                eq(row.name,expected[n].name); assert(deepEqual(row.cells,expected[n].cells))
                assert(deepEqual(row.sortValues,expected[n].sortValues)); eq(row.priority,expected[n].priority)
            end
            opts.currentPlayerGUID=nil; verify(); pause(checkpoint,"U13 GUID schema parity/filter/sort")
        end end
        for _,bad in ipairs({false,7,"","z-current\n",string.rep("x",129),"unknown"}) do
            local opts={currentPlayerGUID=bad}; local a=V.Build(db,{},opts,400); local b=build(h,opts,checkpoint)
            local baseline=V.Build(db,{},nil,400)
            for n,row in ipairs(a) do eq(row.key,baseline[n].key); eq(b[n].key,row.key); eq(row.isCurrentCharacter,nil) end
        end
        verify()
    end
    -- U13 GUID_MODEL END
    local legacy,packs=seed(); local verify=unchangedGraph(legacy)
    local h,root,j=opened(legacy,checkpoint); verify(); eq(count(root.catalogs),32)
    for _,p in ipairs(packs) do
        local before=legacy.characters[p[1].guid].professions[p[2].skillLineID].active
        local after,who=S.Active(h,p[1].guid,p[2].skillLineID); assert(after)
        eq(after.scannedAt,before.scannedAt); eq(after.generation,before.generation)
        eq(who.name,legacy.characters[p[1].guid].name)
        for key,f in pairs(before.fields) do
            local a=after.fields[key]
            assert(deepEqual(a.attempt,f.attempt)); eq(a.last and a.last.observedAt,f.last and f.last.observedAt)
            if f.last then eq(a.last.build,f.last.build); eq(a.last.generation,f.last.generation) end
            if f.last and key:match("^tree:") then
                local x,y=f.last.value,a.last.value; eq(y.compactSnapshot,true); eq(y.currencies,nil)
                eq(x.purchased,y.purchased); eq(x.capacity,y.capacity); eq(x.root,y.root); eq(#x.paths,#y.paths)
                for i,path in ipairs(x.paths) do
                    local q=y.paths[i]; eq(q.id,path.id); eq(q.name,path.name); eq(q.purchased,path.purchased)
                    eq(q.capacity,path.capacity); eq(q.locked,path.locked); eq(q.available,path.node.isAvailable)
                    assert(deepEqual(q.children,path.children)); eq(q.node,nil); eq(q.spend,nil)
                end
            elseif key=="knowledgeRaw" and f.last then eq(a.last.value.format,"raw-summary-v1"); eq(a.last.value.tabs[1].paths,nil)
            elseif f.last then assert(deepEqual(a.last,f.last)) end
        end
        after.identity.name="caller mutation"; who.name="caller mutation"
        assert(S.Active(h,p[1].guid,p[2].skillLineID).identity.name~="caller mutation")
        pause(checkpoint,"S01 eight semantic owners")
    end
    local rows=build(h,{},checkpoint); eq(#rows,8)
    for _,r in ipairs(rows) do
        eq(#r.trees,4); assert(table.concat(r.trees[1].tooltip,"\n"):find("not retained",1,true))
        assert(not table.concat(r.trees[1].tooltip,"\n"):find("unlock token ?",1,true))
    end
    if annotate then annotate("migration:8rows/32catalogues; compact values="..visits(root).."; steps="..j.steps) end
end)
case("S01 migration cancellation invalid legacy unknown structural extensions no partial results",function(checkpoint)
    local raw=seed(); local verify=unchangedGraph(raw)
    local j=S.NewOpenJob(raw); eq(j.status,"running"); j:Step(); eq(j.result,nil); j:Cancel()
    eq(j.status,"cancelled"); eq(j.result,nil); eq(j.savedRoot,nil); j:Step(); verify()
    for _,change in ipairs({
        function(db) db.extra={} end,
        function(db) local _,c=next(db.characters); c.extra=false end,
        function(db) local _,c=next(db.characters); local _,p=next(c.professions); p.extra=0 end,
        function(db) local _,c=next(db.characters); local _,p=next(c.professions); p.active.extra="extension" end,
        function(db) local _,c=next(db.characters); local _,p=next(c.professions); local _,f=next(p.active.fields); f.extra=true end,
        function(db) local _,c=next(db.characters); local _,p=next(c.professions); local _,f=next(p.active.fields); f.attempt.extra=1 end,
    }) do
        local db=assert(C.Copy(raw)); change(db); assert(C.Open(db)); local unchanged=unchangedGraph(db)
        local bad=finish(S.NewOpenJob(db),checkpoint); eq(bad.status,"failed"); eq(bad.result,nil); unchanged()
    end
    local invalid={schema=1,characters={bad={}}}; local bad=S.NewOpenJob(invalid); eq(bad.status,"failed"); eq(bad.result,nil)
    eq(S.NewOpenJob({schema=999}).status,"failed")
end)
case("S01 atomic affected records shared revisions failed attempts equipment and caller ownership",function(checkpoint)
    local legacy,p=seed(); local h,root=opened(legacy,checkpoint)
    local input=p[1]; local id=input[2].skillLineID; local guid=input[1].guid
    local other=applyPack(h,input,"S01-other"); eq(count(root.catalogs),32)
    local original=root.characters[guid].professions[id].active
    local token,revision=S.Token(h,guid,id),S.Revision(h)
    local unchanged=unchangedGraph(root)
    eq(S.Apply(h,input[1],input[2],{unspent=C.Observation("observed",-1,200,"bad")},200,"fixture"),nil)
    eq(S.Token(h,guid,id),token); eq(S.Revision(h),revision); unchanged()
    local g=assert(S.Apply(h,input[1],input[2],{unspent=C.Observation("unknown",nil,201,"failure")},201,"fixture"))
    eq(g.fields.unspent.last.observedAt,100); eq(g.fields.unspent.last.value,0); eq(g.fields.unspent.attempt.status,"unknown")
    assert(S.Token(h,guid,id)~=token); eq(root.characters[guid].professions[id].archives[1],nil)
    eq(root.characters["S01-other"].professions[id].active.scannedAt,other.scannedAt)
    assert(root.characters[guid].professions[id].active~=original)
    local v={slot=20,role="tool",exists=true,metadataReady=true,itemID=9,link="item:9::0",rank=5,rarity=4,
        stats={ITEM_MOD_MULTICRAFT_SHORT=5},enchant={status="observed",present=false,id=0}}
    assert(S.Apply(h,input[1],input[2],{tool=C.Observation("observed",v,210,"gear")},210,"fixture"))
    v.rank=1
    local partial={slot=20,role="tool",exists=true,metadataReady=false,itemID=9,link="item:9::0"}
    g=assert(S.Apply(h,input[1],input[2],{tool=C.Observation("unknown",partial,220,"gear")},220,"fixture"))
    eq(g.fields.tool.last.observedAt,210); eq(g.fields.tool.last.value.rank,5)
    partial.itemID=10; partial.link="item:10::0"
    g=assert(S.Apply(h,input[1],input[2],{tool=C.Observation("unknown",partial,230,"gear")},230,"fixture"))
    eq(g.fields.tool.last.observedAt,230); eq(g.fields.tool.last.value.rank,nil); eq(g.fields.tool.attempt.status,"unknown")
end)
case("S01 catalogue conflicts labels build locale topology immutable and independent old tree times",function(checkpoint)
    local _,p=seed(); local h,root=S.New(); local one=p[1]; applyPack(h,one,"S01-A")
    local base=count(root.catalogs); eq(base,4); applyPack(h,one,"S01-B"); eq(count(root.catalogs),base)
    local who=assert(C.Copy(one[1])); who.guid="S01-A"
    local prior=S.Active(h,who.guid,one[2].skillLineID)
    local oldcat=assert(C.Copy(root.catalogs))
    local changed=assert(C.Copy(one[3])); local first
    for key,o in pairs(changed) do if key:match("^tree:") then first=key; o.value.name=o.value.name.." revision"; break end end
    assert(S.Apply(h,who,one[2],changed,200,one[5])); eq(count(root.catalogs),base+1)
    for id,cat in pairs(oldcat) do assert(deepEqual(cat,root.catalogs[id])) end
    local newer=assert(C.Copy(one[3])); newer.environment.value.locale="zzZZ"
    assert(S.Apply(h,who,one[2],newer,300,"different build")); assert(count(root.catalogs)>=base+5)
    local rawOnly={knowledgeRaw=assert(C.Copy(one[3].knowledgeRaw)),environment=C.Observation("observed",{version="new",locale="xxXX"},400,"env")}
    rawOnly.knowledgeRaw.attemptedAt=400
    local g=assert(S.Apply(h,who,one[2],rawOnly,400,"new raw build"))
    eq(g.fields[first].last.observedAt,100); eq(g.fields.knowledgeRaw.last.observedAt,400)
    eq(prior.fields[first].last.observedAt,100)
    local topology=assert(C.Copy(one[3])); local swapped=false
    for key,o in pairs(topology) do
        if key:match("^tree:") and not swapped then
            for _,path in ipairs(o.value.paths) do
                if #path.children>=2 then path.children[1],path.children[2]=path.children[2],path.children[1]; swapped=true; break end
            end
        end
    end
    assert(swapped); local before=count(root.catalogs); local immutable=assert(C.Copy(root.catalogs))
    assert(S.Apply(h,who,one[2],topology,500,one[5])); eq(count(root.catalogs),before+1)
    for id,cat in pairs(immutable) do assert(deepEqual(cat,root.catalogs[id])) end
    opened(root,checkpoint)
end)
case("S01 schema2 reload corruption references points locks policy keys types aliases limits",function(checkpoint)
    local _,p=seed(); local h,root=S.New(); applyPack(h,p[1])
    local guid,id=p[1][1].guid,p[1][2].skillLineID
    local changes={
        function(r,g) g.fields.unspent.last.value=-1 end,
        function(r,g) g.identity.profession=1 end,
        function(r,g) g.generation=0 end,
        function(r,g) g.fields.unspent.extra=true end,
        function(r,g) g.fields.unspent.last.generation=2 end,
        function(r,g,t) t.catalog=99999 end,
        function(r,g,t) t.purchased=t.purchased+1 end,
        function(r,g,t) local k=next(t.points); t.points[k]=nil end,
        function(r,g,t) local k=next(t.points); t.points[k]=-1 end,
        function(r,g,t) t.points[999999]=0 end,
        function(r,g,t) local k=next(t.locked); t.locked[k]="false" end,
        function(r,g,t) local k=next(t.available); t.available[k]=nil end,
        function(r,g,t) t.accountingEvidence.currencyID=1 end,
        function(r,g,t) t.accountingEvidence.sourcePin="wrong" end,
        function(r,g,t) t.accountingEvidence.quantity=0/0 end,
        function(r,g,t) r.catalogs[t.catalog].build="wrong" end,
        function(r,g,t) r.catalogs[t.catalog].definition.paths[1].children={r.catalogs[t.catalog].definition.root} end,
        function(r,g,t) r.catalogs[t.catalog].definition.paths[1].capacity=-1 end,
        function(r,g,t) r.catalogs[t.catalog].definition.paths[1].name="bad|label" end,
        function(r,g,t) r.catalogs[t.catalog].definition.paths[1].extra={} end,
        function(r,g) g.fields.unspent.attempt.source=string.rep("x",4097) end,
        function(r,g) g.fields.skill.last.value.extra=string.rep("x",4097) end,
        function(r,g) g.fields.skill.last.value.extra={}; local t=g.fields.skill.last.value.extra; for i=1,21 do t[1]={}; t=t[1] end end,
        function(r,g) g.fields.skill.last.value.extra={}; for i=1,50000 do g.fields.skill.last.value.extra[i]=0 end end,
        function(r,g) g.fields.skill.last.value.extra=g end,
        function(r,g) setmetatable(g,{}) end,
        function(r,g) g.fields.unspent.attempt=g.fields.skill.attempt end,
        function(r,g) r.characters["alias"]=r.characters[guid] end,
        function(r,g) r.nextCatalog=1 end,
        function(r,g) r.extra={} end,
    }
    for n,change in ipairs(changes) do
        local r=assert(C.Copy(root)); local g=r.characters[guid].professions[id].active
        local tree; for key,f in pairs(g.fields) do if key:match("^tree:") then tree=f.last.value; break end end
        change(r,g,tree); local verify=frozen(r)
        local j=finish(S.NewOpenJob(r),checkpoint); eq(j.status,"failed","S01 corruption "..n); eq(j.result,nil); verify()
    end
end)
case("S01 lifecycle archive map counters scoped delete relearn token isolation",function(checkpoint)
    local _,p=seed(); local h,root=S.New(); local first=p[1]; local guid,id=first[1].guid,first[2].skillLineID
    applyPack(h,first); applyPack(h,first,"S01-unaffected")
    local unchanged=unchangedGraph(root.characters["S01-unaffected"])
    local token=S.Token(h,guid,id); assert(S.Archive(h,guid,id,200,"retired")); assert(S.Token(h,guid,id)~=token)
    eq(S.Active(h,guid,id),nil); eq(S.Read(h,guid,id,1,true).archivedAt,200)
    local g=applyPack(h,first); eq(g.generation,2); eq(root.characters[guid].professions[id].nextGeneration,3)
    assert(S.Delete(h,{guid=guid,id=id,generation=1},true)); eq(S.Read(h,guid,id,1,true),nil)
    eq(S.Delete(h,{guid=guid,character=true},false),false); assert(S.Delete(h,{guid=guid,character=true},true)); unchanged()
    opened(root,checkpoint)
end)
case("S01 startup cancel retry combat scheduler publication root guards",function(checkpoint)
    local env,state=fixtureAPI(); mockWidgets(env); local old=seed(); env.CraftArmyDB=old
    env.DEFAULT_CHAT_FRAME={AddMessage=function() end}; local cmd=NS.Commands.New(env); cmd:Login()
    eq(cmd.collector.db,nil); eq(env.CraftArmyDB,old); eq(cmd.storageJob.status,"running")
    local frame=cmd.storageFrame; local tick=frame.scripts.OnUpdate; local steps=cmd.storageJob.steps
    state.combat=true; tick(); eq(cmd.storageJob.steps,steps); state.combat=false
    cmd.selftest={}; tick(); eq(cmd.storageJob.steps,steps); cmd.selftest=nil
    cmd:Run("storage cancel"); eq(env.CraftArmyDB,old); eq(cmd.collector.db,nil); tick(); eq(cmd.storageJob.status,"cancelled")
    cmd:Run("storage retry"); local job=cmd.storageJob
    while job.status=="running" do cmd.storageFrame.scripts.OnUpdate(); pause(checkpoint,"S01 startup frame") end
    eq(job.status,"complete"); assert(S.IsHandle(cmd.collector.db)); eq(env.CraftArmyDB.schema,2); assert(env.CraftArmyDB~=old)
    local env2=fixtureAPI(); env2.CraftArmyDB=seed(); local ptr=env2.CraftArmyDB; env2.DEFAULT_CHAT_FRAME=env.DEFAULT_CHAT_FRAME
    local no=NS.Commands.New(env2); no:Login(); eq(env2.CraftArmyDB,ptr); eq(no.collector.db,nil)
    assert(no.collector.blockReason:find("scheduler",1,true))
end)
case("S01 full native growth12to13 46x2 100x2 200x2 archives Details reload apply iterator rows",function(checkpoint,annotate)
    local legacy,p=seed(); local h,root=opened(legacy,checkpoint)
    local chars={}; for guid in pairs(legacy.characters) do chars[#chars+1]=guid end; table.sort(chars)
    local function otherPack(id)
        for _,input in ipairs(p) do if input[2].skillLineID~=id then return input end end
    end
    -- Fill the migrated eight characters to two distinct professions, then grow
    -- only through real Storage.Apply with every full original rich input guard.
    for n,guid in ipairs(chars) do
        local id=next(legacy.characters[guid].professions); applyPack(h,otherPack(id),guid)
        if n==4 then eq(#build(h,{},checkpoint),12) end
        if n==5 then eq(#build(h,{},checkpoint),13) end
        pause(checkpoint,"S01 native-rich initial second profession")
    end
    local measures={}
    for n=9,200 do
        local guid="S01-growth-"..n; chars[n]=guid
        local a=p[(2*n-2)%8+1]; local b=p[(2*n-1)%8+1]
        applyPack(h,a,guid); applyPack(h,b,guid)
        if n==46 or n==100 or n==200 then
            local rows,j=build(h,{},checkpoint); eq(#rows,n*2); eq(count(root.characters),n)
            local values=visits(root); if n>=100 then assert(values>50000,"Growth must exceed old aggregate budget") end
            local reopened,reloaded,open=opened(root,checkpoint)
            local it=finish(S.NewIterator(reopened,false),checkpoint); eq(it.status,"complete"); eq(it.work.items,n*2)
            assert(it.work.maxEdges<=128)
            local reloadRows=build(reopened,{},checkpoint); eq(#reloadRows,n*2)
            for i,r in ipairs(rows) do
                eq(r.key,reloadRows[i].key); eq(r.trees[1].purchased,reloadRows[i].trees[1].purchased)
                eq(r.trees[1].capacity,reloadRows[i].trees[1].capacity)
            end
            local before=reloaded.characters[chars[2]].professions
            applyPack(reopened,a,guid,500); eq(reloaded.characters[chars[2]].professions,before)
            measures[#measures+1]=n.."x2="..values.."v/"..count(root.catalogs).."cat/open"..open.steps.."/build"..j.steps
        end
        pause(checkpoint,"S01 two full native-rich generation writes")
    end
    local insc
    for _,input in ipairs(p) do if input[2].skillLineID==2913 then insc=input end end
    local report; local original=C.Apply
    local ok,why=pcall(function()
        C.Apply=function(db,who,id,obs,at,build)
            if obs.professionDetails and obs.professionDetails.value then report=assert(C.Copy(obs.professionDetails.value)) end
            return original(db,who,id,obs,at,build)
        end
        oldCase("U03 typed optional field native sample rank0 multiline exact and independent copy")()
    end)
    C.Apply=original; assert(ok,why); assert(report)
    local guid,id=insc[1].guid,2913
    local g=assert(S.Apply(h,insc[1],insc[2],{professionDetails=C.Observation("observed",report,200,"S01 retained native sample")},100,"fixture"))
    eq(g.fields.professionDetails.last.observedAt,200); eq(g.scannedAt,100)
    local cat=g.fields.professionDetails.last.value; assert(deepEqual(cat,report))
    assert(S.Archive(h,guid,id,300,"S01 retained history")); applyPack(h,insc)
    eq(S.Read(h,guid,id,1,true).fields.professionDetails.last.observedAt,200)
    local reopened,_,open=opened(root,checkpoint)
    eq(#build(reopened,{},checkpoint),400); eq(#build(reopened,{archived=true},checkpoint),1)
    eq(S.Read(reopened,guid,id,1,true).fields.professionDetails.last.value.trees[1].paths[1].perks[1].state,2)
    assert(S.Delete(reopened,{guid=guid,id=id,generation=1},true)); eq(#build(reopened,{archived=true},checkpoint),0)
    if annotate then annotate(table.concat(measures,"; ").."; archive+Details reload"..open.steps) end
end)
case("S01 all14 heading sorts exact legacy comparator active archive both directions no API writes",function(checkpoint)
    local legacy=seed()
    for _,archived in ipairs({false,true}) do
        if archived then for guid,c in pairs(legacy.characters) do for id in pairs(c.professions) do assert(C.Archive(legacy,guid,id,200,"sort")) end end end
        local h,root=opened(legacy,checkpoint); local verify=frozen(root)
        for column=1,14 do for _,descending in ipairs({false,true}) do
            local opts={sortColumn=column,sortDescending=descending,archived=archived}
            local expected=V.Build(legacy,{},opts,400); local actual=build(h,opts,checkpoint)
            eq(#actual,#expected)
            for i,r in ipairs(expected) do eq(actual[i].key,r.key); eq(actual[i].sortValues[column],r.sortValues[column]) end
            verify(); pause(checkpoint,"S01 exact heading sort")
        end end
    end
end)
case("S01 iterator and build cancellation revisions immutable options no partial rows",function(checkpoint)
    local legacy,p=seed(); local h=opened(legacy,checkpoint)
    local it=S.NewIterator(h,false); it:Step(); it:Cancel(); eq(it.item,nil); eq(it.status,"cancelled")
    it=S.NewIterator(h,false); applyPack(h,p[1]); it:Step(); eq(it.status,"failed"); eq(it.item,nil)
    local opts={profession="no match"}; local j=V.NewBuildJob(h,{},opts,400); opts.profession=nil
    finish(j,checkpoint); eq(j.status,"complete"); eq(#j.rows,0)
    j=V.NewBuildJob(h,{}, {},400); j:Step(); eq(j.rows,nil); j:Cancel(); eq(j.rows,nil)
    j=V.NewBuildJob(h,{}, {},400); applyPack(h,p[1]); finish(j,checkpoint); eq(j.status,"failed"); eq(j.rows,nil)
    local rows,why=V.Build(h,{}, {},400); eq(#rows,0); assert(why:find("pending",1,true))
end)
case("S01 Details actual rich source normal scan final-frame guards and independent saved report",function(checkpoint)
    local env,state,_,c=k2Fixture(); c.db=S.New(); assert(c:Scan())
    local g=S.Active(c.db,character.guid,2913); assert(g)
    local scope={guid=character.guid,id=2913,generation=g.generation,archived=false}
    local rich,token=c:DetailsSource(scope); assert(rich and token); assert(rich.fields.knowledgeRaw.last.value.tabs[1].paths)
    env.C_ProfSpecs.GetDescriptionForPath=function() return "Synthetic per-point fixture" end
    env.C_ProfSpecs.GetPerksForPath=function(id) return {{perkID=id+1000000,isMajorPerk=true}} end
    env.C_ProfSpecs.GetUnlockRankForPerk=function() return 0 end
    env.C_ProfSpecs.GetStateForPerk=function() return 0 end
    env.C_ProfSpecs.GetDescriptionForPerk=function() return "Synthetic milestone fixture" end
    state.at=200
    local job=finish(NS.Details.NewCaptureJob(env,c,scope),checkpoint); eq(job.status,"complete",job.reason)
    local current=S.Active(c.db,character.guid,2913); eq(current.scannedAt,100)
    eq(current.fields.professionDetails.last.observedAt,200); eq(current.fields.unspent.last.observedAt,100)
    eq(c:DetailsSource(scope),nil,"Any active write retires the old ephemeral token")
    local old=current.fields.professionDetails.last
    assert(c:Scan()); state.at=300
    job=NS.Details.NewCaptureJob(env,c,scope)
    while job.status=="running" and job.phase~="commit" do job:Step(); pause(checkpoint,"S01 final gap") end
    eq(job.phase,"commit"); local node=env.C_Traits.GetNodeInfo
    env.C_Traits.GetNodeInfo=function(config,id)
        local out=assert(C.Copy(node(config,id))); out.ranksPurchased=out.ranksPurchased+1; return out
    end
    job:Step(); eq(job.status,"discarded"); eq(S.Active(c.db,character.guid,2913).fields.professionDetails.last.observedAt,old.observedAt)
    c:Invalidate("S01 context invalidation"); eq(c:DetailsSource(scope),nil)
end)
case("S01 dashboard bounded driver pending supersession hidden scheduler failures no reset",function(checkpoint)
    local legacy=seed(); local h,root=opened(legacy,checkpoint)
    local env=fixtureAPI(); mockWidgets(env)
    local create=env.CreateFrame
    env.CreateFrame=function(...)
        local w=create(...); local show,hide=w.Show,w.Hide
        w.Show=function(self) local was=self.shown; show(self); if not was and self.scripts.OnShow then self.scripts.OnShow(self) end end
        w.Hide=function(self) local was=self.shown; hide(self); if was and self.scripts.OnHide then self.scripts.OnHide(self) end end
        return w
    end
    local c=NS.Collectors.New(env,h); local ui=NS.Dashboard.New(env,c)
    local verify=frozen(root); ui:Toggle(); eq(#ui.rows,0); eq(#ui.widgets,12)
    assert(ui.buildJob and ui.buildDriver); local first=ui.buildJob; local stale=ui.buildDriver.scripts.OnUpdate
    ui.options.character="no match"; ui:Refresh(); eq(first.status,"cancelled"); stale(); eq(#ui.rows,0)
    while ui.buildJob do ui.buildDriver.scripts.OnUpdate(); pause(checkpoint,"S01 render frame") end
    eq(#ui.rows,0); ui.options.character=nil; ui:Refresh()
    while ui.buildJob do ui.buildDriver.scripts.OnUpdate(); pause(checkpoint,"S01 render frame") end
    eq(#ui.rows,8); verify()
    ui:Refresh(); local pending=ui.buildJob; ui.frame.scripts.OnHide(); eq(pending.status,"cancelled"); eq(ui.buildJob,nil)
    ui.buildDriver=nil; env.CreateFrame=function() error("S01 frame failure") end
    ui:Refresh(); eq(ui.buildJob,nil); eq(c.db,h); assert(ui.reason:GetText():find("scheduler",1,true)); verify()
end)
case("S01 required dependency budget legacy retained nine tree fields",function(checkpoint,annotate)
    local raw=scan(); raw.tabs[1].paths[72].children={73}
    local evaluated=K.Evaluate(raw); eq(evaluated.complete,true)
    local db=C.Open(nil); local obs={}; local index={}
    for id=1,8 do
        local tree=assert(C.Copy(evaluated.trees[1])); tree.id=id
        eq(C.ValidPayload("tree:"..id,tree,"observed"),true)
        obs["tree:"..id]=C.Observation("observed",tree,100,"S01 synthetic historical tree IDs")
        index[#index+1]={id=id,root=tree.root}
    end
    obs.knowledgeIndex=C.Observation("observed",index,100,"S01 original eight IDs")
    assert(C.Apply(db,character,identity,obs,100,"fixture"))
    local tree=assert(C.Copy(evaluated.trees[1])); tree.id=9
    local g=assert(C.Apply(db,character,identity,{
        ["tree:9"]=C.Observation("observed",tree,200,"S01 changed native IDs; synthetic legacy accounting"),
        knowledgeIndex=C.Observation("observed",{{id=9,root=tree.root}},200,"S01 current index")},200,"fixture"))
    eq(C.Open(db),db); local retained=0
    for key in pairs(g.fields) do if key:match("^tree:") then retained=retained+1 end end
    eq(retained,9)
    local job=S.NewOpenJob(db); local maxReferences=0
    while job.status=="running" do
        local original=C.Copy; local refs={}
        local ok,why=pcall(function()
            C.Copy=function(value)
                if type(value)=="table" and value.kind=="tree" and type(value.definition)=="table" then refs[value.definition.id]=true end
                return original(value)
            end
            job:Step()
        end)
        C.Copy=original; assert(ok,why)
        maxReferences=math.max(maxReferences,count(refs)); pause(checkpoint,"S01 dependency-budget observer restored")
    end
    eq(job.status,"complete",job.reason)
    local output=S.Active(job.result,character.guid,2913)
    for id=1,9 do assert(output.fields["tree:"..id].last.value) end
    if annotate then annotate("valid legacy9 retained trees; max distinct tree definitions in one actual Step="..maxReferences) end
    assert(maxReferences<=1,"S01 amended dependency bound: at most ONE distinct catalogue validation per Step")
    local function observed(job)
        while job.status=="running" do
            local original=C.Copy; local refs={}
            local ok,why=pcall(function()
                C.Copy=function(value)
                    if type(value)=="table" and (value.kind=="tree" or value.kind=="details") then refs[value]=true end
                    return original(value)
                end
                job:Step()
            end)
            C.Copy=original; assert(ok,why)
            -- A validation may own/copy the same catalogue more than once. Count
            -- actual distinct definitions, not a self-reported scheduling counter.
            local definitions={}
            for cat in pairs(refs) do
                local matched=false
                for _,prior in ipairs(definitions) do if deepEqual(cat,prior) then matched=true end end
                if not matched then definitions[#definitions+1]=cat end
            end
            assert(#definitions<=1,"More than one actual catalogue definition validated in a Step")
            pause(checkpoint,"S01 one actual definition per Step")
        end
        eq(job.status,"complete",job.reason); return job
    end
    local reload=observed(S.NewOpenJob(job.savedRoot)); local it=observed(S.NewIterator(reload.result,false))
    eq(it.work.items,1)
    local obs,index={},{}
    for id=10,17 do
        local v=assert(C.Copy(evaluated.trees[1])); v.id=id
        obs["tree:"..id]=C.Observation("observed",v,300,"S01 another index revision")
        index[#index+1]={id=id,root=v.root}
    end
    obs.knowledgeIndex=C.Observation("observed",index,300,"S01 current eight IDs")
    assert(C.Apply(db,character,identity,obs,300,"fixture")); assert(C.Open(db))
    local many=observed(S.NewOpenJob(db)); observed(S.NewIterator(many.result,false))
    local g=S.Active(many.result,character.guid,2913)
    for id=1,17 do eq(g.fields["tree:"..id].last.observedAt,id<=8 and 100 or id==9 and 200 or 300) end
end)
local function single()
    local _,packs=seed(); local h,r=S.New(); applyPack(h,packs[1]); return h,r,packs[1]
end
local function firstTree(g)
    for key,f in pairs(g.fields) do if key:match("^tree:") then return f.last.value,key end end
end
local detailsSample
local function sampleDetails()
    if not detailsSample then
        local original=C.Apply
        local ok,why=pcall(function()
            C.Apply=function(db,who,id,obs,at,build)
                if obs.professionDetails and obs.professionDetails.value then detailsSample=assert(C.Copy(obs.professionDetails.value)) end
                return original(db,who,id,obs,at,build)
            end
            oldCase("U03 typed optional field native sample rank0 multiline exact and independent copy")()
        end)
        C.Apply=original; assert(ok,why)
    end
    return assert(C.Copy(detailsSample))
end
local function withDetails()
    local _,packs=seed(); local input
    for _,p in ipairs(packs) do if p[2].skillLineID==2913 then input=p end end
    local h,r=S.New(); applyPack(h,input)
    assert(S.Apply(h,input[1],input[2],{professionDetails=C.Observation("observed",sampleDetails(),200,"sample")},100,"fixture"))
    return h,r,input
end
case("S01 compact raw summary full scalar enum identity tab corruption matrix",function(checkpoint)
    local _,root,p=single(); local guid,id=p[1].guid,p[2].skillLineID
    local changes={
        function(v) v.format="wrong" end,function(v) v.policy="wrong" end,
        function(v) v.configID=0 end,function(v) v.configID=2147483648 end,function(v) v.sourceCounter=-1 end,
        function(v) v.sourceCounter=2147483648 end,function(v) v.sourceCounter=math.huge end,
        function(v) v.tabsComplete=0 end,function(v) v.nativeComplete="true" end,
        function(v) v.stagedStart=0 end,function(v) v.stagedEnd=0 end,function(v) v.stable=0 end,
        function(v) v.identity.profession=1 end,function(v) v.identity.parentID=nil end,
        function(v) v.identity.expansionID=0 end,function(v) v.identity.extra=false end,
        function(v) v.tabs[1].id=0 end,function(v) v.tabs[1].root=0 end,
        function(v) v.tabs[1].name=false end,function(v) v.tabs[1].coverageComplete=0 end,
        function(v) v.tabs[1].coverageComplete=false end,function(v) v.tabs[1].paths={} end,
        function(v) v.tabs[2]=nil end,function(v) v.tabs[9]=v.tabs[1] end,
        function(v) v.extra=true end,function(v) setmetatable(v,{}) end,
    }
    for n,change in ipairs(changes) do
        local r=assert(C.Copy(root)); local v=r.characters[guid].professions[id].active.fields.knowledgeRaw.last.value
        change(v); local verify=frozen(r); local j=finish(S.NewOpenJob(r),checkpoint)
        eq(j.status,"failed","raw mutation "..n); eq(j.result,nil); verify(); pause(checkpoint,"S01 raw matrix")
    end
end)
case("S01 Details personal catalogue coverage earned text bounds and state corruption matrix",function(checkpoint)
    local _,root,p=withDetails(); local guid,id=p[1].guid,p[2].skillLineID
    local mutations={
        function(v,d) v.format="bad" end,function(v) v.version=2 end,function(v) v.skillLineID=2909 end,
        function(v) v.configID=0 end,function(v) v.sourceScanAt=-1 end,function(v) v.catalog=0 end,
        function(v,d) v.points[d.trees[1].paths[1].id]=nil end,
        function(v,d) v.points[d.trees[1].paths[1].id]=11 end,
        function(v,d) v.locked[d.trees[1].paths[1].id]=true end,
        function(v,d) v.locked[d.trees[1].paths[1].id]=nil end,
        function(v,d) v.states[d.trees[1].paths[1].perks[1].id]=1 end,
        function(v,d) v.states[d.trees[1].paths[1].perks[1].id]=nil end,
        function(v) v.points[999999]=0 end,function(v) v.locked[999999]=false end,
        function(v) v.states[999999]=0 end,function(v) v.extra=false end,
        function(v,d) d.trees[1].capacity=9 end,function(v,d) d.trees[1].root=1 end,
        function(v,d) d.trees[1].paths[1].capacity=0 end,
        function(v,d) d.trees[1].paths[1].name="bad|label" end,
        function(v,d) d.trees[1].paths[1].description=string.rep("x",4097) end,
        function(v,d) d.trees[1].paths[1].perks[1].rank=11 end,
        function(v,d) d.trees[1].paths[1].perks[1].isMajorPerk=0 end,
        function(v,d) d.trees[1].paths[1].perks[1].description=" " end,
        function(v,d) d.trees[1].paths[1].perks[1].extra=0 end,
        function(v,d) d.trees[1].paths[1].perks[2]=d.trees[1].paths[1].perks[1] end,
    }
    for n,change in ipairs(mutations) do
        local r=assert(C.Copy(root)); local v=r.characters[guid].professions[id].active.fields.professionDetails.last.value
        local d=r.catalogs[v.catalog].definition; change(v,d); local verify=frozen(r)
        eq(finish(S.NewOpenJob(r),checkpoint).status,"failed","Details mutation "..n); verify()
        pause(checkpoint,"S01 Details matrix")
    end
end)
case("S01 structural headers envelopes directory keys aliases and counter matrix",function(checkpoint)
    local _,root,p=single(); local guid,id=p[1].guid,p[2].skillLineID
    local changes={
        function(r) r.schema=1 end,function(r) r.nextCatalog=0 end,function(r) r.nextCatalog=1.5 end,
        function(r) r.catalogs=false end,function(r) r.characters=false end,
        function(r) r.characters[""]=r.characters[guid]; r.characters[guid]=nil end,
        function(r) r.characters[string.rep("g",129)]=r.characters[guid]; r.characters[guid]=nil end,
        function(r,c) c.name=string.rep("x",4097) end,function(r,c) c.realm=false end,
        function(r,c) c.classToken="Mage" end,function(r,c) c.professions[0]={} end,
        function(r,c,p) p.nextGeneration=1 end,function(r,c,p) p.nextGeneration=math.huge end,
        function(r,c,p) p.archives=false end,function(r,c,p) p.archives[1]=p.active end,
        function(r,c,p,g) g.archivedAt=1; g.archiveReason="not archived" end,
        function(r,c,p,g) g.scannedAt=-1 end,function(r,c,p,g) g.identity.parentID=false end,
        function(r,c,p,g) g.fields.unspent.attempt.status="bad" end,
        function(r,c,p,g) g.fields.unspent.attempt.attemptedAt=-1 end,
        function(r,c,p,g) g.fields.unspent.attempt.source=false end,
        function(r,c,p,g) g.fields.unspent.attempt.reason={} end,
        function(r,c,p,g) g.fields.unspent.last.status="unknown" end,
        function(r,c,p,g) g.fields.unspent.last.build=false end,
        function(r,c,p,g) g.fields.unspent.last.observedAt=-1 end,
        function(r,c,p,g) g.fields.unspent.last.extra=0 end,
        function(r,c,p,g) g.fields["unregistered"]={attempt=g.fields.unspent.attempt} end,
        function(r,c,p,g) g.fields.skill.last.value[string.rep("k",129)]=0 end,
        function(r,c,p,g) g.fields.skill.last.value[-1]=0 end,
        function(r,c,p,g) g.fields.skill.last.value.extra=function() end end,
        function(r,c,p,g) local t=firstTree(g); r.catalogs[0]=r.catalogs[t.catalog] end,
        function(r,c,p,g) local t=firstTree(g); r.catalogs[t.catalog].identity.extra=0 end,
        function(r,c,p,g) local t=firstTree(g); r.catalogs[t.catalog].kind="bad" end,
        function(r,c,p,g) local t=firstTree(g); r.catalogs[t.catalog].locale=false end,
        function(r,c,p,g) local t=firstTree(g); r.catalogs[t.catalog].definition.paths[1].children={999999} end,
        function(r,c,p,g) local t=firstTree(g); local d=r.catalogs[t.catalog].definition; d.paths[2].id=d.paths[1].id end,
        function(r,c,p,g) local t=firstTree(g); local d=r.catalogs[t.catalog].definition; d.paths[1].children={} end,
        function(r,c,p,g) local t=firstTree(g); t.locked[999999]=false end,
        function(r,c,p,g) local t=firstTree(g); t.available[999999]=false end,
        function(r,c,p,g) local t=firstTree(g); t.accountingPolicy="bad" end,
        function(r,c,p,g) local t=firstTree(g); t.accountingEvidence=nil end,
        function(r,c,p,g) local t=firstTree(g); t.accountingEvidence.totalPurchased=0 end,
        function(r,c,p,g) local t=firstTree(g); t.accountingEvidence.quantity=-1 end,
        function(r,c,p,g) local t=firstTree(g); t.accountingEvidence.extra=0 end,
    }
    for n,change in ipairs(changes) do
        local r=assert(C.Copy(root)); local c=r.characters[guid]; local profession=c.professions[id]
        change(r,c,profession,profession.active); local verify=frozen(r)
        eq(finish(S.NewOpenJob(r),checkpoint).status,"failed","structural mutation "..n); verify()
        pause(checkpoint,"S01 structural matrix")
    end
end)
case("S01 legacy optional lock availability zero false metadata and independent summaries retained",function(checkpoint)
    local raw=scan(); raw.tabs[1].paths[72].children={73}; local result=K.Evaluate(raw); eq(result.complete,true)
    local tree=result.trees[1]; tree.paths[1].locked=false; tree.paths[1].node.isAvailable=false
    local db=dbWith({["tree:11"]=tree,skill={skillLevel=0,maxSkillLevel=100,skillModifier=0,
        extra={flag=false,zero=0,format="tree-ref-v1",catalog=123}},knowledgeRaw=raw})
    local h=opened(db,checkpoint); local g=S.Active(h,character.guid,2913); local t=g.fields["tree:11"].last.value
    eq(t.paths[1].locked,false); eq(t.paths[1].available,false); eq(t.paths[2].locked,nil); eq(t.paths[2].available,nil)
    eq(g.fields.skill.last.value.extra.flag,false); eq(g.fields.skill.last.value.extra.zero,0)
    eq(g.fields.knowledgeRaw.last.value.policy,nil); eq(g.fields.knowledgeRaw.last.value.nativeComplete,nil)
    eq(#build(h,{},checkpoint),1)
end)
case("S01 same native definition different allocations locked zero availability exact catalogue reuse",function(checkpoint)
    local env,state,f,c=k2Fixture(); local h,r=S.New(); c.db=h; assert(c:Scan())
    local before=count(r.catalogs); local old=S.Active(h,character.guid,2913)
    local raw=k2Raw(c); local path=raw.tabs[1].paths[raw.tabs[1].root]
    path.node.ranksPurchased=0; path.node.currentRank=0; path.node.activeRank=0
    path.node.activeEntry={entryID=path.unlockEntryID,rank=0}; path.node.entryIDsWithCommittedRanks={}
    path.node.nextEntry={entryID=path.unlockEntryID,rank=1}; path.node.isAvailable=false
    path.costs={{ID=3912,amount=1}}
    local result=K.Evaluate(raw); eq(result.complete,true)
    local observations=k2Observations(raw,result,200)
    observations.environment=C.Observation("observed",assert(C.Copy(old.fields.environment.last.value)),200,"same locale")
    local who=assert(C.Copy(character)); who.guid="S01-other-allocation"
    local g=assert(S.Apply(h,who,identity,observations,200,old.fields["tree:1122"].last.build))
    eq(count(r.catalogs),before)
    local t=g.fields["tree:1122"].last.value; eq(t.paths[1].locked,true); eq(t.paths[1].purchased,0); eq(t.paths[1].available,false)
    eq(old.fields["tree:1122"].last.value.paths[1].locked,false)
    eq(S.Active(h,character.guid,2913).fields["tree:1122"].last.value.paths[1].locked,false)
    opened(r,checkpoint)
end)
case("S01 Details independent revision time failed attempt and field-local locale never borrow future",function(checkpoint)
    local h,r,p=withDetails(); local g=S.Active(h,p[1].guid,2913)
    local saved=assert(C.Copy(g.fields.professionDetails.last)); local previous=count(r.catalogs)
    local report=sampleDetails(); report.trees[1].paths[1].description="New independently observed text"
    local obs={professionDetails=C.Observation("observed",report,300,"later Details"),
        environment=C.Observation("observed",{version="other",locale="later-locale"},400,"future env")}
    assert(S.Apply(h,p[1],p[2],obs,100,"other build")); eq(count(r.catalogs),previous+1)
    local ref=r.characters[p[1].guid].professions[2913].active.fields.professionDetails.last.value
    eq(r.catalogs[ref.catalog].locale,nil)
    local newer=S.Active(h,p[1].guid,2913); eq(newer.fields.professionDetails.last.observedAt,300)
    eq(saved.value.trees[1].paths[1].description,sampleDetails().trees[1].paths[1].description)
    assert(S.Apply(h,p[1],p[2],{professionDetails=C.Observation("unknown",nil,500,"failed Details")},100,"new build"))
    g=S.Active(h,p[1].guid,2913); eq(g.fields.professionDetails.last.observedAt,300); eq(g.scannedAt,100)
    eq(g.fields.professionDetails.attempt.attemptedAt,500)
    local before=count(r.catalogs)
    obs.professionDetails.attemptedAt=600; obs.environment.attemptedAt=600
    assert(S.Apply(h,p[1],p[2],obs,100,"other build")); eq(count(r.catalogs),before+1)
    ref=r.characters[p[1].guid].professions[2913].active.fields.professionDetails.last.value
    eq(r.catalogs[ref.catalog].locale,"later-locale")
    opened(r,checkpoint)
end)
case("S01 immutable definitions and touched mutable record refs reject without token counter or unrelated changes",function(checkpoint)
    for _,mode in ipairs({"record","catalog","counter","characterAlias","professionAlias","recordAlias","catalogAlias"}) do
        local h,r,p=single(); local guid,id=p[1].guid,p[2].skillLineID
        applyPack(h,p,"S01-unrelated"); local c=r.characters[guid]; local profession=c.professions[id]
        if mode=="record" then profession.active.fields.unspent.last.value=-1
        elseif mode=="catalog" then local t=firstTree(profession.active); r.catalogs[t.catalog].definition.name="Typed but mutated immutable text"
        elseif mode=="counter" then profession.nextGeneration=1
        elseif mode=="characterAlias" then r.characters[guid]=r.characters["S01-unrelated"]
        elseif mode=="professionAlias" then c.professions[id]=r.characters["S01-unrelated"].professions[id]
        elseif mode=="recordAlias" then profession.active=r.characters["S01-unrelated"].professions[id].active
        else local t=firstTree(profession.active); local cat=r.catalogs[t.catalog]; cat.definition.paths=profession.active.fields end
        local verify=frozen(r); local token,rev=S.Token(h,guid,id),S.Revision(h)
        eq(S.Active(h,guid,id),nil,mode)
        eq(S.Apply(h,p[1],p[2],{},200,"fixture"),nil,mode)
        eq(S.Archive(h,guid,id,300,"bad"),false); eq(S.Token(h,guid,id),token); eq(S.Revision(h),rev); verify()
        pause(checkpoint,"S01 touched corruption")
    end
end)
case("S01 real rich preflight budget attribution and counter overflow rejection atomic",function(checkpoint)
    local h,r,p=single(); local original=C.Apply; local calls=0
    local verify=frozen(r); local token=S.Token(h,p[1].guid,p[2].skillLineID)
    local ok,why=pcall(function()
        C.Apply=function(db,...)
            eq(db.schema,1); eq(next(db.characters),nil); calls=calls+1; return original(db,...)
        end
        local bad=assert(C.Copy(p[3])); bad.knowledgeRaw.value.identity.profession=1
        eq(S.Apply(h,p[1],p[2],bad,200,"fixture"),nil)
        local big={}; for i=1,50000 do big[i]=0 end
        eq(S.Apply(h,p[1],p[2],{skill=C.Observation("observed",{skillLevel=1,maxSkillLevel=100,skillModifier=0,extra=big},200,"overlimit")},200,"fixture"),nil)
    end)
    C.Apply=original; assert(ok,why); eq(calls,2); verify(); eq(S.Token(h,p[1].guid,p[2].skillLineID),token)
    local overflow=assert(C.Copy(r)); overflow.nextCatalog=2^53
    local openedHandle,openedRoot=opened(overflow,checkpoint); local snap=frozen(openedRoot)
    eq(S.Apply(openedHandle,p[1],p[2],p[3],300,"new catalogue build"),nil); snap()
    local legacy=dbWith({unspent=0}); assert(C.Archive(legacy,character.guid,2913,200,"old"))
    legacy.characters[character.guid].professions[2913].nextGeneration=2^53
    local ch,cr=opened(legacy,checkpoint); local unchanged=frozen(cr)
    eq(S.Apply(ch,character,identity,{},300,"fixture"),nil); unchanged()
end)
case("S01 affected hot paths never copy character archives account or revalidate unrelated record",function(checkpoint)
    local h,r,p=single(); local guid,id=p[1].guid,p[2].skillLineID
    applyPack(h,p,"S01-unrelated"); assert(S.Archive(h,guid,id,200,"history")); applyPack(h,p)
    local c=r.characters[guid]; local archives=c.professions[id].archives
    r.characters["S01-unrelated"].professions[id].active.fields.unspent.last.value=-1
    local copy,open=C.Copy,C.Open; local calls=0
    local ok,why=pcall(function()
        C.Copy=function(v)
            assert(v~=r and v~=c and v~=archives and v~=r.characters,"Whole account/character/archive copy")
            if type(v)=="table" then assert(v.characters~=r.characters,"Account wrapper copy") end
            calls=calls+1; return copy(v)
        end
        C.Open=function(v) assert(v~=r,"Schema2 account Open"); return open(v) end
        assert(S.Active(h,guid,id)); assert(S.Apply(h,p[1],p[2],{},300,"fixture"))
        assert(S.Archive(h,guid,id,400,"history2"))
        assert(S.Delete(h,{guid=guid,id=id,generation=1},true))
        assert(S.Delete(h,{guid=guid,character=true},true))
    end)
    C.Copy=copy; C.Open=open; assert(ok,why); assert(calls>0)
    eq(finish(S.NewOpenJob(r),checkpoint).status,"failed","Reopen must inspect unrelated corruption")
end)
case("S01 incremental open late corruption directory wrapper drift cancellation and reentry",function(checkpoint)
    local _,root=single()
    for _,mode in ipairs({"cancel","reentry","lateUnit","directory","wrapper","copyError"}) do
        local r=assert(C.Copy(root)); local j=S.NewOpenJob(r); local original=C.Copy; local fired=false
        if mode=="directory" then j:Step(); r.characters.added={name="Late",realm="Late",professions={}}; r.characters.extra=r.characters.added
        elseif mode=="wrapper" then j:Step(); r.nextCatalog=r.nextCatalog+1
        elseif mode=="lateUnit" then local _,cat=next(r.catalogs); cat.definition.root=999999 end
        local verify=frozen(r)
        while j.status=="running" do
            local ok,why=pcall(function()
                C.Copy=function(v)
                    if not fired and mode=="cancel" then fired=true; j:Cancel()
                    elseif not fired and mode=="reentry" then fired=true; j:Step()
                    elseif not fired and mode=="copyError" then fired=true; error("fixture copy failure") end
                    return original(v)
                end
                j:Step()
            end)
            C.Copy=original; assert(ok,why); pause(checkpoint,"S01 startup observer restored")
        end
        assert(j.status=="failed" or j.status=="cancelled",mode); eq(j.result,nil); eq(j.savedRoot,nil); verify()
    end
end)
case("S01 iterator dependency isolation corruption cancellation reentry and no public Read fallback",function(checkpoint)
    for _,mode in ipairs({"normal","cancel","reentry","catalogDrift","recordCorrupt"}) do
        local h,r,p=single(); local it=S.NewIterator(h,false); local read,copy=S.Read,C.Copy; local fired=false
        if mode=="catalogDrift" then local _,cat=next(r.catalogs); cat.definition.name="Mutated"
        elseif mode=="recordCorrupt" then r.characters[p[1].guid].professions[p[2].skillLineID].active.fields.unspent.last.value=-1 end
        while it.status=="running" do
            local ok,why=pcall(function()
                S.Read=function() error("Iterator must not synchronously Read all definitions") end
                C.Copy=function(v)
                    if not fired and mode=="cancel" then fired=true; it:Cancel()
                    elseif not fired and mode=="reentry" then fired=true; it:Step() end
                    return copy(v)
                end
                it:Step()
            end)
            S.Read=read; C.Copy=copy; assert(ok,why); pause(checkpoint,"S01 iterator observers restored")
        end
        if mode=="normal" then eq(it.status,"complete"); eq(it.work.items,1)
        else assert(it.status=="failed" or it.status=="cancelled",mode); eq(it.item,nil) end
    end
end)
local function nativeWidgets(env)
    mockWidgets(env); local create=env.CreateFrame
    env.CreateFrame=function(...)
        local w=create(...); local show,hide=w.Show,w.Hide
        w.Show=function(self) local was=self.shown; show(self); if not was and self.scripts.OnShow then self.scripts.OnShow(self) end end
        w.Hide=function(self) local was=self.shown; hide(self); if was and self.scripts.OnHide then self.scripts.OnHide(self) end end
        return w
    end
end
case("S01 startup scheduler errors unknown combat capture pause root drift and stale callbacks",function(checkpoint)
    for _,mode in ipairs({"unknown","capture","root","runtime","Step","frameThrow","setScript","cleanupGuard"}) do
        local env,state=fixtureAPI(); nativeWidgets(env); env.CraftArmyDB=seed()
        env.DEFAULT_CHAT_FRAME={AddMessage=function() end}; local ptr=env.CraftArmyDB
        if mode=="frameThrow" then env.CreateFrame=function() error("Frame failure") end
        elseif mode=="setScript" then local create=env.CreateFrame; env.CreateFrame=function(...) local f=create(...); f.SetScript=function() error("SetScript failure") end; return f end end
        local cmd=NS.Commands.New(env); cmd:Login(); local j=cmd.storageJob
        if mode=="frameThrow" or mode=="setScript" then eq(cmd.collector.db,nil); eq(env.CraftArmyDB,ptr)
        else
            local frame=cmd.storageFrame; local callback=frame.scripts.OnUpdate; local steps=j.steps
            if mode=="unknown" then env.InCombatLockdown=function() return nil end; callback(); eq(j.steps,steps); cmd:Run("storage cancel")
            elseif mode=="capture" then cmd.knowledgeCapture={}; callback(); eq(j.steps,steps); cmd.knowledgeCapture=nil; cmd:Run("storage cancel")
            elseif mode=="root" then local replacement={schema=99}; env.CraftArmyDB=replacement; callback(); eq(env.CraftArmyDB,replacement); callback(); eq(j.steps,steps)
            elseif mode=="runtime" then cmd.collector=NS.Collectors.New(env,nil); callback(); eq(cmd.collector.db,nil); callback(); eq(j.steps,steps)
            elseif mode=="Step" then j.Step=function() error("job failure") end; callback(); eq(cmd.collector.db,nil); eq(frame.scripts.OnUpdate,nil)
            else
                local hide=frame.Hide
                frame.Hide=function(self) env.CraftArmyDB={schema=98}; hide(self) end
                while j.status=="running" do callback(); pause(checkpoint,"S01 publication guard") end
                eq(cmd.collector.db,nil); eq(env.CraftArmyDB.schema,98)
            end
        end
        if mode~="root" and mode~="cleanupGuard" then eq(env.CraftArmyDB,ptr) end
        pause(checkpoint,"S01 startup failure matrix")
    end
end)
case("S01 model freshness pin mutation filters reentry row failure and cancellation no partial publish",function(checkpoint)
    local h,r,p=single(); local fresh={[p[1].guid..":"..p[2].skillLineID]={generation=1,fields={unspent=true}}}
    local j=V.NewBuildJob(h,fresh,{},400); j:Step(); fresh[p[1].guid..":"..p[2].skillLineID].fields.unspent=nil
    finish(j,checkpoint); eq(j.status,"failed"); eq(j.rows,nil)
    for _,mode in ipairs({"cancel","reentry","rowError"}) do
        j=V.NewBuildJob(h,{}, {},400); local row=V.Row; local fired=false
        local ok,why=pcall(function()
            V.Row=function(...)
                if mode=="rowError" then error("row failure") end
                if not fired then fired=true; if mode=="cancel" then j:Cancel() else j:Step() end end
                return row(...)
            end
            while j.status=="running" do j:Step() end
        end)
        V.Row=row; assert(ok,why); assert(j.status=="failed" or j.status=="cancelled"); eq(j.rows,nil)
        pause(checkpoint,"S01 model failure restored")
    end
    for _,opts in ipairs({{character="does not exist"},{profession="does not exist"},{professionFamily=999},
        {attention="Missing enchant"},{attention="Moxie"},{archived=true}}) do
        local legacy=seed(); local expected=V.Build(legacy,{},opts,400)
        local full=opened(legacy,checkpoint); local actual=build(full,opts,checkpoint)
        eq(#actual,#expected); for i,row in ipairs(expected) do eq(actual[i].key,row.key) end
        pause(checkpoint,"S01 legacy filter equivalence")
    end
end)
case("S01 dashboard factory Step scheduler combat and runtime supersession cannot publish old rows",function(checkpoint)
    for _,mode in ipairs({"factory","Step","combat","context","options","hidden"}) do
        local h,r=single(); local env,state=fixtureAPI(); nativeWidgets(env)
        local c=NS.Collectors.New(env,h); local ui=NS.Dashboard.New(env,c); local original=V.NewBuildJob
        local ok,why=pcall(function()
            if mode=="factory" then V.NewBuildJob=function() error("factory failure") end end
            ui:Toggle()
        end)
        V.NewBuildJob=original; assert(ok,why); eq(c.db,h); eq(#ui.rows,0)
        if mode=="factory" then eq(ui.buildJob,nil); assert(ui.reason:GetText():find("setup failed",1,true))
        else
            local j=ui.buildJob; local callback=ui.buildDriver.scripts.OnUpdate
            if mode=="Step" then j.Step=function() error("Step failure") end end
            if mode=="combat" then
                state.combat=true; callback(); eq(j.steps,0); env.InCombatLockdown=function() return nil end; callback(); eq(j.steps,0)
                env.InCombatLockdown=function() return false end
                while ui.buildJob do callback(); pause(checkpoint,"S01 resumed read-only rendering") end
                eq(#ui.rows,1)
            elseif mode=="context" then c.revision=c.revision+1; callback(); eq(ui.buildJob,nil); eq(#ui.rows,0)
            elseif mode=="options" then ui.options.sortColumn=1; callback(); eq(ui.buildJob,nil); eq(#ui.rows,0)
            elseif mode=="hidden" then ui.frame:Hide(); callback(); eq(ui.buildJob,nil); eq(#ui.rows,0)
            else callback(); eq(ui.buildJob,nil); eq(#ui.rows,0); assert(ui.reason:GetText():find("failed",1,true)) end
        end
        pause(checkpoint,"S01 render failure matrix")
    end
end)
case("S01 collector item retry failure timeout changed instance and lifecycle stale token matrices",function(checkpoint)
    for _,mode in ipairs({"success","failed","timeout","changed","context","archive"}) do
        local env,state=fixtureAPI(); local h,r=S.New(); local c=NS.Collectors.New(env,h); assert(c:Scan())
        state.loading=true; state.at=110; assert(c:Scan()); local pending=c.pending[90020]; assert(pending)
        local token=pending.token; local before=S.Active(h,character.guid,2913).fields.tool.last
        eq(before.observedAt,100); eq(before.value.rank,5)
        state.loading=false; state.at=115
        if mode=="timeout" then state.loading=true; state.timers[#state.timers].fn()
        elseif mode=="changed" then state.itemID=99999; c:ItemResult(90020,true)
        elseif mode=="context" then state.info.sourceCounter=2; c:ItemResult(90020,true)
        elseif mode=="archive" then assert(S.Archive(h,character.guid,2913,120,"retired")); c:ItemResult(90020,true)
        else c:ItemResult(90020,mode=="success") end
        if mode=="archive" then eq(S.Active(h,character.guid,2913),nil); eq(S.Read(h,character.guid,2913,1,true).fields.tool.last.observedAt,100)
        else
            local g=S.Active(h,character.guid,2913)
            eq(g.fields.tool.last.observedAt,mode=="success" and 115 or 100)
            eq(g.fields.tool.last.value.rank,5)
            if mode=="timeout" then assert(g.fields.tool.attempt.reason:find("timeout",1,true)) end
            if mode=="success" then eq(c:TokenValid(token),true) end
        end
        local revision=S.Revision(h); c:ItemResult(90020,true); eq(S.Revision(h),revision)
        pause(checkpoint,"S01 item retry matrix")
    end
end)
local function detailsCollector()
    local env,state,f,c=k2Fixture(); local h,r=S.New(); c.db=h; assert(c:Scan())
    assert(S.Apply(h,character,identity,{professionDetails=C.Observation("observed",sampleDetails(),200,"sample")},100,"fixture"))
    state.at=300; assert(c:Scan())
    env.C_ProfSpecs.GetDescriptionForPath=function() return "Synthetic path text" end
    env.C_ProfSpecs.GetPerksForPath=function(id) return {{perkID=id+1000000,isMajorPerk=false}} end
    env.C_ProfSpecs.GetUnlockRankForPerk=function() return 0 end
    env.C_ProfSpecs.GetStateForPerk=function() return 0 end
    env.C_ProfSpecs.GetDescriptionForPerk=function() return "Synthetic perk text" end
    return env,state,f,c,{guid=character.guid,id=2913,generation=1,archived=false},r
end
case("S01 Details all source interval and native fingerprint guard classes preserve old observations",function(checkpoint)
    for _,mode in ipairs({"serial","revision","token","counter","staged","closed","combat","time","node","nodeError","perkError","cancel"}) do
        local env,state,f,c,scope=detailsCollector()
        local j=NS.Details.NewCaptureJob(env,c,scope); eq(j.status,"running",mode)
        if mode=="serial" then c.serial=c.serial+1 elseif mode=="revision" then c.revision=c.revision+1
        elseif mode=="token" then assert(S.Apply(c.db,character,identity,{},300,"fixture"))
        elseif mode=="counter" then state.info.sourceCounter=2 elseif mode=="staged" then state.staged=true
        elseif mode=="closed" then state.shown=false elseif mode=="combat" then state.combat=true
        elseif mode=="time" then state.at=299 elseif mode=="node" then f.nodes[f.tabs[1].root].flags=1
        elseif mode=="nodeError" then env.C_Traits.GetNodeInfo=function() error("fixture private native error") end
        elseif mode=="perkError" then env.C_ProfSpecs.GetPerksForPath=function() return {{perkID=0,isMajorPerk=false}} end
        else j:Cancel() end
        finish(j,checkpoint); assert(j.status=="failed" or j.status=="discarded" or j.status=="cancelled",mode)
        eq(S.Active(c.db,character.guid,2913).fields.professionDetails.last.observedAt,200)
        assert(not tostring(j.reason):find("private native error",1,true)); pause(checkpoint,"S01 Details source guard")
    end
end)
case("S01 Details cached reload archive no profession APIs and ephemeral source lost on context drift",function(checkpoint)
    local env,state,_,c,scope,r=detailsCollector()
    local source=c:DetailsSource(scope); assert(source); source.fields.knowledgeRaw.last.value.tabs={}
    assert(#c:DetailsSource(scope).fields.knowledgeRaw.last.value.tabs>0)
    state.info.sourceCounter=2; eq(c:DetailsSource(scope),nil); state.info.sourceCounter=1; eq(c:DetailsSource(scope),nil)
    local h,reloaded=opened(r,checkpoint); local cached=NS.Collectors.New(env,h)
    local function forbidden() error("Cached view must not call live profession API") end
    cached.Context=forbidden; cached.Scan=forbidden
    for _,space in ipairs({env.C_Traits,env.C_ProfSpecs,env.C_TradeSkillUI}) do for key in pairs(space) do space[key]=forbidden end end
    local model=NS.Details.Model(cached,scope); eq(#model.branches,1); eq(model.branches[1].path.perks[1].state,2)
    eq(NS.Details.NewCaptureJob(env,cached,scope).status,"blocked")
    assert(S.Archive(h,character.guid,2913,400,"retired")); scope.archived=true
    model=NS.Details.Model(cached,scope); eq(model.archived,true); eq(#model.branches,1)
    opened(reloaded,checkpoint)
end)
case("S01 catalogue aggregate Details limits earned contradictions tree path child limits",function(checkpoint)
    local _,root,p=withDetails(); local guid=p[1].guid
    for _,mode in ipairs({"bytes","paths","perks","earned","treePaths","children"}) do
        local r=assert(C.Copy(root)); local g=r.characters[guid].professions[2913].active
        local v=g.fields.professionDetails.last.value; local d=r.catalogs[v.catalog].definition
        if mode=="bytes" then
            local path=d.trees[1].paths[1]; path.perks={}
            for i=1,8 do path.perks[i]={id=100000+i,rank=0,isMajorPerk=false,description=string.rep("x",4096)} end
        elseif mode=="paths" or mode=="perks" then
            d.trees={}
            for n=1,(mode=="paths" and 2 or 1) do
                local t={id=n,root=n*1000+1,capacity=mode=="paths" and (n==1 and 33 or 32) or 17,paths={}}; d.trees[n]=t
                for i=1,t.capacity do
                    local path={id=n*1000+i,capacity=1,description="",perks={}}; t.paths[i]=path
                    if mode=="perks" then for k=1,32 do path.perks[k]={id=i*100+k,rank=0,isMajorPerk=false,description="x"} end end
                end
            end
        elseif mode=="earned" then
            local path=d.trees[1].paths[1]; v.points[path.id]=0; path.perks[1].rank=1; v.states[path.perks[1].id]=2
        else
            local tree=firstTree(g); local definition=r.catalogs[tree.catalog].definition
            if mode=="treePaths" then
                local path=definition.paths[1]
                for i=#definition.paths+1,65 do local q=assert(C.Copy(path)); q.id=900000+i; q.children={}; definition.paths[i]=q end
            else for i=1,17 do definition.paths[1].children[i]=900000+i end end
        end
        local j=finish(S.NewOpenJob(r),checkpoint); eq(j.status,"failed",mode); eq(j.result,nil)
        pause(checkpoint,"S01 aggregate typed limit")
    end
end)
case("S01 owned input output tree children equipment raw summaries Details definitions cannot leak",function(checkpoint)
    local h,r,p=withDetails(); applyPack(h,p,"S01-second-owner")
    local verify=frozen(r); local g,c=S.Active(h,p[1].guid,2913)
    local tree=firstTree(g); tree.paths[1].children[1]=999999; tree.paths[1].name="caller"
    tree.accountingEvidence.quantity=99999; g.fields.tool.last.value.stats={}; g.fields.knowledgeRaw.last.value.tabs={}
    g.fields.professionDetails.last.value.trees[1].paths[1].perks[1].description="caller"
    c.name="caller"; verify()
    local again=S.Active(h,p[1].guid,2913); assert(again.fields.professionDetails.last.value.trees[1].paths[1].perks[1].description~="caller")
    assert(S.Active(h,"S01-second-owner",2913).fields["tree:1122"].last.value.paths[1].name~="caller")
    local input=assert(C.Copy(p[3])); local who=assert(C.Copy(p[1])); who.guid="S01-input-owned"
    local result=assert(S.Apply(h,who,p[2],input,200,p[5])); local snapshot=frozen(r)
    who.name="caller"; input.knowledgeRaw.value.tabs={}; result.fields.skill.last.value.skillLevel=999; snapshot()
    opened(r,checkpoint)
end)
case("S01 sparse large archive directory grows and selected lifecycle never copies whole history",function(checkpoint,annotate)
    local h,r,p=single(); local guid,id=p[1].guid,p[2].skillLineID
    for n=1,120 do
        assert(S.Archive(h,guid,id,200+n,"retained "..n)); applyPack(h,p)
        pause(checkpoint,"S01 full-rich archived generation")
    end
    local profession=r.characters[guid].professions[id]; eq(count(profession.archives),120); eq(profession.active.generation,121)
    local copier=C.Copy; local ok,why=pcall(function()
        C.Copy=function(v) assert(v~=profession.archives and v~=r.characters[guid] and v~=r,"Whole history copy"); return copier(v) end
        assert(S.Delete(h,{guid=guid,id=id,generation=1},true)); assert(S.Delete(h,{guid=guid,id=id,generation=3},true))
        eq(S.Read(h,guid,id,120,true).generation,120)
    end)
    C.Copy=copier; assert(ok,why); eq(count(profession.archives),118)
    local reopened,_,job=opened(r,checkpoint); local rows=build(reopened,{archived=true},checkpoint); eq(#rows,118)
    eq(S.Active(reopened,guid,id).generation,121)
    if annotate then annotate("120full-rich archives ->118 sparse; values="..visits(r).."; reopen Steps="..job.steps) end
end)
case("S01 handle14 typed mixed known unknown ties both directions active archive exact old fixtures",function(checkpoint)
    local original=C.Apply; local legacy
    local ok,why=pcall(function()
        C.Apply=function(db,...)
            local g,e=original(db,...); if g then legacy=assert(C.Copy(db)) end; return g,e
        end
        oldCase("U05 typed heading both directions active archived Name")()
    end)
    C.Apply=original; assert(ok,why); eq(count(legacy.characters),4)
    for _,archived in ipairs({false,true}) do
        if archived then for guid in pairs(legacy.characters) do assert(C.Archive(legacy,guid,2913,120,"sort")) end end
        local h=opened(legacy,checkpoint)
        for col=1,14 do for _,descending in ipairs({false,true}) do
            local opts={sortColumn=col,sortDescending=descending,archived=archived}
            local expected=V.Build(legacy,{},opts,100000); local actual=build(h,opts,checkpoint)
            eq(#actual,4)
            for i,row in ipairs(expected) do eq(actual[i].key,row.key); eq(actual[i].sortValues[col],row.sortValues[col]) end
            if col>I.Profession and col~=I.LastUpdated then eq(actual[4].guid,"U05-unknown") end
            pause(checkpoint,"S01 all14 mixed sort comparisons")
        end end
    end
end)
case("S01 late candidate and occupied allocation failures leave all saved pointers counters tokens unchanged",function(checkpoint)
    local h,r,p=single(); local verify=frozen(r); local token,revision=S.Token(h,p[1].guid,p[2].skillLineID),S.Revision(h)
    local original=C.Copy; local fired=false
    local ok,why=pcall(function()
        C.Copy=function(v)
            if type(v)=="table" and type(v.fields)=="table" then
                for key,f in pairs(v.fields) do
                    if key:match("^tree:") and f.last and f.last.build=="S01 late candidate" and f.last.value.format=="tree-ref-v1" then
                        fired=true; error("late candidate validation failure")
                    end
                end
            end
            return original(v)
        end
        eq(S.Apply(h,p[1],p[2],p[3],200,"S01 late candidate"),nil)
    end)
    C.Copy=original; assert(ok,why); eq(fired,true); verify(); eq(S.Token(h,p[1].guid,p[2].skillLineID),token); eq(S.Revision(h),revision)
    r.catalogs[r.nextCatalog]={unfamiliar=true}; local occupied=frozen(r)
    eq(S.Apply(h,p[1],p[2],p[3],200,"S01 another build"),nil); occupied(); eq(S.Token(h,p[1].guid,p[2].skillLineID),token)
    eq(S.Token(h,nil,nil),nil); pause(checkpoint,"S01 late atomic guards")
end)
case("S01 write reentry rejects nested Apply Archive Delete without interfering outer real preflight",function()
    local h,r,p=single(); local original=C.Copy; local fired=false; local revision=S.Revision(h)
    local ok,why=pcall(function()
        C.Copy=function(v)
            if not fired then
                fired=true
                eq(S.Apply(h,p[1],p[2],{},201,"nested"),nil)
                eq(S.Archive(h,p[1].guid,p[2].skillLineID,201,"nested"),false)
                eq(S.Delete(h,{guid=p[1].guid,character=true},true),false)
            end
            return original(v)
        end
        assert(S.Apply(h,p[1],p[2],{},200,"outer"))
    end)
    C.Copy=original; assert(ok,why); eq(fired,true); eq(S.Revision(h),revision+1)
    eq(S.Active(h,p[1].guid,p[2].skillLineID).scannedAt,200)
end)
-- S01 PIECE8 BEGIN
do
for _,mode in ipairs({"identical replacement","equal-content subtree alias"}) do
    local variant=mode
    case("S01 review new owner reused catalogue rejects "..variant,function()
        local h,r,p=single()
        applyPack(h,p,"S01-review-normal-reuse")
        assert(S.Active(h,"S01-review-normal-reuse",p[2].skillLineID))
        local ids={}; for id in pairs(r.catalogs) do ids[#ids+1]=id end; table.sort(ids)
        if variant=="identical replacement" then r.catalogs[ids[1]]=assert(C.Copy(r.catalogs[ids[1]]))
        else
            assert(deepEqual(r.catalogs[ids[1]].identity,r.catalogs[ids[2]].identity))
            r.catalogs[ids[1]].identity=r.catalogs[ids[2]].identity
        end
        local who=assert(C.Copy(p[1])); who.guid="S01-review-rejected-owner"
        local token=S.Token(h,p[1].guid,p[2].skillLineID)
        local newToken=S.Token(h,who.guid,p[2].skillLineID)
        local revision,nextCatalog=S.Revision(h),r.nextCatalog
        local unchanged=frozen(r)
        eq(S.Apply(h,who,p[2],p[3],200,p[5]),nil,"Reused saved catalogue must reject before committing a new owner")
        eq(r.characters[who.guid],nil); eq(r.nextCatalog,nextCatalog); eq(S.Revision(h),revision)
        eq(S.Token(h,p[1].guid,p[2].skillLineID),token); eq(S.Token(h,who.guid,p[2].skillLineID),newToken)
        unchanged()
    end)
end
local function batchJob(limit,work)
    return {status="running",steps=0,Step=function(j)
        j.steps=j.steps+1; if work then work(j) end
        if limit and j.steps>=limit then j.status="complete" end
    end}
end
case("S01 review new Details dependency reuse and nested clones preserve rejected owner graph",function()
    for _,mode in ipairs({"replacement","alias","nested clone"}) do
        local h,r,p=withDetails(); local catID,treeID
        for id,cat in pairs(r.catalogs) do if cat.kind=="details" then catID=id else treeID=id end end
        local obs={professionDetails=C.Observation("observed",sampleDetails(),200,"same Details")}
        local who=assert(C.Copy(p[1])); who.guid="S01-normal-details-reuse"
        assert(S.Apply(h,who,p[2],obs,100,"fixture")); assert(S.Active(h,who.guid,2913))
        if mode=="replacement" then r.catalogs[catID]=assert(C.Copy(r.catalogs[catID]))
        elseif mode=="alias" then r.catalogs[catID].identity=r.catalogs[treeID].identity
        else r.catalogs[catID].definition=assert(C.Copy(r.catalogs[catID].definition)) end
        who.guid="S01-reject-details-reuse"; local token=S.Token(h,p[1].guid,2913)
        local rev,nextCatalog=S.Revision(h),r.nextCatalog; local verify=frozen(r)
        eq(S.Apply(h,who,p[2],obs,100,"fixture"),nil,mode); eq(r.characters[who.guid],nil)
        eq(S.Revision(h),rev); eq(r.nextCatalog,nextCatalog); eq(S.Token(h,p[1].guid,2913),token); verify()
        eq(S.Active(h,p[1].guid,2913),nil,"Touched read still rejects the corrupted dependency")
    end
end)
case("S01 frame batch zero clock max16 terminal work counts and clockless fallback",function()
    local alternate=0
    local b=S.NewFrameBatch({debugprofilestop=function() return 0 end,
        GetTimePreciseSec=function() alternate=alternate+1; return 0 end})
    local j=batchJob(33); local allow=function() return true end
    local ok,n=b:Step(j,allow); eq(ok,true); eq(n,16); eq(j.steps,16); eq(b.status,"unit-cap")
    ok,n=b:Step(j,allow); eq(ok,true); eq(n,16)
    ok,n=b:Step(j,allow); eq(ok,true); eq(n,1); eq(b.status,"terminal")
    eq(b.work.frames,3); eq(b.work.steps,33); eq(b.work.maxSteps,16); eq(alternate,0); eq(b.mode,"profile-ms")
    local fallback=S.NewFrameBatch({}); j=batchJob(10)
    ok,n=fallback:Step(j,allow); eq(ok,true); eq(n,1); eq(j.steps,1)
    eq(fallback.mode,"clockless-one-step"); eq(fallback.status,"clockless-one-step"); eq(fallback.work.lastElapsed,nil)
end)
case("S01 frame batch two ms boundary seconds conversion and one unit overshoot",function()
    for _,seconds in ipairs({false,true}) do
        local ms=0; local env={}
        env[seconds and "GetTimePreciseSec" or "debugprofilestop"]=function() return seconds and ms/1000 or ms end
        local b=S.NewFrameBatch(env); local j=batchJob(nil,function() ms=ms+.5 end)
        local ok,n=b:Step(j,function() return true end); eq(ok,true); eq(n,4); eq(b.work.lastElapsed,2); eq(b.status,"budget")
        eq(b.mode,seconds and "precise-seconds" or "profile-ms")
    end
    local ms=0; local b=S.NewFrameBatch({debugprofilestop=function() return ms end})
    local j=batchJob(nil,function() ms=ms+7 end)
    local ok,n=b:Step(j,function() return true end); eq(ok,true); eq(n,1); eq(b.work.lastElapsed,7)
    eq(j.steps,1,"The unit completed; observed budget is not preemption")
    local calls=0; b=S.NewFrameBatch({debugprofilestop=function() calls=calls+1; return calls==1 and 0 or 2 end})
    j=batchJob(); ok,n=b:Step(j,function() return true end); eq(ok,true); eq(n,0); eq(j.steps,0)
end)
case("S01 frame batch selected clock nil nonfinite throw backward overflow no switch fail closed",function(checkpoint)
    for _,mode in ipairs({"nil","false","string","nan","infinity","throw","backward","secondsOverflow","elapsedOverflow"}) do
        local reads,alternate,ms=0,0,0
        local function clock()
            reads=reads+1
            if mode=="secondsOverflow" then return 1e308 end
            if mode=="elapsedOverflow" then return ms end
            if reads<3 then return 10 end
            if mode=="nil" then return nil elseif mode=="false" then return false elseif mode=="string" then return "10"
            elseif mode=="nan" then return 0/0 elseif mode=="infinity" then return math.huge
            elseif mode=="throw" then error("S01_PRIVATE_CLOCK_PAYLOAD") else return 9 end
        end
        if mode=="elapsedOverflow" then ms=-1e308 end
        local env={debugprofilestop=clock,GetTimePreciseSec=function() alternate=alternate+1; return 10 end}
        if mode=="secondsOverflow" then env.debugprofilestop=nil; env.GetTimePreciseSec=clock end
        local b=S.NewFrameBatch(env); local j=batchJob(nil,function() if mode=="elapsedOverflow" then ms=1e308 end end)
        local ok,why=b:Step(j,function() return true end); eq(ok,false,mode); assert(type(why)=="string")
        assert(not why:find("PRIVATE_CLOCK_PAYLOAD",1,true)); eq(alternate,0); eq(b.status,"failed")
        local before=j.steps; eq(b:Step(j,function() return true end),false); eq(j.steps,before)
        eq(before,mode=="secondsOverflow" and 0 or 1); pause(checkpoint,"S01 selected clock failure")
    end
    local ms=100; local b=S.NewFrameBatch({debugprofilestop=function() return ms end}); local j=batchJob()
    assert(b:Step(j,function() return true end)); ms=99
    eq(b:Step(j,function() return true end),false); eq(j.steps,16,"Backward across frames must not advance")
end)
case("S01 frame batch guard pauses errors and reentry from clock guard job stop additional work",function(checkpoint)
    local b=S.NewFrameBatch({debugprofilestop=function() return 0 end}); local j=batchJob()
    local ok,n=b:Step(j,function() return false end); eq(ok,true); eq(n,0); eq(b.status,"paused")
    local safe=true; j=batchJob(nil,function() safe=false end)
    ok,n=b:Step(j,function() return safe end); eq(ok,true); eq(n,1); eq(j.steps,1)
    for _,mode in ipairs({"clock","guard","job","guardError","jobError"}) do
        local batch,job,entered
        local function nested()
            if not entered then entered=true; eq(batch:Step(job,function() return true end),false) end
        end
        batch=S.NewFrameBatch({debugprofilestop=function() if mode=="clock" then nested() end; return 0 end})
        job=batchJob(nil,function() if mode=="job" then nested() elseif mode=="jobError" then error("S01_PRIVATE_JOB_PAYLOAD") end end)
        local ok,reason=batch:Step(job,function()
            if mode=="guard" then nested() elseif mode=="guardError" then error("S01_PRIVATE_GUARD_PAYLOAD") end
            return true
        end)
        eq(ok,false,mode); eq(batch.status,"failed"); assert(not reason:find("PRIVATE_",1,true))
        eq(job.steps,(mode=="job" or mode=="jobError") and 1 or 0); pause(checkpoint,"S01 batch reentry/error")
    end
end)
local function pumpStartup(cmd,checkpoint)
    local callbacks=0; local job=cmd.storageJob
    while not S.IsHandle(cmd.collector.db) do
        assert(job.status=="running" or job.status=="complete",job.reason)
        local callback=cmd.storageFrame.scripts.OnUpdate; assert(callback,"Startup driver retired before publication")
        callbacks=callbacks+1; callback(); assert(cmd.storageBatch.work.lastSteps<=16)
        pause(checkpoint,"S01 actual startup batch callback")
    end
    eq(job.status,"complete"); eq(cmd.storageBatch.work.frames,callbacks); eq(cmd.storageBatch.work.steps,job.steps)
    return callbacks,job.steps
end
local function pumpDashboard(ui,checkpoint)
    local callbacks=0; local job=ui.buildJob; local batch=ui.buildBatch
    while ui.buildJob do
        assert(ui.buildJob==job,"Unexpected superseding build in stable growth fixture")
        callbacks=callbacks+1; ui.buildDriver.scripts.OnUpdate(); assert(batch.work.lastSteps<=16)
        pause(checkpoint,"S01 actual dashboard batch callback")
    end
    eq(job.status,"complete",job.reason); eq(batch.work.frames,callbacks); eq(batch.work.steps,job.steps)
    return callbacks,job.steps
end
-- Wrap only a fixture-owned job; restore the shared Copy observer before any yield.
local function observeUnitCatalogues(job)
    local step=job.Step
    job.Step=function(self)
        local original=C.Copy; local definitions={}
        local ok,why=pcall(function()
            C.Copy=function(v)
                if type(v)=="table" and (v.kind=="tree" or v.kind=="details") then
                    local found=false
                    for _,other in ipairs(definitions) do if deepEqual(v,other) then found=true end end
                    if not found then definitions[#definitions+1]=v end
                end
                return original(v)
            end
            step(self)
        end)
        C.Copy=original; assert(ok,why)
        assert(#definitions<=1,"A batched frame may not enlarge an individual Step's catalogue budget")
    end
end
for _,size in ipairs({46,100,200}) do
local target=size
case("S01 actual batched startup dashboard growth"..target.." callbacks versus steps",function(checkpoint,annotate)
    local legacy,packs=seed(); local env=fixtureAPI(); nativeWidgets(env)
    env.debugprofilestop=function() return 0 end; env.CraftArmyDB=legacy
    env.DEFAULT_CHAT_FRAME={AddMessage=function() end}
    local cmd=NS.Commands.New(env); cmd:Login(); observeUnitCatalogues(cmd.storageJob)
    local migrationFrames,migrationSteps=pumpStartup(cmd,checkpoint)
    local h,r=cmd.collector.db,env.CraftArmyDB; local chars={}
    for guid in pairs(r.characters) do chars[#chars+1]=guid end; table.sort(chars)
    for _,guid in ipairs(chars) do
        local id=next(r.characters[guid].professions)
        for _,p in ipairs(packs) do if p[2].skillLineID~=id then applyPack(h,p,guid); break end end
    end
    local records={"migration="..migrationFrames.."callbacks/"..migrationSteps.."steps"}
    for n=9,target do
        local guid="S01-batched-growth-"..n
        applyPack(h,packs[(2*n-2)%8+1],guid); applyPack(h,packs[(2*n-1)%8+1],guid)
        if n==target then
            local e=fixtureAPI(); nativeWidgets(e); e.debugprofilestop=function() return 0 end
            e.CraftArmyDB=r; e.DEFAULT_CHAT_FRAME=env.DEFAULT_CHAT_FRAME
            local reload=NS.Commands.New(e); reload:Login(); observeUnitCatalogues(reload.storageJob)
            local openFrames,openSteps=pumpStartup(reload,checkpoint)
            local ui=reload.dashboard; ui:Toggle(); observeUnitCatalogues(ui.buildJob)
            local renderFrames,renderSteps=pumpDashboard(ui,checkpoint)
            eq(#ui.rows,n*2); eq(count(e.CraftArmyDB.characters),n)
            assert(openFrames<openSteps and renderFrames<renderSteps)
            eq(reload.storageBatch.mode,"profile-ms"); eq(ui.buildBatch.mode,"profile-ms")
            records[#records+1]=n.."x2:open="..openFrames.."/"..openSteps..",view="..renderFrames.."/"..renderSteps
        end
        pause(checkpoint,"S01 full-rich batched growth")
    end
    if annotate then annotate(table.concat(records,"; ")) end
end)
end
case("S01 batched startup terminal clock cleanup pause supersession and stale publication guards",function(checkpoint)
    for _,mode in ipairs({"rootClock","clockError","combatClock","selftestClock","retryClock","retryCleanup","combatCleanup"}) do
        local env,state=fixtureAPI(); nativeWidgets(env); local legacy=seed(); env.CraftArmyDB=legacy
        env.DEFAULT_CHAT_FRAME={AddMessage=function() end}; local cmd,fired,newJob
        local function change()
            fired=true
            if mode=="rootClock" then env.CraftArmyDB={schema=99}
            elseif mode=="clockError" then error("S01_PRIVATE_TERMINAL_CLOCK")
            elseif mode=="combatClock" or mode=="combatCleanup" then state.combat=true
            elseif mode=="selftestClock" then cmd.selftest={}
            else cmd:Run("storage cancel"); cmd:Run("storage retry"); newJob=cmd.storageJob end
        end
        env.debugprofilestop=function()
            if cmd and not fired and ((mode=="retryClock") or
                (mode~="retryCleanup" and mode~="combatCleanup" and cmd.storageJob.status=="complete")) then change() end
            return 0
        end
        cmd=NS.Commands.New(env); cmd:Login(); local oldJob=cmd.storageJob
        local frame=cmd.storageFrame; local callback=frame.scripts.OnUpdate
        if mode=="retryCleanup" or mode=="combatCleanup" then
            local hide=frame.Hide; frame.Hide=function(w)
                hide(w); if not fired and oldJob.status=="complete" then change() end
            end
        end
        while not fired do callback(); pause(checkpoint,"S01 terminal startup batching") end
        eq(cmd.collector.db,nil,"Unsafe/superseded batch cannot publish the root")
        if mode=="rootClock" then eq(env.CraftArmyDB.schema,99)
        else eq(env.CraftArmyDB,legacy) end
        if mode=="retryClock" or mode=="retryCleanup" then
            eq(cmd.storageJob,newJob); assert(newJob~=oldJob); assert(cmd.collector.blockReason:find("pending",1,true))
            pumpStartup(cmd,checkpoint)
            local root,batch,reason=env.CraftArmyDB,cmd.storageBatch,cmd.collector.reason
            local frames=batch.work.frames; local verify=frozen(root)
            callback(); eq(env.CraftArmyDB,root); eq(cmd.storageBatch,batch); eq(batch.work.frames,frames)
            eq(cmd.collector.reason,reason); verify()
        elseif mode=="combatClock" or mode=="selftestClock" then
            local steps=oldJob.steps; state.combat=false; cmd.selftest=nil; callback()
            eq(env.CraftArmyDB,oldJob.savedRoot); assert(S.IsHandle(cmd.collector.db)); eq(oldJob.steps,steps)
        else
            local root=env.CraftArmyDB; callback(); eq(env.CraftArmyDB,root); eq(cmd.collector.db,nil)
            if mode=="clockError" then eq(cmd.storageBatch.status,"failed"); assert(not cmd.collector.blockReason:find("PRIVATE_",1,true)) end
        end
        pause(checkpoint,"S01 startup publication fixture")
    end
end)
case("S01 batched dashboard terminal clock cleanup supersession safety and store revision guards",function(checkpoint)
    for _,mode in ipairs({"optionsClock","contextClock","clockError","hiddenClock","writeClock","retryCleanup","combatCleanup"}) do
        local h,r,p=single(); local env,state=fixtureAPI(); nativeWidgets(env)
        local c=NS.Collectors.New(env,h); local ui=NS.Dashboard.New(env,c); local fired,newJob
        local function change()
            fired=true
            if mode=="clockError" then error("S01_PRIVATE_RENDER_CLOCK")
            elseif mode=="contextClock" then c.revision=c.revision+1
            elseif mode=="hiddenClock" then ui.frame:Hide()
            elseif mode=="writeClock" then assert(S.Apply(h,p[1],p[2],{},200,"clock write"))
            elseif mode=="combatCleanup" then state.combat=true
            else ui.options.character="no such name"; ui:Refresh(); newJob=ui.buildJob end
        end
        env.debugprofilestop=function()
            if not fired and mode~="retryCleanup" and mode~="combatCleanup" and ui.buildJob and ui.buildJob.status=="complete" then change() end
            return 0
        end
        ui:Toggle(); local job=ui.buildJob; local callback=ui.buildDriver.scripts.OnUpdate
        if mode=="retryCleanup" or mode=="combatCleanup" then
            local hide=ui.buildDriver.Hide; ui.buildDriver.Hide=function(w)
                hide(w); if not fired and job.status=="complete" then change() end
            end
        end
        while not fired do callback(); pause(checkpoint,"S01 terminal render batching") end
        eq(#ui.rows,0); eq(c.db,h)
        if mode=="optionsClock" or mode=="retryCleanup" then
            eq(ui.buildJob,newJob); assert(newJob~=job); assert(ui.reason:GetText():find("Building",1,true))
            pumpDashboard(ui,checkpoint); eq(#ui.rows,0)
            local rows,batch,reason=ui.rows,ui.buildBatch,ui.reason:GetText(); local frames=batch.work.frames
            callback(); eq(ui.rows,rows); eq(ui.buildBatch,batch); eq(batch.work.frames,frames); eq(ui.reason:GetText(),reason)
        elseif mode=="combatCleanup" then
            eq(ui.buildJob,nil); state.combat=false; ui:Refresh(); pumpDashboard(ui,checkpoint); eq(#ui.rows,1)
        else
            eq(ui.buildJob,nil); callback(); eq(#ui.rows,0)
            if mode=="clockError" then eq(ui.buildBatch.status,"failed"); assert(not ui.reason:GetText():find("PRIVATE_",1,true)) end
            if mode=="writeClock" then eq(S.Active(h,p[1].guid,p[2].skillLineID).scannedAt,200) end
        end
        pause(checkpoint,"S01 render publication fixture")
    end
end)
end
-- S01 PIECE8 END
-- S01 PIECE9 BEGIN
do
local function startupFixture()
    local env,state=fixtureAPI(); nativeWidgets(env); env.CraftArmyDB=seed()
    env.DEFAULT_CHAT_FRAME={AddMessage=function() end}
    local cmd=NS.Commands.New(env)
    return env,state,cmd
end
local function completeReplacement(cmd,env,oldCallback,checkpoint)
    local job,frame,batch=cmd.storageJob,cmd.storageFrame,cmd.storageBatch
    local reason,label=cmd.collector.blockReason,cmd.dashboard.reason:GetText()
    eq(job.status,"running"); eq(batch.status,"ready"); eq(cmd.collector.storagePending,true)
    eq(cmd.collector.reason,reason); eq(cmd.collector.db,nil)
    assert(reason:find("pending",1,true),"Replacement must retain its pending explanation")
    local steps,frames=job.steps,batch.work.frames; local original=env.CraftArmyDB
    local verify=frozen(original)
    oldCallback()
    eq(cmd.storageJob,job); eq(cmd.storageFrame,frame); eq(cmd.storageBatch,batch)
    eq(job.status,"running"); eq(batch.status,"ready"); eq(cmd.collector.storagePending,true)
    eq(cmd.collector.blockReason,reason); eq(cmd.dashboard.reason:GetText(),label)
    eq(job.steps,steps); eq(batch.work.frames,frames); eq(env.CraftArmyDB,original); verify()
    while not S.IsHandle(cmd.collector.db) do
        assert(job.status=="running" or job.status=="complete",job.reason)
        assert(frame.scripts.OnUpdate,"Replacement startup unexpectedly retired")
        frame.scripts.OnUpdate(); pause(checkpoint,"S01 replacement startup completion")
    end
    eq(env.CraftArmyDB,job.savedRoot); eq(job.status,"complete"); eq(cmd.storageJob,job)
    local saved,reason=env.CraftArmyDB,cmd.collector.reason; local ticks=batch.work.frames
    oldCallback(); eq(env.CraftArmyDB,saved); eq(cmd.collector.reason,reason); eq(batch.work.frames,ticks)
end
case("S01 startup combined terminal clock error cleanup retry preserves replacement pending status",function(checkpoint)
    local env,_,cmd=startupFixture(); local failed,retried,newJob,newFrame,newBatch,pending,label
    env.debugprofilestop=function()
        if not failed and cmd.storageJob and cmd.storageJob.status=="complete" then
            failed=true; error("S01_TERMINAL_CLOCK_ERROR")
        end
        return 0
    end
    cmd:Login(); cmd.dashboard:Toggle()
    local oldJob,frame=cmd.storageJob,cmd.storageFrame; local callback=frame.scripts.OnUpdate
    local original=env.CraftArmyDB; local verify=frozen(original); local hide=frame.Hide
    frame.Hide=function(w)
        hide(w)
        if failed and not retried then
            retried=true; cmd:Run("storage retry")
            newJob,newFrame,newBatch=cmd.storageJob,cmd.storageFrame,cmd.storageBatch
            pending=cmd.collector.blockReason; label=cmd.dashboard.reason:GetText()
        end
    end
    while not retried do callback(); pause(checkpoint,"S01 combined failure cleanup") end
    assert(newJob~=oldJob); eq(cmd.storageJob,newJob); eq(cmd.storageFrame,newFrame); eq(cmd.storageBatch,newBatch)
    eq(cmd.collector.blockReason,pending,"Retired failure must not overwrite new startup status")
    eq(cmd.dashboard.reason:GetText(),label); eq(env.CraftArmyDB,original); eq(cmd.collector.db,nil); verify()
    completeReplacement(cmd,env,callback,checkpoint)
end)
case("S01 startup source drift cleanup retry and current source fault status",function(checkpoint)
    for _,mode in ipairs({"beforeBatch","terminalClock","finishHide","noRetry","setupShow"}) do
        local env,_,cmd=startupFixture(); local drifted,retried,pending,label,newJob,newFrame,newBatch
        local original=env.CraftArmyDB; local verify=frozen(original); local other=assert(C.Copy(original))
        env.debugprofilestop=function()
            if mode=="terminalClock" and not drifted and cmd.storageJob and cmd.storageJob.status=="complete" then
                drifted=true; env.CraftArmyDB=other
            end
            return 0
        end
        if mode=="setupShow" then
            local create=env.CreateFrame
            env.CreateFrame=function(...)
                local f=create(...); local show=f.Show
                f.Show=function(w) show(w); if not drifted then drifted=true; env.CraftArmyDB=other end end
                return f
            end
        end
        cmd:Login(); cmd.dashboard:Toggle(); local job,frame=cmd.storageJob,cmd.storageFrame
        local callback=frame.scripts.OnUpdate; local hide=frame.Hide
        frame.Hide=function(w)
            hide(w)
            if mode=="finishHide" and not drifted and job.status=="complete" then
                drifted=true; env.CraftArmyDB=other
            end
            if drifted and mode~="noRetry" and mode~="setupShow" and not retried then
                retried=true; env.CraftArmyDB=original; cmd:Run("storage retry")
                newJob,newFrame,newBatch=cmd.storageJob,cmd.storageFrame,cmd.storageBatch
                pending=cmd.collector.blockReason; label=cmd.dashboard.reason:GetText()
            end
        end
        if mode=="beforeBatch" or mode=="noRetry" then drifted=true; env.CraftArmyDB=other end
        if mode=="setupShow" then
            assert(cmd.collector.blockReason:find("source",1,true),"Current setup invocation must explain source drift")
            eq(cmd.collector.db,nil); eq(env.CraftArmyDB,other); verify()
        else
            while not retried and job.status=="running" do callback(); pause(checkpoint,"S01 source drift cleanup") end
            if mode=="finishHide" or mode=="terminalClock" then
                while not retried do callback(); pause(checkpoint,"S01 terminal source drift") end
            end
            eq(cmd.collector.db,nil); verify()
            if mode=="noRetry" then
                eq(env.CraftArmyDB,other); eq(cmd.storageJob,job)
                assert(cmd.collector.blockReason:find("source",1,true),"Current invocation explains drift without original root ownership")
                local reason=cmd.collector.blockReason; callback(); eq(cmd.collector.blockReason,reason)
            else
                eq(cmd.storageJob,newJob); eq(cmd.storageFrame,newFrame); eq(cmd.storageBatch,newBatch)
                eq(cmd.collector.blockReason,pending); eq(cmd.dashboard.reason:GetText(),label)
                eq(env.CraftArmyDB,original); completeReplacement(cmd,env,callback,checkpoint)
            end
        end
    end
end)
case("S01 startup setup return throw and failure cleanup cannot overwrite replacement",function(checkpoint)
    for _,mode in ipairs({"createReturn","createThrow","setReturn","setThrow","showReturn","showThrow","failureHide","failureSet"}) do
        local env,_,cmd=startupFixture(); local create=env.CreateFrame
        local fired,newJob,newFrame,newBatch,pending,label,oldCallback,oldJob
        local original=env.CraftArmyDB; local verify=frozen(original)
        cmd:Login(); cmd:Run("storage cancel"); cmd.dashboard:Toggle()
        local function replace()
            fired=true; oldJob=cmd.storageJob
            cmd:StartStorage()
            newJob,newFrame,newBatch=cmd.storageJob,cmd.storageFrame,cmd.storageBatch
            pending=cmd.collector.blockReason; label=cmd.dashboard.reason:GetText()
        end
        env.CreateFrame=function(...)
            local f=create(...)
            if fired then return f end
            if mode=="createReturn" or mode=="createThrow" then
                replace(); if mode=="createThrow" then error("S01_SETUP_CREATE") end
            end
            local set,show,hide=f.SetScript,f.Show,f.Hide
            f.SetScript=function(w,k,fn)
                set(w,k,fn)
                if k=="OnUpdate" and fn and not fired then
                    oldCallback=fn
                    if mode=="setReturn" or mode=="setThrow" then
                        replace(); if mode=="setThrow" then error("S01_SETUP_SET") end
                    elseif mode=="failureSet" then error("S01_SETUP_SET_FAILURE") end
                elseif k=="OnUpdate" and not fn and mode=="failureSet" and not fired then replace() end
            end
            f.Show=function(w)
                show(w)
                if not fired then
                    if mode=="showReturn" or mode=="showThrow" then
                        replace(); if mode=="showThrow" then error("S01_SETUP_SHOW") end
                    elseif mode=="failureHide" then error("S01_SETUP_SHOW_FAILURE") end
                end
            end
            f.Hide=function(w) hide(w); if mode=="failureHide" and not fired then replace() end end
            return f
        end
        cmd:Run("storage retry"); assert(fired,mode); assert(newJob~=oldJob)
        eq(cmd.storageJob,newJob); eq(cmd.storageFrame,newFrame); eq(cmd.storageBatch,newBatch)
        eq(cmd.collector.blockReason,pending); eq(cmd.dashboard.reason:GetText(),label)
        eq(env.CraftArmyDB,original); eq(cmd.collector.db,nil); verify()
        completeReplacement(cmd,env,oldCallback or function() end,checkpoint)
    end
end)
case("S01 startup explicit cancel and entry cleanup retain replacement at each boundary",function(checkpoint)
    for _,action in ipairs({"cancel","entry"}) do
        for _,boundary in ipairs({"jobCancel","setScript","hide"}) do
            local env,_,cmd=startupFixture(); env.debugprofilestop=function() return 0 end
            cmd:Login(); cmd.dashboard:Toggle()
            local oldJob,frame=cmd.storageJob,cmd.storageFrame; local callback=frame.scripts.OnUpdate
            local original=env.CraftArmyDB; local verify=frozen(original)
            local fired,newJob,newFrame,newBatch,pending,label
            local function replace()
                if fired then return end
                fired=true; cmd:Run("storage retry")
                newJob,newFrame,newBatch=cmd.storageJob,cmd.storageFrame,cmd.storageBatch
                pending=cmd.collector.blockReason; label=cmd.dashboard.reason:GetText()
            end
            local cancel,set,hide=oldJob.Cancel,frame.SetScript,frame.Hide
            oldJob.Cancel=function(j) cancel(j); if boundary=="jobCancel" then replace() end end
            frame.SetScript=function(w,k,fn) set(w,k,fn); if boundary=="setScript" and not fn then replace() end end
            frame.Hide=function(w) hide(w); if boundary=="hide" then replace() end end
            if action=="cancel" then cmd:Run("storage cancel") else cmd:StartStorage() end
            assert(fired,action..boundary); assert(newJob~=oldJob)
            eq(cmd.storageJob,newJob); eq(cmd.storageFrame,newFrame); eq(cmd.storageBatch,newBatch)
            eq(cmd.collector.blockReason,pending); eq(cmd.dashboard.reason:GetText(),label)
            eq(env.CraftArmyDB,original); eq(cmd.collector.db,nil); verify()
            completeReplacement(cmd,env,callback,checkpoint)
        end
    end
end)
case("S01 startup thrown work finish and failure cleanup preserve replacement on cancel set hide",function(checkpoint)
    for _,path in ipairs({"workError","finish","batchFailure"}) do
        for _,boundary in ipairs({"jobCancel","setScript","hide"}) do
            if path~="finish" or boundary~="jobCancel" then
                local env,_,cmd=startupFixture(); env.debugprofilestop=function() return 0 end
                cmd:Login(); cmd.dashboard:Toggle()
                local oldJob,frame=cmd.storageJob,cmd.storageFrame; local callback=frame.scripts.OnUpdate
                local original=env.CraftArmyDB; local verify=frozen(original)
                local fired,newJob,newFrame,newBatch,pending,label
                local function replace()
                    if fired then return end
                    fired=true; cmd:Run("storage retry")
                    newJob,newFrame,newBatch=cmd.storageJob,cmd.storageFrame,cmd.storageBatch
                    pending=cmd.collector.blockReason; label=cmd.dashboard.reason:GetText()
                end
                local cancel,set,hide=oldJob.Cancel,frame.SetScript,frame.Hide
                oldJob.Cancel=function(j) cancel(j); if boundary=="jobCancel" then replace() end end
                frame.SetScript=function(w,k,fn) set(w,k,fn); if boundary=="setScript" and not fn then replace() end end
                frame.Hide=function(w) hide(w); if boundary=="hide" then replace() end end
                if path=="workError" then cmd.storageBatch.Step=function() error("S01_WORK_ERROR") end
                elseif path=="batchFailure" then cmd.storageBatch.Step=function() return false,"Fixture batch failed" end end
                while not fired do callback(); pause(checkpoint,"S01 error finish cleanup boundary") end
                assert(newJob~=oldJob); eq(cmd.storageJob,newJob); eq(cmd.storageFrame,newFrame); eq(cmd.storageBatch,newBatch)
                eq(cmd.collector.blockReason,pending); eq(cmd.dashboard.reason:GetText(),label)
                eq(env.CraftArmyDB,original); eq(cmd.collector.db,nil); verify()
                completeReplacement(cmd,env,callback,checkpoint)
            end
        end
    end
end)
end
-- S01 PIECE9 END
-- R01 BEGIN (additive; S01 helpers and original cases remain unchanged)
local function redrawPump(ui,checkpoint)
    local ticks=0
    while ui.buildJob do
        ticks=ticks+1; assert(ticks<10000,"R01 bounded fixture driver did not finish")
        ui.buildDriver.scripts.OnUpdate(); pause(checkpoint,"R01 actual dashboard frame")
    end
end
local function redrawFixture(checkpoint)
    local env,state=fixtureAPI(); nativeWidgets(env); env.debugprofilestop=function() return 0 end
    env.CraftArmyDB=seed(); env.DEFAULT_CHAT_FRAME={AddMessage=function() end}
    local cmd=NS.Commands.New(env); cmd:Login()
    while not S.IsHandle(cmd.collector.db) do cmd.storageFrame.scripts.OnUpdate(); pause(checkpoint,"R01 startup") end
    local ui=cmd.dashboard; ui:Toggle(); redrawPump(ui,checkpoint)
    return ui,env,state,cmd
end
case("R01 completed eight-row Commands close retains visible surface until replacement",function(checkpoint)
    local ui,env,_,cmd=redrawFixture(checkpoint)
    local rows,height,viewport=ui.rows,ui.frame:GetHeight(),ui.viewport:GetHeight()
    local verify=frozen(env.CraftArmyDB)
    cmd:Event("TRADE_SKILL_CLOSE")
    eq(ui.rows,rows,"Completed list retained by reference"); eq(#ui.rows,8)
    eq(ui.frame:GetHeight(),height); eq(ui.viewport:GetHeight(),viewport)
    for n=1,8 do eq(ui.widgets[n]:IsShown(),true) end
    eq(ui.retained,true); assert(ui.reason:GetText():find("Previous saved view",1,true))
    redrawPump(ui,checkpoint); eq(#ui.rows,8); eq(ui.retained,false); verify()
end)
case("R01 identical in-flight requests coalesce and every real input supersedes without writes",function(checkpoint)
    local ui,env,_,cmd=redrawFixture(checkpoint); local c=cmd.collector
    local verify=frozen(env.CraftArmyDB); local rows=ui.rows
    ui:Refresh(); local job=ui.buildJob; ui.buildDriver.scripts.OnUpdate(); local steps=job.steps
    for _=1,4 do ui:Refresh(); eq(ui.buildJob,job); eq(job.steps,steps); eq(ui.rows,rows) end
    for _,mode in ipairs({"serial","revision","fresh","character","profession","attention","sort","direction","View"}) do
        local old=ui.buildJob; local stale=ui.buildDriver.scripts.OnUpdate
        if mode=="serial" then c.serial=c.serial+1 elseif mode=="revision" then c.revision=c.revision+1
        elseif mode=="fresh" then c.fresh={}
        elseif mode=="character" then ui.options.character="no matching character"
        elseif mode=="profession" then ui.options.professionFamily=773
        elseif mode=="attention" then ui.options.attention="Moxie"
        elseif mode=="sort" then ui.options.sortColumn=I.Name
        elseif mode=="direction" then ui.options.sortDescending=true else ui.options.archived=true end
        ui:Refresh(); assert(ui.buildJob~=old); eq(old.status,"cancelled"); eq(ui.rows,rows)
        local nextJob=ui.buildJob; stale(); eq(ui.buildJob,nextJob); eq(ui.rows,rows); verify()
        pause(checkpoint,"R01 supersession inputs")
    end
    redrawPump(ui,checkpoint); eq(#ui.rows,0); eq(ui.completed.rows,ui.rows); eq(ui.retained,false)
    local empty=ui.rows; ui:Refresh(); eq(ui.rows,empty); redrawPump(ui,checkpoint); eq(#ui.rows,0)
    ui.options={}; ui:Refresh(); redrawPump(ui,checkpoint); eq(#ui.rows,8); verify()
end)
case("R01 post-scan saved revision retains completed values and changes only after publication",function(checkpoint)
    local ui,env,_,cmd=redrawFixture(checkpoint); local rows=ui.rows; local _,packs=seed()
    ui:Refresh(); local old=ui.buildJob; local stale=ui.buildDriver.scripts.OnUpdate
    applyPack(cmd.collector.db,packs[1],nil,900)
    local verify=frozen(env.CraftArmyDB); ui:Refresh(); assert(ui.buildJob~=old); eq(ui.rows,rows)
    eq(ui.retained,true); stale(); eq(ui.rows,rows); redrawPump(ui,checkpoint)
    assert(ui.rows~=rows); eq(#ui.rows,8); eq(ui.retained,false); verify()
end)
case("R01 all normal Shift cell tree and status hovers are historical without graph mutation",function(checkpoint)
    local ui,env,_,cmd=redrawFixture(checkpoint); local row=ui.rows[1]
    -- Fixture-owned presentation sentinel: test exact fresh-marker substitution,
    -- never change any stored observation or the original tests' case bodies.
    row.cells[I.Skill]="|cffffbb00!|r 4/100"; ui:Render()
    local verify=frozen({ui.rows,env.CraftArmyDB,cmd.collector.fresh})
    env.GameTooltip:Show(); ui.selected=row; ui:Confirm({guid=row.guid,id=row.id,generation=row.generation},"delete","fixture")
    ui:Refresh(); eq(env.GameTooltip:IsShown(),false); eq(ui.confirmation,nil); eq(ui.confirmPanel:IsShown(),false)
    eq(ui.widgets[1].cells[I.Skill].label:GetText(),"|cff999999!|r 4/100")
    for _,shift in ipairs({false,true}) do
        env.IsShiftKeyDown=function() return shift end
        for _,w in ipairs(ui.widgets) do if w.row then
            for _,cell in ipairs(w.cells) do
                cell.scripts.OnEnter(cell); eq(env.GameTooltip.nativeLink,nil)
                eq(#env.GameTooltip.lines,1); assert(env.GameTooltip.lines[1]:find("Previous saved values",1,true))
            end
            for _,bar in ipairs(w.bars) do if bar.tree then
                bar.scripts.OnEnter(bar); eq(env.GameTooltip.nativeLink,nil); eq(#env.GameTooltip.lines,1)
                assert(env.GameTooltip.lines[1]:find("Previous saved values",1,true))
            end end
        end end
        ui.statusArea.scripts.OnEnter(ui.statusArea)
        assert(table.concat(env.GameTooltip.lines,"\n"):find("Previous saved view",1,true))
    end
    verify(); redrawPump(ui,checkpoint); eq(ui.retained,false)
    ui.widgets[1].cells[I.Name].scripts.OnEnter(ui.widgets[1].cells[I.Name])
    assert(not table.concat(env.GameTooltip.lines,"\n"):find("Previous saved values",1,true))
    verify()
end)
case("R01 pending failed and drifted actions old confirmations and Details cannot act",function(checkpoint)
    for _,mode in ipairs({"pending","failed","serial","revision","fresh","store","options"}) do
        local ui,env,_,cmd=redrawFixture(checkpoint); local c=cmd.collector; local row=ui.rows[1]
        ui.selected=row; ui:Lifecycle("delete"); assert(ui.confirmation)
        if mode=="pending" or mode=="failed" then
            ui:Refresh()
            if mode=="failed" then ui.buildJob.Step=function() error("R01 Step") end; ui.buildDriver.scripts.OnUpdate() end
        elseif mode=="serial" then c.serial=c.serial+1 elseif mode=="revision" then c.revision=c.revision+1
        elseif mode=="fresh" then c.fresh={} elseif mode=="store" then
            local _,packs=seed(); applyPack(c.db,packs[1],nil,901)
        else ui.options.character="no match" end
        local verify=frozen(env.CraftArmyDB)
        eq(ui:FinishConfirmation(true),false); eq(ui.confirmation,nil)
        ui.selected=row; ui:Lifecycle("delete",true); eq(ui.confirmation,nil)
        ui:Confirm({guid=row.guid,id=row.id,generation=row.generation},"delete","stale"); eq(ui.confirmation,nil)
        for _,w in ipairs(ui.widgets) do if w.row then for col,cell in ipairs(w.cells) do
            cell.scripts.OnMouseDown(cell,"LeftButton"); eq(ui.details,nil)
            assert(ui.selected==nil or ui.selected==row,"No new active scope")
        end end end
        verify(); pause(checkpoint,"R01 action guards")
    end
end)
case("R01 same-source factory Step frame batch clock driver and render failures preserve completed table retry",function(checkpoint)
    for _,mode in ipairs({"factory","Step","frame","batch","clock","setScript","show","render"}) do
        local ui,env,_,cmd=redrawFixture(checkpoint); local rows=ui.rows; local verify=frozen(env.CraftArmyDB)
        local factory,create,render=V.NewBuildJob,env.CreateFrame,ui.Render
        local driver=ui.buildDriver; local set,show=driver.SetScript,driver.Show
        local ok,why=pcall(function()
            if mode=="factory" then V.NewBuildJob=function() error("R01 factory") end
            elseif mode=="frame" then ui.buildDriver=nil; env.CreateFrame=function() error("R01 frame") end
            elseif mode=="clock" then env.debugprofilestop=function() error("R01 private clock") end
            elseif mode=="setScript" then driver.SetScript=function() error("R01 scheduler") end
            elseif mode=="show" then driver.Show=function() error("R01 scheduler") end end
            ui:Refresh()
            if mode=="Step" then ui.buildJob.Step=function() error("R01 Step") end
            elseif mode=="batch" then ui.buildBatch.Step=function() error("R01 batch") end
            elseif mode=="render" then ui.widgets[1].cells[1].label.SetText=function() error("R01 rendering") end end
            if ui.buildJob then
                local n=0; while ui.buildJob do n=n+1; assert(n<10000); ui.buildDriver.scripts.OnUpdate() end
            end
            eq(ui.rows,mode=="render" and ui.completed.rows or rows); eq(#ui.rows,8); eq(ui.retained,true)
            eq(ui:ActionsReady(),false); assert(ui.reason:GetText():find("Previous saved view",1,true)); verify()
        end)
        V.NewBuildJob=factory; env.CreateFrame=create; ui.Render=render; driver.SetScript=set; driver.Show=show
        -- Remove instance-only mock fault, restoring inherited SetText.
        ui.widgets[1].cells[1].label.SetText=nil; env.debugprofilestop=function() return 0 end
        assert(ok,mode..": "..tostring(why)); ui:Refresh(); redrawPump(ui,checkpoint)
        eq(#ui.rows,8); eq(ui.retained,false); verify(); pause(checkpoint,"R01 failure retry")
    end
end)
case("R01 hidden and combat unknown safety preserve values and avoid duplicate visible jobs",function(checkpoint)
    local ui,env,state,cmd=redrawFixture(checkpoint); local rows=ui.rows; local verify=frozen(env.CraftArmyDB)
    ui:Refresh(); local job=ui.buildJob; local callback=ui.buildDriver.scripts.OnUpdate; local steps=job.steps
    state.combat=true; callback(); eq(job.steps,steps); eq(ui.rows,rows)
    env.InCombatLockdown=function() return nil end; callback(); eq(job.steps,steps); eq(ui.rows,rows)
    env.InCombatLockdown=function() return false end; ui.frame:Hide(); eq(ui.buildJob,nil); eq(ui.rows,rows)
    eq(job.status,"cancelled"); callback(); eq(ui.rows,rows)
    ui:Refresh(); eq(ui.buildJob,nil); eq(ui.rows,rows); eq(ui.retained,true)
    local factory=V.NewBuildJob; local created=0
    local ok,why=pcall(function()
        V.NewBuildJob=function(...) created=created+1; return factory(...) end
        ui:Toggle(); eq(created,1)
    end)
    V.NewBuildJob=factory; assert(ok,why); redrawPump(ui,checkpoint); eq(#ui.rows,8); verify()
    -- Plain Show mocks do not invoke OnShow; Toggle must still launch once.
    local e=fixtureAPI(); mockWidgets(e); local c=NS.Collectors.New(e,cmd.collector.db)
    local other=NS.Dashboard.New(e,c); other:Toggle(); assert(other.buildJob); redrawPump(other,checkpoint); eq(#other.rows,8)
end)
case("R01 detached nil different invalid and schema1 sources drop old display and callbacks",function(checkpoint)
    for _,mode in ipairs({"nil","different","invalid","schema1"}) do
        local ui,env,_,cmd=redrawFixture(checkpoint); local c=cmd.collector
        ui:Refresh(); local stale=ui.buildDriver.scripts.OnUpdate
        if mode=="nil" then c.db=nil; c.storagePending=true
        elseif mode=="different" then c.db=S.New()
        elseif mode=="invalid" then env.CraftArmyDB.characters=false
        else c.db=dbWith({unspent=7}) end
        ui:Refresh(); eq(ui.completed,nil); eq(ui.selected,nil); eq(ui.confirmation,nil)
        stale()
        if mode=="schema1" then eq(#ui.rows,1); eq(ui.rows[1].unspent,7)
        else eq(#ui.rows,0); for _,w in ipairs(ui.widgets) do eq(w:IsShown(),false) end end
        if mode=="different" then redrawPump(ui,checkpoint); eq(#ui.rows,0); assert(ui.completed) end
        pause(checkpoint,"R01 source retirement")
    end
end)
case("R01 selection restoration is visible-page exact generation and offsets clamp with twelve reused widgets",function(checkpoint)
    local ui,env,_,cmd=redrawFixture(checkpoint); local _,packs=seed()
    for n=1,16 do applyPack(cmd.collector.db,packs[1],"R01-page-"..n) end
    ui:Refresh(); redrawPump(ui,checkpoint); eq(#ui.rows,24); eq(#ui.widgets,12)
    local widgets={unpack(ui.widgets)}; ui.offset=12; ui:Render(); local selected=ui.widgets[3].row
    ui.selected=selected; ui:Refresh(); eq(ui.selected,nil); eq(ui.offset,12); redrawPump(ui,checkpoint)
    eq(ui.offset,12); eq(ui.selected.key,selected.key)
    ui.selected=ui.rows[1]; ui:Refresh(); redrawPump(ui,checkpoint); eq(ui.selected,nil)
    ui.selected=selected; ui.options.character="no match"; ui:Refresh(); redrawPump(ui,checkpoint)
    eq(#ui.rows,0); eq(ui.offset,0); eq(ui.selected,nil)
    for n,w in ipairs(widgets) do eq(ui.widgets[n],w) end
    ui.options={}; ui:Refresh(); redrawPump(ui,checkpoint)
    local row=ui.rows[1]; ui.selected=row; ui:Refresh()
    assert(S.Archive(cmd.collector.db,row.guid,row.id,1000,"fixture generation change"))
    for _,p in ipairs(packs) do if p[2].skillLineID==row.id then applyPack(cmd.collector.db,p,row.guid,1001); break end end
    ui:Refresh(); redrawPump(ui,checkpoint); eq(ui.selected,nil)
end)
case("R01 successful retire generation delete character delete retire cache failed cancelled confirmation preserves",function(checkpoint)
    for _,action in ipairs({"retire","generation","character","cancel","failed"}) do
        local ui,env,_,cmd=redrawFixture(checkpoint); local rows=ui.rows; local row=rows[1]; ui.selected=row
        ui:Lifecycle(action=="retire" and "retire" or "delete",action=="character"); assert(ui.confirmation)
        if action=="failed" then ui.confirmation.scope.generation=99999 end
        local result=ui:FinishConfirmation(action~="cancel")
        if action=="cancel" then eq(result,false); eq(ui.rows,rows); eq(ui.retained,false)
        elseif action=="failed" then eq(result,false); eq(ui.rows,rows); redrawPump(ui,checkpoint); eq(#ui.rows,8)
        else
            eq(result,true); eq(ui.completed,nil); eq(#ui.rows,0); eq(ui.restoreKey,nil)
            -- A failed replacement cannot bring deliberately removed data back.
            ui.buildJob.Step=function() error("R01 replacement failure") end; ui.buildDriver.scripts.OnUpdate()
            eq(#ui.rows,0); ui.frame:Hide(); ui:Toggle(); redrawPump(ui,checkpoint); eq(#ui.rows,7)
            for _,r in ipairs(ui.rows) do assert(r.key~=row.key) end
        end
        pause(checkpoint,"R01 lifecycle cache retirement")
    end
end)
case("R01 setup status Render widget and scheduler reentry retires old invocation without stale publication",function(checkpoint)
    for _,boundary in ipairs({"factory","batchFactory","frame","setScript","show","status","Render","cell"}) do
        for _,action in ipairs({"Refresh","Hide","source"}) do
            local ui,env,_,cmd=redrawFixture(checkpoint); local c=cmd.collector; local originalRows=ui.rows
            local fired,newJob,newRows,newReason=false
            local function change()
                if fired then return end; fired=true
                if action=="Refresh" then ui.options.character="no match"; ui:Refresh()
                elseif action=="Hide" then ui.frame:Hide()
                else c.db=S.New(); ui:Refresh() end
                newJob,newRows,newReason=ui.buildJob,ui.rows,ui.reason:GetText()
            end
            local factory,batchFactory,create=V.NewBuildJob,S.NewFrameBatch,env.CreateFrame
            local driver=ui.buildDriver; local set,show=driver.SetScript,driver.Show
            local status,render=ui.reason.SetText,ui.Render
            local label=ui.widgets[1].cells[1].label; local text=label.SetText
            local ok,why=pcall(function()
                if boundary=="factory" then V.NewBuildJob=function(...) local j=factory(...); change(); return j end
                elseif boundary=="batchFactory" then S.NewFrameBatch=function(...) local b=batchFactory(...); change(); return b end
                elseif boundary=="frame" then ui.buildDriver=nil; env.CreateFrame=function(...) local w=create(...); change(); return w end
                elseif boundary=="setScript" then driver.SetScript=function(w,k,fn) set(w,k,fn); if fn then change() end end
                elseif boundary=="show" then driver.Show=function(w) show(w); change() end
                elseif boundary=="status" then ui.reason.SetText=function(w,v) status(w,v); change() end
                elseif boundary=="Render" then ui.Render=function(w) change(); return render(w) end
                else label.SetText=function(w,v) text(w,v); if ui.publishing then change() end end end
                ui:Refresh(); local callback=not fired and ui.buildDriver and ui.buildDriver.scripts.OnUpdate
                local n=0
                while not fired and ui.buildJob do n=n+1; assert(n<10000); callback() end
                assert(fired,boundary); eq(ui.buildJob,newJob); eq(ui.rows,newRows); eq(ui.reason:GetText(),newReason)
                if callback then callback(); eq(ui.buildJob,newJob); eq(ui.rows,newRows); eq(ui.reason:GetText(),newReason) end
                if action=="source" then eq(#ui.rows,0); eq(ui.selected,nil)
                else eq(#ui.rows,8); eq(ui.retained,true); eq(ui:ActionsReady(),false)
                    if boundary~="cell" then eq(ui.rows,originalRows) end
                end
            end)
            V.NewBuildJob=factory; S.NewFrameBatch=batchFactory; env.CreateFrame=create
            driver.SetScript=set; driver.Show=show; ui.reason.SetText=status; ui.Render=render; label.SetText=nil
            assert(ok,boundary.."/"..action..": "..tostring(why))
            if action=="Hide" then ui:Toggle() end
            redrawPump(ui,checkpoint)
            eq(#ui.rows,action=="Hide" and 8 or 0)
            pause(checkpoint,"R01 setup and presentation reentry observers restored")
        end
    end
end)
case("R01 cancellation failure and completion cleanup reentry preserve replacement ownership",function(checkpoint)
    for _,path in ipairs({"cancel","complete","failure"}) do
        for _,boundary in ipairs({"Cancel","setScript","Hide"}) do
            for _,action in ipairs({"Refresh","Hide","source"}) do
                local ui,env,_,cmd=redrawFixture(checkpoint); local c=cmd.collector; ui:Refresh()
                local old=ui.buildJob; local callback=ui.buildDriver.scripts.OnUpdate
                local fired,newJob,newRows,newReason=false
                local function change()
                    if fired then return end; fired=true
                    if action=="Refresh" then ui.options.character="no match"; ui:Refresh()
                    elseif action=="Hide" then ui.frame:Hide()
                    else c.db=S.New(); ui:Refresh() end
                    newJob,newRows,newReason=ui.buildJob,ui.rows,ui.reason:GetText()
                end
                local driver=ui.buildDriver; local cancel,set,hide=old.Cancel,driver.SetScript,driver.Hide
                local ok,why=pcall(function()
                    old.Cancel=function(j) cancel(j); if boundary=="Cancel" then change() end end
                    driver.SetScript=function(w,k,fn) set(w,k,fn); if boundary=="setScript" and not fn then change() end end
                    driver.Hide=function(w) hide(w); if boundary=="Hide" then change() end end
                    if path=="cancel" then ui.options.sortColumn=I.Realm; ui:Refresh()
                    else
                        if path=="failure" then old.Step=function() error("R01 failed old work") end end
                        local n=0; while not fired do n=n+1; assert(n<10000); callback() end
                    end
                    assert(fired); eq(ui.buildJob,newJob); eq(ui.rows,newRows); eq(ui.reason:GetText(),newReason)
                    callback(); eq(ui.buildJob,newJob); eq(ui.rows,newRows); eq(ui.reason:GetText(),newReason)
                    eq(ui.selected,nil); eq(ui.confirmation,nil)
                end)
                old.Cancel=cancel; driver.SetScript=set; driver.Hide=hide
                assert(ok,path.."/"..boundary.."/"..action..": "..tostring(why))
                if action=="Hide" then ui:Toggle() end
                redrawPump(ui,checkpoint); eq(#ui.rows,action=="Hide" and 8 or 0)
                local rows,reason=ui.rows,ui.reason:GetText(); callback(); eq(ui.rows,rows); eq(ui.reason:GetText(),reason)
                pause(checkpoint,"R01 cleanup observers restored")
            end
        end
    end
end)
case("R01 source changes without Refresh during final cleanup never leave detached rows actionable",function(checkpoint)
    for _,mode in ipairs({"nil","different","invalid","combat","unknown"}) do
        local ui,env,state,cmd=redrawFixture(checkpoint); ui:Refresh()
        local driver=ui.buildDriver; local hide=driver.Hide; local job=ui.buildJob; local fired=false
        driver.Hide=function(w)
            hide(w)
            if not fired and job.status=="complete" then
                fired=true
                if mode=="nil" then cmd.collector.db=nil elseif mode=="different" then cmd.collector.db=S.New()
                elseif mode=="invalid" then env.CraftArmyDB.characters=false
                elseif mode=="combat" then state.combat=true else env.InCombatLockdown=function() return nil end end
            end
        end
        local n=0; while not fired do n=n+1; assert(n<10000); driver.scripts.OnUpdate() end
        driver.Hide=hide; eq(ui.buildJob,nil); eq(ui:ActionsReady(),false)
        if mode=="combat" or mode=="unknown" then eq(#ui.rows,8); eq(ui.retained,true)
        else eq(#ui.rows,0); eq(ui.completed,nil) end
        eq(ui.selected,nil); eq(ui.confirmation,nil); pause(checkpoint,"R01 final source/safety guard")
    end
end)
case("R01 initial empty and no-prior setup frame and selected-clock failures remain explicit retryable",function(checkpoint)
    -- U14 THUMB BEGIN
    do
        local e=fixtureAPI(); mockWidgets(e)
        local view=NS.Dashboard.New(e,NS.Collectors.New(e,dbWith({}))); assert(view:Create())
        eq(view.scrollThumb.texturePath,"Interface\\Buttons\\WHITE8X8","U14 opaque thumb asset")
        local rgb=assert(view.scrollThumb.style.SetColorTexture,"U14 full-quad thumb color")
        eq(rgb[1],.45); eq(rgb[2],.50); eq(rgb[3],.58); eq(rgb[4],1)
    end
    -- U14 THUMB END
    -- U14 THUMB_CREATION BEGIN
    do
        for _,mode in ipairs({"fault","reentry"}) do
            local e=fixtureAPI(); mockWidgets(e)
            local c=NS.Collectors.New(e,dbWith({})); local view=NS.Dashboard.New(e,c)
            local create=e.CreateFrame; local fired,newRows,newFrame,newJob=false
            e.CreateFrame=function(kind,...)
                local w=create(kind,...)
                if kind=="Slider" then
                    local get=w.GetThumbTexture
                    w.GetThumbTexture=function(host)
                        local thumb=get(host); local color=thumb.SetColorTexture
                        thumb.SetColorTexture=function(t,...)
                            color(t,...); eq(select(4,...),1); fired=true
                            if mode=="fault" then error("U14 thumb color creation fault") end
                            view:StopBuild(); newRows={}; newFrame=create("Frame",nil,e.UIParent)
                            newJob={Cancel=function() end,status="running"}
                            view.rows=newRows; view.frame=newFrame; view.buildJob=newJob
                        end
                        return thumb
                    end
                end
                return w
            end
            local verify=frozen(c.db); eq(pcall(view.Create,view),false,"U14 thumb color creation ownership")
            assert(fired); if mode=="reentry" then eq(view.rows,newRows); eq(view.frame,newFrame); eq(view.buildJob,newJob) end
            verify(); pause(checkpoint,"U14 guarded opaque thumb color creation")
        end
    end
    -- U14 THUMB_CREATION END
    for _,mode in ipairs({"empty","factory","frame","clock"}) do
        local env=fixtureAPI(); nativeWidgets(env); env.debugprofilestop=function() return 0 end
        local h=S.New(); local c=NS.Collectors.New(env,h); local ui=NS.Dashboard.New(env,c); ui:Create()
        local factory,create=V.NewBuildJob,env.CreateFrame
        local ok,why=pcall(function()
            if mode=="factory" then V.NewBuildJob=function() error("R01 initial factory") end
            elseif mode=="frame" then env.CreateFrame=function() error("R01 initial frame") end
            elseif mode=="clock" then env.debugprofilestop=function() return nil end end
            ui:Toggle(); if ui.buildJob then
                local n=0; while ui.buildJob do n=n+1; assert(n<10000); ui.buildDriver.scripts.OnUpdate() end
            end
            eq(#ui.rows,0); eq(ui.retained,false)
            if mode=="empty" then assert(ui.completed); eq(ui:ActionsReady(),true)
            else eq(ui.completed,nil); eq(ui:ActionsReady(),false)
                assert(ui.reason:GetText():find(mode=="frame" and "scheduler" or "failed",1,true)) end
        end)
        V.NewBuildJob=factory; env.CreateFrame=create; env.debugprofilestop=function() return 0 end
        assert(ok,mode..": "..tostring(why)); ui:Refresh(); redrawPump(ui,checkpoint); assert(ui.completed)
    end
end)
case("R01 tooltip and confirmation widget reentry cannot expose obsolete details or execute writes",function(checkpoint)
    for _,boundary in ipairs({"shift","owner","hyperlink","append","show","confirmText","confirmHide","confirmCombat"}) do
        local ui,env,_,cmd=redrawFixture(checkpoint); local c=cmd.collector; local row=ui.rows[1]
        local verify=frozen(env.CraftArmyDB); local fired=false
        local function change()
            if fired then return end; fired=true; c.revision=c.revision+1; ui:Refresh()
        end
        local tip=env.GameTooltip; local owner,link,append,show=tip.SetOwner,tip.SetHyperlink,tip.AddLine,tip.Show
        local shift,combat=env.IsShiftKeyDown,env.InCombatLockdown
        local text,hide=ui.confirmText.SetText,ui.confirmPanel.Hide
        local ok,why=pcall(function()
            if boundary=="shift" then env.IsShiftKeyDown=function() change(); return true end
            elseif boundary=="owner" then tip.SetOwner=function(w,...) owner(w,...); change() end
            elseif boundary=="hyperlink" then tip.SetHyperlink=function(w,...) link(w,...); change() end
            elseif boundary=="append" then tip.AddLine=function(w,...) append(w,...); change() end
            elseif boundary=="show" then tip.Show=function(w,...) show(w,...); change() end end
            if boundary:match("^confirm") then
                ui.selected=row; ui:Lifecycle("delete"); assert(ui.confirmation)
                if boundary=="confirmText" then
                    ui.confirmText.SetText=function(w,...) text(w,...); change() end
                    ui:Lifecycle("delete"); eq(ui.confirmation,nil)
                else
                    if boundary=="confirmHide" then ui.confirmPanel.Hide=function(w) hide(w); change() end
                    else env.InCombatLockdown=function() change(); return false end end
                    eq(ui:FinishConfirmation(true),false)
                end
                eq(ui.confirmation,nil)
            else
                local col=boundary=="hyperlink" and I.Tool or I.Name
                local cell=ui.widgets[1].cells[col]
                if boundary=="hyperlink" then
                    -- Isolated fixture row may lack a tool hyperlink; add a public
                    -- presentation sentinel, not a saved-data/native API claim.
                    row.gear.tool.link="item:19019"
                end
                cell.scripts.OnEnter(cell); eq(tip.nativeLink,nil)
                assert(not tip:IsShown() or table.concat(tip.lines,"\n"):find("Previous saved values",1,true))
            end
            assert(fired,boundary); eq(ui.retained,true); eq(ui:ActionsReady(),false); verify()
        end)
        tip.SetOwner=owner; tip.SetHyperlink=link; tip.AddLine=append; tip.Show=show
        env.IsShiftKeyDown=shift; env.InCombatLockdown=combat; ui.confirmText.SetText=nil; ui.confirmPanel.Hide=hide
        assert(ok,boundary..": "..tostring(why)); redrawPump(ui,checkpoint); verify()
    end
end)
case("R01 lifecycle native enable state recovers and retained renders coalescence collect nothing",function(checkpoint)
    -- U14 DISPATCH BEGIN
    do
        local view,e,state,command=redrawFixture(checkpoint); local c=command.collector; local _,packs=seed()
        for n=1,37 do applyPack(c.db,packs[1],"U14-scroll-"..n) end
        view:Refresh(); redrawPump(view,checkpoint)
        local render=view.Render; local paints=0
        view.Render=function(w) paints=paints+1; return render(w) end
        view:ScrollTo(1); eq(paints,1); paints=0
        for n=1,100 do view:ScrollTo(1) end
        eq(paints,0,"U14 100 unchanged offsets must dispatch zero paints")
        local slider=view.scrollbar; local callback=view.frame.scripts.OnUpdate
        for n=2,25 do slider:SetValue(n) end
        eq(paints,0,"U14 drag must defer paint"); eq(view.offset,1)
        callback(view.frame,0); eq(paints,1); eq(view.offset,25)
        paints=0
        for n=1,100 do slider:SetValue(25+.001) end
        callback(view.frame,0); eq(paints,0,"U14 subrow/repeat no paint")
        slider:SetValue(10); slider:SetValue(25); callback(view.frame,0)
        eq(paints,0,"U14 reverse to displayed cancels queue")
        slider:SetValue(10); view.viewport.scripts.OnMouseWheel(view.viewport,1)
        eq(view.offset,22); eq(paints,1); callback(view.frame,0); eq(paints,1,"U14 wheel cancels drag")
        slider:SetValue(4); view:ScrollTo(22); callback(view.frame,0); eq(paints,1,"U14 unchanged wheel/direct cancels too")
        local guard=u13NoAcquisition(state); local guid=state.u13GUIDReads
        local verify=frozen({e.CraftArmyDB,c.fresh,view.rows}); local originalNow=c.Now
        local calls=0; c.Now=function() calls=calls+1; return 260 end
        local row=view.rows[1]; local oldValue,oldState=row.concentrationValue,row.concentrationState
        -- Set display-only fixtures before freezing those particular rows below.
        row.concentrationValue={quantity=400,maxQuantity=1000,rechargingCycleDurationMS=1000,rechargingAmountPerCycle=1}
        row.concentrationState={observedAt=10}; view:ScrollTo(0)
        local immutable=frozen({e.CraftArmyDB,c.fresh,view.rows})
        paints=0; calls=0; callback(view.frame,29); eq(paints,0)
        slider:SetValue(1); callback(view.frame,1); eq(paints,1); eq(calls,1,"U14 estimate+drag one shared paint/clock")
        callback(view.frame,29); eq(paints,1); callback(view.frame,1); eq(paints,2,"U14 ordinary30s timer survives drag")
        for _,bad in ipairs({false,-1,0/0,math.huge,-math.huge,"30"}) do
            slider:SetValue(view.offset==1 and 2 or 1); local target=slider.value
            callback(view.frame,bad); eq(view.offset,target,"U14 scroll independent of invalid estimate elapsed")
        end
        slider:SetValue(3); callback(view.frame,nil); eq(view.offset,3)
        c.Now=function() error("U14 clock fallback") end
        slider:SetValue(0); callback(view.frame,0); eq(view.offset,0)
        eq(view.widgets[1].cells[I.Concentration].estimate:IsShown(),false)
        c.Now=function() return 260 end; slider:SetValue(1); callback(view.frame,0)
        slider:SetValue(0); callback(view.frame,0)
        eq(view.widgets[1].cells[I.Concentration].label:GetText(),"~650/1000","U14 scroll recomputes estimates")
        immutable(); row.concentrationValue=oldValue; row.concentrationState=oldState
        guard(); eq(state.u13GUIDReads,guid); verify(); c.Now=originalNow
        view.Render=render
    end
    -- U14 DISPATCH END
    -- U14 COUNTS BEGIN
    do
        local e,state=fixtureAPI(); mockWidgets(e)
        local c=NS.Collectors.New(e,dbWith({moxie={id=3261,quantity=601}})); local view=NS.Dashboard.New(e,c)
        view:Toggle(); local template=view.rows[1]; local render=view.Render; local paints=0
        view.Render=function(w) paints=paints+1; return render(w) end
        for _,count in ipairs({0,1,12,13,37,5000}) do
            local rows={}; for n=1,count do rows[n]=template end
            view:StopBuild(); view.rows=rows; view.offset=0; assert(view:Render()); paints=0
            local slider=view.scrollbar; local cb=view.frame.scripts.OnUpdate; local maximum=math.max(0,count-12)
            eq(slider.minimum,0); eq(slider.maximum,maximum)
            local color=assert(view.scrollThumb.style.SetColorTexture); eq(color[4],1)
            for n=1,100 do view:ScrollTo(0) end; eq(paints,0)
            slider:SetValue(count); eq(view.offset,0); eq(paints,0)
            cb(view.frame,0); eq(view.offset,maximum); eq(paints,maximum>0 and 1 or 0)
            eq(view.rowRange:GetText(),count==0 and "No matching rows" or
                "Rows "..(maximum+1).."–"..count.." of "..count)
            paints=0; slider:SetValue(0); cb(view.frame,0); eq(view.offset,0); eq(paints,maximum>0 and 1 or 0)
            paints=0; for n=1,100 do slider:SetValue(0) end; cb(view.frame,0); eq(paints,0)
            if maximum>0 then
                slider:SetValue(maximum); view.frame:Hide(); cb(view.frame,0); eq(paints,0); eq(view.offset,0)
                view.frame:Show(); cb(view.frame,0); eq(paints,0,"U14 hidden queue discarded")
            end
            eq(#view.widgets,12); pause(checkpoint,"U14 counts/top/bottom/full-alpha no cap")
        end
    end
    -- U14 COUNTS END
    -- U14 OWNERS BEGIN
    do
        local function fixture()
            local view,e,state,command=redrawFixture(checkpoint); local _,packs=seed()
            for n=1,16 do applyPack(command.collector.db,packs[1],"U14-owner-"..n) end
            view:Refresh(); redrawPump(view,checkpoint)
            return view,e,state,command.collector
        end
        for _,action in ipairs({"Hide","Retain","StopBuild","DropCompleted","filter","view","source","GUID","options","rows","completed","serial","fresh","revision"}) do
            local view,e,state,c=fixture(); local slider=view.scrollbar; local cb=view.frame.scripts.OnUpdate
            slider:SetValue(3); eq(view.offset,0)
            if action=="Hide" then view.frame:Hide()
            elseif action=="Retain" then view:Retain("U14")
            elseif action=="StopBuild" then view:StopBuild()
            elseif action=="DropCompleted" then view:DropCompleted()
            elseif action=="filter" then view.options.character="no match"; view:Refresh()
            elseif action=="view" then view.options.archived=true; view:Refresh()
            elseif action=="source" then c.db=S.New()
            elseif action=="GUID" then view.options.currentPlayerGUID="Player-U14-replacement"
            elseif action=="options" then view.options=assert(C.Copy(view.options))
            elseif action=="rows" then view.rows={unpack(view.rows)}
            elseif action=="completed" then view.completed={rows=view.rows,context=view.completed.context}
            elseif action=="serial" then c.serial=c.serial+1
            elseif action=="fresh" then c.fresh={}
            else c.revision=c.revision+1 end
            local rows,completed,offset,job=view.rows,view.completed,view.offset,view.buildJob
            local render=view.Render; local paints=0; view.Render=function(w) paints=paints+1; return render(w) end
            cb(view.frame,0); cb(view.frame,0)
            eq(paints,0,"U14 stale queue/"..action); eq(view.offset,offset); eq(view.rows,rows); eq(view.completed,completed); eq(view.buildJob,job)
            view.Render=render; pause(checkpoint,"U14 queue lifecycle owner/"..action)
        end
        do
            local view,e,state,c=fixture(); view:Refresh(); eq(view.retained,true)
            local job=view.buildJob; local verify=frozen(e.CraftArmyDB)
            local render=view.Render; local paints=0; view.Render=function(w) paints=paints+1; return render(w) end
            view.scrollbar:SetValue(3); view.frame.scripts.OnUpdate(view.frame,0)
            eq(paints,1,"U14 retained scroll not blocked by estimate gates"); eq(view.offset,3); eq(view.buildJob,job)
            eq(view:ActionsReady(),false); for n=1,3 do eq(view.footer[n].enabled,false) end
            local cell=view.widgets[1].cells[I.Name]; cell.scripts.OnEnter(cell)
            assert(table.concat(e.GameTooltip.lines,"\n"):find("Previous saved values",1,true)); verify()
        end
        for _,boundary in ipairs({"visibility","combat","clock","range","value","row","text"}) do
            for _,mode in ipairs({"fault","replacement","replacementFault","reentry"}) do
                local view,e,state,c=fixture(); local cb=view.frame.scripts.OnUpdate; local slider=view.scrollbar
                local target=boundary=="visibility" and view.frame or boundary=="combat" and e or boundary=="clock" and c or
                    boundary=="row" and view.widgets[1].cells[I.Name].label or boundary=="text" and view.rowRange or slider
                local method=boundary=="visibility" and "IsShown" or boundary=="combat" and "InCombatLockdown" or
                    boundary=="clock" and "Now" or boundary=="range" and "SetMinMaxValues" or boundary=="value" and "SetValue" or "SetText"
                local original=target[method]; local fired=false; local replacementRows,replacementJob,replacementOffset
                slider:SetValue(3)
                target[method]=function(...)
                    local result=original(...)
                    if not fired then
                        fired=true
                        if mode=="fault" then error("U14 queued native fault") end
                        if mode=="replacement" or mode=="replacementFault" then
                            view.options.sortColumn=I.Name; view:Refresh(); redrawPump(view)
                            replacementRows,replacementJob,replacementOffset=view.rows,view.buildJob,view.offset
                            view.scrollbar:SetValue(replacementOffset==4 and 5 or 4)
                            if mode=="replacementFault" then error("U14 old native cleanup after replacement") end
                        else
                            -- A callback reentering itself cannot drain a second paint.
                            cb(view.frame,30)
                        end
                    end
                    return result
                end
                local verify=frozen(e.CraftArmyDB); local render=view.Render; local paints=0
                view.Render=function(w) paints=paints+1; return render(w) end
                cb(view.frame,30); target[method]=original; assert(fired,boundary)
                if mode=="replacement" or mode=="replacementFault" then
                    eq(view.rows,replacementRows); eq(view.buildJob,replacementJob); eq(view.offset,replacementOffset)
                    paints=0; cb(view.frame,0); eq(paints,1,"U14 replacement queue preserved/"..boundary)
                    eq(view.offset,replacementOffset==4 and 5 or 4)
                elseif mode=="reentry" then
                    eq(paints,1,"U14 no reentrant callback drain/"..boundary); eq(view.offset,3)
                else
                    assert(paints<=1,"U14 fault never causes extra paint")
                    paints=0; cb(view.frame,0); eq(paints,0,"U14 fault leaves no dead queue")
                    view:Refresh(); redrawPump(view); paints=0
                    slider:SetValue(view.offset==3 and 4 or 3); cb(view.frame,0); eq(paints,1,"U14 queue recovers after native fault")
                end
                verify(); pause(checkpoint,"U14 queued fault/owner/reentry/"..boundary.."/"..mode)
            end
        end
    end
    -- U14 OWNERS END
    -- U14 NO_ACQUISITION BEGIN
    do
        local view,e,state,command=redrawFixture(checkpoint); local c=command.collector; local _,packs=seed()
        for n=1,37 do applyPack(c.db,packs[1],"U14-bounds-"..n) end
        view:Refresh(); redrawPump(view,checkpoint)
        local guard=u13NoAcquisition(state); local guid=state.u13GUIDReads
        local verify=frozen({e.CraftArmyDB,c.fresh,view.rows})
        local build,newBuild,row,sort=V.Build,V.NewBuildJob,V.Row,table.sort
        local scan,request,context,login,identity=c.Scan,c.Request,c.Context,c.Login,e.UnitGUID
        local function forbidden() error("U14 scroll must not build/sort/collect/query identity") end
        local ok,why=pcall(function()
            V.Build=forbidden; V.NewBuildJob=forbidden; V.Row=forbidden; table.sort=forbidden
            c.Scan=forbidden; c.Request=forbidden; c.Context=forbidden; c.Login=forbidden; e.UnitGUID=forbidden
            local clock=c.Now; local calls=0; c.Now=function() calls=calls+1; return 500 end
            view:ScrollTo(1); eq(calls,1)
            for n=1,100 do view:ScrollTo(1) end; eq(calls,1)
            local first=view.widgets[1].row; local text=view.rowRange:GetText()
            for n=2,25 do view.scrollbar:SetValue(n) end
            eq(view.widgets[1].row,first); eq(view.rowRange:GetText(),text); eq(view.offset,1); eq(calls,1)
            view.frame.scripts.OnUpdate(view.frame,30); eq(calls,2)
            eq(view.widgets[1].row,view.rows[26]); eq(view.offset,25)
            view.viewport.scripts.OnMouseWheel(view.viewport,1); eq(calls,3); eq(view.offset,22)
            eq(#view.widgets,12); eq(state.u13GUIDReads,guid); guard(); verify(); c.Now=clock
        end)
        V.Build=build; V.NewBuildJob=newBuild; V.Row=row; table.sort=sort
        c.Scan=scan; c.Request=request; c.Context=context; c.Login=login; e.UnitGUID=identity
        assert(ok,why); pause(checkpoint,"U14 one shared clock/bounded12/no acquisition or GUID")
    end
    -- U14 NO_ACQUISITION END
    -- U14 SAME_OWNER BEGIN
    do
        for _,boundary in ipairs({"queueVisibility","flushVisibility","combat","clock","paint"}) do
            for _,fault in ipairs({false,true}) do
                local view,e,state,command=redrawFixture(checkpoint); local c=command.collector; local _,packs=seed()
                for n=1,16 do applyPack(c.db,packs[1],"U14-same-owner-"..n) end
                view:Refresh(); redrawPump(view,checkpoint)
                local cb=view.frame.scripts.OnUpdate; local slider=view.scrollbar
                local target=(boundary=="queueVisibility" or boundary=="flushVisibility") and view.frame or
                    boundary=="combat" and e or boundary=="clock" and c or view.rowRange
                local method=(boundary=="queueVisibility" or boundary=="flushVisibility") and "IsShown" or
                    boundary=="combat" and "InCombatLockdown" or boundary=="clock" and "Now" or "SetText"
                local original=target[method]; local fired=false
                if boundary~="queueVisibility" then slider:SetValue(3) end
                target[method]=function(...)
                    local result=original(...)
                    if not fired then
                        fired=true; slider:SetValue(5)
                        if fault then error("U14 same-owner native callback fault") end
                    end
                    return result
                end
                local render=view.Render; local paints=0
                view.Render=function(w) paints=paints+1; return render(w) end
                if boundary=="queueVisibility" then slider:SetValue(3) else cb(view.frame,30) end
                target[method]=original; assert(fired)
                local before=paints; cb(view.frame,0)
                if fault and boundary=="paint" then
                    -- Existing Render failure retains/demotes and intentionally retires
                    -- all queues for that now-retained owner.
                    eq(view.retained,true); eq(paints,before)
                else
                    eq(view.offset,5,"U14 latest same-owner target survives/"..boundary)
                    eq(paints,before+1,"U14 exactly one replacement paint/"..boundary)
                end
                pause(checkpoint,"U14 same-owner replacement queue/fault/"..boundary)
            end
        end
    end
    -- U14 SAME_OWNER END
    -- U14 STALE_TIMER BEGIN
    do
        local view,e,state,command=redrawFixture(checkpoint); local c=command.collector; local _,packs=seed()
        for n=1,16 do applyPack(c.db,packs[1],"U14-stale-timer-"..n) end
        view:Refresh(); redrawPump(view,checkpoint)
        view.scrollbar:SetValue(3); view.options=assert(C.Copy(view.options))
        local render=view.Render; local paints=0; view.Render=function(w) paints=paints+1; return render(w) end
        view.frame.scripts.OnUpdate(view.frame,30)
        eq(paints,1,"U14 discard stale queue without blocking ordinary estimate timer"); eq(view.offset,0)
        view.frame.scripts.OnUpdate(view.frame,0); eq(paints,1)
        pause(checkpoint,"U14 stale scroll queue independent of ordinary timer")
    end
    -- U14 STALE_TIMER END
    -- U14 DRIFT BEGIN
    do
        for _,boundary in ipairs({"visibility","clock","feedback","row"}) do
            for _,action in ipairs({"source","GUID","Hide","Retain"}) do
                local view,e,state,command=redrawFixture(checkpoint); local c=command.collector; local _,packs=seed()
                for n=1,16 do applyPack(c.db,packs[1],"U14-drift-"..n) end
                view:Refresh(); redrawPump(view,checkpoint)
                local cb=view.frame.scripts.OnUpdate; local slider=view.scrollbar
                local target=boundary=="visibility" and view.frame or boundary=="clock" and c or
                    boundary=="feedback" and slider or view.rowRange
                local method=boundary=="visibility" and "IsShown" or boundary=="clock" and "Now" or
                    boundary=="feedback" and "SetValue" or "SetText"
                local original=target[method]; local fired=false
                slider:SetValue(3)
                target[method]=function(...)
                    local result=original(...)
                    if not fired then
                        fired=true
                        if action=="source" then c.db=S.New()
                        elseif action=="GUID" then view.options.currentPlayerGUID="Player-U14-drift"
                        elseif action=="Hide" then view.frame:Hide()
                        else view:Retain("U14 native drift") end
                    end
                    return result
                end
                local verify=frozen(e.CraftArmyDB); cb(view.frame,0); target[method]=original; assert(fired)
                local rows,completed,offset,job=view.rows,view.completed,view.offset,view.buildJob
                local render=view.Render; local paints=0; view.Render=function(w) paints=paints+1; return render(w) end
                cb(view.frame,0); eq(paints,0,"U14 drift cannot leave stale queued paint")
                eq(view.rows,rows); eq(view.completed,completed); eq(view.offset,offset); eq(view.buildJob,job)
                view.Render=render; eq(view:ActionsReady(),false); verify()
                if action=="Hide" then
                    view:Toggle(); redrawPump(view,checkpoint)
                    paints=0; view.Render=function(w) paints=paints+1; return render(w) end
                    cb(view.frame,0); eq(paints,0,"U14 reopen never revives hidden drag")
                end
                pause(checkpoint,"U14 native drift/"..boundary.."/"..action)
            end
        end
    end
    -- U14 DRIFT END
    -- U14 WHEEL_FAULT BEGIN
    do
        local view,e,state,command=redrawFixture(checkpoint); local c=command.collector; local _,packs=seed()
        for n=1,16 do applyPack(c.db,packs[1],"U14-wheel-fault-"..n) end
        view:Refresh(); redrawPump(view,checkpoint); view.scrollbar:SetValue(3)
        local shown=view.frame.IsShown
        view.frame.IsShown=function() error("U14 wheel visibility fault") end
        view.viewport.scripts.OnMouseWheel(view.viewport,-1); view.frame.IsShown=shown
        local render=view.Render; local paints=0; view.Render=function(w) paints=paints+1; return render(w) end
        view.frame.scripts.OnUpdate(view.frame,0)
        eq(paints,0,"U14 failed wheel must still cancel older drag"); eq(view.offset,0)
        view:ScrollTo(3); eq(paints,1); eq(view.offset,3)
        pause(checkpoint,"U14 wheel cancels drag even if visibility query fails")
    end
    -- U14 WHEEL_FAULT END
    -- U13 MOXIE_RETAIN BEGIN
    do
        for _,mode in ipairs({"normal","renderFault","colorFault","hideFault","reentry"}) do
            local view,e,_,command=redrawFixture(checkpoint)
            local w=view.widgets[1]; local row=w.row; local label=w.cells[I.Moxie].label
            row.moxie=601; row.moxieState={known=true,fresh=true}; row.cells[I.Moxie]="601"
            assert(view:Render()); eq(label.style.SetTextColor[1],.20)
            local original=label.SetTextColor; local fired=false; local replacement
            if mode=="renderFault" then w.cells[I.Name].label.SetText=function() error("U13 render fault") end end
            if mode=="colorFault" or mode=="hideFault" then
                label.SetTextColor=function() error("U13 color fault") end
                if mode=="hideFault" then label.Hide=function() error("U13 hide fault") end end
            elseif mode=="reentry" then
                label.SetTextColor=function(widget,...)
                    original(widget,...)
                    if not fired then
                        fired=true; view.options.character="no match"; view:Refresh(); redrawPump(view)
                        replacement=view.rows
                    end
                end
            end
            local verify=frozen(e.CraftArmyDB)
            view:Refresh()
            if mode=="reentry" then assert(fired); eq(view.rows,replacement); eq(#view.rows,0)
            else
                eq(view.retained,true)
                -- U14 ADAPT MOXIE_RETAINED BEGIN
--[===========[U14 ORIGINAL BEGIN
                assert(not w:IsShown() or not label:IsShown() or label.style.SetTextColor[1]~=.20,
                    "U13 retained row stranded fresh green")
                if mode=="normal" or mode=="renderFault" then
                    eq(label.style.SetTextColor[1],.38); eq(label.style.SetTextColor[2],.58); eq(label.style.SetTextColor[3],.42)
                end
U14 ORIGINAL END]===========]
                if mode=="normal" or mode=="renderFault" then
                    eq(label.style.SetTextColor[1],.20); eq(label.style.SetTextColor[2],.78); eq(label.style.SetTextColor[3],.30)
                else
                    assert(not w:IsShown() or not label:IsShown(),"U14 retained color fault must still hide label/row")
                end
                -- U14 ADAPT MOXIE_RETAINED END
            end
            verify(); pause(checkpoint,"U13 Moxie retained fault/reentry")
        end
    end
    -- U13 MOXIE_RETAIN END
    -- U13 ESTIMATE_TIMER BEGIN
    do
        local view,e,state,command=redrawFixture(checkpoint); local c=command.collector
        local callback=assert(view.frame.scripts.OnUpdate,"U13 estimate timer rejection")
        local originalRender=view.Render; local renders=0
        view.Render=function(w) renders=renders+1; return originalRender(w) end
        local verify=frozen({e.CraftArmyDB,c.fresh,view.rows})
        callback(view.frame,29); eq(renders,0); callback(view.frame,1); eq(renders,1)
        callback(view.frame,300); eq(renders,2,"U13 no catch-up loop")
        for _,bad in ipairs({-1,math.huge,-math.huge,0/0,false,"30"}) do callback(view.frame,bad) end
        callback(view.frame,nil); eq(renders,2)
        for _,mode in ipairs({"hidden","retained","publishing","combat","unknown","drift"}) do
            local shown=view.frame.IsShown; local combat=e.InCombatLockdown
            if mode=="hidden" then view.frame.IsShown=function() return false end
            elseif mode=="retained" then view.retained=true
            elseif mode=="publishing" then view.publishing=true
            elseif mode=="combat" then e.InCombatLockdown=function() return true end
            elseif mode=="unknown" then e.InCombatLockdown=function() return nil end
            else c.serial=c.serial+1 end
            callback(view.frame,30); eq(renders,2,mode.." timer did work")
            view.frame.IsShown=shown; e.InCombatLockdown=combat; view.retained=false; view.publishing=false
            if mode=="drift" then c.serial=c.serial-1 end
        end
        verify()
        for _,boundary in ipairs({"visibility","combat","clock"}) do
            local fired,newJob=false
            local shown,combat,now=view.frame.IsShown,e.InCombatLockdown,c.Now
            local function change()
                if fired then return end; fired=true; view.options.character="no match"; view:Refresh(); newJob=view.buildJob
            end
            if boundary=="visibility" then view.frame.IsShown=function(w) change(); return shown(w) end
            elseif boundary=="combat" then e.InCombatLockdown=function() change(); return false end
            else c.Now=function() change(); return 500 end end
            callback(view.frame,30)
            view.frame.IsShown=shown; e.InCombatLockdown=combat; c.Now=now
            assert(fired); eq(view.buildJob,newJob); redrawPump(view,checkpoint)
            view.options.character=nil; view:Refresh(); redrawPump(view,checkpoint)
            pause(checkpoint,"U13 timer query ownership")
        end
        view.Render=originalRender
    end
    -- U13 ESTIMATE_TIMER END
    -- U13 ESTIMATE_NATIVE BEGIN
    do
        for _,boundary in ipairs({"ClearAllPoints","SetPoint","SetSize","SetColorTexture","SetShown","Now"}) do
            for _,mode in ipairs({"fault","reentry"}) do
                local view,e,_,command=redrawFixture(checkpoint); local c=command.collector
                local row=view.rows[1]; row.concentrationValue={quantity=400,maxQuantity=1000,rechargingCycleDurationMS=1000,rechargingAmountPerCycle=1}
                row.concentrationState.observedAt=10
                local gain=assert(view.widgets[1].cells[I.Concentration].estimate)
                local now=c.Now; c.Now=function() return 260 end
                assert(view:Render()); eq(gain:IsShown(),true)
                local target=boundary=="Now" and c or gain; local original=target[boundary]; local fired,newJob=false
                target[boundary]=function(widget,...)
                    if mode=="fault" then error("U13 native fault") end
                    local result=original(widget,...)
                    if not fired then fired=true; view.options.character="no match"; view:Refresh(); newJob=view.buildJob end
                    return result
                end
                local verify=frozen(e.CraftArmyDB); view:Render()
                target[boundary]=original; c.Now=now
                if mode=="reentry" then assert(fired); eq(view.buildJob,newJob)
                elseif boundary~="Now" then eq(view.retained,true) end
                assert(not view.widgets[1]:IsShown() or not gain:IsShown(),"U13 stale cyan survives fault/reentry")
                verify(); pause(checkpoint,"U13 estimate native boundaries")
            end
        end
    end
    -- U13 ESTIMATE_NATIVE END
    -- U13 SLIDER_NATIVE BEGIN
    do
        for _,boundary in ipairs({"SetMinMaxValues","SetValue","SetSize","SetEnabled","SetShown","LayoutSize","RangeText"}) do
            for _,mode in ipairs({"fault","reentry"}) do
                local view,e,_,command=redrawFixture(checkpoint); local _,packs=seed()
                for n=1,16 do applyPack(command.collector.db,packs[1],"U13-scroll-"..n) end
                view:Refresh(); redrawPump(view,checkpoint)
                local target=boundary=="SetSize" and view.scrollThumb or boundary=="RangeText" and view.rowRange or view.scrollbar
                local method=boundary=="LayoutSize" and "SetSize" or boundary=="RangeText" and "SetText" or boundary
                local original=target[method]; local fired,newJob=false
                target[method]=function(w,...)
                    local result=original(w,...)
                    if mode=="fault" then error("U13 Slider fault") end
                    if not fired then fired=true; view.options.character="no match"; view:Refresh(); newJob=view.buildJob end
                    return result
                end
                local verify=frozen(e.CraftArmyDB); view:Render(); target[method]=original
                if mode=="reentry" then assert(fired); eq(view.buildJob,newJob) else eq(view.retained,true) end
                verify(); view.options.character=nil; view:Refresh(); redrawPump(view,checkpoint)
                -- U14 ADAPT FEEDBACK_FLUSH BEGIN
--[===========[U14 ORIGINAL BEGIN
                view.scrollbar:SetValue(3); eq(view.offset,3,"U13 feedback cleanup not stuck")
U14 ORIGINAL END]===========]
                view.scrollbar:SetValue(3); view.frame.scripts.OnUpdate(view.frame,0); eq(view.offset,3,"U13 feedback cleanup not stuck")
                -- U14 ADAPT FEEDBACK_FLUSH END
                pause(checkpoint,"U13 Slider feedback fault/reentry")
            end
        end
    end
    -- U13 SLIDER_NATIVE END
    -- U13 GUID_UI BEGIN
    do
        local view,e,_,command=redrawFixture(checkpoint); local c=command.collector
        local target=view.rows[#view.rows].guid; local calls=0
        e.UnitGUID=function(unit) eq(unit,"player"); calls=calls+1; return target end
        view.options.sortColumn=I.Name; view.options.sortDescending=true; view:Refresh(); redrawPump(view,checkpoint)
        eq(calls,1); eq(view.rows[1].guid,target,"U13 current UI ordering rejection")
        local cell=view.widgets[1].cells[I.Name]; local marker=assert(cell.currentDot,"U13 current dot rejection")
        eq(marker:GetText(),"•"); eq(marker:IsShown(),true); eq(cell.label.width,96)
        eq(marker.width,8); eq(marker.height,14); eq(marker.font[2],10)
        eq(marker.points[1].relative,cell.label); eq(marker.points[1].x,math.min(96,cell.label:GetStringWidth())+2)
        local row=view.rows[1]; local name=row.cells[I.Name]
        for _,sample in ipairs({"Short","Éléonore世界",string.rep("W",200),"|cffff0000Hostile|r"}) do
            row.cells[I.Name]=sample; assert(view:Render()); eq(cell.label:GetText(),sample:gsub("|","||"))
            assert(marker.points[1].x>=2 and marker.points[1].x<=98)
        end
        row.cells[I.Name]=name
        local width=cell.label.GetStringWidth
        for _,bad in ipairs({"throw",0/0,math.huge,-math.huge,false}) do
            cell.label.GetStringWidth=function() if bad=="throw" then error("U13 font query") end; return bad end
            assert(view:Render()); eq(marker.points[1].x,98)
        end
        cell.label.GetStringWidth=false; assert(view:Render()); eq(marker.points[1].x,98); cell.label.GetStringWidth=width
        for _,sample in ipairs({{-100,2},{500,98}}) do
            cell.label.GetStringWidth=function() return sample[1] end; assert(view:Render()); eq(marker.points[1].x,sample[2])
        end
        cell.label.GetStringWidth=width
        eq(marker.kind,"FontString"); eq(marker.style.EnableMouse,nil); eq(next(marker.scripts),nil)
        for _,nextGUID in ipairs({view.rows[2].guid,target}) do
            target=nextGUID; view:Refresh(); redrawPump(view,checkpoint)
            eq(view.rows[1].guid,nextGUID)
            for _,widget in ipairs(view.widgets) do if widget.row then
                eq(widget.cells[I.Name].currentDot:IsShown(),widget.row.guid==nextGUID)
                eq(widget.cells[I.Name].label.width,widget.row.guid==nextGUID and 96 or 106)
            end end
        end
        view:Refresh(); eq(marker:IsShown(),false); redrawPump(view,checkpoint)
        for _,bad in ipairs({false,7,"",string.rep("x",129),"bad\n","throw","missing"}) do
            if bad=="missing" then e.UnitGUID=nil
            else e.UnitGUID=function() if bad=="throw" then error("U13 GUID query") end; return bad end end
            view:Refresh(); redrawPump(view,checkpoint); eq(view.options.currentPlayerGUID,nil)
            for _,w in ipairs(view.widgets) do eq(w.cells[I.Name].currentDot:IsShown(),false); eq(w.cells[I.Name].label.width,106) end
        end
        for _,boundary in ipairs({"GUID","GetStringWidth","SetPoint","SetText","SetShown","SetWidth"}) do
            local fired,newJob=false
            e.UnitGUID=function() return target end; view:Refresh(); redrawPump(view,checkpoint)
            cell=view.widgets[1].cells[I.Name]; marker=cell.currentDot
            local object=boundary=="GUID" and e or (boundary=="GetStringWidth" or boundary=="SetWidth") and cell.label or marker
            local method=boundary=="GUID" and "UnitGUID" or boundary; local original=object[method]
            object[method]=function(...)
                local result=original(...)
                if not fired then fired=true; view.options.character="no match"; view:Refresh(); newJob=view.buildJob end
                return result
            end
            if boundary=="GUID" then view:Refresh() else view:Render() end
            object[method]=original; assert(fired); eq(view.buildJob,newJob); redrawPump(view,checkpoint)
            eq(#view.rows,0); view.options.character=nil; pause(checkpoint,"U13 GUID/marker reentry")
        end
    end
    -- U13 GUID_UI END
    -- U13 GUID_BOUNDS BEGIN
    do
        local view,e,state,command=redrawFixture(checkpoint)
        local guard=u13NoAcquisition(state)
        local reads,guid=state.reads,state.u13GUIDReads
        view:Refresh(); eq(state.reads,reads+1); eq(state.u13GUIDReads,guid+1)
        local job=view.buildJob; local steps=job.steps
        view:StartBuild(); eq(view.buildJob,job); eq(job.steps,steps)
        eq(state.reads,reads+2); eq(state.u13GUIDReads,guid+2)
        for n=1,3 do view:Refresh(); eq(state.reads,reads+2+n); eq(view.buildJob,job) end
        redrawPump(view,checkpoint); guard()
        reads=state.reads; guid=state.u13GUIDReads
        view:Render(); view:ScrollTo(0); view.viewport.scripts.OnMouseWheel(view.viewport,-1)
        view.frame.scripts.OnUpdate(view.frame,30); view.frame.scripts.OnUpdate(view.frame,300)
        eq(state.reads,reads,"U13 no GUID on Render/drag/wheel/timer")
        eq(state.u13GUIDReads,guid); guard()
    end
    -- U13 GUID_BOUNDS END
    -- U13 MARKER_NATIVE BEGIN
    do
        for _,boundary in ipairs({"SetShown","SetText","ClearAllPoints","SetPoint","SetWidth","GetStringWidth","Hide","IsShown"}) do
            for _,mode in ipairs({"fault","reentry"}) do
                local view,e,_,command=redrawFixture(checkpoint)
                local guid=view.rows[1].guid; e.UnitGUID=function() return guid end
                view:Refresh(); redrawPump(view,checkpoint)
                local cell=view.widgets[1].cells[I.Name]; local marker=cell.currentDot
                assert(marker:IsShown())
                local target=(boundary=="SetWidth" or boundary=="GetStringWidth") and cell.label or marker
                local original=target[boundary]; local fired,newRows,newJob=false
                target[boundary]=function(widget,...)
                    local result=original(widget,...)
                    if mode=="fault" then error("U13 marker mutation fault") end
                    if not fired then
                        fired=true; view.options.character="no match"; view:Refresh(); redrawPump(view)
                        newRows,newJob=view.rows,view.buildJob
                    end
                    return result
                end
                local verify=frozen(e.CraftArmyDB)
                if boundary=="Hide" or boundary=="IsShown" then view:Refresh() else view:Render() end
                target[boundary]=original
                if mode=="reentry" then assert(fired,boundary); eq(view.rows,newRows); eq(view.buildJob,newJob)
                elseif boundary=="GetStringWidth" then eq(marker.points[1].x,98)
                else
                    assert(not view.widgets[1]:IsShown() or not marker:IsShown(),"U13 failed marker must not remain current")
                end
                verify(); pause(checkpoint,"U13 marker mutation/query fault-reentry")
            end
        end
    end
    -- U13 MARKER_NATIVE END
    -- U13 CREATION_NATIVE BEGIN
    do
        local points={
            {"marker","CreateFontString"},{"marker","SetJustifyH"},{"marker","SetWordWrap"},
            {"marker","SetSize"},{"marker","SetFont"},{"marker","SetTextColor"},{"marker","Hide"},
            {"slider","CreateFrame"},{"slider","SetSize"},{"slider","SetPoint"},{"slider","SetOrientation"},
            {"slider","SetValueStep"},{"slider","SetObeyStepOnDrag"},{"slider","SetThumbTexture"},
            {"slider","GetThumbTexture"},{"slider","SetScript"},{"track","CreateTexture"},
            {"track","SetAllPoints"},{"track","SetColorTexture"},
            {"estimate","CreateTexture"},{"estimate","SetColorTexture"},{"estimate","Hide"},
            {"timer","SetScript"},{"range","CreateFontString"},{"range","SetWidth"},
            {"range","SetJustifyH"},{"range","SetWordWrap"},{"range","SetPoint"},{"moxie","SetJustifyH"}}
        for _,point in ipairs(points) do for _,mode in ipairs({"fault","reentry"}) do
            local e=fixtureAPI(); mockWidgets(e)
            local c=NS.Collectors.New(e,dbWith({moxie={id=3261,quantity=601}}))
            local view=NS.Dashboard.New(e,c); local create=e.CreateFrame
            local fired,newFrame,newRows,newJob=false
            local function change()
                if fired then return end; fired=true
                if mode=="fault" then error("U13 creation native fault") end
                view:StopBuild(); newFrame=create("Frame",nil,e.UIParent)
                newRows={}; newJob={status="running",Cancel=function() end}
                view.frame=newFrame; view.rows=newRows; view.buildJob=newJob
            end
            local function arm(widget,method,predicate)
                local original=widget[method]
                widget[method]=function(host,...)
                    local result=original(host,...)
                    if not predicate or predicate(...) then change() end
                    return result
                end
            end
            e.CreateFrame=function(kind,name,parent,template)
                local w=create(kind,name,parent,template)
                if point[1]=="slider" and kind=="Slider" then
                    if point[2]=="CreateFrame" then change() else arm(w,point[2]) end
                elseif point[1]=="timer" and parent==e.UIParent and template=="BackdropTemplate" then
                    arm(w,"SetScript",function(event) return event=="OnUpdate" end)
                elseif point[1]=="track" and kind=="Slider" then
                    local texture=w.CreateTexture
                    w.CreateTexture=function(host,...)
                        local t=texture(host,...)
                        if point[2]=="CreateTexture" then change() else arm(t,point[2]) end
                        return t
                    end
                elseif point[1]=="estimate" and kind=="StatusBar" then
                    local texture=w.CreateTexture
                    w.CreateTexture=function(host,name,layer,...)
                        local t=texture(host,name,layer,...)
                        if host.width==92 and layer=="ARTWORK" then
                            if point[2]=="CreateTexture" then change() else arm(t,point[2]) end
                        end
                        return t
                    end
                elseif point[1]=="range" and parent==e.UIParent and template=="BackdropTemplate" then
                    local font=w.CreateFontString; local n=0
                    w.CreateFontString=function(host,...)
                        local label=font(host,...); n=n+1
                        if n==4 then
                            if point[2]=="CreateFontString" then change() else arm(label,point[2]) end
                        end
                        return label
                    end
                elseif point[1]=="moxie" and kind=="Frame" then
                    local font=w.CreateFontString
                    w.CreateFontString=function(host,...)
                        local label=font(host,...)
                        if host.width==56 and host.parent and host.parent.parent==view.viewport then
                            arm(label,"SetJustifyH",function(justify) return justify=="CENTER" end)
                        end
                        return label
                    end
                elseif point[1]=="marker" and kind=="Frame" then
                    local font=w.CreateFontString; local n=0
                    w.CreateFontString=function(host,...)
                        local label=font(host,...)
                        if host.width==110 and host.parent and host.parent.parent==view.viewport then
                            n=n+1
                            if n==2 then
                                if point[2]=="CreateFontString" then change() else arm(label,point[2]) end
                            end
                        end
                        return label
                    end
                end
                return w
            end
            local verify=frozen(c.db); local ok=pcall(view.Create,view)
            assert(fired,point[1].."/"..point[2].." creation site not exercised")
            eq(ok,false,"U13 creation must abort on native fault/replaced ownership")
            if mode=="reentry" then eq(view.frame,newFrame); eq(view.rows,newRows); eq(view.buildJob,newJob) end
            verify(); pause(checkpoint,"U13 guarded creation mutation/query")
        end end
    end
    -- U13 CREATION_NATIVE END
    -- U13 VISIBLE_BOUNDS BEGIN
    do
        local view,e,state,command=redrawFixture(checkpoint); local c=command.collector; local _,packs=seed()
        for n=1,25 do applyPack(c.db,packs[1],"U13-visible-"..n) end
        view:Refresh(); redrawPump(view,checkpoint); eq(#view.widgets,12); assert(#view.rows>12)
        local clock=c.Now; local calls=0
        c.Now=function() calls=calls+1; return 500 end
        local verify=frozen({e.CraftArmyDB,c.fresh,view.rows}); local reads=u13NoAcquisition(state)
        local guid=state.u13GUIDReads; local originalBuild,originalRow=V.NewBuildJob,V.Row
        local request,scan,context,login=c.Request,c.Scan,c.Context,c.Login
        local function forbidden() error("U13 presentation must not build/sort/collect") end
        local ok,why=pcall(function()
            c.Request=forbidden; c.Scan=forbidden; c.Context=forbidden; c.Login=forbidden
            V.NewBuildJob=forbidden; V.Row=forbidden
            assert(view:Render()); eq(calls,1,"U13 one shared clock for twelve visible rows")
            local render=view.Render; local renders=0
            view.Render=function(w) renders=renders+1; return render(w) end
            for _,boundary in ipairs({"visibility","combat"}) do
                local shown,combat=view.frame.IsShown,e.InCombatLockdown
                if boundary=="visibility" then view.frame.IsShown=function() error("U13 visibility fault") end
                else e.InCombatLockdown=function() error("U13 combat fault") end end
                view.frame.scripts.OnUpdate(view.frame,30); eq(renders,0)
                view.frame.IsShown=shown; e.InCombatLockdown=combat
            end
            view.frame.scripts.OnUpdate(view.frame,30); eq(renders,1); eq(calls,2)
            view.Render=render
            c.Now=function() error("U13 shared clock fault") end
            assert(view:Render())
            for _,w in ipairs(view.widgets) do if w.row then eq(w.cells[I.Concentration].estimate:IsShown(),false) end end
            eq(state.u13GUIDReads,guid); reads(); verify()
        end)
        V.NewBuildJob=originalBuild; V.Row=originalRow; c.Now=clock
        c.Request=request; c.Scan=scan; c.Context=context; c.Login=login
        assert(ok,why); pause(checkpoint,"U13 twelve-row presentation bound/no acquisition")
    end
    -- U13 VISIBLE_BOUNDS END
    local ui,env,_,cmd=redrawFixture(checkpoint); local c=cmd.collector; local verify=frozen(env.CraftArmyDB)
    for n=1,3 do ui.footer[n].SetEnabled=function(w,value) w.enabled=value end end
    local request,scan=c.Request,c.Scan; local requests,scans=0,0
    c.Request=function() requests=requests+1; error("R01 render must not request collection") end
    c.Scan=function() scans=scans+1; error("R01 render must not scan") end
    local ok,why=pcall(function()
        ui:Refresh(); for n=1,3 do eq(ui.footer[n].enabled,false) end
        ui:Render(); ui:Refresh(); redrawPump(ui,checkpoint)
        for n=1,3 do eq(ui.footer[n].enabled,true) end
        eq(requests,0); eq(scans,0); verify()
    end)
    c.Request=request; c.Scan=scan; assert(ok,why)
    -- Programmatic source drift is guarded even while already retained.
    ui:Refresh(); c.db=nil; eq(ui:ActionsReady(),false); eq(#ui.rows,0); eq(ui.completed,nil)
end)
case("R01 post-cleanup visibility and combat callbacks cannot publish across replacement reentry",function(checkpoint)
    for _,boundary in ipairs({"visibility","combat"}) do
        local ui,env,_,cmd=redrawFixture(checkpoint); local rows=ui.rows; ui:Refresh()
        local old=ui.buildJob; local callback=ui.buildDriver.scripts.OnUpdate; local fired,newJob=false
        local shown,combat=ui.frame.IsShown,env.InCombatLockdown
        local function change()
            if not fired and old.status=="complete" and ui.buildJob==nil then
                fired=true; ui.options.character="no match"; ui:Refresh(); newJob=ui.buildJob
            end
        end
        if boundary=="visibility" then ui.frame.IsShown=function(w) change(); return shown(w) end
        else env.InCombatLockdown=function() change(); return false end end
        local n=0; while not fired do n=n+1; assert(n<10000); callback() end
        ui.frame.IsShown=shown; env.InCombatLockdown=combat
        eq(ui.rows,rows); eq(ui.buildJob,newJob); eq(ui.retained,true); eq(ui:ActionsReady(),false)
        callback(); eq(ui.rows,rows); eq(ui.buildJob,newJob); redrawPump(ui,checkpoint); eq(#ui.rows,0)
    end
end)
-- R01 END
-- R01 ROUND1 BEGIN (additive review regressions; preceding480 cases unchanged)
local function round1OldHover(ui,kind)
    local w=ui.widgets[1]; local r=w.row
    r.cellTooltips[I.Name]={"ROUND1_OLD_CELL"}; r.tooltip={"ROUND1_OLD_CELL"}
    r.gear.tool.summaryTooltip={"ROUND1_OLD_ITEM"}; r.gear.tool.tooltip={"ROUND1_OLD_ITEM"}
    r.gear.tool.link="item:19019"
    local bar
    for _,candidate in ipairs(w.bars) do if candidate.tree then bar=candidate; break end end
    assert(bar,"Eight-row fixture needs a captured tree")
    bar.tree.summaryTooltip={"ROUND1_OLD_TREE"}; bar.tree.tooltip={"ROUND1_OLD_TREE"}
    return kind=="tree" and bar or w.cells[kind=="item" and I.Tool or I.Name]
end
for _,hoverKind in ipairs({"cell","tree"}) do
    local target=hoverKind
    case("R01 round1 "..target.." completed Shift replacement rejects original hover content",function(checkpoint)
        for _,source in ipairs({"same","new"}) do for _,down in ipairs({false,true}) do
            for _,kind in ipairs(target=="cell" and {"cell","item"} or {"tree"}) do
                local ui,env,_,cmd=redrawFixture(checkpoint); local widget=round1OldHover(ui,kind)
                local verify=frozen({ui.rows,env.CraftArmyDB,cmd.collector.fresh})
                local tip=env.GameTooltip; local add,link=tip.AddLine,tip.SetHyperlink; local leaks=0; local fired=false
                tip.AddLine=function(w,line,...) if line:find("ROUND1_OLD",1,true) then leaks=leaks+1 end; return add(w,line,...) end
                tip.SetHyperlink=function(w,value) if value=="item:19019" then leaks=leaks+1 end; return link(w,value) end
                env.IsShiftKeyDown=function()
                    if not fired then
                        fired=true
                        if source=="new" then cmd.collector.db=S.New() else ui.options.character="no matching row" end
                        ui:Refresh(); redrawPump(ui); eq(#ui.rows,0); eq(ui.retained,false)
                    end
                    return down
                end
                local ok,why=pcall(function()
                    widget.scripts.OnEnter(widget); assert(fired)
                    eq(leaks,0,target.."/"..kind.."/"..source.."/"..tostring(down).." obsolete tooltip content")
                    eq(tip.nativeLink,nil); verify()
                end)
                tip.AddLine=add; tip.SetHyperlink=link; env.IsShiftKeyDown=nil
                assert(ok,why); pause(checkpoint,"R01 round1 completed hover replacement")
            end
        end end
    end)
end
case("R01 round1 obsolete hover cleanup preserves a newer completed-view hover",function(checkpoint)
    for _,boundary in ipairs({"shift","owner","append","show"}) do
        for _,kind in ipairs({"cell","tree"}) do
            local ui,env,_,cmd=redrawFixture(checkpoint); local widget=round1OldHover(ui,kind)
            local tip=env.GameTooltip; local owner,add,show=tip.SetOwner,tip.AddLine,tip.Show; local fired=false
            local newText,newOwner
            local function replace()
                if fired then return end; fired=true; ui:Refresh(); redrawPump(ui)
                local cell=ui.widgets[2].cells[I.Name]; ui.widgets[2].row.cellTooltips[I.Name]={"ROUND1_NEW_HOVER"}
                env.IsShiftKeyDown=function() return false end; cell.scripts.OnEnter(cell)
                newText=table.concat(tip.lines,"\n"); newOwner=tip.owner
                assert(newText:find("ROUND1_NEW_HOVER",1,true)); eq(tip:IsShown(),true)
            end
            env.IsShiftKeyDown=function() if boundary=="shift" then replace() end; return true end
            tip.SetOwner=function(w,...) owner(w,...); if boundary=="owner" then replace() end end
            tip.AddLine=function(w,...) add(w,...); if boundary=="append" then replace() end end
            tip.Show=function(w) show(w); if boundary=="show" then replace() end end
            local ok,why=pcall(function()
                widget.scripts.OnEnter(widget); assert(fired)
                eq(table.concat(tip.lines,"\n"),newText,"Obsolete hover must not append to newer tooltip")
                eq(tip.owner,newOwner); eq(tip:IsShown(),true,"Obsolete hover must not hide newer tooltip")
            end)
            tip.SetOwner=owner; tip.AddLine=add; tip.Show=show; env.IsShiftKeyDown=nil
            assert(ok,boundary.."/"..kind..": "..tostring(why)); pause(checkpoint,"R01 round1 newer hover ownership")
        end
    end
end)
local function round1Markers(ui)
    for n,r in ipairs(ui.rows) do
        for _,col in ipairs({I.Skill,I.Moxie,I.Concentration}) do r.cells[col]="|cffffbb00!|r "..n..":"..col end
    end
    ui:Render()
end
local function round1SafeMarkers(ui)
    for _,w in ipairs(ui.widgets) do if w.row and w:IsShown() then
        for _,col in ipairs({I.Skill,I.Moxie,I.Concentration}) do
            local label=w.cells[col].label
            assert(not label:IsShown() or not label:GetText():find("|cffffbb00!|r",1,true),"Visible historical marker remained fresh amber")
        end
    end end
end
case("R01 round1 persistent early Name or layout fault cannot strand later historical markers",function(checkpoint)
    for _,mode in ipairs({"Name","layout"}) do
        local ui,env,_,cmd=redrawFixture(checkpoint); round1Markers(ui)
        local rows=ui.rows; local verify=frozen({rows,env.CraftArmyDB,cmd.collector.fresh})
        local name=ui.widgets[1].cells[I.Name].label; local layout=ui.Layout
        if mode=="Name" then name.SetText=function() error("ROUND1_EARLY_NAME") end
        else ui.Layout=function() error("ROUND1_EARLY_LAYOUT") end end
        local ok,why=pcall(function()
            ui:Refresh(); eq(ui.rows,rows); eq(ui.retained,true); eq(ui:ActionsReady(),false)
            for n=1,8 do eq(ui.widgets[n]:IsShown(),true) end
            round1SafeMarkers(ui); assert(ui.reason:GetText():find("failed",1,true)); verify()
        end)
        name.SetText=nil; ui.Layout=layout; assert(ok,mode..": "..tostring(why))
        ui:Refresh(); redrawPump(ui,checkpoint); eq(ui.retained,false); verify()
    end
end)
case("R01 round1 marker-label faults isolate only affected labels or rows and retry restores them",function(checkpoint)
    for _,mode in ipairs({"label","row"}) do
        local ui,env,_,cmd=redrawFixture(checkpoint); round1Markers(ui)
        local rows=ui.rows; local verify=frozen({rows,env.CraftArmyDB,cmd.collector.fresh})
        local label=ui.widgets[1].cells[I.Skill].label; local hide=label.Hide
        label.SetText=function() error("ROUND1_MARKER_TEXT") end
        if mode=="row" then label.Hide=function() error("ROUND1_MARKER_HIDE") end end
        local ok,why=pcall(function()
            ui:Refresh(); eq(ui.rows,rows); eq(ui.retained,true); round1SafeMarkers(ui)
            if mode=="label" then eq(label:IsShown(),false); eq(ui.widgets[1]:IsShown(),true)
            else eq(ui.widgets[1]:IsShown(),false) end
            for n=2,8 do eq(ui.widgets[n]:IsShown(),true) end
            verify()
        end)
        label.SetText=nil; label.Hide=hide; assert(ok,mode..": "..tostring(why))
        ui:Refresh(); redrawPump(ui,checkpoint); eq(ui.retained,false)
        for n=1,8 do
            eq(ui.widgets[n]:IsShown(),true)
            for _,col in ipairs({I.Skill,I.Moxie,I.Concentration}) do eq(ui.widgets[n].cells[col].label:IsShown(),true) end
        end
        verify()
    end
end)
case("R01 round1 partial publication render failure independently demotes already-drawn new fresh markers",function(checkpoint)
    local ui,env,_,cmd=redrawFixture(checkpoint); local verifySaved=frozen({env.CraftArmyDB,cmd.collector.fresh})
    ui:Refresh(); local job=ui.buildJob; local step=job.Step; local verifyRows
    local name=ui.widgets[2].cells[I.Name].label
    job.Step=function(j)
        step(j)
        if j.status=="complete" then
            for n,r in ipairs(j.rows) do for _,col in ipairs({I.Skill,I.Moxie,I.Concentration}) do
                r.cells[col]="|cffffbb00!|r "..n..":"..col
            end end
            verifyRows=frozen(j.rows); name.SetText=function() error("ROUND1_PUBLICATION_NAME") end
        end
    end
    redrawPump(ui,checkpoint); eq(ui.retained,true); round1SafeMarkers(ui)
    assert(ui.reason:GetText():find("failed",1,true)); eq(ui:ActionsReady(),false); verifySaved(); verifyRows()
    name.SetText=nil; ui:Refresh(); redrawPump(ui,checkpoint); eq(ui.retained,false); verifySaved(); verifyRows()
end)
case("R01 round1 safety sweep reentry cannot demote or fault-hide a replacement display",function(checkpoint)
    for _,replacement in ipairs({"pending","complete","newPending","newComplete"}) do for _,throws in ipairs({false,true}) do
        local ui,env,_,cmd=redrawFixture(checkpoint); round1Markers(ui)
        local label=ui.widgets[1].cells[I.Skill].label; local text=label.SetText; local fired=false
        local nextRows,nextJob,nextReason,nextText,nextShown
        label.SetText=function(w,v)
            text(w,v)
            if not fired and v:find("|cff999999!|r",1,true) then
                fired=true; ui.options.sortColumn=I.Name
                if replacement=="newPending" or replacement=="newComplete" then cmd.collector.db=S.New() end
                ui:Refresh()
                if replacement=="complete" or replacement=="newComplete" then redrawPump(ui) end
                nextRows,nextJob,nextReason=ui.rows,ui.buildJob,ui.reason:GetText()
                nextText,nextShown=label:GetText(),label:IsShown()
                if throws then error("ROUND1_RETIRED_SWEEP") end
            end
        end
        local ok,why=pcall(function()
            ui:Refresh(); assert(fired); eq(ui.rows,nextRows); eq(ui.buildJob,nextJob)
            eq(ui.reason:GetText(),nextReason); eq(label:GetText(),nextText); eq(label:IsShown(),nextShown)
            if replacement=="pending" then eq(ui.retained,true) else eq(ui.retained,false) end
        end)
        label.SetText=nil; assert(ok,replacement.."/"..tostring(throws)..": "..tostring(why))
        redrawPump(ui,checkpoint); eq(ui.retained,false)
    end end
end)
case("R01 round1 exact row tree pointers and newer sweep hover retain their own invocation",function(checkpoint)
    for _,kind in ipairs({"cell","tree","sweepHover"}) do
        local ui,env,_,cmd=redrawFixture(checkpoint); local widget=round1OldHover(ui,kind=="tree" and "tree" or "cell")
        local tip=env.GameTooltip; local fired=false
        if kind=="sweepHover" then
            round1Markers(ui); local label=ui.widgets[1].cells[I.Skill].label; local text=label.SetText
            label.SetText=function(w,v)
                text(w,v)
                if not fired and v:find("|cff999999!|r",1,true) then
                    fired=true; widget.scripts.OnEnter(widget)
                    eq(tip:IsShown(),true); assert(tip.lines[1]:find("Previous saved values",1,true))
                end
            end
            ui:Refresh(); label.SetText=nil; assert(fired); eq(tip:IsShown(),true)
            assert(tip.lines[1]:find("Previous saved values",1,true)); redrawPump(ui,checkpoint)
        else
            env.IsShiftKeyDown=function()
                fired=true
                if kind=="cell" then ui.widgets[1].row=ui.rows[2] else widget.tree=ui.widgets[2].bars[1].tree end
                return true
            end
            widget.scripts.OnEnter(widget); assert(fired)
            assert(not tip:IsShown() or not table.concat(tip.lines,"\n"):find("ROUND1_OLD",1,true))
            env.IsShiftKeyDown=nil
        end
        pause(checkpoint,"R01 round1 exact invocation pointers")
    end
end)
-- R01 ROUND1 END
-- U06 BEGIN (additive; all488 prior cases and helpers remain byte-identical)
do
local function near(actual,expected)
    assert(type(actual)=="number" and math.abs(actual-expected)<1e-12,
        tostring(actual).." not near "..tostring(expected))
end
local function color(actual,expected)
    for n=1,3 do near(actual[n],expected[n]) end
end
local function skillFixture(values)
    local env,state=fixtureAPI(); mockWidgets(env)
    local create=env.CreateFrame
    env.CreateFrame=function(...)
        local w=create(...); local font=w.CreateFontString
        w.CreateFontString=function(host,name,layer,template)
            local label=font(host,name,layer,template); label.u06Layer=layer; return label
        end
        return w
    end
    local db=dbWith(values or {skill={skillLevel=25,maxSkillLevel=100,skillModifier=75}})
    local c=NS.Collectors.New(env,db); local ui=NS.Dashboard.New(env,c); ui:Toggle()
    return ui,env,c,state
end
local function noSkillWrites(ui,env,c,state)
    -- U13 ADAPT NOSKILLWRITES_READ_SNAPSHOT BEGIN
--[==========[U13 ORIGINAL BEGIN
    local verify=frozen({c.db,c.fresh,ui.rows}); local reads,requests,timers=state.reads,state.requests,#state.timers
U13 ORIGINAL END]==========]
    local verify=frozen({c.db,c.fresh,ui.rows}); local reads,requests,timers=state.reads,state.requests,#state.timers
    local u13VerifyReads=u13NoAcquisition(state)
    -- U13 ADAPT NOSKILLWRITES_READ_SNAPSHOT END
    local function forbidden() error("U06 presentation must not collect") end
    c.Request=forbidden; c.Scan=forbidden; c.Context=forbidden; c.Login=forbidden
    -- U13 ADAPT NOSKILLWRITES_READ_CHECK BEGIN
--[==========[U13 ORIGINAL BEGIN
    return function() verify(); eq(state.reads,reads); eq(state.requests,requests); eq(#state.timers,timers) end
U13 ORIGINAL END]==========]
    return function() verify(); u13VerifyReads(); eq(state.requests,requests); eq(#state.timers,timers) end
    -- U13 ADAPT NOSKILLWRITES_READ_CHECK END
end
for _,sample in ipairs({{0,100,0,.85,.20,.20},{25,100,.25,.925,.425,.10},
    {50,100,.5,1,.65,0},{75,100,.75,.60,.715,.15},{100,100,1,.20,.78,.30},
    {20,80,.25,.925,.425,.10},{180,150,1,.20,.78,.30}}) do
    local s=sample
    case("U06 scalar completion "..s[1].."/"..s[2],function()
        local skill={skillLevel=s[1],maxSkillLevel=s[2],skillModifier=9999}; local verify=frozen(skill)
        local ratio,r,g,b=NS.Dashboard.SkillProgress(skill)
        near(ratio,s[3]); color({r,g,b},{s[4],s[5],s[6]}); verify()
    end)
end
case("U06 invalid scalar inputs are neutral unknown not zero or full",function()
    -- U09 SCALAR BEGIN
    do
        for _,s in ipairs({{0,1000,0},{250,1000,.25},{1000,1000,1},{1200,1000,1},{25,50,.5}}) do
            local v={quantity=s[1],maxQuantity=s[2]}; local verify=frozen(v)
            local ratio,r,g,b=NS.Dashboard.ConcentrationProgress(v)
            near(ratio,s[3]); color({r,g,b},s[3]==1 and {.20,.78,.30} or {.20,.65,.95}); verify()
        end
        local function unknown(v)
            local ratio,r,g,b=NS.Dashboard.ConcentrationProgress(v)
            eq(ratio,nil); color({r,g,b},{.45,.50,.58})
        end
        unknown(nil); unknown(false); unknown(5); unknown("100/1000"); unknown({}); unknown({quantity=25})
        for _,bad in ipairs({false,"100",-1,.5,math.huge,-math.huge,0/0}) do
            unknown({quantity=bad,maxQuantity=1000}); unknown({quantity=25,maxQuantity=bad})
        end
        unknown({quantity=25,maxQuantity=0})
    end
    -- U09 SCALAR END
    local samples={false,7,"25/100",{}, {skillLevel=0}, {maxSkillLevel=100}}
    for _,bad in ipairs({-1,.5,math.huge,-math.huge,0/0,"25",false}) do
        samples[#samples+1]={skillLevel=bad,maxSkillLevel=100}
        samples[#samples+1]={skillLevel=25,maxSkillLevel=bad}
    end
    samples[#samples+1]={skillLevel=25,maxSkillLevel=0}
    local function unknown(value)
        local ratio,r,g,b=NS.Dashboard.SkillProgress(value)
        eq(ratio,nil); color({r,g,b},{.45,.50,.58})
    end
    unknown(nil)
    for _,s in ipairs(samples) do local verify=frozen(s); unknown(s); verify() end
end)
case("U06 actual Skill widgets geometry flat texture overlay and mouse pass-through",function()
    -- U13 CONCENTRATION_UI BEGIN
    do
        local ui,env,c,state=skillFixture({concentration={id=50001,quantity=400,maxQuantity=1000,
            rechargingCycleDurationMS=1000,rechargingAmountPerCycle=1}})
        local row=ui.rows[1]; local cell=ui.widgets[1].cells[I.Concentration]
        local gain=assert(cell.estimate,"U13 additional Concentration texture rejection")
        local originalNow=c.Now; local calls=0
        c.Now=function() calls=calls+1; return row.concentrationState.observedAt+250 end
        local verify=noSkillWrites(ui,env,c,state)
        assert(ui:Render()); eq(calls,1); verify()
        near(cell.bar.value,.4); color(cell.bar.style.SetStatusBarColor,{.20,.65,.95})
        near(gain.width,23); eq(gain.height,14); near(gain.points[1].x,36.8)
        eq(gain.points[1].relative,cell.bar); eq(gain.points[1].point,"LEFT"); eq(gain.drawLayer,"ARTWORK")
        color(gain.style.SetColorTexture,{.10,.90,1}); eq(gain:IsShown(),true)
        eq(cell.label:GetText(),"~650/1000"); eq(row.cells[I.Concentration],"400/1000")
        eq(row.concentration,400); eq(row.sortValues[I.Concentration],400); eq(row.priority,3)
        local value=row.concentrationValue
        for _,mode in ipairs({"floor","zero","invalidRate","clockFail","clockBack","archive","retained","full","projectedFull","unknown"}) do
            row.concentrationValue=value; row.archived=false; ui.retained=false
            c.Now=function() return row.concentrationState.observedAt+250 end
            if mode=="floor" then row.concentrationValue={quantity=400,maxQuantity=1000,rechargingCycleDurationMS=1000000,rechargingAmountPerCycle=1}
            elseif mode=="zero" then c.Now=function() return row.concentrationState.observedAt end
            elseif mode=="invalidRate" then row.concentrationValue={quantity=400,maxQuantity=1000,rechargingCycleDurationMS=0,rechargingAmountPerCycle=1}
            elseif mode=="clockFail" then c.Now=function() error("U13 clock failure") end
            elseif mode=="clockBack" then c.Now=function() return row.concentrationState.observedAt-1 end
            elseif mode=="archive" then row.archived=true
            elseif mode=="retained" then ui.retained=true
            elseif mode=="full" then row.concentrationValue={quantity=1000,maxQuantity=1000,rechargingCycleDurationMS=1000,rechargingAmountPerCycle=1}
            elseif mode=="projectedFull" then c.Now=function() return row.concentrationState.observedAt+10000 end
            else row.concentrationValue=nil end
            assert(ui:Render())
            eq(gain:IsShown(),mode=="projectedFull",mode.." cyan reset")
            if mode=="projectedFull" then near(gain.width,55.2); eq(cell.label:GetText(),"~1000/1000"); color(cell.bar.style.SetStatusBarColor,{.20,.65,.95})
            elseif mode=="full" then eq(cell.label:GetText(),"1000/1000"); color(cell.bar.style.SetStatusBarColor,{.20,.78,.30})
            else eq(cell.label:GetText(),mode=="unknown" and "?" or "400/1000") end
        end
        row.concentrationValue=value; row.archived=false; ui.retained=false; c.Now=originalNow
    end
    -- U13 CONCENTRATION_UI END
    -- U09 GEOMETRY BEGIN
    do
        local ui,env,c,state=skillFixture({concentration={id=50001,quantity=100,maxQuantity=1000}})
        assert(ui.widgets[1].cells[I.Concentration].bar,"U09 missing Concentration bar")
        local verify=noSkillWrites(ui,env,c,state); local widgets=#env.fixtureWidgets
        local bars={}; local count=0
        for n,w in ipairs(ui.widgets) do
            local cell=w.cells[I.Concentration]; local b=assert(cell.bar); bars[n]=b; count=count+1
            -- U10 ADAPT U09_CELL_HEIGHT BEGIN
--[====[U10 ORIGINAL BEGIN
            eq(cell.width,96); eq(cell.height,22); eq(b.kind,"StatusBar"); eq(b.parent,cell)
U10 ORIGINAL END]====]
            -- U11 ADAPT U09_CELL BEGIN
--[======[U11 ORIGINAL BEGIN
            eq(cell.width,96); eq(cell.height,32); eq(b.kind,"StatusBar"); eq(b.parent,cell)
U11 ORIGINAL END]======]
            eq(cell.width,96); eq(cell.height,28); eq(b.kind,"StatusBar"); eq(b.parent,cell)
            -- U11 ADAPT U09_CELL END
            -- U10 ADAPT U09_CELL_HEIGHT END
            eq(b.width,92); eq(b.height,14); eq(b.points[1].point,"CENTER")
            eq(b.points[1].relative,cell); eq(b.points[1].x,0); eq(b.points[1].y,0)
            eq(b.style.SetStatusBarTexture[1],"Interface\\Buttons\\WHITE8X8")
            eq(b.style.SetMinMaxValues[1],0); eq(b.style.SetMinMaxValues[2],1)
            color(b.background.style.SetColorTexture,{.15,.15,.15}); eq(b.background.style.SetColorTexture[4],1)
            eq(b.background.allPoints,b); eq(b.style.EnableMouse[1],false); eq(next(b.scripts),nil)
            eq(cell.label.parent,b); eq(cell.label.u06Layer,"OVERLAY"); eq(cell.label.width,92)
            eq(cell.label.style.SetJustifyH[1],"CENTER"); eq(cell.label.allPoints,b)
            eq(cell.style.EnableMouse[1],true); assert(cell.scripts.OnEnter and cell.scripts.OnMouseDown)
            local labels,children=0,0
            for _,candidate in ipairs(env.fixtureWidgets) do
                if candidate.kind=="FontString" and (candidate.parent==cell or candidate.parent==b) then labels=labels+1 end
                if candidate.kind=="StatusBar" and candidate.parent==cell then children=children+1 end
            end
            eq(labels,1); eq(children,1)
        end
        eq(count,12); near(bars[1].value,.1); color(bars[1].style.SetStatusBarColor,{.20,.65,.95})
        eq(ui.widgets[1].cells[I.Concentration].label:GetText(),"100/1000")
        color(ui.widgets[1].cells[I.Concentration].label.style.SetTextColor,{1,1,1})
        ui:Render(); for n,w in ipairs(ui.widgets) do eq(w.cells[I.Concentration].bar,bars[n]) end
        eq(#env.fixtureWidgets,widgets); verify()
    end
    -- U09 GEOMETRY END
    local ui,env,c,state=skillFixture(); local verify=noSkillWrites(ui,env,c,state)
    local countBars=0
    for _,w in ipairs(env.fixtureWidgets) do
        if w.kind=="StatusBar" and w.parent==ui.widgets[1].cells[I.Skill] then countBars=countBars+1 end
    end
    eq(countBars,1,"Only one Skill child in first row outside Knowledge")
    for _,w in ipairs(ui.widgets) do
        local cell=w.cells[I.Skill]; local b=assert(cell.bar,"Skill cell requires native bar")
        -- U10 ADAPT U06_CELL_HEIGHT BEGIN
--[====[U10 ORIGINAL BEGIN
        eq(cell.width,64); eq(cell.height,22); eq(b.kind,"StatusBar"); eq(b.parent,cell)
U10 ORIGINAL END]====]
        -- U11 ADAPT U06_CELL BEGIN
--[======[U11 ORIGINAL BEGIN
        eq(cell.width,64); eq(cell.height,32); eq(b.kind,"StatusBar"); eq(b.parent,cell)
U11 ORIGINAL END]======]
        eq(cell.width,64); eq(cell.height,28); eq(b.kind,"StatusBar"); eq(b.parent,cell)
        -- U11 ADAPT U06_CELL END
        -- U10 ADAPT U06_CELL_HEIGHT END
        eq(b.width,60); eq(b.height,14); eq(b.points[1].point,"CENTER")
        eq(b.points[1].relative,cell); eq(b.points[1].x,0); eq(b.points[1].y,0)
        eq(b.style.SetStatusBarTexture[1],"Interface\\Buttons\\WHITE8X8")
        eq(b.style.SetMinMaxValues[1],0); eq(b.style.SetMinMaxValues[2],1)
        color(b.background.style.SetColorTexture,{.15,.15,.15}); eq(b.background.style.SetColorTexture[4],1)
        eq(b.background.allPoints,b); eq(b.style.EnableMouse[1],false); eq(b.scripts.OnEnter,nil); eq(b.scripts.OnMouseDown,nil)
        eq(cell.label.parent,b); eq(cell.label.u06Layer,"OVERLAY"); eq(cell.label.width,60)
        eq(cell.label.style.SetJustifyH[1],"CENTER"); eq(cell.label.allPoints,b)
        local labels=0
        for _,candidate in ipairs(env.fixtureWidgets) do if candidate.kind=="FontString" and
            (candidate.parent==cell or candidate.parent==b) then labels=labels+1 end end
        eq(labels,1,"No duplicate Skill labels")
    end
    local b=ui.widgets[1].cells[I.Skill].bar; near(b.value,.25); color(b.style.SetStatusBarColor,{.925,.425,.10})
    eq(ui.widgets[1].cells[I.Skill].label:GetText(),ui.rows[1].cells[I.Skill]); verify()
end)
case("U06 reused Skill known zero full unknown and unusable caps clear fill and preserve prefixes",function()
    -- U09 REUSE BEGIN
    do
        local ui,env,c,state=skillFixture({concentration={id=50001,quantity=100,maxQuantity=1000}})
        local row=ui.rows[1]; local cell=ui.widgets[1].cells[I.Concentration]; local b=assert(cell.bar)
        local widgets=#env.fixtureWidgets
        for _,s in ipairs({{0,1000,0,"0/1000"},{1000,1000,1,"1000/1000"},{1200,1000,1,"1200/1000"},
            {250,1000,.25,"250/1000"},{25,0,false,"25/?"},{25,-1,false,"25/?"},{25,.5,false,"25/?"},
            {25,math.huge,false,"25/?"},{25,false,false,"25/?"},{false,1000,false,"?"},
            {-1,1000,false,"?"},{.5,1000,false,"?"},{math.huge,1000,false,"?"}}) do
            row.concentrationValue={quantity=s[1],maxQuantity=s[2]}
            local verify=noSkillWrites(ui,env,c,state); ui:Render(); verify()
            eq(cell.bar,b); eq(b.value,s[3] or 0); eq(b:GetStatusBarTexture():IsShown(),s[3]~=false)
            eq(cell.label:GetText(),s[4]); local _,r,g,blue=NS.Dashboard.ConcentrationProgress(row.concentrationValue)
            color(b.style.SetStatusBarColor,{r,g,blue})
        end
        for _,value in ipairs({false,{}, {quantity=25},{maxQuantity=1000}}) do
            row.concentrationValue=value; ui:Render(); eq(b.value,0); eq(b:GetStatusBarTexture():IsShown(),false)
            eq(cell.label:GetText(),type(value)=="table" and value.quantity==25 and "25/?" or "?")
        end
        row.concentrationValue=nil; ui:Render(); eq(cell.label:GetText(),"?"); eq(b.value,0)
        row.concentrationValue={quantity=500,maxQuantity=1000}; ui:Render(); eq(b.value,.5)
        eq(b:GetStatusBarTexture():IsShown(),true); eq(cell.label:GetText(),"500/1000")
        cell.scripts.OnMouseDown(cell,"LeftButton"); eq(ui.selected,row); eq(ui.details,nil)
        eq(#env.fixtureWidgets,widgets)
    end
    -- U09 REUSE END
    local ui,env,c,state=skillFixture(); local row=ui.rows[1]; local cell=ui.widgets[1].cells[I.Skill]
    local b=assert(cell.bar,"Skill cell requires native bar"); local widgets=#env.fixtureWidgets
    for _,s in ipairs({{0,100,0},{100,100,1},{25,100,.25},{180,150,1},
        {25,0},{25,-1},{25,.5},{-1,100},{.5,100},{25,math.huge},{math.huge,100},{25,false},{false,100}}) do
        for _,prefix in ipairs({"","|cffffbb00!|r ","|cff999999!|r "}) do
            row.skill={skillLevel=s[1],maxSkillLevel=s[2],skillModifier=400}
            row.cells[I.Skill]=prefix..tostring(s[1]).."/"..tostring(s[2])
            local verify=noSkillWrites(ui,env,c,state); ui:Render(); verify()
            eq(cell.bar,b); eq(b.value,s[3] or 0); eq(b:GetStatusBarTexture():IsShown(),s[3]~=nil)
            eq(cell.label:GetText(),s[3]~=nil and row.cells[I.Skill] or prefix.."?")
            local _,r,g,blue=NS.Dashboard.SkillProgress(row.skill); color(b.style.SetStatusBarColor,{r,g,blue})
        end
    end
    for _,skill in ipairs({false,{}, {maxSkillLevel=100},{skillLevel=25}}) do
        row.skill=skill; row.cells[I.Skill]="|cffffbb00!|r ?/100"; ui:Render()
        eq(cell.label:GetText(),"|cffffbb00!|r ?"); eq(b.value,0); eq(b:GetStatusBarTexture():IsShown(),false)
    end
    row.skill=nil; row.cells[I.Skill]="?"; ui:Render(); eq(b:GetStatusBarTexture():IsShown(),false)
    row.skill={skillLevel=50,maxSkillLevel=200}; row.cells[I.Skill]="50/200"; ui:Render()
    near(b.value,.25); eq(cell.label:GetText(),"50/200"); eq(b:GetStatusBarTexture():IsShown(),true)
    row.skill=nil; row.cells[I.Skill]="?"; ui:Render()
    eq(b.value,0); eq(b:GetStatusBarTexture():IsShown(),false); eq(cell.label:GetText(),"?")
    color(b.style.SetStatusBarColor,{.45,.50,.58})
    eq(#env.fixtureWidgets,widgets,"Render must reuse all widgets")
end)
case("U06 saved fresh stale and archived Skill keep numbers freshness and existing hovers",function()
    local ui,env,c,state=skillFixture(); local db=c.db; local g=S.Active(db,character.guid,2913)
    c.fresh={[character.guid..":2913"]={generation=g.generation,fields={skill=true}}}; ui:Refresh()
    local function check(mode)
        local row=ui.rows[1]; local cell=ui.widgets[1].cells[I.Skill]; local verify=noSkillWrites(ui,env,c,state)
        near(cell.bar.value,.25); eq(cell.label:GetText(),row.cells[I.Skill])
        for _,shift in ipairs({false,true}) do
            env.IsShiftKeyDown=function() return shift end; cell.scripts.OnEnter(cell)
            local expected=shift and row.tooltip or row.cellTooltips[I.Skill]
            for _,line in ipairs(expected) do assert(table.concat(env.GameTooltip.lines,"\n"):find(NS.Dashboard.PlainTooltip(line),1,true)) end
            cell.scripts.OnLeave(cell); eq(env.GameTooltip:IsShown(),false)
        end
        if mode=="fresh" then eq(row.skillState.fresh,true); eq(cell.label:GetText(),"25/100"); eq(row.cells[I.Skill],"25/100")
        elseif mode=="stale" then eq(row.skillState.stale,true); eq(row.skillState.fresh,false)
        else eq(row.archived,true); eq(row.skillState.fresh,false) end
        cell.scripts.OnMouseDown(cell,"LeftButton"); eq(ui.selected,row); eq(ui.details,nil); verify()
    end
    check("fresh")
    assert(C.Apply(db,character,identity,{skill=C.Observation("error",nil,200,"U06","transient")},200,"fixture"))
    ui:Refresh(); check("stale")
    assert(S.Archive(db,character.guid,2913,300,"U06")); ui.options.archived=true; ui:Refresh(); check("archived")
end)
case("U06 numeric Skill sorting filtering and twelve-bar reuse leave snapshots untouched",function(checkpoint)
    local ui,env,_,cmd=redrawFixture(checkpoint); local c=cmd.collector; local _,packs=seed()
    for n=1,16 do applyPack(c.db,packs[1],"U06-page-"..n) end
    ui:Refresh(); redrawPump(ui,checkpoint); local verify=frozen({env.CraftArmyDB,c.fresh})
    local widgets,bars={},{}
    for n,w in ipairs(ui.widgets) do widgets[n]=w; bars[n]=assert(w.cells[I.Skill].bar) end
    local reads=cmd.collector.Scan; cmd.collector.Scan=function() error("U06 sort cannot scan") end
    local function sorted(desc)
        local previous
        for _,r in ipairs(ui.rows) do
            local value=r.sortValues[I.Skill]
            if value and previous then assert(desc and previous>=value or not desc and previous<=value) end
            if value then previous=value end
        end
    end
    for _=1,2 do ui.headers[I.Skill].scripts.OnClick(); redrawPump(ui,checkpoint); sorted(ui.options.sortDescending) end
    ui.offset=12; ui:Render(); eq(#ui.widgets,12)
    for n,w in ipairs(ui.widgets) do eq(w,widgets[n]); eq(w.cells[I.Skill].bar,bars[n]) end
    local name=ui.rows[1].name
    ui.filters.character:SetText("U06 no matching character"); ui.filters.character.scripts.OnTextChanged(ui.filters.character)
    redrawPump(ui,checkpoint); eq(#ui.rows,0)
    ui.filters.character:SetText(name); ui.filters.character.scripts.OnTextChanged(ui.filters.character)
    redrawPump(ui,checkpoint); assert(#ui.rows>0)
    for _,r in ipairs(ui.rows) do assert(r.name:lower():find(name:lower(),1,true)) end
    cmd.collector.Scan=reads; verify()
end)
case("U06 populated schema2 refresh retains last bars and blocks historical Skill hovers actions",function(checkpoint)
    -- U09 RETAINED BEGIN
    do
        local ui,env,_,cmd=redrawFixture(checkpoint); local c=cmd.collector
        local cell=ui.widgets[1].cells[I.Concentration]; local b=assert(cell.bar)
        local value,label=b.value,cell.label:GetText(); local verify=frozen({env.CraftArmyDB,c.fresh,ui.rows})
        ui:Refresh(); local now=c.Now; c.Now=function() error("U09 retained hover cannot read clock") end
        for _,shift in ipairs({false,true}) do
            env.IsShiftKeyDown=function() return shift end; cell.scripts.OnEnter(cell)
            eq(#env.GameTooltip.lines,1); assert(env.GameTooltip.lines[1]:find("Previous saved values",1,true))
            cell.scripts.OnMouseDown(cell,"LeftButton"); eq(ui.selected,nil)
            eq(b.value,value); eq(cell.label:GetText(),label)
        end
        c.Now=now; verify(); redrawPump(ui,checkpoint)
    end
    -- U09 RETAINED END
    local ui,env,_,cmd=redrawFixture(checkpoint); local rows=ui.rows; local bars={}
    for n=1,8 do local b=assert(ui.widgets[n].cells[I.Skill].bar); bars[n]={b,b.value,{unpack(b.style.SetStatusBarColor)}} end
    local verify=frozen({rows,env.CraftArmyDB,cmd.collector.fresh}); local _,packs=seed()
    ui:Refresh(); local stale=ui.buildDriver.scripts.OnUpdate
    for n=1,8 do
        local cell=ui.widgets[n].cells[I.Skill]; local b=cell.bar
        eq(b,bars[n][1]); eq(b.value,bars[n][2]); color(b.style.SetStatusBarColor,bars[n][3])
        for _,shift in ipairs({false,true}) do
            env.IsShiftKeyDown=function() return shift end; cell.scripts.OnEnter(cell)
            eq(#env.GameTooltip.lines,1); assert(env.GameTooltip.lines[1]:find("Previous saved values",1,true))
            cell.scripts.OnMouseDown(cell,"LeftButton"); eq(ui.selected,nil)
        end
    end
    verify(); applyPack(cmd.collector.db,packs[1],nil,950); local verifySaved=frozen(env.CraftArmyDB)
    ui:Refresh(); stale(); eq(ui.rows,rows); redrawPump(ui,checkpoint); eq(ui.retained,false); verifySaved()
end)
case("U06 early Skill label bar and texture failures retain demoted markers and retry",function(checkpoint)
    for _,site in ipairs({"label","labelHide","color","value","getTexture","texture"}) do
        local ui,env,_,cmd=redrawFixture(checkpoint); round1Markers(ui)
        local cell=ui.widgets[1].cells[I.Skill]; local b=assert(cell.bar); local texture=b:GetStatusBarTexture()
        local target,method=cell.label,"SetText"
        if site=="color" then target,method=b,"SetStatusBarColor" elseif site=="value" then target,method=b,"SetValue"
        elseif site=="getTexture" then target,method=b,"GetStatusBarTexture" elseif site=="texture" then target,method=texture,"SetShown" end
        local original=target[method]; target[method]=function() error("U06_DRAW_FAULT") end
        local hide=cell.label.Hide; if site=="labelHide" then cell.label.Hide=function() error("U06_HIDE_FAULT") end end
        local verify=frozen({ui.rows,env.CraftArmyDB,cmd.collector.fresh})
        local ok,why=pcall(function()
            ui:Refresh(); eq(ui.retained,true); eq(ui:ActionsReady(),false); round1SafeMarkers(ui); verify()
            if site=="label" then eq(cell.label:IsShown(),false) elseif site=="labelHide" then eq(ui.widgets[1]:IsShown(),false) end
        end)
        target[method]=original; cell.label.Hide=hide; assert(ok,site..": "..tostring(why))
        ui:Refresh(); redrawPump(ui,checkpoint); eq(ui.retained,false); eq(cell.label:IsShown(),true); eq(ui.widgets[1]:IsShown(),true)
        verify()
    end
end)
for _,operation in ipairs({"SetStatusBarColor","SetValue","GetStatusBarTexture","SetShown","SetText"}) do
    local method=operation
    case("U06 guarded new draw reentry "..method,function(checkpoint)
        for _,mode in ipairs({"Refresh","source","sourceOnly","Hide"}) do for _,throws in ipairs({false,true}) do
            local ui,env,_,cmd=redrawFixture(checkpoint); local cell=ui.widgets[1].cells[I.Skill]; local b=assert(cell.bar)
            local target=method=="SetShown" and b:GetStatusBarTexture() or (method=="SetText" and cell.label or b)
            local original=target[method]; local fired=false; local nextRows,nextJob,nextText,nextValue,nextColor,nextShown
            local verify=frozen({env.CraftArmyDB,cmd.collector.fresh})
            target[method]=function(w,...)
                local result=original(w,...)
                if not fired then
                    fired=true
                    if mode=="source" or mode=="sourceOnly" then cmd.collector.db=S.New() end
                    if mode=="Hide" then ui.frame:Hide() elseif mode~="sourceOnly" then
                        ui.options.sortColumn=I.Name; ui:Refresh(); redrawPump(ui)
                    end
                    nextRows,nextJob,nextText=ui.rows,ui.buildJob,cell.label:GetText()
                    nextValue,nextColor,nextShown=b.value,{unpack(b.style.SetStatusBarColor)},ui.widgets[1]:IsShown()
                    if throws then error("U06_RETIRED_DRAW") end
                end
                return result
            end
            local ok,why=pcall(function()
                ui:Render(); assert(fired)
                if mode=="sourceOnly" then
                    eq(ui.completed,nil); eq(#ui.rows,0); eq(ui.widgets[1]:IsShown(),false)
                    eq(ui.selected,nil); eq(ui.confirmation,nil)
                else
                    eq(ui.rows,nextRows); eq(ui.buildJob,nextJob)
                    eq(cell.label:GetText(),nextText); eq(b.value,nextValue); color(b.style.SetStatusBarColor,nextColor)
                    eq(ui.widgets[1]:IsShown(),nextShown)
                end
                verify()
                -- A different-source completion must not resurrect a detached row.
                if mode=="source" then eq(#ui.rows,0); eq(ui.widgets[1]:IsShown(),false) end
            end)
            target[method]=original; assert(ok,method.."/"..mode.."/"..tostring(throws)..": "..tostring(why))
            pause(checkpoint,"U06 guarded draw reentry")
        end end
        -- U09 DRAW BEGIN
        for _,mode in ipairs({"Refresh","pending","source","sourceOnly","Hide"}) do for _,throws in ipairs({false,true}) do
            local ui,env,_,cmd=redrawFixture(checkpoint); local cell=ui.widgets[1].cells[I.Concentration]; local b=assert(cell.bar)
            local target=method=="SetShown" and b:GetStatusBarTexture() or (method=="SetText" and cell.label or b)
            local original=target[method]; local fired=false; local nextRows,nextJob,nextText,nextValue,nextColor,nextShown
            local verify=frozen({env.CraftArmyDB,cmd.collector.fresh})
            target[method]=function(w,...)
                local result=original(w,...)
                if not fired then
                    fired=true
                    if mode=="source" or mode=="sourceOnly" then cmd.collector.db=S.New() end
                    if mode=="Hide" then ui.frame:Hide() elseif mode~="sourceOnly" then
                        ui.options.sortColumn=I.Name; ui:Refresh(); if mode~="pending" then redrawPump(ui) end
                    end
                    nextRows,nextJob,nextText=ui.rows,ui.buildJob,cell.label:GetText()
                    nextValue,nextColor,nextShown=b.value,{unpack(b.style.SetStatusBarColor)},ui.widgets[1]:IsShown()
                    if throws then error("U09_RETIRED_DRAW") end
                end
                return result
            end
            local ok,why=pcall(function()
                ui:Render(); assert(fired)
                if mode=="sourceOnly" then
                    eq(ui.completed,nil); eq(#ui.rows,0); eq(ui.widgets[1]:IsShown(),false)
                    eq(ui.selected,nil); eq(ui.confirmation,nil)
                else
                    eq(ui.rows,nextRows); eq(ui.buildJob,nextJob); eq(cell.label:GetText(),nextText)
                    eq(b.value,nextValue); color(b.style.SetStatusBarColor,nextColor); eq(ui.widgets[1]:IsShown(),nextShown)
                end
                verify()
                if mode=="source" then eq(#ui.rows,0); eq(ui.widgets[1]:IsShown(),false) end
            end)
            target[method]=original; assert(ok,method.."/"..mode.."/"..tostring(throws)..": "..tostring(why))
            pause(checkpoint,"U09 guarded Concentration draw reentry")
        end end
        -- U09 DRAW END
        -- U10 DRAW BEGIN
        if method=="SetText" then
            local sites={{"itemBorder","SetShown"},{"itemBorder","SetBackdropBorderColor"},
                {"itemIcon","SetTexture"},{"itemIcon","SetShown"},{"qualityIcon","SetAtlas"},{"qualityIcon","SetShown"},
                {"qualityDigit","SetText"},{"qualityDigit","SetShown"},{"qualityFrame","SetShown"},{"statLetter","SetText"},{"statLetter","SetFont"},
                {"statLetter","SetTextColor"},{"statLetter","SetShown"},{"statBacking","SetShown"},{"enchantBadge","SetShown"}}
            for _,site in ipairs(sites) do
                local function fixture()
                    local ui,env,_,cmd=redrawFixture(checkpoint)
                    local gear=ui.rows[1].gear.tool
                    gear.qualityAtlas="U10FaultAtlas"; gear.toolLetter="M"; gear.enchanted=true
                    ui:Render()
                    return ui,env,cmd,ui.widgets[1].cells[I.Tool]
                end
                do
                    local ui,env,cmd,cell=fixture(); local target,key=cell[site[1]],site[2]
                    local original=target[key]; local verify=frozen({env.CraftArmyDB,cmd.collector.fresh})
                    target[key]=function() error("U10_DRAW_FAULT") end
                    eq(ui:Render(),false); eq(ui.retained,true); eq(ui:ActionsReady(),false); verify()
                    target[key]=original; ui:Refresh(); redrawPump(ui,checkpoint); eq(ui.retained,false); verify()
                end
                for _,mode in ipairs({"Refresh","pending","source","sourceOnly","Hide"}) do for _,throws in ipairs({false,true}) do
                    local ui,env,cmd,cell=fixture(); local target,key=cell[site[1]],site[2]
                    local original=target[key]; local fired=false; local nextRows,nextJob,nextVisual,nextShown
                    local verify=frozen({env.CraftArmyDB,cmd.collector.fresh})
                    local function visual()
                        return C.Copy({cell.itemIcon.texturePath,cell.itemIcon.shown,cell.itemBorder.style.SetBackdropBorderColor,
                            cell.qualityIcon.shown,cell.qualityIcon.atlas,cell.qualityDigit:GetText(),cell.qualityDigit.shown,
                            cell.statLetter:GetText(),cell.statLetter.shown,cell.statLetter.font,cell.statBacking.shown,cell.enchantBadge.shown,
                            cell.qualityFrame.shown})
                    end
                    target[key]=function(w,...)
                        local result=original(w,...)
                        if not fired then
                            fired=true
                            if mode=="source" or mode=="sourceOnly" then cmd.collector.db=S.New() end
                            if mode=="Hide" then ui.frame:Hide() elseif mode~="sourceOnly" then
                                ui.options.sortColumn=I.Name; ui:Refresh(); if mode~="pending" then redrawPump(ui) end
                            end
                            nextRows,nextJob,nextVisual,nextShown=ui.rows,ui.buildJob,visual(),ui.widgets[1]:IsShown()
                            if throws then error("U10_RETIRED_DRAW") end
                        end
                        return result
                    end
                    local ok,why=pcall(function()
                        ui:Render(); assert(fired)
                        if mode=="sourceOnly" then eq(ui.completed,nil); eq(#ui.rows,0); eq(ui.widgets[1]:IsShown(),false)
                        else
                            eq(ui.rows,nextRows); eq(ui.buildJob,nextJob); assert(deepEqual(visual(),nextVisual),"retired gear write")
                            eq(ui.widgets[1]:IsShown(),nextShown)
                        end
                        if mode=="source" then eq(#ui.rows,0); eq(ui.widgets[1]:IsShown(),false) end
                        verify()
                    end)
                    target[key]=original; assert(ok,site[1].."/"..key.."/"..mode.."/"..tostring(throws)..": "..tostring(why))
                    pause(checkpoint,"U10 icon border atlas font badge reentry")
                end end
            end
        end
        -- U10 DRAW END
    end)
end
case("U06 Skill hover retains original provenance through completed replacement",function(checkpoint)
    -- U15 ADD MOVED_DETAIL_GUARDS BEGIN
    do
        for _,col in ipairs({I.Accessory1,I.Accessory2,I.Tool,I.Concentration}) do
            local gear=col~=I.Concentration
            for _,boundary in ipairs(gear and {"SetHyperlink","AddLine","Show"} or {"AddLine","Show"}) do
                for _,mode in ipairs({"pending","complete","source","row","newer"}) do
                    for _,throws in ipairs({false,true}) do
                        local ui,env,_,cmd=redrawFixture(checkpoint); local c=cmd.collector
                        local cell=ui.widgets[1].cells[col]; local tip=env.GameTooltip
                        if gear then
                            local role=({[I.Accessory1]="accessory1",[I.Accessory2]="accessory2",[I.Tool]="tool"})[col]
                            ui.rows[1].gear[role].link="item:19019"
                            ui.rows[1].gear[role].summaryTooltip={}
                        end
                        local verify=frozen({env.CraftArmyDB,c.fresh,ui.rows})
                        local newer=ui.widgets[2].cells[I.Name]; local expected,fired
                        -- Normal native-link callbacks still exercise no-addon routing;
                        -- AddLine/Show test the now-moved Shift detail callsites.
                        env.IsShiftKeyDown=function() return boundary~="SetHyperlink" end
                        local original=tip[boundary]
                        tip[boundary]=function(...)
                            local result=pack(original(...))
                            if not fired then
                                fired=true
                                if mode=="newer" then
                                    env.IsShiftKeyDown=function() return false end
                                    newer.scripts.OnEnter(newer); expected=table.concat(tip.lines,"\n")
                                elseif mode=="row" then ui.widgets[1].row=ui.rows[2]
                                else
                                    if mode=="source" then c.db=S.New() end
                                    ui.options.character="U15 no matching row"; ui:Refresh()
                                    if mode~="pending" then redrawPump(ui) end
                                end
                                if throws then error("U15_THIRD_PARTY_FAULT") end
                            end
                            return unpack(result,1,result.n)
                        end
                        local ok,why=pcall(function()
                            eq(pcall(cell.scripts.OnEnter,cell),true); assert(fired)
                            local text=table.concat(tip.lines,"\n")
                            if mode=="newer" then eq(text,expected); eq(tip:IsShown(),true)
                            elseif mode=="pending" then assert(text:find("Previous saved values",1,true)); eq(tip:IsShown(),true)
                            else eq(tip:IsShown(),false) end
                            verify()
                        end)
                        tip[boundary]=original; env.IsShiftKeyDown=nil
                        assert(ok,"U15 moved-detail boundary "..col.."/"..boundary.."/"..mode.."/"..tostring(throws)..": "..tostring(why))
                        pause(checkpoint,"U15 moved detail and native-only hover ownership")
                    end
                end
            end
        end
    end
    -- U15 ADD MOVED_DETAIL_GUARDS END
    -- U09 HOVER REENTRY BEGIN
    for _,boundary in ipairs({"clock","helper","ClearLines","SetOwner","AddLine","Show"}) do
        for _,mode in ipairs({"pending","complete","source","row","newer"}) do
            local ui,env,_,cmd=redrawFixture(checkpoint); local c=cmd.collector
            local cell=ui.widgets[1].cells[I.Concentration]; local tip=env.GameTooltip
            ui.rows[1].cellTooltips[I.Concentration][1]="U09_OBSOLETE_CONCENTRATION"
            local verify=frozen({env.CraftArmyDB,c.fresh}); local fired=false
            local newer=ui.widgets[1].cells[I.Name]; local expected
            env.IsShiftKeyDown=function() return false end
            local target,key=tip,boundary
            if boundary=="clock" then target,key=c,"Now" elseif boundary=="helper" then target,key=NS.ViewModel,"ConcentrationTooltip" end
            local original=target[key]
            target[key]=function(...)
                local result=pack(original(...))
                if not fired then
                    fired=true
                    if mode=="newer" then
                        newer.scripts.OnEnter(newer); expected=table.concat(tip.lines,"\n")
                    elseif mode=="row" then ui.widgets[1].row=ui.rows[2]
                    else
                        if mode=="source" then c.db=S.New() end
                        ui.options.character="U09 no matching row"; ui:Refresh()
                        if mode~="pending" then redrawPump(ui) end
                    end
                end
                return unpack(result,1,result.n)
            end
            local ok,why=pcall(function()
                cell.scripts.OnEnter(cell); assert(fired)
                local text=table.concat(tip.lines,"\n")
                if mode=="pending" then assert(text:find("Previous saved values",1,true)); eq(tip:IsShown(),true)
                elseif mode=="newer" then eq(text,expected); eq(tip:IsShown(),true)
                else eq(tip:IsShown(),false) end
                if tip:IsShown() then assert(not text:find("U09_OBSOLETE_CONCENTRATION",1,true)) end
                verify()
            end)
            target[key]=original; assert(ok,boundary.."/"..mode..": "..tostring(why))
            pause(checkpoint,"U09 clock helper and tooltip ownership restored")
        end
    end
    -- U09 HOVER REENTRY END
    -- U10 HOVER BEGIN
    for _,boundary in ipairs({"ClearLines","SetOwner","SetHyperlink","AddLine","Show"}) do
        for _,mode in ipairs({"pending","complete","source","row","newer"}) do for _,throws in ipairs({false,true}) do
            local ui,env,_,cmd=redrawFixture(checkpoint); local c=cmd.collector
            local cell=ui.widgets[1].cells[I.Tool]; local tip=env.GameTooltip; local fired=false
            local verify=frozen({env.CraftArmyDB,c.fresh}); local newer=ui.widgets[1].cells[I.Name]; local expected
            -- U15 ADAPT GEAR_FAULT_CHANNEL BEGIN
--[============[U15 ORIGINAL BEGIN
            ui.rows[1].gear.tool.summaryTooltip={"U10_OBSOLETE_GEAR"}
            env.IsShiftKeyDown=function() return false end
U15 ORIGINAL END]============]
            ui.rows[1].gear.tool.summaryTooltip={}
            ui.rows[1].gear.tool.tooltip={"U10_OBSOLETE_GEAR"}
            env.IsShiftKeyDown=function() return boundary=="AddLine" end
            -- U15 ADAPT GEAR_FAULT_CHANNEL END
            local original=tip[boundary]
            tip[boundary]=function(...)
                local result=pack(original(...))
                if not fired then
                    fired=true
                    if mode=="newer" then newer.scripts.OnEnter(newer); expected=table.concat(tip.lines,"\n")
                    elseif mode=="row" then ui.widgets[1].row=ui.rows[2]
                    else
                        if mode=="source" then c.db=S.New() end
                        ui.options.character="U10 no matching row"; ui:Refresh(); if mode~="pending" then redrawPump(ui) end
                    end
                    if throws then error("U10_HOVER_NATIVE_FAULT") end
                end
                return unpack(result,1,result.n)
            end
            local ok,why=pcall(function()
                local hovered=pcall(cell.scripts.OnEnter,cell); eq(hovered,true); assert(fired)
                local text=table.concat(tip.lines,"\n")
                if mode=="newer" then eq(text,expected); eq(tip:IsShown(),true)
                else
                    if mode=="pending" then assert(text:find("Previous saved values",1,true)); eq(tip:IsShown(),true)
                    else eq(tip:IsShown(),false) end
                end
                if tip:IsShown() then assert(not text:find("U10_OBSOLETE_GEAR",1,true)) end
                verify()
            end)
            tip[boundary]=original; assert(ok,boundary.."/"..mode.."/"..tostring(throws)..": "..tostring(why))
            pause(checkpoint,"U10 gear native tooltip fault ownership")
        end end
    end
    -- U10 HOVER END
    for _,shift in ipairs({false,true}) do
        local ui,env,_,cmd=redrawFixture(checkpoint); local cell=ui.widgets[1].cells[I.Skill]
        ui.rows[1].cellTooltips[I.Skill]={"U06_OBSOLETE_SKILL"}; ui.rows[1].tooltip={"U06_OBSOLETE_SKILL"}
        local fired=false; local leaks=0; local tip=env.GameTooltip; local add=tip.AddLine
        tip.AddLine=function(w,line,...) if line:find("U06_OBSOLETE_SKILL",1,true) then leaks=leaks+1 end; return add(w,line,...) end
        env.IsShiftKeyDown=function()
            if not fired then fired=true; ui.options.character="no matching row"; ui:Refresh(); redrawPump(ui) end
            return shift
        end
        cell.scripts.OnEnter(cell); assert(fired); eq(leaks,0); eq(#ui.rows,0)
        tip.AddLine=add; env.IsShiftKeyDown=nil; pause(checkpoint,"U06 Skill hover provenance")
    end
end)
end
-- U06 END
-- U07 BEGIN (additive; four authorized original expectations adapted separately)
do
-- U07 GROUP COLLECT BEGIN
local registerGroup=case
local scenarios={}
local function case(name,fn)
    scenarios[#scenarios+1]={name=name,fn=fn}
end
-- U07 GROUP COLLECT END
local function valuesFor(level,cap,knowledge)
    local values=payloadFixtures()
    values.skill=level~=false and {skillLevel=level,maxSkillLevel=cap,skillModifier=9999} or nil
    if knowledge=="complete" then values["tree:11"]=treeValue(11,10,10)
    elseif knowledge=="unknown" then values.knowledgeIndex=nil; values.knowledgeRaw=nil; values["tree:11"]=nil end
    return values
end
local function sessionsFor(guid,g)
    local fields={}; for key in pairs(g.fields) do fields[key]=true end
    return {[guid..":2913"]={generation=g.generation,fields=fields}}
end
local function warning(row,category)
    for _,w in ipairs(row.warnings) do if w.category==category then return w end end
end
local function pairRows(db,sessions,opts,checkpoint)
    local h,root=opened(db,checkpoint); local verify=frozen({db,root,sessions,opts})
    local a=V.Build(db,sessions,opts,400)
    local job=finish(V.NewBuildJob(h,sessions,opts,400),checkpoint)
    eq(job.status,"complete",job.reason); eq(#job.rows,#a); assert(job.work.maxOperations<=128)
    for n,row in ipairs(a) do
        local other=job.rows[n]
        eq(other.key,row.key); eq(other.priority,row.priority); eq(other.archived,row.archived)
        eq(other.cells[I.Skill],row.cells[I.Skill]); eq(other.skillState.fresh,row.skillState.fresh)
        eq(other.skillState.stale,row.skillState.stale); eq(other.progressionIncomplete,row.progressionIncomplete)
        assert(deepEqual(other.warnings,row.warnings)); assert(deepEqual(other.sortValues,row.sortValues))
    end
    verify(); return a
end
local function menuItem(ui,label)
    ui.attention:fixtureGenerate()
    for _,item in ipairs(ui.attention.radios) do if item.label==label then return item end end
    error("U07 missing Attention choice "..label)
end
local function uiFor(db,flags)
    local env,state=fixtureAPI(); mockWidgets(env)
    for key,value in pairs(flags or {}) do env[key]=value end
    local c=NS.Collectors.New(env,db); local ui=NS.Dashboard.New(env,c); ui:Toggle()
    return ui,env,c,state
end
local function forbidCollection(c)
    local function forbidden() error("U07 filters must not collect") end
    c.Request=forbidden; c.Scan=forbidden; c.Context=forbidden; c.Login=forbidden
end
for _,sample in ipairs({{0,100},{25,100},{100,100},{125,100},{false,100}}) do
    local level,cap=sample[1],sample[2]
    case("U07 real Skill text has no marker "..tostring(level),function()
        for _,knowledge in ipairs({"incomplete","complete","unknown"}) do
            for _,mode in ipairs({"fresh","saved","stale","archived"}) do
                local db,g=dbWith(valuesFor(level,cap,knowledge)); local sessions=sessionsFor(character.guid,g)
                if mode=="saved" then sessions={}
                elseif mode=="stale" then
                    assert(C.Apply(db,character,identity,{skill=C.Observation("error",nil,20,"U07","transient")},20,"fixture"))
                elseif mode=="archived" then assert(C.Archive(db,character.guid,2913,30,"U07")) end
                local verify=frozen({db,sessions})
                local row=V.Build(db,sessions,{archived=mode=="archived"},400)[1]
                local text=level~=false and level.."/"..cap or "?"
                eq(row.cells[I.Skill],text,"Skill model "..mode.."/"..knowledge)
                eq(row.skillState.fresh,mode=="fresh" and level~=false)
                if level==false and mode~="stale" then eq(row.skillState.stale,nil)
                else eq(row.skillState.stale,mode=="stale" and level~=false) end
                local ui,env,c,state=uiFor(db); c.fresh=sessions; ui.options.archived=mode=="archived"; ui:Refresh()
                forbidCollection(c); local uiVerify=frozen({c.db,c.fresh,ui.rows})
                eq(ui.widgets[1].cells[I.Skill].label:GetText(),text,"Skill widget "..mode.."/"..knowledge)
                -- U13 ADAPT U07_SKILL_READ_CHECK BEGIN
--[==========[U13 ORIGINAL BEGIN
                ui:Render(); uiVerify(); verify(); eq(state.reads,0); eq(state.requests,0)
U13 ORIGINAL END]==========]
                local u13Reads=state.reads; ui:Render(); uiVerify(); verify()
                eq(state.reads,u13Reads,"U13 pure Render makes no own-GUID reads"); u13NoAcquisition(state,true)(); eq(state.requests,0)
                -- U13 ADAPT U07_SKILL_READ_CHECK END
            end
        end
    end)
end
for _,sample in ipairs({{0,100,true},{25,100,true},{20,80,true},{100,100,false},
    {125,100,false},{false,100,false},{0,0,false}}) do
    local level,cap,include=sample[1],sample[2],sample[3]
    case("U07 Skill-only membership "..tostring(level).."/"..cap,function(checkpoint)
        for _,knowledge in ipairs({"incomplete","complete","unknown"}) do
            local db,g=dbWith(valuesFor(level,cap,knowledge)); local sessions=sessionsFor(character.guid,g)
            for _,mode in ipairs({"fresh","saved","stale","archived"}) do
                if mode=="saved" then sessions={}
                elseif mode=="stale" then
                    assert(C.Apply(db,character,identity,{skill=C.Observation("error",nil,20,"U07","transient")},20,"fixture"))
                elseif mode=="archived" then assert(C.Archive(db,character.guid,2913,30,"U07")) end
                local opts={attention="Progression",archived=mode=="archived"}
                local rows=pairRows(db,sessions,opts,checkpoint)
                eq(#rows,include and mode~="archived" and 1 or 0,mode.."/"..knowledge.." membership")
                if rows[1] then
                    eq(rows[1].skill.skillModifier,9999); eq(rows[1].skillState.fresh,mode=="fresh")
                    eq(rows[1].skillState.stale,mode=="stale")
                end
                eq(#pairRows(db,sessions,{attention="All",archived=mode=="archived"},checkpoint),1)
            end
        end
    end)
end
case("U07 malformed projected Skill rejected by both membership paths without cap inference",function()
    -- Synthetic row-boundary faults exercise private defensive guards, not saved/API validity.
    local db=dbWith(valuesFor(25,100,"incomplete")); local h=opened(db)
    local samples={false,7,"25/100",{}, {skillLevel=0},{maxSkillLevel=100},{skillLevel=25,maxSkillLevel=0}}
    for _,bad in ipairs({-1,.5,math.huge,-math.huge,0/0,"25",false}) do
        samples[#samples+1]={skillLevel=bad,maxSkillLevel=100}
        samples[#samples+1]={skillLevel=25,maxSkillLevel=bad}
    end
    local original=V.Row; local projected
    local verify=frozen(db)
    V.Row=function(...) local row=original(...); row.skill=projected; return row end
    local ok,why=pcall(function()
        local function reject(skill)
            projected=skill
            eq(#V.Build(db,{}, {attention="Progression"},400),0)
            local job=finish(V.NewBuildJob(h,{}, {attention="Progression"},400))
            eq(job.status,"complete",job.reason); eq(#job.rows,0)
        end
        reject(nil); for _,skill in ipairs(samples) do reject(skill) end
    end)
    V.Row=original; assert(ok,why); verify()
end)
case("U07 other indicators combined warning diagnostics and priority stay intact",function()
    for _,mode in ipairs({"fresh","saved","stale","archived"}) do
        local values=valuesFor(100,100,"incomplete"); values.moxie.quantity=601
        values.concentration={id=50001,quantity=900,maxQuantity=1000}
        local db,g=dbWith(values); local sessions=sessionsFor(character.guid,g)
        if mode=="saved" then sessions={}
        elseif mode=="stale" then
            local obs={}; for _,key in ipairs({"moxie","concentration","tool","tree:11"}) do
                obs[key]=C.Observation("error",nil,20,"U07","transient") end
            assert(C.Apply(db,character,identity,obs,20,"fixture"))
        elseif mode=="archived" then assert(C.Archive(db,character.guid,2913,30,"U07")) end
        local verify=frozen({db,sessions}); local row=V.Build(db,sessions,{archived=mode=="archived"},400)[1]
        local prefix=mode=="archived" and "" or mode=="fresh" and "|cffffbb00!|r " or "|cff999999!|r "
        -- U13 ADAPT U07_MOXIE BEGIN
--[==========[U13 ORIGINAL BEGIN
        eq(row.cells[I.Skill],"100/100"); eq(row.cells[I.Moxie],prefix.."601")
U13 ORIGINAL END]==========]
        eq(row.cells[I.Skill],"100/100"); eq(row.cells[I.Moxie],"601")
        -- U13 ADAPT U07_MOXIE END
        eq(row.cells[I.Concentration],"900/1000")
        if mode=="stale" then
            -- A failed tool attempt retains the established unknown-enchant policy,
            -- not a newly confirmed missing enchant inferred from historical gear.
            eq(row.enchantMissing,nil); eq(row.enchantAttention,nil); eq(row.cells[I.Enchant],"?")
        else
            eq(row.enchantMissing,true,mode.." missing enchant")
            eq(row.enchantAttention,mode~="archived" and true or nil,mode.." enchant attention")
        end
        eq(row.priority,mode=="archived" and 3 or mode=="fresh" and 1 or 2)
        eq(row.progression,1); eq(row.progressionIncomplete,true)
        if mode=="archived" then eq(#row.warnings,0) else
            eq(#row.warnings,mode=="stale" and 3 or 4)
            for _,category in ipairs({"Moxie","Concentration","Missing enchant","Progression"}) do
                if mode=="stale" and category=="Missing enchant" then eq(warning(row,category),nil)
                else
                    local w=assert(warning(row,category)); eq(w.fresh,mode=="fresh",mode.."/"..category.." fresh")
                    eq(w.label,(mode=="fresh" and "confirmed " or "last observed ")..category)
                    assert(table.concat(row.tooltip,"\n"):find(w.label,1,true))
                end
            end
            -- U15 ADAPT U07_ATTENTION BEGIN
--[============[U15 ORIGINAL BEGIN
            assert(table.concat(row.cellTooltips[I.Skill],"\n"):find("Attention: "..warning(row,"Progression").label,1,true))
U15 ORIGINAL END]============]
            assert(not table.concat(row.cellTooltips[I.Skill],"\n"):find("Attention:",1,true))
            assert(table.concat(row.tooltip,"\n"):find(warning(row,"Progression").label,1,true))
            -- U15 ADAPT U07_ATTENTION END
        end
        verify()
    end
end)
case("U07 schema paths filters archives default combined priority and numeric sorts agree",function(checkpoint)
    local db=C.Open(nil); local sessions={}
    local specs={{"z-fresh-max",100,"incomplete",true},{"a-saved-below",25,"complete",false},
        {"b-unknown",false,"incomplete",false},{"c-complete",100,"complete",false}}
    for _,s in ipairs(specs) do
        local who={guid=s[1],name="U07 Alt",realm="Test"}; local obs={}; local values=valuesFor(s[2],100,s[3])
        values.tool.enchant.present=true; values.tool.enchant.id=123
        if s[1]=="c-complete" then values.moxie.quantity=601; values.concentration={id=50001,quantity=900,maxQuantity=1000}
            values.tool.enchant.present=false; values.tool.enchant.id=0 end
        for key,value in pairs(values) do obs[key]=C.Observation("observed",value,10,"U07") end
        local g=assert(C.Apply(db,who,identity,obs,10,"fixture"))
        if s[4] then sessions[s[1]..":2913"]=sessionsFor(s[1],g)[s[1]..":2913"] end
    end
    -- A second profession and an archive enforce combined identity and archived policy.
    local who={guid="a-saved-below",name="U07 Alt",realm="Test"}; local id=C.Copy(identity)
    id.skillLineID=2906; id.profession=4; id.name="Alchemy"
    assert(C.Apply(db,who,id,{skill=C.Observation("observed",{skillLevel=20,maxSkillLevel=80,skillModifier=0},10,"U07")},10,"fixture"))
    assert(C.Archive(db,"a-saved-below",2906,20,"U07"))
    local rows=pairRows(db,sessions,{},checkpoint)
    eq(table.concat({rows[1].guid,rows[2].guid,rows[3].guid,rows[4].guid},","),
        "z-fresh-max,a-saved-below,b-unknown,c-complete","default combined Knowledge attention remains")
    eq(rows[1].priority,1); eq(rows[2].priority,2); eq(rows[3].priority,2); eq(rows[4].priority,2)
    for _,category in ipairs({"All","Progression","Moxie","Concentration","Missing enchant"}) do
        for _,archived in ipairs({false,true}) do
            local opts={attention=category,archived=archived,character="U07",profession="Inscription",professionFamily=13}
            rows=pairRows(db,sessions,opts,checkpoint)
            eq(#rows,archived and 0 or category=="All" and 4 or 1)
            if rows[1] and category~="All" then eq(rows[1].guid,category=="Progression" and "a-saved-below" or "c-complete") end
        end
    end
    eq(#pairRows(db,sessions,{archived=true},checkpoint),1)
    eq(#pairRows(db,sessions,{archived=true,attention="Progression"},checkpoint),0)
    for _,opts in ipairs({{sort="progression"},{sortColumn=I.Skill},{sortColumn=I.Skill,sortDescending=true}}) do
        rows=pairRows(db,sessions,opts,checkpoint); eq(rows[#rows].guid,"b-unknown","unknown Skill sorts last")
    end
end)
case("U07 generated exact labels stable internal selector default text and no writes",function()
    local ui,env,c,state=uiFor(dbWith(valuesFor(25,100,"complete")))
    local verify=frozen({c.db,c.fresh}); forbidCollection(c)
    local labels={"All","Concentration","Moxie","Missing enchant","Skill below max"}
    eq(#ui.attention.radios,5); eq(ui.attention.width,176); eq(ui.attention.defaultText,"Attention: All")
    for n,item in ipairs(ui.attention.radios) do eq(item.label,labels[n]); assert(item.label~="Progression") end
    local item=menuItem(ui,"Skill below max"); eq(item.data,"Progression"); eq(item.isSelected(item.data),false)
    item:Click(); eq(ui.options.attention,"Progression"); eq(ui.attention.defaultText,"Attention: Skill below max")
    eq(ui.attention.selectedText,"Skill below max"); eq(menuItem(ui,"Skill below max").isSelected("Progression"),true)
    eq(#ui.rows,1); eq(ui.rows[1].cells[I.Skill],"25/100")
    menuItem(ui,"All"):Click(); eq(ui.options.attention,"All"); eq(ui.attention.defaultText,"Attention: All")
    -- U13 ADAPT U07_MENU_READ_CHECK BEGIN
--[==========[U13 ORIGINAL BEGIN
    verify(); eq(state.reads,0); eq(state.requests,0); eq(#state.timers,0)
U13 ORIGINAL END]==========]
    verify(); u13NoAcquisition(state,true)(); eq(state.requests,0); eq(#state.timers,0)
    -- U13 ADAPT U07_MENU_READ_CHECK END
end)
case("U07 Skill menu failure fallback invalidates old callback and preserves saved graph",function()
    for _,failure in ipairs({"radio","text"}) do
        local ui,env,c,state=uiFor(dbWith(valuesFor(25,100,"complete")))
        local verify=frozen({c.db,c.fresh}); forbidCollection(c)
        local item=menuItem(ui,"Skill below max"); item:Click(); eq(ui.options.attention,"Progression")
        if failure=="radio" then env.fixtureRadioError=true; ui.attention:fixtureGenerate()
        else ui.attention.SetDefaultText=function() error("U07 text fault") end; item.onSelect(item.data) end
        eq(ui.attentionMenu.available,false); eq(ui.options.attention,"All"); eq(ui.attention.kind,"Frame")
        item.onSelect(item.data); eq(ui.options.attention,"All"); eq(item.isSelected(item.data),false)
        -- U13 ADAPT U07_FALLBACK_READ_CHECK BEGIN
--[==========[U13 ORIGINAL BEGIN
        eq(#ui.rows,1); verify(); eq(state.reads,0); eq(state.requests,0)
U13 ORIGINAL END]==========]
        eq(#ui.rows,1); verify(); u13NoAcquisition(state,true)(); eq(state.requests,0)
        -- U13 ADAPT U07_FALLBACK_READ_CHECK END
    end
end)
case("U07 populated Skill-filter changes retain bars and obsolete callbacks cannot publish",function(checkpoint)
    local ui,env,state,cmd=redrawFixture(checkpoint); local c=cmd.collector
    -- U13 U07_POPULATED_SNAPSHOT BEGIN
    local u13VerifyReads=u13NoAcquisition(state)
    -- U13 U07_POPULATED_SNAPSHOT END
    local rows=ui.rows; local text=ui.widgets[1].cells[I.Skill].label:GetText(); local value=ui.widgets[1].cells[I.Skill].bar.value
    local verify=frozen({env.CraftArmyDB,c.fresh,rows}); local reads,requests=state.reads,state.requests; forbidCollection(c)
    menuItem(ui,"Skill below max"):Click(); eq(ui.options.attention,"Progression")
    eq(ui.retained,true); eq(ui.rows,rows); eq(ui.widgets[1].cells[I.Skill].label:GetText(),text)
    eq(ui.widgets[1].cells[I.Skill].bar.value,value); eq(ui:ActionsReady(),false)
    local old=ui.buildJob; local stale=ui.buildDriver.scripts.OnUpdate
    menuItem(ui,"All"):Click(); local current=ui.buildJob; assert(current~=old); eq(old.status,"cancelled")
    stale(); eq(ui.buildJob,current); eq(ui.rows,rows)
    redrawPump(ui,checkpoint); eq(#ui.rows,8); eq(ui.retained,false)
    menuItem(ui,"Skill below max"):Click(); redrawPump(ui,checkpoint)
    for _,row in ipairs(ui.rows) do assert(row.skill and row.skill.skillLevel<row.skill.maxSkillLevel) end
    -- U13 ADAPT U07_POPULATED_READ_CHECK BEGIN
--[==========[U13 ORIGINAL BEGIN
    verify(); eq(state.reads,reads); eq(state.requests,requests)
U13 ORIGINAL END]==========]
    verify(); u13VerifyReads(); eq(state.requests,requests)
    -- U13 ADAPT U07_POPULATED_READ_CHECK END
end)
case("U07 Skill filtering keeps failed hidden and unknown-combat retention safety",function(checkpoint)
    for _,mode in ipairs({"failed","hidden","unknown-combat"}) do
        local ui,env,state,cmd=redrawFixture(checkpoint); local rows=ui.rows; local c=cmd.collector
        -- U13 U07_RETAINED_SNAPSHOT BEGIN
        local u13VerifyReads=u13NoAcquisition(state)
        -- U13 U07_RETAINED_SNAPSHOT END
        local verify=frozen({env.CraftArmyDB,c.fresh,rows}); local reads,requests=state.reads,state.requests; forbidCollection(c)
        local original=V.NewBuildJob
        if mode=="failed" then V.NewBuildJob=function() error("U07 build fault") end
        elseif mode=="unknown-combat" then env.InCombatLockdown=function() error("U07 combat unknown") end end
        local ok,why=pcall(function()
            menuItem(ui,"Skill below max"):Click(); eq(ui.rows,rows); eq(ui:ActionsReady(),false)
            if mode=="failed" then eq(ui.buildJob,nil); eq(ui.retained,true)
            else
                local old=ui.buildJob; local stale=ui.buildDriver.scripts.OnUpdate
                if mode=="hidden" then ui.frame:Hide() end
                stale(); eq(ui.rows,rows)
                if mode=="hidden" then eq(ui.buildJob,nil); eq(old.status,"cancelled") end
            end
        end)
        V.NewBuildJob=original; env.InCombatLockdown=function() return false end; assert(ok,mode..": "..tostring(why))
        ui.frame:Show(); ui:Refresh(); redrawPump(ui,checkpoint); eq(ui.retained,false)
        for _,row in ipairs(ui.rows) do assert(row.skill.skillLevel<row.skill.maxSkillLevel) end
        -- U13 ADAPT U07_RETAINED_READ_CHECK BEGIN
--[==========[U13 ORIGINAL BEGIN
        verify(); eq(state.reads,reads); eq(state.requests,requests)
U13 ORIGINAL END]==========]
        verify(); u13VerifyReads(); eq(state.requests,requests)
        -- U13 ADAPT U07_RETAINED_READ_CHECK END
    end
end)
-- U07 GROUP RUN BEGIN
assert(#scenarios==19,"U07 requires all19 original scenarios")
for _,range in ipairs({{1,5},{6,15},{16,17},{18,19}}) do
    local first,last=range[1],range[2]
    registerGroup("U07 grouped scenarios "..first.."-"..last,function(checkpoint,annotate)
        local completed=0
        for index=first,last do
            local scenario=scenarios[index]
            local label="U07 "..index.."/19 "..scenario.name:sub(1,96)
            if annotate then annotate(label) end
            scenario.fn(checkpoint,annotate)
            completed=completed+1
            if index<last then pause(checkpoint,label) end
        end
        eq(completed,last-first+1)
        if annotate then annotate("U07 scenarios "..first.."-"..last.." complete: "..completed.." workloads") end
    end)
end
-- U07 GROUP RUN END
end
-- U07 END
-- S01 END
end

function Tests.Run(cases)
    local runner=Tests.NewRunner(cases)
    while runner.status=="running" do runner:Step() end
    if not runner.completed then
        runner.lines[#runner.lines+1]="INCOMPLETE: "..(runner.reason or "runner stopped")
    end
    return runner
end
