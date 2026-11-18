local _, D = ...
-- Signatures: Q03's Gethe revision 297d7aaaa736f346b3e036f38ee088eaf7f8c07f.
-- Presence is not proof of installed-client compatibility. No gameplay writes.
local professionKeys = "profession professionID sourceCounter professionName expansionName skillLevel maxSkillLevel skillModifier isPrimaryProfession parentProfessionID parentProfessionName"
local currencyKeys = "name quantity maxQuantity rechargingCycleDurationMS rechargingAmountPerCycle"
local nodeKeys = "ID ranksPurchased ranksIncreased currentRank activeRank maxRanks totalMaxRanks"
local apiNames = {
    "GetBuildInfo", "GetLocale", "UnitGUID", "UnitName", "GetRealmName", "GetServerTime",
    "C_AddOns.GetAddOnMetadata", "C_AddOns.IsAddOnLoaded",
    "C_TradeSkillUI.IsTradeSkillLinked", "C_TradeSkillUI.IsTradeSkillGuild",
    "C_TradeSkillUI.IsNPCCrafting", "C_TradeSkillUI.IsDataSourceChanging",
    "C_TradeSkillUI.GetBaseProfessionInfo", "C_TradeSkillUI.GetChildProfessionInfo",
    "C_TradeSkillUI.GetProfessionSlots", "ItemLocation.CreateFromEquipmentSlot",
    "C_Item.DoesItemExist", "C_Item.GetItemLink", "C_Item.IsItemDataCached",
    "C_Item.GetItemQuality", "C_Item.GetItemStats", "C_TooltipInfo.GetInventoryItem",
    "C_TradeSkillUI.GetItemCraftedQualityByItemInfo", "C_TradeSkillUI.GetItemCraftedQualityInfo",
    "C_TradeSkillUI.GetConcentrationCurrencyID", "C_CurrencyInfo.GetCurrencyInfo",
    "C_ProfSpecs.GetConfigIDForSkillLine", "C_ProfSpecs.GetSpecTabIDsForSkillLine",
    "C_ProfSpecs.GetTabInfo", "C_ProfSpecs.GetRootPathForTab", "C_ProfSpecs.GetChildrenForPath",
    "C_ProfSpecs.GetCurrencyInfoForSkillLine", "C_Traits.ConfigHasStagedChanges",
    "C_Traits.GetTreeCurrencyInfo", "C_Traits.GetTreeNodes", "C_Traits.GetNodeInfo",
    "C_Item.GetItemCount"
}
D.API_NAMES = apiNames

