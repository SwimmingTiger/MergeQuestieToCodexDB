function printf(s, ...)
    return print(s:format(...))
end

function listToString(t, singleSkipBracket, toStringFunction, sortFunction)
    if not toStringFunction then
        toStringFunction = tostring
    end
    local separator = false
    local str = ''
    if #t > 1 then
        if sortFunction then
            table.sort(t, sortFunction)
        else
            table.sort(t)
        end
    end
    for i=1, #(t) do
        if separator then str = str .. ',' end
        str = str .. toStringFunction(t[i])
        separator = true
    end
    if #(t) > 1 or not singleSkipBracket then
        str = '{' .. str .. '}'
    end
    return str
end

function tablelen(table)
    local count = 0
    for _ in pairs(table) do count = count + 1 end
    return count
end
