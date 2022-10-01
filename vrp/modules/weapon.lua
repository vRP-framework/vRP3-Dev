-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.weapon then return end

local lang = vRP.lang

local Weapon = class("Weapon", vRP.Extension)

local function menu_weapons_type_options_components(self)
	vRP.EXT.GUI:registerMenuBuilder("weapons.type.options.components", function(menu)
		local user = menu.user

		menu.title = menu.data.name
		menu.css.header_color = "rgba(200,0,0,0.75)"

		for k, v in pairs(self.weapons) do
			if k == menu.data.weapon then
				local n, d, g, c = table.unpack(v)
				for k, v in pairs(c) do
					local h, n, d, e = v.HashKey, v.Name, v.Description, v.Enabled
					if e then
						menu:addOption(n, function(menu)
							vRP.EXT.Weapon.remote._giveComponent(menu.user.source, user.source, menu.data.weapon, h)
						end, d)
					end
				end
			end
		end
	end)
end

local function menu_weapons_type_options(self)
	vRP.EXT.GUI:registerMenuBuilder("weapons.type.options", function(menu)
		local user = menu.user
		local test = self.remote._hasWeapon(menu.user.source, menu.data.weapon)
		menu.title = menu.data.name
		menu.css.header_color = "rgba(200,0,0,0.75)"

		menu:addOption("Give Weapon", function(menu)
			self.remote._giveWeapon(menu.user.source, user.source, menu.data.weapon, menu.data.name)
		end)
		menu:addOption("Components", function(menu)
			menu.user:openMenu("weapons.type.options.components", { name = menu.data.name, weapon = menu.data.weapon })
		end)
		menu:addOption("Give Ammo x20", function(menu)
			vRP.EXT.Weapon.remote._giveAmmo(menu.user.source, user.source, menu.data.weapon, 20)
		end)
	end)
end

local function menu_weapons_type(self)
	vRP.EXT.GUI:registerMenuBuilder("weapons.type", function(menu)
		local user = menu.user

		menu.title = menu.data.title
		menu.css.header_color = "rgba(200,0,0,0.75)"

		for weapon, v in pairs(self.weapons) do
			local name, Description, Group, Components = table.unpack(v)

			if menu.data.gtype == Group then
				menu:addOption(name, function(menu)
					menu.user:openMenu("weapons.type.options", { name = name, weapon = weapon })
				end, Description)
			end
		end
	end)
end

-- menu: admin
local function menu_weapons(self)
	vRP.EXT.GUI:registerMenuBuilder("weapons", function(menu)
		local user = menu.user

		menu.title = "Weapons"
		menu.css.header_color = "rgba(200,0,0,0.75)"

		for k, v in pairs(self.gtypes) do
			local title = table.unpack(v)

			menu:addOption(title, function(menu)
				menu.user:openMenu("weapons.type", { gtype = k, title = title })
			end)
		end

	end)
end

function Weapon:__construct()
	vRP.Extension.__construct(self)

	self.cfg = module("vrp", "cfg/weapon")

	self.weapons = {} -- map of all enabled weapons
	self.gtypes = {} -- map of all enabled gtypes

	-- register all enabled weapons
	for k, v in pairs(self.cfg.weapons) do
		local h, n, d, g, e, c = v.HashKey, v.Name, v.Description, v.Group, v.Enabled, v.Components
		if e then
			self.weapons[h] = { n, d, g, c }
		end
	end

	-- register all enabled gtypes
	for k, v in pairs(self.cfg.types) do
		local gcfg = v._config
		if gcfg.enabled then
			self.gtypes[k] = { gcfg.title }
		end
	end

	--[[
		for k,v in pairs(self.weapons) do
			self.remote._init(user.source, k)
			vRP.EXT.GUI.remote._closeMenu(self.source)
		end
	]]

	--menu
	menu_weapons(self)
	menu_weapons_type(self)
	menu_weapons_type_options(self)
	menu_weapons_type_options_components(self)

	-- list for all weapons that are useable
	vRP.EXT.GUI:registerMenuBuilder("admin", function(menu)
		menu:addOption("Weapons", function(menu)
			menu.user:openMenu("weapons")
		end)
	end)
end

-- EVENT

Weapon.event = {}

function Weapon.event:characterLoad(user)
	for k,v in pairs(self.weapons) do
		self.remote._init(user.source, k)
	end
end

vRP:registerExtension(Weapon)
