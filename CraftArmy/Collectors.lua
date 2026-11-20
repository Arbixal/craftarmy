local _, NS = ...
local C, D, K = NS.Core, NS.Data, NS.Knowledge
local S = NS.Storage
local Collectors = {}
NS.Collectors = Collectors

function Collectors.Resolve(env, path)
    local v=env
    for key in path:gmatch("[^.]+") do
        if type(v) ~= "table" then return nil end
        v=v[key]
    end
    return v
end
function Collectors.Call(env, path, ...)
    local fn=Collectors.Resolve(env,path)
    if type(fn) ~= "function" then return nil, "unsupported", path.." unavailable" end
    local ok, value=pcall(fn,...)
    if not ok then return nil, "error", path..": "..tostring(value) end
    if value == nil then return nil, "unknown", path.." returned nil" end
    return value, "observed"
end
local function pick(t, keys)
    if type(t) ~= "table" then return nil end
    local out={}
    for key in keys:gmatch("%S+") do
        local v=t[key]
        if type(v)=="string" or type(v)=="boolean" or C.Finite(v) then out[key]=v end
    end
    return out
end
local function list(t, limit)
    if type(t) ~= "table" then return nil, false end
    local out, complete={}, #t<=limit
    for i=1,math.min(#t,limit) do
        if C.Integer(t[i],1) then out[#out+1]=t[i] else complete=false end
    end
    -- Sparse or keyed ID lists are not a complete array.
    for k in pairs(t) do if not C.Integer(k,1) or k>#t then complete=false end end
    return out, complete
end

function Collectors.Enchant(link, typedPositive, ready)
    if ready ~= true or type(link) ~= "string" then return {status="unknown", reason="instance link unready"} end
    local item, raw=link:match("item:(%d+):(%d*):")
    local id=raw=="" and 0 or tonumber(raw)
    if not item or not C.Integer(id) then return {status="unknown", reason="invalid/missing enchant field"} end
    if id==0 and typedPositive==true then return {status="unknown", reason="link/typed-line conflict"} end
    if id>0 then
        return {status="observed", present=true, id=id,
            category=D.enchants[id] and D.enchants[id].category or nil}
    end
    return {status="observed", present=false, id=0}
end

-- Read-only query payload: retain ALL crafted/bonus/suffix fields, replacing only
-- the permanent enchant. Never return this synthetic payload as equipped evidence.
function Collectors.ToolStatLink(link)
    if type(link)~="string" or #link>4096 or link:find("%c") then return nil end
    local payload=link
    if link:sub(1,5)~="item:" then
        local body=link:match("^|c%x%x%x%x%x%x%x%x(.*)|r$") or
            link:match("^|cnIQ%d+:?(.*)|r$") or link
        -- The display label is opaque: crafted names can contain atlas/texture/color
        -- markup. Only one anchored hyperlink is accepted, and only its item payload
        -- reaches the query; nested headers/delimiters cannot hide another link.
        local label
        payload,label=body:match("^|H(item:[^|]+)|h(.*)|h$")
        if label and label:find("|[Hh]") then return nil end
    end
    if not payload then return nil end
    local prefix,enchant,rest=payload:match("^(item:%d+:)(%d*)(:.*)$")
    local id=tonumber(payload:match("^item:(%d+):"))
    if not prefix or not C.Integer(id,1) or id>2147483647 or
        (enchant~="" and (not C.Integer(tonumber(enchant)) or tonumber(enchant)>2147483647)) or
        rest:find("[^A-Za-z0-9:%-]") or rest:find("item:",1,true) then return nil end
    return prefix.."0"..rest
end

local function optionalGear(env,link,itemID,role,at)
    if not C.Integer(at) then return nil,nil end
    local function unit(source,status,value)
        if value==nil and status=="observed" then status="unknown" end
        -- MergeEquipment omits valueless attempts with no history. Keeping the
        -- typed failure here lets same-instance history retain the actual status.
        return {status=status,attemptedAt=at,source=source,value=value,observedAt=value~=nil and at or nil}
    end
    local ok,returned,expansion,infoStatus=pcall(function()
        local fn=Collectors.Resolve(env,"C_Item.GetItemInfo")
        if type(fn)~="function" then return nil,nil,"unsupported" end
        local _,returned,_,_,_,_,_,_,_,_,_,_,_,_,expansion=fn(link)
        return returned,expansion,"observed"
    end)
    local normalized=ok and Collectors.ToolStatLink(returned)
    local returnedID=normalized and tonumber(normalized:match("^item:(%d+):"))
    local expansionStatus=not ok and "error" or infoStatus=="unsupported" and "unsupported" or "unknown"
    local validExpansion=returnedID==itemID and C.Integer(expansion) and expansion<=2147483647
    local expansionUnit=unit("C_Item.GetItemInfo",validExpansion and "observed" or expansionStatus,returnedID==itemID and
        C.Integer(expansion) and expansion<=2147483647 and expansion or nil)
    local toolUnit
    local neutral=role=="tool" and Collectors.ToolStatLink(link)
    if neutral then
        local good,stats,status=pcall(function()
            local fn=Collectors.Resolve(env,"C_Item.GetItemStats")
            if type(fn)=="function" then return fn(neutral),"unknown" end
            return nil,"unsupported"
        end)
        toolUnit=unit("C_Item.GetItemStats:unenchant-link-v1",good and status or "error")
        if good and type(stats)=="table" and getmetatable(stats)==nil then
            local valid,count,positive,category=true,0,0,nil
            for key,n in next,stats do
                count=count+1
                if count>32 then valid=false; break end
                if type(key)~="string" or #key>128 or not key:match("^ITEM_MOD_[A-Z0-9_]+$") or not C.Finite(n) then
                    valid=false; break
                end
                if D.statNames[key] and n>0 then positive=positive+1; category=D.statNames[key][2] end
            end
            if valid and positive==1 then toolUnit=unit("C_Item.GetItemStats:unenchant-link-v1","observed",category) end
        end
    elseif role=="tool" then
        toolUnit=unit("C_Item.GetItemStats:unenchant-link-v1","unknown")
    end
    return expansionUnit,toolUnit
end

-- Knowledge-only projection: bounded inspection, plain typed output, no API error
-- payloads. A valid prefix is evidence, never a claim that its source was complete.
local MAX=2147483647
local function knInt(v,low) return C.Integer(v,low or 0) and v<=MAX end
local function knPlain(v) return type(v)=="table" and getmetatable(v)==nil end
local function knRead(env,path,...)
    local fn=Collectors.Resolve(env,path)
    if type(fn)~="function" then return nil,"unsupported" end
    local ok,v=pcall(fn,...)
    if not ok then return nil,"error" end
    if v==nil then return nil,"unknown" end
    return v,"observed"
end
local function knArray(raw,limit,project)
    local out,seen={},{}
    if not knPlain(raw) then return out,false,"unavailable/malformed list" end
    local key,count,maxIndex=nil,0,0
    local complete=true
    while true do
        key=next(raw,key); if key==nil then break end
        count=count+1
        if count>limit then complete=false; break end
        if not knInt(key,1) or key>limit then complete=false
        elseif key>maxIndex then maxIndex=key end
    end
    for i=1,limit do
        local v=rawget(raw,i)
        if v==nil then if i<=maxIndex then complete=false end
        else
            local item,valid,id=project(v)
            if not valid then complete=false end
            local duplicate=id and seen[id]
            if duplicate then complete=false end
            if id then seen[id]=true end
            if item~=nil and not duplicate then out[#out+1]=item end
        end
    end
    return out,complete,complete and "observed" or "incomplete list"
end
local function knIDs(raw,limit)
    return knArray(raw,limit,function(v)
        local valid=knInt(v,1); return valid and v or nil,valid,valid and v or nil
    end)
end
-- P02: P01's strict skill/slot safeguards are independent of Moxie activation.
-- Call only after the exact identity/capability registry has validated the tuple.
local function expansionSafeguards(identity)
    local id=identity.skillLineID
    return id==2912 or id==2916 or id==2917 or id==2908 or id==2911
end
local function knCosts(raw)
    return knArray(raw,16,function(v)
        if not knPlain(v) or not knInt(v.ID,1) or not knInt(v.amount) then return nil,false end
        return {ID=v.ID,amount=v.amount},true,v.ID
    end)
end
local function knNumbers(raw,out,names)
    local complete=knPlain(raw)
    for key in names:gmatch("%S+") do
        local v=knPlain(raw) and rawget(raw,key)
        if knInt(v,key=="ID" and 1 or 0) then out[key]=v else complete=false end
    end
    return complete
end
local function knNode(raw)
    if not knPlain(raw) then return nil,false end
    local n={}
    local complete=knNumbers(raw,n,"ID type flags currentRank activeRank ranksPurchased ranksIncreased maxRanks totalMaxRanks")
    if type(raw.isAvailable)=="boolean" then n.isAvailable=raw.isAvailable else complete=false end
    for _,key in ipairs({"activeEntry","nextEntry"}) do
        local v=rawget(raw,key)
        if v~=nil then
            if knPlain(v) and knInt(v.entryID,1) and knInt(v.rank) then n[key]={entryID=v.entryID,rank=v.rank}
            else complete=false end
        end
    end
    for _,key in ipairs({"entryIDs","entryIDsWithCommittedRanks"}) do
        local valid; n[key],valid=knIDs(rawget(raw,key),32)
        if not valid then complete=false end
    end
    n.entryIDToRanksIncreased={}
    local map=rawget(raw,"entryIDToRanksIncreased")
    if not knPlain(map) then complete=false else
        local key,count=nil,0
        while true do
            local value; key,value=next(map,key); if key==nil then break end
            count=count+1; if count>32 then complete=false; break end
            if knInt(key,1) and knInt(value) then n.entryIDToRanksIncreased[key]=value else complete=false end
        end
    end
    return n,complete
end
local function knEntry(env,config,id)
    if not knInt(id,1) then return nil,false end
    local raw=knRead(env,"C_Traits.GetEntryInfo",config,id)
    if not knPlain(raw) then return nil,false end
    local e={}
    local complete=knNumbers(raw,e,"type maxRanks")
    local definitionID=rawget(raw,"definitionID")
    if knInt(definitionID,1) then e.definitionID=definitionID end
    e.entryCost,e.entryCostComplete=knCosts(rawget(raw,"entryCost"))
    return e,complete and e.entryCostComplete
end
local function knName(value)
    if type(value)~="string" then return nil end
    value=value:gsub("[%c|]"," "):match("^%s*(.-)%s*$")
    if #value>0 and #value<=256 then return value end
end
local function knPathName(env,p)
    local active=p.node and p.node.activeEntry
    local entry
    if active and active.entryID==p.unlockEntryID then entry=p.unlock
    elseif active and active.entryID==p.spendEntryID then entry=p.spend end
    if not entry or not knInt(entry.definitionID,1) then return nil end
    local definition=knRead(env,"C_Traits.GetDefinitionInfo",entry.definitionID)
    if not knPlain(definition) then return nil end
    local name=knName(rawget(definition,"overrideName"))
    if name then return name end
    local spellID=rawget(definition,"spellID")
    if knInt(spellID,1) then return knName(knRead(env,"C_Spell.GetSpellName",spellID)) end
end

function Collectors.New(env, db, changed)
    local self={env=env, db=db, revision=0, serial=0, fresh={}, pending={},
        reason="Log into each alt and open its profession.", changed=changed or function() end}
    local knowledgeSource
    -- R03: runtime-only transition evidence, not freshness or saved observations.
    local dashboardHandoff,dashboardScheduled
    local function publishHandoff(kind,token)
        if token then
            local session=self.fresh[token.guid..":"..token.id]
            if token.serial~=self.serial or token.revision~=self.revision or
                not session or session.generation~=token.generation then
                dashboardHandoff=nil; return
            end
        end
        dashboardHandoff={kind=kind,db=self.db,fresh=self.fresh,serial=self.serial,
            revision=self.revision,storeRevision=S.Revision(self.db),
            guid=token and token.guid,id=token and token.id,generation=token and token.generation}
    end
    function self:DashboardHandoff() return dashboardHandoff end
    local function call(path, ...) return Collectors.Call(env,path,...) end
    function self:Now()
        local at=call("GetServerTime")
        if C.Integer(at) then return at end
        return nil
    end
    function self:Invalidate(reason)
        dashboardHandoff=nil
        knowledgeSource=nil
        self.revision=self.revision+1; self.fresh={}; self.pending={}
        self.reason=reason or "Snapshot invalidated; open your profession and refresh."
    end
    function self:Character()
        local guid=call("UnitGUID","player")
        local name=call("UnitName","player")
        local realm=call("GetRealmName")
        if type(guid)~="string" or guid=="" or type(name)~="string" or type(realm)~="string" then return nil end
        local character={guid=guid,name=name,realm=realm}
        -- Optional own-player metadata only. Failed reads/validation never erase a
        -- same-GUID saved token or prevent the existing guarded generic scan.
        local token=call("UnitClassBase","player")
        local ok,valid=pcall(C.ValidClassToken,token)
        if ok and valid==true then character.classToken=token end
        return character
    end
    function self:Roster()
        -- Blizzard_ProfessionsBook uses first two results as learned primaries.
        -- Does NOT prove authoritative absence in all login/readiness states.
        local fn=env.GetProfessions
        if type(fn)~="function" or type(env.GetProfessionInfo)~="function" then
            self.roster={complete=false, reason="Primary roster APIs unavailable"}; return
        end
        local ok, a,b,_,fishing,cooking=pcall(fn)
        local roster={complete=false, entries={}, reason="Presence only; automatic unlearning unverified"}
        if ok then
            for position,index in pairs({[1]=a,[2]=b,[4]=fishing,[5]=cooking}) do
                local good,name,_,_,_,_,_,parent=pcall(env.GetProfessionInfo,index)
                if good and C.Integer(parent,1) and type(name)=="string" and
                    (position<=2 or position==4 and parent==356 or position==5 and parent==185) then
                    roster.entries[parent]={name=name, parentID=parent,primary=position<=2}
                end
            end
        end
        self.roster=roster
    end
    function self:Context()
        if call("InCombatLockdown") ~= false then return nil,"Combat/unknown safety; collection deferred" end
        local frame=env.ProfessionsFrame
        if not frame or type(frame.IsShown)~="function" then return nil,"Open your own profession (frame unavailable)" end
        local ok,shown=pcall(frame.IsShown,frame)
        if not ok or shown~=true then return nil,"Open your own profession to refresh" end
        for _,name in ipairs({"IsTradeSkillLinked","IsTradeSkillGuild","IsTradeSkillGuildMember","IsNPCCrafting","IsDataSourceChanging"}) do
            if call("C_TradeSkillUI."..name) ~= false then return nil,"Unsafe/unknown profession context: "..name end
        end
        if call("C_TradeSkillUI.IsTradeSkillReady")~=true then return nil,"Profession not ready" end
        local character=self:Character()
        if not character then return nil,"Current player identity unavailable" end
        local info=call("C_TradeSkillUI.GetChildProfessionInfo")
        local identity,why=D.Identity(info)
        if not identity then return nil,why end
        local capabilities=D.Capabilities(identity)
        if not capabilities then return nil,"Unverified profession capability tuple" end
        local base=call("C_TradeSkillUI.GetBaseProfessionInfo")
        if type(base)~="table" or base.professionID~=identity.parentID or info.isPrimaryProfession~=capabilities.primary then
            return nil,capabilities.primary and "Base/child identity not coherent primary profession" or
                "Base/child identity not coherent secondary profession"
        end
        self:Roster()
        local learned=self.roster and self.roster.entries and self.roster.entries[identity.parentID]
        if not learned or learned.primary~=capabilities.primary then
            return nil,capabilities.primary and "Own learned-primary profession presence not established" or
                "Own learned-secondary profession presence not established"
        end
        if expansionSafeguards(identity) and (not C.Integer(info.skillLevel) or
            not C.Integer(info.maxSkillLevel,1) or info.skillLevel>info.maxSkillLevel) then
            return nil,"Usable observed Midnight skill/cap unavailable"
        end
        local config,staged
        if capabilities.knowledgeMode~="not_applicable" then
            config=call("C_ProfSpecs.GetConfigIDForSkillLine",identity.skillLineID)
            if C.Integer(config,1) then staged=call("C_Traits.ConfigHasStagedChanges",config) end
        end
        return {character=character, identity=identity, info=info, config=config,
            capabilities=capabilities,staged=staged, revision=self.revision, sourceCounter=info.sourceCounter}
    end
    function self:Same(a,b)
        return b and a.revision==b.revision and a.character.guid==b.character.guid and
            a.identity.skillLineID==b.identity.skillLineID and a.identity.parentID==b.identity.parentID and
            a.identity.profession==b.identity.profession and a.identity.expansionID==b.identity.expansionID and a.config==b.config and
            a.sourceCounter==b.sourceCounter
    end
    function self:Gear(slot, role)
        local location
        if env.ItemLocation and type(env.ItemLocation.CreateFromEquipmentSlot)=="function" then
            local ok,v=pcall(env.ItemLocation.CreateFromEquipmentSlot,env.ItemLocation,slot)
            if ok then location=v end
        end
        if not location then return nil,"unsupported","ItemLocation unavailable; instance unidentifiable" end
        local exists,status,why=call("C_Item.DoesItemExist",location)
        if exists~=true and exists~=false then return nil,status,why or "Existence unknown" end
        local value={slot=slot,role=role,exists=exists,metadataReady=false}
        if exists==false then return value,"observed" end
        value.link=call("C_Item.GetItemLink",location)
        value.itemID=call("C_Item.GetItemID",location)
        local ready=call("C_Item.IsItemDataCached",location)==true and type(value.link)=="string" and C.Integer(value.itemID,1)
        if not ready then
            value.loadReason="Equipped instance metadata loading"
            return value,"unknown",value.loadReason,location
        end
        value.metadataReady=true
        local failed,failReason
        local function metadata(path,valid,...)
            local v,s,r=call(path,...)
            if s=="observed" and not valid(v) then v=nil; s="unknown"; r=path.." malformed/nullable metadata" end
            if s~="observed" then
                if not failed or s=="error" or (s=="unsupported" and failed=="unknown") then failed=s end
                failReason=(failReason and failReason.."; " or "")..(r or path.." unavailable")
            end
            return v,s
        end
        value.rarity,value.rarityStatus=metadata("C_Item.GetItemQuality",function(v) return C.Integer(v) and v<=8 end,location)
        value.icon=metadata("C_Item.GetItemIcon",function(v) return C.Integer(v,1) end,location)
        value.rank,value.rankStatus=metadata("C_TradeSkillUI.GetItemCraftedQualityByItemInfo",function(v)
            return C.Integer(v,1) and v<=5
        end,value.link)
        local q=metadata("C_TradeSkillUI.GetItemCraftedQualityInfo",function(v) return type(v)=="table" end,value.link)
        value.quality=pick(q,"quality icon iconSmall iconInventory iconChat")
        value.statAttribution="observed total; base/enchant attribution unknown"
        local stats,statStatus=metadata("C_Item.GetItemStats",function(v)
            if type(v)~="table" then return false end
            local count=0
            for key,n in pairs(v) do
                count=count+1
                if count>32 or type(key)~="string" or not key:match("^ITEM_MOD_[A-Z0-9_]+$") or
                    not C.Finite(n) then return false end
            end
            return true
        end,value.link)
        value.statsStatus=statStatus
        if type(stats)=="table" then
            value.stats={}
            local n=0
            for key,v in pairs(stats) do
                if type(key)=="string" and key:match("^ITEM_MOD_[A-Z0-9_]+$") and
                    C.Finite(v) and n<32 then
                    value.stats[key]=v; n=n+1
                end
            end
        end
        local tooltip=call("C_TooltipInfo.GetInventoryItem","player",slot)
        local positive=false
        value.enchantLines={}
        local lineType=env.Enum and env.Enum.TooltipDataLineType and env.Enum.TooltipDataLineType.ItemEnchantmentPermanent
        if lineType and type(tooltip)=="table" and type(tooltip.lines)=="table" then
            for i=1,math.min(#tooltip.lines,128) do
                local line=tooltip.lines[i]
                if line.type==lineType then
                    positive=true
                    if #value.enchantLines<8 then value.enchantLines[#value.enchantLines+1]=pick(line,"leftText rightText") end
                end
            end
        end
        value.enchant=Collectors.Enchant(value.link,positive,true)
        if not failed and role~=nil and D.slotRoles[slot]==role then
            value.itemExpansion,value.toolStat=optionalGear(env,value.link,value.itemID,role,self:Now())
            -- Optional reads can reenter/change equipment without changing profession.
            -- Discard only optional evidence; never downgrade valid base gear for them.
            local ok,current=pcall(function() return env.C_Item.GetItemLink(location) end)
            if not ok or current~=value.link then
                for _,key in ipairs({"itemExpansion","toolStat"}) do
                    local unit=value[key]
                    if unit then unit.value=nil; unit.observedAt=nil; unit.status=ok and "unknown" or "error" end
                end
            end
        end
        if failed then value.metadataReady=false; value.loadReason=failReason end
        return value,failed or "observed",failReason
    end
    function self:Knowledge(ctx)
        local raw={policy="native-rank-reconciled-v1",identity={},tabs={},tabsComplete=false,nativeComplete=false}
        for _,key in ipairs({"skillLineID","parentID","profession","expansionID"}) do
            if knInt(ctx.identity[key],1) then raw.identity[key]=ctx.identity[key] end
        end
        if knInt(ctx.sourceCounter) then raw.sourceCounter=ctx.sourceCounter end
        if type(ctx.staged)=="boolean" then raw.stagedStart=ctx.staged end
        if not knInt(ctx.config,1) then return raw end
        raw.configID=ctx.config
        local ids,complete=knIDs(knRead(env,"C_ProfSpecs.GetSpecTabIDsForSkillLine",ctx.identity.skillLineID),8)
        raw.tabsComplete=complete and #ids>0
        raw.nativeComplete=raw.tabsComplete and raw.sourceCounter~=nil
        local owners={}
        for _,id in ipairs(ids) do
            local info=knRead(env,"C_ProfSpecs.GetTabInfo",id)
            local root=knRead(env,"C_ProfSpecs.GetRootPathForTab",id)
            local tab={id=id,paths={},coverageComplete=true}
            if knPlain(info) and type(info.name)=="string" then tab.name=info.name:sub(1,256):gsub("[%c|]"," ")
            else tab.coverageComplete=false end
            if knInt(root,1) then tab.root=root else tab.coverageComplete=false end
            tab.currencies,tab.currenciesComplete,tab.currencyStatus=knArray(
                knRead(env,"C_Traits.GetTreeCurrencyInfo",ctx.config,id,true),64,function(v)
                    if not knPlain(v) or not knInt(v.traitCurrencyID,1) or not knInt(v.quantity) or
                        not knInt(v.spent) or (v.maxQuantity~=nil and not knInt(v.maxQuantity)) then return nil,false end
                    return {traitCurrencyID=v.traitCurrencyID,quantity=v.quantity,spent=v.spent,maxQuantity=v.maxQuantity},true,v.traitCurrencyID
                end)
            tab.currencyCount=#tab.currencies
            if not tab.currenciesComplete then tab.coverageComplete=false end
            raw.tabs[#raw.tabs+1]=tab
            local queue,seen,cursor={},{},1
            local function discover(pathID)
                if seen[pathID] or owners[pathID] then
                    tab.coverageComplete=false
                    if owners[pathID] then owners[pathID].coverageComplete=false end
                    raw.nativeComplete=false; return
                end
                seen[pathID]=true; owners[pathID]=tab
                if #queue>=64 then tab.coverageComplete=false else queue[#queue+1]=pathID end
            end
            if tab.root then discover(tab.root) end
            while cursor<=#queue do
                local pathID=queue[cursor]; cursor=cursor+1
                local p={costRule="unknown",costReason="Current costs are not verified future/all-rank costs"}
                p.children,p.childrenComplete=knIDs(knRead(env,"C_ProfSpecs.GetChildrenForPath",pathID),16)
                local valid; p.node,valid=knNode(knRead(env,"C_Traits.GetNodeInfo",ctx.config,pathID))
                p.metadataComplete=valid and p.node.ID==pathID
                if p.node and p.node.ID~=pathID then p.node.ID=nil; p.metadataComplete=false end
                for _,role in ipairs({"unlock","spend"}) do
                    local entryID=knRead(env,role=="unlock" and "C_ProfSpecs.GetUnlockEntryForPath" or "C_ProfSpecs.GetSpendEntryForPath",pathID)
                    if knInt(entryID,1) then p[role.."EntryID"]=entryID end
                    p[role],valid=knEntry(env,ctx.config,p[role.."EntryID"])
                    if not valid then p.metadataComplete=false end
                end
                p.name=knPathName(env,p)
                local currencyID=knRead(env,"C_ProfSpecs.GetSpendCurrencyForPath",pathID)
                if knInt(currencyID,1) then p.spendCurrencyID=currencyID else p.metadataComplete=false end
                p.costs,valid=knCosts(knRead(env,"C_Traits.GetNodeCost",ctx.config,pathID))
                if not valid then p.metadataComplete=false end
                if not p.childrenComplete or not p.metadataComplete then tab.coverageComplete=false end
                tab.paths[pathID]=p
                for _,child in ipairs(p.children) do discover(child) end
            end
            if not tab.coverageComplete then raw.nativeComplete=false end
        end
        return raw
    end
    function self:Scan()
        dashboardHandoff=nil
        knowledgeSource=nil
        if self.storagePending then
            self.reason=self.blockReason or "Saved storage initialization pending; scans disabled."
            self.changed(); return false,self.reason
        end
        if not C.Integer(self.serial) or not C.Integer(self.revision) then
            self.fresh={}; self.pending={}; self.reason="Invalid scan generation token; collection blocked."
            self.changed(); return false,self.reason
        end
        self.pending={}; self.fresh={}; self.serial=self.serial+1
        local scanSerial=self.serial
        if self.db then
            local valid,why=S.Check(self.db)
            if not valid then
                self.blockReason=why; self.reason=why; self.db=nil
                self.changed(); return false,why
            end
        end
        local ctx,why=self:Context()
        local at=self:Now()
        if not ctx or not at or not self.db then
            self.reason=self.blockReason or why or "Saved data/time unavailable; writes disabled"
            self.changed(); return false,self.reason
        end
        local observations,loads={},{}
        local function obs(key,value,source,status,reason)
            observations[key]=C.Observation(status or (value~=nil and "observed" or "unknown"),value,at,source,reason)
        end
        local cap=ctx.capabilities
        local function na(key)
            obs(key,nil,"P01 exact profession capability registry; user evidence 2026-11-18/19",
                "not_applicable","Not applicable; confirmed profession capability")
        end
        local skill=pick(ctx.info,"skillLevel maxSkillLevel skillModifier")
        if skill and C.Integer(skill.skillLevel) and C.Integer(skill.maxSkillLevel) and C.Finite(skill.skillModifier) then
            obs("skill",skill,"C_TradeSkillUI.GetChildProfessionInfo")
        else obs("skill",nil,"C_TradeSkillUI.GetChildProfessionInfo","unknown","Invalid skill/cap/modifier") end
        local function currency(key,id)
            if not C.Integer(id,1) then obs(key,nil,"currency mapping","unsupported","No evidenced currency mapping"); return end
            local raw,status,reason=call("C_CurrencyInfo.GetCurrencyInfo",id)
            local v=pick(raw,"name quantity maxQuantity rechargingCycleDurationMS rechargingAmountPerCycle")
            if v and C.Integer(v.quantity) then v.id=id; obs(key,v,"C_CurrencyInfo.GetCurrencyInfo")
            else obs(key,nil,"C_CurrencyInfo.GetCurrencyInfo",status=="observed" and "unknown" or status,reason) end
        end
        if cap.concentration then currency("concentration",call("C_TradeSkillUI.GetConcentrationCurrencyID",ctx.identity.skillLineID))
        else na("concentration") end
        if cap.moxieMode=="enabled" then
            currency("moxie",D.moxie[ctx.identity.skillLineID] and D.moxie[ctx.identity.skillLineID].id)
        elseif cap.moxieMode=="not_applicable" then na("moxie")
        else obs("moxie",nil,"P01 capability registry","unsupported","Moxie applicability/mapping pending native evidence; not confirmed N/A") end
        local slotList=call("C_TradeSkillUI.GetProfessionSlots",ctx.identity.profession)
        local slots,slotComplete
        if expansionSafeguards(ctx.identity) then slots,slotComplete=knIDs(slotList,16)
        else slots,slotComplete=list(slotList,16) end
        local roles={}
        for _,slot in ipairs(slots or {}) do
            local role=cap.slotRoles[slot]
            if role and roles[role] then slotComplete=false end
            roles[role or ("slot"..slot)]=slot
        end
        obs("slots",{indices=slots or {},complete=slotComplete},"C_TradeSkillUI.GetProfessionSlots")
        for _,role in ipairs({"accessory1","accessory2","tool"}) do
            if not cap.roles[role] then na(role)
            elseif not slotComplete or not roles[role] then
                obs(role,nil,"equipment role registry","unknown","No unique verified role/location")
            else
                local v,status,reason,location=self:Gear(roles[role],role)
                obs(role,v,"C_Item equipped instance",status,reason)
                if location and v and C.Integer(v.itemID,1) then loads[#loads+1]={key=role,value=v,location=location} end
            end
        end
        -- Unknown roles remain independent raw evidence, never relabeled by position.
        for role,slot in pairs(roles) do
            if not expansionSafeguards(ctx.identity) and role:match("^slot") then
                local v,status,reason=self:Gear(slot,nil); obs(role,v,"unmapped equipped slot",status,reason)
            end
        end
        if cap.knowledgeMode=="enabled" then
            local kp,status,reason=call("C_ProfSpecs.GetCurrencyInfoForSkillLine",ctx.identity.skillLineID)
            if type(kp)=="table" and C.Integer(kp.numAvailable) then obs("unspent",kp.numAvailable,"C_ProfSpecs.GetCurrencyInfoForSkillLine")
            else obs("unspent",nil,"C_ProfSpecs.GetCurrencyInfoForSkillLine",status=="observed" and "unknown" or status,reason) end
        elseif cap.knowledgeMode=="not_applicable" then na("unspent")
        else obs("unspent",nil,"P01 capability registry","unsupported","Gathering Knowledge accounting pending native evidence") end
        local version="unknown"
        if type(env.GetBuildInfo)=="function" then
            local ok,v,b=pcall(env.GetBuildInfo)
            if ok then version=tostring(v).." ("..tostring(b)..")" end
        end
        local locale=call("GetLocale")
        obs("environment",{version=version,locale=locale},"GetBuildInfo / GetLocale")
        local raw=cap.knowledgeMode=="enabled" and self:Knowledge(ctx) or {}
        local finish=self:Context()
        if not self:Same(ctx,finish) or self.serial~=scanSerial or
            finish.identity.expansionID~=ctx.identity.expansionID then
            self:Invalidate("Profession/config/context changed; scan discarded"); self.changed(); return false,self.reason
        end
        if type(finish.staged)=="boolean" then raw.stagedEnd=finish.staged end
        raw.stable=ctx.revision==self.revision and self.serial==scanSerial
        local result=cap.knowledgeMode=="enabled" and K.Evaluate(raw) or {complete=false,trees={}}
        -- Evidence is duplicated in coherent tree units. Do not raise the global
        -- copier budget for a maximally sized scan: fail all trees together and
        -- retain only failed attempts when that combined evidence cannot fit.
        local evidenceFits=C.Copy({raw,result})~=nil
        if not evidenceFits then
            result.complete=false; result.reason="Knowledge evidence exceeds bounded snapshot payload"
            for _,tree in ipairs(result.trees) do tree.complete=false; tree.reason=result.reason end
        end
        if cap.knowledgeMode=="not_applicable" then na("knowledgeRaw")
        elseif C.NativeKnowledgeCurrency(ctx.identity) then
            local rawValid=evidenceFits and C.ValidPayload("knowledgeRaw",raw,"observed")
            obs("knowledgeRaw",rawValid and raw or nil,"C_ProfSpecs / C_Traits",
                rawValid and "observed" or "unknown",not rawValid and
                (not evidenceFits and result.reason or "Invalid native raw metadata or wrong profession spend currency") or nil)
        else
            obs("knowledgeRaw",nil,"C_ProfSpecs / C_Traits","unsupported",
                "Native Knowledge accounting is unverified for this profession")
        end
        local index={}
        for _,tree in ipairs(result.trees) do
            index[#index+1]={id=tree.id,name=tree.name,root=tree.root}
            obs("tree:"..tree.id,tree.complete and tree or nil,"Knowledge.Evaluate",
                tree.complete and "observed" or "unknown",tree.reason)
        end
        local prior
        if S.IsHandle(self.db) then prior=S.Active(self.db,ctx.character.guid,ctx.identity.skillLineID)
        else
            local character=self.db.characters[ctx.character.guid]
            local profession=character and character.professions[ctx.identity.skillLineID]
            prior=profession and profession.active
        end
        local priorIndex=prior and prior.fields.knowledgeIndex and prior.fields.knowledgeIndex.last
        if cap.knowledgeMode=="not_applicable" then na("knowledgeIndex")
        elseif cap.knowledgeMode=="pending" then
            obs("knowledgeIndex",nil,"P01 capability registry","unsupported","Gathering Knowledge accounting pending native evidence")
        elseif not result.complete and priorIndex then
            obs("knowledgeIndex",nil,"Knowledge.Evaluate","unknown","Native evaluation failed; retained coherent tree index")
        elseif raw.tabsComplete==true and #index>0 then
            obs("knowledgeIndex",index,"C_ProfSpecs.GetSpecTabIDsForSkillLine")
        else
            obs("knowledgeIndex",nil,"C_ProfSpecs.GetSpecTabIDsForSkillLine","unknown","Incomplete tab/config coverage")
        end
        if not result.complete or raw.tabsComplete~=true then
            for _,tree in ipairs(priorIndex and priorIndex.value or {}) do
                if not observations["tree:"..tree.id] then
                    obs("tree:"..tree.id,nil,"Knowledge.Evaluate","unknown","Tree absent from incomplete scan; retained coherent history")
                end
            end
        end
        if cap.knowledgeMode=="enabled" and (ctx.staged~=false or finish.staged~=false) then
            obs("unspent",nil,"knowledge staging","unknown","Staged state not explicitly false at both boundaries")
        end
        if self.serial~=scanSerial or self.revision~=ctx.revision then
            self:Invalidate("Profession/config/context changed; scan discarded"); self.changed(); return false,self.reason
        end
        local rich
        if S.IsHandle(self.db) and result.complete and raw.nativeComplete==true then
            rich=C.Apply({schema=1,characters={}},ctx.character,ctx.identity,observations,at,tostring(version))
        end
        local g,err=S.Apply(self.db,ctx.character,ctx.identity,observations,at,tostring(version))
        if not g then self.reason=err; self.changed(); return false,err end
        local token={guid=ctx.character.guid,id=ctx.identity.skillLineID,generation=g.generation,
            revision=self.revision,serial=self.serial,ctx=ctx,at=at,build=tostring(version)}
        if S.IsHandle(self.db) then
            token.storage=S.Token(self.db,token.guid,token.id)
            if rich then
                rich.generation=g.generation
                for _,f in pairs(rich.fields) do if f.last then f.last.generation=g.generation end end
                knowledgeSource={g=rich,ctx=C.Copy({character=ctx.character,identity=ctx.identity,config=ctx.config,
                    staged=ctx.staged,revision=ctx.revision,sourceCounter=ctx.sourceCounter}),serial=self.serial,revision=self.revision,
                    token=token.storage,db=self.db,guid=token.guid,id=token.id,at=at}
            end
        end
        local fresh={generation=g.generation,fields={}}
        for key,o in pairs(observations) do if o.status=="observed" then fresh.fields[key]=true end end
        self.fresh[token.guid..":"..token.id]=fresh
        self.reason=result.complete and
            "Snapshot refreshed; native rank points/shared-spent reconciled (not verified future costs)." or
            "Snapshot refreshed; knowledge totals unknown or stale (native reconciliation incomplete)."
        if cap.knowledgeMode=="not_applicable" then self.reason="Snapshot refreshed; Knowledge not applicable for this profession."
        elseif cap.knowledgeMode=="pending" then self.reason="Snapshot refreshed; gathering Moxie/Knowledge activation pending native evidence." end
        publishHandoff("observed",token)
        self:StartLoads(loads,token)
        self.changed(); return true
    end
    function self:TokenValid(token)
        if token.serial~=self.serial or token.revision~=self.revision then return false end
        if S.IsHandle(self.db) then
            return token.storage==S.Token(self.db,token.guid,token.id) and self:Same(token.ctx,self:Context())
        end
        local c=self.db and self.db.characters[token.guid]
        local p=c and c.professions[token.id]
        return p and p.active and p.active.generation==token.generation and self:Same(token.ctx,self:Context())
    end
    function self:DetailsSource(scope)
        local s=knowledgeSource
        if not s or s.db~=self.db or s.guid~=scope.guid or s.id~=scope.id or s.g.generation~=scope.generation or
            s.serial~=self.serial or s.revision~=self.revision or s.token~=S.Token(self.db,s.guid,s.id) or
            not s.ctx or not self:Same(s.ctx,self:Context()) then
            knowledgeSource=nil; return nil
        end
        return C.Copy(s.g),s.token
    end
    function self:StartLoads(loads,token)
        local count=0
        for _,entry in ipairs(loads) do
            local id=entry.value.itemID
            local pending=self.pending[id]
            if pending then pending.entries[#pending.entries+1]=entry
            elseif count<16 then
                count=count+1
                self.pending[id]={token=token,entries={entry},retried=false}
            end
        end
        -- Register all tokens before issuing requests (completion can be synchronous).
        local requests={}
        for id,p in pairs(self.pending) do requests[#requests+1]={id=id,p=p} end
        for _,request in ipairs(requests) do
            call("C_Item.RequestLoadItemData",request.p.entries[1].location)
        end
        if count>0 and env.C_Timer and type(env.C_Timer.After)=="function" then
            env.C_Timer.After(5,function() self:Expire(token) end)
        else self:Expire(token) end
    end
    function self:ItemResult(itemID,success)
        local p=self.pending[itemID]
        if not p or p.retried then return end
        self.pending[itemID]=nil; p.retried=true
        if not self:TokenValid(p.token) then return end
        local sessionKey=p.token.guid..":"..p.token.id
        local session=self.fresh[sessionKey]
        if session and session.generation==p.token.generation then
            -- A failed/mismatched retry or failed commit cannot inherit freshness.
            -- Do not replace the session table or disturb unrelated field flags.
            for _,entry in ipairs(p.entries) do session.fields[entry.key]=nil end
        end
        if success~=true then self.changed(); return end
        local observations={}
        for _,entry in ipairs(p.entries) do
            local value,status,reason=self:Gear(entry.value.slot,entry.value.role)
            if value and value.itemID==itemID and value.link==entry.value.link then
                observations[entry.key]=C.Observation(status,value,self:Now(),"ITEM_DATA_LOAD_RESULT retry",reason)
            end
        end
        if next(observations) and self:TokenValid(p.token) then
            local applied,why=S.Apply(self.db,p.token.ctx.character,p.token.ctx.identity,observations,self:Now(),p.token.build)
            if applied and S.IsHandle(self.db) then
                knowledgeSource=nil; p.token.storage=S.Token(self.db,p.token.guid,p.token.id)
            end
            if applied and applied.generation==p.token.generation and self:TokenValid(p.token) then
                session=self.fresh[sessionKey]
                if session and session.generation==p.token.generation then
                    for key,o in pairs(observations) do
                        if o.status=="observed" then session.fields[key]=true end
                    end
                end
                publishHandoff("observed",p.token)
            elseif not applied then self.reason=why or "Item retry commit failed; snapshot not refreshed" end
        end
        self.changed()
    end
    function self:Expire(token)
        for id,p in pairs(self.pending) do
            if p.token==token then
                self.pending[id]=nil
                if self:TokenValid(token) then
                    local session=self.fresh[token.guid..":"..token.id]
                    if session and session.generation==token.generation then
                        for _,entry in ipairs(p.entries) do session.fields[entry.key]=nil end
                    end
                    local observations={}
                    for _,entry in ipairs(p.entries) do
                        local v=C.Copy(entry.value); v.loadReason="Item data timeout (5 seconds); refresh manually"
                        observations[entry.key]=C.Observation("unknown",v,self:Now(),"bounded item timeout",v.loadReason)
                    end
                    local applied=S.Apply(self.db,token.ctx.character,token.ctx.identity,observations,self:Now(),token.build)
                    if applied and S.IsHandle(self.db) then
                        knowledgeSource=nil; token.storage=S.Token(self.db,token.guid,token.id)
                    end
                    if applied and applied.generation==token.generation then publishHandoff("observed",token) end
                end
            end
        end
        self.changed()
    end
    function self:Request(reason)
        self:Invalidate(reason)
        if self.storagePending then self.changed(); return end
        if call("InCombatLockdown")~=false then self.deferred=true; self.changed(); return end
        if self.scheduled then
            if dashboardScheduled and env.C_Timer and type(env.C_Timer.After)=="function" then publishHandoff("requested") end
            return
        end
        if not env.C_Timer or type(env.C_Timer.After)~="function" then
            self.reason="Scheduling unavailable; use /ca scan"; self.changed(); return
        end
        self.scheduled=true
        dashboardScheduled=true
        publishHandoff("requested")
        local ok,why=pcall(env.C_Timer.After,0,function()
            dashboardScheduled=nil; self.scheduled=false; self:Scan()
        end)
        if not ok then dashboardHandoff=nil; dashboardScheduled=nil; error(why,0) end
    end
    return self
end

-- Payloads are used only where pinned source verifies them; other event callbacks
-- ignore payloads and only invalidate/coalesce a guarded read.
Collectors.events={"PLAYER_LOGIN","PLAYER_REGEN_ENABLED","PLAYER_REGEN_DISABLED",
    "TRADE_SKILL_SHOW","TRADE_SKILL_CLOSE","TRADE_SKILL_DATA_SOURCE_CHANGING",
    "TRADE_SKILL_DATA_SOURCE_CHANGED","TRADE_SKILL_LIST_UPDATE","PLAYER_EQUIPMENT_CHANGED",
    "CURRENCY_DISPLAY_UPDATE","TRAIT_CONFIG_UPDATED","TRAIT_NODE_CHANGED",
    "TRAIT_NODE_CHANGED_PARTIAL","TRAIT_NODE_ENTRY_UPDATED","TRAIT_TREE_CURRENCY_INFO_UPDATED",
    "ITEM_DATA_LOAD_RESULT"}
