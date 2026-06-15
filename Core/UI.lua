local KeyRollReminder = _G.KeyRollReminder
local L = KeyRollReminder.L
local ICON_PATH = "Interface\\AddOns\\KeyRollReminder\\media\\icon.tga"
local REMINDER_SOUND = SOUNDKIT and (SOUNDKIT.IG_MAINMENU_OPEN or SOUNDKIT.IG_CHARACTER_INFO_OPEN)
local CLOSE_SOUND = SOUNDKIT and (SOUNDKIT.IG_MAINMENU_CLOSE or SOUNDKIT.IG_CHARACTER_INFO_CLOSE)
local GROUP_ROW_HEIGHT = 22
local GROUP_MAX_ROWS = 5
local DEFAULT_POSITION = {
    point = "CENTER",
    relativePoint = "CENTER",
    x = 0,
    y = 300,
}

local function RestoreFramePosition(frame)
    local position = KeyRollReminderDB.reminderFramePosition or DEFAULT_POSITION

    if frame.SetDontSavePosition then
        frame:SetDontSavePosition(true)
    end

    frame:ClearAllPoints()

    if position.point == "TOPLEFT" and not position.relativePoint then
        frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", position.x or 0, position.y or 0)
        return
    end

    frame:SetPoint(
        position.point or DEFAULT_POSITION.point,
        UIParent,
        position.relativePoint or DEFAULT_POSITION.relativePoint,
        position.x or DEFAULT_POSITION.x,
        position.y or DEFAULT_POSITION.y
    )
end

local function SaveFramePosition(frame)
    local point, _, relativePoint, x, y = frame:GetPoint()

    if not point then
        return
    end

    KeyRollReminderDB.reminderFramePosition = {
        point = point,
        relativePoint = relativePoint or DEFAULT_POSITION.relativePoint,
        x = x or DEFAULT_POSITION.x,
        y = y or DEFAULT_POSITION.y,
    }
end

function KeyRollReminder:ResetReminderPosition()
    KeyRollReminderDB.reminderFramePosition = nil

    if self.frame then
        RestoreFramePosition(self.frame)
    end
end

local function CreateGroupKeystoneFrame()
    local frame = CreateFrame("Frame", "KeyRollReminderGroupFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(460, 230)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 120)
    frame:SetFrameStrata("DIALOG")

    if frame.TitleText then
        frame.TitleText:SetText(L.groupWindowTitle)
    end

    frame.subtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.subtitle:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -36)
    frame.subtitle:SetText(L.groupWindowSubtitle)

    frame.rows = {}
    for i = 1, GROUP_MAX_ROWS do
        local row = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        row:SetPoint("TOPLEFT", frame.subtitle, "BOTTOMLEFT", 0, -12 - ((i - 1) * GROUP_ROW_HEIGHT))
        row:SetPoint("RIGHT", frame, "RIGHT", -18, 0)
        row:SetJustifyH("LEFT")
        frame.rows[i] = row
    end

    frame.empty = frame:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    frame.empty:SetPoint("TOPLEFT", frame.rows[2], "TOPLEFT", 0, 0)
    frame.empty:SetPoint("RIGHT", frame, "RIGHT", -18, 0)
    frame.empty:SetJustifyH("LEFT")
    frame.empty:SetText(L.groupWindowNoGroup)

    local refreshButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    refreshButton:SetSize(96, 24)
    refreshButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -18, 16)
    refreshButton:SetText(L.groupWindowRefresh)
    refreshButton:SetScript("OnClick", function()
        KeyRollReminder:UpdateGroupKeystoneFrame()
    end)

    tinsert(UISpecialFrames, "KeyRollReminderGroupFrame")

    return frame
end

function KeyRollReminder:UpdateGroupKeystoneFrame()
    local frame = self.groupFrame
    if not frame then
        return
    end

    local rows = self:GetGroupKeystoneRows()
    local isGrouped = IsInGroup()

    frame.empty:SetShown(not isGrouped)

    for i = 1, GROUP_MAX_ROWS do
        local data = rows[i]
        if data then
            frame.rows[i]:SetText(string.format("%s: %s", data.name, data.keyText))
            frame.rows[i]:Show()
        else
            frame.rows[i]:Hide()
        end
    end
end

function KeyRollReminder:ShowGroupKeystones()
    if not self.groupFrame then
        self.groupFrame = CreateGroupKeystoneFrame()
    end

    self:UpdateGroupKeystoneFrame()
    self.groupFrame:Show()
end

local function CreateReminderFrame()
    local frame = CreateFrame("Frame", "KeyRollReminderFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(420, 145)
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    if frame.SetDontSavePosition then
        frame:SetDontSavePosition(true)
    end
    RestoreFramePosition(frame)
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SaveFramePosition(self)
    end)
    frame:SetScript("OnHide", function(self)
        SaveFramePosition(self)

        if CLOSE_SOUND then
            PlaySound(CLOSE_SOUND, "Master")
        end
    end)

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
        if IsShiftKeyDown() then
            KeyRollReminder:ResetReminderPosition()
            return
        end

        frame:Hide()
    end)

    okButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0)
        GameTooltip:SetText(L.buttonOK, 1, 1, 1, nil, nil)
        GameTooltip:AddLine(L.buttonOKTooltip, 1, 1, 1)
        GameTooltip:AddLine(L.buttonOKTooltipShift, 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)

    okButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    tinsert(UISpecialFrames, "KeyRollReminderFrame")

    return frame
end

function KeyRollReminder:ShowReminder()
    if not self.frame then
        self.frame = CreateReminderFrame()
    end

    self.frame.ownedKey:SetText(self:GetOwnedKeystoneText())
    self.frame:Show()
    RestoreFramePosition(self.frame)

    if C_Timer then
        C_Timer.After(0, function()
            if self.frame and self.frame:IsShown() then
                RestoreFramePosition(self.frame)
            end
        end)
    end

    if REMINDER_SOUND then
        PlaySound(REMINDER_SOUND, "Master")
    end
end
