local ADDON, ns = ...
local _G = _G
setfenv(1, ns)

function diffObjectLocale()
    setPrintKey('objectLoc')

    local old = _G.CodexDB.objects.loc
    local new = QuestieDB.objectData

    local codexVersion = tostring(GetAddOnMetadata('ClassicCodex', 'Version') or '')
    local questieVersion = tostring(GetAddOnMetadata('Questie', 'Version') or '')

    -- sort by object id
    local ids = {}
    local idIndex = {}
    for id,_ in pairs(old) do
        if not idIndex[id] then
            table.insert(ids, id)
            idIndex[id] = true
        end
    end
    for id,_ in pairs(new) do
        if not idIndex[id] then
            table.insert(ids, id)
            idIndex[id] = true
        end
    end
    table.sort(ids)

    -- output some meta info
    print('-- A script to merge Questie objectDB locale to ClassicCodex')
    printf('-- ClassicCodex version: %s, object locale num: %d', codexVersion, tablelen(old))
    printf('-- Questie version: %s, object locale num: %d', questieVersion, tablelen(new))
    print("if select(4, GetAddOnInfo('MergeQuestieToCodexDB')) then return end")
    print('local D = CodexDB.objects.loc')

    local k = QuestieDB.objectKeys

    -- Comparing each unit
    for _, id in pairs(ids) do
        if not new[id] then
            --printf('-- Questie missing object loc %d', id)
        elseif new[id][k.name] and not old[id] then
            printf('D[%d]="%s"', id, string.gsub(new[id][k.name], '"', '\\"'))
        end
    end

    print('CodexDB.questiePatchVersion = CodexDB.questiePatchVersion or {}')
    printf("CodexDB.questiePatchVersion.objectLoc = '%s'", questieVersion)
end
