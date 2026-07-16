local cfg = {}

-- marker https://docs.fivem.net/docs/game-references/blips/
	--color={r,g,b,a}
cfg.marker = {
  "PoI",{ 
    blip_id = 61,           -- Hospital
    blip_color = 2,           -- Green
    marker_id = 1,
    scale = {1.0, 1.0, 1.0},
    color = {0, 255, 0, 255}
  }
}

-- {Name, Gtype, x, y, z}
cfg.pos = {
  {"Pillbox Hill Medical",        "Hospital",  307.400, -1433.900, 29.900},
  {"Central LS Medical",          "Hospital", 1151.200, -1529.600, 35.400},
  {"Mount Zonah Medical",         "Hospital", -449.700,  -340.200, 34.500},
  {"Sandy Shores Medical",        "Hospital", 1839.600,  3672.900, 34.300},
  {"Paleto Bay Medical",          "Hospital", -246.900,  6330.000, 32.400}
}

return cfg