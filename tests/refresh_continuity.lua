-- R02 synthetic callbacks/widgets only: not native timing, trigger or estimate-accuracy evidence.
local NS={}
for _,name in ipairs({"Core","Storage","Data","Knowledge","Collectors","KnowledgeCheck","Details","ViewModel","Dashboard","SelfTests","Commands"}) do
    assert(loadfile("CraftArmy/"..name..".lua"))("CraftArmy",NS)
end
local C,S,V=NS.Core,NS.Storage,NS.ViewModel
local checks,passed,failed=0,0,0
local function check(ok,why) checks=checks+1; assert(ok,why or "assertion failed") end
local function eq(a,b,why) check(a==b,(why or "equality")..": "..tostring(a).." ~= "..tostring(b)) end
local function case(name,fn)
    local ok,why=xpcall(fn,debug.traceback)
    if ok then passed=passed+1; print("PASS R02 "..name)
    else failed=failed+1; print("FAIL R02 "..name..": "..tostring(why)) end
end
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
local function widgets(e)
    local m={}
    local function new(kind,parent) return setmetatable({kind=kind,parent=parent,shown=true,scripts={},style={},points={},width=0,height=14,text="",lines={},calls={}}, {__index=m}) end
    local function call(w,key,...)
        w.calls[#w.calls+1]={key,...}
        if w.hook then w.hook(w,key,...) end
    end
    function m:CreateTexture() return new("Texture",self) end
    function m:CreateFontString() return new("FontString",self) end
    function m:SetText(v) call(self,"SetText",v); eq(type(v),"string"); self.text=v end
    function m:GetText() call(self,"GetText"); if self.kind=="FontString" and self.text=="" then return nil end; return self.text end
    function m:SetScript(k,v) call(self,"SetScript",k); self.scripts[k]=v end
    function m:SetSize(w,h) call(self,"SetSize",w,h); self.width=w; self.height=h end
    function m:SetWidth(w) call(self,"SetWidth",w); self.width=w end
    function m:SetHeight(h) call(self,"SetHeight",h); self.height=h end
    function m:GetWidth() call(self,"GetWidth"); return self.width end
    function m:GetHeight() call(self,"GetHeight"); return self.height end
    function m:SetScale(v) call(self,"SetScale",v); self.scale=v end
    function m:GetFrameLevel() return 1 end
    function m:SetPoint(...) call(self,"SetPoint",...); self.points[#self.points+1]={...} end
    function m:ClearAllPoints() call(self,"ClearAllPoints"); self.points={} end
    function m:SetAllPoints(v) self.allPoints=v or self.parent end
    function m:Show() call(self,"Show"); self.shown=true end
    function m:Hide() call(self,"Hide"); self.shown=false end
    function m:IsShown() call(self,"IsShown"); return self.shown end
    function m:SetShown(v) call(self,"SetShown",v); self.shown=v end
    function m:SetTexture(v) self.texture=v; return true end
    function m:SetAtlas(v) self.atlas=v end
    function m:SetFont(...) self.font={...} end
    function m:GetStatusBarTexture() if not self.textureWidget then self.textureWidget=new("Texture",self) end; return self.textureWidget end
    function m:SetValue(v) call(self,"SetValue",v); self.value=v; if self.kind=="Slider" and self.scripts.OnValueChanged then self.scripts.OnValueChanged(self,v) end end
    function m:SetMinMaxValues(a,b) self.minimum=a; self.maximum=b end
    function m:SetThumbTexture(v) self.thumb=new("Texture",self); self.thumb:SetTexture(v) end
    function m:GetThumbTexture() return self.thumb end
    function m:GetStringWidth() call(self,"GetStringWidth"); return #self.text*6 end
    function m:ClearLines() self.lines={} end
    function m:SetHyperlink(v) self.link=v end
    function m:AddLine(v) self.lines[#self.lines+1]=v end
    function m:SetDefaultText(v) self.defaultText=v end
    function m:SetupMenu(fn) fn(self,{CreateRadio=function() end}) end
    for _,key in ipairs({"SetMovable","EnableMouse","RegisterForDrag","StartMoving","StopMovingOrSizing","EnableMouseWheel",
        "SetAutoFocus","ClearFocus","SetHighlightTexture","SetJustifyH","SetWordWrap","SetStatusBarTexture","SetStatusBarColor",
        "SetColorTexture","SetBackdrop","SetBackdropColor","SetTextColor","SetFrameStrata","SetToplevel","Raise","SetBackdropBorderColor",
        "SetOrientation","SetValueStep","SetObeyStepOnDrag","SetEnabled","SetOwner","SetFrameLevel"}) do
        local k=key; m[k]=function(self,...) call(self,k,...); self.style[k]={...} end
    end
    e.UIParent=new("Frame"); e.UIParent:SetSize(1920,1080); e.GameTooltip=new("Tooltip")
    e.CreateFrame=function(kind,_,parent) return new(kind,parent) end
end
local specs={{2913,773,13},{2906,171,3},{2912,182,4},{2916,186,6},{2917,393,11},{2908,185,5},{2911,356,10}}
local function identity(s) return {skillLineID=s[1],parentID=s[2],profession=s[3],expansionID=11} end
local function observation(q,at)
    return C.Observation("observed",{id=777,quantity=q or 500,maxQuantity=1000,rechargingCycleDurationMS=100000,rechargingAmountPerCycle=10},at or 100,"fixture concentration")
end
local function fixture(noConcentration)
    local db,root=S.New()
    local state={guid="own",at=200,guidReads=0,clockReads=0,combat=false}
    local e={UnitGUID=function() state.guidReads=state.guidReads+1; return state.guid end,
        InCombatLockdown=function() return state.combat end}
    widgets(e)
    for n=1,46 do
        local spec=specs[(n-1)%#specs+1]
        local char={guid=n<=2 and "own" or "alt"..n,name="Fixture"..n,realm="Fixture"}
        local fields={skill=C.Observation("observed",{skillLevel=1,maxSkillLevel=100,skillModifier=0},100,"fixture")}
        if not noConcentration then fields.concentration=observation() end
        check(S.Apply(db,char,identity(spec),fields,100,"fixture"))
    end
    local collector={db=db,fresh={},serial=0,revision=0,reason="fixture"}
    function collector:Now() state.clockReads=state.clockReads+1; return state.at end
    for _,k in ipairs({"Scan","Context","Request"}) do collector[k]=function() error("unexpected acquisition "..k) end end
    local ui=NS.Dashboard.New(e,collector)
    ui:Toggle()
    local function step()
        local fn=ui.buildDriver and ui.buildDriver.scripts.OnUpdate
        check(type(fn)=="function","actual production driver")
        fn(ui.buildDriver,.016)
    end
    local function settle(after)
        local frames=0
        while ui.buildJob do frames=frames+1; check(frames<10000,"bounded synthetic callback count"); step(); if after then after() end end
    end
    settle(); eq(#ui.rows,46); eq(#ui.widgets,12)
    return ui,e,collector,state,root,settle,step
end
local function indicators(ui)
    local w=ui.widgets[1]; eq(w.row.guid,"own")
    return w.cells[V.index.Name].currentDot,w.cells[V.index.Concentration].estimate,w.cells[V.index.Concentration].label
end
local function visible(w) return w.shown and (not w.parent or visible(w.parent)) end
local function fallen(ui)
    for _,w in ipairs(ui.widgets) do
        check(not visible(w) or not w.cells[V.index.Name].currentDot.shown,"unsafe dot cleared")
        check(not visible(w) or not w.cells[V.index.Concentration].estimate.shown,"unsafe estimate cleared")
    end
end
local function pending(ui,estimateExpected)
    for n=1,2 do
        local w=ui.widgets[n]; eq(w.row.guid,"own")
        check(visible(w),"own row visible"); check(w.cells[V.index.Name].currentDot.shown,"own dot visible")
        eq(w.cells[V.index.Concentration].estimate.shown,estimateExpected~=false,"own estimate")
    end
end
local function write(c,key,obs,guid,spec)
    return check(S.Apply(c.db,{guid=guid or "own",name="Fixture",realm="Fixture"},identity(spec or specs[2]),{[key]=obs},201,"fixture"))
end
local function withHook(object,key,fn,body)
    local old=object[key]; object[key]=fn(old)
    local ok,why=xpcall(body,debug.traceback); object[key]=old
    assert(ok,why)
end
local function frozenCalls(dot,estimate,label,fn,stillPending)
    local d,e,l=#dot.calls,#estimate.calls,#label.calls
    local text=label.text
    fn()
    if stillPending and not stillPending() then return end
    for n=d+1,#dot.calls do
        local x=dot.calls[n]
        check(x[1]~="Hide" and x[1]~="IsShown" and x[1]~="ClearAllPoints" and x[1]~="SetPoint" and x[1]~="SetText" and not (x[1]=="SetShown" and x[2]==false),"no dot demotion/reset/query")
    end
    for n=e+1,#estimate.calls do
        local x=estimate.calls[n]
        check(x[1]~="Hide" and x[1]~="ClearAllPoints" and x[1]~="SetPoint" and x[1]~="SetSize" and not (x[1]=="SetShown" and x[2]==false),"no estimate demotion/reset")
    end
    for n=l+1,#label.calls do check(label.calls[n][1]~="SetText","no approximate label reset") end
    eq(label.text,text)
end
case("ordinary refresh dot visible at every pending callback",function()
    local ui,e,c,st,root,settle=fixture(); local dot=indicators(ui)
    check(dot:IsShown(),"initial completed dot"); local verify=unchanged(root)
    ui:Refresh(); check(dot:IsShown(),"unchanged pending dot must not disappear")
    settle(function() check(dot:IsShown(),"dot at callback return") end); verify()
end)
case("invalidated new contexts coalesce frozen paints and keep saved-root and tokens",function()
    for _,mode in ipairs({"serial","revision","fresh","unrelated-own","unrelated-alt","unchanged"}) do
        local ui,e,c,st,root,settle,step=fixture()
        local dot,estimate,label=indicators(ui)
        if mode=="serial" then c.serial=c.serial+1 elseif mode=="revision" then c.revision=c.revision+1
        elseif mode=="fresh" then c.fresh={}
        elseif mode=="unrelated-own" then write(c,"unspent",C.Observation("observed",7,201,"fixture"))
        elseif mode=="unrelated-alt" then write(c,"unspent",C.Observation("observed",7,201,"fixture"),"alt3",specs[3]) end
        local token=S.Token(c.db,"own",2913); local ownToken=S.Token(c.db,"own",2906)
        local verify=unchanged({root,c.fresh,ui.rows})
        local guidReads,clockReads=st.guidReads,st.clockReads
        local activeReads=0
        withHook(S,"Active",function(old) return function(...) activeReads=activeReads+1; return old(...) end end,function()
            frozenCalls(dot,estimate,label,function() ui:Refresh() end)
            check(activeReads<=12,"bounded eligibility Active reads"); eq(activeReads,12)
            local job=ui.buildJob; local steps=job.steps
            for n=1,3 do
                frozenCalls(dot,estimate,label,function() ui:Refresh() end)
                eq(ui.buildJob,job); eq(job.steps,steps); eq(activeReads,12,"coalescing no repeated active reads")
            end
        end)
        eq(st.guidReads,guidReads+4); eq(st.clockReads,clockReads+2,"one pending Render clock + one job clock")
        local oldText=label.text
        st.at=300
        pending(ui)
        while ui.buildJob do
            local oldJob=ui.buildJob
            frozenCalls(dot,estimate,label,step,function() return ui.buildJob==oldJob end)
            if ui.buildJob==oldJob then pending(ui); eq(label.text,oldText) end
        end
        pending(ui); eq(label.text,"~520/1000"); eq(S.Token(c.db,"own",2913),token); eq(S.Token(c.db,"own",2906),ownToken); verify()
    end
end)
case("changed successful or failed concentration provenance rejects estimate only",function()
    for _,mode in ipairs({"quantity","cap","duration","rate","currency","observed-time","attempt-time","source","build","failed","unknown"}) do
        local ui,e,c,st,root,settle=fixture()
        local obs=observation()
        if mode=="quantity" then obs.value.quantity=450 elseif mode=="cap" then obs.value.maxQuantity=1100
        elseif mode=="duration" then obs.value.rechargingCycleDurationMS=200000
        elseif mode=="rate" then obs.value.rechargingAmountPerCycle=20 elseif mode=="currency" then obs.value.id=778
        elseif mode=="observed-time" then obs=observation(500,101)
        elseif mode=="attempt-time" then obs.attemptedAt=101
        elseif mode=="source" then obs.source="new source"
        elseif mode~="build" then obs=C.Observation(mode=="failed" and "error" or "unknown",nil,201,"new failed attempt") end
        if mode=="build" then
            check(S.Apply(c.db,{guid="own",name="Fixture",realm="Fixture"},identity(specs[2]),{concentration=obs},201,"changed fixture build"))
        else write(c,"concentration",obs) end
        local verify=unchanged(root); ui:Refresh()
        local dot,estimate,label=indicators(ui)
        eq(ui.widgets[1].row.id,2906,"fixture target "..mode)
        check(dot.shown,"same generation dot survives new observation"); eq(estimate.shown,false,"changed old estimate removed "..mode)
        eq(label.text,"500/1000","retained observation not advanced")
        check(ui.widgets[2].cells[V.index.Concentration].estimate.shown,"other own profession unchanged")
        settle(); verify()
    end
end)
case("removed retired or replaced generation cannot borrow decorations",function()
    for _,mode in ipairs({"delete","archive","generation"}) do
        local ui,e,c,st,root,settle=fixture()
        if mode=="delete" then check(S.Delete(c.db,{guid="own",id=2906,generation=1},true))
        else check(S.Archive(c.db,"own",2906,201,"fixture")) end
        if mode=="generation" then write(c,"concentration",observation(400,202)) end
        local verify=unchanged(root); ui:Refresh()
        local dot,estimate=indicators(ui); eq(ui.widgets[1].row.id,2906,"fixture target "..mode); eq(dot.shown,false,mode); eq(estimate.shown,false,mode)
        check(ui.widgets[2].cells[V.index.Name].currentDot.shown,"independent profession identity")
        settle(); verify()
    end
end)
case("changed invalid or missing GUID and every option reject continuity",function()
    for _,mode in ipairs({"other","nil","empty","invalid","throw","character","realm","professionFamily","profession","attention","archived","sortColumn","sortDescending"}) do
        local ui,e,c,st,root,settle=fixture(); local verify=unchanged(root)
        if mode=="other" then st.guid="alt3" elseif mode=="nil" then e.UnitGUID=nil
        elseif mode=="empty" then st.guid="" elseif mode=="invalid" then st.guid=7
        elseif mode=="throw" then e.UnitGUID=function() error("synthetic GUID fault") end
        else ui.options[mode]=({character="no match",realm="no match",professionFamily=4,profession="no match",attention="Moxie",archived=true,sortColumn=V.index.Name,sortDescending=true})[mode] end
        ui:Refresh(); fallen(ui); settle(); verify()
        if mode=="other" then eq(ui.rows[1].guid,"alt3"); check(ui.widgets[1].cells[V.index.Name].currentDot.shown) end
    end
end)
case("manual retention cancel hide drop and absence of reusable paint fail closed",function()
    for _,mode in ipairs({"retain","stop","hide","drop","failed-cache"}) do
        local ui,e,c,st,root,settle=fixture(); local verify=unchanged(root)
        ui:Refresh(); pending(ui)
        if mode=="retain" then ui:Retain("manual")
        elseif mode=="stop" then ui:StopBuild()
        elseif mode=="hide" then ui.frame:Hide(); ui.frame.scripts.OnHide(ui.frame)
        elseif mode=="drop" then ui:DropCompleted()
        else
            withHook(ui.widgets[1].cells[V.index.Skill].label,"SetText",function() return function() error("synthetic render fault") end end,function() ui:Render() end)
        end
        local ok,why=pcall(fallen,ui); check(ok,mode..": "..tostring(why))
        -- A retry must not resurrect a prediction from the failed/retained cache.
        ui:Refresh(); fallen(ui); verify()
    end
end)
case("combat unknown safety and drift revoke during both frame callbacks",function()
    for _,callback in ipairs({"frame","build"}) do for _,mode in ipairs({"combat","unknown","options","serial","revision","fresh","token"}) do
        local ui,e,c,st,root,settle,step=fixture(); ui:Refresh(); pending(ui)
        if mode=="combat" then st.combat=true elseif mode=="unknown" then st.combat=nil
        elseif mode=="options" then ui.options.character="no match" elseif mode=="serial" then c.serial=c.serial+1
        elseif mode=="revision" then c.revision=c.revision+1 elseif mode=="fresh" then c.fresh={}
        else write(c,"unspent",C.Observation("observed",1,201,"fixture")) end
        local verify=unchanged(root)
        if callback=="frame" then ui.frame.scripts.OnUpdate(ui.frame,.016) else step() end
        fallen(ui); verify()
    end end
end)
case("detached replaced and corrupt source drop pending decorations immediately",function()
    for _,callback in ipairs({"frame","build","render"}) do for _,mode in ipairs({"detach","replace","corrupt"}) do
        local ui,e,c,st,root,settle,step=fixture(); ui:Refresh()
        if mode=="detach" then c.db=nil elseif mode=="replace" then c.db=S.New() else root.characters={} end
        local verify=unchanged(root)
        if callback=="frame" then ui.frame.scripts.OnUpdate(ui.frame,.016) elseif callback=="build" then step() else ui:Render() end
        fallen(ui); eq(ui.completed,nil,"invalid source dropped"); verify()
    end end
end)
case("pending actions confirmations Details and hovers remain historical",function()
    local ui,e,c,st,root,settle=fixture(); local verify=unchanged(root)
    ui.selected=ui.rows[1]; ui.confirmation={scope="synthetic"}; local detailsCalls=0
    ui.details={Open=function() detailsCalls=detailsCalls+1 end,Refresh=function() end}
    ui:Refresh(); pending(ui); eq(ui.selected,nil); eq(ui.confirmation,nil); eq(ui:ActionsReady(),false)
    for n=1,3 do eq(ui.footer[n].style.SetEnabled[1],false) end
    local cell=ui.widgets[1].cells[V.index.Profession]
    cell.scripts.OnMouseDown(cell,"LeftButton"); eq(detailsCalls,0)
    local cc=ui.widgets[1].cells[V.index.Concentration]; cc.scripts.OnEnter(cc)
    check(table.concat(e.GameTooltip.lines):find("Previous saved values pending replacement",1,true),"historical hover")
    ui:Lifecycle("retire",false); eq(ui.confirmation,nil); eq(ui:FinishConfirmation(true),false)
    settle(); verify()
end)
case("ready ticker wheel coalesced drag and reused uncached widgets",function()
    local ui,e,c,st,root,settle=fixture(); local verify=unchanged(root)
    local dot,estimate,label=indicators(ui); local reads=st.guidReads
    st.at=300; ui.frame.scripts.OnUpdate(ui.frame,29); eq(label.text,"~510/1000")
    ui.frame.scripts.OnUpdate(ui.frame,1); eq(label.text,"~520/1000"); eq(st.guidReads,reads)
    ui:Refresh(); local q=ui.buildJob
    ui.viewport.scripts.OnMouseWheel(ui.viewport,-1); eq(ui.offset,3); eq(ui.buildJob,q)
    for _,w in ipairs(ui.widgets) do eq(w.cells[V.index.Name].currentDot.shown,false,"reused alt has no dot") end
    ui:QueueScroll(34); ui:QueueScroll(33); ui:QueueScroll(34); eq(ui.offset,3)
    ui.frame.scripts.OnUpdate(ui.frame,.016); eq(ui.offset,34); eq(ui.rowRange.text,"Rows 35–46 of 46")
    settle(); ui:ScrollTo(0); pending(ui); eq(ui.rowRange.text,"Rows 1–12 of 46"); verify()
end)
case("successful zero full unknown invalid-rate and N/A never fabricate estimates",function()
    for _,mode in ipairs({"zero","full","unknown","zero-rate","negative-rate","zero-duration","missing-duration","future"}) do
        local ui,e,c,st,root,settle=fixture(mode=="unknown"); local obs=observation()
        if mode=="zero" then obs.value.quantity=0 elseif mode=="full" then obs.value.quantity=1000
        elseif mode=="unknown" then obs=C.Observation("unknown",nil,201,"fixture")
        elseif mode=="zero-rate" then obs.value.rechargingAmountPerCycle=0
        elseif mode=="negative-rate" then obs.value.rechargingAmountPerCycle=-1
        elseif mode=="zero-duration" then obs.value.rechargingCycleDurationMS=0
        elseif mode=="missing-duration" then obs.value.rechargingCycleDurationMS=nil
        else obs=observation(500,300) end
        -- Negative metadata is rejected by the actual storage guard, not coerced.
        if mode=="negative-rate" then
            local verify=unchanged(root)
            local result=S.Apply(c.db,{guid="own",name="Fixture",realm="Fixture"},identity(specs[2]),{concentration=obs},201,"fixture")
            eq(result,nil); verify()
        else
            write(c,"concentration",obs); ui:Refresh(); settle()
            local dot,estimate,label=indicators(ui)
            local expected=mode=="zero"
            eq(estimate.shown,expected,mode)
            ui:Refresh(); eq(estimate.shown,expected,"pending "..mode)
        end
        for _,w in ipairs(ui.widgets) do if w.row and w.row.professionFamily~=3 and w.row.professionFamily~=13 then
            eq(w.cells[V.index.Concentration].estimate.shown,false); eq(w.cells[V.index.Concentration].label.text,"—")
        end end
    end
end)
case("normal archived own dot stays but archived refresh has no exception",function()
    local ui,e,c,st,root,settle=fixture()
    check(S.Archive(c.db,"own",2906,201,"fixture")); ui.options.archived=true; ui:Refresh(); settle()
    local dot,estimate,label=indicators(ui); check(dot.shown); eq(estimate.shown,false)
    local verify=unchanged(root); ui:Refresh(); fallen(ui); settle(); check(dot.shown); verify()
end)
case("eligibility Active Token and Revision faults discard cache before retry",function()
    for _,key in ipairs({"Active","Token","Revision"}) do
        local ui,e,c,st,root,settle=fixture(); local verify=unchanged(root); local fired=false
        withHook(S,key,function() return function() fired=true; error("synthetic protected read fault") end end,function()
            local ok=pcall(ui.Refresh,ui); check(ok,"protected eligibility "..key); fallen(ui)
        end)
        check(fired,key); ui:Refresh(); fallen(ui); settle(); pending(ui); verify()
    end
end)
case("eligibility read mutation and reentry never overwrite replacement work",function()
    for _,key in ipairs({"Active","Token","Revision"}) do for _,mode in ipairs({"mutation","reentry"}) do
        local ui,e,c,st,root,settle=fixture(); local fired=false; local newJob,newRows
        withHook(S,key,function(old) return function(...)
            local result={old(...)}
            if not fired then
                fired=true
                if mode=="mutation" then write(c,"unspent",C.Observation("observed",8,201,"fixture"))
                else ui.options.character="no match"; ui:Refresh(); newJob,newRows=ui.buildJob,ui.rows end
            end
            return unpack(result)
        end end,function() ui:Refresh() end)
        check(fired)
        if mode=="reentry" then eq(ui.buildJob,newJob); eq(ui.rows,newRows)
        else fallen(ui) end
        settle(); if mode=="reentry" then eq(#ui.rows,0) end
    end end
end)
case("early demotion widget faults still clear later markers and estimates",function()
    for _,key in ipairs({"GetText","SetText","Hide","IsShown"}) do
        local ui,e,c,st,root,settle=fixture(); local target=ui.widgets[1].cells[V.index.Name].label
        if key=="Hide" or key=="IsShown" then target=ui.widgets[1].cells[V.index.Name].currentDot end
        local fired=false
        withHook(target,key,function(old) return function(...)
            fired=true; old(...); error("synthetic unsafe demotion fault")
        end end,function() ui.options.character="no match"; ui:Refresh() end)
        check(fired,key); fallen(ui)
    end
end)
case("unsafe marker Hide IsShown reentry preserves newer rows hover and queued scroll",function()
    for _,key in ipairs({"Hide","IsShown"}) do
        local ui,e,c,st,root,settle=fixture(); local dot=indicators(ui); local fired=false; local newRows,newJob
        withHook(dot,key,function(old) return function(...)
            local result=old(...)
            if not fired then
                fired=true; ui.options.character=nil; ui:Refresh(); settle()
                newRows,newJob=ui.rows,ui.buildJob
                ui:QueueScroll(2)
                local cell=ui.widgets[2].cells[V.index.Concentration]; cell.scripts.OnEnter(cell)
            end
            return result
        end end,function() ui.options.character="unsafe"; ui:Refresh() end)
        check(fired,key); eq(ui.rows,newRows); eq(ui.buildJob,newJob)
        check(e.GameTooltip.shown,"new hover remains")
        ui.frame.scripts.OnUpdate(ui.frame,.016); eq(ui.offset,2,"new scroll owner remains")
    end
end)
case("pending preserved paint native widget and clock faults fail closed",function()
    for _,boundary in ipairs({"Show","SetShown","SetText","SetPoint","SetWidth","visibility","combat","clock","Token"}) do
        local ui,e,c,st,root,settle=fixture(); ui:Refresh(); pending(ui)
        local object,key
        if boundary=="Show" then object,key=ui.widgets[1],"Show"
        elseif boundary=="SetShown" or boundary=="SetText" then object,key=ui.widgets[1].cells[V.index.Name].label,boundary
        elseif boundary=="SetPoint" then object,key=ui.selectionArea,"SetPoint"
        elseif boundary=="SetWidth" then object,key=ui.widgets[3].cells[V.index.Name].label,"SetWidth"
        elseif boundary=="visibility" then object,key=ui.frame,"IsShown"
        elseif boundary=="combat" then object,key=e,"InCombatLockdown"
        elseif boundary=="clock" then object,key=c,"Now"
        else object,key=S,"Token" end
        local fired=false; local verify=unchanged(root)
        withHook(object,key,function() return function() fired=true; error("synthetic pending paint fault") end end,function() ui:Render() end)
        check(fired,boundary); fallen(ui); ui:Refresh(); fallen(ui); verify()
    end
end)
case("preserved paint reentry at every dispatched native boundary protects newer publication",function()
    for _,boundary in ipairs({"Show","SetShown","SetText","SetPoint","SetSize","SetWidth","visibility","combat","clock","Token"}) do
        local ui,e,c,st,root,settle=fixture(); ui:Refresh()
        local object,key
        if boundary=="Show" then object,key=ui.widgets[1],"Show"
        elseif boundary=="SetShown" or boundary=="SetText" then object,key=ui.widgets[1].cells[V.index.Name].label,boundary
        elseif boundary=="SetPoint" then object,key=ui.selectionArea,"SetPoint"
        elseif boundary=="SetSize" then object,key=ui.frame,"SetSize"
        elseif boundary=="SetWidth" then object,key=ui.widgets[3].cells[V.index.Name].label,"SetWidth"
        elseif boundary=="visibility" then object,key=ui.frame,"IsShown"
        elseif boundary=="combat" then object,key=e,"InCombatLockdown"
        elseif boundary=="clock" then object,key=c,"Now"
        else object,key=S,"Token" end
        local fired=false; local newRows,newJob,newText
        withHook(object,key,function(old) return function(...)
            local result=old(...)
            if not fired then
                fired=true; ui.options.character="no match"; ui:Refresh(); settle()
                newRows,newJob,newText=ui.rows,ui.buildJob,ui.reason.text
            end
            return result
        end end,function() ui:Render() end)
        check(fired,boundary); eq(ui.rows,newRows); eq(ui.buildJob,newJob); eq(ui.reason.text,newText); eq(#ui.rows,0)
    end
end)
case("setup Step batch scheduler and publication errors revoke before retry",function()
    for _,mode in ipairs({"setup","batch-setup","Step","batch","scheduler","publication"}) do
        local ui,e,c,st,root,settle,step=fixture(); local verify=unchanged(root); local fired=false
        local function fault() fired=true; error("synthetic build fault") end
        if mode=="setup" or mode=="batch-setup" then
            local object,key=mode=="setup" and V or S,mode=="setup" and "NewBuildJob" or "NewFrameBatch"
            withHook(object,key,function() return fault end,function() ui:Refresh() end)
        elseif mode=="scheduler" then withHook(ui.buildDriver,"SetScript",function() return fault end,function() ui:Refresh() end)
        else
            ui:Refresh()
            if mode=="Step" then withHook(ui.buildJob,"Step",function() return fault end,step)
            elseif mode=="batch" then withHook(ui.buildBatch,"Step",function() return fault end,step)
            else
                withHook(ui.reason,"SetText",function() return fault end,function() settle() end)
            end
        end
        check(fired,mode); fallen(ui); ui:Refresh(); fallen(ui); verify()
    end
end)
case("token row reuse and provenance drift during pending callback demote immediately",function()
    for _,mode in ipairs({"token","widget-row","row-generation","row-value","row-guid","clock"}) do
        local ui,e,c,st,root,settle=fixture(); ui:Refresh()
        if mode=="token" then write(c,"concentration",observation(400,201))
        elseif mode=="widget-row" then ui.widgets[1].row=ui.rows[3]
        elseif mode=="row-generation" then ui.rows[1].generation=9
        elseif mode=="row-value" then ui.rows[1].concentrationValue.quantity=9
        elseif mode=="row-guid" then ui.rows[1].guid="alt3"
        else st.at=nil end
        local verify=unchanged(root)
        if mode=="clock" then ui:Render() else ui.frame.scripts.OnUpdate(ui.frame,.016) end
        if mode=="clock" then
            local dot,estimate,label=indicators(ui)
            check(dot.shown,"F1 invalid clock preserves valid identity"); eq(estimate.shown,false); eq(label.text,"500/1000")
        else fallen(ui) end
        verify()
    end
end)
case("eligibility newer paint hover and scroll ownership survives old preparation",function()
    local ui,e,c,st,root,settle=fixture(); local fired=false; local newRows,newText
    withHook(S,"Active",function(old) return function(...)
        local results={old(...)}
        if not fired then
            fired=true; ui:Render(); newRows,newText=ui.rows,ui.reason.text
            ui:QueueScroll(2)
            local cell=ui.widgets[1].cells[V.index.Concentration]; cell.scripts.OnEnter(cell)
        end
        return unpack(results)
    end end,function() ui:Refresh() end)
    check(fired); eq(ui.rows,newRows); eq(ui.reason.text,newText); check(e.GameTooltip.shown,"new eligibility hover survives")
    ui.frame.scripts.OnUpdate(ui.frame,.016); eq(ui.offset,2,"new eligibility scroll survives")
end)
case("bounded preparation does not walk or copy account graphs or render new predictions",function()
    local ui,e,c,st,root,settle=fixture(); local verify=unchanged(root)
    local copies,reads=0,0; local oldCopy,oldActive,oldIterator,oldEstimate=C.Copy,S.Active,S.NewIterator,V.ConcentrationEstimate
    local oldRows=ui.rows
    local ok,why=xpcall(function()
        C.Copy=function(value)
            copies=copies+1
            check(value~=root and value~=root.characters and value~=oldRows,"no root/directory/list graph copy")
            check(type(value)~="table" or not value.cells,"no whole row graph copy")
            return oldCopy(value)
        end
        S.Active=function(db,guid,id) reads=reads+1; check(reads<=12,"at most12active reads"); return oldActive(db,guid,id) end
        S.NewIterator=function(...)
            local it=oldIterator(...)
            it.Step=function() error("no eager account traversal in preparation") end
            return it
        end
        V.ConcentrationEstimate=function() error("no retained prediction recomputation") end
        ui:Refresh(); pending(ui); eq(ui.buildJob.steps,0,"no synchronous replacement work"); eq(reads,12)
        for n=1,5 do ui:Render(); pending(ui); eq(reads,12,"preserved render no active reread") end
        check(copies>0 and copies<100,"bounded scalar-option copying only")
    end,debug.traceback)
    C.Copy,S.Active,S.NewIterator,V.ConcentrationEstimate=oldCopy,oldActive,oldIterator,oldEstimate
    assert(ok,why); verify()
end)
case("pending warning demotion never promotes frozen data to fresh",function()
    local ui,e,c,st,root,settle=fixture(); local verify=unchanged(root)
    local w=ui.widgets[3]; w.row.cells[V.index.Unspent]="|cffffbb00!|r 7"; check(ui:Render())
    local oldRows=ui.rows; local oldState=oldRows[1].concentrationState
    ui:Refresh(); pending(ui); eq(w.cells[V.index.Unspent].label.text,"|cff999999!|r 7")
    eq(ui.rows,oldRows); eq(ui.rows[1].concentrationState,oldState); eq(ui.rows[1].concentration,500)
    eq(ui.rows[1].sortValues[V.index.Concentration],500); verify()
end)
case("preparation visibility combat clock and source-query faults fail closed",function()
    for _,inflight in ipairs({false,true}) do for _,mode in ipairs({"visibility","combat","clock","check","revision"}) do
        local ui,e,c,st,root,settle=fixture()
        if inflight then ui:Refresh() end
        local object,key
        if mode=="visibility" then object,key=ui.frame,"IsShown" elseif mode=="combat" then object,key=e,"InCombatLockdown"
        elseif mode=="clock" then object,key=c,"Now" elseif mode=="check" then object,key=S,"Check" else object,key=S,"Revision" end
        local fired=false
        withHook(object,key,function() return function() fired=true; error("synthetic start/coalescing fault") end end,function()
            local ok=pcall(ui.Refresh,ui); check(ok,"protected start "..mode)
            if inflight and mode=="clock" then pending(ui) else fallen(ui) end
        end)
        -- A same-job coalescing call has no clock read; it must validate safety but
        -- must not invent a clock lookup just to exercise this fault hook.
        if not (inflight and mode=="clock") then check(fired,mode) end
    end end
end)
case("Cancel setup Step batch and publication reentry cannot retire a newer job",function()
    for _,mode in ipairs({"Cancel","setup","Step","batch","publication"}) do
        local ui,e,c,st,root,settle,step=fixture(); ui:Refresh()
        local object,key
        if mode=="Cancel" then object,key=ui.buildJob,"Cancel"
        elseif mode=="setup" then object,key=V,"NewBuildJob"
        elseif mode=="Step" then object,key=ui.buildJob,"Step"
        elseif mode=="batch" then object,key=ui.buildBatch,"Step"
        else object,key=ui.reason,"SetText" end
        local fired=false; local newRows,newJob,newStatus
        withHook(object,key,function(old) return function(...)
            local result=old(...)
            if not fired then
                fired=true; ui.options.character="no match"; ui:Refresh(); settle()
                newRows,newJob,newStatus=ui.rows,ui.buildJob,ui.reason.text
            end
            return result
        end end,function()
            if mode=="Cancel" then ui:StopBuild() elseif mode=="setup" then c.serial=c.serial+1; ui:Refresh()
            elseif mode=="publication" then settle() else step() end
        end)
        check(fired,mode); eq(ui.rows,newRows); eq(ui.buildJob,newJob); eq(ui.reason.text,newStatus); eq(#ui.rows,0)
    end
end)
case("same-build native reentrant paint prevents all subsequent old widget dispatch",function()
    local ui,e,c,st,root,settle=fixture(); ui:Refresh(); local fired,after=false,false; local stale=0
    local original=ui.frame.SetSize
    ui.frame.SetSize=function(...)
        if after then stale=stale+1 end
        return original(...)
    end
    withHook(ui.frame,"IsShown",function(old) return function(...)
        local result=old(...)
        if not fired then fired=true; check(ui:Render()); after=true end
        return result
    end end,function() ui:Render() end)
    ui.frame.SetSize=original
    check(fired); eq(stale,0,"retired outer paint never reaches a widget"); pending(ui)
end)
case("mutation inside preserved painting revokes frozen indicators by callback return",function()
    for _,mode in ipairs({"observation","options","GUID","source","hide","combat"}) do
        local ui,e,c,st,root,settle=fixture(); ui:Refresh(); local fired=false
        local target=ui.widgets[1].cells[V.index.Name].label
        withHook(target,"SetText",function(old) return function(...)
            local result=old(...)
            if not fired then
                fired=true
                if mode=="observation" then write(c,"concentration",observation(400,201))
                elseif mode=="options" then ui.options.character="no match"
                elseif mode=="GUID" then ui.options.currentPlayerGUID="alt3"
                elseif mode=="source" then c.db=nil
                elseif mode=="hide" then ui.frame.shown=false else st.combat=true end
            end
            return result
        end end,function() ui:Render() end)
        check(fired); fallen(ui)
    end
end)
case("normal partial or completed-cache read failures cannot lend prior paint on retry",function()
    for _,mode in ipairs({"widget","Active","Token"}) do
        local ui,e,c,st,root,settle=fixture(); local verify=unchanged(root)
        local object,key
        if mode=="widget" then object,key=ui.widgets[2].cells[V.index.Name].currentDot,"SetPoint" else object,key=S,mode end
        local fired=false
        withHook(object,key,function() return function() fired=true; error("synthetic completed paint failure") end end,function() ui:Render() end)
        check(fired,mode); fallen(ui); ui:Refresh(); fallen(ui); settle(); pending(ui); verify()
    end
end)
case("current active identity capability and generation must match cached scalars",function()
    for _,mode in ipairs({"wrong-supported","unsupported","family","generation","archived"}) do
        local ui,e,c,st,root,settle=fixture(); local verify=unchanged(root)
        withHook(S,"Active",function(old) return function(db,guid,id)
            local g=old(db,guid,id)
            if guid=="own" and id==2906 and g then
                local fake={identity=C.Copy(g.identity),generation=g.generation,fields=g.fields}
                if mode=="wrong-supported" then fake.identity=identity(specs[1])
                elseif mode=="unsupported" then fake.identity.expansionID=10
                elseif mode=="family" then fake.identity.profession=13
                elseif mode=="generation" then fake.generation=fake.generation+1
                else fake.archived=true end
                return fake
            end
            return g
        end end,function()
            ui:Refresh(); local dot,estimate=indicators(ui); eq(dot.shown,false); eq(estimate.shown,false)
            check(ui.widgets[2].cells[V.index.Name].currentDot.shown,"other profession still matches")
        end)
        verify()
    end
end)
case("ordinary refresh frozen cyan and approximate label at every pending callback",function()
    local ui,e,c,st,root,settle=fixture(); local dot,estimate,label=indicators(ui)
    check(estimate:IsShown(),"initial completed estimate"); check(label:GetText():sub(1,1)=="~","initial approximate label")
    local text,width=label:GetText(),estimate.width; local verify=unchanged(root)
    ui:Refresh(); check(estimate:IsShown(),"unchanged pending estimate must not disappear"); eq(label:GetText(),text)
    settle(function() check(estimate:IsShown(),"estimate at callback return"); eq(estimate.width,width) end); verify()
end)
-- C1: independent review findings are STATIC evidence; these executions are
-- writer-attributed rejecting reproductions against the first delivery.
for _,when in ipairs({"before Refresh","during pending Render"}) do
    case("F1 backward integer clock "..when.." rejects estimate only",function()
        local ui,e,c,st,root,settle=fixture(); local dot,estimate,label=indicators(ui)
        check(dot.shown and estimate.shown); eq(label.text,"~510/1000")
        local token=S.Token(c.db,"own",2906); local verify=unchanged(root)
        if when=="during pending Render" then ui:Refresh() end
        local clocks=st.clockReads
        st.at=50 -- Valid integer, but before the cached successful observation100.
        if when=="before Refresh" then ui:Refresh() else ui:Render() end
        check(dot.shown,"backward estimate clock does not invalidate own identity")
        eq(estimate.shown,false,"backward clock must hide frozen cyan estimate")
        eq(label.text,"500/1000","backward clock restores observed-only label")
        eq(st.clockReads,clocks+(when=="before Refresh" and 2 or 1),"existing shared clocks only")
        st.at=200; ui:Render(); eq(estimate.shown,false,"rejected projection cannot revive while retained")
        eq(label.text,"500/1000"); eq(S.Token(c.db,"own",2906),token); verify()
        settle(); check(dot.shown and estimate.shown,"successful new normal paint may estimate again")
    end)
end
local function insidePreparationRead()
    -- Test-only stack observation identifies the native callback AFTER the actual
    -- eligibility helper returns, not another native check inside that helper.
    local depth=2
    while true do
        local info=debug.getinfo(depth,"n")
        if not info then return false end
        if info.name=="prepareContinuity" or info.name=="continuityCurrent" then return true end
        depth=depth+1
    end
end
for _,boundary in ipairs({"post-eligibility visibility","initial status","initial paint"}) do
    case("F2 same-build newer owner from "..boundary.." wins",function()
        local ui,e,c,st,root,settle=fixture(); local verify=unchanged(root)
        local reads,fired=0,false; local newRows,newPaint,newStatus,tipText
        local target,key
        if boundary=="post-eligibility visibility" then target,key=ui.frame,"IsShown"
        elseif boundary=="initial status" then target,key=ui.reason,"SetText"
        else target,key=ui.widgets[1],"Show" end
        withHook(S,"Active",function(old) return function(...)
            reads=reads+1; return old(...)
        end end,function()
            withHook(target,key,function(old) return function(...)
                local result=old(...)
                if not fired and reads==12 and not insidePreparationRead() and not ui.buildJob then
                    fired=true
                    check(ui:Render(),"new same-build paint succeeds")
                    newRows,newPaint=ui.rows,ui.widgets[1].row
                    ui.reason:SetText("F2 newer owner status")
                    newStatus=ui.reason.text
                    ui:QueueScroll(2)
                    local cell=ui.widgets[1].cells[V.index.Concentration]; cell.scripts.OnEnter(cell)
                    tipText=table.concat(e.GameTooltip.lines,"\n")
                    check(e.GameTooltip.shown,"new owner hover shown")
                end
                return result
            end end,function() ui:Refresh() end)
        end)
        check(fired,"actual requested post-eligibility callback fired")
        eq(ui.rows,newRows,"new rows owned"); eq(ui.widgets[1].row,newPaint,"new paint owned")
        eq(ui.buildJob,nil,"retired stack must not install older job")
        eq(ui.reason.text,newStatus,"new status owned"); check(e.GameTooltip.shown,"new hover survives")
        eq(table.concat(e.GameTooltip.lines,"\n"),tipText,"new hover content survives")
        ui.frame.scripts.OnUpdate(ui.frame,.016); eq(ui.offset,2,"new queued scroll survives")
        eq(ui.buildJob,nil); eq(ui.reason.text,newStatus); verify()
    end)
end
case("self-only wrapped Refresh completes and publishes normal indicators",function()
    local ui,e,c,st,root,settle=fixture(); local original=ui.Render; local calls=0
    ui.Render=function(w) calls=calls+1; return original(w) end
    local before=ui.completed; local verify=unchanged(root)
    ui:Refresh(); check(ui.buildJob,"transparent self-only wrapper must not retire normal setup")
    settle(); check(ui.completed~=before); eq(ui.retained,false); pending(ui); check(calls>=2); verify()
end)
case("self-only wrapped timer recovery remains ready for future native callbacks",function()
    local ui,e,c,st,root,settle=fixture(); local original=ui.Render
    ui.Render=function(w) return original(w) end
    local at=st.at
    ui.frame.scripts.OnUpdate(ui.frame,30)
    ui:Refresh(); settle(); check(ui:ActionsReady(),"wrapped refresh must leave timer eligible")
    local fired=false
    withHook(c,"Now",function(old) return function(...)
        if not fired then fired=true; st.at=at+100 end
        return old(...)
    end end,function() ui.frame.scripts.OnUpdate(ui.frame,30) end)
    check(fired,"future timer clock boundary must still be reached")
    local dot,estimate,label=indicators(ui); eq(label.text,"~520/1000"); check(dot.shown and estimate.shown)
end)
for _,action in ipairs({"Refresh","Hide","source"}) do
    case("self-only Render wrapper "..action.." reentry preserves newer owner",function()
        local ui,e,c,st,root,settle=fixture(); local original=ui.Render
        local fired=false; local newRows,newJob,newReason
        ui.Render=function(w)
            if not fired then
                fired=true
                if action=="Refresh" then ui.options.character="no match"; ui:Refresh()
                elseif action=="Hide" then ui.frame:Hide(); ui.frame.scripts.OnHide(ui.frame)
                else c.db=S.New(); ui:Refresh() end
                newRows,newJob,newReason=ui.rows,ui.buildJob,ui.reason.text
            end
            return original(w)
        end
        ui:Refresh(); check(fired); eq(ui.rows,newRows); eq(ui.buildJob,newJob); eq(ui.reason.text,newReason)
        if action=="Hide" then ui:Toggle() end
        settle(); eq(#ui.rows,action=="Hide" and 46 or 0,"new normal replacement must still complete")
    end)
end
case("all original public signatures survive transparent Render Retain StopBuild wrappers",function()
    local ui,e,c,st,root,settle=fixture()
    local render,retain,stop=ui.Render,ui.Retain,ui.StopBuild
    local calls={render=0,retain=0,stop=0}; local verify=unchanged(root)
    ui.Render=function(w) calls.render=calls.render+1; return render(w) end
    ui.Retain=function(w,why) calls.retain=calls.retain+1; return retain(w,why) end
    ui.StopBuild=function(w) calls.stop=calls.stop+1; return stop(w) end
    ui:Refresh(); check(ui.buildJob); pending(ui)
    settle(); pending(ui); eq(ui.retained,false)
    check(calls.render>=2 and calls.retain>=1 and calls.stop>=2,"actual public wrapper dispatch")
    verify()
end)
case("one-shot dispatch does not leak owner into nested native Render after entry",function()
    local ui,e,c,st,root,settle=fixture(); local original=ui.Render
    local wrapped=0; ui.Render=function(w) wrapped=wrapped+1; return original(w) end
    local fired=false; local newRows,newStatus,newJob
    withHook(ui.widgets[1],"Show",function(old) return function(...)
        local result=old(...)
        if not fired then
            fired=true; check(ui:Render()); newRows,newJob=ui.rows,ui.buildJob
            ui.reason:SetText("nested Render owns status"); newStatus=ui.reason.text
            ui:QueueScroll(2)
            local cell=ui.widgets[1].cells[V.index.Concentration]; cell.scripts.OnEnter(cell)
        end
        return result
    end end,function() ui:Refresh() end)
    check(fired and wrapped>=2); eq(ui.rows,newRows); eq(ui.buildJob,newJob); eq(newJob,nil)
    eq(ui.reason.text,newStatus); check(e.GameTooltip.shown)
    ui.frame.scripts.OnUpdate(ui.frame,.016); eq(ui.offset,2); eq(ui.reason.text,newStatus)
end)
case("owned dispatch is retired after wrapper throws before production entry",function()
    local ui,e,c,st,root,settle=fixture(); local original=ui.Render
    ui.Render=function() error("synthetic public wrapper fault before entry") end
    eq(pcall(ui.Refresh,ui),false,"wrapper exception is not a successful render")
    fallen(ui)
    ui.Render=original
    -- An ordinary subsequent Render is a new invocation, not the retired ticket.
    check(ui:Render()); ui:Refresh(); check(ui.buildJob); settle(); pending(ui)
end)
for _,method in ipairs({"Retain","StopBuild","Render with throwing Retain"}) do
    case("F3 pre-entry "..method.." failure demotes revokes and recovers",function()
        local ui,e,c,st,root,settle=fixture(); local verify=unchanged(root)
        local retain,stop,render=ui.Retain,ui.StopBuild,ui.Render
        local calls=0
        if method=="Retain" then ui.Retain=function() error("synthetic pre-entry Retain failure") end
        elseif method=="StopBuild" then ui.StopBuild=function() error("synthetic pre-entry StopBuild failure") end
        else
            ui.Retain=function(w,why)
                calls=calls+1
                if calls>1 then error("synthetic throwing public cleanup Retain") end
                return retain(w,why)
            end
            ui.Render=function() error("synthetic pre-entry Render failure") end
        end
        local dot,estimate,label=indicators(ui); check(dot.shown and estimate.shown)
        eq(pcall(ui.Refresh,ui),false,"failed dispatch must not continue setup")
        fallen(ui); eq(label.text,"500/1000","immediate observed-only fallback")
        eq(ui.buildJob,nil); eq(ui:ActionsReady(),false,"failed view stays historical")
        ui.Retain,ui.StopBuild,ui.Render=retain,stop,render
        ui:Refresh(); check(ui.buildJob,"ordinary retry still incremental")
        fallen(ui); eq(label.text,"500/1000","failed cache cannot revive on retry")
        settle(); pending(ui); eq(label.text,"~510/1000","new normal paint recovers")
        verify()
    end)
end
for _,method in ipairs({"Retain","StopBuild","Render"}) do
    for _,replacement in ipairs({"same-build paint","new build"}) do
        case("F3 throwing "..method.." preserves newer "..replacement,function()
            local ui,e,c,st,root,settle=fixture(); local original=ui[method]; local fired=false
            local newRows,newJob,newStatus,hoverText
            ui[method]=function(w,...)
                if fired then return original(w,...) end
                fired=true
                if replacement=="new build" then ui.options.character="no match"; ui:Refresh()
                else check(ui:Render()); ui:QueueScroll(2) end
                ui.reason:SetText("F3 newer owner status")
                local cell=ui.widgets[1].cells[V.index.Concentration]; cell.scripts.OnEnter(cell)
                newRows,newJob,newStatus=ui.rows,ui.buildJob,ui.reason.text
                hoverText=table.concat(e.GameTooltip.lines,"\n")
                error("synthetic retired wrapper exception")
            end
            eq(pcall(ui.Refresh,ui),false); check(fired)
            ui[method]=original
            eq(ui.rows,newRows); eq(ui.buildJob,newJob); eq(ui.reason.text,newStatus)
            check(e.GameTooltip.shown); eq(table.concat(e.GameTooltip.lines,"\n"),hoverText)
            if replacement=="same-build paint" then
                ui.frame.scripts.OnUpdate(ui.frame,.016); eq(ui.offset,2,"new scroll survives old exception")
                eq(ui.reason.text,newStatus)
            else settle(); eq(#ui.rows,0) end
        end)
    end
end
case("F3 cleanup never depends on either throwing public presentation wrapper",function()
    local ui,e,c,st,root,settle=fixture(); local retain,render=ui.Retain,ui.Render
    ui.Retain=function() error("synthetic always-throwing public Retain") end
    ui.Render=function() error("synthetic always-throwing public Render") end
    eq(pcall(ui.Refresh,ui),false); fallen(ui); eq(ui.buildJob,nil)
    ui.Retain,ui.Render=retain,render
    ui:Refresh(); fallen(ui); settle(); pending(ui)
end)
case("F3 post-entry exceptions share the same private cache-revocation contract",function()
    for _,method in ipairs({"Retain","StopBuild","Render"}) do
        local ui,e,c,st,root,settle=fixture(); local original=ui[method]; local fired=false
        ui[method]=function(w,...)
            local result=original(w,...)
            fired=true; error("synthetic post-entry "..method.." failure")
            return result
        end
        eq(pcall(ui.Refresh,ui),false); check(fired); fallen(ui); eq(ui.buildJob,nil)
        ui[method]=original
        ui:Refresh(); fallen(ui); settle(); pending(ui)
    end
end)
case("F3 private demotion checks native reentry before touching a newer owner",function()
    for _,boundary in ipairs({"GetText","Hide","IsShown","SetText","source check"}) do
        local ui,e,c,st,root,settle=fixture(); local retain=ui.Retain
        local thrown,fired=false,false; local newRows,newStatus,hoverText
        ui.Retain=function(w,why)
            if not thrown then thrown=true; error("synthetic one-shot pre-entry failure") end
            return retain(w,why)
        end
        local object,key
        if boundary=="source check" then object,key=S,"Check"
        elseif boundary=="Hide" or boundary=="IsShown" then object,key=ui.widgets[1].cells[V.index.Name].currentDot,boundary
        elseif boundary=="SetText" then object,key=ui.widgets[1].cells[V.index.Concentration].label,"SetText"
        else object,key=ui.widgets[1].cells[V.index.Name].label,"GetText" end
        withHook(object,key,function(old) return function(...)
            local result=old(...)
            if thrown and not fired then
                fired=true; check(ui:Render()); ui:QueueScroll(2)
                ui.reason:SetText("F3 cleanup newer status")
                local cell=ui.widgets[1].cells[V.index.Concentration]; cell.scripts.OnEnter(cell)
                newRows,newStatus,hoverText=ui.rows,ui.reason.text,table.concat(e.GameTooltip.lines,"\n")
            end
            return result
        end end,function() eq(pcall(ui.Refresh,ui),false) end)
        ui.Retain=retain
        check(thrown and fired,boundary); eq(ui.rows,newRows); eq(ui.reason.text,newStatus); eq(ui.buildJob,nil)
        check(e.GameTooltip.shown); eq(table.concat(e.GameTooltip.lines,"\n"),hoverText)
        ui.frame.scripts.OnUpdate(ui.frame,.016); eq(ui.offset,2,"native cleanup did not clear replacement scroll")
        eq(ui.reason.text,newStatus)
    end
end)
case("F3 cleanup isolates early widget faults while revoking all reusable paint",function()
    local ui,e,c,st,root,settle=fixture(); local retain=ui.Retain
    ui.Retain=function() error("synthetic pre-entry failure") end
    withHook(ui.widgets[1].cells[V.index.Name].label,"GetText",function() return function() error("synthetic early cleanup label failure") end end,function()
        eq(pcall(ui.Refresh,ui),false); fallen(ui)
    end)
    ui.Retain=retain
    ui:Refresh(); fallen(ui); settle(); pending(ui)
end)
case("F3 failed StopBuild dispatch retires only its owned previous in-flight work",function()
    local ui,e,c,st,root,settle=fixture(); ui:Refresh(); local oldJob=ui.buildJob
    local stop=ui.StopBuild; ui.StopBuild=function() error("synthetic pre-entry cancellation failure") end
    c.serial=c.serial+1 -- Force replacement rather than valid-job coalescing.
    eq(pcall(ui.Refresh,ui),false); fallen(ui)
    eq(ui.buildJob,nil,"failed preparation must not strand its old scheduler job")
    eq(oldJob.status,"cancelled","old owned work cancelled privately")
    ui.StopBuild=stop; ui:Refresh(); fallen(ui); settle(); pending(ui)
end)
case("F3 private cancellation cleanup cannot cancel a newer replacement job or scroll",function()
    local ui,e,c,st,root,settle=fixture(); ui:Refresh()
    local oldJob=ui.buildJob; local cancel,stop=oldJob.Cancel,ui.StopBuild
    local thrown,fired=false,false; local newJob,newRows,newStatus
    ui.StopBuild=function(w)
        if not thrown then thrown=true; error("synthetic one-shot StopBuild failure") end
        return stop(w)
    end
    oldJob.Cancel=function(job)
        cancel(job)
        if not fired then
            fired=true; ui:Refresh()
            newJob,newRows=ui.buildJob,ui.rows
            ui.reason:SetText("F3 newer cancellation replacement")
            newStatus=ui.reason.text; ui:QueueScroll(2)
            local cell=ui.widgets[1].cells[V.index.Concentration]; cell.scripts.OnEnter(cell)
        end
    end
    c.serial=c.serial+1
    eq(pcall(ui.Refresh,ui),false); check(thrown and fired)
    ui.StopBuild=stop; oldJob.Cancel=cancel
    check(newJob and newJob~=oldJob); eq(ui.buildJob,newJob); eq(ui.rows,newRows); eq(ui.reason.text,newStatus)
    check(e.GameTooltip.shown); ui.frame.scripts.OnUpdate(ui.frame,.016); eq(ui.offset,2)
    eq(ui.buildJob,newJob); eq(newJob.status,"running"); eq(ui.reason.text,newStatus)
    settle(); eq(#ui.rows,46)
end)
-- V01 additions: exercise the existing status widget and Shift selector only.
do
    local expected="Loaded dashboard build: 0.2.0-mvp+p04.1"
    local function hover(ui,e,c,st,root)
        local verify=unchanged({root,c.fresh,ui.rows,ui.title.points,ui.statusArea.points})
        local tokens={S.Token(c.db,"own",2906),S.Token(c.db,"own",2913)}
        local title,status=ui.title.text,ui.reason.text
        local titleCalls,statusCalls=#ui.title.calls,#ui.reason.calls
        local guidReads,clockReads=st.guidReads,st.clockReads
        local job,completed,retained=ui.buildJob,ui.completed,ui.retained
        local create=e.CreateFrame
        e.CreateFrame=function() error("status hover must not create a frame") end
        local ok,why=pcall(ui.statusArea.scripts.OnEnter,ui.statusArea)
        e.CreateFrame=create
        check(ok,why); check(e.GameTooltip.shown,"status hover shown")
        eq(st.guidReads,guidReads,"no status-hover GUID read")
        eq(st.clockReads,clockReads,"no status-hover clock read")
        eq(S.Token(c.db,"own",2906),tokens[1]); eq(S.Token(c.db,"own",2913),tokens[2])
        eq(ui.buildJob,job); eq(ui.completed,completed); eq(ui.retained,retained)
        eq(ui.title.text,title); eq(ui.reason.text,status)
        eq(#ui.title.calls,titleCalls,"no title dispatch"); eq(#ui.reason.calls,statusCalls,"no status label dispatch")
        eq(title,"CraftArmy — observed profession snapshots"); eq(ui.title.width,1080)
        eq(ui.statusArea.width,1138); eq(ui.statusArea.height,16); eq(ui.frame.width,1184)
        verify()
        return e.GameTooltip.lines
    end
    for _,retained in ipairs({false,true}) do
        case("V01 exact Shift-only loaded identifier in "..(retained and "retained" or "ready").." status",function()
            local ui,e,c,st,root,settle=fixture()
            if retained then ui:Refresh(); check(ui.retained); check(ui.buildJob) end
            c.blockReason="synthetic diagnostic block"
            local shiftReads=0
            e.IsShiftKeyDown=function() shiftReads=shiftReads+1; return false end
            local lines=hover(ui,e,c,st,root)
            eq(#lines,1); eq(lines[1],ui:DisplayStatus()); eq(shiftReads,1)
            check(not table.concat(lines):find("Loaded dashboard build:",1,true),"normal hover has no marker")
            e.IsShiftKeyDown=function() shiftReads=shiftReads+1; return true end
            lines=hover(ui,e,c,st,root); eq(shiftReads,2)
            eq(lines[#lines],expected,"exact loaded identifier appended to diagnostic detail")
            eq(#lines,4); eq(lines[1],ui:DisplayStatus()); eq(lines[2],"Raw status: fixture")
            eq(lines[3],"Blocked: synthetic diagnostic block")
            local count=0; for _,line in ipairs(lines) do if line==expected then count=count+1 end end
            eq(count,1,"identifier occurs once")
            ui.statusArea.scripts.OnLeave(ui.statusArea); eq(e.GameTooltip.shown,false)
            e.IsShiftKeyDown=function() return false end
            lines=hover(ui,e,c,st,root); eq(#lines,1); eq(lines[1],ui:DisplayStatus(),"normal after diagnostic hover")
        end)
    end
    case("V01 missing throwing and nontrue Shift queries keep normal status",function()
        for _,retained in ipairs({false,true}) do
            local ui,e,c,st,root=fixture()
            if retained then ui:Refresh(); check(ui.retained) end
            for _,mode in ipairs({"missing","throw","nonfunction","nil","string","number"}) do
                local reads=0
                if mode=="missing" then e.IsShiftKeyDown=nil
                elseif mode=="nonfunction" then e.IsShiftKeyDown=true
                else e.IsShiftKeyDown=function()
                    reads=reads+1
                    if mode=="throw" then error("synthetic Shift query fault")
                    elseif mode=="string" then return "true" elseif mode=="number" then return 1 end
                end end
                local lines=hover(ui,e,c,st,root)
                eq(#lines,1,mode); eq(lines[1],ui:DisplayStatus(),mode)
                eq(reads,(mode=="missing" or mode=="nonfunction") and 0 or 1)
                check(not table.concat(lines):find("0.2.0-mvp+p04.1",1,true),"no fallback identifier")
            end
        end
    end)
end
print(string.format("R02 additive: %d groups passed; %d failed; %d assertions (synthetic, not native evidence)",passed,failed,checks))
if failed>0 then os.exit(1) end
