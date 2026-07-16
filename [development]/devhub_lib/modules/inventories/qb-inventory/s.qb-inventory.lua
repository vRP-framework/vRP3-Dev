if Shared.InventorySystem ~= "qb-inventory" then return end  
local QBCore = exports['qb-core']:GetCoreObject()

Core.RegisterItem = function(item, func)
    QBCore.Functions.CreateUseableItem(item, function(source, itemData)
        func(source, itemData.slot, itemData.info or {})
    end)
end

Core.RegisterServerCallback('dh_lib:server:getItemData', function(source, cb, itemName)
    cb(Core.GetItemData(itemName))
end)

Core.GetAllItems = function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return {} end
    local items = {}
    for slot, item in pairs(Player.PlayerData.items) do
        if item then
            items[#items + 1] = {
                name = item.name,
                amount = item.amount,
                metadata = item.info or {},
                label = item.label,
                slot = slot
            }
        end
    end
    return items
end

Core.GetItemData = function(itemName)
    local itemData = QBCore.Shared.Items[itemName]
    if not itemData then return nil end
    return {
        label = itemData.label or itemName,
        img = string.format("nui://qb-inventory/html/images/%s.png", itemName),
    }
end 

Core.RemoveItem = function(source, itemName, amount)
    return exports['qb-inventory']:RemoveItem(source, itemName, amount or 1, false, nil)
end

Core.AddItem = function(source, itemName, amount, metadata)
    return exports['qb-inventory']:AddItem(source, itemName, amount or 1)
end

Core.CanCarry = function(source, item, amount)
    return exports['qb-inventory']:CanAddItem(source, item, amount)
end

Core.GetItemCount = function(source, item)
    return exports['qb-inventory']:GetItemCount(source, item)
end

LoadedSystems['inventory'] = true