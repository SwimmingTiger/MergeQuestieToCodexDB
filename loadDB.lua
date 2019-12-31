local ADDON, ns = ...
local _G = _G
setfenv(1, ns)

function loadDB()
    -- Database from ClassicCodex
    CodexDB = _G.CodexDB

    -- Database from Questie
    QuestieDB = _G.QuestieLoader:ImportModule("QuestieDB")
    QuestieCorrections = _G.QuestieCorrections

    -- Converted database from Questie format to ClassicCodex format
    ConvDB = {
        ["quests"] = {
            ["data"] = {}
        }
    }

    -- result
    if type(_G.CodexDatabasePatch) ~= 'table' then
        _G.CodexDatabasePatch = {}
    end
    _G.CodexDatabasePatch.quest = ''
end
