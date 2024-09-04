fx_version 'cerulean'
games { 'gta5' }

description "RP Menus"
version '0.0.1'

shared_script {
  "@vrp/lib/utils.lua"
}

server_script {
  "init.lua"
}

client_script {
  "client.lua"
}

files {
	"cfg/multiCharacter.lua"
}