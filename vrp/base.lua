-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

-- Init vRP server context
Proxy = module("lib/Proxy")
Tunnel = module("lib/Tunnel")

local htmlEntities = module("vrp", "lib/htmlEntities")

local cvRP = module("vrp", "vRP")
vRP = cvRP() -- Instantiate vRP

local pvRP = {}
-- Load script in vRP context
pvRP.loadScript = module
Proxy.addInterface("vRP", pvRP)

-- Queries
vRP:prepare("vRP/base_tables", [[
  -- Your base table creation queries go here
]])

-- Add other queries here...

-- Initialize tables
async(function()
  vRP:execute("vRP/base_tables")
end)

-- Handlers

AddEventHandler("playerDropped", function(reason)
  vRP:onPlayerDropped(source, reason)
end)

RegisterServerEvent("vRPcli:playerSpawned")
AddEventHandler("vRPcli:playerSpawned", function()
  vRP:onPlayerSpawned(source)
end)

RegisterServerEvent("vRPcli:playerDied")
AddEventHandler("vRPcli:playerDied", function()
  vRP:onPlayerDied(source)
end)

local lang = vRP.lang

-- Base extension
local Base = class("Base", vRP.Extension)

-- Event

Base.event = {}

function Base.event:extensionLoad(ext)
  if ext == vRP.EXT.GUI then
    -- Add your extension load logic for GUI here
  elseif ext == vRP.EXT.Group then
    -- Register fperm inside
    vRP.EXT.Group:registerPermissionFunction("inside", function(user, params)
      return self.remote.isInside(user.source)
    end)
  end
end

function Base.event:characterLoad(user)
  self.remote._setCharacterId(user.source, user.cid)
end

function Base.event:playerSpawn(user, first_spawn)
  if first_spawn then
    self.remote._setUserId(user.source, user.id)
    self.remote._setCharacterId(user.source, user.cid)

    -- Notify last login
    if user.last_login then
      SetTimeout(15000, function()
        self.remote._notify(user.source, lang.common.welcome({ user.last_login }))
      end)
    end
  end
end

vRP:registerExtension(Base)
