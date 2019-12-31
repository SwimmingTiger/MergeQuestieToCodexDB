local ADDON, ns = ...
local _G = _G
setfenv(1, ns)

local getValue1 = function(arr)
    local result = {}
    for _,v in ipairs(arr) do
        table.insert(result, v[1])
    end
    return result
end

function convertQuestieQuestDB()
    local db = ConvDB.quests.data

    -- sort by quest id
    local questIds = {}
    for questId,_ in pairs(QuestieDB.questData) do
        table.insert(questIds, questId)
    end
    table.sort(questIds)

    local k = QuestieDB.questKeys
    for _, questId in pairs(questIds) do
        local v = deepCopy(QuestieDB.questData[questId])

        db[questId] = {}
        local quest = db[questId]

        if v[k.requiredClasses] then
            quest.class = v[k.requiredClasses]
        end

        if v[k.finishedBy] and (v[k.finishedBy][1] or v[k.finishedBy][2]) then
            quest["end"] = {}
            if v[k.finishedBy][1] then
                quest["end"].U = v[k.finishedBy][1]
            end
            if v[k.finishedBy][2] then
                quest["end"].O = v[k.finishedBy][2]
            end
        end

        if v[k.exclusiveTo] then
            quest.excl = v[k.exclusiveTo]
        end

        if QuestieCorrections.hiddenQuests[questId] then
            quest.hide = true
        end

        if v[k.questLevel] > 0 then
            quest.lvl = v[k.questLevel]
        end
        if v[k.requiredLevel] > 0 then
            quest.min = v[k.requiredLevel]
        end

        if v[k.nextQuestInChain] then
            -- if this quest is active/finished, the current quest is not available anymore
            quest.next = v[k.nextQuestInChain]
            if type(quest.next) == 'table' and #quest.next == 1 then
                quest.next = quest.next[1]
            end
        end

        local objectItems = {}
        if v[k.objectives] and v[k.objectives][3] then
            for _,obj in pairs(v[k.objectives][3]) do
                table.insert(objectItems, obj[1])
            end
        end
        if v[k.startedBy] and v[k.startedBy][3] then
            objectItems = mergeSet(objectItems, v[k.startedBy][3])
        end
        if v[k.sourceItemId] then
            objectItems = mergeSet(objectItems, v[k.sourceItemId])
        end
        if v[k.requiredSourceItems] then
            objectItems = mergeSet(objectItems, v[k.requiredSourceItems])
        end

        if #objectItems > 0 then
            if not v[k.objectives] then
                v[k.objectives] = {nil, nil, objectItems}
            else
                v[k.objectives][3] = objectItems
            end
        end

        if v[k.objectives] and (v[k.objectives][1] or v[k.objectives][2] or v[k.objectives][3]) then
            quest.obj = {}
            if v[k.objectives][3] then
                quest.obj.I = v[k.objectives][3]
            end
            if v[k.objectives][2] then
                quest.obj.O = getValue1(v[k.objectives][2])
            end
            if v[k.objectives][1] then
                quest.obj.U = getValue1(v[k.objectives][1])
            end
        end

        if v[k.preQuestSingle] then
            quest.pre = v[k.preQuestSingle]
            if type(quest.pre) == 'table' and #quest.pre == 1 then
                quest.pre = quest.pre[1]
            end
        end
        if v[k.preQuestGroup] then
            quest.preg = v[k.preQuestGroup]
        end

        if v[k.requiredRaces] and v[k.requiredRaces]~=0 then
            quest.race = v[k.requiredRaces]
        end

        if v[k.requiredMinRep] then
            quest.repu = {
                id = v[k.requiredMinRep][1],
                min = v[k.requiredMinRep][2]
            }
        end

        if v[k.requiredSkill] then
            quest.skill = {
                id = v[k.requiredSkill][1], 
                min = v[k.requiredSkill][2]
            }
        end

        if v[k.startedBy] and (v[k.startedBy][1] or v[k.startedBy][2]) then
            quest.start = {}
            if v[k.startedBy][2] then
                quest.start.O = v[k.startedBy][2]
            end
            if v[k.startedBy][1] then
                quest.start.U = v[k.startedBy][1]
            end
        end
    end
end
