-- P03 private synthetic fixtures only, never native API/build/neutral-query proof.
local NS={}
for _,name in ipairs({"Core","Storage","Data","Knowledge","Collectors","KnowledgeCheck","Details","ViewModel","Dashboard","SelfTests","Commands"}) do
    assert(loadfile("CraftArmy/"..name..".lua"))("CraftArmy",NS)
end
local C,D,S,V=NS.Core,NS.Data,NS.Storage,NS.ViewModel
local checks,passed,failed=0,0,0
local function check(ok,why) checks=checks+1; assert(ok,why or "assertion failed") end
local function eq(a,b,why) check(a==b,(why or "equality")..": "..tostring(a).." ~= "..tostring(b)) end
local function case(name,fn)
    local ok,why=xpcall(fn,debug.traceback)
    if ok then passed=passed+1; print("PASS P03 "..name)
    else failed=failed+1; print("FAIL P03 "..name..": "..tostring(why)) end
end
local specs={{2912,182,4},{2916,186,6},{2917,393,11},{2908,185,5},{2911,356,10}}
local function identity(s) return {skillLineID=s[1],parentID=s[2],profession=s[3],expansionID=11} end
local tabs={{1074,1073,1080},{1107,1105,1106},{1120,1119,1121}}
local palette={{.20,.65,.95},{.20,.78,.48},{.98,.62,.20}}
local old={{2913,773,13},{2909,333,9},{2906,171,3},{2907,164,1},{2910,202,8},{2914,755,12},{2915,165,2},{2918,197,7}}
local function unchanged(root)
    local records={}
    local function visit(t)
        if type(t)~="table" or records[t] then return end
        local r={meta=getmetatable(t),entries={}}; records[t]=r
        for k,v in next,t do r.entries[k]=v; visit(k); visit(v) end
    end
    visit(root)
    return function()
        for t,r in pairs(records) do
            eq(getmetatable(t),r.meta,"metatable unchanged")
            for k,v in next,r.entries do eq(rawget(t,k),v,"edge unchanged") end
            for k in next,t do check(r.entries[k]~=nil,"no added edge") end
        end
    end
end
local function drain(job)
    while job.status=="running" do job:Step(); check(job.steps<=10000,"bounded private job") end
    eq(job.status,"complete",job.reason); return job
end
local function rows(db,fresh,options,at)
    if S.IsHandle(db) then return drain(V.NewBuildJob(db,fresh or {},options or {},at or 200)).rows end
    return V.Build(db,fresh or {},options or {},at or 200)
end
local char={guid="fixture-guid",name="Fixture",realm="Fixture"}
local function active(db,s) return S.Active(db,char.guid,s[1]) end
local function database(schema)
    if schema==2 then return S.New() end
    local db={schema=1,characters={}}; return db,db
