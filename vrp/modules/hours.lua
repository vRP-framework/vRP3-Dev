-- https://github.com/ImagicTheCat/vRP
-- MIT license (see LICENSE or vrp/vRPShared.lua)

if not vRP.modules.hours then return end

local hours = class("hours", vRP.Extension)

hours.event = {}
hours.tunnel = {}

function hours:__construct()
    vRP.Extension.__construct(self)
    RegisterCommand("timer", function(source) 
        vRP:triggerEvent("getHours", source)
    end, false)
end

function hours.event:getHours(source)
    local user = vRP.users_by_source[source]
    local hours = user.cdata.hours
    local minutes = hours - math.floor(hours)

    vRP.EXT.Base.remote._notify(user.source, "You have ~b~" .. math.floor(hours) .. " ~w~ hours and ~b~" .. math.floor(minutes * 100 * 0.60) .. " ~w~ minutes played!")
end

function hours.event:updateHours(hoursToAdd)
    for _, user in pairs(vRP.users) do
        if user.cdata then
            local currentHours = user.cdata.hours or 0
            local newHour = currentHours + hoursToAdd
            user.cdata.hours = newHour
            user:save()
            vRP.EXT.Base.remote._notify(user.source, "You now have ~b~" .. math.floor(newHour) .. " ~w~ hours and ~b~" .. math.floor((newHour - math.floor(newHour)) * 100 * 0.60) .. " ~w~ minutes played.")
        end
    end
end

function hours.tunnel:updateHours(hours)
    local user = vRP.users_by_source[source]
    if user then
        vRP:triggerEvent("updateHours", hours)
    end
end

function hours.event:characterLoad(user)
  if user.cdata then
    if user.cdata.hours == nil then
      user.cdata.hours = 0
    end
  end
end


vRP:registerExtension(hours)
