local _, NS = ...
local Details, C = {}, NS.Core
local S = NS.Storage
NS.Details = Details
local POLICY="native-rank-reconciled-v1"
local function integer(v,low) return C.Integer(v,low or 0) and v<=2147483647 end
local function plain(v) return type(v)=="table" and getmetatable(v)==nil end
local function native(i)
    return plain(i) and integer(i.skillLineID,1) and integer(i.parentID,1) and integer(i.profession,1) and
        integer(i.expansionID,1) and i.skillLineID==2913 and i.parentID==773 and i.profession==13 and i.expansionID==11
end
-- Private lookup only: callers either just validated this DB or hold immutable
-- selected-source ownership. Never use this as a public saved-data validation gate.
local function activeLookup(db,s)
    if not plain(db) or not C.Integer(db.schema,1) or db.schema~=1 or not plain(db.characters) then return nil end
    local c=db.characters[s.guid]
    local p=plain(c) and plain(c.professions) and c.professions[s.id]
    local g=plain(p) and p.active
    if not plain(g) or not integer(g.generation,1) or g.generation~=s.generation or
        not plain(g.fields) or not native(g.identity) then return nil end
    return g,c,p
end
local function value(g,key,at)
    local f=g.fields[key]; local l=f and f.last
    if not l or l.status~="observed" or f.attempt.status~="observed" or
        (at~=nil and l.observedAt~=at) then return nil end
    return l.value,l
end
local function selected(db,s)
    if S.IsHandle(db) then
        if not plain(s) or type(s.archived)~="boolean" then return nil end
        return S.Read(db,s.guid,s.id,s.generation,s.archived)
    end
    if not plain(s) or type(s.guid)~="string" or not integer(s.id,1) or not integer(s.generation,1) or
        type(s.archived)~="boolean" or not db or not C.Open(db) then return nil end
    local c=db.characters[s.guid]; local p=c and c.professions[s.id]
    if not p then return nil end
    if not s.archived then return p.active and p.active.generation==s.generation and p.active or nil end
    for _,g in ipairs(p.archives) do if g.generation==s.generation then return g end end
end

