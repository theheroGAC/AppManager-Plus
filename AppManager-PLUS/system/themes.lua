--[[ 
	APP Manager Plus
	Application, themes and files manager.
	
	Licensed by Creative Commons Attribution-ShareAlike 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Designed By Gdljjrod & DevDavisNunez.
	Collaborators: BaltaR4 & Wzjk.
]]

theme = { -- Module theme :P
	data = {}, -- Handle of imgs xD
	style = {}, -- Handle of colors xD
}

-- Local Values :D
local root_themes = "ux0:data/AppManPlus/themes/" -- Path of themes folder...

function theme.load()
	local id = ini.read(pathini,"theme","id","default") -- Get the id of theme pack xD
	local path = root_themes..id.."/"
	if not files.exists(path) then
		path = "system/theme/default/"
	end
	-- Removed callbacks, and rename searchvpk to generic list
	local elements = {
		{name="back"},
		{name="wave"},
		{name="menu"},
		{name="list"},
		{name="themesmanager"},
		{name="ftp"},
		{name="music"},
		{name="cover"},
		{name="icons",sprite=true, w=16,h=16}, 		-- 112x16
		{name="buttons1",sprite=true, w=20,h=20}, 	-- 80*20
		{name="buttons2",sprite=true, w=30,h=20}, 	-- 120*20
	}
	-- Load a images :D
	for i=1,#elements do
		if files.exists(string.format("%s%s.png",path,elements[i].name)) then
			if elements[i].sprite then
				theme.data[elements[i].name] = image.load(string.format("%s%s.png",path,elements[i].name),elements[i].w,elements[i].h)
			else
				theme.data[elements[i].name] = image.load(string.format("%s%s.png",path,elements[i].name))
			end
		else
			if elements[i].sprite then
				theme.data[elements[i].name] = image.load(string.format("%s%s.png","system/theme/default/",elements[i].name),elements[i].w,elements[i].h)
			else
				theme.data[elements[i].name] = image.load(string.format("%s%s.png","system/theme/default/",elements[i].name))
			end
		end
	end

	-- TODO: Update ini.load to read ini´s without index :(
	--theme.style = ini.load(path.."theme.ini") -- Load a color styles...
	--write_ini("Debug.ini",theme.style)
	theme.style = {
		BKGCOLOR		=	tonumber(ini.read(path.."theme.ini","BKGCOLOR","0x00000000")),
		BARCOLOR		=	tonumber(ini.read(path.."theme.ini","BARCOLOR","0x64FFFFFF")),
		TITLECOLOR		=	tonumber(ini.read(path.."theme.ini","TITLECOLOR","0xFF9E9E9F")),
		PATHCOLOR		=	tonumber(ini.read(path.."theme.ini","PATHCOLOR","0xA09E9E9F")),
		DATETIMECOLOR	= 	tonumber(ini.read(path.."theme.ini","DATETIMECOLOR","0xFF9E9E9F")),
		
		SELCOLOR		=	tonumber(ini.read(path.."theme.ini","SELCOLOR","0xFF9E9E9F")),
		SFOCOLOR		=	tonumber(ini.read(path.."theme.ini","SFOCOLOR","0x00000000")),
		BINCOLOR		=	tonumber(ini.read(path.."theme.ini","BINCOLOR","0x00000000")),
		MUSICCOLOR		=	tonumber(ini.read(path.."theme.ini","MUSICCOLOR","0x00000000")),
		IMAGECOLOR		=	tonumber(ini.read(path.."theme.ini","IMAGECOLOR","0x00000000")),
		ARCHIVECOLOR	=	tonumber(ini.read(path.."theme.ini","ARCHIVECOLOR","0x00000000")),
		MARKEDCOLOR		=	tonumber(ini.read(path.."theme.ini","MARKEDCOLOR","0x00000000")),
		FTPCOLOR		=	tonumber(ini.read(path.."theme.ini","FTPCOLOR","0x00000000")),
	}
	-- TODO: move this to correct script :P
	isopened = { png = theme.style.IMAGECOLOR, jpg = theme.style.IMAGECOLOR, gif = theme.style.IMAGECOLOR, bmp = theme.style.IMAGECOLOR,
		mp3 = theme.style.MUSICCOLOR, ogg = theme.style.MUSICCOLOR, wav = theme.style.MUSICCOLOR,
		iso = theme.style.BINCOLOR, pbp = theme.style.BINCOLOR, cso = theme.style.BINCOLOR, dax = theme.style.BINCOLOR, bin = theme.style.BINCOLOR, suprx = theme.style.BINCOLOR, skprx = theme.style.BINCOLOR,
		zip = theme.style.ARCHIVECOLOR, rar = theme.style.ARCHIVECOLOR, vpk = theme.style.ARCHIVECOLOR, gz = theme.style.ARCHIVECOLOR,
		sfo = theme.style.SFOCOLOR,
	}

	if files.exists(string.format("%s%s",path,"font.ttf")) then	font.setdefault(string.format("%s%s",path,"font.ttf")) 
	elseif files.exists(string.format("%s%s",path,"font.pgf")) then	font.setdefault(string.format("%s%s",path,"font.pgf")) end

end
	
theme.load()

-- TODO: add option to reload a default theme :P
--	 Add scroll xD :P

function theme.manager()

	local thlist = files.listdirs(root_themes)
	if not thlist then thlist = files.listdirs("system/theme/") end

	local list = {}
	for i=1,#thlist do
		local title = ini.read(thlist[i].path.."/theme.ini","TITLE","Unknow")
		local author = ini.read(thlist[i].path.."/theme.ini","AUTHOR","Unknow")
		local preview = image.load(thlist[i].path.."/preview.png")
		table.insert(list,{id=thlist[i].name,title = title, author = author, preview = preview})
	end

	local theme_list = newScroll(list,15)
	while true do

		buttons.read()

		if buttons.up or buttons.analogly < -60 then theme_list:up() end
		if buttons.down or buttons.analogly > 60 then theme_list:down() end

		if buttons[accept] then
			ini.write(pathini,"theme","id",list[theme_list.sel].id)
			theme.load()
			os.message(strings.themesdone)
		end

		if buttons.start then											--change theme Original
			ini.write(pathini,"theme","id","default")
			theme.load()
			os.message(strings.themesdone)
		end

		if theme.data["themesmanager"] then theme.data["themesmanager"]:blit(0,0) end

		screen.print(480,15,strings.themesappman,1,theme.style.TITLECOLOR,color.gray,__ACENTER)
		local y = 70
		for i=theme_list.ini,theme_list.lim do
			if i == theme_list.sel then
				if list[i].preview then list[i].preview:resize(252,151) list[i].preview:blit(700,84) end
				screen.print(700+126,240,list[i].author or "unk",1.0,theme.style.TITLECOLOR,theme.style.BKGCOLOR,__ACENTER)
				draw.fillrect(15,y-3,675,25,theme.style.SELCOLOR)
			end 
			screen.print(20,y,list[i].title)
			y+=26
		end

		if theme.data["buttons2"] then
			theme.data["buttons2"]:blitsprite(10,515,1)--start
		end
		screen.print(45,520,strings.reload,1.0,color.white,theme.style.BKGCOLOR,__ALEFT)

		screen.flip()

		if buttons[cancel] then break end
	end
end
