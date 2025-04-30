local function Player(source, identifier)
	local self = {}

	print('creating player...')
	-- public variables
	self.source =source
	self.id = identifier
	self.characters = nil
	self.cData = nil
	self.config = module('cfg/config')


	-- inherit module Player constructors from Framework.modules
	for _, mods in pairs(Framework.modules) do 
		if mods.Player then
			local constructor = mods.Player().__construct
			if constructor then
				constructor(self)
			end
		end
	end

	function self:isReady()
		if self.source then
			Framework:log('player is ready')
		end
	end
	
	function self:createCharacter(data)
		if not data then
			return error('invalid data to create character.')
		end
		local char_id = data.character_id
		if not (data.firstname or data.lastname) then -- mandatory data for player
			return Framework:log('Player is missing their first and last name!')
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
		local isInDb = Framework:execute('SelectPlayer', {['@identifier'] = identifier})
		if not isInDb[1] then 
			local isAdded = Framework:execute('AddToPlayers', params)
			if isAdded.affectedRows > 0 then
				return 'success'
			else
				print('no')
			end
		end
		local result = Framework:execute('SavePlayer', params)
		if result.affectedRows > 0 then
			return 'success'
		else
			error('Could not create character.')
			return false
		end
	end

	function self:selectCharacter(char_id)
		if self.characters[char_id] then
			self.cData = self.characters[char_id]
			return 'ok'
		else
			print("[SELECT] char_id NOT found:", char_id)
		end
	end


	function self:save()
		local identifier = self.id
		if self.cData then
			Framework:log('Saving player(s)...')
			local char_id = self.cData.character_id
			self.characters[char_id] = self.cData

			-- Save to database
			local isInDb = Framework:execute('SelectPlayer', {
				['@identifier'] = identifier,
			})
			if isInDb[1] then
				local isSaved = Framework:execute('SavePlayer', {
					['@identifier'] = identifier,
					['cData'] = json.encode(self.characters)
				})
				if isSaved then
					Framework:log('Player '..self.source..' saved successfully')
					return true
				end
			else
				Framework:log('Unable to save '..self.source..'\'s character. Invalid data.')
			end
		end
		return false
	end


	function self:getCharacter()
		return self.cData
	end

--------
	function self:addMoney(amount, account) -- self:addMoney(1, 500, 'cash')
		if not (amount or account) or type(amount) ~= 'number' then
			return Framework:log('Cannot add money. Invalid parameters.')
		end
		if account == 'cash' then
			self.cData.bank.cash = self.cData.bank.cash + amount
		elseif account == 'checking' then
			self.cData.bank.checking.balance = self.cData.bank.checking.balance + amount
		elseif account == 'savings' then
			self.cData.bank.savings.balance = self.cData.bank.savings.balance + amount
		else
			Framework:log('Cannot add moeny. Invalid account type.')
		end
		return
	end

	function self:removeMoney(amount, account) -- self:removeMoney(1, 500, 'cash')
		if not (amount or account) or type(amount) ~= 'number' then
			return Framework:log('Cannot add money. Invalid parameters.')
		end

		if account == 'cash' then
			self.cData.bank.cash = self.cData.bank.cash - amount
		elseif account == 'checking' then
			self.cData.bank.checking.balance = self.cData.bank.checking.balance - amount
		elseif account == 'savings' then
			self.cData.bank.savings.balance = self.cData.bank.savings.balance - amount
		else
			Framework:log('Cannot add moeny. Invalid account type.')
		end
		return
	end
-------

	function self:getAllCharacters()
		local identifier = self.id
		local result = Framework:execute('SelectPlayer', {['@identifier'] = identifier})
		if result[1] and result[1].cData then
			local decoded = json.decode(result[1].cData)
			if decoded then
				self.characters = decoded
				return decoded
			else
				Framework:log('Could not decode cData for self: '..identifier)
			end
		else
			print('no resut[1] or result[1].cData'..json.encode(result[1]))
		end
	end

	function self:getCharactersForUI() -- this is only called when the player joins/spawns in the server
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
					character_id = char.character_id
				}
			end
		end

		return formatted
	end

	return self
end

return Player