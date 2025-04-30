exports('updatehud', function(data)
	SendNUIMessage({
		action = 'updatehud',
		data
	})
end)


RegisterCommand("updatehud", function(source)
	exports['hud']:updatehud({
		playerName = "john doeghnut",
		playerid = 1,
		cash=1,
		bank=1,
		blackmoney=1,
		job='trash collector',
	})
end)