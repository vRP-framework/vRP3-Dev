if Shared.InventorySystem ~= "custom" then return end  

-- Registers an item as usable. When a player uses the item, the callback function is called.
-- @param item (string) The spawn name of the item to register.
-- @param func (function) The callback function. Receives parameters:
--   source   (number) - Player server ID
--   slot     (number) - The inventory slot number
--   metadata (table)  - The item's metadata/info table
Core.RegisterItem = function(item, func)
    -- Example:
    -- exports['your-inventory']:RegisterUsableItem(item, function(source, itemData)
    --     func(source, itemData.slot, itemData.info or {})
    -- end)
end

Core.RegisterServerCallback('dh_lib:server:getItemData', function(source, cb, itemName)
    cb(Core.GetItemData(itemName))
end)

-- Gets all items from a player's inventory.
-- @param source (number) The player's server ID.
-- @return (table) An array of item tables, each containing:
--   name     (string) - The item spawn name
--   amount   (number) - The quantity of the item
--   metadata (table)  - The item's metadata/info
--   label    (string) - The display label of the item
--   slot     (number) - The inventory slot number
Core.GetAllItems = function(source)
    -- Example:
    -- local playerItems = exports['your-inventory']:GetPlayerItems(source)
    -- if not playerItems then return {} end
    -- local items = {}
    -- for slot, item in pairs(playerItems) do
    --     if item then
    --         items[#items + 1] = {
    --             name = item.name,
    --             amount = item.count or item.amount,
    --             metadata = item.metadata or item.info or {},
    --             label = item.label,
    --             slot = item.slot or slot
    --         }
    --     end
    -- end
    -- return items
    return {}
end

-- Gets the data/info for a specific item by name (not player-specific).
-- @param itemName (string) The spawn name of the item.
-- @return (table|nil) A table containing:
--   label (string) - The display label of the item
--   img   (string) - The URL/path to the item image
-- Returns nil if the item does not exist.
Core.GetItemData = function(itemName)
    -- Example:
    -- local itemData = exports['your-inventory']:GetItemData(itemName)
    -- if not itemData then return nil end
    -- return {
    --     label = itemData.label or itemName,
    --     img = string.format("nui://your-inventory/html/images/%s.png", itemName),
    -- }
    return {
        label = itemName,
        img = "",
    }
end

-- Gets the metadata of an item in a specific slot.
-- @param source (number) The player's server ID.
-- @param slot   (number) The inventory slot number.
-- @return (table) A table containing:
--   name     (string) - The item spawn name
--   amount   (number) - The quantity of the item
--   metadata (table)  - The item's metadata/info
Core.GetItemMetadata = function(source, slot)
    -- Example:
    -- local item = exports['your-inventory']:GetItemBySlot(source, slot)
    -- return {name = item?.name, amount = item?.count or item?.amount, metadata = item?.info or item?.metadata}
    return {name = nil, amount = 0, metadata = {}}
end

-- Sets/updates the metadata of an item in a specific slot.
-- @param source   (number) The player's server ID.
-- @param slot     (number) The inventory slot number.
-- @param metadata (table)  The new metadata to set on the item.
-- @return (boolean|nil) Whether the operation was successful.
Core.SetItemMetadata = function(source, slot, metadata)
    -- Example:
    -- return exports['your-inventory']:SetItemMetadata(source, slot, metadata)
    return false
end

-- Removes an item from the player's inventory.
-- @param source   (number) The player's server ID.
-- @param itemName (string) The spawn name of the item to remove.
-- @param amount   (number) The amount to remove (defaults to 1).
-- @return (boolean) Whether the item was successfully removed.
Core.RemoveItem = function(source, itemName, amount)
    -- Example:
    -- return exports['your-inventory']:RemoveItem(source, itemName, amount or 1)
    return false
end

-- Adds an item to the player's inventory.
-- @param source   (number) The player's server ID.
-- @param itemName (string) The spawn name of the item to add.
-- @param amount   (number) The amount to add (defaults to 1).
-- @param metadata (table)  Optional metadata to attach to the item.
-- @return (boolean) Whether the item was successfully added.
Core.AddItem = function(source, itemName, amount, metadata)
    -- Example:
    -- return exports['your-inventory']:AddItem(source, itemName, amount or 1, nil, metadata)
    return false
end

-- Checks if the player can carry a specific item and amount.
-- @param source (number) The player's server ID.
-- @param item   (string) The spawn name of the item.
-- @param amount (number) The amount to check.
-- @return (boolean) Whether the player can carry the specified item and amount.
Core.CanCarry = function(source, item, amount)
    -- Example:
    -- return exports['your-inventory']:CanCarryItem(source, item, amount)
    return true
end

-- Gets the total count of a specific item in the player's inventory.
-- @param source (number) The player's server ID.
-- @param item   (string) The spawn name of the item.
-- @return (number) The total amount of the item the player has.
Core.GetItemCount = function(source, item)
    -- Example:
    -- return exports['your-inventory']:GetItemCount(source, item)
    return 0
end

LoadedSystems['inventory'] = true