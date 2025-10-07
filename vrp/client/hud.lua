-- vRP HUD Client Module
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.hud then return end

local HUD = class("HUD", vRP.Extension)

-- METHODS

function HUD:__construct()
  vRP.Extension.__construct(self)

  self.hud_enabled = true
  -- Initialize with default settings
  self.hud_settings = {
    hud_enabled = true,
    hud_show_health = true,
    hud_show_armor = true,
    hud_show_hunger = true,
    hud_show_thirst = true,
    hud_show_stamina = true -- Temporarily enabled for stamina testing
  }
  self.player_data = {
    health = 100,
    armor = 0,
    hunger = 1.0,
    thirst = 1.0,
    stamina = 100
  }

  -- Debug flag to help troubleshoot
  self.debug_mode = false -- Disabled for clean operation

  -- HUD update task - frequent updates
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(0) -- Critical: Yield control every frame to prevent script deadlock

      if self.hud_enabled and self.hud_settings.hud_enabled then
        self:checkForUpdates()
      else
        Citizen.Wait(100) -- Wait when HUD is disabled
      end
    end
  end)

  -- Listen for player state changes
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(0) -- Critical: Yield control every frame to prevent script deadlock

      if self.hud_enabled and self.hud_settings.hud_enabled then
        local update_data = {}

        -- Get current health
        if self.hud_settings.hud_show_health then
          local current_health = GetEntityHealth(GetPlayerPed(-1))
          if math.abs(current_health - self.player_data.health) > 1 then -- Allow small variance
            update_data.health = current_health
          end
        end

        -- Get current armor
        if self.hud_settings.hud_show_armor then
          local current_armor = GetPedArmour(GetPlayerPed(-1))
          if math.abs(current_armor - self.player_data.armor) > 1 then -- Allow small variance
            update_data.armor = current_armor
          end
        end

        -- Get current stamina (real-time tracking - no threshold)
        if self.hud_settings.hud_show_stamina then
          local current_stamina = self:getPlayerStamina()
          -- Always update stamina for real-time response
          update_data.stamina = current_stamina
        end

        if next(update_data) then
          self:updatePlayerData(update_data)
        end
      else
        Citizen.Wait(100) -- Wait when HUD is disabled
      end
    end
  end)

  -- Dedicated stamina tracking (every frame updates)
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(0) -- Critical: Yield control every frame to prevent script deadlock

      if self.hud_enabled and self.hud_settings.hud_enabled and self.hud_settings.hud_show_stamina then
        local current_stamina = self:getPlayerStamina()
        -- Always update stamina for real-time response (no threshold)
        self:updatePlayerData({stamina = current_stamina})
      else
        Citizen.Wait(100) -- Minimal wait when stamina HUD is disabled
      end
    end
  end)

  -- Override native stamina system (set to max every 3 seconds)
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(3000) -- Update every 3 seconds

      if self.hud_enabled and self.hud_settings.hud_enabled and self.hud_settings.hud_show_stamina then
        local playerPed = GetPlayerPed(-1)
        if DoesEntityExist(playerPed) then
          -- Get player's maximum stamina and set current stamina to match
          local maxStamina = GetPlayerMaxStamina(PlayerId())
          SetPlayerStamina(PlayerId(), maxStamina)
        end
      end
    end
  end)

  -- Fallback mechanism: refresh HUD after 5 seconds if no data received
  Citizen.CreateThread(function()
    Citizen.Wait(5000) -- Wait 5 seconds after initialization

    if self.hud_enabled and self.hud_settings.hud_enabled then
      self:refreshHUD()
    end
  end)
end

