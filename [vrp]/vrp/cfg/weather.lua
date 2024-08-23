local cfg = {}

cfg.time = {
	['Morning'] 	= 9, 
	['Noon'] 		= 12, 
	['Evening'] 	= 18, 
	['Night'] 		= 23
}

cfg.types = {
	'EXTRASUNNY', 
    'CLEAR',  
    'SMOG', 
    'FOGGY', 
    'OVERCAST', 
    'CLOUDS', 
    'CLEARING', 
    'RAIN', 
    'THUNDER', 
    'SNOW', 
    'BLIZZARD', 
    'SNOWLIGHT'
	
	--'XMAS', 
	--'NEUTRAL',		--makes sky green
    --'HALLOWEEN'
}

cfg.options = {
	forcast_opt = {
		{
			label = "Blackout",
			remoteFunction = "_toggleBlackout",
			promptMessage = ""
		},
		{
			label = "Set Weather",
			remoteFunction = "_setWeather",
			promptMessage = "Weather types: Not case Sensitive"
		},
	},
	time_opt = {
		{
			label = "Freeze Time",
			remoteFunction = "_toggleFreeze",
			promptMessage = "Set Time: 24 hour format from 0 - 23"
		},
		{
			label = "Set Time",
			remoteFunction = "_setTime",
			promptMessage = "Set Time: 24 hour format from 0 - 23"
		},
		{
			label = "Speed Up Time",
			remoteFunction = "_speedUpTime",
			promptMessage = "Set Multiplier: recommended 2 - 6 (1 is default speed)"
		},
		{
			label = "Slow Down Time",
			remoteFunction = "_slowTime",
			promptMessage = "Set Divider: recommended 2 - 6. (1 is default speed)"
		}
	}
}

return cfg