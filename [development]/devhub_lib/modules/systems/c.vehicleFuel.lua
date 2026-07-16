local function formatFuel(amount)
    local amountToNumber = tonumber(amount)
    if not amountToNumber then return 100.0 end
    return amountToNumber + 0.0
end

CreateThread(function()
    --[[
        This file defines a custom vehicle fuel system
        It contains the following data properties:
        - @vehicle: The vehicle entity.
        - @amount: The amount of fuel to set (0-100).
    ]]

    if Shared.VehicleFuel == "LegacyFuel" then
        Core.SetVehicleFuel = function(vehicle, amount)
            exports["LegacyFuel"]:SetFuel(vehicle, formatFuel(amount))
        end
    elseif Shared.VehicleFuel == "ps-fuel" then
        Core.SetVehicleFuel = function(vehicle, amount)
            exports['ps-fuel']:SetFuel(vehicle, formatFuel(amount))
        end
    elseif Shared.VehicleFuel == "ox_fuel" then
        Core.SetVehicleFuel = function(vehicle, amount)
            Entity(vehicle).state.fuel = formatFuel(amount)
        end
    elseif Shared.VehicleFuel == "cd_fuel" then
        Core.SetVehicleFuel = function(vehicle, amount)
            exports['cd_fuel']:SetFuel(vehicle, formatFuel(amount))
        end
    elseif Shared.VehicleFuel == "rcore_fuel" then
        Core.SetVehicleFuel = function(vehicle, amount)
            exports["rcore_fuel"]:SetFuel(vehicle, formatFuel(amount))
        end   
    else -- custom or default
        Core.SetVehicleFuel = function(vehicle, amount)
            SetVehicleFuelLevel(vehicle, formatFuel(amount)) -- custom or default
        end
    end
end)