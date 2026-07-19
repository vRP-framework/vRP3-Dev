fx_version 'cerulean'
games { 'gta5' }

description "RP module/framework"
version '3.0.0'

ui_page "gui/index.html"

shared_script {
  "lib/utils.lua"
}

server_script {
  "base.lua",
	"modules/map.lua",
	"modules/gui.lua", 
  "modules/admin.lua",
  "modules/group.lua", 
  "modules/identity.lua", 
  "modules/player_state.lua",
	"modules/money.lua",
	
	-- Utility
	"modules/transformer.lua",
	
	--Sub Modules
	"modules/aptitude.lua",
	"modules/weapon.lua",
	"modules/weather.lua",
	"modules/misc.lua",	
	"modules/commands.lua", 
  "modules/log.lua",  
	"modules/vehicle.lua"
}

client_scripts {
  "client/base.lua",	
  "client/map.lua",
  "client/gui.lua",
	"client/admin.lua",
  "client/identity.lua",
  "client/player_state.lua",
	
	--Sub Modules
	"client/weapon.lua",
	"client/weather.lua",
	"client/misc.lua",
  "client/commands.lua",
	"client/vehicle.lua"
}

files {
	-- lib
  "lib/Luaoop.lua",
  "lib/Tunnel.lua",
  "lib/Proxy.lua",
  "lib/IDManager.lua",
  "lib/ActionDelay.lua",
  "lib/Luang.lua",
  "lib/ELProfiler.lua",
	
	-- Core
  "client/vRP.lua",
  "client/bootstrap.lua",
  "vRPShared.lua",
	
	-- CFG
  "cfg/client.lua",
  "cfg/modules.lua",
	
	-- Gui
  "gui/index.html",
  "gui/design.css",
  "gui/main.js",
  "gui/Menu.js",
  "gui/ProgressBar.js",
  "gui/WPrompt.js",
  "gui/RequestManager.js",
  "gui/AnnounceManager.js",
  "gui/RadioDisplay.js",
  "gui/Div.js",
  "gui/config.js",
  "gui/dynamic_classes.js",
  "gui/countdown.js",
  "gui/AudioEngine.js",
  "gui/lib/libopus.wasm.js",
  "gui/images/voice_active.png",
  "gui/sounds/phone_dialing.ogg",
  "gui/sounds/phone_ringing.ogg",
  "gui/sounds/phone_sms.ogg",
  "gui/sounds/radio_on.ogg",
  "gui/sounds/radio_off.ogg",
  "gui/sounds/eating.ogg",
  "gui/sounds/drinking.ogg"
}