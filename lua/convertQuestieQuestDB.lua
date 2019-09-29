require "utils"
require "loadDB"

print('CodexDB["quests"]["data"]={')

-- sort by quest id
questIds = {}
for questId,_ in pairs(QuestieDB.questData) do
    table.insert(questIds, questId)
end
table.sort(questIds)

local getValue1 = function(arr)
    return tostring(arr[1])
end
local sortByValue1 = function(a, b)
    return a[1] < b[1]
end

k = QuestieDB.questKeys
for _, questId in pairs(questIds) do
    local v = QuestieDB.questData[questId]
    printf('[%d]={', questId)

    if v[k.requiredClasses] then
        printf('["class"]=%d,', v[k.requiredClasses])
    end

    if v[k.finishedBy] then
        print('["end"]={')
        if v[k.finishedBy][1] then
            printf('["U"]=%s,', listToString(v[k.finishedBy][1]))
        end
        if v[k.finishedBy][2] then
            printf('["O"]=%s,', listToString(v[k.finishedBy][2]))
        end
        print('},')
    end

    if v[k.exclusiveTo] then
        printf('["excl"]=%s,', listToString(v[k.exclusiveTo]))
    end

    if v[k.questLevel] > 0 then
        printf('["lvl"]=%d,', v[k.questLevel])
    end
    if v[k.requiredLevel] > 0 then
        printf('["min"]=%d,', v[k.requiredLevel])
    end

    if v[k.nextQuestInChain] then
        -- if this quest is active/finished, the current quest is not available anymore
        printf('["next"]=%d,', v[k.nextQuestInChain])
    end

    if v[k.objectives] and (v[k.objectives][1] or v[k.objectives][2] or v[k.objectives][3]) then
        print('["obj"]={')
        if v[k.objectives][3] then
            printf('["I"]=%s,', listToString(v[k.objectives][3], false, getValue1, sortByValue1))
        end
        if v[k.objectives][2] then
            printf('["O"]=%s,', listToString(v[k.objectives][2], false, getValue1, sortByValue1))
        end
        if v[k.objectives][1] then
            printf('["U"]=%s,', listToString(v[k.objectives][1], false, getValue1, sortByValue1))
        end
        print('},')
    elseif v[k.startedBy] and v[k.startedBy][3] then
        print('["obj"]={')
        printf('["I"]=%s,', listToString(v[k.startedBy][3]))
        print('},')
    elseif v[k.sourceItemId] then
            print('["obj"]={')
            printf('["I"]={%d},', v[k.sourceItemId])
            print('},')
    elseif v[k.requiredSourceItems] then
        print('["obj"]={')
        printf('["I"]=%s,', listToString(v[k.requiredSourceItems]))
        print('},')
    end

    if v[k.preQuestSingle] then
        printf('["pre"]=%s,', listToString(v[k.preQuestSingle], true))
    end
    if v[k.preQuestGroup] then
        printf('["preg"]=%s,', listToString(v[k.preQuestGroup]))
    end
    
    if v[k.requiredRaces] then
        printf('["race"]=%d,', v[k.requiredRaces])
    end
    
    if v[k.requiredMinRep] then
        printf('["repu"]={["id"]=%d,["min"]=%d},', v[k.requiredMinRep][1], v[k.requiredMinRep][2])
    end

    if v[k.requiredSkill] then
        printf('["skill"]={["id"]=%d,["min"]=%d},', v[k.requiredSkill][1], v[k.requiredSkill][2])
    end

    if v[k.startedBy] and (v[k.startedBy][1] or v[k.startedBy][2]) then
        print('["start"]={')
        if v[k.startedBy][2] then
            printf('["O"]=%s,', listToString(v[k.startedBy][2]))
        end
        if v[k.startedBy][1] then
            printf('["U"]=%s,', listToString(v[k.startedBy][1]))
        end
        print('},')
    end

    print('},')
end

print('}')
