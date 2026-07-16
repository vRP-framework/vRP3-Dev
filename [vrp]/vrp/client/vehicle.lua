-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.vehicle then return end

local Vehicle = class("Vehicle", vRP.Extension)

-- METHODS

-- localize frequent natives for small perf win
local GetPlayerPed = GetPlayerPed
local IsEntityAVehicle = IsEntityAVehicle
local GetEntityCoords = GetEntityCoords
local GetEntityQuaternion = GetEntityQuaternion
local table_unpack = table.unpack
local RequestModel = RequestModel
local HasModelLoaded = HasModelLoaded
local Citizen_Wait = Citizen.Wait
local GetHashKey = GetHashKey
local CreateVehicle = CreateVehicle
local SetVehicleOnGroundProperly = SetVehicleOnGroundProperly
local SetEntityInvincible = SetEntityInvincible
local SetPedIntoVehicle = SetPedIntoVehicle
local SetVehicleNumberPlateText = SetVehicleNumberPlateText
local SetEntityAsMissionEntity = SetEntityAsMissionEntity
local SetVehicleHasBeenOwnedByPlayer = SetVehicleHasBeenOwnedByPlayer
local DecorSetInt = DecorSetInt
local SetModelAsNoLongerNeeded = SetModelAsNoLongerNeeded
local GetEntityModel = GetEntityModel

function Vehicle:__construct()
  vRP.Extension.__construct(self)

  -- init decorators
  DecorRegister("vRP.owner", 3)

  self.vehicles = {} -- map of vehicle model => veh id (owned vehicles)
  self.hash_models = {} -- map of hash => model

  self.update_interval = 30 -- seconds
  self.check_interval = 30 -- seconds
  self.update_multiplyer = 10000 -- ms multiplier (set by server)
  self.respawn_radius = 200

  self.state_ready = false -- flag, if true will try to re-own/spawn periodically out vehicles

  self.out_vehicles = {} -- map of vehicle model => {cstate, position, rotation}, unloaded out vehicles to spawn

  -- task: save vehicle states
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(self.update_interval * self.update_multiplyer)

      if self.state_ready then
        local states = {}

        for model, veh in pairs(self.vehicles) do
          if IsEntityAVehicle(veh) then
            local state = self:getVehicleState(model)
            state.position = {table_unpack(GetEntityCoords(veh, true))}
            state.rotation = {GetEntityQuaternion(veh)}

            states[model] = state

            if self.out_vehicles[model] then -- update out vehicle state data
              self.out_vehicles[model] = {state, state.position, state.rotation}
            end
          end
        end

        self.remote._updateVehicleStates(states)
        vRP.EXT.PlayerState.remote._update({ in_owned_vehicle = self:getInOwnedVehicleModel() or false})
      end
    end
  end)

  -- task: vehicles check
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(self.check_interval * self.update_multiplyer)

      if self.state_ready then
        self:cleanupVehicles()
        self:tryOwnVehicles() -- get back network lost vehicles
        self:trySpawnOutVehicles()
      end
    end
  end)
end

-- veh: vehicle game id
-- return owner character id and model or nil if not managed by vRP
-- Refactored getVehicleInfo function
function Vehicle:getVehicleInfo(veh)
  if DecorExistOn(veh, "vRP.owner") then
    local model = self.hash_models[GetEntityModel(veh)]
    if model then
      return DecorGetInt(veh, "vRP.owner"), model
    end
  end
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
	
	local function isLocationClear(x, y, z, radius)
    local veh = GetClosestVehicle(x, y, z, radius or 3.0, 0, 70)
    return not DoesEntityExist(veh)
  end

  -- Load vehicle model
  local mhash = GetHashKey(model)
  RequestModel(mhash)
  local i = 0
  while not HasModelLoaded(mhash) and i < 1000 do
    Citizen_Wait(10)
    i = i + 1
  end

  if HasModelLoaded(mhash) then
    local ped = GetPlayerPed(-1)
    local x, y, z

    if position and position.x and position.y and position.z then
      x, y, z = position.x, position.y, position.z
    else
      x, y, z = table_unpack(GetEntityCoords(ped))
    end
		
		-- Check if location is clear before spawning
    if not isLocationClear(x, y, z, 3.0) then
      print("[Vehicle] Spawn location is blocked.")  --debug
      return  -- stop spawning to avoid overlap
    end
		
    local nveh = CreateVehicle(mhash, x, y, z + 0.5, 0.0, true, false)
		
    -- Set rotation and heading if provided
    if rotation then
      SetEntityQuaternion(nveh, table_unpack(rotation))
    else
      SetEntityHeading(nveh, GetEntityHeading(ped))
    end
		
    -- Finalize vehicle setup
    SetVehicleOnGroundProperly(nveh)
    SetEntityInvincible(nveh, false)

    -- Put the player inside the vehicle if no position is provided
    if not position then
      SetPedIntoVehicle(ped, nveh, -1)
    end

    -- Set vehicle plate
    if not state.custom or state.custom.plate_txt then
			SetVehicleNumberPlateText(nveh, "P "..vRP.EXT.Identity.registration)
		else
			SetVehicleNumberPlateText(nveh, state.custom.plate_txt)
		end

		-- Set vehicle ownership
    SetEntityAsMissionEntity(nveh, true, true)
    SetVehicleHasBeenOwnedByPlayer(nveh, true)
		
		-- set decorators
    DecorSetInt(nveh, "vRP.owner", vRP.EXT.Base.cid)
    self.vehicles[model] = nveh

    -- Set vehicle previous state or current 
		-- customizations on purchase should be empty
    if state and (not state.customization or next(state.customization) == nil) then
			self:setVehicleState(nveh, self:getVehicleCustomization(nveh))
		else
			self:setVehicleState(nveh, state)
		end

    -- Mark the model as no longer needed and trigger event
    SetModelAsNoLongerNeeded(mhash)
    vRP:triggerEvent("VehicleVehicleSpawn", model)
  end
