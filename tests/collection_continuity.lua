-- R03 actual production collector/event/Storage/dashboard callbacks; synthetic API
-- and widgets only, never native trigger/order/timing/estimate-accuracy evidence.
local function read(path)
    local f=assert(io.open(path,"r")); local s=f:read("*a"); f:close(); return s
end
-- Reuse frozen fixture helpers without running or modifying their case lists.
local helpers=assert(read("tests/profession_expansion.lua"):match("^(.-)\ncase%("))
local native=assert(read("tests/refresh_continuity.lua"):match("(local function widgets%(e%).-)\nlocal specs="))
local tests=[=[
local function setup(mode)
    local e,st=api({2913,773,13}); widgets(e)
    st.parents={[1]=773}; st.roster={1}; st.slots={20,21,22}
    st.quantity=100; st.cap=1000; st.duration=1000; st.rate=1; st.currency=777
    st.currencyUnknown=mode=='unknown'
    e.debugprofilestop=function() return 0 end
    e.C_TradeSkillUI.GetConcentrationCurrencyID=function() return st.currency end
    local currency=e.C_CurrencyInfo.GetCurrencyInfo
    e.C_CurrencyInfo.GetCurrencyInfo=function(id)
        if id==st.currency then
            if st.currencyError then error('synthetic currency failure') end
            if st.currencyUnknown then return nil end
            return {id=id,quantity=st.quantity,maxQuantity=st.cap,
            rechargingCycleDurationMS=st.duration,rechargingAmountPerCycle=st.rate} end
        return currency(id)
    end
    local queue={}
    e.C_Timer.After=function(delay,fn) queue[#queue+1]={delay=delay,fn=fn} end
    local db,root=S.New(); local ui
    local r=NS.Collectors.New(e,db,function() if ui then ui:Refresh() end end)
    check(r:Scan(),r.reason)
    local mix={{2906,171,3},{2912,182,4},{2916,186,6},{2917,393,11},{2908,185,5},{2911,356,10}}
    for n=2,46 do
        local spec=mix[(n-2)%#mix+1]
        check(S.Apply(db,{guid=n==2 and 'PRIVATE-GUID' or 'alt'..n,name='Fixture'..n,realm='Fixture'},identity(spec),
            {skill=C.Observation('observed',{skillLevel=1,maxSkillLevel=100,skillModifier=0},100,'fixture'),
            concentration=C.Observation('observed',{id=777,quantity=100,maxQuantity=1000,
                rechargingCycleDurationMS=1000,rechargingAmountPerCycle=1},100,'fixture')},100,'fixture'))
    end
    st.at=200
    ui=NS.Dashboard.New(e,r); ui:Toggle()
    local cmd=NS.Commands.New(e); cmd.collector=r; cmd.dashboard=ui
    local function step() ui.buildDriver.scripts.OnUpdate(ui.buildDriver,.016) end
    local function finish()
        local n=0
        while ui.buildJob do n=n+1; check(n<10000,'bounded callbacks'); step() end
        check(ui.completed and not ui.retained,'completed publication')
    end
    finish(); eq(#ui.rows,46); eq(#ui.widgets,12)
    local w
    for _,v in ipairs(ui.widgets) do if v.row.id==2913 and v.row.guid=='PRIVATE-GUID' then w=v end end
    check(w,'visible actual scanned profession')
    local function scan() local q=table.remove(queue,1); check(q and q.delay==0,'actual queued Scan'); q.fn() end
    local function frame() ui.frame.scripts.OnUpdate(ui.frame,.016) end
    return ui,r,st,e,root,cmd,scan,frame,finish,w,step,queue
end
local function indicators(w,dot,estimate,label)
    eq(w.cells[V.index.Name].currentDot.shown,dot,'dot')
    eq(w.cells[V.index.Concentration].estimate.shown,estimate,'estimate')
    if label then eq(w.cells[V.index.Concentration].label.text,label,'coherent label') end
end
local function hook(t,key,fn,body)
    local old=t[key]; t[key]=fn(old)
    local ok,why=xpcall(body,debug.traceback); t[key]=old; assert(ok,why)
end
local function renew(r,st,at,now)
    local old=r.StartLoads
    r.StartLoads=function(self,...) st.at=now; return old(self,...) end
    st.at=at
    local ok,why=pcall(r.Scan,r)
    r.StartLoads=old
    check(ok,why)
end
local function noReset(w,fn,estimate)
    local dot=w.cells[V.index.Name].currentDot
    local cell=w.cells[V.index.Concentration]
    local dn,en,ln=#dot.calls,#cell.estimate.calls,#cell.label.calls
    fn()
    for n=dn+1,#dot.calls do
        local x=dot.calls[n]
        check(x[1]~='Hide' and x[1]~='IsShown' and x[1]~='ClearAllPoints' and
            x[1]~='SetText' and not(x[1]=='SetShown' and x[2]==false),'no dot reset')
    end
    if estimate then
        for n=en+1,#cell.estimate.calls do
            local x=cell.estimate.calls[n]
            check(x[1]~='Hide' and x[1]~='ClearAllPoints' and x[1]~='SetSize' and
                not(x[1]=='SetShown' and x[2]==false),'frozen estimate geometry')
        end
        for n=ln+1,#cell.label.calls do check(cell.label.calls[n][1]~='SetText','frozen label') end
    end
end
local function fallen(ui)
    for _,w in ipairs(ui.widgets) do
        if w.shown then
            check(not w.cells[V.index.Name].currentDot.shown,'unsafe dot')
            check(not w.cells[V.index.Concentration].estimate.shown,'unsafe estimate')
        end
    end
end
case('R03 event during build dashboard frame before real queued Scan',function()
    local ui,r,st,e,root,cmd,scan,frame,finish,w=setup()
    indicators(w,true,true); ui:Refresh()
    local verify=unchanged(root); local token=S.Token(r.db,'PRIVATE-GUID',2913)
    cmd:Event('CURRENCY_DISPLAY_UPDATE',777); frame()
    indicators(w,true,true); verify(); eq(S.Token(r.db,'PRIVATE-GUID',2913),token)
end)
case('R03 real queued Scan before dashboard frame renews zero-gain cell',function()
    local ui,r,st,e,root,cmd,scan,frame,finish,w=setup()
    ui:Refresh(); cmd:Event('CURRENCY_DISPLAY_UPDATE',777); st.at=210; scan()
    indicators(w,true,false,'100/1000'); frame(); indicators(w,true,false,'100/1000')
    local verify=unchanged(root); finish(); verify()
end)
case('R03 verified renewed observation uses shared render clock for positive gain',function()
    local ui,r,st,e,root,cmd,scan,frame,finish,w=setup()
    -- Advance the synthetic clock after the actual commit and before its synchronous
    -- StartLoads/Expire changed callback, not by replacing the collector with a fake.
    local start=r.StartLoads
    r.StartLoads=function(self,...) st.at=220; return start(self,...) end
    st.at=210; st.quantity=150; check(r:Scan(),r.reason)
    indicators(w,true,true,'~160/1000')
    local verify=unchanged(root); frame(); indicators(w,true,true,'~160/1000'); verify()
end)
case('R03 coalesced events and both callback orders preserve dots without reset',function()
    for _,first in ipairs({'frame','scan','build'}) do
        local ui,r,st,e,root,cmd,scan,frame,finish,w,step,queue=setup()
        local oldJob
        noReset(w,function() ui:Refresh(); oldJob=ui.buildJob end,true)
        local serial=r.serial; local revision=r.revision
        for n=1,3 do cmd:Event('CURRENCY_DISPLAY_UPDATE',777) end
        eq(#queue,1,'events coalesce'); eq(r.serial,serial); eq(r.revision,revision+3)
        if first=='frame' then noReset(w,frame,true)
        elseif first=='build' then noReset(w,step,true) end
        check(ui.buildJob,'pending job'); if first~='scan' then check(ui.buildJob~=oldJob,'old job retired') end
        st.at=210; noReset(w,scan)
        indicators(w,true,false,'100/1000')
        local verify=unchanged({root,r.fresh,ui.rows}); local token=S.Token(r.db,'PRIVATE-GUID',2913)
        noReset(w,frame,true); noReset(w,step,true)
        verify(); eq(S.Token(r.db,'PRIVATE-GUID',2913),token)
        finish()
    end
end)
case('R03 signal exact scope lifecycle and sync Expire publication ordering',function()
    local ui,r,st,e,root,cmd,scan,frame,finish,w,step,queue=setup()
    local h=r:DashboardHandoff()
    eq(h.kind,'observed'); eq(h.db,r.db); eq(h.fresh,r.fresh)
    eq(h.serial,r.serial); eq(h.revision,r.revision)
    -- Mixed fixture writes are intentionally later than the original Scan signal.
    check(h.storeRevision~=S.Revision(r.db),'stale record detectable')
    r:Invalidate('bare'); eq(r:DashboardHandoff(),nil)
    cmd:Event('CURRENCY_DISPLAY_UPDATE',777)
    h=r:DashboardHandoff(); eq(h.kind,'requested'); eq(h.storeRevision,S.Revision(r.db))
    cmd:Event('CURRENCY_DISPLAY_UPDATE',777); check(r:DashboardHandoff()~=h,'new publication identity')
    local changed=r.changed; local calls=0
    r.changed=function()
        calls=calls+1
        local x=r:DashboardHandoff(); eq(x.kind,'observed'); eq(x.guid,'PRIVATE-GUID'); eq(x.id,2913)
        eq(x.generation,S.Active(r.db,x.guid,x.id).generation)
        eq(x.storeRevision,S.Revision(r.db)); eq(x.fresh,r.fresh)
        changed()
    end
    st.at=210; scan(); eq(calls,2,'unchanged sync Expire plus Scan changed callbacks')
    local verify=unchanged({root,r:DashboardHandoff()}); frame(); verify()
end)
case('R03 failed unsafe and unscheduled collector paths grant no record',function()
    for _,mode in ipairs({'combat','unknown-combat','storage','scheduler','scheduler-throw','scan-context','scan-clock','scan-storage','bad-serial'}) do
        local ui,r,st,e,root,cmd,scan,frame,finish,w=setup()
        if mode=='combat' then st.combat=true
        elseif mode=='unknown-combat' then e.InCombatLockdown=function() return nil end
        elseif mode=='storage' or mode=='scan-storage' then r.storagePending=true
        elseif mode=='scheduler' then e.C_Timer=nil
        elseif mode=='scheduler-throw' then e.C_Timer.After=function() error('scheduler unavailable') end
        elseif mode=='scan-context' then st.ready=false
        elseif mode=='scan-clock' then e.GetServerTime=function() return nil end
        elseif mode=='bad-serial' then r.serial='invalid' end
        if mode:match('^scan') or mode=='bad-serial' then check(not r:Scan())
        elseif mode=='scheduler-throw' then check(not pcall(r.Request,r,'unsafe'))
        else r:Request('unsafe') end
        eq(r:DashboardHandoff(),nil,mode)
        if mode=='scheduler-throw' then r:Request('still no queued work'); eq(r:DashboardHandoff(),nil) end
    end
end)
case('R03 bounded actual requested handoff has no eager job work or extra UI acquisition',function()
    local ui,r,st,e,root,cmd,scan,frame,finish,w=setup(); ui:Refresh()
    cmd:Event('CURRENCY_DISPLAY_UPDATE',777)
    local active,estimates,guids,clocks=0,0,0,0
    local token=S.Token(r.db,'PRIVATE-GUID',2913); local verify=unchanged({root,r.fresh,ui.rows})
    hook(S,'Active',function(old) return function(...) active=active+1; return old(...) end end,function()
    hook(V,'ConcentrationEstimate',function(old) return function(...) estimates=estimates+1; return old(...) end end,function()
    hook(e,'UnitGUID',function(old) return function(...) guids=guids+1; return old(...) end end,function()
    hook(r,'Now',function(old) return function(...) clocks=clocks+1; return old(...) end end,function()
        noReset(w,frame,true); eq(active,12); eq(estimates,0); eq(guids,1); eq(clocks,2)
        local job=ui.buildJob; local steps=job.steps
        for n=1,3 do noReset(w,function() frame(); ui:Render() end,true) end
        eq(active,12,'retained renders no Active reads'); eq(estimates,0)
        eq(ui.buildJob,job); eq(job.steps,steps,'no eager iterator')
    end) end) end) end)
    verify(); eq(S.Token(r.db,'PRIVATE-GUID',2913),token)
end)
case('R03 replacement scalar coherent frozen through repeated Render and requested successor',function()
    local ui,r,st,e,root,cmd,scan,frame,finish,w=setup()
    local estimates=0
    hook(V,'ConcentrationEstimate',function(old) return function(...) estimates=estimates+1; return old(...) end end,function()
        renew(r,st,210,220); eq(estimates,1,'once despite two changed callbacks')
        indicators(w,true,true,'~110/1000')
        local cell=w.cells[V.index.Concentration]
        eq(cell.bar.value,.1); eq(cell.estimate.width,.01*92)
        eq(cell.estimate.points[1][4],.1*92)
        local verify=unchanged({root,r.fresh,ui.rows}); local token=S.Token(r.db,'PRIVATE-GUID',2913)
        st.at=250
        for n=1,3 do noReset(w,function() ui:Render(); frame() end,true) end
        cmd:Event('CURRENCY_DISPLAY_UPDATE',777); noReset(w,frame,true)
        indicators(w,true,true,'~110/1000'); eq(estimates,1,'requested successor freezes replacement')
        verify(); eq(S.Token(r.db,'PRIVATE-GUID',2913),token)
    end)
end)
case('R03 multiple successful scans replace only new provenance not cached completed rows',function()
    local ui,r,st,e,root,cmd,scan,frame,finish,w=setup()
    local oldRows=ui.rows; local verifyRows=unchanged(oldRows)
    for n=1,3 do
        st.quantity=100+n*50
        renew(r,st,200+n*20,210+n*20)
        indicators(w,true,true,'~'..(110+n*50)..'/1000')
        eq(ui.rows,oldRows); verifyRows()
        local verify=unchanged(root); frame(); ui:Render(); verify()
    end
    st.at=300; finish(); check(ui.rows~=oldRows); verifyRows()
end)
case('R03 renewed value time build currency capacity and recharge provenance',function()
    for _,mode in ipairs({'time','build','currency','amount','capacity','duration','rate'}) do
        local ui,r,st,e,root,cmd,scan,frame,finish,w=setup()
        local expected='~110/1000'
        if mode=='build' then e.GetBuildInfo=function() return 'new','new' end
        elseif mode=='currency' then st.currency=778
        elseif mode=='amount' then st.quantity=150; expected='~160/1000'
        elseif mode=='capacity' then st.cap=1200; expected='~110/1200'
        elseif mode=='duration' then st.duration=2000; expected='~105/1000'
        elseif mode=='rate' then st.rate=2; expected='~120/1000' end
        renew(r,st,210,220); indicators(w,true,true,expected)
        local verify=unchanged({root,ui.rows}); frame(); ui:Render(); verify()
    end
end)
case('R03 zero full invalid-rate future and unavailable clocks use truthful new cells',function()
    for _,mode in ipairs({'zero','full','zero-gain','rate','duration','future','backward','nil-clock'}) do
        local ui,r,st,e,root,cmd,scan,frame,finish,w=setup()
        local now,label,estimate=220,'100/1000',false
        if mode=='zero' then st.quantity=0; label='~10/1000'; estimate=true
        elseif mode=='full' then st.quantity=1000; label='1000/1000'
        elseif mode=='zero-gain' then now=210
        elseif mode=='rate' then st.rate=0
        elseif mode=='duration' then st.duration=0
        elseif mode=='future' or mode=='backward' then now=209
        elseif mode=='nil-clock' then now=nil end
        renew(r,st,210,now); indicators(w,true,estimate,label)
        local verify=unchanged(root); frame(); verify()
    end
end)
case('R03 failed and unknown new attempts never lend obsolete prediction',function()
    for _,mode in ipairs({'error','unknown'}) do
        local ui,r,st,e,root,cmd,scan,frame,finish,w=setup()
        st.currencyError=mode=='error'; st.currencyUnknown=mode=='unknown'
        renew(r,st,210,220)
        indicators(w,true,false,'100/1000')
        local g=S.Active(r.db,'PRIVATE-GUID',2913)
        eq(g.fields.concentration.last.observedAt,100,'known observation retained')
        eq(g.fields.concentration.attempt.status,mode)
    end
end)
case('R03 actual item retry and timeout callbacks preserve unchanged concentration replacement',function()
    for _,mode in ipairs({'success','failure','timeout'}) do
        local ui,r,st,e,root,cmd,scan,frame,finish,w,step,queue=setup()
        st.loading=true; renew(r,st,210,220); indicators(w,true,true,'~110/1000')
        local before=r:DashboardHandoff(); local at=S.Active(r.db,'PRIVATE-GUID',2913).fields.concentration.last.observedAt
        local count=0
        hook(V,'ConcentrationEstimate',function(old) return function(...) count=count+1; return old(...) end end,function()
            noReset(w,function()
                if mode=='timeout' then local q=table.remove(queue,1); eq(q.delay,5); q.fn()
                else st.loading=false; r:ItemResult(st.itemID,mode=='success') end
            end,true)
            eq(count,0,'item-only commit cannot infer changed Concentration')
        end)
        indicators(w,true,true,'~110/1000')
        eq(S.Active(r.db,'PRIVATE-GUID',2913).fields.concentration.last.observedAt,at)
        if mode~='failure' then check(r:DashboardHandoff()~=before); eq(r:DashboardHandoff().storeRevision,S.Revision(r.db)) end
        local verify=unchanged(root); frame(); verify()
    end
end)
case('R03 missing throwing malformed stale signal and bare drift fail closed',function()
    for _,mode in ipairs({'absent','throw','nil','kind','db','fresh','serial','revision','storeRevision','scope','meta','stale','bare','unsigned-token'}) do
        local ui,r,st,e,root,cmd,scan,frame,finish,w=setup(); ui:Refresh()
        if mode=='bare' then r:Invalidate('bare')
        elseif mode=='unsigned-token' then
            check(S.Apply(r.db,{guid='PRIVATE-GUID',name='Fixture',realm='Fixture'},identity({2913,773,13}),
                {unspent=C.Observation('observed',9,210,'fixture')},210,'fixture'))
        else
            local old=r:DashboardHandoff(); cmd:Event('CURRENCY_DISPLAY_UPDATE',777)
            local h=r:DashboardHandoff()
            if mode=='absent' then r.DashboardHandoff=nil
            elseif mode=='throw' then r.DashboardHandoff=function() error('signal fault') end
            elseif mode=='nil' then r.DashboardHandoff=function() end
            elseif mode=='stale' then r.DashboardHandoff=function() return old end
            else
                local fake={}; for k,v in pairs(h) do fake[k]=v end
                if mode=='kind' then fake.kind='invalid'
                elseif mode=='scope' then fake.kind='observed'; fake.guid=''; fake.id=2913; fake.generation=1
                elseif mode=='meta' then setmetatable(fake,{})
                else fake[mode]=({db={},fresh={},serial=-1,revision=-1,storeRevision=-1})[mode] end
                r.DashboardHandoff=function() return fake end
            end
        end
        local verify=unchanged(root); frame(); fallen(ui); verify()
    end
end)
case('R03 signal never authorizes changed identity source GUID options or removed generation',function()
    for _,mode in ipairs({'guid','option','option-ref','db','detach','archive','delete','generation','unsupported'}) do
        local ui,r,st,e,root,cmd,scan,frame,finish,w=setup(); ui:Refresh()
        cmd:Event('CURRENCY_DISPLAY_UPDATE',777)
        if mode=='guid' then e.UnitGUID=function() return 'other' end
        elseif mode=='option' then ui.options.character='no match'
        elseif mode=='option-ref' then ui.options=C.Copy(ui.options); ui.options.character='no match'
        elseif mode=='db' then r.db=S.New()
        elseif mode=='detach' then r.db=nil
        elseif mode=='archive' or mode=='generation' then
            check(S.Archive(r.db,'PRIVATE-GUID',2913,210,'fixture'))
            if mode=='generation' then check(S.Apply(r.db,{guid='PRIVATE-GUID',name='Fixture',realm='Fixture'},identity({2913,773,13}),{},210,'fixture')) end
        elseif mode=='delete' then check(S.Delete(r.db,{guid='PRIVATE-GUID',id=2913,generation=1},true))
        else
            hook(S,'Active',function(old) return function(...)
                local g,why=old(...)
                if g then g=C.Copy(g); g.identity.profession=999 end
                return g,why
            end end,function() frame() end)
        end
        if mode~='unsupported' then frame() end
        check(not w.shown or not w.cells[V.index.Name].currentDot.shown,'target unsafe dot '..mode)
        check(not w.shown or not w.cells[V.index.Concentration].estimate.shown,'target unsafe estimate '..mode)
    end
end)
case('R03 valid observed signal with wrong committed scope cannot replace changed cell',function()
    for _,key in ipairs({'guid','id','generation'}) do
        local ui,r,st,e,root,cmd,scan,frame,finish,w=setup()
        local seen,fake
        hook(r,'DashboardHandoff',function(old) return function(self)
            local h=old(self); if not h then return end
            if seen~=h then
                seen=h; fake={}; for k,v in pairs(h) do fake[k]=v end
                fake[key]=key=='guid' and 'alt3' or key=='id' and 2906 or 999
            end
            return fake
        end end,function() st.quantity=150; renew(r,st,210,220) end)
        indicators(w,true,false,'100/1000')
    end
end)
case('R03 changed-again signal during handoff attempt fails closed with no recursive rearm',function()
    local ui,r,st,e,root,cmd,scan,frame,finish,w=setup(); ui:Refresh()
    cmd:Event('CURRENCY_DISPLAY_UPDATE',777)
    local calls=0; local attempts=0
    hook(ui,'StartBuild',function(old) return function(self)
        attempts=attempts+1; return old(self)
    end end,function()
    hook(r,'DashboardHandoff',function(old) return function(self)
        calls=calls+1
        local h=old(self)
        if calls==2 then self:Invalidate('changed again') end
        return h
    end end,function() frame() end)
    end)
    eq(attempts,1,'bounded attempt'); fallen(ui)
end)
case('R03 verified replacement reads at most12active rows and never copies account graphs',function()
    local ui,r,st,e,root,cmd,scan,frame,finish,w=setup()
    local old=r.StartLoads; local reads=0; local estimates=0
    r.StartLoads=function(self,...)
        st.at=220
        local args={...}
        hook(C,'Copy',function(copy) return function(value)
            check(value~=root and value~=root.characters and value~=ui.rows,'no account/list copy')
            check(type(value)~='table' or not value.cells,'no whole row copy')
            return copy(value)
        end end,function()
        hook(S,'Active',function(active) return function(...) reads=reads+1; check(reads<=12); return active(...) end end,function()
        hook(S,'NewIterator',function(iterator) return function(...)
            local it=iterator(...); it.Step=function() error('no eager iteration') end; return it
        end end,function()
        hook(V,'ConcentrationEstimate',function(estimate) return function(...) estimates=estimates+1; return estimate(...) end end,function()
            old(self,unpack(args)); eq(reads,12); eq(estimates,1)
            for n=1,3 do ui:Render() end
            eq(reads,12); eq(estimates,1); eq(ui.buildJob.steps,0)
        end) end) end) end)
    end
    st.at=210; check(r:Scan()); r.StartLoads=old
    eq(reads,12); eq(estimates,1); indicators(w,true,true,'~110/1000')
end)
case('R03 preparation signal Active Token source clock and widget faults revoke safely',function()
    for _,mode in ipairs({'signal','Active','Token','Check','Revision','clock','label','bar','estimate','setup','batch-setup','scheduler'}) do
        local ui,r,st,e,root,cmd,scan,frame,finish,w=setup(); ui:Refresh()
        cmd:Event('CURRENCY_DISPLAY_UPDATE',777)
        local object,key
        if mode=='signal' then object,key=r,'DashboardHandoff'
        elseif mode=='clock' then object,key=r,'Now'
        elseif mode=='label' then object,key=w.cells[V.index.Name].label,'SetText'
        elseif mode=='bar' then object,key=w.cells[V.index.Concentration].bar,'SetValue'
        elseif mode=='estimate' then object,key=w.cells[V.index.Concentration].label,'SetShown'
        elseif mode=='setup' then object,key=V,'NewBuildJob'
        elseif mode=='batch-setup' then object,key=S,'NewFrameBatch'
        elseif mode=='scheduler' then object,key=ui.buildDriver,'SetScript'
        else object,key=S,mode end
        local fired=false; local verify=unchanged(root)
        hook(object,key,function() return function() fired=true; error('synthetic '..mode..' fault') end end,function()
            check(pcall(frame),'protected frame handoff')
        end)
        check(fired,mode); fallen(ui); ui:Refresh(); fallen(ui); verify()
    end
end)
case('R03 new scalar paint exceptions never leave obsolete prediction over changed bar',function()
    for _,mode in ipairs({'estimate-point','estimate-size','estimate-show','label','bar-color','bar-value','estimate-model','clock'}) do
        local ui,r,st,e,root,cmd,scan,frame,finish,w=setup()
        local cell=w.cells[V.index.Concentration]
        local object,key
        if mode=='estimate-point' then object,key=cell.estimate,'SetPoint'
        elseif mode=='estimate-size' then object,key=cell.estimate,'SetSize'
        elseif mode=='estimate-show' then object,key=cell.estimate,'SetShown'
        elseif mode=='label' then object,key=cell.label,'SetText'
        elseif mode=='bar-color' then object,key=cell.bar,'SetStatusBarColor'
        elseif mode=='bar-value' then object,key=cell.bar,'SetValue'
        elseif mode=='estimate-model' then object,key=V,'ConcentrationEstimate'
        else object,key=r,'Now' end
        local fired=false
        local start=r.StartLoads
        r.StartLoads=function(self,...)
            local args={...}; st.at=220
            hook(object,key,function() return function() fired=true; error('synthetic cell paint fault') end end,function()
                start(self,unpack(args))
            end)
        end
        st.quantity=150; st.at=210; check(r:Scan()); r.StartLoads=start
        check(fired,mode); check(not w.shown or not cell.estimate.shown,'no stranded cyan '..mode)
        ui:Refresh(); check(not w.shown or not cell.estimate.shown,'no failed cache reuse '..mode)
    end
end)
local function boundary(ui,r,e,w,mode)
    if mode=='signal' then return r,'DashboardHandoff'
    elseif mode=='Active' or mode=='Token' then return S,mode
    elseif mode=='clock' then return r,'Now'
    elseif mode=='cancel' then return ui.buildJob,'Cancel'
    elseif mode=='setup' then return V,'NewBuildJob'
    elseif mode=='scheduler' then return ui.buildDriver,'SetScript'
    elseif mode=='estimate' then return w.cells[V.index.Concentration].estimate,'SetPoint'
    elseif mode=='bar' then return w.cells[V.index.Concentration].bar,'SetValue'
    elseif mode=='label' then return w.cells[V.index.Concentration].label,'SetText'
    elseif mode=='status' or mode=='publication' then return ui.reason,'SetText'
    elseif mode=='Step' then return ui.buildJob,'Step'
    elseif mode=='batch' then return ui.buildBatch,'Step'
    end
end
case('R03 signalled handoff reentry preserves newer completed job status hover and scroll',function()
    for _,mode in ipairs({'signal','Active','Token','clock','cancel','setup','scheduler','status','Step','batch','publication'}) do
        local ui,r,st,e,root,cmd,scan,frame,finish,w,step=setup(); ui:Refresh()
        cmd:Event('CURRENCY_DISPLAY_UPDATE',777)
        -- Step/batch/publication must target the successor, not the cancelled job.
        if mode=='Step' or mode=='batch' or mode=='publication' then frame() end
        local object,key=boundary(ui,r,e,w,mode)
        local fired=false; local rows,job,status
        hook(object,key,function(old) return function(...)
            local result=old(...)
            if not fired then
                fired=true; ui.options.sortColumn=V.index.Name; ui:Refresh(); finish()
                rows,job,status=ui.rows,ui.buildJob,ui.reason.text
                ui:QueueScroll(2)
                local cell=ui.widgets[2].cells[V.index.Concentration]; cell.scripts.OnEnter(cell)
            end
            return result
        end end,function()
            if mode=='publication' then finish()
            elseif mode=='Step' or mode=='batch' then step() else frame() end
        end)
        check(fired,mode); eq(ui.rows,rows,mode); eq(ui.buildJob,job); eq(ui.reason.text,status)
        check(e.GameTooltip.shown,'newer hover '..mode)
        frame(); eq(ui.offset,2,'newer scroll '..mode)
    end
end)
case('R03 changed scalar native/model reentry cannot overwrite newer same-build paint',function()
    for _,mode in ipairs({'estimate','bar','label','clock'}) do
        local ui,r,st,e,root,cmd,scan,frame,finish,w=setup(); ui:Refresh()
        local object,key=boundary(ui,r,e,w,mode)
        local fired=false; local status,rows,job
        local start=r.StartLoads
        r.StartLoads=function(self,...)
            local args={...}; st.at=220
            hook(object,key,function(old) return function(...)
                local result=old(...)
                if not fired then
                    fired=true; ui:Render(); rows,job,status=ui.rows,ui.buildJob,ui.reason.text
                    ui:QueueScroll(2)
                    local cell=ui.widgets[2].cells[V.index.Concentration]; cell.scripts.OnEnter(cell)
                end
                return result
            end end,function() start(self,unpack(args)) end)
            check(fired,mode); eq(ui.rows,rows); eq(ui.buildJob,job); eq(ui.reason.text,status)
            check(e.GameTooltip.shown,'same-build hover '..mode)
            frame(); eq(ui.offset,2,'same-build scroll '..mode)
        end
        st.at=210; st.quantity=150; check(r:Scan()); r.StartLoads=start
    end
end)
case('R03 unsignalled mutation during eligibility and scalar painting fails closed',function()
    for _,where in ipairs({'Active','estimate','bar','label','clock'}) do
    for _,mode in ipairs({'token','option','guid','source','hide','combat','row'}) do
        local ui,r,st,e,root,cmd,scan,frame,finish,w=setup(); ui:Refresh()
        local object,key=boundary(ui,r,e,w,where); local fired=false
        local start=r.StartLoads
        r.StartLoads=function(self,...)
            local args={...}; st.at=220
            hook(object,key,function(old) return function(...)
                local results={old(...)}
                if not fired then
                    fired=true
                    if mode=='token' then check(S.Apply(r.db,{guid='PRIVATE-GUID',name='Fixture',realm='Fixture'},identity({2913,773,13}),
                        {unspent=C.Observation('observed',9,220,'mutation')},220,'fixture'))
                    elseif mode=='option' then ui.options.character='no match'
                    elseif mode=='guid' then ui.options.currentPlayerGUID='other'
                    elseif mode=='source' then r.db=nil
                    elseif mode=='hide' then ui.frame.shown=false
                    elseif mode=='combat' then st.combat=true
                    else w.row.concentrationValue.quantity=999 end
                end
                return unpack(results)
            end end,function() start(self,unpack(args)) end)
        end
        st.at=210; st.quantity=150; check(r:Scan()); r.StartLoads=start
        check(fired,where..'/'..mode); fallen(ui)
    end end
end)
case('R03 private one-shot wrappers and exceptions preserve cleanup on actual handoff',function()
    for _,method in ipairs({'Render','Retain','StopBuild'}) do
    for _,throw in ipairs({false,true}) do
        local ui,r,st,e,root,cmd,scan,frame,finish,w=setup(); ui:Refresh()
        cmd:Event('CURRENCY_DISPLAY_UPDATE',777)
        local fired=false
        hook(ui,method,function(old) return function(self)
            fired=true
            if throw then error('pre-entry self-only wrapper fault') end
            return old(self)
        end end,function() check(pcall(frame)) end)
        check(fired,method)
        if throw then fallen(ui); ui:Refresh(); fallen(ui)
        else indicators(w,true,true); finish() end
    end end
end)
case('R03 pending handoff actions hovers warnings and cancellation remain historical',function()
    local ui,r,st,e,root,cmd,scan,frame,finish,w=setup()
    renew(r,st,210,220)
    check(ui.retained and ui.buildJob); check(not ui:ActionsReady())
    for _,button in ipairs(ui.footer) do eq(button.style.SetEnabled[1],false) end
    local rows=ui.rows; local verify=unchanged({root,r.fresh,rows})
    local cell=w.cells[V.index.Concentration]; cell.scripts.OnEnter(cell)
    check(table.concat(e.GameTooltip.lines,'\n'):find('Previous saved values',1,true),'historical hover')
    ui:StopBuild(); fallen(ui); verify()
    ui:Refresh(); fallen(ui)
end)
case('R03 initially unknown and nonapplicable cells never gain fabricated projections',function()
    local ui,r,st,e,root,cmd,scan,frame,finish,w=setup('unknown')
    indicators(w,true,false,'?')
    st.at=210; check(r:Scan()); indicators(w,true,false,'?')
    for _,widget in ipairs(ui.widgets) do
        if widget.row.notApplicableColumns[V.index.Concentration] then
            eq(widget.cells[V.index.Concentration].label.text,'—')
            eq(widget.cells[V.index.Concentration].estimate.shown,false)
        end
    end
    st.currencyUnknown=false; renew(r,st,230,240)
    indicators(w,true,true,'~110/1000')
end)
case('R03 renewed cell cancellation hide drop scroll and row reuse revoke paint',function()
    for _,mode in ipairs({'cancel','hide','drop','retain','scroll','widget-row'}) do
        local ui,r,st,e,root,cmd,scan,frame,finish,w=setup(); renew(r,st,210,220)
        if mode=='cancel' then ui:StopBuild()
        elseif mode=='hide' then ui.frame.shown=false; ui.frame.scripts.OnHide()
        elseif mode=='drop' then ui:DropCompleted()
        elseif mode=='retain' then ui:Retain('explicit')
        elseif mode=='scroll' then ui:ScrollTo(2)
        else w.row=ui.rows[3]; frame() end
        fallen(ui)
    end
end)
case('R03 replacement backward clock cannot revive until new observed successor',function()
    local ui,r,st,e,root,cmd,scan,frame,finish,w=setup(); renew(r,st,210,220)
    st.at=209; ui:Render(); indicators(w,true,false,'100/1000')
    st.at=250; ui:Render(); indicators(w,true,false,'100/1000')
    cmd:Event('CURRENCY_DISPLAY_UPDATE',777); frame(); indicators(w,true,false,'100/1000')
    renew(r,st,260,270); indicators(w,true,true,'~110/1000')
end)
case('R03 signal Active Token reentry to same-build owner preserves newer hover scroll',function()
    -- A separate callback may refresh legitimately; ownership assertions here stay
    -- within the single frame callback being deliberately reentered.
    for _,mode in ipairs({'signal','Active','Token'}) do
        local ui,r,st,e,root,cmd,scan,frame,finish,w=setup(); ui:Refresh()
        cmd:Event('CURRENCY_DISPLAY_UPDATE',777)
        local object,key=boundary(ui,r,e,w,mode); local fired=false; local rows,job,status
        hook(object,key,function(old) return function(...)
            local result=old(...)
            if not fired then
                fired=true; ui:Render(); rows,job,status=ui.rows,ui.buildJob,ui.reason.text
                ui:QueueScroll(2)
                local cell=ui.widgets[2].cells[V.index.Concentration]; cell.scripts.OnEnter(cell)
            end
            return result
        end end,frame)
        check(fired,mode); eq(ui.rows,rows); eq(ui.buildJob,job); eq(ui.reason.text,status)
        check(e.GameTooltip.shown,'newer same-build hover '..mode)
        frame(); eq(ui.offset,2,'newer same-build scroll '..mode)
    end
end)
case('R03 positive renewed cell never hides valid cyan first and other own profession stays frozen',function()
    local ui,r,st,e,root,cmd,scan,frame,finish,w=setup()
    local other
    for _,widget in ipairs(ui.widgets) do
        if widget.row.guid=='PRIVATE-GUID' and widget.row.id~=2913 then other=widget end
    end
    check(other,'second own profession')
    local cell=w.cells[V.index.Concentration]; local n=#cell.estimate.calls
    noReset(other,function() st.quantity=150; renew(r,st,210,220) end,true)
    for i=n+1,#cell.estimate.calls do
        local call=cell.estimate.calls[i]
        check(call[1]~='Hide' and not(call[1]=='SetShown' and call[2]==false),'no preliminary cyan demotion')
    end
    indicators(w,true,true,'~160/1000'); indicators(other,true,true,'~200/1000')
    eq(cell.bar.value,.15); eq(cell.estimate.width,.01*92)
    eq(cell.estimate.points[1][4],.15*92)
    local verify=unchanged({root,ui.rows,r.fresh}); ui:Render(); frame(); verify()
end)
case('R03 throwing self-only wrappers cannot erase newer same-build or new-build owner',function()
    for _,method in ipairs({'Render','Retain','StopBuild'}) do
    for _,when in ipairs({'before','after'}) do
    for _,newer in ipairs({'same','new'}) do
        local ui,r,st,e,root,cmd,scan,frame,finish,w=setup(); ui:Refresh()
        cmd:Event('CURRENCY_DISPLAY_UPDATE',777)
        local fired=false; local rows,job,status
        hook(ui,method,function(old) return function(self)
            if fired then return old(self) end
            fired=true
            if when=='after' then old(self) end
            if newer=='same' then ui:Render()
            else ui.options.sortColumn=V.index.Name; ui:Refresh(); finish() end
            rows,job,status=ui.rows,ui.buildJob,ui.reason.text
            ui:QueueScroll(2)
            local cell=ui.widgets[2].cells[V.index.Concentration]; cell.scripts.OnEnter(cell)
            error('retired wrapper stack fault')
        end end,function() check(pcall(frame)) end)
        check(fired,method..when..newer); eq(ui.rows,rows); eq(ui.buildJob,job); eq(ui.reason.text,status)
        check(e.GameTooltip.shown,'newer wrapper hover')
        frame(); eq(ui.offset,2,'newer wrapper scroll')
    end end end
end)
print('R03 additive: '..passed..' groups passed; '..failed..' failed; '..checks..' assertions (synthetic, not native evidence)')
if failed>0 then os.exit(1) end
]=]
assert(loadstring(helpers.."\n"..native.."\n"..tests,"R03-collection-continuity"))()
