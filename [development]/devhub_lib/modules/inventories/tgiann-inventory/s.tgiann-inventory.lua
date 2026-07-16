if Shared.InventorySystem ~= "tgiann-inventory" then return end  
local Items = exports["tgiann-inventory"]:ItemsRaw()

Core.RegisterItem = function(item, func)
    if Shared.Framework == "ESX" then 
        ESX.RegisterUsableItem(item, function(playerId)
            func(playerId)
        end)
    elseif Shared.Framework == "QBCore" then
        QBCore.Functions.CreateUseableItem(item, function(source, item)
            func(source)
        end)
     elseif Shared.Framework == "QBOX" then
        exports.qbx_core:CreateUseableItem(item, function(source, item)
            func(source)
        end)
    end
end

Core.RegisterServerCallback('dh_lib:server:getItemData', function(source, cb, itemName)
    cb(Core.GetItemData(itemName))
end)

Core.GetAllItems = function(source)
    local playerItems = exports['tgiann-inventory']:GetPlayerItems(source)
    if not playerItems then return {} end
    local items = {}
    for slot, item in pairs(playerItems) do
        if item then
            items[#items + 1] = {
                name = item.name,
                amount = item.count or item.amount,
                metadata = item.metadata or item.info or {},
                label = item.label,
                slot = item.slot or slot
            }
        end
    end
    return items
end

Core.GetItemData = function(itemName)
    local itemData = Items[itemName]
    if not itemData then return nil end
    return {
        label = itemData.label or itemName,
        img = string.format("nui://inventory_images/images/%s", itemData.image),
    }
end

Core.GetItemMetadata = function(source, slot)
    local item = exports['tgiann-inventory']:GetItemBySlot(source, slot)
    return {name = item?.name, amount = item?.count or item?.amount, metadata = item?.info or item?.metadata}
end

Core.SetItemMetadata = function(source, slot, metadata)
    local item = exports['tgiann-inventory']:GetItemBySlot(source, slot)
    if not item then return end
    return exports['tgiann-inventory']:UpdateItemMetadata(source, item.name, slot, metadata)
end

Core.RemoveItem = function(source, itemName, amount)
    return exports['tgiann-inventory']:RemoveItem(source, itemName, amount or 1)
end

Core.AddItem = function(source, itemName, amount, metadata)
    return exports['tgiann-inventory']:AddItem(source, itemName, amount or 1, nil, metadata)
end

Core.CanCarry = function(source, item, amount)
    return exports['tgiann-inventory']:CanCarryItem(source, item, amount)
end

Core.GetItemCount = function(source, item)
    local itemData = exports['tgiann-inventory']:GetItemByName(source, item)
    if not itemData then return 0 end
    return itemData.amount or 0
end

LoadedSystems['inventory'] = true