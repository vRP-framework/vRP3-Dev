local Characters = class('Characters', Solar)

--[[ CALLBACKS ]]
Solar:RegisterCallback('saveCharacter', function(source, data)
	local src = source
	local user = Solar.users_by_source[source]
	if user then
		local charData= {
			character_id = data.slot..'-'..user.id,
			firstname = data.character.firstname,
			lastname = data.character.lastname,
			age = data.character.age,
			gender = data.character.gender,
			phone = math.random(1111111111,9999999999)
		}
		local success = user:createCharacter(charData)
		return success
	end
	return false
end)

Solar:RegisterCallback('selectCharacter', function(source, data)
	local src = source
	local user = Solar.users_by_source[source]
	if user then
		local slot = math.floor(tonumber(data.index)) + 1
		local charID = slot..'-'..user.id
		local success = user:selectCharacter(charID)
		if not success then
			return Solar:log('no character selected.')
		end
		return 'ok'
	end
	return false
end)