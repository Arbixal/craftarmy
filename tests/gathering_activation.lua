-- P02 standalone private fixtures. No native API/all-rank/timing proof or real snapshots.
local NS={}
for _,name in ipairs({"Core","Storage","Data","Knowledge","Collectors","KnowledgeCheck","Details","ViewModel","Dashboard","SelfTests","Commands"}) do
    assert(loadfile("CraftArmy/"..name..".lua"))("CraftArmy",NS)
end
local C,D,S,K,V=NS.Core,NS.Data,NS.Storage,NS.Knowledge,NS.ViewModel
local checks,passed,failed=0,0,0
local function check(ok,why) checks=checks+1; assert(ok,why or "assertion failed") end
local function eq(a,b,why) check(a==b,(why or "equality")..": "..tostring(a).." ~= "..tostring(b)) end
local function case(name,fn)
    local ok,why=pcall(fn)
    if ok then passed=passed+1; print("PASS P02 "..name)
    else failed=failed+1; print("FAIL P02 "..name..": "..tostring(why)) end
end
local specs={
    {2916,186,6,3264,3784,245,5,69,480,"Mining"},
    {2912,182,4,3260,3778,300,4,81,560,"Herbalism"},
    {2917,393,11,3265,3889,55,0,61,400,"Skinning"},
}
local function identity(s) return {skillLineID=s[1],parentID=s[2],profession=s[3],expansionID=11} end
case("exact active catalogues and rejecting identities",function()
    for _,s in ipairs(specs) do
        local i=identity(s); eq(D.Capabilities(i).moxieMode,"enabled","verified Moxie mode")
        eq(D.Capabilities(i).knowledgeMode,"enabled"); eq(D.moxie[s[1]],D.moxieCatalog[s[10]])
        eq(D.moxie[s[1]].id,s[4]); eq(C.NativeKnowledgeCurrency(i),s[5])
        eq(D.moxie[s[1]].provenance,"User native gathering capture/UI agreement 2026-11-19; 70961")
        for _,key in ipairs({"skillLineID","parentID","profession","expansionID"}) do
            local bad=C.Copy(i); bad[key]=999; eq(D.Capabilities(bad),nil); eq(C.NativeKnowledgeCurrency(bad),nil)
        end
        local bad=C.Copy(i); bad.skillLineID=s[2]; eq(D.Capabilities(bad),nil); eq(C.NativeKnowledgeCurrency(bad),nil)
        bad=C.Copy(i); bad.expansionID=10; eq(D.Capabilities(bad),nil); eq(C.NativeKnowledgeCurrency(bad),nil)
    end
    local original={
        [2913]={"Inscription",3261,3902,"T01 user currency query; 70783"},
        [2909]={"Enchanting",3258,4056,"User native currency query/UI agreement 2026-11-10"},
        [2906]={"Alchemy",3256,4030},[2907]={"Blacksmithing",3257,3750},[2910]={"Engineering",3259,3903},
        [2914]={"Jewelcrafting",3262,3989},[2915]={"Leatherworking",3263,4085},[2918]={"Tailoring",3266,3736},
    }
    local count=0; for _ in pairs(D.moxie) do count=count+1 end; eq(count,11)
    for id,expected in pairs(original) do
        local m=D.expansions[id]; local cap=D.Capabilities({skillLineID=id,parentID=m.parentID,profession=m.profession,expansionID=11})
        eq(D.moxie[id],D.moxieCatalog[expected[1]]); eq(D.moxie[id].id,expected[2]); eq(D.moxie[id].provenance,expected[4] or "User-supplied list 2026-11-10; not native-verified")
        eq(C.NativeKnowledgeCurrency({skillLineID=id,parentID=m.parentID,profession=m.profession,expansionID=11}),expected[3])
        check(cap.concentration); eq(cap.enchantAttentionMode,"enabled")
    end
end)
case("Finesse and Perception production Tool categories",function()
    for _,category in ipairs({"Finesse","Perception"}) do
        eq(D.statNames["ITEM_MOD_"..category:upper().."_SHORT"],D.statCategories[category],"verified stat key")
        local gear={slot=23,role="tool",exists=true,metadataReady=true,itemID=123,link="item:123:0:0",
            toolStat={status="observed",attemptedAt=10,observedAt=10,source="C_Item.GetItemStats:unenchant-link-v1",value=category}}
        check(C.ValidPayload("tool",gear,"observed"),"verified Tool category accepted")
    end
    -- P03 ADAPT DEFTNESS_KEY BEGIN
--[==============[P03 ORIGINAL BEGIN
    eq(D.statNames.ITEM_MOD_DEFTNESS_SHORT,nil)
P03 ORIGINAL END]==============]
    eq(D.statNames.ITEM_MOD_DEFTNESS_SHORT,D.statCategories.Deftness)
    -- P03 ADAPT DEFTNESS_KEY END
end)
-- Normalized transcription of all36 report paths, NOT raw-report parser replay.
-- Active/next/committed rows and definition IDs below are reconstructed fixture-only
-- metadata consistent with the recorded ranks; no claim of all-rank cost evidence.
local projection=[[
Mining,1107,105568,105567|105566|105565,30,51,130286,130282,3784
Mining,1107,105567,-,1,41,130285,130270,3784
Mining,1107,105566,-,1,41,130284,130260,3784
Mining,1107,105565,-,0,41,130283,130250,3875
Mining,1105,105475,105474|105473,41,41,130184,130181,3784
Mining,1105,105474,-,1,36,130183,130171,3784
Mining,1105,105473,-,1,36,130182,130161,3784
Mining,1106,105526,105525|105524|105523|105522,1,41,130240,130235,3784
Mining,1106,105525,-,0,41,130239,130225,3871
Mining,1106,105524,-,0,41,130238,130215,3871
Mining,1106,105523,-,0,41,130237,130205,3871
Mining,1106,105522,-,0,41,130236,130195,3871
Herbalism,1074,104481,104480|104479|104478|104477|104476,41,41,129113,129107,3778
Herbalism,1074,104480,-,1,41,129112,129097,3778
Herbalism,1074,104479,-,1,41,129111,129087,3778
Herbalism,1074,104478,-,1,41,129110,129077,3778
Herbalism,1074,104477,-,1,41,129109,129067,3778
Herbalism,1074,104476,-,1,41,129108,129057,3778
Herbalism,1073,104421,104420|104419,41,41,129047,129044,3778
Herbalism,1073,104420,-,1,41,129046,129034,3778
Herbalism,1073,104419,-,2,41,129045,129024,3778
Herbalism,1080,104707,104706|104705|104704|104703,1,41,129367,129362,3778
Herbalism,1080,104706,-,0,41,129366,129352,3816
Herbalism,1080,104705,-,0,41,129365,129342,3816
Herbalism,1080,104704,-,0,41,129364,129332,3816
Herbalism,1080,104703,-,0,41,129363,129322,3816
Skinning,1120,106089,106088|106087,1,41,130827,130824,3889
Skinning,1120,106088,-,0,41,130826,130814,3896
Skinning,1120,106087,-,0,41,130825,130804,3896
Skinning,1119,106059,106058|106057|106056,1,41,130794,130790,3889
Skinning,1119,106058,-,0,41,130793,130780,3893
Skinning,1119,106057,-,0,41,130792,130770,3893
Skinning,1119,106056,-,0,41,130791,130760,3893
Skinning,1121,106119,106118|106117,41,41,130860,130857,3889
Skinning,1121,106118,-,22,41,130859,130847,3889
Skinning,1121,106117,-,1,41,130858,130837,3889
]]
local totals={Mining={{29,170},{40,110},{0,200}},Herbalism={{40,240},{41,120},{0,200}},Skinning={{0,120},{0,160},{61,120}}}
local function rawFixture(s)
    local raw={policy="native-rank-reconciled-v1",identity=identity(s),configID=77,sourceCounter=1,
        nativeComplete=true,tabsComplete=true,stable=true,stagedStart=false,stagedEnd=false,tabs={}}
    local tabs={}
    for line in projection:gmatch("[^\n]+") do
        local name,tab,id,children,rp,max,un,sp,cost=line:match("(%w+),(%d+),(%d+),([^,]+),(%d+),(%d+),(%d+),(%d+),(%d+)")
        if name==s[10] then
            tab,id,rp,max,un,sp,cost=tonumber(tab),tonumber(id),tonumber(rp),tonumber(max),tonumber(un),tonumber(sp),tonumber(cost)
            local t=tabs[tab]
            if not t then t={id=tab,name="Fixture tree "..tab,root=id,paths={},coverageComplete=true,currenciesComplete=true,
                currencies={{traitCurrencyID=s[5],quantity=s[7],spent=s[8]}}}; tabs[tab]=t; raw.tabs[#raw.tabs+1]=t end
            if cost~=s[5] then
                local found=false; for _,row in ipairs(t.currencies) do if row.traitCurrencyID==cost then found=true end end
                if not found then t.currencies[#t.currencies+1]={traitCurrencyID=cost,quantity=1,spent=0} end
            end
            local ch={}; for child in children:gmatch("%d+") do ch[#ch+1]=tonumber(child) end
            local active=rp>1 and sp or un
            local p={id=id,children=ch,childrenComplete=true,metadataComplete=true,costRule="unknown",
                unlockEntryID=un,spendEntryID=sp,spendCurrencyID=s[5],costs={{ID=cost,amount=1}},
                unlock={type=9,maxRanks=1,definitionID=un+1000000,entryCostComplete=true,entryCost={}},
                spend={type=7,maxRanks=max-1,definitionID=sp+1000000,entryCostComplete=true,entryCost={}},
                node={ID=id,type=1,flags=0,isAvailable=true,currentRank=rp,activeRank=rp,ranksPurchased=rp,
                    ranksIncreased=0,maxRanks=max,totalMaxRanks=max,entryIDs={un,sp},
                    entryIDsWithCommittedRanks=rp>0 and {active} or {},entryIDToRanksIncreased={[un]=0,[sp]=0},
                    activeEntry={entryID=active,rank=rp>1 and rp-1 or rp}}}
            if rp<max then p.node.nextEntry={entryID=rp==0 and un or sp,rank=rp==0 and 1 or rp} end
            t.paths[id]=p
        end
    end
    return raw
end
local function api(s)
    local state={at=100,raw=rawFixture(s),balance=s[6],max=0,unspent=s[7],slots=s[1]==2916 and {23,24,25} or {20,21,22},
        reads={},link="item:222481:8003:0:0",itemID=222481,loading=false,staged=false}
    state.info={professionID=s[1],parentProfessionID=s[2],profession=s[3],isPrimaryProfession=true,
        skillLevel=s[1]==2917 and 105 or 86,maxSkillLevel=s[1]==2917 and 105 or 100,
        skillModifier=s[1]==2917 and 40 or s[1]==2912 and 5 or 0,sourceCounter=1}
    local e={C_TradeSkillUI={},C_Item={},C_ProfSpecs={},C_Traits={},C_CurrencyInfo={}}
    e.GetServerTime=function() return state.at end
    e.GetBuildInfo=function() return "fixture","70961","fixture",120105 end
    e.GetLocale=function() return "fixture" end
    e.UnitGUID=function() return "fixture-guid" end; e.UnitName=function() return "Fixture" end; e.GetRealmName=function() return "Fixture" end
    e.InCombatLockdown=function() return state.combat or false end
    e.ProfessionsFrame={IsShown=function() return state.shown~=false end}
    e.GetProfessions=function() return 1 end
    e.GetProfessionInfo=function() return "Fixture",0,0,0,0,0,s[2] end
    local t=e.C_TradeSkillUI
    for _,key in ipairs({"IsTradeSkillLinked","IsTradeSkillGuild","IsTradeSkillGuildMember","IsNPCCrafting","IsDataSourceChanging"}) do
        local k=key; t[k]=function() return state[k] or false end
    end
    t.IsTradeSkillReady=function() return state.ready~=false end
    t.GetChildProfessionInfo=function() return state.info end
    t.GetBaseProfessionInfo=function() return {professionID=s[2]} end
    t.GetProfessionSlots=function() return state.slots end
    t.GetConcentrationCurrencyID=function() error("N/A concentration must not be read") end
    t.GetItemCraftedQualityByItemInfo=function() return 3 end
    t.GetItemCraftedQualityInfo=function() return {quality=3,iconSmall="fixture"} end
    e.ItemLocation={CreateFromEquipmentSlot=function(_,slot) state.reads[#state.reads+1]=slot; return {slot=slot} end}
    local item=e.C_Item
    item.DoesItemExist=function() return state.exists~=false end
    item.GetItemLink=function() return state.link end; item.GetItemID=function() return state.itemID end
    item.IsItemDataCached=function() return not state.loading end
    item.GetItemQuality=function() return 3 end; item.GetItemIcon=function() return 123 end
    item.GetItemInfo=function(link) return "fixture",link,3,1,1,"","",1,"",123,0,0,0,0,11 end
    item.GetItemStats=function(link)
        if state.statsHook then return state.statsHook(link) end
        local key=s[1]==2917 and "ITEM_MOD_PERCEPTION_SHORT" or "ITEM_MOD_FINESSE_SHORT"
        return {[key]=link==state.link and 110 or 79}
    end
    item.RequestLoadItemData=function() end
    e.C_TooltipInfo={GetInventoryItem=function() return {lines={}} end}
    local p,tr=e.C_ProfSpecs,e.C_Traits
    p.GetConfigIDForSkillLine=function() return 77 end
    p.GetCurrencyInfoForSkillLine=function() return state.unspent~=nil and {numAvailable=state.unspent} or nil end
    local function tab(id) for _,v in ipairs(state.raw.tabs) do if v.id==id then return v end end end
    local function path(id) for _,v in ipairs(state.raw.tabs) do if v.paths[id] then return v.paths[id] end end end
    p.GetSpecTabIDsForSkillLine=function() local out={}; for _,v in ipairs(state.raw.tabs) do out[#out+1]=v.id end; return out end
    p.GetTabInfo=function(id) return {name=tab(id).name} end
    p.GetRootPathForTab=function(id) return tab(id).root end
    p.GetChildrenForPath=function(id) return path(id).children end
    p.GetUnlockEntryForPath=function(id) return path(id).unlockEntryID end
    p.GetSpendEntryForPath=function(id) return path(id).spendEntryID end
    p.GetSpendCurrencyForPath=function(id) return path(id).spendCurrencyID end
    tr.ConfigHasStagedChanges=function() return state.staged end
    tr.GetTreeCurrencyInfo=function(_,id) return tab(id).currencies end
    tr.GetNodeInfo=function(_,id) return path(id).node end
    tr.GetEntryInfo=function(_,id)
        for _,t2 in ipairs(state.raw.tabs) do for _,v in pairs(t2.paths) do
            if v.unlockEntryID==id then return v.unlock elseif v.spendEntryID==id then return v.spend end
        end end
    end
    tr.GetNodeCost=function(_,id) return path(id).costs end
    e.C_CurrencyInfo.GetCurrencyInfo=function(id) eq(id,s[4]); return state.balance~=nil and {quantity=state.balance,maxQuantity=state.max} or nil end
    return e,state
end
local function active(db,s) return S.IsHandle(db) and S.Active(db,"fixture-guid",s[1]) or db.characters["fixture-guid"].professions[s[1]].active end
local function dbFor(schema) return schema==2 and S.New() or {schema=1,characters={}} end
local function drain(job)
    while job.status=="running" do job:Step(); check(job.steps<=10000,"bounded fixture job") end
    return job
end
local function rows(db,fresh,options,at)
    if S.IsHandle(db) then local job=drain(V.NewBuildJob(db,fresh,options,at)); check(job.status=="complete",job.reason); return job.rows end
    return V.Build(db,fresh,options,at)
end
local function row(db,r,at) return rows(db,r.fresh,{},at)[1] end
case("complete36path9tree native projection and payloads",function()
    local count=0
    for _,s in ipairs(specs) do
        local raw=rawFixture(s); local result=K.Evaluate(raw); check(result.complete,result.reason)
        check(C.ValidPayload("knowledgeRaw",raw,"observed")); eq(#result.trees,3)
        local bought,cap=0,0
        for n,tree in ipairs(result.trees) do
            eq(tree.purchased,totals[s[10]][n][1]); eq(tree.capacity,totals[s[10]][n][2])
            eq(tree.accountingPolicy,"native-rank-reconciled-v1"); check(C.ValidPayload("tree:"..tree.id,tree,"observed"))
            for _,p in ipairs(tree.paths) do eq(p.costRule,"unknown"); count=count+1 end
            bought=bought+tree.purchased; cap=cap+tree.capacity
        end
        eq(bought,s[8]); eq(cap,s[9]); eq(result.sharedSpent,s[8])
    end
    eq(count,36)
end)
case("both storage facades scans reopen view agree with evidence",function()
    for _,s in ipairs(specs) do for _,schema in ipairs({1,2}) do
        local e,st=api(s); local db,saved
        if schema==2 then db,saved=S.New() else db=dbFor(schema); saved=db end
        local r=NS.Collectors.New(e,db); check(r:Scan(),r.reason)
        local g=active(db,s); eq(g.fields.moxie.last.value.quantity,s[6]); eq(g.fields.moxie.last.value.maxQuantity,0)
        eq(g.fields.unspent.last.value,s[7]); eq(g.fields.concentration.attempt.status,"not_applicable")
        for n,t in ipairs(st.raw.tabs) do
            local f=g.fields["tree:"..t.id]; eq(f.attempt.status,"observed"); eq(f.last.value.purchased,totals[s[10]][n][1])
            eq(f.last.value.capacity,totals[s[10]][n][2])
        end
        local v=row(db,r,st.at); eq(v.moxie,s[6]); eq(v.cells[V.index.Moxie],tostring(s[6])); eq(v.unspent,s[7]); eq(#v.trees,3)
        check(not v.enchantMissing); eq(#rows(db,r.fresh,{attention="Missing enchant"},100),0)
        if s[1]==2917 then eq(g.fields.skill.last.value.skillLevel,105); eq(g.fields.skill.last.value.maxSkillLevel,105); eq(g.fields.skill.last.value.skillModifier,40) end
        local job=drain(S.NewOpenJob(saved)); check(job.status=="complete",job.reason)
        local again=rows(job.result,{}, {},200)[1]
        eq(again.moxie,s[6]); eq(again.unspent,s[7]); eq(#again.trees,3)
    end end
end)
local function first(raw) local t=raw.tabs[1]; return t.paths[t.root],t end
case("native graph and rank guards reject without partial numeric trees",function()
    local mutations={
        function(r) r.tabs[2].id=r.tabs[1].id end,
        function(r) r.tabs[2].root=r.tabs[1].root; r.tabs[2].paths=r.tabs[1].paths end,
        function(r) local p=first(r); p.children[#p.children+1]=p.children[1] end,
        function(r) local p,t=first(r); t.paths[p.children[1]]=nil end,
        function(r) local p,t=first(r); t.paths[999]=C.Copy(p); t.paths[999].node.ID=999 end,
        function(r) local p=first(r); p.childrenComplete=false end,
        function(r) r.tabsComplete=false end,
        function(r) local p=first(r); p.metadataComplete=false end,
        function(r) local p=first(r); p.node.ID=999 end,
        function(r) local p=first(r); p.node.type=2 end,
        function(r) local p=first(r); p.node.flags=1 end,
        function(r) local p=first(r); p.node.ranksIncreased=1 end,
        function(r) local p=first(r); p.node.currentRank=p.node.currentRank+1 end,
        function(r) local p=first(r); p.node.activeRank=999 end,
        function(r) local p=first(r); p.node.totalMaxRanks=999 end,
        function(r) local p=first(r); p.node.activeEntry.rank=999 end,
        function(r) local p=first(r); p.node.entryIDs={p.unlockEntryID,p.unlockEntryID} end,
        function(r) local p=first(r); p.node.entryIDToRanksIncreased[p.unlockEntryID]=1 end,
        function(r) local p=first(r); p.unlock.type=7 end,
        function(r) local p=first(r); p.spend.maxRanks=999 end,
        function(r) local p=first(r); p.unlock.entryCost={{ID=999,amount=1}} end,
        function(r) local p=first(r); p.costRule="verified-unit-spend" end,
        function(r) local p=first(r); p.spendCurrencyID=999 end,
        function(r) local p=first(r); p.costs={{ID=999,amount=1}} end,
        function(r) local p=first(r); p.costs[1].amount=2 end,
        function(r) r.tabs[1].currencies[1].quantity=-1 end,
        function(r) r.tabs[1].currenciesComplete=false end,
        function(r) r.tabs[2].currencies[1].quantity=999 end,
        function(r) r.tabs[2].currencies[1].spent=999 end,
        function(r) for _,t in ipairs(r.tabs) do t.currencies[1].spent=t.currencies[1].spent+1 end end,
        function(r) r.stagedStart=true end,function(r) r.stagedEnd=true end,function(r) r.stable=false end,
        function(r) r.nativeComplete=false end,function(r) r.identity.parentID=999 end,
    }
    for _,s in ipairs(specs) do for n,change in ipairs(mutations) do
        local raw=rawFixture(s); change(raw); local out=K.Evaluate(raw); check(not out.complete,"negative native "..n)
        for _,tree in ipairs(out.trees) do eq(tree.purchased,nil); eq(tree.capacity,nil) end
    end end
    -- Auxiliary unlock tokens are valid only on a zero-rank/max1 locked path.
    for _,s in ipairs(specs) do
        local raw=rawFixture(s); local locked,t
        for _,tab in ipairs(raw.tabs) do for _,p in pairs(tab.paths) do if p.node.ranksPurchased==0 then locked,t=p,tab end end end
        check(K.NativePathPoints(locked,t)); local bad=C.Copy(locked); bad.costs[1].ID=s[5]
        eq(K.NativePathPoints(bad,t),nil); bad=C.Copy(locked); bad.node.nextEntry.entryID=bad.spendEntryID
        eq(K.NativePathPoints(bad,t),nil)
    end
end)
local function seeded(s,schema)
    local e,st=api(s); local db,saved
    if schema==2 then db,saved=S.New() else db=dbFor(schema); saved=db end
    local r=NS.Collectors.New(e,db); check(r:Scan(),r.reason)
    local g=active(db,s); local observations={}; local times={moxie=11,unspent=12,knowledgeIndex=13,knowledgeRaw=14}
    for n,t in ipairs(st.raw.tabs) do times["tree:"..t.id]=14+n end
    -- Schema2's compact read facade is not a live incoming rich-payload format.
    -- Reconstruct rich units via the same production acquisition/evaluation path.
    local raw=r:Knowledge(assert(r:Context())); raw.stable=true; raw.stagedEnd=false
    local result=K.Evaluate(raw); check(result.complete,result.reason)
    local rich={knowledgeRaw=raw}
    for _,tree in ipairs(result.trees) do rich["tree:"..tree.id]=tree end
    for key,at in pairs(times) do observations[key]=C.Observation("observed",rich[key] or g.fields[key].last.value,at,"independent fixture history") end
    check(S.Apply(db,{guid="fixture-guid",name="Fixture",realm="Fixture"},identity(s),observations,20,"fixture"))
    st.at=200; return e,st,r,db,saved,times
end
local function retained(db,s,times)
    local g=active(db,s)
    -- A newly observed structurally valid raw diagnostic may update on an otherwise
    -- nonnumeric evaluation. Coherent tree/index and independent currencies must not.
    for key,at in pairs(times) do if key~="knowledgeRaw" then eq(g.fields[key].last.observedAt,at,"retained "..key) end end
    eq(g.fields.moxie.last.value.quantity,s[6]); eq(g.fields.unspent.last.value,s[7])
    for n,t in ipairs(rawFixture(s).tabs) do eq(g.fields["tree:"..t.id].last.value.purchased,totals[s[10]][n][1]) end
end
case("failed currency graph reads preserve independent observations and reopen",function()
    local modes={"nil","error","unsupported","invalid","missing-node","bad-rank","wrong-spend","shared-sum","staged","unstable",
        "duplicate","shared","clipped","bad-entry","bad-cost","currency-error","changed-config","changed-serial","changed-revision","end-staged"}
    for _,s in ipairs(specs) do for _,schema in ipairs({1,2}) do for _,mode in ipairs(modes) do
        local e,st,r,db,saved,times=seeded(s,schema)
        local function bad() if mode=="error" then error("PRIVATE") end; return mode=="invalid" and {quantity=-1,numAvailable=-1} or nil end
        if mode=="unsupported" then
            e.C_CurrencyInfo.GetCurrencyInfo=nil; e.C_ProfSpecs.GetCurrencyInfoForSkillLine=nil
        else e.C_CurrencyInfo.GetCurrencyInfo=bad; e.C_ProfSpecs.GetCurrencyInfoForSkillLine=bad end
        if mode=="nil" or mode=="error" or mode=="unsupported" or mode=="invalid" then
            if mode=="unsupported" then e.C_ProfSpecs.GetSpecTabIDsForSkillLine=nil
            else e.C_ProfSpecs.GetSpecTabIDsForSkillLine=bad end
        elseif mode=="missing-node" then e.C_Traits.GetNodeInfo=function() return nil end
        elseif mode=="bad-rank" then local p=first(st.raw); p.node.ranksIncreased=1
        elseif mode=="wrong-spend" then local p=first(st.raw); p.spendCurrencyID=999
        elseif mode=="shared-sum" then for _,t in ipairs(st.raw.tabs) do t.currencies[1].spent=999 end
        elseif mode=="staged" then st.staged=true
        elseif mode=="duplicate" then local p=first(st.raw); p.children[#p.children+1]=p.children[1]
        elseif mode=="shared" then st.raw.tabs[2].root=st.raw.tabs[1].root; st.raw.tabs[2].paths=st.raw.tabs[1].paths
        elseif mode=="clipped" then local p=first(st.raw); p.node.entryIDs={}; for n=1,33 do p.node.entryIDs[n]=n end
        elseif mode=="bad-entry" then local p=first(st.raw); p.spend.type=9
        elseif mode=="bad-cost" then local p=first(st.raw); p.costs[1].amount=2
        elseif mode=="currency-error" then e.C_Traits.GetTreeCurrencyInfo=function() error("PRIVATE") end
        elseif mode=="changed-config" then local n=0; e.C_ProfSpecs.GetConfigIDForSkillLine=function() n=n+1; return n==1 and 77 or 78 end
        elseif mode=="changed-serial" or mode=="changed-revision" or mode=="end-staged" then
            local original=e.C_Traits.GetNodeCost
            e.C_Traits.GetNodeCost=function(...)
                if mode=="changed-serial" then r.serial=r.serial+1 elseif mode=="changed-revision" then r.revision=r.revision+1 else st.staged=true end
                return original(...)
            end
        else local original=e.C_Traits.GetNodeCost; e.C_Traits.GetNodeCost=function(...) st.info.sourceCounter=2; return original(...) end end
        local scanned=r:Scan()
        if mode=="unstable" or mode=="changed-config" or mode=="changed-serial" or mode=="changed-revision" then
            check(not scanned,"context drift discarded "..mode)
        else check(scanned,r.reason) end
        if mode=="unsupported" then
            eq(active(db,s).fields.moxie.attempt.status,"unsupported")
            eq(active(db,s).fields.unspent.attempt.status,"unsupported")
        end
        if scanned then
            for key in pairs(times) do if key~="knowledgeRaw" then check(active(db,s).fields[key].attempt.status~="observed","failed attempt "..mode.." "..key) end end
        end
        retained(db,s,times)
        local job=drain(S.NewOpenJob(saved)); check(job.status=="complete",job.reason); retained(job.result,s,times)
        local v=rows(job.result,{}, {},300)[1]; eq(v.moxie,s[6]); eq(#v.trees,3)
    end end end
end)
case("observed balances zero threshold max0 nil and separate Skill",function()
    for _,s in ipairs(specs) do for _,schema in ipairs({1,2}) do
        local e,st=api(s); local db=dbFor(schema); local r=NS.Collectors.New(e,db)
        for _,balance in ipairs({0,600,601}) do for _,maxMode in ipairs({"zero","nil"}) do
            st.balance=balance; st.max=maxMode=="zero" and 0 or nil; check(r:Scan(),r.reason)
            local v=row(db,r,st.at); eq(v.moxie,balance); eq(v.cells[V.index.Moxie],tostring(balance))
            eq(#rows(db,r.fresh,{attention="Moxie"},st.at),balance>600 and 1 or 0)
            eq(active(db,s).fields.moxie.last.value.quantity,balance)
        end end
    end end
end)
case("unspent is independent and auxiliary balances are not Knowledge",function()
    for _,s in ipairs(specs) do for _,schema in ipairs({1,2}) do
        local e,st=api(s); st.unspent=17
        for _,t in ipairs(st.raw.tabs) do for n=2,#t.currencies do t.currencies[n].quantity=999 end end
        local db=dbFor(schema); local r=NS.Collectors.New(e,db); check(r:Scan(),r.reason)
        eq(active(db,s).fields.unspent.last.value,17); eq(#row(db,r,100).trees,3)
        for n,t in ipairs(st.raw.tabs) do eq(active(db,s).fields["tree:"..t.id].last.value.purchased,totals[s[10]][n][1]) end
    end end
end)
case("all five skill cap and strict slot safeguards independent of mode",function()
    local all={specs[1],specs[2],specs[3],{2908,185,5},{2911,356,10}}
    for _,s in ipairs(all) do
        local e,st=api(specs[1]); st.info.professionID=s[1]; st.info.parentProfessionID=s[2]; st.info.profession=s[3]
        st.info.isPrimaryProfession=s[3]~=5 and s[3]~=10
        e.GetProfessionInfo=function() return "Fixture",0,0,0,0,0,s[2] end
        e.GetProfessions=function() if s[3]==5 then return nil,nil,nil,nil,1 elseif s[3]==10 then return nil,nil,nil,1 else return 1 end end
        e.C_TradeSkillUI.GetBaseProfessionInfo=function() return {professionID=s[2]} end
        local r=NS.Collectors.New(e,dbFor(1)); check(r:Context())
        for _,pair in ipairs({{0,0},{0,-1},{0,1.5},{-1,100},{.5,100},{101,100}}) do
            st.info.skillLevel=pair[1]; st.info.maxSkillLevel=pair[2]; eq(r:Context(),nil,"invalid skill/cap")
        end
        st.info.skillLevel=1; st.info.maxSkillLevel=100
        local oversize={}; for n=1,17 do oversize[n]=n+19 end
        for n,slots in ipairs({{23,23},{[2]=23},setmetatable({23},{}),oversize,{1,29,30,33},{23,20}}) do
            st.slots=slots; st.reads={}; check(r:Scan(),r.reason); eq(#st.reads,0,"no invented/forbidden role reads "..n)
            local g=active(r.db,s); eq(g.fields.tool.attempt.status,"unknown")
            for _,id in ipairs({1,29,30,33}) do eq(g.fields["slot"..id],nil) end
        end
    end
end)
case("F P optional Tool queries letters attribution and metadata rejections",function()
    for _,s in ipairs(specs) do for _,schema in ipairs({1,2}) do
        local e,st,r,db=seeded(s,schema); local key=s[1]==2917 and "ITEM_MOD_PERCEPTION_SHORT" or "ITEM_MOD_FINESSE_SHORT"
        local category=s[1]==2917 and "Perception" or "Finesse"
        local g=active(db,s); local value=g.fields.tool.last.value
        eq(value.toolStat.value,category); eq(value.toolStat.source,"C_Item.GetItemStats:unenchant-link-v1")
        eq(value.stats[key],110); eq(value.enchant.category,"Finesse"); eq(row(db,r,st.at).gear.tool.toolLetter,category:sub(1,1))
        check(not g.fields.accessory1.last.value.toolStat); check(not g.fields.accessory2.last.value.toolStat)
        local queries={}
        st.statsHook=function(link) queries[#queries+1]=link; return link==st.link and {[key]=110} or {[key]=79} end
        check(r:Scan(),r.reason); check(#queries>=4); check(queries[1]==st.link)
        local neutral=NS.Collectors.ToolStatLink(st.link); check(neutral~=st.link)
        local found=false; for _,link in ipairs(queries) do if link==neutral then found=true end end; check(found)
        local at=active(db,s).fields.tool.last.value.toolStat.observedAt
        for _,mode in ipairs({"ambiguous","zero","negative","malformed","error","nil","loading"}) do
            st.at=st.at+1; st.loading=mode=="loading"
            st.statsHook=function(link)
                if link==st.link then return {[key]=110} end
                if mode=="error" then error("PRIVATE") elseif mode=="nil" then return nil
                elseif mode=="ambiguous" then return {ITEM_MOD_FINESSE_SHORT=1,ITEM_MOD_PERCEPTION_SHORT=1}
                elseif mode=="malformed" then return {BAD=1}
                elseif mode=="negative" then return {[key]=-1} else return {[key]=0} end
            end
            check(r:Scan(),r.reason); local tool=active(db,s).fields.tool.last.value
            eq(tool.toolStat.value,category,"same instance optional history"); eq(tool.toolStat.observedAt,at)
        end
        st.loading=false; st.link="item:222482:8003:0:0"; st.itemID=222482; st.at=300
        st.statsHook=function(link) if link==st.link then return {[key]=110} end; return {} end
        check(r:Scan(),r.reason); local tool=active(db,s).fields.tool.last.value
        check(not tool.toolStat or tool.toolStat.value==nil,"different instance inherits no letter"); eq(row(db,r,st.at).gear.tool.toolLetter,nil)
        st.statsHook=function(link)
            if link~=st.link then st.link="item:222483:8003:0:0"; st.itemID=222483 end
            return {[key]=79}
        end
        tool=assert(r:Gear(st.slots[1],"tool")); check(not tool.toolStat or tool.toolStat.value==nil,"changed link discards optional")
    end end
    for _,category in ipairs({"Finesse","Perception"}) do
        local e,st=api(specs[1]); st.statsHook=function() return {["ITEM_MOD_"..category:upper().."_SHORT"]=1} end
        local tool=assert(NS.Collectors.New(e,dbFor(1)):Gear(23,"tool")); check(C.ValidPayload("tool",tool,"observed"))
        for _,change in ipairs({
            -- P03 ADAPT UNSUPPORTED_CATEGORY BEGIN
--[==============[P03 ORIGINAL BEGIN
            function(t) t.toolStat.value="Deftness" end,function(t) t.toolStat.value="Arbitrary" end,
P03 ORIGINAL END]==============]
            function(t) t.toolStat.value="P03Unsupported" end,function(t) t.toolStat.value="Arbitrary" end,
            -- P03 ADAPT UNSUPPORTED_CATEGORY END
            function(t) t.toolStat.source="wrong" end,function(t) t.toolStat.observedAt=nil end,
            function(t) t.toolStat.extra=true end,function(t) t.metadataReady=false end,function(t) t.exists=false end,
            function(t) t.slot=29 end,function(t) t.link=nil end,function(t) t.itemID=999 end,
        }) do local bad=C.Copy(tool); change(bad); check(not C.ValidPayload("tool",bad,"observed")) end
        local bad=C.Copy(tool); bad.role="accessory1"; bad.slot=24; check(not C.ValidPayload("accessory1",bad,"observed"))
    end
end)
-- Strict private widgets record actual Dashboard calls, not native rendering/font behavior.
local function widgets(e)
    local m={}
    local function new(kind,parent,template) return setmetatable({kind=kind,parent=parent,template=template,shown=true,scripts={},points={},width=0,height=14,text="",lines={}}, {__index=m}) end
    function m:CreateTexture() return new("Texture",self) end
    function m:CreateFontString() return new("FontString",self) end
    function m:SetText(v) self.text=v end; function m:GetText() return self.text end
    function m:SetScript(k,v) self.scripts[k]=v end
    function m:SetSize(w,h) self.width=w; self.height=h end
    function m:SetWidth(w) self.width=w end; function m:SetHeight(h) self.height=h end
    function m:GetWidth() return self.width end; function m:GetHeight() return self.height end
    function m:SetScale(s) self.scale=s end; function m:GetScale() return self.scale or 1 end
    function m:GetFrameLevel() return self.level or 1 end; function m:SetFrameLevel(v) self.level=v end
    function m:SetPoint(...) self.points[#self.points+1]={...} end
    function m:ClearAllPoints() self.points={} end; function m:SetAllPoints(v) self.allPoints=v or self.parent end
    function m:Show() self.shown=true end; function m:Hide() self.shown=false end
    function m:IsShown() return self.shown end; function m:SetShown(v) self.shown=v end
    function m:SetTexture(v) self.texture=v; self.atlas=nil; return true end
    function m:SetAtlas(v) self.atlas=v end; function m:SetFont(...) self.font={...} end
    function m:GetStatusBarTexture() if not self.textureWidget then self.textureWidget=new("Texture",self) end; return self.textureWidget end
    function m:SetValue(v) self.value=v; if self.kind=="Slider" and self.scripts.OnValueChanged then self.scripts.OnValueChanged(self,v) end end
    function m:SetMinMaxValues(a,b) self.minimum=a; self.maximum=b end
    function m:SetThumbTexture(v) self.thumb=new("Texture",self); self.thumb:SetTexture(v) end
    function m:GetThumbTexture() return self.thumb end
    function m:GetStringWidth() return #self.text*6 end
    function m:ClearLines() self.lines={}; self.nativeLink=nil end
    function m:SetHyperlink(v) self.nativeLink=v; self.lines={"Native","Third-party"} end
    function m:AddLine(v) self.lines[#self.lines+1]=v end
    function m:SetDefaultText(v) self.defaultText=v end
    function m:SetupMenu(fn)
        self.radios={}; local owner=self; local root={}
        function root:CreateRadio(label,selected,select,data)
            local r={label=label,data=data,selected=selected,select=select}
            function r:Click() self.select(self.data) end
            owner.radios[#owner.radios+1]=r
        end
        fn(self,root)
    end
    function m:SetScrollChild(v) self.scrollChild=v end
    for _,key in ipairs({"SetMovable","EnableMouse","RegisterForDrag","StartMoving","StopMovingOrSizing","EnableMouseWheel",
        "SetAutoFocus","ClearFocus","SetHighlightTexture","SetJustifyH","SetWordWrap","SetStatusBarTexture","SetStatusBarColor",
        "SetColorTexture","SetBackdrop","SetBackdropColor","SetTextColor","SetFrameStrata","SetToplevel","Raise","SetBackdropBorderColor",
        "SetOrientation","SetValueStep","SetObeyStepOnDrag","SetEnabled","SetOwner","SetMultiLine","SetFontObject","SetMaxLetters","SetFocus","HighlightText"}) do m[key]=function() end end
    e.UIParent=new("Frame"); e.UIParent:SetSize(1920,1080); e.GameTooltip=new("Tooltip")
    e.CreateFrame=function(kind,_,parent,template) local w=new(kind,parent,template); if template=="BasicFrameTemplateWithInset" then w.TitleText=new("FontString",w) end; return w end
end
case("active gathering reused widgets secondary N/A and native-only normal hover",function()
    for _,spec in ipairs(specs) do
        local env=api(spec); widgets(env); local collector=NS.Collectors.New(env,dbFor(1)); check(collector:Scan(),collector.reason)
        local dashboard=NS.Dashboard.New(env,collector); dashboard:Toggle()
        eq(dashboard.widgets[1].cells[V.index.Tool].statLetter:GetText(),spec[1]==2917 and "P" or "F")
    end
    local s=specs[1]; local e,st=api(s); widgets(e); local db=dbFor(1); local r=NS.Collectors.New(e,db); check(r:Scan(),r.reason)
    local ui=NS.Dashboard.New(e,r); ui:Toggle(); local w=ui.widgets[1]; local I=V.index
    eq(w.cells[I.Tool].statLetter:GetText(),"F"); check(w.cells[I.Tool].statLetter.shown)
    local tool=w.cells[I.Tool]; e.IsShiftKeyDown=function() return false end; tool.scripts.OnEnter(tool)
    eq(e.GameTooltip.nativeLink,st.link); eq(table.concat(e.GameTooltip.lines),"NativeThird-party")
    e.IsShiftKeyDown=function() return true end; tool.scripts.OnEnter(tool)
    check(table.concat(e.GameTooltip.lines):find("Finesse",1,true)); check(table.concat(e.GameTooltip.lines):find("unenchant",1,true))
    local fishing={skillLineID=2911,parentID=356,profession=10,expansionID=11}
    check(S.Apply(db,{guid="secondary",name="Secondary",realm="Fixture"},fishing,
        {skill=C.Observation("observed",{skillLevel=1,maxSkillLevel=100,skillModifier=0},100,"fixture")},100,"fixture"))
    ui.options.professionFamily=10; ui:Refresh(); eq(ui.widgets[1],w)
    for _,col in ipairs({I.Concentration,I.Knowledge,I.Unspent,I.Accessory1,I.Accessory2}) do eq(w.cells[col].label:GetText(),"—") end
    eq(tool.statLetter.shown,false); eq(tool.statLetter:GetText(),"")
    eq(w.cells[I.Accessory1].itemIcon.shown,false); eq(w.cells[I.Concentration].estimate.shown,false)
    check(not ui.rows[1].enchantMissing); eq(ui.rows[1].moxie,nil)
end)
case("mixed46character active-field workload filters sort and observation-only reads",function()
    local db=S.New()
    for n=1,46 do
        local s=specs[(n-1)%3+1]; local out=K.Evaluate(rawFixture(s)); check(out.complete)
        local obs={moxie=C.Observation("observed",{id=s[4],quantity=n*20,maxQuantity=0},10,"fixture"),
            unspent=C.Observation("observed",s[7],11,"fixture"),
            skill=C.Observation("observed",{skillLevel=n,maxSkillLevel=105,skillModifier=40},12,"fixture"),
            knowledgeIndex=C.Observation("observed",{},13,"fixture")}
        for _,tree in ipairs(out.trees) do
            obs.knowledgeIndex.value[#obs.knowledgeIndex.value+1]={id=tree.id,root=tree.root,name=tree.name}
            obs["tree:"..tree.id]=C.Observation("observed",tree,14,"fixture")
        end
        check(S.Apply(db,{guid="mixed"..n,name="Fixture"..n,realm="Fixture"},identity(s),obs,20,"fixture"))
    end
    local all=rows(db,{}, {currentPlayerGUID="mixed1",sortColumn=V.index.Moxie,sortDescending=true},100)
    eq(#all,46); eq(all[1].guid,"mixed1"); eq(all[2].moxie,920)
    for _,v in ipairs(all) do eq(#v.trees,3); check(not v.enchantMissing); eq(v.concentrationValue,nil) end
    eq(#rows(db,{}, {attention="Moxie"},100),16); eq(#rows(db,{}, {attention="Progression"},100),46)
    eq(#rows(db,{}, {attention="Missing enchant"},100),0); eq(#rows(db,{}, {attention="Concentration"},100),0)
    print("P02 mixed active workload46characters/46rows complete")
end)
print(string.format("P02 additive: %d groups passed; %d failed; %d assertions (pure fixtures, not native evidence)",passed,failed,checks))
if failed>0 then os.exit(1) end
