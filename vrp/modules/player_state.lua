-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.player_state then return end

local lang = vRP.lang

local PlayerState = class("PlayerState", vRP.Extension)

-- PRIVATE METHODS

-- menu: admin
local function menu_admin(self)
  local function m_model(menu)
    local user = menu.user

    if user:hasPermission("player.custom_model") then
      local model = user:prompt(lang.admin.custom_model.prompt(), "")
      local hash = tonumber(model)
      local custom = {}
      if hash then
        custom.modelhash = hash
      else
        custom.model = model
      end

      self.remote._setCustomization(user.source, custom)
    end
  end

  vRP.EXT.GUI:registerMenuBuilder("admin", function(menu)
    local user = menu.user

    if user:hasPermission("player.custom_model") then
      menu:addOption(lang.admin.custom_model.title(), m_model)
    end
  end)
end

-- METHODS

function PlayerState:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("vrp", "cfg/player_state")

  menu_admin(self)
end

-- EVENT

PlayerState.event = {}

function PlayerState.event:playerSpawn(user, first_spawn)
  if first_spawn then
    self.remote._setConfig(user.source, self.cfg.update_interval, self.cfg.mp_models)
  end
  self.remote._setStateReady(user.source, false)

  -- default customization
  if not user.cdata.state.customization then
    user.cdata.state.customization = self.cfg.default_customization
  end

  --- default position
  if not user.cdata.state.position and self.cfg.spawn_enabled then
    local x = self.cfg.spawn_position[1]+math.random()*self.cfg.spawn_radius*2-self.cfg.spawn_radius
    local y = self.cfg.spawn_position[2]+math.random()*self.cfg.spawn_radius*2-self.cfg.spawn_radius
    local z = self.cfg.spawn_position[3]
    user.cdata.state.position = {x=x,y=y,z=z}
  end

  if user.cdata.state.position then -- teleport to saved pos
    vRP.EXT.Base.remote.teleport(user.source, user.cdata.state.position.x, user.cdata.state.position.y,
      user.cdata.state.position.z, user.cdata.state.heading)
  end

  if user.cdata.state.customization then -- customization
    self.remote.setCustomization(user.source, user.cdata.state.customization)
  end
  
  if user.cdata.state.weapons then -- Weapons
    vRP.EXT.Weapon.remote._giveWeapons(user.source,user.source,user.cdata.state.weapons or {},true)
  end
  
  if user.cdata.state.components then -- Components
    vRP.EXT.Weapon.remote._giveComponents(user.source,user.source,user.cdata.state.components or {},true)
  end


  if user.cdata.state.health then -- health
    self.remote.setHealth(user.source, user.cdata.state.health)
  end

  self.remote._setStateReady(user.source, true)

  vRP:triggerEvent("playerStateLoaded", user)
end

function PlayerState.event:playerDeath(user)
  user.cdata.state.position = nil
  user.cdata.state.heading = nil
  user.cdata.state.health = nil
  user.cdata.state.weapons = nil
  user.cdata.state.components = nil
end

function PlayerState.event:characterLoad(user)
  if not user.cdata.state then
    user.cdata.state = {}
  end
end

function PlayerState.event:characterUnload(user)
  self.remote._setStateReady(user.source, false)
end

-- TUNNEL
PlayerState.tunnel = {}

function PlayerState.tunnel:update(state)
  local user = vRP.users_by_source[source]
  if user and user:isReady() then
    for k, v in pairs(state) do
      user.cdata.state[k] = v
    end
	
	--print('Update State')

    vRP:triggerEvent("playerStateUpdate", user, state)
  end
end

vRP:registerExtension(PlayerState)