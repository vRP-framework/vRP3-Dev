local EMS = class("EMS", vRP.Extension)
local cfg = module("vrp_dispatch", "cfg/ems")

function EMS:__construct()
	vRP.Extension.__construct(self)

  print("EMS extension loaded.")
end

-- Tunnel interface
EMS.tunnel = {}

vRP:registerExtension(EMS)