if not Shared.CompatibilityTest then return end

local playerDead = false

RegisterNetEvent('dh_lib:client:test_showStatus', function(text)
    if text then
        Core.ShowStaticMessage("🧪 Testing: " .. text)
    else
        Core.ShowStaticMessage(false)
    end
end)

local function displayText(text)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(0.0, 2.0)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(0.20, 0.40)
end

RegisterNetEvent('dh_lib:client:playerLoaded', function()
    TriggerServerEvent('dh_lib:server:transferClientTestResults', true, 'playerLoadedClient')
end)

RegisterNetEvent('dh_lib:client:playerUnloaded', function()
    TriggerServerEvent('dh_lib:server:transferClientTestResults', true, 'playerUnloadedClient')
end)

RegisterNetEvent('dh_lib:client:setDeathStatus', function(status)
    if status then
        TriggerServerEvent('dh_lib:server:transferClientTestResults', true, 'playerDiedClient')
    else
        TriggerServerEvent('dh_lib:server:transferClientTestResults', true, 'playerRevivedClient')
    end
    playerDead = true
end)

local forceStop = false
RegisterNetEvent('dh_lib:client:testRequestAction',function(action, _forceStop)
    forceStop = _forceStop
    if _forceStop then return end
    if action == 'useItem' then
        local time = 20
        Citizen.CreateThread(function()
            while time > 0 and not forceStop do
                displayText("USE ITEM dh_test "..time)
                Wait(0)
            end
        end)
        while time > 0 and not forceStop do
            time = time - 1
            Wait(1000)
        end
    elseif action == 'revive' then
        SetEntityHealth(PlayerPedId(), 0)
        Wait(1000)
        local time = 20
        Citizen.CreateThread(function()
            while time > 0 and not forceStop do
                displayText("REVIVE YOURSELF "..time)
                Wait(0)
            end
        end)
        while time > 0 and not forceStop do
            time = time - 1
            Wait(1000)
        end
    end
    forceStop = false
end)
