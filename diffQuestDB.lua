local ADDON, ns = ...
local _G = _G
setfenv(1, ns)

local function compQuestsTarget(questId, new, old, parent, key, firstCall)
    if new[parent] then
        if not old[parent] then
            old[parent] = {}
            if firstCall then
                local fmt = (parent == 'end') and "D[%d]['%s']={}" or 'D[%d].%s={}'
                printf(fmt, questId, parent)
            end
        end
        if new[parent][key] then
            if not listCmp(new[parent][key], old[parent][key]) then
                local fmt = (parent == 'end') and "D[%d]['%s'].%s=%s --old: %s" or 'D[%d].%s.%s=%s --old: %s'
                printf(fmt, questId, parent, key,
                    listToString(new[parent][key]),
                    listToString(old[parent][key]))
            end
        end
    end
end

local function compQuestsListOrValue(questId, new, old, key, singleSkipBracket)
    if new[key] then
        if old[key] then
            if not listCmp(new[key], old[key]) then
                printf('D[%d].%s=%s --old: %s', questId, key,
                    listToString(new[key], singleSkipBracket),
                    listToString(old[key], singleSkipBracket))
            end
        else
            printf('D[%d].%s=%s --old: %s', questId, key,
                listToString(new[key], singleSkipBracket),
                listToString(old[key], singleSkipBracket))
        end
    end
end

local function compQuestsValue(questId, new, old, key, toStringFunction)
    if not toStringFunction then toStringFunction = tostring end
    if new[key] ~= old[key] then
        printf('D[%d].%s=%s --old: %s', questId, key, toStringFunction(new[key]), toStringFunction(old[key]))
    end
end

local function compString(questId, new, old, key)
    local toStringFunction = function(str)
        if str == nil then return 'nil' end
        return string.format('"%s"', str)
    end
    if new[key] ~= old[key] then
        printf('D[%d].%s=%s --old: %s', questId, key, toStringFunction(new[key]), toStringFunction(old[key]))
    end
end

local function compQuestsTableIdMin(questId, new, old, key)
    if new[key] then
        if type(old[key]) ~= 'table' then
            printf('D[%d].%s={id=%d,min=%d} --old: id=%s', questId, key,
                new[key].id, new[key].min, tostring(old[key]))
        elseif old[key].id ~= new[key].id or old[key].min ~= new[key].min then
            printf('D[%d].%s={id=%d,min=%d} --old: id=%d,min=%d', questId, key,
                new[key].id, new[key].min, old[key].id, old[key].min)
        end
    end
end

local function coordToString(coord)
    return string.format('{%s,%s,%s,%s},', tostring(coord[1]), tostring(coord[2]), tostring(coord[3]), tostring(coord[4]))
end

local function compCoords(id, new, old, key)
    local ncrd = new[key]
    local ocrd = old[key]

    local add, del = 0, 0
    local result = {}

    for _,o in ipairs(ocrd) do
        local ox, oy, oz = unpack(o)
        local found = false
        for _,n in ipairs(ncrd) do
            local nx, ny, nz = unpack(n)
            if nz == oz and abs(nx - ox) < 0.1 and abs(ny - oy) < 0.1 then
                found = true
                break
            end
        end
        if found then
            table.insert(result, coordToString(o))
        else
            table.insert(result, string.format('--%s --del', coordToString(o)))
            del = del + 1
        end
    end

    for _,n in ipairs(ncrd) do
        local nx, ny, nz = unpack(n)
        local found = false
        for _,o in ipairs(ocrd) do
            local ox, oy, oz = unpack(o)
            if nz == oz and abs(nx - ox) < 0.1 and abs(ny - oy) < 0.1 then
                found = true
                break
            end
        end
        if not found then
            table.insert(result, string.format('%s --add', coordToString(n)))
            add = add + 1
        end
    end

    if add == 0 and del == 0 then
        return
    end

    printf('D[%d].%s={', id, key)

    for _,v in ipairs(result) do
        print(v)
    end

    print('}')
end

-- Compare quests and output differences as lua script
local function compQuests(questId, new, old)
    compQuestsTarget(questId, new, old, 'start', 'I', true)
    compQuestsTarget(questId, new, old, 'start', 'O')
    compQuestsTarget(questId, new, old, 'start', 'U')

    compQuestsTarget(questId, new, old, 'end', 'I', true)
    compQuestsTarget(questId, new, old, 'end', 'O')
    compQuestsTarget(questId, new, old, 'end', 'U')

    compQuestsTarget(questId, new, old, 'obj', 'I', true)
    compQuestsTarget(questId, new, old, 'obj', 'O')
    compQuestsTarget(questId, new, old, 'obj', 'U')

    compQuestsListOrValue(questId, new, old, 'pre', true)
    compQuestsListOrValue(questId, new, old, 'preg')
    compQuestsListOrValue(questId, new, old, 'next')

    compQuestsListOrValue(questId, new, old, 'excl')

    compQuestsValue(questId, new, old, 'lvl')
    compQuestsValue(questId, new, old, 'min')

    compQuestsValue(questId, new, old, 'class')
    compQuestsValue(questId, new, old, 'race')
    compQuestsTableIdMin(questId, new, old, 'skill')
    compQuestsTableIdMin(questId, new, old, 'repu')

    compQuestsValue(questId, new, old, 'hide')