end

-- return true if despawned
function Vehicle:despawnVehicle(model)
  local veh = self.vehicles[model]
  if veh then			
    vRP:triggerEvent("VehicleVehicleDespawn", model)

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
  if veh then table.insert(vehs, veh) end
  local ok
  repeat
    ok, veh = FindNextVehicle(it)
    if ok and veh then table.insert(vehs, veh) end
  until not ok
  EndFindVehicle(it)

  return vehs
end

-- return map of veh => distance
function Vehicle:getNearestVehicles(radius)
  local r = {}

  local px,py,pz = vRP.EXT.Base:getPosition()

  for _,veh in pairs(self:getAllVehicles()) do
    local x,y,z = table_unpack(GetEntityCoords(veh,true))
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
  if not self.respawn_radius then return end -- early check to prevent nil compare

  local x,y,z = vRP.EXT.Base:getPosition()

  for model, data in pairs(self.out_vehicles) do
    if not self.vehicles[model] then
      local vx,vy,vz = table_unpack(data[2])
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

function Vehicle:getVehicleClass(radius)
	local veh = self:getNearestVehicle(radius)
  if IsEntityAVehicle(veh) then
    return GetVehicleClass(veh)
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
    local x,y,z = table_unpack(GetEntityCoords(veh,true))
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

-- return ok,x,y,z
function Vehicle:getAnyOwnedVehiclePosition()
  self:cleanupVehicles()
  self:tryOwnVehicles() -- get back network lost vehicles

  for model,veh in pairs(self.vehicles) do
    if IsEntityAVehicle(veh) then
      local x,y,z = table_unpack(GetEntityCoords(veh,true))
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
    return table_unpack(GetEntityCoords(veh,true))
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

-- VEHICLE STATE

function Vehicle:getVehicleCustomization(veh)
  local custom = {}

  custom.colours = {GetVehicleColours(veh)}
  custom.extra_colours = {GetVehicleExtraColours(veh)}
  custom.plate_index = GetVehicleNumberPlateTextIndex(veh)
  custom.plate_txt = GetVehicleNumberPlateText(veh)
  custom.wheel_type = GetVehicleWheelType(veh)
  custom.window_tint = GetVehicleWindowTint(veh)
  custom.livery = GetVehicleLivery(veh)
  custom.neons = {}
  for i=0,3 do
    custom.neons[i] = IsVehicleNeonLightEnabled(veh, i)
  end
  custom.neon_colour = {GetVehicleNeonLightsColour(veh)}
  custom.tyre_smoke_color = {GetVehicleTyreSmokeColor(veh)}

  custom.mods = {}
  for i=0,49 do
    custom.mods[i] = GetVehicleMod(veh, i)
  end

  custom.turbo_enabled = IsToggleModOn(veh, 18)
  custom.smoke_enabled = IsToggleModOn(veh, 20)
  custom.xenon_enabled = IsToggleModOn(veh, 22)

  return custom
end

