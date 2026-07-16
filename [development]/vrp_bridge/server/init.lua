local function init()
	load(LoadResourceFile('vrp', 'lib/utils.lua'))()
	local Proxy = module('vrp', 'lib/Proxy')
	local vRP = Proxy.getInterface('vRP')
	vRP.loadScript(GetCurrentResourceName(), 'server')
	return Proxy.getInterface('vRP.EXT.Bridge')
end

local vRP = init()

Bridge = {}

-- items
function Bridge.getItemAmount(source, extensionName)
	return vRP.getItemAmount(source, extensionName)
end

function Bridge.removeItem(source, extensionName, amount)
	return vRP.tryTakeItem(source, extensionName, amount)
end

function Bridge.addItem(source, extensionName, amount)
	return vRP.tryGiveItem(source, extensionName, amount)
end

-- Cash
function Bridge.getWallet(source)
	return vRP.getWallet(source)
end

function Bridge.removeCash(source, amount)
	return vRP.removeCash(source, amount)
end

function Bridge.addCash(source, amount)
	return vRP.addCash(source, amount)
end

-- Bank
function Bridge.getBank(source)
	local source = source
	return vRP.getBank(source)
end

function Bridge.removeBank(source, amount)
	return vRP.removeBank(source, amount)
end

function Bridge.addBank(source, amount)
	return vRP.addBank(source, amount)
end

-- Job

function Bridge.getJob(source)
	return vRP.getJob(source, 'job')
end

-- name
function Bridge.getCharacterName(source)
	local identity = vRP.getIdentity(source)
	return identity
end