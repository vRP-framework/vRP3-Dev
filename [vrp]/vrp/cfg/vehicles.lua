local cfg = {}

cfg.sell_factor = 0.75 -- sell for 75% of the original price

cfg.force_out_fee = 1000 -- amount of money (fee) to force re-spawn an already out vehicle

-- match player_state timings
cfg.vehicle_update_interval = 30 -- seconds
cfg.vehicle_check_interval = 30 -- seconds, re-own/respawn task
-- multiplier (ms) applied to update/check intervals on clients (matches player_state)
cfg.vehicle_update_multiplyer = 10000 -- milliseconds

--[[
	* Adding a New Dealership Location
	**
	*** Step 1: Add a new entry in the location table
	*** Example:
	*** ["mydealership"] = {
	***     _config = {
	***         map_entity = {"PoI", {blip_id = 326, blip_color = 69, marker_id = 1, scale = {1.5,1.5,1.0}, color = {255,215,0,100}}}
	***     },
	***     title = "My Custom Dealership",
	***     garage = false, -- set to true if this shop includes garage functionality
	***     pos = vec3(x, y, z), -- marker position
	***     spawn = {
	***         vec4(x1, y1, z1, h1), -- vehicle spawn locations
	***         vec4(x2, y2, z2, h2)
	***     }
	*** }
--]]

cfg.shops = {
	["pdm"] = {
		_config = {map_entity = {"PoI", {blip_id = 326, blip_color = 69, marker_id = 1, scale = {1.5,1.5,1.0}, color = {255,215,0,100}}}},
		title = "Luxury Car Dealership",
		garage = false,
		pos = vec3(-54.94, -1111.50, 26.44),
		spawn = { -- vehicle Spawn Location
			vec4(-61.744976043701,-1117.8952636719,26.432458877563, 10),
			vec4(-56.407440185547,-1116.4392089844,26.434999465942, 10)
		},
	},
	
	["aircraft"] = {
		_config = {map_entity = {"PoI", {blip_id = 90, blip_color = 38, marker_id = 1, scale = {2.0,2.0,1.0}, color = {0,191,255,120}}}},
		title = "LSIA Hangar",
		garage = true,
		pos = vec3(-965.33026123047,-3004.2521972656,13.9426612854),
		spawn = { 
			vec4(-979.73876953125,-2997.0693359375,13.945078849792,0), -- x,y,z,heading
			vec4(-974.91973876953,-2986.9838867188,13.945068359375, 0),
			vec4(-984.21917724609,-3004.3366699219,13.945056915283,0)
		},
	},
}

--[[
	* Adding a New Selling Location
	**
	*** Step 1: Add a new entry in the location table
	*** Example:
	*** ["mydealership"] = {
	***     _config = {
	***         map_entity = {"PoI", {blip_id = 326, blip_color = 69, marker_id = 1, scale = {1.5,1.5,1.0}, color = {255,215,0,100}}}
	***     },
	***     title = "My Custom Dealership",
	***     pos = vec3(x, y, z), -- marker position
	*** }
--]]
cfg.sell_points = {
	["pdm"] = {
		_config = {map_entity = {"PoI", {blip_id = 369, blip_color = 25, marker_id = 1, scale = {1.5,1.5,1.0}, color = {0, 128, 255, 100}}}},
		title = "Sell Cars",
		pos = vec3(-61.744976043701,-1117.8952636719,26.432458877563),
	},

	["aircraft"] = {
		_config = {map_entity = {"PoI", {blip_id = 370, blip_color = 38, marker_id = 1, scale = {10.0,10.0,1.0}, color = {0,191,255,120}}}},
		title = "Sell Aircraft",
		pos = vec4(-1345.1208496094,-2722.6687011719,13.944955825806, 330.0),
		radius = 6,
	}
}

--[[
	* Adding a New Vehicles
	*** ['vehicle_model'] = {name = 'Vehicle Name', price = 10000, shop = {'mydealership'}}
	*** You can assign multiple vehicles to one shop or multiple shops to one vehicle
	*** Example:
	*** ['buffalo'] = {name = 'Buffalo', price = 18000, shop = {'mydealership', 'pdm'}}
--]]

