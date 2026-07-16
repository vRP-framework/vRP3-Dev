if Shared.Framework ~= "custom" then return end
    
CreateThread( function()
 
    -- Registers an event for when the player is loaded.
    RegisterNetEvent("playerSpawned", function()
        TriggerEvent("dh_lib:client:playerLoaded")
        TriggerServerEvent("dh_lib:server:playerLoaded", GetPlayerServerId(PlayerId()))
    end)

    -- Registers an event to set the player's death status.
    -- @param isDead A boolean indicating the player's death status.
    RegisterNetEvent("SetDeathStatus", function(isDead)
        TriggerEvent("dh_lib:client:setDeathStatus", isDead)
    end)

    -- Registers an event for when the player is unloaded.
    RegisterNetEvent('OnPlayerUnload', function()
        TriggerEvent("dh_lib:client:playerUnloaded")
        TriggerServerEvent("dh_lib:server:playerUnloaded", GetPlayerServerId(PlayerId()))
    end)

    LoadedSystems['framework'] = true
end)