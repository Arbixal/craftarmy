local _, NS = ...
local Dashboard, V, C, D = {}, NS.ViewModel, NS.Core, NS.Data
local loadedDashboardBuild="0.2.0-mvp+p04.1"
NS.Dashboard = Dashboard
local I=V.index
local S=NS.Storage
local widths={110,100,150,64,34,28,34,0,0,96,56,292,74,100}
local G={margin=15,screenMargin=30,rowHeight=28,pageRows=12,baseHeight=194,
    headerTop=96,headerHeight=18,viewportTop=118,toolbarTop=60}
G.contentWidth=0
for _,width in ipairs(widths) do G.contentWidth=G.contentWidth+width end
G.outerWidth=G.contentWidth+2*G.margin+16
local shortHeaders={[I.Accessory1]="Gear"}
local roleColumns={[I.Accessory1]="accessory1",[I.Accessory2]="accessory2",[I.Tool]="tool"}
local function clean(text)
    -- Labels are not executable markup. Item hyperlink rendering is separate.
    return tostring(text or ""):gsub("|","||")
end
function Dashboard.SkillProgress(skill)
    if type(skill)~="table" or not C.Integer(skill.skillLevel,0) or not C.Integer(skill.maxSkillLevel,1) then
        return nil,.45,.50,.58
    end
    local ratio=math.min(1,math.max(0,skill.skillLevel/skill.maxSkillLevel))
    if ratio==1 then return ratio,.20,.78,.30 end
    if ratio<=.5 then
        local t=ratio*2
        return ratio,.85+.15*t,.20+.45*t,.20-.20*t
    end
    local t=(ratio-.5)*2
    return ratio,1-.80*t,.65+.13*t,.30*t
end
function Dashboard.ConcentrationProgress(value)
    if type(value)~="table" or not C.Integer(value.quantity,0) or not C.Integer(value.maxQuantity,1) then
        return nil,.45,.50,.58
    end
    local ratio=math.min(1,math.max(0,value.quantity/value.maxQuantity))
    if ratio==1 then return ratio,.20,.78,.30 end
    return ratio,.20,.65,.95
end
local function moxieRGB(row,retained)
    if not C.Finite(row.moxie) then return .45,.50,.58 end
    if row.moxie<=600 then return 1,1,1 end
    return .20,.78,.30
end
local function classRGB(env,token)
    -- Protect both native lookup/ColorMixin access and scalar validation. No
    -- runtime color objects or RGB values cross the saved-data boundary.
    local ok,r,g,b=pcall(function()
        if not C.ValidClassToken(token) then return end
        local api=env.C_ClassColor
        if not api or type(api.GetClassColor)~="function" then return end
        local color=api.GetClassColor(token)
        if not color then return end
        local red,green,blue
        if type(color.GetRGB)=="function" then red,green,blue=color:GetRGB()
        else red,green,blue=color.r,color.g,color.b end
        for _,v in ipairs({red,green,blue}) do
            if not C.Finite(v) or v<0 or v>1 then return end
        end
        if red==nil or green==nil or blue==nil then return end
        return red,green,blue
    end)
    if ok and r~=nil and g~=nil and b~=nil then return r,g,b end
    return 1,1,1
