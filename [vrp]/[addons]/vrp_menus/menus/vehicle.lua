-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)
local init = module("vrp_menus", "cfg/components")
if not init.vehicle then return end

local lang = vRP.lang
local Vehicle = class("Vehicle", vRP.Component)

local function menu_options(self)
  vRP.EXT.GUI:registerMenuBuilder("vehicles.type.options", function(menu)
		local user = menu.user
		local model = menu.data.model		--model name - need to get hash

		menu.title = menu.data.name
		menu.css.header_color = "rgba(200,0,0,0.75)"

		menu:addOption("Spawn Vehicle", function(menu)
			vRP.EXT.Base.remote._notify(menu.user.source, 'Spawned Vehcile')
		end)
		
		menu:addOption("Repair Vehicle", function(menu)
			vRP.EXT.Base.remote._notify(menu.user.source, 'Repaired Vehcile')
		end)
		
		menu:addOption("Clean Vehicle", function(menu)
			vRP.EXT.Base.remote._notify(menu.user.source, 'Vehcile is clean')
		end)
  end)
end

local function menu_types(self)
  vRP.EXT.GUI:registerMenuBuilder("vehicles.type", function(menu)

    menu.title = menu.data.title
    menu.css.header_color = "rgba(200,0,0,0.75)"
		
		for k,v in pairs(self.vehicles) do
			local gtype = menu.data.gtype
			
			if gtype == v.category and v.enabled then
				menu:addOption(v.name, function(menu)
           menu.user:openMenu("vehicles.type.options", { model = k, name = v.name })
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
    
		for category,enabled in pairs(self.cfg.categories) do	
			if enabled then
				menu:addOption(category, function(menu)
					menu.user:openMenu("vehicles.type", { gtype = category, title = category })
				end)
			end
		end
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
  menu_types(self)
  menu_options(self)

  -- list for all Vehicles that are useable
  vRP.EXT.GUI:registerMenuBuilder("admin", function(menu)
    menu:addOption("Vehicles", function(menu)
      menu.user:openMenu("vehicles")
    end)
  end)
end

vRP:registerComponent(Vehicle)