end
local function api(spec)
    local st={at=100,link="item:123:8003:0:0:0:0:0:0:0:0:0:2:42:43",itemID=123,expansion=10,
        reads={},queries={},currencyReads=0,source=1}
    local e={C_TradeSkillUI={},C_Item={},C_CurrencyInfo={},C_ProfSpecs={},C_Traits={}}
    e.GetServerTime=function() return st.at end
    e.GetBuildInfo=function() return "fixture","fixture","fixture",120105 end
    e.GetLocale=function() return "fixture" end
    e.UnitGUID=function() return char.guid end; e.UnitName=function() return char.name end; e.GetRealmName=function() return char.realm end
    e.InCombatLockdown=function() return st.combat or false end
    e.ProfessionsFrame={IsShown=function() return st.shown~=false end}
    e.GetProfessions=function()
        if spec[3]==5 then return nil,nil,nil,nil,1 elseif spec[3]==10 then return nil,nil,nil,1 else return 1 end
    end
    e.GetProfessionInfo=function() return "Fixture",0,0,0,0,0,spec[2] end
    local t=e.C_TradeSkillUI
    for _,key in ipairs({"IsTradeSkillLinked","IsTradeSkillGuild","IsTradeSkillGuildMember","IsNPCCrafting","IsDataSourceChanging"}) do t[key]=function() return false end end
    t.IsTradeSkillReady=function() return st.ready~=false end
    t.GetChildProfessionInfo=function() return {professionID=spec[1],parentProfessionID=spec[2],profession=spec[3],
        isPrimaryProfession=spec[3]~=5 and spec[3]~=10,skillLevel=1,maxSkillLevel=100,skillModifier=0,sourceCounter=st.source} end
    t.GetBaseProfessionInfo=function() return {professionID=spec[2]} end
    st.slots=spec[3]==5 and {26,27} or spec[3]==10 and {28,29,30} or {23,24,25}
    t.GetProfessionSlots=function() return st.slots end
    t.GetConcentrationCurrencyID=function() return 777 end
    t.GetItemCraftedQualityByItemInfo=function() return 3 end
    t.GetItemCraftedQualityInfo=function() return {quality=3,iconSmall="fixture"} end
    e.ItemLocation={CreateFromEquipmentSlot=function(_,slot) st.reads[#st.reads+1]=slot; return {slot=slot} end}
    local item=e.C_Item
    item.DoesItemExist=function() if st.unknown then return nil end; return st.exists~=false end
    item.GetItemLink=function() return st.link end; item.GetItemID=function() return st.itemID end
    item.IsItemDataCached=function() return not st.loading end
    item.GetItemQuality=function() return 3 end; item.GetItemIcon=function() return 123 end
    item.GetItemInfo=function(link) return "fixture",st.returned or link,3,1,1,"","",1,"",123,0,0,0,0,st.expansion end
    item.GetItemStats=function(link)
        st.queries[#st.queries+1]=link
        if st.statsHook then return st.statsHook(link) end
        -- Both values synthetic; screenshot proves ONLY raw D110, not this neutral79.
        return {ITEM_MOD_DEFTNESS_SHORT=link==st.link and 110 or 79}
    end
    item.RequestLoadItemData=function() end
    e.Enum={TooltipDataLineType={ItemEnchantmentPermanent=99}}
    e.C_TooltipInfo={GetInventoryItem=function() return {lines=st.conflict and {{type=99,leftText="Fixture permanent enchant"}} or {}} end}
    e.C_CurrencyInfo.GetCurrencyInfo=function(id) st.currencyReads=st.currencyReads+1; return {quantity=id==777 and 500 or 700,maxQuantity=id==777 and 1000 or 0} end
    return e,st
end
-- Strict private widget state records actual Dashboard dispatch, not native visuals.
local function widgets(e)
    local m={}
    local function new(kind,parent,template) return setmetatable({kind=kind,parent=parent,template=template,shown=true,scripts={},style={},points={},width=0,height=14,text="",lines={}}, {__index=m}) end
    function m:CreateTexture() return new("Texture",self) end
    function m:CreateFontString() return new("FontString",self) end
    function m:SetText(v) eq(type(v),"string"); self.text=v end; function m:GetText() return self.text end
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
        "SetOrientation","SetValueStep","SetObeyStepOnDrag","SetEnabled","SetOwner","SetMultiLine","SetFontObject","SetMaxLetters","SetFocus","HighlightText"}) do
        local k=key; m[k]=function(self,...) self.style[k]={...} end
    end
    e.UIParent=new("Frame"); e.UIParent:SetSize(1920,1080); e.GameTooltip=new("Tooltip")
    e.CreateFrame=function(kind,_,parent,template) local w=new(kind,parent,template); if template=="BasicFrameTemplateWithInset" then w.TitleText=new("FontString",w) end; return w end
end
local function rgb(actual,expected)
    for n=1,3 do eq(actual[n],expected[n],"RGB"..n) end
end
local function settle(ui)
    local frames=0
    while ui.buildJob do
        frames=frames+1; check(frames<10000,"bounded synthetic frames")
        local fn=ui.buildDriver and ui.buildDriver.scripts.OnUpdate; check(type(fn)=="function","actual build driver")
        fn(ui.buildDriver,.016)
    end
    return ui
end
case("secondary Moxie evidenced N/A",function()
    for n=4,5 do eq(D.Capabilities(identity(specs[n])).moxieMode,"not_applicable") end
end)
case("all nine gathering native tab colours",function()
    for n=1,3 do for j,id in ipairs(tabs[n]) do
        local r,g,b=D.TreeRGB(specs[n][1],id); eq(r,palette[j][1]); eq(g,palette[j][2]); eq(b,palette[j][3])
    end end
end)
case("Deftness key and guarded Tool category",function()
    eq(D.statNames.ITEM_MOD_DEFTNESS_SHORT,D.statCategories.Deftness)
    check(C.ValidPayload("tool",{slot=23,role="tool",exists=true,metadataReady=true,itemID=123,link="item:123:0:0",
        toolStat={status="observed",attemptedAt=10,observedAt=10,source="C_Item.GetItemStats:unenchant-link-v1",value="Deftness"}},"observed"))
end)
case("gathering missing-enchant eligibility only",function()
    -- P04 ADAPT ELIGIBILITY BEGIN
--[===============[P04 ORIGINAL BEGIN
    for n=1,5 do eq(D.Capabilities(identity(specs[n])).enchantAttentionMode,n<=3 and "enabled" or "pending") end
P04 ORIGINAL END]===============]
    for n=1,5 do eq(D.Capabilities(identity(specs[n])).enchantAttentionMode,n<=4 and "enabled" or "pending") end
    -- P04 ADAPT ELIGIBILITY END
end)
case("exact immutable capabilities and seven recognized keys",function()
    for n,s in ipairs(specs) do
        local i=identity(s); local cap=D.Capabilities(i)
        eq(cap.knowledgeMode,n<=3 and "enabled" or "not_applicable"); eq(cap.concentration,false)
        -- P04 ADAPT CAP_MODES BEGIN
--[===============[P04 ORIGINAL BEGIN
        eq(cap.moxieMode,n<=3 and "enabled" or "not_applicable"); eq(cap.enchantAttentionMode,n<=3 and "enabled" or "pending")
P04 ORIGINAL END]===============]
        eq(cap.moxieMode,n<=3 and "enabled" or "not_applicable"); eq(cap.enchantAttentionMode,n<=4 and "enabled" or "pending")
        -- P04 ADAPT CAP_MODES END
        cap.moxieMode="bad"; cap.enchantAttentionMode="bad"; cap.roles.tool=false; cap.slotRoles[28]="bad"
        check(D.Capabilities(i).roles.tool); check(D.Capabilities(i).moxieMode~="bad"); check(D.Capabilities(i).enchantAttentionMode~="bad")
        for _,key in ipairs({"skillLineID","parentID","profession","expansionID"}) do
            local bad=C.Copy(i); bad[key]=999; eq(D.Capabilities(bad),nil)
        end
        if n>=4 then eq(D.moxie[s[1]],nil); eq(C.NativeKnowledgeCurrency(i),nil) end
    end
    for _,s in ipairs(old) do local c=D.Capabilities(identity(s)); eq(c.moxieMode,"enabled"); eq(c.enchantAttentionMode,"enabled"); check(c.concentration) end
    local keys={MULTICRAFT="Multicraft",RESOURCEFULNESS="Resourcefulness",CRAFTING_SPEED="Crafting Speed",INGENUITY="Ingenuity",DEFTNESS="Deftness",FINESSE="Finesse",PERCEPTION="Perception"}
    local count=0; for k,v in pairs(D.statNames) do
        local name=assert(keys[k:match("^ITEM_MOD_(.+)_SHORT$")]); eq(v,D.statCategories[name]); count=count+1
    end; eq(count,7); eq(D.statNames.ITEM_MOD_ARBITRARY_SHORT,nil)
end)
case("both facades secondary skip unavailable currency APIs and successful N/A merge",function()
    for _,schema in ipairs({1,2}) do for n=4,5 do for _,mode in ipairs({"nil","error","absent"}) do
        local s=specs[n]; local db,saved=database(schema); local e,st=api(s)
        check(S.Apply(db,char,identity(s),{
            moxie=C.Observation("observed",{id=999,quantity=700,maxQuantity=0},11,"old Moxie source"),
            unspent=C.Observation("observed",9,12,"independent history")},12,"fixture"))
        local verify=unchanged(saved)
        local before=rows(db)[1]; eq(before.cells[V.index.Moxie],"—"); eq(before.moxie,nil); eq(before.sortValues[V.index.Moxie],nil)
        local text=table.concat(before.tooltip,"\n"); check(text:find("Underlying Moxie history: 700; ID 999",1,true)); check(text:find("old Moxie source",1,true)); check(text:find("observed 11",1,true))
        eq(table.concat(before.cellTooltips[V.index.Moxie]),"Not applicable."); verify()
        eq(active(db,s).fields.moxie.last.value.quantity,700); eq(active(db,s).fields.moxie.last.observedAt,11)
        if mode=="absent" then e.C_CurrencyInfo=nil
        else e.C_CurrencyInfo.GetCurrencyInfo=function() st.currencyReads=st.currencyReads+1; if mode=="error" then error("PRIVATE") end; return nil end end
        e.C_ProfSpecs=nil; e.C_Traits=nil
        local collector=NS.Collectors.New(e,db); check(collector:Scan(),collector.reason); eq(st.currencyReads,0)
        local f=active(db,s).fields.moxie; eq(f.attempt.status,"not_applicable"); eq(f.last.status,"not_applicable"); eq(f.last.value,nil); eq(f.last.observedAt,100)
        local g=active(db,s); eq(g.fields.skill.last.value.skillLevel,1); eq(g.fields.tool.last.value.toolStat.value,"Deftness")
        eq(g.fields.unspent.last.status,"not_applicable") -- Existing successful N/A semantics, not hidden backup.
        local re=drain(S.NewOpenJob(saved)).result; local v=rows(re)[1]; eq(v.cells[V.index.Moxie],"—"); eq(v.moxie,nil)
        eq(#rows(re,{}, {attention="Moxie"}),0); eq(#rows(re,{}, {attention="Progression"}),1)
        check(S.Archive(re,char.guid,s[1],120,"fixture")); local frozen=unchanged(saved)
        local archived=rows(re,{}, {archived=true})[1]; eq(archived.cells[V.index.Moxie],"—"); eq(#archived.warnings,0)
        eq(#rows(re,{}, {archived=true,attention="Moxie"}),0); frozen()
    end end end
end)
case("unscanned archived700 history masks read-only; invalid own contexts preserve",function()
    for _,schema in ipairs({1,2}) do for n=4,5 do
        local s=specs[n]; local db,saved=database(schema); local e,st=api(s)
        check(S.Apply(db,char,identity(s),{moxie=C.Observation("observed",{id=999,quantity=700},11,"history")},12,"fixture"))
        local collector=NS.Collectors.New(e,db); st.ready=false; local verify=unchanged(saved)
        check(not collector:Scan()); verify(); eq(active(db,s).fields.moxie.last.value.quantity,700)
        check(S.Archive(db,char.guid,s[1],20,"fixture")); verify=unchanged(saved)
        local v=rows(db,{}, {archived=true})[1]; eq(v.moxie,nil); eq(v.cells[V.index.Moxie],"—"); eq(v.sortValues[V.index.Moxie],nil)
        check(table.concat(v.tooltip):find("Underlying Moxie history: 700; ID 999",1,true)); eq(#v.warnings,0); verify()
    end end
end)
case("real reused Moxie widgets clear gathering green and preserve underlying Shift history",function()
    local db={schema=1,characters={}}; local e,st=api(specs[1]); widgets(e)
    local r=NS.Collectors.New(e,db); check(r:Scan(),r.reason)
    for n=4,5 do check(S.Apply(db,{guid="secondary"..n,name="Secondary"..n,realm="Fixture"},identity(specs[n]),{
        moxie=C.Observation("observed",{id=999,quantity=700},11,"masked source"),
        skill=C.Observation("observed",{skillLevel=1,maxSkillLevel=100,skillModifier=0},12,"fixture")},12,"fixture")) end
    local ui=NS.Dashboard.New(e,r); ui.options.professionFamily=4; ui:Toggle()
    local w=ui.widgets[1]; local cell=w.cells[V.index.Moxie]; eq(cell.label:GetText(),"700"); rgb(cell.label.style.SetTextColor,{.20,.78,.30})
    local verify=unchanged(db)
    for n=4,5 do
        ui.options.professionFamily=specs[n][3]; ui:Refresh(); eq(ui.widgets[1],w)
        eq(cell.label:GetText(),"—"); rgb(cell.label.style.SetTextColor,{.45,.50,.58})
        eq(ui.rows[1].moxie,nil); eq(ui.rows[1].sortValues[V.index.Moxie],nil)
        for _,bar in ipairs(w.bars) do eq(bar.shown,false) end
        eq(w.cells[V.index.Tool].statLetter.shown,false)
        e.IsShiftKeyDown=function() return false end; cell.scripts.OnEnter(cell); eq(table.concat(e.GameTooltip.lines),"Not applicable.")
        e.IsShiftKeyDown=function() return true end; cell.scripts.OnEnter(cell)
        local text=table.concat(e.GameTooltip.lines,"\n"); check(text:find("Underlying Moxie history: 700; ID 999",1,true)); check(text:find("masked source",1,true)); check(text:find("observed 11",1,true))
        ui.options.attention="Moxie"; ui:Refresh(); eq(#ui.rows,0)
        ui.options.attention="Progression"; ui:Refresh(); eq(#ui.rows,1)
        ui.options.attention="All"
    end
    ui.options.professionFamily=4; ui:Refresh(); eq(cell.label:GetText(),"700"); rgb(cell.label.style.SetTextColor,{.20,.78,.30})
    e.IsShiftKeyDown=function() return false end; cell.scripts.OnEnter(cell); eq(e.GameTooltip.shown,false); eq(#e.GameTooltip.lines,0)
    verify()
end)
case("all original palettes and neutral identity fallback unchanged",function()
    local originals={[2906]={1140,1142,1144,1143},[2907]={1068,1069,1075,1076},[2909]={1155,1154,1153,1152},[2910]={1131,1176,1132,1133},
        [2913]={1122,1124,1182,1125},[2914]={1138,1136,1139,1137},[2915]={1158,1157,1159,1156},[2918]={1067,1070,1071,1072}}
    local p={palette[1],palette[2],palette[3],{.70,.42,.92}}
    for id,list in pairs(originals) do for j,tab in ipairs(list) do rgb({D.TreeRGB(id,tab)},p[j]) end end
    for n=1,3 do for _,tab in ipairs(tabs[n]) do
        rgb({D.TreeRGB(specs[n%3+1][1],tab)},{.45,.50,.58}); rgb({D.TreeRGB(specs[n][1],tostring(tab))},{.45,.50,.58})
    end end
    for _,args in ipairs({{2912,999},{999,1074},{"2912",1074},{2912},{}}) do rgb({D.TreeRGB(unpack(args))},{.45,.50,.58}) end
end)
local function treeObservations(list)
    local raw={configID=1,stagedStart=false,stagedEnd=false,stable=true,tabsComplete=true,tabs={}}
    for _,id in ipairs(list) do raw.tabs[#raw.tabs+1]={id=id,name="Same localized name",root=id*10,coverageComplete=true,paths={
        [id*10]={name="Same localized name",children={},childrenComplete=true,unlockEntryID=id*10+1,unlock={maxRanks=0},
            costRule="verified-unit-spend",costEvidence="fixture-only",node={ranksPurchased=2,currentRank=2,ranksIncreased=0,maxRanks=10}}}} end
    local result=NS.Knowledge.Evaluate(raw); check(result.complete,result.reason)
    local obs={knowledgeIndex=C.Observation("observed",{},10,"fixture")}
    for _,tree in ipairs(result.trees) do
        obs.knowledgeIndex.value[#obs.knowledgeIndex.value+1]={id=tree.id,root=tree.root,name=tree.name}
        obs["tree:"..tree.id]=C.Observation("observed",tree,11,"fixture")
    end
    return obs
end
case("actual gathering bars stable across swapped order and identical names",function()
    for n=1,3 do for _,order in ipairs({{1,2,3},{3,1,2}}) do
        local db={schema=1,characters={}}; local e=api(specs[n]); widgets(e)
        local list={}; for _,j in ipairs(order) do list[#list+1]=tabs[n][j] end
        check(S.Apply(db,char,identity(specs[n]),treeObservations(list),12,"fixture")); local verify=unchanged(db)
        local r=NS.Collectors.New(e,db); local ui=NS.Dashboard.New(e,r); ui:Toggle()
        local row=ui.rows[1]; eq(#row.trees,3); eq(row.sortValues[V.index.Knowledge],.2)
        for j,bar in ipairs(ui.widgets[1].bars) do if j<=3 then
            rgb(bar.style.SetStatusBarColor,palette[order[j]]); eq(bar.value,.2); eq(bar.label:GetText(),"2/10"); check(bar.shown)
            eq(row.trees[j].id,list[j]); eq(row.trees[j].name,"Same localized name")
        else eq(bar.shown,false) end end
        ui:Render(); verify()
    end end
end)
case("Deftness raw versus synthetic neutral evidence D letter older red border",function()
    for _,schema in ipairs({1,2}) do
        local db,saved=database(schema); local e,st=api(specs[3]); local r=NS.Collectors.New(e,db); check(r:Scan(),r.reason)
        local tool=active(db,specs[3]).fields.tool.last.value
        eq(tool.stats.ITEM_MOD_DEFTNESS_SHORT,110); eq(tool.enchant.category,"Finesse"); check(tool.enchant.present)
        eq(tool.toolStat.value,"Deftness"); eq(tool.toolStat.source,"C_Item.GetItemStats:unenchant-link-v1"); eq(tool.toolStat.observedAt,100)
        eq(tool.itemExpansion.value,10); eq(tool.itemExpansion.source,"C_Item.GetItemInfo"); eq(tool.itemExpansion.observedAt,100)
        local neutral=NS.Collectors.ToolStatLink(st.link); eq(neutral,"item:123:0:0:0:0:0:0:0:0:0:0:2:42:43")
        local found=false; for _,query in ipairs(st.queries) do if query==neutral then found=true end end; check(found)
        local row=rows(db,r.fresh)[1]; eq(row.gear.tool.toolLetter,"D"); check(row.gear.tool.olderExpansion); rgb(row.gear.tool.borderColor,{.90,.15,.15})
        for _,role in ipairs({"accessory1","accessory2"}) do eq(active(db,specs[3]).fields[role].last.value.toolStat,nil); eq(row.gear[role].toolLetter,nil) end
        local reopened=drain(S.NewOpenJob(saved)).result; eq(rows(reopened)[1].gear.tool.toolLetter,"D")
        if schema==1 then
            widgets(e); local ui=NS.Dashboard.New(e,r); ui:Toggle(); local cell=ui.widgets[1].cells[V.index.Tool]
            eq(cell.statLetter:GetText(),"D"); check(cell.statLetter.shown); rgb(cell.itemBorder.style.SetBackdropBorderColor,{.90,.15,.15})
            e.IsShiftKeyDown=function() return true end; cell.scripts.OnEnter(cell)
            local text=table.concat(e.GameTooltip.lines); check(text:find("Deftness: 110 (observed total)",1,true)); check(text:find("Tool's own stat source C_Item.GetItemStats:unenchant-link-v1",1,true))
        end
    end
end)
case("Deftness failures ambiguity loading and changed instances preserve guards",function()
    for _,schema in ipairs({1,2}) do for _,mode in ipairs({"D+F","D+P","zero","negative","malformed","nil","error","loading","absent-api","arbitrary","wrong-info"}) do
        local db=database(schema); local e,st=api(specs[3]); local r=NS.Collectors.New(e,db); check(r:Scan(),r.reason)
        st.at=200; st.loading=mode=="loading"
        st.statsHook=function(link)
            if link==st.link then return {ITEM_MOD_DEFTNESS_SHORT=110} end
            if mode=="error" then error("PRIVATE") elseif mode=="nil" then return nil
            elseif mode=="D+F" then return {ITEM_MOD_DEFTNESS_SHORT=1,ITEM_MOD_FINESSE_SHORT=1}
            elseif mode=="D+P" then return {ITEM_MOD_DEFTNESS_SHORT=1,ITEM_MOD_PERCEPTION_SHORT=1}
            elseif mode=="malformed" then return {ITEM_MOD_DEFTNESS_SHORT="bad"}
            elseif mode=="negative" then return {ITEM_MOD_DEFTNESS_SHORT=-1}
            elseif mode=="arbitrary" then return {ITEM_MOD_ARBITRARY_SHORT=1}
            else return {ITEM_MOD_DEFTNESS_SHORT=0} end
        end
        if mode=="absent-api" then e.C_Item.GetItemStats=nil end
        if mode=="wrong-info" then st.returned="item:999:0:0" end
        check(r:Scan(),r.reason); local value=active(db,specs[3]).fields.tool.last.value
        eq(value.toolStat.value,"Deftness"); eq(value.toolStat.observedAt,100); eq(rows(db,r.fresh)[1].gear.tool.toolLetter,"D")
        -- A new instance with this failed optional query must NOT inherit D.
        st.loading=false; st.link="item:124:8003:0:0"; st.itemID=124; st.at=300
        check(r:Scan(),r.reason); value=active(db,specs[3]).fields.tool.last.value
        check(not value.toolStat or value.toolStat.value==nil,"new instance no prior D "..mode)
        eq(rows(db,r.fresh)[1].gear.tool.toolLetter,nil)
    end end
    for _,mode in ipairs({"link","source","context"}) do
        local db,saved=database(2); local e,st=api(specs[3]); local r=NS.Collectors.New(e,db); check(r:Scan(),r.reason)
        local frozen=unchanged(saved)
        st.statsHook=function(link)
            if link~=st.link then
                if mode=="link" then st.link="item:124:8003:0:0"; st.itemID=124
                elseif mode=="source" then st.source=2 else st.shown=false end
            end
            return {ITEM_MOD_DEFTNESS_SHORT=79}
        end
        if mode=="link" then
            local tool=r:Gear(23,"tool"); check(not tool.toolStat or tool.toolStat.value==nil); frozen()
        else check(not r:Scan(),"changed context/source discarded"); frozen() end
    end
end)
case("gathering enchant warnings observed absence freshness archive and secondary pending",function()
    local all={specs[1],specs[2],specs[3],specs[4],specs[5],unpack(old)}
    for _,s in ipairs(all) do for _,schema in ipairs({1,2}) do
        for _,mode in ipairs({"zero","empty","enchanted","unknown","loading","absent","conflicting-enchant"}) do
            local db=database(schema); local e,st=api(s)
            st.link=(mode=="zero" or mode=="conflicting-enchant") and "item:123:0:0:0" or mode=="empty" and "item:123::0:0" or st.link
            st.conflict=mode=="conflicting-enchant"
            st.unknown=mode=="unknown"; st.loading=mode=="loading"; st.exists=mode~="absent"
            local r=NS.Collectors.New(e,db); check(r:Scan(),r.reason)
            -- P04 ADAPT WARNING_ELIGIBILITY BEGIN
--[===============[P04 ORIGINAL BEGIN
            local row=rows(db,r.fresh)[1]; local enabled=s[3]~=5 and s[3]~=10
P04 ORIGINAL END]===============]
            local row=rows(db,r.fresh)[1]; local enabled=s[3]~=10
            -- P04 ADAPT WARNING_ELIGIBILITY END
            local missing=enabled and (mode=="zero" or mode=="empty")
            eq(row.enchantMissing==true,missing,"missing "..mode); eq(#rows(db,r.fresh,{attention="Missing enchant"}),missing and 1 or 0)
            if mode=="zero" or mode=="empty" then
                eq(active(db,s).fields.tool.last.value.enchant.present,false); eq(active(db,s).fields.tool.last.value.enchant.id,0)
                if missing then
                    check(row.enchantAttention); local seen=false
                    for _,w in ipairs(row.warnings) do if w.category=="Missing enchant" then check(w.fresh); eq(w.label,"confirmed Missing enchant"); seen=true end end; check(seen)
                    -- No freshness reattribution on reopened/offline history or failed read.
                    st.at=200; st.loading=true; check(r:Scan(),r.reason); row=rows(db,r.fresh)[1]
                    eq(row.gear.tool.state.fresh,false); check(row.gear.tool.state.stale)
                    local seenOld=false; for _,w in ipairs(row.warnings) do if w.category=="Missing enchant" then eq(w.fresh,false); eq(w.label,"last observed Missing enchant"); seenOld=true end end; check(seenOld)
                else check(not row.enchantAttention); eq(D.Capabilities(identity(s)).enchantAttentionMode,"pending") end
            end
            check(S.Archive(db,char.guid,s[1],300,"fixture")); local archive=rows(db,{}, {archived=true})[1]
            eq(#archive.warnings,0); eq(#rows(db,{}, {archived=true,attention="Missing enchant"}),0)
        end
    end end
end)
case("real mixed46character old and new rows filters sorting scrolling read-only",function()
    local db={schema=1,characters={}}; local all={unpack(old)}; for _,s in ipairs(specs) do all[#all+1]=s end
    for n=1,46 do
        local s=all[(n-1)%#all+1]
        check(S.Apply(db,{guid=n==46 and char.guid or "mixed"..n,name="Fixture"..n,realm="Fixture"},identity(s),{
            skill=C.Observation("observed",{skillLevel=n,maxSkillLevel=100,skillModifier=0},10,"fixture"),
            moxie=C.Observation("observed",{id=999,quantity=n*20,maxQuantity=0},11,"fixture")},12,"fixture"))
    end
    local verify=unchanged(db); local e,st=api(specs[1]); widgets(e)
    local r=NS.Collectors.New(e,db); local ui=NS.Dashboard.New(e,r); ui.options.sortColumn=V.index.Moxie; ui.options.sortDescending=true; ui:Toggle()
    eq(#ui.rows,46); eq(#ui.widgets,12); eq(ui.rows[1].guid,char.guid); check(ui.widgets[1].cells[V.index.Name].currentDot.shown)
    eq(ui.rowRange:GetText(),"Rows 1–12 of 46")
    for _,row in ipairs(ui.rows) do
        if row.professionFamily==5 or row.professionFamily==10 then eq(row.moxie,nil); eq(row.cells[V.index.Moxie],"—")
        else eq(row.moxie,row.sortValues[V.index.Moxie]) end
    end
    local last=math.huge; local unknown=false
    for n=2,#ui.rows do local v=ui.rows[n].moxie
        if v==nil then unknown=true else check(not unknown); check(v<=last); last=v end
    end
    ui.viewport.scripts.OnMouseWheel(ui.viewport,-1); eq(ui.offset,3)
    ui:QueueScroll(34); ui.frame.scripts.OnUpdate(ui.frame,.016); eq(ui.offset,34); eq(ui.rowRange:GetText(),"Rows 35–46 of 46")
    ui.options.attention="Moxie"; ui:Refresh()
    local expected=0; for n=31,46 do local family=all[(n-1)%#all+1][3]; if family~=5 and family~=10 then expected=expected+1 end end
    eq(#ui.rows,expected); for _,v in ipairs(ui.rows) do check(v.moxie>600) end
    ui.options.attention="Progression"; ui:Refresh(); eq(#ui.rows,46)
    for _,family in ipairs({5,10}) do ui.options.professionFamily=family; ui:Refresh(); check(#ui.rows>0); for _,v in ipairs(ui.rows) do eq(v.professionFamily,family); eq(v.moxie,nil) end end
    eq(st.currencyReads,0); eq(#st.queries,0); verify()
    print("P03 mixed workload46characters/46rows complete")
end)
case("schema2 actual widgets reopen reuse active archived and independent field history",function()
    local db,saved=database(2); local e,st=api(specs[3]); widgets(e)
    local r=NS.Collectors.New(e,db); check(r:Scan(),r.reason)
    check(S.Apply(db,char,identity(specs[3]),treeObservations({1121,1120,1119}),110,"fixture"))
    for n=4,5 do
        check(S.Apply(db,{guid="secondary"..n,name="Secondary"..n,realm="Fixture"},identity(specs[n]),{
            moxie=C.Observation("observed",{id=999,quantity=700},11,"schema2 masked source"),
            skill=C.Observation("observed",{skillLevel=1,maxSkillLevel=100,skillModifier=0},12,"independent skill")},12,"fixture"))
    end
    local verify=unchanged(saved)
    local ui=NS.Dashboard.New(e,r); ui.options.professionFamily=11; ui:Toggle(); settle(ui)
    local w=ui.widgets[1]; local cell=w.cells[V.index.Moxie]
    eq(w.cells[V.index.Tool].statLetter:GetText(),"D"); rgb(w.bars[1].style.SetStatusBarColor,palette[3]); eq(w.bars[1].value,.2)
    for n=4,5 do
        ui.options.professionFamily=specs[n][3]; ui:Refresh(); settle(ui); eq(ui.widgets[1],w)
        eq(cell.label:GetText(),"—"); rgb(cell.label.style.SetTextColor,{.45,.50,.58}); eq(w.cells[V.index.Tool].statLetter.shown,false)
        for _,bar in ipairs(w.bars) do eq(bar.shown,false) end
        e.IsShiftKeyDown=function() return false end; cell.scripts.OnEnter(cell); eq(table.concat(e.GameTooltip.lines),"Not applicable.")
        e.IsShiftKeyDown=function() return true end; cell.scripts.OnEnter(cell); check(table.concat(e.GameTooltip.lines):find("Underlying Moxie history: 700; ID 999",1,true))
    end
    verify()
    local reopened=drain(S.NewOpenJob(saved)).result; verify()
    check(S.Archive(reopened,"secondary5",2911,150,"fixture"))
    local frozen=unchanged(saved); r.db=reopened; ui.options.archived=true; ui:Refresh(); settle(ui)
    eq(#ui.rows,1); eq(cell.label:GetText(),"—"); eq(ui.rows[1].sortValues[V.index.Moxie],nil)
    e.IsShiftKeyDown=function() return true end; cell.scripts.OnEnter(cell)
    check(table.concat(e.GameTooltip.lines):find("Underlying Moxie history: 700; ID 999",1,true)); frozen()
    -- Ordinary same-profession rescans do not rewrite independent stored observations.
    local gathering=active(reopened,specs[3]); local moxAt=gathering.fields.moxie.last.observedAt
    local skillAt=gathering.fields.skill.last.observedAt; eq(moxAt,100); eq(skillAt,100)
    for _,balance in ipairs({0,600,601}) do
        local m=D.moxie[2917].id
        check(S.Apply(reopened,char,identity(specs[3]),{moxie=C.Observation("observed",{id=m,quantity=balance,maxQuantity=0},160,"fixture")},160,"fixture"))
        local v=rows(reopened,{}, {professionFamily=11})[1]; eq(v.moxie,balance); eq(v.cells[V.index.Moxie],tostring(balance))
        eq(active(reopened,specs[3]).fields.skill.last.observedAt,skillAt)
    end
end)
print(string.format("P03 additive: %d groups passed; %d failed; %d assertions (pure fixtures, not native evidence)",passed,failed,checks))
if failed>0 then os.exit(1) end
