CreateThread( function() 
    --[[
        This file defines a custom vehicle keys system
        It contains the following data properties:
        - @plate: The vehicle plate.
        - @vehicle: The vehicle entity.
    ]]  
    if Shared.VehicleKeys == "qb-vehiclekeys" then
        Core.AddVehicleKeys = function(plate, vehicle)
            TriggerEvent("vehiclekeys:client:SetOwner", plate)
        end
        Core.RemoveVehicleKeys = function(plate, vehicle)
            -- Remove keys from the player
        end
    elseif Shared.VehicleKeys == "qs-vehiclekeys" then
        Core.AddVehicleKeys = function(plate, vehicle)
            local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
            exports['qs-vehiclekeys']:GiveKeys(plate, model)
        end
        Core.RemoveVehicleKeys = function(plate, vehicle)
            local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
            exports['qs-vehiclekeys']:RemoveKeys(plate, model)
        end
    elseif Shared.VehicleKeys == "ak47_vehiclekeys" then
        Core.AddVehicleKeys = function(plate, vehicle)
            exports['ak47_vehiclekeys']:GiveKey(plate, false)
        end
        Core.RemoveVehicleKeys = function(plate, vehicle)
            exports['ak47_vehiclekeys']:RemoveKey(plate, false)
        end
    elseif Shared.VehicleKeys == "t1ger_keys" then
        Core.AddVehicleKeys = function(plate, vehicle)
            local name = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
            exports['t1ger_keys']:GiveJobKeys(plate, name, true)
        end
        Core.RemoveVehicleKeys = function(plate, vehicle)
            -- Remove keys from the player
        end
    elseif Shared.VehicleKeys == "Renewed-Vehiclekeys" then
        Core.AddVehicleKeys = function(plate, vehicle)
            exports['Renewed-Vehiclekeys']:addKey(plate)
        end
        Core.RemoveVehicleKeys = function(plate, vehicle)
            exports['Renewed-Vehiclekeys']:removeKey(plate)
        end
    elseif Shared.VehicleKeys == "cd_garage" then
        Core.AddVehicleKeys = function(plate, vehicle)
            TriggerEvent('cd_garage:AddKeys', plate)
        end
        Core.RemoveVehicleKeys = function(plate, vehicle)
            -- Remove keys from the player
        end
    else -- custom or default
        Core.AddVehicleKeys = function(plate, vehicle)
            -- Add your custom vehicle keys logic here
        end
        Core.RemoveVehicleKeys = function(plate, vehicle)
            -- Add your custom remove keys logic here
        end
    end
end)