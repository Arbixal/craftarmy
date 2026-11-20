-- P04 actual modules with private synthetic items/APIs/widgets only. IDs and stat
-- amounts below are NOT the user's Cooking enchant ID/rank or native base stats.
local function read(path)
    local f=assert(io.open(path,"r")); local text=f:read("*a"); f:close(); return text
end
-- Reuse helpers only, never execute or change previous runners' case lists.
local helpers=assert(read("tests/profession_completion.lua"):match("^(.-)\ncase%("))
local native=assert(read("tests/refresh_continuity.lua"):match("(local function widgets%(e%).-)\nlocal specs="))
local tests=[=[
local cooking,fishing=specs[4],specs[5]
case('P04 exact Cooking eligibility and Fishing still pending',function()
    eq(D.Capabilities(identity(cooking)).enchantAttentionMode,'enabled')
    eq(D.Capabilities(identity(fishing)).enchantAttentionMode,'pending')
    local count=0
    for id,m in pairs(D.expansions) do
        count=count+1
        local i={skillLineID=id,parentID=m.parentID,profession=m.profession,expansionID=11}
        local cap=D.Capabilities(i); check(cap)
        local secondary=id==2908 or id==2911
        local gathering=id==2912 or id==2916 or id==2917
        eq(cap.enchantAttentionMode,id==2911 and 'pending' or 'enabled')
        eq(cap.primary,not secondary); eq(cap.concentration,not secondary and not gathering)
        eq(cap.moxieMode,secondary and 'not_applicable' or 'enabled')
        eq(cap.knowledgeMode,secondary and 'not_applicable' or 'enabled')
        for _,key in ipairs({'skillLineID','parentID','profession','expansionID'}) do
            local bad=C.Copy(i); bad[key]=999; eq(D.Capabilities(bad),nil)
        end
        cap.enchantAttentionMode='bad'; cap.roles.tool=false
        eq(D.Capabilities(i).enchantAttentionMode,id==2911 and 'pending' or 'enabled')
        check(D.Capabilities(i).roles.tool)
    end; eq(count,13)
end)
local function missing(db,r,wanted,fresh)
    local row=rows(db,r and r.fresh)[1]; check(row,'actual view row')
    eq(row.enchantMissing==true,wanted,'Missing enchant value')
    eq(row.enchantAttention==true,wanted,'attention marker')
    eq(#rows(db,r and r.fresh,{attention='Missing enchant'}),wanted and 1 or 0,'filter')
    local count=0
    for _,w in ipairs(row.warnings) do if w.category=='Missing enchant' then
        count=count+1; eq(w.fresh,fresh); eq(w.label,fresh and 'confirmed Missing enchant' or 'last observed Missing enchant')
    end end; eq(count,wanted and 1 or 0)
    return row
end
local function make(schema,spec,link)
    local db,saved=database(schema); local e,st=api(spec or cooking)
    st.link=link or 'item:123:0:0:0'; st.expansion=11
    -- Deliberately SYNTHETIC multi-stat Cooking mixture. No claim about actual
    -- Cooking constituent keys/amounts; in particular M is NOT a guessed base stat.
    st.statsHook=function(link)
        if spec==fishing then return {ITEM_MOD_PERCEPTION_SHORT=17} end
        if link==NS.Collectors.ToolStatLink(st.link) then
            return {ITEM_MOD_RESOURCEFULNESS_SHORT=11,ITEM_MOD_CRAFTING_SPEED_SHORT=13}
        end
        return {ITEM_MOD_RESOURCEFULNESS_SHORT=11,ITEM_MOD_CRAFTING_SPEED_SHORT=13,ITEM_MOD_MULTICRAFT_SHORT=8}
    end
    local r=NS.Collectors.New(e,db)
    return db,saved,e,st,r
end
case('P04 actual observed Cooking absence warns fresh and matches filter',function()
    for _,schema in ipairs({1,2}) do for _,link in ipairs({'item:123:0:0:0','item:123::0:0'}) do
        local db=database(schema); local e,st=api(cooking); st.link=link
        local r=NS.Collectors.New(e,db); check(r:Scan(),r.reason)
        local tool=active(db,cooking).fields.tool.last.value
        eq(tool.enchant.present,false); eq(tool.enchant.id,0)
        local row=rows(db,r.fresh)[1]
        check(row.enchantMissing,'observed Cooking absence must warn')
        check(row.enchantAttention); eq(#rows(db,r.fresh,{attention='Missing enchant'}),1)
        local found=false
        for _,w in ipairs(row.warnings) do if w.category=='Missing enchant' then
            found=true; check(w.fresh); eq(w.label,'confirmed Missing enchant')
        end end; check(found)
    end end
end)
case('P04 positive Multicraft other and uncatalogued presence never missing',function()
    for _,schema in ipairs({1,2}) do for _,id in ipairs({8005,7977,987654}) do
        local db,saved,e,st,r=make(schema,cooking,'item:123:'..id..':0:0:0:0:0:0:0:0:0:2:42:43')
        check(r:Scan(),r.reason); local row=missing(db,r,false)
        local value=active(db,cooking).fields.tool.last.value
        eq(value.enchant.present,true); eq(value.enchant.id,id)
        eq(value.enchant.category,({[8005]='Multicraft',[7977]='Resourcefulness'})[id])
        check(row.gear.tool.enchanted); eq(row.gear.tool.toolLetter,nil,'no arbitrary multi-stat letter')
        eq(value.toolStat,nil,'no guessed single intrinsic category')
        eq(value.stats.ITEM_MOD_MULTICRAFT_SHORT,8,'observed total independent from neutral query')
        eq(value.stats.ITEM_MOD_RESOURCEFULNESS_SHORT,11)
        local neutral=NS.Collectors.ToolStatLink(st.link)
        eq(neutral,'item:123:0:0:0:0:0:0:0:0:0:0:2:42:43')
        local seen=false; for _,q in ipairs(st.queries) do if q==neutral then seen=true end end; check(seen)
        local verify=unchanged(saved); local reopened=drain(S.NewOpenJob(saved)).result
        missing(reopened,nil,false); verify()
    end end
end)
local unknownModes={'unknown-existence','loading','missing-link','missing-id','cache-error','item-error',
    'missing-cache-api','stats-error','conflict','malformed-enchant','missing-enchant-field','missing-slots','missing-tool'}
local function unavailable(e,st,mode)
    if mode=='unknown-existence' then st.unknown=true
    elseif mode=='loading' then st.loading=true
    elseif mode=='missing-link' then st.link=nil
    elseif mode=='missing-id' then st.itemID=nil
    elseif mode=='cache-error' then e.C_Item.IsItemDataCached=function() error('synthetic cache error') end
    elseif mode=='item-error' then e.C_Item.DoesItemExist=function() error('synthetic existence error') end
    elseif mode=='missing-cache-api' then e.C_Item.IsItemDataCached=nil
    elseif mode=='stats-error' then st.statsHook=function() error('synthetic stat error') end
    elseif mode=='conflict' then st.conflict=true
    elseif mode=='malformed-enchant' then st.link='item:123:bad:0:0'
    elseif mode=='missing-enchant-field' then st.link='item:123:'
    elseif mode=='missing-slots' then st.slots={}
    elseif mode=='missing-tool' then st.exists=false end
end
case('P04 unknown loading conflicts and absent Tool cannot fabricate absence',function()
    for _,schema in ipairs({1,2}) do for _,mode in ipairs(unknownModes) do
        local db,saved,e,st,r=make(schema); unavailable(e,st,mode)
        check(r:Scan(),mode..': '..tostring(r.reason)); local row=missing(db,r,false)
        check(not row.gear.tool.enchanted)
        if mode=='conflict' then
            local enchant=active(db,cooking).fields.tool.last.value.enchant
            eq(enchant.status,'unknown'); eq(enchant.present,nil)
            eq(enchant.reason,'link/typed-line conflict')
        end
        if mode=='missing-tool' then check(row.gear.tool.empty) end
        local verify=unchanged(saved); missing(drain(S.NewOpenJob(saved)).result,nil,false); verify()
    end end
end)
case('P04 same instance failure retains absent or positive history without fresh relabel',function()
    for _,schema in ipairs({1,2}) do for _,id in ipairs({0,8005,987654}) do
        for _,mode in ipairs({'loading','stats-error','cache-error'}) do
            local db,saved,e,st,r=make(schema,cooking,'item:123:'..id..':0:0')
            check(r:Scan(),r.reason); missing(db,r,id==0,id==0 and true or nil)
            st.at=200; unavailable(e,st,mode); check(r:Scan(),r.reason)
            local row=missing(db,r,id==0,false); local tool=active(db,cooking).fields.tool
            eq(tool.last.observedAt,100,'no borrowed successful timestamp')
            eq(tool.last.value.enchant.id,id); eq(tool.last.value.enchant.present,id>0)
            eq(row.gear.tool.state.fresh,false); check(row.gear.tool.state.stale)
            local verify=unchanged(saved); local reopened=drain(S.NewOpenJob(saved)).result
            missing(reopened,nil,id==0,false); verify()
        end
    end end
end)
case('P04 changed unidentifiable and removed instances cannot inherit prior absence or badge',function()
    for _,schema in ipairs({1,2}) do for _,id in ipairs({0,8005}) do
        for _,mode in ipairs({'new-loading','new-conflict','missing-link','unknown-existence','missing-slots','missing-tool'}) do
            local db,saved,e,st,r=make(schema,cooking,'item:123:'..id..':0:0')
            check(r:Scan(),r.reason); st.at=200
            if mode=='new-loading' then st.link='item:124:0:0:0'; st.itemID=124; st.loading=true
            elseif mode=='new-conflict' then st.link='item:124:0:0:0'; st.itemID=124; st.conflict=true
            else unavailable(e,st,mode) end
            check(r:Scan(),r.reason); local row=missing(db,r,false)
            check(not row.gear.tool.enchanted,'no borrowed badge')
            if mode=='new-loading' or mode=='new-conflict' then eq(row.gear.tool.value.itemID,124) end
            local verify=unchanged(saved); missing(drain(S.NewOpenJob(saved)).result,nil,false); verify()
        end
    end end
end)
case('P04 reopen archive and relearn never turn historical absence fresh',function()
    for _,schema in ipairs({1,2}) do
        local db,saved,e,st,r=make(schema); check(r:Scan(),r.reason); missing(db,r,true,true)
        local verify=unchanged(saved); missing(db,nil,true,false)
        local reopened=drain(S.NewOpenJob(saved)).result; missing(reopened,nil,true,false); verify()
        check(S.Archive(reopened,char.guid,cooking[1],200,'synthetic archive'))
        verify=unchanged(saved)
        local row=rows(reopened,{}, {archived=true})[1]; check(row.archived)
        eq(#row.warnings,0); check(not row.enchantAttention)
        eq(#rows(reopened,{}, {archived=true,attention='Missing enchant'}),0); verify()
        r.db=reopened; st.at=300; st.loading=true; check(r:Scan(),r.reason)
        missing(reopened,r,false)
        st.at=400; st.loading=false; check(r:Scan(),r.reason); missing(reopened,r,true,true)
        eq(active(reopened,cooking).generation,2)
    end
end)
case('P04 successful equipped transitions replace absence and positive history coherently',function()
    for _,schema in ipairs({1,2}) do
        local db,saved,e,st,r=make(schema)
        for n,field in ipairs({'0','8005','987654','','7977','0'}) do
            st.at=n*100; st.link='item:123:'..field..':0:0'
            check(r:Scan(),r.reason)
            local absent=field=='0' or field==''
            local row=missing(db,r,absent,absent and true or nil)
            eq(row.gear.tool.enchanted,not absent)
            local tool=active(db,cooking).fields.tool.last
            eq(tool.observedAt,st.at); eq(tool.value.link,st.link)
            eq(tool.value.enchant.present,not absent)
        end
        local verify=unchanged(saved); missing(drain(S.NewOpenJob(saved)).result,nil,true,false); verify()
    end
end)
case('P04 Tool absence independent from present accessory and accessory absence from enchant',function()
    for _,schema in ipairs({1,2}) do for _,emptySlot in ipairs({26,27}) do
        local db,saved,e,st,r=make(schema,cooking,'item:123:8005:0:0')
        e.C_Item.DoesItemExist=function(location) return location.slot~=emptySlot end
        check(r:Scan(),r.reason); local row=missing(db,r,false)
        eq(row.gear.tool.empty==true,emptySlot==26)
        eq(row.gear.accessory1.empty==true,emptySlot==27)
        eq(row.gear.tool.enchanted==true,emptySlot~=26)
        check(row.gear.accessory2.notApplicable)
        local verify=unchanged(saved); missing(drain(S.NewOpenJob(saved)).result,nil,false); verify()
    end end
end)
case('P04 Fishing pending includes confirmed absence unknown positive and historical data',function()
    for _,schema in ipairs({1,2}) do for _,mode in ipairs({'zero','empty','positive','loading','conflict','missing-tool'}) do
        local link=mode=='positive' and 'item:123:8005:0:0' or mode=='empty' and 'item:123::0:0' or nil
        local db,saved,e,st,r=make(schema,fishing,link)
        unavailable(e,st,mode); check(r:Scan(),r.reason); local row=missing(db,r,false)
        eq(D.Capabilities(identity(fishing)).enchantAttentionMode,'pending','not ineligible')
        for _,slot in ipairs(st.reads) do eq(slot,28,'rod only; no29/30/Head') end
        for _,role in ipairs({'accessory1','accessory2'}) do check(row.gear[role].notApplicable) end
        if mode=='zero' or mode=='empty' then eq(active(db,fishing).fields.tool.last.value.enchant.present,false) end
        if mode=='positive' then check(row.gear.tool.enchanted); eq(row.gear.tool.toolLetter,'P') end
        local verify=unchanged(saved); missing(drain(S.NewOpenJob(saved)).result,nil,false); verify()
        check(S.Archive(db,char.guid,fishing[1],200,'fixture'))
        verify=unchanged(saved); eq(#rows(db,{}, {archived=true})[1].warnings,0)
        eq(#rows(db,{}, {archived=true,attention='Missing enchant'}),0); verify()
    end end
end)
case('P04 Cooking slots and secondary N/A Skill semantics unchanged',function()
    for _,schema in ipairs({1,2}) do for _,s in ipairs({cooking,fishing}) do
        local db,saved,e,st,r=make(schema,s); check(r:Scan(),r.reason)
        local row=rows(db,r.fresh)[1]; local g=active(db,s)
        local seen={}; for _,slot in ipairs(st.reads) do seen[slot]=true; check(slot==(s==cooking and 26 or 28) or s==cooking and slot==27) end
        check(seen[s==cooking and 26 or 28]); if s==cooking then check(seen[27]); eq(g.fields.accessory1.last.value.slot,27) end
        eq(g.fields.tool.last.value.slot,s==cooking and 26 or 28)
        check(row.gear.accessory2.notApplicable); eq(g.fields.accessory2.attempt.status,'not_applicable')
        for _,column in ipairs({V.index.Moxie,V.index.Concentration,V.index.Knowledge,V.index.Unspent}) do
            eq(row.cells[column],'—'); eq(row.sortValues[column],nil)
        end
        eq(st.currencyReads,0); eq(#rows(db,r.fresh,{attention='Moxie'}),0)
        eq(#rows(db,r.fresh,{attention='Progression'}),1,'secondary below cap still included')
        eq(g.fields.skill.last.value.skillLevel,1); eq(g.fields.skill.last.value.maxSkillLevel,100)
        local verify=unchanged(saved); st.at=200
        e.C_TradeSkillUI.GetChildProfessionInfo=function() return {professionID=s[1],parentProfessionID=s[2],profession=s[3],isPrimaryProfession=false,skillLevel=1,maxSkillLevel=0} end
        check(not r:Scan(),'invalid cap remains rejected'); verify()
    end end
end)
case('P04 real native-compatible widgets warning filter and normal versus Shift hovers read only',function()
    for _,schema in ipairs({1,2}) do for _,mode in ipairs({'absence','positive','unknown','history','archive','fishing'}) do
        local s=mode=='fishing' and fishing or cooking
        local db,saved,e,st,r=make(schema,s,mode=='positive' and 'item:123:8005:0:0' or nil)
        if mode=='unknown' then st.loading=true end
        check(r:Scan(),r.reason)
        if mode=='history' then st.at=200; st.loading=true; check(r:Scan(),r.reason) end
        if mode=='archive' then check(S.Archive(db,char.guid,s[1],200,'fixture')) end
        widgets(e)
        local tip=e.GameTooltip; local hyperlink=tip.SetHyperlink; local clear=tip.ClearLines
        tip.SetHyperlink=function(self,link) hyperlink(self,link); self.lines={'Synthetic native item','Synthetic third-party line'} end
        tip.ClearLines=function(self) clear(self); self.link=nil end
        local attempts=0
        for _,key in ipairs({'Scan','Request','Context'}) do r[key]=function() attempts=attempts+1; error('UI acquisition forbidden') end end
        local verify=unchanged({saved,r.fresh}); local token=S.Token(db,char.guid,s[1])
        local queries,reads,currencies=#st.queries,#st.reads,st.currencyReads
        local ui=NS.Dashboard.New(e,r); ui.options.archived=mode=='archive'; ui:Toggle(); settle(ui)
        eq(#ui.rows,1); local w=ui.widgets[1]; local row=w.row
        local rowFrozen=unchanged(ui.rows)
        local cell=w.cells[V.index.Tool]
        if mode~='unknown' then eq(cell.label:GetText(),nil,'icon-only native blank label') end
        eq(cell.statLetter.shown,s==fishing,'no guessed Cooking single stat letter')
        eq(cell.enchantBadge.shown,mode=='positive')
        e.IsShiftKeyDown=function() return false end; cell.scripts.OnEnter(cell)
        if row.gear.tool.link then
            eq(tip.link,row.gear.tool.link); eq(#tip.lines,2,'native only normal hover')
            eq(tip.lines[1],'Synthetic native item'); eq(tip.lines[2],'Synthetic third-party line')
        else check(table.concat(tip.lines):find('unavailable',1,true),'unknown safety cue') end
        e.IsShiftKeyDown=function() return true end; cell.scripts.OnEnter(cell)
        local text=table.concat(tip.lines,'\n')
        if mode=='absence' then check(text:find('confirmed Missing enchant',1,true))
        elseif mode=='history' then check(text:find('last observed Missing enchant',1,true)); check(not text:find('confirmed Missing enchant',1,true))
        else check(not text:find('Missing enchant',1,true),'no false Shift warning') end
        if mode=='positive' then check(text:find('Multicraft',1,true)); check(text:find('amount/rank unknown',1,true)) end
        cell.scripts.OnLeave(cell); check(not tip.shown)
        check(ui:Render()); rowFrozen()
        ui.options.attention='Missing enchant'; ui:Refresh(); settle(ui)
        eq(#ui.rows,(mode=='absence' or mode=='history') and 1 or 0)
        ui.options.attention='Progression'; ui:Refresh(); settle(ui); eq(#ui.rows,mode=='archive' and 0 or 1)
        ui.options.attention='All'; ui.options.sortColumn=V.index.Enchant; ui:Refresh(); settle(ui)
        eq(#ui.rows,1); ui:ScrollTo(0); ui:Render()
        verify(); rowFrozen(); eq(S.Token(db,char.guid,s[1]),token)
        eq(attempts,0); eq(#st.queries,queries); eq(#st.reads,reads); eq(st.currencyReads,currencies)
    end end
end)
print(string.format('P04 additive: %d groups passed; %d failed; %d assertions (synthetic, not native evidence)',passed,failed,checks))
if failed>0 then os.exit(1) end
]=]
assert(loadstring(helpers..'\n'..native..'\n'..tests,'@P04-cooking-enchant'))()
