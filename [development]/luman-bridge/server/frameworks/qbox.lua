if Config.Framework ~= Config.FrameworkId.QBOX then
    return
end

local QBOXCore = exports[Config.FrameworkFolder.QBOX]

Framework = {}

function Framework.getCharacterName(playerId)
    local Ply = QBOXCore:GetPlayer(playerId)
    return Ply.PlayerData.charinfo.firstname, Ply.PlayerData.charinfo.lastname
end

function Framework.getItemAmount(playerId, name)
    local Ply = QBOXCore:GetPlayer(playerId)
    local itemData = Ply.Functions.GetItemByName(name)
    return itemData?.amount or 0
end

function Framework.removeItem(playerId, name, amount)
    local Ply = QBOXCore:GetPlayer(playerId)
    Ply.Functions.RemoveItem(name, amount)
end

function Framework.addItem(playerId, name, amount)
    local Ply = QBOXCore:GetPlayer(playerId)
    Ply.Functions.AddItem(name, amount)
end

function Framework.getMoneyAmount(playerId)
    local Ply = QBOXCore:GetPlayer(playerId)
    return Ply.PlayerData.money['cash']
end

function Framework.removeMoney(playerId, amount)
    local Ply = QBOXCore:GetPlayer(playerId)
    Ply.Functions.RemoveMoney('cash', amount, 'luman-bridge')
end

function Framework.addMoney(playerId, amount)
    local Ply = QBOXCore:GetPlayer(playerId)
    Ply.Functions.AddMoney('cash', amount, 'luman-bridge')
end

function Framework.getJob(playerId)
    local Ply = QBOXCore:GetPlayer(playerId)
    return Ply.PlayerData.job.name
end