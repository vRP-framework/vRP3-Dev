-- local DoorSystemGetActive <const> = DoorSystemGetActive
-- local NetworkHasControlOfDoor <const> = NetworkHasControlOfDoor
-- local NetworkIsDoorNetworked <const> = NetworkIsDoorNetworked
-- local NetworkRequestControlOfDoor <const> = NetworkRequestControlOfDoor
local AddDoorToSystem <const> = AddDoorToSystem
-- local DoorControl <const> = DoorControl
-- local DoorSystemGetAutomaticDistance <const> = DoorSystemGetAutomaticDistance
-- local DoorSystemGetDoorState <const> = DoorSystemGetDoorState
-- local DoorSystemGetOpenRatio <const> = DoorSystemGetOpenRatio
-- local GetStateOfClosestDoorOfType <const> = GetStateOfClosestDoorOfType
-- local IsDoorClosed <const> = IsDoorClosed
-- local RemoveDoorFromSystem <const> = RemoveDoorFromSystem
-- local SetStateOfClosestDoorOfType <const> = SetStateOfClosestDoorOfType
local DoorSystemSetDoorState <const> = DoorSystemSetDoorState
local IsDoorRegisteredWithSystem <const> = IsDoorRegisteredWithSystem
local DoorSystemGetIsPhysicsLoaded <const> = DoorSystemGetIsPhysicsLoaded

RequestAnimDict("anim@heists@keycard@")

local Door = class("Door", vRP.Extension)
local lastInput = 0

-- local function Draw3DText(coords, str)
--     local onScreen, worldX, worldY = World3dToScreen2d(coords.x, coords.y, coords.z)
-- 	local camCoords = GetGameplayCamCoord()
-- 	local scale = 200 / (GetGameplayCamFov() * #(camCoords - coords))
--     if onScreen then
--         SetTextScale(1.0, 0.5 * scale)
--         SetTextFont(4)
--         SetTextColour(255, 255, 255, 255)
--         SetTextEdge(2, 0, 0, 0, 150)
-- 		SetTextProportional(1)
-- 		SetTextOutline()
-- 		SetTextCentre(1)
--         SetTextEntry("STRING")
--         AddTextComponentString(str)
--         DrawText(worldX, worldY)
--     end
-- end

function Door:__construct()
    vRP.Extension.__construct(self)
    self.allDoors = {}
    self.nearbyDoors = {}
    self.Misc = vRP.EXT.Misc
    self.Base = vRP.EXT.Base
    self.initialized = true

    -- CreateThread(function()
    --     self.allDoors = self.remote.requestDoors()
    -- end)

    CreateThread(function()
        local d = 0
        while self.initialized do
            local idle = 2000
            local pos = GetEntityCoords(PlayerPedId())
            for k, v in next, self.nearbyDoors or {} do
                local distance = #(pos - v.pos)
                if distance < 1.2 then
                    if GetGameTimer() - d > 500 then
                        d = GetGameTimer()
                        local message = GlobalState[v.id] and "Unlock Door" or "Lock Door"
                        self.Misc:NativeHelpText(message)
                    end
                    if IsControlJustPressed(0, 38) and GetGameTimer() - lastInput > 200 then
                        lastInput = GetGameTimer()
                        self.remote.tryOpenDoor(v.id)
                    end
                    idle = 10
                end
            end
            Wait(idle)
        end
    end)

    CreateThread(function()
        while self.initialized do
            local ppos = GetEntityCoords(PlayerPedId())
            for k, v in next, self.allDoors or {} do
                if #(v.pos - ppos) < 25.0 then              
                    if not self.nearbyDoors[k] then
                        if not IsDoorRegisteredWithSystem(v.id) then
                            AddDoorToSystem(v.id, v.hash, v.pos.x, v.pos.y, v.pos.z, false, false, false)
                            while not DoorSystemGetIsPhysicsLoaded(v.id) do Wait(0) end
                            DoorSystemSetDoorState(v.id, GlobalState[v.id])                       
                        end
                        self.nearbyDoors[k] = v
                    end
                elseif self.nearbyDoors[k] then
                    self.nearbyDoors[k] = nil
                end
            end
            Wait(2000)
        end
    end)

    self.stateBagDoorHandle = AddStateBagChangeHandler(nil, nil, function(bagName, key, value)
        if bagName == "global" and self.allDoors[key] then
            DoorSystemSetDoorState(key, value and 1 or 0)
        end
    end)
end

function Door:__destruct()
    self.initialized = false
    RemoveStateBagChangeHandler(self.stateBagDoorHandle)
end

function Door:updateDoors(doors)
    self.allDoors = doors
end

function Door:addDoor(door)
    allDoors[door.id] = door
end

function Door:removeDoor(door)
    if allDoors[door.id] then
        allDoors[door.id] = nil
    end

    if nearbyDoors[door.id] then
        nearbyDoors[door.id] = nil
    end
end


Door.tunnel = {}
Door.tunnel.updateDoors = Door.updateDoors
Door.tunnel.addDoor = Door.addDoor
Door.tunnel.removeDoor = Door.removeDoor

vRP:registerExtension(Door)
