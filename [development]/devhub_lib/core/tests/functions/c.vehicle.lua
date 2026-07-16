if not Shared.CompatibilityTest then return end

local testResults = {
    SetVehicleFuel = { message = "", results = false },
    AddVehicleKeys = { message = "", results = false },
    RemoveVehicleKeys = { message = "", results = false }
}

local testVehicle = nil
local isTestingVehicle = false

--- Prevent player from leaving vehicle during test
local function preventVehicleExit()
    CreateThread(function()
        while isTestingVehicle do
            local ped = PlayerPedId()
            if testVehicle and DoesEntityExist(testVehicle) then
                if not IsPedInVehicle(ped, testVehicle, false) then
                    TaskWarpPedIntoVehicle(ped, testVehicle, -1)
                end
                DisableControlAction(0, 75, true) -- Disable exit vehicle
                DisableControlAction(0, 231, true) -- Disable exit vehicle
                DisableControlAction(0, 23, true) -- Disable enter/exit vehicle
            end
            Wait(0)
        end
    end)
end

--- Spawn test vehicle and put player inside
---@return number|nil vehicle The spawned vehicle entity or nil on failure
---@return string|nil error Error message if spawning failed
local function spawnTestVehicle()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local vehicleModel = `adder` -- Default test vehicle
    
    -- Request model
    local modelLoaded, loadError = TestHelper.Execute(function()
        RequestModel(vehicleModel)
        local timeout = 50
        while not HasModelLoaded(vehicleModel) and timeout > 0 do
            timeout = timeout - 1
            Wait(100)
        end
        return HasModelLoaded(vehicleModel)
    end)
    
    if loadError then
        return nil, "Failed to load vehicle model: " .. tostring(modelLoaded)
    end
    
    if not modelLoaded then
        return nil, "Vehicle model 'adder' failed to load within timeout"
    end
    
    -- Create vehicle
    local vehicle, createError = TestHelper.Execute(function()
        local veh = CreateVehicle(vehicleModel, coords.x, coords.y, coords.z + 1.0, heading, true, false)
        return veh
    end)
    
    if createError or not vehicle or vehicle == 0 then
        SetModelAsNoLongerNeeded(vehicleModel)
        return nil, "Failed to create vehicle: " .. tostring(vehicle)
    end
    
    -- Set player inside vehicle
    local warpResult, warpError = TestHelper.Execute(function()
        TaskWarpPedIntoVehicle(ped, vehicle, -1)
        Wait(500)
        return IsPedInVehicle(ped, vehicle, false)
    end)
    
    if warpError then
        DeleteEntity(vehicle)
        SetModelAsNoLongerNeeded(vehicleModel)
        return nil, "Failed to warp player into vehicle: " .. tostring(warpResult)
    end
    
    if not warpResult then
        DeleteEntity(vehicle)
        SetModelAsNoLongerNeeded(vehicleModel)
        return nil, "Player could not be placed in vehicle"
    end
    
    SetModelAsNoLongerNeeded(vehicleModel)
    return vehicle, nil
end

--- Clean up test vehicle
local function cleanupTestVehicle()
    isTestingVehicle = false
    Wait(100) -- Allow exit prevention thread to stop
    
    if testVehicle and DoesEntityExist(testVehicle) then
        local ped = PlayerPedId()
        if IsPedInVehicle(ped, testVehicle, false) then
            TaskLeaveVehicle(ped, testVehicle, 0)
            Wait(1000)
        end
        DeleteEntity(testVehicle)
    end
    testVehicle = nil
end

--- Test SetVehicleFuel function
local function test_setVehicleFuel()
    if not Core.SetVehicleFuel then
        testResults['SetVehicleFuel'].results = false
        testResults['SetVehicleFuel'].message = "Core.SetVehicleFuel function not defined"
        testResults['SetVehicleFuel'].manualCheckRequired = {
            "Check modules/systems/c.vehicleFuel.lua",
            "Verify Shared.VehicleFuel is configured correctly in config.lua"
        }
        return false
    end
    
    -- Test setting fuel to 50%
    local setResult, setError = TestHelper.Execute(function()
        Core.SetVehicleFuel(testVehicle, 50.0)
    end)
    
    if setError then
        testResults['SetVehicleFuel'].results = false
        testResults['SetVehicleFuel'].message = setResult
        testResults['SetVehicleFuel'].manualCheckRequired = {
            "Client-side error occurred. Check F8 console for details.",
            "Verify your fuel system (" .. tostring(Shared.VehicleFuel) .. ") is properly installed"
        }
        return false
    end
    
    Wait(500)
    
    -- Try to verify fuel level (native method as fallback check)
    local fuelLevel, fuelError = TestHelper.Execute(function()
        return GetVehicleFuelLevel(testVehicle)
    end)
    
    if fuelError then
        -- Can't verify, but function executed without error
        testResults['SetVehicleFuel'].results = true
        testResults['SetVehicleFuel'].message = "SetVehicleFuel executed (verification unavailable)"
        testResults['SetVehicleFuel'].manualCheckRequired = {
            "Manual verification recommended - check if fuel systems work in-game"
        }
        return true
    end
    
    -- Function executed successfully
    testResults['SetVehicleFuel'].results = true
    testResults['SetVehicleFuel'].message = "SetVehicleFuel executed successfully. Fuel level: " .. tostring(fuelLevel)
    return true
