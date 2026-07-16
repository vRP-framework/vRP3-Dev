if Config.Framework ~= Config.FrameworkId.QB then
    return
end

local QBCore = exports[Config.FrameworkFolder.QB]:GetCoreObject()

Framework = {}

function Framework.getCharacterName(playerId)
    local Ply = QBCore.Functions.GetPlayer(playerId)
    return Ply.PlayerData.charinfo.firstname, Ply.PlayerData.charinfo.lastname
end

function Framework.getItemAmount(playerId, name)
    local Ply = QBCore.Functions.GetPlayer(playerId)
    local itemData = Ply.Functions.GetItemByName(name)
    return itemData?.amount or 0
end

function Framework.removeItem(playerId, name, amount)
    local Ply = QBCore.Functions.GetPlayer(playerId)
    Ply.Functions.RemoveItem(name, amount)
end

function Framework.addItem(playerId, name, amount)
    local Ply = QBCore.Functions.GetPlayer(playerId)
    Ply.Functions.AddItem(name, amount)
end

function Framework.getMoneyAmount(playerId)
    local Ply = QBCore.Functions.GetPlayer(playerId)
    return Ply.PlayerData.money['cash']
end

function Framework.removeMoney(playerId, amount)
    local Ply = QBCore.Functions.GetPlayer(playerId)
    Ply.Functions.RemoveMoney('cash', amount, 'luman-bridge')
end

function Framework.addMoney(playerId, amount)
    local Ply = QBCore.Functions.GetPlayer(playerId)
    Ply.Functions.AddMoney('cash', amount, 'luman-bridge')
end

function Framework.getJob(playerId)
    local Ply = QBCore.Functions.GetPlayer(playerId)
    return Ply.PlayerData.job.name
end