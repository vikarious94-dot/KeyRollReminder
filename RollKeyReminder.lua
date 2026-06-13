local RollKeyReminder = ...

_G.RollKeyReminder = _G.RollKeyReminder or {}
RollKeyReminder = _G.RollKeyReminder

RollKeyReminderDB = RollKeyReminderDB or {}
RollKeyReminderDB.shouldRemind = RollKeyReminderDB.shouldRemind or false

RollKeyReminder.name = RollKeyReminder
RollKeyReminder.version = "1.0"
RollKeyReminder.lastReminder = 0
RollKeyReminder.lastRunLevel = nil
RollKeyReminder.lastRunTimed = nil

--[[
print("RollKeyReminder.lua chargé")
print("shouldRemind au chargement =", tostring(RollKeyReminderDB and RollKeyReminderDB.shouldRemind))

]]
