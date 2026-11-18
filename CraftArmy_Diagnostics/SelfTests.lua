local _, D = ...
-- The same runner is used by tests/run.lua and /cad selftest. Every collector
-- invocation receives a fresh fake environment, never _G or real SavedVariables.
function D.RunSelfTests()
    local result = { passed = 0, total = 0, failures = {} }
    local function test(name, fn)
        result.total = result.total + 1
        local ok, err = pcall(fn)
        if ok then result.passed = result.passed + 1
        else result.failures[#result.failures + 1] = name .. ": " .. tostring(err):sub(1, 240) end
    end
    local function eq(a, b) assert(a == b, tostring(a) .. " ~= " .. tostring(b)) end
    local function sample() return D.NewSample("fixture", 100) end
    local function ownContext()
        return {
            ProfessionsFrame = { IsShown = function() return true end },
            C_TradeSkillUI = {
                IsTradeSkillLinked = function() return false end,
                IsTradeSkillGuild = function() return false end,
                IsNPCCrafting = function() return false end,
                IsDataSourceChanging = function() return false end,
                GetChildProfessionInfo = function() return { professionID = 999, profession = 3, skillLevel = 0, maxSkillLevel = 100 } end,
                GetBaseProfessionInfo = function() return { professionID = 773, profession = 3 } end,
                GetProfessionSlots = function() return { 20 } end
            },
            ItemLocation = { CreateFromEquipmentSlot = function(_, slot) return { slot = slot } end }
        }
    end
    local function pathFixture(tabCount)
        local calls = { nodes = {}, actions = 0 }
        local function root(tab) return tab * 10000 + 72 end
        local function forbidden() calls.actions = calls.actions + 1; error("forbidden action") end
        local tabs = {}
        for i = 1, tabCount do tabs[i] = i end
        local env = setmetatable({
            C_ProfSpecs = {
                GetConfigIDForSkillLine = function() return 1 end,
                GetCurrencyInfoForSkillLine = function() return { numAvailable = 0, currencyName = "Fixture knowledge" } end,
                GetSpecTabIDsForSkillLine = function() return tabs end,
                GetTabInfo = function(tab) return { rootNodeID = root(tab), name = "Synthetic " .. tab } end,
                GetRootPathForTab = root,
                GetChildrenForPath = function(path)
                    if path % 10000 == 72 then return { path - 1 } end
                    return {}
                end
            },
            C_Traits = {
                ConfigHasStagedChanges = function() return false end,
                GetTreeCurrencyInfo = function(_, _, exclude)
                    eq(exclude, true)
                    return { { traitCurrencyID = 4, quantity = 0, spent = 260 } }
                end,
                GetTreeNodes = function(tab)
                    local nodes = {}
                    for n = 1, 72 do nodes[n] = tab * 10000 + n end
                    return nodes
                end,
                GetNodeInfo = function(_, id)
                    calls.nodes[#calls.nodes + 1] = id
                    return { ID = id, ranksPurchased = 21, currentRank = 22,
                        ranksIncreased = 1, maxRanks = 30 }
                end,
                PurchaseRank = forbidden, CommitConfig = forbidden
            },
            Auctionator = { sentinel = "retained", API = { v1 = {
                GetShoppingListItems = forbidden, CreateShoppingList = forbidden,
                DeleteShoppingList = forbidden, MultiSearch = forbidden } } }
        }, { __index = forbidden })
        return env, calls, root
    end
    test("observed zero vs nil", function()
        local s = sample()
        D.Probe(s, "currency.zero", "fixture", function() return 0 end)
        D.Probe(s, "currency.nil", "fixture", function() return nil end)
        eq(s.fields["currency.zero"].status, "observed")
        eq(s.fields["currency.zero"].value, 0)
        eq(s.fields["currency.nil"].status, "unknown")
        eq(D.NewSample("no clock", nil).timeKnown, false)
    end)
    test("missing and erroring optional API", function()
        local s = sample()
        D.Probe(s, "currency.missing", "fixture", nil)
        D.Probe(s, "currency.error", "fixture", function() error("private payload") end)
        eq(s.fields["currency.missing"].status, "unsupported")
        eq(s.fields["currency.error"].status, "error")
        assert(not D.Export({ s }):find("private payload", 1, true))
    end)
    test("last successful field survives failed attempts", function()
        local s = sample()
        local old = D.Record(s, "currency.zero", "observed", "fixture", 0)
        local latest = D.Record(s, "currency.zero", "unknown", "fixture", nil, "loading", old)
        latest = D.Record(s, "currency.zero", "error", "fixture", nil, "failed", latest)
        eq(latest.status, "error"); eq(latest.lastObserved.value, 0)
        eq(latest.lastObserved.time, 100)
    end)
    test("20-sample limit and reload preservation", function()
        local db = D.OpenDB(nil)
        for i = 1, 25 do assert(D.AddSample(db, "fixture-guid", D.NewSample("sample " .. i, i))) end
        eq(#db.characters["fixture-guid"].samples, 20)
        eq(db.characters["fixture-guid"].samples[1].time, 6)
        eq(D.OpenDB(db), db)
        local foreign = { schema = 2, retained = true }
        eq(D.OpenDB(foreign), nil); eq(foreign.retained, true)
    end)
    test("independent character storage", function()
        local db = D.OpenDB(nil)
        D.AddSample(db, "a", sample()); D.AddSample(db, "b", D.NewSample("b", 200))
        eq(db.characters.a.samples[1].time, 100)
        eq(db.characters.b.samples[1].time, 200)
    end)
    test("bounded fields and values", function()
        local s = sample()
        for i = 1, 600 do D.Record(s, "currency." .. i, "observed", "fixture", i) end
        eq(s.fieldCount, 512); eq(s.truncated, true)
        eq(#D.Clean(string.rep("a", 5000)), 1024)
        eq(D.Record(sample(), "private.arbitrary", "observed", "fixture", 1), nil)
        local byteBound = sample()
        for i = 1, 100 do
            D.Record(byteBound, "currency.large." .. i, "observed", "fixture", string.rep("x", 1024))
        end
        eq(byteBound.truncated, true)
        assert(byteBound.bytes <= 65536 and byteBound.fieldCount < 100)
    end)
    test("deterministic escaping and type filtering", function()
        local cycle = { text = '"\\\n|Hitem:1|h', fn = function() end }
        cycle.self = cycle
        local encoded = D.Serialize(cycle)
        eq(encoded, D.Serialize(cycle))
        assert(encoded:find('\\u000a', 1, true)); assert(encoded:find('\\u007c', 1, true))
        assert(not encoded:find('"fn"', 1, true)); assert(not encoded:find('"self"', 1, true))
        eq(D.Serialize(0/0), "null")
        eq(#D.Trim(string.rep("\195\169", 600), 1023), 1022)
    end)
    test("export whitelist and full bounded field set", function()
        local s = sample()
        for i = 1, 150 do D.Record(s, "currency." .. i, "observed", "fixture", i) end
        s.secret = "not exported"
        s.fields["private.secret"] = { status = "observed", value = "not exported" }
        local text = D.Export({ s })
        assert(text:find('"currency.150"', 1, true)); assert(not text:find("not exported", 1, true))
    end)
    test("empty vs unloaded equipment slot", function()
        local env = ownContext()
        env.C_Item = { DoesItemExist = function() return false end }
        local empty = D.Collect(env, sample())
        eq(empty.fields["equipment.slot.20.item"].status, "empty")
        env.C_Item.DoesItemExist = function() return true end
        env.C_Item.GetItemLink = function() return nil end
        env.C_Item.IsItemDataCached = function() return false end
        local unloaded = D.Collect(env, sample())
        eq(unloaded.fields["equipment.slot.20.link"].status, "unknown")
        eq(unloaded.fields["equipment.slot.20.cached"].value, false)
        eq(unloaded.fields["equipment.slot.20.craftedRank"].status, "unknown")
    end)
    test("rarity and crafted rank independent; rank five", function()
        local env = ownContext()
        env.C_Item = { DoesItemExist = function() return true end,
            GetItemLink = function() return "item:fixture-instance" end,
            GetItemQuality = function() return 3 end }
        env.C_TradeSkillUI.GetItemCraftedQualityByItemInfo = function(link)
            eq(link, "item:fixture-instance"); return 5
        end
        env.C_TradeSkillUI.GetItemCraftedQualityInfo = function() return { quality = 5, icon = "fixture-atlas", private = "excluded" } end
        local s = D.Collect(env, sample())
        eq(s.fields["equipment.slot.20.rarity"].value, 3)
        eq(s.fields["equipment.slot.20.craftedRank"].value, 5)
        eq(s.fields["equipment.slot.20.qualityIcons"].value.icon, "fixture-atlas")
        eq(s.fields["equipment.slot.20.qualityIcons"].value.private, nil)
        env.C_TradeSkillUI.GetItemCraftedQualityByItemInfo = function() return nil end
        eq(D.Collect(env, sample()).fields["equipment.slot.20.craftedRank"].status, "unknown")
    end)
    test("multiple stats; unknown enchant attribution", function()
        local env = ownContext()
        env.C_Item = { DoesItemExist = function() return true end,
            GetItemLink = function() return "item:fixture" end,
            GetItemStats = function() return { ITEM_MOD_CRAFTING_SPEED_SHORT = 10,
                ITEM_MOD_RESOURCEFULNESS_SHORT = 20, arbitrary = "private" } end }
        env.Enum = { TooltipDataLineType = { ItemEnchantmentPermanent = 15 } }
        env.C_TooltipInfo = { GetInventoryItem = function(unit, slot)
            eq(unit, "player"); eq(slot, 20)
            return { lines = { { type = 15, leftText = "localized enchant", private = true }, { type = 1, leftText = "not captured" } } }
        end }
        local s = D.Collect(env, sample())
        local stats = s.fields["equipment.slot.20.stats"].value
        eq(stats.ITEM_MOD_CRAFTING_SPEED_SHORT, 10); eq(stats.ITEM_MOD_RESOURCEFULNESS_SHORT, 20)
        eq(stats.arbitrary, nil)
        eq(s.fields["equipment.slot.20.enchantAttribution"].status, "unknown")
        local lines = s.fields["equipment.slot.20.permanentEnchantLines"].value
        eq(#lines.lines, 1); eq(lines.absenceVerified, false); eq(lines.lines[1].private, nil)
    end)
    test("non-player and unready contexts are not attributed", function()
        local env = ownContext()
        local calls = 0
        env.C_TradeSkillUI.GetChildProfessionInfo = function() calls = calls + 1; return {} end
        env.C_TradeSkillUI.IsTradeSkillLinked = function() return true end
        eq(D.Collect(env, sample()).fields["profession.current"].status, "unknown")
        eq(calls, 0)
        env.C_TradeSkillUI.IsTradeSkillLinked = nil
        D.Collect(env, sample()); eq(calls, 0)
    end)
    test("committed vs staged and purchased vs free knowledge", function()
        local info = { ID = 1, ranksPurchased = 2, currentRank = 5, ranksIncreased = 1, maxRanks = 10 }
        local committed = D.KnowledgeNode(info, false)
        eq(committed.committedPurchased, 2); eq(committed.currentRank, 5)
        eq(D.KnowledgeNode(info, true).committedPurchased, nil)
        eq(D.KnowledgeNode(info, nil).committedPurchasedKnown, false)
        eq(committed.capacityKnown, false)
    end)
    test("knowledge calls exclude staged currency and retain nullable cap", function()
        local env = ownContext()
        env.C_ProfSpecs = {
            GetConfigIDForSkillLine = function() return 1 end,
            GetSpecTabIDsForSkillLine = function() return { 2 } end,
            GetRootPathForTab = function() return 5 end,
            GetChildrenForPath = function() return {} end }
        local calls = 0
        env.C_Traits = {
            ConfigHasStagedChanges = function() return true end,
            GetTreeCurrencyInfo = function(config, tab, exclude)
                eq(config, 1); eq(tab, 2); eq(exclude, true); calls = calls + 1
                return { { traitCurrencyID = 4, quantity = 0, spent = 2 } }
            end,
            GetTreeNodes = function() return { 5 } end,
            GetNodeInfo = function() return { ID = 5, ranksPurchased = 3, currentRank = 8 } end }
        local s = D.Collect(env, sample())
        eq(calls, 1)
        local c = s.fields["knowledge.tab.2.currencyCommitted"].value
        eq(c.excludeStagedChanges, true); eq(c.currencies[1].quantity, 0)
        eq(c.currencies[1].maxQuantity, nil)
        eq(s.fields["knowledge.tab.2.node.5"].value.committedPurchasedKnown, false)
    end)
    test("inventory flags exclude Warband by default, opt in only", function()
        local env, calls = {}, {}
        env.C_Item = { GetItemCount = function(id, bank, uses, reagent, account)
            eq(id, 123); calls[#calls + 1] = { bank, uses, reagent, account }; return 0
        end }
        local s = D.Collect(env, sample(), {}, { itemID = 123 })
        eq(#calls, 2); eq(calls[1][1], false); eq(calls[2][1], true)
        eq(calls[2][2], false); eq(calls[2][3], true); eq(calls[2][4], false)
        eq(s.fields["inventory.123.bags.count"].value, 0)
        eq(s.fields["inventory.123.warband.count"].status, "not_applicable")
        calls = {}
        D.Collect(env, sample(), {}, { itemID = 123, warband = true })
        eq(#calls, 3); eq(calls[3][1], true); eq(calls[3][3], true); eq(calls[3][4], true)
        eq(#D.InventoryPlan("warband"), 2)
    end)
    test("Auctionator absent, candidate read-capable, unsupported: no calls", function()
        local calls = 0
        local function forbidden() calls = calls + 1; error("must not call") end
        local absent = D.Collect({}, sample())
        eq(absent.fields["auctionator.CraftArmyReadback"].status, "not_applicable")
        local addon = { API = { v1 = { GetShoppingListItems = forbidden,
            ConvertFromSearchString = forbidden, CreateShoppingList = forbidden,
            DeleteShoppingList = forbidden, MultiSearch = forbidden } }, private = "unchanged" }
        local capable = D.Collect({ Auctionator = addon }, sample())
        eq(capable.fields["auctionator.capabilities"].value.getShoppingListItemsPresent, true)
        eq(capable.fields["auctionator.CraftArmyReadback"].status, "unsupported")
        local unsupported = D.Collect({ Auctionator = {} }, sample())
        eq(unsupported.fields["auctionator.CraftArmyReadback"].status, "unsupported")
        eq(calls, 0); eq(addon.private, "unchanged")
    end)
    test("candidate currency not silently promoted to Moxie", function()
        local s = D.Collect({ C_CurrencyInfo = { GetCurrencyInfo = function() return { name = "Candidate", quantity = 0 } end } },
            sample(), {}, { currencyID = 42 })
        eq(s.fields["currency.candidate.42.info"].value.quantity, 0)
        eq(s.fields["currency.mapping"].status, "unknown")
        eq(s.fields["moxie.mapping"].status, "unknown")
    end)
    test("collector isolation: no live fallback, saved/other-addon writes or actions", function()
        local forbiddenCalls = 0
        local function forbidden() forbiddenCalls = forbiddenCalls + 1; error("forbidden action/live fallback") end
        local env = setmetatable(ownContext(), { __index = forbidden })
        env.CraftArmyDiagnosticsDB = { schema = 1, characters = { private = { retained = true } } }
        env.Auctionator = { private = { sentinel = "retained" }, API = { v1 = {
            CreateShoppingList = forbidden, DeleteShoppingList = forbidden,
            GetShoppingListItems = forbidden, MultiSearch = forbidden } } }
        env.C_TradeSkillUI.OpenTradeSkill = forbidden
        env.C_TradeSkillUI.CraftRecipe = forbidden
        env.C_Traits = { PurchaseRank = forbidden, CommitConfig = forbidden }
        local beforeSaved = D.Serialize(env.CraftArmyDiagnosticsDB)
        local beforeAddon = D.Serialize(env.Auctionator)
        local history = { sample() }
        D.Record(history[1], "currency.previous", "observed", "fixture", 10)
        local beforeHistory = D.Export(history)
        D.Collect(env, sample(), history, { itemID = 123 })
        eq(forbiddenCalls, 0)
        eq(D.Serialize(env.CraftArmyDiagnosticsDB), beforeSaved)
        eq(D.Serialize(env.Auctionator), beforeAddon)
        eq(D.Export(history), beforeHistory)
    end)
    test("R1 late invested paths in a 72-node list, not the first 64 perks", function()
        local env, calls, root = pathFixture(1)
        local s = D.CollectKnowledge(env, sample(), {}, 999)
        local r = s.fields["knowledge.tab.1.node." .. root(1)]
        eq(r.status, "observed"); eq(r.value.committedPurchased, 21)
        eq(r.value.currentRank, 22); eq(r.value.ranksIncreased, 1)
        eq(s.fields["knowledge.tab.1.node." .. (root(1) - 1)].value.ranksPurchased, 21)
        eq(s.fields["knowledge.tab.1.node.10001"], nil)
        eq(#calls.nodes, 2); eq(calls.actions, 0)
        local coverage = s.fields["knowledge.coverage"].value
        eq(coverage.policy, "paths_only"); eq(coverage.pathCaptureComplete, true)
        eq(coverage.tabs[1].rawNodeCount, 72)
        eq(coverage.tabs[1].pathsDiscovered, 2); eq(coverage.tabs[1].pathsCaptured, 2)
        eq(coverage.tabs[1].nonPathOmitted, 70)
        eq(s.truncated, nil) -- Intentional non-path omission is not a dropped path write.
    end)
    test("R1 four-tab metadata before detail and round-robin last-tree paths", function()
        local env, calls, root = pathFixture(4)
        local s = sample()
        local original = env.C_Traits.GetNodeInfo
        env.C_Traits.GetNodeInfo = function(config, id)
            for tab = 1, 4 do
                local prefix = "knowledge.tab." .. tab
                for _, key in ipairs({ ".info", ".currencyCommitted", ".rootPath", ".nodeList" }) do
                    eq(s.fields[prefix .. key].status, "observed")
                end
            end
            return original(config, id)
        end
        local old = sample()
        D.Record(old, "knowledge.tab.4.node." .. root(4), "observed", "fixture", { ranksPurchased = 7 })
        local before = D.Export({ old })
        D.CollectKnowledge(env, s, { old }, 999)
        eq(D.Export({ old }), before)
        eq(#calls.nodes, 8); eq(calls.nodes[4], root(4)); eq(calls.nodes[8], root(4) - 1)
        for tab = 1, 4 do
            eq(s.fields["knowledge.tab." .. tab .. ".node." .. root(tab)].value.committedPurchased, 21)
            eq(s.fields["knowledge.coverage"].value.tabs[tab].pathComplete, true)
        end
        eq(s.fields["knowledge.coverage"].value.tabCount, 4)
        eq(s.fields["knowledge.total"], nil) -- Shared spent=260 is never summed.
        eq(calls.actions, 0); eq(env.Auctionator.sentinel, "retained")
    end)
    test("R1 byte/field exhaustion reserves coverage without widening total bounds", function()
        local env, calls = pathFixture(4)
        local s, n = sample(), 0
        while s.bytes < 58000 do
            n = n + 1
            assert(D.Record(s, "environment.padding." .. n, "observed", "fixture", string.rep("x", 1024)))
        end
        local old = sample()
        D.Record(old, "knowledge.tab.4.rootPath", "observed", "fixture", 123)
        local before = D.Export({ old })
        D.CollectKnowledge(env, s, { old }, 999)
        eq(D.Export({ old }), before)
        eq(s.truncated, true); eq(s.knowledgeCoverageFailed, false)
        local r = s.fields["knowledge.coverage"]
        eq(r.status, "observed"); assert(r.value.budgetDrops > 0)
        eq(r.value.pathCaptureComplete, false)
        eq(r.value.tabs[4].nonPathOmitted, 70)
        local text = D.Export({ s })
        assert(text:find('"knowledge.coverage"', 1, true))
        assert(text:find('"nonPathOmitted":70', 1, true))
        assert(s.bytes <= 65536 and s.fieldCount <= 512)
        local fields = sample()
        for i = 1, 511 do assert(D.Record(fields, "currency.pad." .. i, "observed", "fixture", i)) end
        D.CollectKnowledge(env, fields, {}, 999)
        eq(fields.fieldCount, 512); eq(fields.fields["knowledge.coverage"].status, "observed")
        assert(fields.bytes <= 65536)
        local full = sample()
        for i = 1, 512 do assert(D.Record(full, "currency.pad." .. i, "observed", "fixture", i)) end
        local saved, why = D.Record(full, "currency.excess", "observed", "fixture", 1, nil, nil,
            { fields = 9999, bytes = 999999 })
        eq(saved, nil); eq(why, "field_limit") -- A section budget can never relax global bounds.
        D.CollectKnowledge(env, full, {}, 999)
        eq(full.fields["knowledge.coverage"], nil); eq(full.knowledgeCoverageFailed, true)
        assert(D.Export({ full }):find('"knowledgeCoverageFailed":true', 1, true))
        eq(full.fieldCount, 512); assert(full.bytes <= 65536); eq(calls.actions, 0)
    end)
    test("R1 cycles and failed roots/children/nodes never claim complete or empty", function()
        for _, mode in ipairs({ "cycle", "rootError", "childrenError", "nodeError", "missingRoot" }) do
            local env, calls, root = pathFixture(1)
            if mode == "cycle" then env.C_ProfSpecs.GetChildrenForPath = function() return { root(1) } end
            elseif mode == "rootError" then env.C_ProfSpecs.GetRootPathForTab = function() error("fixture") end
            elseif mode == "missingRoot" then env.C_ProfSpecs.GetRootPathForTab = nil
            elseif mode == "childrenError" then env.C_ProfSpecs.GetChildrenForPath = function() error("fixture") end
            else env.C_Traits.GetNodeInfo = function() error("fixture") end end
            local s = D.CollectKnowledge(env, sample(), {}, 999)
            local row = s.fields["knowledge.coverage"].value.tabs[1]
            eq(row.pathComplete, false)
            eq(s.fields["knowledge.coverage"].value.pathCaptureComplete, false)
            if mode == "cycle" then eq(row.repeated, true) end
            if mode == "rootError" or mode == "missingRoot" then
                eq(row.pathsDiscovered, "unknown"); eq(row.nonPathOmitted, "unknown")
                eq(#calls.nodes, 0)
            elseif mode == "childrenError" then eq(row.nonPathOmitted, "unknown")
            elseif mode == "nodeError" then
                eq(s.fields["knowledge.tab.1.node." .. root(1)].status, "error")
                eq(row.pathsCaptured, 0)
            end
            eq(calls.actions, 0)
        end
    end)
    test("R1 child/path/raw-list/tab safety limits and unknown counts are explicit", function()
        local env, _, root = pathFixture(1)
        env.C_ProfSpecs.GetChildrenForPath = function(id)
            local out = {}
            if id == root(1) then for i = 1, 17 do out[i] = id + i end end
            return out
        end
        local s = D.CollectKnowledge(env, sample(), {}, 999)
        local row = s.fields["knowledge.coverage"].value.tabs[1]
        eq(row.childLimit, true); eq(row.pathsDiscovered, 17); eq(row.pathComplete, false)
        eq(row.nonPathOmitted, "unknown")
        env.C_ProfSpecs.GetChildrenForPath = function(id) return { id + 1 } end
        s = D.CollectKnowledge(env, sample(), {}, 999)
        row = s.fields["knowledge.coverage"].value.tabs[1]
        eq(row.pathLimit, true); eq(row.pathsDiscovered, 64); eq(row.pathsCaptured, 64)
        eq(row.pathComplete, false)
        env = pathFixture(9)
        env.C_Traits.GetTreeNodes = function()
            local out = {}
            for i = 1, 129 do out[i] = i end
            return out
        end
        s = D.CollectKnowledge(env, sample(), {}, 999)
        local coverage = s.fields["knowledge.coverage"].value
        eq(coverage.tabCount, 9); eq(coverage.tabLimit, true); eq(#coverage.tabs, 8)
        eq(coverage.pathCaptureComplete, false)
        eq(coverage.tabs[8].rawNodeCount, 129); eq(coverage.tabs[8].nodeListLimit, true)
        eq(coverage.tabs[8].nonPathOmitted, "unknown")
        eq(s.knowledgeCoverageFailed, false)
        env = pathFixture(1)
        env.C_Traits.GetTreeNodes = function() return nil end
        s = D.CollectKnowledge(env, sample(), {}, 999)
        row = s.fields["knowledge.coverage"].value.tabs[1]
        eq(row.rawNodeCount, "unknown"); eq(row.nonPathOmitted, "unknown")
        eq(row.pathComplete, false)
        assert(s.bytes <= 65536 and s.fieldCount <= 512)
    end)
    return result
end
