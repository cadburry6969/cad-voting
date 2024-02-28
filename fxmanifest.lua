fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Rishit & Cadburry (ByteCode Studios)'
description 'Dynamic Voting NUI'
version '1.0'

ui_page 'nui/index.html'

files {
    'nui/**/*',
    'nui/index.html',
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'editable/server.lua',
    'voting/server.lua'
}

client_scripts {
    'editable/client.lua',
    'voting/client.lua',
}

dependencies {
    '/onesync',
    'ox_lib'
}

escrow_ignore {
    'editable/*',
    'config.lua'
}
