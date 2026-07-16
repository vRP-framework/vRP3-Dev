if Shared.InventorySystem ~= "ox_inventory" then return end  

Core.GetItemData = function(itemName) 
    local itemData = exports.ox_inventory:Items(itemName)
    return { 
        name = itemName,
        label = itemData?.label,
        img = string.format("https://cfx-nui-ox_inventory/web/images/%s.png", itemName),
    }
end
 
RegisterNetEvent("ox_inventory:currentWeapon", function(data)
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