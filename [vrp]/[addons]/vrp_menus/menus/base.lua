-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)
local init = module("vrp_menus", "cfg/components")
if not init.base then return end

local lang = vRP.lang
local htmlEntities = module("lib/htmlEntities")
local Base = class("Base", vRP.Component)

function Base:__construct()
	vRP.Component.__construct(self)
	
	-- menu: characters
	local function menu_characters(self)
		local function m_use(menu, cid)
			local user = menu.user
			local ok, err = user:useCharacter(cid)
			if not ok then
				if err <= 2 then
					vRP.EXT.Base.remote._notify(user.source, lang.common.must_wait({user.use_character_action:remaining()}))
				else
					vRP.EXT.Base.remote._notify(user.source, lang.characters.character.error())
				end
			end
		end
		
		local function m_create(menu)
			if user:createCharacter() then
				local characters = user:getCharacters()
				for _, cid in pairs(characters) do
					local identity = vRP.EXT.Identity:getIdentity(cid)
					vRP.EXT.Base.remote._notify(user.source, identity.name.." "..identity.firstname)	
				end
				--user:actualizeMenu()
			else
				vRP.EXT.Base.remote._notify(user.source, lang.characters.create.error())
			end
		end

		local function m_delete(menu)
			local user = menu.user
			local cid = parseInt(user:prompt(lang.characters.delete.prompt(), ""))
			if user:deleteCharacter(cid) then
				user:actualizeMenu()
			else
				vRP.EXT.Base.remote._notify(user.source, lang.characters.delete.error({cid}))
			end
		end
		
		vRP.EXT.GUI:registerMenuBuilder("characters", function(menu)
			local user = menu.user
			menu.title = lang.characters.title()
			menu.css.header_color = "rgba(0,125,255,0.75)"
			
			-- characters
			local characters = user:getCharacters()
			for _, cid in pairs(characters) do
				local identity = vRP.EXT.Identity:getIdentity(cid)
				local prefix
				if cid == user.cid then prefix = "* " else prefix = "" end
				menu:addOption(prefix..lang.characters.character.title({cid, htmlEntities.encode(identity and identity.name or ""), htmlEntities.encode(identity and identity.firstname or "")}), m_use, nil, cid)
			end
			
			menu:addOption(lang.characters.create.title(), m_create)
			menu:addOption(lang.characters.delete.title(), m_delete)
		end)
	end
end

Base.event = {}

function Base.event:extensionLoad(ext)
  if ext == vRP.EXT.GUI then
    menu_characters(self)

    local function m_characters(menu)
      menu.user:openMenu("characters")
    end

    vRP.EXT.GUI:registerMenuBuilder("main", function(menu)
      if menu.user:hasPermission("player.characters") then
        menu:addOption(lang.characters.title(), m_characters)
      end
    end)
		
  elseif ext == vRP.EXT.Group then
    -- register fperm inside
    vRP.EXT.Group:registerPermissionFunction("inside", function(user, params)
      return vRP.EXT.Base.remote.isInside(user.source)
    end)
  end
end

vRP:registerComponent(Base)