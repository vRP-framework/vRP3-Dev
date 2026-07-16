if Shared.Target ~= "vrp" then return end 

CreateThread( function() 

    Core.AddModelToTarget = function(model, data)
        --[[
            This file defines a custom target for the DH framework.
            It contains the following data properties:
            - @data.name: The unique identifier for the target.
            - @data.event: The event that triggers the target.
            - @data.icon: The icon to display for the target (using FontAwesome).
            - @data.label: The label to display on the target.
            - @data.handler: The function to call when the target is interacted with.
        ]]
        exports["target"]:AddTargetModel(model, {
            options = {
                {
                    event = data.event,
				    label = data.label,
				    tunnel = "client"  
                }
            },
            Distance = 1.5
        })
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
            - @data.handler: The function to call when the target is interacted with
            - @data.radius: The radius of the sphere zone
        ]]
        -- Implementation for custom target system would go here
        local options = {}
        if data and data[1] then
            for _, v in pairs(data) do
                options[#options + 1] = {
                    event = v.event,
                    label = v.label,
                    tunnel = "client",
                    name = v.name,
                }
            end
        else 
            options = {
                {
                    event = data.event,
                    label = data.label,
                    tunnel = "client",
                    name = data.name,
                }
            }
        end
        exports["target"]:AddCircleZone(options[1].name, coords.xyz, 0.5, {
            name = options[1].name,
            heading = 0.0
        }, {
            Distance = 1.5,
            options = options
        })
    end
    Core.RemoveCoordsFromTarget = function(name)
        exports["target"]:RemoveZone(name)
    end

    Core.AddLocalEntityToTarget = function(entity, data)
        local options = {}
        if data and data[1] then
            for _, v in pairs(data) do
                options[#options + 1] = {
                    event = v.event,
                    label = v.label,
                    tunnel = "client",
                    name = v.name,
                }
            end
        else
            options = {
                {
                    event = data.event,
                    label = data.label,
                    tunnel = "client",
                    name = data.name,
                }
            }
        end
        exports["target"]:AddTargetEntity(entity, {
            options = options,
            Distance = 1.5,
        })
    end

    Core.RemoveLocalEntityFromTarget = function(entity, names)
        exports["target"]:RemoveTargetEntity(entity, names)
    end

    Core.AddGlobalVehicleToTarget = function(data)
        local options = {}
        if data and data[1] then
            for _, v in pairs(data) do
                options[#options + 1] = {
                    event = v.event,
                    label = v.label,
                    tunnel = "client",
                    name = v.name,
                    bones = v.bones,
                }
            end
        else
            options = {
                {
                    event = data.event,
                    label = data.label,
                    tunnel = "client",
                    name = data.name,
                    bones = data.bones,
                }
            }
        end
        exports["target"]:AddGlobalVehicle({
            options = options,
            Distance = 1.5,
        })
    end

    Core.RemoveGlobalVehicleFromTarget = function(names)
        exports["target"]:RemoveGlobalVehicle(names)
    end

    Core.AddGlobalPlayerToTarget = function(data)
        local options = {}
        if data and data[1] then
            for _, v in pairs(data) do
                options[#options + 1] = {
                    event = v.event,
                    label = v.label,
                    tunnel = "client",
                    name = v.name,
                }
            end
        else
            options = {
                {
                    event = data.event,
                    label = data.label,
                    tunnel = "client",
                    name = data.name,
                }
            }
        end
        exports["target"]:AddGlobalPlayer({
            options = options,
            Distance = 1.5,
        })
    end

    Core.RemoveGlobalPlayerFromTarget = function(names)
        exports["target"]:RemoveGlobalPlayer(names)
    end

    LoadedSystems['targets'] = true
end)