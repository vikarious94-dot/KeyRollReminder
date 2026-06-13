local KeyRollReminder = _G.KeyRollReminder
local frame = CreateFrame("Frame")

local function HookStartButton()
    if ChallengesKeystoneFrame
        and ChallengesKeystoneFrame.StartButton
        and not KeyRollReminder.startButtonHooked then

        ChallengesKeystoneFrame.StartButton:HookScript("OnClick", function()
            KeyRollReminder.iClickedStart = true
            KeyRollReminder:Debug("Start button clicked")
        end)

        KeyRollReminder.startButtonHooked = true
        KeyRollReminder:Debug("Start button hooked")
    end
end

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("CHALLENGE_MODE_START")
frame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
frame:RegisterEvent("CHALLENGE_MODE_RESET")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...

        if addonName == "Blizzard_ChallengesUI" then
            HookStartButton()
        end

    elseif event == "PLAYER_ENTERING_WORLD" then
        C_Timer.After(1, function()
            HookStartButton()

            local instanceName, instanceType = GetInstanceInfo()
            if instanceType == "party" then
                KeyRollReminder:RefreshOwnedKeystone()
                KeyRollReminder:Debug("Entered dungeon", instanceName, "owned key", KeyRollReminder.myKeyLevel)
            end
        end)

    elseif event == "CHALLENGE_MODE_START" then
        KeyRollReminder:CaptureActiveKeystone()
        KeyRollReminderDB.shouldRemind = KeyRollReminder:ShouldRemindForCompletedRun()
        KeyRollReminder:Debug("Challenge started", "owned key", KeyRollReminder.myKeyLevel, "active key", KeyRollReminder.dungeonKeyLevel, "should remind", KeyRollReminderDB.shouldRemind)

        KeyRollReminder.iClickedStart = false

    elseif event == "CHALLENGE_MODE_COMPLETED" then
        if KeyRollReminderDB.shouldRemind then
            KeyRollReminder:ShowReminder()
            KeyRollReminder:ResetRunData()
        end

    elseif event == "CHALLENGE_MODE_RESET" then
        KeyRollReminder:ResetRunData()
    end
end)
