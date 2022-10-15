-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.weapon then return end

local Weapon = class("Weapon", vRP.Extension)
-- METHODS

function Weapon:__construct()
  vRP.Extension.__construct(self)

  self.weapon = {}  -- map of weapon ids
end

-- get player weapons
-- return map of name => {.ammo}
function Weapon:getWeapons()
  local player = GetPlayerPed(-1)
  local ammo_types = {} -- remember ammo type to not duplicate ammo amount

  local weapons = {}
  for k,v in pairs(self.weapon) do
    local hash = GetHashKey(k)
    if HasPedGotWeapon(player,hash) then
      local weapon = {}
      weapons[k] = weapon

      local atype = Citizen.InvokeNative(0x7FEAD38B326B9F74, player, hash)
      if ammo_types[atype] == nil then
        ammo_types[atype] = true
        weapon.ammo = GetAmmoInPedWeapon(player,hash)
      else
        weapon.ammo = 0
      end
    end
  end

  return weapons
end

-- get weapons components
function Weapon:getComponents()
  local player = GetPlayerPed(-1)

  local components = {}
  for w,v in pairs(self.weapon) do
    local hash = GetHashKey(w)
    local n,c = table.unpack(v)
    if HasPedGotWeapon(player,hash) then
      for k, v in pairs(c) do
        local h,n,d,e = v.HashKey, v.Name, v.Description, v.Enabled
        if e then
          local c_hash = GetHashKey(h)
          if HasPedGotWeaponComponent(player, hash, c_hash) then
            table.insert(components, {[w] = {h}})
          else
            table.insert(components, {[w] = nil})
          end
        end
      end
    end
  end

  return components
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
    GiveWeaponToPed(ped, hash, 20, false)
    return vRP.EXT.Base:notify("You recieved a " .. name .. "")
  end
  vRP.EXT.Base:notify("You already own this weapon")
end

-- weapons: map of name => {.ammo}
--- ammo: (optional)
function Weapon:giveComponents(components, clear_before)
  local player = GetPlayerPed(-1)

  for k,v in pairs(components) do
    for weapon,v in pairs(v) do
      for k,component in pairs(v) do
        local hash = GetHashKey(weapon)
        local c_hash = GetHashKey(component)
        if HasPedGotWeapon(player,hash,false) then
          if not HasPedGotWeaponComponent(player, hash, c_hash) then
            GiveWeaponComponentToPed(player, hash, c_hash)
          end
        end
      end
    end
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
      return
    end

    return vRP.EXT.Base:notify("You already have this component")
  end

  vRP.EXT.Base:notify("You dont own this weapon")
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
      return vRP.EXT.Base:notify("You have ".. newAmmo .." rounds total for your weapon")
    end
      return vRP.EXT.Base:notify("You already have max ammo")
  end
  
  vRP.EXT.Base:notify("You dont own this weapon")
end

-- initialize weapon table
function Weapon:init(data)
  for k,v in pairs(data) do
    local n,d,g,p,c = table.unpack(v)
    self.weapon[k] = {n, c}
  end
end

-- TUNNEL
Weapon.tunnel = {}

Weapon.tunnel.init = Weapon.init
Weapon.tunnel.giveAmmo = Weapon.giveAmmo
Weapon.tunnel.getWeapons = Weapon.getWeapons
Weapon.tunnel.getComponents = Weapon.getComponents
Weapon.tunnel.replaceWeapons = Weapon.replaceWeapons
Weapon.tunnel.giveWeapons = Weapon.giveWeapons
Weapon.tunnel.giveWeapon = Weapon.giveWeapon
Weapon.tunnel.giveComponent = Weapon.giveComponent
Weapon.tunnel.giveComponents = Weapon.giveComponents

vRP:registerExtension(Weapon)
