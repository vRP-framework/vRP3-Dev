local config = module('cfg/config')

--[[ CALLBACKS ]]
Framework:RegisterCallback('saveCharacter', function(source, data)
	local src = source
	local player = Framework.players[src]
	if player then
		local identifier = player.id
		local charData= {
			character_id = data.slot..'-'..identifier,
			firstname = data.character.firstname,
			lastname = data.character.lastname,
			age = data.character.age,
			gender = data.character.gender,
			phone = math.random(1111111111,9999999999)
		}
		local success = player:createCharacter(charData)
		return success
	end
	return false
end)

Framework:RegisterCallback('selectCharacter', function(source, data)
	local src = source
	local player = Framework.players[src]
	if player then
		local identifer = player.id

		local slot = math.floor(tonumber(data.index)) + 1
		local charID = slot..'-'..identifer
		if config.debug then
			Framework:log('charID variable is: '..charID)
			Framework:log('Attempting to select character '.. charID)
		end

		local success = player:selectCharacter(charID)
		if not success then
			return Framework:error('no character selected.')
		end
		return 'ok'
	end
	return false
end)


