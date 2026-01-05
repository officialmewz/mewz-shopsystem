fx_version 'cerulean'
game 'gta5'
name 'Mewz Development'
description 'Mewz Development Shop System'
version '1.0.0'

lua54 'yes'
dependency '/assetpacks'
dependencies {
    'ox_lib',
    'ox_target',
}

shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',
    'config.lua'
}

client_scripts {
    'client/client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
'server/server.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

escrow_ignore {
    'config.lua',
    'server/server.lua'
}