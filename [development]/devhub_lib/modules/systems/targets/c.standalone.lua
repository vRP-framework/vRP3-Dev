if Shared.Target ~= "standalone" then return end

local coordsTargets = {}
local modelTargets = {}
local globalVehicleTargets = {}
local globalPlayerTargets = {}
local targetsThread = {}
local threadStarted = false
local cachedPed = {
    ped = nil,
    coords = nil
} 

CreateThread(function() 
    Core.AddModelToTarget = function(model, data)
        table.insert(modelTargets, {
            model = model,
            event = data.event,
            label = data.label,
            handler = data.handler,
            resource = GetInvokingResource(),
        })
    end

    Core.AddCoordsToTarget = function(coords, data)
        local options = {}
        if data and data[1] then
            for _, v in pairs(data) do
                table.insert(coordsTargets, {
                    coords = coords,
                    radius = v.radius or 2.0,
                    event = v.event,
                    label = v.label,
                    handler = v.handler,
                    name = v.name,
                    resource = GetInvokingResource(),
                })
            end
        else
            table.insert(coordsTargets, {
                coords = coords,
                radius = data.radius or 2.0,
                event = data.event,
                label = data.label,
                handler = data.handler,
                name = data.name,
                resource = GetInvokingResource(),
            })
        end
    end

    Core.RemoveCoordsFromTarget = function(name)
        for k, v in pairs(coordsTargets) do
            if v.name == name then
                table.remove(coordsTargets, k)
                break
            end
        end
    end

    Core.AddLocalEntityToTarget = function(entity, data)
        local options = {}
        if data and data[1] then
            for _, v in pairs(data) do
                table.insert(modelTargets, {
                    entity = entity,
                    event = v.event,
                    label = v.label,
                    handler = v.handler,
                    name = v.name,
                    resource = GetInvokingResource(),
                    isLocalEntity = true,
                })
            end
        else
            table.insert(modelTargets, {
                entity = entity,
                event = data.event,
                label = data.label,
                handler = data.handler,
                name = data.name,
                resource = GetInvokingResource(),
                isLocalEntity = true,
            })
        end
    end

    Core.RemoveLocalEntityFromTarget = function(entity, names)
        local tableToRemove = {}
        for k, v in pairs(modelTargets) do
            if v.isLocalEntity and v.entity == entity then
                if not names or (type(names) == "table" and lib.table.contains(names, v.name)) or names == v.name then
                    RemoveTarget(k + 10000)
                    table.insert(tableToRemove, k)
                end
            end
        end
        for i = #tableToRemove, 1, -1 do
            table.remove(modelTargets, tableToRemove[i])
        end
    end

    Core.AddGlobalVehicleToTarget = function(data)
        if not globalVehicleTargets then
            globalVehicleTargets = {}
        end
        if data and data[1] then
            for _, v in pairs(data) do
                table.insert(globalVehicleTargets, {
                    event = v.event,
                    label = v.label,
                    handler = v.handler,
                    name = v.name,
                    bones = v.bones,
                    resource = GetInvokingResource(),
                })
            end
        else
            table.insert(globalVehicleTargets, {
                event = data.event,
                label = data.label,
                handler = data.handler,
                name = data.name,
                bones = data.bones,
                resource = GetInvokingResource(),
            })
        end
    end

    Core.RemoveGlobalVehicleFromTarget = function(names)
        if not globalVehicleTargets then return end
        local tableToRemove = {}
        for k, v in pairs(globalVehicleTargets) do
            if not names or (type(names) == "table" and lib.table.contains(names, v.name)) or names == v.name then
                table.insert(tableToRemove, k)
            end
        end
        for i = #tableToRemove, 1, -1 do
            table.remove(globalVehicleTargets, tableToRemove[i])
        end
    end

    Core.AddGlobalPlayerToTarget = function(data)
        if not globalPlayerTargets then
            globalPlayerTargets = {}
        end
        if data and data[1] then
            for _, v in pairs(data) do
                table.insert(globalPlayerTargets, {
                    event = v.event,
                    label = v.label,
                    handler = v.handler,
                    name = v.name,
                    resource = GetInvokingResource(),
                })
            end
        else
            table.insert(globalPlayerTargets, {
                event = data.event,
                label = data.label,
                handler = data.handler,
                name = data.name,
                resource = GetInvokingResource(),
            })
        end
    end

    Core.RemoveGlobalPlayerFromTarget = function(names)
        if not globalPlayerTargets then return end
        local tableToRemove = {}
        for k, v in pairs(globalPlayerTargets) do
            if not names or (type(names) == "table" and lib.table.contains(names, v.name)) or names == v.name then
                table.insert(tableToRemove, k)
            end
        end
        for i = #tableToRemove, 1, -1 do
            table.remove(globalPlayerTargets, tableToRemove[i])
        end
    end

    while true do
        cachedPed.ped = PlayerPedId()
        cachedPed.coords = GetEntityCoords(cachedPed.ped)
        local threadShouldStart = false

        for _k, v in pairs(coordsTargets) do
            local k = tostring(_k)
            local distance = #(cachedPed.coords - v.coords)
            if not v.started and distance < v.radius + 3.0 and (not v.handler or v.handler()) then
                threadShouldStart = true 
                v.started = true
                local _, groundZ = GetGroundZFor_3dCoord(v.coords.x, v.coords.y, v.coords.z, 0)
                table.insert(targetsThread, {
                    event = v.event,
                    label = v.label,
                    coords = vec3(v.coords.x, v.coords.y, groundZ + 0.05),
                    radius = v.radius,
                    id = k
                })
                CreateThread(TargetThread)
            elseif v.started and distance < v.radius + 3.0 then
                threadShouldStart = true
            elseif v.started and distance > v.radius + 3.0 then
                v.started = false
                RemoveTarget(k)
            end
            Wait(1)
        end

        local closestEntity = nil
        local closestDist = math.huge
        local isGlobalPlayer = false

        if not modelTargets._prevEntities then
            modelTargets._prevEntities = {}
        end
        
        if not modelTargets._entityStarted then
            modelTargets._entityStarted = {}
        end

        if #globalPlayerTargets > 0 then
            local players = GetActivePlayers()
            for _, playerId in ipairs(players) do
                local playerPed = GetPlayerPed(playerId)
                if playerPed ~= cachedPed.ped and DoesEntityExist(playerPed) then
                    local playerCoords = GetEntityCoords(playerPed)
                    local distance = #(cachedPed.coords - playerCoords)
                    if distance < closestDist and distance < 3.0 then
                        closestDist = distance
                        closestEntity = playerPed
                        isGlobalPlayer = true
                    end
                end
            end
        end

        for k, v in pairs(modelTargets) do
            if k == "_prevEntities" or k == "_entityStarted" then goto continue end
            
            if v.isLocalEntity and v.entity then
                if DoesEntityExist(v.entity) then
                    local entityCoords = GetEntityCoords(v.entity)
                    local distance = #(cachedPed.coords - entityCoords)
                    if distance < closestDist and distance < 5.0 then
                        closestDist = distance
                        closestEntity = v.entity
                        isGlobalPlayer = false
                    end
                end
            elseif v.model then
                local model = GetHashKey(v.model)
                local peds = GetGamePool('CPed')
                local objects = GetGamePool('CObject')

                for i = 1, #objects do
                    local object = objects[i]
                    if DoesEntityExist(object) then
                        local objectModel = GetEntityModel(object)
                        if objectModel == model then
                            local objectCoords = GetEntityCoords(object)
                            local distance = #(cachedPed.coords - objectCoords)
                            if distance < closestDist and distance < 5.0 then
                                closestDist = distance
                                closestEntity = object
                                isGlobalPlayer = false
                            end
                        end
                    end
                end

                for i = 1, #peds do
                    local ped = peds[i]
                    if DoesEntityExist(ped) then
                        local pedModel = GetEntityModel(ped)
                        if pedModel == model then
                            local pedCoords = GetEntityCoords(ped)
                            local distance = #(cachedPed.coords - pedCoords)
                            if distance < closestDist and distance < 5.0 then
                                closestDist = distance
                                closestEntity = ped
                                isGlobalPlayer = false
                            end
                        end
                    end
                end
            end
            
            ::continue::
        end

        if closestEntity then
            local entityCoords = GetEntityCoords(closestEntity)
            local _, groundZ = GetGroundZFor_3dCoord(entityCoords.x, entityCoords.y, entityCoords.z, 0)
            local targetCoords = vec3(entityCoords.x, entityCoords.y, groundZ + 0.05)
            
            local prevEntity = modelTargets._prevEntities["_closest"]
            if prevEntity ~= closestEntity then
                if prevEntity then
                    for k, v in pairs(modelTargets) do
                        if k ~= "_prevEntities" and k ~= "_entityStarted" and v.started then
                            v.started = false
                            local numericK = tonumber(k) or k
                            local id = (type(numericK) == "number" and numericK + 10000) or tostring(numericK) .. "_model"
                            RemoveTarget(id)
                        end
                    end
                    for k, v in pairs(globalPlayerTargets) do
                        if v.started then
                            v.started = false
                            RemoveTarget("globalplayer_" .. k)
                        end
                    end
                end
                modelTargets._prevEntities["_closest"] = closestEntity
            end
            
            if isGlobalPlayer then
                for k, v in pairs(globalPlayerTargets) do
                    local id = "globalplayer_" .. k
                    if not v.started and (not v.handler or v.handler(closestEntity, closestDist)) then
                        threadShouldStart = true
                        v.started = true
                        table.insert(targetsThread, {
                            event = v.event,
                            label = v.label,
                            coords = targetCoords,
                            radius = 2.0,
                            id = id,
                            entity = closestEntity
                        })
                        CreateThread(TargetThread)
                    elseif v.started then
                        threadShouldStart = true
                    end
                end
            else
                for k, v in pairs(globalPlayerTargets) do
                    if v.started then
                        v.started = false
                        RemoveTarget("globalplayer_" .. k)
                    end
                end
            end
            
            for k, v in pairs(modelTargets) do
                if k == "_prevEntities" or k == "_entityStarted" then goto continue2 end
                
                local isMatch = false
                if v.isLocalEntity and v.entity == closestEntity then
                    isMatch = true
                elseif v.model and GetEntityModel(closestEntity) == GetHashKey(v.model) then
                    isMatch = true
                end
                
                if isMatch then
                    local numericK = tonumber(k) or k
                    local id = (type(numericK) == "number" and numericK + 10000) or tostring(numericK) .. "_model"
                    
                    if not v.started and (not v.handler or v.handler(closestEntity, closestDist)) then
                        threadShouldStart = true
                        v.started = true
                        table.insert(targetsThread, {
                            event = v.event,
                            label = v.label,
                            coords = targetCoords,
                            radius = 2.0,
                            id = id,
                            entity = closestEntity
                        })
                        CreateThread(TargetThread)
                    elseif v.started then
                        threadShouldStart = true
                    end
                elseif v.started then
                    v.started = false
                    local numericK = tonumber(k) or k
                    local id = (type(numericK) == "number" and numericK + 10000) or tostring(numericK) .. "_model"
                    RemoveTarget(id)
                end
                
                ::continue2::
            end
        else
            if modelTargets._prevEntities["_closest"] then
                for k, v in pairs(modelTargets) do
                    if k ~= "_prevEntities" and k ~= "_entityStarted" and v.started then
                        v.started = false
                        local numericK = tonumber(k) or k
                        local id = (type(numericK) == "number" and numericK + 10000) or tostring(numericK) .. "_model"
                        RemoveTarget(id)
                    end
                end
                for k, v in pairs(globalPlayerTargets) do
                    if v.started then
                        v.started = false
                        RemoveTarget("globalplayer_" .. k)
                    end
                end
                modelTargets._prevEntities["_closest"] = nil
            end
        end

        if not threadShouldStart and threadStarted then
            threadStarted = false
        end

        Wait(threadShouldStart and 250 or 1000)
    end

    LoadedSystems['targets'] = true
end)

