-------------------
-- Notifications --
-------------------
exports('notify', function(playerId, message)
	playerId = tonumber(playerId) or 1
	TriggerClientEvent(EVENTS.SHOW_NOTIFICATION, playerId, message)
end)

---------------
-- Character --
---------------
exports('getCharacterName', function(playerId)
	playerId = tonumber(playerId)
	local firstName, lastName = Bridge.getCharacterName(playerId)
	return firstName, lastName
end)

---------------
-- Inventory --
---------------
exports('getItemAmount', function(playerId, itemName)
	playerId = tonumber(playerId)
	return Bridge.getItemAmount(playerId, itemName)
end)

exports('addItem', function(playerId, itemName, amount)
	playerId = tonumber(playerId)
	amount = tonumber(amount) or 1
	if amount <= 0 then
		return false
	end
	local expectedAmount = Bridge.getItemAmount(playerId, itemName) + amount
	Bridge.addItem(playerId, itemName, amount)
	return Bridge.getItemAmount(playerId, itemName) == expectedAmount
end)

exports('removeItem', function(playerId, itemName, amount)
	playerId = tonumber(playerId)
	amount = tonumber(amount) or 1
	if amount <= 0 then
		return false
	end
	
	if Bridge.getItemAmount(playerId, itemName) < amount then
		return false
	end
	
	local expectedAmount = Bridge.getItemAmount(playerId, itemName) - amount
	Bridge.removeItem(playerId, itemName, amount)
	return Bridge.getItemAmount(playerId, itemName) == expectedAmount
end)

-----------
-- Money --
-----------
exports('getMoneyAmount', function(playerId)
	playerId = tonumber(playerId)
	return Bridge.getMoneyAmount(playerId)
end)

exports('addMoney', function(playerId, amount)
	playerId = tonumber(playerId)
	amount = tonumber(amount) or 0
	if amount <= 0 then
		return false
	end
	local expectedAmount = Bridge.getMoneyAmount(playerId) + amount
	Bridge.addMoney(playerId, amount)
	return Bridge.getMoneyAmount(playerId) == expectedAmount
end)

exports('removeMoney', function(playerId, amount)
	playerId = tonumber(playerId)
	amount = tonumber(amount) or 0
	if amount <= 0 then
		return false
	end
	if Bridge.getMoneyAmount(playerId) < amount then
		return false
	end
	local expectedAmount = Bridge.getMoneyAmount(playerId) - amount
	Bridge.removeMoney(playerId, amount)
	return Bridge.getMoneyAmount(playerId) == expectedAmount
end)

exports('getJob', function(playerId)
	return Bridge.getJob(playerId) or ''
end)