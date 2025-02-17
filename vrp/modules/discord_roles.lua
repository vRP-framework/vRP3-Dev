-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.discord_roles then return end

local discord_roles = class("discord_roles", vRP.Extension)

local cfg = module("vrp", "cfg/discord_roles")

local function contains(t, value)
    for k, v in pairs(t) do
        if v == value then
            return true
        end
    end
    return false
end

local function getDiscordID(source)
    local identifiers = GetPlayerIdentifiers(source)
    for i, identifier in ipairs(identifiers) do
        local type, value = table.unpack(splitString(identifier, ':'))
        if type == 'discord' then
            print("Found Discord ID: " .. value)
            return value
        end
    end
    print("No Discord ID found for player " .. source)
end


if not cfg or not cfg.token or not cfg.guildId or not cfg.groups then
    print("[ERROR] Discord Roles: Configuration is missing required fields. Please check vrp/cfg/discord_roles")
    return
end

local function fetchDiscordMember(guild_id, user_id)
    local r = async()

    PerformHttpRequest(("https://discord.com/api/guilds/%s/members/%s"):format(guild_id, user_id), function (code, data, headers)
        if code == 200 then
            print("Successfully fetched Discord member data.")
            r(json.decode(data))
        else
            print("[ERROR] discord_roles: Failed to fetch member data from Discord API. Code: " .. code)
            r(nil)
        end
    end, 'GET', '', { ["Authorization"] = cfg.token })
    
    return r:wait()
end

local function checkPlayerRoles(user)
    local discord_id = getDiscordID(user.source)
    if discord_id == nil then
        return
    end

    local member = fetchDiscordMember(cfg.guildId, discord_id)
    if member == nil then
        return
    end

    for i, entry in ipairs(cfg.groups) do
        local hasRole = contains(member.roles, entry.roleId)  
        local hasGroup = user:hasGroup(entry.group)  

        if hasRole and not hasGroup then
            user:addGroup(entry.group)
            vRP.EXT.Base.remote._notifyPicture(user.source,"CHAR_LESTER", 1, "Discord Sync", "Role Assigned", "You have been assigned the '" .. entry.group .. "' role.")
        elseif not hasRole and hasGroup then
            user:removeGroup(entry.group)
            vRP.EXT.Base.remote._notifyPicture(user.source,"CHAR_BLOCKED", 2, "Discord Sync", "Role Removed", "Your " .. entry.group .. " role has been removed.")
        end
    end

    local userGroups = user:getGroups()
    print("Checking user's groups in vRP:")
    for groupName, _ in pairs(userGroups) do
        print(" - " .. groupName)
    end
end

discord_roles.event = {}

function discord_roles.event:characterLoad(user)
    checkPlayerRoles(user)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(cfg.timer_check_roles) 
        for _, user in pairs(vRP.users) do
            if user.source then
                checkPlayerRoles(user)
            end
        end
        print("[Discord Roles] Role check completed for all players.")
    end
end)

vRP:registerExtension(discord_roles)
