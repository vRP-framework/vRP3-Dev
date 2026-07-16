fx_version 'cerulean'
games {'gta5'}
lua54 'yes'

author 'DEVHUB (store.devhub.gg)'
description 'LIBRARY FOR DEVHUB SCRIPTS'
version '3.0.3'

ui_page "html/index.html"

dependencies {
	'vrp',
}

shared_script {
	'core/shared/sh.*.lua',
	
	-- ======= vRP =======
	'@vrp/lib/utils.lua',
}

client_scripts {
	'@vrp/lib/utils.lua',
	'config.lua',
	'core/shared/autoDetect.lua',
	'core/client/main.lua',
	'core/client/c.*.lua',
	'core/tests/c.*.lua',
	'core/tests/functions/c.*.lua',
	'modules/**/c.*.lua',
}

server_scripts {
	-- ======= vRP =======
	'@oxmysql/lib/MySQL.lua',
	'@vrp/lib/utils.lua',
	--'modules/**/init.lua',
	
	-- ======= Main =======
	'config.lua',
	'core/shared/autoDetect.lua',
	'core/server/main.lua',
	'core/server/s.*.lua',
	'core/tests/s.*.lua',
	'core/tests/functions/s.*.lua',
	'modules/**/s.*.lua',
}

files {
	'html/**/*',
	'config.lua',
}

provide 'dh_lib'

escrow_ignore {
	'core/**/*.lua',
	'modules/**/*.lua',
}