cfg.vehicles = {
	['sports'] = {
		['alpha'] 				= {name = 'Alpha',                price = 53000,   shop = {'pdm'}},
    ['banshee'] 			= {name = 'Banshee',              price = 56000,   shop = {'pdm'}},
    ['bestiagts'] 		= {name = 'Bestia GTS',           price = 37000,   shop = {'pdm'}},
    ['buffalo'] 			= {name = 'Buffalo',              price = 18750,   shop = {'pdm'}},
    ['buffalo2'] 			= {name = 'Buffalo S',            price = 24500,   shop = {'pdm'}},
    ['carbonizzare'] 	= {name = 'Carbonizzare',         price = 155000,  shop = {'pdm'}},
    ['comet2']	 			= {name = 'Comet',                price = 130000,  shop = {'pdm'}},
    ['comet3']	 			= {name = 'Comet Retro Custom',   price = 175000,  shop = {'pdm'}},
    ['comet4']	 			= {name = 'Comet Safari',         price = 110000,  shop = {'pdm'}},
    ['comet5']	 			= {name = 'Comet SR',             price = 155000,  shop = {'pdm'}},
    ['coquette'] 			= {name = 'Coquette',             price = 145000,  shop = {'pdm'}},
	},
	['compacts'] = {
		["blista"] 				= {name = "Blista", 							price = 100, 			shop = {"pdm","luxury"}},
	},
	['helicopters'] = {
		["buzzard"] 			= {name = "Buzzard Attack",  			price = 100, 			shop = {"aircraft"}},
		["maverick"] 			= {name = "Maverick", 						price = 150000, 	shop = {"aircraft"}},
    ["swift"] 				= {name = "Swift", 								price = 550000, 	shop = {"aircraft"}},
    ["swift2"] 				= {name = "Swift II", 						price = 550000, 	shop = {"aircraft"}},
    ["supervolito"] 	= {name = "Super Volito", 				price = 850000, 	shop = {"aircraft"}},
    ["supervolito2"] 	= {name = "Super Volito II", 			price = 850000, 	shop = {"aircraft"}},
    ["volatus"] 			= {name = "Volatus", 							price = 3500000, 	shop = {"aircraft"}},
	},
	['boats'] = {
		["dinghy"] 				= {name = "Dinghy", 							price = 100, 			shop = {"marina"} }
	},
}

-- configuration for each vehicle shop
-- key = shop identifier (matches cfg.vehicles.shop)
-- showroom_location = vec3(x,y,z)
-- preview            = vec4(x,y,z,heading)
-- purchaseSpawn      = vec4(x,y,z,heading)
-- blip               = { id = blipId, color = blipColor }
-- marker             = { id = markerId, scale = { x,y,z }, color = { r,g,b,a } }
cfg.vehicleshops = {
    pdm = {
      shop_name         = "Luxury Car Dealership",
      showroom_location = vec3(-54.94, -1111.50, 26.44),
      preview           = vec4(-60.0, -1110.0, 26.4, 120.0),
      purchaseSpawn = {
          vec4(-61.744976043701,-1117.8952636719,26.432458877563, 10), -- Location where purchased vehicles will spawn
          vec4(-56.407440185547,-1116.4392089844,26.434999465942, 10)

      },
      blip              = { id = 326, color = 69 },
      marker            = { id = 1, scale = {1.5,1.5,1.0}, color = {255,215,0,100} }
    },
    aircraft = {
      shop_name         = "LSIA Hangar",
      showroom_location = vec3(-970.63586425781,-2999.8103027344,13.945083618164),
      preview           = vec4(-1345.1208496094,-2722.6687011719,13.944955825806, 330.0),
      purchaseSpawn = {
          vec4(-979.73876953125,-2997.0693359375,13.945078849792,0), -- x,y,z,heading
          vec4(-974.91973876953,-2986.9838867188,13.945068359375, 0),
          vec4(-984.21917724609,-3004.3366699219,13.945056915283,0)
      },
      blip              = { id = 90, color = 38 },
      marker            = { id = 1, scale = {2.0,2.0,1.0}, color = {0,191,255,120} }
    }
  }

-- where players can sell back vehicles
cfg.sellvehicle = {
    cars = {
      name = "Sell Cars",  
      type = "automobile",
      sellPrice = 75, -- players get 75% of original price
      blip = { id = 369, color = 25 },
      marker = { id = 1, scale = {1.5, 1.5, 1.0}, color = {0, 128, 255, 100} },
      coords = {
        vec3(-61.744976043701,-1117.8952636719,26.432458877563)
      }
    },
  
    aircraft = {
      name = "Sell Aircraft",  
      type = "aircraft",  
      sellPrice = 50, -- players get 50% of original price
      blip = { id = 370, color = 38 },
      marker = { id = 1, scale = {2.0, 2.0, 1.0}, color = {0, 191, 255, 120} },
      coords = {
        vec3(-965.33026123047,-3004.2521972656,13.9426612854)
      }
    }
  }

return cfg