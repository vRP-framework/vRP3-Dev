fx_version 'cerulean'
game "gta5"

author "Project Error"
version '1.0.0'
lua54 'yes'

ui_page 'build/index.html'

client_script "client/**/*"
server_script "server/**/*"

files {
  'build/index.html',
  'build/**/*'
}
