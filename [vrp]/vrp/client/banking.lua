-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.banking then return end

local Banking = class("Banking", vRP.Extension)

function Banking:__construct()
  vRP.Extension.__construct(self)
	
	--[[
	-- Example usage
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(5000) -- Give time for resources to load

			local atmCoords = getAllAtmCoords()

			if #atmCoords > 0 then
				for _, atm in ipairs(atmCoords) do
					print(string.format("ATM Hash: 0x%X, x=%.2f, y=%.2f, z=%.2f", atm.hash, atm.x, atm.y, atm.z))
				end
			else
				print("No ATMs found.")
			end
		end
	end)
	--]]
end

-- Define ATM prop hashes based on configuration
local atmModels = {
    ['prop_atm_01'] = GetHashKey('prop_atm_01'),
    ['prop_atm_02'] = GetHashKey('prop_atm_02'),
    ['prop_atm_03'] = GetHashKey('prop_atm_03'),
    ['prop_fleeca_atm'] = GetHashKey('prop_fleeca_atm')
}

function getAllAtmCoords()
    local atmCoords = {}
    local objects = GetGamePool('CObject') -- Get all objects in the game world

    for _, object in ipairs(objects) do
        local modelHash = GetEntityModel(object)
        for _, atmHash in pairs(atmModels) do
            if modelHash == atmHash then
                local objectCoords = GetEntityCoords(object)
                local x, y, z = table.unpack(objectCoords) -- Unpack coordinates
                table.insert(atmCoords, {hash = modelHash, x = x, y = y, z = z})
                break -- Exit the loop once a match is found
            end
        end
    end

    return atmCoords
end

vRP:registerExtension(Banking)