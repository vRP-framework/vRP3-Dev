if Shared.Framework ~= "ESX" then return end
   
CreateThread( function()
    RegisterNetEvent("esx:playerLoaded",function()
        TriggerEvent("dh_lib:client:playerLoaded")
    end)

    RegisterNetEvent("esx:onPlayerDeath",function()
        TriggerEvent("dh_lib:client:setDeathStatus", true)
    end)

    RegisterNetEvent('esx_ambulancejob:revive', function()
        TriggerEvent("dh_lib:client:setDeathStatus", false)
    end)

    RegisterNetEvent('esx:onPlayerLogout', function()
        TriggerEvent("dh_lib:client:playerUnloaded")
        TriggerServerEvent("dh_lib:server:playerUnloaded", GetPlayerServerId(PlayerId()))
    end)

    LoadedSystems['framework'] = true
end)