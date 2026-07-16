if not Shared.CompatibilityTest then return end

testResults = {
    LoadedSystems_server_framework = { message = "LoadedSystems.framework is not true on server.", results = false, ignoreXPlayerWipe = true },
    LoadedSystems_server_inventory = { message = "LoadedSystems.inventory is not true on server.", results = false, ignoreXPlayerWipe = true },
    LoadedSystems_server_callbacks = { message = "LoadedSystems.callbacks is not true on server.", results = false, ignoreXPlayerWipe = true },
    LoadedSystems_server_sql = { message = "LoadedSystems.sql is not true on server.", results = false, ignoreXPlayerWipe = true },
    LoadedSystems_server_admin = { message = "LoadedSystems.admin is not true on server.", results = false, ignoreXPlayerWipe = true },
    LoadedSystems_client_framework = { message = "LoadedSystems.framework is not true on client.", results = false, ignoreXPlayerWipe = true },
    LoadedSystems_client_inventory = { message = "LoadedSystems.inventory is not true on client.", results = false, ignoreXPlayerWipe = true },
    LoadedSystems_client_targets = { message = "LoadedSystems.targets is not true on client.", results = false, ignoreXPlayerWipe = true },
    LoadedSystems_client_callbacks = { message = "LoadedSystems.callbacks is not true on client.", results = false, ignoreXPlayerWipe = true },
    CoreLoaded_client = { message = "Core.Loaded is not true on client.", results = false, ignoreXPlayerWipe = true },
    playerLoadedClient = { message = "dh_lib:client:playerLoaded event not triggered.", results = false, ignoreXPlayerWipe = true },
    playerLoadedServer = { message = "dh_lib:server:playerLoaded event not triggered.", results = false, ignoreXPlayerWipe = true },
    playerUnloadedClient = { message = "dh_lib:client:playerUnloaded event not triggered.", results = false, ignoreXPlayerWipe = true },
    playerUnloadedServer = { message = "dh_lib:server:playerUnloaded event not triggered.", results = false, ignoreXPlayerWipe = true },
    playerDiedClient = { message = "dh_lib:client:setDeathStatus VALUE true event not triggered.", results = false, ignoreXPlayerWipe = true },
    playerRevivedClient = { message = "dh_lib:client:setDeathStatus VALUE false event not triggered.", results = false, ignoreXPlayerWipe = true },
    GetIdentifier = { message = "", results = false, ignoreXPlayerWipe = true },
    GetCash = { message = "", results = false },
    AddCash = { message = "", results = false },
    RemoveCash = { message = "", results = false },
    GetBank = { message = "", results = false },
    AddBank = { message = "", results = false },
    RemoveBank = { message = "", results = false },
    CanCarry = { message = "", results = false },
    CanCarryOverweight = { message = "", results = false },
    AddItem = { message = "", results = false },
    GetItemCount = { message = "", results = false },
    RemoveItem = { message = "", results = false },
    GetAllItems = { message = "", results = false },
    GetItemDataClient = { message = "", results = false },
    GetItemDataServer = { message = "", results = false },
    GetItemMetadata = { message = "", results = false },
    SetItemMetadata = { message = "", results = false },
    GetJob = { message = "", results = false },
    GetFullName = { message = "", results = false },
    GetUserInfo = { message = "", results = false },
    GetUserSkin = { message = "", results = false },
    IsPlayerAdmin = { message = "", results = false, ignoreXPlayerWipe = true },
    PlaySoundLocally = { message = "", results = false, ignoreXPlayerWipe = true },
    TargetResource = { message = "", results = false, ignoreXPlayerWipe = true },
    TargetEntity = { message = "", results = false, ignoreXPlayerWipe = true },
    TargetCoords = { message = "", results = false, ignoreXPlayerWipe = true },
    TargetModel = { message = "", results = false, ignoreXPlayerWipe = true },
    TargetGlobalVehicle = { message = "", results = false, ignoreXPlayerWipe = true },
    TargetGlobalPlayer = { message = "", results = false, ignoreXPlayerWipe = true },
    SetVehicleFuel = { message = "", results = false, ignoreXPlayerWipe = true },
    AddVehicleKeys = { message = "", results = false, ignoreXPlayerWipe = true },
    RemoveVehicleKeys = { message = "", results = false, ignoreXPlayerWipe = true },
    FrameworkResource = { message = "", results = false, ignoreXPlayerWipe = true },
    SqlResource = { message = "", results = false, ignoreXPlayerWipe = true },
    SqlAction = { message = "", results = false, ignoreXPlayerWipe = true },
    SqlActionAwait = { message = "", results = false, ignoreXPlayerWipe = true },
    RegisterItem = { message = "Item was not used in time.", results = false, ignoreXPlayerWipe = true },
}

