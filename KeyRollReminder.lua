local KeyRollReminder = ...

_G.KeyRollReminder = _G.KeyRollReminder or {}
KeyRollReminder = _G.KeyRollReminder

KeyRollReminderDB = KeyRollReminderDB or {}
KeyRollReminderDB.shouldRemind = KeyRollReminderDB.shouldRemind or false

KeyRollReminder.name = "KeyRollReminder"
KeyRollReminder.debug = false

function KeyRollReminder:Debug(...)
    if self.debug then
        print("|cff00ff00KeyRollReminder:|r", ...)
    end
end
