fx_version 'cerulean'
games { 'gta5' }
author 'Luman Studio'
version '1.0.3'
lua54 'yes'
provide 'luman-bridge'

shared_scripts {
    'config.lua',
    'init.lua',

    'shared/events.lua',
    'shared/shared_exports.lua',
}

client_scripts {
    'client/frameworks/*.lua',
    'client/c_exports.lua',
    'client/c_events.lua',
}

server_scripts {
    'server/frameworks/*.lua',
    'server/s_exports.lua',
}

files {
    'client/frameworks/modules/*.lua',
}

escrow_ignore {
    '**/*.lua',
}