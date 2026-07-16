local PlayingAnim = false
local AnimProp = nil

Core.StartAnim = function(data)
    if PlayingAnim then return end
    local dict = data[1]
    local anim = data[2]
    local flag = 0
    if data.AnimationOptions.EmoteLoop then
        flag = 1
    elseif data.AnimationOptions.EmoteMoving then
        flag = 51 
    end
    RequestAnimDict(dict)
    for i = 1, 100 do 
        if HasAnimDictLoaded(dict) then 
            break
        end
        Wait(10)
    end  
    if not HasAnimDictLoaded(dict) then return end
    local ped = PlayerPedId()
    PlayingAnim = true 
    if data.AnimationOptions.Prop then 
        if not Core.RequestModel(data.AnimationOptions.Prop) then
            print("Failed to load prop model: " .. data.AnimationOptions.Prop)
            return
        end
        local coords = GetEntityCoords(ped)
        AnimProp = CreateObject(GetHashKey(data.AnimationOptions.Prop), coords.x, coords.y, coords.z + 0.2, true, true, true)
        local propPlacement = data.AnimationOptions.PropPlacement
        AttachEntityToEntity(AnimProp, ped, GetPedBoneIndex(ped, data.AnimationOptions.PropBone), propPlacement[1], propPlacement[2], propPlacement[3], propPlacement[4], propPlacement[5], propPlacement[6], true, true,
        false, true, 1, true)
        SetModelAsNoLongerNeeded(AnimProp)
    end
    TaskPlayAnim(PlayerPedId(), dict, anim, 2.0, 2.0, -1, flag, 0, false, false, false)
    CreateThread(function()
        while PlayingAnim do 
            if not IsEntityPlayingAnim(ped, dict, anim, 3) then
                TaskPlayAnim(ped, dict, anim, 2.0, 2.0, -1, flag, 0, false, false, false)
            end
            Wait(100)
        end
        ClearPedTasks(ped)
    end)
end

Core.StopAnim = function()
    if not PlayingAnim then return end
    PlayingAnim = false
    if AnimProp then
        DeleteObject(AnimProp)
        AnimProp = nil
    end
end
