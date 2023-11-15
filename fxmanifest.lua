
fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
game 'gta5'
lua54 'yes'

description 'ESX Gangs - Wasabi Edit'
version '1.0.1'

ui_page {
    'nui/index.html',
}

files {
    'nui/index.html',
    'nui/main.js',
    'nui/main.css',
    'nui/logo.png',
    'nui/gtafont.woff',
    'nui/gtafont.woff2',
}

shared_script 'config.lua'

client_script 'client.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}