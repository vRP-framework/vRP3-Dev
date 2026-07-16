if not Shared.CompatibilityTest then return end

TestHelper = {}

--- Execute a function with pcall error handling
---@param func function The function to execute
---@param ... any Arguments to pass to the function
---@return any result The result or error message
---@return boolean hasError Whether an error occurred
function TestHelper.Execute(func, ...)
    local success, result = pcall(func, ...)
    if success then
        return result, false
    else
        return "Error: " .. tostring(result), true
    end
end

--- Set test result with standardized handling
---@param testName string The test name key
---@param passed boolean Whether the test passed
---@param message string|nil Optional message
---@param options table|nil Optional { manualCheckRequired, failedTips }
function TestHelper.SetResult(testName, passed, message, options)
    if not testResults[testName] then
        print("^1[TestHelper] Warning: Unknown test name: " .. testName .. "^7")
        return
    end
    
    testResults[testName].results = passed
    if message then
        testResults[testName].message = message
    end
    
    if options then
        if options.manualCheckRequired then
            TestHelper.AddManualCheck(testName, options.manualCheckRequired)
        end
        if options.failedTips then
            TestHelper.AddFailedTip(testName, options.failedTips)
        end
    end
end

--- Add a manual check requirement to a test
---@param testName string The test name key
---@param message string|table Message(s) to add
function TestHelper.AddManualCheck(testName, message)
    if not testResults[testName] then return end
    if not testResults[testName].manualCheckRequired then
        testResults[testName].manualCheckRequired = {}
    end
    
    if type(message) == "table" then
        for _, msg in ipairs(message) do
            table.insert(testResults[testName].manualCheckRequired, msg)
        end
    else
        table.insert(testResults[testName].manualCheckRequired, message)
    end
end

--- Add a failed tip to a test
---@param testName string The test name key
---@param message string|table Message(s) to add
function TestHelper.AddFailedTip(testName, message)
    if not testResults[testName] then return end
    if not testResults[testName].failedTips then
        testResults[testName].failedTips = {}
    end
    
    if type(message) == "table" then
        for _, msg in ipairs(message) do
            table.insert(testResults[testName].failedTips, msg)
        end
    else
        table.insert(testResults[testName].failedTips, message)
    end
end

--- Wait for an action with timeout
---@param timeout number Timeout in seconds
---@param checkFn function|nil Optional function to check completion (return true to stop)
---@return boolean completed Whether the action completed before timeout
function TestHelper.WaitForAction(timeout, checkFn)
    local time = timeout
    test_waitForAction = true
    
    while time > 0 do
        if checkFn and checkFn() then
            test_waitForAction = false
            return true
        end
        if not test_waitForAction then
            return true
        end
        time = time - 1
        Wait(1000)
    end
    
    test_waitForAction = false
    return false
end

--- Run a test function with automatic error handling
---@param testName string The test name key
---@param testFn function The test function to run
---@param ... any Arguments to pass to the test function
---@return any result The result of the test function
function TestHelper.RunTest(testName, testFn, ...)
    local result, hasError = TestHelper.Execute(testFn, ...)
    
    if hasError then
        TestHelper.SetResult(testName, false, result)
        return nil
    end
    
    return result
end

