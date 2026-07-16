Core = {} 

LoadedSystems = {
    ["framework"] = false,
    ['inventory'] = false,
    ['targets'] = false,
    ['callbacks'] = false,
}

local function areSystemsLoaded()
    for _, loaded in pairs(LoadedSystems) do
        if not loaded then
            return false
        end
    end
    return true 
end

-- PolyZone functionality
Core.CreatePolyZone = function(points, options)
    return PolyZone:Create(points, options)
end

Core.PolyZone = PolyZone

createExport("GetCoreObject", function()
    return Core
end)

-- Direct PolyZone exports for easier usage
createExport("CreatePolyZone", function(points, options)
    return PolyZone:Create(points, options)
end)

createExport("GetPolyZoneClass", function()
    return PolyZone
end)

Citizen.CreateThread(function()
    while not areSystemsLoaded() do
        Wait(100)
    end

    Core.Loaded = true
    TriggerServerEvent("dh_lib:server:clientReady")
end)