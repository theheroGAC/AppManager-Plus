--[[ 
	APP Manager Plus
	Application, themes and files manager.
	
	Licensed by Creative Commons Attribution-ShareAlike 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Designed By Gdljjrod & DevDavisNunez.
	Collaborators: BaltaR4 & Wzjk.
]]
game.close()
buttons.read()
color.loadpalette()

files.mkdir("ux0:data/AppManPlus/themes/")								-- Create a folder work

dofile("git/updater.lua")

-- Create a globals
SYMBOL_CROSS = string.char(0xe2)..string.char(0x95)..string.char(0xb3)
SYMBOL_CIRCLE = string.char(0xe2)..string.char(0x97)..string.char(0x8b)

__ID = os.titleid()
vpkdel,_print,game_move = false,true,false

Dev = 1
Root = {"ux0:","ur0:", "ux0:","ur0:"}
if files.exists("uma0:") then
	Root = {"ux0:","ur0:","uma0:", "ux0:","ur0:","uma0:"} 
end
NDev = #Root/2

infosize = os.devinfo(Root[Dev])

dofile("system/utils.lua") 												-- Extra funtions

pathini="ux0:data/AppManPlus/config.ini"								-- Path to config.ini
if not files.exists(pathini) then
	ini.write(pathini,"theme","id","default")
end

-- Load lang file
__LANG = os.language()
if files.exists("ux0:/data/AppManPlus/lang.lua") then dofile("ux0:/data/AppManPlus/lang.lua")
else 
	if files.exists("system/lang/"..__LANG..".lua") then dofile("system/lang/"..__LANG..".lua")
	else dofile("system/lang/default.lua") end
end

dofile("system/themes.lua")												-- Load Theme Application
dofile("system/explorer/commons.lua")									-- Load Functions Commons
dofile("system/explorer/explorer.lua")									-- Load Explorer File
dofile("system/explorer/callbacks.lua")									-- Load Callbacks
dofile("system/scan.lua")												-- Load Search vpks 
dofile("system/customtheme.lua")										-- Load Mgr of livearea themes...
dofile("system/plugman.lua")											-- Load PluginsManager in WIP
dofile("system/appman.lua")												-- Load AppManager
dofile("system/advanced.lua")											-- Load Advanced Options 

appman.launch() 														-- Main Cycle :D
