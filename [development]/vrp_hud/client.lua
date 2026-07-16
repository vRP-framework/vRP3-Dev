Tunnel = module("vrp", "lib/Tunnel")
Proxy = module("vrp", "lib/Proxy")

local cvRP = module("vrp", "client/vRP")
vRP = cvRP() -- instantiate vRP

local pvRP = {}
-- load script in vRP context
function pvRP.loadScript(resource, path)
  module(resource, path)
end

Proxy.addInterface("vRP", pvRP)

for k,v in pairs(vRP.EXT) do
	print(k,v)
end

local HUD = class("HUD", vRP.Extension)
local cfg = module("vrp_hud", "cfg/hud")

---------------------------------------------------------------------
-- CONSTRUCTOR
---------------------------------------------------------------------

function HUD:__construct()
  vRP.Extension.__construct(self)
	
	self.vRP = {}

  self.player_data = {
    health = 100,
    armor = 0,
    hunger = 1.0,
    thirst = 1.0,
    stamina = 100
  }

  -- stamina tracking cache
  self.staminaData = {
    currentStamina = 100,
    lastUpdate = GetGameTimer()
  }

  ---------------------------------------------------------------------
  -- MAIN OPTIMIZED HUD LOOP (Level 2)
  ---------------------------------------------------------------------
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(50) -- 20 ticks per second (fast + efficient)

      if not cfg.hud_enabled or not cfg.hud_settings.hud_enabled then
        Citizen.Wait(300)
        goto continue
      end

      local ped = PlayerPedId()
      if not DoesEntityExist(ped) then
        Citizen.Wait(200)
        goto continue
      end

      local changes = {}

      -------------------------------------------------------------
      -- HEALTH
      -------------------------------------------------------------
      if cfg.hud_settings.hud_show_health then
        local h = GetEntityHealth(ped)
        if math.abs(h - self.player_data.health) >= 2 then
          changes.health = h
        end
      end

      -------------------------------------------------------------
      -- ARMOR
      -------------------------------------------------------------
      if cfg.hud_settings.hud_show_armor then
        local a = GetPedArmour(ped)
        if math.abs(a - self.player_data.armor) >= 2 then
          changes.armor = a
        end
      end

      -------------------------------------------------------------
      -- STAMINA (custom system)
      -------------------------------------------------------------
      if cfg.hud_settings.hud_show_stamina then
        local s = self:getPlayerStamina(ped)
        if math.abs(s - self.player_data.stamina) >= 0.5 then
          changes.stamina = s
        end
      end

      -------------------------------------------------------------
      -- APPLY UPDATES
      -------------------------------------------------------------
      if next(changes) then
        self:updatePlayerData(changes)
        self:updateHUD()
      end

      ::continue::
    end
  end)

  ---------------------------------------------------------------------
  -- FALLBACK INITIAL REFRESH
  ---------------------------------------------------------------------
  Citizen.CreateThread(function()
    Citizen.Wait(2000)
    if cfg.hud_enabled and cfg.hud_settings.hud_enabled then
      self:refreshHUD()
    end
  end)
end

---------------------------------------------------------------------
-- HUD CONTAINER BUILDING (Only called when needed)
---------------------------------------------------------------------

function HUD:updateHUD()
  if not cfg.hud_settings.hud_enabled or not cfg.hud_enabled then
    vRP.EXT.GUI:removeDiv(user.source, "hud_container")
    return
  end

  local elements = {}

  local function addElement(show, name, label, color, value, max)
    if not show then return end
    local percent = math.max(0, math.min(1, value / max)) * 100
    table.insert(elements,
      self:createHUDElement(name, string.format("%s: %d%%", label, value), color, percent)
    )
  end

  addElement(cfg.hud_settings.hud_show_health,  "health",  "Health",  "rgba(255,0,0,0.9)", self.player_data.health, 100)
  addElement(cfg.hud_settings.hud_show_armor,   "armor",   "Armor",   "rgba(0,0,255,0.9)", self.player_data.armor, 100)
  addElement(cfg.hud_settings.hud_show_hunger,  "hunger",  "Hunger",  "rgba(255,165,0,0.9)", self.player_data.hunger * 100, 100)
  addElement(cfg.hud_settings.hud_show_thirst,  "thirst",  "Thirst",  "rgba(0,191,255,0.9)", self.player_data.thirst * 100, 100)
  addElement(cfg.hud_settings.hud_show_stamina, "stamina", "Stamina", "rgba(0,255,0,0.9)", self.player_data.stamina, 100)

  local hud_html = string.format([[
    <div style="position:fixed;bottom:10px;right:20px;z-index:1000;font-family:Montserrat,sans-serif;">
      %s
    </div>
  ]], table.concat(elements, ""))

  vRP.EXT.GUI:setDiv(user.source, "hud_container", "", hud_html)
