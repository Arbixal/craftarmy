-- R04: real Dashboard/Storage/collector paths with synthetic native-compatible
-- widgets. Not a native call trace, timing result or estimate-accuracy proof.
local function read(path)
    local f=assert(io.open(path,"r")); local text=f:read("*a"); f:close(); return text
end
-- Reuse helpers, never execute, rewrite or skip any existing runner's cases.
local refresh=assert(read("tests/refresh_continuity.lua"):match("^(.-)\ncase%("))
local ordinary=[=[
local function blankGear(ui,row,role)
    ui.rows[row].gear[role]={exists=true,icon=123}
    check(ui:Render(),'actual icon-only Render')
    local column=({accessory1=V.index.Accessory1,accessory2=V.index.Accessory2,tool=V.index.Tool})[role]
    local cell=ui.widgets[row-ui.offset].cells[column]
    eq(cell.label.text,'','Render deliberately cleared gear label')
    eq(cell.label:GetText(),nil,'native empty FontString')
    return cell
end
case('R04 FontString no-text and intentional-empty contract only',function()
    local e={}; widgets(e)
    local label=e.UIParent:CreateFontString()
    eq(label:GetText(),nil,'no text yet')
    label:SetText(''); eq(label:GetText(),nil,'intentional empty')
    label:SetText('text'); eq(label:GetText(),'text')
    label:SetText('0'); eq(label:GetText(),'0')
    local edit=e.CreateFrame('EditBox'); edit:SetText(''); eq(edit:GetText(),'','other widgets unchanged')
    label.text=false; eq(label:GetText(),false,'invalid values not coerced by mock')
end)
case('R04 icon-only actual Render survives every ordinary pending callback',function()
    local ui,e,c,st,root,settle,step=fixture()
    c.reason='Open your own profession to refresh'
    blankGear(ui,1,'accessory1')
    pending(ui); local dot,estimate,label=indicators(ui)
    local verify=unchanged({root,c.fresh,ui.rows})
    local token=S.Token(c.db,'own',2906)
    frozenCalls(dot,estimate,label,function()
        ui:Refresh()
        check(dot.shown and estimate.shown,'pending dot='..tostring(dot.shown)..'; estimate='..tostring(estimate.shown))
    end)
    check(ui.buildJob and ui.retained,'meaningful pending replacement')
    pending(ui)
    while ui.buildJob do
        local job=ui.buildJob
        frozenCalls(dot,estimate,label,function() ui.frame.scripts.OnUpdate(ui.frame,.016); step() end,
            function() return ui.buildJob==job end)
        if ui.buildJob==job then pending(ui) end
    end
    pending(ui); verify(); eq(S.Token(c.db,'own',2906),token)
end)
local function bothFrozen(ui,fn,stillPending)
    local a,b=ui.widgets[1],ui.widgets[2]
    frozenCalls(a.cells[V.index.Name].currentDot,a.cells[V.index.Concentration].estimate,a.cells[V.index.Concentration].label,function()
        frozenCalls(b.cells[V.index.Name].currentDot,b.cells[V.index.Concentration].estimate,b.cells[V.index.Concentration].label,fn,stillPending)
    end,stillPending)
end
case('R04 early late accessory Tool and hidden blank labels preserve both own professions',function()
    for _,row in ipairs({1,12}) do for _,mode in ipairs({'accessory1','accessory2','tool','empty','hidden','no-text'}) do
        local ui,e,c,st,root,settle,step=fixture()
        if mode=='hidden' then
            ui.rows[row].cells[V.index.Stat]=''
            check(ui:Render()); local cell=ui.widgets[row].cells[V.index.Stat]
            check(cell.hiddenColumn and not cell.label.shown,'hidden label still inspected')
            eq(cell.label:GetText(),nil)
        elseif mode=='no-text' then
            blankGear(ui,row,'tool')
            ui.widgets[row].cells[V.index.Tool].label.text=nil
            eq(ui.widgets[row].cells[V.index.Tool].label:GetText(),nil)
        elseif mode=='empty' then
            ui.rows[row].gear.accessory1={empty=true}; check(ui:Render())
            eq(ui.widgets[row].cells[V.index.Accessory1].label:GetText(),nil)
        else blankGear(ui,row,mode) end
        pending(ui); local oldRows=ui.rows
        local verify=unchanged({root,c.fresh,oldRows})
        local tokens={}; for _,r in ipairs(oldRows) do tokens[r.key]=S.Token(c.db,r.guid,r.id) end
        bothFrozen(ui,function() ui:Refresh() end); pending(ui)
        local text=ui.widgets[1].cells[V.index.Concentration].label.text
        st.at=300
        while ui.buildJob do
            local job=ui.buildJob
            bothFrozen(ui,function() ui.frame.scripts.OnUpdate(ui.frame,.016); step() end,function() return ui.buildJob==job end)
            if ui.buildJob==job then pending(ui); eq(ui.widgets[1].cells[V.index.Concentration].label.text,text) end
        end
        pending(ui); eq(ui.widgets[1].cells[V.index.Concentration].label.text,'~520/1000')
        check(ui.rows~=oldRows,'normal replacement publication'); verify()
        for _,r in ipairs(oldRows) do eq(S.Token(c.db,r.guid,r.id),tokens[r.key],'all46 row tokens preserved') end
    end end
end)
case('R04 mixed46 blank gear frozen labels bounded validation and historical controls',function()
    local ui,e,c,st,root,settle,step=fixture()
    for n,r in ipairs(ui.rows) do
        r.gear.accessory1={exists=true,icon=123}; r.gear.accessory2={empty=true}
        r.gear.tool=n%2==0 and {exists=true,icon=456,toolLetter='R'} or {exists=true,icon=456}
    end
    ui.rows[12].cells[V.index.Unspent]='|cffffbb00!|r 7'
    check(ui:Render()); pending(ui)
    local verify=unchanged({root,c.fresh,ui.rows}); local active,estimates=0,0
    local guids,clocks=st.guidReads,st.clockReads
    withHook(S,'Active',function(old) return function(...) active=active+1; return old(...) end end,function()
    withHook(V,'ConcentrationEstimate',function(old) return function(...) estimates=estimates+1; return old(...) end end,function()
        bothFrozen(ui,function() ui:Refresh() end)
        eq(active,12,'only visible active validation'); eq(estimates,0,'no new prediction')
        eq(st.guidReads,guids+1); eq(st.clockReads,clocks+2,'unchanged existing refresh clocks')
        local job,steps=ui.buildJob,ui.buildJob.steps
        for n=1,3 do bothFrozen(ui,function() ui:Refresh() end) end
        eq(ui.buildJob,job); eq(job.steps,steps); eq(active,12); eq(estimates,0)
        eq(st.guidReads,guids+4); eq(st.clockReads,clocks+2)
    end) end)
    eq(ui.widgets[12].cells[V.index.Unspent].label.text,'|cff999999!|r 7','warning still demoted')
    eq(ui:ActionsReady(),false)
    for _,button in ipairs(ui.footer) do eq(button.style.SetEnabled[1],false) end
    local cc=ui.widgets[1].cells[V.index.Concentration]; cc.scripts.OnEnter(cc)
    check(table.concat(e.GameTooltip.lines,'\n'):find('Previous saved values pending replacement',1,true),'historical hover')
    local details=0; ui.details={Open=function() details=details+1 end,Refresh=function() end}
    local pc=ui.widgets[1].cells[V.index.Profession]; pc.scripts.OnMouseDown(pc,'LeftButton'); eq(details,0)
    while ui.buildJob do
        local job=ui.buildJob
        bothFrozen(ui,step,function() return ui.buildJob==job end)
        if ui.buildJob==job then pending(ui) end
    end
    pending(ui); verify()
end)
case('R04 real GetText throws and nonnil invalid types revoke paint without retry revival',function()
    for _,row in ipairs({1,12}) do for _,mode in ipairs({'throw','false','number','table','function'}) do
        local ui,e,c,st,root,settle=fixture(); local cell=blankGear(ui,row,'tool')
        local verify=unchanged({root,c.fresh,ui.rows}); local fired=0
        withHook(cell.label,'GetText',function() return function()
            fired=fired+1
            if mode=='throw' then error('genuine synthetic GetText fault') end
            return ({['false']=false,number=0,table={},['function']=function() end})[mode]
        end end,function() check(pcall(ui.Refresh,ui),'protected fault'); fallen(ui) end)
        check(fired>0,mode..' dispatched'); verify()
        ui:Refresh(); fallen(ui); verify()
        settle(); pending(ui)
    end end
end)
case('R04 nil GetText reentry cannot touch newer paint job status hover or scroll',function()
    for _,row in ipairs({1,12}) do for _,mode in ipairs({'same-paint','new-completed','new-pending'}) do
        local ui,e,c,st,root,settle=fixture(); local cell=blankGear(ui,row,'accessory1')
        local fired=false; local rows,job,status,hover,counts
        local verify=unchanged({root,c.fresh,ui.rows})
        withHook(cell.label,'GetText',function(old) return function(self)
            eq(old(self),nil,'native successful blank read')
            if not fired then
                fired=true
                if mode=='same-paint' then ui:Render()
                else ui.options.sortColumn=V.index.Name; ui:Refresh(); if mode=='new-completed' then settle() end end
                rows,job,status=ui.rows,ui.buildJob,ui.reason.text
                ui:QueueScroll(2)
                local cc=ui.widgets[2].cells[V.index.Concentration]; cc.scripts.OnEnter(cc)
                hover=table.concat(e.GameTooltip.lines,'\n'); check(e.GameTooltip.shown)
                counts={}
                for _,w in ipairs(ui.widgets) do for _,c in ipairs(w.cells) do
                    for _,key in ipairs({'label','currentDot','estimate'}) do
                        local widget=c[key]; if widget then counts[widget]=#widget.calls end
                    end
                end end
            end
            return nil
        end end,function() ui:Refresh() end)
        check(fired); eq(ui.rows,rows); eq(ui.buildJob,job); eq(ui.reason.text,status)
        check(e.GameTooltip.shown,'new hover remains'); eq(table.concat(e.GameTooltip.lines,'\n'),hover)
        for widget,count in pairs(counts) do eq(#widget.calls,count,'no stale paint after post-GetText ownership check') end
        verify(); ui.frame.scripts.OnUpdate(ui.frame,.016); eq(ui.offset,2,'new queued scroll remains owned')
    end end
end)
]=]
local footer=[=[
print(string.format('R04 %s: %d groups passed; %d failed; %d assertions (synthetic, not native evidence)',suite,passed,failed,checks))
return passed,failed,checks
]=]
local p,f,n=assert(loadstring(refresh..'\nlocal suite="ordinary"\n'..ordinary..footer,'R04-ordinary'))()
local collectionSource=read('tests/collection_continuity.lua')
local collectionHelpers=assert(collectionSource:match('local tests=%[=%[\n(.-)\ncase%('))
local expansionHelpers=assert(read('tests/profession_expansion.lua'):match('^(.-)\ncase%('))
local native=assert(read('tests/refresh_continuity.lua'):match('(local function widgets%(e%).-)\nlocal specs='))
local collection=[=[
local function frozenStep(ui,w,fn)
    local cell=w.cells[V.index.Concentration]; local dot=w.cells[V.index.Name].currentDot
    local dn,en,ln=#dot.calls,#cell.estimate.calls,#cell.label.calls
    local job,text=ui.buildJob,cell.label.text
    fn()
    if ui.buildJob~=job then return end -- Normal publication owns its new paint.
    for _,pair in ipairs({{dot,dn},{cell.estimate,en}}) do
        for n=pair[2]+1,#pair[1].calls do
            local x=pair[1].calls[n]
            check(x[1]~='Hide' and x[1]~='ClearAllPoints' and x[1]~='SetPoint' and x[1]~='SetSize' and
                not(x[1]=='SetShown' and x[2]==false),'no eligible pending decoration reset')
        end
    end
    for n=ln+1,#cell.label.calls do check(cell.label.calls[n][1]~='SetText','no pending approximate label reset') end
    eq(cell.label.text,text)
end
local function blankScanned(w)
    for _,col in ipairs({V.index.Accessory1,V.index.Accessory2,V.index.Tool}) do
        local cell=w.cells[col]
        check(cell.itemIcon.shown,'actual collected icon painted')
        eq(cell.label.text,''); eq(cell.label:GetText(),nil,'actual scanned icon label reads native nil')
    end
end
case('R04 real closed-profession Scan raw status retains both while building saved view',function()
    local ui,r,st,e,root,cmd,scan,frame,finish,w,step=setup()
    blankScanned(w); indicators(w,true,true)
    st.shown=false
    local verify=unchanged(root); local token=S.Token(r.db,'PRIVATE-GUID',2913)
    noReset(w,function() check(not r:Scan(),'actual closed-profession Scan failure') end,true)
    eq(r.reason,'Open your own profession to refresh'); eq(r:DashboardHandoff(),nil)
    check(ui.retained and ui.buildJob,'ordinary saved replacement, not failure status')
    check(ui:DisplayStatus():find('Building saved dashboard incrementally',1,true))
    e.IsShiftKeyDown=function() return true end; ui.statusArea.scripts.OnEnter(ui.statusArea)
    local text=table.concat(e.GameTooltip.lines,'\n')
    check(text:find('Raw status: Open your own profession to refresh',1,true),'screenshot raw status')
    local verifyRows=unchanged({r.fresh,ui.rows})
    while ui.buildJob do
        local job=ui.buildJob
        frozenStep(ui,w,frame)
        if ui.buildJob==job then indicators(w,true,true) end
        frozenStep(ui,w,function() if ui.buildJob then step() end end)
        if ui.buildJob==job then indicators(w,true,true) end
    end
    indicators(w,true,true); verify(); verifyRows(); eq(S.Token(r.db,'PRIVATE-GUID',2913),token)
end)
case('R04 real requested and successful Scan handoffs with native blank labels',function()
    for _,order in ipairs({'frame','build','scan'}) do
        local ui,r,st,e,root,cmd,scan,frame,finish,w,step=setup()
        blankScanned(w); indicators(w,true,true); noReset(w,function() ui:Refresh() end,true)
        cmd:Event('CURRENCY_DISPLAY_UPDATE',777)
        local verify=unchanged({root,r.fresh,ui.rows}); local token=S.Token(r.db,'PRIVATE-GUID',2913)
        if order=='frame' then noReset(w,frame,true) elseif order=='build' then noReset(w,step,true) end
        indicators(w,true,true); verify(); eq(S.Token(r.db,'PRIVATE-GUID',2913),token)
        local oldRows=ui.rows; local verifyRows=unchanged(oldRows)
        local start=r.StartLoads
        r.StartLoads=function(self,...) st.at=220; return start(self,...) end
        st.at=210; st.quantity=150; noReset(w,scan)
        r.StartLoads=start
        indicators(w,true,true,'~160/1000'); eq(ui.rows,oldRows); verifyRows()
        local after=unchanged({root,r.fresh,oldRows}); local newToken=S.Token(r.db,'PRIVATE-GUID',2913)
        while ui.buildJob do
            local job=ui.buildJob
            frozenStep(ui,w,frame)
            if ui.buildJob==job then indicators(w,true,true,'~160/1000') end
            local last=ui.buildJob
            frozenStep(ui,w,step)
            if ui.buildJob==last then
                indicators(w,true,true,'~160/1000')
            end
        end
        indicators(w,true,true,'~160/1000'); after(); verifyRows(); eq(S.Token(r.db,'PRIVATE-GUID',2913),newToken)
    end
end)
case('R04 blank-label requested handoff stays bounded with no UI acquisition',function()
    local ui,r,st,e,root,cmd,scan,frame,finish,w=setup()
    blankScanned(w); ui:Refresh(); cmd:Event('CURRENCY_DISPLAY_UPDATE',777)
    local active,estimates,guids,clocks=0,0,0,0
    local verify=unchanged({root,r.fresh,ui.rows}); local token=S.Token(r.db,'PRIVATE-GUID',2913)
    local reads=#st.reads; local currencies=st.currencyReads; local graph=st.graphReads
    local trapped,acquisitions={},0
    for _,object in ipairs({e.C_TradeSkillUI,e.C_Item,e.C_ProfSpecs,e.C_Traits,e.C_CurrencyInfo,e.C_TooltipInfo}) do
        for key,value in pairs(object) do if type(value)=='function' then trapped[#trapped+1]={object,key} end end
    end
    for _,key in ipairs({'Scan','Context','Request'}) do trapped[#trapped+1]={r,key} end
    local function noAcquisition(n,fn)
        local pair=trapped[n]
        if not pair then return fn() end
        hook(pair[1],pair[2],function() return function() acquisitions=acquisitions+1; error('unexpected UI acquisition '..pair[2]) end end,
            function() noAcquisition(n+1,fn) end)
    end
    noAcquisition(1,function()
    hook(S,'Active',function(old) return function(...) active=active+1; return old(...) end end,function()
    hook(V,'ConcentrationEstimate',function(old) return function(...) estimates=estimates+1; return old(...) end end,function()
    hook(e,'UnitGUID',function(old) return function(...) guids=guids+1; return old(...) end end,function()
    hook(r,'Now',function(old) return function(...) clocks=clocks+1; return old(...) end end,function()
        noReset(w,frame,true); eq(active,12); eq(estimates,0); eq(guids,1); eq(clocks,2)
        local job,steps=ui.buildJob,ui.buildJob.steps
        for n=1,3 do noReset(w,function() frame(); ui:Render() end,true) end
        eq(active,12); eq(estimates,0); eq(ui.buildJob,job); eq(job.steps,steps)
    end) end) end) end)
    end)
    eq(acquisitions,0,'no attempted acquisition, even protected errors')
    eq(#st.reads,reads); eq(st.currencyReads,currencies); eq(st.graphReads,graph)
    verify(); eq(S.Token(r.db,'PRIVATE-GUID',2913),token)
end)
]=]
local cp,cf,cn=assert(loadstring(expansionHelpers..'\n'..native..'\n'..collectionHelpers..'\nlocal suite="collection"\n'..collection..footer,'R04-collection'))()
p,f,n=p+cp,f+cf,n+cn
print(string.format('R04 total: %d groups passed; %d failed; %d assertions',p,f,n))
if f>0 then os.exit(1) end
