local function registerExtension(extensionName)
	local extension = class(extensionName, vRP.Extension)

	extension.event = {}
	extension.tunnel = {}
	extension.proxy = {}

	function extension:__construct()
		vRP.Extension.__construct(self)
	end

	function extension.proxy:getIdentity(playerId)
		local user = vRP.users_by_source[playerId]
		return vRP.EXT.Identity:getIdentity(user.cid)
	end

	function extension.proxy:registerItem(item, name, description)
		vRP.EXT.Inventory:defineItem(item, name, description, nil, 0.05)
	end

	function extension.proxy:getItemAmount(playerId, item)
		local user = vRP.users_by_source[playerId]
		return user:getItemAmount(item)
	end

	function extension.proxy:tryTakeItem(playerId, item, amount)
		local user = vRP.users_by_source[playerId]
		return user:tryTakeItem(item, amount)
	end

	function extension.proxy:tryGiveItem(playerId, item, amount)
		local user = vRP.users_by_source[playerId]
		return user:tryGiveItem(item, amount)
	end

	function extension.proxy:getWallet(playerId, amount)
		local user = vRP.users_by_source[playerId]
		return user:getWallet()
	end

	function extension.proxy:giveWallet(playerId, amount)
		local user = vRP.users_by_source[playerId]
		user:giveWallet(amount)
		return true
	end

	function extension.proxy:tryPayment(playerId, amount)
		local user = vRP.users_by_source[playerId]
		return user:tryPayment(amount)
	end

	function extension.proxy:getGroupByType(playerId, amount)
		local user = vRP.users_by_source[playerId]
		return user:getGroupByType('job')
	end

	vRP:registerExtension(extension)
end
registerExtension('Bridge')