fx_version 'cerulean'
games { 'gta5' }
lua54 'yes'

ui_page 'html/index.html'

description "vRP Dispatch"
version '0.0.1'

shared_script {
  "@vrp/lib/utils.lua"
}

server_script {
  "@vrp/lib/init.lua",
}

client_script {
  'client.lua',
  'client/*.lua' -- Load all client scripts in the client folder
}

files {
  'html/index.html',
  'html/favicon.svg',
  'html/assets/*.js',
  'html/assets/*.css'
}