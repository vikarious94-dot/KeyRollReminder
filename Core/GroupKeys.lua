local KeyRollReminder = _G.KeyRollReminder

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

local function AddGroupUnit(rows, unit)
    local name = GetUnitFullName(unit)

    if name then
        table.insert(rows, {
            name = name,
            keyText = KeyRollReminder.groupKeystones[name] or KeyRollReminder.L.groupWindowUnknownKey,
        })
    end
end

function KeyRollReminder:GetGroupKeystoneRows()
    self.groupKeystones = self.groupKeystones or {}

    local rows = {
        {
            name = string.format("%s (%s)", UnitName("player") or self.L.groupWindowYou, self.L.groupWindowYou),
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

SLASH_KEYROLLREMINDER1 = "/krr"
SLASH_KEYROLLREMINDER2 = "/keyrollreminder"
SlashCmdList.KEYROLLREMINDER = function()
    KeyRollReminder:ShowGroupKeystones()
end