print("^3DEVHUB:^7 Compatibility tests enabled, type /dh_startTest to start the test.")
print("^3DEVHUB:^7 Test results will be displayed in the server console.")
print("^3DEVHUB:^1 MAKE SURE^7 you added new item ^1dh_test^7")
print("^3DEVHUB:^1 MAKE SURE^7 you have ^1Shared.CompatibilityTest DISABLED^7 on main server^7")

test_waitForAction = false

local function showTestStatus(source, text)
    TriggerClientEvent('dh_lib:client:test_showStatus', source, text)
end

--- Save test results to a file
---@param passed number Number of passed tests
---@param failed number Number of failed tests
---@param actions number Number of required actions
---@param tips table Failed tips
---@param filePaths table Test file paths mapping
local function saveTestResultsToFile(passed, failed, actions, tips, filePaths)
    local resourcePath = GetResourcePath(GetCurrentResourceName())
    local timestamp = os.date("%Y-%m-%d_%H-%M-%S")
    local fileName = resourcePath .. "/test_results_" .. timestamp .. ".txt"
    
    local file = io.open(fileName, "w")
    if not file then
        print("^3DEVHUB:^1 Failed to create test results file.^7")
        return
    end
    
    -- Header
    file:write("================================================================================\n")
    file:write("                         DEVHUB LIB - TEST RESULTS\n")
    file:write("================================================================================\n")
    file:write("Date: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n")
    file:write("  Resource Name:  " .. tostring(GetCurrentResourceName()) .. "\n")
    file:write("\n")
    
    -- Configuration
    file:write("CONFIGURATION:\n")
    file:write("--------------------------------------------------------------------------------\n")
    file:write("  Framework:       " .. tostring(Shared.Framework) .. "\n")
    file:write("  Target:          " .. tostring(Shared.Target) .. "\n")
    file:write("  VehicleKeys:     " .. tostring(Shared.VehicleKeys) .. "\n")
    file:write("  VehicleFuel:     " .. tostring(Shared.VehicleFuel) .. "\n")
    file:write("  InventorySystem: " .. tostring(Shared.InventorySystem) .. "\n")
    file:write("\n")
    
    -- Summary
    file:write("SUMMARY:\n")
    file:write("--------------------------------------------------------------------------------\n")
    file:write("  Passed Tests:     " .. passed .. "\n")
    file:write("  Failed Tests:     " .. failed .. "\n")
    file:write("  Required Actions: " .. actions .. "\n")
    file:write("  Total Tests:      " .. (passed + failed) .. "\n")
    file:write("  Success Rate:     " .. string.format("%.1f%%", (passed / (passed + failed)) * 100) .. "\n")
    file:write("\n")
    
    -- Detailed Results
    file:write("DETAILED RESULTS:\n")
    file:write("================================================================================\n")
    
    -- Passed tests first
    file:write("\n[PASSED TESTS]\n")
    file:write("--------------------------------------------------------------------------------\n")
    for testName, testData in pairs(testResults) do
        if testData.results then
            file:write("  [PASS] " .. testName .. "\n")
            if testData.message and testData.message ~= "" then
                file:write("         " .. testData.message .. "\n")
            end
        end
    end
    
    -- Failed tests
    file:write("\n[FAILED TESTS]\n")
    file:write("--------------------------------------------------------------------------------\n")
    for testName, testData in pairs(testResults) do
        if not testData.results then
            file:write("  [FAIL] " .. testName .. "\n")
            if testData.message and testData.message ~= "" then
                file:write("         Error: " .. testData.message .. "\n")
            end
            if testData.manualCheckRequired then
                for _, action in pairs(testData.manualCheckRequired) do
                    file:write("         Action: " .. action .. "\n")
                end
            end
            file:write("\n")
        end
    end
    
    -- Tips
    if #tips > 0 then
        file:write("\nTIPS:\n")
        file:write("--------------------------------------------------------------------------------\n")
        for _, tip in pairs(tips) do
            -- Remove color codes from tips
            local cleanTip = tip:gsub("%^%d", ""):gsub("⚠️ ", ""):gsub("\n", "")
            file:write("  - " .. cleanTip .. "\n")
        end
    end
    
    file:write("\n================================================================================\n")
    file:write("                              END OF REPORT\n")
    file:write("================================================================================\n")
    
    file:close()
    
    print("^3DEVHUB:^2 Test results saved to: ^7" .. fileName)
    return fileName
