local KeyRollReminder = _G.KeyRollReminder
local L = KeyRollReminder.L
local ICON_PATH = "Interface\\AddOns\\KeyRollReminder\\media\\icon.tga"
local REMINDER_SOUND = SOUNDKIT and (SOUNDKIT.IG_MAINMENU_OPEN or SOUNDKIT.IG_CHARACTER_INFO_OPEN)
local CLOSE_SOUND = SOUNDKIT and (SOUNDKIT.IG_MAINMENU_CLOSE or SOUNDKIT.IG_CHARACTER_INFO_CLOSE)
local GROUP_ROW_HEIGHT = 34
local GROUP_MAX_ROWS = 5
local GROUP_ROWS_TOP_OFFSET = 56
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

local function CreateGroupKeystoneRow(parent, index)
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(424, GROUP_ROW_HEIGHT)
    row:SetPoint(
        "TOPLEFT",
        parent,
        "TOPLEFT",
        18,
        -GROUP_ROWS_TOP_OFFSET - ((index - 1) * GROUP_ROW_HEIGHT)
    )

    row.iconButton = CreateFrame("Button", nil, row, "InsecureActionButtonTemplate")
    row.iconButton:SetSize(28, 28)
    row.iconButton:SetPoint("LEFT", row, "LEFT", 0, 0)
    row.iconButton:RegisterForClicks("AnyDown", "AnyUp")

    row.icon = row.iconButton:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(28, 28)
    row.icon:SetAllPoints(row.iconButton)

    row.iconLabel = row.iconButton:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.iconLabel:SetPoint("BOTTOM", row.iconButton, "BOTTOM", 0, 1)
    row.iconLabel:SetJustifyH("CENTER")
    row.iconLabel:SetTextColor(1, 1, 1)
    row.iconLabel:SetShadowColor(0, 0, 0, 1)
    row.iconLabel:SetShadowOffset(1, -1)

    row.player = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.player:SetPoint("LEFT", row.iconButton, "RIGHT", 10, 0)
    row.player:SetWidth(130)
    row.player:SetJustifyH("LEFT")

    row.dungeon = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.dungeon:SetPoint("LEFT", row.player, "RIGHT", 8, 0)
    row.dungeon:SetWidth(190)
    row.dungeon:SetJustifyH("LEFT")

    row.level = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    row.level:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    row.level:SetWidth(48)
    row.level:SetJustifyH("RIGHT")

    row.unknown = row:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    row.unknown:SetPoint("LEFT", row.player, "RIGHT", 8, 0)
    row.unknown:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    row.unknown:SetJustifyH("LEFT")

    row.iconButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0)
        GameTooltip:SetText(row.teleportMapName or L.groupWindowTitle, 1, 1, 1, nil, nil)

        if InCombatLockdown() then
            GameTooltip:AddLine(L.groupTeleportInCombat, 1, 0.3, 0.3)
        elseif row.teleportSpellID then
            GameTooltip:AddLine(L.groupTeleportAvailable, 0.3, 1, 0.3)
        else
            GameTooltip:AddLine(L.groupTeleportUnavailable, 0.7, 0.7, 0.7)
        end

        GameTooltip:Show()
    end)

    row.iconButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return row
end

local function GetTeleportSpellIDSafe(mapID)
    local ok, spellID = pcall(
        KeyRollReminder.GetDungeonTeleportSpellID,
        KeyRollReminder,
        mapID
    )

    if not ok then
        KeyRollReminder:Debug("Dungeon teleport lookup failed", spellID)
        return nil
    end

    return spellID
end

local function UpdateGroupKeystoneRow(row, data)
    if not data then
        row:Hide()
        return
    end

    row:Show()
    row.player:SetText(data.name)

    if data.mapName and data.level and data.level > 0 then
        local _, texture = KeyRollReminder:GetChallengeMapDisplayInfo(data.mapID)
        local shortName = KeyRollReminder:GetChallengeMapShortName(data.mapName)
        local teleportSpellID = GetTeleportSpellIDSafe(data.mapID)

        row.icon:SetTexture(texture)
        row.iconButton:SetShown(texture ~= nil)
        row.iconLabel:SetText(shortName or "")
        row.iconLabel:SetShown(texture ~= nil and shortName ~= nil)
        row.teleportMapName = data.mapName
        row.teleportSpellID = teleportSpellID

        row.iconButton:SetAttribute("type", teleportSpellID and "spell" or nil)
        row.iconButton:SetAttribute("spell", teleportSpellID)
        row.iconButton:SetEnabled(true)
        row.icon:SetDesaturated(false)
        row.dungeon:SetText(data.mapName)
        row.dungeon:Show()
        row.level:SetText(string.format("+%d", data.level))
        row.level:Show()
        row.unknown:Hide()
    else
        row.iconButton:Hide()
        row.iconLabel:Hide()
        row.teleportMapName = nil
        row.teleportSpellID = nil

        row.iconButton:SetAttribute("type", nil)
        row.iconButton:SetAttribute("spell", nil)

        row.dungeon:Hide()
        row.level:Hide()
        row.unknown:SetText(data.keyText or L.groupWindowUnknownKey)
        row.unknown:Show()
    end
end

local function UpdateGroupKeystoneRowSafe(row, data)
    local ok, errorMessage = pcall(UpdateGroupKeystoneRow, row, data)
    if ok then
        return
    end

    KeyRollReminder:Debug("Group keystone row update failed", errorMessage)

    if not data then
        row:Hide()
        return
    end

    row:Show()
    row.iconButton:Hide()
    row.iconLabel:Hide()
    row.player:SetText(data.name or "")
    row.dungeon:Hide()
    row.level:Hide()
    row.unknown:SetText(data.keyText or L.groupWindowUnknownKey)
    row.unknown:Show()
end

local function CreateGroupKeystoneFrame()
    local frame = CreateFrame("Frame", "KeyRollReminderGroupFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(490, 255)
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
        frame.rows[i] = CreateGroupKeystoneRow(frame, i)
    end

    frame.empty = frame:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    frame.empty:SetPoint("TOPLEFT", frame.rows[2], "TOPLEFT", 38, 0)
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
    if not frame or InCombatLockdown() then
        return
    end

    local rows = self:GetGroupKeystoneRows()
    local isGrouped = IsInGroup()

    frame.empty:SetShown(not isGrouped)

    for i = 1, GROUP_MAX_ROWS do
        UpdateGroupKeystoneRowSafe(frame.rows[i], rows[i])
    end
end

function KeyRollReminder:ShowGroupKeystones()
    if InCombatLockdown() then
        print("|cff00ff00KeyRollReminder:|r", L.groupWindowCombatUnavailable)
        return
    end

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
