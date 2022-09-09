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

    wait(1, function()
        _G.print('loadDB')
        loadDB()
        wait(1, function()
            _G.print('convertQuestieQuestDB')
            convertQuestieQuestDB()
            wait(1, function()
                _G.print('diffQuestDB')
                diffQuestDB()
                wait(1, function()
                    _G.print('convertQuestieUnitDB')
                    convertQuestieUnitDB()
                    wait(1, function()
                        _G.print('diffUnitDB')
                        diffUnitDB()
                        wait(1, function()
                            _G.print('convertQuestieObjectDB')
                            convertQuestieObjectDB()
                            wait(1, function()
                                _G.print('diffObjectDB')
                                diffObjectDB()
                                wait(1, function()
                                    _G.print('diffObjectLocale')
                                    diffObjectLocale()
                                    _G.print('Done, please run /reload to save the change.')
                                end)
                            end)
                        end)
                    end)
                end)
            end)
        end)
    end)
end
