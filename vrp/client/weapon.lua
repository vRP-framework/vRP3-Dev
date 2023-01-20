-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.weapon then return end

local Weapon = class("Weapon", vRP.Extension)

-- METHODS

function Weapon:__construct()
  vRP.Extension.__construct(self)

  self.state_ready = false
  self.update_interval = 30
  self.mp_models = {} -- map of model hash

  -- update task
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(self.update_interval*1000)

      if self.state_ready then
        local x,y,z = vRP.EXT.Base:getPosition()

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
  local player = PlayerPedId()

  local ammo_types = {} -- remember ammo type to not duplicate ammo amount

  local weapons = {}
  for k,v in pairs(Weapon.weapon_types) do
	if v then
		local hash = GetHashKey(k)
		if HasPedGotWeapon(player,hash) then
		  local weapon = {}
		  weapons[v] = weapon

		  local atype = Citizen.InvokeNative(0x7FEAD38B326B9F74, player, hash)
		  if ammo_types[atype] == nil then
			ammo_types[atype] = true
			weapon.ammo = GetAmmoInPedWeapon(player,hash)
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
  local player = PlayerPedId()

  -- give weapons to player

  if clear_before then
    RemoveAllPedWeapons(player,true)
  end

  for k,weapon in pairs(weapons) do
    local hash = GetHashKey(k)
    local ammo = weapon.ammo or 0

    GiveWeaponToPed(player, hash, ammo, false)
  end
end

-- give specific weapon to player
function Weapon:giveWeapon(player, weapon, clear_before)
  local playerIdx = GetPlayerFromServerId(player)
  local ped = GetPlayerPed(playerIdx)
  local hash = GetHashKey(weapon)
  
  -- give a weapon to player
  GiveWeaponToPed(ped, hash, 999, false)
end

-- give specific weapon to player
function Weapon:giveComponent(player, weapon, component, clear_before)
  local playerIdx = GetPlayerFromServerId(player)
  local ped = GetPlayerPed(playerIdx)
    
  local weapon_hash = GetHashKey(weapon)
  local component_hash = GetHashKey(component)

  local component = GetWeaponComponentTypeModel(hash)
  
  if not HasPedGotWeaponComponent(ped, weapon_hash, component_hash) then
	  GiveWeaponComponentToPed(ped, weapon_hash, component_hash)
  end
end

-- give specific weapon to player
function Weapon:getComponent(weapon, component)
  local comp_1  = ""..weapon..""..component
  local comp_2  = ""..component
  local comp_3  = component

  local w_Hash  = GetHashKey(weapon)
  local c_Hash  = GetHashKey(component)

  local checked = DoesWeaponTakeWeaponComponent(w_Hash, c_Hash)
  local temp = {}

  notification(comp_1)
end

-- give specific weapon to player
function Weapon:giveAmmo(player, weapon, ammo, clear_before)
  local playerIdx = GetPlayerFromServerId(player)
  local ped = GetPlayerPed(playerIdx)
  local hash = GetHashKey(weapon)
  
  local currentAmmo = GetAmmoInPedWeapon(ped, hash)
  local newAmmo = currentAmmo + ammo
  local maxAmmo = GetMaxAmmo(ped, hash)
  
  notification("current Ammo: "..currentAmmo..", Max: "..maxAmmo..", new Ammo: "..newAmmo)
  
  if newAmmo < maxAmmo then
	SetPedAmmo(ped, hash, newAmmo)
  end
end

--Client side notification
function notification(msg)		
	SetNotificationTextEntry("STRING")
	AddTextComponentString(msg)
	DrawNotification(false, false)
end

-- TUNNEL
Weapon.tunnel = {}

Weapon.tunnel.giveAmmo = Weapon.giveAmmo
Weapon.tunnel.getWeapons = Weapon.getWeapons
Weapon.tunnel.replaceWeapons = Weapon.replaceWeapons
Weapon.tunnel.giveWeapons = Weapon.giveWeapons
Weapon.tunnel.giveWeapon = Weapon.giveWeapon
Weapon.tunnel.giveComponent = Weapon.giveComponent
Weapon.tunnel.getComponent = Weapon.getComponent

vRP:registerExtension(Weapon)
