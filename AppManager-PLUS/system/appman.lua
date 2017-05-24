--[[ 
	APP Manager Plus
	Application, themes and files manager.
	
	Licensed by Creative Commons Attribution-ShareAlike 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Designed By Gdljjrod & DevDavisNunez.
	Collaborators: BaltaR4 & Wzjk.
]]

vel, posimg, posy, var = 1.8, __DISPLAYW, 0, 0
function bliteffect(img)
	posimg -= vel
	posy += var

	if ( posimg <= 0 ) then posimg = 960 end
	if ( posy >= 30 ) then var = 0.07 end
	if ( posy < 0 ) then var = -0.07 end

	img:blit(math.ceil(posimg),posy)
	img:blit(math.ceil(posimg)-960,posy)
end

function splash(pics,delay,vel)
   pics:center()
   for i = 0, 255, vel do
      pics:blit(__DISPLAYW/2,__DISPLAYH/2,i)
      screen.flip()
   end
   os.delay(delay)
   for i = 255, 0, -vel do
      pics:blit(__DISPLAYW/2,__DISPLAYH/2,i)
      screen.flip()
   end
end

-- Module App manager...
appman = {
	list = {},
	len = 0,
}

function appman.refresh()

	appman.list = game.list()
	table.sort(appman.list ,function (a,b) return string.lower(a.id)<string.lower(b.id); end)

	appman.len = #appman.list
	for i=1,appman.len do

		appman.list[i].location = "ux0:"
		appman.list[i].flag = 1

		if appman.list[i].path:sub(1,4) == "ur0:" then
			appman.list[i].location = "ur0:"
			appman.list[i].flag = 0
		end

		local img = nil
		local info = nil

		appman.list[i].clon = false
		if appman.list[i].path:sub(1,10) == "ux0:pspemu" then

			img = game.geticon0(string.format("%s/eboot.pbp",appman.list[i].path))
			info = game.info(string.format("%s/eboot.pbp",appman.list[i].path))

			if info.CATEGORY and info.CATEGORY == "EG" then
				local sceid = game.sceid(string.format("%s/__sce_ebootpbp",appman.list[i].path))
				if sceid and sceid != "---" then
					if sceid != appman.list[i].id then
						appman.list[i].clon = true
					end
				end
			end

		else
			img = image.load(string.format("%s/sce_sys/icon0.png",appman.list[i].path))
			info = game.info(string.format("%s/sce_sys/param.sfo",appman.list[i].path))
		end
		appman.list[i].img = img

		appman.list[i].title = appman.list[i].id								--the param.sfo on some apps are unreadable
		appman.list[i].cat = ""
		if info and info.TITLE then appman.list[i].title = info.TITLE end
		if info and info.CATEGORY then appman.list[i].cat = info.CATEGORY end

		if theme.data["back"] then theme.data["back"]:blit(0,0) end

		-- Only for test xD
		if not explorer.list then
			screen.print(10,10,appman.list[i].title) 
			screen.flip()
		end

	end--for
end

flagscan, reboot = true,true

local pos = 1
function appman.ctrls()
	if (buttons.up or buttons.held.l or buttons.analogly < -60) and pos > 1 then pos -= 1 end
	if (buttons.down or buttons.held.r or buttons.analogly > 60) and pos < appman.len then pos += 1 end

	
	--tmp0.CATEGORY: ISO/CSO UG, PSN EG, HBs MG, PS1 ME
	if buttons[accept] then
		if __ID != appman.list[pos].id then
			if appman.list[pos].cat == "EG" or appman.list[pos].cat == "ME" then
				gameboot = game.getpic1(string.format("%s/eboot.pbp",appman.list[pos].path))
				if not gameboot then gameboot = game.getpic0(string.format("%s/eboot.pbp",appman.list[pos].path)) end
			else
				gameboot = game.bg0(appman.list[pos].path)
			end
			if gameboot then
				screen.flip()
				splash(gameboot,10,3)
			end
			game.launch(appman.list[pos].id)
		else os.restart() end
	end

	if buttons[cancel] then
		local pathmanual = ""
		if appman.list[pos].path:sub(1,10) == "ux0:pspemu" then		--manual PSP/PS1
			pathmanual = string.format("%s/document.dat",appman.list[pos].path)
		else
			pathmanual = string.format("%s/sce_sys/manual/",appman.list[pos].path)
		end
		if files.exists(pathmanual) then
			if os.message(strings.manual+"\n"+appman.list[pos].id + "?",1) == 1 then
				reboot=false
				files.delete(pathmanual)
				if not files.exists(pathmanual) then os.message(strings.notmanual) end
				reboot=true
			end
		else
			os.message(strings.notfindmanual)
		end
	end

	if buttons.triangle and (__ID != appman.list[pos].id) then
		if os.message(strings.switch+appman.list[pos].id + "?",1) == 1 then
			buttons.homepopup(0)
			reboot=false
			local result = game.move(appman.list[pos].id, appman.list[pos].flag + 2)
			buttons.homepopup(1)
			reboot=true
			if result ==1 then appman.refresh()
			elseif result ==-2 then os.message(strings.notmemory) end
		end
	end

	if buttons.square and (__ID != appman.list[pos].id) then
		if appman.list[pos].clon then
			local state = os.message(strings.delclon+appman.list[pos].id+" ?",1)
			if state == 1 then
				buttons.homepopup(0)
				reboot=false
				files.delete("ur0:appmeta/"+appman.list[pos].id)
				files.delete("ux0:pspemu/PSP/GAME/"+appman.list[pos].id)
				os.delay(1500)
				os.updatedb()
				os.message(strings.updatedb,0)
				os.delay(3500)
				buttons.homepopup(1)
				power.restart()
			end
		else
			if os.message(strings.appremove + appman.list[pos].id + "?",1) == 1 then
				buttons.homepopup(0)
				reboot=false
				local result_rmv = game.delete(appman.list[pos].id)
				buttons.homepopup(1)
				reboot=true
				if result_rmv == 1 then
					table.remove(appman.list, pos)
					pos = math.max(pos-1, 1)
					appman.len -= 1
				end
			end
		end
	end
	
