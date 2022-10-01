-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.weapon then return end

local Weapon = class("Weapon", vRP.Extension)
-- METHODS

function Weapon:__construct()
  vRP.Extension.__construct(self)

  self.weapon = {}  -- map of weapon ids
  self.state_ready = false
  self.update_interval = 30
  self.mp_models = {} -- map of model hash

  -- update task
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(self.update_interval * 1000)

      if self.state_ready then
        local x, y, z = vRP.EXT.Base:getPosition()
        print("test")
        self.remote._update({
          weapons = self:getWeapons()
        })
      end
    end
  end)
end

-- WEAPONS

-- get player weapons
-- return map of name => {.ammo}
function Weapon:getWeapons()
  local player = GetPlayerPed(-1)

  local ammo_types = {} -- remember ammo type to not duplicate ammo amount

  local weapons = {}
  for k, v in pairs(self.weapon) do
    if v then
      local hash = GetHashKey(v)
      if HasPedGotWeapon(player, hash) then
        local weapon = {}
        weapons[v] = weapon

        local atype = Citizen.InvokeNative(0x7FEAD38B326B9F74, player, hash)
        if ammo_types[atype] == nil then
          ammo_types[atype] = true
          weapon.ammo = GetAmmoInPedWeapon(player, hash)
        else
          weapon.ammo = 0
        end
      end
    end
  end

  return weapons
end

-- replace weapons (combination of getWeapons and giveWeapons)
-- weapons: map of name => {.ammo}
--- ammo: (optional)
-- return previous weapons
function Weapon:replaceWeapons(weapons)
  local old_weapons = self:getWeapons()
  self:giveWeapons(weapons, true)
  return old_weapons
end

-- weapons: map of name => {.ammo}
--- ammo: (optional)
function Weapon:giveWeapons(weapons, clear_before)
  local player = GetPlayerPed(-1)

  -- give weapons to player
  if clear_before then
    RemoveAllPedWeapons(player, true)
  end

  for k, weapon in pairs(weapons) do
    local hash = GetHashKey(k)
    local ammo = weapon.ammo or 0

    GiveWeaponToPed(player, hash, ammo, false)
  end
end

-- give specific weapon to player
function Weapon:giveWeapon(player, weapon, name)
  local playerIdx = GetPlayerFromServerId(player)
  local ped = GetPlayerPed(playerIdx)
  local hash = GetHashKey(weapon)

  -- give a weapon to player
  if not HasPedGotWeapon(ped,hash,false) then
    GiveWeaponToPed(ped, hash, 999, false)
    vRP.EXT.Base:notify("You recieved a " .. name .. "")
  else
    vRP.EXT.Base:notify("You already own this weapon")
  end
end

-- give specific weapon to player
function Weapon:giveComponent(player, weapon, component, clear_before)
  local playerIdx = GetPlayerFromServerId(player)
  local ped = GetPlayerPed(playerIdx)

  local weapon_hash = GetHashKey(weapon)
  local component_hash = GetHashKey(component)

  -- give a weapon to player
  if HasPedGotWeapon(ped,weapon_hash,false) then
    if not HasPedGotWeaponComponent(ped, weapon_hash, component_hash) then
      GiveWeaponComponentToPed(ped, weapon_hash, component_hash)
    else
      vRP.EXT.Base:notify("You already own this component")
    end
  else
    vRP.EXT.Base:notify("You dont own this weapon")
  end
end

-- give specific weapon to player
function Weapon:giveAmmo(player, weapon, ammo, clear_before)
  local playerIdx = GetPlayerFromServerId(player)
  local ped = GetPlayerPed(playerIdx)
  local hash = GetHashKey(weapon)

  local ammoInWeapon = GetAmmoInPedWeapon(ped, hash)
  local newAmmo = ammoInWeapon + ammo
  local c, maxAmmo = GetMaxAmmo(ped, hash)

  if HasPedGotWeapon(ped,hash,false) then
    if ammoInWeapon < maxAmmo then
      SetPedAmmo(ped, hash, newAmmo)
    else
      vRP.EXT.Base:notify("You already have max ammo")
    end
  else
    vRP.EXT.Base:notify("You dont own this weapon")
  end
end

-- initialize weapon table
function Weapon:init(data)
  table.insert(self.weapon, data)
end

-- TUNNEL
Weapon.tunnel = {}

Weapon.tunnel.init = Weapon.init
Weapon.tunnel.giveAmmo = Weapon.giveAmmo
Weapon.tunnel.getWeapons = Weapon.getWeapons
Weapon.tunnel.replaceWeapons = Weapon.replaceWeapons
Weapon.tunnel.giveWeapons = Weapon.giveWeapons
Weapon.tunnel.giveWeapon = Weapon.giveWeapon
Weapon.tunnel.giveComponent = Weapon.giveComponent

vRP:registerExtension(Weapon)
