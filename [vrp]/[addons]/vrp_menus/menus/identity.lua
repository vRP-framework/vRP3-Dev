-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)
local init = module("vrp_menus", "cfg/components")
if not init.identity then return end

local lang = vRP.lang
local htmlEntities = module("lib/htmlEntities")
local Identity = class("Identity", vRP.Component)

-- menu: cityhall
local function menu_cityhall(self)
  local function m_new_identity(menu)
    local user = menu.user

    local firstname = user:prompt(lang.identity.cityhall.new_identity.prompt_firstname(),"")
    if string.len(firstname) >= 2 and string.len(firstname) < 50 then
      firstname = sanitizeString(firstname, self.sanitizes.name[1], self.sanitizes.name[2])
      local name = user:prompt(lang.identity.cityhall.new_identity.prompt_name(),"")
      if string.len(name) >= 2 and string.len(name) < 50 then
        name = sanitizeString(name, self.sanitizes.name[1], self.sanitizes.name[2])
        local age = user:prompt(lang.identity.cityhall.new_identity.prompt_age(),"")
        age = parseInt(age)
        if age >= 16 and age <= 150 then
          if user:tryPayment(self.cfg.new_identity_cost) then
            local registration = self:generateRegistrationNumber()
            local phone = self:generatePhoneNumber()

            user.identity.firstname = firstname
            user.identity.name = name
            user.identity.age = age
            user.identity.registration = registration
            user.identity.phone = phone

            vRP:execute("vRP/update_character_identity", {
              character_id = user.cid,
              firstname = firstname,
              name = name,
              age = age,
              registration = registration,
              phone = phone
            })

            vRP:triggerEvent("characterIdentityUpdate", user)
            vRP.EXT.Base.remote._notify(user.source,lang.money.paid({self.cfg.new_identity_cost}))
          else
            vRP.EXT.Base.remote._notify(user.source,lang.money.not_enough())
          end
        else
          vRP.EXT.Base.remote._notify(user.source,lang.common.invalid_value())
        end
      else
        vRP.EXT.Base.remote._notify(user.source,lang.common.invalid_value())
      end
    else
      vRP.EXT.Base.remote._notify(user.source,lang.common.invalid_value())
    end
  end

  vRP.EXT.GUI:registerMenuBuilder("cityhall", function(menu)
    menu.title = lang.identity.cityhall.title()
    menu.css.header_color="rgba(0,125,255,0.75)"

    menu:addOption(lang.identity.cityhall.new_identity.title(), m_new_identity, lang.identity.cityhall.new_identity.description({self.cfg.new_identity_cost}))
  end)
end

-- menu: identity
local function menu_identity(self)
  vRP.EXT.GUI:registerMenuBuilder("identity", function(menu)
    menu.title = lang.identity.title()
    menu.css.header_color="rgba(0,125,255,0.75)"

    local identity = vRP.EXT.Identity:getIdentity(menu.data.cid)

    if identity then
      menu:addOption(lang.identity.citizenship.title(), nil, lang.identity.citizenship.info({htmlEntities.encode(identity.name), htmlEntities.encode(identity.firstname), identity.age, identity.registration, identity.phone}))
    end
  end)
end

-- menu: admin users user
local function menu_admin_users_user(self)
  local function m_identity(menu)
    local tuser = vRP.users[menu.data.id]

    if tuser and tuser:isReady() then
      menu.user:openMenu("identity", {cid = tuser.cid})
    end
  end

  vRP.EXT.GUI:registerMenuBuilder("admin.users.user", function(menu)
    local user = menu.user
    local tuser = vRP.users[menu.data.id]

    if tuser then
      menu:addOption(lang.identity.title(), m_identity)
    end
  end)
end

function Identity:__construct()
  vRP.Component.__construct(self)
	
	self.cfg = module("vrp", "cfg/identity")
	
	-- menus
  menu_cityhall(self)
  menu_identity(self)
  menu_admin_users_user(self)

  -- add identity to main menu
  local function m_identity(menu)
    menu.user:openMenu("identity", {cid = menu.user.cid})
  end

  vRP.EXT.GUI:registerMenuBuilder("main", function(menu)
    menu:addOption(lang.identity.title(), m_identity)
  end)
end

vRP:registerComponent(Identity)