end

---------------------------------------------------------------------
-- HUD ELEMENT CREATOR
---------------------------------------------------------------------

function HUD:createHUDElement(element, text, bar_color, bar_width)
  return string.format([[
    <div style="
      width:180px;height:20px;background:rgba(0,0,0,0.8);
      border-left:4px solid %s;border-radius:3px;
      margin-bottom:5px;position:relative;color:white;
      font-size:11px;font-weight:bold;text-shadow:1px 1px black;
      display:flex;align-items:center;padding:0 8px;box-sizing:border-box;
    ">
      <div style="
        position:absolute;left:0;top:0;height:100%%;
        width:%d%%;background:%s;border-radius:2px;opacity:0.8;
      "></div>
      <div style="position:relative;z-index:2;width:100%%;text-align:center;">%s</div>
    </div>
  ]], bar_color, bar_width, bar_color, text)
end

---------------------------------------------------------------------
-- HUD DATA UPDATES
---------------------------------------------------------------------

function HUD:updatePlayerData(data)
  for k, v in pairs(data) do
    self.player_data[k] = tonumber(v) or v
  end
end

---------------------------------------------------------------------
-- SETTINGS UPDATE
---------------------------------------------------------------------

function HUD:updateHUDSettings(settings)
  local prev_enabled = cfg.hud_settings.hud_enabled

  for k, v in pairs(settings) do
    cfg.hud_settings[k] = v
  end

  if settings.hud_enabled == false then
    cfg.hud_enabled = false
    vRP.EXT.GUI:removeDiv(user.source, "hud_container")
    return
  end

  cfg.hud_enabled = true
  self:updateHUD()
end

function HUD:setHUDEnabled(enabled)
  cfg.hud_enabled = enabled
  if not enabled then
    vRP.EXT.GUI:removeDiv(user.source, "hud_container")
  else
    self:updateHUD()
  end
end

---------------------------------------------------------------------
-- STAMINA SYSTEM (Optimized)
---------------------------------------------------------------------

function HUD:getPlayerStamina(ped)
  local now = GetGameTimer()
  local dt = (now - self.staminaData.lastUpdate) / 1000.0
  self.staminaData.lastUpdate = now

  local isSprinting = IsControlPressed(0, 21)

  if isSprinting and self.staminaData.currentStamina > 0 then
    self.staminaData.currentStamina = self.staminaData.currentStamina - (3.5 * dt)
  else
    self.staminaData.currentStamina = self.staminaData.currentStamina + (1.75 * dt)
  end

  self.staminaData.currentStamina = math.max(0, math.min(100, self.staminaData.currentStamina))

  return self.staminaData.currentStamina
end

---------------------------------------------------------------------
-- REFRESH
---------------------------------------------------------------------

function HUD:refreshHUD()
  self:updateHUD()
end

---------------------------------------------------------------------
-- NUI READY EVENT
---------------------------------------------------------------------

HUD.event = {}

function HUD.event:NUIReady()
  self:updateHUD()
end

---------------------------------------------------------------------
-- NUI READY EVENT
---------------------------------------------------------------------

function HUD:test(data)
print("triggered")
	for k,v in pairs(data) do
		print(k,v)
	end
end

---------------------------------------------------------------------
-- TUNNEL
---------------------------------------------------------------------

HUD.tunnel = {}
HUD.tunnel.test = HUD.test
HUD.tunnel.updatePlayerData = HUD.updatePlayerData
HUD.tunnel.setHUDEnabled = HUD.setHUDEnabled
HUD.tunnel.updateHUDSettings = HUD.updateHUDSettings
HUD.tunnel.refreshHUD = HUD.refreshHUD

vRP:registerExtension(HUD)
