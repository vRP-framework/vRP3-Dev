fx_version 'cerulean'
games { 'gta5' }
lua54 'yes'

description "vRP money"
version '0.0.1'

shared_script {
  "@vrp/lib/utils.lua"
}

server_script {
  "@vrp/lib/init.lua"
}

client_script {
  'client.lua'
}

files {
  "cfg/hud.lua"
}