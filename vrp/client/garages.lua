if not vRP.modules.garages then return end

local Garages = class("Garages", vRP.Extension)

function Garages:__construct()
    vRP.Extension.__construct(self)

    DecorRegister("VehicleID", 3)
    DecorRegister("CustomVehicle", 2)

    -- Configuration handeled from server
    self.cfg = module("vrp", "cfg/garages")

    self.garageBlips = {}
    self.parkingSpaces = {}

    self.garages = {}
    self.garagesToRender = {}

    self.currentGarage = nil
    self.inPickup = false
    self.inReturn = false
    self.inMenu = false

    self.vehiclesOut = {}

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            local playerCoords = GetEntityCoords(PlayerPedId())
            local interactionDistance = self.cfg.options.interactionDistance
            local returnInteractionDistance = self.cfg.options.returnInteractionDistance


            for _, garage in pairs(self.garagesToRender) do
                DrawMarker(1, garage.pickLocation.x, garage.pickLocation.y, garage.pickLocation.z, 0, 0, 0, 0, 0, 0,
                    interactionDistance, interactionDistance, 0.5, 255, 0, 0, 100, false, true, 2, false, false, false,
                    false)

                if #(playerCoords - garage.pickLocation) < interactionDistance then
                    if self.currentGarage ~= garage then
                        vRP.EXT.Base:notifyHelp("Press ~g~E~w~ to open garage")
                        self:showParkingSpaces(garage.id)
                        self.currentGarage = garage
                        self.inPickup = true
                    end


                    if not self.inMenu and GetVehiclePedIsIn(PlayerPedId(), false) == 0 then
                        if IsControlJustPressed(0, 38) then
                            self.remote._openGarageVehiclesMenu(garage.id)
                            vRP.EXT.Base:clearHelp()
                            self.inMenu = true
                        end
                    end
                else
                    if self.currentGarage == garage then
                        self:hideParkingSpaces(self.currentGarage.id)
                        self.remote._closeGarageVehiclesMenu()
                        self.currentGarage = nil
                        self.inPickup = false
                        self.inMenu = false
                    end
                end

                if self.shouldDisplayReturn(garage) then
                    DrawMarker(1, garage.returnLocation.x, garage.returnLocation.y, garage.returnLocation.z, 0, 0,
                        0,
                        0,
                        0, 0, returnInteractionDistance, returnInteractionDistance, 0.5, 255, 0, 0, 100, false,
                        true,
                        2,
                        false, false, false, false)

                    if #(playerCoords - garage.returnLocation) < returnInteractionDistance then
                        if not self.currentGarage then
                            vRP.EXT.Base:notifyHelp("Press ~g~E~w~ to return vehicle")
                            self.currentGarage = garage
                            self.inReturn = true
                        end

                        if IsControlJustPressed(0, 38) then
                            self:returnCurrentVehicle(garage.id)
                            vRP.EXT.Base:clearHelp()
                            self.currentGarage = nil
                        end
                    else
                        if self.currentGarage == garage then
                            self.currentGarage = nil
                            self.inReturn = false
                        end
                    end
                end
            end
        end
    end)


    -- Secondary thread, Optimizes the rendering of nearby garages
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(self.cfg.options.renderDelay)

            self.garagesToRender = {}
            if not self.garages then return end

            local playerCoords = GetEntityCoords(PlayerPedId())

            for _, garage in pairs(self.garages) do
                if #(playerCoords - vector3(garage.pickLocation.x, garage.pickLocation.y, garage.pickLocation.z)) < self.cfg.options.renderDistance then
                    self.garagesToRender[garage.id] = garage
                end
            end
        end
    end)

    function self.shouldDisplayReturn(garage)
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        if not DoesEntityExist(vehicle) then return false end

        if garage.returnLocation then
            if self.cfg.options.returnToAnyGarage then
                return true
            else
                local vehicleType = self.cfg.classToType[GetVehicleClass(vehicle)]
                for _, garageVehicleType in pairs(garage.types) do
                    if vehicleType == garageVehicleType then
                        return true
                    end
                end
            end
        end

        return false
    end
