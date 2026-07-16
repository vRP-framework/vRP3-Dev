if Shared.Framework ~= "ESX" then return end  
ESX = nil

CreateThread(function()
    Wait(5000)
    ESX = exports["es_extended"]:getSharedObject()

    Core.GetIdentifier = function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return false end
        return xPlayer.identifier
    end

    Core.GetCash = function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        return xPlayer.getMoney()
    end
    
    Core.AddCash = function(source, amount)
        local xPlayer = ESX.GetPlayerFromId(source)
        xPlayer.addMoney(amount) 
        return true 
    end

    Core.RemoveCash = function(source, amount)
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer.getMoney() < amount then 
            return false
        end
        xPlayer.removeMoney(amount)
        return true
    end

    Core.GetBank = function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        return xPlayer.getAccount("bank").money
    end
    
    Core.AddBank = function(source, amount)
        local xPlayer = ESX.GetPlayerFromId(source)
        xPlayer.addAccountMoney("bank", amount)
        return true
    end

    Core.RemoveBank = function(source, amount)
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer.getAccount("bank").money < amount then 
            return false
        end
        xPlayer.removeAccountMoney("bank", amount)
        return true
    end

    Core.GetJob = function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        local jobData = {
            name = xPlayer?.job?.name or "unemployed",
            label = xPlayer?.job?.label or "Unemployed",
            grade = xPlayer?.job?.grade or 0,
            gradeLabel = xPlayer?.job?.grade_label or "Unemployed",
            onDuty = xPlayer?.job?.onDuty or true,
        }
        return jobData
    end

    Core.IsPolice = function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer?.job?.name == "police" or xPlayer?.job?.name == "sheriff" or xPlayer?.job?.name == "state" then 
            return true
        end
        return false
    end

    Core.GetFullName = function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        return xPlayer.getName()
    end

    Core.GetUserInfo = function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        local info = {
            dateOfBirth = xPlayer?.dateofbirth or "Unknown",
            sex = xPlayer?.sex or "Unknown",
            height = xPlayer?.height or "Unknown",
            nationality = xPlayer?.nationality or "Unknown", -- esx_identity dosn't have nationality by default
        }
        return info
    end

    Core.GetUserSkin = function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        return {
            eyesColor = xPlayer?.skin?.eyes_color or 0, -- number
            skinColor = xPlayer?.skin?.skin_md_weight or 0, -- number
        }
    end
    
    RegisterNetEvent("esx:playerLoaded",function(source)
        TriggerClientEvent("dh_lib:client:playerLoaded", source)
        TriggerEvent("dh_lib:server:playerLoaded", source)
    end)

    RegisterNetEvent('esx:playerDropped', function(source, reason)
        TriggerEvent("dh_lib:server:playerUnloaded", source)
        TriggerClientEvent("dh_lib:client:playerUnloaded", source)
    end)

    AddEventHandler('esx:onAddInventoryItem', function(source, itemName, itemCount)
        TriggerClientEvent("devhub_lib:itemCarry:addItem:client", source, itemName)
    end)

    AddEventHandler('esx:onRemoveInventoryItem', function(source, itemName, itemCount)
        TriggerClientEvent("devhub_lib:itemCarry:removeItem:client", source, itemName)
    end)

    LoadedSystems["framework"] = true
end)