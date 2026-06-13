local RollKeyReminder = _G.RollKeyReminder
local frame = CreateFrame("Frame")

--[[
print("Events.lua chargé")

]]

local function HookStartButton()
    if ChallengesKeystoneFrame
       and ChallengesKeystoneFrame.StartButton
       and not RollKeyReminder.startButtonHooked then

        ChallengesKeystoneFrame.StartButton:HookScript("OnClick", function()
            RollKeyReminder.iClickedStart = true

            --[[
            print("J'ai cliqué sur le bouton de lancement")
            
            ]]
            

        end)

        RollKeyReminder.startButtonHooked = true

        --[[
        print("Bouton de lancement hooké")
        
        ]]
        

    end
end

local function ResetData()
    RollKeyReminderDB.shouldRemind = false
    RollKeyReminder.iClickedStart = false
    RollKeyReminder.dungeonKeyLevel = nil
    RollKeyReminder.myKeyWasUsed = nil
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
                RollKeyReminder.myKeyLevel = C_MythicPlus.GetOwnedKeystoneLevel()

                --[[
                print("Entrée en donjon :", instanceName)
                print("Ma clé :", RollKeyReminder.myKeyLevel)
                print("PLAYER_ENTERING_WORLD")
                print("shouldRemind =", tostring(RollKeyReminderDB.shouldRemind))
                
                ]]
                
            end
        end)

    elseif event == "CHALLENGE_MODE_START" then

        RollKeyReminder.dungeonKeyLevel = C_ChallengeMode.GetActiveKeystoneInfo()

        --[[
        print("Début MM+ détecté")
        print("Ma clé :", RollKeyReminder.myKeyLevel)
        print("Clé lancée :", RollKeyReminder.dungeonKeyLevel)
        print("Avant calcul :", tostring(RollKeyReminderDB.shouldRemind))
        
        ]]
        

        RollKeyReminderDB.shouldRemind =
            not RollKeyReminder.iClickedStart
            and RollKeyReminder.myKeyLevel
            and RollKeyReminder.dungeonKeyLevel
            and RollKeyReminder.dungeonKeyLevel >= RollKeyReminder.myKeyLevel

        --[[
        print("Après calcul :", tostring(RollKeyReminderDB.shouldRemind))
        
        ]]
        

        RollKeyReminder.iClickedStart = false

    elseif event == "CHALLENGE_MODE_COMPLETED" then

        --[[
        print("Donjon terminé")
        print("Reminder nécessaire :", tostring(RollKeyReminderDB.shouldRemind))
        
        ]]
        

        if RollKeyReminderDB.shouldRemind then

            --[[
            print("Affichage du reminder")
            
            ]]
            

            RollKeyReminder:ShowReminder()

            ResetData()
        end

    elseif event == "CHALLENGE_MODE_RESET" then

        ResetData()
    end
end)