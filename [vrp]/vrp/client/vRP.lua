-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

local vRPShared = module("vrp", "vRPShared")
local moduals = {"vrp_oxmysql"}

-- Client vRP
local vRP = class("vRP", vRPShared)

function vRP:__construct()
  vRPShared.__construct(self)

  -- load config
  self.cfg = module("vrp", "cfg/client")
	
	if self.cfg.loading then
		DoScreenFadeOut(0)
	end

	AddEventHandler('onResourceStart', function(resourceName)
		if GetCurrentResourceName() == 'vrp' then
			TriggerServerEvent("vRP:init")
			TriggerServerEvent("vRPcli:playerSpawned")
		end
	end)
end

return vRP
