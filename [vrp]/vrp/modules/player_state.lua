-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.player_state then return end

local lang = vRP.lang

local PlayerState = class("PlayerState", vRP.Extension)

-- PRIVATE METHODS

-- menu: admin
local function menu_admin(self)	
	vRP.EXT.GUI:registerMenuBuilder("admin", function(menu)
    local user = menu.user
    if user:hasPermission("player.custom_model") then
      menu:addOption(lang.admin.custom_model.title(), function()
        local model = user:prompt(lang.admin.custom_model.prompt(), "")
				
        if model and #model > 0 then
          local hash = tonumber(model)
          local custom = { modelhash = hash or GetHashKey(model) }
          self.remote._setCustomization(user.source, custom)
        end
      end)
    end
  end)
end

-- METHODS

function PlayerState:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("vrp", "cfg/player_state")

  -- copy only required cfg fields and free cfg to reduce memory
  self.update_interval = self.cfg.update_interval
  self.update_multiplyer = self.cfg.update_multiplyer
  self.mp_models = self.cfg.mp_models
  self.default_customization = self.cfg.default_customization
  self.spawn_enabled = self.cfg.spawn_enabled
  self.spawn_position = self.cfg.spawn_position
  self.spawn_radius = self.cfg.spawn_radius
  self.cfg = nil

  menu_admin(self)
end

-- EVENT

PlayerState.event = {}

function PlayerState.event:playerSpawn(user, first_spawn)
  self.remote._setStateReady(user.source, false)
  
  if first_spawn then
    self.remote._setConfig(user.source, self.update_interval, self.update_multiplyer, self.mp_models)
  end

  -- Default position and customization setup
	if not user.cdata.state.customization then
    user.cdata.state.customization = self.default_customization
  end
	
  if not user.cdata.state.position and self.spawn_enabled then
    user.cdata.state.position = {
      x = self.spawn_position[1] + math.random() * self.spawn_radius * 2 - self.spawn_radius,
      y = self.spawn_position[2] + math.random() * self.spawn_radius * 2 - self.spawn_radius,
      z = self.spawn_position[3]
    }
  end
	
	-- Teleport, customize, health, weapons and components
  local pos = user.cdata.state.position
  if pos then 
		vRP.EXT.Base.remote.teleport(user.source, pos.x, pos.y, pos.z, user.cdata.state.heading) 
	end
	
  if user.cdata.state.customization then 
		self.remote.setCustomization(user.source, user.cdata.state.customization) 
	end
	
  if user.cdata.state.health then 
		self.remote.setHealth(user.source, user.cdata.state.health) 
	end
  
  if user.cdata.state.weapons then -- Weapons
    if vRP.EXT and vRP.EXT.Weapon and vRP.EXT.Weapon.remote and vRP.EXT.Weapon.remote._giveWeapons then
      vRP.EXT.Weapon.remote._giveWeapons(user.source,user.source,user.cdata.state.weapons or {},true)
    end
  end
  
  if user.cdata.state.components then -- Components
    if vRP.EXT and vRP.EXT.Weapon and vRP.EXT.Weapon.remote and vRP.EXT.Weapon.remote._giveComponents then
      vRP.EXT.Weapon.remote._giveComponents(user.source,user.source,user.cdata.state.components or {},true)
    end
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
  user.cdata.state = user.cdata.state or {}
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

function PlayerState:performGC()
  -- prune empty per-user `cdata.state` tables to reduce retained per-user keys
  if type(_G.vRP) ~= "table" or type(vRP.users) ~= "table" then return end
  for _, user in pairs(vRP.users) do
    if user and user.cdata and user.cdata.state then
      local empty = true
      for k, v in pairs(user.cdata.state) do
        if v ~= nil then empty = false; break end
      end
      if empty then user.cdata.state = nil end
    end
  end
end

vRP:registerExtension(PlayerState)
