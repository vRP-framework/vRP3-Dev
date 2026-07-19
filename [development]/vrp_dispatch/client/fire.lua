local Fire = class("Fire", vRP.Extension)
local cfg = module("vrp_dispatch", "cfg/fire")

function Fire:__construct()
	vRP.Extension.__construct(self)

  print("Fire extension loaded.")
end

-- Tunnel interface
Fire.tunnel = {}


vRP:registerExtension(Fire)