-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.vehicle_state then return end

local lang = vRP.lang

local Vehicle_state = class("Vehicle_state", vRP.Extension)

-- SUBCLASS

Vehicle_state.User = class("User")

-- get owned vehicles
-- return map of model => state
--- state: 0 (out), 1 (in garage)
function Vehicle_state.User:getVehicles()
  return self.cdata.vehicles
end

-- send out vehicles to player
local function send_out_vehicles(self, user)
  -- out vehicles
  local out_vehicles = {}
  for model, state in pairs(user:getVehicles()) do
    if state == 0 then -- out
      local vstate = user:getVehicleState(model)
      if vstate.position then
        local cstate = {
          customization = vstate.customization,
          condition = vstate.condition,
          locked = vstate.locked
        }

        out_vehicles[model] = {cstate, vstate.position, vstate.rotation}
      end
    end
  end

  vRP.EXT.Vehicle.remote._setOutVehicles(user.source, out_vehicles)
end

function Vehicle_state:__construct()
  vRP.Extension.__construct(self)
	
	self.cfg = module("cfg/vehicle_state")
end

-- get vehicle model state table (may be async)
function Vehicle_state.User:getVehicleState(model)
  local state = self.vehicle_states[model]
  if not state then -- load state
    local sdata = vRP:getCData(self.cid, "vRP:vehicle_state:"..model)
    if sdata and string.len(sdata) > 0 then
      state = msgpack.unpack(sdata)
    else
      state = {}
    end

    self.vehicle_states[model] = state
  end

  return state
end

-- EVENT
Vehicle_state.event = {}

function Vehicle_state.event:characterLoad(user)
  if not user.cdata.vehicles then
    user.cdata.vehicles = {}
  end

  if not user.cdata.rent_vehicles then
    user.cdata.rent_vehicles = {}
  end

  -- remove rented vehicles
  local vehicles = user:getVehicles()
  for model in pairs(user.cdata.rent_vehicles) do
    vehicles[model] = nil
  end

  user.vehicle_states = {}

  send_out_vehicles(self, user)
end

function Vehicle_state.event:characterUnload(user)
  self.remote._setStateReady(user.source, false)
  
  -- save vehicle states
  if user.vehicle_states then
    for model, state in pairs(user.vehicle_states) do
      vRP:setCData(user.cid, "vRP:vehicle_state:"..model, msgpack.pack(state))
    end
  end

  -- despawn vehicles
  vRP.EXT.Vehicle.remote._despawnVehicles(user.source)
  vRP.EXT.Vehicle.remote._clearOutVehicles(user.source)
end

function Vehicle_state.event:save()
  for id, user in pairs(vRP.users) do
    -- save vehicle states
    for model, state in pairs(user.vehicle_states) do
      vRP:setCData(user.cid, "vRP:vehicle_state:"..model, msgpack.pack(state))
    end
  end
end

function Vehicle_state.event:playerSpawn(user, first_spawn)
  if first_spawn then
    -- config
    self.remote._setConfig(user.source, self.cfg.vehicle_update_interval, self.cfg.vehicle_check_interval, self.cfg.vehicle_respawn_radius)

    -- register models
    self.remote._registerModels(user.source, self.models)

    send_out_vehicles(self, user)
  end
end

function Vehicle_state.event:playerStateLoaded(user)
  vRP.EXT.Vehicle.remote._tryOwnVehicles(user.source)
  vRP.EXT.Vehicle.remote.trySpawnOutVehicles(user.source)

  if user.cdata.state.in_owned_vehicle then
    vRP.EXT.Vehicle.remote._putInOwnedVehicle(user.source, user.cdata.state.in_owned_vehicle)
  end

  self.remote._setStateReady(user.source, true)
end

-- TUNNEL
Vehicle_state.tunnel = {}

function Vehicle_state.tunnel:updateVehicleStates(states)
  local user = vRP.users_by_source[source]

  if user then
    for model, state in pairs(states) do
      if user.cdata.vehicles[model] then -- has model
        local vstate = user:getVehicleState(model)

        if state.customization then
          vstate.customization = state.customization
        end

        if state.condition then
          vstate.condition = state.condition
        end

        if state.position then vstate.position = state.position end
        if state.rotation then vstate.rotation = state.rotation end

        if state.locked ~= nil then vstate.locked = state.locked end
      end
    end
  end
end

vRP:registerExtension(Vehicle_state)