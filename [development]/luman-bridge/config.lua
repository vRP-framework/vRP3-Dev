Config = {}

-----------------------
-- FRAMEWORK OPTIONS --
-----------------------
Config.Framework = 'vrp2'
--[[
    Supported frameworks:
        * auto: auto-detect framework
        * esx: https://github.com/esx-framework/esx-legacy                  (auto)
        * qb: https://github.com/qbcore-framework/qb-core                   (auto)         
        * qbox: https://github.com/Qbox-project/qbx_core                    (auto)
        * vrp_dunko: https://github.com/vRP-Official-Developers/dunko_vrp   (specify manually)
        * vrp1: https://github.com/vRP-framework/vRP/releases/tag/1.0       (specify manually)
        * vrp2: https://github.com/vRP-framework/vRP                        (specify manually)
        * standalone: no framework / custom functionality in server/frameworks/standalone.lua and client/frameworks.standalone.lua 
]]

----------------------
-- FRAMEWORK FOLDER --
----------------------
Config.FrameworkFolder = {
    ESX = 'es_extended',
    QB = 'qb-core',
    QBOX = 'qbx_core',
}
--[[
    In case you've renamed a resource folder with the framework - change it here accordingly.
]]