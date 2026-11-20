local _, NS = ...
local Commands = {}
NS.Commands = Commands
function Commands.New(env,runnerFactory)
    local self={env=env}
    local startupEpoch=0
    local function printLine(message)
        if env.DEFAULT_CHAT_FRAME then env.DEFAULT_CHAT_FRAME:AddMessage("CraftArmy: "..tostring(message)) end
    end
    local function safeCombat()
        if type(env.InCombatLockdown)~="function" then return false end
        local ok,value=pcall(env.InCombatLockdown)
        return ok and value==false
    end
    local function identity(s)
        local r=s.runner
        return "case "..tostring(r and r.index or s.index or 0).."/"..tostring(s.total).." "..
            tostring(r and r.name or s.name or "not started").." unit "..tostring(r and r.unit or s.unit or 0)..
            " ["..tostring(r and r.label or s.label or "entry").."]"
    end
    local function progress(s,prefix)
        local r=s.runner
        printLine(prefix..": "..r.passed.." passed; "..r.failed.." failed; "..identity(s)..
            string.format("; wall %.1fms; max unit %.1fms",s.elapsed,s.maxUnit))
    end
    local readClock
    local function finish(s,reason)
        if self.selftest~=s then return end
        self.selftest=nil -- retire before any injected cleanup/output can fail
        if not pcall(readClock,s) then reason=(reason and reason.."; " or "").."invalid stop clock (last valid wall time shown)" end
        local r=s.runner
        s.index=r.index; s.name=r.name; s.label=r.label; s.unit=r.unit
        if reason or r.status~="complete" or r.completed~=true then
            reason=reason or r.reason or "runner incomplete"
            pcall(r.Cancel,r,reason)
            r.status="incomplete"; r.completed=false; r.reason=reason
        end
        if s.frame then
            pcall(s.frame.SetScript,s.frame,"OnUpdate",nil)
            pcall(s.frame.Hide,s.frame)
        end
        self.selftestFrame=nil
        s.frame=nil; s.runner=nil; s.clock=nil
        self.selftestSummary={status=r.status,completed=r.completed,passed=r.passed,failed=r.failed,
            total=s.total,index=s.index,name=s.name,label=s.label,unit=s.unit,elapsed=s.elapsed,maxUnit=s.maxUnit,
            maxIdentity=s.maxIdentity,reason=reason}
        pcall(printLine,(r.completed and "COMPLETE" or "INCOMPLETE")..": "..r.passed.." passed; "..r.failed..
            " failed of "..s.total.."; "..identity(s)..string.format("; wall %.1fms; max unit %.1fms",s.elapsed,s.maxUnit)..
            "; max at "..tostring(s.maxIdentity or "none")..(reason and "; "..reason or "")..
            " (pure injected fixtures, not client API evidence)")
    end
    readClock=function(s)
        local ok,value=pcall(s.clock)
        if not ok or not NS.Core.Finite(value) or value<s.lastTime then error("unusable/backward selftest clock",0) end
        local elapsed=value-s.started
        if not NS.Core.Finite(elapsed) then error("nonfinite elapsed selftest clock",0) end
        s.lastTime=value; s.elapsed=elapsed
        return value
    end
    local function startSelftest()
        if self.knowledgeCapture then pcall(printLine,"Selftest not started: knowledgecapture running; cancel it first."); return end
        if self.selftest then
            local s=self.selftest
            if not safeCombat() then finish(s,"combat/unknown safety; no automatic resume"); return end
            local ok=pcall(function() readClock(s); progress(s,"RUNNING") end)
            if not ok then finish(s,"status callback or clock failure") end
            return s.runner
        end
        if not safeCombat() then printLine("Selftest not started: combat/unknown safety."); return end
        local clock
        if type(env.debugprofilestop)=="function" then clock=env.debugprofilestop
        elseif type(env.GetTimePreciseSec)=="function" then clock=function()
            local value=env.GetTimePreciseSec()
            if not NS.Core.Finite(value) then error("invalid seconds clock",0) end
            return value*1000
        end end
        local ok,now=false,nil
        if clock then ok,now=pcall(clock) end
        if not ok or not NS.Core.Finite(now) or type(env.CreateFrame)~="function" then
            printLine("Selftest not started: usable finite clock and native Frame required."); return
        end
        local s={clock=clock,started=now,lastTime=now,elapsed=0,maxUnit=0,total=0,progressAt=now,progressCount=0}
        local setup=pcall(function()
            s.runner=(runnerFactory or NS.SelfTests.NewRunner)()
            assert(type(s.runner)=="table" and type(s.runner.Step)=="function" and type(s.runner.Cancel)=="function","invalid runner")
            s.total=s.runner.total
            assert(NS.Core.Integer(s.total) and s.total<=512,"invalid runner total")
            self.selftest=s
            s.frame=env.CreateFrame("Frame")
            assert(s.frame and type(s.frame.SetScript)=="function" and type(s.frame.Hide)=="function" and type(s.frame.Show)=="function","Frame capability missing")
            self.selftestFrame=s.frame
            s.frame:SetScript("OnUpdate",function()
                if self.selftest~=s then return end
                local worked=pcall(function()
                    if not safeCombat() then finish(s,"combat/unknown safety; no automatic resume"); return end
                    local before=readClock(s)
                    local r=s.runner
                    local from=identity(s)
                    r:Step() -- exactly ONE unit; never drain/loop in a frame
                    local after=readClock(s)
                    local duration=after-before
                    if not NS.Core.Finite(duration) then error("nonfinite unit duration",0) end
                    local boundary=from.." -> "..identity(s)
                    if not s.maxIdentity or duration>s.maxUnit then s.maxUnit=duration; s.maxIdentity=boundary end
                    if duration>100 then
                        if r.lastLine and r.lastLine:sub(1,5)=="FAIL " then pcall(printLine,r.lastLine) end
                        finish(s,string.format("slow unit %.1fms >100ms; ",duration)..boundary); return
                    end
                    if r.lastLine then printLine(r.lastLine) end
                    if r.status~="running" then finish(s); return end
                    local count=r.passed+r.failed
                    if count-s.progressCount>=10 or after-s.progressAt>=1000 then
                        progress(s,"PROGRESS"); s.progressCount=count; s.progressAt=after
                    end
                end)
                if not worked then finish(s,"scheduler/callback or clock failure; reload if function drift") end
            end)
            s.frame:Show()
            printLine("Selftest STARTED: "..s.total.." cases; one safe unit/frame; /ca selftest cancel; slow-unit stop >100ms (not preemption).")
            if s.runner.status~="running" then finish(s) end
        end)
        if not setup then
            if self.selftest==s then finish(s,"frame/runner setup failure")
            else
                if s.runner and type(s.runner.Cancel)=="function" then pcall(s.runner.Cancel,s.runner,"setup failure") end
                s.runner=nil; s.clock=nil
                pcall(printLine,"Selftest INCOMPLETE: runner setup failure.")
            end
        end
        return s.runner
    end
    -- Separate ephemeral evidence scheduler. Never borrow runtime Context/Roster or DB:
    -- only a new collector's Context/Same may inspect the current native attribution.
    local function captureContext(ctx)
        if type(ctx)~="table" or type(ctx.identity)~="table" or type(ctx.character)~="table" then return false end
        local i=ctx.identity
        local m=NS.Data.expansions[i.skillLineID]
        local cap=NS.Data.Capabilities(i)
        return m and cap and cap.knowledgeMode~="not_applicable" and i.parentID==m.parentID and
            i.profession==m.profession and i.expansionID==11 and m.expansionID==11 and
            NS.Core.Integer(ctx.config,1) and ctx.config<=2147483647 and
            NS.Core.Integer(ctx.sourceCounter,0) and ctx.sourceCounter<=2147483647 and ctx.staged==false and
            type(ctx.character.guid)=="string" and ctx.character.guid~="" and
            type(ctx.character.name)=="string" and type(ctx.character.realm)=="string"
    end
    local function captureGuard(s)
        if self.knowledgeCapture~=s or not safeCombat() then return false end
        local r=self.collector
        if r~=s.runtime or r.revision~=s.revision or r.serial~=s.serial or r.scheduled or r.deferred then return false end
        local ctx=s.guard:Context()
        return captureContext(ctx) and s.guard:Same(s.context,ctx)==true and
            ctx.character.name==s.context.character.name and ctx.character.realm==s.context.character.realm
    end
    local function captureClock(s)
        local value=s.clock()
        if not NS.Core.Finite(value) or value<s.lastTime or not NS.Core.Finite(value-s.started) then error("invalid capture clock",0) end
        s.lastTime=value; s.elapsed=value-s.started
        return value
    end
    local function stopCapture(s,reason)
        if self.knowledgeCapture~=s then return end
        self.knowledgeCapture=nil -- retire FIRST: even throwing cleanup leaves stale callbacks inert
        self.knowledgeCaptureFrame=nil
        if s.dispose then pcall(s.dispose); s.dispose=nil end
        if s.frame then
            pcall(function() s.frame:SetScript("OnUpdate",nil) end)
            pcall(function() s.frame:Hide() end)
        end
        s.frame=nil; s.runtime=nil; s.guard=nil; s.context=nil; s.clock=nil
        s.status=reason and "incomplete" or "complete"; s.completed=not reason
        s.reason=reason; s.phase=s.status
        self.knowledgeCaptureSummary={status=s.status,completed=s.completed,reason=reason,
            callbacks=s.callbacks,elapsed=s.elapsed,maxCallback=s.maxCallback,captureComplete=s.captureComplete==true}
        if reason then pcall(printLine,"Knowledgecapture INCOMPLETE: "..reason.."; no automatic resume; previous success retained, not current.") end
    end
    local function captureStatus()
        local s=self.knowledgeCapture or self.knowledgeCaptureSummary
        if not s then pcall(printLine,"No knowledgecapture running or completed this session."); return end
        if self.knowledgeCapture then
            local ok,valid=pcall(captureGuard,s)
            if not ok or not valid then stopCapture(s,"status guard failed (payload omitted)"); return end
        end
        local ok=pcall(printLine,"Knowledgecapture "..(self.knowledgeCapture and "RUNNING" or s.status)..
            "; callbacks="..tostring(s.callbacks).."; phase="..tostring(s.phase or s.status)..
            "; captureComplete="..tostring(s.captureComplete==true).."; evidence only, all-rank costs unverified.")
        if not ok and self.knowledgeCapture then stopCapture(self.knowledgeCapture,"status callback failure (payload omitted)") end
        return self.knowledgeCapture
    end
    local function startCapture()
        if self.knowledgeCapture then return captureStatus() end
        if self.selftest then pcall(printLine,"Knowledgecapture not started: selftest running; cancel it first."); return end
        local s={callbacks=0,elapsed=0,maxCallback=0,phase="capture",status="running",completed=false}
        -- Pending outputs/jobs are closure-private; dispose clears them even when a
        -- native frame retains a stale callback after failed SetScript cleanup.
        local job,report,text,summary,attempt
        local armed=false -- even reentrant native setup cannot Step on the slash stack
        s.dispose=function()
            local old=job; job=nil; report=nil; text=nil; summary=nil
            if attempt then pcall(function() attempt.frame:Hide() end); attempt=nil end
            if old then pcall(function() old:Cancel("driver retired") end) end
        end
        local setup=pcall(function()
            assert(safeCombat(),"unsafe")
            local r=self.collector
            assert(type(r)=="table" and getmetatable(r)==nil and NS.Core.Integer(r.revision,0) and
                r.revision<=2147483647 and NS.Core.Integer(r.serial,0) and r.serial<=2147483647 and
                not r.scheduled and not r.deferred,"runtime unavailable or pending")
            assert(type(env.CreateFrame)=="function","Frame missing")
            if type(env.debugprofilestop)=="function" then s.clock=env.debugprofilestop
            elseif type(env.GetTimePreciseSec)=="function" then s.clock=function()
                local value=env.GetTimePreciseSec()
                assert(NS.Core.Finite(value),"seconds clock invalid"); return value*1000
            end end
            assert(s.clock,"clock missing")
            s.started=s.clock(); assert(NS.Core.Finite(s.started),"clock invalid"); s.lastTime=s.started
            s.runtime=r; s.revision=r.revision; s.serial=r.serial
            s.guard=NS.Collectors.New(env,nil); s.context=s.guard:Context()
            assert(captureContext(s.context),"context unavailable")
            self.knowledgeCapture=s
            assert(captureGuard(s),"context changed")
            -- Requirements have passed: hide stale success even if later factory or
            -- native driver setup fails. Successful fields themselves remain intact.
            if self.knowledgeCaptureWindow then self.knowledgeCaptureWindow.frame:Hide() end
            job=NS.KnowledgeCheck.NewProfessionCaptureJob(env,r)
            assert(type(job)=="table" and job.status=="running" and type(job.Step)=="function" and type(job.Cancel)=="function","factory failure")
            s.frame=env.CreateFrame("Frame")
            assert(s.frame and type(s.frame.SetScript)=="function" and type(s.frame.Hide)=="function" and type(s.frame.Show)=="function","Frame capability")
            self.knowledgeCaptureFrame=s.frame
            s.frame:SetScript("OnUpdate",function()
                if not armed or self.knowledgeCapture~=s then return end
                local worked=pcall(function()
                    local before=captureClock(s)
                    assert(captureGuard(s),"guard failed")
                    if s.callbacks>=10000 then stopCapture(s,"10000 callback limit reached"); return end
                    s.callbacks=s.callbacks+1
                    local publish=s.phase=="publish"
                    if publish then
                        -- This separate callback closes the completed-format -> UI gap.
                        local window=NS.KnowledgeCheck.Show(env,text,self.knowledgeCaptureWindow)
                        if self.knowledgeCapture~=s then
                            if window then pcall(function() window.frame:Hide() end) end
                            return
                        end
                        attempt=window
                        assert(window,"UI failure")
                        assert(captureGuard(s),"publication guard failed")
                        printLine("Knowledgecapture publication; captureComplete="..tostring(summary.captureComplete==true)..
                            "; evidence only / provisional; all-rank costs unverified; no snapshot writes.")
                    else
                        job:Step() -- exactly ONE capture OR format unit per callback
                        assert(captureGuard(s),"post-Step guard failed")
                        if job.status=="complete" and job.completed==true then
                            if s.phase=="capture" then
                                report=job.report
                                job=NS.KnowledgeCheck.NewFormatJob(report)
                                assert(type(job)=="table" and job.status=="running" and type(job.Step)=="function" and type(job.Cancel)=="function","format factory failure")
                                s.phase="format" -- no format Step in this callback
                            else
                                text=job.text; summary=job.summary
                                assert(type(text)=="string" and type(summary)=="table","invalid format output")
                                job=nil; s.phase="publish" -- publication only next frame
                            end
                        elseif job.status~="running" then error("job incomplete",0) end
                    end
                    assert(captureGuard(s),"final guard failed")
                    local duration=captureClock(s)-before
                    assert(NS.Core.Finite(duration),"duration invalid")
                    -- The clock itself can fail/reenter event processing. Never
                    -- publish disposed locals or overwrite old success after retirement.
                    assert(self.knowledgeCapture==s and self.collector==s.runtime and
                        s.runtime.revision==s.revision and s.runtime.serial==s.serial and
                        not s.runtime.scheduled and not s.runtime.deferred,"post-clock runtime guard failed")
                    s.maxCallback=math.max(s.maxCallback,duration)
                    if duration>100 then stopCapture(s,"slow callback >100ms (post-return detection, not preemption)"); return end
                    if publish then
                        self.knowledgeCaptureReport=report; self.knowledgeCaptureText=text; self.knowledgeCaptureWindow=attempt
                        s.captureComplete=summary.captureComplete==true
                        attempt=nil -- successful window survives disposal
                        stopCapture(s)
                        pcall(printLine,"Knowledgecapture scheduler COMPLETE (data completeness is separate; all-rank costs unverified).")
                    elseif s.callbacks>=10000 then stopCapture(s,"10000 callback limit reached") end
                end)
                if not worked then stopCapture(s,"guard/job/clock/UI/callback failure (payload omitted)") end
            end)
            assert(captureGuard(s),"setup guard failed")
            s.frame:Show()
            printLine("Knowledgecapture STARTED: one unit/frame; /ca knowledgecapture status | cancel; >100ms post-return stop, 10000 callbacks; evidence only.")
        end)
        if not setup then
            if self.knowledgeCapture==s then stopCapture(s,"start/setup failure (payload omitted); require idle runtime, own ready unstaged profession, safe clock/Frame")
            else
                pcall(s.dispose); s.dispose=nil; s.runtime=nil; s.guard=nil; s.context=nil; s.clock=nil
                self.knowledgeCaptureSummary={status="incomplete",completed=false,reason="start requirements unavailable (payload omitted)",callbacks=0,captureComplete=false}
                pcall(printLine,"Knowledgecapture not started: idle existing collector, own ready unstaged specialization profession, safe combat/clock/Frame required; wait/retry manually.")
            end
        end
        armed=setup and self.knowledgeCapture==s
        return self.knowledgeCapture
    end
    local function storageMessage(reason)
        self.collector.blockReason=reason; self.collector.reason=reason
        if self.dashboard then self.dashboard:Refresh() end
    end
    local function startupCurrent(epoch,job,runtime)
        return startupEpoch==epoch and self.storageJob==job and self.collector==runtime
    end
    function self:StartStorage()
        local S=NS.Storage
        startupEpoch=startupEpoch+1; local epoch=startupEpoch
        local runtime,oldJob,oldFrame=self.collector,self.storageJob,self.storageFrame
        local function entering() return startupCurrent(epoch,oldJob,runtime) end
        if oldJob and oldJob.status=="running" then
            pcall(oldJob.Cancel,oldJob); if not entering() then return end
        end
        if oldFrame then
            pcall(function() oldFrame:SetScript("OnUpdate",nil) end); if not entering() then return end
            pcall(function() oldFrame:Hide() end); if not entering() then return end
        end
        if not entering() then return end
        local original=env.CraftArmyDB
        self.storageFrame=nil; self.storageBatch=nil
        runtime.db=nil; runtime.storagePending=true
        runtime:Invalidate("Saved storage initialization pending")
        if not entering() then return end
        local job=S.NewOpenJob(original)
        if not entering() then return end
        self.storageJob=job
        local frame,armed
        local function current() return startupCurrent(epoch,job,runtime) end
        local function owns() return current() and env.CraftArmyDB==original end
        local function message(reason)
            if not current() then return false end
            storageMessage(reason)
            return current()
        end
        local function retireDriver(cancel)
            armed=false
            if not current() then return false end
            if cancel then pcall(job.Cancel,job); if not current() then return false end end
            if frame then
                pcall(function() frame:SetScript("OnUpdate",nil) end); if not current() then return false end
                pcall(function() frame:Hide() end); if not current() then return false end
            end
            return current()
        end
        local function fail(reason)
            -- Cleanup can start a newer invocation; source drift alone may still
            -- be explained by this invocation, without requiring owns().
            if retireDriver(true) then return message(reason) end
            return false
        end
        local function finish()
            if not owns() then return false end
            if job.status=="complete" and original~=nil then
                local safe=safeCombat()
                if not owns() or not safe or self.selftest or self.knowledgeCapture then return false end
            end
            if not retireDriver(false) then return false end
            if not owns() then
                message("Storage source changed during cleanup; root not replaced. /ca storage retry")
                return false
            end
            if job.status=="complete" and original~=nil then
                local safe=safeCombat()
                if not current() then return false end
                if not owns() or not safe or self.selftest or self.knowledgeCapture then
                    message("Storage publication safety changed; original data retained. /ca storage retry")
                    return false
                end
            end
            if job.status=="complete" and job.completed and S.IsHandle(job.result) then
                env.CraftArmyDB=job.savedRoot
                runtime.db=job.result; runtime.storagePending=nil; runtime.blockReason=nil
                runtime:Invalidate("Saved storage ready; showing retained snapshots. Open your profession for a normal refresh.")
                if not current() then return false end
                runtime.changed(); return current()
            end
            message(job.reason or "Storage initialization failed; original data retained. /ca storage retry is explicit.")
            return false
        end
        if job.status~="running" then finish(); return end
        if not message("Saved storage initialization/migration pending; writes disabled. /ca storage status | cancel | retry") or job.status~="running" then return end
        local ok=pcall(function()
            local batch=S.NewFrameBatch(env)
            assert(type(batch)=="table" and type(batch.Step)=="function","Frame batch unavailable")
            if not current() or job.status~="running" then return end
            self.storageBatch=batch
            if not message("Saved storage initialization/migration pending; writes disabled; scheduler "..batch.mode..". /ca storage status | cancel | retry") or job.status~="running" then return end
            assert(type(env.CreateFrame)=="function","Scheduler missing")
            frame=env.CreateFrame("Frame")
            assert(frame and type(frame.SetScript)=="function" and type(frame.Show)=="function" and type(frame.Hide)=="function","Frame capability missing")
            if not current() or job.status~="running" then return end
            self.storageFrame=frame
            frame:SetScript("OnUpdate",function()
                if not armed or not current() then return end
                local worked=pcall(function()
                    if not owns() then
                        fail("Storage source/runtime changed; original root not replaced. /ca storage retry"); return
                    end
                    local safe=safeCombat()
                    if not current() then return end
                    if not owns() then fail("Storage source changed; root not replaced. /ca storage retry"); return end
                    if not safe or self.selftest or self.knowledgeCapture then return end
                    local success,reason=batch:Step(job,function()
                        return safeCombat() and not self.selftest and not self.knowledgeCapture and owns()
                    end)
                    if not current() then armed=false; return end
                    if not success then
                        fail(reason.."; original data retained. /ca storage retry"); return
                    end
                    if not owns() then
                        fail("Storage source/runtime changed; root not replaced. /ca storage retry"); return
                    end
                    safe=safeCombat()
                    if not current() then return end
                    if not owns() then fail("Storage source changed; root not replaced. /ca storage retry"); return end
                    if not safe or self.selftest or self.knowledgeCapture then return end
                    if job.status~="running" then finish() end
                end)
                if not worked and current() then
                    pcall(fail,"Storage scheduler failed; original data retained. /ca storage retry")
                end
            end)
            if not current() or job.status~="running" then return end
            frame:Show()
        end)
        if not current() then return end
        armed=ok and owns() and job.status=="running"
        if not ok then fail("Storage scheduler unavailable; writes disabled, original data retained. /ca storage retry; no synchronous fallback.")
        elseif not owns() then fail("Storage source changed during setup; root not replaced. /ca storage retry") end
    end
    function self:Login()
        if self.collector then return end
        self.collector=NS.Collectors.New(env,nil,function() if self.dashboard then self.dashboard:Refresh() end end)
        self.dashboard=NS.Dashboard.New(env,self.collector)
        self.collector:Roster()
        self:StartStorage()
        if self.collector.blockReason then printLine(self.collector.blockReason) end
    end
    function self:Run(message)
        local action=(message or ""):match("^%s*selftest%s*(.-)%s*$")
        -- Match the command token, not prefixes such as selftesting.
        local token=(message or ""):match("^%s*(%S+)")
        if token=="storage" then
            local arg=(message or ""):match("^%s*storage%s*(.-)%s*$")
            self:Login()
            if arg=="retry" then
                if self.storageJob and self.storageJob.status=="running" then printLine("Storage initialization already running; cancel before retry.")
                elseif NS.Storage.IsHandle(self.collector.db) then printLine("Storage is ready; no initialization retry needed.")
                else self:StartStorage() end
            elseif arg=="cancel" then
                if self.storageJob and self.storageJob.status=="running" then
                    local job,frame,runtime=self.storageJob,self.storageFrame,self.collector
                    startupEpoch=startupEpoch+1; local epoch=startupEpoch -- retire captured callbacks too
                    local function current() return startupCurrent(epoch,job,runtime) end
                    pcall(job.Cancel,job); if not current() then return self.storageJob end
                    if frame then
                        pcall(function() frame:SetScript("OnUpdate",nil) end); if not current() then return self.storageJob end
                        pcall(function() frame:Hide() end); if not current() then return self.storageJob end
                    end
                    if current() then storageMessage("Storage initialization cancelled; original data retained, writes disabled. /ca storage retry") end
                    if not current() then return self.storageJob end
                else printLine("No storage initialization running.") end
            elseif arg~="status" then printLine("Usage: /ca storage status | cancel | retry"); return end
            printLine("Storage "..tostring(self.storageJob and self.storageJob.status or "unavailable").."; steps="..
                tostring(self.storageJob and self.storageJob.steps or 0).."; scheduler="..tostring(self.storageBatch and self.storageBatch.mode or "immediate")..
                "; "..tostring(self.collector.blockReason or self.collector.reason))
            return self.storageJob
        end
        if token=="knowledgecapture" then
            local arg=(message or ""):match("^%s*knowledgecapture%s*(.-)%s*$")
            if arg=="" then return startCapture() end
            if arg=="status" then return captureStatus() end
            if arg=="cancel" then
                if self.knowledgeCapture then stopCapture(self.knowledgeCapture,"cancelled by user")
                else pcall(printLine,"No knowledgecapture running.") end
                return
            end
            pcall(printLine,"Usage: /ca knowledgecapture | /ca knowledgecapture status | /ca knowledgecapture cancel"); return
        end
        if token=="selftest" then
            if action=="" then return startSelftest() end
            if action=="cancel" then
                if self.selftest then finish(self.selftest,"cancelled by user")
                else printLine("No selftest running.") end
                return
            end
            printLine("Usage: /ca selftest | /ca selftest cancel"); return
        end
        local command=(message or ""):match("^%s*(%S*)%s*$")
        if command=="knowledgecheck" then
            if self.knowledgeCapture then pcall(printLine,"Knowledgecheck not started: knowledgecapture running; cancel it first."); return end
            local combat=NS.Collectors.Call(env,"InCombatLockdown")
            if combat~=false then
                printLine("Combat/unknown safety: no knowledge capture or window; run /ca knowledgecheck again out of combat.")
                return nil,"combat/unknown safety"
            end
            local report=NS.KnowledgeCheck.Capture(env,self.collector)
            local text,summary=NS.KnowledgeCheck.Format(report)
            self.knowledgeText=text
            local window,why=NS.KnowledgeCheck.Show(env,text,self.knowledgeWindow)
            self.knowledgeWindow=window
            printLine("Knowledge evidence only: captureComplete="..tostring(summary.captureComplete)..
                "; "..summary.reconciliation.status.."; all-rank costs unverified; no snapshot writes.")
            if why then printLine(why) end
            return report,text,why
        end
        if command=="scan" and self.knowledgeCapture then stopCapture(self.knowledgeCapture,"explicit scan requested") end
        self:Login()
        if command=="" then self.dashboard:Toggle()
        elseif command=="scan" then
            local _,why=self.collector:Scan(); printLine(why or self.collector.reason)
        else printLine("/ca toggles dashboard; /ca help; /ca scan (open own Midnight profession); /ca selftest (frame-stepped isolated fixtures, out of combat); /ca selftest cancel; /ca knowledgecheck (read-only provisional Inscription evidence, out of combat); /ca knowledgecapture [status|cancel] (frame-stepped read-only specialization profession evidence).") end
    end
    function self:Event(event,...)
        if self.knowledgeCapture then stopCapture(self.knowledgeCapture,"event received; retry manually after normal processing settles") end
        if event=="PLAYER_REGEN_DISABLED" and self.selftest then finish(self.selftest,"entered combat; no automatic resume") end
        if event=="PLAYER_LOGIN" then self:Login(); self.collector:Request("Login: open your own profession to refresh"); return end
        if not self.collector then return end
        if event=="ITEM_DATA_LOAD_RESULT" then self.collector:ItemResult(...); return end
        if event=="TRADE_SKILL_CLOSE" or event=="TRADE_SKILL_DATA_SOURCE_CHANGING" or event=="PLAYER_REGEN_DISABLED" then
            self.collector:Invalidate(event); self.dashboard:Refresh(); return
        end
        if event=="PLAYER_REGEN_ENABLED" then
            self.collector.deferred=nil
            if self.dashboard.wantOpen then self.dashboard.wantOpen=nil; self.dashboard:Toggle() end
        end
        self.collector:Request(event)
    end
    return self
end
-- A nonvisible event driver only. Actual dashboard frames are lazy/out of combat.
if type(CreateFrame)=="function" and type(SlashCmdList)=="table" then
    local commands=Commands.New(_G)
    NS.runtime=commands
    SLASH_CRAFTARMY1="/ca"
    SlashCmdList.CRAFTARMY=function(message) commands:Run(message) end
    local driver=CreateFrame("Frame")
    for _,event in ipairs(NS.Collectors.events) do driver:RegisterEvent(event) end
    driver:SetScript("OnEvent",function(_,event,...) commands:Event(event,...) end)
end
