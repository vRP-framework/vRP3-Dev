if Config.Framework ~= Config.FrameworkId.VRP2 then
    return
end

local function init()
	load(LoadResourceFile('vrp', 'lib/utils.lua'))()
	local Proxy = module('vrp', 'lib/Proxy')
	local vRP = Proxy.getInterface('vRP')
	vRP.loadScript(GetCurrentResourceName(), 'client')
	return Proxy.getInterface('vRP.EXT.Bridge')
end
local vRP = init()

Bridge = {}

function Bridge.notify(message)
	vRP.notify(message)
end