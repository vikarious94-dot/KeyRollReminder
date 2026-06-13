local KeyRollReminder = ...

_G.KeyRollReminder = _G.KeyRollReminder or {}
KeyRollReminder = _G.KeyRollReminder

KeyRollReminderDB = KeyRollReminderDB or {}
KeyRollReminderDB.shouldRemind = KeyRollReminderDB.shouldRemind or false

KeyRollReminder.name = "KeyRollReminder"
KeyRollReminder.version = "1.0"
KeyRollReminder.lastReminder = 0
KeyRollReminder.lastRunLevel = nil
KeyRollReminder.lastRunTimed = nil

--[[
print("KeyRollReminder.lua chargé")
print("shouldRemind au chargement =", tostring(KeyRollReminderDB and KeyRollReminderDB.shouldRemind))

]]
