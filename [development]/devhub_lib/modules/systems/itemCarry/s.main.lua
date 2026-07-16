local CarryingItems = {}
RegisterNetEvent("devhub_lib:itemCarry:addItem:server", function(netId)
    local source = tostring(source)
    local obj = NetworkGetEntityFromNetworkId(netId)
    if not DoesEntityExist(obj) then
        TriggerClientEvent("devhub_lib:itemCarry:deleteEntity", source)
        return
    end
    CarryingItems[source] = netId
end)

RegisterNetEvent("devhub_lib:itemCarry:removeItem:server", function()
    local source = tostring(source)
    DeletePlayerEntity(source)
end) 

function DeletePlayerEntity(source)
    local netId = CarryingItems[source]
    if not netId then
        return
    end
    local obj = NetworkGetEntityFromNetworkId(netId)
    if DoesEntityExist(obj) then
        for i = 1, 10 do
            if DoesEntityExist(obj) then
                DeleteEntity(obj)
            else
                break
            end
            Wait(100)
        end
    end
    CarryingItems[source] = nil
end

AddEventHandler('playerDropped', function (reason, resourceName, clientDropReason)
    local source = tostring(source)
    DeletePlayerEntity(source)
end)

exports('IsPlayerCarryingItem', function(source)
    local source = tostring(source)
    return CarryingItems[source] ~= nil
end)

RegisterNetEvent("devhub_lib:server:setBucket", function(source, bucket)
    if CarryingItems[tostring(source)] then
        SetEntityRoutingBucket(NetworkGetEntityFromNetworkId(CarryingItems[tostring(source)]), bucket)
    end
end)