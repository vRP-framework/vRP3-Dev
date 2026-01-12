-- vRP HUD configuration

local cfg = {}

-- HUD Module
cfg.module_enabled = true

-- Default HUD settings (these can be customized per player)
cfg.default_settings = {
  hud_enabled = true,
  hud_show_health = true,
  hud_show_armor = true,
  hud_show_hunger = true,
  hud_show_thirst = true,
  hud_show_stamina = false
}

return cfg