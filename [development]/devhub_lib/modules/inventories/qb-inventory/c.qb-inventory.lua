if Shared.InventorySystem ~= "qb-inventory" then return end  

Core.GetItemData = function(itemName) 
    local itemData = QBCore.Shared.Items[itemName]
    if not itemData then return nil end
    return { 
        name = itemName,
        label = itemData.label,
        img = 'nui://qb-inventory/html/images/' .. itemData.image,
    }
end

RegisterNetEvent("qb-weapons:client:UseWeapon", function(data)
    if not data then 
        TriggerEvent("devhub_lib:client:currentWeapon")
        return
    end
    local metadata = data?.metadata
    TriggerEvent("devhub_lib:client:currentWeapon", {
        weapon = data.name,
        metadata = metadata,
    })
end)

LoadedSystems['inventory'] = true