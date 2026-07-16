local frameworkFolder = 'vrp'
if GetCurrentResourceName() ~= frameworkFolder then
	return
end

local function registerExtension(extensionName)
	local extension = class(extensionName, vRP.Extension)

	extension.proxy = {}
	extension.event = {}
	extension.tunnel = {}

	function extension:__construct()
		vRP.Extension.__construct(self)
	end

	function extension.proxy:notify(message)
		vRP.EXT.Base:notify(message)
	end

	vRP:registerExtension(extension)
end

registerExtension('Bridge')