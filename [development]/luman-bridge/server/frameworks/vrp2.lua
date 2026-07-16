if Config.Framework ~= Config.FrameworkId.VRP2 then 
	return 
end

local function init()
	load(LoadResourceFile('vrp', 'lib/utils.lua'))()
	local Proxy = module('vrp', 'lib/Proxy')
	local vRP = Proxy.getInterface('vRP')
	vRP.loadScript(GetCurrentResourceName(), 'server/frameworks/modules/vrp2_extension')
	return Proxy.getInterface('vRP.EXT.Bridge')
end
local vRP2 = init()

Bridge = {}

function Bridge.getCharacterName(playerId)
	local identity = vRP2.getIdentity(playerId)
	return identity.firstname, identity.name
end

function Bridge.getItemAmount(playerId, extensionName)
	return vRP2.getItemAmount(playerId, extensionName)
end

function Bridge.removeItem(playerId, extensionName, amount)
	return vRP2.tryTakeItem(playerId, extensionName, amount)
end

function Bridge.addItem(playerId, extensionName, amount)
	return vRP2.tryGiveItem(playerId, extensionName, amount)
end

function Bridge.getMoneyAmount(playerId)
	local playerId = playerId or 1
	return vRP2.getWallet(playerId)
end

function Bridge.removeMoney(playerId, amount)
	return vRP2.tryPayment(playerId, amount)
end

function Bridge.addMoney(playerId, amount)
	return vRP2.giveWallet(playerId, amount)
end

function Bridge.getJob(playerId)
	return vRP2.getGroupByType(playerId, 'job')
end