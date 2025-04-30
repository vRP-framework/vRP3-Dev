local FW = module('core','main')
Framework = FW()

-- vRP2 inspired proxy system
local Proxy = module('bridge/bridge')
local pFW = {}
Proxy.addInterface('Framework', pFW)
---
AddEventHandler('playerSpawned', function()
	Framework:triggerEvent('playerReady')
	TriggerServerEvent('Framework:isReady')
end)

RegisterNetEvent('updateclienthud', function(playerdata, playerid)
	local bankaccount = playerdata.bank
	local name = playerdata.firstname..' '..playerdata.lastname

	exports['hud']:updatehud({
		playerName = name,
		cash = bankaccount.cash,
		bank = bankaccount.checking.balance,
		blackmoney = 0,
		job = 'unemployed',
		playerid=playerid
	})
end)

function Base(Framework)
	local self = {}
	self.__name = 'Base'
	self.event={}
	Framework.Modules(self)

	function self.event:playerReady()
		local model = GetHashKey('mp_m_freemode_01')

		RequestModel(model)
		while not HasModelLoaded(model) do Wait(0) end

		SetPlayerModel(PlayerId(), model)
		SetModelAsNoLongerNeeded(model)

		-- Wait until applied
		local tries = 0
		while GetEntityModel(PlayerPedId()) ~= model and tries < 100 do
			Wait(10)
			tries = tries+ 1
		end

		local ped = PlayerPedId()
		SetPedDefaultComponentVariation(ped)
		SetEntityVisible(ped, true, false)
		ClearPedTasksImmediately(ped)
	end

	return self
end

Framework:RegisterModule(Base)