-- Check for updates and only update HUD when values change
function HUD:checkForUpdates()
  local needs_update = false
  local update_data = {}

  -- Check health
  if self.hud_settings.hud_show_health then
    local current_health = GetEntityHealth(GetPlayerPed(-1))
    if math.abs(current_health - self.player_data.health) > 2 then -- Allow small variance
      update_data.health = current_health
      needs_update = true
    end
  end

  -- Check armor
  if self.hud_settings.hud_show_armor then
    local current_armor = GetPedArmour(GetPlayerPed(-1))
    if math.abs(current_armor - self.player_data.armor) > 2 then -- Allow small variance
      update_data.armor = current_armor
      needs_update = true
    end
  end

  -- Check stamina (real detection - no threshold)
  if self.hud_settings.hud_show_stamina then
    local current_stamina = self:getPlayerStamina()
    update_data.stamina = current_stamina
    needs_update = true
  end

  if needs_update then
    self:updatePlayerData(update_data)
    self:updateHUD()
  end
end

-- Update HUD display (real-time updates)
function HUD:updateHUD()
  -- Create a single HUD container with all elements
  if self.hud_settings.hud_enabled then
    self:createHUDContainer()
  else
    vRP.EXT.GUI:removeDiv("hud_container")
  end
end

function HUD:createHUDContainer()
  local elements = {}

  -- Build elements in correct order based on settings
  if self.hud_settings.hud_show_health and self.hud_settings.hud_enabled then
    local health = tonumber(self.player_data.health) or 100
    local health_percent = math.max(0, math.min(100, health)) / 100
    table.insert(elements, self:createHUDElement("health", "Health: " .. math.floor(health), "rgba(255, 0, 0, 0.9)", math.floor(health_percent * 100)))
  end

  if self.hud_settings.hud_show_armor and self.hud_settings.hud_enabled then
    local armor = tonumber(self.player_data.armor) or 0
    local armor_percent = math.max(0, math.min(100, armor)) / 100
    table.insert(elements, self:createHUDElement("armor", "Armor: " .. math.floor(armor), "rgba(0, 0, 255, 0.9)", math.floor(armor_percent * 100)))
  end

  if self.hud_settings.hud_show_hunger and self.hud_settings.hud_enabled then
    local hunger = tonumber(self.player_data.hunger) or 1.0
    local hunger_percent = math.max(0, math.min(1, hunger))
    table.insert(elements, self:createHUDElement("hunger", "Hunger: " .. math.floor(hunger_percent * 100) .. "%", "rgba(255, 165, 0, 0.9)", math.floor(hunger_percent * 100)))
  end

  if self.hud_settings.hud_show_thirst and self.hud_settings.hud_enabled then
    local thirst = tonumber(self.player_data.thirst) or 1.0
    local thirst_percent = math.max(0, math.min(1, thirst))
    table.insert(elements, self:createHUDElement("thirst", "Thirst: " .. math.floor(thirst_percent * 100) .. "%", "rgba(0, 191, 255, 0.9)", math.floor(thirst_percent * 100)))
  end

  if self.hud_settings.hud_show_stamina and self.hud_settings.hud_enabled then
    local stamina = tonumber(self.player_data.stamina) or 100
    local stamina_percent = math.max(0, math.min(100, stamina)) / 100
    table.insert(elements, self:createHUDElement("stamina", "Stamina: " .. math.floor(stamina) .. "%", "rgba(0, 255, 0, 0.9)", math.floor(stamina_percent * 100)))
  end

  -- Create container HTML
  local hud_html = string.format([[
    <div id="hud-container" style="
      position: fixed;
      bottom: 10px;
      right: 20px;
      z-index: 1000;
      font-family: 'Montserrat', sans-serif;
    ">
      %s
    </div>
  ]], table.concat(elements, ""))

  vRP.EXT.GUI:setDiv("hud_container", "", hud_html)
end

