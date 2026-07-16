if Config.Framework ~= Config.FrameworkId.STANDALONE then
    return
end

Framework = {}

function Framework.notify(message)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(message)
    DrawNotification(false, false)
end