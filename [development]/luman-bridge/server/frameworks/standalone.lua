if Config.Framework ~= Config.FrameworkId.STANDALONE then
    return
end

Framework = {}

function Framework.getCharacterName(playerId)
    return GetPlayerName(playerId), ''
end

function Framework.getItemAmount(playerId, name)
    return math.huge
end

function Framework.removeItem(playerId, name, amount)
    TriggerClientEvent(EVENTS.SHOW_NOTIFICATION, playerId, ('[luman-bridge]: ~r~Removed~s~ item ~y~%s x %s'):format(amount, name))
    return true
end

function Framework.addItem(playerId, name, amount)
    TriggerClientEvent(EVENTS.SHOW_NOTIFICATION, playerId, ('[luman-bridge]: ~g~Added~s~ item ~y~%s x %s'):format(amount, name))
    return true
end

function Framework.getMoneyAmount(playerId)
    return math.huge
end

function Framework.removeMoney(playerId, amount)
    TriggerClientEvent(EVENTS.SHOW_NOTIFICATION, playerId, ('[luman-bridge]: ~r~Removed~s~ money ~g~$%s'):format(amount))
    return true
end

function Framework.addMoney(playerId, amount)
    TriggerClientEvent(EVENTS.SHOW_NOTIFICATION, playerId, ('[luman-bridge]: ~g~Added~s~ money ~g~$%s'):format(amount))
    return true
end

function Framework.getJob(playerId)
    return ''
end