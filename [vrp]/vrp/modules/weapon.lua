-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.weapon then return end

local lang = vRP.lang

local Weapon = class("Weapon", vRP.Extension)

local function componentsMenu(self)
	vRP.EXT.GUI:registerMenuBuilder("weapons.type.options.components", function(menu)
		local user = menu.user

		menu.title = menu.data.name
		menu.css.header_color = "rgba(200,0,0,0.75)"

		local weaponData = self.weapons[menu.data.weapon]
		if weaponData then
			local comps = (self._caches and self._caches.components and self._caches.components[menu.data.weapon])
			if not comps then
				local wcfg = module("vrp", "cfg/weapon")
				local entry = nil
				if wcfg and wcfg.weapons then
					for _, e in pairs(wcfg.weapons) do
						if e.HashKey == menu.data.weapon then entry = e break end
					end
				end
				comps = (entry and entry.Components) or {}
				if self._caches and self._caches.components then self._caches.components[menu.data.weapon] = comps end
			end
			for _, v in pairs(comps) do
				local hashKey, name, description, enabled = v.HashKey,v.Name,v.Description,v.Enabled
				if enabled then
					menu:addOption(name, function(menu)
						vRP.EXT.Weapon.remote._giveComponent(menu.user.source, user.source, menu.data.weapon, hashKey)
					end, description)
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
			self.remote._giveWeapon(menu.user.source, user.source, menu.data.weapon)
			vRP.EXT.Base.remote._notify(menu.user.source, "You received a " .. menu.data.name)
		end)
		
		menu:addOption("Components", function(menu)
			menu.user:openMenu("weapons.type.options.components", { name = menu.data.name, weapon = menu.data.weapon })
		end)
		
		menu:addOption("Give Ammo", function(menu)
			local ammo = user:prompt("give weapon ammo amount", "")
			vRP.EXT.Weapon.remote._giveAmmo(menu.user.source, user.source, menu.data.weapon, tonumber(ammo))
			vRP.EXT.Base.remote._notify(menu.user.source, "You received " .. ammo .. " ammo")
		end)
	end)
end

local function weaponTypeMenu(self)
	vRP.EXT.GUI:registerMenuBuilder("weapons.type", function(menu)
		local user = menu.user

		menu.title = menu.data.title
		menu.css.header_color = "rgba(200,0,0,0.75)"

		for weapon, _ in pairs(self.weapons) do
			local entry = nil
			local wcfg = module("vrp", "cfg/weapon")
			if wcfg and wcfg.weapons then
				for _, e in pairs(wcfg.weapons) do
					if e.HashKey == weapon then entry = e break end
				end
			end
			local name = (entry and entry.Name) or "unknown"
			local description = (entry and entry.Description) or ""
			local group = (entry and entry.Group) or nil

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
  vRP.Extension.__construct(self)

  self.cfg = module("vrp", "cfg/weapon")
	-- Strip long descriptions from cfg to reduce memory footprint (safe: descriptions used only for menu help)
	if type(self.cfg) == "table" and type(self.cfg.weapons) == "table" then
		for _, w in pairs(self.cfg.weapons) do
			w.Description = nil
			if type(w.Components) == "table" then
				for _, c in pairs(w.Components) do
					c.Description = nil
				end
			end
		end
	end

	self.weapons = {} -- map of all enabled weapons (keyed by HashKey -> true)
	self.gtypes = {} -- map of all enabled gtypes

	-- register all enabled weapons (store only HashKey -> group mapping; keep cfg key index)
	for k,v in pairs(self.cfg.weapons) do
		local h,n,d,g,e = v.HashKey,v.Name,v.Description,v.Group,v.Enabled
		if e then
			self.weapons[h] = true
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
	-- lightweight weak caches (do not keep values alive)
	self._caches = {
		components = setmetatable({}, { __mode = "kv" })
	}

	-- clear large config reference (cfg already consumed)
	self.cfg = nil
end

-- cleanup on unload: free any per-user or large caches
Weapon.event = Weapon.event or {}
function Weapon.event:characterUnload(user)
	if self._caches and self._caches.components then
		for k in pairs(self._caches.components) do self._caches.components[k] = nil end
	end
end

vRP:registerExtension(Weapon)

-- performGC: lightweight cleanup hook called by GC manager
function Weapon:performGC()
	if self._caches and self._caches.components then
		for k in pairs(self._caches.components) do self._caches.components[k] = nil end
	end
end