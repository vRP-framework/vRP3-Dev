if Shared.InventorySystem ~= "core_inventory" then return end  

Core.GetItemData = function(itemName) 
    -- TODO this inventory does not have a method to get item data directly
    return { 
        name = itemName,
        label = itemName,
        img = ('nui://core_inventory/html/img/%s.png'):format(itemName),
    }
end

RegisterNetEvent('onEquipWeapon', function(currentWeapon)
    --TODO if you have this inventory and need help, open a ticket  

    -- local metadata = data?.metadata
    -- TriggerEvent("devhub_lib:client:currentWeapon", {
    --     weapon = data.name,
    --     metadata = metadata,
    -- })
end)

RegisterNetEvent('onUnEquipWeapon', function(currentWeapon)
    TriggerEvent("devhub_lib:client:currentWeapon")
end)

LoadedSystems['inventory'] = true