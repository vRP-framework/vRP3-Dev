-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.vehicle_state then return end

local lang = vRP.lang

local VehicleState = class("VehicleState", vRP.Extension)

function VehicleState:__construct()
  vRP.Extension.__construct(self)
	
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
				local vehicles = vRP.EXT.Vehicle:getOwnedVehicles()

        for model, veh in pairs(vehicles) do
          if IsEntityAVehicle(veh) then
            local state = self:getVehicleState(veh)
            state.position = {table.unpack(GetEntityCoords(veh, true))}
            state.rotation = {GetEntityQuaternion(veh)}

            states[model] = state

            if self.out_vehicles[model] then -- update out vehicle state data
              self.out_vehicles[model] = {state, state.position, state.rotation}
            end
          end
        end
				
        self.remote._updateVehicleStates(states)
        vRP.EXT.PlayerState.remote._update({ in_owned_vehicle = vRP.EXT.Vehicle:getInOwnedVehicleModel() or false})
      end
    end
  end)

  -- task: vehicles check
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(self.check_interval*1000)

      if self.state_ready then
        vRP.EXT.Vehicle:cleanupVehicles()
        vRP.EXT.Vehicle:tryOwnVehicles() -- get back network lost vehicles
        vRP.EXT.Vehicle:trySpawnOutVehicles()
      end
    end
  end)
end

-- VEHICLE STATE
function VehicleState:getVehicleCustomization(veh)
  local custom = {
    colours = {GetVehicleColours(veh)},
    extra_colours = {GetVehicleExtraColours(veh)},
    plate_index = GetVehicleNumberPlateTextIndex(veh),
    plate_txt = GetVehicleNumberPlateText(veh),
    wheel_type = GetVehicleWheelType(veh),
    window_tint = GetVehicleWindowTint(veh),
    livery = GetVehicleLivery(veh),
    neons = {},
    neon_colour = {GetVehicleNeonLightsColour(veh)},
    tyre_smoke_color = {GetVehicleTyreSmokeColor(veh)},
    mods = {},
    turbo_enabled = IsToggleModOn(veh, 18),
    smoke_enabled = IsToggleModOn(veh, 20),
    xenon_enabled = IsToggleModOn(veh, 22)
  }

  for i = 0, 3 do
    custom.neons[i] = IsVehicleNeonLightEnabled(veh, i)
  end

  for i = 0, 49 do
    custom.mods[i] = GetVehicleMod(veh, i)
  end

  return custom
end

-- partial update per property
function VehicleState:setVehicleCustomization(veh, custom)
  veh = veh or GetVehiclePedIsIn(GetPlayerPed(-1), false)
  SetVehicleModKit(veh, 0)

  if custom.colours then SetVehicleColours(veh, table.unpack(custom.colours)) end
  if custom.extra_colours then SetVehicleExtraColours(veh, table.unpack(custom.extra_colours)) end
  if custom.plate_index then SetVehicleNumberPlateTextIndex(veh, custom.plate_index) end
  if custom.plate_txt then SetVehicleNumberPlateText(veh, custom.plate_txt) end
  if custom.wheel_type then SetVehicleWheelType(veh, custom.wheel_type) end
  if custom.window_tint then SetVehicleWindowTint(veh, custom.window_tint) end
  if custom.livery then SetVehicleLivery(veh, custom.livery) end
  
  if custom.neons then
    for i = 0, 3 do
      SetVehicleNeonLightEnabled(veh, i, custom.neons[i])
    end
  end
  
  if custom.neon_colour then
    SetVehicleNeonLightsColour(veh, table.unpack(custom.neon_colour))
  end
  
  if custom.tyre_smoke_color then
    SetVehicleTyreSmokeColor(veh, table.unpack(custom.tyre_smoke_color))
  end
  
  if custom.mods then
    for i, mod in pairs(custom.mods) do
      SetVehicleMod(veh, i, mod, false)
    end
  end

  if custom.turbo_enabled ~= nil then ToggleVehicleMod(veh, 18, custom.turbo_enabled) end
  if custom.smoke_enabled ~= nil then ToggleVehicleMod(veh, 20, custom.smoke_enabled) end
  if custom.xenon_enabled ~= nil then ToggleVehicleMod(veh, 22, custom.xenon_enabled) end

  vRP.EXT.Vehicle.remote._updateVehicleStates(custom)
end

function VehicleState:getVehicleState(veh)
  local state = {
    customization = self:getVehicleCustomization(veh),
    condition = {
      health = GetEntityHealth(veh),
      engine_health = GetVehicleEngineHealth(veh),
      petrol_tank_health = GetVehiclePetrolTankHealth(veh),
      dirt_level = GetVehicleDirtLevel(veh),
      windows = {},
      tyres = {},
      doors = {}
    },
    locked = (GetVehicleDoorLockStatus(veh) >= 2)
  }

  for i = 0, 7 do 
    state.condition.windows[i] = IsVehicleWindowIntact(veh, i)
    local tyre_state = 2 -- 2: fine, 1: burst, 0: completely burst
    if IsVehicleTyreBurst(veh, i, true) then
      tyre_state = 0
    elseif IsVehicleTyreBurst(veh, i, false) then
      tyre_state = 1
    end
    state.condition.tyres[i] = tyre_state
  end

  for i = 0, 5 do
    state.condition.doors[i] = not IsVehicleDoorDamaged(veh, i)
  end

  return state
end

-- partial update per property
function VehicleState:setVehicleState(veh, state)
  -- apply state
  if state.customization then
    self:setVehicleCustomization(veh, state.customization)
  end
  
  local condition = state.condition
  if condition then
    if condition.health then SetEntityHealth(veh, condition.health) end
    if condition.engine_health then SetVehicleEngineHealth(veh, condition.engine_health) end
    if condition.petrol_tank_health then SetVehiclePetrolTankHealth(veh, condition.petrol_tank_health) end
    if condition.dirt_level then SetVehicleDirtLevel(veh, condition.dirt_level) end

    for i, window_state in pairs(condition.windows or {}) do
      if not window_state then SmashVehicleWindow(veh, i) end
    end

    for i, tyre_state in pairs(condition.tyres or {}) do
      if tyre_state < 2 then
        SetVehicleTyreBurst(veh, i, (tyre_state == 1), 1000.01)
      end
    end

    for i, door_state in pairs(condition.doors or {}) do
      if not door_state then SetVehicleDoorBroken(veh, i, true) end
    end
  end

  if state.locked ~= nil then 
    if state.locked then -- lock
      SetVehicleDoorsLocked(veh, 2)
      SetVehicleDoorsLockedForAllPlayers(veh, true)
    else -- unlock
      SetVehicleDoorsLockedForAllPlayers(veh, false)
      SetVehicleDoorsLocked(veh, 1)
      SetVehicleDoorsLockedForPlayer(veh, PlayerId(), false)
    end
  end
end

-- TUNNEL
VehicleState.tunnel = {}

function VehicleState.tunnel:setConfig(update_interval, check_interval, respawn_radius)
  self.update_interval = update_interval
  self.check_interval = check_interval
  self.respawn_radius = respawn_radius
end

function VehicleState.tunnel:setStateReady(state)
  self.state_ready = state
end

VehicleState.tunnel.setVehicleCustomization = VehicleState.setVehicleCustomization

vRP:registerExtension(VehicleState)