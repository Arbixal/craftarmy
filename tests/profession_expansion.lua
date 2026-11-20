-- P01 additional local fixtures only. No client globals/SavedVariables are used.
local NS={}
for _,name in ipairs({"Core","Storage","Data","Knowledge","Collectors","KnowledgeCheck","Details","ViewModel","Dashboard","SelfTests","Commands"}) do
    assert(loadfile("CraftArmy/"..name..".lua"))("CraftArmy",NS)
end
local C,D,S,V=NS.Core,NS.Data,NS.Storage,NS.ViewModel
local checks,passed,failed=0,0,0
local function check(ok,why) checks=checks+1; assert(ok,why or "assertion failed") end
local function eq(a,b,why) check(a==b,(why or "equality")..": "..tostring(a).." ~= "..tostring(b)) end
local function case(name,fn)
    local ok,why=pcall(fn)
    if ok then passed=passed+1; print("PASS P01 "..name)
    else failed=failed+1; print("FAIL P01 "..name..": "..tostring(why)) end
end
local specs={{2912,182,4},{2916,186,6},{2917,393,11},{2908,185,5},{2911,356,10}}
local function identity(spec)
    return {skillLineID=spec[1],parentID=spec[2],profession=spec[3],expansionID=11}
end
local function unchanged(root)
    local saved={}
    local function visit(t)
        if type(t)~="table" or saved[t] then return end
        local r={meta=getmetatable(t),entries={}}; saved[t]=r
        for k,v in next,t do r.entries[k]=v; visit(k); visit(v) end
    end
    visit(root)
    return function()
        for t,r in pairs(saved) do
            eq(getmetatable(t),r.meta,"metatable unchanged")
            for k,v in next,r.entries do eq(rawget(t,k),v,"edge unchanged") end
            for k in next,t do check(r.entries[k]~=nil,"no added edge") end
        end
    end
