local cfg = {}

-- HUD Module
cfg.module_enabled = true

cfg.hud_enabled = true

-- Default HUD settings (these can be customized per player)
cfg.default_settings = {
  hud_enabled = true,
  hud_show_health = true,
  hud_show_armor = true,
  hud_show_hunger = true,
  hud_show_thirst = true,
  hud_show_stamina = false
}

cfg.hud_settings = {
	hud_enabled = true,
	hud_show_health = true,
	hud_show_armor = true,
	hud_show_hunger = true,
	hud_show_thirst = true,
	hud_show_stamina = true
}

cfg.keys = {
	"hud_enabled",
	"hud_show_health",
	"hud_show_armor",
	"hud_show_hunger",
	"hud_show_thirst",
	"hud_show_stamina"
}

return cfg