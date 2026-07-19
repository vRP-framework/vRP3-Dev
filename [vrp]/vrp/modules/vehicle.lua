-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.vehicle then return end

-- A basic Vehicle implementation
local Vehicle = class("Vehicle", vRP.Extension)

-- SUBCLASS
Vehicle.User = class("User")

-- localize common globals for micro-optimizations
local pairs = pairs
local ipairs = ipairs
local type = type
local tostring = tostring
local math_random = math.random
local next = next
local SetTimeout = SetTimeout

-- Get owned vehicles
-- Return map of id => {state, price, model}
function Vehicle.User:getVehicles()
  return self.cdata.vehicles
end

-- Improved function
function Vehicle.User:getVehicleState(model)
  self.vehicle_states = self.vehicle_states or {}
	
  local state = self.vehicle_states[model]
  if not state then -- load state
		local sdata = vRP:getCData(self.cid, "vRP:vehicle_state:"..model)
		if sdata and #sdata > 0 then
			local ok, vs = pcall(msgpack.unpack, sdata)
			if ok and type(vs) == "table" then
				state = vs
			else
				vRP:log("warning: failed to unpack vehicle state for cid="..tostring(self.cid) .. " model="..tostring(model))
				state = {}
			end
		else
			state = {}
		end
    self.vehicle_states[model] = state
  end
  
  return state
end

-- Send out vehicles to player
local function send_out_vehicles(self, user)
  local out_vehicles = {}

  for model, state in pairs(user:getVehicles()) do
    if state == 0 then -- vehicle is "out"
      local vstate = user:getVehicleState(model)
      if vstate and vstate.position then
        out_vehicles[model] = {
          {
            customization = vstate.customization,
            condition = vstate.condition,
            locked = vstate.locked
          },
          vstate.position,
          vstate.rotation
        }
      end
    end
  end

	self.remote._setOutVehicles(user.source, out_vehicles)
end

