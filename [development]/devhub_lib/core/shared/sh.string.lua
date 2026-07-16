while not Core do Wait(0) end

Core.String = {}

Core.String.Capitalize = function(str)
    return str:gsub("^%l", string.upper)
end

Core.String.Uppercase = function(str)
    return str:upper()
end

Core.String.Trim = function(str)
    return str:match("^%s*(.-)%s*$")
end

Core.String.Split = function(str, sep)
    local result = {}
    for match in (str .. sep):gmatch("(.-)" .. sep) do
        result[#result + 1] = match
    end
    return result
end

Core.String.Replace = function(str, search, replace)
    return str:gsub(search, replace)
end

Core.String.Join = function(tbl, sep)
    return table.concat(tbl, sep)
end