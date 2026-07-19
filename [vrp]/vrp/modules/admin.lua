-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.admin then return end

local htmlEntities = module("lib/htmlEntities")
local lang = vRP.lang
local Admin = class("Admin", vRP.Extension)

-- shared gate for the vrpReload/vrpStop/vrpStart commands: source 0 (server
-- console) is trusted implicitly, otherwise requires core.reload
local function checkReloadPermission(source)
  if source == 0 then return true end
  local user = vRP.users_by_source[source]
  if not user or not user:hasPermission("core.reload") then
    if user then vRP.EXT.Base.remote._notify(source, "You are not authorized to use this command.") end
    return false
  end
  return true
end

-- refresh every connected user's currently-open menu (no-op for users with
-- none open) so a stop/start/reload becomes visible immediately instead of
-- requiring them to close and reopen the menu themselves.
local function actualizeAllMenus()
  if not vRP.EXT.GUI then return end
  for _, user in pairs(vRP.users) do
    user:actualizeMenu()
  end
end

--menu movement. gives all location based options
local function menu_admin_movement(self)
  vRP.EXT.GUI:registerMenuBuilder(self, "admin.movement", function(menu)
		local user = menu.user
		if not user:hasPermission("admin.menu") then return end
		menu.title = "Movement"
		menu.css.header_color = "rgba(200,0,0,0.75)"
		
		menu:addOption(lang.admin.coords.title(), function(menu)		-- Curent coordinates
			local user = menu.user
			local x,y,z = vRP.EXT.Base.remote.getPosition(user.source)
			user:prompt(lang.admin.coords.hint(),x..","..y..","..z)
		end)
		
		menu:addOption(lang.admin.tptocoords.title(), function(menu)	-- Teleport to coordinates
			local user = menu.user
			local fcoords = user:prompt(lang.admin.tptocoords.prompt(),"")
			local coords = {}
			for coord in string.gmatch(fcoords or "0,0,0","[^,]+") do
				table.insert(coords,tonumber(coord))
			end

			vRP.EXT.Base.remote._teleport(user.source, coords[1] or 0, coords[2] or 0, coords[3] or 0)
		end)
		
		menu:addOption(lang.admin.tptomarker.title(), function(menu)		-- teleport to current maker
			self.remote._teleportToMarker(menu.user.source)
		end)
		
		menu:addOption(lang.admin.noclip.title(), function(menu)			-- toogle noclip
			self.remote._toggleNoclip(menu.user.source)
		end)
  end)
end

-- menu emote. give emote related options
local function menu_admin_emotes(self)
  vRP.EXT.GUI:registerMenuBuilder(self, "admin.emotes", function(menu)
		local user = menu.user
		if not user:hasPermission("admin.menu") then return end
		menu.title = "Emotes"
		menu.css.header_color = "rgba(200,0,0,0.75)"
		
		menu:addOption(lang.admin.custom_upper_emote.title(), function(menu)
			self:emote(menu)
		end)
		
		menu:addOption(lang.admin.custom_full_emote.title(), function(menu)
			self:emote(menu)
		end)
		
		menu:addOption(lang.admin.custom_emote_task.title(), function(menu)
			local user = menu.user
			local content = user:prompt(lang.admin.custom_emote_task.prompt(),"")
			local seq = {task = content or ""}

			vRP.EXT.Base.remote._playAnim(user.source, false, seq, false)
		end)
  end)
end

--menu users. List all current users
local function menu_admin_users(self)	
  vRP.EXT.GUI:registerMenuBuilder(self, "admin.users", function(menu)
		local user = menu.user
		menu.title = lang.admin.users.title()
		menu.css.header_color = "rgba(200,0,0,0.75)"
		
		menu:addOption(lang.admin.users.by_id.title(), function(menu)
			local id = parseInt(menu.user:prompt(lang.admin.users.by_id.prompt(),""))
			menu.user:openMenu("admin.users.user", {id = id})
		end)
		
		for id, user in pairs(vRP.users) do
			menu:addOption(lang.admin.users.user.title({id, htmlEntities.encode(user.name)}), function(menu)
				menu.user:openMenu("admin.users.user", {id = id})
			end)
		end
  end)
