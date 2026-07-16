if Shared.InventorySystem ~= "ak47_inventory" then return end  

Core.GetItemData = function(itemName) 
    local item = exports['ak47_inventory']:Items(itemName)
    return { 
        name = itemName,
        label = item.label or itemName,
        img = ('nui://ak47_inventory/web/build/images/%s.png'):format(itemName),
    }
end


local lastWeapon = { name = nil, slot = nil, cooldown = false }

RegisterNetEvent('ak47_inventory:onEquipWeapon', function(currentWeapon)
    if currentWeapon?.slot then
        if lastWeapon.cooldown and currentWeapon.name == lastWeapon.name and currentWeapon.slot == lastWeapon.slot then
            TriggerEvent("devhub_lib:client:currentWeapon", {
                weapon = lastWeapon.name,
                metadata = lastWeapon.metadata or {},
            })
            return
        end
        lastWeapon.name = currentWeapon.name
        lastWeapon.slot = currentWeapon.slot
        lastWeapon.cooldown = true
        SetTimeout(2000, function()
            lastWeapon.cooldown = false
        end)
        Core.TriggerServerCallback('dh_lib:server:getWeaponMetadata', function(result)
            local meta = result?.metadata or currentWeapon?.metadata or {}
            lastWeapon.metadata = meta
            TriggerEvent("devhub_lib:client:currentWeapon", {
                weapon = currentWeapon.name,
                metadata = meta,
            })
        end, currentWeapon.slot)
    else
        TriggerEvent("devhub_lib:client:currentWeapon", {
            weapon = currentWeapon.name,
            metadata = currentWeapon?.metadata or {},
        })
    end
end)

RegisterNetEvent('ak47_inventory:onUnEquipWeapon', function(currentWeapon)
    TriggerEvent("devhub_lib:client:currentWeapon")
end)

LoadedSystems['inventory'] = true