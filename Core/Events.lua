local KeyRollReminder = _G.KeyRollReminder
local frame = CreateFrame("Frame")

--[[
print("Events.lua chargé")

]]

local function HookStartButton()
    if ChallengesKeystoneFrame
       and ChallengesKeystoneFrame.StartButton
       and not KeyRollReminder.startButtonHooked then

        ChallengesKeystoneFrame.StartButton:HookScript("OnClick", function()
            KeyRollReminder.iClickedStart = true

            --[[
            print("J'ai cliqué sur le bouton de lancement")
            
            ]]
            

        end)

        KeyRollReminder.startButtonHooked = true

        --[[
        print("Bouton de lancement hooké")
        
        ]]
        

    end
end

local function ResetData()
    KeyRollReminderDB.shouldRemind = false
    KeyRollReminder.iClickedStart = false
    KeyRollReminder.dungeonKeyLevel = nil
    KeyRollReminder.myKeyWasUsed = nil
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
                KeyRollReminder.myKeyLevel = C_MythicPlus.GetOwnedKeystoneLevel()

                --[[
                print("Entrée en donjon :", instanceName)
                print("Ma clé :", KeyRollReminder.myKeyLevel)
                print("PLAYER_ENTERING_WORLD")
                print("shouldRemind =", tostring(KeyRollReminderDB.shouldRemind))
                
                ]]
                
            end
        end)

    elseif event == "CHALLENGE_MODE_START" then

        KeyRollReminder.dungeonKeyLevel = C_ChallengeMode.GetActiveKeystoneInfo()

        --[[
        print("Début MM+ détecté")
        print("Ma clé :", KeyRollReminder.myKeyLevel)
        print("Clé lancée :", KeyRollReminder.dungeonKeyLevel)
        print("Avant calcul :", tostring(KeyRollReminderDB.shouldRemind))
        
        ]]
        

        KeyRollReminderDB.shouldRemind =
            not KeyRollReminder.iClickedStart
            and KeyRollReminder.myKeyLevel
            and KeyRollReminder.dungeonKeyLevel
            and KeyRollReminder.dungeonKeyLevel >= KeyRollReminder.myKeyLevel

        --[[
        print("Après calcul :", tostring(KeyRollReminderDB.shouldRemind))
        
        ]]
        

        KeyRollReminder.iClickedStart = false

    elseif event == "CHALLENGE_MODE_COMPLETED" then

        --[[
        print("Donjon terminé")
        print("Reminder nécessaire :", tostring(KeyRollReminderDB.shouldRemind))
        
        ]]
        

        if KeyRollReminderDB.shouldRemind then

            --[[
            print("Affichage du reminder")
            
            ]]
            

            KeyRollReminder:ShowReminder()

            ResetData()
        end

    elseif event == "CHALLENGE_MODE_RESET" then

        ResetData()
    end
end)