end

--menu user. options for seleced user
local function menu_admin_users_user(self)		-- individual user options
  vRP.EXT.GUI:registerMenuBuilder(self, "admin.users.user", function(menu)
		local user = menu.user
    local id = menu.data.id
    local tuser = vRP.users[id]

    if tuser then -- online
      menu.title = lang.admin.users.user.title({id, tuser.name})
    else
      menu.title = lang.admin.users.user.title({id, htmlEntities.encode("<offline>")})
    end
	
		menu.css.header_color = "rgba(200,0,0,0.75)"
	
		-- player info
		menu:addOption(lang.admin.users.user.info.title(), function(menu)
			local user = menu.user
			local id = menu.data.id
			local tuser = vRP.users[id]
		end, lang.admin.users.user.info.description({
			htmlEntities.encode(tuser and tuser.endpoint or "offline"), -- endpoint
			tuser and tuser.source or "offline", -- source
			tuser and tuser.last_login or "offline", -- last login
			tuser and tuser.cid or "none" -- character id
		}))
		
		if tuser then
			-- kick player
			if user:hasPermission("player.kick") then
        menu:addOption(lang.admin.users.user.kick.title(), function(menu)
          local reason = user:prompt(lang.admin.users.user.kick.prompt(), "")
          if tuser then
            vRP:kick(tuser, reason)
          end
        end)
      end
			
			-- revive player
			if user:hasPermission("player.revive") then
        menu:addOption(lang.admin.users.user.revive.title(), function(menu)
          vRP.EXT.Base.remote._notify(user.source, "Not Created yet")
        end)
      end
			
			-- spectate player
			if user:hasPermission("player.spectate") and tuser ~= menu.user then
        menu:addOption(lang.admin.users.user.spectate.title(), function(menu)
          self.remote._toggleSpectate(menu.user.source, tuser)
          self.remote._toggleNoclip(menu.user.source)
        end)
      end
			
			-- Give player weapon
			if user:hasPermission("player.giveweapon") then
        menu:addOption("Give Weapon", function(menu)
          local weapon = user:prompt("give user a weapon by name no spaces", "")
          if tuser and weapon and weapon ~= "" then
            local weaponName = string.upper("weapon_"..weapon)
            if vRP.EXT.Weapon.weapons[weaponName] then
              vRP.EXT.Weapon.remote._giveWeapon(user.source, tuser.source, weaponName)
            else
              vRP.EXT.Base.remote._notify(user.source, "Unknown or disabled weapon: "..weapon)
            end
          end
        end)
      end
			
			-- telepoert player to me
			if user:hasPermission("player.tptome") then
        menu:addOption(lang.admin.users.user.tptome.title(), function(menu)
          local x, y, z = vRP.EXT.Base.remote.getPosition(user.source)
          if tuser then
            vRP.EXT.Base.remote._teleport(tuser.source, x, y, z)
          end
        end)
      end
			
			-- teleport to player
			if user:hasPermission("player.tpto") then
        menu:addOption(lang.admin.users.user.tpto.title(), function(menu)
          if tuser then
            local tx, ty, tz = vRP.EXT.Base.remote.getPosition(tuser.source)
            vRP.EXT.Base.remote._teleport(user.source, tx, ty, tz)
          end
        end)
      end
		end
  end)
end

