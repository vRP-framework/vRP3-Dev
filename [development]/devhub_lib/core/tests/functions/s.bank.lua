if not Shared.CompatibilityTest then return end

function test_bank(source)
    TestHelper.TestMoney(source, "Bank", Core.GetBank, Core.AddBank, Core.RemoveBank)
end