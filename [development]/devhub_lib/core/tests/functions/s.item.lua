if not Shared.CompatibilityTest then return end

local item = "dh_test"
local amount = 1

-- Event handler for receiving client inventory test results
RegisterNetEvent('dh_lib:server:transferInventoryTestResults', function(clientItemData, foundItem)
    local source = source
    
    -- Set client GetItemData result
    if clientItemData then
        TestHelper.SetResult("GetItemDataClient", true, "Returned " .. json.encode(clientItemData))
    else
        TestHelper.SetResult("GetItemDataClient", false, "Returned nil")
    end
    
    -- Test server-side GetItemData
    local serverItemData, serverError = TestHelper.Execute(Core.GetItemData, item)
    if serverError then
        TestHelper.SetResult("GetItemDataServer", false, tostring(serverItemData))
    elseif not serverItemData then
        TestHelper.SetResult("GetItemDataServer", false, "Returned nil")
    else
        TestHelper.SetResult("GetItemDataServer", true, "Returned " .. json.encode(serverItemData))
    end
    
    -- Test GetItemMetadata
    if foundItem and foundItem.slot then
        local metadata, metaError = TestHelper.Execute(Core.GetItemMetadata, source, foundItem.slot)
        if metaError then
            TestHelper.SetResult("GetItemMetadata", false, tostring(metadata))
        elseif not metadata then
            TestHelper.SetResult("GetItemMetadata", false, "Returned nil")
        else
            TestHelper.SetResult("GetItemMetadata", true, "Returned " .. json.encode(metadata))
            
            -- Test SetItemMetadata
            -- Save original metadata before modifying
            local originalMetadata = json.encode(metadata.metadata or {})
            local testMetadata = {}
            -- Copy existing metadata
            if metadata.metadata then
                for k, v in pairs(metadata.metadata) do
                    testMetadata[k] = v
                end
            end
            local testValue = os.time()
            testMetadata.dh_test_value = testValue
            
            local setResult, setError = TestHelper.Execute(Core.SetItemMetadata, source, foundItem.slot, testMetadata)
            if setError then
                TestHelper.SetResult("SetItemMetadata", false, tostring(setResult))
            else
                -- Get metadata again to verify it was changed
                local verifyMetadata, verifyError = TestHelper.Execute(Core.GetItemMetadata, source, foundItem.slot)
                if verifyError then
                    TestHelper.SetResult("SetItemMetadata", false, "Failed to verify: " .. tostring(verifyMetadata))
                elseif not verifyMetadata or not verifyMetadata.metadata then
                    TestHelper.SetResult("SetItemMetadata", false, "Verification returned nil metadata. Before: " .. originalMetadata .. ", After: " .. json.encode(verifyMetadata))
                elseif verifyMetadata.metadata.dh_test_value == testValue then
                    TestHelper.SetResult("SetItemMetadata", true, "Metadata changed successfully. Before: " .. originalMetadata .. ", After: " .. json.encode(verifyMetadata.metadata))
                else
                    TestHelper.SetResult("SetItemMetadata", false, "Metadata did not change. Expected dh_test_value=" .. testValue .. ". Before: " .. originalMetadata .. ", After: " .. json.encode(verifyMetadata.metadata))
                end
            end
        end
    else
        TestHelper.SetResult("GetItemMetadata", false, "No valid item slot found")
        TestHelper.SetResult("SetItemMetadata", false, "No valid item slot found")
    end
    
    test_waitForAction = false
end)

Citizen.CreateThread(function()
    print("^2Waiting for Core to load before starting item tests...^7")
    while not Core.Loaded do
        Wait(100)
    end
    Wait(1000)
    print("^2Starting item tests...^7", item)
    local _, regError = TestHelper.Execute(Core.RegisterItem, item, function(source)
        print("Item used by player " .. tostring(source))
        TriggerClientEvent('dh_lib:client:testRequestAction', source, 'useItem', true)
        test_waitForAction = false
        TestHelper.SetResult("RegisterItem", true, "Item used")
    end)
    
    if regError then
        TestHelper.SetResult("RegisterItem", false, "Failed to register item: " .. tostring(regError))
    end
end)

