-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.banking then return end

local lang = vRP.lang
local Banking = class("Banking", vRP.Extension)

-- METHODS
function Banking:__construct()
  vRP.Extension.__construct(self)
  
  self.cfg = module("cfg/banking")
  self:log(#self.cfg.banks.." banks")
	  
end

-- EVENT
Banking.event = {}

function Banking.event:playerSpawn(user, first_spawn)
  if first_spawn then 
    local menu
    local function enter(user)
      menu = user:openMenu("Bank")
    end

    local function leave(user)
      user:closeMenu(menu)
    end

    for k,v in pairs(self.cfg.banks) do
      local x,y,z = table.unpack(v)

      local ment = clone(self.cfg.marker)
      ment[2].title = lang.bank.title()
      ment[2].pos = {x,y,z-1}
      vRP.EXT.Map.remote._addEntity(user.source,ment[1],ment[2])

      user:setArea("vRP:bank:"..k,x,y,z,1,1.5,enter,leave)
    end
  end
end


vRP:registerExtension(Banking)