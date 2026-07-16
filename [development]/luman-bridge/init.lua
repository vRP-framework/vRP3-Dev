------------------
-- FRAMEWORK ID --
------------------
Config.FrameworkId = {
    AUTO = 'auto',
    ESX = 'esx',
    QB = 'qb',
    QBOX = 'qbox',
    VRP_DUNKO = 'vrp_dunko',
    VRP1 = 'vrp1',
    VRP2 = 'vrp2',
    STANDALONE = 'standalone',
}
--[[
    Internal identifier used in luman-bridge
]]

function selectEsx()
    Config.Framework = Config.FrameworkId.ESX
end

function selectQb()
    Config.Framework = Config.FrameworkId.QB
end

function selectQbox()
    Config.Framework = Config.FrameworkId.QBOX
end

function selectVrpDunko()
    Config.Framework = Config.FrameworkId.VRP_DUNKO
end

function selectVrp1()
    Config.Framework = Config.FrameworkId.VRP1
end

function selectVrp2()
    Config.Framework = Config.FrameworkId.VRP2
end

function selectStandalone()
    Config.Framework = Config.FrameworkId.STANDALONE
end

-- Auto plug-in framework. See `server/framework.lua` for API.
if Config.Framework == 'auto' then
    if GetResourceState(Config.FrameworkFolder.ESX) == 'started' then
        selectEsx()
    elseif GetResourceState(Config.FrameworkFolder.QBOX) == 'started' then
        selectQbox()
    elseif GetResourceState(Config.FrameworkFolder.QB) == 'started' then
        selectQb()
    elseif GetResourceState('vrp') == 'started' then
        print(('^1[luman-bridge]:^0 Specify the framework in luman-bridge/config.lua'):format(Config.Framework))
        selectStandalone()
    else
        selectStandalone()
    end
-- Manual plug-in.
elseif Config.Framework == Config.FrameworkId.ESX then
    selectEsx()
elseif Config.Framework == Config.FrameworkId.QB then
    selectQb()
elseif Config.Framework == Config.FrameworkId.QBOX then
    selectQbox()
elseif Config.Framework == Config.FrameworkId.VRP_DUNKO then
    selectVrpDunko()
elseif Config.Framework == Config.FrameworkId.VRP1 then
    selectVrp1()
elseif Config.Framework == Config.FrameworkId.VRP2 then
    selectVrp2()
elseif Config.Framework == Config.FrameworkId.STANDALONE then
    selectStandalone()
end

if Config.Framework == 'auto' then
    print(('^1[luman-bridge]:^0 No framework selected^0'):format(Config.Framework))
else
    print(('^2[luman-bridge]:^0 Selected framework ^6%s^0'):format(Config.Framework))
end