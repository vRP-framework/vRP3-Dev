local SolarShared = module('SolarShared')
local Solar = class('Solar', SolarShared)

function Solar:__construct()
	SolarShared.__construct(self)
end

return Solar