end

function Garages:setGarages(garages)
    self.garages = garages

    if not self.cfg.options.showGaragesAsBlips then return end

    for k, v in pairs(self.garageBlips) do
        RemoveBlip(v)
    end

    self.garageBlips = {}

    for k, v in pairs(self.garages) do
        local blip = AddBlipForCoord(v.pickLocation.x, v.pickLocation.y, v.pickLocation.z)
        SetBlipSprite(blip, 357)
        SetBlipColour(blip, 3)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(v.name)
        EndTextCommandSetBlipName(blip)
        SetBlipRotation(blip, 0)

        self.garageBlips[k] = blip
    end
end

function Garages:addGarage(garage, addBlip, blipData)
    self.garages[garage.id] = garage

    if addBlip then
        blipData = blipData or {}
        local blip = AddBlipForCoord(garage.pickLocation.x, garage.pickLocation.y, garage.pickLocation.z)
        SetBlipSprite(blip, blipData.sprite or 357)
        SetBlipColour(blip, blipData.color or 3)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(garage.name)
        EndTextCommandSetBlipName(blip)
        SetBlipRotation(blip, 0)

        self.garageBlips[garage.id] = blip
    end
end

function Garages:removeGarage(garageId)
    self.garages[garageId] = nil

    if self.garageBlips[garageId] then
        RemoveBlip(self.garageBlips[garageId])
        self.garageBlips[garageId] = nil
    end

    self.garagesToRender[garageId] = nil
    self.remote.closeGarageVehiclesMenu()
end

function Garages:showParkingSpaces(garage)
    if not self.cfg.options.showSpawnsAsBlips then return end
    local garage = self.garages[garage]

    self.parkingSpaces[garage.id] = self.parkingSpaces[garage.id] or {}
    for k, v in pairs(garage.spawnLocations) do
        local blip = AddBlipForCoord(v.x, v.y, v.z)
        if IsAnyVehicleNearPoint(v.x, v.y, v.z, 5.0) then
            SetBlipSprite(blip, 364)
            SetBlipColour(blip, 1)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Occupied parking space")
            EndTextCommandSetBlipName(blip)
        else
            SetBlipSprite(blip, 367)
            SetBlipColour(blip, 2)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Parking space")
            EndTextCommandSetBlipName(blip)
        end
        self.parkingSpaces[garage.id][k] = blip
    end
end

function Garages:hideParkingSpaces(garage)
    if not self.cfg.options.showSpawnsAsBlips then return end
    local garage = self.garages[garage]

    if not self.parkingSpaces[garage.id] then return end

    for k, v in pairs(self.parkingSpaces[garage.id]) do
        RemoveBlip(v)
    end
end

