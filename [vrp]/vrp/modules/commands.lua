-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)
if not vRP.modules.command then return end

local Command = class("Command", vRP.Extension)

-- per-invocation permission check: source 0 (server console) is trusted
-- implicitly, otherwise the connected user must hold perm. Unlike the old
-- construct-time check this runs on every call, against the actual caller.
local function checkPermission(source, perm)
  if source == 0 then return true end
  local user = vRP.users_by_source[source]
  return user ~= nil and user:hasPermission(perm)
end

function Command:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("cfg/commands")

  -- location based commands
  RegisterCommand("marker", function(source, args, rawCommand)
    if not checkPermission(source, "player.tptome") then return end
    --vRP.EXT.Admin.remote._teleportToMarker(source)
  end, false)

  RegisterCommand("pos", function(source, args, rawCommand)
    if not checkPermission(source, "player.coords") then return end
    self:log(vRP.EXT.Base.remote._getPosition(source))
  end, false)

  -- player/ ai based commands
  RegisterCommand("spectate", function(source, args, rawCommand)
    if not checkPermission(source, "player.spectate") then return end
    vRP.EXT.Admin.remote._toggleSpectate(source, args[1])
    vRP.EXT.Admin.remote._toggleNoclip(source)
  end, false)

  RegisterCommand("ai", function(source, args, rawCommand)
    if not checkPermission(source, "admin.debug") then return end
    self.remote._getAI(source, args[1])
  end, false)

  -- weather/ time based commands
  RegisterCommand("setWeather", function(source, args, rawCommand)
    if not checkPermission(source, "admin.weather") then return end
    vRP.EXT.Weather.remote._setWeather(source, args[1])
  end, false)

  RegisterCommand("setTime", function(source, args, rawCommand)
    if not checkPermission(source, "admin.weather") then return end
    vRP.EXT.Weather.remote._setTime(source, args[1])
  end, false)

  RegisterCommand("freezeTime", function(source, args, rawCommand)
    if not checkPermission(source, "admin.weather") then return end
    vRP.EXT.Weather.remote._toggleFreeze(source, args[1])
  end, false)

  RegisterCommand("blackout", function(source, args, rawCommand)
    if not checkPermission(source, "admin.weather") then return end
    vRP.EXT.Weather.remote._toggleBlackout(source, args[1])
  end, false)

  RegisterCommand("speedupTime", function(source, args, rawCommand)
    if not checkPermission(source, "admin.weather") then return end
    vRP.EXT.Weather.remote._speedUpTime(source, args[1])
  end, false)

  RegisterCommand("slowTime", function(source, args, rawCommand)
    if not checkPermission(source, "admin.weather") then return end
    vRP.EXT.Weather.remote._slowTime(source, args[1])
  end, false)

  -- Weapon bassed commands
  RegisterCommand("loadout", function(source, args, rawCommand)
    if not checkPermission(source, "admin.loadout") then return end
    for k,v in pairs(self.cfg.weapons) do
      self.remote._loadout(source, v)
    end
  end, false)
end


vRP:registerExtension(Command)