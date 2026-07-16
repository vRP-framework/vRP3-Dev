if not Shared.CompatibilityTest then return end

function test_identifier(source)
    local identifier, hasError = TestHelper.Execute(Core.GetIdentifier, source)
    
    if hasError or not identifier then
				print(tostring(hasError))
				
        -- Mark dependent tests as failed
        for k, v in pairs(testResults) do
            if not v.ignoreXPlayerWipe then
                testResults[k].message = "GetIdentifier failed"
            end
        end
				
        return
    end
    
    TestHelper.SetResult("GetIdentifier", true, "Returned " .. tostring(identifier))
end