end

-- Compare unit and output differences as lua script
local function compUnits(id, new, old)
    compCoords(id, new, old, 'coords')
    compString(id, new, old, 'fac')
    compString(id, new, old, 'lvl')
    compString(id, new, old, 'rnk')
end

function diffQuestDB()
    setPrintKey('quest')

    local oldQuests = _G.CodexDB.quests.data
    local newQuests = ConvDB.quests.data

    local codexVersion = tostring(GetAddOnMetadata('ClassicCodex', 'Version') or '')
    local questieVersion = tostring(GetAddOnMetadata('Questie', 'Version') or '')

    -- output some meta info
    print('-- A script to merge Questie questDB to ClassicCodex')
    printf('-- ClassicCodex version: %s, quest num: %d', codexVersion, tablelen(oldQuests))
    printf('-- Questie version: %s, quest num: %d', questieVersion, tablelen(newQuests))
    print("if select(4, GetAddOnInfo('MergeQuestieToCodexDB')) then return end")
    print('local D = CodexDB.quests.data')

    --[[ Compare item/object/unit list of quests and output differences as lua script
    new[questId] = {
        [parent] = { -- the quest target
        ["I"] = {itemId, ...},
        ["O"] = {objectId, ...},
        ["U"] = {unitId, ...},
        },
    }]]

    -- sort by quest id
    local questIds = {}
    local questIdIndex = {}
    for questId,_ in pairs(oldQuests) do
        if not questIdIndex[questId] then
            table.insert(questIds, questId)
            questIdIndex[questId] = true
        end
    end
    for questId,_ in pairs(newQuests) do
        if not questIdIndex[questId] then
            table.insert(questIds, questId)
            questIdIndex[questId] = true
        end
    end
    table.sort(questIds)

    -- Comparing each quest
    for _, questId in pairs(questIds) do
        local new = deepCopy(newQuests[questId])
        local old = deepCopy(oldQuests[questId])

        if old then
            if new then
                compQuests(questId, new, old)
            else
                printf('-- Questie missing quest %d', questId)
            end
        else
            printf('-- TODO: convert missing quest[%d] to lua table', questId)
        end
    end

    print('CodexDB.questiePatchVersion = CodexDB.questiePatchVersion or {}')
    printf("CodexDB.questiePatchVersion.quest = '%s'", questieVersion)
end

function diffUnitDB()
    setPrintKey('unit'..UnitFactionGroup('player'))

    local oldUnit = _G.CodexDB.units.data
    local newUnit = ConvDB.units.data

    local codexVersion = tostring(GetAddOnMetadata('ClassicCodex', 'Version') or '')
    local questieVersion = tostring(GetAddOnMetadata('Questie', 'Version') or '')

    -- output some meta info
    print('-- A script to merge Questie questDB to ClassicCodex')
    printf('-- ClassicCodex version: %s, unit num: %d', codexVersion, tablelen(oldUnit))
    printf('-- Questie version: %s, unit num: %d', questieVersion, tablelen(newUnit))
    print("if select(4, GetAddOnInfo('MergeQuestieToCodexDB')) then return end")
    print('local D = CodexDB.units.data')

    -- sort by unit id
    local ids = {}
    local idIndex = {}
    for id,_ in pairs(oldUnit) do
        if not idIndex[id] then
            table.insert(ids, id)
            idIndex[id] = true
        end
    end
    for id,_ in pairs(newUnit) do
        if not idIndex[id] then
            table.insert(ids, id)
            idIndex[id] = true
        end
    end
    table.sort(ids)

    -- Comparing each unit
    for _, id in pairs(ids) do
        local new = deepCopy(newUnit[id])
        local old = deepCopy(oldUnit[id])

        if old then
            if new then
                compUnits(id, new, old)
            else
                printf('-- Questie missing unit %d', id)
            end
        else
            printf('-- TODO: convert missing unit[%d] to lua table', id)
        end
    end

    print('CodexDB.questiePatchVersion = CodexDB.questiePatchVersion or {}')
    printf("CodexDB.questiePatchVersion.unit = '%s'", questieVersion)
end
