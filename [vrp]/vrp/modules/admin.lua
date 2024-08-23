-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.admin then return end

local htmlEntities = module("lib/htmlEntities")
local lang = vRP.lang
local Admin = class("Admin", vRP.Extension)
-- PRIVATE METHODS

function Admin:emote(menu, upper)
	local user = menu.user
    local content = user:prompt(lang.admin.custom_upper_emote.prompt(),"")
    local seq = {}
    for line in string.gmatch(content,"[^\n]+") do
      local args = {}
      for arg in string.gmatch(line,"[^%s]+") do
        table.insert(args,arg)
      end

      table.insert(seq,{args[1] or "", args[2] or "", args[4] or 1})
    end

    vRP.EXT.Base.remote._playAnim(user.source, upper, seq, false)
end

function Admin:__construct()
  vRP.Extension.__construct(self)
end

vRP:registerExtension(Admin)