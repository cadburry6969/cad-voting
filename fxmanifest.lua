fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author "Cadburry"
description "Voting Interface"

shared_scripts {
    "@ox_lib/init.lua",
    "config.lua"
}

client_scripts {
    "bridge/client.lua",
    "module/client.lua",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "bridge/server.lua",
    "module/server.lua"
}

ui_page "web/index.html"

files {
    "web/**/*",
    "web/index.html",
}

dependencies {
    'ox_lib',
    '/onesync'
}

escrow_ignore {
    'bridge/*',
    'config.lua'
}