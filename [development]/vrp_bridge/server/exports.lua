local CURRENT_RESOURCE = GetCurrentResourceName()
local Config = module(CURRENT_RESOURCE,"cfg/cfg")

-------------------
--   validate    --
-------------------
local function validateResource()
	local resource = GetInvokingResource()

	-- allow internal calls
	if not resource or resource == CURRENT_RESOURCE then
		return true
	end

	-- explicitly allowed resources
	if Config.AllowedResources[resource] then
		return true
	end

	-- optional auto-trust vrp_* resources
	if Config.AllowVRPResources and resource:sub(1,4) == "vrp_" then
		return true
	end

	-- ACE permission fallback
	if IsPrincipalAceAllowed("resource." .. resource, "vrp_bridge") then
		return true
	end

	if Config.DebugSecurity then
		print(("^1 Unauthorized export access from: %s^7"):format(resource))
	end

	return false
end

-------------------
-- 		Warapper 	 --
-------------------
local function secureExport(fn)
	return function(...)
		if not validateResource() then return nil end
		return fn(...)
	end
end

-------------------
-- Notifications --
-------------------
exports('notify', secureExport(function(source, message)
	source = tonumber(source)
	TriggerClientEvent(EVENTS.SHOW_NOTIFICATION, source, message)
end))

---------------
-- Character --
---------------
exports('getCharacterName', secureExport(function(source)
	source = tonumber(source)
	local firstName, lastName = Bridge.getCharacterName(source)
	return firstName, lastName
end))

---------------
-- Inventory --
---------------
exports('getItemAmount', secureExport(function(source, itemName)
	source = tonumber(source)
	return Bridge.getItemAmount(source, itemName)
end))

exports('addItem', secureExport(function(source, itemName, amount)
	source = tonumber(source)
	amount = tonumber(amount) or 1
	if amount <= 0 then
		return false
	end

	local expectedAmount = Bridge.getItemAmount(source, itemName) + amount
	Bridge.addItem(source, itemName, amount)

	return Bridge.getItemAmount(source, itemName) == expectedAmount
end))

exports('removeItem', secureExport(function(source, itemName, amount)
	source = tonumber(source)
	amount = tonumber(amount) or 1
	if amount <= 0 then
		return false
	end
	
	if Bridge.getItemAmount(source, itemName) < amount then
		return false
	end
	
	local expectedAmount = Bridge.getItemAmount(source, itemName) - amount
	Bridge.removeItem(source, itemName, amount)

	return Bridge.getItemAmount(source, itemName) == expectedAmount
end))

exports('registerItem', secureExport(function(item, name, description)
	return Bridge.registerItem(item, name, description)
end))

-----------
-- Cash --
-----------
exports('getWallet', secureExport(function(source)
	return Bridge.getWallet(source)
end))

exports('addCash', secureExport(function(source, amount)
	source, amount = tonumber(source), tonumber(amount)
	if amount <= 0 then return false end
	return Bridge.addCash(source, amount)
end))

exports('removeCash', secureExport(function(source, amount)
	source, amount = tonumber(source), tonumber(amount)
	if amount <= 0 then return false end
	if Bridge.getWallet(source) < amount then return false end
	return Bridge.removeCash(source, amount)
end))

-----------
-- Bank --
-----------
exports('getBank', secureExport(function(source)
	return Bridge.getBank(source)
end))

exports('addBank', secureExport(function(source, amount)
	source, amount = tonumber(source), tonumber(amount)
	if amount <= 0 then return false end
	return Bridge.addBank(source, amount)
end))

exports('removeBank', secureExport(function(source, amount)
	source, amount = tonumber(source), tonumber(amount)
	if amount <= 0 then return false end
	if Bridge.getBank(source) < amount then return false end
	return Bridge.removeBank(source, amount)
end))

-----------
-- Job --
-----------
exports('getJob', secureExport(function(source)
	return Bridge.getJob(source) or ''
end))