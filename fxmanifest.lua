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
    'shared/config.lua'
}

server_scripts {
    'shared/server.lua',
    'voting/server.lua'
}

client_scripts {
    'shared/client.lua',
    'voting/client.lua',
}

dependencies {
    '/onesync',
    'ox_lib'
}

escrow_ignore {
    'shared/*',
}
