local ADDON, ns = ...
local _G = _G
setfenv(1, ns)

function loadDB()
    -- Database from ClassicCodex
    CodexDB = _G.CodexDB

    -- Database from Questie
    QuestieDB = _G.QuestieLoader:ImportModule("QuestieDB")
    QuestieCorrections = _G.QuestieLoader:ImportModule("QuestieCorrections")

    -- Converted database from Questie format to ClassicCodex format
    ConvDB = {
        ["quests"] = {
            ["data"] = {}
        },
        ["units"] = {
            ["data"] = {}
        },
        ["objects"] = {
            ["data"] = {}
        },
    }

    -- result
    if type(_G.CodexDatabasePatch) ~= 'table' then
        _G.CodexDatabasePatch = {}
    end
end