-- All API reads are private, guarded on both sides. Raw errors never escape.
function Details.NewCaptureJob(env,collector,scope)
    local job={status="running",steps=0,phase="metadata",progress="Preparing details"}
    local db,source,ctx,serial,revision,at,build,report,descriptors
    local characters,characterRecord,professionRecord,lastTime
    local storageToken
    local pathIndex,perkIndex,verifyIndex,totalPerks,textBytes=1,1,1,0,0
    local perkIDs={}
    local busy=false
    local function stop(status,reason)
        job.status=status; job.reason=reason
        db=nil; source=nil; ctx=nil; report=nil; descriptors=nil
        characters=nil; characterRecord=nil; professionRecord=nil; perkIDs=nil
        return job
    end
    function job:Cancel()
        if self.status=="running" then stop("cancelled","Details capture cancelled; saved report retained.") end
        return self
    end
    local function cheap()
        if job.status~="running" or collector.db~=db or not C.Integer(collector.serial) or
            not C.Integer(collector.revision) or collector.serial~=serial or collector.revision~=revision then return false end
        if storageToken then return S.IsHandle(db) and S.Token(db,scope.guid,scope.id)==storageToken end
        local g,c,p=activeLookup(db,scope)
        return g==source and c==characterRecord and p==professionRecord and db.characters==characters and
            C.Integer(g.scannedAt) and g.scannedAt==at
    end
    local function guard()
        if not cheap() then return false end
        local current=collector:Context()
        if not cheap() or not current or current.staged~=false or not native(current.identity) or
            not integer(current.config,1) or not integer(current.sourceCounter) or
            current.character.guid~=scope.guid or current.identity.skillLineID~=scope.id or
            current.identity.expansionID~=ctx.identity.expansionID or not collector:Same(ctx,current) or
            current.config~=report.configID then return false end
        local now=collector:Now()
        if not cheap() or not C.Integer(now) or now<lastTime then return false end
        lastTime=now
        return true
    end
    local function read(path,...)
        if not guard() then error("discard",0) end
        local fn=NS.Collectors.Resolve(env,path)
        if type(fn)~="function" then error("data",0) end
        local ok,result=pcall(fn,...)
        if not guard() then error("discard",0) end
        if not ok or result==nil then error("data",0) end
        return result
    end
    local function nodeMatches(d,n)
        if not plain(n) then return false end
        for key,v in pairs(d.node) do
            if key=="activeEntry" then
                if not plain(n.activeEntry) or not integer(n.activeEntry.entryID,1) or not integer(n.activeEntry.rank) or
                    n.activeEntry.entryID~=v.entryID or n.activeEntry.rank~=v.rank then return false end
            elseif key=="isAvailable" then
                if type(n[key])~="boolean" or n[key]~=v then return false end
            elseif not integer(n[key],key=="ID" and 1 or 0) or n[key]~=v then return false end
        end
        return true
    end
    local function matches(d)
        return nodeMatches(d,read("C_Traits.GetNodeInfo",report.configID,d.path.id)) and cheap()
    end
    local function description(v,required)
        if type(v)~="string" or #v>4096 or (required and not v:match("%S")) then error("data",0) end
        textBytes=textBytes+#v
        if textBytes>32768 then error("data",0) end
        return v
    end
    local function commit(failed)
        if not failed and (not C.ValidPayload("professionDetails",report,"observed") or not C.Copy(report)) then
            return stop("failed","Invalid details payload; saved report retained.")
        end
        if not guard() then return stop("discarded","Context/source changed; details discarded.") end
        -- Amendment: compact final fingerprint in THIS commit frame. Context only
        -- brackets the batch; no Copy/Open/perk/entry reads between its node pcalls.
        local fn=NS.Collectors.Resolve(env,"C_Traits.GetNodeInfo")
        if type(fn)~="function" then return stop("failed","Final point check unavailable; saved report retained.") end
        for _,d in ipairs(descriptors) do
            if not cheap() then return stop("discarded","Source changed; details discarded.") end
            local ok,n=pcall(fn,report.configID,d.path.id)
            if not cheap() or not ok or not nodeMatches(d,n) or not cheap() then
                return stop("discarded","Final point check failed; saved report retained.")
            end
        end
        if not guard() then return stop("discarded","Context/source changed; details discarded.") end
        -- No Context or changed callback inside this atomic writer. Core owns preflight.
        local g=S.Apply(db,ctx.character,ctx.identity,{professionDetails=C.Observation(
            failed and "unknown" or "observed",not failed and report or nil,lastTime,"C_ProfSpecs details",
            failed and "Details unavailable; prior coherent report retained." or nil)},at,build)
        if not g then return stop("failed","Details commit rejected; saved data unchanged.") end
        local key=scope.guid..":"..scope.id
        local fresh=collector.fresh[key]
        if not fresh or fresh.generation~=g.generation then fresh={generation=g.generation,fields={}}; collector.fresh[key]=fresh end
        fresh.fields.professionDetails=not failed and true or nil
        job.committed=true
        return stop(failed and "failed" or "complete",failed and
            "Details unavailable; saved report retained." or "Details refreshed; recipe learning not checked.")
    end
    local function unit()
        if job.phase=="commit" then return commit(job.dataFailed) end
        if not guard() then return stop("discarded","Context/source changed; details discarded.") end
        if job.phase=="metadata" then
            local d=descriptors[pathIndex]
            if not matches(d) then return stop("discarded","Native points changed; run a normal scan first.") end
            d.path.description=description(read("C_ProfSpecs.GetDescriptionForPath",d.path.id),false)
            local list=read("C_ProfSpecs.GetPerksForPath",d.path.id)
            if not plain(list) then error("data",0) end
            local count,max,seen=0,0,{}
            for key in pairs(list) do
                count=count+1
                if count>32 or not integer(key,1) or key>32 then error("data",0) end
                max=math.max(max,key)
            end
            if count~=max then error("data",0) end
            d.perks={}
            for i=1,count do
                local k=rawget(list,i)
                if not plain(k) or not integer(k.perkID,1) or type(k.isMajorPerk)~="boolean" or seen[k.perkID] or perkIDs[k.perkID] then error("data",0) end
                seen[k.perkID]=true; perkIDs[k.perkID]=true
                totalPerks=totalPerks+1; if totalPerks>512 then error("data",0) end
                d.perks[i]={id=k.perkID,isMajorPerk=k.isMajorPerk}
            end
            if count>0 then job.phase="perk" else pathIndex=pathIndex+1 end
        elseif job.phase=="perk" then
            local d=descriptors[pathIndex]; local k=d.perks[perkIndex]
            k.rank=read("C_ProfSpecs.GetUnlockRankForPerk",k.id)
            k.state=read("C_ProfSpecs.GetStateForPerk",k.id,report.configID)
            k.description=description(read("C_ProfSpecs.GetDescriptionForPerk",k.id),true)
            if not integer(k.rank) or k.rank>d.path.capacity or not integer(k.state) or (k.state~=0 and k.state~=2) or
                (k.state==2 and (d.path.locked or k.rank>d.path.purchased)) then error("data",0) end
            d.path.perks[#d.path.perks+1]=k; perkIndex=perkIndex+1
            if perkIndex>#d.perks then perkIndex=1; pathIndex=pathIndex+1; job.phase="metadata" end
        elseif job.phase=="verify" then
            if not matches(descriptors[verifyIndex]) then return stop("discarded","Native points changed; details discarded.") end
            verifyIndex=verifyIndex+1
            if verifyIndex>#descriptors then job.phase="commit" end
        end
        if pathIndex>#descriptors and job.phase=="metadata" then job.phase="verify" end
        if not guard() then return stop("discarded","Context/source changed; details discarded.") end
        job.progress="Details: "..job.phase.." (unit "..job.steps..")"
    end
    function job:Step()
        if self.status~="running" then return self end
        if busy then return stop("discarded","Reentrant details capture discarded.") end
        if self.steps>=10000 then return stop("failed","Details step limit; saved report retained.") end
        busy=true; self.steps=self.steps+1
        local committing=self.phase=="commit"
        local ok,why=pcall(unit)
        busy=false
        if not ok and self.status=="running" then
            local safe,valid=pcall(guard)
            if not committing and why=="data" and safe and valid then
                self.dataFailed=true; self.phase="commit"; self.progress="Details unavailable; retaining saved report"
            else stop("discarded","Details capture interrupted; saved report retained.") end
        end
        return self
    end
    local ok=pcall(function()
        if not plain(scope) or scope.archived~=false or scope.id~=2913 then error("scope") end
        scope={guid=scope.guid,id=scope.id,generation=scope.generation,archived=false}
        db=collector.db; source=selected(db,scope)
        if not source or not native(source.identity) then error("scope") end
        if S.IsHandle(db) then
            local presentation=source
            source,storageToken=collector:DetailsSource(scope)
            if not source or not storageToken or source.scannedAt~=presentation.scannedAt then error("source") end
            source.fields.professionDetails=presentation.fields.professionDetails
        else
            characters=db.characters
            local g; g,characterRecord,professionRecord=activeLookup(db,scope)
            if g~=source then error("scope") end
        end
        at=source.scannedAt; ctx=collector:Context(); serial=collector.serial; revision=collector.revision
        if not ctx or not native(ctx.identity) or ctx.character.guid~=scope.guid or ctx.staged~=false or not integer(ctx.config,1) or
            not integer(ctx.sourceCounter) or not C.Integer(serial) or not C.Integer(revision) then error("context") end
        local prior=source.fields.professionDetails
        lastTime=math.max(at,prior and prior.last and prior.last.observedAt or at)
        local raw=value(source,"knowledgeRaw",at); local index=value(source,"knowledgeIndex",at)
        if not raw or raw.policy~=POLICY or raw.nativeComplete~=true or raw.tabsComplete~=true or raw.stagedStart~=false or
            raw.stagedEnd~=false or raw.stable~=true or raw.configID~=ctx.config or raw.sourceCounter~=ctx.sourceCounter or
            not index or #index==0 or #raw.tabs~=#index then error("source") end
        report={version=1,skillLineID=2913,configID=ctx.config,sourceScanAt=at,trees={}}
        descriptors={}; local seen={}
        for i,t in ipairs(index) do
            local tree,last=value(source,"tree:"..t.id,at)
            if not tree or tree.accountingPolicy~=POLICY or tree.id~=t.id or tree.root~=t.root or
                raw.tabs[i].id~=t.id or raw.tabs[i].root~=tree.root or not native(raw.identity) then error("source") end
            build=last.build
            local out={id=tree.id,name=tree.name,root=tree.root,purchased=tree.purchased,capacity=tree.capacity,paths={}}
            report.trees[#report.trees+1]=out
            for _,p in ipairs(tree.paths) do
                if #descriptors>=64 or seen[p.id] then error("source") end
                seen[p.id]=true
                local path={id=p.id,name=p.name,purchased=p.purchased,capacity=p.capacity,locked=p.locked,perks={}}
                local node={}
                for _,key in ipairs({"ID","type","flags","isAvailable","currentRank","activeRank","ranksPurchased","ranksIncreased","maxRanks","totalMaxRanks"}) do node[key]=p.node[key] end
                node.activeEntry={entryID=p.node.activeEntry.entryID,rank=p.node.activeEntry.rank}
                local rp=raw.tabs[i].paths[p.id]
                if not rp or not nodeMatches({node=node},rp.node) then error("source") end
                out.paths[#out.paths+1]=path; descriptors[#descriptors+1]={path=path,node=node}
            end
        end
        if #descriptors==0 or not guard() then error("context") end
    end)
    if not ok then stop("blocked","Open your own ready unstaged Midnight Inscription and run a complete normal scan first.") end
    return job
end

-- Presentation only. Never changes the persisted client strings or the dashboard's
-- existing tooltip cleaner. Unknown tokens become literal escaped pipes.
function Details.Plain(text)
    local raw=tostring(text or "")
    local tokens,stack,pos={}, {},1
    local function token(text,kind)
        local t={text=text,kind=kind}; tokens[#tokens+1]=t; return t
    end
    while pos<=#raw do
        local pipe=raw:find("|",pos,true)
        if not pipe then token(raw:sub(pos),"text"); break end
        token(raw:sub(pos,pipe-1),"text")
        local code=raw:sub(pipe,pipe+1)
        local color=raw:sub(pipe,pipe+9):match("^|c%x%x%x%x%x%x%x%x$")
        local close=(code=="|H" or code=="|T" or code=="|A") and raw:find("|",pipe+2,true)
        local body=close and raw:sub(pipe+2,close-1)
        local link=code=="|H" and close and raw:sub(close,close+1)=="|h" and body~="" and not body:find("[\r\n]")
        local icon=close and body and not body:find("[\r\n]") and
            ((code=="|T" and body:match("^[^%s:]") and raw:sub(close,close+1)=="|t") or
             (code=="|A" and body:match("^:[^%s:]") and raw:sub(close,close+1)=="|a"))
        if code=="||" then token("||","text"); pos=pipe+2
        elseif color or link then
            local last=color and pipe+9 or close+1
            local t=token(raw:sub(pipe,last),color and "color" or "link")
            if #stack<16 then stack[#stack+1]=t end
            pos=last+1
        elseif code=="|r" or code=="|h" then
            local t=token(code,"markup"); local open=stack[#stack]
            if open and open.kind==(code=="|r" and "color" or "link") then
                open.remove=true; t.remove=true; stack[#stack]=nil
            end
            pos=pipe+2
        elseif icon then token("","text"); pos=close+2
        else
            token("||","text"); pos=pipe+1
        end
    end
    local out={}
    for _,t in ipairs(tokens) do
        if not t.remove then out[#out+1]=t.kind=="text" and t.text or (t.text:gsub("|","||")) end
    end
    return table.concat(out)
end

-- Resolve a stable scope exactly once per normal refresh, never per capture frame.
function Details.Model(collector,scope)
    local g=selected(collector.db,scope)
    if not g then return {status="Snapshot unavailable or generation removed.",branches={}} end
    local f=g.fields.professionDetails; local last=f and f.last
    local report=last and last.status=="observed" and last.value
    local session=collector.fresh[scope.guid..":"..scope.id]
    local fresh=not scope.archived and session and session.generation==g.generation and
        session.fields.professionDetails==true and f and f.attempt.status=="observed" and
        report and report.sourceScanAt==g.scannedAt
    local status=scope.archived and "Archived saved details" or (fresh and "Fresh details" or "Saved / stale details — not current")
    if not native(g.identity) then status="Details unavailable for this profession (read-only)." end
    if last then
        local ok,now=pcall(collector.Now,collector)
        local age="age unknown"
        if ok and C.Integer(now) and now>=last.observedAt then
            local seconds=now-last.observedAt
            if seconds<60 then age=seconds.."s ago"
            elseif seconds<3600 then age=math.floor(seconds/60).."m ago"
            elseif seconds<86400 then age=math.floor(seconds/3600).."h ago"
            else age=math.floor(seconds/86400).."d ago" end
        end
        status=status.."; observed "..age.." (at "..tostring(last.observedAt)..")"
    end
    local branches={}
    local trees=report and report.trees
    if not trees then
        trees={}
        local index=value(g,"knowledgeIndex") or (g.fields.knowledgeIndex and g.fields.knowledgeIndex.last and g.fields.knowledgeIndex.last.value) or {}
        for _,t in ipairs(index) do
            local tf=g.fields["tree:"..t.id]; local tv=tf and tf.last and tf.last.value
            if tv then trees[#trees+1]=tv end
        end
        status=status.."; perks not observed."
    end
    for _,t in ipairs(trees) do
        for _,p in ipairs(t.paths) do
            local path={purchased=p.purchased,locked=p.locked,description=report and p.description,perks={}}
            if report then
                for _,k in ipairs(p.perks) do
                    path.perks[#path.perks+1]={rank=k.rank,state=k.state,description=k.description}
                end
            end
            branches[#branches+1]={tree=Details.Plain((t.name or "Unknown tree")..": "..t.purchased.."/"..t.capacity),
                title=Details.Plain((p.name or "Unknown branch")..": "..p.purchased.."/"..p.capacity),
                path=path,observed=report~=nil}
        end
    end
    return {status=status,branches=branches,supported=native(g.identity),archived=scope.archived}
end

-- Only the selected branch is formatted into a scroll body. Model descriptors own
-- their scalars/strings, never exposing a saved table to callers or later navigation.
function Details.Branch(model,index)
    local branch=model.branches[index]
    if not branch then return nil end
    local p=branch.path
    local lines={}
    if branch.observed then
        lines[#lines+1]="Client per-point rule (not computed gained totals):"
        lines[#lines+1]=p.description~="" and p.description or "No per-point rule supplied by the client."
        if p.locked then lines[#lines+1]="Locked — not earned from investment."
        elseif p.purchased==0 then lines[#lines+1]="0 invested — this rule is not a flat earned gain." end
        lines[#lines+1]="\nEarned milestones:"
        local count=0
        for _,k in ipairs(p.perks) do
            if k.state==2 then
                count=count+1; lines[#lines+1]="Required rank "..k.rank..":\n"..k.description
            end
        end
        if count==0 then lines[#lines+1]="None earned in this fully observed report." end
    else lines[#lines+1]="Perks not observed. Open your own ready unstaged Midnight Inscription, run a normal scan, then choose Refresh details." end
    return {tree=branch.tree,title=branch.title,body=Details.Plain(table.concat(lines,"\n\n"))}
end

function Details.NewView(env,collector)
    local self={index=1}
    local function combat()
        local ok,v=pcall(function() return env.InCombatLockdown() end)
        return not ok or v~=false
    end
    function self:Retire()
        if self.job then self.job:Cancel() end
        self.job=nil
        if self.driver then self.driver:SetScript("OnUpdate",nil) end
    end
    function self:Close()
        self:Retire()
        if self.frame then self.frame:Hide() end
    end
    function self:Render()
        local model=self.model; if not self.frame or not model then return end
        self.index=math.max(1,math.min(self.index,math.max(1,#model.branches)))
        local branch=Details.Branch(model,self.index)
        self.tree:SetText(branch and branch.tree or "No known branch investment")
        self.title:SetText(branch and branch.title or "Details")
        self.position:SetText((#model.branches==0 and 0 or self.index).." / "..#model.branches)
        self.status:SetText(Details.Plain(model.status))
        -- Full names also live inside the wrapping scroll body, never clipped out
        -- of reach by unusually long localized header labels.
        self.bodyText=branch and (branch.tree.."\n"..branch.title.."\n\n"..branch.body) or
            Details.Plain(model.supported==false and "Details unavailable for this profession (read-only)." or
                "Perks not observed. Refresh details after a complete normal Inscription scan.")
        local top=32
        for _,label in ipairs({self.status,self.tree,self.title}) do
            local h=42
            if type(label.GetStringHeight)=="function" then
                local ok,n=pcall(label.GetStringHeight,label)
                if ok and C.Finite(n) and n>0 then h=math.min(80,math.max(14,n)) end
            end
            if label==self.status then h=math.max(42,h) end
            label:SetHeight(h)
            label:ClearAllPoints(); label:SetPoint("TOPLEFT",18,-top); top=top+h+4
        end
        self.position:ClearAllPoints(); self.position:SetPoint("TOPLEFT",660,-top)
        top=top+24
        self.scroll:ClearAllPoints(); self.scroll:SetPoint("TOPLEFT",18,-top); self.scroll:SetSize(716,math.max(140,453-top))
        self.body:SetText(self.bodyText); self.body:ClearFocus(); self.scroll:SetVerticalScroll(0)
        self.previous:SetEnabled(self.index>1); self.next:SetEnabled(self.index<#model.branches)
        self.refresh:SetEnabled(model.supported==true and not model.archived)
    end
    function self:Refresh()
        if not self.scope or not self.frame or not self.frame:IsShown() then return end
        if self.job and self.job.status=="running" then return end
        self.model=Details.Model(collector,self.scope)
        self:Render()
    end
    function self:Start()
        self:Retire()
        if combat() or not self.scope then return end
        local job=Details.NewCaptureJob(env,collector,self.scope); self.job=job
        self.status:SetText(Details.Plain(job.reason or job.progress))
        if job.status~="running" then self.job=nil; return end
        self.driver:SetScript("OnUpdate",function()
            -- Identity check also retires callbacks retained by an older frame/job.
            if self.job~=job then return end
            if combat() or not self.frame:IsShown() then
                self:Retire(); self:Refresh()
                self.status:SetText("Details capture cancelled; showing saved report. "..Details.Plain(self.model.status))
                return
            end
            job:Step()
            if self.job~=job then return end
            if job.status=="running" then self.status:SetText(Details.Plain(job.progress)); return end
            self.job=nil; self.driver:SetScript("OnUpdate",nil)
            self:Refresh(); self.status:SetText(Details.Plain(job.reason.." "..self.model.status))
            if job.committed then collector.changed() end
        end)
    end
    function self:Create()
        if self.frame then return true end
        if combat() then return false end
        local frame=env.CreateFrame("Frame","CraftArmyProfessionDetails",env.UIParent,"BasicFrameTemplateWithInset")
        self.frame=frame; frame:SetSize(780,540); frame:SetPoint("CENTER")
        frame.TitleText:SetText("CraftArmy — profession Details")
        local function label(width,x,y)
            local t=frame:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
            t:SetWidth(width); t:SetJustifyH("LEFT"); t:SetWordWrap(true); t:SetPoint("TOPLEFT",x,y); return t
        end
        local function button(text,width,x,fn)
            local b=env.CreateFrame("Button",nil,frame,"UIPanelButtonTemplate")
            b:SetSize(width,22); b:SetPoint("BOTTOMLEFT",x,42); b:SetText(text); b:SetScript("OnClick",fn); return b
        end
        self.status=label(740,18,-32); self.tree=label(740,18,-64); self.title=label(740,18,-91)
        self.position=label(90,660,-118)
        self.scroll=env.CreateFrame("ScrollFrame",nil,frame,"UIPanelScrollFrameTemplate")
        self.scroll:SetPoint("TOPLEFT",18,-143); self.scroll:SetSize(716,310)
        self.body=env.CreateFrame("EditBox",nil,self.scroll)
        self.body:SetMultiLine(true); self.body:SetAutoFocus(false); self.body:SetFontObject("ChatFontNormal")
        self.body:SetWidth(710); self.body:SetTextInsets(4,4,4,4); self.body:SetMaxLetters(0)
        self.body:SetScript("OnTextChanged",function(edit)
            if edit:GetText()~=self.bodyText then edit:SetText(self.bodyText or "") end
        end)
        self.body:SetScript("OnEditFocusGained",function(edit) edit:ClearFocus() end)
        self.body:SetScript("OnEscapePressed",function() self:Close() end)
        self.scroll:SetScrollChild(self.body)
        self.previous=button("Previous branch",125,18,function() self.index=self.index-1; self:Render() end)
        self.next=button("Next branch",125,151,function() self.index=self.index+1; self:Render() end)
        self.refresh=button("Refresh details",135,292,function() self:Start() end)
        self.close=button("Close",85,655,function() self:Close() end)
        self.footer=label(740,18,-511); self.footer:SetText("Recipe learning not checked in this slice.")
        self.driver=env.CreateFrame("Frame",nil,frame)
        frame:SetScript("OnHide",function() self:Retire() end)
        frame:SetScript("OnKeyDown",function(f,key)
            if key=="ESCAPE" then f:SetPropagateKeyboardInput(false); self:Close()
            else f:SetPropagateKeyboardInput(true) end
        end)
        frame:EnableKeyboard(true)
        if type(env.UISpecialFrames)=="table" then env.UISpecialFrames[#env.UISpecialFrames+1]="CraftArmyProfessionDetails" end
        frame:Hide(); return true
    end
    function self:Open(scope)
        self:Retire()
        if combat() or not self:Create() then return false end
        self.scope=C.Copy(scope); self.index=1
        local scale=1
        for _,d in ipairs({{"GetWidth",780},{"GetHeight",540}}) do
            if env.UIParent and type(env.UIParent[d[1]])=="function" then
                local ok,n=pcall(env.UIParent[d[1]],env.UIParent)
                if ok and C.Finite(n) and n>30 then scale=math.min(scale,(n-30)/d[2]) end
            end
        end
        self.frame:SetScale(C.Finite(scale) and scale>0 and scale or 1)
        self.frame:Show(); self:Refresh(); return true
    end
    return self
end
