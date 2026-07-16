if Config.Framework ~= Config.FrameworkId.ESX then
    return
end

local ESX = exports[Config.FrameworkFolder.ESX]:getSharedObject()

Framework = {}

function Framework.getCharacterName(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    local firstName = xPlayer.get('firstName')
    local lastName = xPlayer.get('lastName')
    if not firstName and not lastName then
        firstName, lastName = string.match(xPlayer.getName(), '^(%S+)%s*(.*)$')
    end
    return firstName, lastName 
end

function Framework.getItemAmount(playerId, name)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    local itemData = xPlayer.getInventoryItem(name)
    return itemData?.count or 0
end

function Framework.removeItem(playerId, name, amount)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    xPlayer.removeInventoryItem(name, amount)
end

function Framework.addItem(playerId, name, amount)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    xPlayer.addInventoryItem(name, amount)
end

function Framework.getMoneyAmount(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    return xPlayer.getMoney()
end

function Framework.removeMoney(playerId, amount)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    xPlayer.removeMoney(amount)
end

function Framework.addMoney(playerId, amount)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    xPlayer.addMoney(amount)
end

function Framework.getJob(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    return xPlayer.getJob().name
end