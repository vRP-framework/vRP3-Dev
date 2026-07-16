local cfg = {}

-- marker https://docs.fivem.net/docs/game-references/blips/
	--color={r,g,b,a}
cfg.marker = {
  "PoI",{ 
    blip_id = 436,          -- Fire Station
    blip_color = 1,           -- Red
    marker_id = 1,
    scale = {1.0, 1.0, 1.0},
    color = {255, 0, 0, 255}
  }
}

-- {Name, Gtype, x, y, z}
cfg.pos = {
  {"Davis Fire Station",        "Fire",   215.800, -1642.300, 29.700},
  {"El Burro Heights Fire",     "Fire",  1191.600, -1464.300, 34.900},
  {"Rockford Hills Fire",       "Fire",  -635.900,  -121.200, 39.000},
  {"Sandy Shores Fire",         "Fire",  1697.600,  3585.300, 35.500},
  {"Paleto Bay Fire",           "Fire",  -379.500,  6118.700, 31.800}
}

return cfg