local cfg = {}

-- Units and base weights
cfg.inventory_unit = "lb" -- "lb" | "kg"
cfg.inventory_weight_per_strength = 10  -- Weight added per strength level
cfg.inventory_base_strength = 100       -- Base weight capacity

-- Death inventory rules
cfg.lose_inventory_on_death = true
cfg.keep_items_on_death = {
    "item1",
    "item2",
    "item3",
    "item4",
}

-- (see vRP.EXT.Inventory:defineItem)
-- map of id => {name, description, menu_builder, weight}
--- name: display name, value or genfunction(args)
--- description: value or genfunction(args) (html)
--- menu_builder: (optional) genfunction(args, menu)
--- weight: (optional) value or genfunction(args)
--
-- genfunction are functions returning a correct value as: function(args, ...)
-- where args is a list of {base_idname,args...}
cfg.items = {
  ["gold_ore"] = {"Gold ore","",nil,1},
  ["gold_processed"] = {"Gold processed","",nil,1.2},
  ["gold_ingot"] = {"Gold ingot","",nil,12},
  ["gold_catalyst"] = {"Gold catalyst","Used to transform processed gold into gold ingot.",nil,0.1},
  ["weed"] = {"Weed leaf", "", nil, 0.05},
  ["weed_processed"] = {"Weed processed", "", nil, 0.1},
  ["demineralized_water"] = {"Demineralized water (1L)","",nil,1}
}


-- Carry bag types and effects
cfg.bags = {
  ["Small_bag"] = { -- item id
    bonus = 15,
    model = "prop_cs_handbag",
  },
  ["Medium_bag"] = {
    bonus = 20,
    model = "prop_med_bag_01", 
  },
  ["Large_bag"] = {
    bonus = 25,
    model = "xm_prop_body_bag",
    restrict_movement = true
  }
}

-- Drop system
cfg.drop_item = "bkr_prop_duffel_bag_01a" -- World drop prop
cfg.drop_cleanup = 60   -- Minutes between cleanup cycles, set to false to disable
cfg.drop_size = {
    maxWeight = 5000,
    maxItems = 25
}

-- Static/shared inventories
cfg.chests = {
    ["evidence"] = {
        title = "Police Evidence",
        weight = 50000,
        permission = {"police"},
        coords = vec3(452.4429, -980.1745, 30.6896)
    },
    ["police"] = {
        title = "Police Inventory",
        weight = 5000,
        permission = {"police"},
        coords = vec3(1,1,1) -- Fill as needed
    },
    ["ambulance"] = {
        title = "Ambulance Inventory",
        weight = 5000,
        permission = {"ambulance"},
        coords = vec3(1,1,1) -- Fill as needed
    }
}

return cfg
