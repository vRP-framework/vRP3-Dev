-- ADD ITEM EVENTS
RegisterNetEvent("esx:addInventoryItem", function(src, item)
    TriggerClientEvent("devhub_lib:itemCarry:addItem:client", src, item)
end)




-- REMOVE ITEM EVENTS
RegisterNetEvent("esx:onRemoveInventoryItem", function(src, item)
    TriggerClientEvent("devhub_lib:itemCarry:removeItem:client", src, item)
end)