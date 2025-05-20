-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.vehicle then return end

local Vehicle = class("Vehicle", vRP.Extension)

-- METHODS

function Vehicle:__construct()
  vRP.Extension.__construct(self)

  -- init decorators
  DecorRegister("vRP.owner", 3)

  self.vehicles = {} -- map of vehicle model => veh id (owned vehicles)
  self.hash_models = {} -- map of hash => model

  self.update_interval = 30 -- seconds
  self.check_interval = 15 -- seconds
  self.respawn_radius = 200

  self.state_ready = false -- flag, if true will try to re-own/spawn periodically out vehicles

  self.out_vehicles = {} -- map of vehicle model => {cstate, position, rotation}, unloaded out vehicles to spawn

  -- task: save vehicle states
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(self.update_interval*1000)

      if self.state_ready then
        local states = {}

        for model, veh in pairs(self.vehicles) do
          if IsEntityAVehicle(veh) then
            local state = self:getVehicleState(model)
            state.position = {table.unpack(GetEntityCoords(veh, true))}
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
      Citizen.Wait(self.check_interval*1000)

      if self.state_ready then
        self:cleanupVehicles()
        self:tryOwnVehicles() -- get back network lost vehicles
        self:trySpawnOutVehicles()
      end
    end
  end)
end

local custom = {}

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

  -- Load vehicle model
  local mhash = GetHashKey(model)
  RequestModel(mhash)
  local i = 0
  while not HasModelLoaded(mhash) and i < 10000 do
    Citizen.Wait(10)
    i = i + 1
  end

  if HasModelLoaded(mhash) then
    local ped = GetPlayerPed(-1)
    local x, y, z

    if position and position.x and position.y and position.z then
      x, y, z = position.x, position.y, position.z
    else
      x, y, z = table.unpack(GetEntityCoords(ped))
    end

    local nveh = CreateVehicle(mhash, x, y, z + 0.5, 0.0, true, false)

    -- Set rotation and heading if provided
    if rotation then
      SetEntityQuaternion(nveh, table.unpack(rotation))
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

    -- Set vehicle plate and ownership
    local plateText = custom.plate_txt or ("LS " .. vRP.EXT.Identity.registration)
    SetVehicleNumberPlateText(nveh, plateText)
    SetEntityAsMissionEntity(nveh, true, true)
    SetVehicleHasBeenOwnedByPlayer(nveh, true)
    DecorSetInt(nveh, "vRP.owner", vRP.EXT.Base.cid)
    self.vehicles[model] = nveh

    -- Set vehicle state if provided
    if state then
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
		-- Before despawning, save its state
    self:saveVehicleState()
		
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
  if not veh then
    veh = GetVehiclePedIsIn(GetPlayerPed(-1), false)
  end
  SetVehicleModKit(veh, 0)

  -- Apply each customization if it's provided
  if custom.colours then SetVehicleColours(veh, table.unpack(custom.colours)) end
  if custom.extra_colours then SetVehicleExtraColours(veh, table.unpack(custom.extra_colours)) end
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
  if custom.neon_colour then SetVehicleNeonLightsColour(veh, table.unpack(custom.neon_colour)) end
  if custom.tyre_smoke_color then SetVehicleTyreSmokeColor(veh, table.unpack(custom.tyre_smoke_color)) end

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
  -- apply state
  if state.customization then
    self:setVehicleCustomization(veh, state.customization)
  end
  
  if state.condition then
    if state.condition.health then
      SetEntityHealth(veh, state.condition.health)
    end

    if state.condition.engine_health then
      SetVehicleEngineHealth(veh, state.condition.engine_health)
    end

    if state.condition.petrol_tank_health then
      SetVehiclePetrolTankHealth(veh, state.condition.petrol_tank_health)
    end

    if state.condition.dirt_level then
      SetVehicleDirtLevel(veh, state.condition.dirt_level)
    end

    if state.condition.windows then
      for i, window_state in pairs(state.condition.windows) do
        if not window_state then
          SmashVehicleWindow(veh, i)
        end
      end
    end

    if state.condition.tyres then
      for i, tyre_state in pairs(state.condition.tyres) do
        if tyre_state < 2 then
          SetVehicleTyreBurst(veh, i, (tyre_state == 1), 1000.01)
        end
      end
    end

    if state.condition.doors then
      for i, door_state in pairs(state.condition.doors) do
        if not door_state then
          SetVehicleDoorBroken(veh, i, true)
        end
      end
    end
  end

  if state.locked ~= nil then 
    if state.locked then -- lock
      SetVehicleDoorsLocked(veh,2)
      SetVehicleDoorsLockedForAllPlayers(veh, true)
    else -- unlock
      SetVehicleDoorsLockedForAllPlayers(veh, false)
      SetVehicleDoorsLocked(veh,1)
      SetVehicleDoorsLockedForPlayer(veh, PlayerId(), false)
    end
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

Vehicle.tunnel.spawnVehicle = Vehicle.spawnVehicle
Vehicle.tunnel.despawnVehicle = Vehicle.despawnVehicle
Vehicle.tunnel.despawnVehicles = Vehicle.despawnVehicles

Vehicle.tunnel.tryOwnVehicles = Vehicle.tryOwnVehicles
Vehicle.tunnel.trySpawnOutVehicles = Vehicle.trySpawnOutVehicles
Vehicle.tunnel.cleanupVehicles = Vehicle.cleanupVehicles
Vehicle.tunnel.getInOwnedVehicleModel = Vehicle.getInOwnedVehicleModel

Vehicle.tunnel.setVehicleCustomization = Vehicle.setVehicleCustomization


vRP:registerExtension(Vehicle)