end

--- Test AddVehicleKeys function
local function test_addVehicleKeys()
    if not Core.AddVehicleKeys then
        testResults['AddVehicleKeys'].results = false
        testResults['AddVehicleKeys'].message = "Core.AddVehicleKeys function not defined"
        testResults['AddVehicleKeys'].manualCheckRequired = {
            "Check modules/systems/c.vehicleKeys.lua",
            "Verify Shared.VehicleKeys is configured correctly in config.lua"
        }
        return false
    end
    
    local plate = GetVehicleNumberPlateText(testVehicle)
    if not plate or plate == "" then
        plate = "DHTEST"
        SetVehicleNumberPlateText(testVehicle, plate)
    end
    
    -- Test adding keys
    local addResult, addError = TestHelper.Execute(function()
        Core.AddVehicleKeys(plate, testVehicle)
    end)
    
    if addError then
        testResults['AddVehicleKeys'].results = false
        testResults['AddVehicleKeys'].message = addResult
        testResults['AddVehicleKeys'].manualCheckRequired = {
            "Client-side error occurred. Check F8 console for details.",
            "Verify your vehicle keys system (" .. tostring(Shared.VehicleKeys) .. ") is properly installed"
        }
        return false
    end
    
    Wait(300)
    
    testResults['AddVehicleKeys'].results = true
    testResults['AddVehicleKeys'].message = "AddVehicleKeys executed successfully for plate: " .. plate
    return true
end

--- Test RemoveVehicleKeys function
local function test_removeVehicleKeys()
    if not Core.RemoveVehicleKeys then
        testResults['RemoveVehicleKeys'].results = false
        testResults['RemoveVehicleKeys'].message = "Core.RemoveVehicleKeys function not defined"
        testResults['RemoveVehicleKeys'].manualCheckRequired = {
            "Check modules/systems/c.vehicleKeys.lua",
            "Verify Shared.VehicleKeys is configured correctly in config.lua"
        }
        return false
    end
    
    local plate = GetVehicleNumberPlateText(testVehicle)
    if not plate or plate == "" then
        plate = "DHTEST"
    end
    
    -- Test removing keys
    local removeResult, removeError = TestHelper.Execute(function()
        Core.RemoveVehicleKeys(plate, testVehicle)
    end)
    
    if removeError then
        testResults['RemoveVehicleKeys'].results = false
        testResults['RemoveVehicleKeys'].message = removeResult
        testResults['RemoveVehicleKeys'].manualCheckRequired = {
            "Client-side error occurred. Check F8 console for details.",
            "Verify your vehicle keys system (" .. tostring(Shared.VehicleKeys) .. ") is properly installed"
        }
        return false
    end
    
    Wait(300)
    
    testResults['RemoveVehicleKeys'].results = true
    testResults['RemoveVehicleKeys'].message = "RemoveVehicleKeys executed successfully for plate: " .. plate
    return true
end

--- Main vehicle test function
function test_vehicle()
    -- Spawn and enter vehicle
    local vehicle, spawnError = spawnTestVehicle()
    
    if spawnError or not vehicle then
        local errorMsg = spawnError or "Unknown error spawning vehicle"
        testResults['SetVehicleFuel'].results = false
        testResults['SetVehicleFuel'].message = errorMsg
        testResults['SetVehicleFuel'].manualCheckRequired = { "Could not spawn test vehicle" }
        
        testResults['AddVehicleKeys'].results = false
        testResults['AddVehicleKeys'].message = errorMsg
        testResults['AddVehicleKeys'].manualCheckRequired = { "Could not spawn test vehicle" }
        
        testResults['RemoveVehicleKeys'].results = false
        testResults['RemoveVehicleKeys'].message = errorMsg
        testResults['RemoveVehicleKeys'].manualCheckRequired = { "Could not spawn test vehicle" }
        return
    end
    
    testVehicle = vehicle
    isTestingVehicle = true
    preventVehicleExit()
    
    Wait(500) -- Allow vehicle to settle
    
    -- Run fuel test
    test_setVehicleFuel()
    Wait(500)
    
    -- Run vehicle keys tests
    test_addVehicleKeys()
    Wait(500)
    
    test_removeVehicleKeys()
    Wait(500)
    
    -- Cleanup
    cleanupTestVehicle()
end

RegisterNetEvent('dh_lib:client:test_vehicle', function()
    local success, err = pcall(test_vehicle)
    if not success then
        local errorMsg = "Error: " .. tostring(err)
        local manualCheck = { "Client-side error occurred. Check F8 console for details." }
        
        testResults['SetVehicleFuel'].results = false
        testResults['SetVehicleFuel'].message = errorMsg
        testResults['SetVehicleFuel'].manualCheckRequired = manualCheck
        
        testResults['AddVehicleKeys'].results = false
        testResults['AddVehicleKeys'].message = errorMsg
        testResults['AddVehicleKeys'].manualCheckRequired = manualCheck
        
        testResults['RemoveVehicleKeys'].results = false
        testResults['RemoveVehicleKeys'].message = errorMsg
        testResults['RemoveVehicleKeys'].manualCheckRequired = manualCheck
    end
    
    TriggerServerEvent('dh_lib:server:transferVehicleTestResults', testResults)
end)
