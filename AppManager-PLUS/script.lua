--[[ 
	APP Manager Plus
	Application, themes and files manager.
	
	Licensed by Creative Commons Attribution-ShareAlike 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Designed By Gdljjrod & DevDavisNunez.
	Collaborators: BaltaR4 & Wzjk.
]]

color.loadpalette()

files.mkdir("ux0:data/AppManPlus/themes/")								-- Create a folder work

-- Global constants
APP_VERSION_MAJOR = 0x02 -- major.minor
APP_VERSION_MINOR = 0x10
	
APP_VERSION = ((APP_VERSION_MAJOR << 0x18) | (APP_VERSION_MINOR << 0x10)) -- Union Binary

-- == Updater ==
game.delete("AMUPDATER") -- Exists delete update app

files.mkdir("ux0:/data/1luapkg")

function onAppInstallCB(step, size_argv, written, file, totalsize, totalwritten)
	return 10 -- Ok code
end

function onNetGetFileCB(size,written,speed)
	screen.print(10,10,"Downloading Update...")
	screen.print(10,30,"Size: "..tostring(size).." Written: "..tostring(written).." Speed: "..tostring(speed).."Kb/s")
	screen.print(10,50,"Porcent: "..math.floor((written*100)/size).."%")
	draw.fillrect(0,520,((written*960)/size),24,color.new(0,255,0))
	screen.flip()
	buttons.read()
	if buttons.circle then	return 0 end --Cancel or Abort
	return 1;
end

local version = http.get("https://raw.githubusercontent.com/ONElua/AppManager-PLUS/master/version")
if version then
	version = tonumber(version)
	local major = (version >> 0x18) & 0xFF;
	local minor = (version >> 0x10) & 0xFF;
	if version > APP_VERSION then
		local res = os.message("App Manager Plus "..string.format("%X.%02X",major, minor).." is now available.\n".."Do you want to update the application?", 1)
		if res == 1 then -- Response Ok.
			local url = string.format("https://github.com/ONElua/AppManager-PLUS/releases/download/%s/AppManagerPlus.vpk", string.format("%X.%02X",major, minor))
			local path = "ux0:data/AppManPlus/AppManagerPlus.vpk"
			--os.message(url:sub(1,#url/2).."\n"..url:sub(#url/2))
			onAppInstall = onAppInstallCB
			onNetGetFile = onNetGetFileCB
			local res = http.getfile(url, path)
			if res then -- Success!
				files.copy("eboot.bin","ux0:/data/1luapkg")
				files.copy("updater/script.lua","ux0:/data/1luapkg/")
				files.copy("updater/param.sfo","ux0:/data/1luapkg/sce_sys/")
				game.installdir("ux0:/data/1luapkg")
				files.delete("ux0:/data/1luapkg")
				game.launch("AMUPDATER") -- Goto installer extern!
			end
		end
	end
end

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
