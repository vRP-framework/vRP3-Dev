-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.hours then return end

local Hours = class("hours", vRP.Extension)

Hours.event = {}
Hours.tunnel = {}

function Hours:__construct()
    vRP.Extension.__construct(self)
    RegisterCommand("timer", function(source)
        if source == 0 then return end
        vRP:triggerEvent("getHours", source)
    end, false)
end

function Hours.event:getHours(source)
    local user = vRP.users_by_source[source]
    if not user or not user.cdata or not user.cdata.hours then return end

    local hours = user.cdata.hours
    local fullHours = math.floor(hours)
    local minutes = math.floor((hours % 1) * 60)

    local message = string.format("You have ~b~%d~w~ hours and ~b~%d~w~ minutes played!", fullHours, minutes)
    vRP.EXT.Base.remote._notify(user.source, message)
end

function Hours.event:updateHours(hoursToAdd)
    if type(hoursToAdd) ~= "number" or hoursToAdd <= 0 then return end

    for _, user in pairs(vRP.users) do
        if user.cdata then
            local currentHours = user.cdata.hours or 0
            local newHour = currentHours + hoursToAdd
            user.cdata.hours = newHour
            user:save()

            local fullHours = math.floor(newHour)
            local minutes = math.floor((newHour % 1) * 60)
            local message = string.format("You now have ~b~%d~w~ hours and ~b~%d~w~ minutes played.", fullHours, minutes)
            vRP.EXT.Base.remote._notify(user.source, message)
        end
    end
end

function Hours.tunnel:updateHours(hours)
    if type(hours) ~= "number" or hours <= 0 or hours > 24 then return end
    local user = vRP.users_by_source[source]
    if user then
        vRP:triggerEvent("updateHours", hours)
    end
end

function Hours.event:characterLoad(user)
    if user.cdata and user.cdata.hours == nil then
        user.cdata.hours = 0
    end
end

vRP:registerExtension(Hours)
