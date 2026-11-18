local _, NS = ...
local V, C, D = {}, NS.Core, NS.Data
NS.ViewModel = V
V.index={Name=1,Realm=2,Profession=3,Skill=4,Accessory1=5,Accessory2=6,Tool=7,
    Stat=8,Enchant=9,Concentration=10,Moxie=11,Knowledge=12,Unspent=13,LastUpdated=14}
local I=V.index
V.columns={"Name","Realm","Profession","Skill","Accessory #1","Accessory #2","Tool","Stat","Enchant",
    "Concentration","Moxie","Knowledge trees","Unspent KP","Last Updated"}
V.roles={"accessory1","accessory2","tool"}
function V.SortDescending(column)
    return column==I.Accessory1 or column==I.Accessory2 or column==I.Tool or
        column==I.Concentration or column==I.Moxie or column==I.Unspent or column==I.LastUpdated
end
local colors={[2]={30/255,1,0},[3]={0,112/255,221/255},[4]={163/255,53/255,238/255}}
local function str(v) if v==nil then return "?" end return tostring(v) end
local function number(v) return C.Finite(v) end
local function currentGUID(value)
    return type(value)=="string" and #value>0 and #value<=128 and not value:find("[%c]") and value or nil
end
function V.Age(now, at)
    if not C.Integer(at) or not C.Integer(now) then return "? age" end
    local d=math.max(0,now-at)
    if d<60 then return d.."s" elseif d<3600 then return math.floor(d/60).."m"
    elseif d<86400 then return math.floor(d/3600).."h" end
    return math.floor(d/86400).."d"
end
function V.Field(g,key,session)
    local f=g.fields[key]
    if not f then return nil,{known=false, fresh=false, text="No snapshot: "..key} end
    local l=f.last
    local fresh=session and session.generation==g.generation and session.fields[key]==true and
        f.attempt.status=="observed" and l and l.status=="observed"
    local successful=f.attempt.status=="observed" or f.attempt.status=="empty" or f.attempt.status=="not_applicable"
    local state={known=l~=nil, fresh=fresh==true, stale=l~=nil and not successful,
        status=f.attempt.status, observedAt=l and l.observedAt, attemptedAt=f.attempt.attemptedAt,
        lastStatus=l and l.status, reason=f.attempt.reason, source=f.attempt.source}
    state.text=key..": "..f.attempt.status.."; attempted "..str(state.attemptedAt)..
        "; observed "..str(state.observedAt).."; "..(state.fresh and "fresh guarded read" or "snapshot/last observed")..
        "; "..(state.source or "")..(state.reason and "; "..state.reason or "")
    return l and l.value,state
