fx_version 'cerulean'
games { 'gta5' }
lua54 'yes'

loadscreen 'cfg/html/index.html'

description "vRP Loading"
version '0.0.1'

shared_script {
  "@vrp/lib/utils.lua"
}

server_script {
  "init.lua"
}

client_script {
	'client.lua'
}

files {
	"cfg/loading.lua",
  "cfg/html/*",
	"cfg/html/js/*",
  "cfg/assets/**"
}

loadscreen_cursor 'yes'
loadscreen_manual_shutdown 'yes'