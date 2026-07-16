if Config.Framework ~= Config.FrameworkId.VRP1 then
    return
end

local frameworkFolder = 'vrp'
local function init()
	load(LoadResourceFile(frameworkFolder, 'lib/utils.lua'))()
	local Proxy = module(frameworkFolder, "lib/Proxy")
	return Proxy.getInterface("vRP")
end

local vRP = init()

Framework = {}

function Framework.getCharacterName(playerId)
	local userId = vRP.getUserId(playerId)
	local identityPromise = promise.new()
	local identity = vRP.getUserIdentity(userId)
	return identity.firstname, identity.name
end

function Framework.getItemAmount(playerId, name)
	local userId = vRP.getUserId(playerId)
	return vRP.getInventoryItemAmount(userId, name)
end

function Framework.removeItem(playerId, name, amount)
	local userId = vRP.getUserId(playerId)
	vRP.tryGetInventoryItem(userId, name, amount, true)
end

function Framework.addItem(playerId, name, amount)
	local userId = vRP.getUserId(playerId)
	vRP.giveInventoryItem(userId, name, amount, true)
end

function Framework.getMoneyAmount(playerId)
	local userId = vRP.getUserId(playerId)
	return vRP.getMoney(userId)
end

function Framework.removeMoney(playerId, amount)
	local userId = vRP.getUserId(playerId)
	vRP.tryPayment(userId, amount)
end

function Framework.addMoney(playerId, amount)
	local userId = vRP.getUserId(playerId)
	vRP.giveMoney(userId, amount)
end

function Framework.getJob(playerId)
	return vRP.getUserGroupByType(playerId, 'job')
end