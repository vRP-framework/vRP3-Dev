if Shared.InventorySystem ~= "codem-inventory" then return end  

Core.RegisterItem = function(item, func)
    exports['codem-inventory']:RegisterUsableItem(item, function(source, itemData)
        func(source, itemData.slot, itemData.metadata or itemData.info or {})
    end)
end

Core.RegisterServerCallback('dh_lib:server:getItemData', function(source, cb, itemName)
    cb(Core.GetItemData(itemName))
end)
 
Core.GetAllItems = function(source)
    local playerItems = exports['codem-inventory']:GetInventory(source)
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
    local itemData = exports['codem-inventory']:GetItemData(itemName)
    if not itemData then return nil end
    return {
        label = itemData.label or itemName,
        img = string.format("https://cfx-nui-codem-inventory/html/img/%s.png", itemName),
    }
end
 
Core.GetItemMetadata = function(source, slot)
    local item = exports['codem-inventory']:GetItemBySlot(source, slot)
    return {name = item?.name, amount = item?.count or item?.amount, metadata = item?.info or item?.metadata}
end

Core.SetItemMetadata = function(source, slot, metadata)
    return exports['codem-inventory']:SetItemMetadata(source, slot, metadata)
end

Core.RemoveItem = function(source, itemName, amount)
    return exports['codem-inventory']:RemoveItem(source, itemName, amount or 1)
end

Core.AddItem = function(source, itemName, amount, metadata)
    return exports['codem-inventory']:AddItem(source, itemName, amount or 1, metadata)
end

Core.CanCarry = function(source, item, amount)
    return true
end

Core.GetItemCount = function(source, item)
    return exports['codem-inventory']:GetItemsTotalAmount(source, item)
end

LoadedSystems['inventory'] = true