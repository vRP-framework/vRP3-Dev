-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.weapon then return end

local Weapon = class("Weapon", vRP.Extension)

-- Helper function to get the player's Ped
function Weapon:getPlayerPed(player)
	local playerIdx = GetPlayerFromServerId(player)
  local ped = GetPlayerPed(playerIdx)

  return ped or GetPlayerPed(-1)
end

-- METHODS

function Weapon:__construct()
  vRP.Extension.__construct(self)

  -- Initialize weapon storage with metatable for default values
  self.current = {}
  setmetatable(self.current, {
    __index = function(t, k)
      t[k] = {weaponHash = k, ammo = 0, components = {}}
      return t[k]
    end
  })
end

-- get player weapons
-- return map of name => {.ammo}
function Weapon:getWeapons()
  local weapons = {}
  
  for _, entry in pairs(self.current) do
    weapons[entry.weaponHash] = { weaponHash = entry.weaponHash, ammo = entry.ammo }
  end

  return weapons
end

-- get weapons components
function Weapon:getComponents()
  local components = {}

  for _, entry in pairs(self.current) do
    if entry.components then
      components[entry.weaponHash] = {}
      for _, component in ipairs(entry.components) do
        table.insert(components[entry.weaponHash], component)
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
function Weapon:giveWeapons(weapons, clear_before, player)
  local ped = self:getPlayerPed(player)

  if clear_before then RemoveAllPedWeapons(ped, true) end

  for _, v in pairs(weapons) do
    GiveWeaponToPed(ped, v.weaponHash, v.ammo, false)
    self.current[v.weaponHash] = self.current[v.weaponHash] or {weaponHash = v.weaponHash, ammo = v.ammo}
  end
end

-- give specific weapon to player
function Weapon:giveWeapon(weapon, player)
  local ped = self:getPlayerPed(player)
  local hash = GetHashKey(weapon)

  if not HasPedGotWeapon(ped, hash, false) then
    GiveWeaponToPed(ped, hash, 0, false, true)
    self.current[hash] = self.current[hash] or {weaponHash = hash}
  end
end

-- weapons: map of name => {.ammo}
--- ammo: (optional)
function Weapon:giveComponents(components, player)
  local ped = self:getPlayerPed(player)
  
  for weaponHash, v in pairs(components) do
    for _, component in ipairs(v) do
      if HasPedGotWeapon(ped, weaponHash, false) and not HasPedGotWeaponComponent(ped, weaponHash, component) then
        GiveWeaponComponentToPed(ped, weaponHash, component)
        table.insert(self.current[weaponHash].components, component)
      end
    end
  end
end

-- give specific weapon component to player
function Weapon:giveComponent(weapon, component, player)
  local ped = self:getPlayerPed(player)
  local weaponHash = GetHashKey(weapon)
  local componentHash = GetHashKey(component)

  if HasPedGotWeapon(ped, weaponHash, false) and not HasPedGotWeaponComponent(ped, weaponHash, componentHash) then
    GiveWeaponComponentToPed(ped, weaponHash, componentHash)
    table.insert(self.current[weaponHash].components, componentHash)
  end 
end

-- give specific weapon ammo to player
function Weapon:giveAmmo(weapon, ammo, player)
  local ped = self:getPlayerPed(player)
  local hash = GetHashKey(weapon)

  if HasPedGotWeapon(ped, hash, false) then
    local _, maxAmmo = GetMaxAmmo(ped, hash)
    local currentAmmo = GetAmmoInPedWeapon(ped, hash)
    local newAmmo = currentAmmo + ammo

    if newAmmo <= maxAmmo then
      SetPedAmmo(ped, hash, newAmmo)
      self.current[hash].ammo = newAmmo
    end
  end
end

-- TUNNEL
Weapon.tunnel = {}

Weapon.tunnel.giveAmmo = Weapon.giveAmmo
Weapon.tunnel.getWeapons = Weapon.getWeapons
Weapon.tunnel.getComponents = Weapon.getComponents
Weapon.tunnel.replaceWeapons = Weapon.replaceWeapons
Weapon.tunnel.giveWeapons = Weapon.giveWeapons
Weapon.tunnel.giveWeapon = Weapon.giveWeapon
Weapon.tunnel.giveComponent = Weapon.giveComponent
Weapon.tunnel.giveComponents = Weapon.giveComponents

vRP:registerExtension(Weapon)
