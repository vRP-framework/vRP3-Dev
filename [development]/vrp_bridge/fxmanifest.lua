fx_version 'cerulean'
games { 'gta5' }
lua54 'yes'

description "vRP Bridge"
version '0.0.1'

shared_script {
  "@vrp/lib/utils.lua"
}

server_script {
	"server/*.lua"
}

client_scripts {
	'client/*.lua',
}

files {
  "cfg/cfg.lua"
}
