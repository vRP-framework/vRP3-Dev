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
	local r = {}
	local px,py,pz = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
	
	for _,pedAI in ipairs(GetGamePool('CPed')) do
		if pedAI ~= GetPlayerPed(-1) then
			local x,y,z = table.unpack(GetEntityCoords(pedAI))
			local dist = GetDistanceBetweenCoords(x,y,z,px,py,pz,true)
			if dist <= radius then
				r[pedAI] = dist
			end
		end
	end
	
	return r
end

function Misc:getClosestPed(radius)	--gets closest ped
	local p = nil
	
	local ai = self:getClosestPeds(radius)
	local min = radius+10.0
	for k,v in pairs(ai) do
		if v < min then
		  min = v
		  p = k
		end
	end
	
	return p
end

function Misc:getClosestObjects(radius) -- gets all nearby objects
	local r = {}
	local px,py,pz = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
	
	for _,obj in ipairs(GetGamePool('CObject')) do
		if obj ~= GetPlayerPed(-1) then
			local x,y,z = table.unpack(GetEntityCoords(obj))
			local dist = GetDistanceBetweenCoords(x,y,z,px,py,pz,true)
			if dist <= radius then
				r[obj] = dist
			end
		end
	end
	
	return r
end

function Misc:getClosestObject(radius)	--gets closest object
	local p = nil
	
	local obj = self:getClosestObjects(radius)
	local min = radius+10.0
	for k,v in pairs(obj) do
		if v < min then
		  min = v
		  p = k
		end
	end
	
	return p
end

Misc.tunnel = {}

Misc.tunnel.getEntity = Misc.getEntity
Misc.tunnel.getClosestObject = Misc.getClosestObject
Misc.tunnel.getClosestObjects = Misc.getClosestObjects
Misc.tunnel.getClosestPed = Misc.getClosestPed
Misc.tunnel.getClosestPeds = Misc.getClosestPeds

vRP:registerExtension(Misc)