-- partial update per property
-- Refactored setVehicleCustomization function
function Vehicle:setVehicleCustomization(veh, custom)
  veh = veh or GetVehiclePedIsIn(GetPlayerPed(-1), false)
  SetVehicleModKit(veh, 0)

  -- Apply each customization if it's provided
  if custom.colours then SetVehicleColours(veh, table_unpack(custom.colours)) end
  if custom.extra_colours then SetVehicleExtraColours(veh, table_unpack(custom.extra_colours)) end
  if custom.plate_index then SetVehicleNumberPlateTextIndex(veh, custom.plate_index) end
  if custom.plate_txt then SetVehicleNumberPlateText(veh, custom.plate_txt) end
  if custom.wheel_type then SetVehicleWheelType(veh, custom.wheel_type) end
  if custom.window_tint then SetVehicleWindowTint(veh, custom.window_tint) end
  if custom.livery then SetVehicleLivery(veh, custom.livery) end

  -- Neons
  if custom.neons then
    for i = 0, 3 do
      SetVehicleNeonLightEnabled(veh, i, custom.neons[i])
    end
  end
  if custom.neon_colour then SetVehicleNeonLightsColour(veh, table_unpack(custom.neon_colour)) end
  if custom.tyre_smoke_color then SetVehicleTyreSmokeColor(veh, table_unpack(custom.tyre_smoke_color)) end

  -- Mods
  if custom.mods then
    for i, mod in pairs(custom.mods) do
      SetVehicleMod(veh, i, mod, false)
    end
  end

  -- Toggle mods if enabled
  if custom.turbo_enabled ~= nil then ToggleVehicleMod(veh, 18, custom.turbo_enabled) end
  if custom.smoke_enabled ~= nil then ToggleVehicleMod(veh, 20, custom.smoke_enabled) end
  if custom.xenon_enabled ~= nil then ToggleVehicleMod(veh, 22, custom.xenon_enabled) end
end


function Vehicle:getVehicleState(veh)
	veh = veh or GetVehiclePedIsIn(GetPlayerPed(-1), false)
	
  local state = {
    customization = self:getVehicleCustomization(veh),
    condition = {
      health = GetEntityHealth(veh),
      engine_health = GetVehicleEngineHealth(veh),
      petrol_tank_health = GetVehiclePetrolTankHealth(veh),
      dirt_level = GetVehicleDirtLevel(veh)
    }
  }

  state.condition.windows = {}
  for i=0,7 do 
    state.condition.windows[i] = IsVehicleWindowIntact(veh, i)
  end

  state.condition.tyres = {}
  for i=0,7 do
    local tyre_state = 2 -- 2: fine, 1: burst, 0: completely burst
    if IsVehicleTyreBurst(veh, i, true) then
      tyre_state = 0
    elseif IsVehicleTyreBurst(veh, i, false) then
      tyre_state = 1
    end

    state.condition.tyres[i] = tyre_state
  end

  state.condition.doors = {}
  for i=0,5 do
    state.condition.doors[i] = not IsVehicleDoorDamaged(veh, i)
  end

  state.locked = (GetVehicleDoorLockStatus(veh) >= 2)

  return state
end

-- partial update per property
function Vehicle:setVehicleState(veh, state)
  -- Customization
  if state.customization then
    self:setVehicleCustomization(veh, state.customization)
  end

  -- Vehicle condition
  local condition = state.condition
  if condition then
    local health, engine, tank, dirt = condition.health, condition.engine_health, condition.petrol_tank_health, condition.dirt_level
		
    if health then SetEntityHealth(veh, health) end
    if engine then SetVehicleEngineHealth(veh, engine) end
    if tank then SetVehiclePetrolTankHealth(veh, tank) end
    if dirt then SetVehicleDirtLevel(veh, dirt) end

    for i, broken in pairs(condition.windows or {}) do
      if not broken then SmashVehicleWindow(veh, i) end
    end

    for i, tyre in pairs(condition.tyres or {}) do
      if tyre < 2 then
        SetVehicleTyreBurst(veh, i, tyre == 1, 1000.01)
      end
    end

    for i, door in pairs(condition.doors or {}) do
      if not door then SetVehicleDoorBroken(veh, i, true) end
    end
  end

  -- Lock state
  if state.locked ~= nil then
    local pid = PlayerId()
    if state.locked then
      SetVehicleDoorsLocked(veh, 2)
      SetVehicleDoorsLockedForAllPlayers(veh, true)
    else
      SetVehicleDoorsLockedForAllPlayers(veh, false)
      SetVehicleDoorsLocked(veh, 1)
      SetVehicleDoorsLockedForPlayer(veh, pid, false)
    end
  end
end

-- Vehicle controls

function Vehicle:openDoor(model, door_index)
  local veh = self.vehicles[model]
  if not veh then return end
	
  SetVehicleDoorOpen(veh, door_index, 0, false)
end

function Vehicle:closeDoor(model, door_index)
  local veh = self.vehicles[model]
  if not veh then return end
	
  SetVehicleDoorShut(veh, door_index)
end

function Vehicle:detachTrailer(model)
  local veh = self.vehicles[model]
  if not veh then return end
	
  DetachVehicleFromTrailer(veh)
end

function Vehicle:detachTowTruck(model)
  local veh = self.vehicles[model]
  if not veh then return end

  local attached = GetEntityAttachedToTowTruck(veh)
  if IsEntityAVehicle(attached) then
    DetachVehicleFromTowTruck(veh, attached)
  end
end

