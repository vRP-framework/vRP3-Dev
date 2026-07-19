-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.map then return end

local Map = class("Map", vRP.Extension)

-- SUBCLASS

Map.User = class("User")

function Map.User:__construct()
  self.map_areas = {}
end

-- create/update a player area
-- cb_enter(user, name): (optional) called when entering the area
-- cb_leave(user, name): (optional) called when leaving the area
function Map.User:setArea(name,x,y,z,radius,height,cb_enter,cb_leave)
	if not name then return end -- Check for valid area name
  self:removeArea(name)
  self.map_areas[name] = {enter=cb_enter,leave=cb_leave}
  vRP.EXT.Map.remote._setArea(self.source,name,x,y,z,radius,height)
end

function Map.User:removeArea(name)
  -- delete local area
  local area = self.map_areas[name] 
  if area then
    -- delete remote area
    vRP.EXT.Map.remote._removeArea(self.source,name)

    if area.inside and area.leave then
      area.leave(self, name)
    end

    self.map_areas[name] = nil
  end
end

function Map.User:inArea(name)
  return self.map_areas[name] and self.map_areas[name].inside or false
end

-- METHODS

function Map:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("vrp", "cfg/map")
  -- copy only the small parts we need and free the cfg to save memory
  self.entities = self.cfg.entities
  self:log(#self.entities.." entities")
  self.cfg = nil
end

-- EVENT

Map.event = {}

function Map.event:playerLeave(user)
  -- leave areas
  for name, area in pairs(user.map_areas) do
    if area.inside and area.leave then
      area.leave(user, name)
    end
    user.map_areas[name] = nil -- Clear references to prevent memory leaks
  end
end

function Map.event:playerSpawn(user, first_spawn)
  -- add additional entities
  if first_spawn then
    local remote = self.remote
    local source = user.source
    for _, entdef in ipairs(self.entities) do
      remote._addEntity(source, entdef[1], entdef[2]) -- Use a single remote reference
    end
  end
end

-- TUNNEL

Map.tunnel = {}

function Map.tunnel:enterArea(name)
  local user = vRP.users_by_source[source]

  if user and user:isReady() then
    local area = user.map_areas[name] 
    if area and not area.inside then -- trigger enter callback
      area.inside = true
      if area.enter then
        area.enter(user,name)
      end
    end
  end
end

function Map.tunnel:leaveArea(name)
  local user = vRP.users_by_source[source]

  if user and user:isReady() then
    local area = user.map_areas[name] 
    if area and area.inside then -- trigger enter callback
      area.inside = false
      if area.leave then
        area.leave(user,name)
      end
    end
  end
end

vRP:registerExtension(Map)
