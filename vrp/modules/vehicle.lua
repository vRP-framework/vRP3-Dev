-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.vehicle then return end

-- A basic Vehicle implementation
local Vehicle = class("Vehicle", vRP.Extension)

-- SUBCLASS
Vehicle.User = class("User")

-- Get owned vehicles
-- Return map of id => {state, price, model}
function Vehicle.User:getVehicles()
  return self.cdata.vehicles
end

-- Simplified send_out_vehicles function with better early returns and clearer structure
local function send_out_vehicles(self, user)
  local out_vehicles = {}

  -- Get all vehicles from the user
  for model, state in pairs(user:getVehicles()) do
    if state == 0 then -- Only 'out' vehicles
      local vstate = user:getVehicleState(model)
      if vstate.position then
        -- Build vehicle state and position information
        out_vehicles[model] = {
          customization = vstate.customization,
          condition = vstate.condition,
          locked = vstate.locked,
          position = vstate.position,
          rotation = vstate.rotation
        }
      end
    end
  end

  -- Send out the vehicles via remote
  self.remote._setOutVehicles(user.source, out_vehicles)
end

-- detect which vehicle shop area the user is in
function Vehicle:getUserVehicleShop(user)
  local shops = self.cfg.vehicleshops
  for shop_key, shop_data in pairs(shops) do
    local area_id = "vRP:vehicleshop:" .. shop_key
    if user:inArea(area_id) then
      return shop_key, shop_data.shop_name or shop_key
    end
  end
  return nil, "Unknown Shop"
end

function Vehicle:getVehicleByModel(model)
  for _, veh in ipairs(self.cfg.vehicles) do
    if veh.model == model then return veh end
  end
  return nil
end

-- Improved function
function Vehicle.User:getVehicleState(model)
  if not self.vehicle_states then
    self.vehicle_states = {} 
  end
  local state = self.vehicle_states[model]
  if not state then 
    local sdata = vRP:getCData(self.cid, "vRP:vehicle_state:"..model)
    if sdata and #sdata > 0 then
      state = msgpack.unpack(sdata)
    else
      state = {}
    end
    self.vehicle_states[model] = state
  end
  
  return state
end