-- menu: garage
local function menu_buy(self)
	
	local function m_buy(menu, model)
		local user = menu.user
    local uvehicles = user:getVehicles()
		local shop = self.shops and self.shops[menu.data.type]
		local veh = menu.data.vehicles and menu.data.vehicles[model]
		
		if not veh then
			return vRP.EXT.Base.remote._notify(user.source, "Invalid vehicle selected.")
		end

		if not shop or not shop.spawn or #shop.spawn == 0 then
			return vRP.EXT.Base.remote._notify(user.source, "No spawn locations configured.")
		end

		local spawn = shop.spawn[math.random(#shop.spawn)]

		if not spawn or not spawn.x or spawn.x == 0 then
			return vRP.EXT.Base.remote._notify(user.source, "Invalid spawn point.")
		end

		if not user:tryPayment(veh.price) then
			return vRP.EXT.Base.remote._notify(user.source, "Not enough money.")
		end
		
			uvehicles[model] = 0
			vRP:setCData(user.cid, "vRP:vehicle_state:"..model, {})

			vRP.EXT.Base.remote.teleport(user.source, spawn.x, spawn.y, spawn.z, spawn.w or 0.0)

			self.remote._spawnVehicle(user.source, model, {}) -- spawn vehicle with empty state
		self.remote._setOutVehicles(user.source, { [model] = {} })

		vRP.EXT.Base.remote._notify(user.source, "Purchased for $" .. veh.price)
		user:actualizeMenu()
		user:closeMenu(menu)
	end


  vRP.EXT.GUI:registerMenuBuilder(self, "buy", function(menu)
    menu.title = menu.data.type
    menu.css.header_color = "rgba(255,125,0,0.75)"
		local uvehicles = menu.user:getVehicles()
		
		for model,veh in pairs(menu.data.vehicles) do
				if not uvehicles[model] then
					local name = veh.name or self.model_names[model] or "unknown"
					local price = veh.price or 0
					menu:addOption(name, m_buy, vRP.lang.garage.buy.info({price, ""}), model)
				end
		end
  end)
end

local function menu_sell(self)
	
	local function m_sell(menu, model)
		local user = menu.user
    local uvehicles = user:getVehicles()
		local veh = menu.data.vehicles[model]
		local price = math.ceil(veh.price*(self.sell_factor or 0))

		if not uvehicles[model] then
			return vRP.EXT.Base.remote._notify(user.source, "You do not own this vehicle.") 
		end
		
	user:giveWallet(price)    
	uvehicles[model] = nil
    
	vRP:delCData(user.cid, "vRP:vehicle_state:"..model)
    
	-- despawn vehicles
	self.remote._despawnVehicle(user.source, model)
    
	vRP.EXT.Base.remote._notify(user.source, "Vehicle sold for $" .. price)
		user:actualizeMenu()
  end


  vRP.EXT.GUI:registerMenuBuilder(self, "sell", function(menu)
    menu.title = "Sell " .. tostring(menu.data.type)
    menu.css.header_color = "rgba(255,125,0,0.75)"
		local user = menu.user
    local uvehicles = user:getVehicles()
		
		-- for each existing vehicle in the garage group and owned (and not rented)
    for model,veh in pairs(menu.data.vehicles) do
      if uvehicles[model] and not user.cdata.rent_vehicles[model] then
				local price = math.ceil((veh.price or 0)*(self.sell_factor or 0))
				local name = veh.name or self.model_names[model] or "unknown"
				menu:addOption(name, m_sell, vRP.lang.garage.buy.info({price, ""}), model)
      end
    end
  end)
end

local function menu_owned(self)
	local function m_get(menu, model)
		local user = menu.user
		local vehicles = user:getVehicles()

		if vehicles[model] == nil then
			return vRP.EXT.Base.remote._notify(user.source, "You don't own this vehicle.")
		end

		if vehicles[model] == 1 then -- in garage
			local vstate = user:getVehicleState(model) or {}
			local state = {
				customization = vstate.customization or {},
				condition = vstate.condition or {},
				locked = vstate.locked or false
			}

			vehicles[model] = 0 -- mark as out
			self.remote._spawnVehicle(user.source, model, state)
			self.remote._setOutVehicles(user.source, { [model] = {} })
			user:closeMenu(menu)

		elseif vehicles[model] == 0 then -- already out
			vRP.EXT.Base.remote._notify(user.source, vRP.lang.garage.owned.already_out())

			if user:request(vRP.lang.garage.owned.force_out.request({self.cfg.force_out_fee}), 15) then
					if user:tryPayment(self.force_out_fee) then
					local vstate = user:getVehicleState(model) or {}
					local state = {
						customization = vstate.customization or {},
						condition = vstate.condition or {},
						locked = vstate.locked or false
					}
					
					vehicles[model] = 0 -- mark as out
					self.remote._spawnVehicle(user.source, model, state)
					self.remote._setOutVehicles(user.source, {[model] = { state, vstate.position, vstate.rotation }})
					user:closeMenu(menu)
				else
					vRP.EXT.Base.remote._notify(user.source, vRP.lang.money.not_enough())
				end
			end
		end
	end

  vRP.EXT.GUI:registerMenuBuilder(self, "owned", function(menu)
    menu.title = "Owned " .. tostring(menu.data.type)
    menu.css.header_color = "rgba(255,125,0,0.75)"
		local user = menu.user

    for model in pairs(user:getVehicles()) do
      local veh = menu.data.vehicles[model]
      if veh then
	        local name = veh.name or self.model_names[model] or "unknown"
	        menu:addOption(name, m_get, "", model)
      end
    end
  end)
end

local function menu_garage(self)	
	local function m_store(menu, shopName)
    local user = menu.user
    local model = self.remote.getNearestOwnedVehicle(user.source, 15)
	
		if not model then 
			return vRP.EXT.Base.remote._notify(user.source, vRP.lang.garage.store.too_far())
		end
		
		if not menu.data or not menu.data.vehicles or not menu.data.vehicles[model] then 
			return vRP.EXT.Base.remote._notify(user.source, vRP.lang.garage.store.wrong_garage())
		end
		
			self.remote._removeOutVehicles(user.source, {[model] = true})

		if self.remote.despawnVehicle(user.source, model) then
			local vehicles = user:getVehicles()
			local state = self.remote.getVehicleState(user.source) or {}
			
			if vehicles[model] then 
				vRP:setCData(user.cid, "vRP:vehicle_state:"..model, state)
				vehicles[model] = 1 -- mark as in garage
			end

			vRP.EXT.Base.remote._notify(user.source, vRP.lang.garage.store.stored())
		end
  end


  vRP.EXT.GUI:registerMenuBuilder(self, "garage", function(menu)
    menu.title = "Garage " .. tostring(menu.data.type)
    menu.css.header_color = "rgba(255,125,0,0.75)"
		local uvehicles = menu.user:getVehicles()
		
		-- owned vehicles
		menu:addOption(vRP.lang.garage.owned.title(), function(menu)
			menu.user:openMenu("owned", menu.data)
		end)
		
		-- buy vehicle
		menu:addOption(vRP.lang.garage.buy.title(), function(menu)	
			menu.user:openMenu("buy", menu.data)
		end)
		
		-- store owned vehicles
		menu:addOption(vRP.lang.garage.store.title(), m_store, vRP.lang.garage.store.description(), menu.data.type)
  end)
end

function Vehicle:__construct()
  vRP.Extension.__construct(self)
	self.cfg = module("vrp", "cfg/vehicles")

	-- placeholders; heavy init happens lazily in :init()
	self._inited = false
	self.models = {}
	self.model_names = {}
	self.shop_groups = nil
	self.shops = nil
	self.sell_points = nil
	self.vehicle_update_interval = nil
	self.vehicle_check_interval = nil
	self.vehicle_respawn_radius = nil
	self.force_out_fee = nil
	self.sell_factor = nil
end

function Vehicle:init()
	if self._inited then return end
	self._inited = true

	menu_owned(self)
	menu_buy(self)
	menu_sell(self)
	menu_garage(self)

	-- register models and precompute shop groups to avoid nested loops on spawn
	self.shop_groups = {} -- gtype -> { model -> {name, price, description} }
	for gtype, vehicles in pairs(self.cfg.vehicles) do
		for model, veh in pairs(vehicles) do
			self.models[model] = true
			if type(veh.shop) == "table" then
				for _, shopName in ipairs(veh.shop) do
					local group = self.shop_groups[shopName]
					if not group then group = {} self.shop_groups[shopName] = group end
					-- store name separately to avoid duplicating strings in shop_groups
					self.model_names[model] = veh.name
					group[model] = { price = veh.price }
				end
			end
		end
	end

	-- extract small cfg pieces and free full cfg to reduce memory
	self.shops = self.cfg.shops
	self.sell_points = self.cfg.sell_points
	self.vehicle_update_interval = self.cfg.vehicle_update_interval
	-- default multiplyer (ms) for client waits
	self.vehicle_update_multiplyer = self.cfg.vehicle_update_multiplyer or 1000
	self.vehicle_check_interval = self.cfg.vehicle_check_interval
	self.vehicle_respawn_radius = self.cfg.vehicle_respawn_radius
	self.force_out_fee = self.cfg.force_out_fee
	self.sell_factor = self.cfg.sell_factor
	self.cfg = nil

end

-- EVENT HANDLERS --
Vehicle.event = {}

function Vehicle.event:playerSpawn(user, first_spawn)
  -- ensure module initialized lazily
  if not self._inited then pcall(function() self:init() end) end
  if first_spawn then
		-- config
		local remote = self.remote
		remote._setConfig(user.source, self.vehicle_update_interval, self.vehicle_check_interval, self.vehicle_update_multiplyer, self.vehicle_respawn_radius)

		-- register models
		-- register models (only if non-empty)
		if next(self.models) then
			remote._registerModels(user.source, self.models)
		end

		send_out_vehicles(self, user)

		-- bind shops
		for k,v in pairs(self.shops or {}) do
			local x,y,z,radius,height = table.unpack(v.pos)
			local gtype,gcfg,title = k,v._config, v.title
			local group = self.shop_groups[gtype] or {}

			-- default values
			if radius == nil then radius = 1.0 end
			if height == nil then height = 1.0 end

			local menu
			local function enter(user)
				local menuType = v.garage and "garage" or "buy"
				menu = user:openMenu(menuType, {type = gtype, vehicles = group})
			end

			local function leave(user)
				if menu then user:closeMenu(menu) end
			end

			local ment = clone(gcfg.map_entity)
			ment[2].title = title
			ment[2].pos = {x,y,z-1}
			vRP.EXT.Map.remote._addEntity(user.source,ment[1], ment[2])

			user:setArea("vRP:vehicleshop:"..gtype,x,y,z,radius,height,enter,leave)
		end
		
		for k,v in pairs(self.sell_points or {}) do
			local x,y,z,radius,height = table.unpack(v.pos)
			local gtype,gcfg,title = k,v._config, v.title
			local group = self.shop_groups[gtype] or {}
			
			-- default values
			if radius == nil then radius = 1.0 end
			if height == nil then height = 1.0 end
			
			local menu
			local function enter(user)
				menu = user:openMenu("sell", {type = gtype, vehicles = group})
			end

			-- leave
			local function leave(user)
				if menu then user:closeMenu(menu) end
			end

			local ment = clone(gcfg.map_entity)
			ment[2].title = title
			ment[2].pos = {x,y,z-1}
			vRP.EXT.Map.remote._addEntity(user.source,ment[1], ment[2])
			
			user:setArea("vRP:sellvehicle::"..gtype,x,y,z,radius,height,enter,leave)
		end
  end
end


function Vehicle.event:characterLoad(user)
	if not self._inited then pcall(function() self:init() end) end
  user.cdata.vehicles = user.cdata.vehicles or {}
	user.cdata.rent_vehicles = user.cdata.rent_vehicles or {}

  -- remove rented vehicles
  local vehicles = user:getVehicles()
  for model in pairs(user.cdata.rent_vehicles) do
    vehicles[model] = nil
  end

  user.vehicle_states = {}

  send_out_vehicles(self, user)
end

function Vehicle.event:characterUnload(user)
	self.remote._setStateReady(user.source, false)

    -- save vehicle states
	for model, state in pairs(user.vehicle_states) do
		vRP:setCData(user.cid, "vRP:vehicle_state:"..model, state)
	end

		self.remote._despawnVehicles(user.source)
		self.remote._clearOutVehicles(user.source)
end


function Vehicle.event:save()
	for _, user in pairs(vRP.users_by_source or {}) do
		for model, state in pairs(user.vehicle_states or {}) do
			vRP:setCData(user.cid, "vRP:vehicle_state:"..model, state)
		end
	end
end

function Vehicle.event:playerStateLoaded(user)
	if not self._inited then pcall(function() self:init() end) end

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

-- safe maintenance: clean small vehicle caches and run full Lua GC
function Vehicle:performGC()
	local before = collectgarbage("count")

	-- cleanup invalid owned vehicles
	pcall(self.cleanupVehicles, self)

	-- drop empty vehicle state entries (safe, non-destructive)
	for _, user in pairs(vRP.users_by_source) do
		if user and user.vehicle_states then
			for m, s in pairs(user.vehicle_states) do
				if type(s) == "table" and next(s) == nil then
					user.vehicle_states[m] = nil
				end
			end
		end
	end

	-- attempt light cleanup (GC handled centrally by gc_manager)
	local after = collectgarbage("count")
	pcall(vRP.log, vRP, "vehicle_gc: before_kb="..tostring(before).." after_kb="..tostring(after).." freed_kb="..tostring(before-after))
end