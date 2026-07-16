if Config.Framework ~= Config.FrameworkId.VRP_DUNKO then
    return
end

local frameworkFolder = 'vrp'
local function init()
    load(LoadResourceFile(frameworkFolder, 'lib/utils.lua'))()
    local content = LoadResourceFile(GetCurrentResourceName(), 'client/frameworks/modules/vrp_dunko_proxy.lua')
    local Proxy = load(content)()
	return Proxy.getInterface('vRP')
end

local vRP = init()

Framework = {}

function Framework.notify(message)
    vRP.notify({message})
end