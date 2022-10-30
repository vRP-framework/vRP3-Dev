if not vRP.modules.user then return end

local htmlEntities = module("lib/htmlEntities")
local lang = vRP.lang
local user = class("user", vRP.Extension)

local function menu_user_test(self)
    vRP.EXT.GUI:registerMenuBuilder("user", function(menu)
        local user = menu.user

        menu.title = "User"
        menu.css.header_color = "rgba(200,0,0,0.75)"

        menu:addOption("test", function(menu)
            vRP.User:createCharacter()
        end)
    end)
end


-- menu: characters
local function menu_characters(self)
    local function m_use(menu, cid)
        local user = menu.user
        local ok, err = user:useCharacter(cid)
        if not ok then
            if err <= 2 then
            self.remote._notify(user.source, lang.common.must_wait({user.use_character_action:remaining()}))
            else
            self.remote._notify(user.source, lang.characters.character.error())
            end
        end
    end
    local function m_create(menu)
        local user = menu.user
        if user:createCharacter() then
            user:actualizeMenu()
        else
            self.remote._notify(user.source, lang.characters.create.error())
        end
    end
    local function m_delete(menu)
        local user = menu.user
        local cid = parseInt(user:prompt(lang.characters.delete.prompt(), ""))
        if user:deleteCharacter(cid) then
            user:actualizeMenu()
        else
            self.remote._notify(user.source, lang.characters.delete.error({cid}))
        end
    end
    vRP.EXT.GUI:registerMenuBuilder("characters", function(menu)
        local user = menu.user
        menu.title = "Characters"
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

-- EVENT

user.event = {}

function user.event:extensionLoad(ext)
    if ext == vRP.EXT.GUI then
        menu_characters(self)
        
        local function m_characters(menu)
            menu.user:openMenu("characters")
        end
  
        vRP.EXT.GUI:registerMenuBuilder("main", function(menu)
            menu:addOption("Characters", m_characters)
--[[             if menu.user:hasPermission("player.characters") then
                menu:addOption(lang.characters.title(), m_characters)
            end ]]
        end)
    elseif ext == vRP.EXT.Group then
        -- register fperm inside
        vRP.EXT.Group:registerPermissionFunction("inside", function(user, params)
            return self.remote.isInside(user.source)
        end)
    end
end

function user:__construct()
    vRP.Extension.__construct(self)

    menu_user_test(self)
    menu_characters(self)

    -- main menu
    vRP.EXT.GUI:registerMenuBuilder("main", function(menu)
        menu:addOption("User", function(menu)
            menu.user:openMenu("user")
        end)
    end)
    -- main menu
    vRP.EXT.GUI:registerMenuBuilder("main", function(menu)
        menu:addOption("Characters", function(menu)
            menu.user:openMenu("characters")
        end)
    end)
end
  
vRP:registerExtension(user)