end

function appman.launch()

	appman.refresh()
	plugman.load() -- Reload plugs, because can change any in ftp, explorer
	buttons.interval(10,10)
	
	while true do
		buttons.read()

		if appman.len > 0 then
			appman.ctrls()
		end
		
		if buttons.select then
			explorer.refresh()
			buttons.interval(8,8)
			while true do

				buttons.read()
				if theme.data["list"] then theme.data["list"]:blit(0,0) end
				show_explorer_list()
				ctrls_explorer_list()
				menu_ctx.run()

				screen.flip()

				if buttons.select and menu_ctx.open== false then pos=1 buttons.interval(10,10) break end
				if (buttons.held.l and buttons.held.r and buttons.up) and reboot then os.restart() end
			end

			plugman.load()
		end

		if (buttons.held.l and buttons.held.r and buttons.up) and reboot then os.restart() end

		--[[
		if buttons.start then
			plugman.launch(appman.list[pos].id)
		end
		]]

		if theme.data["back"] then theme.data["back"]:blit(0,0) end
		if theme.data["wave"] then bliteffect(theme.data["wave"]) end

		screen.print(480,10,strings.apptittle,1,color.white,color.blue,__ACENTER)
		screen.print(950,10,strings.count+appman.len,1,color.red,theme.style.BKGCOLOR,__ARIGHT)

		if appman.len > 0 then
			if appman.list[pos].img then
				screen.clip(950-64,35+64, 128/2)
				appman.list[pos].img:center()
				appman.list[pos].img:blit(950-128 + 64,35 + 64)
				screen.clip()
			else
				draw.fillrect(950-128,35, 128, 128, color.white:a(100))
				draw.rect(950-128,35, 128, 128, color.white)
			end
			screen.print(950,180,appman.list[pos].id or "unk",1.3,color.white,color.blue,__ARIGHT)

			if plugman.list[appman.list[pos].id] then
				local y2=200
				for i=1, #plugman.list[appman.list[pos].id] do
					local ccc = color.green
					if not plugman.list[appman.list[pos].id][i].exists then ccc=color.red end
					screen.print(950,y2,plugman.list[appman.list[pos].id][i].name or "",1.0,ccc,color.gray,__ARIGHT)
					y2 += 18
				end
			end

			local y = 35
			for i=pos,math.min(appman.len,pos+15) do 

				if i == pos then draw.fillrect(25,y-1,700,18,theme.style.SELCOLOR)	end

				screen.print(40,y,appman.list[i].id or "unk",1.0,color.white,theme.style.BKGCOLOR,__ALEFT)

				if appman.list[i].clon then
					screen.print(180,y,"©",1.0,color.white,theme.style.BKGCOLOR,__ALEFT)
				end

				if appman.list[i].flag == 0 then ccc=color.yellow else ccc=color.green end
				screen.print(220,y,appman.list[i].location or "unk",1.0,ccc,theme.style.BKGCOLOR,__ALEFT)

				screen.print(280,y,appman.list[i].title or "unk",1.0,color.white,theme.style.BKGCOLOR,__ALEFT)
				y += 20
			end

			if theme.data["buttons1"] then
				theme.data["buttons1"]:blitsprite(10,468,2)--[]
				theme.data["buttons1"]:blitsprite(10,493,1)--triangle
				if accept_x == 1 then
					theme.data["buttons1"]:blitsprite(10,518,3)--circle
				else
					theme.data["buttons1"]:blitsprite(10,518,0)--X
				end
			end
			screen.print(35,470,strings.pressremove,1.0,color.white,color.blue,__ALEFT)
			screen.print(35,495,strings.pressswitch,1.0,color.white,color.blue,__ALEFT)
			screen.print(35,520,strings.removemanual,1.0,color.white,color.blue,__ALEFT)
		else
			screen.print(10,30,strings.empty,1.0,color.white,color.blue)
		end

		if theme.data["buttons2"] then
			theme.data["buttons2"]:blitsprite(925,520,0)
		end
		screen.print(920,520,strings.toexplorer,1.0,color.white,color.blue,__ARIGHT)
		screen.flip()
	end
end
