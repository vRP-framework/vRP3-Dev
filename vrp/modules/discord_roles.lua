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

-- Helper: Split string by separator
local function splitString(str, sep)
    local result = {}
    for part in string.gmatch(str, "([^" .. sep .. "]+)") do
        table.insert(result, part)
    end
    return result
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


-- Config validation
if not cfg or not cfg.token or not cfg.guildId or not cfg.groups then
    print("[ERROR] Discord Roles: Configuration is missing required fields. Please check vrp/cfg/discord_roles")
    return
end

-- Debug toggle
local DEBUG_LOG = false

-- Helper: Get Discord ID from player identifiers
local function getDiscordID(source)
    local identifiers = GetPlayerIdentifiers(source)
    for _, identifier in ipairs(identifiers) do
        local type, value = table.unpack(splitString(identifier, ':'))
        if type == 'discord' and value and value:match("^%d+$") then
            if DEBUG_LOG then
                print("Found Discord ID: " .. value)
            end
            return value
        end
    end
    print("[WARN] No valid Discord ID found for player " .. source)
    return nil
end

-- Fetch member data from Discord API
local function fetchDiscordMember(guild_id, user_id)
    local r = async()

    PerformHttpRequest(("https://discord.com/api/guilds/%s/members/%s"):format(guild_id, user_id), function (code, data, headers)
        if code == 200 then
            if DEBUG_LOG then print("Successfully fetched Discord member data.") end
            local success, parsed = pcall(json.decode, data)
            if success and parsed then
                r(parsed)
            else
                print("[ERROR] discord_roles: Failed to parse member data.")
                r(nil)
            end
        else
            print("[ERROR] discord_roles: Failed to fetch member data. HTTP Code: " .. code)
            r(nil)
        end
    end, 'GET', '', { ["Authorization"] = cfg.token })

    return r:wait()
end

-- Role check with sync
local function checkPlayerRoles(user)
    local discord_id = getDiscordID(user.source)
    if not discord_id then return end

    local member = fetchDiscordMember(cfg.guildId, discord_id)
    if not member then return end
    if not member.roles or type(member.roles) ~= "table" then
        print("[WARN] No roles found in Discord member data.")
        return
    end

    for _, entry in ipairs(cfg.groups) do
        if entry.roleId and entry.group then
            local hasRole = contains(member.roles, entry.roleId)
            local hasGroup = user:hasGroup(entry.group)

            if hasRole and not hasGroup then
                user:addGroup(entry.group)
                vRP.EXT.Base.remote._notifyPicture(user.source, "CHAR_LESTER", 1, "Discord Sync", "Role Assigned", "You have been assigned the '" .. entry.group .. "' role.")
            elseif not hasRole and hasGroup then
                user:removeGroup(entry.group)
                vRP.EXT.Base.remote._notifyPicture(user.source, "CHAR_BLOCKED", 2, "Discord Sync", "Role Removed", "Your " .. entry.group .. " role has been removed.")
            end
        end
    end

    if DEBUG_LOG then
        print("User groups after sync:")
        for groupName, _ in pairs(user:getGroups()) do
            print(" - " .. groupName)
        end
    end
end

-- Event: character loaded
discord_roles.event = {}

function discord_roles.event:characterLoad(user)
    checkPlayerRoles(user)
end

-- Background role check loop (use cooldowns here in production)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(cfg.timer_check_roles)
        for _, user in pairs(vRP.users or {}) do
            if user and user.source then
                checkPlayerRoles(user)
            end
        end
        print("[Discord Roles] Role check completed for all players.")
    end
end)

-- Register extension
vRP:registerExtension(discord_roles)
