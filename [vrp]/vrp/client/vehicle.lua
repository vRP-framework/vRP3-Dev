-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.vehicle then return end

local Vehicle = class("Vehicle", vRP.Extension)

function Vehicle:__construct()
  vRP.Extension.__construct(self)
	
	-- init decorators
  DecorRegister("vRP.owner", 3)

  self.vehicles = {} -- map of vehicle model => veh id (owned vehicles)
  self.hash_models = {} -- map of hash => model
	
	self.out_vehicles = {} -- map of vehicle model => {cstate, position, rotation}, unloaded out vehicles to spawn
end

-- veh: vehicle game id
-- return owner character id and model or nil if not managed by vRP
function Vehicle:getVehicleInfo(veh)
  if veh and DecorExistOn(veh, "vRP.owner") then
    local model = self.hash_models[GetEntityModel(veh)]
    if model then
      return DecorGetInt(veh, "vRP.owner"), model
    end
  end
end

function Vehicle:getOwnedVehicles()
	return self.vehicles
end

-- spawn vehicle
-- will be placed on ground properly
-- one vehicle per model allowed at the same time
--
-- state: (optional) vehicle state (client)
-- position: (optional) {x,y,z}, if not passed the vehicle will be spawned on the player (and will be put inside the vehicle)
-- rotation: (optional) quaternion {x,y,z,w}, if passed with the position, will be applied to the vehicle entity
function Vehicle:spawnVehicle(model, state, position, rotation) 
  self:despawnVehicle(model)

  -- load vehicle model
  local mhash = GetHashKey(model)

  local i = 0
  while not HasModelLoaded(mhash) and i < 10000 do
    RequestModel(mhash)
    Citizen.Wait(10)
    i = i+1
  end

  -- spawn car
  if HasModelLoaded(mhash) then
    local ped = GetPlayerPed(-1)

    local x,y,z
    if position then
      x,y,z = table.unpack(position)
    else
      x,y,z = vRP.EXT.Base:getPosition()
    end

    local nveh = CreateVehicle(mhash, x,y,z+0.5, 0.0, true, false)
		local state = vRP.EXT.Vehicle_state:getVehicleState(nveh)
	
		for k,v in pairs(state.customization) do
			--print(k,v)
		end
	
    if position and rotation then
      SetEntityQuaternion(nveh, table.unpack(rotation))
    end
		
    if not position then -- set vehicle heading same as player
      SetEntityHeading(nveh, GetEntityHeading(ped))
    end

    SetVehicleOnGroundProperly(nveh)
    SetEntityInvincible(nveh,false)
		
    if not position then
      SetPedIntoVehicle(ped,nveh,-1) -- put player inside
    end

    if not state.customization.plate_txt then
			SetVehicleNumberPlateText(nveh, "P "..vRP.EXT.Identity.registration)
		else
			SetVehicleNumberPlateText(nveh, state.customization.plate_txt)
		end
		
    SetEntityAsMissionEntity(nveh, true, true)
    SetVehicleHasBeenOwnedByPlayer(nveh,true)

    -- set decorators
    DecorSetInt(nveh, "vRP.owner", vRP.EXT.Base.cid)
    self.vehicles[model] = nveh -- mark as owned

    SetModelAsNoLongerNeeded(mhash)

    if state then
			print(state)
			vRP.EXT.Vehicle_state.remote:setVehicleState(nveh, state)
      --self:setVehicleState(nveh, state)
    end

    --vRP:triggerEvent("garageVehicleSpawn", model)
  end
end

-- return true if despawned
function Vehicle:despawnVehicle(model)
  local veh = self.vehicles[model]
  if veh then
    --vRP:triggerEvent("garageVehicleDespawn", model)

    -- remove vehicle
    SetVehicleHasBeenOwnedByPlayer(veh,false)
    SetEntityAsMissionEntity(veh, false, true)
    SetVehicleAsNoLongerNeeded(Citizen.PointerValueIntInitialized(veh))
    Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(veh))
    self.vehicles[model] = nil

    return true
  end
end

function Vehicle:despawnVehicles()
  for model in pairs(self.vehicles) do
    self:despawnVehicle(model)
  end
end

