local cfg = {}

cfg.area_radius = 1.5
cfg.area_height = 2.0

-- flat purchase price per category; a business entry's own `price` field
-- (if set) overrides this. Tune these numbers directly here, no code change.
cfg.category_prices = {
	food = 15000,
	tools = 40000,
	chemicals = 60000,
	drugstore = 35000,
	gear = 50000,
	melee_weapons = 25000,
	handguns = 70000,
}

-- key = unique business id, also the persistence key suffix ("vRP:business:"<id>)
-- kind: category tag, looked up in cfg.category_prices for the default price;
--       also usable later to find "all food stores" etc. without touching
--       this table's shape.
cfg.businesses = {
	["food_1"] = {
		kind = "food", title = "Food Store #1",
		pos = vec3(128.1410369873, -1286.1120605469, 29.281036376953),
		_config = { map_entity = {"PoI", {blip_id = 52, blip_color = 2, marker_id = 1, scale = {1.0,1.0,1.0}, color = {0,255,0,100}}} },
	},
	["food_2"] = {
		kind = "food", title = "Food Store #2",
		pos = vec3(-47.522762298584, -1756.85717773438, 29.4210109710693),
		_config = { map_entity = {"PoI", {blip_id = 52, blip_color = 2, marker_id = 1, scale = {1.0,1.0,1.0}, color = {0,255,0,100}}} },
	},
	["food_3"] = {
		kind = "food", title = "Food Store #3",
		pos = vec3(25.7454013824463, -1345.26232910156, 29.4970207214355),
		_config = { map_entity = {"PoI", {blip_id = 52, blip_color = 2, marker_id = 1, scale = {1.0,1.0,1.0}, color = {0,255,0,100}}} },
	},
	["food_4"] = {
		kind = "food", title = "Food Store #4",
		pos = vec3(1135.57678222656, -981.78125, 46.4157981872559),
		_config = { map_entity = {"PoI", {blip_id = 52, blip_color = 2, marker_id = 1, scale = {1.0,1.0,1.0}, color = {0,255,0,100}}} },
	},
	["food_5"] = {
		kind = "food", title = "Food Store #5",
		pos = vec3(1163.53820800781, -323.541320800781, 69.2050552368164),
		_config = { map_entity = {"PoI", {blip_id = 52, blip_color = 2, marker_id = 1, scale = {1.0,1.0,1.0}, color = {0,255,0,100}}} },
	},
	["food_6"] = {
		kind = "food", title = "Food Store #6",
		pos = vec3(374.190032958984, 327.506713867188, 103.566368103027),
		_config = { map_entity = {"PoI", {blip_id = 52, blip_color = 2, marker_id = 1, scale = {1.0,1.0,1.0}, color = {0,255,0,100}}} },
	},
	["food_7"] = {
		kind = "food", title = "Food Store #7",
		pos = vec3(2555.35766601563, 382.16845703125, 108.622947692871),
		_config = { map_entity = {"PoI", {blip_id = 52, blip_color = 2, marker_id = 1, scale = {1.0,1.0,1.0}, color = {0,255,0,100}}} },
	},
	["food_8"] = {
		kind = "food", title = "Food Store #8",
		pos = vec3(2676.76733398438, 3281.57788085938, 55.2411231994629),
		_config = { map_entity = {"PoI", {blip_id = 52, blip_color = 2, marker_id = 1, scale = {1.0,1.0,1.0}, color = {0,255,0,100}}} },
	},
	["food_9"] = {
		kind = "food", title = "Food Store #9",
		pos = vec3(1960.50793457031, 3741.84008789063, 32.3437385559082),
		_config = { map_entity = {"PoI", {blip_id = 52, blip_color = 2, marker_id = 1, scale = {1.0,1.0,1.0}, color = {0,255,0,100}}} },
	},
	["food_10"] = {
		kind = "food", title = "Food Store #10",
		pos = vec3(1393.23828125, 3605.171875, 34.9809303283691),
		_config = { map_entity = {"PoI", {blip_id = 52, blip_color = 2, marker_id = 1, scale = {1.0,1.0,1.0}, color = {0,255,0,100}}} },
	},
	["food_11"] = {
		kind = "food", title = "Food Store #11",
		pos = vec3(1166.18151855469, 2709.35327148438, 38.15771484375),
		_config = { map_entity = {"PoI", {blip_id = 52, blip_color = 2, marker_id = 1, scale = {1.0,1.0,1.0}, color = {0,255,0,100}}} },
	},
	["food_12"] = {
		kind = "food", title = "Food Store #12",
		pos = vec3(547.987609863281, 2669.7568359375, 42.1565132141113),
		_config = { map_entity = {"PoI", {blip_id = 52, blip_color = 2, marker_id = 1, scale = {1.0,1.0,1.0}, color = {0,255,0,100}}} },
	},
	["food_13"] = {
		kind = "food", title = "Food Store #13",
		pos = vec3(1698.30737304688, 4924.37939453125, 42.0636749267578),
		_config = { map_entity = {"PoI", {blip_id = 52, blip_color = 2, marker_id = 1, scale = {1.0,1.0,1.0}, color = {0,255,0,100}}} },
	},
	["food_14"] = {
		kind = "food", title = "Food Store #14",
		pos = vec3(1729.54443359375, 6415.76513671875, 35.0372200012207),
		_config = { map_entity = {"PoI", {blip_id = 52, blip_color = 2, marker_id = 1, scale = {1.0,1.0,1.0}, color = {0,255,0,100}}} },
	},
	["food_15"] = {
		kind = "food", title = "Food Store #15",
		pos = vec3(-3243.9013671875, 1001.40405273438, 12.8307056427002),
		_config = { map_entity = {"PoI", {blip_id = 52, blip_color = 2, marker_id = 1, scale = {1.0,1.0,1.0}, color = {0,255,0,100}}} },
	},
	["food_16"] = {
		kind = "food", title = "Food Store #16",
		pos = vec3(-2967.8818359375, 390.78662109375, 15.0433149337769),
		_config = { map_entity = {"PoI", {blip_id = 52, blip_color = 2, marker_id = 1, scale = {1.0,1.0,1.0}, color = {0,255,0,100}}} },
	},
	["food_17"] = {
		kind = "food", title = "Food Store #17",
		pos = vec3(-3041.17456054688, 585.166198730469, 7.90893363952637),
		_config = { map_entity = {"PoI", {blip_id = 52, blip_color = 2, marker_id = 1, scale = {1.0,1.0,1.0}, color = {0,255,0,100}}} },
	},
	["food_18"] = {
		kind = "food", title = "Food Store #18",
		pos = vec3(-1820.55725097656, 792.770568847656, 138.113250732422),
		_config = { map_entity = {"PoI", {blip_id = 52, blip_color = 2, marker_id = 1, scale = {1.0,1.0,1.0}, color = {0,255,0,100}}} },
	},
	["food_19"] = {
		kind = "food", title = "Food Store #19",
		pos = vec3(-1486.76574707031, -379.553985595703, 40.163387298584),
		_config = { map_entity = {"PoI", {blip_id = 52, blip_color = 2, marker_id = 1, scale = {1.0,1.0,1.0}, color = {0,255,0,100}}} },
	},
	["food_20"] = {
		kind = "food", title = "Food Store #20",
		pos = vec3(-1223.18127441406, -907.385681152344, 12.3263463973999),
		_config = { map_entity = {"PoI", {blip_id = 52, blip_color = 2, marker_id = 1, scale = {1.0,1.0,1.0}, color = {0,255,0,100}}} },
	},
	["tools_1"] = {
		kind = "tools", title = "Tools Store",
		pos = vec3(-707.408996582031, -913.681701660156, 19.2155857086182),
		_config = { map_entity = {"PoI", {blip_id = 402, blip_color = 47, marker_id = 1, scale = {1.0,1.0,1.0}, color = {255,150,0,100}}} },
	},
	["chemicals_1"] = {
		kind = "chemicals", title = "Chemical Supplier",
		pos = vec3(1163.79260253906, 2705.58544921875, 38.1576995849609),
		_config = { map_entity = {"PoI", {blip_id = 140, blip_color = 5, marker_id = 1, scale = {1.0,1.0,1.0}, color = {255,255,0,100}}} },
	},
	["drugstore_1"] = {
		kind = "drugstore", title = "Drugstore",
		pos = vec3(-497.977142333984, -328.329895599, 34.501636505127),
		_config = { map_entity = {"PoI", {blip_id = 51, blip_color = 27, marker_id = 1, scale = {1.0,1.0,1.0}, color = {255,0,255,100}}} },
	},
	["gear_1"] = {
		kind = "gear", title = "Gear Shop",
		pos = vec3(844.76324462891, -1029.4772949219, 28.194856643677),
		_config = { map_entity = {"PoI", {blip_id = 110, blip_color = 1, marker_id = 1, scale = {1.0,1.0,1.0}, color = {255,0,0,100}}} },
	},
	["melee_weapons_1"] = {
		kind = "melee_weapons", title = "Melee Weapons Shop",
		pos = vec3(21.70, -1107.41, 29.79),
		_config = { map_entity = {"PoI", {blip_id = 141, blip_color = 1, marker_id = 1, scale = {1.0,1.0,1.0}, color = {255,0,0,100}}} },
	},
	["handguns_1"] = {
		kind = "handguns", title = "Handgun Shop",
		pos = vec3(844.299, -1033.26, 28.1949),
		_config = { map_entity = {"PoI", {blip_id = 110, blip_color = 1, marker_id = 1, scale = {1.0,1.0,1.0}, color = {255,0,0,100}}} },
	},
}

return cfg