function RemoveTarget(id)
    for k, v in pairs(targetsThread) do
        if v.id == id then
            if v.uiDisplayed then
                Core.ShowStaticMessage()
            end
            table.remove(targetsThread, k)
            break
        end
    end
end

function TargetThread()
    if threadStarted then return end
    threadStarted = true
    local currentDisplayedKey = nil
    
    while threadStarted do
        local groupedTargets = {}
        for _k, v in pairs(targetsThread) do
            local key = string.format("%.2f_%.2f_%.2f", v.coords.x, v.coords.y, v.coords.z)
            if not groupedTargets[key] then
                groupedTargets[key] = {
                    coords = v.coords,
                    radius = v.radius,
                    targets = {}
                }
            end
            table.insert(groupedTargets[key].targets, v)
        end
        
        local closestKey = nil
        local closestDist = math.huge
        
        for key, group in pairs(groupedTargets) do
            DrawMarker(23, group.coords.x, group.coords.y, group.coords.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 253, 209, 64, 200, false, false, 2, false, false, false, false)
            local dist = #(cachedPed.coords - group.coords)
            if dist < group.radius and dist < closestDist then
                closestDist = dist
                closestKey = key
            end
        end
        
        if closestKey then
            local group = groupedTargets[closestKey]
            
            if currentDisplayedKey ~= closestKey then
                local message = ""
                if #group.targets == 1 then
                    message = "<kbd>E</kbd> " .. group.targets[1].label
                else
                    for i, target in ipairs(group.targets) do
                        if i > 1 then message = message .. "<br>" end
                        message = message .. "<kbd>" .. i .. "</kbd> " .. target.label
                    end
                end
                
                Core.ShowStaticMessage(message)
                currentDisplayedKey = closestKey
            end
            
            if #group.targets == 1 then
                if IsControlJustPressed(0, 38) then
                    TriggerEvent(group.targets[1].event)
                end
            else
                if IsDisabledControlJustPressed(0, 157) or IsDisabledControlJustPressed(0, 1) then
                    if group.targets[1] then TriggerEvent(group.targets[1].event) end
                elseif IsDisabledControlJustPressed(0, 158) or IsDisabledControlJustPressed(0, 2) then
                    if group.targets[2] then TriggerEvent(group.targets[2].event) end
                elseif IsDisabledControlJustPressed(0, 160) or IsDisabledControlJustPressed(0, 3) then
                    if group.targets[3] then TriggerEvent(group.targets[3].event) end
                elseif IsDisabledControlJustPressed(0, 164) or IsDisabledControlJustPressed(0, 4) then
                    if group.targets[4] then TriggerEvent(group.targets[4].event) end
                elseif IsDisabledControlJustPressed(0, 165) or IsDisabledControlJustPressed(0, 5) then
                    if group.targets[5] then TriggerEvent(group.targets[5].event) end
                end
            end
        elseif currentDisplayedKey then
            Core.ShowStaticMessage()
            currentDisplayedKey = nil
        end
        
        Wait(1)
    end
    Core.ShowStaticMessage()
