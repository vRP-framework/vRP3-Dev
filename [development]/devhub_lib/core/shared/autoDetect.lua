FRAMEWORK_RESOURCES = { -- some framework like qbox uses provide to imitate other frameworks
    ['ESX'] = {
        "es_extended",
    },
    ['QBCore'] = {
        "qb-core",
    },
    ['QBOX'] = {
        "qbx_core",
        "qb-core",
    },
    ['VRP'] = {
        "vrp",
    },
}

TARGET_RESOURCES = {
    ['ox_target'] = "ox_target",
    ['qb-target'] = "qb-target",
}

TARGET_ORDER = {
    "ox_target",
    "qb-target",
}

VEHICLE_KEYS_RESOURCES = {
    ['qb-vehiclekeys'] = {
        "qb-vehiclekeys",
        "qbx_vehiclekeys",
    },
    ['qs-vehiclekeys'] = {
        "qs-vehiclekeys",
    },
    ['ak47_vehiclekeys'] = {
        "ak47_vehiclekeys",
        "ak47_qb_vehiclekeys",
    },
    ['t1ger_keys'] = {
        "t1ger_keys",
    },
    ['Renewed-Vehiclekeys'] = {
        "Renewed-Vehiclekeys",
    },
    ['cd_garage'] = {
        "cd_garage",
    },
}
 
INVENTORIES = {
    ['ox_inventory'] = {
        "ox_inventory",
    },
    ['qb-inventory'] = {
        "qb-inventory",
    },
    ["ak47_inventory"] = {
        "ak47_inventory",
    },
    ["codem-inventory"] = {
        "codem-inventory",
    },
    ["core_inventory"] = {
        "core_inventory",
    },
    ["qs-inventory"] = {
        "qs-inventory",
    },
    ["tgiann-inventory"] = {
        "tgiann-inventory",
    },
}

INVENTORIES_ORDER = {
    "ak47_inventory",
    "qs-inventory",
    "tgiann-inventory",
    "codem-inventory",
    "core_inventory",
    "ox_inventory",
    "qb-inventory",
}

FUEL_RESOURCES = {
    ['LegacyFuel'] = {
        "LegacyFuel",
    },
    ['ps-fuel'] = {
        "ps-fuel",
    },
    ['ox_fuel'] = {
        "ox_fuel",
    },
    ['cd_fuel'] = {
        "cd_fuel",
    },
    ['rcore_fuel'] = {
        "rcore_fuel",
    },
}

local FRAMEWORK_NAME_ALIASES = {
    ["ESX"] = {"esx", "es_extended"},
    ["QBCore"] = {"qbcore", "qb-core", "qbx_core", "qb"},
    ["QBOX"] = {"qbox", "qbx_core", "qbx"},
    ["VRP"] = {"vrp"},
}

local function isAutoDetect(value)
    return string.lower(value) == string.lower("AUTO DETECT") or string.lower(value) == string.lower("AUTO") or string.lower(value) == string.lower("AUTODETECT")
end

if isAutoDetect(Shared.Framework) then
    local frameworkDetected = false
    local mostCompatibleFramework = {}
    for k, v in pairs(FRAMEWORK_RESOURCES) do
        for _, resource in pairs(v) do
            if GetResourceState(resource) == "started" then
                if not mostCompatibleFramework[k] then
                    mostCompatibleFramework[k] = 1
                else
                    mostCompatibleFramework[k] = mostCompatibleFramework[k] + 1
                end
            end
        end
    end
    local max = 0
    local maxFramework = ""
    local sameLevel = {}
    for k, v in pairs(mostCompatibleFramework) do -- qbox uses provide to imitate other frameworks
        if v > max then
            max = v
            maxFramework = k
            table.insert(sameLevel, k)
        elseif v == max then
            table.insert(sameLevel, k)
        end
    end
    for _, v in pairs(sameLevel) do
        local resourceCount = #FRAMEWORK_RESOURCES[v]
        if max >= resourceCount then
            maxFramework = v
        end
    end
    if max > 0 then
        Shared.Framework = maxFramework
        frameworkDetected = true
        print("^3devhub_lib:^7 Framework detected: ^2"..maxFramework.."^7")
    end
    if not frameworkDetected then
        print("^3devhub_lib:^1 Framework not detected. Please set it manually.\t^7Framework was automatically set to: ^2custom^7")
        Shared.Framework = "custom"
    end
