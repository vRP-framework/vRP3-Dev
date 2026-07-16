CreateThread( function() 
    local formatVolume = function(volume)
        if volume == nil or volume == false or not tonumber(volume) then
            volume = 0.5
            print("Invalid volume, setting to 0.5")
        end
        if volume > 1.0 then
            volume = 1.0
        elseif volume < 0.0 then
            volume = 0.0
        end
        return volume + 0.0
    end

    Core.PlaySoundLocally = function(uid, url, volume, loop)
        exports['xsound']:PlayUrl(uid, url, formatVolume(volume), loop)
    end
    Core.PlaySoundCoords = function(uid, url, volume, coords, loop)
        exports['xsound']:PlayUrlPos(uid, url, formatVolume(volume), coords, loop, false)
    end
    Core.FadeIn = function(uid, time, volume)
        exports['xsound']:fadeIn(uid, time, formatVolume(volume))
    end
    Core.FadeOut = function(uid, time)
        if Core.SoundExists(uid) then
            exports['xsound']:fadeOut(uid, time)
        end
    end
    Core.ChangeDistance = function(uid, distance)
        exports['xsound']:Distance(uid, distance)
    end
    Core.StopSound = function(uid)
        exports['xsound']:Destroy(uid)
    end
    Core.SoundExists = function(uid)
        return exports['xsound']:soundExists(uid)
    end
end) 