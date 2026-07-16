while not Core do Wait(0) end

Core.GenerateString = function(length)
    local generated = ""
    for _ = 1, length or 7 do
        local char = math.random(1, 2) == 1 and string.char(math.random(97, 122)) or tostring(math.random(0, 9))
        if math.random(1, 2) == 1 then
            char = string.upper(char)
        end
        generated = generated .. char
    end
    return generated
end

Core.GetLengthOfObject = function(object)
    local length = 0
    for k,v in pairs(object) do
        if v then
            length = length + 1
        end
    end
    return length
end

Core.IsObjectEmpty = function(object)
    for k,v in pairs(object) do
        if v then
           return false
        end
    end
    return true
end
