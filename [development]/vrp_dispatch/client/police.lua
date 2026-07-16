Tunnel = module("vrp", "lib/Tunnel")
Proxy = module("vrp", "lib/Proxy")

local cvRP = module("vrp", "client/vRP")
vRP = cvRP() -- instantiate vRP

local pvRP = {}
-- load script in vRP context
function pvRP.loadScript(resource, path)
  module(resource, path)
end

Proxy.addInterface("vRP", pvRP)

local Police = class("Police", vRP.Extension)
local cfg = module("vrp_dispatch", "cfg/police")

function Police:__construct()
  vRP.Extension.__construct(self)

  self.lastShotReport = 0
  self.lastFightReport = 0

  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(250)
      self:detectShooting()
      self:detectFight()
    end
  end)
end

function Police:handleArrest(ped, targetSource, vehicle)
  local user = vRP.users_by_source[targetSource]
  if not user then return end

  -- Face + approach
  local playerPed = GetPlayerPed(targetSource)

  TaskTurnPedToFaceEntity(ped, playerPed, 2000)
  Wait(2000)

  TaskGoToEntity(ped, playerPed, -1, 2.0, 2.0, 0, 0)
  Wait(3000)

  TaskStartScenarioInPlace(ped, "WORLD_HUMAN_COP_IDLES", 0, true)
  Wait(4000)

  -- ✅ CLIENT ACTIONS (via tunnel)
  self.remote.cuffPlayer(targetSource)

  Wait(2000)

  self.remote.putInVehicle(targetSource, VehToNet(vehicle))

  Wait(15000)

  self.remote.jailPlayer(targetSource)

  DeleteEntity(ped)
  DeleteEntity(vehicle)

  self.releaseUnit("police")
end

function Police:detectShooting()
  local ped = PlayerPedId()
  if not DoesEntityExist(ped) then return end

  if IsPedShooting(ped) then
    local now = GetGameTimer()

    -- simple cooldown to stop spam
    if now - self.lastShotReport < 10000 then
      return
    end

    self.lastShotReport = now

    local coords = GetEntityCoords(ped)
    local weapon = GetSelectedPedWeapon(ped)

    -- Call server police module
    self.remote.reportShootingIncident({
      weapon = weapon,
      coords = {
        x = coords.x,
        y = coords.y,
        z = coords.z
      }
    })
  end
end

function Police:detectFight()
  local ped = PlayerPedId()
  if not DoesEntityExist(ped) then return end

  if IsPedInMeleeCombat(ped) then
    local now = GetGameTimer()

    -- simple cooldown to stop spam
    if now - self.lastFightReport < 15000 then
      return
    end

    self.lastFightReport = now

    local coords = GetEntityCoords(ped)

    self.remote.reportFightIncident()
  end
end

-- Tunnel interface
Police.tunnel = {}

vRP:registerExtension(Police)