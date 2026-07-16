-- ADD ITEM EVENTS
RegisterNetEvent('esx:addInventoryItem', function(item)
    ItemCarryAddItem(item)
end)



-- REMOVE ITEM EVENTS
RegisterNetEvent('esx:removeInventoryItem', function(item)
    ItemCarryRemoveItem(item)
end)