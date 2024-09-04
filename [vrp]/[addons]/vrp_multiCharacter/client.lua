-- init vRP server context
Tunnel = module("vrp", "lib/Tunnel")
Proxy = module("vrp", "lib/Proxy")

local cvRP = module("vrp", "client/vRP")
vRP = cvRP()

local pvRP = {}
-- load script in vRP context
pvRP.loadScript = module
Proxy.addInterface("vRP", pvRP)

local cfg = module("vrp_multiCharacter", "cfg/multiCharacter")
local Multi = class("Multi_Character", vRP.Extension)

function Multi:__construct()
  vRP.Extension.__construct(self)
end 

Multi.event = {}

function Multi:close()
  SetNuiFocus(false, false)
  DoScreenFadeOut(10)

  Citizen.Wait(1000)

  --FreezeEntityPosition(PlayerPedId(), true)
  --SetEntityCoords(PlayerPedId(), Config.HiddenCoords.x, Config.HiddenCoords.y, Config.HiddenCoords.z)
  
  Citizen.Wait(1000)

  ShutdownLoadingScreen()
  ShutdownLoadingScreenNui()

  DoScreenFadeIn(500) --temp

  self.remote.getCharacters(source)
end

-- Callbacks
RegisterNUICallback("close", function(data, cb)
  Multi:close()
  cb("ok")
end)

RegisterNUICallback("createNewCharacter", function(data, cb)
  local firstname, name, age = data  
  vRP.EXT.Identity.remote.newIdentity(user,firstname, name, age, data.cid)
  cb("ok")
end)

RegisterNUICallback("selectCharacter", function(data, cb)
  local user = vRP.users_by_source[source]
  user:useCharacter(data.cid)
  cb("ok")
end)

RegisterNUICallback("removeCharacter", function(data, cb)
  local user = vRP.users_by_source[source]
  user:deleteCharacter(data.cid)
  cb("ok")
end)

Multi.tunnel = {}

Multi.tunnel.close = Multi.close

vRP:registerExtension(Multi)