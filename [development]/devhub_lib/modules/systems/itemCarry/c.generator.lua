if not Shared.DevelopmentMode then 
    return
end 

local Offset, Rotation
local InCreator = false
local PropObj = nil
local StepSpeed = 0.5

local function getDefaultMenuArgs()
    return {
        { label = "X: ", min = -10.0, max = 10.0 },
        { label = "Y: ", min = -10.0, max = 10.0 },
        { label = "Z: ", min = -10.0, max = 10.0 },
        { label = "Rot X: ", min = -180.0, max = 180.0 },
        { label = "Rot Y: ", min = -180.0, max = 180.0},
        { label = "Rot Z: ", min = -180.0, max = 180.0 },
        { label = "Step: ", value = 0.5, options = {0.01, 0.1, 0.2, 0.5, 1.0} },
    }
end

local MenuArgs = getDefaultMenuArgs()

local function getActiveIndex()
    for i, v in ipairs(MenuArgs) do
        if v.active then 
            return i
        end
    end
    return 1
end

local function setActiveIndex(index)
    for i, v in ipairs(MenuArgs) do
        v.active = false
    end
    MenuArgs[index].active = true
end

local function clamp(val, min, max)
    if val < min then return min end
    if val > max then return max end
    return val
end

local function getValue(index)
    local value = MenuArgs[index].value or 0.0
    return string.format("%.2f", value)
end

local function formatControlsToText()
    local text = "<div style='width: 5vw;'>"
    for i, v in ipairs(MenuArgs) do
        if v.active then 
            text = text .. "<font color='orange'>" ..v.label .. getValue(i).. " <-</font>".. ( i ~= #MenuArgs and "<br><br>" or "")
        else
            text = text .. v.label .. getValue(i) .. ( i ~= #MenuArgs and "<br><br>" or "")
        end
    end
    text = text .. "<br><br><div style='display:flex; align-items:center; '><kbd>ENTER</kbd> - Save</div>"
    text = text .. "</div>"
    return text
end

local function formatConfig(item, propName)
    local config = [[["%s"] = { prop = "%s", offset = vec3(%s, %s, %s), rotation = vec3(%s, %s, %s), anim = "%s" }]]
    return string.format(config, item, propName, 
        Offset[1], Offset[2], Offset[3], 
        Rotation[1], Rotation[2], Rotation[3], 
        MenuArgs[1].anim or "1")
end

local function changeValue(direction)
    local index = getActiveIndex()
    
    if index == 7 then -- Step speed option
        local options = MenuArgs[index].options
        local currentValue = MenuArgs[index].value or 0.5
        local currentIndex = 3 -- Default to 0.5
        
        -- Find current index in options
        for i, v in ipairs(options) do
            if math.abs(v - currentValue) < 0.001 then
                currentIndex = i
                break
            end
        end
        
        -- Move to next/previous option
        currentIndex = currentIndex + direction
        if currentIndex < 1 then currentIndex = #options end
        if currentIndex > #options then currentIndex = 1 end
        
        MenuArgs[index].value = options[currentIndex]
        StepSpeed = options[currentIndex]
        Wait(250)
    else
        local step = index <= 3 and (0.005 * StepSpeed) or (1.0 * StepSpeed)

        local value = MenuArgs[index].value or 0.0
        local min = MenuArgs[index].min or -10.0
        local max = MenuArgs[index].max or 10.0

        value = clamp(value + (direction * step), min, max)
        MenuArgs[index].value = value

        if index <= 3 then 
            Offset[index] = value
        else 
            Rotation[index - 3] = value
        end
    end

    Core.ShowControlButtons(formatControlsToText(), 'top-right')
end

local function moveMenu(direction)
    local index = getActiveIndex()
    index = index + direction
    if index < 1 then 
        index = #MenuArgs
    elseif index > #MenuArgs then 
        index = 1
    end
    setActiveIndex(index)
    Core.ShowControlButtons(formatControlsToText(), 'top-right')
end

RegisterCommand("propgenerator", function(_, args)
    if InCreator then 
        return 
    end
    local item = args[1]
    local propName = args[2]
    local anim = '1'
    InCreator = true 
    Offset, Rotation = { 0.0, 0.0, 0.0 }, { 0.0, 0.0, 0.0 }
    MenuArgs = getDefaultMenuArgs()
    MenuArgs[1].active = true
    StepSpeed = MenuArgs[7].value or 0.5
    local animation = Animations[anim]
    local ped = PlayerPedId()
    local playerCoords = GetEntityCoords(ped)
    local obj = Core.SpawnObject(propName, playerCoords, nil, true)
    local attempt = 0
    while not DoesEntityExist(obj) do
        attempt = attempt + 1
        if attempt > 10 then
            Core.Notify("Failed to spawn prop, please try again.", 5000, "error")
            InCreator = false
            return
        end
        Wait(100)
    end
    PropObj = obj 
    Core.ShowControlButtons(formatControlsToText(), 'top-right')
    PlayAnimation(animation[1], animation[2], obj, vec3(Offset[1], Offset[2], Offset[3]), vec3(Rotation[1], Rotation[2], Rotation[3]))
    CreateThread(function()
        while InCreator do 
            local update = false
            if IsDisabledControlJustPressed(0, 172) then 
                moveMenu(-1)
            end
            if IsDisabledControlJustPressed(0, 173) then 
                moveMenu(1)
            end
            if IsDisabledControlPressed(0, 174) then 
                changeValue(-1)
                update = true
            end
            if IsDisabledControlPressed(0, 175) then 
                changeValue(1)
                update = true
            end
            if IsDisabledControlJustPressed(0, 18) then 
                InCreator = false
                Core.CopyClipboard(formatConfig(item, propName))
                Core.Notify("Config copied to clipboard, you can paste it in config.lua", 10000, "success")
            end
            if IsDisabledControlJustPressed(0, 322) then
                InCreator = false
            end
            if update then 
                AttachEntityToEntity(obj, ped, GetPedBoneIndex(ped, 60309), Offset[1], Offset[2], Offset[3], Rotation[1], Rotation[2], Rotation[3], true, true, false, true, 1, true)
            end
            Wait(1)
        end
        DeleteEntity(obj)
        Core.ShowControlButtons()
        local ped = PlayerPedId()
        ClearPedTasks(ped)
    end)
end)
