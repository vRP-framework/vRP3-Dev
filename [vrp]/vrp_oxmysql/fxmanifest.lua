fx_version "adamant"
games {"gta5"}

description "vRP oxmysql db driver bridge"

dependencies{
  "vrp",
  "oxmysql"
}

-- server scripts
server_scripts{ 
  "@vrp/lib/utils.lua",
  "init.lua"
}
