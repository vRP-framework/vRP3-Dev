function Core.Notify(source, text, duration, notificationType)
    TriggerClientEvent("dh_lib:client:notify", source, text, duration, notificationType)
end
function Core.DumpTable(table, nb)
    if nb == nil then 
        nb = 0
    end 
    if type(table) == 'table' then
        local s = ''
        for i = 1, nb + 1, 1 do
            s = s .. "    "
        end
        s = '{\n'
        for k,v in pairs(table) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            for i = 1, nb, 1 do
                s = s .. "    "
            end
            s = s .. '['..k..'] = ' .. Core.DumpTable(v, nb + 1) .. '",\n'
        end
        for i = 1, nb, 1 do
            s = s .. "    "
        end
        return s .. '}'
    else
        return tostring(table)
    end
end
Core.SendLog = function(source, webhook, data)
    TriggerEvent("dh_lib:server:sendLog", source, webhook, data)
end

Core.GetPlayerPicture = function(source)
    if not GetPlayerName(source) then return false end

    local steam = GetIdentifier(source, "steam")
    if not steam then
        return "https://winaero.com/blog/wp-content/uploads/2018/08/Windows-10-user-icon-big.png"
    end
    local url
    PerformHttpRequest("https://steamcommunity.com/profiles/" .. tonumber(steam, 16), function(_, text, _) 
        if not text then url = false end
        url = text:match('<meta name="twitter:image" content="(.-)"')
    end, "GET")
    while url == nil do
        Wait(0)
    end
    return url
end

Core.GenerateUid = function(serverId)
    if not serverId then  
        serverId = math.random(1000, 9999)
    end
    return serverId..'DHS'..os.time()
end

local CachedPoliceCount = 0
 
CreateThread(function()
    Core.RegisterServerCallback('devhub_lib:getOnlinePoliceCount', function(source, cb)
        local policeCount = Core.GetOnlinePoliceCount()
        cb(policeCount)
    end)
    while true do
        Wait(180000)
        local players = GetPlayers()
        local playerCount = #players
        if playerCount > 40 then
            local policeCount = 0
            for _, playerId in ipairs(players) do
                local job = Core.GetJob(playerId)
                if job and job.name == 'police' then
                    policeCount = policeCount + 1
                end
                Wait(100)
            end
            CachedPoliceCount = policeCount
        end
    end
end)

Core.GetOnlinePoliceCount = function()
    local playerCount = #GetPlayers()
    
    if playerCount > 40 then
        return CachedPoliceCount
    end
    
    local policeCount = 0
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        local job = Core.GetJob(playerId)
        if job and job.name == 'police' then
            policeCount = policeCount + 1
        end
        Wait(1)
    end
    
    CachedPoliceCount = policeCount
    
    return policeCount
end