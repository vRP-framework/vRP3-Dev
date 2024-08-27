-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)
local init = module("vrp_menus", "cfg/components")
if not init.weapon then return end

local lang = vRP.lang
local Weapon = class("Weapon", vRP.Component)

local function componentsMenu(self)
	vRP.EXT.GUI:registerMenuBuilder("weapons.type.options.components", function(menu)
		local user = menu.user

		menu.title = menu.data.name
		menu.css.header_color = "rgba(200,0,0,0.75)"

		local weaponData = self.weapons[menu.data.weapon]
		if weaponData then
			local _, _, _, components = table.unpack(weaponData)
			for _, v in pairs(components) do
				local hashKey, name, description, enabled = v.HashKey,v.Name,v.Description,v.Enabled
				if enabled then
					local function giveComponent()
						vRP.EXT.Weapon.remote._giveComponent(menu.user.source, menu.data.weapon, hashKey, menu.user.source)
					end

					menu:addOption(name, giveComponent, description)
				end
			end
		end
	end)
end

local function optionsMenu(self)
	vRP.EXT.GUI:registerMenuBuilder("weapons.type.options", function(menu)
		local user = menu.user

		menu.title = menu.data.name
		menu.css.header_color = "rgba(200,0,0,0.75)"

		menu:addOption("Give Weapon", function(menu)	
			vRP.EXT.Weapon.remote._giveWeapon(menu.user.source, menu.data.weapon, menu.user.source)
			vRP.EXT.Base.remote._notify(menu.user.source, "You received a " .. menu.data.name)
		end)
		
		menu:addOption("Components", function(menu)		
			menu.user:openMenu("weapons.type.options.components", { name = menu.data.name, weapon = menu.data.weapon })
		end)
		
		menu:addOption("Give Ammo", function(menu)		
			local ammo = user:prompt("give weapon ammo amount", "")
			vRP.EXT.Weapon.remote._giveAmmo(menu.user.source, menu.data.weapon, tonumber(ammo), menu.user.source)
			vRP.EXT.Base.remote._notify(menu.user.source, "You received " .. ammo .. " ammo")
		end)
	end)
end

local function weaponTypeMenu(self)
	vRP.EXT.GUI:registerMenuBuilder("weapons.type", function(menu)
		local user = menu.user

		menu.title = menu.data.title
		menu.css.header_color = "rgba(200,0,0,0.75)"

		for weapon, data in pairs(self.weapons) do
			local name, description, group, _ = table.unpack(data)

			if menu.data.gtype == group then
				local function openOptionsMenu()
					menu.user:openMenu("weapons.type.options", { name = name, weapon = weapon })
				end

				menu:addOption(name, openOptionsMenu, description)
			end
		end
	end)
end

-- menu: admin
local function weaponsMenu(self)
	vRP.EXT.GUI:registerMenuBuilder("weapons", function(menu)
		local user = menu.user

		menu.title = "Weapons"
		menu.css.header_color = "rgba(200,0,0,0.75)"

		for gtype, title in pairs(self.gtypes) do
			menu:addOption(title, function(menu)
				menu.user:openMenu("weapons.type", { gtype = gtype, title = title })
			end)
		end
	end)
end

function Weapon:__construct()
	vRP.Component.__construct(self)

	self.cfg = module("vrp", "cfg/weapon")
  
  self.weapons = {} -- map of all enabled weapons
  self.gtypes = {} -- map of all enabled gtypes
	
	-- register all enabled weapons
  for k,v in pairs(self.cfg.weapons) do
		local h,n,d,g,e,c = v.HashKey,v.Name,v.Description,v.Group,v.Enabled,v.Components
		if e then
			self.weapons[h] = {n,d,g,c}
		end
  end
  
  -- register all enabled gtypes
  for k, v in pairs(self.cfg.types) do
		local gcfg = v._config
		if gcfg.enabled then
			self.gtypes[k] = {gcfg.title}
		end
  end
	
	-- menu
	weaponsMenu(self)
	weaponTypeMenu(self)
	optionsMenu(self)
	componentsMenu(self)
  
  -- list for all weapons that are useable
  vRP.EXT.GUI:registerMenuBuilder("main", function(menu)
		if menu.user:hasGroup("admin") then
			menu:addOption("Weapons", function(menu)
				menu.user:openMenu("weapons")
			end)
		end
  end)
end

vRP:registerComponent(Weapon)