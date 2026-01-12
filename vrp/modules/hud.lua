-- vRP HUD Module
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.hud then return end

local lang = vRP.lang

local HUD = class("HUD", vRP.Extension)

-- METHODS

function HUD:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("vrp", "cfg/hud")

  -- Register HUD configuration menu
  vRP.EXT.GUI:registerMenuBuilder("main", function(menu)
    local user = menu.user
    menu:addOption(lang.hud.title(), function(menu)
      user:openMenu("hud_config")
    end, lang.hud.description())
  end)

  -- Register HUD config menu
  vRP.EXT.GUI:registerMenuBuilder("hud_config", function(menu)
    local user = menu.user
    menu.title = lang.hud.config.title()
    menu.css.header_color = "rgba(0,125,255,0.75)"

    -- Toggle HUD
    menu:addOption(lang.hud.toggle(), function(menu)
      local hud_enabled = user.cdata.hud_enabled
      if hud_enabled == nil then hud_enabled = true end
      user.cdata.hud_enabled = not hud_enabled

      -- Send both the enabled state and the settings to ensure proper re-enabling
      self.remote._setHUDEnabled(user.source, not hud_enabled)
      if user.cdata.hud_enabled then
        -- If re-enabling, send current settings to client
        self.remote._updateHUDSettings(user.source, user.cdata)
      end

      user:actualizeMenu()
    end, function(menu)
      local hud_enabled = user.cdata.hud_enabled
      if hud_enabled == nil then hud_enabled = true end
      return hud_enabled and lang.hud.enabled() or lang.hud.disabled()
    end)

    -- Health bar toggle
    menu:addOption(lang.hud.health(), function(menu)
      local show_health = user.cdata.hud_show_health
      if show_health == nil then show_health = true end
      user.cdata.hud_show_health = not show_health
      self.remote._updateHUDSettings(user.source, user.cdata)
      user:actualizeMenu()
    end, function(menu)
      local show_health = user.cdata.hud_show_health
      if show_health == nil then show_health = true end
      return (show_health and lang.hud.showing() or lang.hud.hidden()) .. " " .. lang.hud.health()
    end)

    -- Armor bar toggle
    menu:addOption(lang.hud.armor(), function(menu)
      local show_armor = user.cdata.hud_show_armor
      if show_armor == nil then show_armor = true end
      user.cdata.hud_show_armor = not show_armor
      self.remote._updateHUDSettings(user.source, user.cdata)
      user:actualizeMenu()
    end, function(menu)
      local show_armor = user.cdata.hud_show_armor
      if show_armor == nil then show_armor = true end
      return (show_armor and lang.hud.showing() or lang.hud.hidden()) .. " " .. lang.hud.armor()
    end)

    -- Hunger bar toggle
    menu:addOption(lang.hud.hunger(), function(menu)
      local show_hunger = user.cdata.hud_show_hunger
      if show_hunger == nil then show_hunger = true end
      user.cdata.hud_show_hunger = not show_hunger
      self.remote._updateHUDSettings(user.source, user.cdata)
      user:actualizeMenu()
    end, function(menu)
      local show_hunger = user.cdata.hud_show_hunger
      if show_hunger == nil then show_hunger = true end
      return (show_hunger and lang.hud.showing() or lang.hud.hidden()) .. " " .. lang.hud.hunger()
    end)

    -- Thirst bar toggle
    menu:addOption(lang.hud.thirst(), function(menu)
      local show_thirst = user.cdata.hud_show_thirst
      if show_thirst == nil then show_thirst = true end
      user.cdata.hud_show_thirst = not show_thirst
      self.remote._updateHUDSettings(user.source, user.cdata)
      user:actualizeMenu()
    end, function(menu)
      local show_thirst = user.cdata.hud_show_thirst
      if show_thirst == nil then show_thirst = true end
      return (show_thirst and lang.hud.showing() or lang.hud.hidden()) .. " " .. lang.hud.thirst()
    end)

    -- Stamina bar toggle
    menu:addOption(lang.hud.stamina(), function(menu)
      local show_stamina = user.cdata.hud_show_stamina
      if show_stamina == nil then show_stamina = false end
      user.cdata.hud_show_stamina = not show_stamina
      self.remote._updateHUDSettings(user.source, user.cdata)
      user:actualizeMenu()
    end, function(menu)
      local show_stamina = user.cdata.hud_show_stamina
      if show_stamina == nil then show_stamina = false end
      return (show_stamina and lang.hud.showing() or lang.hud.hidden()) .. " " .. lang.hud.stamina()
    end)

    -- Reset HUD settings
    menu:addOption(lang.hud.reset(), function(menu)
      user.cdata.hud_enabled = nil
      user.cdata.hud_show_health = nil
      user.cdata.hud_show_armor = nil
      user.cdata.hud_show_hunger = nil
      user.cdata.hud_show_thirst = nil
      user.cdata.hud_show_stamina = nil
      self.remote._updateHUDSettings(user.source, user.cdata)
      user:actualizeMenu()
    end)
  end)
