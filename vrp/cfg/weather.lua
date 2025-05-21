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

-- API Configuration for Real-World Weather
cfg.api = {
    enable = true,                                -- Set to true to enable real-life weather sync
    key = "YOUR_API_KEY",                         -- Replace with your WeatherAPI key
    default_city = "Miami",                   -- Your chosen city
    update_interval = 1000 * 60 * 15 ,                     -- Update every 15 minutes (in milliseconds)
    units = "metric",                             -- WeatherAPI supports metric or imperial
    api_url = "http://api.weatherapi.com/v1/current.json?key=%s&q=%s"
}

-- Mapping Real-World Weather to In-Game Weather
cfg.weatherMap = {
    -- Clear & Sunny Conditions
    ["Clear"] = "EXTRASUNNY",
    ["Sunny"] = "EXTRASUNNY",
    ["Mostly sunny"] = "CLEAR",
    ["Partly cloudy"] = "CLOUDS",
    ["Cloudy"] = "OVERCAST",
    ["Overcast"] = "OVERCAST",
    
    -- Rain & Thunder Conditions
    ["Light rain"] = "RAIN",
    ["Rain"] = "RAIN",
    ["Moderate rain"] = "RAIN",
    ["Heavy rain"] = "THUNDER",
    ["Drizzle"] = "CLEARING",
    ["Patchy rain possible"] = "CLEARING",
    ["Showers"] = "CLEARING",
    ["Thunderstorm"] = "THUNDER",
    ["Light thunderstorm"] = "THUNDER",
    ["Severe thunderstorm"] = "THUNDER",
    
    -- Snow & Winter Conditions
    ["Light snow"] = "SNOWLIGHT",
    ["Moderate snow"] = "SNOW",
    ["Heavy snow"] = "BLIZZARD",
    ["Patchy snow possible"] = "SNOWLIGHT",
    ["Blizzard"] = "BLIZZARD",
    ["Ice pellets"] = "XMAS",
    ["Sleet"] = "SNOWLIGHT",
    
    -- Fog & Haze Conditions
    ["Mist"] = "FOGGY",
    ["Fog"] = "FOGGY",
    ["Haze"] = "SMOG",
    ["Smoke"] = "SMOG",
    
    -- Extreme & Special Conditions
    ["Sandstorm"] = "SMOG",
    ["Dust storm"] = "SMOG",
    ["Ash"] = "SMOG",
    ["Tornado"] = "THUNDER",
    ["Hurricane"] = "THUNDER",
}


return cfg