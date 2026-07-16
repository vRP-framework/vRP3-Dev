-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.weapon then return end

local Weapon = class("Weapon", vRP.Extension)
-- METHODS

function Weapon:__construct()
  vRP.Extension.__construct(self)

  self.weapon = {}  -- map of weapon ids
  self.current = {}
end

-- get player weapons
-- return map of name => {.ammo}
function Weapon:getWeapons()
  local player = GetPlayerPed(-1)
  local weapons = {}
  
  for _, entry in pairs(self.current) do
	local weaponHash = entry.weaponHash
	local ammo = entry.ammo
	
	weapons[weaponHash] = { weaponHash = weaponHash, ammo = ammo }
  end

  return weapons
end



-- get weapons components
function Weapon:getComponents()
  local player = GetPlayerPed(-1)
  local components = {}

  for _, entry in pairs(self.current) do
	local weaponHash = entry.weaponHash
	local entryComponents = entry.components
	if entryComponents then
		components[weaponHash] = {}
		for _, component in ipairs(entryComponents) do
			table.insert(components[weaponHash], component)
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
function Weapon:giveWeapons(player, weapons, clear_before)
  local playerIdx = GetPlayerFromServerId(player)
  local ped = GetPlayerPed(playerIdx)

  if clear_before then RemoveAllPedWeapons(ped,true) end

  for k, v in pairs(weapons) do
	GiveWeaponToPed(ped, v.weaponHash, v.ammo, false)
	
    if not self.current[v.weaponHash] then
		self.current[v.weaponHash] = {}
		self.current[v.weaponHash].weaponHash = v.weaponHash
		self.current[v.weaponHash].ammo = v.ammo
	end
  end
end

-- give specific weapon to player
function Weapon:giveWeapon(player, weapon)
  local playerIdx = GetPlayerFromServerId(player)
  local ped = GetPlayerPed(playerIdx)
  local hash = GetHashKey(weapon)

  if not HasPedGotWeapon(ped, hash, false) then
	if not self.current[hash] then
		self.current[hash] = {}
		self.current[hash].weaponHash = hash
	end
	
    GiveWeaponToPed(ped, hash, 0, false, true)
  end
end

-- weapons: map of name => {.ammo}
--- ammo: (optional)
function Weapon:giveComponents(player, components)
  local playerIdx = GetPlayerFromServerId(player)
  local ped = GetPlayerPed(playerIdx)
	
  for weaponHash, v in pairs(components) do
	for _, component in ipairs(v) do
		if HasPedGotWeapon(ped, weaponHash, false) and not HasPedGotWeaponComponent(ped, weaponHash, component) then
			GiveWeaponComponentToPed(ped, weaponHash, component)
			
			if self.current[weaponHash] then
				if not self.current[weaponHash].components then
					self.current[weaponHash].components = {}  
				end
				table.insert(self.current[weaponHash].components, component)
			end
		end
	end
  end
end

-- give specific weapon component to player
function Weapon:giveComponent(player, weapon, component)
  local playerIdx = GetPlayerFromServerId(player)
  local ped = GetPlayerPed(playerIdx)
  local weaponHash = GetHashKey(weapon)
  local componentHash = GetHashKey(component)

  if HasPedGotWeapon(ped, weaponHash, false) then
    if not HasPedGotWeaponComponent(ped, weaponHash, componentHash) then
      GiveWeaponComponentToPed(ped, weaponHash, componentHash)
	  
	  if self.current[weaponHash] then
		if not self.current[weaponHash].components then
			self.current[weaponHash].components = {}  -- Create the components array if it doesn't exist
		end
		table.insert(self.current[weaponHash].components, componentHash)
	  end
	end
  end 
end

-- give specific weapon ammo to player
function Weapon:giveAmmo(player, weapon, ammo)
  local playerIdx = GetPlayerFromServerId(player)
  local ped = GetPlayerPed(playerIdx)
  local hash = GetHashKey(weapon)

  -- Check if ped has the specified weapon
  if HasPedGotWeapon(ped, hash, false) then
    local _, maxAmmo = GetMaxAmmo(ped, hash)

    -- Calculate the new ammo amount
    local currentAmmo = GetAmmoInPedWeapon(ped, hash)
    local newAmmo = currentAmmo + ammo

    -- Give ammo only if it doesn't exceed the maximum capacity
    if newAmmo <= maxAmmo then
      SetPedAmmo(ped, hash, newAmmo)
	  
	  if self.current[hash] then
		self.current[hash].ammo = newAmmo
	  end
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