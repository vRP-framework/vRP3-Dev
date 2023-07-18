-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

-- Client

if not vRP.modules.player_state then return end

local PlayerState = class("PlayerState", vRP.Extension)

-- METHODS

function PlayerState:__construct()
  vRP.Extension.__construct(self)

  self.state_ready = false
  self.update_interval = 30
  self.mp_models = {} -- map of model hash

  -- update task
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(self.update_interval * 1000)

      if self.state_ready then
        local x, y, z = vRP.EXT.Base:getPosition()
        self.remote._update({
          position = { x = x, y = y, z = z },
          heading = GetEntityHeading(GetPlayerPed(-1)),
          customization = self:getCustomization(),
          health = self:getHealth(),
          weapons = vRP.EXT.Weapon:getWeapons(),
          components = vRP.EXT.Weapon:getComponents(),
        })
      end
    end
  end)
end

-- amount: 100-200 ?
function PlayerState:setHealth(amount)
  SetEntityHealth(GetPlayerPed(-1), math.floor(amount))
end

function PlayerState:getHealth()
  return GetEntityHealth(GetPlayerPed(-1))
end

-- PLAYER CUSTOMIZATION

-- get number of drawables for a specific part
function PlayerState:getDrawables(part)
  local args = splitString(part, ":")
  local index = parseInt(args[2])

  if args[1] == "prop" then
    return GetNumberOfPedPropDrawableVariations(GetPlayerPed(-1), index)
  elseif args[1] == "drawable" then
    return GetNumberOfPedDrawableVariations(GetPlayerPed(-1), index)
  elseif args[1] == "overlay" then
    return GetNumHeadOverlayValues(index)
  end
end

-- get number of textures for a specific part and drawable
function PlayerState:getDrawableTextures(part, drawable)
  local args = splitString(part, ":")
  local index = parseInt(args[2])

  if args[1] == "prop" then
    return GetNumberOfPedPropTextureVariations(GetPlayerPed(-1), index, drawable)
  elseif args[1] == "drawable" then
    return GetNumberOfPedTextureVariations(GetPlayerPed(-1), index, drawable)
  end
end

-- get player skin customization
-- return custom parts
function PlayerState:getCustomization()
  local ped = GetPlayerPed(-1)

  local custom = {}

  custom.modelhash = GetEntityModel(ped)

  -- ped parts
  for i = 0, 20 do -- index limit to 20
    custom["drawable:" .. i] = { GetPedDrawableVariation(ped, i), GetPedTextureVariation(ped, i),
      GetPedPaletteVariation(ped, i) }
  end

  -- props
  for i = 0, 10 do -- index limit to 10
    custom["prop:" .. i] = { GetPedPropIndex(ped, i), math.max(GetPedPropTextureIndex(ped, i), 0) }
  end

  custom.hair_color = { GetPedHairColor(ped), GetPedHairHighlightColor(ped) }

  for i = 0, 12 do
    local ok, index, ctype, pcolor, scolor, opacity = GetPedHeadOverlayData(ped, i)
    if ok then
      custom["overlay:" .. i] = { index, pcolor, scolor, opacity }
    end
  end

  return custom
end

-- set partial customization (only what is set is changed)
-- custom: indexed customization parts ("foo:arg1:arg2...")
--- "modelhash": number, model hash
--- or "model": string, model name
--- "drawable:<index>": {drawable,texture,palette} ped components
--- "prop:<index>": {prop_index, prop_texture}
--- "hair_color": {primary, secondary}
--- "overlay:<index>": {overlay_index, primary color, secondary color, opacity}
function PlayerState:setCustomization(custom)
  local r = async()

  Citizen.CreateThread(function() -- new thread
    if custom then
      local ped = GetPlayerPed(-1)
      local mhash = nil

      -- model
      if custom.modelhash then
        mhash = custom.modelhash
      elseif custom.model then
        mhash = GetHashKey(custom.model)
      end

      if mhash then
        local i = 0
        while not HasModelLoaded(mhash) and i < 10000 do
          RequestModel(mhash)
          Citizen.Wait(10)
        end

        if HasModelLoaded(mhash) then
          -- changing player model remove armour and health, so save it

          vRP:triggerEventSync("playerModelSave")

          local health = self:getHealth()
          --local weapons = vRP.EXT.Weapon:getWeapons()
          --local components = vRP.EXT.Weapon:getComponents()

          SetPlayerModel(PlayerId(), mhash)

          self:setHealth(health)
          --vRP.EXT.Weapon:giveWeapons(weapons,true)
          --vRP.EXT.Weapon:getComponents(components)

          vRP:triggerEventSync("playerModelRestore")

          SetModelAsNoLongerNeeded(mhash)
        end
      end

      ped = GetPlayerPed(-1)

      local is_mp = self.mp_models[GetEntityModel(ped)]

      if is_mp then
        -- face blend data
        local face = (custom["drawable:0"] and custom["drawable:0"][1]) or GetPedDrawableVariation(ped, 0)
        SetPedHeadBlendData(ped, face, face, 0, face, face, 0, 0.5, 0.5, 0.0, false)
      end

      -- drawable, prop, overlay
      for k, v in pairs(custom) do
        local args = splitString(k, ":")
        local index = parseInt(args[2])

        if args[1] == "prop" then
          if v[1] < 0 then
            ClearPedProp(ped, index)
          else
            SetPedPropIndex(ped, index, v[1], v[2], true)
          end
        elseif args[1] == "drawable" then
          SetPedComponentVariation(ped, index, v[1], v[2], v[3] or 2)
        elseif args[1] == "overlay" and is_mp then
          local ctype = 0
          if index == 1 or index == 2 or index == 10 then ctype = 1
          elseif index == 5 or index == 8 then ctype = 2 end

          SetPedHeadOverlay(ped, index, v[1], v[4] or 1.0)
          SetPedHeadOverlayColor(ped, index, ctype, v[2] or 0, v[3] or 0)
        end
      end

      if custom.hair_color and is_mp then
        SetPedHairColor(ped, table.unpack(custom.hair_color))
      end
    end

    r()
  end)

  return r:wait()
end

-- EVENT

PlayerState.event = {}

function PlayerState.event:playerDeath()
  self.state_ready = false
end

-- TUNNEL
PlayerState.tunnel = {}

function PlayerState.tunnel:setStateReady(state)
  self.state_ready = state
end

function PlayerState.tunnel:setConfig(update_interval, mp_models)
  self.update_interval = update_interval

  for _, model in pairs(mp_models) do
    local hash
    if type(model) == "string" then
      hash = GetHashKey(model)
    else
      hash = model
    end

    self.mp_models[hash] = true
  end
end

PlayerState.tunnel.setHealth = PlayerState.setHealth
PlayerState.tunnel.getHealth = PlayerState.getHealth
PlayerState.tunnel.getDrawables = PlayerState.getDrawables
PlayerState.tunnel.getDrawableTextures = PlayerState.getDrawableTextures
PlayerState.tunnel.getCustomization = PlayerState.getCustomization
PlayerState.tunnel.setCustomization = PlayerState.setCustomization

vRP:registerExtension(PlayerState)