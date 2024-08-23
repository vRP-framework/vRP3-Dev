-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.misc then return end

local Misc = class("Misc", vRP.Extension)

function Misc:__construct()
  vRP.Extension.__construct(self)
end

function Misc:getEntity() -- checks if entity is ped or not
  local ped = GetPlayerPed(-1)
  if IsPedInAnyVehicle(ped, false) then
    entity = GetVehiclePedIsIn(ped, false)
  else
    entity = ped
  end
	
  return entity
end

function Misc:getClosestPeds(radius) -- gets all nearby ped
	local playerCoords = GetEntityCoords(GetPlayerPed(-1))
	local nearbyPeds = {}
	local peds = GetGamePool('CPed') -- Get all peds in the game world

	for _, ped in ipairs(peds) do
			if ped ~= GetPlayerPed(-1) then -- Avoid comparing the player Ped with itself
					local pedCoords = GetEntityCoords(ped)
					local distance = Vdist(playerCoords, pedCoords)

					if distance <= radius then
							table.insert(nearbyPeds, ped)
					end
			end
	end

	return nearbyPeds
end

function Misc:getClosestPed(radius)	--gets closest ped
	local playerCoords = GetEntityCoords(GetPlayerPed(-1))
	local nearbyPeds = getNearbyPeds(radius)
	local closestPed = nil
	local closestDistance = radius

	for _, ped in ipairs(nearbyPeds) do
			local pedCoords = GetEntityCoords(ped)
			local distance = Vdist(playerCoords, pedCoords)

			if distance < closestDistance then
					closestDistance = distance
					closestPed = ped
			end
	end

	return closestPed
end

function Misc:getClosestObjects(radius) -- gets all nearby objects
	local playerCoords = GetEntityCoords(GetPlayerPed(-1))
	local nearbyObjects = {}
	local objects = GetGamePool('CObject') -- Get all objects in the game world

	for _, object in ipairs(objects) do
		local objectCoords = GetEntityCoords(object)
		local distance = Vdist(playerCoords, objectCoords)

		if distance <= tonumber(radius) then
			local modelHash = GetEntityModel(object)
			table.insert(nearbyObjects, {hash = modelHash, coords = objectCoords})
		end
	end

	return nearbyObjects
end

function Misc:getClosestObject(radius)	--gets closest object
	local playerCoords = GetEntityCoords(GetPlayerPed(-1))
	local nearbyObjects = getNearbyObjects(playerPed, radius)
	local closestObject = nil
	local closestDistance = radius

	for _, object in ipairs(nearbyObjects) do
		local objectCoords = GetEntityCoords(object)
		local distance = Vdist(playerCoords, objectCoords)

		if distance < closestDistance then
			closestDistance = distance
			closestObject = object
		end
	end

	return closestObject
end

Misc.tunnel = {}

Misc.tunnel.getEntity = Misc.getEntity
Misc.tunnel.getClosestObject = Misc.getClosestObject
Misc.tunnel.getClosestObjects = Misc.getClosestObjects
Misc.tunnel.getClosestPed = Misc.getClosestPed
Misc.tunnel.getClosestPeds = Misc.getClosestPeds

vRP:registerExtension(Misc)