-- get all game vehicles
-- return list of veh
function Vehicle:getAllVehicles()
  local vehs = {}
	
  local it, veh = FindFirstVehicle()
  if veh then 
		table.insert(vehs, veh) 
	end
	
  local ok
  repeat
    ok, veh = FindNextVehicle(it)
    if ok and veh then 
			table.insert(vehs, veh) 
		end
		
  until not ok
  EndFindVehicle(it)

  return vehs
end

-- return map of veh => distance
function Vehicle:getNearestVehicles(radius)
  local r = {}

  local px,py,pz = vRP.EXT.Base:getPosition()

  for _,veh in pairs(self:getAllVehicles()) do
    local x,y,z = table.unpack(GetEntityCoords(veh,true))
    local distance = GetDistanceBetweenCoords(x,y,z,px,py,pz,true)
		
    if distance <= radius then
      r[veh] = distance
    end
  end

  return r
end

-- return veh
function Vehicle:getNearestVehicle(radius)
  local veh

  local vehs = self:getNearestVehicles(radius)
  local min = radius+10.0
  for _veh,dist in pairs(vehs) do
    if dist < min then
      min = dist 
      veh = _veh 
    end
  end

  return veh 
end

function Vehicle:despawnNearestVehicle(radius)
  local veh

  local vehs = self:getNearestVehicles(radius)
  local min = radius+10.0
  for _veh,dist in pairs(vehs) do
    if dist < min then
      min = dist 
      veh = _veh 
    end
		
		SetEntityAsNoLongerNeeded(veh)
		DeleteEntity(veh)
  end
end

function Vehicle:despawnNearbyVehicles(radius)
	local r = {}

  local px,py,pz = vRP.EXT.Base:getPosition()

  for _,veh in pairs(self:getAllVehicles()) do
    local x,y,z = table.unpack(GetEntityCoords(veh,true))
    local distance = GetDistanceBetweenCoords(x,y,z,px,py,pz,true)
		
    if distance <= radius then
      SetEntityAsNoLongerNeeded(veh)
		DeleteEntity(veh)
    end
  end
end

-- try re-own vehicles
function Vehicle:tryOwnVehicles()
  for _, veh in pairs(self:getAllVehicles()) do
    local cid, model = self:getVehicleInfo(veh)
    if cid and vRP.EXT.Base.cid == cid then -- owned
      local old_veh = self.vehicles[model]
      if old_veh and IsEntityAVehicle(old_veh) then -- still valid
        if old_veh ~= veh then -- remove this new one
          SetVehicleHasBeenOwnedByPlayer(veh,false)
          SetEntityAsMissionEntity(veh, false, true)
          SetVehicleAsNoLongerNeeded(Citizen.PointerValueIntInitialized(veh))
          Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(veh))
        end
      else -- no valid old veh
        self.vehicles[model] = veh -- re-own
      end
    end
  end
end

function Vehicle:trySpawnOutVehicles()
  local x,y,z = vRP.EXT.Base:getPosition()

  -- spawn out vehicles
  for model, data in pairs(self.out_vehicles) do
    if not self.vehicles[model] then -- not already spawned
      local vx,vy,vz = table.unpack(data[2])
      local distance = GetDistanceBetweenCoords(x,y,z,vx,vy,vz,true)

      if distance <= self.respawn_radius then
        self:spawnVehicle(model, data[1], data[2], data[3])
      end
    end
  end
end

-- cleanup invalid owned vehicles
function Vehicle:cleanupVehicles()
  for model, veh in pairs(self.vehicles) do
    if not IsEntityAVehicle(veh) then
      self.vehicles[model] = nil
    end
  end
end

function Vehicle:fixNearestVehicle(radius)
  local veh = self:getNearestVehicle(radius)
  if IsEntityAVehicle(veh) then
    SetVehicleFixed(veh)
  end
end

function Vehicle:replaceNearestVehicle(radius)
  local veh = self:getNearestVehicle(radius)
  if IsEntityAVehicle(veh) then
    SetVehicleOnGroundProperly(veh)
  end
end


