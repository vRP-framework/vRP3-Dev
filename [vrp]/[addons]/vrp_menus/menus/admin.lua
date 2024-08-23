-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)
local init = module("vrp_menus", "cfg/components")
if not init.admin then return end

local lang = vRP.lang
local htmlEntities = module("lib/htmlEntities")
local Admin = class("Admin", vRP.Component)

--menu movement. gives all location based options
local function menu_admin_movement(self)
  vRP.EXT.GUI:registerMenuBuilder("admin.movement", function(menu)
		local user = menu.user
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
			vRP.EXT.Admin.remote._teleportToMarker(menu.user.source)
		end)
		
		menu:addOption(lang.admin.noclip.title(), function(menu)			-- toogle noclip
			vRP.EXT.Admin.remote._toggleNoclip(menu.user.source)
		end)
  end)
end

-- menu emote. give emote related options
local function menu_admin_emotes(self)
  vRP.EXT.GUI:registerMenuBuilder("admin.emotes", function(menu)
		local user = menu.user
		menu.title = "Emotes"
		menu.css.header_color = "rgba(200,0,0,0.75)"
		
		menu:addOption(lang.admin.custom_upper_emote.title(), function(menu)
			vRP.EXT.Admin:emote(menu)
		end)
		
		menu:addOption(lang.admin.custom_full_emote.title(), function(menu)
			vRP.EXT.Admin:emote(menu)
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
	vRP.EXT.GUI:registerMenuBuilder("admin.users", function(menu)
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
  vRP.EXT.GUI:registerMenuBuilder("admin.users.user", function(menu)
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
			  local user = menu.user
			  local id = menu.data.id
			  local tuser = vRP.users[id]
			  
			  if tuser then
			    local reason = user:prompt(lang.admin.users.user.kick.prompt(), "")
			    vRP:kick(tuser, reason)
			  end
			end)
		end
		
		--give money
		if user:hasPermission("player.givemoney") then
			menu:addOption(lang.admin.users.user.give_money.title(), function(menu)		
				local user = menu.user
				local tuser = vRP.users[menu.data.id]

				if tuser then
					local amount = parseInt(user:prompt(lang.admin.users.user.give_money.prompt(),""))
					tuser:giveWallet(amount)
				end
			end)
		end
		
		-- revive player
		if user:hasPermission("player.revive") then
			menu:addOption(lang.admin.users.user.revive.title(), function(menu)
				local id = menu.data.id
				local tuser = vRP.users[id]
				
				if tuser then
					vRP.EXT.Base.remote._notify(user.source,"Not Created yet")
				end
			end)
		end
		
		-- spectate player
		if user:hasPermission("player.spectate") then
			local id = menu.data.id
			local tuser = vRP.users[id]
			
			if tuser ~= menu.user then
			  menu:addOption(lang.admin.users.user.spectate.title(), function(menu)
			    vRP.EXT.Admin.remote._toggleSpectate(menu.user.source, tuser)
			    vRP.EXT.Admin.remote._toggleNoclip(menu.user.source)
			  end)
			end
		end
		
		-- Give player weapon
		if user:hasPermission("player.giveweapon") then
			menu:addOption("Give Weapon", function(menu)
				local user = menu.user
				local id = menu.data.id
				local tuser = vRP.users[id]
				
				if tuser then
					local weapon = user:prompt("give user a weapon by name no spaces", "")
					vRP.EXT.Weapon.remote._giveWeapon(menu.user.source, tuser.source, string.upper("weapon_"..weapon))
				end
			end)
		end
		
		-- telepoert player to me
		if user:hasPermission("player.tptome") then
			menu:addOption(lang.admin.users.user.tptome.title(), function(menu)
			  local user = menu.user
			  local id = menu.data.id
			  local tuser = vRP.users[id]

			  if tuser then
			    local x,y,z = vRP.EXT.Base.remote.getPosition(user.source)
			    vRP.EXT.Base.remote._teleport(tuser.source,x,y,z)
			  end
			end)
		end
		
		-- teleport to player
		if user:hasPermission("player.tpto") then
			menu:addOption(lang.admin.users.user.tpto.title(), function(menu)
			  local user = menu.user
			  local id = menu.data.id
			  local tuser = vRP.users[id]

			  if tuser then
			    vRP.EXT.Base.remote._teleport(user.source, vRP.EXT.Base.remote.getPosition(tuser.source))
			  end
			end)
		end
	end
  end)
end

-- menu: admin
local function menu_admin(self)

	local function callAdmin()
		local user = menu.user
		local desc = user:prompt(lang.admin.call_admin.prompt(),"") or ""
		local answered = false

		local admins = {} 
		for id,user in pairs(vRP.users) do
			-- check admin
			if user:isReady() and user:hasPermission("admin.tickets") then
				table.insert(admins, user)
			end
		end
		-- send notify and alert to all admins
		for _,admin in pairs(admins) do
			async(function()
				local ok = admin:request(lang.admin.call_admin.request({user.id, htmlEntities.encode(desc)}), 60)
				if ok then -- take the call
					if not answered then
					-- answer the call
					vRP.EXT.Base.remote._notify(user.source,lang.admin.call_admin.notify_taken())
					vRP.EXT.Base.remote._teleport(admin.source, vRP.EXT.Base.remote.getPosition(user.source))
					answered = true
					else
					vRP.EXT.Base.remote._notify(admin.source,lang.admin.call_admin.notify_already_taken())
					end
				end
			end)
		end
	end

  vRP.EXT.GUI:registerMenuBuilder("admin", function(menu)
		local user = menu.user

    menu.title = lang.admin.title()
    menu.css.header_color = "rgba(200,0,0,0.75)"
	
		if not user:hasPermission("player.kick") then	-- only shows to non admins
			menu:addOption(lang.admin.call_admin.title(), callAdmin)
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
			local user = menu.user
			local content = user:prompt(lang.admin.custom_sound.prompt(),"")
			local args = {}
			
			for arg in string.gmatch(content,"[^%s]+") do
				table.insert(args,arg)
			end
			
			vRP.EXT.Base.remote._playSound(user.source, args[1] or "", args[2] or "")
		end)
  end)
end

function Admin:__construct()
  vRP.Component.__construct(self)
	
  menu_admin(self)
  menu_admin_users(self)
  menu_admin_users_user(self)
  menu_admin_emotes(self)
  menu_admin_movement(self)

	vRP.EXT.GUI:registerMenuBuilder("main", function(menu)
		menu:addOption("Admin", function(menu)	-- build admin menu
      menu.user:openMenu("admin")
		end)
	end)
end

vRP:registerComponent(Admin)