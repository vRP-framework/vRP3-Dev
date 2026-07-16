local activeDialogPromise = nil
local activeCam = nil
local previousCam = nil
local talkSettings = {
    startTime = 0,
    textLength = 0,
    endTime = 0,
}

local exampleDialog = {
    npc = {
        name = "Bob Grass",
        role = "Citizen",
        icon = 'fas fa-user',
        camera = { -- @table (optional) camera settings for npc dialog
            distance = 0.85, -- @number (optional) camera distance from npc, default 0.85
            height = 0.65, -- @number (optional) camera height offset, default 0.65
        },
        animation = { -- @table (optional) animation to play on npc when dialog opens
            dict = "gestures@m@standing@casual", -- @string (required) animation dictionary
            name = "gesture_shrug_hard", -- @string (required) animation name
            blendIn = 8.0, -- @number (optional) blend in speed, default 8.0
            blendOut = -8.0, -- @number (optional) blend out speed, default -8.0
            duration = -1, -- @number (optional) animation duration in ms, -1 for full length, default -1
            flag = 2, -- @number (optional) animation flags (0 = normal, 1 = repeat, 2 = stop on last frame, etc.), default 1
            playbackRate = 0, -- @number (optional) playback rate, default 0
        },
    },
    soundFile = 'https://upload.devhub.gg/dh_upload/soundSample.mp3', -- @string (optional) sound file URL to play when dialog opens
    text = "We are happy to present the new devhub script license manager. Take your server to new heights with our unique features, making what was previously impossible a reality. Features include a license generator, fake license creation, license stealing detection, and a license scanner, among many others.",
    grid = {
        {
            uid = "talk_bob", -- @string (required) unique identifier for the option
            icon = 'fas fa-comment', -- @string (required) fontawesome icon class
            title = "Talk to Bob",  -- @string (required) option title, can be html
            badge = { -- @table (optional) badge config
                text = "Aggressive action", -- @string (optional) can be html
                color = "#ff0000", -- @string (optional) badge background color
            },
            span = 2, -- @number (optional) makes the option span 2 columns
        },
        {
            uid = "buy_items",
            icon = 'fas fa-shopping-cart',
            title = "Buy items",
        },
        {
            uid = "give_money",
            icon = 'fas fa-dollar-sign',
            title = "Give him money",
        },
        {
            uid = "goodbye",
            icon = 'fas fa-times',
            title = "Goodbye",
        }
    },
    -- input = {
    --     type = "number", -- @string (required) type of input: "number" or "text"
    --     default = 3, -- @number or @string (required) default value
    --     text = "I can give you %s dollars.", -- @string (required) text with %s placeholder for input value
    --     buttonText = "Give", -- @string (required) button text
    --     inputWidth = "3vw",  -- @string (optional) width of the input field
    --     min = 1, -- @number (optional) [type number] min number value
    --     max = 1000, -- @number (optional) [type number] max number value 
    --     maxLength = 7, -- @number (optional) [type text] only for type text
    --     hint = { -- @table (optional) hints for input values
    --         number = { -- [type number]
    --             [5] = "A small amount", -- from 0 to first option
    --             [50] = "A moderate amount", -- from first option to second
    --             [500] = "A large amount",
    --             [1000] = "An extremely large amount",
    --         },
    --         text = { -- [type text]
    --             ['orange'] = "Orange is not what im looking for",
    --             ['banana'] = "Banana is what i need",
    --         },
    --     }
    -- },
    -- items = {
    --     buttonText = "Give", -- @string (required) button text
    --     selectMultiple = false, -- @bool (optional) allow selecting multiple items, default false
    --     items = {
    --         { -- Select example
    --             name = 'dh_drill', -- @string item name (required)
    --             max = 99999, -- @number (optional), maximum selectable amount (set to 99999 if unlimited), if not set will fetch current user amount
    --             -- default = 3, -- @number (optional), default selected amount
    --             -- price = 150, -- @number (optional), only for buy/sell dialogs
    --         },
    --         { -- Buy example
    --             name = 'weapon_pistol',
    --             max = 3,
    --             price = 150,
    --         },
    --         { -- Sell example
    --             name = 'water',
    --             price = 150,
    --         },

    --     }
    -- },
    -- paymentMethod = {
    --     default = "cash", -- @string (optional) default selected method: "cash" or "card", default "cash"
    --     buttonText = "Confirm", -- @string (optional) button text, default "Confirm"
    --     cashLabel = "Cash", -- @string (optional) label for cash option, default "Cash"
    --     cardLabel = "Card", -- @string (optional) label for card option, default "Card"
    --     cashIcon = "fas fa-money-bill-wave", -- @string (optional) fontawesome icon for cash, default "fas fa-money-bill-wave"
    --     cardIcon = "fas fa-credit-card", -- @string (optional) fontawesome icon for card, default "fas fa-credit-card"
    -- },

}

