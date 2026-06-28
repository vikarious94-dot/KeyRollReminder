local KeyRollReminder = _G.KeyRollReminder
local L = KeyRollReminder.L
local ICON_PATH = "Interface\\AddOns\\KeyRollReminder\\media\\icon.tga"
local REMINDER_SOUND = SOUNDKIT and (SOUNDKIT.IG_MAINMENU_OPEN or SOUNDKIT.IG_CHARACTER_INFO_OPEN)
local CLOSE_SOUND = SOUNDKIT and (SOUNDKIT.IG_MAINMENU_CLOSE or SOUNDKIT.IG_CHARACTER_INFO_CLOSE)
local GROUP_ROW_HEIGHT = 34
local GROUP_MAX_ROWS = 6
local GROUP_ROWS_TOP_OFFSET = 56
local LFG_PROMPT_ICON_SIZE = 46
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

local SetTeleportButtonTooltip

local function FormatCooldownTime(seconds)
    seconds = math.max(0, math.ceil(seconds or 0))

    if seconds >= 3600 then
        local hours = math.floor(seconds / 3600)
        local minutes = math.floor((seconds % 3600) / 60)
        return string.format("%dh %02dm", hours, minutes)
    end

    if seconds >= 60 then
        local minutes = math.floor(seconds / 60)
        local remainingSeconds = seconds % 60
        return string.format("%dm %02ds", minutes, remainingSeconds)
    end

    return string.format("%ds", seconds)
end

local function GetSpellCooldownRemaining(spellID)
    if not spellID or not C_Spell or not C_Spell.GetSpellCooldown then
        return nil
    end

    local cooldownInfo = C_Spell.GetSpellCooldown(spellID)
    if not cooldownInfo or not cooldownInfo.startTime or not cooldownInfo.duration then
        return nil
    end

    if cooldownInfo.duration <= 0 then
        return nil
    end

    local remaining = cooldownInfo.startTime + cooldownInfo.duration - GetTime()
    return remaining > 0 and remaining or nil
end

local function UpdateLFGTeleportPromptStatus(frame)
    if not frame or not frame.status or not frame.iconButton then
        return
    end

    local remaining = GetSpellCooldownRemaining(frame.iconButton.teleportSpellID)
    if remaining then
        frame.status:SetText(FormatCooldownTime(remaining))
        frame.status:SetTextColor(1, 0.82, 0)
        frame.iconButton.icon:SetDesaturated(true)
    else
        frame.status:SetText(L.lfgTeleportReady)
        frame.status:SetTextColor(0.3, 1, 0.3)
        frame.iconButton.icon:SetDesaturated(false)
    end
end

local function StopLFGTeleportStatusTicker()
    if KeyRollReminder.lfgTeleportStatusTicker then
        KeyRollReminder.lfgTeleportStatusTicker:Cancel()
        KeyRollReminder.lfgTeleportStatusTicker = nil
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
    row.iconButton:SetSize(424, GROUP_ROW_HEIGHT)
    row.iconButton:SetPoint("LEFT", row, "LEFT", 0, 0)
    row.iconButton:RegisterForClicks("AnyDown", "AnyUp")

    row.icon = row.iconButton:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(28, 28)
    row.icon:SetPoint("LEFT", row.iconButton, "LEFT", 0, 0)
    row.iconButton.icon = row.icon

    row.iconLabel = row.iconButton:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.iconLabel:SetPoint("BOTTOM", row.icon, "BOTTOM", 0, 1)
    row.iconLabel:SetJustifyH("CENTER")
    row.iconLabel:SetTextColor(1, 1, 1)
    row.iconLabel:SetShadowColor(0, 0, 0, 1)
    row.iconLabel:SetShadowOffset(1, -1)
    row.iconButton.iconLabel = row.iconLabel

    row.player = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.player:SetPoint("LEFT", row.icon, "RIGHT", 10, 0)
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

    SetTeleportButtonTooltip(row.iconButton)

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

local function ConfigureTeleportButton(button, mapID, mapName)
    local _, texture = KeyRollReminder:GetChallengeMapDisplayInfo(mapID)
    local shortName = KeyRollReminder:GetChallengeMapShortName(mapName)
    local teleportSpellID = GetTeleportSpellIDSafe(mapID)

    button.icon:SetTexture(texture)
    button.icon:SetShown(texture ~= nil)
    button.iconLabel:SetText(shortName or "")
    button.iconLabel:SetShown(texture ~= nil and shortName ~= nil)
    button.teleportMapName = mapName
    button.teleportSpellID = teleportSpellID

    button:SetAttribute("type", teleportSpellID and "spell" or nil)
    button:SetAttribute("spell", teleportSpellID)
    button:SetEnabled(true)
    button.icon:SetDesaturated(false)

    return texture, teleportSpellID
end

SetTeleportButtonTooltip = function(button)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0)
        GameTooltip:SetText(self.teleportMapName or L.groupWindowTitle, 1, 1, 1, nil, nil)

        if InCombatLockdown() then
            GameTooltip:AddLine(L.groupTeleportInCombat, 1, 0.3, 0.3)
        elseif self.teleportSpellID then
            GameTooltip:AddLine(L.groupTeleportAvailable, 0.3, 1, 0.3)
        else
            GameTooltip:AddLine(L.groupTeleportUnavailable, 0.7, 0.7, 0.7)
        end

        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

