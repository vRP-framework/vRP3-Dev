--- Server side exports
local cSolar = module('Solar')
Solar = cSolar:new()

local Proxy = module('bridge/bridge')

local zSolar = {}
zSolar.loadScript = module
Proxy.addInterface('Solar', zSolar)

---
--- Events
RegisterNetEvent('Solar:isReady', function()
	local src = source
	Solar:onSpawn()
	Solar:triggerEvent('playerReady')
end)

AddEventHandler('playerDropped', function(reason)
	Solar:onLeave(source)
end)


-- Database queries
Solar:query('InitDatabase', [[
	CREATE TABLE IF NOT EXISTS `players` (
		`identifier` VARCHAR(50) NULL DEFAULT NULL COLLATE 'armscii8_bin',
		`cData` LONGTEXT NULL DEFAULT '[]' COLLATE 'armscii8_bin'
	)
	COLLATE='armscii8_bin'
	ENGINE=InnoDB
	;
]])
Solar:query('SelectAllPlayers', [[SELECT * FROM players]])
Solar:query('SelectPlayer', [[SELECT * FROM players WHERE identifier = @identifier]])
Solar:query('AddToPlayers', [[
  INSERT INTO players (identifier, cData)
  VALUES (@identifier, @cData)
  ON DUPLICATE KEY UPDATE cData = @cData
]])
Solar:query('SavePlayer', [[UPDATE players SET cData = @cData WHERE identifier = @identifier]])

----
local Base = class('Base', Solar.Modules)
Base.tunnel = {}
Base.event = {}

function Base:__construct()
	Solar.Modules.__construct(self)
	
	Solar:execute('InitDatabase')
end

function Base:sup()
	print('sup')
end

function Base.event:playerReady()
	local src = source
	local user = Solar.users_by_source[source]
	if user then
		local characters = user:getCharactersForUI(src)
		Solar:TriggerCallback('loadCharacters', function(result) print(result) end, user.source, characters)
	end
end

Solar:registerModule(Base)