if Shared.InventorySystem ~= "qs-inventory" then return end  
local Items = exports['qs-inventory']:GetItemList()
Core.GetItemData = function(itemName) 
    local itemData = Items[itemName]
    if not itemData then return nil end
    return { 
        name = itemName,
        label = itemData.label,
        img = 'nui://qs-inventory/html/images/' .. itemData.image,
    }
end

RegisterNetEvent('weapons:client:SetCurrentWeapon', function(data)
    if not data then 
        TriggerEvent("devhub_lib:client:currentWeapon")
        return
    end
    TriggerEvent("devhub_lib:client:currentWeapon", {
        weapon = data.name,
        metadata = data?.info,
    })
end)


LoadedSystems['inventory'] = true