-- Improved vehicle spawning and buying
local function menu_garage_buy(self)
  local function m_buy(menu, model)
    local user = menu.user
    local uvehicles = user:getVehicles()
    local veh = menu.data.vehicles[model]

    if not veh then
      return vRP.EXT.Base.remote._notify(user.source, "Vehicle not found.")
    end

    
    if not user:tryPayment(veh.price) then
      return vRP.EXT.Base.remote._notify(user.source, "Not enough money")
    end

    
    local shop_key = menu.data.shop_key
    local shop_cfg = self.cfg.vehicleshops[shop_key]
    if not shop_cfg or not shop_cfg.purchaseSpawn or #shop_cfg.purchaseSpawn == 0 then
      return vRP.EXT.Base.remote._notify(user.source, "Vehicle shop configuration error.")
    end

    
    local spawn = shop_cfg.purchaseSpawn[math.random(#shop_cfg.purchaseSpawn)]
    if not spawn or spawn.x == 0 then
      return vRP.EXT.Base.remote._notify(user.source, "No valid spawn point configured.")
    end

    
    vRP.EXT.Base.remote.teleport(user.source, spawn.x, spawn.y, spawn.z, spawn.w)

    local vstate = user:getVehicleState(model)
    local state = {
      customization = vstate.customization,
      condition = vstate.condition,
      locked = vstate.locked
    }

    
    uvehicles[model] = 0
    self.remote._spawnVehicle(user.source, model, state)
    self.remote._setOutVehicles(user.source, { [model] = {} })
    
    vRP.EXT.Base.remote._notify(user.source, "Purchased for $" .. veh.price)
    user:actualizeMenu()
    user:closeMenu(menu)
  end

  
  vRP.EXT.GUI:registerMenuBuilder("garage.buy", function(menu)
    local user = menu.user
    local uvehicles = user:getVehicles()
    local shop_key, shop_name = self:getUserVehicleShop(user)
    local shop_vehicles = {}

    
    menu.title = shop_name or "Vehicle Shop"
    menu.css.header_color = "rgba(255,125,0,0.75)"
    menu.data.shop_key = shop_key 

    
    if shop_key then
      for _, veh in ipairs(self.cfg.vehicles) do
        if veh.shop == shop_key or (type(veh.shop) == "table" and table.contains(veh.shop, shop_key)) then
          shop_vehicles[veh.model] = {
            name = veh.name,
            price = veh.price,
            category = veh.category,
            vtype = veh.type
          }
        end
      end
    end

    menu.data.vehicles = shop_vehicles

    
    for model, veh in pairs(shop_vehicles) do
      if not uvehicles[model] then
        menu:addOption(veh.name, m_buy, string.format("Price: $%d\n<br>Category: %s\n<br>Type: %s", veh.price, veh.category, veh.vtype), model)
      end
    end
  end)
end 

-- Helper function to check if a value exists in a table
function table.contains(tbl, val)
  for _, v in pairs(tbl) do
    if v == val then return true end
  end
  return false
end

local function menu_garage_sell(self)
  local function m_sell(menu, model)
    local user = menu.user
    local uvehicles = user:getVehicles()
    local veh = self:getVehicleByModel(model)

    if veh and uvehicles[model] then
      local zone_type = menu.data.zone_type
      local sell_cfg = self.cfg.sellvehicle[zone_type]
      
      if sell_cfg then
        local price = math.floor((veh.price or 0) * (sell_cfg.sellPrice / 100))
        uvehicles[model] = nil
        user:addWallet(price)
        vRP.EXT.Base.remote._notify(user.source, "Vehicle sold for $" .. price)
        user:actualizeMenu()
      else
        vRP.EXT.Base.remote._notify(user.source, "Invalid sell zone.")
      end
    else
      vRP.EXT.Base.remote._notify(user.source, "You do not own this vehicle.")
    end
  end

  vRP.EXT.GUI:registerMenuBuilder("garage.sell", function(menu)
    local user = menu.user
    local uvehicles = user:getVehicles()
    local zone_type = menu.data.zone_type or "cars"
    local sell_cfg = self.cfg.sellvehicle[zone_type]

    if not sell_cfg then return end -- safety check

    menu.title = sell_cfg.name or "Sell Vehicle"
    menu.css.header_color = "rgba(200, 30, 30, 0.75)"
    menu.data.zone_type = zone_type

    for model, data in pairs(uvehicles) do
      local veh = self:getVehicleByModel(model)

      if veh and veh.type == sell_cfg.type then
        local price = math.floor((veh.price or 0) * (sell_cfg.sellPrice / 100))
        menu:addOption(veh.name, m_sell, string.format("Model: %s\n<br>Original Price: $%d\n<br>Sell Price: $%d", model, veh.price or 0, price), model)

      end
    end
  end)
end


function Vehicle:__construct()
  vRP.Extension.__construct(self)
  self.cfg = module("cfg/vehicles")

  self.models = {}
  menu_garage_buy(self)
  menu_garage_sell(self)
end

-- EVENT HANDLERS --
Vehicle.event = {}

function Vehicle.event:playerSpawn(user, first_spawn)
  if first_spawn then
    self.remote._setConfig(user.source,
      self.cfg.vehicle_update_interval,
      self.cfg.vehicle_check_interval,
      self.cfg.vehicle_respawn_radius
    )
    self.remote._registerModels(user.source, self.models)

    -- setup each shop’s blip + area
    for shop_key, shop_data in pairs(self.cfg.vehicleshops) do
      local p = shop_data.showroom_location
      if p then
        local enterArea = function(u)
          user:openMenu("garage.buy")
        end
        local leaveArea = function(u)
          user:closeMenu("Vehicle Shop")
        end

        local blip_id = (shop_data.blip and shop_data.blip.id) or 326
        local blip_color = (shop_data.blip and shop_data.blip.color) or 69
        local marker_id = (shop_data.marker and shop_data.marker.id) or 1

        local poi = {
          "PoI",
          {
            blip_id    = blip_id,
            blip_color = blip_color,
            title = shop_data.shop_name or shop_key,
            marker_id  = marker_id,
            pos        = { p.x, p.y, p.z - 1 }
          }
        }

        vRP.EXT.Map.remote._addEntity(user.source, poi[1], poi[2])
        user:setArea(
          "vRP:vehicleshop:"..shop_key,
          p.x, p.y, p.z,
          1.5, 2.0,
          enterArea, leaveArea
        )
      end
    end
    -- setup each sell vehicle zone based on cfg
    for zone_type, zone in pairs(self.cfg.sellvehicle) do
      for i, pos in ipairs(zone.coords) do
        local area_id = "vRP:sellvehicle:" .. zone_type .. ":" .. i

        local enterArea = function(u)
          user:openMenu("garage.sell", { zone_type = zone_type })
        end
        local leaveArea = function(u)
          user:closeMenu("Sell Vehicle")
        end

        local poi = {
          "PoI",
          {
            blip_id = zone.blip.id,
            blip_color = zone.blip.color,
            title = zone.name,
            marker_id = zone.marker.id,
            pos = { pos.x, pos.y, pos.z - 1 },
          }
        }

        vRP.EXT.Map.remote._addEntity(user.source, poi[1], poi[2])
        user:setArea(area_id, pos.x, pos.y, pos.z, 1.5, 2.0, enterArea, leaveArea)
      end
    end
  end
end


function Vehicle.event:characterLoad(user)
  if not user.cdata.vehicles then
    user.cdata.vehicles = {}
  end

  user.vehicle_states = {}

  send_out_vehicles(self, user)
end

function Vehicle.event:characterUnload(user)
  self.remote._setStateReady(user.source, false)

  -- save vehicle states
  for model, state in pairs(user.vehicle_states) do
    vRP:setCData(user.cid, "vRP:vehicle_state:"..model, msgpack.pack(state))
  end

  -- despawn vehicles
  self.remote._despawnVehicles(user.source)
  self.remote._clearOutVehicles(user.source)
end


function Vehicle.event:save()
  for _, user in pairs(vRP.users) do
    for model, state in pairs(user.vehicle_states) do
      vRP:setCData(user.cid, "vRP:vehicle_state:"..model, msgpack.pack(state))
    end
  end
end

function Vehicle.event:playerStateLoaded(user)
  self.remote._tryOwnVehicles(user.source)
  self.remote.trySpawnOutVehicles(user.source)
  if user.cdata.state.in_owned_vehicle then
    self.remote._putInOwnedVehicle(user.source, user.cdata.state.in_owned_vehicle)
  end
  self.remote._setStateReady(user.source, true)
end

-- TUNNEL
Vehicle.tunnel = {}

function Vehicle.tunnel:updateVehicleStates(states)
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

vRP:registerExtension(Vehicle)