end
local function api(spec)
    local i=identity(spec)
    local s={at=100,slots=spec[3]==5 and {27,26} or spec[3]==10 and {28,29,30} or {25,23,24},
        reads={},staged=false,loading=false,link="item:90023:8033:0:0",itemID=90023}
    s.info={professionID=i.skillLineID,parentProfessionID=i.parentID,profession=i.profession,
        isPrimaryProfession=spec[3]~=5 and spec[3]~=10,skillLevel=1,maxSkillLevel=100,skillModifier=0,
        sourceCounter=1,professionName="Fixture profession",expansionName="Midnight"}
    s.parents={[1]=182,[2]=186,[4]=356,[5]=185}
    if spec[3]==11 then s.parents[2]=393 end
    s.roster={1,2,nil,4,5}
    local e={C_TradeSkillUI={},C_Item={},C_ProfSpecs={},C_Traits={},C_CurrencyInfo={}}
    e.GetServerTime=function() return s.at end
    e.GetBuildInfo=function() return "fixture","fixture","date",120105 end
    e.GetLocale=function() return "fixture" end
    e.UnitGUID=function() return "PRIVATE-GUID" end
    e.UnitName=function() return "PRIVATE-NAME" end
    e.GetRealmName=function() return "PRIVATE-REALM" end
    e.InCombatLockdown=function() return s.combat==true end
    e.ProfessionsFrame={IsShown=function() return s.shown~=false end}
    e.GetProfessions=function() return unpack(s.roster,1,5) end
    e.GetProfessionInfo=function(index) return "Fixture",0,0,0,0,0,s.parents[index] end
    local t=e.C_TradeSkillUI
    for _,key in ipairs({"IsTradeSkillLinked","IsTradeSkillGuild","IsTradeSkillGuildMember","IsNPCCrafting","IsDataSourceChanging"}) do
        local k=key; t[k]=function() return s[k]==true end
    end
    t.IsTradeSkillReady=function() return s.ready~=false end
    t.GetChildProfessionInfo=function() return s.info end
    t.GetBaseProfessionInfo=function() return {professionID=s.base or i.parentID} end
    t.GetProfessionSlots=function() return s.slots end
    t.GetConcentrationCurrencyID=function() s.concReads=(s.concReads or 0)+1; error("N/A concentration API called") end
    t.GetItemCraftedQualityByItemInfo=function() return 3 end
    t.GetItemCraftedQualityInfo=function() return {quality=3,iconSmall="fixture"} end
    e.ItemLocation={CreateFromEquipmentSlot=function(_,slot) s.reads[#s.reads+1]=slot; return {slot=slot} end}
    local item=e.C_Item
    item.DoesItemExist=function() return s.exists~=false end
    item.GetItemLink=function() return s.link end
    item.GetItemID=function() return s.itemID end
    item.IsItemDataCached=function() return not s.loading end
    item.GetItemQuality=function() return 3 end
    item.GetItemIcon=function() return 123 end
    item.GetItemInfo=function(link) return "fixture",link,3,1,1,"","",1,"",123,0,0,0,0,11 end
    item.GetItemStats=function(link)
        if s.statsHook then return s.statsHook(link) end
        return {ITEM_MOD_DEFTNESS_SHORT=link==s.link and 25 or 20}
    end
    item.RequestLoadItemData=function() s.requests=(s.requests or 0)+1 end
    e.C_TooltipInfo={GetInventoryItem=function(_,slot) check(slot~=1,"no Head reads"); return {lines={}} end}
    e.C_Timer={After=function(_,fn) s.timer=fn end}
    local p,tr=e.C_ProfSpecs,e.C_Traits
    p.GetConfigIDForSkillLine=function() s.configReads=(s.configReads or 0)+1; return 77 end
    p.GetCurrencyInfoForSkillLine=function() s.kpReads=(s.kpReads or 0)+1; return {numAvailable=7} end
    p.GetSpecTabIDsForSkillLine=function() s.graphReads=(s.graphReads or 0)+1; return {100} end
    p.GetTabInfo=function() return {name="Fixture tree"} end
    p.GetRootPathForTab=function() return 101 end
    p.GetChildrenForPath=function() return {} end
    p.GetUnlockEntryForPath=function() return 201 end
    p.GetSpendEntryForPath=function() return 202 end
    p.GetSpendCurrencyForPath=function() return 900 end
    tr.ConfigHasStagedChanges=function() return s.staged end
    tr.GetTreeCurrencyInfo=function() return {{traitCurrencyID=900,quantity=7,spent=0}} end
    tr.GetNodeInfo=function() return {ID=101,type=1,flags=0,currentRank=0,activeRank=0,ranksPurchased=0,
        ranksIncreased=0,maxRanks=10,totalMaxRanks=10,isAvailable=false,entryIDs={201,202},
        entryIDsWithCommittedRanks={},entryIDToRanksIncreased={}} end
    tr.GetEntryInfo=function(_,id) return {type=1,maxRanks=id==201 and 0 or 10,definitionID=id+100,entryCost={}} end
    tr.GetNodeCost=function() return {{ID=900,amount=1}} end
    e.C_CurrencyInfo.GetCurrencyInfo=function(id)
        s.currencyReads=(s.currencyReads or 0)+1
        return {name="Candidate|\nname",quantity=650,maxQuantity=nil}
    end
    e.ITEM_MOD_DEFTNESS_SHORT="Localized|\nlabel"
    return e,s
end
local function drain(job)
    while job.status=="running" do job:Step(); check(job.steps<=10000,"bounded job") end
    return job
end
local function scan(spec,schema)
    local e,s=api(spec); local db=schema==2 and S.New() or {schema=1,characters={}}
    local r=NS.Collectors.New(e,db); check(r:Scan(),r.reason)
    local g=schema==2 and S.Active(db,"PRIVATE-GUID",spec[1]) or db.characters["PRIVATE-GUID"].professions[spec[1]].active
    return e,s,r,g,db
end
case("registry and immutable exact capabilities",function()
    eq(type(D.Capabilities),"function")
    eq(type(D.GatheringMoxieCandidate),"function")
    local count=0
    for _ in pairs(D.families) do count=count+1 end; eq(count,13)
    for n,spec in ipairs(specs) do
        local i=identity(spec); local cap=D.Capabilities(i); check(cap)
        eq(cap.primary,n<=3); eq(cap.concentration,false)
        -- P02 ADAPT CAP_MODES BEGIN
--[=============[P02 ORIGINAL BEGIN
        eq(cap.knowledgeMode,n<=3 and "pending" or "not_applicable")
        eq(cap.moxieMode,"pending"); eq(cap.enchantAttentionMode,"pending")
P02 ORIGINAL END]=============]
        eq(cap.knowledgeMode,n<=3 and "enabled" or "not_applicable")
        -- P03 ADAPT CAP_MODES BEGIN
--[==============[P03 ORIGINAL BEGIN
        eq(cap.moxieMode,n<=3 and "enabled" or "pending"); eq(cap.enchantAttentionMode,"pending")
P03 ORIGINAL END]==============]
        -- P04 ADAPT CAP_MODES BEGIN
--[===============[P04 ORIGINAL BEGIN
        eq(cap.moxieMode,n<=3 and "enabled" or "not_applicable"); eq(cap.enchantAttentionMode,n<=3 and "enabled" or "pending")
P04 ORIGINAL END]===============]
        eq(cap.moxieMode,n<=3 and "enabled" or "not_applicable"); eq(cap.enchantAttentionMode,n<=4 and "enabled" or "pending")
        -- P04 ADAPT CAP_MODES END
        -- P03 ADAPT CAP_MODES END
        -- P02 ADAPT CAP_MODES END
        eq(cap.roles.accessory1,n~=5); eq(cap.roles.accessory2,n<=3); eq(cap.roles.tool,true)
        check(cap.slotRoles[29]==nil and cap.slotRoles[30]==nil)
        cap.roles.tool=false; cap.slotRoles[28]="bad"; cap.primary="bad"
        check(D.Capabilities(i).roles.tool); check(D.Capabilities(i).primary~="bad")
        for _,key in ipairs({"skillLineID","parentID","profession","expansionID"}) do
            local bad=C.Copy(i); bad[key]=999; eq(D.Capabilities(bad),nil); eq(D.GatheringMoxieCandidate(bad),nil)
        end
        -- P02 ADAPT ACTIVE_MAPS BEGIN
--[=============[P02 ORIGINAL BEGIN
        eq(D.moxie[i.skillLineID],nil); eq(C.NativeKnowledgeCurrency(i),nil)
P02 ORIGINAL END]=============]
        if n<=3 then
            eq(D.moxie[i.skillLineID].id,({3260,3264,3265})[n]); eq(C.NativeKnowledgeCurrency(i),({3778,3784,3889})[n])
        else eq(D.moxie[i.skillLineID],nil); eq(C.NativeKnowledgeCurrency(i),nil) end
        -- P02 ADAPT ACTIVE_MAPS END
        local candidate=D.GatheringMoxieCandidate(i)
        if n<=3 then
            eq(candidate.id,({3260,3264,3265})[n]); check(candidate.provenance)
            candidate.id=0; check(D.GatheringMoxieCandidate(i).id>0)
        else eq(candidate,nil) end
        local resolved=D.Identity({professionID=spec[1],parentProfessionID=spec[2],profession=spec[3]})
        eq(resolved.skillLineID,spec[1])
    end
    for id,m in pairs(D.expansions) do
        -- P02 ADAPT CRAFTING_LOOP BEGIN
--[=============[P02 ORIGINAL BEGIN
        if D.moxie[id] then
P02 ORIGINAL END]=============]
        if D.moxie[id] and id~=2912 and id~=2916 and id~=2917 then
        -- P02 ADAPT CRAFTING_LOOP END
            local c=D.Capabilities({skillLineID=id,parentID=m.parentID,profession=m.profession,expansionID=11})
            eq(c.primary,true); eq(c.concentration,true); eq(c.knowledgeMode,"enabled")
            eq(c.moxieMode,"enabled"); eq(c.enchantAttentionMode,"enabled")
            for slot=20,25 do eq(c.slotRoles[slot],D.slotRoles[slot]) end
        end
    end
    -- P02 ADAPT STAT_KEYS BEGIN
--[=============[P02 ORIGINAL BEGIN
    eq(D.statNames.ITEM_MOD_DEFTNESS_SHORT,nil); eq(D.statNames.ITEM_MOD_FINESSE_SHORT,nil); eq(D.statNames.ITEM_MOD_PERCEPTION_SHORT,nil)
P02 ORIGINAL END]=============]
    -- P03 ADAPT STAT_KEYS BEGIN
--[==============[P03 ORIGINAL BEGIN
    eq(D.statNames.ITEM_MOD_DEFTNESS_SHORT,nil); eq(D.statNames.ITEM_MOD_FINESSE_SHORT,D.statCategories.Finesse); eq(D.statNames.ITEM_MOD_PERCEPTION_SHORT,D.statCategories.Perception)
P03 ORIGINAL END]==============]
    eq(D.statNames.ITEM_MOD_DEFTNESS_SHORT,D.statCategories.Deftness); eq(D.statNames.ITEM_MOD_FINESSE_SHORT,D.statCategories.Finesse); eq(D.statNames.ITEM_MOD_PERCEPTION_SHORT,D.statCategories.Perception)
    -- P03 ADAPT STAT_KEYS END
    -- P02 ADAPT STAT_KEYS END
end)
case("roster holes, presence and all context safety gates",function()
    for _,spec in ipairs(specs) do
        local e,s=api(spec); local r=NS.Collectors.New(e,{schema=1,characters={}})
        check(r:Context()); r:Roster(); eq(r.roster.complete,false)
        check(r.roster.entries[356] and r.roster.entries[185]); eq(r.roster.entries[794],nil)
        for _,key in ipairs({"IsTradeSkillLinked","IsTradeSkillGuild","IsTradeSkillGuildMember","IsNPCCrafting","IsDataSourceChanging"}) do
            s[key]=true; eq(r:Context(),nil,key); s[key]=false
        end
        s.combat=true; eq(r:Context(),nil); s.combat=false
        s.shown=false; eq(r:Context(),nil); s.shown=true
        s.ready=false; eq(r:Context(),nil); s.ready=true
        s.info.isPrimaryProfession=not s.info.isPrimaryProfession; eq(r:Context(),nil); s.info.isPrimaryProfession=not s.info.isPrimaryProfession
        for _,cap in ipairs({0,-1}) do s.info.maxSkillLevel=cap; eq(r:Context(),nil) end
        s.info.maxSkillLevel=100; s.info.skillLevel=101; eq(r:Context(),nil); s.info.skillLevel=1
        s.base=999; eq(r:Context(),nil); s.base=nil
        s.parents={}; check(not r:Scan()); eq(next(r.db.characters),nil,"no orphan row")
        e.GetProfessions=function() error("private") end; eq(r:Context(),nil)
    end
    local e,s=api(specs[5]); s.roster={[4]=4}; local r=NS.Collectors.New(e,nil)
    check(r:Context(),"fourth result survives holes")
    e,s=api(specs[4]); s.roster={[5]=5}; check(NS.Collectors.New(e,nil):Context(),"fifth survives holes")
end)
case("guarded schema1/schema2 collection N/A skips and pending retention",function()
    for _,schema in ipairs({1,2}) do for n,spec in ipairs(specs) do
        local e,s,r,g,db=scan(spec,schema)
        eq(g.fields.concentration.attempt.status,"not_applicable"); eq(g.fields.concentration.last.value,nil)
        -- P02 ADAPT SCAN_FIELDS BEGIN
--[=============[P02 ORIGINAL BEGIN
        eq(s.concReads,nil); eq(s.currencyReads,nil); eq(s.graphReads,nil)
        eq(g.fields.moxie.attempt.status,"unsupported"); eq(g.fields.tool.last.value.toolStat,nil)
        eq(g.fields.unspent.attempt.status,n<=3 and "unsupported" or "not_applicable")
        eq(g.fields.knowledgeIndex.attempt.status,n<=3 and "unsupported" or "not_applicable")
P02 ORIGINAL END]=============]
        eq(s.concReads,nil)
        eq(s.currencyReads,n<=3 and 1 or nil); eq(s.graphReads,n<=3 and 1 or nil)
        -- P03 ADAPT SCAN_FIELDS BEGIN
--[==============[P03 ORIGINAL BEGIN
        eq(g.fields.moxie.attempt.status,n<=3 and "observed" or "unsupported"); eq(g.fields.tool.last.value.toolStat,nil)
P03 ORIGINAL END]==============]
        eq(g.fields.moxie.attempt.status,n<=3 and "observed" or "not_applicable")
        if n>=4 then eq(g.fields.moxie.last.status,"not_applicable"); eq(g.fields.moxie.last.value,nil) end
        eq(g.fields.tool.last.value.toolStat.value,"Deftness")
        -- P03 ADAPT SCAN_FIELDS END
        eq(g.fields.unspent.attempt.status,n<=3 and "observed" or "not_applicable")
        eq(g.fields.knowledgeIndex.attempt.status,n<=3 and "observed" or "not_applicable")
        if n<=3 then check(not g.fields["tree:100"].last or g.fields["tree:100"].last.value==nil,"wrong currency remains nonnumeric") end
        -- P02 ADAPT SCAN_FIELDS END
        if n>=4 then eq(s.configReads,nil); eq(s.kpReads,nil) end
        if n==5 then for _,slot in ipairs(s.reads) do eq(slot,28) end end
        if n>=4 then eq(g.fields.accessory2.attempt.status,"not_applicable") end
        if n==5 then eq(g.fields.accessory1.attempt.status,"not_applicable") end
        s.slots={}; check(r:Scan()); g=schema==2 and S.Active(db,"PRIVATE-GUID",spec[1]) or db.characters["PRIVATE-GUID"].professions[spec[1]].active
        eq(g.fields.tool.attempt.status,"unknown") -- No returned instance proves neither empty nor N/A.
        local old=g.fields.skill.last.observedAt; s.info.maxSkillLevel=0; s.at=200
        check(not r:Scan()); eq(g.fields.skill.last.observedAt,old,"failure does not overwrite")
        s.info.maxSkillLevel=100
        local obs={moxie=C.Observation("observed",{id=999,quantity=700},90,"history"),unspent=C.Observation("observed",9,90,"history")}
        if n<=3 then obs.knowledgeIndex=C.Observation("observed",{{id=100,name="history",root=101}},90,"history") end
        check(S.Apply(db,{guid="PRIVATE-GUID",name="Fixture",realm="Fixture"},identity(spec),obs,90,"fixture"))
        -- P02 ADAPT FAILED_READS BEGIN
--[=============[P02 ORIGINAL BEGIN
P02 ORIGINAL END]=============]
        if n<=3 then
            e.C_CurrencyInfo.GetCurrencyInfo=function() return nil end
            e.C_ProfSpecs.GetCurrencyInfoForSkillLine=function() return nil end
        end
        -- P02 ADAPT FAILED_READS END
        check(r:Scan()); g=schema==2 and S.Active(db,"PRIVATE-GUID",spec[1]) or db.characters["PRIVATE-GUID"].professions[spec[1]].active
        -- P03 ADAPT MOXIE_HISTORY BEGIN
--[==============[P03 ORIGINAL BEGIN
        eq(g.fields.moxie.last.value.quantity,700); eq(g.fields.moxie.last.observedAt,90)
P03 ORIGINAL END]==============]
        if n<=3 then eq(g.fields.moxie.last.value.quantity,700); eq(g.fields.moxie.last.observedAt,90)
        else eq(g.fields.moxie.last.status,"not_applicable"); eq(g.fields.moxie.last.value,nil); eq(g.fields.moxie.last.observedAt,s.at) end
        -- P03 ADAPT MOXIE_HISTORY END
        if n<=3 then eq(g.fields.unspent.last.value,9); eq(g.fields.knowledgeIndex.last.observedAt,90) end
        e.GetProfessions=function() return nil end; check(not r:Scan())
        check(schema==2 and S.Active(db,"PRIVATE-GUID",spec[1]) or db.characters["PRIVATE-GUID"].professions[spec[1]].active,"never auto retire")
    end end
end)
case("N/A masks history only in presentation; skill filter and typed sort keys",function()
    for n=4,5 do
        local spec=specs[n]; local i=identity(spec); local db={schema=1,characters={}}
        local char={guid="row",name="Fixture",realm="Fixture"}
        local obs={skill=C.Observation("observed",{skillLevel=1,maxSkillLevel=100,skillModifier=0},10,"fixture"),
            concentration=C.Observation("observed",{id=999,quantity=1000,maxQuantity=1000,rechargingCycleDurationMS=1000,rechargingAmountPerCycle=1},10,"history"),
            unspent=C.Observation("observed",99,10,"history"),
            accessory2=C.Observation("observed",{exists=true,slot=22,role="accessory2",metadataReady=true,link="item:123:0:0",itemID=123,rarity=3,rank=3,icon=123},10,"history")}
        local g=assert(C.Apply(db,char,i,obs,10,"fixture")); local verify=unchanged(db)
        local row=V.Build(db,{}, {},100)[1]; local I=V.index
        eq(row.cells[I.Concentration],"—"); eq(row.cells[I.Knowledge],"—"); eq(row.cells[I.Unspent],"—")
        eq(row.gear.accessory2.text,"—"); eq(row.gear.accessory2.link,nil); eq(row.gear.accessory2.empty,nil)
        eq(row.sortValues[I.Concentration],nil); eq(row.sortValues[I.Unspent],nil); eq(row.sortValues[I.Accessory2],nil)
        eq(#row.trees,0); eq(row.concentrationValue,nil); eq(row.unspent,nil)
        eq(table.concat(V.ConcentrationTooltip(row,100)),"Not applicable.")
        eq(#V.Build(db,{}, {attention="Concentration"},100),0)
        eq(#V.Build(db,{}, {attention="Missing enchant"},100),0)
        eq(#V.Build(db,{}, {attention="Progression"},100),1)
        check(table.concat(row.tooltip,"\n"):find("history",1,true),"underlying provenance retained")
        eq(table.concat(row.cellTooltips[I.Knowledge]),"Not applicable."); verify()
    end
end)
case("candidate read-only gathering report and bounded separate completeness",function()
    for n=1,3 do
        -- P02 ADAPT CAPTURE_FREEZE BEGIN
--[=============[P02 ORIGINAL BEGIN
        local e,s=api(specs[n]); local r=NS.Collectors.New(e,{private="PRIVATE-DB"}); local verify=unchanged(r)
P02 ORIGINAL END]=============]
        local e,s=api(specs[n]); local r=NS.Collectors.New(e,{private="PRIVATE-DB"}); local verify=unchanged(r)
        local registry=unchanged({D,C,NS.Collectors})
        -- P02 ADAPT CAPTURE_FREEZE END
        local report=drain(NS.KnowledgeCheck.NewProfessionCaptureJob(e,r)).report
        check(report.gatheringEvidence,"gathering profile")
        local g=report.gatheringEvidence
        eq(g.skill.skillLevel.value,1); eq(g.unspent.value,7); eq(g.moxie.id,({3260,3264,3265})[n])
        eq(g.moxie.quantity.value,650); eq(g.moxie.maxQuantity.status,"nil")
        eq(g.tool.total.items[1].value,25); eq(g.tool.neutral.items[1].value,20)
        eq(g.complete,true); eq(report.captureComplete,true)
        local text,summary=NS.KnowledgeCheck.Format(report)
        check(text:find("gatheringEvidence",1,true)); check(text:find("ITEM_MOD_DEFTNESS_SHORT",1,true))
        for _,private in ipairs({"PRIVATE-GUID","PRIVATE-NAME","PRIVATE-REALM","PRIVATE-DB","item:90023","private exception"}) do check(not text:find(private,1,true),"no exported private data") end
        check(#text<=262144); check(summary.captureComplete); verify()
        -- P02 ADAPT CAPTURE_MAPS BEGIN
--[=============[P02 ORIGINAL BEGIN
        eq(D.moxie[specs[n][1]],nil); eq(C.NativeKnowledgeCurrency(identity(specs[n])),nil)
P02 ORIGINAL END]=============]
        eq(D.moxie[specs[n][1]].id,({3260,3264,3265})[n]); eq(C.NativeKnowledgeCurrency(identity(specs[n])),({3778,3784,3889})[n]); registry()
        -- P02 ADAPT CAPTURE_MAPS END
    end
end)
case("gathering malformed/changed/staged/error evidence and cancellation",function()
    local modes={"nil","error","oversize","key","metatable","infinite","changed","loading","staged","runtime"}
    for _,mode in ipairs(modes) do
        local e,s=api(specs[1]); local r=NS.Collectors.New(e,{private=true})
        if mode=="staged" then s.staged=true
        elseif mode=="loading" then s.loading=true
        elseif mode=="runtime" then s.statsHook=function() r.revision=r.revision+1; return {} end
        else s.statsHook=function()
            if mode=="nil" then return nil elseif mode=="error" then error("private exception")
            elseif mode=="key" then return {BAD=4} elseif mode=="metatable" then return setmetatable({},{})
            elseif mode=="infinite" then return {ITEM_MOD_DEFTNESS_SHORT=math.huge}
            elseif mode=="changed" then s.link="item:90024:0:0:0"; s.itemID=90024; return {ITEM_MOD_DEFTNESS_SHORT=1}
            else local t={}; for j=1,33 do t["ITEM_MOD_FIXTURE_"..j]=j end; return t end
        end end
        local report=drain(NS.KnowledgeCheck.NewProfessionCaptureJob(e,r)).report
        check(report and report.gatheringEvidence)
        eq(report.gatheringEvidence.complete,false,mode)
        if mode=="runtime" or mode=="staged" then eq(report.captureComplete,false) else eq(report.captureComplete,true,"metadata does not redefine Knowledge completeness") end
        local text=NS.KnowledgeCheck.Format(report); check(not text:find("private exception",1,true))
    end
    local e,s=api(specs[1]); local r=NS.Collectors.New(e,nil)
    local job=NS.KnowledgeCheck.NewProfessionCaptureJob(e,r); job:Step(); job:Cancel("fixture")
    eq(job.worker,nil); eq(job.report,nil); eq(job.status,"incomplete"); job:Step(); eq(job.report,nil)
    for _,spec in ipairs({specs[4],specs[5]}) do
        local env=api(spec); local report=drain(NS.KnowledgeCheck.NewProfessionCaptureJob(env,r)).report
        eq(report.captureComplete,false); eq(report.gatheringEvidence,nil)
    end
end)
case("mixed 46/100/200 character growth, family filters and current grouping",function()
    for _,count in ipairs({46,100,200}) do
        local db=S.New()
        local all={{2913,773,13},{2909,333,9},{2906,171,3},{2907,164,1},{2910,202,8},{2914,755,12},{2915,165,2},{2918,197,7},specs[1],specs[2],specs[3]}
        for n=1,count do
            local char={guid="g"..n,name="Fixture"..n,realm="Fixture"}
            for _,spec in ipairs({all[(n-1)%11+1],all[n%11+1],specs[4],specs[5]}) do
                check(S.Apply(db,char,identity(spec),{skill=C.Observation("observed",{skillLevel=1,maxSkillLevel=100,skillModifier=0},10,"fixture")},10,"fixture"))
            end
        end
        local rows=drain(V.NewBuildJob(db,{}, {currentPlayerGUID="g"..count},100)).rows
        eq(#rows,count*4); for n=1,4 do eq(rows[n].guid,"g"..count) end
        for _,family in ipairs({4,5,6,10,11,13}) do
            local filtered=drain(V.NewBuildJob(db,{}, {professionFamily=family,attention="Progression"},100)).rows
            check(#filtered>0); for _,row in ipairs(filtered) do eq(row.professionFamily,family) end
        end
        print("P01 mixed workload "..count.." characters / "..#rows.." rows complete")
    end
end)
case("Core secondary metadata exact roles and unchanged rejecting predicates",function()
    local function gear(slot,role)
        return {slot=slot,role=role,exists=true,metadataReady=true,itemID=123,link="item:123:0:0",rarity=3,rank=3,
            itemExpansion={status="observed",attemptedAt=10,observedAt=10,source="C_Item.GetItemInfo",value=11}}
    end
    for _,entry in ipairs({{26,"tool"},{27,"accessory1"},{28,"tool"}}) do
        local slot,role=unpack(entry); local value=gear(slot,role)
        check(C.ValidPayload(role,value,"observed"),"verified secondary metadata slot")
        for _,change in ipairs({
            function(v) v.metadataReady=false end,function(v) v.exists=false end,
            function(v) v.itemID=nil end,function(v) v.link=nil end,
            function(v) v.link="item:124:0:0" end,function(v) v.itemID=0 end,
            function(v) v.itemExpansion.value=-1 end,function(v) v.itemExpansion.source="untrusted" end,
            function(v) v.itemExpansion.observedAt=nil end,function(v) v.itemExpansion.extra=true end,
            function(v) v.itemExpansion.status="not_applicable" end,
        }) do local bad=C.Copy(value); change(bad); check(not C.ValidPayload(role,bad,"observed"),"invalid optional metadata rejected") end
        for _,other in ipairs({"tool","accessory1","accessory2"}) do
            if other~=role then local bad=C.Copy(value); bad.role=other; check(not C.ValidPayload(other,bad,"observed"),"wrong named role") end
        end
        for _,excluded in ipairs({1,29,30,33}) do local bad=C.Copy(value); bad.slot=excluded; check(not C.ValidPayload(role,bad,"observed"),"excluded slot") end
        local stat={status="observed",attemptedAt=10,observedAt=10,source="C_Item.GetItemStats:unenchant-link-v1",value="Resourcefulness"}
        value.toolStat=stat; eq(C.ValidPayload(role,value,"observed"),role=="tool","tool-only metadata")
        if role=="tool" then
            -- P02 ADAPT TOOL_CATEGORIES BEGIN
--[=============[P02 ORIGINAL BEGIN
            for _,name in ipairs({"Deftness","Finesse","Perception"}) do stat.value=name; check(not C.ValidPayload(role,value,"observed"),"DFP remains inactive") end
P02 ORIGINAL END]=============]
            -- P03 ADAPT TOOL_CATEGORIES BEGIN
--[==============[P03 ORIGINAL BEGIN
            for _,name in ipairs({"Deftness","Finesse","Perception"}) do stat.value=name; eq(C.ValidPayload(role,value,"observed"),name~="Deftness","only F/P newly valid") end
P03 ORIGINAL END]==============]
            for _,name in ipairs({"Deftness","Finesse","Perception"}) do stat.value=name; check(C.ValidPayload(role,value,"observed"),"DFP valid on Tool") end
            stat.value="P03Unsupported"; check(not C.ValidPayload(role,value,"observed"),"unsupported category rejected")
            -- P03 ADAPT TOOL_CATEGORIES END
            -- P02 ADAPT TOOL_CATEGORIES END
        end
    end
end)
case("secondary absent specialization APIs, excluded slots, source races and async tokens",function()
    for n=4,5 do for _,schema in ipairs({1,2}) do
        local spec=specs[n]; local e,s=api(spec); e.C_ProfSpecs={}; e.C_Traits={}
        local db=schema==2 and S.New() or {schema=1,characters={}}
        local r=NS.Collectors.New(e,db); check(r:Scan(),r.reason)
        local function current() return schema==2 and S.Active(db,"PRIVATE-GUID",spec[1]) or db.characters["PRIVATE-GUID"].professions[spec[1]].active end
        eq(current().fields.unspent.attempt.status,"not_applicable")
        for _,slot in ipairs(s.reads) do check(slot==26 or slot==27 or slot==28,"no excluded reads") end
        local original=e.C_Item.GetItemStats; local token=S.IsHandle(db) and S.Token(db,"PRIVATE-GUID",spec[1]) or current()
        local before=unchanged(schema==2 and current() or db)
        e.C_Item.GetItemStats=function(link) s.info.sourceCounter=s.info.sourceCounter+1; return original(link) end
        check(not r:Scan(),"source race discarded"); before()
        eq(S.IsHandle(db) and S.Token(db,"PRIVATE-GUID",spec[1]) or current(),token)
        e.C_Item.GetItemStats=original
        s.loading=true; check(r:Scan()); check(r.pending[s.itemID],"pending equipped instance")
        s.loading=false; r:ItemResult(s.itemID,true)
        eq(current().fields.tool.attempt.status,"observed"); check(current().fields.tool.last.value.itemExpansion)
        s.loading=true; check(r:Scan()); r:Invalidate("fixture closure"); local frozen=unchanged(current())
        s.loading=false; r:ItemResult(s.itemID,true); frozen()
    end end
    for n=1,5 do
        local e,s=api(specs[n]); s.slots={1,29,30,33}; local r=NS.Collectors.New(e,{schema=1,characters={}})
        check(r:Scan()); eq(#s.reads,0,"unknown/excluded slots never read")
        local g=r.db.characters["PRIVATE-GUID"].professions[specs[n][1]].active
        eq(g.fields.tool.attempt.status,"unknown"); eq(g.fields.slot29,nil)
    end
end)
case("pending indexed trees and independent timestamps survive both storage facades",function()
    local raw={configID=1,stagedStart=false,stagedEnd=false,stable=true,tabsComplete=true,
        tabs={{id=100,name="Historical tree",root=101,coverageComplete=true,paths={
            [101]={children={},childrenComplete=true,unlockEntryID=201,unlock={maxRanks=0},
                costRule="verified-unit-spend",costEvidence="fixture",node={ranksPurchased=2,currentRank=2,ranksIncreased=0,maxRanks=10}}
        }}}}
    local tree=NS.Knowledge.Evaluate(raw).trees[1]; check(tree.complete)
    for _,schema in ipairs({1,2}) do for n=1,3 do
        local e,s=api(specs[n]); local db=schema==2 and S.New() or {schema=1,characters={}}
        local obs={knowledgeIndex=C.Observation("observed",{{id=100,name="Historical tree",root=101}},10,"history"),
            knowledgeRaw=C.Observation("observed",raw,11,"history"),["tree:100"]=C.Observation("observed",tree,12,"history"),
            moxie=C.Observation("observed",{id=999,quantity=23},13,"history"),unspent=C.Observation("observed",9,14,"history")}
        check(S.Apply(db,{guid="PRIVATE-GUID",name="Fixture",realm="Fixture"},identity(specs[n]),obs,15,"fixture"))
        -- P02 ADAPT INDEX_FAILED_READS BEGIN
--[=============[P02 ORIGINAL BEGIN
P02 ORIGINAL END]=============]
        e.C_CurrencyInfo.GetCurrencyInfo=function() return nil end
        e.C_ProfSpecs.GetCurrencyInfoForSkillLine=function() return nil end
        -- P02 ADAPT INDEX_FAILED_READS END
        local r=NS.Collectors.New(e,db); check(r:Scan(),r.reason)
        local g=schema==2 and S.Active(db,"PRIVATE-GUID",specs[n][1]) or db.characters["PRIVATE-GUID"].professions[specs[n][1]].active
        for key,at in pairs({knowledgeIndex=10,knowledgeRaw=11,["tree:100"]=12,moxie=13,unspent=14}) do
            eq(g.fields[key].last.observedAt,at,key.." retained time"); check(g.fields[key].attempt.status~="observed")
        end
        -- P02 ADAPT INDEX_GRAPH BEGIN
--[=============[P02 ORIGINAL BEGIN
        eq(g.fields["tree:100"].last.value.purchased,2); eq(s.graphReads,nil)
P02 ORIGINAL END]=============]
        eq(g.fields["tree:100"].last.value.purchased,2); eq(s.graphReads,1)
        -- P02 ADAPT INDEX_GRAPH END
        local row=V.Row("PRIVATE-GUID",{name="Fixture",realm="Fixture"},specs[n][1],g,r.fresh["PRIVATE-GUID:"..specs[n][1]],100)
        eq(row.trees[1].purchased,2); check(row.trees[1].state.stale)
    end end
end)
-- Small strict widget fake: records method calls/state, not native font/layout behavior.
local function widgets(e)
    local methods={}
    local function new(kind,parent,template)
        return setmetatable({kind=kind,parent=parent,template=template,shown=true,scripts={},style={},points={},width=0,height=14,labelText="",scale=1,lines={}}, {__index=methods})
    end
    function methods:CreateTexture() return new("Texture",self) end
    function methods:CreateFontString() return new("FontString",self) end
    function methods:SetText(v) check(type(v)=="string","text scalar"); self.labelText=v end
    function methods:GetText() return self.labelText end
    function methods:SetScript(k,v) self.scripts[k]=v end
    function methods:SetSize(w,h) self.width=w; self.height=h end
    function methods:SetWidth(w) self.width=w end
    function methods:SetHeight(h) self.height=h end
    function methods:GetWidth() return self.width end
    function methods:GetHeight() return self.height end
    function methods:SetScale(v) self.scale=v end
    function methods:GetScale() return self.scale end
    function methods:GetFrameLevel() return self.level or 1 end
    function methods:SetFrameLevel(v) self.level=v end
    function methods:SetPoint(...) self.points[#self.points+1]={...} end
    function methods:ClearAllPoints() self.points={} end
    function methods:SetAllPoints(v) self.allPoints=v or self.parent end
    function methods:Show() self.shown=true end
    function methods:Hide() self.shown=false end
    function methods:IsShown() return self.shown end
    function methods:SetShown(v) self.shown=v end
    function methods:SetTexture(v) self.texture=v; self.atlas=nil; return true end
    function methods:SetAtlas(v) self.atlas=v end
    function methods:SetFont(...) self.font={...} end
    function methods:GetStatusBarTexture() if not self.textureWidget then self.textureWidget=new("Texture",self) end; return self.textureWidget end
    function methods:SetValue(v)
        self.value=v
        if self.kind=="Slider" and self.scripts.OnValueChanged then self.scripts.OnValueChanged(self,v) end
    end
    function methods:SetMinMaxValues(a,b) self.minimum=a; self.maximum=b end
    function methods:SetThumbTexture(v) self.thumb=new("Texture",self); self.thumb:SetTexture(v) end
    function methods:GetThumbTexture() return self.thumb end
    function methods:GetStringWidth() return #self.labelText*6 end
    function methods:ClearLines() self.lines={}; self.nativeLink=nil end
    function methods:SetHyperlink(link) self.nativeLink=link; self.lines={"Native", "Third-party"} end
    function methods:AddLine(v) self.lines[#self.lines+1]=v end
    function methods:SetDefaultText(v) self.defaultText=v end
    function methods:SetupMenu(fn)
        self.radios={}; local w=self; local root={}
        function root:CreateRadio(label,selected,select,data)
            local r={label=label,data=data,selected=selected,select=select}
            function r:Click() self.select(self.data) end
            w.radios[#w.radios+1]=r
        end
        fn(self,root)
    end
    function methods:SetScrollChild(v) self.scrollChild=v end
    for _,method in ipairs({"SetMovable","EnableMouse","RegisterForDrag","StartMoving","StopMovingOrSizing","EnableMouseWheel",
        "SetAutoFocus","ClearFocus","SetHighlightTexture","SetJustifyH","SetWordWrap","SetStatusBarTexture","SetStatusBarColor",
        "SetColorTexture","SetBackdrop","SetBackdropColor","SetTextColor","SetFrameStrata","SetToplevel","Raise","SetBackdropBorderColor",
        "SetOrientation","SetValueStep","SetObeyStepOnDrag","SetEnabled","SetOwner","SetMultiLine","SetFontObject","SetMaxLetters","SetFocus","HighlightText"}) do
        local key=method; methods[key]=function(self,...) self.style[key]={...} end
    end
    e.UIParent=new("Frame"); e.UIParent:SetSize(1920,1080); e.GameTooltip=new("Tooltip")
    e.CreateFrame=function(kind,_,parent,template)
        local w=new(kind,parent,template)
        if template=="BasicFrameTemplateWithInset" then w.TitleText=new("FontString",w) end
        return w
    end
end
case("N/A real reused widgets, full Shift history and clean normal tooltips",function()
    local e,s=api(specs[5]); widgets(e)
    local db={schema=1,characters={}}; local char={guid="PRIVATE-GUID",name="Fixture",realm="Fixture"}
    local old={slot=22,role="accessory2",exists=true,metadataReady=true,itemID=123,link="item:123:0:0",icon=123,rarity=3,rank=5,
        quality={quality=5,iconSmall="fixture"},enchant={status="observed",present=true,id=8005}}
    local obs={skill=C.Observation("observed",{skillLevel=1,maxSkillLevel=100,skillModifier=0},10,"fixture"),
        accessory2=C.Observation("observed",old,10,"history"),accessory1=C.Observation("observed",C.Copy(old),10,"history"),
        concentration=C.Observation("observed",{id=999,quantity=100,maxQuantity=1000,rechargingCycleDurationMS=1000,rechargingAmountPerCycle=1},10,"history")}
    obs.accessory1.value.slot=21; obs.accessory1.value.role="accessory1"
    check(C.Apply(db,char,{skillLineID=2913,parentID=773,profession=13,expansionID=11},obs,10,"fixture"))
    local r=NS.Collectors.New(e,db); local ui=NS.Dashboard.New(e,r); ui:Toggle()
    local I=V.index; local w=ui.widgets[1]; local cell=w.cells[I.Accessory2]
    check(cell.itemIcon.shown and cell.itemBorder.shown and cell.enchantBadge.shown and cell.qualityIcon.shown)
    check(w.cells[I.Concentration].estimate.shown)
    check(r:Scan()); ui.options.professionFamily=10; ui:Refresh()
    eq(ui.widgets[1],w); eq(cell.label:GetText(),"—"); eq(w.cells[I.Concentration].label:GetText(),"—")
    for _,key in ipairs({"itemIcon","itemBorder","qualityIcon","qualityDigit","qualityFrame","statLetter","statBacking","enchantBadge"}) do eq(cell[key].shown,false,key.." cleared") end
    eq(cell.itemIcon.texture,""); eq(cell.qualityIcon.atlas,nil)
    eq(w.cells[I.Concentration].estimate.shown,false); eq(w.cells[I.Concentration].bar:GetStatusBarTexture().shown,false)
    local before=unchanged(db); local estimate=V.ConcentrationEstimate; local calls=0
    -- Namespace is private to this runner; restore even if the test fails.
    V.ConcentrationEstimate=function(...) calls=calls+1; return estimate(...) end
    local ok,why=pcall(function()
        ui:Render(); eq(calls,0,"N/A render never computes estimate")
        for _,col in ipairs({I.Concentration,I.Knowledge,I.Unspent,I.Accessory1,I.Accessory2}) do
            e.IsShiftKeyDown=function() return false end
            w.cells[col].scripts.OnEnter(w.cells[col]); eq(table.concat(e.GameTooltip.lines),"Not applicable.")
        end
        local tool=w.cells[I.Tool]; tool.scripts.OnEnter(tool)
        eq(e.GameTooltip.nativeLink,s.link); eq(table.concat(e.GameTooltip.lines),"NativeThird-party")
        e.IsShiftKeyDown=function() return true end
        cell.scripts.OnEnter(cell); check(table.concat(e.GameTooltip.lines):find("P01 exact capability registry",1,true))
        ui.options.professionFamily=13; ui:Refresh()
        before()
        -- Mask an older concentration value on a secondary without changing its saved generation.
        local historical=C.Copy(obs); historical.accessory1=nil
        check(C.Apply(db,{guid="history",name="History",realm="Fixture"},identity(specs[5]),historical,10,"fixture"))
        ui.options.character="history"; ui.options.professionFamily=10; ui:Refresh()
        w.cells[I.Concentration].scripts.OnEnter(w.cells[I.Concentration])
        check(table.concat(e.GameTooltip.lines):find("Underlying concentration history: 100/1000",1,true))
        check(not table.concat(e.GameTooltip.lines):find("unchanged recharge rate",1,true),"N/A has no estimate assumptions")
    end)
    V.ConcentrationEstimate=estimate; check(ok,why)
    -- The preexisting DB graph was verified before deliberately adding a distinct owner.
    eq(db.characters[char.guid].professions[2913].active.fields.concentration.last.value.quantity,100)
    eq(#ui.professionDropdown.radios,14); eq(ui.title:GetText(),"CraftArmy — observed profession snapshots")
end)
case("mixed UI scrolling/filter/current grouping remains observation-only",function()
    local e,s=api(specs[4]); widgets(e); local db={schema=1,characters={}}
    for n=1,8 do for _,spec in ipairs({specs[1],specs[4],specs[5]}) do
        check(C.Apply(db,{guid=n==8 and "PRIVATE-GUID" or "g"..n,name="Fixture"..n,realm="Fixture"},identity(spec),
            {skill=C.Observation("observed",{skillLevel=n,maxSkillLevel=100,skillModifier=0},10,"fixture")},10,"fixture"))
    end end
    local verify=unchanged(db); local r=NS.Collectors.New(e,db); local ui=NS.Dashboard.New(e,r); ui:Toggle()
    eq(#ui.rows,24); eq(#ui.widgets,12); eq(ui.rows[1].guid,"PRIVATE-GUID"); eq(ui.widgets[1].cells[V.index.Name].currentDot.shown,true)
    eq(ui.rowRange:GetText(),"Rows 1–12 of 24")
    ui.viewport.scripts.OnMouseWheel(ui.viewport,-1); eq(ui.offset,3); eq(ui.rowRange:GetText(),"Rows 4–15 of 24")
    ui:QueueScroll(12); eq(ui.offset,3); ui.frame.scripts.OnUpdate(ui.frame,.016); eq(ui.offset,12)
    eq(ui.rowRange:GetText(),"Rows 13–24 of 24")
    for _,radio in ipairs(ui.professionDropdown.radios) do if radio.data==5 then radio:Click() end end
    eq(ui.offset,0); eq(#ui.rows,8); eq(ui.rows[1].guid,"PRIVATE-GUID")
    for _,row in ipairs(ui.rows) do eq(row.professionFamily,5) end
    eq(ui.rowRange:GetText(),"Rows 1–8 of 8"); verify(); eq(s.graphReads,nil); eq(s.currencyReads,nil)
end)
case("gathering optional API failures and bounded malformed slot/stat lists",function()
    local modifiers={
        function(e) e.C_CurrencyInfo.GetCurrencyInfo=nil end,
        function(e) e.C_CurrencyInfo.GetCurrencyInfo=function() error("PRIVATE-CURRENCY") end end,
        function(e) e.C_CurrencyInfo.GetCurrencyInfo=function() return nil end end,
        function(e) e.C_CurrencyInfo.GetCurrencyInfo=function() return {name="fixture",quantity=-1} end end,
        function(e) e.C_CurrencyInfo.GetCurrencyInfo=function() return {name="fixture",quantity=1,maxQuantity=math.huge} end end,
        function(e) e.C_ProfSpecs.GetCurrencyInfoForSkillLine=function() return {} end end,
        function(e) e.C_Item.GetItemStats=nil end,
        function(e) e.C_Item.DoesItemExist=function() error("PRIVATE-EXISTS") end end,
        function(e) e.C_Item.GetItemID=function() return 1 end end,
        function(e) e.C_Item.GetItemLink=function() return "not-an-item" end end,
        function(e) e.ItemLocation.CreateFromEquipmentSlot=function() error("PRIVATE-LOCATION") end end,
        function(_,s) s.exists=false end,
        function(_,s) s.slots={23,20} end,
        function(_,s) s.slots={23,23} end,
        function(_,s) s.slots={[2]=23} end,
        function(_,s) s.slots=setmetatable({23},{}) end,
        function(_,s) s.slots={}; for n=1,17 do s.slots[n]=n+19 end end,
    }
    for n,change in ipairs(modifiers) do
        local e,s=api(specs[1]); change(e,s); local r=NS.Collectors.New(e,{private=true}); local verify=unchanged(r)
        local report=drain(NS.KnowledgeCheck.NewProfessionCaptureJob(e,r)).report
        check(report and report.gatheringEvidence,"profile "..n); eq(report.gatheringEvidence.complete,false,"optional failure "..n)
        eq(report.captureComplete,true,"optional failure does not redefine Knowledge completeness")
        local text,summary=NS.KnowledgeCheck.Format(report)
        eq(summary.gatheringEvidenceComplete,false); check(not text:find("PRIVATE%-")); verify()
        if n>=13 then eq(#s.reads,0,"ambiguous/incomplete list has no tool read") end
    end
    local e,s=api(specs[1]); s.statsHook=function() local out={}; for n=1,32 do out["ITEM_MOD_FIXTURE_"..n]=n end; return out end
    e.ITEM_MOD_FIXTURE_1="Untrusted|\nlabel"
    local report=drain(NS.KnowledgeCheck.NewProfessionCaptureJob(e,NS.Collectors.New(e,nil))).report
    eq(#report.gatheringEvidence.tool.total.items,32); eq(report.gatheringEvidence.complete,true)
    local text=NS.KnowledgeCheck.Format(report); check(text:find("Untrusted  label",1,true)); check(not text:find("Untrusted|",1,true))
end)
case("gathering context interval invalidation, optional reentry and disposal",function()
    for _,change in ipairs({
        function(_,s) s.combat=true end,function(_,s) s.shown=false end,
        function(_,s) s.ready=false end,function(_,s) s.IsTradeSkillLinked=true end,
        function(_,s) s.IsTradeSkillGuild=true end,function(_,s) s.IsTradeSkillGuildMember=true end,
        function(_,s) s.IsNPCCrafting=true end,function(_,s) s.IsDataSourceChanging=true end,
        function(_,s) s.info.sourceCounter=s.info.sourceCounter+1 end,
        function(_,s) s.staged=true end,function(_,s) s.info.isPrimaryProfession=false end,
        function(_,s) s.parents={} end,function(_,s) s.info.maxSkillLevel=0 end,
    }) do
        local e,s=api(specs[1]); local r=NS.Collectors.New(e,{private=true}); local job=NS.KnowledgeCheck.NewProfessionCaptureJob(e,r)
        job:Step(); check(job.status=="running"); change(e,s)
        local report=drain(job).report; eq(report.captureComplete,false); eq(report.gatheringEvidence.complete,false)
        local _,summary=NS.KnowledgeCheck.Format(report); eq(summary.gatheringEvidenceComplete,false)
    end
    for _,mode in ipairs({"cancel","step"}) do
        local e,s=api(specs[1]); local r=NS.Collectors.New(e,{private=true}); local verify=unchanged(r)
        local job
        s.statsHook=function()
            if mode=="cancel" then job:Cancel("fixture") else job:Step() end
            return {ITEM_MOD_DEFTNESS_SHORT=1}
        end
        job=NS.KnowledgeCheck.NewProfessionCaptureJob(e,r); drain(job)
        eq(job.status,"incomplete"); eq(job.worker,nil); eq(job.report,nil); eq(job.text,nil); verify()
    end
end)
case("gathering command scheduler eligibility one-unit frames cancel and reentry",function()
    local function setup(spec)
        local e,s=api(spec); widgets(e); e.debugprofilestop=function() return 0 end
        local r=NS.Collectors.New(e,{private="PRIVATE-DB"}); r.roster={private=true}
        local c=NS.Commands.New(e); c.collector=r
        local function forbidden() error("runtime operation forbidden") end
        r.Scan=forbidden; r.Context=forbidden; r.Roster=forbidden; r.Knowledge=forbidden; c.Login=forbidden
        return e,s,r,c
    end
    for n=1,3 do
        local e,s,r,c=setup(specs[n]); local verify=unchanged(r)
        local session=c:Run("knowledgecapture"); check(session); eq(s.graphReads,nil,"no slash-stack traversal")
        eq(c:Run("knowledgecapture"),session); eq(c:Run("knowledgecapture status"),session)
        local stale=c.knowledgeCaptureFrame.scripts.OnUpdate
        local callbacks=0
        while c.knowledgeCapture do
            c.knowledgeCaptureFrame.scripts.OnUpdate(); callbacks=callbacks+1; check(callbacks<10000)
        end
        eq(c.knowledgeCaptureSummary.completed,true); eq(c.knowledgeCaptureReport.gatheringEvidence.complete,true)
        check(c.knowledgeCaptureText:find("gatheringEvidence",1,true)); verify()
        stale(); eq(c.knowledgeCapture,nil,"retired callback inert")
        check(c:Run("knowledgecapture")); c.knowledgeCaptureFrame.scripts.OnUpdate(); c:Run("knowledgecapture cancel")
        eq(c.knowledgeCapture,nil); eq(c.knowledgeCaptureSummary.completed,false)
        s.statsHook=function() c:Run("knowledgecapture cancel"); return {} end
        check(c:Run("knowledgecapture"))
        while c.knowledgeCapture do c.knowledgeCaptureFrame.scripts.OnUpdate() end
        eq(c.knowledgeCaptureSummary.completed,false); verify()
    end
    for n=4,5 do local _,_,_,c=setup(specs[n]); eq(c:Run("knowledgecapture"),nil); eq(c.knowledgeCapture,nil) end
end)
case("gathering full graph and format clipping cannot advertise complete output",function()
    local e,s=api(specs[1]); local p,t=e.C_ProfSpecs,e.C_Traits
    p.GetSpecTabIDsForSkillLine=function() return {1,2,3,4,5,6,7,8} end
    p.GetRootPathForTab=function(tab) return tab*1000+1 end
    p.GetChildrenForPath=function(id) return id%1000<64 and {id+1} or {} end
    p.GetUnlockEntryForPath=function(id) return id*2 end; p.GetSpendEntryForPath=function(id) return id*2+1 end
    t.GetNodeInfo=function(_,id)
        return {ID=id,type=1,flags=0,currentRank=0,activeRank=0,ranksPurchased=0,ranksIncreased=0,maxRanks=10,
            totalMaxRanks=10,isAvailable=false,entryIDs={id*2,id*2+1},entryIDsWithCommittedRanks={},entryIDToRanksIncreased={}}
    end
    t.GetEntryInfo=function(_,id) return {type=1,maxRanks=id%2==0 and 0 or 10,definitionID=id+100,entryCost={}} end
    local report=drain(NS.KnowledgeCheck.NewProfessionCaptureJob(e,NS.Collectors.New(e,{private=true}))).report
    eq(#report.tabs,8); eq(report.captured,512); eq(report.outputTruncated,true); eq(report.captureComplete,false)
    local verify=unchanged(report); local format=drain(NS.KnowledgeCheck.NewFormatJob(report))
    local text,summary=format.text,format.summary
    eq(summary.outputTruncated,true); eq(summary.captureComplete,false); eq(summary.gatheringEvidenceComplete,false)
    check(text:find("END SUMMARY version1",1,true)); check(text:find("allRankCosts=UNVERIFIED",1,true))
    check(#text<=262144); local _,lines=text:gsub("\n",""); check(lines+1<=4096); verify()
end)
print(string.format("P01 additive: %d groups passed; %d failed; %d assertions (pure fixtures, not native evidence)",passed,failed,checks))
if failed>0 then os.exit(1) end
