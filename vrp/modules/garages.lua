if not vRP.modules.garages then return end

local Garages = class("Garages", vRP.Extension)

function Garages:__construct()
    vRP.Extension.__construct(self)

    self.cfg = module("vrp", "cfg/garages")

    self.jobGarages = {}
    self.customUserGarages = {}

    self.GarageVehiclesMenu(self)

    self.vehiclesTakenOut = {}
end

function Garages:GarageVehiclesMenu()
    vRP.EXT.GUI:registerMenuBuilder("garage.vehicles", function(menu)
        local user = menu.user
        local garageId = menu.data.garageId
        local garage = nil

        local vehicles = {}

        if string.match(garageId, "custom_") then
            garage = self.customUserGarages[user.id][garageId]

            vehicles = garage.vehicles
        else
            garage = self.cfg.garages[garageId]

            if self.cfg.options.anyGarageLocation then
                for _, vehicle in pairs(user.cdata.vehicles) do
                    for _, vehicleType in pairs(garage.types) do
                        if vehicle.type == vehicleType then
                            table.insert(vehicles, vehicle)
                        end
                    end
                end
            else
                for _, vehicle in pairs(user.cdata.vehicles) do
                    if vehicle.garageId == garageId then
                        table.insert(vehicles, vehicle)
                    end
                end
            end
        end

        menu.title = garage.name
        menu.css.header_color = "rgba(200,0,0,0.75)"

        if not next(vehicles) then
            menu:addOption("No vehicles found", function() end)
            return
        end

        for _, vehicle in pairs(vehicles) do
            local function spawnVehicle()
                if self.vehiclesTakenOut[user.id] then
                    for vehicleId, _ in pairs(self.vehiclesTakenOut[user.id]) do
                        if vehicleId == vehicle._id then
                            local vehicleExists = self.remote.doesVehicleExistLocal(user.source, vehicleId)

                            if vehicleExists then
                                vRP.EXT.Base.remote._notify(user.source, "You already have this vehicle out")
                                return
                            else
                                self.vehiclesTakenOut[user.id] = {}
                            end
                        end
                    end
                end

                if self.remote.spawnGarageVehicle(user.source, vehicle, garageId) then
                    user:closeMenu(menu)

                    if not self.vehiclesTakenOut[user.id] then
                        self.vehiclesTakenOut[user.id] = {}
                    end

                    self.vehiclesTakenOut[user.id][vehicle._id] = { garageId = garageId }
                end
            end

            menu:addOption(("[%s] %s"):format(vehicle.props.plate, vehicle.name), spawnVehicle)
        end
    end)
end

function Garages:addCustomUserGarage(userSource, garageId, garage)
    local user = vRP.users_by_source[userSource]
    if not self.customUserGarages[user.id] then
        self.customUserGarages[user.id] = {}
    end

    if not string.match(garageId, "custom_") then
        garageId = "custom_" .. garageId
    end

    if not garage.pickLocation then
        self:log(garageId .. " must have a pickLocation")
        return
    end

    if not garage.spawnLocations then
        self:log(garageId .. " must have spawnLocations")
        return
    end

    if not garage.types then
        self:log(garageId .. " must have types")
        return
    end

    if not garage.name then
        self:log(garageId .. " must have a name")
        return
    end

    garage.id = garageId

    garage.vehicles = {}

    self.customUserGarages[user.id][garageId] = garage
    self.remote._addGarage(user.source, garage, true)
end

