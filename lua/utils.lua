function printf(s, ...) return print(s:format(...)) end

function listToString(t, singleSkipBracket, toStringFunction, sortFunction)
    if type(t) ~= 'table' then
        return tostring(t)
    end
    if #t == 0 then
        return '{}'
    end
    if not toStringFunction then toStringFunction = tostring end
    local separator = false
    local str = ''
    if #t > 1 then
        if sortFunction then
            table.sort(t, sortFunction)
        else
            table.sort(t)
        end
    end
    for i = 1, #(t) do
        if separator then str = str .. ',' end
        str = str .. toStringFunction(t[i])
        separator = true
    end
    if #(t) > 1 or not singleSkipBracket then str = '{' .. str .. '}' end
    return str
end

function tablelen(table)
    local count = 0
    for _ in pairs(table) do count = count + 1 end
    return count
end

function deepCopy(orig)
    local copy
    if type(orig) == "table" then
        copy = {}
        for origKey, origValue in next, orig, nil do
            copy[deepCopy(origKey)] = deepCopy(origValue)
        end
        setmetatable(copy, deepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

function listCmp(a, b)
    if type(a) ~= type(b) then
        return false
    end
    if type(a) ~= 'table' then
        return a == b
    end
    if tablelen(a) ~= tablelen(b) then
        return false
    end
    return listToString(a) == listToString(b)
end

function fieldCmp(a, b, key)
    return listCmp(a[key], b[key])
end

function mergeSet(a, b)
    if type(a) ~= 'table' then
        a = {a}
    end
    if type(b) ~= 'table' then
        b = {b}
    end
    local index = {}
    local merged = {}
    for _,v in pairs(a) do
        index[v] = true
        table.insert(merged, v)
    end
    for _,v in pairs(b) do
        if not index[v] then
            table.insert(merged, v)
        end
    end
    return merged
end

function valueToTable(value)
    if type(value) == 'table' then
        return value
    end
    return {value}
end
