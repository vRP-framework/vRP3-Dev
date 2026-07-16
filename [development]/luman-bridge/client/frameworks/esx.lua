if Config.Framework ~= Config.FrameworkId.ESX then
    return
end

local ESX = exports[Config.FrameworkFolder.ESX]:getSharedObject()

Framework = {}

function Framework.notify(message)
    return ESX.ShowNotification(message)
end