function Garages:addVehicleToCustomUserGarage(userId, garageId, vehicle)
    if not self.customUserGarages[userId] then
        self.customUserGarages[userId] = {}
    end

    if not self.customUserGarages[userId][garageId] then
        self:log("garageId " .. garageId .. " does not exist")
        return
    end

    if not vehicle.name then
        self:log("Vehicle must have a name")
        return
    end

    if not vehicle.model then
        self:log(vehicle.name .. " must have a model")
        return
    end

    if not vehicle.type then
        self:log(vehicle.name .. " must have a type")
        return
    end

    if not vehicle.props then
        vehicle.props = {}
    end


    vehicle._id = (#self.customUserGarages[userId][garageId].vehicles + 1)

    table.insert(self.customUserGarages[userId][garageId].vehicles, vehicle._id, vehicle)

    return vehicle._id
end

function Garages:removeVehicleFromCustomUserGarage(userId, garageId, vehicleId, deleteVehicle)
    if self.customUserGarages[userId] then
        if self.customUserGarages[userId][garageId] then
            self.customUserGarages[userId][garageId].vehicles[vehicleId] = nil
        end
    end

    if deleteVehicle then
        local user = vRP.users[userId]


        self.remote.removeVehicleFromCustomUserGarage(user.source, vehicleId)
    end
end

function Garages:removeCustomUserGarage(userId, garageId, deleteVehicles)
    local user = vRP.users[userId]

    self.remote.removeGarage(user.source, garageId)

    if deleteVehicles then
        if self.vehiclesTakenOut[userId] then
            for _, vehicle in pairs(self.vehiclesTakenOut[userId]) do
                if vehicle.garageId == garageId then
                    self.remote.removeVehicleFromCustomUserGarage(user.source, vehicle._id)
                end
            end
        end
    end

    if self.customUserGarages[userId] then
        self.customUserGarages[userId][garageId] = nil
    end
end

function Garages:returnGarageVehicle(vehicleId, vehicleData, garageId, customGarage)
    local user = vRP.users_by_source[source]
    if user and user:isReady() then
        local vehicle = user.cdata.vehicles[vehicleId]
        local garage = self.cfg.garages[garageId]

        if customGarage then
            garageId = self.vehiclesTakenOut[user.id][vehicleId].garageId
            garage = self.customUserGarages[user.id][garageId]
            vehicle = self.customUserGarages[user.id][garageId].vehicles[vehicleId]
        end

        if not self.vehiclesTakenOut[user.id] then return false end

        if vehicle or customGarage then
            if self.cfg.options.returnToAnyGarage then
                if not customGarage then
                    user.cdata.vehicles[vehicleId].props = vehicleData
                    user:save()
                end
                self.vehiclesTakenOut[user.id][vehicleId] = nil
                return true
            else
                for _, vehicleType in pairs(garage.types) do
                    if vehicle.type == vehicleType then
                        if not customGarage then
                            user.cdata.vehicles[vehicleId].props = vehicleData
                            user:save()
                        end
                        self.vehiclesTakenOut[user.id][vehicleId] = nil
                        return true
                    end
                end

                vRP.EXT.Base.remote._notify(user.source, "You cannot return this vehicle to this type of garage")
                return false
            end
        else
            vRP.EXT.Base.remote._notify(user.source, "This vehicle does not exist")
            return false
        end
    end
end

function Garages:vehicleClassToType(vehicleClass)
    return self.cfg.classToType[vehicleClass]
end

Garages.event = {}

function Garages.event:playerJoin(user)
    local userGarages = {}
    for garageId, garage in pairs(self.cfg.garages) do
        garage.id = garageId
        if garage.groups then
            if type(garage.groups) == "table" then
                for _, group in pairs(garage.groups) do
                    if user:hasGroup(group) then
                        userGarages[garageId] = garage
                    end
                end
            else
                if user:hasGroup(garage.groups) then
                    userGarages[garageId] = garage
                end
            end
        else
            userGarages[garageId] = garage
        end
    end

    self.remote._setGarages(user.source, userGarages)
end

function Garages.event:characterLoad(user)
    if not user.cdata.vehicles then
        user.cdata.vehicles = {}
    end
end

Garages.tunnel = {}
function Garages.tunnel:openGarageVehiclesMenu(garageId)
    local user = vRP.users_by_source[source]
    if user and user:isReady() then
        user:openMenu("garage.vehicles", { garageId = garageId })
    end
end

function Garages.tunnel:closeGarageVehiclesMenu()
    local user = vRP.users_by_source[source]
    if user and user:isReady() then
        user:closeMenu()
    end
end

Garages.tunnel.returnGarageVehicle = Garages.returnGarageVehicle
Garages.tunnel.vehicleClassToType = Garages.vehicleClassToType


vRP:registerExtension(Garages)
