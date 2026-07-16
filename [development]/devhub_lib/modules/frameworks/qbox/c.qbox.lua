if Shared.Framework ~= "QBOX" then return end

CreateThread( function()
    RegisterNetEvent("QBCore:Client:OnPlayerLoaded",function()
        TriggerEvent("dh_lib:client:playerLoaded")
        TriggerServerEvent("dh_lib:server:playerLoaded", GetPlayerServerId(PlayerId()))
    end)

    RegisterNetEvent("qbx_medical:client:onPlayerLaststand",function()
        TriggerEvent("dh_lib:client:setDeathStatus", true)
    end)

    RegisterNetEvent("qbx_medical:client:playerRevived",function()
        TriggerEvent("dh_lib:client:setDeathStatus", false)
    end)

    RegisterNetEvent('qbx_core:client:playerLoggedOut', function()
        TriggerEvent("dh_lib:client:playerUnloaded")
        TriggerServerEvent("dh_lib:server:playerUnloaded", GetPlayerServerId(PlayerId()))
    end)

    LoadedSystems['framework'] = true
end)