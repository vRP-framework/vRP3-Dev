if not Shared.CompatibilityTest then return end

RegisterNetEvent('dh_lib:client:test_inventory', function(itemName, foundItem)
    local clientItemData = nil
    
    -- Test client-side Core.GetItemData
    local result, hasError = TestHelper.Execute(Core.GetItemData, itemName)
    if not hasError and result then
        clientItemData = result
    end
    
    -- Send results back to server for server-side tests
    TriggerServerEvent('dh_lib:server:transferInventoryTestResults', clientItemData, foundItem)
end)
