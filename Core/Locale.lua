local KeyRollReminder = _G.KeyRollReminder
local locale = GetLocale()

local L = {
    reminderMessage = "Remember to roll your Mythic+ key!",
    ownedKeyFormat = "Key in your bags: %s +%d",
    ownedKeyLevelOnlyFormat = "Key in your bags: +%d",
    ownedKeyMissing = "No keystone found in your bags",
    groupWindowTitle = "Group keystones",
    groupWindowSubtitle = "Keystones known by KeyRollReminder",
    groupWindowYou = "You",
    groupWindowNoGroup = "You are not in a group.",
    groupWindowUnknownKey = "No key data yet",
    groupWindowRefresh = "Refresh",
    groupTeleportAvailable = "Click to teleport to this dungeon.",
    groupTeleportUnavailable = "Dungeon teleport not learned.",
    groupTeleportInCombat = "Dungeon teleport is unavailable in combat.",
    groupWindowCombatUnavailable = "The group keystone window cannot be opened in combat.",
    buttonOK = "Ok",
    buttonOKTooltip = "Close this reminder.",
    buttonOKTooltipShift = "Shift-click to reset the window position.",
}

if locale == "frFR" then
    L.reminderMessage = "Pense a roll ta cle Mythic+ !"
    L.ownedKeyFormat = "Cle en sac : %s +%d"
    L.ownedKeyLevelOnlyFormat = "Cle en sac : +%d"
    L.ownedKeyMissing = "Aucune cle trouvee en sac"
    L.groupWindowTitle = "Cles du groupe"
    L.groupWindowSubtitle = "Cles connues par KeyRollReminder"
    L.groupWindowYou = "Vous"
    L.groupWindowNoGroup = "Vous n'etes pas en groupe."
    L.groupWindowUnknownKey = "Aucune donnee de cle pour le moment"
    L.groupWindowRefresh = "Rafraichir"
    L.groupTeleportAvailable = "Cliquez pour vous teleporter vers ce donjon."
    L.groupTeleportUnavailable = "Teleportation vers ce donjon non apprise."
    L.groupTeleportInCombat = "La teleportation est indisponible en combat."
    L.groupWindowCombatUnavailable = "La fenetre des cles ne peut pas etre ouverte en combat."
    L.buttonOK = "Ok chef"
    L.buttonOKTooltip = "Fermer ce rappel."
    L.buttonOKTooltipShift = "Maj-clic pour reinitialiser la position de la fenetre."
end

KeyRollReminder.L = L
