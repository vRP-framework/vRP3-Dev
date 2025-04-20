fx_version 'cerulean'
game 'gta5'
ui_page 'nui/index.html'

server_scripts {
	'init.lua',
	'modules/base.lua',
	'server/sv_main.lua',
	'server/sv_chars.lua',
}

client_scripts {
	'init.lua',
	'client/base.lua',
	'client/characters.lua',
}

files {
	'bridge/bridge.lua',
	'bridge/remote.lua',
	'Solar.lua',
	'SolarShared.lua',
	'client/Solar.lua',
	'cfg/player.lua',
	'nui/*',
	'nui/**/*'
}