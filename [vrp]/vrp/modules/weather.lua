-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)
if not vRP.modules.weather then return end

local Weather = class("Weather", vRP.Extension)
Weather.event = {}

function Weather:__construct()
  vRP.Extension.__construct(self)
  
  self.cfg = module("vrp", "cfg/weather")
end

function Weather.event:playerSpawn(user, first_spawn)
  if first_spawn then
		self.remote._sync(user.source)
  end
end

vRP:registerExtension(Weather)