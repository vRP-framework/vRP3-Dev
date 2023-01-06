-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.weapon then return end

local lang = vRP.lang

local Weapon = class("Weapon", vRP.Extension)

local function menu_weapons_type_options(self)
  vRP.EXT.GUI:registerMenuBuilder("weapons.type.options", function(menu)
	local user = menu.user

    menu.title = menu.data.name
    menu.css.header_color = "rgba(200,0,0,0.75)"
	
	menu:addOption("Give Weapon", function(menu)
		self.remote._giveWeapon(menu.user.source, user.source, menu.data.weapon)
		vRP.EXT.Base.remote._notify(menu.user.source,"You recieved a "..menu.data.weapon.."")
	end)
	menu:addOption("Give Component", function(menu)
		local component = user:prompt("give weapon component full name", "")
		vRP.EXT.Weapon.remote._giveComponent(menu.user.source, user.source, menu.data.weapon, string.upper(""..component))
	end)
	menu:addOption("Give Ammo", function(menu)
		local ammo = user:prompt("give weapon ammo amount", "")
		vRP.EXT.Weapon.remote._giveAmmo(menu.user.source, user.source, menu.data.weapon, tonumber(ammo))
		vRP.EXT.Base.remote._notify(menu.user.source,"You recieved "..ammo.." ammo")
	end)
  end)
end

local function menu_weapons_type(self)
  vRP.EXT.GUI:registerMenuBuilder("weapons.type", function(menu)
	local user = menu.user

    menu.title = menu.data.gtype
    menu.css.header_color = "rgba(200,0,0,0.75)"
	
	for weapon, v in pairs(self.weapons) do
		local gtype, name, hash = table.unpack(v)
		if menu.title == gtype then
			menu:addOption(name, function(menu)
				menu.user:openMenu("weapons.type.options", {name = name, weapon = weapon})
			end)
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
	
	for gtype, v in pairs(self.cfg.weapon_types) do
		menu:addOption(gtype, function(menu)
			menu.user:openMenu("weapons.type", {gtype = gtype})
		end)
    end
  end)
end

function Weapon:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("vrp", "cfg/weapon")
  
  self.weapons = {} -- map of all weapons
  self.test = {} -- map of all weapons

  -- register all enabled weapons
  for k,v in pairs(self.cfg.weapons) do
	local gtype, name, enabled = table.unpack(v)
	--print(""..tostring(gtype)..", "..tostring(name)..", "..tostring(enabled))
	for k,v in pairs(v) do
		--print(tostring(k))
		--print("V: "..tostring(v))
	end
  end
  
  --[[
  for gtype, v in pairs(self.cfg.weapon_types) do
	for weapon, v in pairs(v) do
		if v[3] then	-- checks if weapon can be used
			self.weapons[weapon] = {v[1], v[2]}
		end
	end
  end
  ]]--
  
  --menu
  menu_weapons(self)
  menu_weapons_type(self)
  menu_weapons_type_options(self)
   
  -- list for all weapons that are useable
  vRP.EXT.GUI:registerMenuBuilder("admin", function(menu)
    menu:addOption("Weapons", function(menu)
      menu.user:openMenu("weapons")
    end)
  end)
end

vRP:registerExtension(Weapon)