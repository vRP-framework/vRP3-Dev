-- This file is never declared as a server_script in fxmanifest.lua -- see
-- vrp_template/server.lua for the full explanation. Short version:
-- @vrp/lib/init.lua (the only real server_script here) tells vRP core to
-- load and run this file inside vRP core's own Lua environment, so vRP,
-- class, module, etc. are already global below with no requires.

local LoadScreen = class("LoadScreen", vRP.Extension)
LoadScreen.event = {}
LoadScreen.tunnel = {}

function LoadScreen:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("vrp_loadscreen", "cfg/cfg")
end

-- Gated on vRP's own character-ready signal, not FiveM's native
-- playerSpawned (which only means the ped exists) -- avoids dropping the
-- loading screen before vRP's own data has actually finished loading.
function LoadScreen.event:playerSpawn(user, first_spawn)
  if first_spawn and user:isReady() then
    SetTimeout(self.cfg.close_delay, function()
      self.remote._close(user.source)
    end)
  end
end

function LoadScreen:getPlayerCount()
  return { count = GetNumPlayerIndices(), max = GetConvarInt('sv_maxclients', 48) }
end
LoadScreen.tunnel.getPlayerCount = LoadScreen.getPlayerCount

vRP:registerExtension(LoadScreen)
