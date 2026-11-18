local _, D = ...
local reportFrame, reportBox
local function say(text) print("CraftArmy Diagnostics: " .. text) end
local function privacy()
    say("Local diagnostic only. Reports may contain GUID, name/realm, item links and labels. Review/redact before sharing; nothing is uploaded.")
end
local function guid()
    local status, value = D.Attempt(D.Resolve(_G, "UnitGUID"), "player")
    if status == "observed" and type(value) == "string" then return value end
end
local function currentSamples(db, id)
    local character = db and db.characters[id]
    return type(character) == "table" and type(character.samples) == "table" and character.samples or {}
end
local function save(label, request)
    local id = guid()
    if not id then say("Player GUID unavailable; nothing saved"); return end
    local db, reason = D.OpenDB(CraftArmyDiagnosticsDB)
    if not db then say(reason); return end
    local _, now = D.Attempt(D.Resolve(_G, "GetServerTime"))
    local sample = D.NewSample(label, now)
    -- Collect is itself guarded in addition to individual per-field API catches.
    -- Unexpected collector bugs do not append a misleading completed sample.
    local ok = pcall(D.Collect, _G, sample, currentSamples(db, id), request)
    if not ok then say("Collector failed; no sample saved (error payload omitted)"); return end
    local stored, storeReason = D.AddSample(db, id, sample)
    if not stored then say(storeReason); return end
    CraftArmyDiagnosticsDB = db
    privacy()
    say("Saved manual sample '" .. sample.label:gsub("|", "||") .. "' (" .. sample.fieldCount ..
        " fields; latest 20 retained per character)" .. (sample.truncated and " — TRUNCATED; see limits" or ""))
end
local function showReport(text)
    if not reportFrame then
        reportFrame = CreateFrame("Frame", nil, UIParent)
        reportFrame:SetSize(800, 500)
        reportFrame:SetPoint("CENTER")
        reportFrame:SetFrameStrata("DIALOG")
        local background = reportFrame:CreateTexture(nil, "BACKGROUND")
        background:SetAllPoints()
        background:SetColorTexture(0.04, 0.04, 0.04, 0.98)
        local title = reportFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        title:SetPoint("TOPLEFT", 12, -12)
        title:SetText("CraftArmy diagnostic — local/private; select text and copy manually (Esc closes)")
        local close = CreateFrame("Button", nil, reportFrame, "UIPanelCloseButton")
        close:SetPoint("TOPRIGHT")
        local scroll = CreateFrame("ScrollFrame", nil, reportFrame, "UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", 12, -40)
        scroll:SetPoint("BOTTOMRIGHT", -32, 12)
        reportBox = CreateFrame("EditBox", nil, scroll)
        reportBox:SetMultiLine(true)
        reportBox:SetAutoFocus(false)
        reportBox:SetFontObject("ChatFontNormal")
        reportBox:SetWidth(740)
        reportBox:SetMaxLetters(2000000)
        reportBox:SetScript("OnEscapePressed", function() reportFrame:Hide() end)
        reportBox:SetScript("OnTextChanged", function(self, userInput)
            if userInput then self:SetText(self.diagnosticText or "") end
        end)
        scroll:SetScrollChild(reportBox)
    end
    reportBox.diagnosticText = text
    reportBox:SetText(text)
    reportFrame:Show()
    reportBox:SetFocus()
    reportBox:HighlightText()
end
local function positiveID(text)
    if not text or not text:match("^%d+$") then return nil end
    local id = tonumber(text)
    if D.Finite(id) and id >= 1 and id <= 2147483647 then return id end
end
local function help()
    privacy()
    say("/cad scan [label] | inventory <itemID> [warband] | currency <currencyID> | selftest | export | help")
    say("Open your own profession manually for a ready scan. No profession opening, filters, spending or Auctionator calls. Currency IDs are unverified candidates. Warband excluded unless explicitly requested.")
end
local function command(message)
    local verb, args = message:match("^%s*(%S*)%s*(.-)%s*$")
    verb = verb:lower()
    if verb == "scan" then
        save(args ~= "" and args or "scan", {})
    elseif verb == "inventory" then
        local idText, option = args:match("^(%d+)%s*(%S*)$")
        local id = positiveID(idText)
        if not id or (option ~= "" and option ~= "warband") then
            say("Usage: /cad inventory <positive itemID> [warband]"); return
        end
        save("inventory " .. id .. (option == "warband" and " warband" or ""),
            { itemID = id, warband = option == "warband" })
    elseif verb == "currency" then
        local id = positiveID(args)
        if not id then say("Usage: /cad currency <positive currencyID>"); return end
        save("unverified currency candidate " .. id, { currencyID = id })
    elseif verb == "selftest" then
        local result = D.RunSelfTests()
        say(result.passed .. "/" .. result.total .. " pure fixture cases passed; no live API evidence")
        for _, failure in ipairs(result.failures) do say(failure) end
    elseif verb == "export" then
        privacy()
        local id = guid()
        if not id then say("Player GUID unavailable"); return end
        if CraftArmyDiagnosticsDB == nil then say("No saved samples; use /cad scan"); return end
        local db, reason = D.OpenDB(CraftArmyDiagnosticsDB)
        if not db then say(reason); return end
        showReport(D.Export(currentSamples(db, id)))
    else help() end
end

SLASH_CRAFTARMYDIAGNOSTICS1 = "/cad"
SlashCmdList.CRAFTARMYDIAGNOSTICS = command
