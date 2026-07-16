CustomUi = {}

-- Some script may override position value, in that case, you will have a config in a script which will override this value !!!
-- Return False if the default static message system is used, true if a custom static message system is used.
-- Details about parameters in the documentation: https://docs.devhub.gg/scripts/devhub_lib-needed-for-each-script/ui

CustomUi.Notify = function(text, duration, notificationType)
    -- notificationType: 'info', 'error', 'success', 'warning'
    -- duration: in ms
    return false -- if you are using a custom notification, return true
end

-- top-left, top-right, bottom-left, bottom-right, top-center, bottom-center
CustomUi.NotifyPosition = "top-right"

CustomUi.NotifyTypes = {
    ['info'] = "info",
    ['error'] = "error",
    ['success'] = "success",
    ['warning'] = "warning"
}

---------------------------------------------------------------------------------------------------------

CustomUi.ShowStaticMessage = function(text)
    return false -- if you are using a custom static message, return true
end

-- top-left, top-right, bottom-left, bottom-right
CustomUi.StaticMessagePosition = "top-left"

---------------------------------------------------------------------------------------------------------

CustomUi.ShowControlButtons = function(text)
    return false -- if you are using a custom control buttons system, return true
end

-- top-left, top-right, bottom-left, bottom-right
CustomUi.ControlButtonsPosition = "bottom-right"

---------------------------------------------------------------------------------------------------------

CustomUi.ShowProgressbar = function(data, cb)
    return false -- if you are using a custom progress bar, return true
end

-- low, medium, high
CustomUi.ProgressbarPlacement = "low"

CustomUi.CloseProgressbar = function()
    return false -- if you are using a custom progress bar, return true
end

CustomUi.PopupForm = function(data, cb)
    return false -- if you are using a custom popup form, return true
end