if not Shared.CompatibilityTest then return end

local testResults = {
    TargetEntity = { message = "", results = false },
    TargetCoords = { message = "", results = false },
    TargetModel = { message = "", results = false },
    TargetGlobalVehicle = { message = "", results = false },
    TargetGlobalPlayer = { message = "", results = false },
}

local testEntities = {}
local testCompleted = {
    entity = false,
    coords = false,
    model = false,
    globalVehicle = false,
    globalPlayer = false,
}

local testCoords = {
    entity = vector4(1191.2314, 3116.1899, 39.4141, 180.2529),
    coords = vector4(1181.3364, 3112.9534, 39.4141, 180.2235),
    model = vector4(1168.7892, 3110.2542, 39.4141, 180.6971),
    vehicle = vector4(1158.6219, 3108.6409, 39.4141, 180.3203),
    -- Player positions in front of each station
    playerEntity = vector4(1191.2314, 3113.5, 39.4141, 0.0),
    playerCoords = vector4(1181.3364, 3110.5, 39.4141, 0.0),
    playerModel = vector4(1168.7892, 3107.5, 39.4141, 0.0),
    playerVehicle = vector4(1158.6219, 3105.0, 39.4141, 0.0),
}

--- Set test result with error
---@param testName string The test name key
---@param errorMsg string The error message
local function setTestError(testName, errorMsg)
    testResults[testName].results = false
    testResults[testName].message = errorMsg
    testResults[testName].manualCheckRequired = { "Client-side error occurred. Check F8 console for details." }
end

local function displayText(text)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(0.0, 1.0)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(0.05, 0.1)
end

local function drawText3D(coords, text)
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z)
    local camCoords = GetGameplayCamCoords()
    local dist = #(camCoords - coords)
    
    if onScreen then
        local scale = (1 / dist) * 2
        local fov = (1 / GetGameplayCamFov()) * 100
        scale = scale * fov
        
        SetTextScale(0.0, 0.55 * scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

local function spawnPed(model, coords)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end
    local ped = CreatePed(4, model, coords.x, coords.y, coords.z, coords.w, false, false)
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    return ped
end

local function spawnObject(model, coords)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end
    local entity = CreateObject(model, coords.x, coords.y, coords.z, false, false, false)
    SetEntityHeading(entity, coords.w)
    FreezeEntityPosition(entity, true)
    return entity
end

local function spawnVehicle(model, coords)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end
    local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w, false, false)
    FreezeEntityPosition(vehicle, true)
    return vehicle
end

local function cleanup()
    -- Remove targets first (with error handling to prevent cleanup failures)
    pcall(function()
        if testEntities.entity and DoesEntityExist(testEntities.entity) then
            Core.RemoveLocalEntityFromTarget(testEntities.entity, "dh_test_entity")
        end
    end)
    
    pcall(function()
        Core.RemoveCoordsFromTarget("dh_test_coords")
    end)
    
    pcall(function()
        Core.RemoveGlobalVehicleFromTarget("dh_test_global_vehicle")
    end)
    
    pcall(function()
        Core.RemoveGlobalPlayerFromTarget("dh_test_global_player")
    end)
    
    -- Delete entities
    for _, entity in pairs(testEntities) do
        if DoesEntityExist(entity) then
            DeleteEntity(entity)
        end
    end
    testEntities = {}
end

--- Get another player's server ID and coordinates via server callback
---@param cb function Callback with (otherPlayerId, otherPlayerPed or nil, serverCoords or nil)
local function getOtherPlayer(cb)
    Core.TriggerServerCallback('dh_lib:test:getOtherPlayer', function(otherPlayerId, px, py, pz, pheading)
        if otherPlayerId then
            local serverCoords = px and vector4(px, py, pz, pheading) or nil
            -- Try to get the ped from the player ID
            local otherPlayer = GetPlayerFromServerId(otherPlayerId)
            if otherPlayer and otherPlayer ~= -1 then
                local ped = GetPlayerPed(otherPlayer)
                if ped and DoesEntityExist(ped) then
                    cb(otherPlayerId, ped, serverCoords)
                    return
                end
            end
            -- Player exists on server but not in client streaming range yet
            cb(otherPlayerId, nil, serverCoords)
        else
            cb(nil, nil, nil)
        end
    end)
end

