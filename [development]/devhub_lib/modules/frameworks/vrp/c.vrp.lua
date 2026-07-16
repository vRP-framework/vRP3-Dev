if Shared.Framework ~= "VRP" then return end

-- Before using vRP make sure to uncomment @vrp/lib/utils.lua in fxmanifest.lua !!!
-- vRP support is currently in beta. Please report any issues you encounter, check before using in production environments.

CreateThread( function()

	AddEventHandler("vRP:playerSpawn", function(first_spawn)
		if first_spawn then -- this is true only for the first time the player spawns
			TriggerEvent("dh_lib:client:playerLoaded")
			TriggerServerEvent("dh_lib:server:playerLoaded", GetPlayerServerId(PlayerId()))
		else
			TriggerEvent("dh_lib:client:setDeathStatus", false)
		end
	end)

	RegisterNetEvent("vRP:playerDied",function()
		TriggerEvent("dh_lib:client:setDeathStatus", true)
	end)

	LoadedSystems['framework'] = true
end)