local RollKeyReminder = _G.RollKeyReminder

--[[
print("UI.lua chargé")

]]


function RollKeyReminder:ShowReminder()
    --[[
    RaidNotice_AddMessage(
        RaidWarningFrame,
        "PENSE À ROLL TA CLÉ !",
        ChatTypeInfo["RAID_WARNING"]
    )
    
    PlaySound(8959, "Master")
    --]]

    if not self.frame then
        local frame = CreateFrame("Frame", "RollKeyReminderFrame", UIParent, "BasicFrameTemplateWithInset")
        frame:SetSize(400, 150)
        frame:SetPoint("CENTER", UIParent, "CENTER", 0, 300)
        frame:SetFrameStrata("DIALOG")

        frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        frame.title:SetPoint("TOP", frame, "TOP", 0, -40)
        frame.title:SetText("Pense à roll ta clé Mythic+ !")

        local okButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        okButton:SetSize(80, 22)
        okButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, 15)
        okButton:SetText("OK Chef")

        okButton:SetScript("OnClick", function()
            frame:Hide()
        end)

        self.frame = frame
    end

    self.frame:Show()
end