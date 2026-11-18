local _, NS = ...
local Data = {}
NS.Data = Data
-- Visual identity only: Q03 native tab observations/build70783. This private
-- catalogue is NOT an accounting/collection eligibility or topology authority.
local treePalette={{.20,.65,.95},{.20,.78,.48},{.98,.62,.20},{.70,.42,.92}}
local treeColors={
    [2906]={1140,1142,1144,1143},[2907]={1068,1069,1075,1076},
    [2909]={1155,1154,1153,1152},[2910]={1131,1176,1132,1133},
    [2913]={1122,1124,1182,1125},[2914]={1138,1136,1139,1137},
    [2915]={1158,1157,1159,1156},[2918]={1067,1070,1071,1072},
}
function Data.TreeRGB(professionID,tabID)
    for slot,id in ipairs(treeColors[professionID] or {}) do
        if tabID==id then return unpack(treePalette[slot]) end
    end
    return .45,.50,.58
end
Data.revision = "297d7aaaa736f346b3e036f38ee088eaf7f8c07f"
Data.build = "12.1.5 (70783)"
-- ProfessionConstantsDocumentation.lua: enumeration, NOT expansion skill lines.
Data.families = {
    [1]="Blacksmithing", [2]="Leatherworking", [3]="Alchemy", [7]="Tailoring",
    [8]="Engineering", [9]="Enchanting", [12]="Jewelcrafting", [13]="Inscription",
}
-- ExpansionLevelConstantsDocumentation.lua Midnight=11; 2913 is T01 client-evidenced;
-- 2909 is evidenced by the user's child-profession query 2026-11-10.
-- Remaining six crafting identities: user's batch child-profession query 2026-11-10.
Data.expansions = {
    [2913]={parentID=773, profession=13, expansionID=11, provenance="T01 user 70783"},
    [2909]={parentID=333, profession=9, expansionID=11, provenance="E01 user child-profession query 2026-11-10"},
    [2906]={parentID=171, profession=3, expansionID=11, provenance="E03 user batch child-profession query 2026-11-10"},
    [2907]={parentID=164, profession=1, expansionID=11, provenance="E03 user batch child-profession query 2026-11-10"},
    [2910]={parentID=202, profession=8, expansionID=11, provenance="E03 user batch child-profession query 2026-11-10"},
    [2914]={parentID=755, profession=12, expansionID=11, provenance="E03 user batch child-profession query 2026-11-10"},
    [2915]={parentID=165, profession=2, expansionID=11, provenance="E03 user batch child-profession query 2026-11-10"},
    [2918]={parentID=197, profession=7, expansionID=11, provenance="E03 user batch child-profession query 2026-11-10"},
}
-- Stable internal identifiers, not localized display-name lookup. Supplied entries
-- stay dormant until the corresponding profession identity is verified; gathering
-- entries are future reference only, not an expansion of crafting-only support.
Data.moxieCatalog = {
    Alchemy={id=3256, provenance="User-supplied list 2026-11-10; not native-verified"},
    Blacksmithing={id=3257, provenance="User-supplied list 2026-11-10; not native-verified"},
    Enchanting={id=3258, provenance="User native currency query/UI agreement 2026-11-10"},
    Engineering={id=3259, provenance="User-supplied list 2026-11-10; not native-verified"},
    Herbalism={id=3260, provenance="User-supplied list 2026-11-10; not native-verified"},
    Inscription={id=3261, provenance="T01 user currency query; 70783"},
    Jewelcrafting={id=3262, provenance="User-supplied list 2026-11-10; not native-verified"},
    Leatherworking={id=3263, provenance="User-supplied list 2026-11-10; not native-verified"},
    Mining={id=3264, provenance="User-supplied list 2026-11-10; not native-verified"},
    Skinning={id=3265, provenance="User-supplied list 2026-11-10; not native-verified"},
    Tailoring={id=3266, provenance="User-supplied list 2026-11-10; not native-verified"},
}
Data.moxie = { [2913]=Data.moxieCatalog.Inscription, [2909]=Data.moxieCatalog.Enchanting,
    [2906]=Data.moxieCatalog.Alchemy, [2907]=Data.moxieCatalog.Blacksmithing,
    [2910]=Data.moxieCatalog.Engineering, [2914]=Data.moxieCatalog.Jewelcrafting,
    [2915]=Data.moxieCatalog.Leatherworking, [2918]=Data.moxieCatalog.Tailoring }
Data.enchants = {
    [7977]={category="Resourcefulness", provenance="Engineering equipped diagnostic + user category 2026-11-10"},
    [8005]={category="Multicraft", provenance="T01 user ID + typed line; 70783"},
    [8035]={category="Ingenuity", provenance="User-supplied list 2026-11-10; not native-verified here"},
    [8033]={category="Deftness", provenance="User-supplied list 2026-11-10; not native-verified here"},
    [8003]={category="Finesse", provenance="User-supplied list 2026-11-10; not native-verified here"},
    [7975]={category="Perception", provenance="User-supplied list 2026-11-10; not native-verified here"},
}
-- Pinned ProfessionsCrafting.xml named Prof0/1ToolSlot and Gear0/1Slot.
-- Applied only to slots returned by GetProfessionSlots for this profession.
Data.slotRoles = { [20]="tool", [21]="accessory1", [22]="accessory2",
    [23]="tool", [24]="accessory1", [25]="accessory2" }
-- Presentation labels for stable internal categories, not localized-name parsing
-- or additional enchant-ID/API support. Tool keys and enchant categories share them.
Data.statCategories = {
    ["Crafting Speed"]={"C", "Crafting Speed"},
    Ingenuity={"I", "Ingenuity"}, Multicraft={"M", "Multicraft"},
    Resourcefulness={"R", "Resourcefulness"},
    Deftness={"D", "Deftness"}, Finesse={"F", "Finesse"}, Perception={"P", "Perception"},
}
Data.statNames = {
    ITEM_MOD_MULTICRAFT_SHORT=Data.statCategories.Multicraft,
    ITEM_MOD_RESOURCEFULNESS_SHORT=Data.statCategories.Resourcefulness,
    ITEM_MOD_CRAFTING_SPEED_SHORT=Data.statCategories["Crafting Speed"],
    ITEM_MOD_INGENUITY_SHORT=Data.statCategories.Ingenuity,
}
function Data.Identity(info)
    if type(info) ~= "table" then return nil, "No profession identity" end
    if not Data.families[info.profession] then return nil, "Not a supported crafting family" end
    local map = Data.expansions[info.professionID]
    if not map then return nil, "Midnight expansion mapping pending for skill line "..tostring(info.professionID) end
    if info.parentProfessionID ~= map.parentID or info.profession ~= map.profession then
        return nil, "Profession identity conflicts with registry"
    end
    return {skillLineID=info.professionID, parentID=map.parentID, profession=map.profession,
        expansionID=map.expansionID, name=info.professionName, expansionName=info.expansionName}
end