local function UpdateGroupKeystoneRow(row, data)
    if not data then
        row:Hide()
        return
    end

    row:Show()
    row.player:SetText(data.name)

    if data.mapName and data.mapID then
        local texture = ConfigureTeleportButton(row.iconButton, data.mapID, data.mapName)
        row.iconButton:SetShown(texture ~= nil)
        row.dungeon:SetText(data.mapName)
        row.dungeon:Show()
        local hasLevel = data.level and data.level > 0
        row.level:SetText(hasLevel and string.format("+%d", data.level) or "")
        row.level:SetShown(hasLevel == true)
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
    frame:SetSize(490, 289)
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

local function CreateLFGTeleportPromptFrame()
    local frame = CreateFrame("Frame", "KeyRollReminderLFGTeleportFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(168, 92)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 210)
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    if frame.TitleText then
        frame.TitleText:SetText(L.lfgTeleportWindowTitle)
    end

    frame.iconButton = CreateFrame("Button", nil, frame, "InsecureActionButtonTemplate")
    frame.iconButton:SetSize(LFG_PROMPT_ICON_SIZE, LFG_PROMPT_ICON_SIZE)
    frame.iconButton:SetPoint("LEFT", frame, "LEFT", 18, -6)
    frame.iconButton:RegisterForClicks("AnyDown", "AnyUp")

    frame.iconButton.icon = frame.iconButton:CreateTexture(nil, "ARTWORK")
    frame.iconButton.icon:SetAllPoints(frame.iconButton)

    frame.iconButton.iconLabel = frame.iconButton:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.iconButton.iconLabel:SetPoint("BOTTOM", frame.iconButton, "BOTTOM", 0, 2)
    frame.iconButton.iconLabel:SetJustifyH("CENTER")
    frame.iconButton.iconLabel:SetTextColor(1, 1, 1)
    frame.iconButton.iconLabel:SetShadowColor(0, 0, 0, 1)
    frame.iconButton.iconLabel:SetShadowOffset(1, -1)

    frame.status = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.status:SetPoint("LEFT", frame.iconButton, "RIGHT", 10, 0)
    frame.status:SetPoint("RIGHT", frame, "RIGHT", -12, 0)
    frame.status:SetJustifyH("LEFT")
    frame.status:SetText(L.lfgTeleportReady)

    SetTeleportButtonTooltip(frame.iconButton)
    tinsert(UISpecialFrames, "KeyRollReminderLFGTeleportFrame")

    return frame
end

function KeyRollReminder:ShowLFGTeleportPrompt(lfgKeystone)
    if not lfgKeystone or not lfgKeystone.mapID or not lfgKeystone.mapName then
        return
    end

    if not GetTeleportSpellIDSafe(lfgKeystone.mapID) then
        self:Debug("LFG teleport prompt skipped, teleport not learned", lfgKeystone.mapName)
        return
    end

    if InCombatLockdown() then
        self.pendingLFGTeleportPrompt = lfgKeystone
        return
    end

    if not self.lfgTeleportFrame then
        self.lfgTeleportFrame = CreateLFGTeleportPromptFrame()
    end

    ConfigureTeleportButton(self.lfgTeleportFrame.iconButton, lfgKeystone.mapID, lfgKeystone.mapName)
    UpdateLFGTeleportPromptStatus(self.lfgTeleportFrame)
    self.lfgTeleportFrame:Show()

    if C_Timer and C_Timer.NewTicker then
        StopLFGTeleportStatusTicker()

        self.lfgTeleportStatusTicker = C_Timer.NewTicker(1, function()
            if not self.lfgTeleportFrame or not self.lfgTeleportFrame:IsShown() then
                StopLFGTeleportStatusTicker()
                return
            end

            UpdateLFGTeleportPromptStatus(self.lfgTeleportFrame)
        end)
    end

    if REMINDER_SOUND then
        PlaySound(REMINDER_SOUND, "Master")
    end
end

function KeyRollReminder:HideLFGTeleportPrompt()
    self.pendingLFGTeleportPrompt = nil

    if not self.lfgTeleportFrame or not self.lfgTeleportFrame:IsShown() then
        self.pendingLFGTeleportHide = nil
        return
    end

    if InCombatLockdown() then
        self.pendingLFGTeleportHide = true
        return
    end

    self.pendingLFGTeleportHide = nil
    StopLFGTeleportStatusTicker()
    self.lfgTeleportFrame:Hide()
end

function KeyRollReminder:FlushLFGTeleportPrompt()
    if self.pendingLFGTeleportHide then
        self.pendingLFGTeleportHide = nil
        self:HideLFGTeleportPrompt()
    end

    if self.pendingLFGTeleportPrompt then
        local lfgKeystone = self.pendingLFGTeleportPrompt
        self.pendingLFGTeleportPrompt = nil
        self:ShowLFGTeleportPrompt(lfgKeystone)
    end
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