-- return model or nil
function Vehicle:getNearestOwnedVehicle(radius)
  self:cleanupVehicles()
  self:tryOwnVehicles() -- get back network lost vehicles

  local px,py,pz = vRP.EXT.Base:getPosition()
  local min_dist
  local min_k
  for k,veh in pairs(self.vehicles) do
    local x,y,z = table.unpack(GetEntityCoords(veh,true))
    local dist = GetDistanceBetweenCoords(x,y,z,px,py,pz,true)

    if dist <= radius+0.0001 then
      if not min_dist or dist < min_dist then
        min_dist = dist
        min_k = k
      end
    end
  end

  return min_k
end

-- Return distance to trunk of nearest owned vehicle within a radius
function Vehicle:getNearestOwnedVehicleTrunk(radius)
  local px,py,pz = vRP.EXT.Base:getPosition()
  local min_dist
  
  for k,veh in pairs(self.vehicles) do
	local index = GetEntityBoneIndexByName(veh, "platelight")
	local x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(veh, 0.0, -2.5, 0.0))
	local dist = GetDistanceBetweenCoords(x,y,z,px,py,pz,true)
	
	if dist <= radius+0.0001 then
      if not min_dist or dist < min_dist then
        min_dist = dist
      end
    end
  end
  
  return min_dist
end

-- return ok,x,y,z
function Vehicle:getAnyOwnedVehiclePosition()
  self:cleanupVehicles()
  self:tryOwnVehicles() -- get back network lost vehicles

  for model,veh in pairs(self.vehicles) do
    if IsEntityAVehicle(veh) then
      local x,y,z = table.unpack(GetEntityCoords(veh,true))
      return true,x,y,z
    end
  end

  return false
end

-- return x,y,z or nil
function Vehicle:getOwnedVehiclePosition(model)
  self:cleanupVehicles()
  self:tryOwnVehicles() -- get back network lost vehicles

  local veh = self.vehicles[model]
  if veh then
    return table.unpack(GetEntityCoords(veh,true))
  end
end

function Vehicle:putInOwnedVehicle(model)
  local veh = self.vehicles[model]
  if veh then
    SetPedIntoVehicle(GetPlayerPed(-1),veh,-1) -- put player inside
  end
end

-- eject the ped from the vehicle
function Vehicle:ejectVehicle()
  local ped = GetPlayerPed(-1)
  if IsPedSittingInAnyVehicle(ped) then
    local veh = GetVehiclePedIsIn(ped,false)
    TaskLeaveVehicle(ped, veh, 4160)
  end
end

function Vehicle:isInVehicle()
  local ped = GetPlayerPed(-1)
  return IsPedSittingInAnyVehicle(ped) 
end

-- return model or nil if not in owned vehicle
function Vehicle:getInOwnedVehicleModel()
  local veh = GetVehiclePedIsIn(GetPlayerPed(-1),false)
  local cid, model = self:getVehicleInfo(veh)
  if cid and cid == vRP.EXT.Base.cid then
    return model
  end
end

-- TUNNEL
Vehicle.tunnel = {}

function Vehicle.tunnel:registerModels(models)
  -- generate models hashes
  for model in pairs(models) do
    local hash = GetHashKey(model)
    if hash then
      self.hash_models[hash] = model
    end
  end
end

function Vehicle.tunnel:setOutVehicles(out_vehicles)
  for model, data in pairs(out_vehicles) do
    self.out_vehicles[model] = data
  end
end

function Vehicle.tunnel:removeOutVehicles(out_vehicles)
  for model in pairs(out_vehicles) do
    self.out_vehicles[model] = nil
  end
end

function Vehicle.tunnel:clearOutVehicles()
  self.out_vehicles = {}
end

-- VEHICLE COMMANDS

function Vehicle:vc_openDoor(model, door_index)
  local vehicle = self.vehicles[model]
  if vehicle then
    SetVehicleDoorOpen(vehicle,door_index,0,false)
  end
end

function Vehicle:vc_closeDoor(model, door_index)
  local vehicle = self.vehicles[model]
  if vehicle then
    SetVehicleDoorShut(vehicle,door_index)
  end
end

function Vehicle:vc_detachTrailer(model)
  local vehicle = self.vehicles[model]
  if vehicle then
    DetachVehicleFromTrailer(vehicle)
  end
end

