local cfg = {}

cfg.loading = true -- set to true if you want to use the loading screen

-- set the opacity of the clouds
cfg.opacity = 0.01 -- (default: 0.01)

-- setting this to false will NOT mute the sound as soon as the game loads 
-- (you will hear background noises while on the loading screen, so not recommended)
cfg.sound = true -- (default: true)

-- default spawn location {x, y, z, heading}
cfg.default_location = {
	-766.02301025391, 327.63537597656, 210.515625
}
cfg.heading = 332.69610595703

cfg.spawn = {
  ["last location"] = {
		name = "last location",
		label = "Last Location",
	},
	["airport"] = {
		coords = vector4(-1038.70,-2739.20,20.17, 333.15),
		name = "airport",
		label = "LSI Airport",
	},
	["busstop"] = {
    coords = vector4(434.72, -628.29, 28.72, 102.35),
    name = "busstop",
    label = "LS Bus Station",
	},
	["trainstop"] = {
    coords = vector4(-216.66, -1037.8, 30.14, 143.60),
    name = "trainstop",
    label = "LS Train Station",
	},
}

cfg.vRP_groups = true -- set to false if you dont want to use the vRP group system
--[[

	Define the groups for the players

  _config: group configuration
    title: group title
    gtype: group type
    default: set as default group, if

	default will only look for the job group
]]
cfg.groups = {
	["superadmin"] = {
    _config = {
      title = "Owner",
      gtype = "staff",
    }
  },
  ["admin"] = {
    _config = {
      title = "Admin",
      gtype = "staff",
    }
  },
  ["mod"] = {
    _config = {
      title = "Mod",
      gtype = "staff",
    }
  },
  ["police"] = {
    _config = {
      title = "Police",
      gtype = "job",
    }
  },
  ["emergency"] = {
    _config = {
      title = "Emergency",
      gtype = "job"
    }
  },
  ["repair"] = {
    _config = {
      title = "Repair",
      gtype = "job"
    }
  },
  ["taxi"] = {
    _config = {
      title = "Taxi",
      gtype = "job"
    }
  },
  ["citizen"] = {
    _config = {
      default = true,
      title = "Citizen",
      gtype = "job"
    }
  }
}

cfg.disable_keys = {
	["move"] 		= 1, 	-- Look Left Right
	["move_1"] 		= 2, 	-- Look Up Down
	["move_2"] 		= 30, 	-- move let right
	["move_3"] 		= 31, 	-- move up down
	
	["player"] 		= 21, 	-- sprint
	["player_1"] 	= 22, 	-- jump
	["player_2"] 	= 23, 	-- enter
	["player_3"] 	= 24, 	-- attack
	
	["wepon"] 		= 45,	-- reload
	["wepon_1"] 	= 47,	-- detonate
	
	["melee"] 		= 263,	-- Melee 
	["melee_1"] 	= 264,	-- Melee 
	["melee_2"] 	= 257,	-- Melee 
	["melee_3"] 	= 140,	-- Melee 
	["melee_4"] 	= 141,	-- Melee
	["melee_5"] 	= 142,	-- Melee 
	["melee_6"] 	= 143,	-- Melee
	
	["vehicle"] 	= 75,	-- disable exit/enter vehicle
	
	["enter"] 		= 18,	-- Enter
	["veh_ctrl"] 	= 106,	-- Vehicle Mouse Control Override
}

