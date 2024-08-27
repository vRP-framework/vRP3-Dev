-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)
if not vRP.modules.weather then return end

local Weather = class("Weather", vRP.Extension)

-- METHODS

function Weather:__construct()
  vRP.Extension.__construct(self)
  
  self.current = 'CLEAR'
  self.freeze = false
  self.blackout = false
  
  self.time = 0
  self.offset = 0
  
  self.timer = 0
  
  self.normal = 2000 -- normal ms per minute
  self.alteredTime = self.normal
  self.speedTime = 1
  self.slowTime = 1
end

function Weather:sync()
  self.remote._setWeather(self.current)
  SetMillisecondsPerGameMinute(self.alteredTime)
end

function Weather:setWeather(weather)
  self.current = string.upper(weather or 'CLEAR')
  ClearOverrideWeather()
  ClearWeatherTypePersist()
  SetWeatherTypePersist(self.current)
  SetWeatherTypeNow(self.current)
  SetWeatherTypeNowPersist(self.current)
end

function Weather:setHour(hour)
  local currentHour = (self.time + self.offset) / 60 % 24
  self.offset = self.offset - (currentHour - tonumber(hour)) * 60
end

function Weather:setTime(hour)
  self:setHour(hour or 12)
  
  if GetGameTimer() - 500 > self.timer then
    self.time = self.time + 0.25
    self.timer = GetGameTimer()
  end
  
  local hour = math.floor((self.time + self.offset) / 60 % 24)
  local minute = math.floor((self.time + self.offset) % 60)
  
  NetworkOverrideClockTime(hour, minute, 0)
end

function Weather:adjustTimeSpeed(multiplier)
  local newTime = math.floor(self.normal * multiplier)
  SetMillisecondsPerGameMinute(newTime)
  self.alteredTime = newTime
end

function Weather:speedUpTime(inc)
  self:adjustTimeSpeed(1 / (inc or self.speedTime))
end

function Weather:slowTime(dec)
  self:adjustTimeSpeed(dec or self.slowTime)
end

function Weather:toggleFreeze()
  self.freeze = not self.freeze
  SetMillisecondsPerGameMinute(self.normal)
  
  if self.freeze then
    local hours, minutes, seconds = GetClockHours(), GetClockMinutes(), GetClockSeconds()
    NetworkOverrideClockTime(hours, minutes, seconds)
  else
    self:sync()
  end
end

function Weather:toggleBlackout()
  self.blackout = not self.blackout
  SetArtificialLightsState(self.blackout)
end

-- TUNNEL

Weather.tunnel = {}
Weather.tunnel.sync = Weather.sync
Weather.tunnel.setWeather = Weather.setWeather
Weather.tunnel.setTime = Weather.setTime
Weather.tunnel.toggleFreeze = Weather.toggleFreeze
Weather.tunnel.toggleBlackout = Weather.toggleBlackout
Weather.tunnel.speedUpTime = Weather.speedUpTime
Weather.tunnel.slowTime = Weather.slowTime

vRP:registerExtension(Weather)