local addonName, RollKeyReminder = ...

local frame = CreateFrame("Frame")
local keyLevel = C_MythicPlus.GetOwnedKeystoneLevel()

frame:RegisterEvent("CHALLENGE_MODE_START")
frame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
frame:RegisterEvent("CHALLENGE_MODE_COMPLETED_REWARDS")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "CHALLENGE_MODE_START" then
        RollKeyReminder.lastRunLevel = C_ChallengeMode.GetActiveKeystoneInfo()

    elseif event == "CHALLENGE_MODE_COMPLETED" then
        local mapID, level, time, onTime = ...
        RollKeyReminder.lastRunLevel = level
        RollKeyReminder.lastRunTimed = onTime

    elseif event == "CHALLENGE_MODE_COMPLETED_REWARDS" and RollKeyReminder.lastRunLevel >= keyLevel then
        RollKeyReminder:ShowReminder()
    end
end)