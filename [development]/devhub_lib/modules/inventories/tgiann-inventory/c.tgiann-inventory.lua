if Shared.InventorySystem ~= "tgiann-inventory" then return end  
local Items = exports["tgiann-inventory"]:ItemsRaw()

Core.GetItemData = function(itemName) 
    local itemData = Items[itemName]
    if not itemData then return nil end
    return { 
        name = itemName,
        label = itemData.label or itemName,
        img = string.format("nui://inventory_images/images/%s", itemData.image),
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