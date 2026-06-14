local KeyRollReminder = _G.KeyRollReminder
local L = KeyRollReminder.L
local ICON_PATH = "Interface\\AddOns\\KeyRollReminder\\media\\icon.tga"

local function CreateReminderFrame()
    local frame = CreateFrame("Frame", "KeyRollReminderFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(420, 145)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 300)
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    if frame.TitleText then
        frame.TitleText:SetText(KeyRollReminder.name)
    end

    frame.icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon:SetSize(42, 42)
    frame.icon:SetPoint("TOPLEFT", frame, "TOPLEFT", 22, -42)
    frame.icon:SetTexture(ICON_PATH)

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    frame.title:SetPoint("TOPLEFT", frame.icon, "TOPRIGHT", 14, 0)
    frame.title:SetPoint("RIGHT", frame, "RIGHT", -32, 0)
    frame.title:SetJustifyH("LEFT")
    frame.title:SetText(L.reminderMessage)

    frame.ownedKey = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.ownedKey:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -8)
    frame.ownedKey:SetPoint("RIGHT", frame, "RIGHT", -32, 0)
    frame.ownedKey:SetJustifyH("LEFT")

    local okButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    okButton:SetSize(86, 24)
    okButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, 16)
    okButton:SetText(L.buttonOK)

    okButton:SetScript("OnClick", function()
        frame:Hide()
    end)

    return frame
end

function KeyRollReminder:ShowReminder()
    if not self.frame then
        self.frame = CreateReminderFrame()
    end

    self.frame.ownedKey:SetText(self:GetOwnedKeystoneText())
    self.frame:Show()
end