else
    local frameworkDetected = false
    for k, v in pairs(FRAMEWORK_NAME_ALIASES) do
        for _, alias in pairs(v) do
            if string.lower(Shared.Framework) == string.lower(alias) then
                Shared.Framework = k
                frameworkDetected = true
                break
            end
        end
    end
    if not frameworkDetected then
        print("^3devhub_lib:^1 Framework set in config.lua is not recognized. Please check it again.^7")
        Shared.Framework = "custom"
    end
end

if Shared.Framework == "VRP" then
    print("^3devhub_lib:^7 Before using ^1vRP^7 make sure to uncomment ^1@vrp/lib/utils.lua^7 in fxmanifest.lua !!!^7")
end

if isAutoDetect(Shared.Target) then
    local targetDetected = false
    for _, targetName in ipairs(TARGET_ORDER) do
        local resource = TARGET_RESOURCES[targetName]
        if resource then
            local status = GetResourceState(resource)
            if status == "started" then
                Shared.Target = targetName
                targetDetected = true
                print("^3devhub_lib:^7 Target detected: ^2"..targetName.."^7")
                break
            end
        end
    end
    if not targetDetected then
        print("^3devhub_lib:^1 Target not detected. Please set it manually.\t^7Target was automatically set to: ^2standalone^7")
        Shared.Target = "standalone"
    end
end


if isAutoDetect(Shared.VehicleKeys) then
    local vehicleKeysDetected = false
    for k, v in pairs(VEHICLE_KEYS_RESOURCES) do
        for _, resource in pairs(v) do
            local status = GetResourceState(resource)
            if status == "started" then
                Shared.VehicleKeys = k
                vehicleKeysDetected = true
                print("^3devhub_lib:^7 Vehicle Keys detected: ^2"..k.."^7")
                break
            end
        end
        if vehicleKeysDetected then
            break
        end
    end
    if not vehicleKeysDetected then
        print("^3devhub_lib:^1 Vehicle Keys not detected. Please set it manually.\t^7 Vehicle Keys were automatically set to: ^2custom^7")
        Shared.VehicleKeys = "custom"
    end
end
if isAutoDetect(Shared.InventorySystem) then
    local inventoryDetected = false
    for _, invName in ipairs(INVENTORIES_ORDER) do
        local resources = INVENTORIES[invName]
        if resources then
            for _, resource in pairs(resources) do
                local status = GetResourceState(resource)
                if status == "started" then
                    Shared.InventorySystem = invName
                    inventoryDetected = true
                    print("^3devhub_lib:^7 Inventory System detected: ^2"..invName.."^7")
                    break
                end
            end
        end
        if inventoryDetected then
            break
        end
    end
    if not inventoryDetected then
        print("^3devhub_lib:^1 Inventory System not detected.\t^7 Inventory System was automatically set to: ^2custom^7. You can edit ^3modules/inventories/custom/^7 to add your own inventory integration.")
        Shared.InventorySystem = "custom"
    end
end


if isAutoDetect(Shared.VehicleFuel) then
    local fuelDetected = false
    for k, v in pairs(FUEL_RESOURCES) do
        for _, resource in pairs(v) do
            local status = GetResourceState(resource)
            if status == "started" then
                Shared.VehicleFuel = k
                fuelDetected = true
                print("^3devhub_lib:^7 Fuel System detected: ^2"..k.."^7")
                break
            end
        end
        if fuelDetected then
            break
        end
    end
    if not fuelDetected then
        print("^3devhub_lib:^1 Fuel System not detected. Please set it manually.\t^7 Fuel System was automatically set to: ^2custom^7")
        Shared.VehicleFuel = "custom"
    end
end

function createExport(name, cb)
    exports(name, function(...)
        return cb(...)
    end)
    AddEventHandler(('__cfx_export_dh_lib_%s'):format(name), function(setCB)
        setCB(cb)
    end)
end