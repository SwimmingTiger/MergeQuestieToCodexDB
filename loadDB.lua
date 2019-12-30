local ADDON, ns = ...
local _G = _G
setfenv(1, ns)

function loadDB()
    -- Database from ClassicCodex
    CodexDB = _G.CodexDB

    -- Database from Questie
    QuestieDB = _G.QuestieLoader:ImportModule("QuestieDB")

    -- Converted database from Questie format to ClassicCodex format
    ConvDB = {
        ["quests"] = {
            ["data"] = {}
        }
    }

    -- result
    _G.CodexDatabasePatch = ""
end
