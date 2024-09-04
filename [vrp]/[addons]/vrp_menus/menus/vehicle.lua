-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)
local init = module("vrp_menus", "cfg/components")
if not init.vehicle then return end

local lang = vRP.lang
local Vehicle = class("Vehicle", vRP.Component)

local function menu_types(self)
  vRP.EXT.GUI:registerMenuBuilder("vehicles.type", function(menu)
    menu.title = menu.data.title
    menu.css.header_color = "rgba(200,0,0,0.75)"
		
		for model,v in pairs(self.vehicles) do
			local gtype = menu.data.gtype
			
			if gtype == v.category and v.enabled then
				menu:addOption(v.name, function(menu)
					vRP.EXT.Vehicle.remote._spawnVehicle(menu.user.source, model)
				end)
			end
		end
  end)
end

-- menu: admin
local function menu_spawn(self)
  vRP.EXT.GUI:registerMenuBuilder("vehicles.spawn", function(menu)
    menu.title = "Spawn Vehicle"
    menu.css.header_color = "rgba(200,0,0,0.75)"
    
		menu:addOption("Spawn by Model", function(menu)
			local model = menu.user:prompt("Enter Model name","")
			vRP.EXT.Vehicle.remote._spawnVehicle(menu.user.source, model)
		end)
		
		for category,enabled in pairs(self.cfg.categories) do	
			if enabled then
				menu:addOption(category, function(menu)
					menu.user:openMenu("vehicles.type", { gtype = category, title = category })
				end)
			end
		end
  end)
end

-- menu: admin
local function menu_vehicles(self)
  vRP.EXT.GUI:registerMenuBuilder("vehicles", function(menu)
    menu.title = "Vehicles"
    menu.css.header_color = "rgba(200,0,0,0.75)"
    
		menu:addOption("Spawn Vehicle", function(menu)
			menu.user:openMenu("vehicles.spawn")
		end)
		
		menu:addOption("Despawn Nearby", function(menu)
			local Vehicle = vRP.EXT.Vehicle.remote
			local model = Vehicle.getNearestOwnedVehicle(menu.user.source, 5)
			
			if not model then
				Vehicle._despawnNearestVehicle(menu.user.source, 5)
				return
			end
			
			Vehicle.despawnVehicle(menu.user.source, model)
			vRP.EXT.Base.remote._notify(menu.user.source, ""..model.." has been despawned")
		end)
		
		menu:addOption("Despawn All Nearby", function(menu)
			vRP.EXT.Vehicle.remote._despawnNearbyVehicles(menu.user.source, 10)
			vRP.EXT.Base.remote._notify(menu.user.source, "All Nearby vehicle have been despawned")
		end)
		
		menu:addOption("Fix Nearby", function(menu)
			vRP.EXT.Vehicle.remote.fixNearestVehicle(menu.user.source, 5)
			vRP.EXT.Base.remote._notify(menu.user.source, 'Vehcile is Fixed')
		end)
  end)
end

function Vehicle:__construct()
  vRP.Component.__construct(self)
	
	self.cfg = module("vrp", "cfg/vehicle")
	
	self.vehicles = {}
	
	for _, vehicle in pairs(self.cfg.vehicles) do
    self.vehicles[vehicle.model] = {
			name = vehicle.name,
			brand = vehicle.brand,
			enabled = vehicle.enabled,
			price = vehicle.price,
			category = vehicle.category,
			type = vehicle.type,
			shop = vehicle.shop
		}
	end
			
	-- menu
  menu_vehicles(self)
  menu_spawn(self)
  menu_types(self)

  -- list for all Vehicles that are useable
  vRP.EXT.GUI:registerMenuBuilder("main", function(menu)
		if menu.user:hasGroup("admin") then
			menu:addOption("Vehicles", function(menu)
				menu.user:openMenu("vehicles")
			end)
		end
  end)
end

vRP:registerComponent(Vehicle)