--- Generic money test (works for both Cash and Bank)
---@param source number Player source
---@param moneyType string "Cash" or "Bank"
---@param getFn function Function to get money
---@param addFn function Function to add money
---@param removeFn function Function to remove money
function TestHelper.TestMoney(source, moneyType, getFn, addFn, removeFn)
    local getTestName = "Get" .. moneyType
    local addTestName = "Add" .. moneyType
    local removeTestName = "Remove" .. moneyType
    local amount = 100
    
    -- Test Get
    local money, hasError = TestHelper.Execute(getFn, source)
    if hasError or money == nil then
        TestHelper.SetResult(getTestName, false, money or "Returned nil")
        TestHelper.SetResult(addTestName, false, getTestName .. " failed, cannot check " .. addTestName)
        TestHelper.SetResult(removeTestName, false, getTestName .. " failed, cannot check " .. removeTestName)
        return
    end
    
    TestHelper.SetResult(getTestName, true, "Returned " .. tostring(money))
    
    -- Test Add
    local _, addError = TestHelper.Execute(addFn, source, amount)
    if addError then
        TestHelper.SetResult(addTestName, false, "Error adding " .. moneyType:lower())
        TestHelper.SetResult(removeTestName, false, addTestName .. " failed, cannot check " .. removeTestName)
        return
    end
    
    local moneyAfterAdd, _ = TestHelper.Execute(getFn, source)
    local addPassed = moneyAfterAdd == money + amount
    TestHelper.SetResult(addTestName, addPassed, 
        "Added " .. amount .. ", " .. moneyType:lower() .. " before: " .. tostring(money) .. ", after: " .. tostring(moneyAfterAdd))
    
    Wait(100)
    
    -- Test Remove
    local _, removeError = TestHelper.Execute(removeFn, source, amount)
    if removeError then
        TestHelper.SetResult(removeTestName, false, "Error removing " .. moneyType:lower())
        return
    end
    
    local moneyAfterRemove, _ = TestHelper.Execute(getFn, source)
    local removePassed = moneyAfterRemove == money and moneyAfterAdd ~= moneyAfterRemove
    TestHelper.SetResult(removeTestName, removePassed,
        "Removed " .. amount .. ", " .. moneyType:lower() .. " before: " .. tostring(moneyAfterAdd) .. ", after: " .. tostring(moneyAfterRemove))
end

--- Check if a resource is started
---@param resourceName string Resource name
---@return boolean isStarted
function TestHelper.IsResourceStarted(resourceName)
    return GetResourceState(resourceName) == "started"
end

--- Test a resource dependency
---@param testName string The test name key
---@param resourceName string|table Resource name(s) to check
---@param customFailMessage string|nil Custom failure message
---@return boolean allStarted
function TestHelper.TestResource(testName, resourceName, customFailMessage)
    local resources = type(resourceName) == "table" and resourceName or { resourceName }
    local found = 0
    local total = #resources
    
    for _, res in ipairs(resources) do
        if TestHelper.IsResourceStarted(res) then
            found = found + 1
        end
    end
    
    local passed = found == total
    local message = "Found resources: " .. found .. "/" .. total
    
    if not passed and customFailMessage then
        TestHelper.SetResult(testName, false, message, {
            manualCheckRequired = { customFailMessage }
        })
    else
        TestHelper.SetResult(testName, passed, message)
    end
    
    return passed
end

--- Validate multiple fields and build manual check requirements
---@param testName string The test name key
---@param data table The data to validate
---@param validators table Array of { field, validator, failMessage }
---@return boolean allPassed
function TestHelper.ValidateFields(testName, data, validators)
    if not data then
        TestHelper.SetResult(testName, false, "Returned nil")
        return false
    end
    
    local canPass = 0
    local totalChecks = #validators
    
    for _, v in ipairs(validators) do
        local value = data[v.field]
        local passed = v.validator(value)
        
        if passed then
            canPass = canPass + 1
        else
            TestHelper.AddManualCheck(testName, v.failMessage)
            if v.failedTip then
                TestHelper.AddFailedTip(testName, v.failedTip)
            end
        end
    end
    
    local allPassed = canPass == totalChecks
    TestHelper.SetResult(testName, allPassed, "Returned " .. json.encode(data))
    
    return allPassed
end

--- Skip a test with a message
---@param testName string The test name key
---@param reason string Reason for skipping
function TestHelper.SkipTest(testName, reason)
    TestHelper.SetResult(testName, true, "Skipped - " .. reason)
end

--- Skip multiple tests with the same reason
---@param testNames table Array of test name keys
---@param reason string Reason for skipping
function TestHelper.SkipTests(testNames, reason)
    for _, testName in ipairs(testNames) do
        TestHelper.SkipTest(testName, reason)
    end
end

print("^3DEVHUB:^7 Test helpers loaded.")
