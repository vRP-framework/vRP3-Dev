RegisterCommand('changeMoney', function(source, args) -- /changeMoney add 500 1 cash
	local user = Solar.users_by_source[source]
	if user then
		local player = user:getPlayer(target)
		local action = args[1]
		local amount = tonumber(args[2])
		local target = tonumber(args[3])
		local account = args[4]

		if action == 'add' then
			user:addMoney(target, amount, account)
		elseif action == 'remove' then
			user:removeMoney(target, amount, account)
		else
			return Solar:log('Invalid action.')
		end
		TriggerClientEvent('updateclienthud', target, player, target)
	end
end)


RegisterNetEvent('updatehud', function()
	local src = source
	local user = Solar.users_by_source[source]
	if user then
		local player = user:getPlayer(src)
		TriggerClientEvent('updateclienthud', src, player, src)
	end
end)