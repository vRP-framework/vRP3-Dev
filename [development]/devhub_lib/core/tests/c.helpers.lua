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

print("^3DEVHUB:^7 Client test helpers loaded.")
