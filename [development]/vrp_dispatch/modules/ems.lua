local EMS = class("EMS", vRP.Extension)
local cfg = module("vrp_dispatch", "cfg/ems")

function EMS:__construct()
	vRP.Extension.__construct(self)

end

function EMS:init(user)
  local enter = function(player, area)
    print("Entered EMS area")
  end

  local leave = function(player, area)
    print("Left EMS area")
  end
  -- register markers
  vRP.EXT.Dispatch:registerMarker(user, cfg.pos, cfg.marker, {
    prefix = "EMS",
    enter = enter,
    leave = leave
  })
end

function EMS:onDispatchEvent(event, data)
  if event == "FOOT_INJURED" then
    self:handleInjury(data)

  elseif event == "VEHICLE_CRASH" then
    self:handleCrash(data)

  elseif event == "AI_REQUEST_EMS" then
    print(("[vrp_dispatch][EMS] AI EMS requested: %d unit(s)"):format(data.count or 0))
  end
end

function EMS:handleInjury(data)
  print("[vrp_dispatch][EMS] Responding to injured subject")

  -- Stub for future AI or assisted EMS flow
  -- Example future logic:
  -- self:treatPlayer(data.user)
  -- self:transportToHospital(data.user)

  if vRP.EXT.Dispatch.cfg.jailAfterHospital and data.user then
    vRP.EXT.Dispatch:emit("POST_HOSPITAL", data)
  end
end

function EMS:handleCrash(data)
  print("[vrp_dispatch][EMS] Responding to vehicle crash")
end

function EMS:reportOverdoseIncident(user, extra)
  return vRP.EXT.Dispatch:reportIncident("OVERDOSE", user, extra)
end

-- Event handlers
EMS.event = {}
EMS.tunnel = {}

EMS.tunnel.init = EMS.init

return EMS