function HUD:createHUDElement(element, text, bar_color, bar_width)
  return string.format([[
    <div class="hud-element hud-%s" style="
      width: 180px;
      height: 20px;
      background-color: rgba(0, 0, 0, 0.8);
      border-left: 4px solid %s;
      border-radius: 3px;
      margin-bottom: 5px;
      display: flex;
      align-items: center;
      padding: 0 8px;
      box-sizing: border-box;
      color: white;
      font-size: 11px;
      font-weight: bold;
      text-shadow: 1px 1px black;
      position: relative;
    ">
      <div style="
        height: 100%%;
        background-color: %s;
        width: %d%%;
        position: absolute;
        left: 0;
        top: 0;
        border-radius: 2px;
        opacity: 0.8;
      "></div>
      <div style="
        position: relative;
        z-index: 2;
        width: 100%%;
        text-align: center;
      ">%s</div>
    </div>
  ]], element, bar_color, bar_color, bar_width, text)
end

-- Update player data
function HUD:updatePlayerData(data)
  for k, v in pairs(data) do
    self.player_data[k] = tonumber(v) or v
  end
end

-- Set HUD enabled/disabled
function HUD:setHUDEnabled(enabled)
  self.hud_enabled = enabled

  if not enabled then
    -- Remove HUD container
    vRP.EXT.GUI:removeDiv("hud_container")
  else
    -- Re-enable HUD - force immediate update
    self:updateHUD()
  end
end

-- Update HUD settings
function HUD:updateHUDSettings(settings)
  -- Store old enabled state
  local was_enabled = self.hud_settings.hud_enabled

  self.hud_settings = settings

  -- Update individual settings with defaults if not provided
  if settings.hud_show_health == nil then settings.hud_show_health = true end
  if settings.hud_show_armor == nil then settings.hud_show_armor = true end
  if settings.hud_show_hunger == nil then settings.hud_show_hunger = true end
  if settings.hud_show_thirst == nil then settings.hud_show_thirst = true end
  if settings.hud_show_stamina == nil then settings.hud_show_stamina = false end

  -- Handle HUD enabled/disabled state changes
  if not settings.hud_enabled then
    self:setHUDEnabled(false)
  elseif not was_enabled and settings.hud_enabled then
    self:setHUDEnabled(true)
  elseif settings.hud_enabled then
    self:updateHUD()
  end
end

-- Update individual HUD element value
function HUD:updateHUDElement(element, value, percent, text)
  if not self.hud_enabled or not self.hud_settings.hud_enabled then return end

  local div_name = "hud_" .. element

  -- Create complete HTML structure with CSS and JS
  local html_content = string.format([[
    <div class="hud-element hud-%s" style="
      position: fixed;
      bottom: %s;
      right: 20px;
      width: 180px;
      height: 20px;
      background-color: rgba(0, 0, 0, 0.8);
      border-radius: 3px;
      font-family: 'Montserrat', sans-serif;
      font-size: 12px;
      font-weight: bold;
      color: white;
      text-shadow: 1px 1px black;
      z-index: 1000;
      display: flex;
      align-items: center;
      padding: 0 8px;
      box-sizing: border-box;
    ">
      <div class="hud-bar hud-%s-bar" style="
        height: 100%%;
        background-color: %s;
        width: %d%%;
        transition: width 0.3s ease;
        border-radius: 2px;
        position: absolute;
        left: 0;
        top: 0;
      "></div>
      <div class="hud-text" style="
        position: relative;
        z-index: 2;
        width: 100%%;
        text-align: center;
      ">%s</div>
    </div>
  ]],
    element,
    self:getElementPosition(element),
    element,
    self:getElementColor(element),
    math.floor(percent * 100),
    text
  )

  vRP.EXT.GUI:setDiv(div_name, "", html_content)
end

function HUD:getElementPosition(element)
  local positions = {
    health = "130px",
    armor = "105px",
    hunger = "80px",
    thirst = "55px",
    stamina = "30px"
  }
  return positions[element] or "80px"
end