function Garages:getVehicleProperties(vehicle)
    if not DoesEntityExist(vehicle) then
        return
    end

    local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
    local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
    local hasCustomPrimaryColor = GetIsVehiclePrimaryColourCustom(vehicle)
    local dashboardColor = GetVehicleDashboardColor(vehicle)
    local interiorColor = GetVehicleInteriorColour(vehicle)
    local customPrimaryColor = nil
    if hasCustomPrimaryColor then
        customPrimaryColor = { GetVehicleCustomPrimaryColour(vehicle) }
    end

    local hasCustomXenonColor, customXenonColorR, customXenonColorG, customXenonColorB = GetVehicleXenonLightsCustomColor(
        vehicle)
    local customXenonColor = nil
    if hasCustomXenonColor then
        customXenonColor = { customXenonColorR, customXenonColorG, customXenonColorB }
    end

    local hasCustomSecondaryColor = GetIsVehicleSecondaryColourCustom(vehicle)
    local customSecondaryColor = nil
    if hasCustomSecondaryColor then
        customSecondaryColor = { GetVehicleCustomSecondaryColour(vehicle) }
    end

    local extras = {}
    for extraId = 0, 20 do
        if DoesExtraExist(vehicle, extraId) then
            extras[tostring(extraId)] = IsVehicleExtraTurnedOn(vehicle, extraId)
        end
    end

    local doorsBroken, windowsBroken, tyreBurst = {}, {}, {}
    local numWheels = tostring(GetVehicleNumberOfWheels(vehicle))

    local TyresIndex = {             -- Wheel index list according to the number of vehicle wheels.
        ['2'] = { 0, 4 },            -- Bike and cycle.
        ['3'] = { 0, 1, 4, 5 },      -- Vehicle with 3 wheels (get for wheels because some 3 wheels vehicles have 2 wheels on front and one rear or the reverse).
        ['4'] = { 0, 1, 4, 5 },      -- Vehicle with 4 wheels.
        ['6'] = { 0, 1, 2, 3, 4, 5 } -- Vehicle with 6 wheels.
    }

    if TyresIndex[numWheels] then
        for _, idx in pairs(TyresIndex[numWheels]) do
            tyreBurst[tostring(idx)] = IsVehicleTyreBurst(vehicle, idx, false)
        end
    end

    for windowId = 0, 7 do              -- 13
        RollUpWindow(vehicle, windowId) --fix when you put the car away with the window down
        windowsBroken[tostring(windowId)] = not IsVehicleWindowIntact(vehicle, windowId)
    end

    local numDoors = GetNumberOfVehicleDoors(vehicle)
    if numDoors and numDoors > 0 then
        for doorsId = 0, numDoors do
            doorsBroken[tostring(doorsId)] = IsVehicleDoorDamaged(vehicle, doorsId)
        end
    end

    return {
        model = GetEntityModel(vehicle),
        doorsBroken = doorsBroken,
        windowsBroken = windowsBroken,
        tyreBurst = tyreBurst,
        tyresCanBurst = GetVehicleTyresCanBurst(vehicle),
        plate = GetVehicleNumberPlateText(vehicle),
        plateIndex = GetVehicleNumberPlateTextIndex(vehicle),

        bodyHealth = GetVehicleBodyHealth(vehicle),
        engineHealth = GetVehicleEngineHealth(vehicle),
        tankHealth = GetVehiclePetrolTankHealth(vehicle),

        fuelLevel = GetVehicleFuelLevel(vehicle),
        dirtLevel = GetVehicleDirtLevel(vehicle),
        color1 = colorPrimary,
        color2 = colorSecondary,
        customPrimaryColor = customPrimaryColor,
        customSecondaryColor = customSecondaryColor,

        pearlescentColor = pearlescentColor,
        wheelColor = wheelColor,

        dashboardColor = dashboardColor,
        interiorColor = interiorColor,

        wheels = GetVehicleWheelType(vehicle),
        windowTint = GetVehicleWindowTint(vehicle),
        xenonColor = GetVehicleXenonLightsColor(vehicle),
        customXenonColor = customXenonColor,

        neonEnabled = { IsVehicleNeonLightEnabled(vehicle, 0), IsVehicleNeonLightEnabled(vehicle, 1),
            IsVehicleNeonLightEnabled(vehicle, 2), IsVehicleNeonLightEnabled(vehicle, 3) },

        neonColor = table.pack(GetVehicleNeonLightsColour(vehicle)),
        extras = extras,
        tyreSmokeColor = table.pack(GetVehicleTyreSmokeColor(vehicle)),

        modSpoilers = GetVehicleMod(vehicle, 0),
        modFrontBumper = GetVehicleMod(vehicle, 1),
        modRearBumper = GetVehicleMod(vehicle, 2),
        modSideSkirt = GetVehicleMod(vehicle, 3),
        modExhaust = GetVehicleMod(vehicle, 4),
        modFrame = GetVehicleMod(vehicle, 5),
        modGrille = GetVehicleMod(vehicle, 6),
        modHood = GetVehicleMod(vehicle, 7),
        modFender = GetVehicleMod(vehicle, 8),
        modRightFender = GetVehicleMod(vehicle, 9),
        modRoof = GetVehicleMod(vehicle, 10),
        modRoofLivery = GetVehicleRoofLivery(vehicle),

        modEngine = GetVehicleMod(vehicle, 11),
        modBrakes = GetVehicleMod(vehicle, 12),
        modTransmission = GetVehicleMod(vehicle, 13),
        modHorns = GetVehicleMod(vehicle, 14),
        modSuspension = GetVehicleMod(vehicle, 15),
        modArmor = GetVehicleMod(vehicle, 16),

        modTurbo = IsToggleModOn(vehicle, 18),
        modSmokeEnabled = IsToggleModOn(vehicle, 20),
        modXenon = IsToggleModOn(vehicle, 22),

        modFrontWheels = GetVehicleMod(vehicle, 23),
        modCustomFrontWheels = GetVehicleModVariation(vehicle, 23),
        modBackWheels = GetVehicleMod(vehicle, 24),
        modCustomBackWheels = GetVehicleModVariation(vehicle, 24),

        modPlateHolder = GetVehicleMod(vehicle, 25),
        modVanityPlate = GetVehicleMod(vehicle, 26),
        modTrimA = GetVehicleMod(vehicle, 27),
        modOrnaments = GetVehicleMod(vehicle, 28),
        modDashboard = GetVehicleMod(vehicle, 29),
        modDial = GetVehicleMod(vehicle, 30),
        modDoorSpeaker = GetVehicleMod(vehicle, 31),
        modSeats = GetVehicleMod(vehicle, 32),
        modSteeringWheel = GetVehicleMod(vehicle, 33),
        modShifterLeavers = GetVehicleMod(vehicle, 34),
        modAPlate = GetVehicleMod(vehicle, 35),
        modSpeakers = GetVehicleMod(vehicle, 36),
        modTrunk = GetVehicleMod(vehicle, 37),
        modHydrolic = GetVehicleMod(vehicle, 38),
        modEngineBlock = GetVehicleMod(vehicle, 39),
        modAirFilter = GetVehicleMod(vehicle, 40),
        modStruts = GetVehicleMod(vehicle, 41),
        modArchCover = GetVehicleMod(vehicle, 42),
        modAerials = GetVehicleMod(vehicle, 43),
        modTrimB = GetVehicleMod(vehicle, 44),
        modTank = GetVehicleMod(vehicle, 45),
        modWindows = GetVehicleMod(vehicle, 46),
        modLivery = GetVehicleMod(vehicle, 48) == -1 and GetVehicleLivery(vehicle) or GetVehicleMod(vehicle, 48),
        modLightbar = GetVehicleMod(vehicle, 49)
    }