--- Teleport player near another player
---@param targetPed number The target player's ped
local function teleportNearPlayer(targetPed)
    local targetCoords = GetEntityCoords(targetPed)
    local heading = GetEntityHeading(targetPed)
    
    -- Position the tester 2 units in front of the target player
    local offsetX = targetCoords.x - (math.sin(math.rad(heading)) * 2.0)
    local offsetY = targetCoords.y + (math.cos(math.rad(heading)) * 2.0)
    
    local ped = PlayerPedId()
    SetEntityCoords(ped, offsetX, offsetY, targetCoords.z, false, false, false, false)
    
    -- Face towards the target player
    local myCoords = GetEntityCoords(ped)
    local dirX = targetCoords.x - myCoords.x
    local dirY = targetCoords.y - myCoords.y
    local facingHeading = math.deg(math.atan2(dirX, dirY))
    SetEntityHeading(ped, facingHeading)
end

local function teleportPlayer(coords)
    local ped = PlayerPedId()
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
    SetEntityHeading(ped, coords.w)
end

RegisterNetEvent('dh_lib:client:test_target_interaction:entity', function()
    testCompleted.entity = true
    testResults['TargetEntity'].results = true
    testResults['TargetEntity'].message = "AddLocalEntityToTarget - Interaction successful"
end)

RegisterNetEvent('dh_lib:client:test_target_interaction:coords', function()
    testCompleted.coords = true
    testResults['TargetCoords'].results = true
    testResults['TargetCoords'].message = "AddCoordsToTarget - Interaction successful"
end)

RegisterNetEvent('dh_lib:client:test_target_interaction:model', function()
    testCompleted.model = true
    testResults['TargetModel'].results = true
    testResults['TargetModel'].message = "AddModelToTarget - Interaction successful"
end)

RegisterNetEvent('dh_lib:client:test_target_interaction:globalVehicle', function()
    testCompleted.globalVehicle = true
    testResults['TargetGlobalVehicle'].results = true
    testResults['TargetGlobalVehicle'].message = "AddGlobalVehicleToTarget - Interaction successful"
end)

RegisterNetEvent('dh_lib:client:test_target_interaction:globalPlayer', function()
    testCompleted.globalPlayer = true
    testResults['TargetGlobalPlayer'].results = true
    testResults['TargetGlobalPlayer'].message = "AddGlobalPlayerToTarget - Interaction successful"
end)

