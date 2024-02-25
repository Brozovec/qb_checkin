fx_version "cerulean"
game "gta5"

author "Brozovec"

client_scripts {
    'config.lua',
    'client.lua'
}

server_scripts {
    'server.lua',
    'config.lua'
}

shared_script{
'config.lua',
'@okok_notify',
'@okokBilling',
'@nwrp_core'
}