function Vehicle:vc_detachTowTruck(model)
  local vehicle = self.vehicles[model]
  if vehicle then
    local ent = GetEntityAttachedToTowTruck(vehicle)
    if IsEntityAVehicle(ent) then
      DetachVehicleFromTowTruck(vehicle,ent)
    end
  end
end

function Vehicle:vc_detachCargobob(model)
  local vehicle = self.vehicles[model]
  if vehicle then
    local ent = GetVehicleAttachedToCargobob(vehicle)
    if IsEntityAVehicle(ent) then
      DetachVehicleFromCargobob(vehicle,ent)
    end
  end
end

function Vehicle:vc_toggleEngine(model)
  local vehicle = self.vehicles[model]
  if vehicle then
    local running = Citizen.InvokeNative(0xAE31E7DF9B5B132E,vehicle) -- GetIsVehicleEngineRunning
    SetVehicleEngineOn(vehicle,not running,true,true)
    if running then
      SetVehicleUndriveable(vehicle,true)
    else
      SetVehicleUndriveable(vehicle,false)
    end
  end
end

-- return true if locked, false if unlocked
function Vehicle:vc_toggleLock(model)
  local vehicle = self.vehicles[model]
  if vehicle then
    local veh = vehicle
    local locked = GetVehicleDoorLockStatus(veh) >= 2
    if locked then -- unlock
      SetVehicleDoorsLockedForAllPlayers(veh, false)
      SetVehicleDoorsLocked(veh,1)
      SetVehicleDoorsLockedForPlayer(veh, PlayerId(), false)
      return false
    else -- lock
      SetVehicleDoorsLocked(veh,2)
      SetVehicleDoorsLockedForAllPlayers(veh, true)
      return true
    end
  end
end

Vehicle.tunnel = {}

Vehicle.tunnel.spawnVehicle = Vehicle.spawnVehicle
Vehicle.tunnel.despawnVehicle = Vehicle.despawnVehicle
Vehicle.tunnel.despawnVehicles = Vehicle.despawnVehicles
Vehicle.tunnel.fixNearestVehicle = Vehicle.fixNearestVehicle
Vehicle.tunnel.replaceNearestVehicle = Vehicle.replaceNearestVehicle
Vehicle.tunnel.despawnNearestVehicle = Vehicle.despawnNearestVehicle
Vehicle.tunnel.despawnNearbyVehicles = Vehicle.despawnNearbyVehicles	--
Vehicle.tunnel.getNearestOwnedVehicle = Vehicle.getNearestOwnedVehicle
Vehicle.tunnel.getNearestOwnedVehicleTrunk = Vehicle.getNearestOwnedVehicleTrunk
Vehicle.tunnel.getAnyOwnedVehiclePosition = Vehicle.getAnyOwnedVehiclePosition
Vehicle.tunnel.getOwnedVehiclePosition = Vehicle.getOwnedVehiclePosition
Vehicle.tunnel.putInOwnedVehicle = Vehicle.putInOwnedVehicle
Vehicle.tunnel.getInOwnedVehicleModel = Vehicle.getInOwnedVehicleModel
Vehicle.tunnel.tryOwnVehicles = Vehicle.tryOwnVehicles
Vehicle.tunnel.trySpawnOutVehicles = Vehicle.trySpawnOutVehicles
Vehicle.tunnel.cleanupVehicles = Vehicle.cleanupVehicles
Vehicle.tunnel.ejectVehicle = Vehicle.ejectVehicle
Vehicle.tunnel.isInVehicle = Vehicle.isInVehicle
Vehicle.tunnel.vc_openDoor = Vehicle.vc_openDoor
Vehicle.tunnel.vc_closeDoor = Vehicle.vc_closeDoor
Vehicle.tunnel.vc_detachTrailer = Vehicle.vc_detachTrailer
Vehicle.tunnel.vc_detachTowTruck = Vehicle.vc_detachTowTruck
Vehicle.tunnel.vc_detachCargobob = Vehicle.vc_detachCargobob
Vehicle.tunnel.vc_toggleEngine = Vehicle.vc_toggleEngine
Vehicle.tunnel.vc_toggleLock = Vehicle.vc_toggleLock

vRP:registerExtension(Vehicle)