if not Shared.CompatibilityTest then return end

RegisterCommand('dh_startTest', function()
    print("^3devhub_lib:^7 Starting compatibility tests. It may take a while.")
    TriggerServerEvent('dh_lib:server:startTest')
end)

RegisterNetEvent('dh_lib:client:test_checkLoadedSystems', function()
    TriggerServerEvent('dh_lib:server:transferClientTestResults', LoadedSystems["framework"] == true, 'LoadedSystems_client_framework')
    TriggerServerEvent('dh_lib:server:transferClientTestResults', LoadedSystems["inventory"] == true, 'LoadedSystems_client_inventory')
    TriggerServerEvent('dh_lib:server:transferClientTestResults', LoadedSystems["targets"] == true, 'LoadedSystems_client_targets')
    TriggerServerEvent('dh_lib:server:transferClientTestResults', LoadedSystems["callbacks"] == true, 'LoadedSystems_client_callbacks')
    TriggerServerEvent('dh_lib:server:transferClientTestResults', Core.Loaded == true, 'CoreLoaded_client')
end)