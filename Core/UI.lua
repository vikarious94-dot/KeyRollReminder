local KeyRollReminder = _G.KeyRollReminder
local locale = GetLocale()

--[[
print("UI.lua chargé")

]]

local L = {
    reminderMessage = "Remember to roll your Mythic+ key!",
    buttonOK = "Ok",
}

if locale == "frFR" then
    L.reminderMessage = "Pense à roll ta clé Mythic+ !"
    L.buttonOK = "Ok chef"
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
        frame:SetSize(400, 150)
        frame:SetPoint("CENTER", UIParent, "CENTER", 0, 300)
        frame:SetFrameStrata("DIALOG")
        frame.CloseButton:Hide()
        frame.CloseButton:SetScript("OnShow", frame.CloseButton.Hide)

        frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.title:SetPoint("TOP", frame, "TOP", 0, -40)
        frame.title:SetText(L.reminderMessage)

        local okButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        okButton:SetSize(80, 22)
        okButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, 15)
        okButton:SetText(L.buttonOK)

        okButton:SetScript("OnClick", function()
            frame:Hide()
        end)

        self.frame = frame
    end

    self.frame:Show()
end