end

function Garages:applyVehicleProperties(vehicle, props)
    if not DoesEntityExist(vehicle) then
        return
    end
    local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
    local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
    SetVehicleModKit(vehicle, 0)

    if props.tyresCanBurst ~= nil then
        SetVehicleTyresCanBurst(vehicle, props.tyresCanBurst)
    end

    if props.plate ~= nil then
        SetVehicleNumberPlateText(vehicle, props.plate)
    end
    if props.plateIndex ~= nil then
        SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex)
    end
    if props.bodyHealth ~= nil then
        SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0)
    end
    if props.engineHealth ~= nil then
        SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0)
    end
    if props.tankHealth ~= nil then
        SetVehiclePetrolTankHealth(vehicle, props.tankHealth + 0.0)
    end
    if props.fuelLevel ~= nil then
        SetVehicleFuelLevel(vehicle, props.fuelLevel + 0.0)
    end
    if props.dirtLevel ~= nil then
        SetVehicleDirtLevel(vehicle, props.dirtLevel + 0.0)
    end
    if props.customPrimaryColor ~= nil then
        SetVehicleCustomPrimaryColour(vehicle, props.customPrimaryColor[1], props.customPrimaryColor[2],
            props.customPrimaryColor[3])
    end
    if props.customSecondaryColor ~= nil then
        SetVehicleCustomSecondaryColour(vehicle, props.customSecondaryColor[1], props.customSecondaryColor[2],
            props.customSecondaryColor[3])
    end
    if props.color1 ~= nil then
        SetVehicleColours(vehicle, props.color1, colorSecondary)
    end
    if props.color2 ~= nil then
        SetVehicleColours(vehicle, props.color1 or colorPrimary, props.color2)
    end
    if props.pearlescentColor ~= nil then
        SetVehicleExtraColours(vehicle, props.pearlescentColor, wheelColor)
    end

    if props.interiorColor ~= nil then
        SetVehicleInteriorColor(vehicle, props.interiorColor)
    end

    if props.dashboardColor ~= nil then
        SetVehicleDashboardColor(vehicle, props.dashboardColor)
    end

    if props.wheelColor ~= nil then
        SetVehicleExtraColours(vehicle, props.pearlescentColor or pearlescentColor, props.wheelColor)
    end
    if props.wheels ~= nil then
        SetVehicleWheelType(vehicle, props.wheels)
    end
    if props.windowTint ~= nil then
        SetVehicleWindowTint(vehicle, props.windowTint)
    end

    if props.neonEnabled ~= nil then
        SetVehicleNeonLightEnabled(vehicle, 0, props.neonEnabled[1])
        SetVehicleNeonLightEnabled(vehicle, 1, props.neonEnabled[2])
        SetVehicleNeonLightEnabled(vehicle, 2, props.neonEnabled[3])
        SetVehicleNeonLightEnabled(vehicle, 3, props.neonEnabled[4])
    end

    if props.extras ~= nil then
        for extraId, enabled in pairs(props.extras) do
            SetVehicleExtra(vehicle, tonumber(extraId) or -1, enabled)
        end
    end

    if props.neonColor ~= nil then
        SetVehicleNeonLightsColour(vehicle, props.neonColor[1], props.neonColor[2], props.neonColor[3])
    end
    if props.xenonColor ~= nil then
        SetVehicleXenonLightsColor(vehicle, props.xenonColor)
    end
    if props.customXenonColor ~= nil then
        SetVehicleXenonLightsCustomColor(vehicle, props.customXenonColor[1], props.customXenonColor[2],
            props.customXenonColor[3])
    end
    if props.modSmokeEnabled ~= nil then
        ToggleVehicleMod(vehicle, 20, true)
    end
    if props.tyreSmokeColor ~= nil then
        SetVehicleTyreSmokeColor(vehicle, props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3])
    end
    if props.modSpoilers ~= nil then
        SetVehicleMod(vehicle, 0, props.modSpoilers, false)
    end
    if props.modFrontBumper ~= nil then
        SetVehicleMod(vehicle, 1, props.modFrontBumper, false)
    end
    if props.modRearBumper ~= nil then
        SetVehicleMod(vehicle, 2, props.modRearBumper, false)
    end
    if props.modSideSkirt ~= nil then
        SetVehicleMod(vehicle, 3, props.modSideSkirt, false)
    end
    if props.modExhaust ~= nil then
        SetVehicleMod(vehicle, 4, props.modExhaust, false)
    end
    if props.modFrame ~= nil then
        SetVehicleMod(vehicle, 5, props.modFrame, false)
    end
    if props.modGrille ~= nil then
        SetVehicleMod(vehicle, 6, props.modGrille, false)
    end
    if props.modHood ~= nil then
        SetVehicleMod(vehicle, 7, props.modHood, false)
    end
    if props.modFender ~= nil then
        SetVehicleMod(vehicle, 8, props.modFender, false)
    end
    if props.modRightFender ~= nil then
        SetVehicleMod(vehicle, 9, props.modRightFender, false)
    end
    if props.modRoof ~= nil then
        SetVehicleMod(vehicle, 10, props.modRoof, false)
    end

    if props.modRoofLivery ~= nil then
        SetVehicleRoofLivery(vehicle, props.modRoofLivery)
    end

    if props.modEngine ~= nil then
        SetVehicleMod(vehicle, 11, props.modEngine, false)
    end
    if props.modBrakes ~= nil then
        SetVehicleMod(vehicle, 12, props.modBrakes, false)
    end
    if props.modTransmission ~= nil then
        SetVehicleMod(vehicle, 13, props.modTransmission, false)
    end
    if props.modHorns ~= nil then
        SetVehicleMod(vehicle, 14, props.modHorns, false)
    end
    if props.modSuspension ~= nil then
        SetVehicleMod(vehicle, 15, props.modSuspension, false)
    end
    if props.modArmor ~= nil then
        SetVehicleMod(vehicle, 16, props.modArmor, false)
    end
    if props.modTurbo ~= nil then
        ToggleVehicleMod(vehicle, 18, props.modTurbo)
    end
    if props.modXenon ~= nil then
        ToggleVehicleMod(vehicle, 22, props.modXenon)
    end
    if props.modFrontWheels ~= nil then
        SetVehicleMod(vehicle, 23, props.modFrontWheels, props.modCustomFrontWheels)
    end
    if props.modBackWheels ~= nil then
        SetVehicleMod(vehicle, 24, props.modBackWheels, props.modCustomBackWheels)
    end
    if props.modPlateHolder ~= nil then
        SetVehicleMod(vehicle, 25, props.modPlateHolder, false)
    end
    if props.modVanityPlate ~= nil then
        SetVehicleMod(vehicle, 26, props.modVanityPlate, false)
    end
    if props.modTrimA ~= nil then
        SetVehicleMod(vehicle, 27, props.modTrimA, false)
    end
    if props.modOrnaments ~= nil then
        SetVehicleMod(vehicle, 28, props.modOrnaments, false)
    end
    if props.modDashboard ~= nil then
        SetVehicleMod(vehicle, 29, props.modDashboard, false)
    end
    if props.modDial ~= nil then
        SetVehicleMod(vehicle, 30, props.modDial, false)
    end
    if props.modDoorSpeaker ~= nil then
        SetVehicleMod(vehicle, 31, props.modDoorSpeaker, false)
    end
    if props.modSeats ~= nil then
        SetVehicleMod(vehicle, 32, props.modSeats, false)
    end
    if props.modSteeringWheel ~= nil then
        SetVehicleMod(vehicle, 33, props.modSteeringWheel, false)
    end
    if props.modShifterLeavers ~= nil then
        SetVehicleMod(vehicle, 34, props.modShifterLeavers, false)
    end
    if props.modAPlate ~= nil then
        SetVehicleMod(vehicle, 35, props.modAPlate, false)
    end
    if props.modSpeakers ~= nil then
        SetVehicleMod(vehicle, 36, props.modSpeakers, false)
    end
    if props.modTrunk ~= nil then
        SetVehicleMod(vehicle, 37, props.modTrunk, false)
    end
    if props.modHydrolic ~= nil then
        SetVehicleMod(vehicle, 38, props.modHydrolic, false)
    end
    if props.modEngineBlock ~= nil then
        SetVehicleMod(vehicle, 39, props.modEngineBlock, false)
    end
    if props.modAirFilter ~= nil then
        SetVehicleMod(vehicle, 40, props.modAirFilter, false)
    end
    if props.modStruts ~= nil then
        SetVehicleMod(vehicle, 41, props.modStruts, false)
    end
    if props.modArchCover ~= nil then
        SetVehicleMod(vehicle, 42, props.modArchCover, false)
    end
    if props.modAerials ~= nil then
        SetVehicleMod(vehicle, 43, props.modAerials, false)
    end
    if props.modTrimB ~= nil then
        SetVehicleMod(vehicle, 44, props.modTrimB, false)
    end
    if props.modTank ~= nil then
        SetVehicleMod(vehicle, 45, props.modTank, false)
    end
    if props.modWindows ~= nil then
        SetVehicleMod(vehicle, 46, props.modWindows, false)
    end

    if props.modLivery ~= nil then
        SetVehicleMod(vehicle, 48, props.modLivery, false)
        SetVehicleLivery(vehicle, props.modLivery)
    end

    if props.windowsBroken ~= nil then
        for k, v in pairs(props.windowsBroken) do
            if v then
                RemoveVehicleWindow(vehicle, tonumber(k) or -1)
            end
        end
    end

    if props.doorsBroken ~= nil then
        for k, v in pairs(props.doorsBroken) do
            if v then
                SetVehicleDoorBroken(vehicle, tonumber(k) or -1, true)
            end
        end
    end

    if props.tyreBurst ~= nil then
        for k, v in pairs(props.tyreBurst) do
            if v then
                SetVehicleTyreBurst(vehicle, tonumber(k) - 1, true, 1000.0)
            end
        end
    end
