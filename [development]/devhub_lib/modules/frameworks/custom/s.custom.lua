if Shared.Framework ~= "custom" then return end  

CreateThread(function()
    -- Retrieves the identifier of a player.
    -- @param source The player's source ID.
    -- @return The identifier of the player.
    Core.GetIdentifier = function(source)
        -- code here
        local license = GetPlayerIdentifierByType(source, 'license')
        local colonPosition = string.find(license, ":") - 1
        license = string.sub(license, colonPosition + 2)
        if not license or license == "" then
            print("^1No license found, returning nil.^7")
            return nil
        end
        return license
    end

    -- Adds cash to the player's account.
    -- @param source The player's source ID.
    -- @param amount The amount of cash to add.
    -- @return True if the cash was successfully added, false otherwise.
    Core.AddCash = function(source, amount)
        return true 
    end

    -- Removes cash from the player's account.
    -- @param source The player's source ID.
    -- @param amount The amount of cash to remove.
    -- @return True if the cash was successfully removed, false otherwise.
    Core.RemoveCash = function(source, amount)
        return true
    end

    -- Gets the amount of cash in the player's account.
    -- @param source The player's source ID.
    -- @return The amount of cash in the player's account.
    Core.GetCash = function(source)
        return 0
    end

    -- Gets the amount of money in the player's bank account.
    -- @param source The player's source ID.
    -- @return The amount of money in the player's bank account.
    Core.GetBank = function(source)
        return 0
    end

    -- Adds an amount to the player's bank account.
    -- @param source The player's source ID.
    -- @param amount The amount to add to the player's bank account.
    -- @return True if the operation was successful, false otherwise.
    Core.AddBank = function(source, amount)
        return true
    end

    -- Removes an amount from the player's bank account.
    -- @param source The player's source ID.
    -- @param amount The amount to remove from the player's bank account.
    -- @return True if the operation was successful, false otherwise.
    Core.RemoveBank = function(source, amount)
        return true
    end

    -- Gets the job data of the player.
    -- @param source The player's source ID.
    -- @return A table containing the player's job data (name, label, grade, gradeLabel, onDuty).
    Core.GetJob = function(source)
        local jobData = {
            name = "unemployed",
            label = "Unemployed",
            grade = 0,
            gradeLabel = "Unemployed",
            onDuty = false,
        }
        return jobData
    end

    -- Checks if the player is a police officer.
    -- @param source The player's source ID.
    -- @return True if the player is a police officer, false otherwise.
    Core.IsPolice = function(source)
        return true
    end
    
    -- Gets the full name of the player.
    -- @param source The player's source ID.
    -- @return The full name of the player.
    Core.GetFullName = function(source)
        return "Firstname Lastname"
    end

    Core.GetUserInfo = function(source)
        local info = {
            dateOfBirth = "Unknown",
            sex = "Unknown",
            height = "Unknown",
            nationality = "Unknown",
        }
        return info
    end

    Core.GetUserSkin = function(source)
        return {
            eyesColor = 0, -- number
            skinColor = 0, -- number
        }
    end

    LoadedSystems["framework"] = true
end)