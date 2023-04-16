if not vRP.modules.doors then return end

local Door = class("Door", vRP.Extension)


function Door:__construct()
    vRP.Extension.__construct(self)
    self.cfg = module("cfg/doors") or {}
    self.registeredDoors = {}    
end

function Door:getLastId()
    return #self.registeredDoors + 1
end

function Door:tryOpenDoor(doorId)
    local user = vRP.users_by_source[source]
    local currentDoor = self.registeredDoors[doorId]    
    if currentDoor then
        local isPerm = not currentDoor.permissions or user:hasPermissions(currentDoor.permissions)
        if isPerm then
            local ped = GetPlayerPed(user.source)
            TaskPlayAnim(ped, "anim@heists@keycard@", "exit", 8.0, 1.0, -1, 48, 0, 0, 0, 0)        
            Wait(550)
            ClearPedTasks(ped)
            GlobalState[currentDoor.id] = not GlobalState[currentDoor.id]
            if currentDoor.other then
                GlobalState[currentDoor.other] = GlobalState[currentDoor.id]
            end
        end
    end
end


function Door:RegisterDoor(index, doordata, force_update)
    local permissions = doordata.permissions or nil
    if doordata.keyitem then
        if not permissions then permissions = {} end
        permissions[#permissions+1] = '#'..doordata.keyitem:lower() .. '.1'
    end
    local other = nil
    if doordata.isdouble then
        if doordata.isfirst then
            other = index + 1
        else
            other = index - 1
        end
    end

    local id = ("door_%d"):format(index)
    self.registeredDoors[id] = {
        id = id,
        hash = doordata.hash,
        pos = doordata.pos,
        state = doordata.state,
        permissions = permissions,
        other = other and ("door_%d"):format(other)
    }

    GlobalState:set(id, doordata.state or false, true)
    if force_update then
        self.remote._addDoor(-1, self.registeredDoors[id])
    end
end


function Door:addDoor(doordata, force_update)
    if doordata.isdouble then
        for i = 1, 2 do
            local door = doordata[i]
            local index = self:getLastId()            
            self:RegisterDoor(index, door, force_update)
        end
    else
        local door = doordata 
        local index = self:getLastId()
        self:RegisterDoor(index, door, force_update)
    end 
end

function Door:removeDoor(doorId)
    local door = self.registeredDoors[doorId]
    if door then
        GlobalState[door.id] = nil
        self.registeredDoors[door.id] = nil
        self.remote._removeDoor(-1, {id = door.id})
        if door.other and self.registeredDoors[door.other] then
            GlobalState[self.registeredDoors[door.other].id] = nil
            self.registeredDoors[door.other] = nil
            self.remote._removeDoor(-1, {id = self.registeredDoors[door.other].id })
        end
    end
end



function Door:requestDoors()
    return self.registeredDoors
end

Door.event = {}

function Door.event:playerSpawn(user, first_spawn)
    if first_spawn then
        self.remote._updateDoors(user.source, self.registeredDoors)
    end
end

Door.tunnel = {}
Door.tunnel.requestDoors = Door.registeredDoors


vRP:registerExtension(Door)