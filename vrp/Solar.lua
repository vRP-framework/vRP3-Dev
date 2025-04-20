local SolarShared = module('SolarShared')
local Solar = class('Solar', SolarShared)

function Solar:__construct()
	SolarShared.__construct(self)
	self.users_by_source = {}
end


function Solar:onSpawn()
	local src = source
	local user_id = GetPlayerIdentifierByType(src,'fivem')
	if not self.User then self.User = module('modules/User') end
	local user = self.User:new(src, user_id)
	if user then
		self.users_by_source[src] = user
		user:isReady()
	end
end

function Solar:onLeave()
	local src = source
	self:disconnect(src)
	Solar:triggerEvent('playerLeave', src)
end

function Solar:disconnect()
	local src = source
	local user = self.users_by_source[src]
	if user then
		local saved = user:save()
		if not saved then return self:log('could not save player') end
		user.cData = nil
		user.source = nil
		user.id = nil
		user.characters = nil
		self:log('User has been saved successfully')
	end
end

return Solar