if not Shared.CompatibilityTest then return end

-- Server callback to get another player's server ID and coordinates
Core.RegisterServerCallback('dh_lib:test:getOtherPlayer', function(source, cb)
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        local playerSource = tonumber(playerId)
        if playerSource and playerSource ~= source then
            local ped = GetPlayerPed(playerSource)
            local coords = GetEntityCoords(ped)
            local heading = GetEntityHeading(ped)
            cb(playerSource, coords.x, coords.y, coords.z, heading)
            return
        end
    end
    cb(nil)
end)

function test_target()
    -- Standalone target is always valid
    if Shared.Target == "standalone" then
        TestHelper.SetResult("TargetResource", true, "Standalone target - no resource needed")
        return
    end
    
    -- Custom target requires manual verification
    if Shared.Target == "custom" or not TARGET_RESOURCES[Shared.Target] then
        TestHelper.SetResult("TargetResource", false, "Custom target configured", {
            manualCheckRequired = "Custom targets cannot be tested. Make sure you configured it correctly."
        })
        return
    end
    
    -- Check if target resource is started
    local resourceName = TARGET_RESOURCES[Shared.Target]
    local isStarted = TestHelper.IsResourceStarted(resourceName)
    
    TestHelper.SetResult("TargetResource", isStarted, 
        "Status of resource: " .. tostring(GetResourceState(resourceName)) .. " : " .. resourceName,
        not isStarted and { manualCheckRequired = "Target resource '" .. resourceName .. "' is not started." } or nil
    )
end