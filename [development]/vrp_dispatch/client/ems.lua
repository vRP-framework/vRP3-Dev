Tunnel = module("vrp", "lib/Tunnel")
Proxy = module("vrp", "lib/Proxy")

local cvRP = module("vrp", "client/vRP")
vRP = cvRP() -- instantiate vRP

local pvRP = {}
-- load script in vRP context
function pvRP.loadScript(resource, path)
  module(resource, path)
end

Proxy.addInterface("vRP", pvRP)

local EMS = class("EMS", vRP.Extension)
local cfg = module("vrp_dispatch", "cfg/ems")

function EMS:__construct()
	vRP.Extension.__construct(self)

  print("EMS extension loaded.")
end

-- Tunnel interface
EMS.tunnel = {}

vRP:registerExtension(EMS)