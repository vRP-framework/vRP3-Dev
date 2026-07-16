local Config = {}

Config.AllowedResources = {
	["devhub_lib"] = true,
	["vrp"] = true,
}

-- Optional automatic trust for vrp_* resources
Config.AllowVRPResources = false

Config.DebugSecurity = true

return Config