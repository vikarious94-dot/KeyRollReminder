local KeyRollReminder = _G.KeyRollReminder
local frame = CreateFrame("Frame")

local function HookStartButton()
    if ChallengesKeystoneFrame
        and ChallengesKeystoneFrame.StartButton
        and not KeyRollReminder.startButtonHooked then

        ChallengesKeystoneFrame.StartButton:HookScript("OnClick", function()
            KeyRollReminder:MarkRunStartedByPlayer()
            KeyRollReminder:Debug("Run started by player")
        end)

        KeyRollReminder.startButtonHooked = true
        KeyRollReminder:Debug("Start button hooked")
    end
end

local function ScheduleStartButtonHook()
    HookStartButton()

    if C_Timer then
        C_Timer.After(0, HookStartButton)
        C_Timer.After(0.5, HookStartButton)
    end
end

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN")
frame:RegisterEvent("CHALLENGE_MODE_START")
frame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
frame:RegisterEvent("CHALLENGE_MODE_RESET")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...

        if addonName == "Blizzard_ChallengesUI" then
            ScheduleStartButtonHook()
        end

    elseif event == "PLAYER_ENTERING_WORLD" then
        C_Timer.After(1, function()
            ScheduleStartButtonHook()

            local instanceName, instanceType = GetInstanceInfo()
            if instanceType == "party" then
                KeyRollReminder:RefreshOwnedKeystone()
                KeyRollReminder:Debug("Entered dungeon", instanceName, "owned key", KeyRollReminder.myKeyLevel)
            end
        end)

    elseif event == "CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN" then
        ScheduleStartButtonHook()

    elseif event == "CHALLENGE_MODE_START" then
        KeyRollReminder:CaptureActiveKeystone()
        KeyRollReminderDB.shouldRemind = KeyRollReminder:ShouldRemindForCompletedRun()
        KeyRollReminder:Debug("Challenge started", "owned key", KeyRollReminder.myKeyLevel, "active key", KeyRollReminder.dungeonKeyLevel, "started by player", KeyRollReminder.runStartedByPlayer, "recent player start", KeyRollReminder:WasRecentlyStartedByPlayer(), "should remind", KeyRollReminderDB.shouldRemind)

        KeyRollReminder.iClickedStart = false
        KeyRollReminder.runStartedByPlayer = false

    elseif event == "CHALLENGE_MODE_COMPLETED" then
        if KeyRollReminderDB.shouldRemind then
            KeyRollReminder:ShowReminder()
            KeyRollReminder:ResetRunData()
        end

    elseif event == "CHALLENGE_MODE_RESET" then
        KeyRollReminder:ResetRunData()
    end
end)