end
function Dashboard.PlainTooltip(text)
    local raw=tostring(text or "")
    local out,pos={},1
    while pos<=#raw do
        local pipe=raw:find("|",pos,true)
        if not pipe then out[#out+1]=raw:sub(pos); break end
        out[#out+1]=raw:sub(pos,pipe-1)
        local code=raw:sub(pipe+1,pipe+1)
        if code=="|" then
            out[#out+1]="||"; pos=pipe+2 -- Already literal pipes are never icon openers.
        else
            local atlas=code=="A" and raw:sub(pipe+2,pipe+2)==":"
            local bodyStart=pipe+(atlas and 3 or 2)
            local close=(atlas or code=="T") and raw:find("|",bodyStart,true) or nil
            local body=close and raw:sub(bodyStart,close-1) or ""
            local complete=close and body~="" and body:sub(1,1)~=":" and not body:match("^%s") and
                not body:find("[\r\n]") and raw:sub(close,close+1)==(atlas and "|a" or "|t")
            if complete then pos=close+2 else out[#out+1]="|"; pos=pipe+1 end
        end
    end
    return clean(table.concat(out))
end
local statuses={
    TRADE_SKILL_CLOSE="Profession closed — showing saved snapshots.",
    TRADE_SKILL_DATA_SOURCE_CHANGING="Profession changing — wait for your own ready profession.",
    TRADE_SKILL_DATA_SOURCE_CHANGED="Profession data changed — wait for your own ready profession.",
    PLAYER_REGEN_DISABLED="In combat — collection deferred; showing saved snapshots.",
    ["Open your own profession to refresh"]="Profession closed — showing saved snapshots. Open your own profession to refresh.",
    ["Combat/unknown safety; collection deferred"]="Collection deferred: combat or safety status unknown. Showing saved snapshots.",
    ["Dashboard deferred until out of combat."]="In combat — dashboard deferred; showing saved snapshots when safe.",
    ["Guarded snapshot collected; knowledge cost eligibility pending evidence."]="Snapshot refreshed; knowledge totals pending verification.",
}
function Dashboard.StatusText(raw,blockReason)
    if blockReason~=nil then return tostring(blockReason) end
    if raw==nil then return "No scan status; open your own profession to refresh." end
    return statuses[raw] or tostring(raw)
end

function Dashboard.New(env, collector)
    local self={env=env,collector=collector,options={},selected=nil,offset=0,widgets={}}
    local buildVersion,hoverVersion,renderVersion=0,0,0
    local estimateTick={elapsed=0}
    local scrollFeedback
    local pendingScroll,updateBusy
    local scrollRequest=0
    local guidQueryVersion=0
    -- R02: private paint ownership, never observations or model state. Only the
    -- twelve visible widget/row pairs can lend decorations to ordinary pending work.
    local lastPaint,continuity
    local handoffBusy
    local keepPaint={}
    local function preparationCurrent(owner)
        return not owner or (owner.version==buildVersion and owner.render==renderVersion and
            owner.hover==hoverVersion and owner.scroll==scrollRequest)
    end
    -- A public wrapper need only forward the original method arguments. Private
    -- ownership crosses that wrapper in a scoped, one-shot dispatch, NOT ambient
    -- inheritance: production entry consumes it before any native callback.
    local dispatch={}
    local cleanupFailedPreparation
    local productionStopBuild
    local function consumeDispatch(method)
        local ticket=dispatch[method]
        dispatch[method]=nil
        if ticket then ticket.consumed=true end
        return ticket
    end
    local function ownedCall(method,owner,permit,...)
        if not preparationCurrent(owner) then return false end
        local previous=dispatch[method]
        local ticket={owner=owner,permit=permit}
        dispatch[method]=ticket
        local ok,a,b=pcall(self[method],self,...)
        if dispatch[method]==ticket or dispatch[method]==nil then
            -- Restore only an unconsumed outer invocation, even if retired: its
            -- own entry must reject its stale owner, not become an unowned call.
            dispatch[method]=previous and not previous.consumed and previous or nil
        end
        if not ok then
            if owner and cleanupFailedPreparation then pcall(cleanupFailedPreparation,owner) end
            error(a,0)
        end
        return a,b
    end
    local function capturePlayerGUID()
        guidQueryVersion=guidQueryVersion+1
        local invocation,version,options,db=guidQueryVersion,buildVersion,self.options,collector.db
        local render,hover,scroll=renderVersion,hoverVersion,scrollRequest
        local ok,guid=pcall(function()
            if type(env.UnitGUID)=="function" then return env.UnitGUID("player") end
        end)
        if invocation~=guidQueryVersion or version~=buildVersion or options~=self.options or db~=collector.db or
            render~=renderVersion or hover~=hoverVersion or scroll~=scrollRequest then return false end
        if not ok or type(guid)~="string" or #guid==0 or #guid>128 or guid:find("[%c]") then guid=nil end
        self.options.currentPlayerGUID=guid
        return true
    end
    local function normalizeSort()
        local col=self.options.sortColumn
        if C.Integer(col,5) and col<=9 then self.options.sortColumn=nil; self.options.sortDescending=nil end
    end
    local function combat() return NS.Collectors.Call(env,"InCombatLockdown")~=false end
    local historical="Previous saved view / last observed; "
    local retainedHint="Previous saved values pending replacement (or refresh failed). Detailed freshness and gear tooltips are temporarily unavailable."
    local function validSource(db)
        local ok,valid=pcall(function()
            return db~=nil and collector.db==db and S.IsHandle(db) and S.Check(db)==db
        end)
        return ok and valid and collector.db==db
    end
    local function context()
        return {db=collector.db,fresh=collector.fresh,serial=collector.serial,revision=collector.revision,
            storeRevision=S.Revision(collector.db),options=assert(C.Copy(self.options))}
    end
    local function matches(c)
        if not c or not validSource(c.db) or collector.fresh~=c.fresh or collector.serial~=c.serial or
            collector.revision~=c.revision or S.Revision(c.db)~=c.storeRevision then return false end
        for k,v in pairs(c.options) do if self.options[k]~=v then return false end end
        for k,v in pairs(self.options) do if c.options[k]~=v then return false end end
        return true
    end
    local function sameOptions(a,b)
        for k,v in pairs(a) do if b[k]~=v then return false end end
        for k,v in pairs(b) do if a[k]~=v then return false end end
        return true
    end
    local function handoff(ctx)
        local ok,h=pcall(function()
            if type(collector.DashboardHandoff)~="function" then return end
            local h=collector:DashboardHandoff()
            if type(h)~="table" or getmetatable(h)~=nil or
                (h.kind~="requested" and h.kind~="observed") or
                h.db~=ctx.db or h.fresh~=ctx.fresh or h.serial~=ctx.serial or
                h.revision~=ctx.revision or h.storeRevision~=ctx.storeRevision or
                not C.Integer(h.serial) or not C.Integer(h.revision) or
                (h.kind=="observed" and (type(h.guid)~="string" or #h.guid==0 or
                    not C.Integer(h.id,1) or not C.Integer(h.generation,1))) or not matches(ctx) then return end
            return h
        end)
        return ok and h or nil
    end
    local function provenance(g)
        local f=g.fields and g.fields.concentration
        local l,a=f and f.last,f and f.attempt
        local v=l and l.value
        if not l or not a or l.status~="observed" or a.status~="observed" or type(v)~="table" then return end
        return {status=l.status,generation=l.generation,observedAt=l.observedAt,source=l.source,build=l.build,
            attemptedStatus=a.status,attemptedAt=a.attemptedAt,attemptedSource=a.source,
            id=v.id,quantity=v.quantity,maxQuantity=v.maxQuantity,
            rechargingCycleDurationMS=v.rechargingCycleDurationMS,rechargingAmountPerCycle=v.rechargingAmountPerCycle}
    end
    local function activeIdentity(g,r)
        local id=g and g.identity
        local cap=id and D.Capabilities(id)
        return cap and not r.archived and not g.archived and g.generation==r.generation and
            id.skillLineID==r.id and id.profession==r.professionFamily and cap
    end
    local function rowProvenance(r,p)
        local s,v=r.concentrationState,r.concentrationValue
        return p and s and v and s.status=="observed" and s.lastStatus=="observed" and
            s.observedAt==p.observedAt and s.attemptedAt==p.attemptedAt and s.source==p.attemptedSource and
            v.id==p.id and v.quantity==p.quantity and v.maxQuantity==p.maxQuantity and
            v.rechargingCycleDurationMS==p.rechargingCycleDurationMS and v.rechargingAmountPerCycle==p.rechargingAmountPerCycle
    end
    local function continuityBase(q)
        local function owned()
            return q and continuity==q and q.version==buildVersion and q.cache==lastPaint and
                q.completed==self.completed and q.rows==self.rows and q.frame==self.frame and
                q.optionsRef==self.options and sameOptions(q.options,self.options) and
                q.context.db==collector.db and q.context.fresh==collector.fresh and
                q.context.serial==collector.serial and q.context.revision==collector.revision and
                (not q.job or self.buildJob==q.job) and
                preparationCurrent(q.preparing)
        end
        return owned() and q.context.storeRevision==S.Revision(collector.db) and owned()
    end
    local function continuityCurrent(q)
        if not continuityBase(q) then return false end
        if not matches(q.context) or not continuityBase(q) then return false end
        if q.signal and (handoff(q.context)~=q.signal or not continuityBase(q)) then return false end
        local shown=q.frame:IsShown()
        if not continuityBase(q) or not shown then return false end
        local blocked=combat()
        if not continuityBase(q) or blocked then return false end
        for _,entry in ipairs(q.entries) do
            local r=entry.row
            if entry.widget.row~=r or r.guid~=entry.guid or r.id~=entry.id or r.generation~=entry.generation or
                r.professionFamily~=entry.family or r.archived or
                ((entry.estimate or entry.cell) and entry.paint.provenance and
                    not rowProvenance(r,entry.paint.provenance)) then return false end
            local token=S.Token(q.context.db,entry.guid,entry.id)
            if not continuityBase(q) or not token or token~=entry.token then return false end
        end
        return continuityBase(q)
    end
    local function preserved(q,w,r)
        if not q or not continuityCurrent(q) then return end
        local entry=q.byWidget[w]
        if entry and entry.row==r and w.row==r then return entry end
    end
    local function prepareContinuity(ctx,version,owner,previous,requiredSignal)
        local cache=lastPaint
        if not cache or cache.completed~=self.completed or cache.rows~=self.rows or
            cache.db~=ctx.db or not ctx.options.currentPlayerGUID or ctx.options.archived or
            not sameOptions(cache.options,ctx.options) then return end
        local signal=handoff(ctx)
        if not preparationCurrent(owner) then return end
        if requiredSignal and signal~=requiredSignal then lastPaint=nil; return end
        local q={version=version,cache=cache,completed=self.completed,rows=self.rows,frame=self.frame,
            context=ctx,options=ctx.options,optionsRef=self.options,offset=self.offset,entries={},byWidget={},
            preparing=owner,signal=signal}
        continuity=q
        local ok=pcall(function()
            assert(continuityCurrent(q),"Unsafe pending paint")
            for _,entry in ipairs(cache.entries) do
                assert(continuityCurrent(q),"Superseded pending paint")
                local token=S.Token(ctx.db,entry.guid,entry.id)
                assert(token and continuityCurrent(q),"Unowned row")
                local g,why=S.Active(ctx.db,entry.guid,entry.id)
                assert(continuityCurrent(q) and S.Token(ctx.db,entry.guid,entry.id)==token and
                    continuityCurrent(q),"Changed row during read")
                assert(not (type(why)=="string" and why:find("Storage rejected:",1,true)),"Invalid active row")
                local cap=activeIdentity(g,entry.row)
                if cap and entry.widget.row==entry.row and entry.row.guid==entry.guid and entry.row.id==entry.id and
                    entry.row.generation==entry.generation and entry.row.professionFamily==entry.family then
                    local p=provenance(g)
                    local e={row=entry.row,widget=entry.widget,token=token,guid=entry.guid,id=entry.id,
                        generation=entry.generation,family=entry.family,
                        dot=entry.dot and entry.row.guid==ctx.options.currentPlayerGUID,
                        estimate=entry.estimate and cap.concentration and p and entry.provenance and
                            sameOptions(p,entry.provenance),paint=entry}
                    local prior=previous and previous.cache==cache and previous.byWidget[entry.widget]
                    if cap.concentration and p and prior and prior.cell and
                        sameOptions(p,prior.cell.provenance) then
                        e.cell=prior.cell; e.estimate=prior.estimate
                    elseif cap.concentration and p and p.generation==entry.generation and signal and signal.kind=="observed" and
                        signal.guid==entry.guid and signal.id==entry.id and signal.generation==entry.generation and
                        (not entry.provenance or not sameOptions(p,entry.provenance)) then
                        -- Private scalar display only. Never alter cached rows or observations.
                        e.cell={provenance=p,value={id=p.id,quantity=p.quantity,maxQuantity=p.maxQuantity,
                            rechargingCycleDurationMS=p.rechargingCycleDurationMS,
                            rechargingAmountPerCycle=p.rechargingAmountPerCycle}}
                    end
                    q.entries[#q.entries+1]=e; q.byWidget[entry.widget]=e
                end
            end
            assert(continuityCurrent(q),"Changed pending paint")
            if signal then assert(handoff(ctx)==signal and continuityCurrent(q),"Changed handoff") end
        end)
        if not ok then
            if continuity==q then continuity=nil; lastPaint=nil end
            return
        end
        return q
    end
    local function validateContinuity()
        local q=continuity
        if not q then return end
        local render,hover,scroll=renderVersion,hoverVersion,scrollRequest
        local ok,valid=pcall(continuityCurrent,q)
        if (not ok or not valid) and continuity==q and q.version==buildVersion and
            render==renderVersion and hover==hoverVersion and scroll==scrollRequest then
            -- Only explicit ordinary collection drift may replace a pending job.
            -- One attempt per callback; a changed-again/reentrant signal fails closed.
            if not handoffBusy then
                local checked,signal=pcall(function()
                    if not matches(q.context) then return handoff(context()) end
                end)
                if checked and signal and continuity==q and q.version==buildVersion and
                    render==renderVersion and hover==hoverVersion and scroll==scrollRequest then
                    handoffBusy=true
                    local worked=pcall(ownedCall,"StartBuild",nil,signal)
                    handoffBusy=nil
                    if worked and continuity~=q then return end
                end
            end
            if continuity~=q or q.version~=buildVersion or render~=renderVersion or
                hover~=hoverVersion or scroll~=scrollRequest then return end
            self:Retain("refresh continuity invalidated; showing last observed values")
        end
    end
    function self:ClearScope()
        self.selected=nil; self.confirmation=nil
        if self.confirmPanel then self.confirmPanel:Hide() end
    end
    function self:DropCompleted()
        continuity=nil; lastPaint=nil
        pendingScroll=nil
        local version=buildVersion
        self.completed=nil; self.restoreKey=nil; self.rows={}; self.retained=false
        pcall(self.ClearScope,self)
        if version~=buildVersion then return end
        -- Detached values must disappear even if a later formatting call fails.
        for _,w in ipairs(self.widgets) do
            w.row=nil; pcall(w.Hide,w); if version~=buildVersion then return end
        end
    end
    local function demoteVisible(owner)
        local version,completed,rows,render=buildVersion,self.completed,self.rows,renderVersion
        local function owns()
            return preparationCurrent(owner) and version==buildVersion and render==renderVersion and completed==self.completed and rows==self.rows and
                (not completed or validSource(completed.context.db)) and version==buildVersion and
                render==renderVersion and completed==self.completed and rows==self.rows and preparationCurrent(owner)
        end
        -- Presentation only: inspect at most12*14 current labels, not the row list.
        -- Every call is isolated so an early broken label cannot strand later !s.
        for _,w in ipairs(self.widgets) do
            for col,cell in ipairs(w.cells) do
                if not owns() then return end
                local label=cell.label
                local ok,value=pcall(label.GetText,label)
                if not owns() then return end
                -- Native FontString returns nil for empty text.
                if ok and value==nil then value="" end
                if ok and type(value)=="string" then
                    local safe,n=value:gsub("|cffffbb00!|r","|cff999999!|r")
                    if n>0 then ok=pcall(label.SetText,label,safe) end
                else ok=false end
                if not owns() then return end
                if col==I.Moxie and w.row then
                    local colored=pcall(label.SetTextColor,label,moxieRGB(w.row,true))
                    if not owns() then return end
                    ok=ok and colored
                end
                local q=continuity
                local checked,kept=pcall(preserved,q,w,w.row)
                if not owns() then return end
                if not checked then
                    if continuity==q then continuity=nil; lastPaint=nil end
                    kept=nil
                end
                if cell.estimate and not (kept and (kept.estimate or kept.cell)) then
                    local hidden=pcall(cell.estimate.Hide,cell.estimate)
                    if not owns() then return end
                    if hidden then
                        local checked,shown=pcall(cell.estimate.IsShown,cell.estimate)
                        if not owns() then return end
                        hidden=checked and shown==false
                    end
                    if not hidden then
                        pcall(w.Hide,w)
                        if not owns() then return end
                    end
                    -- Retained labels must not keep an approximate total, even
                    -- when the following Render fails before reaching this row.
                    local value=(w.row and w.row.cells[I.Concentration] or "?"):gsub("|cffffbb00!|r","|cff999999!|r")
                    local reset=pcall(label.SetText,label,value)
                    if not owns() then return end
                    ok=ok and reset
                end
                if cell.currentDot and not (kept and kept.dot) then
                    local hidden=pcall(cell.currentDot.Hide,cell.currentDot)
                    if not owns() then return end
                    if hidden then
                        local checked,shown=pcall(cell.currentDot.IsShown,cell.currentDot)
                        if not owns() then return end
                        hidden=checked and shown==false
                    end
                    if not hidden then
                        pcall(w.Hide,w)
                        if not owns() then return end
                    end
                end
                if not ok then
                    continuity=nil; lastPaint=nil
                    local hidden=pcall(label.Hide,label)
                    if not owns() then return end
                    if hidden then
                        local checked,shown=pcall(label.IsShown,label)
                        if not owns() then return end
                        hidden=checked and shown==false
                    end
                    if not hidden then
                        pcall(w.Hide,w)
                        if not owns() then return end
                    end
                end
            end
        end
    end
    function self:Retain(why)
        local ticket=consumeDispatch("Retain")
        local owner,permit=ticket and ticket.owner,ticket and ticket.permit
        if not preparationCurrent(owner) then return false end
        if not permit or permit~=continuity then continuity=nil; lastPaint=nil end
        pendingScroll=nil
        renderVersion=renderVersion+1; estimateTick={elapsed=0}
        if owner then owner.render=renderVersion end -- Exact intentional mutation, before any callback.
        local version,hover,render,completed,rows=buildVersion,hoverVersion,renderVersion,self.completed,self.rows
        local function owns()
            return preparationCurrent(owner) and version==buildVersion and render==renderVersion and completed==self.completed and rows==self.rows
        end
        if self.completed and not validSource(self.completed.context.db) then self:DropCompleted() end
        if not owns() then return end
        if self.selected then self.restoreKey=self.selected.key end
        self.retained=self.completed~=nil
        self.presentation=why
        if self.retained then demoteVisible(owner) end
        if not owns() then return end
        if self.completed and not validSource(self.completed.context.db) then self:DropCompleted() end
        if not owns() then return end
        pcall(self.ClearScope,self)
        if not owns() then return end
        if hover==hoverVersion and env.GameTooltip then pcall(env.GameTooltip.Hide,env.GameTooltip) end
    end
    -- Failure cleanup must not call the public wrapper that just threw (nor a
    -- different throwing wrapper). Capture the production path privately.
    local productionRetain=self.Retain
    cleanupFailedPreparation=function(owner)
        if not preparationCurrent(owner) then
            -- Retire only this failed invocation's still-armed private record.
            -- A newer completed paint has a different cache; never demote it or
            -- alter the newer hover/scroll/job/status because the old call threw.
            local q=continuity
            if q and q.preparing==owner then
                if lastPaint==q.cache then lastPaint=nil end
                continuity=nil
            end
            return
        end
        continuity=nil; lastPaint=nil -- Revoke before any cleanup callback.
        if self.buildJob then
            -- A pre-entry StopBuild failure can leave its previous async job
            -- alive. Retire that owned work privately before historical demotion.
            local previous=dispatch.StopBuild
            local ticket={owner=owner}
            dispatch.StopBuild=ticket
            pcall(productionStopBuild,self)
            if dispatch.StopBuild==ticket or dispatch.StopBuild==nil then
                dispatch.StopBuild=previous and not previous.consumed and previous or nil
            end
            if not preparationCurrent(owner) then return end
        end
        local previous=dispatch.Retain
        local ticket={owner=owner}
        dispatch.Retain=ticket
        local ok=pcall(productionRetain,self,"refresh failed during preparation; showing last observed values. Refresh to retry")
        if dispatch.Retain==ticket or dispatch.Retain==nil then
            dispatch.Retain=previous and not previous.consumed and previous or nil
        end
        return ok and preparationCurrent(owner)
    end
    function self:DisplayStatus()
        if self.retained then return historical..(self.presentation or "updating")..
            ". Requested filters, View and order may not yet match these rows." end
        return self.presentation or Dashboard.StatusText(collector.reason,collector.blockReason)
    end
    function self:ActionsReady()
        if self.completed and not validSource(self.completed.context.db) then self:Refresh(); return false end
        if self.retained or self.publishing or collector.db==nil then return false end
        if self.completed and not matches(self.completed.context) then self:Refresh(); return false end
        if S.IsHandle(collector.db) and not self.completed then return false end
        return true
    end
    local function beginHover(widget,rowWidget,bar)
        hoverVersion=hoverVersion+1
        -- Capture BEFORE ActionsReady, Shift or any widget/native lookup can reenter.
        return {invocation=hoverVersion,version=buildVersion,completed=self.completed,rows=self.rows,
            db=collector.db,widget=widget,host=rowWidget,row=rowWidget.row,bar=bar,tree=bar and bar.tree}
    end
    local function hoverCurrent(h)
        return h.invocation==hoverVersion and h.version==buildVersion and h.completed==self.completed and
            h.rows==self.rows and h.db==collector.db and h.host.row==h.row and (not h.bar or h.bar.tree==h.tree)
    end
    local function hoverReady(h)
        if not hoverCurrent(h) then return false end
        local ready=self:ActionsReady()
        return ready and hoverCurrent(h)
    end
    local function historicalTooltip(widget,invocation)
        local tip=env.GameTooltip
        if not tip then return end
        local version,completed,db=buildVersion,self.completed,collector.db
        local function good()
            return invocation==hoverVersion and version==buildVersion and completed==self.completed and db==collector.db and
                (self.retained or self.publishing) and (not completed or validSource(completed.context.db)) and
                invocation==hoverVersion and version==buildVersion
        end
        for _,entry in ipairs({{"ClearLines"},{"SetOwner",widget,"ANCHOR_RIGHT"},
            {"AddLine",retainedHint,1,1,1,true},{"Show"}}) do
            if not good() then return end
            tip[entry[1]](tip,unpack(entry,2))
            if not good() then return end
        end
    end
    local function abortHover(widget,h)
        if h.invocation~=hoverVersion then return end -- Never clean up a newer hover.
        if self.retained or self.publishing then historicalTooltip(widget,h.invocation)
        elseif env.GameTooltip then env.GameTooltip:Hide() end
    end
    local function retainedTooltip(widget,h)
        if not hoverCurrent(h) then abortHover(widget,h); return true end
        self:ActionsReady() -- Detect drift even before the next scheduler callback.
        if not hoverCurrent(h) then abortHover(widget,h); return true end
        if self.retained or self.publishing then historicalTooltip(widget,h.invocation); return true end
        return self.completed==nil and S.IsHandle(collector.db)
    end
    local function text(parent,size)
        local f=parent:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
        if size then f:SetWidth(size) end
        f:SetJustifyH("LEFT"); f:SetWordWrap(false)
        return f
    end
    local function tooltip(widget,lines,link,origin)
        local tip=env.GameTooltip
        if not tip then return end
        if not origin then hoverVersion=hoverVersion+1 end
        local invocation=origin and origin.invocation or hoverVersion
        local function good()
            return invocation==hoverVersion and (not origin or hoverReady(origin))
        end
        local function call(method,...)
            if not good() then return false end
            local ok=pcall(tip[method],tip,...)
            -- A native/third-party tooltip failure is not permission to skip
            -- provenance cleanup, nor to hide a replacement or a newer hover.
            return ok and good()
        end
        local function show()
            if not call("ClearLines") or not call("SetOwner",widget,"ANCHOR_RIGHT") then return false end
            if link and not call("SetHyperlink",link) then return false end
            for _,line in ipairs(lines or {}) do
                if not call("AddLine",Dashboard.PlainTooltip(line),1,1,1,true) then return false end
            end
            return call("Show")
        end
        if not show() then
            if origin then abortHover(widget,origin)
            elseif invocation==hoverVersion then tip:Hide() end
        end
    end
    local function diagnostics()
        if type(env.IsShiftKeyDown)~="function" then return false end
        local ok,down=pcall(env.IsShiftKeyDown)
        return ok and down==true
    end
    local function focusedTooltip(widget,summary,detail,link,down,noHint,origin)
        if origin and not hoverReady(origin) then abortHover(widget,origin); return end
        if down==nil then down=diagnostics() end
        if origin and not hoverReady(origin) then abortHover(widget,origin); return end
        if down then tooltip(widget,detail,link,origin); return end
        local lines={}
        for _,line in ipairs(summary or {}) do lines[#lines+1]=line end
        tooltip(widget,lines,link,origin)
    end
    local function button(parent,label,width,fn)
        local b=env.CreateFrame("Button",nil,parent,"UIPanelButtonTemplate")
        b:SetSize(width,22); b:SetText(label); b:SetScript("OnClick",fn); return b
    end
    local function raise(frame)
        if frame and type(frame.Raise)=="function" then pcall(frame.Raise,frame) end
    end
    -- Only View/Attention share this plumbing; Profession's public behavior stays
    -- unchanged. Invalidate callbacks before exposing a noninteractive fallback.
    local function menu(parent,alias,title,key,choices,default,x,width,clearSelection)
        local state={available=false}
        local placeholder=env.CreateFrame("Frame",nil,parent)
        placeholder:SetSize(width,25); placeholder:SetPoint("TOPLEFT",x,-55); placeholder:EnableMouse(true)
        local label=text(placeholder,width-4); label:SetPoint("LEFT",2,0)
        label:SetText(title..": "..choices[1].label.." (unavailable)")
        placeholder:SetScript("OnEnter",function(w) tooltip(w,{state.reason or (title.." dropdown unavailable.")}) end)
        placeholder:SetScript("OnLeave",function() if env.GameTooltip then env.GameTooltip:Hide() end end)
        local dropdown
        local function unavailable(reason)
            state.available=false; state.reason=title.." dropdown unavailable: "..reason.."; showing "..choices[1].label.."."
            self.options[key]=default; self.offset=0
            if clearSelection then self.selected=nil end
            if dropdown then dropdown:Hide() end
            self[alias]=placeholder; placeholder:Show()
            if self.selectionArea then self:Refresh() end
        end
        self[alias.."Menu"]=state
        local ok,result=pcall(env.CreateFrame,"DropdownButton",nil,parent,"WowStyle1DropdownTemplate")
        if ok then dropdown=result end
        if not dropdown then unavailable("native creation failed"); return end
        state.dropdown=dropdown
        if type(dropdown.SetupMenu)~="function" or type(dropdown.SetDefaultText)~="function" then
            unavailable("SetupMenu/SetDefaultText missing"); return
        end
        dropdown:SetSize(width,25); dropdown:SetPoint("TOPLEFT",x,-55)
        state.available=true; self[alias]=dropdown
        local function selected(value) return state.available and (self.options[key]==value or (self.options[key]==nil and value==default)) end
        local function select(value)
            if not state.available then return end
            local choice
            for _,entry in ipairs(choices) do if entry.value==value then choice=entry end end
            if not choice then return end
            local updated=pcall(dropdown.SetDefaultText,dropdown,title..": "..choice.label)
            if not updated then unavailable("SetDefaultText failed"); return end
            self.options[key]=value; self.offset=0
            if clearSelection then self.selected=nil end
            self:Refresh()
        end
        local setup=pcall(function()
            dropdown:SetDefaultText(title..": "..choices[1].label)
            dropdown:SetupMenu(function(_,root)
                if not state.available then return end
                if not root or type(root.CreateRadio)~="function" then unavailable("root CreateRadio missing"); return end
                for _,choice in ipairs(choices) do
                    if not pcall(root.CreateRadio,root,choice.label,selected,select,choice.value) then
                        unavailable("CreateRadio failed"); return
                    end
                end
            end)
        end)
        if not setup then unavailable("SetupMenu/SetDefaultText failed"); return end
        if state.available then placeholder:Hide() end
    end
    function self:ProfessionControl(parent,x,width)
        local placeholder=env.CreateFrame("Frame",nil,parent)
        placeholder:SetSize(width,25); placeholder:SetPoint("TOPLEFT",x,-55); placeholder:EnableMouse(true)
        local label=text(placeholder,width-4); label:SetPoint("LEFT",2,0); label:SetText("All professions (unavailable)")
        placeholder:SetScript("OnEnter",function(w) tooltip(w,{self.professionUnavailableReason or "Profession dropdown unavailable; showing All professions."}) end)
        placeholder:SetScript("OnLeave",function() if env.GameTooltip then env.GameTooltip:Hide() end end)
        self.professionFallback=placeholder
        local function unavailable(reason)
            self.professionAvailable=false; self.professionUnavailableReason="Profession dropdown unavailable: "..reason.."; showing All professions."
            self.options.professionFamily=nil; self.options.profession=nil; self.offset=0
            if self.professionDropdown then self.professionDropdown:Hide() end
            self.professionControl=placeholder; placeholder:Show()
            if self.selectionArea then self:Refresh() end
        end
        local ok,dropdown=pcall(env.CreateFrame,"DropdownButton",nil,parent,"WowStyle1DropdownTemplate")
        self.professionDropdown=ok and dropdown or nil
        if not ok or not dropdown then unavailable("native creation failed"); return end
        if type(dropdown.SetupMenu)~="function" or type(dropdown.SetDefaultText)~="function" then unavailable("SetupMenu/SetDefaultText missing"); return end
        dropdown:SetSize(width,25); dropdown:SetPoint("TOPLEFT",x,-55)
        local choices={{label="All professions"}}
        local families={}
        for id,labelText in pairs(D.families) do families[#families+1]={family=id,label=labelText} end
        table.sort(families,function(a,b) if a.label~=b.label then return a.label<b.label end return a.family<b.family end)
        for _,choice in ipairs(families) do choices[#choices+1]=choice end
        self.professionChoices=choices; self.professionAvailable=true; self.professionControl=dropdown
        local function selected(data) return self.options.professionFamily==data end
        local function select(data)
            if not self.professionAvailable or (data~=nil and not D.families[data]) then return end
            self.options.professionFamily=data; self.options.profession=nil; self.offset=0; self:Refresh()
        end
        local setup,why=pcall(function()
            dropdown:SetDefaultText("All professions")
            dropdown:SetupMenu(function(_,root)
                if not self.professionAvailable then return end
                if not root or type(root.CreateRadio)~="function" then unavailable("root CreateRadio missing"); return end
                for _,choice in ipairs(choices) do
                    local made=pcall(root.CreateRadio,root,choice.label,selected,select,choice.family)
                    if not made then unavailable("CreateRadio failed"); return end
                end
            end)
        end)
        if not setup then unavailable("SetupMenu failed: "..tostring(why)); return end
        if self.professionAvailable then placeholder:Hide() end
    end
    function self:Layout(draw)
        draw=draw or function(w,method,...) return w[method](w,...) end
        local count=#(self.rows or {})
        self.visibleRows=math.min(G.pageRows,math.max(1,count))
        local viewportHeight=G.rowHeight*self.visibleRows
        local height=G.baseHeight+viewportHeight
        draw(self.frame,"SetSize",G.outerWidth,height)
        draw(self.viewport,"SetSize",G.contentWidth,viewportHeight)
        if self.scrollbar then draw(self.scrollbar,"SetSize",12,viewportHeight) end
        draw(self.selectionArea,"ClearAllPoints")
        draw(self.selectionArea,"SetPoint","TOPLEFT",G.margin,-(G.viewportTop+viewportHeight+4))
        local scale=1
        for _,dimension in ipairs({{method="GetWidth",size=G.outerWidth},{method="GetHeight",size=height}}) do
            local parent=env.UIParent
            if parent and type(parent[dimension.method])=="function" then
                local ok,size=pcall(parent[dimension.method],parent)
                -- A missing/invalid dimension or nonpositive space after the
                -- requested margin supplies no usable fit constraint; keep a safe
                -- positive default (or the other valid dimension's constraint).
                if ok and C.Finite(size) and size>G.screenMargin then
                    scale=math.min(scale,(size-G.screenMargin)/dimension.size)
                end
            end
        end
        if not C.Finite(scale) or scale<=0 then scale=1 end
        draw(self.frame,"SetScale",scale)
    end
    function self:Confirm(scope,action,label)
        if not self:ActionsReady() then return end
        local version=buildVersion
        if combat() then self.collector.reason="Leave combat before changing snapshot lifecycle."; return end
        if version~=buildVersion or not self:ActionsReady() then return end
        self.confirmation={scope=C.Copy(scope),action=action,label=label}
        self.confirmText:SetText(clean("Confirm "..action..": "..label.."?"))
        if version~=buildVersion or not self:ActionsReady() then return end
        self.confirmPanel:Show()
        if version==buildVersion and not self:ActionsReady() then self:ClearScope() end
    end
    function self:FinishConfirmation(confirmed)
        if not self:ActionsReady() then self:ClearScope(); return false end
        local version=buildVersion
        local p=self.confirmation
        self.confirmation=nil; self.confirmPanel:Hide()
        if not p or confirmed~=true or combat() or not self.collector.db then return false end
        if version~=buildVersion or not self:ActionsReady() then return false end
        if not S.Check(self.collector.db) then self:Refresh(); return false end
        local ok=false
        if p.action=="retire" then
            local g=S.Active(self.collector.db,p.scope.guid,p.scope.id)
            if g and g.generation==p.scope.generation then
                local at=self.collector:Now()
                if version~=buildVersion or not self:ActionsReady() then return false end
                ok=S.Archive(self.collector.db,p.scope.guid,p.scope.id,at,"manual retirement")
            end
        else ok=S.Delete(self.collector.db,p.scope,true) end
        if ok then self:DropCompleted(); self.collector:Invalidate("Snapshot lifecycle changed; fresh own-profession scan required.") end
        self.selected=nil; self:Refresh(); return ok
    end
    function self:Lifecycle(action,character)
        if not self:ActionsReady() then return end
        local r=self.selected
        if not r or not self.collector.db then return end
        local scope={guid=r.guid,id=r.id,generation=r.generation,character=character==true}
        local label=r.name.."-"..r.realm
        if character then label=label.." — ALL professions and archived generations"
        else label=label.." / "..r.profession.." / generation "..r.generation end
        if action=="retire" and r.archived then return end
        self:Confirm(scope,action,label)
    end
    local function scrollOwner()
        return {version=buildVersion,render=renderVersion,rows=self.rows,completed=self.completed,
            db=collector.db,fresh=collector.fresh,serial=collector.serial,revision=collector.revision,
            storeRevision=S.Revision(collector.db),options=assert(C.Copy(self.options)),optionsRef=self.options,
            retained=self.retained,job=self.buildJob,publishing=self.publishing,frame=self.frame}
    end
    local function scrollCurrent(q)
        if q.version~=buildVersion or q.render~=renderVersion or q.rows~=self.rows or q.completed~=self.completed or
            q.db~=collector.db or q.fresh~=collector.fresh or q.serial~=collector.serial or q.revision~=collector.revision or
            q.storeRevision~=S.Revision(collector.db) or q.retained~=self.retained or q.job~=self.buildJob or
            q.publishing~=self.publishing or q.frame~=self.frame or q.optionsRef~=self.options then return false end
        for k,v in pairs(q.options) do if self.options[k]~=v then return false end end
        for k,v in pairs(self.options) do if q.options[k]~=v then return false end end
        return (not q.completed or (validSource(q.completed.context.db) and (self.retained or matches(q.completed.context)))) and
            q.version==buildVersion and q.render==renderVersion and q.rows==self.rows and q.completed==self.completed
    end
    local function scrollVisible(q)
        if not scrollCurrent(q) then return false end
        local shown=not q.frame or q.frame:IsShown()
        return scrollCurrent(q) and shown
    end
    local function boundedOffset(rows,value)
        return math.max(0,math.min(math.max(0,#(rows or {})-G.pageRows),math.floor(value+.5)))
    end
    function self:QueueScroll(value)
        if scrollFeedback or not C.Finite(value) then return end
        scrollRequest=scrollRequest+1; local request=scrollRequest
        local q=scrollOwner()
        local ok,ready=pcall(scrollVisible,q)
        if request~=scrollRequest or not ok or not ready or not scrollCurrent(q) then return end
        if #(q.rows or {})<=G.pageRows then return end
        q.target=boundedOffset(q.rows,value)
        pendingScroll=q.target~=self.offset and q or nil
    end
    function self:ScrollTo(value)
        if scrollFeedback then return end
        if not C.Finite(value) then return end
        scrollRequest=scrollRequest+1; local request=scrollRequest
        pendingScroll=nil -- Cancel drag even if the following native visibility query fails.
        local q=scrollOwner()
        local ok,ready=pcall(scrollVisible,q)
        if request~=scrollRequest or not ok or not ready or not scrollCurrent(q) then return end
        local target=boundedOffset(q.rows,value)
        if target==self.offset then return end
        self.offset=target
        if scrollCurrent(q) then self:Render() end
    end
    function self:Create()
        if self.frame then return true end
        if combat() then self.wantOpen=true; return false end
        local frame=env.CreateFrame("Frame",nil,env.UIParent,"BackdropTemplate")
        self.frame=frame; frame:SetSize(G.outerWidth,G.baseHeight+G.rowHeight); frame:SetPoint("CENTER")
        local creationVersion,creationRows,creationSource=buildVersion,self.rows,collector.db
        local function creating()
            assert(self.frame==frame and buildVersion==creationVersion and self.rows==creationRows and collector.db==creationSource,
                "Retired UI creation")
        end
        local function init(widget,method,...)
            creating(); local result=widget[method](widget,...); creating(); return result
        end
        local function initialText(parent,width)
            local label=init(parent,"CreateFontString",nil,"OVERLAY","GameFontHighlightSmall")
            if width then init(label,"SetWidth",width) end
            init(label,"SetJustifyH","LEFT"); init(label,"SetWordWrap",false)
            return label
        end
        frame:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
        frame:SetBackdropColor(.055,.065,.085,.98); frame:SetBackdropBorderColor(.18,.21,.26,1)
        frame:SetFrameStrata("HIGH"); frame:SetToplevel(true)
        frame:SetMovable(true); frame:EnableMouse(true); frame:RegisterForDrag("LeftButton")
        frame:SetScript("OnShow",function(f) raise(f); if S.IsHandle(collector.db) then self:Refresh() end end)
        frame:SetScript("OnHide",function()
            local version=self:StopBuild()
            if version==buildVersion then self:Retain("refresh cancelled while hidden; reopen or Refresh to retry"); self:Render() end
        end)
        init(frame,"SetScript","OnUpdate",function(_,elapsed)
            if updateBusy then return end
            updateBusy=true
            validateContinuity()
            local tick,version,render,rows,completed=estimateTick,buildVersion,renderVersion,self.rows,self.completed
            local function current()
                return tick==estimateTick and version==buildVersion and render==renderVersion and
                    rows==self.rows and completed==self.completed and not self.retained and not self.publishing and
                    not self.buildJob and (not completed or matches(completed.context)) and tick==estimateTick
            end
            local q=pendingScroll
            pcall(function()
                local function queued() return q and pendingScroll==q and scrollCurrent(q) end
                local shown=frame:IsShown()
                if pendingScroll~=q then return end
                if not shown then
                    if pendingScroll==q then pendingScroll=nil end
                    return
                end
                -- Scrolls are independent of estimate eligibility (notably retained
                -- views/pending builds); both paths share this callback's one paint.
                local scrolling=queued()
                if q and not scrolling and pendingScroll==q then pendingScroll=nil; q=nil end
                local due=false
                if not tick.busy and C.Finite(elapsed) and elapsed>=0 and current() then
                    local blocked=combat()
                    if pendingScroll~=q then return end
                    if current() and not blocked then
                        tick.elapsed=math.min(30,tick.elapsed+math.min(30,elapsed))
                        due=tick.elapsed>=30
                    end
                end
                if scrolling and queued() then
                    pendingScroll=nil
                    local target=boundedOffset(q.rows,q.target)
                    if target~=self.offset and scrollCurrent(q) then
                        if due then tick.elapsed=0 end
                        self.offset=target; self:Render()
                        return
                    end
                end
                if not due or not current() then return end
                tick.elapsed=0
                self:Render()
            end)
            if pendingScroll==q then pendingScroll=nil end -- Never clear a replacement queue.
            updateBusy=nil
        end)
        frame:SetScript("OnMouseDown",function(f) raise(f) end)
        frame:SetScript("OnDragStart",function(f) f:StartMoving() end)
        frame:SetScript("OnDragStop",function(f) f:StopMovingOrSizing() end)
        local icon
        local iconOK,loaded=pcall(function()
            icon=frame:CreateTexture(nil,"ARTWORK")
            icon:SetSize(22,22); icon:SetPoint("TOPLEFT",G.margin,-5)
            return icon:SetTexture("Interface\\AddOns\\CraftArmy\\Media\\Icons\\CraftArmy.tga")
        end)
        if iconOK and loaded==true then
            self.titleIcon=icon
        elseif icon then
            pcall(function() icon:Hide() end)
        end
        local titleInset=self.titleIcon and 28 or 0
        self.title=text(frame,G.contentWidth-30-titleInset); self.title:SetPoint("TOPLEFT",G.margin+titleInset,-8)
        self.title:SetText("CraftArmy — observed profession snapshots")
        self.close=button(frame,"X",22,function() frame:Hide() end)
        self.close:SetPoint("TOPRIGHT",-G.margin,-5)
        self.statusArea=env.CreateFrame("Frame",nil,frame); self.statusArea:SetSize(G.contentWidth,16)
        self.statusArea:SetPoint("TOPLEFT",G.margin,-31); self.statusArea:EnableMouse(true)
        self.reason=text(self.statusArea,G.contentWidth); self.reason:SetAllPoints()
        self.statusArea:SetScript("OnEnter",function(w)
            self:ActionsReady()
            local lines={self:DisplayStatus(),"Raw status: "..(collector.reason==nil and "" or tostring(collector.reason))}
            if collector.blockReason~=nil then lines[#lines+1]="Blocked: "..tostring(collector.blockReason) end
            lines[#lines+1]="Loaded dashboard build: "..loadedDashboardBuild
            focusedTooltip(w,{self:DisplayStatus()},lines)
        end)
        self.statusArea:SetScript("OnLeave",function() if env.GameTooltip then env.GameTooltip:Hide() end end)
        local refresh=button(frame,"Refresh",76,function() collector:Request("Manual refresh") end)
        refresh:SetPoint("TOPLEFT",G.margin,-G.toolbarTop)
        local categories={"All","Concentration","Moxie","Missing enchant","Progression"}
        local choices={}
        for _,category in ipairs(categories) do
            choices[#choices+1]={label=category=="Progression" and "Skill below max" or category,value=category}
        end
        menu(frame,"attention","Attention","attention",choices,"All",115,176,false)
        menu(frame,"archived","View","archived",{{label="Active",value=false},{label="Archived",value=true}},false,315,126,true)
        self.toolbar={refresh,self.attention,self.archived}; self.filters={}
        local toolbarWidth=450
        local filterWidth=(G.contentWidth-toolbarWidth-2*6)/2
        local function filter(label,x,key)
            local l=text(frame,76); l:SetPoint("TOPLEFT",x,-65); l:SetText(label)
            local e=env.CreateFrame("EditBox",nil,frame,"InputBoxTemplate")
            e:SetAutoFocus(false); e:SetSize(filterWidth-76,20); e:SetPoint("TOPLEFT",x+76,-61)
            e:SetScript("OnEscapePressed",function(edit) edit:ClearFocus() end)
            e:SetScript("OnTextChanged",function(edit)
                self.options[key]=edit:GetText(); self.offset=0; self:Refresh()
            end)
            self.filters[key]=e
        end
        filter("Character",G.margin+toolbarWidth+6,"character")
        local professionX=G.margin+toolbarWidth+12+filterWidth
        local professionLabel=text(frame,76); professionLabel:SetPoint("TOPLEFT",professionX,-65); professionLabel:SetText("Profession")
        self:ProfessionControl(frame,professionX+76+8,filterWidth-76-16)
        local x=G.margin
        self.headers={}
        for i,label in ipairs(V.columns) do
            local hidden=i==I.Accessory2 or i==I.Tool or i==I.Stat or i==I.Enchant
            local static=hidden or i==I.Accessory1
            local header=env.CreateFrame(static and "Frame" or "Button",nil,frame)
            header.hiddenColumn=hidden
            local width=hidden and 0 or i==I.Accessory1 and 96 or widths[i]
            header:SetSize(width,G.headerHeight); header:SetPoint("TOPLEFT",x,-G.headerTop)
            local l=text(header,math.max(1,width-4)); l:SetPoint("LEFT",2,0); l:SetText(shortHeaders[i] or label)
            if roleColumns[i] then l:SetJustifyH("CENTER") end
            header.label=l; self.headers[i]=header
            header.direction=text(header,8); header.direction:SetPoint("RIGHT",-1,0)
            if not static then header:SetScript("OnClick",function()
                if self.options.sortColumn==i then self.options.sortDescending=not self.options.sortDescending
                else self.options.sortColumn=i; self.options.sortDescending=V.SortDescending(i) end
                self.offset=0; self:Refresh()
            end) end
            header:EnableMouse(not hidden)
            header:SetScript("OnEnter",function(w) tooltip(w,{shortHeaders[i] or label}) end)
            header:SetScript("OnLeave",function() if env.GameTooltip then env.GameTooltip:Hide() end end)
            if hidden then header:Hide(); l:Hide(); header.direction:Hide() end
            x=x+widths[i]
        end
        self.viewport=env.CreateFrame("Frame",nil,frame); self.viewport:SetSize(G.contentWidth,G.rowHeight)
        self.viewport:SetPoint("TOPLEFT",G.margin,-G.viewportTop); self.viewport:EnableMouseWheel(true)
        self.viewport:SetScript("OnMouseWheel",function(_,delta)
            if C.Finite(delta) then self:ScrollTo(self.offset-delta*3) end
        end)
        creating(); local slider=env.CreateFrame("Slider",nil,frame); creating()
        self.scrollbar=slider
        init(slider,"SetSize",12,G.rowHeight); init(slider,"SetPoint","TOPLEFT",self.viewport,"TOPRIGHT",4,0)
        init(slider,"SetOrientation","VERTICAL"); init(slider,"SetValueStep",1); init(slider,"SetObeyStepOnDrag",true)
        slider.track=init(slider,"CreateTexture",nil,"BACKGROUND")
        init(slider.track,"SetAllPoints"); init(slider.track,"SetColorTexture",.10,.12,.16,1)
        init(slider,"SetThumbTexture","Interface\\Buttons\\WHITE8X8"); self.scrollThumb=init(slider,"GetThumbTexture")
        init(self.scrollThumb,"SetColorTexture",.45,.50,.58,1)
        init(slider,"SetScript","OnValueChanged",function(_,value) self:QueueScroll(value) end)
        -- Reuse 12 row widgets regardless of record count; wheel + native drag.
        for i=1,G.pageRows do
            local w=env.CreateFrame("Button",nil,self.viewport)
            w:SetSize(G.contentWidth,G.rowHeight); w:SetPoint("TOPLEFT",0,-(i-1)*G.rowHeight)
            w.bg=w:CreateTexture(nil,"BACKGROUND"); w.bg:SetAllPoints()
            w.bg:SetColorTexture(1,1,1,i%2==0 and 0.045 or 0.015)
            w:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
            w.cells={}; local left=0
            for col=1,#widths do
                local cell=env.CreateFrame("Frame",nil,w)
                cell.hiddenColumn=col==I.Stat or col==I.Enchant
                cell:SetSize(widths[col],G.rowHeight); cell:SetPoint("LEFT",left,0); cell:EnableMouse(not cell.hiddenColumn)
                cell.fill=cell:CreateTexture(nil,"BACKGROUND"); cell.fill:SetAllPoints(); cell.fill:SetColorTexture(0,0,0,0)
                if col==I.Skill or col==I.Concentration then
                    local barWidth=col==I.Skill and 60 or 92
                    local b=env.CreateFrame("StatusBar",nil,cell); cell.bar=b
                    b:SetSize(barWidth,14); b:SetPoint("CENTER",0,0)
                    b:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8"); b:SetMinMaxValues(0,1)
                    b.background=b:CreateTexture(nil,"BACKGROUND"); b.background:SetAllPoints()
                    b.background:SetColorTexture(.15,.15,.15,1); b:EnableMouse(false)
                    if col==I.Concentration then
                        cell.estimate=init(b,"CreateTexture",nil,"ARTWORK")
                        init(cell.estimate,"SetColorTexture",.10,.90,1,1); init(cell.estimate,"Hide")
                    end
                    cell.label=text(b,barWidth); cell.label:SetAllPoints(); cell.label:SetJustifyH("CENTER")
                else
                    cell.label=text(cell,math.max(1,widths[col]-4)); cell.label:SetPoint("LEFT",2,0)
                end
                if roleColumns[col] then cell.label:SetJustifyH("CENTER")
                elseif col==I.Moxie then init(cell.label,"SetJustifyH","CENTER") end
                if col==I.Name then
                    cell.currentDot=initialText(cell)
                    init(cell.currentDot,"SetSize",8,14); init(cell.currentDot,"SetJustifyH","CENTER")
                    init(cell.currentDot,"SetFont",env.STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF",10,"")
                    init(cell.currentDot,"SetTextColor",.20,.78,.30); init(cell.currentDot,"Hide")
                end
                if cell.hiddenColumn then cell:Hide(); cell.label:Hide() end
                if roleColumns[col] then
                    local border=env.CreateFrame("Frame",nil,cell,"BackdropTemplate"); cell.itemBorder=border
                    border:SetSize(26,26); border:SetPoint("CENTER",col==I.Accessory1 and 3 or col==I.Tool and -3 or 0,0); border:EnableMouse(false)
                    border:SetBackdrop({edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
                    cell.itemIcon=border:CreateTexture(nil,"ARTWORK"); cell.itemIcon:SetSize(24,24); cell.itemIcon:SetPoint("CENTER",0,0)
                    local quality=env.CreateFrame("Frame",nil,border); cell.qualityFrame=quality
                    quality:SetSize(10,10); quality:SetPoint("TOPLEFT",1,-1); quality:EnableMouse(false)
                    quality:SetFrameLevel(border:GetFrameLevel()+1)
                    cell.qualityIcon=quality:CreateTexture(nil,"OVERLAY"); cell.qualityIcon:SetSize(10,10); cell.qualityIcon:SetPoint("TOPLEFT",0,0)
                    cell.qualityDigit=text(quality,10); cell.qualityDigit:SetSize(10,10); cell.qualityDigit:SetPoint("TOPLEFT",0,0)
                    cell.qualityDigit:SetFont(env.STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF",10,"OUTLINE")
                    cell.statBacking=border:CreateTexture(nil,"ARTWORK"); cell.statBacking:SetSize(16,16); cell.statBacking:SetPoint("CENTER",0,-2)
                    cell.statBacking:SetColorTexture(0,0,0,.65)
                    cell.statLetter=text(border); cell.statLetter:SetPoint("CENTER",0,-2)
                    cell.statLetter:SetJustifyH("CENTER")
                    cell.statLetter:SetFont(env.STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF",14,"OUTLINE")
                    local badge=env.CreateFrame("Frame",nil,border); cell.enchantBadge=badge
                    badge:SetSize(9,11); badge:SetPoint("TOPRIGHT",-1,-1); badge:EnableMouse(false)
                    badge.backing=badge:CreateTexture(nil,"BACKGROUND"); badge.backing:SetAllPoints(); badge.backing:SetColorTexture(0,0,0,.8)
                    badge.label=text(badge,9); badge.label:SetAllPoints(); badge.label:SetJustifyH("CENTER"); badge.label:SetText("E"); badge.label:SetTextColor(.2,1,.3)
                    border:Hide(); cell.itemIcon:Hide(); quality:Hide(); cell.qualityIcon:Hide(); cell.qualityDigit:Hide()
                    cell.statBacking:Hide(); cell.statLetter:Hide(); badge:Hide()
                end
                cell:SetScript("OnEnter",function(widget)
                    local origin=beginHover(widget,w)
                    if retainedTooltip(widget,origin) then return end
                    if not hoverReady(origin) then abortHover(widget,origin); return end
                    local r=origin.row; if not r then return end
                    local down=diagnostics()
                    if not hoverReady(origin) then abortHover(widget,origin); return end
                    if not down and not (r.notApplicableColumns and r.notApplicableColumns[col]) and
                        (col==I.Moxie or col==I.Unspent or col==I.LastUpdated or col==I.Stat or col==I.Enchant) then
                        if env.GameTooltip then
                            env.GameTooltip:ClearLines()
                            if hoverReady(origin) then env.GameTooltip:Hide() else abortHover(widget,origin) end
                        end
                        return
                    end
                    local role=roleColumns[col]
                    local gear=role and r.gear[role] or ((col==I.Stat or col==I.Enchant) and r.gear.tool)
                    local lines=gear and gear.tooltip or {r.cells[I.Name].."-"..r.cells[I.Realm],r.cells[I.Profession],unpack(r.tooltip)}
                    local summary=role and gear.summaryTooltip or r.cellTooltips[col]
                    if col==I.Concentration and down and not r.notApplicableColumns[col] then
                        -- Transient diagnostic presentation only. Shift does not
                        -- read the clock or estimate, nor append to cached rows.
                        local detail={}
                        for _,line in ipairs(lines) do detail[#detail+1]=line end
                        detail[#detail+1]="Approximate; assumes no spending and unchanged recharge rate. Not a live read."
                        lines=detail
                    end
                    if col==I.Concentration and not down and not r.notApplicableColumns[col] then
                        local ok,now=pcall(function() return collector:Now() end)
                        if not hoverReady(origin) then abortHover(widget,origin); return end
                        if not ok then now=nil end
                        local built,fresh=pcall(V.ConcentrationTooltip,origin.row,now)
                        if not hoverReady(origin) then abortHover(widget,origin); return end
                        if built and type(fresh)=="table" then summary=fresh end
                    end
                    focusedTooltip(widget,summary,lines,role and gear.link,down,nil,origin)
                end)
                cell:SetScript("OnLeave",function() if env.GameTooltip then env.GameTooltip:Hide() end end)
                -- Propagate selection without intercepting tooltip hover.
                cell:SetScript("OnMouseDown",function(_,mouse)
                    if not self:ActionsReady() then return end
                    local version=buildVersion
                    self.selected=w.row; self:Render()
                    if version~=buildVersion or not self:ActionsReady() then return end
                    if col==I.Profession and mouse=="LeftButton" and w.row then
                        if combat() then return end
                        if version~=buildVersion or not self:ActionsReady() then return end
                        if not self.details then self.details=NS.Details.NewView(env,collector) end
                        if version~=buildVersion or not self:ActionsReady() then return end
                        local r=w.row
                        if self.details:Open({guid=r.guid,id=r.id,generation=r.generation,archived=r.archived==true}) then
                            local detailsFrame=self.details.frame
                            if detailsFrame and type(detailsFrame.SetFrameStrata)=="function" then
                                pcall(detailsFrame.SetFrameStrata,detailsFrame,"DIALOG"); raise(detailsFrame)
                            end
                        end
                    end
                end)
                w.cells[col]=cell; left=left+widths[col]
            end
            w.bars={}
            for n=1,8 do
                local b=env.CreateFrame("StatusBar",nil,w.cells[I.Knowledge])
                b:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
                b:SetStatusBarColor(0.2,0.65,0.95); b:SetMinMaxValues(0,1); b:SetSize(widths[I.Knowledge]-6,14)
                b.background=b:CreateTexture(nil,"BACKGROUND"); b.background:SetAllPoints(); b.background:SetColorTexture(0.15,0.15,0.15,1)
                b.label=text(b,widths[I.Knowledge]-6); b.label:SetAllPoints(); b.label:SetJustifyH("CENTER")
                b:EnableMouse(true)
                b:SetScript("OnEnter",function(widget)
                    local origin=beginHover(widget,w,b)
                    if retainedTooltip(widget,origin) then return end
                    if not hoverReady(origin) then abortHover(widget,origin); return end
                    local tree=origin.tree
                    if tree then focusedTooltip(widget,tree.summaryTooltip,tree.tooltip,nil,nil,true,origin) end
                end)
                b:SetScript("OnLeave",function() if env.GameTooltip then env.GameTooltip:Hide() end end)
                w.bars[n]=b
            end
            self.widgets[i]=w
        end
        self.empty=text(self.viewport,G.contentWidth-8); self.empty:SetPoint("TOPLEFT",4,-4)
        self.empty:SetText("No snapshot. Log into each alt and open its own supported Midnight profession; /ca scan to refresh. No snapshot does not mean no profession.")
        self.selectionArea=env.CreateFrame("Frame",nil,frame); self.selectionArea:SetSize(G.contentWidth,14)
        self.selection=text(self.selectionArea,G.contentWidth); self.selection:SetAllPoints()
        self.selectionArea:EnableMouse(true)
        self.selectionArea:SetScript("OnEnter",function(w) tooltip(w,{self.selectionFull or ""}) end)
        self.selectionArea:SetScript("OnLeave",function() if env.GameTooltip then env.GameTooltip:Hide() end end)
        local retire=button(frame,"Retire selected",120,function() self:Lifecycle("retire") end); retire:SetPoint("BOTTOMLEFT",G.margin,32)
        local del=button(frame,"Delete generation",145,function() self:Lifecycle("delete") end); del:SetPoint("LEFT",retire,"RIGHT",6,0)
        local dc=button(frame,"Delete character",145,function() self:Lifecycle("delete",true) end); dc:SetPoint("LEFT",del,"RIGHT",6,0)
        self.footer={retire,del,dc}
        self.rowRange=initialText(frame,280)
        init(self.rowRange,"SetPoint","BOTTOMRIGHT",-(G.margin+16),32); init(self.rowRange,"SetJustifyH","RIGHT")
        self.confirmPanel=env.CreateFrame("Frame",nil,frame,"BackdropTemplate")
        self.confirmPanel:SetSize(G.contentWidth,22); self.confirmPanel:SetPoint("BOTTOM",0,6); self.confirmPanel:SetFrameLevel(frame:GetFrameLevel()+20)
        self.confirmPanel:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8"}); self.confirmPanel:SetBackdropColor(0.08,0.08,0.08,1)
        self.confirmText=text(self.confirmPanel,G.contentWidth-190); self.confirmText:SetPoint("LEFT",5,0)
        self.confirmPanel:EnableMouse(true)
        self.confirmPanel:SetScript("OnEnter",function(w) tooltip(w,{self.confirmation and self.confirmation.label or ""}) end)
        self.confirmPanel:SetScript("OnLeave",function() if env.GameTooltip then env.GameTooltip:Hide() end end)
        local yes=button(self.confirmPanel,"Confirm",80,function() self:FinishConfirmation(true) end); yes:SetPoint("RIGHT",-90,0)
        local no=button(self.confirmPanel,"Cancel",80,function() self:FinishConfirmation(false) end); no:SetPoint("LEFT",yes,"RIGHT",5,0)
        self.confirmButtons={yes,no}
        self:Layout()
        self.confirmPanel:Hide(); frame:Hide()
        return true
    end
    function self:Render()
        local ticket=consumeDispatch("Render")
        local owner=ticket and ticket.owner
        if not self.frame then return end
        if not preparationCurrent(owner) then return false end
        if continuity and continuity.preparing and continuity.preparing~=owner then continuity=nil; lastPaint=nil end
        if not continuity and (self.retained or self.buildJob) then lastPaint=nil end
        if continuity and continuity.offset~=self.offset then
            ownedCall("Retain",owner,nil,"scroll destination has no completed pending paint; showing last observed values")
        end
        if not preparationCurrent(owner) then return false end
        renderVersion=renderVersion+1; local render=renderVersion
        if owner then owner.render=renderVersion end -- Only this owned increment is adopted.
        local feedback={}
        local version,rows=buildVersion,self.rows
        local q=continuity
        local candidate
        local function guard()
            assert(preparationCurrent(owner),"Retired preparation paint")
            assert(renderVersion==render,"Retired paint")
            assert(buildVersion==version and self.rows==rows,"Retired render")
            assert(not self.completed or validSource(self.completed.context.db),"Detached render")
            assert(self.retained or not self.completed or matches(self.completed.context),"Superseded render")
            assert(buildVersion==version,"Retired render")
            if q then assert(continuityCurrent(q),"Invalid pending continuity") end
            -- Continuity validation itself crosses protected/native boundaries.
            -- Recheck the paint owner AFTER them, before touching a widget.
            assert(preparationCurrent(owner) and renderVersion==render and buildVersion==version and self.rows==rows,"Retired paint")
        end
        local function draw(w,method,...)
            guard(); local result=w[method](w,...); guard(); return result
        end
        local ok=pcall(function()
        guard()
        local clockOK,now=pcall(collector.Now,collector)
        guard()
        if q then
            assert(clockOK,"Pending paint clock unavailable")
            for _,entry in ipairs(q.entries) do
                local at=entry.cell and entry.cell.provenance.observedAt or entry.paint.provenance and entry.paint.provenance.observedAt
                if entry.cell and not entry.cell.ready then
                    local cell=entry.cell
                    cell.ratio,cell.red,cell.green,cell.blue=Dashboard.ConcentrationProgress(cell.value)
                    local v=cell.value
                    cell.label=C.Integer(v.quantity,0) and (tostring(v.quantity).."/"..
                        (C.Integer(v.maxQuantity,1) and tostring(v.maxQuantity) or "?")) or "?"
                    local estimate=V.ConcentrationEstimate(v,at,now)
                    guard()
                    if estimate and estimate.quantity>v.quantity and cell.ratio then
                        cell.gain=math.min(1-cell.ratio,(estimate.quantity-v.quantity)/v.maxQuantity)
                        if cell.gain>0 then cell.label="~"..estimate.quantity.."/"..estimate.maxQuantity end
                    end
                    entry.estimate=cell.gain and cell.gain>0 or false
                    cell.ready=true
                end
                if entry.estimate and (not C.Integer(now,0) or not C.Integer(at,0) or now<at) then
                    -- Reuse this Render's one clock, never recompute a retained
                    -- prediction. Reject only the estimate, not player identity.
                    -- Poison only its private paint flag until a normal paint wins.
                    entry.estimate=false; entry.paint.estimate=false
                    if entry.cell then
                        entry.cell.gain=nil; entry.cell.painted=nil
                        local v=entry.cell.value
                        entry.cell.label=tostring(v.quantity).."/"..tostring(v.maxQuantity)
                    end
                end
            end
            guard()
        end
        if not clockOK then now=nil end
        if not self.retained and not self.buildJob and self.completed and clockOK then
            local shown=draw(self.frame,"IsShown")
            local blocked=combat(); guard()
            if shown and not blocked then
                candidate={db=collector.db,completed=self.completed,rows=rows,options=assert(C.Copy(self.options)),entries={}}
            end
        end
        self:Layout(draw); guard()
        for column,header in ipairs(self.headers) do
            draw(header.direction,"SetText",self.options.sortColumn==column and (self.options.sortDescending and "v" or "^") or "")
        end
        self.offset=math.max(0,math.min(self.offset,math.max(0,#(self.rows or {})-G.pageRows)))
        scrollFeedback=feedback
        local count=#(self.rows or {})
        draw(self.scrollbar,"SetMinMaxValues",0,math.max(0,count-G.pageRows))
        draw(self.scrollbar,"SetValue",self.offset)
        local viewportHeight=G.rowHeight*self.visibleRows
        draw(self.scrollThumb,"SetSize",12,math.max(18,math.min(viewportHeight,viewportHeight*G.pageRows/math.max(G.pageRows,count))))
        draw(self.scrollbar,"SetEnabled",count>G.pageRows)
        draw(self.scrollbar,"SetShown",count>G.pageRows)
        if scrollFeedback==feedback then scrollFeedback=nil end
        draw(self.rowRange,"SetText",count==0 and "No matching rows" or
            ("Rows "..(self.offset+1).."–"..math.min(count,self.offset+G.pageRows).." of "..count))
        for i,w in ipairs(self.widgets) do
            local r=self.rows and self.rows[self.offset+i]; w.row=r
            if r then
                local kept=preserved(q,w,r)
                guard()
                local painted={widget=w,row=r,guid=r.guid,id=r.id,generation=r.generation,family=r.professionFamily}
                draw(w,"Show")
                for col,cell in ipairs(w.cells) do
                    local value=r.cells[col] or ""
                    local ratio,red,green,blue
                    if col==I.Skill then
                        ratio,red,green,blue=Dashboard.SkillProgress(r.skill)
                        if ratio==nil then value=(value:match("^(|c%x+!|r%s*)") or "").."?" end
                    elseif col==I.Concentration then
                        local replacement=kept and kept.cell
                        local observed=replacement and replacement.value or r.concentrationValue
                        ratio,red,green,blue=Dashboard.ConcentrationProgress(observed)
                        value=type(observed)=="table" and C.Integer(observed.quantity,0) and
                            (tostring(observed.quantity).."/"..(C.Integer(observed.maxQuantity,1) and tostring(observed.maxQuantity) or "?")) or "?"
                        if r.notApplicableColumns[col] then value="—" end
                        if replacement then
                            ratio,red,green,blue=replacement.ratio,replacement.red,replacement.green,replacement.blue
                            value=replacement.label
                            if not replacement.painted then
                                if kept.estimate then
                                    draw(cell.estimate,"ClearAllPoints")
                                    draw(cell.estimate,"SetPoint","LEFT",cell.bar,"LEFT",ratio*92,0)
                                    draw(cell.estimate,"SetSize",replacement.gain*92,14)
                                    draw(cell.estimate,"SetColorTexture",.10,.90,1,1)
                                    draw(cell.estimate,"SetShown",true)
                                else draw(cell.estimate,"SetShown",false) end
                            end
                        elseif kept and kept.estimate then
                            value=kept.paint.label
                        else
                            draw(cell.estimate,"SetShown",false)
                            draw(cell.estimate,"ClearAllPoints")
                            local estimate=not r.notApplicableColumns[col] and not self.retained and not self.buildJob and not r.archived and
                                V.ConcentrationEstimate(observed,r.concentrationState.observedAt,now)
                            if estimate and estimate.quantity>observed.quantity and ratio then
                                local gain=math.min(1-ratio,(estimate.quantity-observed.quantity)/observed.maxQuantity)
                                if gain>0 then
                                    draw(cell.estimate,"SetPoint","LEFT",cell.bar,"LEFT",ratio*92,0)
                                    draw(cell.estimate,"SetSize",gain*92,14)
                                    draw(cell.estimate,"SetColorTexture",.10,.90,1,1)
                                    draw(cell.estimate,"SetShown",true)
                                    value="~"..estimate.quantity.."/"..estimate.maxQuantity
                                    painted.estimate=true; painted.label=value
                                    painted.estimateLeft=ratio*92; painted.estimateWidth=gain*92; painted.estimateHeight=14
                                end
                            end
                        end
                    end
                    if col==I.Name then value=clean(value) end
                    if self.retained then value=value:gsub("|cffffbb00!|r","|cff999999!|r") end
                    if not (col==I.Concentration and kept and
                        (kept.cell and kept.cell.painted or not kept.cell and kept.estimate)) then draw(cell.label,"SetText",value) end
                    draw(cell.label,"SetShown",not cell.hiddenColumn) -- Restore only visible labels.
                    if col==I.Moxie then draw(cell.label,"SetTextColor",moxieRGB(r,self.retained))
                    else draw(cell.label,"SetTextColor",1,1,1) end
                    if col==I.Name then draw(cell.label,"SetTextColor",classRGB(env,r.classToken)) end
                    if col==I.Name and not (kept and kept.dot) then
                        local marked=not self.retained and r.isCurrentCharacter==true and r.guid==self.options.currentPlayerGUID
                        local marker=cell.currentDot
                        draw(marker,"SetShown",false); draw(marker,"SetText",marked and "•" or "")
                        draw(marker,"ClearAllPoints"); draw(cell.label,"SetWidth",marked and 96 or 106)
                        local width=96
                        if marked then
                            guard()
                            local measured,result=pcall(function() return cell.label:GetStringWidth() end)
                            guard()
                            if measured and C.Finite(result) then width=math.max(0,math.min(96,result)) end
                            guard()
                        end
                        draw(marker,"SetPoint","LEFT",cell.label,"LEFT",marked and width+2 or 2,0)
                        draw(marker,"SetShown",marked)
                        painted.dot=marked; painted.dotLeft=marked and width+2 or 2
                        painted.nameWidth=marked and 96 or 106
                        painted.dotWidth=8; painted.dotHeight=14
                    end
                    draw(cell.fill,"SetColorTexture",0,0,0,0)
                    local role=roleColumns[col]; local gear=role and r.gear[role]
                    if gear then
                        local exists=gear.exists==true
                        local icon=exists and C.Integer(gear.icon,1)
                        draw(cell.label,"SetText",gear.notApplicable and "—" or gear.empty and "" or icon and "" or "?")
                        draw(cell.itemBorder,"SetShown",exists)
                        local color=gear.borderColor or gear.rarityColor or {.45,.50,.58}
                        draw(cell.itemBorder,"SetBackdropBorderColor",color[1],color[2],color[3],1)
                        draw(cell.itemIcon,"SetTexture",icon and gear.icon or "")
                        draw(cell.itemIcon,"SetShown",icon==true)
                        local atlas=exists and gear.qualityAtlas
                        if atlas then draw(cell.qualityIcon,"SetAtlas",atlas) else draw(cell.qualityIcon,"SetTexture","") end
                        draw(cell.qualityIcon,"SetShown",atlas~=nil and atlas~=false)
                        local rank=exists and C.Integer(gear.rank,1) and gear.rank<=5
                        draw(cell.qualityDigit,"SetText",rank and tostring(gear.rank) or "")
                        draw(cell.qualityDigit,"SetShown",rank==true and not atlas)
                        draw(cell.qualityFrame,"SetShown",exists and (rank==true or (atlas~=nil and atlas~=false)))
                        local letter=role=="tool" and exists and gear.toolLetter or nil
                        draw(cell.statLetter,"SetFont",env.STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF",14,"OUTLINE")
                        draw(cell.statLetter,"SetText",letter or "")
                        draw(cell.statLetter,"SetTextColor",1,1,1)
                        draw(cell.statLetter,"SetShown",letter~=nil); draw(cell.statBacking,"SetShown",letter~=nil)
                        draw(cell.enchantBadge,"SetShown",exists and gear.enchanted==true)
                    end
                    if col==I.Skill or col==I.Concentration then
                        if not (col==I.Concentration and kept and kept.cell and kept.cell.painted) then
                            draw(cell.bar,"SetStatusBarColor",red,green,blue)
                            draw(cell.bar,"SetValue",ratio or 0)
                            draw(draw(cell.bar,"GetStatusBarTexture"),"SetShown",ratio~=nil)
                        end
                        if col==I.Concentration and kept and kept.cell then kept.cell.painted=true end
                    end
                end
                if candidate then candidate.entries[#candidate.entries+1]=painted end
                draw(w.bg,"SetColorTexture",1,1,1,self.selected and self.selected.key==r.key and 0.16 or (i%2==0 and 0.045 or 0.015))
                for n,b in ipairs(w.bars) do
                    local t=r.trees[n]; b.tree=t
                    if t then
                        draw(b,"SetStatusBarColor",D.TreeRGB(r.id,t.id))
                        local width=(widths[I.Knowledge]-4)/math.max(1,#r.trees)-2
                        draw(b,"ClearAllPoints"); draw(b,"SetPoint","LEFT",(n-1)*(width+2),0); draw(b,"SetWidth",width)
                        draw(b.label,"SetWidth",width)
                        draw(b,"SetValue",t.ratio or 0); draw(draw(b,"GetStatusBarTexture"),"SetShown",t.ratio~=nil)
                        draw(b.label,"SetText",t.purchased and (t.purchased.."/"..t.capacity) or "?"); draw(b,"Show")
                    else draw(b,"Hide") end
                end
            else
                draw(w,"Hide")
                local name=w.cells[I.Name]
                draw(name.currentDot,"SetShown",false); draw(name.currentDot,"SetText","")
                draw(name.currentDot,"ClearAllPoints"); draw(name.label,"SetWidth",106)
                draw(w.cells[I.Concentration].estimate,"SetShown",false)
                draw(w.cells[I.Concentration].estimate,"ClearAllPoints")
            end
        end
        draw(self.empty,"SetShown",not self.rows or #self.rows==0)
        self.selectionFull=self.retained and self:DisplayStatus() or (self.selected and ("Selected: "..self.selected.name.." / "..self.selected.profession.." / generation "..self.selected.generation) or "Click a row to select a lifecycle scope; all actions require confirmation.")
        draw(self.selection,"SetText",clean(self.selectionFull))
        for n=1,3 do local b=self.footer[n]
            if type(b.SetEnabled)=="function" then draw(b,"SetEnabled",not self.retained and not self.publishing) end
        end
        if candidate then
            -- Validate only visible projections; never traverse the account graph.
            for _,entry in ipairs(candidate.entries) do
                guard()
                local token=S.Token(candidate.db,entry.row.guid,entry.row.id); guard()
                local g=S.Active(candidate.db,entry.row.guid,entry.row.id); guard()
                local after=S.Token(candidate.db,entry.row.guid,entry.row.id); guard()
                assert(token and token==after,"Changed completed paint")
                local cap=activeIdentity(g,entry.row)
                if not cap then entry.dot=false; entry.estimate=false end
                local p=g and provenance(g)
                if p and cap and cap.concentration and rowProvenance(entry.row,p) then entry.provenance=p
                else entry.estimate=false end
            end
            guard()
        end
        end)
        if scrollFeedback==feedback then scrollFeedback=nil end
        if not ok and version==buildVersion and render==renderVersion and preparationCurrent(owner) then
            local detached=self.completed and not validSource(self.completed.context.db)
            if version~=buildVersion or render~=renderVersion or not preparationCurrent(owner) then return false end
            if detached then self:DropCompleted()
            else ownedCall("Retain",owner,nil,"refresh failed during rendering; Refresh to retry") end
            if version==buildVersion then pcall(self.reason.SetText,self.reason,clean(self:DisplayStatus())) end
            return false
        end
        if ok and version==buildVersion and render==renderVersion and preparationCurrent(owner) and not self.retained and not self.buildJob then
            lastPaint=candidate; continuity=nil
        end
        return ok
    end
    function self:Refresh()
        if not self.frame then return end
        normalizeSort()
        if S.IsHandle(self.collector.db) then return self:StartBuild() end
        if not capturePlayerGUID() then return end
        local version=self:StopBuild(); if buildVersion~=version then return end
        if self.completed then self:DropCompleted(); if buildVersion~=version then return end end
        self.retained=false; self.presentation=nil; self.restoreKey=nil; self.publishing=false
        local why
        self.rows,why=V.Build(self.collector.db,self.collector.fresh,self.options,self.collector:Now())
        if why then
            self.collector.blockReason=why; self.collector.reason=why
            self.collector.db=nil -- Disable writes, never reset or replace saved globals.
        end
        self.reason:SetText(clean(Dashboard.StatusText(self.collector.reason,self.collector.blockReason)))
        if self.collector.storagePending then self.empty:SetText("Saved storage unavailable/pending — saved snapshots are not empty or reset.") end
        if self.selected then
            local found
            for _,r in ipairs(self.rows) do if r.key==self.selected.key then found=r end end
            self.selected=found
        end
        self:Render()
        if self.details then self.details:Refresh() end
    end
    function self:StopBuild()
        local ticket=consumeDispatch("StopBuild")
        local owner,permit=ticket and ticket.owner,ticket and ticket.permit
        if not preparationCurrent(owner) then return buildVersion end
        local previous=continuity
        continuity=nil
        if permit~=keepPaint then lastPaint=nil end
        pendingScroll=nil
        estimateTick={elapsed=0}
        buildVersion=buildVersion+1; local version=buildVersion
        if owner then owner.version=version end -- Exact owned retirement, before cancellation callbacks.
        local job,driver=self.buildJob,self.buildDriver; self.buildJob=nil
        if previous and permit~=keepPaint then
            -- Explicit cancellation/publication retirement cannot strand an armed
            -- frozen paint. Revoke before any Cancel/native callback can reenter.
            pcall(ownedCall,"Retain",owner,nil,"refresh cancelled; showing last observed values")
        end
        if job then pcall(job.Cancel,job) end
        if buildVersion==version and preparationCurrent(owner) and driver then
            pcall(driver.SetScript,driver,"OnUpdate",nil)
            if buildVersion==version and preparationCurrent(owner) then pcall(driver.Hide,driver) end
        end
        return version
    end
    productionStopBuild=self.StopBuild
    function self:StartBuild()
        local ticket=consumeDispatch("StartBuild")
        local requiredSignal=ticket and ticket.permit
        normalizeSort()
        if not capturePlayerGUID() then return end
        local entryVersion,entryRender,entryHover,entryScroll=buildVersion,renderVersion,hoverVersion,scrollRequest
        local checked,coalesced=pcall(function()
            return self.buildJob and self.buildJob.status=="running" and matches(self.buildContext) and self.frame:IsShown()
        end)
        if entryVersion~=buildVersion or entryRender~=renderVersion or entryHover~=hoverVersion or entryScroll~=scrollRequest then return end
        if checked and coalesced then
            validateContinuity(); return
        end
        if not checked then lastPaint=nil end
        local previous=continuity
        local owner={version=buildVersion,render=renderVersion,hover=hoverVersion,scroll=scrollRequest}
        local version=ownedCall("StopBuild",owner,keepPaint)
        if buildVersion~=version or not preparationCurrent(owner) then return end
        self.publishing=false
        local ctx,job,batch
        local preparing=true
        local function owns()
            return buildVersion==version and (not preparing or preparationCurrent(owner))
        end
        local function sameContext()
            if not owns() then return false end
            local ok,valid=pcall(function() return ctx and matches(ctx) and self.frame:IsShown() end)
            return ok and valid and owns()
        end
        local function paint(why,permit)
            if not owns() then return end
            ownedCall("Retain",preparing and owner or nil,permit,why); if not owns() then return end
            self.rows=self.rows or {}
            pcall(self.empty.SetText,self.empty,why); if not owns() then return end
            pcall(self.reason.SetText,self.reason,clean(self:DisplayStatus())); if not owns() then return end
            ownedCall("Render",preparing and owner or nil)
        end
        local function fail(why)
            if not owns() then return end
            local retired=ownedCall("StopBuild",preparing and owner or nil)
            if buildVersion~=retired or self.buildJob~=nil then return end
            version=retired
            paint(why)
        end
        local prepared,q=pcall(function()
            ctx=context()
            if owns() and sameContext() then return prepareContinuity(ctx,version,owner,previous,requiredSignal) end
        end)
        if not owns() then
            if q and continuity==q then continuity=nil end
            return
        end
        if not prepared then q=nil end
        local shownOK,shown=pcall(self.frame.IsShown,self.frame)
        if not owns() then return end
        if not shownOK then fail("Dashboard visibility unavailable; showing last observed values. Refresh to retry."); return end
        paint(shown and "Building saved dashboard incrementally; updating; Refresh to retry if interrupted" or
            "refresh deferred while hidden; reopen or Refresh to retry",q)
        if not owns() then return end
        shownOK,shown=pcall(self.frame.IsShown,self.frame)
        if not owns() then return end
        if not shownOK then fail("Dashboard visibility unavailable; showing last observed values. Refresh to retry."); return end
        if not shown then ownedCall("Retain",owner,nil,"refresh deferred while hidden; reopen or Refresh to retry"); return end
        if not validSource(self.collector.db) then fail("Dashboard source unavailable/invalid; Refresh to retry."); return end
        local setup=pcall(function()
            if not ctx then ctx=context() end
            if not owns() or not sameContext() then return end
            job=V.NewBuildJob(ctx.db,ctx.fresh,ctx.options,self.collector:Now())
            if not owns() or not sameContext() then return end
            assert(type(job)=="table" and type(job.Step)=="function" and type(job.Cancel)=="function","Invalid build job")
            batch=S.NewFrameBatch(env)
            if not owns() or not sameContext() then return end
            assert(type(batch)=="table" and type(batch.Step)=="function","Invalid frame batch")
        end)
        if not owns() then if job and self.buildJob~=job then pcall(job.Cancel,job) end; return end
        if not setup then
            if job then pcall(job.Cancel,job) end
            fail("Dashboard build setup failed; saved data retained. Refresh to retry.")
            return
        end
        if not sameContext() then if job then pcall(job.Cancel,job) end; fail("Dashboard build superseded; refresh to retry."); return end
        -- Do not expose the job before scheduler/native setup returns under the
        -- exact preparation owner. A same-build callback can win here too.
        local function setupCurrent()
            return owns() and self.buildJob==nil and sameContext() and owns() and self.buildJob==nil
        end
        local function current() return owns() and self.buildJob==job and sameContext() and owns() and self.buildJob==job end
        local ok=pcall(function()
            assert(job.status=="running","Build setup rejected")
            if not self.buildDriver then
                local created=env.CreateFrame("Frame")
                if not setupCurrent() then return end
                self.buildDriver=created
            end
            local driver=self.buildDriver
            assert(driver and type(driver.SetScript)=="function" and type(driver.Show)=="function" and type(driver.Hide)=="function","Scheduler unavailable")
            driver:SetScript("OnUpdate",function()
                if not owns() or self.buildJob~=job then return end
                validateContinuity()
                if not owns() or self.buildJob~=job then return end
                local worked=pcall(function()
                    if not current() then fail("Dashboard build superseded; refresh to retry."); return end
                    if combat() then return end
                    local success,reason=batch:Step(job,function() return not combat() and current() end)
                    if not owns() or self.buildJob~=job then return end
                    if not success then fail("Dashboard frame batch failed: "..reason.."; saved data retained. Refresh to retry."); return end
                    if not current() then fail("Dashboard build superseded; refresh to retry."); return end
                    if combat() or not current() then return end
                    if job.status=="complete" and job.completed then
                        local rows=job.rows
                        local retired=self:StopBuild()
                        if buildVersion~=retired or self.buildJob~=nil or self.buildBatch~=batch then return end
                        version=retired
                        if not sameContext() or combat() then
                            if owns() then paint("refresh superseded or safety deferred; Refresh to retry") end
                            return
                        end
                        if not owns() then return end
                        self.publishing=true
                        self.rows=rows; self.completed={rows=rows,context=ctx}; self.retained=false; self.presentation=nil
                        self.offset=math.max(0,math.min(self.offset,math.max(0,#rows-G.pageRows)))
                        self.selected=nil
                        for n=self.offset+1,math.min(#rows,self.offset+G.pageRows) do
                            if rows[n].key==self.restoreKey then self.selected=rows[n] end
                        end
                        self.restoreKey=nil
                        self.empty:SetText("No snapshot matches the selected view and filters; saved data is unchanged.")
                        if not owns() then return end
                        if not sameContext() then self.publishing=false; paint("refresh superseded; Refresh to retry"); return end
                        self.reason:SetText(clean(Dashboard.StatusText(self.collector.reason,self.collector.blockReason)))
                        if not owns() then return end
                        if not sameContext() then self.publishing=false; paint("refresh superseded; Refresh to retry"); return end
                        local rendered=self:Render()
                        if not owns() then return end
                        self.publishing=false
                        if not sameContext() then paint("refresh superseded; Refresh to retry"); return end
                        if rendered~=false and not self.retained then
                            for n=1,3 do local b=self.footer[n]
                                if type(b.SetEnabled)=="function" then b:SetEnabled(true) end
                                if not owns() then return end
                                if not sameContext() then paint("refresh superseded; Refresh to retry"); return end
                            end
                        end
                        if rendered~=false and not self.retained and self.details then self.details:Refresh() end
                    elseif job.status~="running" then fail(job.reason or "Dashboard build failed; saved data retained.") end
                end)
                if not worked then fail("Dashboard scheduler/build failed; saved data retained. Refresh to retry.") end
                if owns() then validateContinuity() end
            end)
            if not setupCurrent() then return end
            driver:Show()
            if owns() and not sameContext() then fail("Dashboard build superseded; refresh to retry.") end
        end)
        if not ok then
            if job then pcall(job.Cancel,job) end
            fail("Dashboard scheduler unavailable; saved data retained. No synchronous fallback.")
            return
        end
        if setupCurrent() then
            -- All synchronous native/setup callbacks returned under the exact
            -- expected owner. Only now hand the job to its asynchronous guard.
            self.buildJob=job; self.buildBatch=batch; self.buildContext=ctx
            if continuity==q and q then q.job=job; q.preparing=nil end
            preparing=false
        elseif job and self.buildJob~=job then
            pcall(job.Cancel,job)
        end
    end
    function self:Toggle()
        if combat() then self.wantOpen=true; self.collector.reason="Dashboard deferred until out of combat."; return end
        if not self:Create() then return end
        if self.frame:IsShown() then
            self.frame:Hide()
            -- Native Hide runs OnHide; the strict fixture Show/Hide mocks may not.
            if not self.frame:IsShown() and self.buildJob then
                local version=self:StopBuild()
                if version==buildVersion then self:Retain("refresh cancelled while hidden; reopen or Refresh to retry"); self:Render() end
            end
        else self.frame:Show(); self:Refresh() end
    end
    return self
end
