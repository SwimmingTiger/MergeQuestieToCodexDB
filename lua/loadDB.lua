package.path = package.path..';../../ClassicCodex/decompressed_db/?.lua;../../QuestieDev/Database/?.lua'

-- Mock, avoid error
function UnitFactionGroup(name)
    return nil
end

-- Database from ClassicCodex
CodexDB = {
    ["quests"] = {
        ["data"] = {}
    }
}
require "quests"

-- Database from Questie
QuestieDB = {}
require "questDB"
require "spawnDB"
require "objectDB"
require "TEMP_questie4items"
require "corrections"

for ObjectID,_ in pairs(QuestieDB.objectData) do
    if QuestieCorrections.objectFixes[ObjectID] then
        for k,v in pairs(QuestieCorrections.objectFixes[ObjectID]) do
            QuestieDB.objectData[ObjectID][k] = v
        end
    end
end

for QuestID,_ in pairs(QuestieDB.questData) do
    if QuestieCorrections.questFixes[QuestID] then
        for k,v in pairs(QuestieCorrections.questFixes[QuestID]) do
            QuestieDB.questData[QuestID][k] = v
        end
    end
end

for NPCID,_ in pairs(QuestieDB.npcData) do
    if QuestieCorrections.npcFixes[NPCID] then
        for k,v in pairs(QuestieCorrections.npcFixes[NPCID]) do
            QuestieDB.npcData[NPCID][k] = v
        end
    end
end
