local lang = vRP.lang
local Luang = module("vrp", "lib/Luang")

local HUD = class("HUD", vRP.Extension)

---------------------------------------------------------------------
-- HELPERS
---------------------------------------------------------------------

local function getBool(user, key, default)
  local v = user.cdata[key]
  if v == nil then return default end
  return v
end

local function toggleBoolean(user, key, default)
  local current = getBool(user, key, default)
  user.cdata[key] = not current
  return not current
end

---------------------------------------------------------------------
-- EXTENSION
---------------------------------------------------------------------

function HUD:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("vrp_hud", "cfg/hud")
	
	-- load language 
	self.luang = Luang()
	self.luang:loadLocale(vRP.cfg.lang, module("vrp_hud", "cfg/lang/"..vRP.cfg.lang))
	self.lang = self.luang.lang[vRP.cfg.lang]

  ---------------------------------------------------------------------
	-- HUD CONFIG MENU
	---------------------------------------------------------------------
	local function menu_hud(self)
		vRP.EXT.GUI:registerMenuBuilder("hud", function(menu)
			local cfg = self.cfg
			local user   = menu.user
			local lang   = self.lang.hud
			local source = user.source

			menu.title = lang.config.title()
			menu.css.header_color = "rgba(0,125,255,0.75)"

			-- unified toggle builder
			local function addToggle(key, default)
				local bar = key:gsub("^hud_show_", "")
				local title = (lang[bar] and lang[bar]())

				menu:addOption(title, function(menu)
					toggleBoolean(user, key, default)
					self.remote._updateHUDSettings(source, user.cdata)
					user:actualizeMenu()
				end, (getBool(user, key, default) and lang.showing() or lang.hidden()) .. " " .. title)
			end

			---------------------------------------------------------------------
			-- HUD ENABLE TOGGLE
			---------------------------------------------------------------------
			menu:addOption(lang.toggle(), function(menu)
				local enabled = toggleBoolean(user, "hud_enabled", true)
				self.remote._setHUDEnabled(source, enabled)
				if enabled then
					self.remote._updateHUDSettings(source, user.cdata)
				end
				user:actualizeMenu()
			end, getBool(user, "hud_enabled", true) and lang.enabled() or lang.disabled())

			---------------------------------------------------------------------
			-- AUTO-GENERATED HUD BAR TOGGLES
			---------------------------------------------------------------------
			for _, key in ipairs(cfg.keys) do
				if key ~= "hud_enabled" then
					addToggle(key, (cfg.default_settings and cfg.default_settings[key]) or true)
				end
			end

			---------------------------------------------------------------------
			-- RESET ALL HUD SETTINGS
			---------------------------------------------------------------------
			menu:addOption(lang.reset(), function(menu)
				for _, key in ipairs(cfg.keys) do
					user.cdata[key] = nil
				end
				self.remote._updateHUDSettings(source, user.cdata)
				user:actualizeMenu()
			end)
		end)
	end
	
	menu_hud(self)
	
	---------------------------------------------------------------------
	-- MAIN MENU ENTRY
	---------------------------------------------------------------------	
	vRP.EXT.GUI:registerMenuBuilder("main", function(menu)
		menu:addOption("Hud", function(menu)
			menu.user:openMenu("hud")
		end)
	end)
end

---------------------------------------------------------------------
-- EVENTS
---------------------------------------------------------------------

HUD.event = {}

function HUD.event:playerSpawn(user, first_spawn)
  if not first_spawn then return end

  -- default settings
  local defaults = {
    hud_enabled      = true,
    hud_show_health  = true,
    hud_show_armor   = true,
    hud_show_hunger  = true,
    hud_show_thirst  = true,
    hud_show_stamina = false
  }

  for k,v in pairs(defaults) do
    if user.cdata[k] == nil then user.cdata[k] = v end
  end

  -- initial push
  --self.remote._updateHUDSettings(user.source, user.cdata)

  -- wait minimal time for client HUD to init
  Citizen.Wait(600)

  local ps = vRP.EXT.PlayerState

  local data = {
    health  = (ps and ps.remote.getHealth(user.source)) or 100,
    armor   = (ps and ps.remote.getArmour(user.source)) or 0,
    hunger  = 1.0,
    thirst  = 1.0,
    stamina = 100
  }

  --self.remote._updatePlayerData(user.source, data)

  -- delayed refresh
  Citizen.CreateThread(function()
    Citizen.Wait(1500)
    if user and user:isReady() then
      --self.remote._refreshHUD(user.source)
    end
  end)
end

function HUD.event:playerDeath(user)
  local ps = vRP.EXT.PlayerState
  if ps then
    self.remote._updatePlayerData(user.source, {
      health = ps.remote.getHealth(user.source) or 0,
      armor  = ps.remote.getArmour(user.source) or 0
    })
  end
end

function HUD.event:playerStateUpdate(user, state)
  if not user.cdata.hud_enabled then return end

  local ps = vRP.EXT.PlayerState
  local update = {}

  if state.health then update.health = state.health end
  if state.armor or update.health then
    update.armor = state.armor or (ps and ps.remote.getArmour(user.source) or 0)
  end

  if next(update) then
    self.remote._updatePlayerData(user.source, update)
  end
end

---------------------------------------------------------------------
-- TUNNEL
---------------------------------------------------------------------

HUD.tunnel = {}

function HUD.tunnel:updateHUDSettings(settings)
  local user = vRP.users_by_source[source]
  if not user or not user:isReady() then return end
  for k,v in pairs(settings) do user.cdata[k] = v end
end

---------------------------------------------------------------------
-- REMOTE
---------------------------------------------------------------------

HUD.remote = {}

function HUD.remote:_updateHUDSettings(source, settings)
  local user = vRP.users_by_source[source]
  if not user or not user:isReady() then return end
  for k,v in pairs(settings) do user.cdata[k] = v end
  self.remote.updateHUDSettings(source, settings)
end

function HUD.remote:_setHUDEnabled(source, enabled)
  vRP.EXT.GUI.remote.setVisible(source, enabled)
  if enabled then
    local user = vRP.users_by_source[source]
    if user then
      self.remote.updateHUDSettings(source, user.cdata)
    end
  end
end

function HUD.remote:_updatePlayerData(source, data)
  self.remote.updatePlayerData(source, data)
end

function HUD.remote:_refreshHUD(source)
  self.remote.refreshHUD(source)
end

function HUD.event:characterLoad(user)
	self.remote.test(source, vRP)
end

function HUD.event:extensionLoad(ext)
  if ext == vRP.EXT.GUI then
    self.remote.test(source, vRP)
  end
end

vRP:registerExtension(HUD)
