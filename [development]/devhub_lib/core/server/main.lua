Core = {}
createExport("GetCoreObject", function()
    return Core
end)

LoadedSystems = {
    ["framework"] = false,
    ['admin'] = false,
    ['sql'] = false,
    ['inventory'] = false,
    ['callbacks'] = false,
}

local function areSystemsLoaded()
    for _, loaded in pairs(LoadedSystems) do
        if not loaded then
            return false
        end
    end
    return true 
end

PerformHttpRequest('https://raw.githubusercontent.com/DEVHUB-GG/dh_versions/main/versions.json', function(_, res)
    local updateName = "devhub_lib_new"
    local resName = GetCurrentResourceName()
    local resPrefix = "^3["..resName.."]^"
    print("^3-------------------- DEVHUB.GG - Version Check --------------------")
    print(resPrefix.."1 Checking for updates...^7")
    if not res then print(resPrefix.."1Failed to check for updates^7") return end
    local result = json.decode(res)
    if result[updateName].version and GetResourceMetadata(resName, 'version', 0) ~= result[updateName].version then
        print(resPrefix.."1 New version ^3"..result[updateName].version.."^1 of the script is available^7")
        if result[updateName].changelog then
            print(resPrefix.."1 Changelog: ^3")
            local text = ""
            for _, log in ipairs(result[updateName].changelog) do
                print("- "..log)
            end
        end
        print(resPrefix.."1 You can download it from ^3https://github.com/DEVHUB-GG/devhub_lib^7")
    else 
        print(resPrefix.."2 You have the latest version of the script^7")
    end
    print("^3-------------------- DEVHUB.GG - Version Check --------------------^7")
end)

Citizen.CreateThread(function()
    local scriptName = GetCurrentResourceName()
    if scriptName ~= "devhub_lib" then
        if scriptName == 'devhub_lib-main' then
            print("^1----------------------------------------^7")
            print("^1REMOVE -main FROM SCRIPT NAME !!!^7")
            print("^1----------------------------------------^7")
        else
            print("^1----------------------------------------^7")
            print("^1SCRIPT MUST BE NAMED devhub_lib !!!^7")
            print("^1----------------------------------------^7")
        end
    end

    while not areSystemsLoaded() do
        Citizen.Wait(100)
    end
    Core.Loaded = true
    Core.RegisterServerCallback('core:callback:getItemsAmount', function(source, cb, itemsList)
        local itemsAmount = {}
        for i=1, #itemsList do
            local itemName = itemsList[i]
            itemsAmount[itemName] = Core.GetItemCount(source, itemName) or 0
        end
        cb(itemsAmount)
    end)
end)