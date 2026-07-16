if Config.Framework ~= Config.FrameworkId.QBOX then
    return
end

local QBOXCore = exports[Config.FrameworkFolder.QBOX]

Framework = {}

function Framework.notify(message)
    QBOXCore:Notify(message)
end