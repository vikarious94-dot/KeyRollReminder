local KeyRollReminder = _G.KeyRollReminder
local PLAYER_START_GRACE_SECONDS = 10

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

local function SafeCallValues(func, ...)
    if not func then
        return nil
    end

    local ok, value1, value2, value3, value4, value5 = pcall(func, ...)
    if ok then
        return value1, value2, value3, value4, value5
    end

    return nil
end

local function GetCurrentTime()
    return GetTime and GetTime() or time()
end

function KeyRollReminder:GetChallengeMapShortName(mapName)
    if not mapName then
        return nil
    end

    local lastWord
    for word in string.gmatch(mapName, "[%a%-']+") do
        lastWord = word
    end

    if not lastWord then
        return nil
    end

    lastWord = string.gsub(lastWord, "[%-']", "")
    return string.upper(string.sub(lastWord, 1, 6))
end

function KeyRollReminder:GetChallengeMapDisplayInfo(mapID)
    if not mapID then
        return nil, nil
    end

    local mapName, _, _, texture = SafeCallValues(C_ChallengeMode and C_ChallengeMode.GetMapUIInfo, mapID)
    return mapName, texture
end

function KeyRollReminder:GetChallengeMapIconMarkup(mapID, size)
    local _, texture = self:GetChallengeMapDisplayInfo(mapID)

    if not texture then
        return nil
    end

    size = size or 22
    return string.format("|T%s:%d:%d:0:0|t", texture, size, size)
end

function KeyRollReminder:FormatKeystoneText(mapName, level, mapID)
    local L = self.L

    if not level or level <= 0 then
        return L.ownedKeyMissing
    end

    if mapName then
        local icon = self:GetChallengeMapIconMarkup(mapID)
        local shortName = self:GetChallengeMapShortName(mapName)
        local displayName = icon and string.format("%s |cff00ccff%s|r %s", icon, shortName or "", mapName) or mapName

        return string.format(L.ownedKeyFormat, displayName, level)
    end

    return string.format(L.ownedKeyLevelOnlyFormat, level)
end

function KeyRollReminder:RefreshOwnedKeystone()
    self.myKeyLevel = SafeCall(C_MythicPlus and C_MythicPlus.GetOwnedKeystoneLevel)
    self.myKeyMapID = SafeCall(C_MythicPlus and C_MythicPlus.GetOwnedKeystoneChallengeMapID)

    return self.myKeyLevel, self.myKeyMapID
end

function KeyRollReminder:GetOwnedKeystoneInfo()
    local level = SafeCall(C_MythicPlus and C_MythicPlus.GetOwnedKeystoneLevel) or self.myKeyLevel
    local mapID = SafeCall(C_MythicPlus and C_MythicPlus.GetOwnedKeystoneChallengeMapID) or self.myKeyMapID
    local mapName = self:GetChallengeMapDisplayInfo(mapID)

    return mapName, level, mapID
end

function KeyRollReminder:GetOwnedKeystoneText()
    return self:FormatKeystoneText(self:GetOwnedKeystoneInfo())
end

function KeyRollReminder:CaptureActiveKeystone()
    self.dungeonKeyLevel = SafeCall(C_ChallengeMode and C_ChallengeMode.GetActiveKeystoneInfo)
    return self.dungeonKeyLevel
end

function KeyRollReminder:MarkRunStartedByPlayer()
    self.iClickedStart = true
    self.runStartedByPlayer = true
    self.playerStartTime = GetCurrentTime()
    KeyRollReminderDB.shouldRemind = false
end

function KeyRollReminder:WasRecentlyStartedByPlayer()
    return self.playerStartTime
        and GetCurrentTime() - self.playerStartTime <= PLAYER_START_GRACE_SECONDS
end

function KeyRollReminder:ShouldRemindForCompletedRun()
    return not (self.iClickedStart or self.runStartedByPlayer or self:WasRecentlyStartedByPlayer())
        and self.myKeyLevel
        and self.dungeonKeyLevel
        and self.dungeonKeyLevel >= self.myKeyLevel
end

function KeyRollReminder:ResetRunData()
    KeyRollReminderDB.shouldRemind = false
    self.iClickedStart = false
    self.runStartedByPlayer = false
    self.dungeonKeyLevel = nil
    self.myKeyWasUsed = nil
    self.myKeyMapID = nil
end
