-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.vehicle then return end

local Vehicle = class("Vehicle", vRP.Extension)
-- METHODS

function Vehicle:__construct()
  vRP.Extension.__construct(self)
end

-- TUNNEL
Vehicle.tunnel = {}


vRP:registerExtension(Vehicle)