end
function V.Gear(value,state)
    local out={text="?",tooltip={state.text},state=state}
    if state.lastStatus=="empty" then out.text=""; out.empty=true; out.exists=false; return out end
    if not value then return out end
    out.value=value; out.link=type(value.link)=="string" and value.link or nil
    out.exists=value.exists
    if value.exists==false then out.text=""; out.empty=true; return out end
    if value.exists~=true then return out end
    local rank=C.Integer(value.rank,1) and value.rank<=5 and tostring(value.rank) or "?"
    local icon=C.Integer(value.icon,1) and ("|T"..value.icon..":14:14|t") or ""
    local atlas=value.quality and value.quality.iconSmall
    local rankIcon=rank~="?" and value.quality and value.quality.quality==value.rank and
        type(atlas)=="string" and atlas:match("^[%w_%-]+$") and
        ("|A:"..atlas..":14:14|a") or ""
    out.text=icon..(rankIcon~="" and rankIcon or rank)
    out.rarityColor=colors[value.rarity]
    out.rarity=value.rarity; out.rank=value.rank; out.icon=value.icon
    out.qualityAtlas=rankIcon~="" and atlas or nil
    out.enchanted=value.metadataReady==true and value.enchant and value.enchant.status=="observed" and value.enchant.present==true or false
    local intrinsic=value.role=="tool" and value.toolStat
    out.toolLetter=intrinsic and intrinsic.value and D.statCategories[intrinsic.value] and D.statCategories[intrinsic.value][1] or nil
    out.tooltip[#out.tooltip+1]="Slot "..str(value.slot).."; role "..str(value.role)..
        "; rarity "..str(value.rarity).."; crafted rank "..rank
    if value.loadReason then out.tooltip[#out.tooltip+1]=value.loadReason end
    return out
end
function V.Tool(value,state)
    local out=V.Gear(value,state)
    out.statsText="?"; out.enchantText="?"
    if out.empty or state.lastStatus=="not_applicable" then
        out.text=""; out.statsText=""; out.enchantText=""; out.tooltip[#out.tooltip+1]="Tool confirmed empty/not applicable"
        return out
    end
    if not value or value.exists~=true then return out end
    local stats={}
    local keys={}
    for key in pairs(value.stats or {}) do keys[#keys+1]=key end
    table.sort(keys)
    for _,key in ipairs(keys) do
        local map=D.statNames[key]
        stats[#stats+1]=map and map[2] or "?"
        out.tooltip[#out.tooltip+1]=(map and map[2] or key)..": "..str(value.stats[key]).." (observed total); key "..key
    end
    if #stats>0 then out.statsText=table.concat(stats,", ") end
    out.tooltip[#out.tooltip+1]="* Observed total; base/enchant attribution unknown. No bonus added/subtracted."
    local enchant=value.enchant
    if enchant and enchant.status=="observed" then
        local category=D.statCategories[enchant.category]
        if value.metadataReady~=false then
            if enchant.present==false then out.enchantText="" else out.enchantText=category and category[2] or "?" end
            out.enchant=enchant
        end
        out.tooltip[#out.tooltip+1]="Enchant: "..(enchant.present and "yes" or "no")..
            "; ID "..str(enchant.id).."; stat "..(category and category[2] or str(enchant.category)).."; amount/rank unknown"
    elseif enchant then out.tooltip[#out.tooltip+1]="Enchant: unknown; "..str(enchant.reason) end
    for _,line in ipairs(value.enchantLines or {}) do
        out.tooltip[#out.tooltip+1]=line.leftText or ""; out.tooltip[#out.tooltip+1]=line.rightText or ""
    end
    return out
end

local function treeDetail(tree,raw,at,state)
    local lines={state.text,"Observed tree at "..str(at)}
    if (tree and tree.compactSnapshot) or (raw and raw.format=="raw-summary-v1") then
        lines[#lines+1]="Raw diagnostic payload is not retained in compact saved snapshots."
    end
    if tree then
        lines[#lines+1]="Tree purchased/capacity: "..str(tree.purchased).."/"..str(tree.capacity)
        local native=tree.accountingPolicy=="native-rank-reconciled-v1"
        if native then
            local e=tree.accountingEvidence or {}
            lines[#lines+1]="Native rank points / shared-spent reconciled; NOT verified future/all-rank costs"
            lines[#lines+1]="Shared currency "..str(e.currencyID)..": spent "..str(e.spent)..
                "; compared ONCE to profession total "..str(e.totalPurchased).."; quantity "..str(e.quantity).." (unspent shown separately)"
            lines[#lines+1]="Source pin: "..str(e.sourcePin)
        end
        local byID={}
        for _,p in ipairs(tree.paths or {}) do byID[p.id]=p end
        local seen={}
        local function visit(id,indent)
            if seen[id] or indent>64 then return end
            seen[id]=true
            local p=byID[id]
            if not p then lines[#lines+1]="Missing path "..str(id); return end
            local pathState=p.node and p.node.isAvailable==false and "locked" or "state unknown/available"
            if tree.compactSnapshot then
                pathState="lock="..str(p.locked).."; availability="..str(p.available).." (observed personal state)"
            elseif native then
                pathState=p.locked and ("locked; unlock token "..str(p.costs and p.costs[1] and p.costs[1].ID)..
                    " distinct from spend currency "..str(p.spendCurrencyID)) or ("spend-ready; spend currency "..str(p.spendCurrencyID))
            end
            lines[#lines+1]=string.rep(" ",indent).."Path "..id..": "..str(p.purchased).."/"..str(p.capacity).."; "..pathState
            for _,child in ipairs(p.children or {}) do visit(child,indent+1) end
        end
        visit(tree.root,0)
        lines[#lines+1]="Coverage: "..str(tree.coverage and tree.coverage.captured).." paths; complete="..str(tree.complete)
    elseif raw then
        lines[#lines+1]=raw.policy=="native-rank-reconciled-v1" and
            "Native total unknown: complete metadata, stable unstaged coverage and shared-spent reconciliation required" or
            "Numeric total unknown: committed costs/unlock/coverage eligibility required"
        for _,t in ipairs(raw.tabs or {}) do
            lines[#lines+1]="Tree "..str(t.id).."; root "..str(t.root).."; coverage="..str(t.coverageComplete)
            local ids={}; for id in pairs(t.paths or {}) do ids[#ids+1]=id end; table.sort(ids)
            for _,id in ipairs(ids) do
                local p=t.paths[id]; local n=p.node or {}
                lines[#lines+1]="Path "..id.." raw purchased="..str(n.ranksPurchased).." increased="..str(n.ranksIncreased)..
                    " current="..str(n.currentRank).." max="..str(n.maxRanks).." unlock="..str(p.unlock and p.unlock.maxRanks)..
                    "; cost="..str(p.costRule)
            end
        end
    end
    return lines
end

-- Player summaries are separate from the unchanged diagnostic evidence above.
local function freshness(state,now,archived)
    local age=V.Age(now,state.observedAt)
    if archived and not state.known then return "Archived snapshot; not observed." end
    if archived then return "Archived snapshot; last observed "..age.." ago." end
    if not state.known then return "Not observed." end
    if state.stale then return "Stale: refresh unavailable; last observed "..age.." ago." end
    if state.fresh then return "Current observation; observed "..age.." ago." end
    return "Observed "..age.." ago."
end
local function normalStatus(state,archived)
    if archived then return "Archived snapshot." end
    if not state.known then return "Observation unavailable." end
    if state.stale then return "Stale: refresh unavailable." end
end
local function withStatus(lines,state,archived)
    local status=normalStatus(state,archived)
    if status then lines[#lines+1]=status end
    return lines
end
local function bounded(lines)
    -- Reserve the final line for Dashboard's opt-in hint. Never trim source evidence.
    if #lines>15 then
        local count=#lines-14
        for i=#lines,15,-1 do lines[i]=nil end
        lines[15]=count.." more details available on Shift-hover."
    end
    return lines
end
local function statSummary(tool)
    local lines={"Tool stats"}
    if tool.empty or tool.state.lastStatus=="not_applicable" then
        lines[#lines+1]="No tool; stats not applicable."
    elseif not tool.value or tool.value.exists~=true then
        lines[#lines+1]="Tool stats not observed."
    else
        local keys={}
        for key in pairs(tool.value.stats or {}) do keys[#keys+1]=key end
        table.sort(keys)
        local amounts={}
        for _,key in ipairs(keys) do
            local map=D.statNames[key]
            amounts[#amounts+1]=(map and map[2] or "Unknown stat")..": "..str(tool.value.stats[key])
        end
        if #amounts>0 then lines[#lines+1]=table.concat(amounts,"; ") end
        if #keys==0 then lines[#lines+1]="Tool stats not observed." end
        lines[#lines+1]="Observed totals; base/enchant split unknown."
    end
    return lines
end
local function enchantSummary(tool)
    local lines={"Tool enchant"}
    local value=tool.value
    if tool.empty or tool.state.lastStatus=="not_applicable" then
        lines[#lines+1]="No tool; enchant not applicable."
    elseif not value or value.exists~=true or value.metadataReady==false then
        lines[#lines+1]="Enchant unknown; item data unavailable."
    else
        local enchant=value.enchant
        if enchant and enchant.status=="observed" and enchant.present==false then
            lines[#lines+1]="No enchant (confirmed)."
        elseif enchant and enchant.status=="observed" and enchant.present==true then
            local category=D.statCategories[enchant.category]
            lines[#lines+1]="Enchanted: "..(category and category[2] or "Unknown stat").."; amount/rank unknown."
        else lines[#lines+1]="Enchant unknown; not observed." end
        local count=0
        for _,line in ipairs(value.enchantLines or {}) do
            for _,key in ipairs({"leftText","rightText"}) do
                local text=line[key]
                if type(text)=="string" and text:match("%S") then
                    count=count+1
                    if count<=2 then lines[#lines+1]=text end
                end
            end
        end
        if count>2 then lines[#lines+1]=(count-2).." more enchant text lines on Shift-hover." end
    end
    return lines
end
local function treeSummary(tree,value,now,archived)
    local known=value and C.Integer(value.purchased) and C.Integer(value.capacity)
    local lines,missing={},false
    if value then
        local byID,seen={},{}
        for _,p in ipairs(value.paths or {}) do byID[p.id]=p end
        local function visit(id,depth)
            if seen[id] or depth>64 or #lines>=64 then return end
            seen[id]=true
            local p=byID[id]
            if not p then missing=true; lines[#lines+1]=string.rep("  ",depth).."Unknown branch: ?/?"; return end
            local name=type(p.name)=="string" and #p.name<=256 and p.name:match("%S") and
                not p.name:find("[%c|]") and p.name or "Unknown branch"
            local points=known and C.Integer(p.purchased) and C.Integer(p.capacity) and
                (p.purchased.."/"..p.capacity) or "?/?"
            lines[#lines+1]=string.rep("  ",depth)..name..": "..points
            for _,child in ipairs(p.children or {}) do visit(child,depth+1) end
        end
        visit(value.root,0)
    end
    if #lines==0 then lines[1]="Unknown branch: ?/?"; missing=true end
    local footer={}
    if missing or not known then footer[#footer+1]="Branch observations unavailable." end
    if archived then footer[#footer+1]="Archived"
    elseif tree.state.stale then footer[#footer+1]="Stale data" end
    if #footer>0 then lines[#lines+1]=table.concat(footer," ") end
    return lines
end

-- Continuous extrapolation is presentation only: it never becomes an observation.
function V.ConcentrationEstimate(value,observedAt,now)
    if type(value)~="table" or getmetatable(value)~=nil or
        not C.Integer(value.quantity,0) or not C.Integer(value.maxQuantity,1) or
        value.quantity>value.maxQuantity then return nil,"invalid observed amount/cap" end
    if not C.Integer(observedAt,0) or not C.Integer(now,0) or now<observedAt then
        return nil,"observation time or clock unavailable"
    end
    local cycle,amount=value.rechargingCycleDurationMS,value.rechargingAmountPerCycle
    if not C.Finite(cycle) or cycle<=0 or not C.Finite(amount) or amount<=0 then
        return nil,"recharge metadata unavailable"
    end
    local seconds=cycle/1000
    if not C.Finite(seconds) or seconds<=0 then return nil,"invalid recharge calculation" end
    local rate=amount/seconds
    local elapsed=now-observedAt
    if not C.Finite(rate) or rate<=0 or not C.Finite(elapsed) or elapsed<0 then
        return nil,"invalid recharge calculation"
    end
    local gap=value.maxQuantity-value.quantity
    local duration=gap/rate
    if not C.Finite(duration) or duration<0 or (gap>0 and duration==0) then
        return nil,"invalid recharge calculation"
    end
    local estimate,remaining=value.maxQuantity,0
    -- Compare before multiplication so a long offline interval cannot overflow.
    if elapsed<duration then
        local added=elapsed*rate
        if not C.Finite(added) or added<0 or (elapsed>0 and added==0) then
            return nil,"invalid recharge calculation"
        end
        local projected=value.quantity+added
        if not C.Finite(projected) then return nil,"invalid recharge calculation" end
        estimate=math.min(value.maxQuantity,projected)
        remaining=(value.maxQuantity-estimate)/rate
        if not C.Finite(estimate) or not C.Finite(remaining) or remaining<0 or
            (estimate<value.maxQuantity and remaining==0) then return nil,"invalid recharge calculation" end
    end
    return {quantity=math.floor(estimate),maxQuantity=value.maxQuantity,secondsToFull=remaining}
end
local function fullTime(seconds)
    local minutes=seconds>0 and math.max(1,math.ceil(seconds/60)) or 0
    local days=math.floor(minutes/1440)
    local hours=math.floor((minutes%1440)/60)
    local rest=minutes%60
    if days>0 then return string.format("%.0fd %.0fh %.0fm",days,hours,rest) end
    if hours>0 then return string.format("%.0fh %.0fm",hours,rest) end
    return string.format("%.0fm",rest)
end
function V.ConcentrationTooltip(row,now)
    local cached=row.cellTooltips[I.Concentration]
    local lines=withStatus({cached[1]},row.concentrationState,row.archived)
    local estimate,why
    if row.archived then why="archived snapshot"
    else estimate,why=V.ConcentrationEstimate(row.concentrationValue,row.concentrationState.observedAt,now) end
    if estimate then
        lines[#lines+1]="Estimated now: ~"..str(estimate.quantity).."/"..str(estimate.maxQuantity)
        lines[#lines+1]="Estimated full in: "..fullTime(estimate.secondsToFull)
    else lines[#lines+1]="Estimate unavailable: "..why.."." end
    return lines
end

function V.Row(guid,c,id,g,session,now,archived)
    if archived then session=nil end
    local row={guid=guid,id=id,generation=g.generation,archived=archived==true, name=c.name,realm=c.realm,classToken=c.classToken,
        profession=g.identity.name or D.families[g.identity.profession] or tostring(id),professionFamily=g.identity.profession,
        cells={},warnings={},trees={},known=0}
    row.key=guid..":"..id..":"..g.generation
    local details,states={},{}
    local function field(key)
        local v,s=V.Field(g,key,session)
        states[key]=s
        if s.known then row.known=row.known+1 end
        details[#details+1]=s.text
        return v,s
    end
    local skill,ss=field("skill")
    for key,f in pairs(g.fields) do
        if key:match("^slot%d+$") and f.last and type(f.last.value)=="table" then
            local unknown=f.last.value
            details[#details+1]="Unmapped slot "..str(unknown.slot).." (role unknown); existence="..str(unknown.exists)..
                "; rarity="..str(unknown.rarity).."; crafted rank="..str(unknown.rank)
        end
    end
    row.skill=skill; row.skillState=ss
    row.cells[I.Name]=c.name; row.cells[I.Realm]=c.realm; row.cells[I.Profession]=row.profession
    row.cells[I.Skill]=skill and (str(skill.skillLevel).."/"..str(skill.maxSkillLevel)) or "?"
    row.gear={}
    for i,role in ipairs(V.roles) do
        local value,state=field(role)
        row.gear[role]=(role=="tool" and V.Tool or V.Gear)(value,state)
        row.cells[({I.Accessory1,I.Accessory2,I.Tool})[i]]=row.gear[role].text
    end
    local tool=row.gear.tool
    row.cells[I.Stat]=tool.statsText; row.cells[I.Enchant]=tool.enchantText
    local conc,cs=field("concentration"); local mox,ms=field("moxie")
    row.concentrationValue=conc; row.concentrationState=cs; row.moxieState=ms
    row.concentration=conc and conc.quantity; row.moxie=mox and mox.quantity
    row.cells[I.Concentration]=conc and C.Integer(conc.quantity,0) and
        (str(conc.quantity).."/"..(C.Integer(conc.maxQuantity,1) and str(conc.maxQuantity) or "?")) or "?"
    row.cells[I.Moxie]=mox and str(mox.quantity) or "?"
    local function warning(category,condition,state)
        if condition and not archived then
            row.warnings[#row.warnings+1]={category=category,fresh=state.fresh,
                label=(state.fresh and "confirmed " or "last observed ")..category}
        end
    end
    warning("Moxie",mox and number(mox.quantity) and mox.quantity>600,ms)
    warning("Concentration",conc and number(conc.quantity) and number(conc.maxQuantity) and
        conc.maxQuantity>0 and conc.quantity>=conc.maxQuantity*0.9,cs)
    if tool.enchant then row.enchantMissing=tool.enchant.present==false end
    warning("Missing enchant",row.enchantMissing,tool.state)
    local index=field("knowledgeIndex")
    local raw=field("knowledgeRaw")
    local incomplete,progressFresh,progressKnown=false,false,false
    if skill and number(skill.skillLevel) and number(skill.maxSkillLevel) and skill.maxSkillLevel>0 then
        progressKnown=true; incomplete=skill.skillLevel<skill.maxSkillLevel
        progressFresh=incomplete and ss.fresh
        row.progression=skill.skillLevel/skill.maxSkillLevel
    end
    for _,t in ipairs(index or {}) do
        local value,state=field("tree:"..t.id)
        local tree={id=t.id,name=t.name or tostring(t.id),state=state}
        if state.stale and value and type(value.name)=="string" then tree.name=value.name end
        tree.shortName=tree.name:gsub("%s+",""):sub(1,3)
        if value and C.Integer(value.purchased) and C.Integer(value.capacity) and value.capacity>0 then
            tree.purchased=value.purchased; tree.capacity=value.capacity; tree.ratio=value.purchased/value.capacity
            progressKnown=true
            if tree.purchased<tree.capacity then incomplete=true; progressFresh=progressFresh or state.fresh end
        end
        tree.tooltip=treeDetail(value,raw,state.observedAt,state)
        table.insert(tree.tooltip,1,tree.name)
        tree.summaryTooltip=treeSummary(tree,value,now,archived)
        tree.aggregateText=value and C.Integer(value.purchased) and C.Integer(value.capacity) and
            (value.purchased.."/"..value.capacity) or "?/?"
        row.trees[#row.trees+1]=tree
    end
    if progressKnown then row.progressionIncomplete=incomplete end
    warning("Progression",incomplete,{fresh=progressFresh})
    row.cells[I.Knowledge]=#row.trees==0 and "?" or "" -- Native inline bars render here.
    local unspent,us=field("unspent"); row.cells[I.Unspent]=str(unspent); row.unspent=unspent
    local hasFresh=false
    for _,s in ipairs({ss,cs,ms,us,tool.state}) do if s.fresh then hasFresh=true end end
    row.snapshot=(hasFresh and not archived and "read " or "snapshot ")..V.Age(now,g.scannedAt)
    if archived then row.snapshot="archived "..V.Age(now,g.archivedAt) end
    local stale=false
    for _,f in pairs(g.fields) do
        if f.last and f.attempt.status~="observed" and f.attempt.status~="empty" and
            f.attempt.status~="not_applicable" then stale=true end
    end
    if stale then row.snapshot=row.snapshot.." stale" end
    row.lastUpdated=V.Age(now,g.scannedAt); row.cells[I.LastUpdated]=row.lastUpdated
    details[#details+1]="Snapshot context: "..row.snapshot.."; fields have independent observation times"
    details[#details+1]="Skill modifier: "..str(skill and skill.skillModifier)
    details[#details+1]="Generation "..g.generation.."; scan timestamp "..str(g.scannedAt)
    if archived then details[#details+1]="Archived "..str(g.archivedAt)..": "..str(g.archiveReason) end
    row.tooltip=details
    for _,w in ipairs(row.warnings) do
        details[#details+1]=w.label
        if w.category=="Missing enchant" then
            row.enchantAttention=true; tool.tooltip[#tool.tooltip+1]=w.label
        end
    end
    row.priority=row.known>0 and 3 or 4
    for _,w in ipairs(row.warnings) do row.priority=math.min(row.priority,w.fresh and 1 or 2) end
    row.cellTooltips={}
    local summaries=row.cellTooltips
    local identity={row.name,row.realm,row.profession}
    summaries[I.Name]=identity; summaries[I.Realm]=identity; summaries[I.Profession]=identity
    summaries[I.Skill]=withStatus({"Profession skill: "..(skill and (str(skill.skillLevel).."/"..str(skill.maxSkillLevel)) or "Not observed"),
        "Skill modifier: "..str(skill and skill.skillModifier)},ss,archived)
    for _,entry in ipairs({{I.Concentration,"Concentration",conc,cs},{I.Moxie,"Moxie",mox,ms}}) do
        local value=entry[3]
        summaries[entry[1]]=withStatus({entry[2]..": "..(value and (str(value.quantity)..
            (value.maxQuantity~=nil and ("/"..str(value.maxQuantity)) or "")) or "Not observed")},entry[4],archived)
    end
    summaries[I.Unspent]=withStatus({"Unspent knowledge: "..(us.known and str(unspent) or "Not observed")},us,archived)
    summaries[I.LastUpdated]={"Last scan: "..row.lastUpdated.." ago.",
        archived and "Archived snapshot." or (stale and "Stale snapshot; refresh unavailable." or
        (hasFresh and "Current guarded observations." or "Saved snapshot; not a current read.")),
        "Fields may have independent observation times."}
    summaries[I.Knowledge]=withStatus({"Knowledge trees: "..#row.trees,"Unspent knowledge is shown separately."},
        states.knowledgeIndex,archived)
    if #row.trees==0 then summaries[I.Knowledge][#summaries[I.Knowledge]+1]="Tree observations unavailable." end
    for _,tree in ipairs(row.trees) do
        local status=normalStatus(tree.state,archived)
        summaries[I.Knowledge][#summaries[I.Knowledge]+1]=tree.name..": "..
            tree.aggregateText..(status and ("; "..status) or "")
    end
    for _,role in ipairs(V.roles) do
        local gear=row.gear[role]
        local lines={({accessory1="Accessory #1",accessory2="Accessory #2",tool="Tool"})[role],freshness(gear.state,now,archived)}
        if gear.state.lastStatus=="not_applicable" then lines[#lines+1]="Not applicable."
        elseif gear.empty then lines[#lines+1]="Empty slot (confirmed)."
        elseif gear.exists~=true then lines[#lines+1]="Item unknown; data unavailable."
        else
            lines[#lines+1]="Rarity: "..(({[0]="Poor",[1]="Common",[2]="Uncommon",[3]="Rare",[4]="Epic",[5]="Legendary"})[gear.rarity] or "Unknown")
            lines[#lines+1]="Crafted quality: "..(C.Integer(gear.rank,1) and gear.rank<=5 and gear.rank or "Unknown")
        end
        local value=gear.value
        if value and gear.exists==true then
            local expansion=value.itemExpansion
            local itemExpansion=expansion and expansion.value
            gear.olderExpansion=C.Integer(itemExpansion) and itemExpansion<g.identity.expansionID or false
            gear.borderColor=gear.olderExpansion and {.90,.15,.15} or gear.rarityColor
            local function metadataLine(title,unit,description)
                local line=title..": "..description
                if unit and unit.value~=nil then
                    line=line.."; last observed "..V.Age(now,unit.observedAt).." ago"
                    if unit.status~="observed" then line=line.."; retained after "..unit.status.." metadata attempt ("..V.Age(now,unit.attemptedAt).." ago)" end
                    gear.tooltip[#gear.tooltip+1]=title.." source "..unit.source.."; observed "..str(unit.observedAt).."; attempted "..str(unit.attemptedAt).."; status "..unit.status
                end
                lines[#lines+1]=line; gear.tooltip[#gear.tooltip+1]=line
            end
            metadataLine("Item expansion",expansion,itemExpansion~=nil and (tostring(itemExpansion)..
                (gear.olderExpansion and " (older)" or itemExpansion==g.identity.expansionID and " (current)" or " (future)")) or "unknown")
            if role=="tool" then
                metadataLine("Tool's own stat",value.toolStat,value.toolStat and value.toolStat.value or "unavailable")
            else
                local enchant=value.enchant
                local category=enchant and D.statCategories[enchant.category]
                local detail=enchant and enchant.status=="observed" and
                    (enchant.present and ("yes; "..(category and category[2] or "category unknown")) or "no (confirmed)") or "unknown"
                lines[#lines+1]="Enchant: "..detail; gear.tooltip[#gear.tooltip+1]="Enchant: "..detail
            end
        end
        if role=="tool" then
            summaries[I.Stat]=statSummary(gear); summaries[I.Enchant]=enchantSummary(gear)
            for _,col in ipairs({I.Stat,I.Enchant}) do
                summaries[col][#summaries[col]+1]=freshness(gear.state,now,archived)
                for n=2,#summaries[col]-1 do lines[#lines+1]=summaries[col][n] end
            end
            for _,w in ipairs(row.warnings) do
                if w.category=="Missing enchant" then lines[#lines+1]="Attention: "..w.label end
            end
        end
        -- Preserve every generated addon summary line in diagnostics, without
        -- duplicating metadata lines already emitted there. Native item contents
        -- are never inspected or rebuilt here.
        local present={}
        for _,line in ipairs(gear.tooltip) do present[line]=true end
        for _,line in ipairs(lines) do
            if not present[line] then gear.tooltip[#gear.tooltip+1]=line; present[line]=true end
        end
        if gear.state.lastStatus=="not_applicable" then gear.summaryTooltip={"Not applicable."}; gear.link=nil
        elseif gear.empty then gear.summaryTooltip={"Empty slot (confirmed)."}; gear.link=nil
        elseif gear.exists~=true then gear.summaryTooltip={"Item unknown; data unavailable."}; gear.link=nil
        elseif type(gear.link)=="string" and #gear.link>0 then gear.summaryTooltip={}
        else gear.summaryTooltip={"Item link unavailable."}; gear.link=nil end
    end
    for _,lines in pairs(summaries) do bounded(lines) end
    -- Presentation-only typed keys. Never compare warning markup/age strings or
    -- borrow raw Knowledge/skill progression as evidence of displayed tree totals.
    local keys={[I.Name]=row.name:lower(),[I.Realm]=row.realm:lower(),[I.Profession]=row.profession:lower()}
    local function numeric(column,value) if number(value) then keys[column]=value end end
    numeric(I.Skill,skill and skill.skillLevel)
    numeric(I.Concentration,row.concentration); numeric(I.Moxie,row.moxie)
    numeric(I.Unspent,unspent); numeric(I.LastUpdated,g.scannedAt)
    for n,role in ipairs(V.roles) do
        local gear=row.gear[role]
        if gear.empty then keys[I.Accessory1+n-1]=-1
        elseif gear.exists==true and C.Integer(gear.rarity) and C.Integer(gear.rank,1) and gear.rank<=5 then
            keys[I.Accessory1+n-1]=gear.rarity*10+gear.rank
        end
    end
    for column,value in pairs({[I.Stat]=tool.statsText,[I.Enchant]=tool.enchantText}) do
        if not value:find("?",1,true) then keys[column]=value:lower() end
    end
    local purchased,capacity,complete=0,0,#row.trees>0
    for _,tree in ipairs(row.trees) do
        if tree.purchased==nil or tree.capacity==nil then complete=false
        else purchased=purchased+tree.purchased; capacity=capacity+tree.capacity end
    end
    if complete and capacity>0 then keys[I.Knowledge]=purchased/capacity end
    row.sortValues=keys
    return row
end

-- Keep the legacy selector stable, but its membership now means saved Skill below
-- a usable observed cap, independently of combined Skill/Knowledge warnings.
local function attentionMatches(row,category)
    if not category or category=="All" then return true end
    if row.archived then return false end
    if category=="Progression" then
        local skill=row.skill
        return type(skill)=="table" and C.Integer(skill.skillLevel,0) and
            C.Integer(skill.maxSkillLevel,1) and skill.skillLevel<skill.maxSkillLevel
    end
    for _,w in ipairs(row.warnings) do if w.category==category then return true end end
    return false
end

function V.Build(db,sessions,options,now)
    local rows={}; options=options or {}; sessions=sessions or {}
    local player=currentGUID(options.currentPlayerGUID)
    if not db then return rows end
    if NS.Storage.IsHandle(db) then return rows,"Storage dashboard build pending; use the incremental build job." end
    local valid,why=C.Open(db)
    if not valid then return rows,why end
    local function include(row)
        if options.character and options.character~="" and not
            (row.name:lower():find(options.character:lower(),1,true) or row.realm:lower():find(options.character:lower(),1,true) or
                (row.name.."-"..row.realm):lower():find(options.character:lower(),1,true) or row.guid==options.character) then return end
        if options.professionFamily~=nil and options.professionFamily~=row.professionFamily then return end
        if options.profession and options.profession~="" and not
            (row.profession:lower():find(options.profession:lower(),1,true) or tostring(row.id)==options.profession) then return end
        if not attentionMatches(row,options.attention) then return end
        row.isCurrentCharacter=player==row.guid and true or nil
        rows[#rows+1]=row
    end
    for guid,c in pairs(db.characters) do
        for id,p in pairs(c.professions) do
            if options.archived then
                for _,g in ipairs(p.archives) do include(V.Row(guid,c,id,g,nil,now,true)) end
            elseif p.active then include(V.Row(guid,c,id,p.active,sessions[guid..":"..id],now,false)) end
        end
    end
    table.sort(rows,function(a,b)
        if a.isCurrentCharacter~=b.isCurrentCharacter then return a.isCurrentCharacter==true end
        local mode=options.sort
        local column=options.sortColumn
        if C.Integer(column,1) and column<=#V.columns then
            local av,bv=a.sortValues[column],b.sortValues[column]
            if av==nil and bv~=nil then return false elseif av~=nil and bv==nil then return true end
            if av~=bv then
                if options.sortDescending==true then return av>bv end
                return av<bv
            end
        elseif mode=="concentration" or mode=="moxie" or mode=="enchant" or mode=="progression" then
            local key=mode=="enchant" and "enchantMissing" or mode
            local av,bv=a[key],b[key]
            if av==nil and bv~=nil then return false elseif av~=nil and bv==nil then return true end
            if av~=bv then
                if mode=="enchant" then return av==true end
                if mode=="progression" then return av<bv end
                return av>bv
            end
        elseif a.priority~=b.priority then return a.priority<b.priority end
        if a.guid~=b.guid then return a.guid<b.guid end
        if a.id~=b.id then return a.id<b.id end
        return a.generation<b.generation
    end)
    return rows
end

-- Schema2 never drains an account iterator/sort on the caller's stack. Legacy
-- Build above deliberately remains synchronous for actual schema1 callers.
function V.NewBuildJob(db,sessions,options,now)
    local S=NS.Storage
    local job={status="running",completed=false,steps=0,phase="freshness",work={rows=0,operations=0,maxOperations=0}}
    local rows,buffer,iterator,opts,fresh,revision,busy={},{},nil,nil,nil,nil,false
    local width,left,i,j,mid,right,out=1,1
    local sourceFresh,freshCursor,verifyCursor,freshCount,verifiedCount=nil,nil,nil,0,0
    local function equal(a,b)
        if type(a)~=type(b) then return false end
        if type(a)~="table" then return a==b end
        for k,v in pairs(a) do if not equal(v,b[k]) then return false end end
        for k in pairs(b) do if a[k]==nil then return false end end
        return true
    end
    local function stop(status,why)
        job.status=status; job.reason=why; job.completed=status=="complete"
        if status~="complete" then job.rows=nil end
        if iterator and iterator.status=="running" then iterator:Cancel() end
        rows=nil; buffer=nil; iterator=nil; opts=nil; fresh=nil; sourceFresh=nil
        return job
    end
    function job:Cancel() if self.status=="running" then stop("cancelled","Dashboard build cancelled") end; return self end
    local ok=pcall(function()
        assert(S.IsHandle(db) and S.Check(db),"Ready storage required")
        opts=assert(C.Copy(options or {})); sourceFresh=sessions or {}; fresh={}; revision=S.Revision(db)
        assert(type(opts)=="table" and type(sourceFresh)=="table" and getmetatable(sourceFresh)==nil,"Invalid build inputs")
        iterator=S.NewIterator(db,opts.archived==true)
        assert(iterator.status=="running","Iterator unavailable")
    end)
    if not ok then return stop("failed","Dashboard build setup failed") end
    local function include(row)
        if opts.character and opts.character~="" and not
            (row.name:lower():find(opts.character:lower(),1,true) or row.realm:lower():find(opts.character:lower(),1,true) or
             (row.name.."-"..row.realm):lower():find(opts.character:lower(),1,true) or row.guid==opts.character) then return false end
        if opts.professionFamily~=nil and opts.professionFamily~=row.professionFamily then return false end
        if opts.profession and opts.profession~="" and not
            (row.profession:lower():find(opts.profession:lower(),1,true) or tostring(row.id)==opts.profession) then return false end
        if not attentionMatches(row,opts.attention) then return false end
        row.isCurrentCharacter=currentGUID(opts.currentPlayerGUID)==row.guid and true or nil
        return true
    end
    -- Same comparison rules as the schema1 Build, including unknowns last in both
    -- directions and the deterministic generation tie-break.
    local function less(a,b)
        if a.isCurrentCharacter~=b.isCurrentCharacter then return a.isCurrentCharacter==true end
        local mode,column=opts.sort,opts.sortColumn
        if C.Integer(column,1) and column<=#V.columns then
            local av,bv=a.sortValues[column],b.sortValues[column]
            if av==nil and bv~=nil then return false elseif av~=nil and bv==nil then return true end
            if av~=bv then if opts.sortDescending==true then return av>bv end; return av<bv end
        elseif mode=="concentration" or mode=="moxie" or mode=="enchant" or mode=="progression" then
            local key=mode=="enchant" and "enchantMissing" or mode
            local av,bv=a[key],b[key]
            if av==nil and bv~=nil then return false elseif av~=nil and bv==nil then return true end
            if av~=bv then
                if mode=="enchant" then return av==true end
                if mode=="progression" then return av<bv end
                return av>bv
            end
        elseif a.priority~=b.priority then return a.priority<b.priority end
        if a.guid~=b.guid then return a.guid<b.guid end
        if a.id~=b.id then return a.id<b.id end
        return a.generation<b.generation
    end
    function job:Step()
        if self.status~="running" then return self end
        if busy then return stop("failed","Reentrant dashboard build") end
        busy=true; self.steps=self.steps+1
        local ok=pcall(function()
            assert(S.Revision(db)==revision,"Storage revision changed")
            if self.phase=="freshness" then
                local key,value=next(sourceFresh,freshCursor)
                if key==nil then self.phase="rows"; return end
                assert(type(key)=="string" and #key<=4096,"Invalid freshness key")
                freshCursor=key; fresh[key]=assert(C.Copy(value)); freshCount=freshCount+1; return
            end
            if self.phase=="verify-freshness" then
                local key,value=next(sourceFresh,verifyCursor)
                if key==nil then
                    assert(freshCount==verifiedCount,"Freshness directory changed")
                    self.rows=rows; stop("complete"); return
                end
                verifyCursor=key; verifiedCount=verifiedCount+1
                assert(fresh[key]~=nil and equal(fresh[key],assert(C.Copy(value))),"Freshness changed")
                return
            end
            if self.phase=="rows" then
                iterator:Step()
                assert(iterator.status=="running" or iterator.status=="complete","Iterator failed")
                local item=iterator.item
                if item then
                    local session=not item.archived and fresh[item.guid..":"..item.id]
                    local row=V.Row(item.guid,item.c,item.id,item.g,session and assert(C.Copy(session)),now,item.archived)
                    self.work.rows=self.work.rows+1
                    if include(row) then rows[#rows+1]=row end
                end
                if iterator.status=="complete" then self.phase="sort" end
                return
            end
            local operations=0
            while operations<128 do
                if width>=#rows then
                    self.phase="verify-freshness"; break
                end
                if not i then
                    mid=math.min(left+width-1,#rows); right=math.min(left+2*width-1,#rows)
                    i=left; j=mid+1; out=left
                end
                if out>right then
                    left=left+2*width; i=nil
                    if left>#rows then rows,buffer=buffer,rows; width=width*2; left=1 end
                else
                    local takeLeft
                    if i>mid then takeLeft=false elseif j>right then takeLeft=true
                    else
                        if operations>=127 then break end
                        takeLeft=not less(rows[j],rows[i]); operations=operations+1
                    end
                    if takeLeft then buffer[out]=rows[i]; i=i+1 else buffer[out]=rows[j]; j=j+1 end
                    out=out+1; operations=operations+1
                end
            end
            self.work.operations=self.work.operations+operations
            self.work.maxOperations=math.max(self.work.maxOperations,operations)
        end)
        busy=false
        if not ok and self.status=="running" then stop("failed","Dashboard build rejected; saved data retained") end
        if self.status=="failed" or self.status=="cancelled" then stop(self.status,self.reason) end
        return self
    end
    return job
end
