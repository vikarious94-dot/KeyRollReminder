local KeyRollReminder = _G.KeyRollReminder
local locale = GetLocale()

local L = {
    reminderMessage = "Remember to roll your Mythic+ key!",
    ownedKeyFormat = "Key in your bags: %s +%d",
    ownedKeyLevelOnlyFormat = "Key in your bags: +%d",
    ownedKeyMissing = "No keystone found in your bags",
    buttonOK = "Ok",
    buttonOKTooltip = "Close this reminder.",
    buttonOKTooltipShift = "Shift-click to reset the window position.",
}

if locale == "frFR" then
    L.reminderMessage = "Pense a roll ta cle Mythic+ !"
    L.ownedKeyFormat = "Cle en sac : %s +%d"
    L.ownedKeyLevelOnlyFormat = "Cle en sac : +%d"
    L.ownedKeyMissing = "Aucune cle trouvee en sac"
    L.buttonOK = "Ok chef"
    L.buttonOKTooltip = "Fermer ce rappel."
    L.buttonOKTooltipShift = "Maj-clic pour reinitialiser la position de la fenetre."
end

KeyRollReminder.L = L
