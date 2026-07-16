if Shared.Framework ~= "QBCore" then return end  
QBCore = nil

CreateThread(function()
    Wait(5000)
    QBCore = exports['qb-core']:GetCoreObject()

    Core.GetIdentifier = function(source)
        local Player = QBCore.Functions.GetPlayer(tonumber(source))
        if not Player then return false end
        return Player.PlayerData.citizenid
    end
    
    Core.AddCash = function(source, amount)
        local Player = QBCore.Functions.GetPlayer(tonumber(source))
        Player.Functions.AddMoney('cash', amount)
        return true
    end
    
    Core.RemoveCash = function(source, amount)
        local Player = QBCore.Functions.GetPlayer(tonumber(source))
        if Player.PlayerData.money['cash'] < amount then
            return false
        end
        Player.Functions.RemoveMoney('cash', amount)
        return true
    end
    
    Core.GetCash = function(source)
        local Player = QBCore.Functions.GetPlayer(tonumber(source))
        return Player.PlayerData.money['cash']
    end

    Core.GetBank = function(source)
        local Player = QBCore.Functions.GetPlayer(tonumber(source))
        return Player.PlayerData.money.bank
    end
    
    Core.AddBank = function(source, amount)
        local Player = QBCore.Functions.GetPlayer(tonumber(source))
        return Player.Functions.AddMoney('bank', amount, 'bank deposit')
    end

    Core.RemoveBank = function(source, amount)
        local Player = QBCore.Functions.GetPlayer(tonumber(source))
        return Player.Functions.RemoveMoney('bank', amount, 'bank withdrawal')
    end

    Core.GetJob = function(source)
        local xPlayer = QBCore.Functions.GetPlayer(tonumber(source))
        local jobData = {
            name = xPlayer.PlayerData?.job?.name or "unemployed",
            label = xPlayer.PlayerData?.job?.label or "Unemployed",
            grade = xPlayer.PlayerData?.job?.grade?.level or 0,
            gradeLabel = xPlayer.PlayerData?.job?.grade?.name or "Unemployed",
            onDuty = xPlayer.PlayerData?.job?.onduty or false,
        }
        return jobData
    end

    Core.IsPolice = function(source)
        local xPlayer = QBCore.Functions.GetPlayer(tonumber(source))
        if xPlayer.PlayerData?.job?.name == "police" or xPlayer.PlayerData?.job?.name == "sheriff" or xPlayer.PlayerData?.job?.name == "state" then 
            return true
        end
        return false
    end

    Core.GetFullName = function(source)
        local xPlayer = QBCore.Functions.GetPlayer(tonumber(source))
        return (xPlayer.PlayerData?.charinfo?.firstname or "Unknown") .. " " .. (xPlayer.PlayerData?.charinfo?.lastname or "Unknown")
    end

    Core.GetUserInfo = function(source)
        local xPlayer = QBCore.Functions.GetPlayer(tonumber(source))
        local info = {
            dateOfBirth = xPlayer.PlayerData?.charinfo?.birthdate or "Unknown",
            sex = xPlayer.PlayerData?.charinfo?.gender or "Unknown",
            height = xPlayer.PlayerData?.charinfo?.height or "Unknown", -- qb dosn't have height by default
            nationality = xPlayer.PlayerData?.charinfo?.nationality or "Unknown",
        }
        return info
    end

    Core.GetUserSkin = function(source)
        local xPlayer = QBCore.Functions.GetPlayer(tonumber(source))
        local result Core.SQL.AwaitExecute('SELECT * FROM playerskins WHERE citizenid = ? AND active = ?', { xPlayer.PlayerData.citizenid, 1 })
        return {
            eyesColor = result?.skin?.eyes_color?.texture or 0, -- number
            skinColor = result?.skin?.facemix?.skinMix or 0, -- number
        }
    end

    RegisterNetEvent("hospital:server:SetLaststandStatus",function(status)
        local source = source
        if status then
            TriggerClientEvent("dh_lib:client:setDeathStatus", source,  status)
        end
    end)

    RegisterNetEvent('hospital:server:SetDeathStatus', function(isDead)
        local source = source
        TriggerClientEvent("dh_lib:client:setDeathStatus", source,  isDead)
    end)

    LoadedSystems["framework"] = true
end)