local KeyRollReminder = _G.KeyRollReminder
local L = KeyRollReminder.L

function KeyRollReminder:ShowReminder()
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

    self.frame.ownedKey:SetText(self:GetOwnedKeystoneText())
    self.frame:Show()
end
