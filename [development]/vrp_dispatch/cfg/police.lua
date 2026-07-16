local cfg = {}

-- marker https://docs.fivem.net/docs/game-references/blips/
	--color={r,g,b,a}
cfg.marker = {
  "PoI",{ 
    blip_id = 60,           -- Police Station
    blip_color = 29,          -- Blue
    marker_id = 1,
    scale = {1.0, 1.0, 1.0},
    color = {0, 0, 255, 255}
  }
}

-- {Name, Gtype, x, y, z}
cfg.pos = {
  {"Mission Row PD",        "Police",  441.200,  -981.900, 30.700},
  {"Vespucci PD",           "Police", -1096.400, -836.000, 19.000},
  {"Del Perro PD",          "Police", -1623.400, -1015.800, 13.100},
  {"Rockford Hills PD",     "Police",  -561.700,  -132.000, 38.400},
  {"Davis PD",              "Police",   362.500, -1591.000, 25.400},
  {"La Mesa PD",            "Police",   830.100, -1290.100, 28.200},
  {"Sandy Shores Sheriff",  "Police",  1853.200,  3686.600, 34.200},
  {"Paleto Bay Sheriff",    "Police",  -448.400,  6012.600, 31.700}
}

return cfg