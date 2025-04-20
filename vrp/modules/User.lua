local modules = {}

for name,ext in pairs(Solar.modules)do
	if ext.User then
		table.insert(modules, ext.User)
	end
end

local User = class('User', table.unpack(modules))

function User:__construct(source, identifier)
	self.source= source
	self.id = identifier 
	self.characters = {} -- characters created by player
	self.cData = {} -- active character's data
	self.config = module('cfg/player')
	
	  -- extensions constructors
  for _,uext in pairs(modules) do
    local construct = uext.__construct
    if construct then
      construct(self)
    end
  end
end

function User:isReady()
	if self.source then
		print('User is now ready.')
	end
end

function User:createCharacter(data)
	if not data then
		return error('invalid data to create character.')
	end
	local char_id = data.character_id

	if not (data.firstname or data.lastname) then -- mandatory data for player
		return Solar:error('Player is missing their first and last name!'..tostring(json.encode(data)))
	end
	
	local function applyDefaults(defaults, target)
		for key, defaultValue in pairs(defaults) do 
			if type(defaultValue) == "table" then
				target[key] = type(target[key]) == 'table' and target[key] or {}
				applyDefaults(defaultValue, target[key])
			else
				if target[key] == nil or type(target[key]) ~= type(defaultValue) then
					if key == 'account' then
						target[key] = math.random(1000,9999)..'-'..math.random(1000, 9999)
					else
						target[key] = defaultValue
					end
				end
			end
		end
	end
	applyDefaults(self.config.defaultData, data)
	
	if not data.gender or type(data.gender) ~= 'string' then
		data.gender = 'unknown'
	end
	
	self.characters = self.characters or {}
	self.characters[char_id] = data
	
	local identifier = self.id
	local params = {
		['@identifier'] = identifier,
		['@cData'] = json.encode(self.characters),
	}
	local isInDb = Solar:execute('SelectPlayer', {['@identifier'] = identifier})
	if not isInDb[1] then 
		local isAdded = Solar:execute('AddToPlayers', params)
		if isAdded.affectedRows > 0 then
			return 'success'
		else
			print('could not add player')
		end
	end
	local result = Solar:execute('SavePlayer', params)
	if result.affectedRows > 0 then
		return 'success'
	else
		error('Could not create character.')
		return false
	end
end

function User:selectCharacter(char_id)
  if self.characters then
    if self.characters[char_id] then
      self.cData = self.characters[char_id]
      return 'ok'
    else
      Solar:log("[SELECT] char_id NOT found:", char_id)
    end
  else
    Solar:log("[SELECT] No characters found for ID:", char_id)
  end
end

function User:getCharacter()
	return self.cData
end

function User:save()
	if self.cData then
		Solar:log('Saving player(s)...')
		local char_id = self.cData.character_id
		if not char_id then return Solar:log('no char_id found for user save') end
		self.characters[char_id] = self.cData

		-- Save to database
		local isInDb = Solar:execute('SelectPlayer', {
			['@identifier'] = self.id,
		})
		if isInDb[1] then
			local isSaved = Solar:execute('SavePlayer', {
				['@identifier'] = self.id,
				['cData'] = json.encode(self.characters)
			})
			if isSaved then
				Solar:log('Player '..self.source..' saved successfully')
				return true
			end
		else
			Solar:log('Unable to save '..self.source..'\'s character. Invalid data.')
		end
	end
	return false
end

function User:getAllCharacters()
	local identifier = self.id
	local result = Solar:execute('SelectPlayer', {['@identifier'] = identifier})
	if result[1] and result[1].cData then
		local decoded = json.decode(result[1].cData)
		if decoded then
			self.characters = decoded
			--Solar:log('slot based data log: '..json.encode(decoded, {indent=true}))  -- logs your slot-based data
			return decoded
		else
			Solar:log('Could not decode cData for player: '..identifier)
		end
	else
		Solar:log('no resut[1] or result[1].cData'..json.encode(result[1]))
	end
end

function User:getCharactersForUI() -- this is only called when the player joins/spawns in the server
  local characters = self:getAllCharacters()
  local formatted = {}

	for key, char in pairs(characters or {}) do
    local slot = tonumber(key:match("^(%d+)%-%w+")) -- extract slot number (1, 2, 3)
    if slot then
      formatted[#formatted + 1] = {
        slot = slot,
        firstname = char.firstname,
        lastname = char.lastname,
        age = char.age,
        gender = char.gender,
        character_id = char.character_id,
      }
    end
  end

  return formatted
end

return User