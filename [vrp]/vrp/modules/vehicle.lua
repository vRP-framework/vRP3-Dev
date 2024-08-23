-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.vehicle then return end

local lang = vRP.lang

local Vehicle = class("Vehicle", vRP.Extension)

function Vehicle:__construct()
  vRP.Extension.__construct(self)

end

vRP:registerExtension(Vehicle)