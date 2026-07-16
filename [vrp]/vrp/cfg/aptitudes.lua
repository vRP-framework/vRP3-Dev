
local cfg = {}

-- exp notes:
-- levels are defined by the amount of xp
-- with a step of 5: 5|15|30|50|75 (by default)
-- total exp for a specific level, exp = step*lvl*(lvl+1)/2
-- level for a specific exp amount, lvl = (sqrt(1+8*exp/step)-1)/2

--calculate max
cfg.step = 5						-- XP needed per level unit
cfg.max_level = 100 		-- max level

cfg.max_xp = cfg.step * cfg.max_level * (cfg.max_level + 1) / 2
-- maxXP = 5 * 100 * 101 / 2 = 25250

-- define groups of aptitudes
--- _title: title of the group
--- map of aptitude => {title,init_exp,max_exp}
---- max_exp: -1 for infinite exp
cfg.gaptitudes = {
  -- Core character skills (based on GTA-style logic)
	--[[
  ["physical"] = {
    _title = "Physical",
    ["strength"] = {"Strength", 0, cfg.max_xp},       -- Impacts carry weight, melee damage
    ["stamina"] = {"Stamina", 0, cfg.max_xp},         -- Affects sprint duration
    ["agility"] = {"Agility", 0, cfg.max_xp},         -- Affects movement speed, jumping
  },
	--]]
}

cfg.lose_aptitudes_on_death = true

return cfg
