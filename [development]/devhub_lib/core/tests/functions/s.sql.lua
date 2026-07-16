if not Shared.CompatibilityTest then return end

function test_sql()
    local sqlResource = "oxmysql"
    
    -- Test SQL Resource
    if TestHelper.IsResourceStarted(sqlResource) then
        TestHelper.SetResult("SqlResource", true, "Status of resource: started : " .. sqlResource)
    else
        TestHelper.SetResult("SqlResource", false, "Status of resource: " .. tostring(GetResourceState(sqlResource)) .. " : " .. sqlResource, {
            manualCheckRequired = "Custom SQL resources state cannot be tested. Make sure you configured it correctly."
        })
    end

    -- Test SQL Execute (async)
    local cbResult, hasError = TestHelper.Execute(function()
        local result = nil
        Core.SQL.Execute("SELECT ?", {5}, function(cbSql)
            result = cbSql
        end)
        Wait(500)
        return result
    end)
    
    if hasError then
        TestHelper.SetResult("SqlAction", false, cbResult)
    elseif cbResult and cbResult[1] and cbResult[1]["5"] == 5 then
        TestHelper.SetResult("SqlAction", true, "Returned " .. json.encode(cbResult))
    else
        TestHelper.SetResult("SqlAction", false, "Unexpected result: " .. json.encode(cbResult or {}))
    end

    Wait(200)

    -- Test SQL AwaitExecute (sync)
    local awaitResult, awaitError = TestHelper.Execute(Core.SQL.AwaitExecute, "SELECT ?", {10})
    
    if awaitError then
        TestHelper.SetResult("SqlActionAwait", false, awaitResult)
    elseif awaitResult and awaitResult[1] and awaitResult[1]["10"] == 10 then
        TestHelper.SetResult("SqlActionAwait", true, "Returned " .. json.encode(awaitResult))
    else
        TestHelper.SetResult("SqlActionAwait", false, "Unexpected result: " .. json.encode(awaitResult or {}))
    end
end