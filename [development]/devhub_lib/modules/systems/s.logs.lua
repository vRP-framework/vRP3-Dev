RegisterNetEvent('dh_lib:server:sendLog',function(_source, webhook, data)
    local identifier = ""
    local message = ""
    if _source then
        identifier = Core.GetIdentifier(_source)
        message = message .. "**Player:** " .. GetPlayerName(_source) .. " (".._source..")\n**Identifier: **" .. identifier .. "\n\n"
    else
        message = "**Identifier: SYSTEM**\n\n"
    end
    for k,v in pairs(data) do
        message = message .. "**"..Core.String.Capitalize(k)..":** " .. tostring(v) .. "\n"
    end

    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({
        embeds = { {
            ["color"] = 16640286,
            ["description"] = message,
            ["footer"] = {
                ["text"] = "DEVHUB.GG "..os.date("%H:%M:%S"),
            },
        } },
    }), {['Content-Type'] = 'application/json'})
end)