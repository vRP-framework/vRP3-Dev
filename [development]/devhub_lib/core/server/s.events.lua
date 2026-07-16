AddEventHandler('onResourceStop', function(resourceName)
    TriggerEvent("dh_lib:server:resourceStop", resourceName)
end)

RegisterNetEvent('txAdmin:events:serverShuttingDown',function()
    TriggerEvent("dh_lib:server:resourceStop", 'dh_all')
end)

local dh_loadedPlayers = {}

RegisterNetEvent("dh_lib:server:playerLoaded", function(source)
    local src = source
    if src and src > 0 then
        dh_loadedPlayers[src] = true
    end
end)

AddEventHandler('playerDropped', function (reason)
    local source = source
    dh_loadedPlayers[source] = nil
    TriggerClientEvent("dh_lib:client:playerUnloaded", source)
    TriggerEvent("dh_lib:server:playerUnloaded", source)
end)

-- If no framework module triggered playerLoaded, this will handle it
RegisterNetEvent("dh_lib:server:clientReady", function()
    local src = source
    CreateThread(function()
        Wait(10000) 

        while true do
            if dh_loadedPlayers[src] then
                return
            end

            if not GetPlayerName(src) then
                dh_loadedPlayers[src] = nil
                return
            end

            if Core.GetIdentifier then
                local ok, identifier = pcall(Core.GetIdentifier, src)
                if ok and identifier and identifier ~= false and identifier ~= "" then
                    if not dh_loadedPlayers[src] and GetPlayerName(src) then
                        dh_loadedPlayers[src] = true
                        TriggerClientEvent("dh_lib:client:playerLoaded", src)
                        TriggerEvent("dh_lib:server:playerLoaded", src)
                    end
                    return
                end
            end

            Wait(5000)
        end
    end)
end)

RegisterNetEvent('devhub_lib:server:setPlayerRoutingBucket', function(routingBucket, target)
    local source = target or source
    if routingBucket and routingBucket >= 0 then
        SetPlayerRoutingBucket(source, routingBucket)
        TriggerEvent('devhub_lib:server:setBucket', source, routingBucket)
    end
end)

RegisterNetEvent('devhub_lib:server:resetPlayerRoutingBucket', function(target)
    local source = target or source
    SetPlayerRoutingBucket(source, 0)
    TriggerEvent('devhub_lib:server:setBucket', source, 0)
end)