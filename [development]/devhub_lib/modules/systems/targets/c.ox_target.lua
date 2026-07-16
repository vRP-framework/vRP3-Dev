if Shared.Target ~= "ox_target" then return end 
CreateThread( function() 
    Core.AddModelToTarget = function(model, data)
        exports.ox_target:addModel(model, {
            name = data.name, 
            event = data.event,
            icon = data.icon,
            label = data.label,
            canInteract = data.handler
        })
    end
    Core.AddCoordsToTarget = function(coords, data)
        local options = {}
        if data and data[1] then
            for _, v in pairs(data) do
                options[#options + 1] = {
                    event = v.event,
                    icon = v.icon,
                    label = v.label,
                    canInteract = v.handler,
                    name = v.name,
                    radius = v.radius,
                }
            end
        else
            options = {
                {
                    event = data.event,
                    icon = data.icon,
                    label = data.label,
                    canInteract = data.handler,
                    name = data.name,
                    radius = data.radius,
                }
            }
        end
        exports.ox_target:addSphereZone({
            coords = coords,
            radius = options[1].radius or 2.0,
            name = options[1].name,
            options = options
        })
    end
    Core.RemoveCoordsFromTarget = function(name)
        exports.ox_target:removeZone(name)
    end

    Core.AddLocalEntityToTarget = function(entity, data)
        local options = {}
        if data and data[1] then
            for _, v in pairs(data) do
                options[#options + 1] = {
                    event = v.event,
                    icon = v.icon,
                    label = v.label,
                    canInteract = v.handler,
                    name = v.name,
                }
            end
        else
            options = {
                {
                    event = data.event,
                    icon = data.icon,
                    label = data.label,
                    canInteract = data.handler,
                    name = data.name,
                }
            }
        end
        exports.ox_target:addLocalEntity(entity, options)
    end

    Core.RemoveLocalEntityFromTarget = function(entity, names)
        exports.ox_target:removeLocalEntity(entity, names)
    end

    Core.AddGlobalVehicleToTarget = function(data)
        local options = {}
        if data and data[1] then
            for _, v in pairs(data) do
                options[#options + 1] = {
                    event = v.event,
                    icon = v.icon,
                    label = v.label,
                    canInteract = v.handler,
                    name = v.name,
                    bones = v.bones,
                }
            end
        else
            options = {
                {
                    event = data.event,
                    icon = data.icon,
                    label = data.label,
                    canInteract = data.handler,
                    name = data.name,
                    bones = data.bones,
                }
            }
        end
        exports.ox_target:addGlobalVehicle(options)
    end

    Core.RemoveGlobalVehicleFromTarget = function(names)
        exports.ox_target:removeGlobalVehicle(names)
    end

    Core.AddGlobalPlayerToTarget = function(data)
        local options = {}
        if data and data[1] then
            for _, v in pairs(data) do
                options[#options + 1] = {
                    event = v.event,
                    icon = v.icon,
                    label = v.label,
                    canInteract = v.handler,
                    name = v.name,
                }
            end
        else
            options = {
                {
                    event = data.event,
                    icon = data.icon,
                    label = data.label,
                    canInteract = data.handler,
                    name = data.name,
                }
            }
        end
        exports.ox_target:addGlobalPlayer(options)
    end

    Core.RemoveGlobalPlayerFromTarget = function(names)
        exports.ox_target:removeGlobalPlayer(names)
    end

    LoadedSystems['targets'] = true
end)