end

RegisterNetEvent('dh_lib:server:startTest',function()
    local source = source
    print("^3DEVHUB:^7 Starting compatibility tests. It may take a while.")
    print("^3DEVHUB:^7 Resource name: ^5" .. GetCurrentResourceName() .. "^7")
    print("^3DEVHUB:^7 Current configuration:")
    print("^3DEVHUB:^7   Framework: ^5" .. tostring(Shared.Framework) .. "^7")
    print("^3DEVHUB:^7   Target: ^5" .. tostring(Shared.Target) .. "^7")
    print("^3DEVHUB:^7   VehicleKeys: ^5" .. tostring(Shared.VehicleKeys) .. "^7")
    print("^3DEVHUB:^7   VehicleFuel: ^5" .. tostring(Shared.VehicleFuel) .. "^7")
    print("^3DEVHUB:^7   InventorySystem: ^5" .. tostring(Shared.InventorySystem) .. "^7")
    print("^3DEVHUB:^7 ----------------------------")

    local Core = exports.dh_lib:GetCoreObject()
		local LoadedSystems = Core.LoadedSystems or {}
		testResults['LoadedSystems_server_framework'].results = LoadedSystems["framework"] == true
    testResults['LoadedSystems_server_framework'].message = "LoadedSystems.framework = " .. tostring(LoadedSystems["framework"])
    testResults['LoadedSystems_server_inventory'].results = LoadedSystems["inventory"] == true
    testResults['LoadedSystems_server_inventory'].message = "LoadedSystems.inventory = " .. tostring(LoadedSystems["inventory"])
    testResults['LoadedSystems_server_callbacks'].results = LoadedSystems["callbacks"] == true
    testResults['LoadedSystems_server_callbacks'].message = "LoadedSystems.callbacks = " .. tostring(LoadedSystems["callbacks"])
    testResults['LoadedSystems_server_sql'].results = LoadedSystems["sql"] == true
    testResults['LoadedSystems_server_sql'].message = "LoadedSystems.sql = " .. tostring(LoadedSystems["sql"])
    testResults['LoadedSystems_server_admin'].results = LoadedSystems["admin"] == true
    testResults['LoadedSystems_server_admin'].message = "LoadedSystems.admin = " .. tostring(LoadedSystems["admin"])

    TriggerClientEvent('dh_lib:client:test_checkLoadedSystems', source)
    Wait(2000)

    showTestStatus(source, "TargetResource")
    TestHelper.RunTest("TargetResource", test_target)
    showTestStatus(source, "FrameworkResource")
    TestHelper.RunTest("FrameworkResource", test_framework)
    showTestStatus(source, "SQL")
    TestHelper.RunTest("SqlResource", test_sql)
    showTestStatus(source, "PlaySoundLocally")
    test_sound(source)
    showTestStatus(source, "Target Interactions")
    test_target_interaction(source)
    showTestStatus(source, "Vehicle Systems")
    test_vehicle(source)
    showTestStatus(source, "GetIdentifier")
    TestHelper.RunTest("GetIdentifier", test_identifier, source)
    if testResults['GetIdentifier'].results then
        showTestStatus(source, "Cash Functions")
        TestHelper.RunTest("GetCash", test_cash, source)
        showTestStatus(source, "Bank Functions")
        TestHelper.RunTest("GetBank", test_bank, source)
        showTestStatus(source, "Item Functions")
        TestHelper.RunTest("CanCarry", test_item, source)
        showTestStatus(source, "User Functions")
        TestHelper.RunTest("GetJob", test_user, source)
    end
    Wait(500)
    showTestStatus(source, false)
    DropPlayer(source, "You have been kicked from the server for compatibility tests. You will see the test results in the server console.")
    print("^3DEVHUB:^7 Compatibility tests finished.")
    print("^3DEVHUB:^7 Saving test results to file...")
    Wait(3000)

    print("^3DEVHUB:^7 Test results:")
    local amountOfPassedTests = 0
    local amountOfFailedTests = 0
    local requireAction = 0
    local failedTips = {}
    for k,v in pairs(testResults) do
        if v.results then
            print("^3DEVHUB:^2 "..k.." test passed. ✅ ^7. "..v.message)
            amountOfPassedTests = amountOfPassedTests + 1
        else
            print("^3DEVHUB:^1 "..k.." test failed. ❌ .^7 "..v.message)
            if v.failedTips then
                for _,message in pairs(v.failedTips) do
                    table.insert(failedTips,"⚠️ ^6 "..message..'\n')
                end
            end
            if v.manualCheckRequired then
                for _,message in pairs(v.manualCheckRequired) do
                    print("\t\t 🛠️ ^5 "..message)
                    requireAction = requireAction + 1
                end
            end
            amountOfFailedTests = amountOfFailedTests + 1
        end
    end
    print('----------------------------')
    print("^3DEVHUB:^2 Passed tests: ^7"..amountOfPassedTests)
    print("^3DEVHUB:^1 Failed tests: ^7"..amountOfFailedTests)
    print("^3DEVHUB:^5 Required actions: ^7"..requireAction)
    print('----------------------------')
    if amountOfFailedTests > 0 then
        print("^3DEVHUB:^1 Some tests ^1failed^7, check the console for more information.")
    else
        print("^3DEVHUB:^2 All tests ^2passed^7, you can now disable compatibility tests.")
    end
    if #failedTips > 0 then
        print('----------------------------')
        print("^3DEVHUB:^5 Tips:")
        for _,message in pairs(failedTips) do
            print(message)
        end
        print('^7----------------------------')
    end
    
    -- Show TODO list with failed tests and file paths
    local frameworkLower = string.lower(Shared.Framework)
    local inventoryLower = string.lower(Shared.InventorySystem)
    local targetLower = string.lower(Shared.Target)
    local testFilePaths = {
        playerLoadedClient = "modules/frameworks/"..frameworkLower.."/",
        playerLoadedServer = "modules/frameworks/"..frameworkLower.."/",
        playerUnloadedClient = "modules/frameworks/"..frameworkLower.."/",
        playerUnloadedServer = "modules/frameworks/"..frameworkLower.."/",
        playerDiedClient = "modules/frameworks/"..frameworkLower.."/",
        playerRevivedClient = "modules/frameworks/"..frameworkLower.."/",
        GetIdentifier = "modules/frameworks/"..frameworkLower.."/s."..frameworkLower..".lua",
        GetCash = "modules/frameworks/"..frameworkLower.."/s."..frameworkLower..".lua",
        AddCash = "modules/frameworks/"..frameworkLower.."/s."..frameworkLower..".lua",
        RemoveCash = "modules/frameworks/"..frameworkLower.."/s."..frameworkLower..".lua",
        GetBank = "modules/frameworks/"..frameworkLower.."/s."..frameworkLower..".lua",
        AddBank = "modules/frameworks/"..frameworkLower.."/s."..frameworkLower..".lua",
        RemoveBank = "modules/frameworks/"..frameworkLower.."/s."..frameworkLower..".lua",
        CanCarry = "modules/inventories/"..inventoryLower.."/s."..inventoryLower..".lua",
        CanCarryOverweight = "modules/inventories/"..inventoryLower.."/s."..inventoryLower..".lua",
        AddItem = "modules/inventories/"..inventoryLower.."/s."..inventoryLower..".lua",
        GetItemCount = "modules/inventories/"..inventoryLower.."/s."..inventoryLower..".lua",
        RemoveItem = "modules/inventories/"..inventoryLower.."/s."..inventoryLower..".lua",
        GetAllItems = "modules/inventories/"..inventoryLower.."/s."..inventoryLower..".lua",
        GetItemDataClient = "modules/inventories/"..inventoryLower.."/c."..inventoryLower..".lua",
        GetItemDataServer = "modules/inventories/"..inventoryLower.."/s."..inventoryLower..".lua",
        GetItemMetadata = "modules/inventories/"..inventoryLower.."/s."..inventoryLower..".lua",
        SetItemMetadata = "modules/inventories/"..inventoryLower.."/s."..inventoryLower..".lua",
        GetJob = "modules/frameworks/"..frameworkLower.."/s."..frameworkLower..".lua",
        GetFullName = "modules/frameworks/"..frameworkLower.."/s."..frameworkLower..".lua",
        GetUserInfo = "modules/frameworks/"..frameworkLower.."/s."..frameworkLower..".lua",
        GetUserSkin = "modules/frameworks/"..frameworkLower.."/s."..frameworkLower..".lua",
        IsPlayerAdmin = "modules/systems/s.admin.lua",
        PlaySoundLocally = "modules/systems/c.sound.lua (requires xsound resource)",
        TargetResource = "config.lua (Shared.Target setting)",
        TargetEntity = "modules/systems/targets/c."..targetLower..".lua",
        TargetCoords = "modules/systems/targets/c."..targetLower..".lua",
        TargetModel = "modules/systems/targets/c."..targetLower..".lua",
        TargetGlobalVehicle = "modules/systems/targets/c."..targetLower..".lua",
        TargetGlobalPlayer = "modules/systems/targets/c."..targetLower..".lua",
        SetVehicleFuel = "modules/systems/c.vehicleFuel.lua",
        AddVehicleKeys = "modules/systems/c.vehicleKeys.lua",
        RemoveVehicleKeys = "modules/systems/c.vehicleKeys.lua",
        FrameworkResource = "config.lua",
        SqlResource = "Ensure oxmysql is started",
        SqlAction = "modules/systems/s.sql.lua",
        SqlActionAwait = "modules/systems/s.sql.lua",
        RegisterItem = "modules/inventories/"..inventoryLower.."/s."..inventoryLower..".lua",
    }
    
    if amountOfFailedTests > 0 then
        print('')
        print('^3DEVHUB:^7 ============ TODO LIST ============')
        print('^3DEVHUB:^7 Failed tests and where to fix them:')
        print('')
        local todoIndex = 1
        for testName, testData in pairs(testResults) do
            if not testData.results then
                local filePath = testFilePaths[testName] or "Unknown location"
                print('^3DEVHUB:^1 ['..todoIndex..'] ^7'..testName)
                print('^3DEVHUB:^7     📁 File: ^5'..filePath..'^7')
                if testData.message and testData.message ~= "" then
                    print('^3DEVHUB:^7     📝 Error: ^6'..testData.message..'^7')
                end
                if testData.manualCheckRequired then
                    for _, action in pairs(testData.manualCheckRequired) do
                        print('^3DEVHUB:^7     🔧 Action: ^2'..action..'^7')
                    end
                end
                print('')
                todoIndex = todoIndex + 1
            end
        end
        print('^3DEVHUB:^7 ===================================')
        print('')
        print('^3DEVHUB:^7 ========== QUICK CHECKLIST ==========')
        print('^3DEVHUB:^7 Before reporting issues, double-check:')
        print('^3DEVHUB:^7  1. devhub_lib is ensured AFTER your core')
        print('^3DEVHUB:^7  2. Framework is configured in config.lua')
        print('^3DEVHUB:^7  3. All dependencies are installed')
        print('^3DEVHUB:^7  4. Database tables created (if sql provided)')
        print('^3DEVHUB:^7  5. Config files have no syntax errors')
        print('^3DEVHUB:^7  6. Server and resource fully restarted')
        print('^3DEVHUB:^7  7. Console (F8 + server) checked for errors')
        print('^3DEVHUB:^7  8. No conflicting resources running')
        print('')
        print('^3DEVHUB:^7 If issues persist:')
        print('^3DEVHUB:^7  - Test with minimal/default configuration')
        print('^3DEVHUB:^7  - Check for updates (script + devhub_lib)')
        print('^3DEVHUB:^5  - Docs: https://docs.devhub.gg/troubleshooting')
        print('^3DEVHUB:^7 =======================================')
    end
    
    -- Save results to file
    saveTestResultsToFile(amountOfPassedTests, amountOfFailedTests, requireAction, failedTips, testFilePaths)
end)

