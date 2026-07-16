if not Shared.CompatibilityTest then return end

function test_cash(source)
	TestHelper.TestMoney(source, "Cash", Core.GetCash, Core.AddCash, Core.RemoveCash, true)
end

--[[
local function TestMoneyFunction(name, func, ...)
	print("[DEBUG] Running test:", name)

	local success, result = pcall(func, ...)

	if success then
		print("[DEBUG]", name, "succeeded. Returned:", tostring(result))

		TestHelper.SetResult(
			name,
			true,
			"Returned value: " .. tostring(result)
		)
	else
		print("[ERROR]", name, "failed with error:", tostring(result))

		TestHelper.SetResult(
			name,
			false,
			"Error: " .. tostring(result)
		)
	end
end

function test_cash(source)
	print("[DEBUG] Starting cash tests for source:", source)

	TestMoneyFunction("Core.GetCash", Core.GetCash, source)
	TestMoneyFunction("Core.AddCash", Core.AddCash, source, 100)
	TestMoneyFunction("Core.RemoveCash", Core.RemoveCash, source, 100)

	print("[DEBUG] Cash tests completed")
end
--]]