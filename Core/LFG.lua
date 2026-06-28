local KeyRollReminder = _G.KeyRollReminder
local IsSecretValue = issecretvalue or function()
    return false
end

local function SafeCall(func, ...)
    if not func then
        return nil
    end

    local ok, result = pcall(func, ...)
    if ok then
        return result
    end

    return nil
end

local function SafeCallValues(func, ...)
    if not func then
        return nil
    end

    local ok, value1, value2, value3, value4, value5 = pcall(func, ...)
    if ok then
        return value1, value2, value3, value4, value5
    end

    return nil
end

local function AddText(texts, text)
    if type(text) == "string" and text ~= "" and not IsSecretValue(text) then
        table.insert(texts, text)
    end
end

local function GetFirstActivityID(info)
    if type(info) ~= "table" then
        return nil
    end

    local activityID = info.activityID
    if not activityID and info.activityIDs and not IsSecretValue(info.activityIDs) then
        activityID = info.activityIDs[1]
    end

    if IsSecretValue(activityID) then
        return nil
    end

    activityID = tonumber(activityID)
    return activityID and activityID > 0 and activityID or nil
end

local function GetActivityInfo(activityID)
    if not activityID or not C_LFGList then
        return nil
    end

    local activityInfo = SafeCall(C_LFGList.GetActivityInfoTable, activityID)
    if type(activityInfo) == "table" then
        return activityInfo
    end

    local fullName, shortName, categoryID, groupID, itemLevel =
        SafeCallValues(C_LFGList.GetActivityInfo, activityID)

    if fullName or shortName then
        return {
            fullName = fullName,
            shortName = shortName,
            categoryID = categoryID,
            groupID = groupID,
            itemLevel = itemLevel,
        }
    end

    return nil
end

local function GetSearchResultInfo(searchResultID)
    if not searchResultID or not C_LFGList or not C_LFGList.GetSearchResultInfo then
        return nil
    end

    local searchInfo = SafeCall(C_LFGList.GetSearchResultInfo, searchResultID)
    if type(searchInfo) == "table" then
        return searchInfo
    end

    return nil
end

local function FindChallengeMapIDFromFields(searchInfo, activityInfo)
    local sources = { searchInfo, activityInfo }
    local fields = { "challengeMapID", "mapID", "dungeonID" }

    for _, source in ipairs(sources) do
        if type(source) == "table" then
            for _, field in ipairs(fields) do
                local value = source[field]
                local mapID = not IsSecretValue(value) and tonumber(value) or nil
                local mapName = mapID and KeyRollReminder:GetChallengeMapDisplayInfo(mapID)

                if mapName then
                    return mapID, mapName
                end
            end
        end
    end

    return nil, nil
end

local function ParseKeystoneLevel(text)
    if not text then
        return nil
    end

    local level = string.match(text, "%+(%d%d?)")
    return level and tonumber(level) or nil
end

local function BuildLFGKeystoneData(searchInfo, activityInfo)
    local texts = {}

    if type(searchInfo) == "table" then
        AddText(texts, searchInfo.name)
        AddText(texts, searchInfo.comment)
    end

    if type(activityInfo) == "table" then
        AddText(texts, activityInfo.fullName)
        AddText(texts, activityInfo.shortName)
        AddText(texts, activityInfo.name)
    end

    local mapID, mapName = FindChallengeMapIDFromFields(searchInfo, activityInfo)
    if not mapID then
        mapID, mapName = KeyRollReminder:FindChallengeMapFromText(table.concat(texts, " "))
    end

    if not mapID or not mapName then
        return nil
    end

    local level
    for _, text in ipairs(texts) do
        level = ParseKeystoneLevel(text)
        if level then
            break
        end
    end

    return {
        mapID = mapID,
        mapName = mapName,
        level = level,
    }
end

local function GetLFGKeystoneFromSearchResult(searchResultID)
    local ok, lfgKeystone = pcall(function()
        local searchInfo = GetSearchResultInfo(searchResultID)
        if type(searchInfo) ~= "table" then
            return nil
        end

        local activityInfo = GetActivityInfo(GetFirstActivityID(searchInfo))
        return BuildLFGKeystoneData(searchInfo, activityInfo)
    end)

    if not ok then
        KeyRollReminder:Debug("LFG keystone lookup failed", lfgKeystone)
        return nil
    end

    if lfgKeystone then
        KeyRollReminder:Debug("LFG keystone detected", lfgKeystone.mapName, lfgKeystone.level)
    else
        KeyRollReminder:Debug("No LFG keystone detected from search result", searchResultID)
    end

    return lfgKeystone
end

function KeyRollReminder:HandleLFGJoinedGroup(searchResultID)
    self:Debug("LFG joined group", searchResultID)
    local lfgKeystone = GetLFGKeystoneFromSearchResult(searchResultID)

    if lfgKeystone then
        self:ShowLFGTeleportPrompt(lfgKeystone)
    end
end
