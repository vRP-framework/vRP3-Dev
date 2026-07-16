fx_version 'cerulean'
games { 'gta5' }
lua54 'yes'

ui_page 'cfg/html/index.html'

description "vRP Banking"
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
  "cfg/cfg.lua",
  'cfg/html/index.html',
  'cfg/html/assets/*.js',
  'cfg/html/assets/*.css',
  'cfg/html/*.png', -- if you have images
}