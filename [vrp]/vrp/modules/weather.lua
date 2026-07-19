-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)
if not vRP.modules.weather then return end

local Weather = class("Weather", vRP.Extension)
Weather.event = {}

-- localize globals for hot paths
local pairs = pairs
local ipairs = ipairs
local table_insert = table.insert
local table_sort = table.sort
local string_upper = string.upper

local function menu_types(self)

  vRP.EXT.GUI:registerMenuBuilder(self, "types", function(menu)
		local user = menu.user
		if not user:hasPermission("admin.weather") then return end
		local remote = self.remote
		menu.title = "Forcast Types"
		menu.css.header_color = "rgba(200,0,0,0.75)"

		for _,v in pairs(self.cfg.types) do
			menu:addOption(v, function(menu)
				remote._setWeather(user.source, v)
			end)
		end
  end)
end

local function menu_forcast(self)
  vRP.EXT.GUI:registerMenuBuilder(self, "forcast", function(menu)
		local user = menu.user
		if not user:hasPermission("admin.weather") then return end
		local remote = self.remote
		menu.title = "Forcast"
		menu.css.header_color = "rgba(200,0,0,0.75)"

		menu:addOption("Blackout", function(menu)
			remote._toggleBlackout(user.source)
		end)

		menu:addOption("Set Weather", function(menu)
			local weather = user:prompt("Weather types: Not case Sensitive", "")
			remote._setWeather(user.source, string.upper(weather))
		end)

		menu:addOption("Types", function(menu)
			menu.user:openMenu("types")
		end)
  end)
end

local function menu_timeOfDay(self)
  vRP.EXT.GUI:registerMenuBuilder(self, "timeOfDay", function(menu)
		local user = menu.user
		if not user:hasPermission("admin.weather") then return end
		local remote = self.remote
		menu.title = "Time of Day"
		menu.css.header_color = "rgba(200,0,0,0.75)"

		for i=1, #self.times do
			local name, hour = self.times[i][1], self.times[i][2]    -- time of day name, hour
			menu:addOption(name, function(menu)
				remote._setTime(user.source, hour)
			end)
		end
  end)
end

local function menu_time(self)

  vRP.EXT.GUI:registerMenuBuilder(self, "time", function(menu)
		local user = menu.user
		if not user:hasPermission("admin.weather") then return end
		local remote = self.remote
		menu.title = "Time"
		menu.css.header_color = "rgba(200,0,0,0.75)"

		menu:addOption("Freeze Time", function(menu)
			remote._toggleFreeze(user.source)
		end)

		menu:addOption("Set Time", function(menu)
			local timeChange = user:prompt("Set Time: 24 hour format from 0 - 23", "")
			remote._setTime(user.source, timeChange)
		end)

		menu:addOption("Speed Up Time", function(menu)
			local timeChange = user:prompt("Set Multiplyer: recomended 2 - 6 (1 is default speed)", "")
			remote._speedUpTime(user.source, timeChange)
		end)

		menu:addOption("Slow Down Time", function(menu)
			local timeChange = user:prompt("Set Divider: recomended 2 - 6. (1 is default speed)", "")
			remote._slowTime(user.source, timeChange)
		end)

		menu:addOption("Time of Day", function(menu)
			menu.user:openMenu("timeOfDay")
		end)
  end)
end

local function menu_weather(self)

  vRP.EXT.GUI:registerMenuBuilder(self, "weather", function(menu)
		local user = menu.user
		if not user:hasPermission("admin.weather") then return end
		menu.title = "Weather"
		menu.css.header_color = "rgba(200,0,0,0.75)"
		
		menu:addOption("Forcast", function(menu)
			menu.user:openMenu("forcast")
		end)
		
		menu:addOption("Time", function(menu)
			menu.user:openMenu("time")
		end)
  end)
end

function Weather:__construct()
  vRP.Extension.__construct(self)
  
  self.cfg = module("vrp", "cfg/weather")
  
  self.types = {}
  self.times = {}
	
  --menu
  menu_weather(self)
  menu_forcast(self)
  menu_types(self)
  menu_time(self)
  menu_timeOfDay(self)
	
  -- main menu
  vRP.EXT.GUI:registerMenuBuilder(self, "admin", function(menu)
		if not menu.user:hasPermission("admin.weather") then return end
		menu:addOption("Weather", function(menu)
			menu.user:openMenu("weather")
		end)
  end)
  
  -- Sort weather types and times on initialization
	-- build and sort types with precomputed uppercase keys to avoid heavy comparators
	local types_tmp = {}
	for _,v in pairs(self.cfg.types) do table_insert(types_tmp, { orig = v, key = string_upper(v) }) end
	table_sort(types_tmp, function(a, b) return a.key < b.key end)
	for _,t in ipairs(types_tmp) do table_insert(self.types, t.orig) end

	for k,v in pairs(self.cfg.time) do table_insert(self.times, {k, v}) end

	table_sort(self.times, function(a, b) return a[2] < b[2] end)
end

function Weather.event:playerSpawn(user, first_spawn)
  if first_spawn then
		self.remote._sync(user.source)
  end
end

vRP:registerExtension(Weather)