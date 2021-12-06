fx_version 'cerulean'
games { 'rdr3', 'gta5' }

client_script {
	"@es_extended/locale.lua",
	--
	"src/client/RMenu.lua",
    "src/client/menu/RageUI.lua",
    "src/client/menu/Menu.lua",
    "src/client/menu/MenuController.lua",
    "src/client/components/*.lua",
    "src/client/menu/elements/*.lua",
    "src/client/menu/items/*.lua",
    "src/client/menu/panels/*.lua",
	"src/client/menu/windows/*.lua",
	--
	'server-callback/client.lua',
    'CLevel.lua',
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
	'server-callback/server.lua',
    'SLevel.lua',
}
