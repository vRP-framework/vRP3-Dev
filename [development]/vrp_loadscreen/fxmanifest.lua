fx_version 'cerulean'
games { 'gta5' }
lua54 'yes'

description 'vRP3 (core-v2) custom loading screen -- theme-selectable, real progress, tips, music'
version '0.0.1'

loadscreen 'html/index.html'
loadscreen_cursor 'yes'
loadscreen_manual_shutdown 'yes'

-- Provides module()/class/clone/async/tohex/etc. as globals -- see
-- vrp_template for why every vRP3 addon resource needs this exact line.
shared_script {
  '@vrp/lib/utils.lua'
}

-- IMPORTANT: server.lua is never listed as a server_script -- see the
-- comment at the top of server.lua for why (same load method as
-- vrp_template).
server_script {
  '@vrp/lib/init.lua'
}

client_script {
  'client.lua'
}

files {
  'cfg/cfg.lua',
  'html/index.html',
  'html/css/style.css',
  'html/js/script.js',
  'html/audio/theme.mp3',
  'html/video/boot.mp4',
  'html/img/bg/*.jpg'
}
