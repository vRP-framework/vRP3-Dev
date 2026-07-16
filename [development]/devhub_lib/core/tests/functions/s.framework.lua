if not Shared.CompatibilityTest then return end

function test_framework()
    -- Custom framework requires manual verification
    if Shared.Framework == "custom" or not FRAMEWORK_RESOURCES[Shared.Framework] then
        TestHelper.SetResult("FrameworkResource", false, "Custom framework configured", {
            manualCheckRequired = "Custom frameworks cannot be tested. Make sure you configured it correctly."
        })
        return
    end
    
    local resourcesToCheck = FRAMEWORK_RESOURCES[Shared.Framework]
    local found = 0
    local total = #resourcesToCheck
    
    for i = 1, total do
        if TestHelper.IsResourceStarted(resourcesToCheck[i]) then
            found = found + 1
        end
    end
    
    local passed = found == total
    TestHelper.SetResult("FrameworkResource", passed, 
        "Found resources: " .. found .. "/" .. total .. ". Most compatible: " .. Shared.Framework,
        not passed and { manualCheckRequired = "Some framework resources are not started." } or nil
    )
end