if Shared.Target ~= "custom" then return end 
CreateThread( function() 

    Core.AddModelToTarget = function(model, data)
        --[[
            This file defines a custom target for the DH framework.
            It contains the following data properties:
            - @data.name: The unique identifier for the target.
            - @data.event: The event that triggers the target.
            - @data.icon: The icon to display for the target (using FontAwesome).
            - @data.label: The label to display on the target.
            - @data.handler: The function to call when the target is interacted with. handler = function(entity, distance, coords, name, bone)
        ]]
    end

    Core.AddCoordsToTarget = function(coords, data)
        --[[
            This function adds a spherical target zone at specified coordinates.
            It contains the following data properties:
            - @coords: Vector3 coordinates where to place the target zone
            - @data.name: The unique identifier for the target
            - @data.event: The event that triggers the target
            - @data.icon: The icon to display for the target (using FontAwesome)
            - @data.label: The label to display on the target
            - @data.handler: The function to call when the target is interacted with. handler = function(entity, distance, coords, name, bone)
            - @data.radius: The radius of the sphere zone
        ]]
        -- Implementation for custom target system would go here
    end

    Core.RemoveCoordsFromTarget = function(name)
        --[[
            This function removes a coords based target zone by its name.
            It contains the following data properties:
            - @name: The unique identifier for the target to be removed
        ]]
        -- Implementation for removing target zone would go here
    end

    Core.AddLocalEntityToTarget = function(entity, data)
        --[[
            This function adds a target to a specific local entity.
            It contains the following data properties:
            - @entity: The entity handle to add the target to
            - @data.name: The unique identifier for the target
            - @data.event: The event that triggers the target
            - @data.icon: The icon to display for the target (using FontAwesome)
            - @data.label: The label to display on the target
            - @data.handler: The function to call when the target is interacted with. handler = function(entity, distance, coords, name, bone)
        ]]
        -- Implementation for custom target system would go here
    end

    Core.RemoveLocalEntityFromTarget = function(entity, names)
        --[[
            This function removes a target from a specific local entity.
            It contains the following data properties:
            - @entity: The entity handle to remove the target from
            - @names: The name(s) of the options to remove
        ]]
        -- Implementation for removing local entity target would go here
    end

    Core.AddGlobalVehicleToTarget = function(data)
        --[[
            This function adds a target to all vehicles globally.
            It contains the following data properties:
            - @data.name: The unique identifier for the target
            - @data.event: The event that triggers the target
            - @data.icon: The icon to display for the target (using FontAwesome)
            - @data.label: The label to display on the target
            - @data.handler: The function to call when the target is interacted with. handler = function(entity, distance, coords, name, bone)
            - @data.bones: Optional table of bone names to target specific vehicle parts
        ]]
        -- Implementation for custom target system would go here
    end

    Core.RemoveGlobalVehicleFromTarget = function(names)
        --[[
            This function removes a global vehicle target by its name(s).
            It contains the following data properties:
            - @names: The name(s) of the options to remove
        ]]
        -- Implementation for removing global vehicle target would go here
    end

    Core.AddGlobalPlayerToTarget = function(data)
        --[[
            This function adds a target to all players globally.
            It contains the following data properties:
            - @data.name: The unique identifier for the target
            - @data.event: The event that triggers the target
            - @data.icon: The icon to display for the target (using FontAwesome)
            - @data.label: The label to display on the target
            - @data.handler: The function to call when the target is interacted with. handler = function(entity, distance, coords, name, bone)
        ]]
        -- Implementation for custom target system would go here
    end

    Core.RemoveGlobalPlayerFromTarget = function(names)
        --[[
            This function removes a global player target by its name(s).
            It contains the following data properties:
            - @names: The name(s) of the options to remove
        ]]
        -- Implementation for removing global player target would go here
    end

    LoadedSystems['targets'] = true
end)