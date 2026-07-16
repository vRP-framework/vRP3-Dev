function Core.DumpTable(table, nb)
    nb = nb or 0 
    local indent = string.rep("    ", nb) -- Tworzy poprawne wcięcie

    if type(table) == "table" then
        local s = "{\n" -- Otwieramy nową tabelę na nowej linii
        for k, v in pairs(table) do
            local key = (type(k) == "number") and ("[" .. k .. "]") or ("[\"" .. k .. "\"]")
            s = s .. indent .. "    " .. key .. " = " .. Core.DumpTable(v, nb + 1) .. ",\n"
        end
        return s .. indent .. "}" -- Zamykamy tabelę na tej samej głębokości
    else
        return type(table) == "string" and ("\"" .. table .. "\"") or tostring(table)
    end
end


function Core.RequestModel(modelHash, cb)
    local originalName = modelHash
	modelHash = (type(modelHash) == 'number' and modelHash or GetHashKey(modelHash))

	if not HasModelLoaded(modelHash) then
		RequestModel(modelHash)
        local attempts = 0
		while not HasModelLoaded(modelHash) do
            attempts = attempts + 1
            if attempts > 100 then
                print("Failed to load model: " .. modelHash.. " | " .. originalName)
                if cb ~= nil then
                    cb()
                end
                return false
            end
			Citizen.Wait(1)
		end
	end

	if cb ~= nil then
		cb()
	end
    return true
end

function Core.GetClosestVehicle(coords)
    local ped = PlayerPedId()
    local vehicles = GetGamePool('CVehicle')
    local closestDistance = -1
    local closestVehicle = -1
    if coords then
        coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords
    else
        coords = GetEntityCoords(ped)
    end
    for i = 1, #vehicles, 1 do
        local vehicleCoords = GetEntityCoords(vehicles[i])
        local distance = #(vehicleCoords - coords)

        if closestDistance == -1 or closestDistance > distance then
            closestVehicle = vehicles[i]
            closestDistance = distance
        end
    end
    return closestVehicle, closestDistance
end
function Core.GetObjects()
	return GetGamePool('CObject') 
end 

function Core.SpawnObject(model, coords, cb, isLocal)
	local model = (type(model) == 'number' and model or GetHashKey(model))
	if not Core.RequestModel(model) then
        return false
    end
	local networked = true 
	if isLocal then 
		networked = false
	end
	local obj = CreateObject(model, coords.x, coords.y, coords.z, networked, false, networked)
	if cb then
		cb(obj)
	end
    return obj
end
function Core.DeleteVehicle(vehicle)
    local plate = GetVehicleNumberPlateText(vehicle)
    Core.RemoveVehicleKeys(plate, vehicle)
    SetEntityAsMissionEntity(vehicle, false, true) 
    local attempt = 0
    NetworkRequestControlOfEntity(vehicle)
    while not NetworkHasControlOfEntity(vehicle) and attempt < 100 do
        attempt = attempt + 1
        Wait(10)
    end
    if attempt >= 100 then
        return false
    end
    attempt = 0
    while DoesEntityExist(vehicle) and attempt < 100 do
        attempt = attempt + 1
        SetEntityAsMissionEntity(vehicle, false, true)
        DeleteEntity(vehicle)
        Wait(10)
    end
    if attempt >= 100 then
        return false
    end
    return true
end

function Core.SpawnVehicle(modelName, coords, heading, cb, _networked, fuel)
	local model = (type(modelName) == 'number' and modelName or GetHashKey(modelName))
	Citizen.CreateThread(function()
		if not Core.RequestModel(model) then
            if cb then
                cb(false)
            end
            return false
        end
		local networked = _networked ~= nil and _networked or true
		local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, networked, networked)
		local id      = NetworkGetNetworkIdFromEntity(vehicle)
		SetNetworkIdCanMigrate(id, true)
		SetModelAsNoLongerNeeded(model)
		SetVehicleAsNoLongerNeeded(vehicle)
		SetVehicleNeedsToBeHotwired(vehicle, false)
        SetVehicleHasBeenOwnedByPlayer(vehicle, true)
        SetEntityAsMissionEntity(vehicle, true, true)
        SetVehicleIsStolen(vehicle, false)
        SetVehicleIsWanted(vehicle, false)
        SetVehRadioStation(vehicle, 'OFF')
        local plate = GetVehicleNumberPlateText(vehicle) 
        Core.AddVehicleKeys(plate, vehicle)
        Core.SetVehicleFuel(vehicle, fuel or 100.0)
        RequestCollisionAtCoord(coords.x, coords.y, coords.z)
		while not HasCollisionLoadedAroundEntity(vehicle) do
			RequestCollisionAtCoord(coords.x, coords.y, coords.z)
			Citizen.Wait(0)
		end
		if cb ~= nil then
			cb(vehicle)
		end
	end)
