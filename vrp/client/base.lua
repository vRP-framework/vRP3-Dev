-- Client side exports
local cSolar = module('client/Solar')
Solar = cSolar:new()

local Proxy = module('bridge/bridge')

local zSolar = {}
zSolar.loadScript = module
Proxy.addInterface('Solar', zSolar)

------
--- Events
AddEventHandler('playerSpawned', function()
	Solar:triggerEvent('playerSpawned')
	TriggerServerEvent('Solar:isReady')
end)

----
local Base = class('Base', Solar.Modules)
Base.event = {}
Base.tunnel = {}

function Base:__construct()
	Solar.Modules.__construct(self)
end

function Base.tunnel:doSomething()
	print('awa awa')
	return 'ara ara'
end

function Base.event:playerSpawned()
	print('[Client Base] player spawned')
end

Solar:registerModule(Base)