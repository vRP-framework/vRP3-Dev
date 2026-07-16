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

local Fire = class("Fire", vRP.Extension)
local cfg = module("vrp_dispatch", "cfg/fire")

function Fire:__construct()
	vRP.Extension.__construct(self)

  print("Fire extension loaded.")
end

-- Tunnel interface
Fire.tunnel = {}


vRP:registerExtension(Fire)