end

-- EVENT

HUD.event = {}

function HUD.event:playerSpawn(user, first_spawn)
  if first_spawn then
    -- Initialize HUD data if not exists
    if not user.cdata.hud_settings then
      user.cdata.hud_settings = {}
    end

    -- Set default HUD settings
    if user.cdata.hud_enabled == nil then
      user.cdata.hud_enabled = true
    end
    if user.cdata.hud_show_health == nil then
      user.cdata.hud_show_health = true
    end
    if user.cdata.hud_show_armor == nil then
      user.cdata.hud_show_armor = true
    end
    if user.cdata.hud_show_hunger == nil then
      user.cdata.hud_show_hunger = true
    end
    if user.cdata.hud_show_thirst == nil then
      user.cdata.hud_show_thirst = true
    end
    if user.cdata.hud_show_stamina == nil then
      user.cdata.hud_show_stamina = false
    end

    -- Send HUD settings to client immediately
    self.remote._updateHUDSettings(user.source, user.cdata)

    -- Send initial player data after a short delay to ensure client is ready
    Citizen.Wait(1500) -- Increased delay to ensure client is fully ready

    local initial_data = {
      health = 100,
      armor = 0,
      hunger = 1.0,
      thirst = 1.0,
      stamina = 100
    }

    -- Get actual player data if modules exist
    if vRP.EXT.PlayerState then
      initial_data.health = vRP.EXT.PlayerState.remote.getHealth(user.source) or 100
      initial_data.armor = vRP.EXT.PlayerState.remote.getArmour(user.source) or 0
    end

    -- Ensure all values are properly typed
    initial_data.health = tonumber(initial_data.health) or 100
    initial_data.armor = tonumber(initial_data.armor) or 0
    initial_data.hunger = tonumber(initial_data.hunger) or 1.0
    initial_data.thirst = tonumber(initial_data.thirst) or 1.0
    initial_data.stamina = tonumber(initial_data.stamina) or 100

    -- Send to client
    self.remote._updatePlayerData(user.source, initial_data)

    -- Fallback: refresh HUD after additional delay if needed
    Citizen.CreateThread(function()
      Citizen.Wait(3000) -- Wait 3 more seconds
      if user and user:isReady() then
        self.remote._refreshHUD(user.source)
      end
    end)
  end
end

function HUD.event:playerDeath(user)
  -- Update HUD when player dies
  if vRP.EXT.PlayerState then
    self.remote._updatePlayerData(user.source, {
      health = vRP.EXT.PlayerState.remote.getHealth(user.source) or 0,
      armor = vRP.EXT.PlayerState.remote.getArmour(user.source) or 0
    })
  end
end

-- Listen for player state updates
function HUD.event:playerStateUpdate(user, state)
  if user.cdata.hud_enabled then
    local update_data = {}

    if state.health then
      update_data.health = state.health
    end

    if update_data.health or state.armor then
      update_data.armor = state.armor or (vRP.EXT.PlayerState and vRP.EXT.PlayerState.remote.getArmour(user.source) or 0)
      self.remote._updatePlayerData(user.source, update_data)
    end
  end
end

-- TUNNEL

HUD.tunnel = {}

function HUD.tunnel:updateHUDSettings(settings)
  local user = vRP.users_by_source[source]
  if user and user:isReady() then
    for k, v in pairs(settings) do
      user.cdata[k] = v
    end
  end
end

-- REMOTE

HUD.remote = {}

function HUD.remote:_updateHUDSettings(source, settings)
  local user = vRP.users_by_source[source]
  if user and user:isReady() then
    for k, v in pairs(settings) do
      user.cdata[k] = v
    end
  end
end

function HUD.remote:_setHUDEnabled(source, enabled)
  vRP.EXT.GUI.remote.setVisible(source, enabled)

  -- If re-enabling HUD, also send current settings to ensure proper display
  if enabled then
    local user = vRP.users_by_source[source]
    if user and user.cdata then
      self.remote._updateHUDSettings(source, user.cdata)
    end
  end
end

function HUD.remote:_updatePlayerData(source, data)
  -- Send updated player data to client
  local user = vRP.users_by_source[source]
  if user and user:isReady() then
    self.remote.updatePlayerData(source, data)
  end
end

function HUD.remote:_refreshHUD(source)
  -- Force client to refresh HUD display
  local user = vRP.users_by_source[source]
  if user and user:isReady() then
    self.remote.refreshHUD(source)
  end
end

vRP:registerExtension(HUD)