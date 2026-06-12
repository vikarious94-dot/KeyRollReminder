local addonName, RollKeyReminder = ...

function RollKeyReminder:ShowReminder()
    local level = self.lastRunLevel or "?"

    print("|cffffcc00[RollKeyReminder]|r Pense à roll ta clé +" .. level .. " !")

    RaidNotice_AddMessage(
        RaidWarningFrame,
        "PENSE À ROLL TA CLÉ +" .. level .. " !",
        ChatTypeInfo["RAID_WARNING"]
    )

    PlaySound(8959, "Master")
end