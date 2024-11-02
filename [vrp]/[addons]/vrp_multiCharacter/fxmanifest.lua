fx_version 'cerulean'
games { 'gta5' }

description "vRP Multi Character"
version '0.0.1'

ui_page 'cfg/html/index.html'

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
	"cfg/multiCharacter.lua",
  "cfg/html/*",
  "cfg/html/js/*"
}