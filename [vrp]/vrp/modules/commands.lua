-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)
if not vRP.modules.command then return end

local Command = class("Command", vRP.Extension)

function Command:__construct()
  vRP.Extension.__construct(self)
  
  self.cfg = module("cfg/commands")
  
  local user = vRP.EXT.Group:getUsersByPermission("player.kick")

  if user then
	-- location based commands
    RegisterCommand("marker", function(source, args, rawCommand)
	  --vRP.EXT.Admin.remote._teleportToMarker(user.source)
	end, false)
	
	-- player/ ai based commands
	RegisterCommand("spectate", function(source, args, rawCommand)
	  vRP.EXT.Admin.remote._toggleSpectate(source, args[1])
	  vRP.EXT.Admin.remote._toggleNoclip(source)
	end, false)
	
	RegisterCommand("ai", function(source, args, rawCommand)
		self.remote._getAI(source, args[1])
	end, false)
	
	-- weather/ time based commands
	RegisterCommand("setWeather", function(source, args, rawCommand)
	  vRP.EXT.Weather.remote._setWeather(source, args[1])
	end, false)

	RegisterCommand("setTime", function(source, args, rawCommand)
	  vRP.EXT.Weather.remote._setTime(source, args[1])
	end, false)

	RegisterCommand("freezeTime", function(source, args, rawCommand)
	  vRP.EXT.Weather.remote._toggleFreeze(source, args[1])
	end, false)

	RegisterCommand("blackout", function(source, args, rawCommand)
	  vRP.EXT.Weather.remote._toggleBlackout(source, args[1])
	end, false)

	RegisterCommand("speedupTime", function(source, args, rawCommand)
	  vRP.EXT.Weather.remote._speedUpTime(source, args[1])
	end, false)

	RegisterCommand("slowTime", function(source, args, rawCommand)
	  vRP.EXT.Weather.remote._slowTime(source, args[1])
	end, false)
	
	-- Weapon bassed commands
	RegisterCommand("loadout", function(source, args, rawCommand)
		for k,v in pairs(self.cfg.weapons) do
			self.remote._loadout(source, v)
		end
	end, false)
	
	RegisterCommand("unregister", function(source, args, rawCommand)
		for k,v in pairs(vRP.EXT) do
			vRP:unregisterExtension(class(k, vRP.Extension))
		end
	end, false)
	
	RegisterCommand("ext", function(source, args, rawCommand)
		for k,v in pairs(vRP.EXT) do
			print(k,v)
		end
	end, false)
	
	RegisterCommand("reload", function(source, args, rawCommand)
	  stopModules()
	  restartStoredModules()
	end, false)
	
	RegisterCommand("prop", function(source, args, rawCommand)
		local nearbyObjects = vRP.EXT.Misc.remote.getClosestObjects(source, 2)
		
		if #nearbyObjects > 0 then
			for _, obj in ipairs(nearbyObjects) do
				vRP.EXT.Base.remote._notify(source, "Hash Key: " .. tostring(obj.hash) .. ", Prop Name: " .. (obj.name or "Unknown Prop"))
				
				if obj.hash == -1364697528 then
					vRP.EXT.Base.remote._notify(source,"atm nearby")
				end
			end
		end
	end, false)
  end
end


vRP:registerExtension(Command)