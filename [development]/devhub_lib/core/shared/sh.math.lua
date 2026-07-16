while not Core do Wait(0) end

Core.Math = {}

Core.Math.Round = function(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    if not numDecimalPlaces then return math.floor(num * mult + 0.5) end
    return math.floor(num * mult + 0.5) / mult
end