-- executeWithErrorHandling is now provided by TestHelper.Execute in helpers.lua
-- Keeping this as an alias for backward compatibility
function executeWithErrorHandling(func, ...)
    return TestHelper.Execute(func, ...)
end

RegisterNetEvent('dh_lib:server:transferClientTestResults',function(results, testName)
    local source = source
    TestHelper.SetResult(testName, results, "")
    if testName == 'playerRevivedClient' then
        TriggerClientEvent('dh_lib:client:testRequestAction', source, 'revive', true)
        test_waitForAction = false
        TestHelper.SetResult("playerRevivedClient", true, "Player revived")
    end
end)

RegisterNetEvent('dh_lib:server:playerUnloaded', function()
    TestHelper.SetResult("playerUnloadedServer", true, "")
    -- We can assume playerUnloadedClient will also be triggered
    TestHelper.SetResult("playerUnloadedClient", true, "")
end)

RegisterNetEvent('dh_lib:server:playerLoaded', function()
    TestHelper.SetResult("playerLoadedServer", true, "")
end)

function test_sound(source)
    TriggerClientEvent('dh_lib:client:test_sound', source)
    Wait(3000) -- Wait for sound test to complete
end

RegisterNetEvent('dh_lib:server:transferSoundTestResults', function(result)
    TestHelper.SetResult("PlaySoundLocally", result.results, result.message, {
        manualCheckRequired = result.manualCheckRequired
    })
end)

