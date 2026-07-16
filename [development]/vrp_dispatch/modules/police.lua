local Police = class("Police", vRP.Extension)
local cfg = module("vrp_dispatch", "cfg/police")

function Police:__construct()
  vRP.Extension.__construct(self)
end

-- Event handlers
Police.event = {}

-- Tunnel interface
Police.tunnel = {}

-- Initializes police station markers for the user.
function Police:init(user)
  local enter = function(player, area)
    print("Entered Police area")
  end

  local leave = function(player, area)
    print("Left Police area")
  end

  vRP.EXT.Dispatch:registerMarker(user, cfg.pos, cfg.marker, {
    prefix = "Police",
    enter = enter,
    leave = leave
  })
end

function Police:onDispatchEvent(event, data)
  if event == "FOOT_SURRENDER" then
    self:handleSurrender(data)

  elseif event == "VEHICLE_SURRENDER" then
    self:handleVehicleArrest(data)

  elseif event == "POST_HOSPITAL" then
    self:transportToJail(data.user)

  elseif event == "AI_REQUEST_POLICE" then
    print(("[vrp_dispatch][Police] AI Police requested: %d unit(s)"):format(data.count or 0))
  end
end

function Police:handleSurrender(data)
  print("[vrp_dispatch][Police] Responding to surrender")

  if self:isJailAvailable() and data.user then
    self:transportToJail(data.user)
  end
end

function Police:handleVehicleArrest(data)
  print("[vrp_dispatch][Police] Responding to vehicle surrender")
end

function Police:isJailAvailable()
  return true
end

function Police:transportToJail(user)
  if not user then return end
  print(("[vrp_dispatch][Police] Transporting user %s to jail"):format(user.id or "unknown"))
end

-- Police-specific dispatch wrappers
function Police.tunnel:reportFightIncident(extra)
  print("[vrp_dispatch][Police] Reporting fight incident to server")
  return vRP.EXT.Dispatch:reportIncident("FIGHT", user, extra)
end

function Police.tunnel:reportTheftIncident(user, extra)
  return vRP.EXT.Dispatch:reportIncident("THEFT", user, extra)
end

function Police.tunnel:reportArmedTheftIncident(user, extra)
  return vRP.EXT.Dispatch:reportIncident("ARMED_THEFT", user, extra)
end

function Police.tunnel:reportShootingIncident(user, extra)
  return vRP.EXT.Dispatch:reportIncident("SHOOTING", user, extra)
end

Police.tunnel.init = Police.init

return Police