Core.NpcDialog = function(entity, dialogData)

    if DoesEntityExist(entity) then
        local playerPed = PlayerPedId()
        
        -- Store original alpha and make player semi-transparent
        SetEntityAlpha(playerPed, 0, false)
        
        local playerCoords = GetEntityCoords(playerPed)
        local entityCoords = GetEntityCoords(entity)
        local entityHeading = GetEntityHeading(entity)
        
        -- Get camera settings from npc config or use defaults
        local distance = 0.85
        local height = 0.65
        if dialogData.npc and dialogData.npc.camera then
            distance = dialogData.npc.camera.distance or distance
            height = dialogData.npc.camera.height or height
        end
        
        local forwardVector = GetEntityForwardVector(entity)
        local camX = entityCoords.x + forwardVector.x * distance
        local camY = entityCoords.y + forwardVector.y * distance
        local camZ = entityCoords.z + height
        
        -- Create and activate camera
        if not activeCam then
            activeCam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", camX, camY, camZ, 0.0, 0.0, 0.0, 50.0, false, 0)
            PointCamAtEntity(activeCam, entity, 0.0, 0.0, height - 0.1, true)
            SetCamActive(activeCam, true)
            RenderScriptCams(true, true, 500, true, false)
        end
        
        -- Play NPC animation if provided
        if dialogData.npc and dialogData.npc.animation then
            local anim = dialogData.npc.animation
            if anim.dict and anim.name then
                RequestAnimDict(anim.dict)
                while not HasAnimDictLoaded(anim.dict) do
                    Wait(0)
                end
                local blendIn = anim.blendIn or 8.0
                local blendOut = anim.blendOut or -8.0
                local duration = anim.duration or -1
                local flag = anim.flag or 1
                local playbackRate = anim.playbackRate or 0
                TaskPlayAnim(entity, anim.dict, anim.name, blendIn, blendOut, duration, flag, playbackRate, false, false, false)
            end
        end
        
        -- Calculate speech duration and make ped speak
        if dialogData.text then
            local typingSpeedMs = 30 -- milliseconds per character (matches Vue component)
            talkSettings.textLength = string.len(dialogData.text)
            local speechDuration = (talkSettings.textLength * typingSpeedMs) -- duration in milliseconds
            
            -- Create a thread to manage mouth movement
            Citizen.CreateThread(function()
                talkSettings.startTime = GetGameTimer()
                talkSettings.endTime = talkSettings.startTime + speechDuration
                
                local lastAnimTime = GetGameTimer()
                
                -- Keep the mouth moving until duration is complete
                PlayFacialAnim(entity, "mic_chatter", "mp_facial")
                while GetGameTimer() < talkSettings.endTime do
                    -- Restart the facial animation periodically to ensure it keeps playing
                    if GetGameTimer() - lastAnimTime > 5000 then
                        PlayFacialAnim(entity, "mic_chatter", "mp_facial")
                        lastAnimTime = GetGameTimer()
                    end
                    Wait(100)
                end
                
                PlayFacialAnim(entity, "mood_normal_1", "facials@gen_male@variations@normal")
            end)
        end
    end

    return Core.Promise(function(resolve)
        -- Pre-fetch item data if items are present
        if dialogData.items and dialogData.items.items then
            local itemsAmount = {}
            for i, option in ipairs(dialogData.items.items) do
                local itemData = Core.GetItemData(option.name)
                option.label = itemData.label or option.name
                option.img = itemData.img or ""
                if option.max == nil then
                    table.insert(itemsAmount, option.name)
                end
            end
            if #itemsAmount > 0 then
                local amounts = Core.Promise(function(resolveItems)
                    Core.TriggerServerCallback('core:callback:getItemsAmount', function(amounts)
                        resolveItems(amounts)
                    end, itemsAmount)
                end)
                for i, option in ipairs(dialogData.items.items) do
                    if amounts[option.name] then
                        option.max = amounts[option.name] or 0
                        if option.default == nil or option.default > option.max then
                            option.default = option.max
                        end
                        if option.max <= 0 then option.default = 0 end
                    end
                end
            end
        end
        
        -- Store the promise resolver for callbacks to use
        activeDialogPromise = resolve
        
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = "openNpcDialog",
            dialogData = dialogData,
        })
    end)
end

Core.CloseNpcDialog = function()
    -- Restore player alpha
    local playerPed = PlayerPedId()
    ResetEntityAlpha(playerPed)
    
    -- Restore camera
    if activeCam then
        RenderScriptCams(false, true, 500, true, false)
        DestroyCam(activeCam, false)
        activeCam = nil
    end

    talkSettings.endTime = GetGameTimer()
    if activeDialogPromise then
        print("Dialog closed by user")
        
        -- Restore camera
        if activeCam then
            RenderScriptCams(false, true, 500, true, false)
            DestroyCam(activeCam, false)
            activeCam = nil
        end
        
        activeDialogPromise({ status = false, data = { } })
        activeDialogPromise = nil
    end

    SetNuiFocus(false, false)
    
    SendNUIMessage({
        type = "closeNpcDialog",
    })
end

RegisterNUICallback('npcDialogSubmit', function(data, cb)
    cb('ok')
    
    if activeDialogPromise then
        
        activeDialogPromise({ status = true, data = data })
        activeDialogPromise = nil
    end
end)

RegisterNUICallback('npcDialogAudioDuration', function(data, cb)
    cb('ok')
    
    if data.duration and data.typingSpeed then
        print("Audio duration: " .. data.duration .. " ms, Typing speed: " .. data.typingSpeed .. " ms per char")
        talkSettings.endTime = talkSettings.startTime + math.max(data.duration, talkSettings.textLength * data.typingSpeed)
    end
end)

RegisterNUICallback('npcDialogSoundSkipped', function(data, cb)
    cb('ok')
    
    print("Sound was skipped by user")
    -- Force end the talking animation immediately
    talkSettings.endTime = GetGameTimer()
end)

RegisterNUICallback('npcDialogClose', function(data, cb)
    cb('ok')
    Core.CloseNpcDialog()
end)