local vehicleTestCompleted = false

function test_vehicle(source)
    vehicleTestCompleted = false
    TriggerClientEvent('dh_lib:client:test_vehicle', source)
    local timeout = 30
    while not vehicleTestCompleted and timeout > 0 do
        timeout = timeout - 1
        Wait(1000)
    end
    if not vehicleTestCompleted then
        TestHelper.SetResult("SetVehicleFuel", false, "Vehicle test timed out", {
            manualCheckRequired = { "Client-side test did not respond in time" }
        })
        TestHelper.SetResult("AddVehicleKeys", false, "Vehicle test timed out", {
            manualCheckRequired = { "Client-side test did not respond in time" }
        })
        TestHelper.SetResult("RemoveVehicleKeys", false, "Vehicle test timed out", {
            manualCheckRequired = { "Client-side test did not respond in time" }
        })
    end
end

RegisterNetEvent('dh_lib:server:transferVehicleTestResults', function(results)
    for testName, result in pairs(results) do
        TestHelper.SetResult(testName, result.results, result.message, {
            manualCheckRequired = result.manualCheckRequired
        })
    end
    vehicleTestCompleted = true
end)

local targetTestCompleted = false

function test_target_interaction(source)
    if Shared.Target == 'standalone' then
        TestHelper.SkipTests({"TargetEntity", "TargetCoords", "TargetModel", "TargetGlobalVehicle", "TargetGlobalPlayer"}, "standalone target")
        return
    end
    targetTestCompleted = false
    TriggerClientEvent('dh_lib:client:test_target', source)
    local timeout = 100
    while not targetTestCompleted and timeout > 0 do
        timeout = timeout - 1
        Wait(1000)
    end
end

RegisterNetEvent('dh_lib:server:transferTargetTestResults', function(results)
    for testName, result in pairs(results) do
        TestHelper.SetResult(testName, result.results, result.message, {
            manualCheckRequired = result.manualCheckRequired
        })
    end
    targetTestCompleted = true
end)