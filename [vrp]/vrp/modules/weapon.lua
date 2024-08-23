-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.weapon then return end

local lang = vRP.lang

local Weapon = class("Weapon", vRP.Extension)

function Weapon:__construct()
  vRP.Extension.__construct(self)

  self.cfg = module("vrp", "cfg/weapon")
end

vRP:registerExtension(Weapon)