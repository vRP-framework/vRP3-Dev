if not Shared.CompatibilityTest then return end

-- Helper to split full name into parts
local function splitName(fullName)
    local names = {}
    for word in fullName:gmatch("%S+") do
        table.insert(names, word)
    end
    return names
end

function test_user(source)
    test_getJob(source)
    test_getFullName(source)
    test_getUserInfo(source)
    test_getUserSkin(source)
    test_isPlayerAdmin(source)
    test_playerRevive(source)
end

function test_getJob(source)
    local job, hasError = TestHelper.Execute(Core.GetJob, source)
    
    if hasError then
        TestHelper.SetResult("GetJob", false, job)
        return
    end
    
    if not job then
        TestHelper.SetResult("GetJob", false, "Returned nil")
        return
    end
    
    local validators = {
        { field = "name", validator = function(v) return v and v ~= "unemployed" end, 
          failMessage = "Job name: unemployed, change job to pass the test." },
        { field = "grade", validator = function(v) return v and v ~= 0 end, 
          failMessage = "Job grade: 0, change job grade to pass the test." },
        { field = "label", validator = function(v) return v and v ~= "Unemployed" end, 
          failMessage = "Job label: Unemployed, change job to pass the test." },
        { field = "gradeLabel", validator = function(v) return v and v ~= "Unemployed" end, 
          failMessage = "Job gradeLabel: Unemployed, change job grade to pass the test." },
        { field = "onDuty", validator = function(v) return v == true end, 
          failMessage = "Job onDuty: false, go on duty to pass the test.",
          failedTip = "If you are not using job duty, go to server side of your framework and do following actions \n\t1.Find Core.GetJob \n\t2. change onDuty = xPlayer.job.onDuty to onDuty = true" },
    }
    
    TestHelper.ValidateFields("GetJob", job, validators)
end

function test_getFullName(source)
    local fullName, hasError = TestHelper.Execute(Core.GetFullName, source)
    
    if hasError then
        TestHelper.SetResult("GetFullName", false, fullName)
        return
    end
    
    if not fullName or fullName == "Firstname Lastname" then
        TestHelper.SetResult("GetFullName", false, "Returned " .. tostring(fullName), {
            manualCheckRequired = "GetFullName returned default placeholder name."
        })
        return
    end
    
    local words = splitName(fullName)
    local passed = words[1] and words[2]
    
    TestHelper.SetResult("GetFullName", passed, "Returned " .. tostring(fullName),
        not passed and { manualCheckRequired = "GetFullName has not returned string with first and last name." } or nil
    )
end

function test_getUserInfo(source)
    local userInfo, hasError = TestHelper.Execute(Core.GetUserInfo, source)
    
    if hasError then
        TestHelper.SetResult("GetUserInfo", false, userInfo)
        return
    end
    
    if not userInfo then
        TestHelper.SetResult("GetUserInfo", false, "Returned nil")
        return
    end
    
    local validators = {
        { field = "dateOfBirth", validator = function(v) return v and v ~= "Unknown" end, 
          failMessage = "dateOfBirth is Unknown or nil." },
        { field = "sex", validator = function(v) return v and v ~= "Unknown" end, 
          failMessage = "sex is Unknown or nil." },
        { field = "height", validator = function(v) return v and v ~= "Unknown" end, 
          failMessage = "height is Unknown or nil." },
        { field = "nationality", validator = function(v) return v and v ~= "Unknown" end, 
          failMessage = "nationality is Unknown or nil." },
    }
    
    TestHelper.ValidateFields("GetUserInfo", userInfo, validators)
end

function test_getUserSkin(source)
    local userSkin, hasError = TestHelper.Execute(Core.GetUserSkin, source)
    
    if hasError then
        TestHelper.SetResult("GetUserSkin", false, userSkin)
        return
    end
    
    if not userSkin then
        TestHelper.SetResult("GetUserSkin", false, "Returned nil")
        return
    end
    
    local validators = {
        { field = "eyesColor", validator = function(v) return type(v) == "number" and v ~= 0 end, 
          failMessage = type(userSkin.eyesColor) ~= "number" and "eyesColor is not a number or nil." or "eyesColor is 0, change character eye color to pass the test." },
        { field = "skinColor", validator = function(v) return type(v) == "number" and v ~= 0 end, 
          failMessage = type(userSkin.skinColor) ~= "number" and "skinColor is not a number or nil." or "skinColor is 0, change character skin color to pass the test." },
    }
    
    TestHelper.ValidateFields("GetUserSkin", userSkin, validators)
end

function test_isPlayerAdmin(source)
    local isAdmin, hasError = TestHelper.Execute(Core.IsPlayerAdmin, source)
    
    if hasError then
        TestHelper.SetResult("IsPlayerAdmin", false, isAdmin)
        return
    end
    
    if type(isAdmin) ~= "boolean" then
			TestHelper.SetResult("IsPlayerAdmin", false, "Returned non-boolean: " .. tostring(isAdmin))
			return
    end
    
    TestHelper.SetResult("IsPlayerAdmin", true, "Returned " .. tostring(isAdmin),
			not isAdmin and { manualCheckRequired = "Player is not admin, give admin permissions to pass the test." } or nil
    )
end

function test_playerRevive(source)
	Wait(1000)
	TriggerClientEvent('dh_lib:client:testRequestAction', source, 'revive')
	Wait(1100)
	TestHelper.WaitForAction(20)
	Wait(4000)
end