-- menu: admin
local function menu_admin(self)
  vRP.EXT.GUI:registerMenuBuilder(self, "admin", function(menu)
    local user = menu.user
    menu.title = lang.admin.title()
    menu.css.header_color = "rgba(200,0,0,0.75)"

    if not user:hasPermission("admin.menu") then
      -- not staff: offer only the way to reach staff, nothing else
      if user:hasPermission("player.calladmin") then
        menu:addOption(lang.admin.call_admin.title(), function(menu)
          local desc = user:prompt(lang.admin.call_admin.prompt(), "") or ""
          local answered = false
          local admins = {}
          for id, user in pairs(vRP.users) do
            if user:isReady() and user:hasPermission("admin.tickets") then
              table.insert(admins, user)
            end
          end

          for _, admin in ipairs(admins) do
            async(function()
              local ok = admin:request(lang.admin.call_admin.request({user.id, htmlEntities.encode(desc)}), 60)
              if ok and not answered then
                vRP.EXT.Base.remote._notify(user.source, lang.admin.call_admin.notify_taken())
                vRP.EXT.Base.remote._teleport(admin.source, vRP.EXT.Base.remote.getPosition(user.source))
                answered = true
              elseif ok then
                vRP.EXT.Base.remote._notify(admin.source, lang.admin.call_admin.notify_already_taken())
              end
            end)
          end
        end)
      end
      return
    end

    menu:addOption(lang.admin.users.title(), function(menu)
      menu.user:openMenu("admin.users")
    end)

    menu:addOption("Movement", function(menu)
      menu.user:openMenu("admin.movement")
    end)

    menu:addOption("Emotes", function(menu)
      menu.user:openMenu("admin.emotes")
    end)

    menu:addOption(lang.admin.custom_sound.title(), function(menu)
      local content = user:prompt(lang.admin.custom_sound.prompt(), "")
      local args = {}
      for arg in string.gmatch(content, "[^%s]+") do
        table.insert(args, arg)
      end
      vRP.EXT.Base.remote._playSound(user.source, args[1] or "", args[2] or "")
    end)
  end)
end

-- PRIVATE METHODS

function Admin:emote(menu, upper)
	local user = menu.user
	local content = user:prompt(lang.admin.custom_upper_emote.prompt(),"")
	local seq = {}
	for line in string.gmatch(content,"[^\n]+") do
		local args = {}
		for arg in string.gmatch(line,"[^%s]+") do
			table.insert(args,arg)
		end

		table.insert(seq,{args[1] or "", args[2] or "", args[4] or 1})
	end

	vRP.EXT.Base.remote._playAnim(user.source, upper, seq, false)
end

function Admin:__construct()
  vRP.Extension.__construct(self)

  menu_admin(self)
  menu_admin_users(self)
  menu_admin_users_user(self)
  menu_admin_emotes(self)
  menu_admin_movement(self)

  -- main menu
  vRP.EXT.GUI:registerMenuBuilder(self, "main", function(menu)
    menu:addOption("Admin", function(menu)
      menu.user:openMenu("admin")
    end)
  end)

  -- hot-reload extensions registered with a module source (see
  -- vRPShared:reloadExtensions); gated on core.reload, granted only to the
  -- superadmin group (which includes the server owner, see cfg/groups.lua's
  -- cfg.users[1]). Server console (source 0) is trusted implicitly.
  -- usage: /vrpReload            -- reload every reloadable extension
  --        /vrpReload Weapon GUI -- reload only the named extensions
  RegisterCommand("vrpReload", function(source, args)
    if not checkReloadPermission(source) then return end

    self:log("Extension reload triggered by source " .. tostring(source) ..
      (args[1] and (" for: " .. table.concat(args, ", ")) or " (all)"))
    vRP:reloadExtensions(args[1] and args or nil)
    actualizeAllMenus()
  end, false)

  -- stop a running extension and leave it stopped (e.g. before editing its
  -- code on disk); same permission gate as vrpReload.
  -- usage: /vrpStop Weapon
  RegisterCommand("vrpStop", function(source, args)
    if not checkReloadPermission(source) then return end
    if not args[1] then
      self:log("vrpStop: usage /vrpStop <ExtensionName>")
      return
    end

    self:log("Extension stop triggered by source " .. tostring(source) .. " for: " .. args[1])
    vRP:stopExtension(args[1])
    actualizeAllMenus()
  end, false)

  -- (re)start a previously-stopped extension from its remembered module
  -- source; same permission gate as vrpReload.
  -- usage: /vrpStart Weapon
  RegisterCommand("vrpStart", function(source, args)
    if not checkReloadPermission(source) then return end
    if not args[1] then
      self:log("vrpStart: usage /vrpStart <ExtensionName>")
      return
    end

    self:log("Extension start triggered by source " .. tostring(source) .. " for: " .. args[1])
    vRP:startExtension(args[1])
    actualizeAllMenus()
  end, false)
end

vRP:registerExtension(Admin)