fx_version 'cerulean'
games { 'gta5' }
lua54 'yes'

description 'vRP3 (core-v2) addon resource template -- reference for the current load method'
version '0.0.1'

-- Provides module()/class/clone/async/tohex/etc. as globals. Needed by
-- both client.lua (to bootstrap the client vRP instance below) and by
-- @vrp/lib/init.lua's remote loadScript call server-side. Every vRP3
-- addon resource needs this exact shared_script line.
shared_script {
  '@vrp/lib/utils.lua'
}

-- IMPORTANT: this is the *only* server-side entry point declared here.
-- server.lua is never listed as a server_script -- see the comment at the
-- top of server.lua for why.
server_script {
  '@vrp/lib/init.lua'
}

client_script {
  'client.lua'
}

files {
  'cfg/cfg.lua'
}
