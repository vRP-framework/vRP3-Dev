local Peds = {}
createExport('addPedToCoords', function(model, coords)
    if not model or not coords or not coords.w then print('WRONG EXPORT VALUE',model,coords) return end
    for i=1, #Peds do
        local pedConfig = Peds[i]
        if coords.x == pedConfig.coords.x and coords.y == pedConfig.coords.y and coords.z == pedConfig.coords.z then
            print('PED ALREADY EXISTS',model)
            return
        end
    end
    Peds[#Peds+1] = {
        coords = coords,
        model = model,
    }
end) 
 

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        for i=1,#Peds do
            local pedConfig = Peds[i]
            local distance = #(coords - vec3(pedConfig.coords.x, pedConfig.coords.y, pedConfig.coords.z))
            if distance <= 75 and not pedConfig.spawned then
                pedConfig.spawned = true
                spawnPeds(pedConfig)
            elseif distance > 75 and pedConfig.spawned then
                pedConfig.spawned = false
                DeleteEntity(pedConfig.ped)
            end
        end
        Wait(1000)
    end
end)

function spawnPeds(v)
    local modelHash = GetHashKey(v.model)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Citizen.Wait(0)
    end
    local correctZ = v.coords.z - 1.0
    local thisPed = CreatePed(26, modelHash, v.coords.x, v.coords.y, correctZ,  v.coords.w, false, false)
    v.ped = thisPed
    Citizen.Wait(1)
    SetEntityInvincible(thisPed, true)
    TaskSetBlockingOfNonTemporaryEvents(thisPed, true)
    SetBlockingOfNonTemporaryEvents(thisPed, true)
    SetEntityAsMissionEntity(thisPed, true, true)
    FreezeEntityPosition(thisPed, true)  
    if v.anim then 
        RequestAnimDict(v.animDict)
        while not HasAnimDictLoaded(v.animDict) do
            Citizen.Wait(0)
        end
        TaskPlayAnim(thisPed, v.animDict, v.anim, 8.0, 8.0, -1, 1, 1.0, 0, 0, 0)
    elseif v.animDict then 
        TaskStartScenarioInPlace(thisPed, v.animDict, 0, false)
    end
    if not v.options then 
        SetPedDefaultComponentVariation(thisPed)
    else
        if v.options.torso then 
            SetPedComponentVariation(thisPed, 3, 0, tonumber(v.options.torso), 0)
        end

        if v.options.pants then 
            SetPedComponentVariation(thisPed, 4, 0, tonumber(v.options.pants), 0)
        end

        if v.options.mask then 
            SetPedComponentVariation(thisPed, 1, 0, tonumber(v.options.mask), 0)
        end

        if v.options.shoes then 
            SetPedComponentVariation(thisPed, 6, 0, tonumber(v.options.shoes), 0)
        end
    end
end