function D.IDList(v)
    if type(v) ~= "table" then return nil end
    local out = {}
    for i = 1, math.min(#v, 128) do
        if D.Finite(v[i]) and v[i] > 0 and v[i] == math.floor(v[i]) then out[#out + 1] = v[i] end
    end
    return out
end

function D.Resolve(env, path)
    local value = env
    for part in path:gmatch("[^.]+") do
        if type(value) ~= "table" then return nil end
        value = rawget(value, part)
    end
    return value
end

function D.InventoryPlan(warband)
    local plan = {
        { key = "bags", flags = { false, false, false, false } },
        { key = "personal", flags = { true, false, true, false } }
    }
    if warband == true then
        plan[#plan + 1] = { key = "warband", flags = { true, false, true, true } }
    end
    return plan
end

function D.AuctionatorCapabilities(addon)
    local api = type(addon) == "table" and rawget(addon, "API")
    local v1 = type(api) == "table" and rawget(api, "v1")
    return { namespacePresent = type(addon) == "table", v1Present = type(v1) == "table",
        getShoppingListItemsPresent = type(v1) == "table" and type(rawget(v1, "GetShoppingListItems")) == "function",
        convertFromSearchStringPresent = type(v1) == "table" and type(rawget(v1, "ConvertFromSearchString")) == "function" }
end

-- Only uppercase ITEM_MOD_* numeric stat observations are retained. Attribution
-- between base tool and enchant contribution is explicitly not inferred.
function D.StatEvidence(stats)
    if type(stats) ~= "table" then return nil end
    local out, count = {}, 0
    for key, value in next, stats do
        if count >= 32 then break end
        if type(key) == "string" and #key <= 96 and key:match("^ITEM_MOD_[A-Z0-9_]+$") and D.Finite(value) then
            out[key], count = value, count + 1
        end
    end
    return out
end

function D.KnowledgeNode(info, staged)
    local out = D.Pick(info, nodeKeys)
    if not out then return nil end
    out.committedPurchasedKnown = staged == false
    if staged == false then out.committedPurchased = out.ranksPurchased end
    -- currentRank includes non-purchased evidence; never sum it as spent points.
    out.capacityKnown = false
    return out
end

-- Kept separate for injected, prefilled-budget fixtures. Called only by a manual
-- ready-player scan. Paths, not a prefix of the raw perk/node list, select detail.
function D.CollectKnowledge(env, sample, previousSamples, skillLineID)
    previousSamples = previousSamples or {}
    local coverage = { policy = "paths_only", tabCount = "unknown", tabLimit = false,
        tabListInvalid = false, budgetDrops = 0, tabs = {},
        limits = { tabs = 8, paths = 64, children = 16, nodeList = 128 },
        reserveBytes = 4096, reserveFields = 1 }
    local writeBudget = { bytes = D.LIMITS.sampleBytes - 4096, fields = D.LIMITS.fields - 1 }
    local activeTab
    local function write(key, status, source, value, reason)
        local saved = D.Record(sample, key, status, source, value, reason,
            D.Previous(previousSamples, key), writeBudget)
        if not saved then
            coverage.budgetDrops = coverage.budgetDrops + 1
            if activeTab then activeTab.budgetDrops = activeTab.budgetDrops + 1 end
        end
        return saved
    end
    local function read(key, path, project, ...)
        local args, count = { ... }, select("#", ...)
        local fn = D.Resolve(env, path)
        local status, value, reason
        if type(fn) ~= "function" then
            status, reason = "unsupported", "API unavailable"
        else
            status, value, reason = D.Attempt(function()
                local raw = fn(unpack(args, 1, count))
                if raw == nil then return nil end
                if project then return project(raw) end
                return raw
            end)
        end
        local saved = write(key, status, path, value, reason)
        if activeTab and status ~= "observed" then activeTab.failures = activeTab.failures + 1 end
        return value, status, saved
    end
    local function positiveID(value)
        if D.Finite(value) and value > 0 and value == math.floor(value) then return value end
    end
    local config, configStatus = read("knowledge.config", "C_ProfSpecs.GetConfigIDForSkillLine", positiveID, skillLineID)
    coverage.configStatus = configStatus
    read("knowledge.unspent", "C_ProfSpecs.GetCurrencyInfoForSkillLine", function(v)
        return D.Pick(v, "numAvailable currencyName")
    end, skillLineID)
    local tabIDs, tabsStatus = read("knowledge.tabs", "C_ProfSpecs.GetSpecTabIDsForSkillLine", function(v)
        if type(v) ~= "table" then return nil end
        coverage.tabCount, coverage.tabLimit = #v, #v > 8
        local ids, seen = {}, {}
        for i = 1, math.min(#v, 8) do
            local id = positiveID(v[i])
            if id and not seen[id] then ids[#ids + 1], seen[id] = id, true
            else coverage.tabListInvalid = true end
        end
        return ids
    end, skillLineID)
    coverage.tabsStatus = tabsStatus
    local staged
    if configStatus == "observed" and config then
        staged = read("knowledge.hasStagedChanges", "C_Traits.ConfigHasStagedChanges", nil, config)
    else
        write("knowledge.hasStagedChanges", "unknown", "C_Traits.ConfigHasStagedChanges", nil, "No verified config ID")
    end
    write("knowledge.capacity", "unknown", "diagnostic", nil,
        "No verified spendable purchased-point denominator; maxRanks/currentRank are not tree capacity/spent totals")

    local states = {}
    -- Phase 1: every bounded tab's metadata precedes ANY path/node detail.
    for _, tab in ipairs(type(tabIDs) == "table" and tabIDs or {}) do
        local row = { id = tab, rawNodeCount = "unknown", pathsDiscovered = "unknown",
            pathsCaptured = 0, nonPathOmitted = "unknown", pathComplete = false,
            failures = 0, budgetDrops = 0, childLimit = false, pathLimit = false,
            nodeListLimit = false, listInvalid = false, repeated = false }
        activeTab = row
        coverage.tabs[#coverage.tabs + 1] = row
        local state = { row = row, prefix = "knowledge.tab." .. tab,
            paths = {}, seen = {}, cursor = 1, traversalOK = true }
        states[#states + 1] = state
        read(state.prefix .. ".info", "C_ProfSpecs.GetTabInfo", function(v)
            return D.Pick(v, "rootNodeID name rootIconID")
        end, tab)
        if configStatus == "observed" and config then
            read(state.prefix .. ".currencyCommitted", "C_Traits.GetTreeCurrencyInfo", function(v)
                if type(v) ~= "table" then return nil end
                local out = { excludeStagedChanges = true, currencies = {} }
                for n = 1, math.min(#v, 8) do
                    out.currencies[n] = D.Pick(v[n], "traitCurrencyID quantity maxQuantity spent")
                end
                return out
            end, config, tab, true)
        else
            write(state.prefix .. ".currencyCommitted", "unknown", "C_Traits.GetTreeCurrencyInfo", nil, "No verified config ID")
        end
        local root, rootStatus = read(state.prefix .. ".rootPath", "C_ProfSpecs.GetRootPathForTab", positiveID, tab)
        if rootStatus == "observed" and root then
            state.paths[1], state.seen[root], row.pathsDiscovered = root, true, 1
        else state.traversalOK = false end
        read(state.prefix .. ".nodeList", "C_Traits.GetTreeNodes", function(v)
            if type(v) ~= "table" then return nil end
            row.rawNodeCount, row.nodeListLimit = #v, #v > 128
            state.rawNodes = {}
            for n = 1, math.min(#v, 128) do
                local id = positiveID(v[n])
                if id and not state.rawNodes[id] then state.rawNodes[id] = true
                else row.listInvalid = true end
            end
            return { rawCount = #v, inspected = math.min(#v, 128),
                limited = row.nodeListLimit, invalid = row.listInvalid }
        end, tab)
    end

    -- Phase 2: breadth-first within each tree, round-robin ACROSS trees. This
    -- gives later roots priority too. Non-path perk details are never queried.
    local pending = true
    while pending do
        pending = false
        for _, state in ipairs(states) do
            local path = state.paths[state.cursor]
            if path then
                pending = true
                state.cursor = state.cursor + 1
                local row = state.row
                activeTab = row
                local children, childStatus = read(state.prefix .. ".path." .. path .. ".children",
                    "C_ProfSpecs.GetChildrenForPath", function(v)
                        if type(v) ~= "table" then return nil end
                        if #v > 16 then row.childLimit = true end
                        local ids = {}
                        for n = 1, math.min(#v, 16) do
                            local id = positiveID(v[n])
                            if id then ids[#ids + 1] = id else row.listInvalid = true end
                        end
                        return ids
                    end, path)
                if childStatus ~= "observed" then state.traversalOK = false end
                for _, id in ipairs(type(children) == "table" and children or {}) do
                    if state.seen[id] then row.repeated = true
                    elseif #state.paths >= 64 then row.pathLimit = true
                    else
                        state.seen[id] = true
                        state.paths[#state.paths + 1] = id
                    end
                end
                row.pathsDiscovered = #state.paths
                if configStatus == "observed" and config then
                    local _, nodeStatus, saved = read(state.prefix .. ".node." .. path, "C_Traits.GetNodeInfo",
                        function(v) return D.KnowledgeNode(v, staged) end, config, path)
                    if nodeStatus == "observed" and saved and saved.status == "observed" then
                        row.pathsCaptured = row.pathsCaptured + 1
                    end
                else
                    write(state.prefix .. ".node." .. path, "unknown", "C_Traits.GetNodeInfo", nil, "No verified config ID")
                end
            end
        end
    end
    for _, state in ipairs(states) do
        local row = state.row
        local traversed = state.traversalOK and not row.childLimit and not row.pathLimit
            and not row.listInvalid and not row.repeated
        row.pathComplete = traversed and row.pathsDiscovered ~= "unknown"
            and not row.nodeListLimit and row.pathsCaptured == row.pathsDiscovered
            and row.budgetDrops == 0 and row.failures == 0
        if traversed and state.rawNodes and not row.nodeListLimit then
            local omitted = 0
            for id in next, state.rawNodes do if not state.seen[id] then omitted = omitted + 1 end end
            row.nonPathOmitted = omitted
        end
    end
    activeTab = nil
    coverage.pathCaptureComplete = #states > 0 and tabsStatus == "observed"
        and configStatus == "observed" and not coverage.tabLimit
        and not coverage.tabListInvalid and coverage.budgetDrops == 0
    for _, row in ipairs(coverage.tabs) do
        if not row.pathComplete then coverage.pathCaptureComplete = false end
    end
    -- Bypass ONLY the section's reduced ceiling, never the original sample bounds.
    -- The coverage record itself must fit in at most the reserved 4096 bytes.
    local finalBudget = { bytes = math.min(D.LIMITS.sampleBytes, sample.bytes + 4096), fields = D.LIMITS.fields }
    local saved = D.Record(sample, "knowledge.coverage", "observed", "diagnostic path-capture accounting", coverage,
        nil, nil, finalBudget)
    sample.knowledgeCoverageFailed = saved == nil
    if not saved then
        -- Extreme pre-knowledge exhaustion or unexpectedly large bookkeeping is
        -- visible even if the minimal fallback cannot fit. Never claim full success.
        sample.truncated = true
        D.Record(sample, "knowledge.coverage", "error", "diagnostic path-capture accounting",
            { policy = "paths_only", coverageReduced = true, pathCaptureComplete = false,
                budgetDrops = coverage.budgetDrops },
            "Full coverage record did not fit remaining/reserved budget", nil, finalBudget)
    end
    return sample, coverage
end

function D.Collect(env, sample, previousSamples, request)
    previousSamples, request = previousSamples or {}, request or {}
    local function record(key, status, source, value, reason)
        return D.Record(sample, key, status, source, value, reason,
            D.Previous(previousSamples, key))
    end
    local function capture(key, path, project, ...)
        local args, count = { ... }, select("#", ...)
        local fn = D.Resolve(env, path)
        if type(fn) ~= "function" then
            record(key, "unsupported", path, nil, "API unavailable")
            return nil
        end
        local status, value, reason = D.Attempt(function()
            local raw = fn(unpack(args, 1, count))
            if raw == nil then return nil end
            if project then return project(raw) end
            return raw
        end)
        record(key, status, path, value, reason)
        if status == "observed" then return value end
    end
    local function unknown(key, reason)
        record(key, "unknown", "diagnostic", nil, reason)
    end
    local function tablePick(names) return function(v) return D.Pick(v, names) end end

    -- Retain the first four documented GetBuildInfo return values, not buildInfo.
    local buildFn = D.Resolve(env, "GetBuildInfo")
    if type(buildFn) == "function" then
        local status, value, reason = D.Attempt(function()
            local version, build, date, interface = buildFn()
            return { version = version, build = build, date = date, interface = interface }
        end)
        record("environment.build", status, "GetBuildInfo", value, reason)
    else record("environment.build", "unsupported", "GetBuildInfo", nil, "API unavailable") end
    capture("environment.locale", "GetLocale")
    capture("environment.guid", "UnitGUID", nil, "player")
    capture("environment.name", "UnitName", nil, "player")
    capture("environment.realm", "GetRealmName")
    capture("environment.serverTime", "GetServerTime")
    for _, path in ipairs(apiNames) do
        record("capabilities." .. path, "observed", "type", type(D.Resolve(env, path)) == "function")
    end
    for _, name in ipairs({ "CraftArmy_Diagnostics", "Auctionator", "Blizzard_Professions", "Blizzard_ProfessionsTemplates" }) do
        capture("environment.addon." .. name .. ".version", "C_AddOns.GetAddOnMetadata", nil, name, "Version")
        local loader = D.Resolve(env, "C_AddOns.IsAddOnLoaded")
        local loadStatus, loadState, loadReason = D.Attempt(type(loader) == "function" and function()
            local loadedOrLoading, loaded = loader(name)
            return { loadedOrLoading = loadedOrLoading, loaded = loaded }
        end or nil)
        record("environment.addon." .. name .. ".loadState", loadStatus, "C_AddOns.IsAddOnLoaded", loadState, loadReason)
    end
    local caps = D.AuctionatorCapabilities(rawget(env, "Auctionator"))
    record("auctionator.capabilities", "observed", "Auctionator.API.v1 (presence only)", caps)
    record("auctionator.CraftArmyReadback", caps.namespacePresent and "unsupported" or "not_applicable",
        "Auctionator.API.v1.GetShoppingListItems", nil,
        caps.namespacePresent and "Current installed public read signature unverified; no method invoked" or "Auctionator absent; no method invoked")
    unknown("moxie.mapping", "No evidenced profession-specific Moxie mapping; /cad currency ID is only an unverified candidate")

    local function currency(key, id)
        if not D.Finite(id) or id <= 0 then unknown(key, "No positive currency ID available"); return end
        record(key .. ".id", "observed", "diagnostic candidate or API mapping", id)
        capture(key .. ".info", "C_CurrencyInfo.GetCurrencyInfo", tablePick(currencyKeys), id)
    end
    if request.currencyID then
        record("currency.mapping", "unknown", "user supplied", nil, "Unverified candidate, not a profession Moxie mapping")
        currency("currency.candidate." .. request.currencyID, request.currencyID)
    end
    if request.itemID then
        local id = request.itemID
        record("inventory.itemID", "observed", "user supplied", id)
        record("inventory.warbandOptIn", "observed", "explicit command argument", request.warband == true)
        local bank = rawget(env, "BankFrame")
        local bankStatus, bankVisible, bankReason = D.Attempt(type(bank) == "table" and
            type(bank.IsShown) == "function" and function() return bank:IsShown() end or nil)
        record("inventory.bankFrameVisible", bankStatus, "BankFrame:IsShown", bankVisible, bankReason)
        unknown("inventory.freshness", "API counts may be cached; visible bank does not prove bank type, freshness, usability or other-alt availability")
        for _, probe in ipairs(D.InventoryPlan(request.warband)) do
            local key = "inventory." .. id .. "." .. probe.key
            record(key .. ".flags", "observed", "C_Item.GetItemCount argument order",
                { includeBank = probe.flags[1], includeUses = probe.flags[2],
                    includeReagentBank = probe.flags[3], includeAccountBank = probe.flags[4] })
            capture(key .. ".count", "C_Item.GetItemCount", nil, id, unpack(probe.flags))
        end
        if request.warband ~= true then
            record("inventory." .. id .. ".warband.count", "not_applicable", "explicit opt-in policy", nil, "Not queried; Warband excluded")
        end
    end

    local safe = true
    for _, name in ipairs({ "IsTradeSkillLinked", "IsTradeSkillGuild", "IsNPCCrafting", "IsDataSourceChanging" }) do
        local result = capture("context." .. name, "C_TradeSkillUI." .. name)
        if result ~= false then safe = false end
    end
    -- Require the normal professions frame to be visible as additional readiness
    -- evidence; never open it or collect from the separate inspect frame.
    local frame = rawget(env, "ProfessionsFrame")
    local status, visible, reason = D.Attempt(type(frame) == "table" and
        type(frame.IsShown) == "function" and function() return frame:IsShown() end or nil)
    record("context.professionsFrameVisible", status, "ProfessionsFrame:IsShown", visible, reason)
    if visible ~= true then safe = false end
    if not safe then
        for _, key in ipairs({ "profession.current", "profession.base", "equipment.slots",
            "concentration.mapping", "knowledge.config" }) do
            unknown(key, "Non-player, linked, NPC, changing, closed or unverified context; no profession data attributed to player")
        end
        return sample
    end
    local function readyProfession(v)
        if type(v) ~= "table" or not D.Finite(v.professionID) or v.professionID <= 0 then return nil end
        return D.Pick(v, professionKeys)
    end
    local child = capture("profession.current", "C_TradeSkillUI.GetChildProfessionInfo", readyProfession)
    capture("profession.base", "C_TradeSkillUI.GetBaseProfessionInfo", readyProfession)
    if not child or not D.Finite(child.professionID) or child.professionID <= 0 then
        unknown("context.ready", "No positive current expansion profession ID; dependent probes skipped")
        return sample
    end
    local skillLineID = child.professionID
    local concentrationID = capture("concentration.mapping", "C_TradeSkillUI.GetConcentrationCurrencyID", nil, skillLineID)
    currency("concentration.currency", concentrationID)
    local slots
    if D.Finite(child.profession) then
        slots = capture("equipment.slots", "C_TradeSkillUI.GetProfessionSlots", function(v)
            local out = {}
            if type(v) ~= "table" then return nil end
            for i = 1, math.min(#v, 8) do if D.Finite(v[i]) then out[#out + 1] = v[i] end end
            return out
        end, child.profession)
    else unknown("equipment.slots", "Profession enum unavailable; not inferred from skillLineID") end
    for _, slot in ipairs(slots or {}) do
        local prefix = "equipment.slot." .. slot
        unknown(prefix .. ".role", "Slot index observed; tool/accessory ordering not verified")
        local factory = D.Resolve(env, "ItemLocation.CreateFromEquipmentSlot")
        local locStatus, location = D.Attempt(factory, rawget(env, "ItemLocation"), slot)
        if locStatus ~= "observed" then
            record(prefix .. ".existence", locStatus, "ItemLocation:CreateFromEquipmentSlot", nil, "Location unavailable")
        else
            local exists = capture(prefix .. ".existence", "C_Item.DoesItemExist", nil, location)
            if exists == false then
                record(prefix .. ".item", "empty", "C_Item.DoesItemExist", nil, "Confirmed false for valid player equipment location")
            elseif exists == true then
                local link = capture(prefix .. ".link", "C_Item.GetItemLink", nil, location)
                capture(prefix .. ".cached", "C_Item.IsItemDataCached", nil, location)
                capture(prefix .. ".rarity", "C_Item.GetItemQuality", nil, location)
                if type(link) == "string" then
                    capture(prefix .. ".craftedRank", "C_TradeSkillUI.GetItemCraftedQualityByItemInfo", nil, link)
                    capture(prefix .. ".qualityIcons", "C_TradeSkillUI.GetItemCraftedQualityInfo",
                        tablePick("quality icon iconSmall iconInventory iconChat"), link)
                    capture(prefix .. ".stats", "C_Item.GetItemStats", D.StatEvidence, link)
                else unknown(prefix .. ".craftedRank", "Equipped instance link unavailable/loading; rank not inferred from rarity") end
                unknown(prefix .. ".enchantAttribution", "No verified enchant-ID/stat map; stats may include enchant contribution")
                local permanent = D.Resolve(env, "Enum.TooltipDataLineType.ItemEnchantmentPermanent")
                if D.Finite(permanent) then
                    capture(prefix .. ".permanentEnchantLines", "C_TooltipInfo.GetInventoryItem", function(v)
                        if type(v) ~= "table" or type(v.lines) ~= "table" then return nil end
                        local lines = {}
                        for i = 1, math.min(#v.lines, 64) do
                            local line = v.lines[i]
                            if type(line) == "table" and line.type == permanent and #lines < 8 then
                                lines[#lines + 1] = D.Pick(line, "type leftText rightText")
                            end
                        end
                        return { lines = lines, absenceVerified = false }
                    end, "player", slot)
                else unknown(prefix .. ".permanentEnchantLines", "Permanent-enchant enum unavailable; no numeric fallback") end
            else unknown(prefix .. ".item", "Existence unready; not an empty slot") end
        end
    end

    return D.CollectKnowledge(env, sample, previousSamples, skillLineID)
end
