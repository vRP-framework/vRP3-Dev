if Shared.InventorySystem ~= "codem-inventory" then return end  
local Items = exports['codem-inventory']:GetItemList()
Core.GetItemData = function(itemName) 
    local itemData = Items[itemName]
    return { 
        name = itemName,
        label = itemData?.label or itemName,
        img = itemData?.img or ('nui://codem-inventory/html/img/%s.png'):format(itemName),
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