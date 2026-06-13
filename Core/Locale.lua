local KeyRollReminder = _G.KeyRollReminder
local locale = GetLocale()

local L = {
    reminderMessage = "Remember to roll your Mythic+ key!",
    ownedKeyFormat = "Key in your bags: %s +%d",
    ownedKeyLevelOnlyFormat = "Key in your bags: +%d",
    ownedKeyMissing = "No keystone found in your bags",
    buttonOK = "Ok",
}

if locale == "frFR" then
    L.reminderMessage = "Pense a roll ta cle Mythic+ !"
    L.ownedKeyFormat = "Cle en sac : %s +%d"
    L.ownedKeyLevelOnlyFormat = "Cle en sac : +%d"
    L.ownedKeyMissing = "Aucune cle trouvee en sac"
    L.buttonOK = "Ok chef"
end

KeyRollReminder.L = L