function test_target_interaction()
    -- Reset
    testCompleted = { entity = false, coords = false, model = false, globalVehicle = false, globalPlayer = false }
    testResults['TargetEntity'].results = false
    testResults['TargetCoords'].results = false
    testResults['TargetModel'].results = false
    testResults['TargetGlobalVehicle'].results = false
    testResults['TargetGlobalPlayer'].results = false
    
    -- Spawn all entities first
    testEntities.entity = spawnPed(GetHashKey("a_m_m_business_01"), testCoords.entity)
    testEntities.model = spawnObject(GetHashKey("prop_vend_snak_01"), testCoords.model)
    testEntities.vehicle = spawnVehicle(GetHashKey("adder"), testCoords.vehicle)
    
    Wait(500)
    
    -- Track which targets were added successfully
    local targetErrors = {
        entity = nil,
        coords = nil,
        model = nil,
        globalVehicle = nil,
        globalPlayer = nil,
    }
    
    -- Add all targets with error handling
    local _, entityErr = TestHelper.Execute(function()
        Core.AddLocalEntityToTarget(testEntities.entity, {
            name = "dh_test_entity",
            icon = "fas fa-user",
            label = "[TEST] AddLocalEntityToTarget",
            event = "dh_lib:client:test_target_interaction:entity",
            handler = function() return true end,
        })
    end)
    if entityErr then
        targetErrors.entity = _
        setTestError('TargetEntity', _)
    end
    
    local _, coordsErr = TestHelper.Execute(function()
        Core.AddCoordsToTarget(vector3(testCoords.coords.x, testCoords.coords.y, testCoords.coords.z), {
            name = "dh_test_coords",
            icon = "fas fa-map-marker",
            label = "[TEST] AddCoordsToTarget",
            event = "dh_lib:client:test_target_interaction:coords",
            handler = function() return true end,
            radius = 2.0,
        })
    end)
    if coordsErr then
        targetErrors.coords = _
        setTestError('TargetCoords', _)
    end
    
    local _, modelErr = TestHelper.Execute(function()
        Core.AddModelToTarget(GetHashKey("prop_vend_snak_01"), {
            name = "dh_test_model",
            icon = "fas fa-box",
            label = "[TEST] AddModelToTarget",
            event = "dh_lib:client:test_target_interaction:model",
            handler = function() return true end,
        })
    end)
    if modelErr then
        targetErrors.model = _
        setTestError('TargetModel', _)
    end
    
    local _, vehicleErr = TestHelper.Execute(function()
        Core.AddGlobalVehicleToTarget({
            name = "dh_test_global_vehicle",
            icon = "fas fa-car",
            label = "[TEST] AddGlobalVehicleToTarget",
            event = "dh_lib:client:test_target_interaction:globalVehicle",
            handler = function() return true end,
        })
    end)
    if vehicleErr then
        targetErrors.globalVehicle = _
        setTestError('TargetGlobalVehicle', _)
    end
    
    Wait(500)
    
    local currentTimeout = 0
    local currentTestName = ""
    local currentTestKey = ""
    local showDisplay = false
    local testRunning = true
    local showCoordsMarker = false
    
    Citizen.CreateThread(function()
        while testRunning do
            if showDisplay and currentTestKey ~= "" then
                displayText("~w~" .. currentTestName .. "~n~~w~Time: ~y~" .. currentTimeout .. "s~n~" .. (testCompleted[currentTestKey] and "~g~PASSED" or "~r~Interact with target"))
            end
            if showCoordsMarker and not testCompleted.coords then
                drawText3D(vector3(testCoords.coords.x, testCoords.coords.y, testCoords.coords.z + 1.0), "~y~[TARGET HERE]~n~~w~AddCoordsToTarget Test")
                DrawMarker(1, testCoords.coords.x, testCoords.coords.y, testCoords.coords.z - 0.9, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 1.0, 255, 255, 0, 100, false, true, 2, false, nil, nil, false)
            end
            Wait(0)
        end
    end)
    
    local function waitForInteraction(testKey, timeout, displayName)
        currentTestKey = testKey
        currentTestName = displayName
        currentTimeout = timeout
        showDisplay = true
        
        while currentTimeout > 0 and not testCompleted[testKey] do
            currentTimeout = currentTimeout - 1
            Wait(1000)
        end
        
        showDisplay = false
    end
    
    -- Test 1: AddLocalEntityToTarget (ped)
    if not targetErrors.entity then
        teleportPlayer(testCoords.playerEntity)
        Wait(500)
        waitForInteraction("entity", 15, "TEST 1/5: AddLocalEntityToTarget")
        if not testCompleted.entity and not testResults['TargetEntity'].message:find("Error:") then
            testResults['TargetEntity'].message = "No interaction detected"
            testResults['TargetEntity'].manualCheckRequired = { "Interact with the ped (businessman) to pass AddLocalEntityToTarget test." }
        end
    end
    
    -- Test 2: AddCoordsToTarget
    if not targetErrors.coords then
        teleportPlayer(testCoords.playerCoords)
        showCoordsMarker = true
        Wait(500)
        waitForInteraction("coords", 15, "TEST 2/5: AddCoordsToTarget")
        showCoordsMarker = false
        if not testCompleted.coords and not testResults['TargetCoords'].message:find("Error:") then
            testResults['TargetCoords'].message = "No interaction detected"
            testResults['TargetCoords'].manualCheckRequired = { "Go to the marked coords area to pass AddCoordsToTarget test." }
        end
    end
    
    -- Test 3: AddModelToTarget (vending machine)
    if not targetErrors.model then
        teleportPlayer(testCoords.playerModel)
        Wait(500)
        waitForInteraction("model", 15, "TEST 3/5: AddModelToTarget")
        if not testCompleted.model and not testResults['TargetModel'].message:find("Error:") then
            testResults['TargetModel'].message = "No interaction detected"
            testResults['TargetModel'].manualCheckRequired = { "Interact with the vending machine to pass AddModelToTarget test." }
        end
    end
    
    -- Test 4: AddGlobalVehicleToTarget (vehicle)
    if not targetErrors.globalVehicle then
        teleportPlayer(testCoords.playerVehicle)
        Wait(500)
        waitForInteraction("globalVehicle", 15, "TEST 4/5: AddGlobalVehicleToTarget")
        if not testCompleted.globalVehicle and not testResults['TargetGlobalVehicle'].message:find("Error:") then
            testResults['TargetGlobalVehicle'].message = "No interaction detected"
            testResults['TargetGlobalVehicle'].manualCheckRequired = { "Interact with the vehicle (Adder) to pass AddGlobalVehicleToTarget test." }
        end
    end
    
    -- Test 5: AddGlobalPlayerToTarget (requires another player)
    local globalPlayerTestDone = false
    getOtherPlayer(function(otherPlayerId, otherPlayerPed, serverCoords)
        if not otherPlayerId then
            -- No other player online - fail the test
            testResults['TargetGlobalPlayer'].results = false
            testResults['TargetGlobalPlayer'].message = "No other player online"
            testResults['TargetGlobalPlayer'].manualCheckRequired = { "Invite another player to the server to test AddGlobalPlayerToTarget." }
            globalPlayerTestDone = true
            return
        end
        
        -- Add global player target
        local _, playerErr = TestHelper.Execute(function()
            Core.AddGlobalPlayerToTarget({
                name = "dh_test_global_player",
                icon = "fas fa-user-friends",
                label = "[TEST] AddGlobalPlayerToTarget",
                event = "dh_lib:client:test_target_interaction:globalPlayer",
                handler = function() return true end,
            })
        end)
        if playerErr then
            setTestError('TargetGlobalPlayer', _)
            globalPlayerTestDone = true
            return
        end
        
        -- Teleport near the other player using server coords first (works even if not streamed in)
        if not otherPlayerPed and serverCoords then
            -- Use server-side coords to teleport close to the other player
            local ped = PlayerPedId()
            local heading = serverCoords.w or 0.0
            local offsetX = serverCoords.x - (math.sin(math.rad(heading)) * 2.0)
            local offsetY = serverCoords.y + (math.cos(math.rad(heading)) * 2.0)
            SetEntityCoords(ped, offsetX, offsetY, serverCoords.z, false, false, false, false)
            local dirX = serverCoords.x - offsetX
            local dirY = serverCoords.y - offsetY
            SetEntityHeading(ped, math.deg(math.atan2(dirX, dirY)))
            
            -- Wait for the other player to stream in
            local streamTimeout = 10
            while streamTimeout > 0 do
                local otherPlayer = GetPlayerFromServerId(otherPlayerId)
                if otherPlayer and otherPlayer ~= -1 then
                    local otherPed = GetPlayerPed(otherPlayer)
                    if otherPed and DoesEntityExist(otherPed) then
                        otherPlayerPed = otherPed
                        break
                    end
                end
                streamTimeout = streamTimeout - 1
                Wait(1000)
            end
            
            if not otherPlayerPed then
                testResults['TargetGlobalPlayer'].results = false
                testResults['TargetGlobalPlayer'].message = "Other player did not stream in after teleport"
                testResults['TargetGlobalPlayer'].manualCheckRequired = { "The other player could not be loaded. Make sure the other player is spawned in and not in an interior." }
                globalPlayerTestDone = true
                return
            end
        elseif not otherPlayerPed then
            testResults['TargetGlobalPlayer'].results = false
            testResults['TargetGlobalPlayer'].message = "Could not get other player coordinates"
            testResults['TargetGlobalPlayer'].manualCheckRequired = { "The other player is too far away and coordinates could not be retrieved." }
            globalPlayerTestDone = true
            return
        end
        
        -- Teleport precisely near the other player (now streamed in)
        teleportNearPlayer(otherPlayerPed)
        Wait(500)
        waitForInteraction("globalPlayer", 15, "TEST 5/5: AddGlobalPlayerToTarget")
        if not testCompleted.globalPlayer and not testResults['TargetGlobalPlayer'].message:find("Error:") then
            testResults['TargetGlobalPlayer'].message = "No interaction detected"
            testResults['TargetGlobalPlayer'].manualCheckRequired = { "Interact with the other player to pass AddGlobalPlayerToTarget test." }
        end
        globalPlayerTestDone = true
    end)
    
    -- Wait for global player test to complete
    while not globalPlayerTestDone do
        Wait(100)
    end
    
    testRunning = false
    Wait(1000)
    
    -- Cleanup
    cleanup()
end

RegisterNetEvent('dh_lib:client:test_target', function()
    local success, err = pcall(test_target_interaction)
    if not success then
        -- On error, mark all tests as failed with the error message
        local errorMsg = "Error: " .. tostring(err)
        local manualCheck = { "Client-side error occurred. Check F8 console for details." }
        
        for testName, _ in pairs(testResults) do
            if not testResults[testName].results then
                testResults[testName].message = errorMsg
                testResults[testName].manualCheckRequired = manualCheck
            end
        end
    end
    TriggerServerEvent('dh_lib:server:transferTargetTestResults', {
        TargetEntity = testResults['TargetEntity'],
        TargetCoords = testResults['TargetCoords'],
        TargetModel = testResults['TargetModel'],
        TargetGlobalVehicle = testResults['TargetGlobalVehicle'],
        TargetGlobalPlayer = testResults['TargetGlobalPlayer'],
    })
end)
