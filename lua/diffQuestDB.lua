package.path = package.path .. ';../../ClassicCodex/decompressed_db/?.lua;../tmp/?.lua'
require "utils"

-- load db from ClassicCodex
CodexDB = {
    ["quests"] = {
        ["data"] = {}
    }
}
require "quests"
local oldQuests = deepCopy(CodexDB.quests.data)
CodexDB = nil

-- load db from this repo's tmp dir
CodexDB = {
    ["quests"] = {
        ["data"] = {}
    }
}
require "questie-quests"
local newQuests = deepCopy(CodexDB.quests.data)
CodexDB = nil

-- output some meta info
print('-- A script to merge Questie questDB to ClassicCodex')
printf('-- ClassicCodex git tag: %s, quest num: %d', tostring(arg[1]), tablelen(oldQuests))
printf('-- Questie git tag: %s, quest num: %d', tostring(arg[2]), tablelen(newQuests))
print('local D = CodexDB.quests.data')

--[[ Compare item/object/unit list of quests and output differences as lua script
new[questId] = {
    [parent] = { -- the quest target
      ["I"] = {itemId, ...},
      ["O"] = {objectId, ...},
      ["U"] = {unitId, ...},
    },
}]]
local function compQuestsTarget(questId, new, old, parent, key, firstCall)
    if new[parent] then
        if not old[parent] then
            old[parent] = {}
            if firstCall then
                printf('D[%d].%s={}', questId, parent)
            end
        end
        if new[parent][key] then
            local merged = mergeSet(new[parent][key], old[parent][key])
            if not listCmp(merged, old[parent][key]) then
                printf('D[%d].%s.%s=%s --old: %s', questId, parent, key,
                    listToString(merged),
                    listToString(old[parent][key]))
            end
        end
    end
end

local function compQuestsListOrValue(questId, new, old, key, singleSkipBracket)
    if new[key] then
        if old[key] then
            local merged = mergeSet(new[key], old[key])
            local oldValue = valueToTable(old[key])
            if not listCmp(merged, oldValue) then
                printf('D[%d].%s=%s --old: %s', questId, key,
                    listToString(merged, singleSkipBracket),
                    listToString(oldValue, singleSkipBracket))
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

local function compQuestsTableIdMin(questId, new, old, key)
    if new[key] then
        if type(old[key]) ~= 'table' then
            printf('D[%d].%s={["id"]=%d,["min"]=%d} --old: id=%s', questId, key,
                new[key].id, new[key].min, tostring(old[key]))
        elseif old[key].id ~= new[key].id or old[key].min ~= new[key].min then
            printf('D[%d].%s={["id"]=%d,["min"]=%d} --old: id=%d,min=%d', questId, key,
                new[key].id, new[key].min, old[key].id, old[key].min)
        end
    end
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
    compQuestsValue(questId, new, old, 'next')

    compQuestsListOrValue(questId, new, old, 'excl')

    compQuestsValue(questId, new, old, 'lvl')
    compQuestsValue(questId, new, old, 'min')

    compQuestsValue(questId, new, old, 'class')
    compQuestsValue(questId, new, old, 'race')
    compQuestsTableIdMin(questId, new, old, 'skill')
    compQuestsTableIdMin(questId, new, old, 'repu')

    compQuestsValue(questId, new, old, 'hide')
end

-- sort by quest id
questIds = {}
for questId,_ in pairs(newQuests) do
    table.insert(questIds, questId)
end
table.sort(questIds)

-- Comparing each quest
for _, questId in pairs(questIds) do
    new = newQuests[questId]
    old = oldQuests[questId]

    if old then
        compQuests(questId, new, old)
    else
        printf('-- TODO: convert missing quest[%d] to lua table', questId)
    end
end
