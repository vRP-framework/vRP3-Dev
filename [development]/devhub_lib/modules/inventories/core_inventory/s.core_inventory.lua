if Shared.InventorySystem ~= "core_inventory" then return end  

Core.RegisterItem = function(item, func)
    exports.core_inventory:registerUsableItem(item, function(source, itemData)
        func(source, itemData.slot, itemData.metadata or itemData.info or {})
    end)
end

Core.RegisterServerCallback('dh_lib:server:getItemData', function(source, cb, itemName)
    cb(Core.GetItemData(itemName))
end) 

Core.GetAllItems = function(source)
    local playerItems = exports.core_inventory:getInventory(source)
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
    local itemData = exports.core_inventory:GetItemData(itemName)
    if not itemData then return nil end
    return {
        label = itemData.label or itemName,
        img = string.format("https://cfx-nui-codem-inventory/html/img/%s.png", itemName),
    }
end
 
Core.GetItemMetadata = function(source, slot)
    local item = exports.core_inventory:getItemBySlot(source, slot)
    return {name = item?.name, amount = item?.count or item?.amount, metadata = item?.info or item?.metadata}
end

Core.SetItemMetadata = function(source, slot, metadata)
    return exports.core_inventory:setMetadata(source, slot, metadata)
end

Core.RemoveItem = function(source, itemName, amount)  
    return exports.core_inventory:removeItem(source, itemName, amount or 1) 
end

Core.AddItem = function(source, itemName, amount, metadata)
    return exports.core_inventory:addItem(source, itemName, amount, metadata)
end

Core.CanCarry = function(source, item, amount)
    return exports.core_inventory:canCarry(source, item, amount) 
end

Core.GetItemCount = function(source, item)
    return exports.core_inventory:getItemCount(source, item)
end

LoadedSystems['inventory'] = true