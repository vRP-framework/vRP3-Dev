if Shared.InventorySystem ~= "ak47_inventory" then return end  
local Items = exports['ak47_inventory']:Items()
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

Core.RegisterServerCallback('dh_lib:server:getWeaponMetadata', function(source, cb, slot)
    local metadata = Core.GetItemMetadata(source, slot)
    cb(metadata)
end)

Core.GetAllItems = function(source)
    local playerItems = exports['ak47_inventory']:GetInventoryItems(source)
    if not playerItems then return {} end
    local items = {}
    for _, item in pairs(playerItems) do
        items[#items + 1] = {
            name = item.name,
            amount = item?.count or item?.amount,
            metadata = item?.metadata or item?.info,
            label = item.label,
            slot = item.slot
        }
    end
    return items
end

Core.GetItemData = function(itemName)
    local itemData = Items[itemName]
    if not itemData then return nil end
    return {
        label = itemData.label or itemName,
        img = string.format("https://cfx-nui-ak47_inventory/web/build/images/%s.png", itemName),
    }
end
 
Core.GetItemMetadata = function(source, slot)
    local item = exports['ak47_inventory']:GetSlot(source, slot)
    return {name = item?.name, amount = item?.count or item?.amount, metadata = item?.info}
end

Core.SetItemMetadata = function(source, slot, metadata)
    return exports['ak47_inventory']:SetItemInfo(source, slot, metadata)
end

Core.RemoveItem = function(source, itemName, amount)
    return exports['ak47_inventory']:RemoveItem(source, itemName, amount or 1)
end

Core.AddItem = function(source, itemName, amount, metadata)
    return exports['ak47_inventory']:AddItem(source, itemName, amount or 1, nil, metadata, nil, nil)
end

Core.CanCarry = function(source, item, amount)
    local canCarry = exports['ak47_inventory']:CanCarryAmount(source, item)
    return canCarry >= (amount or 1)
end

Core.GetItemCount = function(source, item)
    return exports['ak47_inventory']:GetAmount(source, item)
end

LoadedSystems['inventory'] = true