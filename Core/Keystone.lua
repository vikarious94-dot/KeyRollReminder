local KeyRollReminder = _G.KeyRollReminder

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

function KeyRollReminder:RefreshOwnedKeystone()
    self.myKeyLevel = SafeCall(C_MythicPlus and C_MythicPlus.GetOwnedKeystoneLevel)
    self.myKeyMapID = SafeCall(C_MythicPlus and C_MythicPlus.GetOwnedKeystoneChallengeMapID)

    return self.myKeyLevel, self.myKeyMapID
end

function KeyRollReminder:GetOwnedKeystoneInfo()
    local level = SafeCall(C_MythicPlus and C_MythicPlus.GetOwnedKeystoneLevel) or self.myKeyLevel
    local mapID = SafeCall(C_MythicPlus and C_MythicPlus.GetOwnedKeystoneChallengeMapID) or self.myKeyMapID
    local mapName = mapID and SafeCall(C_ChallengeMode and C_ChallengeMode.GetMapUIInfo, mapID)

    return mapName, level, mapID
end

function KeyRollReminder:GetOwnedKeystoneText()
    local L = self.L
    local mapName, level = self:GetOwnedKeystoneInfo()

    if not level or level <= 0 then
        return L.ownedKeyMissing
    end

    if mapName then
        return string.format(L.ownedKeyFormat, mapName, level)
    end

    return string.format(L.ownedKeyLevelOnlyFormat, level)
end

function KeyRollReminder:CaptureActiveKeystone()
    self.dungeonKeyLevel = SafeCall(C_ChallengeMode and C_ChallengeMode.GetActiveKeystoneInfo)
    return self.dungeonKeyLevel
end

function KeyRollReminder:ShouldRemindForCompletedRun()
    return not self.iClickedStart
        and self.myKeyLevel
        and self.dungeonKeyLevel
        and self.dungeonKeyLevel >= self.myKeyLevel
end

function KeyRollReminder:ResetRunData()
    KeyRollReminderDB.shouldRemind = false
    self.iClickedStart = false
    self.dungeonKeyLevel = nil
    self.myKeyWasUsed = nil
    self.myKeyMapID = nil
end
