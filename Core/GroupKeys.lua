local KeyRollReminder = _G.KeyRollReminder
local ADDON_MESSAGE_PREFIX = "KRR"
local MESSAGE_REQUEST = "REQ"
local MESSAGE_NO_KEY = "NOKEY"

local function GetUnitFullName(unit)
    local name, realm = UnitName(unit)

    if not name then
        return nil
    end

    if realm and realm ~= "" then
        return name .. "-" .. realm
    end

    return name
end

local function GetMessageChannel()
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        return "INSTANCE_CHAT"
    end

    if IsInRaid() then
        return "RAID"
    end

    if IsInGroup() then
        return "PARTY"
    end

    return nil
end

local function StoreGroupKeystone(sender, mapID, level)
    KeyRollReminder.groupKeystones = KeyRollReminder.groupKeystones or {}

    local mapName = KeyRollReminder:GetChallengeMapDisplayInfo(mapID)
    local keyData = {
        mapID = mapID,
        mapName = mapName,
        level = level,
    }

    KeyRollReminder.groupKeystones[sender] = keyData
    KeyRollReminder.groupKeystones[Ambiguate(sender, "short")] = keyData
end

local function StoreNoKeystone(sender)
    KeyRollReminder.groupKeystones = KeyRollReminder.groupKeystones or {}
    KeyRollReminder.groupKeystones[sender] = KeyRollReminder.L.ownedKeyMissing
    KeyRollReminder.groupKeystones[Ambiguate(sender, "short")] = KeyRollReminder.L.ownedKeyMissing
end

local function BuildOwnedKeystoneMessage()
    local _, level, mapID = KeyRollReminder:GetOwnedKeystoneInfo()

    if not level or level <= 0 or not mapID then
        return MESSAGE_NO_KEY
    end

    return string.format("KEY:%d:%d", mapID, level)
end

local function IsSenderPlayer(sender)
    local playerName = UnitName("player")

    return sender == playerName
        or sender == GetUnitFullName("player")
        or Ambiguate(sender, "short") == playerName
end

local function AddGroupUnit(rows, unit)
    local name = GetUnitFullName(unit)

    if name then
        local keyData = KeyRollReminder.groupKeystones[name]
        if type(keyData) == "table" then
            table.insert(rows, {
                name = name,
                mapName = keyData.mapName,
                level = keyData.level,
                mapID = keyData.mapID,
                keyText = keyData.keyText,
            })

            return
        end

        table.insert(rows, {
            name = name,
            keyText = keyData or KeyRollReminder.L.groupWindowUnknownKey,
        })
    end
end

function KeyRollReminder:GetGroupKeystoneRows()
    self.groupKeystones = self.groupKeystones or {}

    local mapName, level, mapID = self:GetOwnedKeystoneInfo()
    local rows = {
        {
            name = string.format("%s (%s)", UnitName("player") or self.L.groupWindowYou, self.L.groupWindowYou),
            mapName = mapName,
            level = level,
            mapID = mapID,
            keyText = self:GetOwnedKeystoneText(),
        },
    }

    if IsInRaid() then
        for i = 1, GetNumGroupMembers() do
            if not UnitIsUnit("raid" .. i, "player") then
                AddGroupUnit(rows, "raid" .. i)
            end
        end
    elseif IsInGroup() then
        for i = 1, 4 do
            AddGroupUnit(rows, "party" .. i)
        end
    end

    return rows
end

function KeyRollReminder:RegisterGroupKeystoneMessages()
    if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
        C_ChatInfo.RegisterAddonMessagePrefix(ADDON_MESSAGE_PREFIX)
    end
end

function KeyRollReminder:SendGroupKeystoneMessage(message)
    local channel = GetMessageChannel()

    if not channel or not C_ChatInfo or not C_ChatInfo.SendAddonMessage then
        return
    end

    C_ChatInfo.SendAddonMessage(ADDON_MESSAGE_PREFIX, message, channel)
end

function KeyRollReminder:BroadcastOwnedKeystone()
    self:SendGroupKeystoneMessage(BuildOwnedKeystoneMessage())
end

function KeyRollReminder:RequestGroupKeystones()
    self:SendGroupKeystoneMessage(MESSAGE_REQUEST)
    self:BroadcastOwnedKeystone()
end

function KeyRollReminder:HandleGroupKeystoneMessage(prefix, message, sender)
    if prefix ~= ADDON_MESSAGE_PREFIX or not message or not sender then
        return
    end

    if IsSenderPlayer(sender) then
        return
    end

    if message == MESSAGE_REQUEST then
        self:BroadcastOwnedKeystone()
        return
    end

    if message == MESSAGE_NO_KEY then
        StoreNoKeystone(sender)
    else
        local mapID, level = string.match(message, "^KEY:(%d+):(%d+)$")
        if not mapID or not level then
            return
        end

        StoreGroupKeystone(sender, tonumber(mapID), tonumber(level))
    end

    if self.groupFrame and self.groupFrame:IsShown() then
        self:UpdateGroupKeystoneFrame()
    end
end

function KeyRollReminder:ClearGroupKeystoneCache()
    self.groupKeystones = {}
end

SLASH_KEYROLLREMINDER1 = "/krr"
SLASH_KEYROLLREMINDER2 = "/keyrollreminder"
SlashCmdList.KEYROLLREMINDER = function()
    KeyRollReminder:ShowGroupKeystones()
    KeyRollReminder:RequestGroupKeystones()
end

KeyRollReminder:RegisterGroupKeystoneMessages()
