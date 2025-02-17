-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.weather then return end

local Weather = class("Weather", vRP.Extension)
Weather.event = {}

-- Load Configuration
Weather.cfg = module("vrp", "cfg/weather")
Weather.lastWeather = nil  -- Cache last weather to prevent redundant updates

-- Function to Fetch Real-World Weather Data
function Weather:getRealWeather()
  if not self.cfg.api.enable or not self.cfg.api.key or self.cfg.api.key == "YOUR_WEATHERAPI_KEY_HERE" then return end

  local city = self.cfg.api.default_city
  local url = string.format(self.cfg.api.api_url, self.cfg.api.key, city)

  PerformHttpRequest(url, function(code, response)
    if code ~= 200 then return end -- Exit if API call fails

    local data = json.decode(response)
    if not data or not data.current or not data.current.condition or not data.current.condition.text then return end

    local realWeather = string.lower(data.current.condition.text)
    local gameWeather = "EXTRASUNNY" -- Default fallback

    for key, gtaWeather in pairs(self.cfg.weatherMap) do
      if string.find(realWeather, key:lower()) then
        gameWeather = gtaWeather
        break
      end
    end

    -- Only update weather if it has changed
    if gameWeather ~= self.lastWeather then
      self.lastWeather = gameWeather

      -- Apply weather update to all players
      for _, user in pairs(vRP.users) do
        vRP.EXT.Weather.remote._setWeather(user.source, gameWeather)
      end
    end
  end, "GET", "", {["Content-Type"] = "application/json"})
end

-- Apply Real-World Weather When Character Loads
function Weather.event:characterLoad(user, first_spawn)
  if first_spawn and self.lastWeather then
    vRP.EXT.Weather.remote._setWeather(user.source, self.lastWeather)
  end
end

-- Auto-update Real-World Weather Every Configured Interval
Citizen.CreateThread(function()
  while true do
    Weather:getRealWeather()
    Citizen.Wait(Weather.cfg.api.update_interval) -- Uses interval from config
  end
end)

-- Register Weather Extension
function Weather:__construct()
  vRP.Extension.__construct(self)

  -- Weather Menus
  local function menu_weather(self)
    vRP.EXT.GUI:registerMenuBuilder("weather", function(menu)
      menu.title = "Weather"
      menu.css.header_color = "rgba(200,0,0,0.75)"
      menu:addOption("Forecast", function(menu) menu.user:openMenu("forcast") end)
      menu:addOption("Time", function(menu) menu.user:openMenu("time") end)
    end)
  end

  local function menu_forcast(self)
    vRP.EXT.GUI:registerMenuBuilder("forcast", function(menu)
      menu.title = "Forecast"
      menu.css.header_color = "rgba(200,0,0,0.75)"
      menu:addOption("Blackout", function(menu) self.remote._toggleBlackout(source) end)
      menu:addOption("Set Weather", function(menu)
        local weather = menu.user:prompt("Weather types: Not case Sensitive", "")
        self.remote._setWeather(source, string.upper(weather))
      end)
      menu:addOption("Types", function(menu) menu.user:openMenu("types") end)
    end)
  end

  local function menu_time(self)
    vRP.EXT.GUI:registerMenuBuilder("time", function(menu)
      menu.title = "Time"
      menu.css.header_color = "rgba(200,0,0,0.75)"
      menu:addOption("Freeze Time", function(menu) self.remote._toggleFreeze(source) end)
      menu:addOption("Set Time", function(menu)
        local timeChange = menu.user:prompt("Set Time: 24 hour format from 0 - 23", "")
        self.remote._setTime(source, timeChange)
      end)
      menu:addOption("Speed Up Time", function(menu)
        local timeChange = menu.user:prompt("Set Multiplier: recommended 2 - 6 (1 is default speed)", "")
        self.remote._speedUpTime(source, timeChange)
      end)
      menu:addOption("Slow Down Time", function(menu)
        local timeChange = menu.user:prompt("Set Divider: recommended 2 - 6. (1 is default speed)", "")
        self.remote._slowTime(source, timeChange)
      end)
      menu:addOption("Time of Day", function(menu) menu.user:openMenu("timeOfDay") end)
    end)
  end

  -- Admin Menu
  vRP.EXT.GUI:registerMenuBuilder("admin", function(menu)
    menu:addOption("Weather", function(menu) menu.user:openMenu("weather") end)
  end)

  -- Initialize menus
  menu_weather(self)
  menu_forcast(self)
  menu_time(self)

  -- Log real-world weather when the resource starts
  self:getRealWeather()
end

vRP:registerExtension(Weather)
