if Shared.InventorySystem ~= "custom" then return end  

-- Gets the item data for a given item name.
-- @param itemName (string) The spawn name of the item.
-- @return (table) A table containing:
--   name  (string) - The item spawn name
--   label (string) - The display label of the item
--   img   (string) - The URL/path to the item image
Core.GetItemData = function(itemName) 
    return { 
        name = itemName,
        label = itemName,
        img = "",
    }
end

-- Event triggered when the player equips a weapon.
-- Should call TriggerEvent("devhub_lib:client:currentWeapon", { weapon = weaponName, metadata = metadata })
RegisterNetEvent('onEquipWeapon', function(currentWeapon)
    -- Example:
    -- local metadata = currentWeapon?.metadata
    -- TriggerEvent("devhub_lib:client:currentWeapon", {
    --     weapon = currentWeapon.name,
    --     metadata = metadata,
    -- })
end)

-- Event triggered when the player unequips a weapon.
-- Should call TriggerEvent("devhub_lib:client:currentWeapon") with no arguments.
RegisterNetEvent('onUnEquipWeapon', function(currentWeapon)
    TriggerEvent("devhub_lib:client:currentWeapon")
end)

LoadedSystems['inventory'] = true