end

AddEventHandler("onResourceStop", function(resourceName)
    local tableToRemove = {}
    for k, v in pairs(coordsTargets) do
        if v.resource == resourceName then
            RemoveTarget(k)
            table.insert(tableToRemove, k)
        end
    end
    for i = #tableToRemove, 1, -1 do
        table.remove(coordsTargets, tableToRemove[i])
    end
    tableToRemove = {}
    for k, v in pairs(modelTargets) do
        if v.resource == resourceName then
            RemoveTarget(k + 10000)
            table.insert(tableToRemove, k)
        end
    end
    for i = #tableToRemove, 1, -1 do
        table.remove(modelTargets, tableToRemove[i])
    end
end)
 
local DEBUG_AUTO_SPAWN = false

local debugPeds = {}
local debugVehicles = {}

local debugTestCoords = {
    { coords = vec3(524.2487, -3286.4900, 46.271), type = "single" },
    { coords = vec3(524.2306, -3282.4536, 46.2714), type = "multiple" },
}

local function AutoSpawnDebugEntities()
    if not DEBUG_AUTO_SPAWN then return end
    
    print("[DEBUG] Auto-spawning debug entities...")
    
    local pedModel = `a_m_m_business_01`
    local vehModel = `adder`
    
    RequestModel(pedModel)
    RequestModel(vehModel)
    while not HasModelLoaded(pedModel) or not HasModelLoaded(vehModel) do Wait(10) end

    for i, data in ipairs(debugTestCoords) do
        local coords = data.coords
        
        local ped = CreatePed(4, pedModel, coords.x, coords.y, coords.z - 1.0, 0.0, false, true)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        table.insert(debugPeds, ped)
        
        local vehicle = CreateVehicle(vehModel, coords.x + 3.0, coords.y, coords.z, 90.0, false, true)
        table.insert(debugVehicles, vehicle)
        
        if data.type == "single" then
            Core.AddLocalEntityToTarget(ped, {
                name = "debug_ped_single",
                event = "devhub_lib:debug:pedInteract",
                icon = "fas fa-user",
                label = "Single Target Ped",
                handler = function(entity, distance)
                    return distance < 2.5
                end
            })
            
            Core.AddLocalEntityToTarget(vehicle, {
                name = "debug_vehicle_single",
                event = "devhub_lib:debug:vehicleInteract",
                icon = "fas fa-car",
                label = "Single Target Vehicle",
                handler = function(entity, distance)
                    return distance < 3.0
                end
            })
            
            print("[DEBUG] Spawned SINGLE target ped and vehicle at " .. coords.x .. ", " .. coords.y .. ", " .. coords.z)
            
        elseif data.type == "multiple" then
            Core.AddLocalEntityToTarget(ped, {
                {
                    name = "debug_ped_multi_1",
                    event = "devhub_lib:debug:pedInteract1",
                    icon = "fas fa-comment",
                    label = "Talk to Ped",
                    handler = function(entity, distance)
                        return distance < 2.5
                    end
                },
                {
                    name = "debug_ped_multi_2",
                    event = "devhub_lib:debug:pedInteract2",
                    icon = "fas fa-hand-paper",
                    label = "Wave at Ped",
                    handler = function(entity, distance)
                        return distance < 2.5
                    end
                },
                {
                    name = "debug_ped_multi_3",
                    event = "devhub_lib:debug:pedInteract3",
                    icon = "fas fa-question",
                    label = "Ask Ped",
                    handler = function(entity, distance)
                        return distance < 2.5
                    end
                }
            })
            
            Core.AddLocalEntityToTarget(vehicle, {
                {
                    name = "debug_vehicle_multi_1",
                    event = "devhub_lib:debug:vehicleInteract1",
                    icon = "fas fa-door-open",
                    label = "Open Door",
                    handler = function(entity, distance)
                        return distance < 3.0
                    end
                },
                {
                    name = "debug_vehicle_multi_2",
                    event = "devhub_lib:debug:vehicleInteract2",
                    icon = "fas fa-key",
                    label = "Lock Vehicle",
                    handler = function(entity, distance)
                        return distance < 3.0
                    end
                },
                {
                    name = "debug_vehicle_multi_3",
                    event = "devhub_lib:debug:vehicleInteract3",
                    icon = "fas fa-gas-pump",
                    label = "Check Fuel",
                    handler = function(entity, distance)
                        return distance < 3.0
                    end
                }
            })
            
            print("[DEBUG] Spawned MULTIPLE target ped and vehicle at " .. coords.x .. ", " .. coords.y .. ", " .. coords.z)
        end
    end
    
    SetModelAsNoLongerNeeded(pedModel)
    SetModelAsNoLongerNeeded(vehModel)
    
    Core.AddCoordsToTarget(vec3(519.5955, -3284.4668, 46.1876), {
        name = "debug_coords_single",
        event = "devhub_lib:debug:coordsSingle",
        icon = "fas fa-map-marker",
        label = "Single Coords Target",
        radius = 1.5,
        handler = function()
            return true
        end
    })
    print("[DEBUG] Added SINGLE coords target at 519.5955, -3284.4668, 46.1876")
    
    Core.AddCoordsToTarget(vec3(520.0062, -3281.2698, 46.1949), {
        {
            name = "debug_coords_multi_1",
            event = "devhub_lib:debug:coordsMulti1",
            icon = "fas fa-search",
            label = "Search Area",
            radius = 1.5,
            handler = function()
                return true
            end
        },
        {
            name = "debug_coords_multi_2",
            event = "devhub_lib:debug:coordsMulti2",
            icon = "fas fa-box",
            label = "Open Crate",
            radius = 1.5,
            handler = function()
                return true
            end
        },
        {
            name = "debug_coords_multi_3",
            event = "devhub_lib:debug:coordsMulti3",
            icon = "fas fa-trash",
            label = "Clean Up",
            radius = 1.5,
            handler = function()
                return true
            end
        }
    })
    print("[DEBUG] Added MULTIPLE coords target at 520.0062, -3281.2698, 46.1949")
    
    Core.AddGlobalPlayerToTarget({
        name = "debug_global_player",
        event = "devhub_lib:debug:globalPlayer",
        icon = "fas fa-user-friends",
        label = "Interact with Player",
        handler = function(entity, distance)
            return distance < 2.5
        end
    })
    print("[DEBUG] Added GLOBAL PLAYER target")
    
    local mixedPed = CreatePed(4, pedModel, 523.4284, -3278.5361, 46.2576 - 1.0, 0.0, false, true)
    FreezeEntityPosition(mixedPed, true)
    SetEntityInvincible(mixedPed, true)
    SetBlockingOfNonTemporaryEvents(mixedPed, true)
    table.insert(debugPeds, mixedPed)
    
    Core.AddLocalEntityToTarget(mixedPed, {
        name = "debug_mixed_single",
        event = "devhub_lib:debug:mixedSingle",
        icon = "fas fa-eye",
        label = "Look at NPC",
        handler = function(entity, distance)
            return distance < 2.5
        end
    })
    
    Core.AddLocalEntityToTarget(mixedPed, {
        {
            name = "debug_mixed_multi_1",
            event = "devhub_lib:debug:mixedMulti1",
            icon = "fas fa-shopping-cart",
            label = "Buy Item",
            handler = function(entity, distance)
                return distance < 2.5
            end
        },
        {
            name = "debug_mixed_multi_2",
            event = "devhub_lib:debug:mixedMulti2",
            icon = "fas fa-coins",
            label = "Sell Item",
            handler = function(entity, distance)
                return distance < 2.5
            end
        }
    })
    print("[DEBUG] Spawned MIXED (single + multiple) target ped at 523.4284, -3278.5361, 46.2576")
    
    local propModel1 = `prop_barrel_02a`
    local propModel2 = `prop_tool_box_04`
    
    RequestModel(propModel1)
    RequestModel(propModel2)
    while not HasModelLoaded(propModel1) or not HasModelLoaded(propModel2) do Wait(10) end
    
    local prop1 = CreateObject(propModel1, 519.5087, -3276.0740, 46.1858 - 1.0, false, false, false)
    PlaceObjectOnGroundProperly(prop1)
    FreezeEntityPosition(prop1, true)
    
    Core.AddLocalEntityToTarget(prop1, {
        name = "debug_prop_single",
        event = "devhub_lib:debug:propSingle",
        icon = "fas fa-box",
        label = "Search Barrel",
        handler = function(entity, distance)
            return distance < 2.0
        end
    })
    print("[DEBUG] Spawned SINGLE target prop (barrel) at 519.5087, -3276.0740, 46.1858")
    
    local prop2 = CreateObject(propModel2, 519.5087 + 1.5, -3276.0740, 46.1858 - 1.0, false, false, false)
    PlaceObjectOnGroundProperly(prop2)
    FreezeEntityPosition(prop2, true)
    
    Core.AddLocalEntityToTarget(prop2, {
        {
            name = "debug_prop_multi_1",
            event = "devhub_lib:debug:propMulti1",
            icon = "fas fa-wrench",
            label = "Take Wrench",
            handler = function(entity, distance)
                return distance < 2.0
            end
        },
        {
            name = "debug_prop_multi_2",
            event = "devhub_lib:debug:propMulti2",
            icon = "fas fa-screwdriver",
            label = "Take Screwdriver",
            handler = function(entity, distance)
                return distance < 2.0
            end
        },
        {
            name = "debug_prop_multi_3",
            event = "devhub_lib:debug:propMulti3",
            icon = "fas fa-hammer",
            label = "Take Hammer",
            handler = function(entity, distance)
                return distance < 2.0
            end
        }
    })
    print("[DEBUG] Spawned MULTIPLE target prop (toolbox) at " .. (519.5087 + 1.5) .. ", -3276.0740, 46.1858")
    
    SetModelAsNoLongerNeeded(propModel1)
    SetModelAsNoLongerNeeded(propModel2)
    
    print("[DEBUG] Auto-spawn complete! " .. #debugPeds .. " peds, " .. #debugVehicles .. " vehicles, 2 props")
end

CreateThread(function()
    Wait(2000)
    AutoSpawnDebugEntities()
end)

RegisterNetEvent("devhub_lib:debug:pedInteract", function()
    print("[DEBUG] Single Ped interaction triggered!")
end)

RegisterNetEvent("devhub_lib:debug:vehicleInteract", function()
    print("[DEBUG] Single Vehicle interaction triggered!")
end)

RegisterNetEvent("devhub_lib:debug:pedInteract1", function()
    print("[DEBUG] Multiple Ped - Talk triggered!")
end)

RegisterNetEvent("devhub_lib:debug:pedInteract2", function()
    print("[DEBUG] Multiple Ped - Wave triggered!")
end)

RegisterNetEvent("devhub_lib:debug:pedInteract3", function()
    print("[DEBUG] Multiple Ped - Ask triggered!")
end)

RegisterNetEvent("devhub_lib:debug:vehicleInteract1", function()
    print("[DEBUG] Multiple Vehicle - Open Door triggered!")
end)

RegisterNetEvent("devhub_lib:debug:vehicleInteract2", function()
    print("[DEBUG] Multiple Vehicle - Lock triggered!")
end)

RegisterNetEvent("devhub_lib:debug:vehicleInteract3", function()
    print("[DEBUG] Multiple Vehicle - Check Fuel triggered!")
end)

RegisterNetEvent("devhub_lib:debug:teleportToTest", function()
    local ped = PlayerPedId()
    SetEntityCoords(ped, 524.2487, -3286.4900, 46.271, false, false, false, false)
    print("[DEBUG] Teleported to test location")
end)

RegisterNetEvent("devhub_lib:debug:coordsSingle", function()
    print("[DEBUG] Single Coords Target triggered!")
end)

RegisterNetEvent("devhub_lib:debug:coordsMulti1", function()
    print("[DEBUG] Multiple Coords - Search Area triggered!")
end)

RegisterNetEvent("devhub_lib:debug:coordsMulti2", function()
    print("[DEBUG] Multiple Coords - Open Crate triggered!")
end)

RegisterNetEvent("devhub_lib:debug:coordsMulti3", function()
    print("[DEBUG] Multiple Coords - Clean Up triggered!")
end)

RegisterNetEvent("devhub_lib:debug:globalPlayer", function()
    print("[DEBUG] Global Player interaction triggered!")
end)

RegisterNetEvent("devhub_lib:debug:mixedSingle", function()
    print("[DEBUG] Mixed - Look at NPC triggered!")
end)

RegisterNetEvent("devhub_lib:debug:mixedMulti1", function()
    print("[DEBUG] Mixed - Buy Item triggered!")
end)

RegisterNetEvent("devhub_lib:debug:mixedMulti2", function()
    print("[DEBUG] Mixed - Sell Item triggered!")
end)

RegisterNetEvent("devhub_lib:debug:propSingle", function()
    print("[DEBUG] Prop Single - Search Barrel triggered!")
end)

RegisterNetEvent("devhub_lib:debug:propMulti1", function()
    print("[DEBUG] Prop Multiple - Take Wrench triggered!")
end)

RegisterNetEvent("devhub_lib:debug:propMulti2", function()
    print("[DEBUG] Prop Multiple - Take Screwdriver triggered!")
end)

RegisterNetEvent("devhub_lib:debug:propMulti3", function()
    print("[DEBUG] Prop Multiple - Take Hammer triggered!")
end)
