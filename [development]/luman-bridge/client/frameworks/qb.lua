if Config.Framework ~= Config.FrameworkId.QB then
    return
end

local QBCore = exports[Config.FrameworkFolder.QB]:GetCoreObject()

Framework = {}

function Framework.notify(message)
    TriggerEvent('QBCore:Notify', message)
end