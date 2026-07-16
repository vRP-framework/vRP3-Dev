if Shared.InventorySystem ~= "qs-inventory" then return end  
local Items = exports['qs-inventory']:GetItemList()
 
Core.RegisterItem = function(item, func)
    exports['qs-inventory']:CreateUsableItem(item, function(source, itemData)
        func(source, itemData.slot, itemData.metadata or itemData.info or {})
    end)
end

Core.RegisterServerCallback('dh_lib:server:getItemData', function(source, cb, itemName)
    cb(Core.GetItemData(itemName))
end)

Core.GetAllItems = function(source)
    local playerItems = exports['qs-inventory']:GetInventory(source)
    if not playerItems then return {} end
    local items = {}
    for slot, item in pairs(playerItems) do
        items[#items + 1] = {
            name = item.name,
            amount = item.count or item.amount,
            metadata = item.metadata or item.info,
            label = item.label,
            slot = slot
        }
    end
    return items
end

Core.GetItemData = function(itemName)
    local itemData = Items[itemName]
    if not itemData then return nil end
    return {
        label = itemData.label or itemName,
        img = string.format("https://cfx-nui-qs-inventory/html/images/%s", itemData.image),
    }
end
 
Core.GetItemMetadata = function(source, slot)
    local item = nil 
    local playerItems = exports['qs-inventory']:GetInventory(source)
    for itemSlot, itemData in pairs(playerItems) do
        if tonumber(itemSlot) == tonumber(slot) then
            item = itemData
            break
        end
    end
    return {name = item?.name, amount = item?.count, metadata = item?.metadata}
end

Core.SetItemMetadata = function(source, slot, metadata)
    return exports['qs-inventory']:SetItemMetadata(source, slot, metadata)
end

Core.RemoveItem = function(source, itemName, amount)
    return exports['qs-inventory']:RemoveItem(source, itemName, amount, nil, nil)
end

Core.AddItem = function(source, itemName, amount, metadata)
    return exports['qs-inventory']:AddItem(source, itemName, amount, nil, metadata)
end

Core.CanCarry = function(source, item, amount)
    return exports['qs-inventory']:CanCarryItem(source, item, amount)

end

Core.GetItemCount = function(source, item)
    return exports['qs-inventory']:GetItemTotalAmount(source, item)
end

LoadedSystems['inventory'] = true