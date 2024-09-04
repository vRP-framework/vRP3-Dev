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
    local firstname, name, age = vRP.EXT.Identity.tunnel_interface.createIdentity(user)
    vRP.EXT.Identity.tunnel_interface.processIdentity(user, firstname, name, age)
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
  self.sanitizes = module("vrp", "cfg/sanitizes")
	
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