end

function Garages:spawnGarageVehicle(vehicleData, garageId)
    local garage = self.garages[garageId]
    local customGarage = string.match(garage.id, "custom_")


    if not garage then return false end


    local model = vehicleData.model
    local props = vehicleData.props


    local veh = tonumber(model) or GetHashKey(model) or GetHashKey(vehicleData.name)
    local spots = self:GetAvailableSpots(garage)

    if not spots or #spots == 0 then
        vRP.EXT.Base:notify("No available spots, try again later")
        return false
    end

    self:hideParkingSpaces(garage.id)

    if not IsModelInCdimage(veh) or not IsModelAVehicle(veh) then
        vRP.EXT.Base:notify("This vehicle does not exist")
        return false
    end


    RequestModel(veh)
    while not HasModelLoaded(veh) do
        Citizen.Wait(0)
    end

    local spot = spots[math.random(#spots)]

    local veh = CreateVehicle(veh, spot.x, spot.y, spot.z, spot.w, true, false)

    DecorSetInt(veh, "VehicleID", vehicleData._id)
    DecorSetInt(veh, "CustomVehicle", customGarage and 1 or 0)
    NetworkRegisterEntityAsNetworked(veh)

    self.vehiclesOut[vehicleData._id] = veh

    SetVehicleOnGroundProperly(veh)
    SetVehicleHasBeenOwnedByPlayer(veh, true)

    self:applyVehicleProperties(veh, props)

    TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)

    SetModelAsNoLongerNeeded(veh)

    if self.cfg.options.showBlipsForVehicles then
        local blip = AddBlipForEntity(veh)
        SetBlipSprite(blip, 225)
        SetBlipColour(blip, 3)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(vehicleData.name)
        EndTextCommandSetBlipName(blip)
    end

    return true
end

function Garages:returnCurrentVehicle(garageId)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    local vehicleId = DecorGetInt(vehicle, "VehicleID")
    local customVehicle = DecorGetInt(vehicle, "CustomVehicle")

    if vehicleId == 0 then
        vRP.EXT.Base:notify("This vehicle is not from a garage")
        return
    end

    local vehicleData = self:getVehicleProperties(vehicle)

    if self.remote.returnGarageVehicle(vehicleId, vehicleData, garageId, customVehicle) then
        DeleteEntity(vehicle)
        self.vehiclesOut[vehicleId] = nil
    end
end

function Garages:GetAvailableSpots(garage)
    local garage = garage
    if not garage then return nil end

    local spots = {}

    for k, v in pairs(garage.spawnLocations) do
        local isTaken = IsAnyVehicleNearPoint(v.x, v.y, v.z, 5.0)

        if not isTaken then
            table.insert(spots, v)
        end
    end

    return spots
end

function Garages:doesVehicleExistLocal(vehicleId)
    return self.vehiclesOut[vehicleId] ~= nil and DoesEntityExist(self.vehiclesOut[vehicleId])
end

function Garages:removeVehicleFromCustomUserGarage(vehicleId)
    DeleteEntity(self.vehiclesOut[vehicleId])
    self.vehiclesOut[vehicleId] = nil
end

Garages.tunnel = {}
Garages.tunnel.setOptions = Garages.setOptions
Garages.tunnel.setGarages = Garages.setGarages
Garages.tunnel.addGarage = Garages.addGarage
Garages.tunnel.removeGarage = Garages.removeGarage
Garages.tunnel.applyVehicleProperties = Garages.applyVehicleProperties
Garages.tunnel.getVehicleProperties = Garages.getVehicleProperties
Garages.tunnel.spawnGarageVehicle = Garages.spawnGarageVehicle
Garages.tunnel.doesVehicleExistLocal = Garages.doesVehicleExistLocal
Garages.tunnel.removeVehicleFromCustomUserGarage = Garages.removeVehicleFromCustomUserGarage


vRP:registerExtension(Garages)
