local ADDON, ns = ...
local _G = _G
setfenv(1, ns)

type = _G.type
string = _G.string
table = _G.table
pairs = _G.pairs
ipairs = _G.ipairs
tostring = _G.tostring
getmetatable = _G.getmetatable
setmetatable = _G.setmetatable
next = _G.next
abs = _G.abs
unpack = _G.unpack
GetAddOnMetadata = _G.GetAddOnMetadata
UnitFactionGroup = _G.UnitFactionGroup

-- export the global var MergeQuestieToCodexDB
_G[ADDON] = ns

debugEnabled = false
function setDebug(enableDebug)
    debugEnabled = enableDebug
end

local printKey = 'other'
function setPrintKey(key)
    _G.CodexDatabasePatch[key] = {}
    printKey = key
end

function print(...)
    local line = table.concat({...}, ' ')
    table.insert(_G.CodexDatabasePatch[printKey], line)
    if debugEnabled then
        _G.print(...)
    end
end

function printf(s, ...)
    print(s:format(...))
end

function listToString(t, singleSkipBracket, toStringFunction, sortFunction)
    if type(t) ~= 'table' then
        return tostring(t)
    end
    if #t == 0 then
        return 'nil'
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
    if type(a) ~= 'table' then
        a = {a}
    end
    if type(b) ~= 'table' then
        b = {b}
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


-- Delay call function
-- https://wowwiki-archive.fandom.com/wiki/USERAPI_wait

local waitTable = {};
local waitFrame = nil;

function wait(delay, func, ...)
  if(type(delay)~="number" or type(func)~="function") then
    return false;
  end
  if(waitFrame == nil) then
    waitFrame = _G.CreateFrame("Frame","MergeQuestieToCodexDBWaitFrame", UIParent);
    waitFrame:SetScript("onUpdate",function (self,elapse)
      local count = #waitTable;
      local i = 1;
      while(i<=count) do
        local waitRecord = table.remove(waitTable,i);
        local d = table.remove(waitRecord,1);
        local f = table.remove(waitRecord,1);
        local p = table.remove(waitRecord,1);
        if(d>elapse) then
          table.insert(waitTable,i,{d-elapse,f,p});
          i = i + 1;
        else
          count = count - 1;
          f(unpack(p));
        end
      end
    end);
  end
  table.insert(waitTable,{delay,func,{...}});
  return true;
end
