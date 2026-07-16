local function registerExtension(extensionName)
	local extension = class(extensionName, vRP.Extension)

	extension.event = {}
	extension.tunnel = {}
	extension.proxy = {}

	function extension:__construct()
		vRP.Extension.__construct(self)
	end

	function extension.proxy:registerItem(item, name, description)
		vRP.EXT.Inventory:defineItem(item, name, description, nil, 0.05)
	end

	function extension.proxy:getItemAmount(source, item)
		local user = vRP.users_by_source[source]
		return user:getItemAmount(item)
	end

	function extension.proxy:tryTakeItem(source, item, amount)
		local user = vRP.users_by_source[source]
		return user:tryTakeItem(item, amount)
	end

	function extension.proxy:tryGiveItem(source, item, amount)
		local user = vRP.users_by_source[source]
		return user:tryGiveItem(item, amount)
	end

	-- Cash
	function extension.proxy:getWallet(source)
		local user = vRP.users_by_source[source]
		return user:getWallet()
	end

	function extension.proxy:addCash(source, amount)
		local user = vRP.users_by_source[source]

		return user:giveWallet(amount)
	end

	function extension.proxy:removeCash(source, amount)
		local user = vRP.users_by_source[source]
		return user:tryPayment(amount)
	end
	
	-- Bank
	function extension.proxy:getBank(source)
		local user = vRP.users_by_source[source]
		return user:getBank()
	end

	function extension.proxy:addBank(source, amount)
		local user = vRP.users_by_source[source]
		return user:giveBank(amount)
	end

	function extension.proxy:removeBank(source, amount)
		local user = vRP.users_by_source[source]
		return user:tryWithdraw(amount)
	end

	-- job
	function extension.proxy:getJob(source, gtype)
		local user = vRP.users_by_source[source]
		local title = user:getGroupByType("job")
		
		if not user:hasGroup(gtype) then
			user:addGroup("citizen")
		end

		return vRP.EXT.Group:getGroupTitle(title)
	end
	
	-- Name
	function extension.proxy:getIdentity(source)
		local user = vRP.users_by_source[source]
		return vRP.EXT.Identity:getIdentity(user.cid)
	end
	
	-- events
	function extension.event:playerSpawn(user, first_spawn)
		if first_spawn then
			print("[DEBUG] first spawn")
		
		end
	end

	function extension.event:playerDeath(user)
		print("[DEBUG] player Death")
	
	end
	
	function extension.event:playerLeave(user)
		if user then
			print("[DEBUG] player Leave")
			
		end
	end

	vRP:registerExtension(extension)
end

registerExtension('Bridge')