function test_item(source)
    -- Test CanCarry
    local canCarry, carryError = TestHelper.Execute(Core.CanCarry, source, item, amount)
    if carryError then
        TestHelper.SetResult("CanCarry", false, canCarry)
        TestHelper.SetResult("CanCarryOverweight", false, "CanCarry errored")
        TestHelper.SetResult("AddItem", false, "CanCarry errored")
        TestHelper.SetResult("RemoveItem", false, "CanCarry errored")
        TestHelper.SetResult("GetItemCount", false, "CanCarry errored")
        return
    end
    
    TestHelper.SetResult("CanCarry", canCarry == true, "Returned " .. tostring(canCarry))
    
    -- Test CanCarry Overweight (should return false)
    local canCarryOverweight, _ = TestHelper.Execute(Core.CanCarry, source, item, 10000)
    TestHelper.SetResult("CanCarryOverweight", canCarryOverweight == false, "Returned " .. tostring(canCarryOverweight))

    if not canCarry then
        local failMsg = "CanCarry failed, cannot check "
        TestHelper.SetResult("AddItem", false, failMsg .. "AddItem")
        TestHelper.SetResult("RemoveItem", false, failMsg .. "RemoveItem")
        TestHelper.SetResult("GetItemCount", false, failMsg .. "GetItemCount")
        TestHelper.AddFailedTip("AddItem", "Make sure you added item " .. item .. " to items table in your server.")
        return
    end
    
    -- Test GetItemCount and AddItem
    local itemCount, countError = TestHelper.Execute(Core.GetItemCount, source, item)
    if countError then
        local errMsg = "GetItemCount " .. tostring(itemCount) .. ". \n^1 IS ITEM " .. item .. " ADDED TO ITEMS TABLE?^7"
        TestHelper.SetResult("GetItemCount", false, errMsg)
        TestHelper.SetResult("AddItem", false, "GetItemCount failed, cannot check AddItem")
        TestHelper.SetResult("RemoveItem", false, "GetItemCount failed, cannot check RemoveItem")
        TestHelper.SetResult("RegisterItem", false, "GetItemCount failed, cannot check RegisterItem")
        return
    end
    
    -- Add item
    local _, addError = TestHelper.Execute(Core.AddItem, source, item, amount)
    if addError then
        TestHelper.SetResult("AddItem", false, "Error adding item")
        TestHelper.SetResult("RemoveItem", false, "AddItem failed")
        return
    end
    
    local itemCountAfterAdd, _ = TestHelper.Execute(Core.GetItemCount, source, item)
    local addPassed = itemCountAfterAdd == itemCount + amount
    
    TestHelper.SetResult("AddItem", addPassed, 
        "Added " .. amount .. ", item count before: " .. tostring(itemCount) .. ", after: " .. tostring(itemCountAfterAdd))
    TestHelper.SetResult("GetItemCount", addPassed, "Returned " .. tostring(itemCount))
    
    -- Test GetAllItems - find first dh_test item
    local foundItem = nil
    local allItems, allItemsError = TestHelper.Execute(Core.GetAllItems, source)
    if allItemsError then
        TestHelper.SetResult("GetAllItems", false, tostring(allItems))
    elseif not allItems or #allItems == 0 then
        TestHelper.SetResult("GetAllItems", false, "Returned empty or nil")
    else
        -- Find first dh_test item
        for _, itemData in pairs(allItems) do
            if itemData.name == item then
                foundItem = itemData
                break
            end
        end
        if foundItem then
            TestHelper.SetResult("GetAllItems", true, "Found " .. item .. " in slot " .. tostring(foundItem.slot) .. ", total items: " .. #allItems)
        else
            TestHelper.SetResult("GetAllItems", false, "Could not find " .. item .. " in inventory, total items: " .. #allItems)
        end
    end
    
    -- Test client-side GetItemData, then server-side inventory functions
    if foundItem then
        TriggerClientEvent('dh_lib:client:test_inventory', source, item, foundItem)
        TestHelper.WaitForAction(15)
    else
        TestHelper.SetResult("GetItemDataClient", false, "GetAllItems failed, cannot test client GetItemData")
        TestHelper.SetResult("GetItemDataServer", false, "GetAllItems failed, cannot test server GetItemData")
        TestHelper.SetResult("GetItemMetadata", false, "GetAllItems failed, cannot test GetItemMetadata")
        TestHelper.SetResult("SetItemMetadata", false, "GetAllItems failed, cannot test SetItemMetadata")
    end

    -- Wait for player to use item
    TriggerClientEvent('dh_lib:client:testRequestAction', source, 'useItem')
    TestHelper.WaitForAction(20)
    
    -- Remove item
    local _, removeError = TestHelper.Execute(Core.RemoveItem, source, item, amount)
    if removeError then
        TestHelper.SetResult("RemoveItem", false, "Error removing item")
        return
    end
    
    local itemCountAfterRemove, _ = TestHelper.Execute(Core.GetItemCount, source, item)
    TestHelper.SetResult("RemoveItem", itemCountAfterRemove == itemCount,
        "Removed " .. amount .. ", item count before: " .. tostring(itemCountAfterAdd) .. ", after: " .. tostring(itemCountAfterRemove))
end