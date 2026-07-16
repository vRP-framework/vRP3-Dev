local Fire = class("Fire", vRP.Extension)
local cfg = module("vrp_dispatch", "cfg/fire")

function Fire:__construct()
	vRP.Extension.__construct(self)
end

function Fire:init(user)
  local enter = function(player, area)
    print("Entered Fire area")
  end

  local leave = function(player, area)
    print("Left Fire area")
  end
  -- register markers
  vRP.EXT.Dispatch:registerMarker(user, cfg.pos, cfg.marker, {
    prefix = "Fire",
    enter = enter,
    leave = leave
  })
end

function Fire:onDispatchEvent(event, data)
  if event == "VEHICLE_CRASH" then
    self:handleCrash(data)

  elseif event == "AI_REQUEST_FIRE" then
    print(("[vrp_dispatch][Fire] AI Fire requested: %d unit(s)"):format(data.count or 0))
  end
end

function Fire:handleCrash(data)
  print("[vrp_dispatch][Fire] Responding to crash")

  if data.extra and data.extra.vehicle then
    print("[vrp_dispatch][Fire] Vehicle fire risk flagged")
  end
end

function Fire:reportStructureFireIncident(user, extra)
  return vRP.EXT.Dispatch:reportIncident("STRUCTURE_FIRE", user, extra)
end

function Fire:reportVehicleFireIncident(user, extra)
  return vRP.EXT.Dispatch:reportIncident("FIRE_VEHICLE", user, extra)
end

function Fire:reportPropertyFireIncident(user, extra)
  return vRP.EXT.Dispatch:reportIncident("FIRE_PROPERTY", user, extra)
end

-- Event handlers
Fire.event = {}
Fire.tunnel = {}

Fire.tunnel.init = Fire.init


return Fire