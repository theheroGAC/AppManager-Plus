--[[ 
	APP Manager Plus
	Application, themes and files manager.
	
	Licensed by Creative Commons Attribution-ShareAlike 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Designed By Gdljjrod & DevDavisNunez.
	Collaborators: BaltaR4 & Wzjk.
]]

files.mkdir("ux0:data/AppManPlus/themes/")								-- Create a folder work
color.loadpalette()
dofile("system/utils.lua") 												-- Extra funtions

pathini="ux0:data/AppManPlus/config.ini"								-- Path to config.ini
if not files.exists(pathini) then
	ini.write(pathini,"theme","id","default")
end

-- Load lang file
if files.exists("ux0:/data/AppManPlus/lang.lua") then dofile("ux0:/data/AppManPlus/lang.lua")
else dofile("system/lang/default.lua") end

-- Create a globals
__ID = os.titleid()

vpkdel = false
Dev, Root = 1, {"ux0:","ur0:", "ux0:","ur0:"}  
infosize = os.devinfo(Root[Dev])

dofile("system/themes.lua")												-- Load Theme Application
dofile("system/explorer/commons.lua")									-- Load Functions Commons
dofile("system/explorer/explorer.lua")									-- Load Explorer File
dofile("system/explorer/callbacks.lua")									-- Load Callbacks
dofile("system/scan.lua")												-- Load Search vpks 
dofile("system/customtheme.lua")										-- Load Mgr of livearea themes...
dofile("system/plugman.lua")											-- Load PluginsManager in WIP
dofile("system/appman.lua")												-- Load AppManager

appman.launch() 														-- Main Cycle :D