function Vehicle:detachCargobob(model)
  local veh = self.vehicles[model]
  if not veh then return end

  local attached = GetVehicleAttachedToCargobob(veh)
  if IsEntityAVehicle(attached) then
    DetachVehicleFromCargobob(veh, attached)
  end
end

function Vehicle:toggleEngine(model)
  local veh = self.vehicles[model]
  if not veh then return end

  local running = Citizen.InvokeNative(0xAE31E7DF9B5B132E, veh) -- GetIsVehicleEngineRunning
  local toggle = not running

  SetVehicleEngineOn(veh, toggle, true, true)
  SetVehicleUndriveable(veh, not toggle)
end

-- return true if locked, false if unlocked
function Vehicle:toggleLock(model)
  local veh = self.vehicles[model]
  if not veh then return end

  local locked = GetVehicleDoorLockStatus(veh) >= 2
  if locked then
    -- Unlock vehicle
    SetVehicleDoorsLockedForAllPlayers(veh, false)
    SetVehicleDoorsLocked(veh, 1)
    SetVehicleDoorsLockedForPlayer(veh, PlayerId(), false)
    return false
  else
    -- Lock vehicle
    SetVehicleDoorsLocked(veh, 2)
    SetVehicleDoorsLockedForAllPlayers(veh, true)
    return true
  end
end


-- TUNNEL
Vehicle.tunnel = {}

function Vehicle.tunnel:setConfig(update_interval, check_interval, respawn_radius)
  self.update_interval = update_interval
  self.check_interval = check_interval
  self.respawn_radius = respawn_radius
end

function Vehicle.tunnel:setStateReady(state)
  self.state_ready = state
end

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

-- Spawning/Despawn
Vehicle.tunnel.spawnVehicle = Vehicle.spawnVehicle
Vehicle.tunnel.despawnVehicle = Vehicle.despawnVehicle
Vehicle.tunnel.despawnVehicles = Vehicle.despawnVehicles
Vehicle.tunnel.trySpawnOutVehicles = Vehicle.trySpawnOutVehicles
Vehicle.tunnel.cleanupVehicles = Vehicle.cleanupVehicles

--Ownership / Access
Vehicle.tunnel.getVehicleClass = Vehicle.getVehicleClass
Vehicle.tunnel.getNearestVehicle = Vehicle.getNearestVehicle
Vehicle.tunnel.getNearestOwnedVehicle = Vehicle.getNearestOwnedVehicle
Vehicle.tunnel.getOwnedVehiclePosition = Vehicle.getOwnedVehiclePosition
Vehicle.tunnel.getAnyOwnedVehiclePosition = Vehicle.getAnyOwnedVehiclePosition
Vehicle.tunnel.tryOwnVehicles = Vehicle.tryOwnVehicles
Vehicle.tunnel.putInOwnedVehicle = Vehicle.putInOwnedVehicle
Vehicle.tunnel.getInOwnedVehicleModel = Vehicle.getInOwnedVehicleModel

-- Repair / Replacement
Vehicle.tunnel.fixNearestVehicle = Vehicle.fixNearestVehicle
Vehicle.tunnel.replaceNearestVehicle = Vehicle.replaceNearestVehicle
Vehicle.tunnel.ejectVehicle = Vehicle.ejectVehicle

--State / Locking
Vehicle.tunnel.getVehicleState = Vehicle.getVehicleState
Vehicle.tunnel.setVehicleCustomization = Vehicle.setVehicleCustomization
Vehicle.tunnel.isInVehicle = Vehicle.isInVehicle

-- Vehicle Controls
Vehicle.tunnel.vc_openDoor = Vehicle.vc_openDoor
Vehicle.tunnel.vc_closeDoor = Vehicle.vc_closeDoor
Vehicle.tunnel.vc_detachTrailer = Vehicle.vc_detachTrailer
Vehicle.tunnel.vc_detachTowTruck = Vehicle.vc_detachTowTruck
Vehicle.tunnel.vc_detachCargobob = Vehicle.vc_detachCargobob
Vehicle.tunnel.vc_toggleEngine = Vehicle.vc_toggleEngine
Vehicle.tunnel.vc_toggleLock = Vehicle.vc_toggleLock

vRP:registerExtension(Vehicle)

-- add tunnel handlers for config/state (do not overwrite existing tunnel table)
Vehicle.tunnel.setStateReady = function(state)
  local s = vRP.EXT.Vehicle
  if s then s.state_ready = state end
end

Vehicle.tunnel.setConfig = function(update_interval, check_interval, update_multiplyer, respawn_radius)
  local s = vRP.EXT.Vehicle
  if not s then return end
  s.update_interval = update_interval or s.update_interval
  s.check_interval = check_interval or s.check_interval
  s.update_multiplyer = update_multiplyer or s.update_multiplyer
  s.respawn_radius = respawn_radius or s.respawn_radius
end