cfg.default_customization = {
  female = {
    customizations = {
      model = "mp_f_freemode_01",       -- Female character model
    --Face
      ["overlay:0"] = {255, 0, 0, 1.0},  -- Blemishes: ID 255 (no blemishes)
      ["overlay:1"] = {255, 0, 0, 1.0},  -- Eyebrows: ID 255 (default eyebrows)
      ["overlay:2"] = {5, 0, 0, 1.0},    -- Facial blemishes: ID 5
      ["overlay:3"] = {255, 0, 0, 1.0},  -- Facial hair: ID 255 (no facial hair)
      ["overlay:4"] = {1, 0, 0, 1.0},    -- Makeup: ID 1
      ["overlay:5"] = {255, 0, 0, 1.0},  -- Aging: ID 255 (no aging)
      ["overlay:6"] = {255, 0, 0, 1.0},  -- Additional face detail: ID 255
      ["overlay:7"] = {255, 0, 0, 1.0},  -- Additional face detail: ID 255
      ["overlay:8"] = {5, 23, 0, 0.5},   -- Additional face detail: ID 5, color ID 23, opacity 0.5
      ["overlay:9"] = {255, 0, 0, 1.0},  -- Moles/freckles: ID 255 (no moles/freckles)
      ["overlay:10"] = {255, 0, 0, 1.0}, -- Chest hair: ID 255 (no chest hair)
      ["overlay:11"] = {255, 0, 0, 1.0}, -- Body blemishes: ID 255 (no body blemishes)
      ["overlay:12"] = {255, 0, 0, 1.0}, -- Additional face detail: ID 255
    --Hair:
      ["drawable:2"] = {4, 0, 2},        -- Hair: ID 4, variation 2
      ["hair:color"] = {0, 0},           -- Hair color: Primary color 0, secondary color 0
    --Body:
      ["drawable:0"] = {40, 0, 2},       -- Head: ID 40, variation 2
      ["drawable:8"] = {0, 0, 2},        -- Unknown (possibly body armor or decal): ID 0, variation 2
      ["drawable:9"] = {0, 0, 2},        -- Body armor: ID 0, variation 2
      ["drawable:10"] = {0, 0, 2},       -- Decals: ID 0, variation 2
      ["drawable:16"] = {0, 0, 0},       -- Undershirt
      ["drawable:18"] = {0, 0, 0},       -- Unknown
      ["drawable:19"] = {0, 0, 0},       -- Unknown
      ["drawable:20"] = {0, 0, 0},       -- Unknown
    --Clothing
      ["drawable:1"] = {0, 0, 2},        -- Mask: ID 0, variation 2
      ["drawable:3"] = {0, 0, 2},        -- Gloves: ID 0, variation 2
      ["drawable:4"] = {0, 0, 2},        -- Pants: ID 0, variation 2
      ["drawable:5"] = {0, 0, 2},        -- Bags: ID 0, variation 2
      ["drawable:6"] = {0, 0, 2},        -- Torso: ID 0, variation 2
      ["drawable:7"] = {0, 0, 2},        -- Accessories: ID 0, variation 2
      ["drawable:11"] = {1, 4, 2},       -- Tops: ID 1, variation 2
      ["drawable:12"] = {0, 0, 0},       -- Shoes
      ["drawable:13"] = {0, 0, 0},       -- Decal top layer
      ["drawable:14"] = {0, 0, 0},       -- Torso accessories
      ["drawable:15"] = {0, 0, 0},       -- Unknown
      ["drawable:17"] = {0, 0, 0},       -- Armor
    --Accessories
      ["prop:0"] = {-1, 0},              -- Hats/helmets: -1 (no hat/helmet)
      ["prop:1"] = {19, 9},              -- Glasses: ID 19, variation 9
      ["prop:2"] = {7, 0},               -- Earpieces: ID 7, default variation
      ["prop:3"] = {-1, 0},              -- Watches: -1 (no watch)
      ["prop:4"] = {-1, 0},              -- Unknown
      ["prop:5"] = {-1, 0},              -- Bracelets: -1 (no bracelet)
      ["prop:6"] = {4, 2},               -- Neck accessories: ID 4, variation 2
      ["prop:7"] = {-1, 0},              -- Glasses: -1 (no glasses)
      ["prop:8"] = {-1, 0},              -- Left wrist: -1 (no item)
      ["prop:9"] = {-1, 0},              -- Right wrist: -1 (no item)
      ["prop:10"] = {-1, 0}             -- Unknown
    }
  },
  male = {
    customizations = {
      model = "mp_m_freemode_01",        -- Ped model (Male free-mode character)
    -- FACE
      ["overlay:0"] = {255, 0, 0, 1.0},  -- Blemishes
      ["overlay:1"] = {7, 0, 0, 1.0},    -- Eyebrows
      ["overlay:2"] = {4, 0, 0, 1.0},    -- Facial blemishes
      ["overlay:3"] = {255, 0, 0, 1.0},  -- Facial hair
      ["overlay:4"] = {255, 0, 0, 1.0},  -- Makeup
      ["overlay:5"] = {255, 0, 0, 1.0},  -- Aging      
      ["overlay:6"] = {255, 0, 0, 1.0},  -- Additional face detail      
      ["overlay:7"] = {255, 0, 0, 1.0},  -- Additional face detail
      ["overlay:8"] = {255, 0, 0, 1.0},  -- Additional face detail
      ["overlay:9"] = {255, 0, 0, 1.0},  -- Moles/freckles
      ["overlay:10"] = {255, 0, 0, 1.0}, -- Chest hair
      ["overlay:11"] = {255, 0, 0, 1.0}, -- Body blemishes      
      ["overlay:12"] = {255, 0, 0, 1.0}, -- Blemishes      
    -- HAIR
      ["drawable:2"] = {4, 0, 2},        -- Hair
      ["hair_color"] = {0, 0},           -- Hair color
    -- BODY
      ["drawable:6"] = {12, 12, 2},      -- Torso
      ["drawable:7"] = {0, 0, 2},        -- Accessories on torso
      ["drawable:8"] = {16, 0, 2},       -- Unknown
      ["drawable:9"] = {0, 0, 2},        -- Body armor
      ["drawable:11"] = {62, 0, 2},      -- Tops
      ["drawable:10"] = {0, 0, 2},       -- Decals
    -- CLOTHING
      ["drawable:0"] = {0, 0, 2},        -- Headwear
      ["drawable:1"] = {0, 0, 2},        -- Mask
      ["drawable:3"] = {0, 0, 2},        -- Gloves
      ["drawable:4"] = {0, 10, 0},       -- Pants
      ["drawable:5"] = {0, 0, 2},        -- Bags      
      ["drawable:12"] = {0, 0, 0},       -- Shoes
      ["drawable:13"] = {0, 0, 0},       -- Decal top layer
      ["drawable:15"] = {0, 0, 0},       -- Unknown
      ["drawable:16"] = {0, 0, 0},       -- Undershirt
      ["drawable:17"] = {0, 0, 0},       -- Armor
      ["drawable:18"] = {0, 0, 0},       -- Unknown 
      ["drawable:19"] = {0, 0, 0},       -- Unknown 
      ["drawable:20"] = {0, 0, 0},       -- Unknown 
    -- ACCESSORIES
      ["prop:0"] = {-1, 0},              -- Hats/Helmets
      ["prop:1"] = {18, 1},              -- Glasses (specific item)
      ["prop:2"] = {-1, 0},              -- Earpieces
      ["prop:3"] = {-1, 0},              -- Watches
      ["prop:4"] = {-1, 0},              -- Unknown 
      ["prop:5"] = {-1, 0},              -- Bracelets
      ["prop:6"] = {4, 1},               -- Neck accessories
      ["prop:7"] = {-1, 0},              -- Glasses
      ["prop:8"] = {-1, 0},              -- Left wrist item
      ["prop:9"] = {-1, 0},              -- Right wrist item
      ["prop:10"] = {-1, 0},             -- Unknown         
    }
  }
}


return cfg