fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Cadburry & Rishit'
description 'Voting Interface for FiveM'
version '1.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'bridge/client.lua',
    'module/client.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'bridge/server.lua',
    'module/server.lua'
}

ui_page 'web/index.html'

files {
    'web/**/*',
    'web/index.html',
}

dependencies {
    'ox_lib',
    'ox_target',
    '/onesync'
}

escrgnore {
    'bridge/*',
    'config.lua'
}
