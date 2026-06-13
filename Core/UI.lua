local KeyRollReminder = _G.KeyRollReminder
local locale = GetLocale()

--[[
print("UI.lua chargé")

]]

local L = {
    reminderMessage = "Remember to roll your Mythic+ key!",
    ownedKeyFormat = "Key in your bags: %s +%d",
    ownedKeyLevelOnlyFormat = "Key in your bags: +%d",
    ownedKeyMissing = "No keystone found in your bags",
    buttonOK = "Ok",
}

if locale == "frFR" then
    L.reminderMessage = "Pense à roll ta clé Mythic+ !"
    L.ownedKeyFormat = "Cle en sac : %s +%d"
    L.ownedKeyLevelOnlyFormat = "Cle en sac : +%d"
    L.ownedKeyMissing = "Aucune cle trouvee en sac"
    L.buttonOK = "Ok chef"
end

local function SafeCall(func, ...)
    if not func then
        return nil
    end

    local ok, result = pcall(func, ...)
    if ok then
        return result
    end

    return nil
end

local function GetOwnedKeystoneInfo()
    local level = SafeCall(C_MythicPlus and C_MythicPlus.GetOwnedKeystoneLevel) or KeyRollReminder.myKeyLevel
    local mapID = SafeCall(C_MythicPlus and C_MythicPlus.GetOwnedKeystoneChallengeMapID) or KeyRollReminder.myKeyMapID
    local mapName = mapID and SafeCall(C_ChallengeMode and C_ChallengeMode.GetMapUIInfo, mapID)

    return mapName, level
end

local function GetOwnedKeystoneText()
    local mapName, level = GetOwnedKeystoneInfo()

    if not level or level <= 0 then
        return L.ownedKeyMissing
    end

    if mapName then
        return string.format(L.ownedKeyFormat, mapName, level)
    end

    return string.format(L.ownedKeyLevelOnlyFormat, level)
end

function KeyRollReminder:ShowReminder()
    --[[
    RaidNotice_AddMessage(
        RaidWarningFrame,
        L.reminderMessage,
        ChatTypeInfo["RAID_WARNING"]
    )
    
    PlaySound(8959, "Master")
    --]]

    if not self.frame then
        local frame = CreateFrame("Frame", "KeyRollReminderFrame", UIParent, "BasicFrameTemplateWithInset")
        frame:SetSize(440, 170)
        frame:SetPoint("CENTER", UIParent, "CENTER", 0, 300)
        frame:SetFrameStrata("DIALOG")
        frame.CloseButton:Hide()
        frame.CloseButton:SetScript("OnShow", frame.CloseButton.Hide)

        frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.title:SetPoint("TOP", frame, "TOP", 0, -35)
        frame.title:SetText(L.reminderMessage)

        frame.ownedKey = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.ownedKey:SetPoint("TOP", frame.title, "BOTTOM", 0, -18)
        frame.ownedKey:SetWidth(380)
        frame.ownedKey:SetJustifyH("CENTER")

        local okButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        okButton:SetSize(80, 22)
        okButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, 15)
        okButton:SetText(L.buttonOK)

        okButton:SetScript("OnClick", function()
            frame:Hide()
        end)

        self.frame = frame
    end

    self.frame.ownedKey:SetText(GetOwnedKeystoneText())
    self.frame:Show()
end