function HUD:getElementColor(element)
  local colors = {
    health = "rgba(255, 0, 0, 0.9)",
    armor = "rgba(0, 0, 255, 0.9)",
    hunger = "rgba(255, 165, 0, 0.9)",
    thirst = "rgba(0, 191, 255, 0.9)",
    stamina = "rgba(0, 255, 0, 0.9)"
  }
  return colors[element] or "rgba(255, 255, 255, 0.9)"
end

-- Get player's current stamina level (0-100)
function HUD:getPlayerStamina()
  local playerPed = GetPlayerPed(-1)

  -- Check if player ped exists
  if not DoesEntityExist(playerPed) then
    return 100
  end

  -- Independent stamina tracking system (ignores game's stamina)
  local currentTime = GetGameTimer()

  -- Initialize stamina tracking if not exists
  if not self.staminaData then
    self.staminaData = {
      currentStamina = 100,
      lastUpdate = currentTime
    }
  end

  -- Calculate time elapsed since last update
  local deltaTime = currentTime - self.staminaData.lastUpdate
  local deltaSeconds = deltaTime / 1000.0

  -- Check if player is trying to sprint (independent of game's stamina)
  local isTryingToSprint = IsControlPressed(0, 21) -- Left Shift key

  -- Update stamina based on sprint attempts
  if isTryingToSprint and self.staminaData.currentStamina > 0 then
    -- Random stamina drain between 2.5% to 5% per second when sprinting
    local randomDrain = math.random(25, 50) / 10.0 -- Random between 2.5-5.0
    self.staminaData.currentStamina = self.staminaData.currentStamina - (randomDrain * deltaSeconds)

    -- If stamina hits zero, force player out of sprint
    if self.staminaData.currentStamina <= 0 then
      self.staminaData.currentStamina = 0
      SetPedMaxMoveBlendRatio(playerPed, 1.0) -- Force walk speed
    end

    if self.debug_mode then
      print(string.format("[HUD DEBUG] Sprinting - Drain: %.2f%%/sec, Stamina: %.1f%%",
        randomDrain, self.staminaData.currentStamina))
    end
  else
    -- Regenerate stamina while not sprinting (1.5% per second)
    self.staminaData.currentStamina = self.staminaData.currentStamina + (1.5 * deltaSeconds)

    -- Allow normal sprint speed when stamina is above 10%
    if self.staminaData.currentStamina > 10 then
      SetPedMaxMoveBlendRatio(playerPed, 2.6) -- Allow sprint speed
    end
  end

  -- Clamp stamina between 0 and 100
  self.staminaData.currentStamina = math.max(0, math.min(100, self.staminaData.currentStamina))

  -- Update last update time
  self.staminaData.lastUpdate = currentTime

  -- Debug output disabled to prevent console spam
  -- if self.debug_mode then
  --   print(string.format("[HUD DEBUG] Trying to Sprint: %s, Stamina: %.1f%%",
  --     tostring(isTryingToSprint), self.staminaData.currentStamina))
  -- end

  return self.staminaData.currentStamina
end

-- Force refresh HUD display (fallback function)
function HUD:refreshHUD()
  -- Ensure we have valid data
  if not self.player_data.health then self.player_data.health = 100 end
  if not self.player_data.armor then self.player_data.armor = 0 end
  if not self.player_data.hunger then self.player_data.hunger = 1.0 end
  if not self.player_data.thirst then self.player_data.thirst = 1.0 end
  if not self.player_data.stamina then self.player_data.stamina = 100 end

  self:updateHUD()
end

-- EVENT

HUD.event = {}

function HUD.event:NUIReady()
  if self.hud_settings.hud_enabled then
    self:updateHUD()
  end
end

-- TUNNEL

HUD.tunnel = {}

HUD.tunnel.updatePlayerData = HUD.updatePlayerData
HUD.tunnel.setHUDEnabled = HUD.setHUDEnabled
HUD.tunnel.updateHUDSettings = HUD.updateHUDSettings
HUD.tunnel.refreshHUD = HUD.refreshHUD

vRP:registerExtension(HUD)