end 

function Core.IsSpawnPointClear(coords, radius)
    local vehicles = GetGamePool('CVehicle')
	for i=1, #vehicles, 1 do
		local vehicleCoords = GetEntityCoords(vehicles[i])
		local dist = #(coords - vehicleCoords)
		if dist <= radius then
			return false
		end
	end
	return true
end

function Core.AddBlip(coords, sprite, color, scale, name)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, color)
    SetBlipScale(blip, scale)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(name)
    EndTextCommandSetBlipName(blip)
    return blip
end

function Core.RemoveBlip(blip)
    RemoveBlip(blip)
end

function Core.GetClosestPlayers(distance)
    if not distance then distance = 10.0 end
    local players = {}
    local pid = PlayerId()
    local activePlayers = GetActivePlayers()
    local coords = GetEntityCoords(PlayerPedId())

    for i = 1, #activePlayers do
        local currPlayer = activePlayers[i]
        local ped = GetPlayerPed(currPlayer)
        if DoesEntityExist(ped) and currPlayer ~= pid then
            local plyCoords = GetEntityCoords(ped)
            local dist = #(coords - plyCoords)
            if dist <= distance then
                players[#players + 1] = { ped = ped, player = currPlayer, id = GetPlayerServerId(currPlayer), name = GetPlayerName(currPlayer), distance = dist}
            end
        end
    end

    return players
end


function Core.GenerateRandomChar(length)
    local charset = {}
    for i = 48,  57 do table.insert(charset, string.char(i)) end
    for i = 65,  90 do table.insert(charset, string.char(i)) end
    for i = 97, 122 do table.insert(charset, string.char(i)) end
    if not length or length <= 0 then return '' end
    return Core.GenerateRandomChar(length - 1) .. charset[math.random(1, #charset)]
end
 
function Core.Notify(text, duration, notificationType)
    local notifyType = CustomUi.NotifyTypes[notificationType] or CustomUi.NotifyTypes['info']
    if not CustomUi.Notify(text, duration, notifyType) then
        -- notificationType: 'info', 'error', 'success', 'warning'
        -- placement: top-left, top-right, bottom-left, bottom-right
        -- duration: in ms
        local placement = "top-right"
        local duration = tonumber(duration) or 5000
        SendNUIMessage({
            type = "notify",
            placement = placement,
            text = text,
            duration = duration
        })
    end
end

RegisterNetEvent("dh_lib:client:notify", function(text, duration, notificationType)
    Core.Notify(text, duration, notificationType)
end)

function Core.ShowStaticMessage(text, position)
    if not CustomUi.ShowStaticMessage(text) then
        -- placement: top-left, top-right, bottom-left, bottom-right
        local placement = position or CustomUi.StaticMessagePosition
        SendNUIMessage({
            type = "static",
            text = text,
            placement = placement,
            close = (text == nil or text == false)
        })
    end
end

function Core.ShowControlButtons(text, position)
    if not CustomUi.ShowControlButtons(text) then
        -- placement: top-left, top-right, bottom-left, bottom-right
        local placement = position or CustomUi.ControlButtonsPosition
        SendNUIMessage({
            type = "controls",
            text = text,
            placement = placement,
            close = (text == nil or text == false)
        })
    end
end



local progressbarCb = nil
local progressbarBusy = false
function Core.ShowProgressbar(data, cb)
    if not CustomUi.ShowProgressbar(data, cb) then
        if progressbarBusy then print("Progressbar is busy") return end
        progressbarBusy = true
        local duration = data?.duration --@required in ms
        if not duration then print("Duration is required for progressbar") return end
        -- placement: low, medium, high
        local placement = data?.placement or CustomUi.ProgressbarPlacement
        local text = data?.text or "Loading..."
        local canStop = data?.canStop or false
        SendNUIMessage({
            type = "progressbar",
            text = text,
            placement = placement,
            duration = duration
        })
        if canStop then 
            while progressbarCb == nil do 
                if IsControlJustPressed(0, 73) then 
                    SendNUIMessage({
                        type = "progressbar",
                        close = true
                    })
                    if cb then 
                        cb(false)
                    end
                    return false
                end
                Wait(1)
            end
        else 
            while progressbarCb == nil do 
                Wait(50)
            end
        end
        local temp = progressbarCb
        progressbarCb = nil
        progressbarBusy = false
        if cb then 
            cb(temp)
        else 
            return temp
        end
    end
end
 
RegisterNUICallback("progressbarResult", function(data, cb)
    progressbarCb = true
    cb('ok')
end)

function Core.CloseProgressbar()
    if not CustomUi.CloseProgressbar() then
        SendNUIMessage({
            type = "progressbar",
            close = true
        })
    end
end

local inVeh = false
local isDriver = false
CreateThread(function()
    while true do 
        local sleep = 500 
        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped, false)
        if not inVeh then 
            if veh ~= 0 then 
                inVeh = true
                -- print("Entered vehicle")
                local seat = GetPedInVehicleSeat(veh, -1)
                if seat == ped then 
                    -- print("Driver entered")
                    isDriver = true
                    TriggerEvent("dh_lib:client:vehicleStatus", veh, true, true)
                else 
                    -- print("Passenger entered")
                    isDriver = false
                    TriggerEvent("dh_lib:client:vehicleStatus", veh, true, false)
                    CreateThread( function()
                        passengerWaiting(veh)
                    end)
                end
            end
        elseif inVeh then
            if veh == 0 then 
                inVeh = false
                -- print("Exited vehicle")
                isDriver = false
                TriggerEvent("dh_lib:client:vehicleStatus", nil, false, false)
            end
            if not isDriver then 
                local ped = PlayerPedId()
                local seat = GetPedInVehicleSeat(veh, -1)
                if seat == ped then 
                    -- print("Driver entered")
                    isDriver = true
                    TriggerEvent("dh_lib:client:vehicleStatus", veh, true, true)
                end
            end
        end
        Wait(sleep)
    end
end)

function passengerWaiting(veh)
    while inVeh do 
        local ped = PlayerPedId()
        local seat = GetPedInVehicleSeat(veh, -1)
        if seat == ped then 
            TriggerEvent("dh_lib:client:vehicleStatus", veh, true, true)
            isDriver = true
            break
        end
        Wait(1000)
    end
end

Core.SendLog = function(webhook, data)
    TriggerServerEvent("dh_lib:server:sendLog", GetPlayerServerId(PlayerId()), webhook, data)
end

Core.Promise = function(func)
    local p = promise:new()

    local function resolve(value)
        p:resolve(value)
    end

    -- Safely execute the function
    Citizen.CreateThread(function()
        func(resolve)
    end)

    return Citizen.Await(p)
end

-- local result = Core.Promise(function(resolve)
--     Citizen.CreateThread(function()
--         Citizen.Wait(1000)

--         resolve("Async operation result")
--     end)
-- end)

-- print(result) -- "Async operation result"

Core.GetClientTimestamp = function()
    local year, month, day, hour, minute, second = GetUtcTime()
    local function isLeapYear(y)
        return (y % 4 == 0 and y % 100 ~= 0) or (y % 400 == 0)
    end
    local daysInMonth = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
    local days = 0

    for y = 1970, year - 1 do
        days = days + (isLeapYear(y) and 366 or 365)
    end

    for m = 1, month - 1 do
        days = days + daysInMonth[m]
    end

    if month > 2 and isLeapYear(year) then
        days = days + 1
    end

    days = days + (day - 1)

    local timestamp = days * 86400 + hour * 3600 + minute * 60 + second
    return timestamp
end

Core.GenerateUid = function()
    local serverId = GetPlayerServerId(PlayerId())
    return serverId..'DHC'..Core.GetClientTimestamp()
end

Core.DecisionPrompt = function(settings, buttons)
    return DecisionPrompt(settings, buttons)
end

local decisionPromise = nil 
function DecisionPrompt(settings, buttons)
    decisionPromise = promise:new()
    settings.placement = settings.placement or "top-right" --"bottom-right", "bottom-left", "top-right", "top-left"
    if settings.time and settings.time < 2000 then settings.time = 2000 end
    local time = settings.time or 10000
    SendNUIMessage({
        type = "createDecision",
        title = settings.title,
        text = settings.text,
        placement = settings.placement,
        time = time,
        buttons = buttons
    })
    CreateThread(function()
        while decisionPromise do
            for k,v in pairs(buttons) do
                DisableControlAction(0, v.key, true)
                if IsDisabledControlJustPressed(0, v.key) then 
                    decisionPromise:resolve(v.action)
                end
            end
            Wait(1)
        end
    end)
    CreateThread(function()
        while decisionPromise do
            time = time - 1000
            if time <= 0 then
                decisionPromise:resolve(settings.timeRunOutAction or "decline")
            end
            Wait(1000)
        end
    end)
    local decisionResult = Citizen.Await(decisionPromise)
    decisionPromise = nil
    SendNUIMessage({
        type = "closeDecision",
    })
    return decisionResult
end

Core.PlayAnim = function(animDict, animName, duration, flags)
    if not animDict or not animName then return false end
    local ped = PlayerPedId()
    if not IsEntityPlayingAnim(ped, animDict, animName, 3) then
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Wait(100)
        end
        TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, duration or -1, flags or 1, 0.0, false, false, false)
    end
end
 
Core.CopyClipboard = function(text)
    if not text or text == "" then return false end
    SendNUIMessage({
        type = "copyClipboard",
        text = text
    })
    return true
end

local popupFormCb = nil
RegisterNUICallback("popupFormResult", function(result, cb)
    SetNuiFocus(false, false)
    popupFormCb = result
    cb('ok')
end)

Core.PopupForm = function(data)
    if not CustomUi.PopupForm(data, cb) then
        SendNUIMessage({
            type = "popupForm",
            data = data
        })
        SetNuiFocus(true, true)
        popupFormCb = nil
        while popupFormCb == nil do
            Wait(50)
        end
        cbData = popupFormCb
        popupFormCb = nil
        SetNuiFocus(false, false)
        return cbData.status, cbData.data
    end
end

Core.GetOnlinePoliceCount = function()
    local p = promise:new()
    Core.TriggerServerCallback('devhub_lib:getOnlinePoliceCount',function(data)
        p:resolve(data)
    end)
    return Citizen.Await(p)
end

-- Required Items UI
-- Shows a display of required items with their quantities and status
-- @param data table: { title?: string, items: { name: string, amount: number }[], checkAmount?: boolean }
-- @param cb function: callback when items are ready (optional, used when checkAmount is true)
Core.ShowRequiredItems = function(data, cb)
    if not data or not data.items then 
        print("[devhub_lib] ShowRequiredItems: items are required")
        return false 
    end
    
    local checkAmount = data.checkAmount ~= false -- default true
    local itemNames = {}
    for _, item in ipairs(data.items) do
        itemNames[#itemNames + 1] = item.name
    end
    
    local function sendItems(itemCounts)
        local items = {}
        for _, item in ipairs(data.items) do
            local itemData = Core.GetItemData(item.name)
            local count = itemCounts and itemCounts[item.name] or 0
            local requiredAmount = item.amount or 1
            items[#items + 1] = {
                name = item.name,
                label = itemData and itemData.label or item.name,
                img = itemData and itemData.img or "",
                amount = requiredAmount,
                hasItem = (not checkAmount) or (count >= requiredAmount)
            }
        end
        
        SendNUIMessage({
            type = "showRequiredItems",
            title = data.title,
            items = items,
            checkAmount = checkAmount
        })
        
        if cb then cb(items) end
    end
    
    if checkAmount then
        Core.TriggerServerCallback('core:callback:getItemsAmount', function(itemCounts)
            sendItems(itemCounts)
        end, itemNames)
    else
        sendItems(nil)
    end
    
    return true
end

-- Hides the required items UI
Core.HideRequiredItems = function()
    SendNUIMessage({
        type = "hideRequiredItems"
    })
end