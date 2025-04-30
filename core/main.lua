local FrameworkShared = module('shared')

function Framework()
	local self = FrameworkShared()
	self.players = {}


	function self:onSpawn() -- triggered: Framework:onSpawn() anywhere
		local src = source
		local player_id = GetPlayerIdentifierByType(src, 'fivem')
		print(src, player_id)
		if not self.Player then self.Player = module('modules/Player') end
		local player = self.Player(src, player_id)
		if player then
			self.players[src] = player
			player:isReady()
			print("player finished loading.")
		end
	end

	function self:disconnect()
		local src = source
		local player = self.players[src]
		if player then
			local saved = player:save()
			if not saved then return self:error('could not save player on leave '..src) end
			player.cData = nil
			player.source = nil
			player.id = nil
			player.characters = nil
			self:log("Player has been saved successfully on exit.")
		end
	end

	function self:onLeave()
		self:disconnect()
		self:triggerEvent('playerLeave')
	end
	return self
end

return Framework