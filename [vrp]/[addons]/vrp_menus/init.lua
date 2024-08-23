local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

local vRP = Proxy.getInterface("vRP")
local init = module("vrp_menus" , "cfg/components")

async(function()
	-- Define a list of scripts to load in the desired order
	local loadOrder = {"base", "admin", "identity"}

	-- Load scripts in the specified order
	for _, scriptName in ipairs(loadOrder) do
		if init[scriptName] then
			vRP.loadScript("vrp_menus", "menus/" .. scriptName)
		end
	end

	-- Load the remaining scripts that are not explicitly ordered
	for k, v in pairs(init) do
		if not (k == "base" or k == "admin" or k == "identity") then
			vRP.loadScript("vrp_menus", "menus/" .. k)
		end
	end
end)