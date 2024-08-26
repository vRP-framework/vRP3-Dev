-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.vehicle then return end

local lang = vRP.lang

local Vehicle = class("Vehicle", vRP.Extension)

-- STATIC
-- get vehicle trunk chest id by character id and model
function Vehicle.getVehicleChestId(cid, model)
  return "vehtrunk:"..cid.."_"..model
end

-- METHODS
function Vehicle:__construct()
  vRP.Extension.__construct(self)
	
	-- fperms

  vRP.EXT.Group:registerPermissionFunction("in_vehicle", function(user, params)
    return self.remote.isInVehicle(user.source)
  end)

  vRP.EXT.Group:registerPermissionFunction("in_owned_vehicle", function(user, params)
    local model = self.remote.getInOwnedVehicleModel(user.source)
    if model then
      if params[2] then
        return model == params[2]
      end

      return true
    end

    return false
  end)
end

-- EVENT
Vehicle.event = {}

vRP:registerExtension(Vehicle)