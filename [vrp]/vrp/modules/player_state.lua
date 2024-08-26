-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.player_state then return end

local lang = vRP.lang

local PlayerState = class("PlayerState", vRP.Extension)

-- METHODS

function PlayerState:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("vrp", "cfg/player_state")
	
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

  -- default position
  if not user.cdata.state.position and self.cfg.spawn_enabled then
    local x = self.cfg.spawn_position[1]+math.random()*self.cfg.spawn_radius*2-self.cfg.spawn_radius
    local y = self.cfg.spawn_position[2]+math.random()*self.cfg.spawn_radius*2-self.cfg.spawn_radius
    local z = self.cfg.spawn_position[3]
    user.cdata.state.position = {x=x,y=y,z=z}
  end

  if user.cdata.state.position then -- teleport to saved pos
    vRP.EXT.Base.remote.teleport(user.source,user.cdata.state.position.x,user.cdata.state.position.y,user.cdata.state.position.z, user.cdata.state.heading)
  end

  if user.cdata.state.customization then -- customization
    self.remote.setCustomization(user.source,user.cdata.state.customization) 
  end

  if user.cdata.state.weapons then -- weapons
    vRP.EXT.Weapon.remote.giveWeapons(user.source,user.cdata.state.weapons or {},true)
  end

  if user.cdata.state.health then -- health
    self.remote.setHealth(user.source,user.cdata.state.health)
  end

  if user.cdata.state.armour then -- armour
    self.remote.setArmour(user.source,user.cdata.state.armour)
  end

  self.remote._setStateReady(user.source, true)
	
	vRP:log("should trigger playerStateLoaded")
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

    vRP:triggerEvent("playerStateUpdate", user, state)
  end
end

vRP:registerExtension(PlayerState)