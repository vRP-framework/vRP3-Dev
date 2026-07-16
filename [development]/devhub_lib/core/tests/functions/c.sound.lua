if not Shared.CompatibilityTest then return end

local testResults = {
    PlaySoundLocally = { message = "", results = true }
}

function test_sound()
    local testUid = "dh_lib_test_sound"
    local testUrl = "https://upload.devhub.gg/dh_upload/sampleTest.ogg"
    
    -- Play sound locally with error handling
    local errorMessage, playError = TestHelper.Execute(function()
        Core.PlaySoundLocally(testUid, testUrl, 0.5, false)
    end)
    
    if playError then
        testResults['PlaySoundLocally'].results = false
        testResults['PlaySoundLocally'].message = errorMessage
        testResults['PlaySoundLocally'].manualCheckRequired = {
            "Client-side error occurred. Check F8 console for details."
        }
        return
    end
    
    Wait(1500)
    
    local soundExists = false
    -- Check if sound exists with error handling
    local errorMessage, existsError = TestHelper.Execute(function()
        soundExists = Core.SoundExists(testUid)
    end)
    
    if existsError then
        testResults['PlaySoundLocally'].results = false
        testResults['PlaySoundLocally'].message = errorMessage
        if not testResults['PlaySoundLocally'].manualCheckRequired then testResults['PlaySoundLocally'].manualCheckRequired = {} end
        table.insert(testResults['PlaySoundLocally'].manualCheckRequired, "SoundExists check failed - " .. tostring(errorMessage))
        return
    end
    
    if soundExists then
        testResults['PlaySoundLocally'].results = true
        testResults['PlaySoundLocally'].message = "Sound played successfully"
    end
end

RegisterNetEvent('dh_lib:client:test_sound', function()
    local success, err = pcall(test_sound)
    if not success then
        testResults['PlaySoundLocally'].results = false
        testResults['PlaySoundLocally'].message = "Error: " .. tostring(err)
        if not testResults['PlaySoundLocally'].manualCheckRequired then testResults['PlaySoundLocally'].manualCheckRequired = {} end
        table.insert(testResults['PlaySoundLocally'].manualCheckRequired, "Client-side error occurred. Check F8 console for details.")
    end
    TriggerServerEvent('dh_lib:server:transferSoundTestResults', testResults['PlaySoundLocally'])
end)
