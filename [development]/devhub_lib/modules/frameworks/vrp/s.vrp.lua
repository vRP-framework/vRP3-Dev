if Shared.Framework ~= "VRP" then return end  

local export = exports['vrp_bridge']

-- Before using vRP make sure to uncomment @vrp/lib/utils.lua in fxmanifest.lua !!!
-- vRP support is currently in beta. Please report any issues you encounter, check before using in production environments.

CreateThread(function()
	Wait(5000)
	
	local Tunnel = module("vrp", "lib/Tunnel")
	local Proxy = module("vrp", "lib/Proxy")
	

	Core.GetIdentifier = function(source)
		local identifiers = GetPlayerIdentifiers(source)
		for _, id in ipairs(identifiers) do
			if string.sub(id, 1, 8) == "license:" then
				return id
			end
		end
		
		return identifiers[1] -- fallback
	end
	
	-- Cash
	Core.AddCash = function(source, amount)
		return export:addCash(source, amount)
	end

	Core.RemoveCash = function(source, amount)
		return export:removeCash(source, amount)
	end

	Core.GetCash = function(source)
		return export:getWallet(source)
	end

	-- Bank
	Core.GetBank = function(source)
		return export:getBank(source)
	end
	
	Core.AddBank = function(source, amount)
		return export:addBank(source, amount)
	end

	Core.RemoveBank = function(source, amount)
		return export:removeBank(source, amount)
	end
	
	-- Job
	Core.GetJob = function(source)
		local job = export:getJob(source)
		local jobData = {
			name = job or "unemployed",
			label = job and Core.String.Capitalize(job) or "Unemployed",
			grade = 1, -- vRP doesn't support it by default; implement this if needed
			gradeLabel = "Citizen", -- vRP doesn't support it by default; implement this if needed
			onDuty = true -- Assuming onDuty is always true unless custom handling
		}
		return jobData
	end
	
	Core.IsPolice = function(source)
		local job = export:getJob(source) or ""
		return job:match("police|sheriff|state") and true or false
	end
	
	-- Identity
	Core.GetFullName = function(source)
		local identity = export:getCharacterName(source)
		return identity.firstname .. " " .. identity.name
	end
	
	Core.GetUserInfo = function(source)
		local identity = export:getCharacterName(source)
		local userInfo = {
				dateOfBirth = "03/26/1990", -- vRP doesn't support it by default; implement this if needed
				sex = "Male", -- vRP doesn't support it by default; implement this if needed
				height = "5.9", -- vRP doesn't support it by default; implement this if needed
				nationality = "United States", -- vRP doesn't support it by default; implement this if needed
		}
		return userInfo
	end
	
	Core.GetUserSkin = function(source)
		local identity = export:getCharacterName(source)
		return {
				eyesColor = 1, -- number
				skinColor = 3, -- number
		}
	end
	
	--inventory
	--[[
	Core.RegisterItem = function(item, func)
		return export:registerItem(item, func)
	end
	
	Core.AddItem = function(source, item, amount, metadata)
		return export:addItem(source, item, amount, metadata)
	end
	
	Core.RemoveItem = function(source, item, amount)
		return export:removeItem(source, itemName, amount)
	end
	
	Core.GetItemCount = function(source, item)
		return export:getItemAmount(source, item)
	end
	
	Core.CanCarry = function(source, item, amount)
		
	end
	--]]
	
	AddEventHandler("vRP:playerLeave", function(user_id, source)
		if user_id then
			TriggerClientEvent("dh_lib:client:playerUnloaded", source)
			TriggerEvent("dh_lib:server:playerUnloaded", source)
		end
	end)
	
end)

LoadedSystems["framework"] = true