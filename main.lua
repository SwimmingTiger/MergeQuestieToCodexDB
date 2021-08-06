local ADDON, ns = ...
local _G = _G
setfenv(1, ns)

function run(enableDebug)
    setDebug(enableDebug)

    if _G.CodexDB.questiePatchVersion then
        _G.print('ClassicCodex was patched, cannot generate the patch again!')
        _G.print('Please delete the db-patches folder of ClassicCodex and try again.')
        _G.print('Questie patch version:')
        for k,v in pairs(_G.CodexDB.questiePatchVersion) do
            _G.print(k, v)
        end
        return
    end

    loadDB()
    convertQuestieQuestDB()
    diffQuestDB()
    convertQuestieUnitDB()
    diffUnitDB()
    convertQuestieObjectDB()
    diffObjectDB()
    diffObjectLocale()

    _G.print('MergeQuestieToCodexDB Complete. Reload UI to save the change.')
end
