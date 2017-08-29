--Functions Commons

--tmp0.CATEGORY: ISO/CSO UG, PSN EG, HBs MG, PS1 ME
function show_msg_pbp(handle)
	local bufftmp = screen.buffertoimage()
	local x,y = (960-420)/2,(544-420)/2

	local icon0 = game.geticon0(handle.path)
	local sfo = game.info(handle.path)

	local launch=false
	if (sfo.CATEGORY == "EG" or sfo.CATEGORY == "ME") then
		if sfo.DISC_ID and game.exists(sfo.DISC_ID) then
			launch=true
		end
	end

	local name=handle.name:lower()
	--Maybe work with PS1
	local res,xscr = false,290
	while true do
		buttons.read()
		bufftmp:blit(0,0)

		draw.fillrect(x,y,420,420,color.shine)
		draw.rect(x,y,420,420,color.white)

		if sfo then
			if launch then
				screen.print(960/2,y+15,strings.launchpbp,1,color.black,color.blue,__ACENTER)
	
				if accept_x == 1 then
					screen.print(960/2,y+400,string.format("%s"..strings.confirm.." | %s "..strings.cancel,SYMBOL_CROSS, SYMBOL_CIRCLE),1,color.black,color.blue,__ACENTER)
				else
					screen.print(960/2,y+400,string.format("%s"..strings.confirm.." | %s "..strings.cancel,SYMBOL_CIRCLE, SYMBOL_CROSS),1,color.black,color.blue,__ACENTER)
				end
			end

			if screen.textwidth(tostring(sfo.TITLE) or "UNK") > 380 then
				xscr = screen.print(xscr, y+40, tostring(sfo.TITLE) or "UNK",1,color.black,color.blue,__SLEFT,380)
			else
				screen.print(960/2,y+40,tostring(sfo.TITLE) or "UNK",1,color.black,color.blue,__ACENTER)
			end
			screen.print(960/2,y+60,tostring(sfo.DISC_ID) or tostring(sfo.TITLE_ID),1,color.black,color.blue,__ACENTER)
		end

		if icon0 then
			icon0:setfilter(__ALINEAR, __ALINEAR)
			icon0:scale(150)
			icon0:center()
			icon0:blit(960/2,544/2)
		end

		screen.flip()

		if buttons[accept] or buttons[cancel] then
			if buttons[accept] then
				if launch then game.launch(sfo.DISC_ID) end
			end
			break
		end

	end

	bufftmp:blit(0,0)
	buttons.read()--flush xD
	return res
	
end

-- ## Music Player ##
function MusicPlayer(handle)
	local isMp3 = ((files.ext(handle.path) or "") == "mp3")
	local id3 = nil

	if isMp3 then id3 = sound.getid3(handle.path)	end

	local snd = sound.load(handle.path)
	if snd then
		snd:play(1)
		while true do
			if theme.data["music"] then theme.data["music"]:blit(0,0) end
			buttons.read()

			screen.print(10,10,tostring(handle.name),1.0,color.white,color.black)

			if id3 and id3.cover then
				if id3.cover:getw() > 350 or id3.cover:geth() > 350 then
					id3.cover:scale( math.floor( (350*100)/math.max(id3.cover:getw(), id3.cover:geth()) ) )
				end
				id3.cover:center()
				id3.cover:blit(175+35,175+100)
			else
				if theme.data["cover"] then
					theme.data["cover"]:center()
					theme.data["cover"]:blit(175+35,175+100)
				end
			end

			if snd:playing() then
				screen.print(425,90,strings.playing,1.0,color.white,color.black)
			else
				screen.print(425,90,strings.paused,1.0,color.white,color.black)
			end

			if isMp3 then -- Solo los mp3 tienen tiempos :P
				local str = strings.time+tostring(snd:time()) + " / "
				if id3 then
					str += id3.time or strings.id3
				else
					str += strings.id3
				end
				screen.print(425,120, str,1.0,color.white,color.black)

				local pos,size,base,perc = snd:porcent()
				if perc then
					draw.fillrect(425,145,((perc*350)/100),10,color.green)
				end
				draw.rect(425,145,350,10,color.white)

				if id3 and id3.title then
					screen.print(425,175, id3.title,1.0,color.white,color.black)
				end
				if id3 and id3.artist then
					screen.print(425,195, id3.artist,1.0,color.white,color.black)
				end
			end
			
			screen.flip()

			power.tick(__SUSPEND) -- reset a power timers only for block suspend..

			if buttons[accept] then
				--[[if snd:endstream() then
					snd:play()
				else]]
				snd:pause() -- pause/resume
				--end
			end

			if buttons[cancel] or snd:endstream() then break end
			if buttons.triangle then power.display(0) end -- Lock or Down the screen.
		end

		snd:stop()
		snd = nil
		collectgarbage("collect")
		os.delay(150)
	else
		os.message(strings.sounderror)
	end
end

-- ## Photo-Viewer ## --
function visorimg(path)
	local tmp = image.load(path)
	if tmp then
		tmp:center()

		local infoimg = {}
		infoimg.name = files.nopath(path)
		infoimg.w,infoimg.h = image.getrealw(tmp),image.getrealh(tmp)
		local show_bar_upper = true

		bar=45
		if (infoimg.w>500 and infoimg.h>300) then bar=50 end 

		for i=0,bar,5 do
			tmp:blit(__DISPLAYW/2,__DISPLAYH/2)
			draw.fillrect(0,0,__DISPLAYW,i,theme.style.BARCOLOR)
			--screen.flip()
		end

		while true do
			if theme.data["back"] then theme.data["back"]:blit(0,0)	end
			buttons.read()
	
			tmp:blit(__DISPLAYW/2,__DISPLAYH/2)

			if show_bar_upper then
				draw.fillrect(0,0,__DISPLAYW,bar,theme.style.BARCOLOR)

				screen.print(10,5,infoimg.name,1.0,color.white,color.black)
				screen.print(940,3,"w: "..infoimg.w,0.8,color.white,color.black,__ARIGHT)
				screen.print(940,24,"h: "..infoimg.h,0.8,color.white,color.black,__ARIGHT)
			end

			screen.flip()

			if buttons.square then show_bar_upper = not show_bar_upper end
			if buttons[cancel] or buttons[accept] then break	end

		end

		tmp = nil
		--collectgarbage("collect")
		barblit=false
	else
		os.message(strings.imgerror)
	end
end

-- ## File-Viewer ## --
function visortxt(handle)
	local cont = nil
	if handle.ext == "sfo" then cont = files.readlinesSFO(handle.path)
	else cont = files.readlines(handle.path) end

	if cont == nil then return end

	local srcn = newScroll(cont,16)
	while true do
		buttons.read()
		if theme.data["list"] then theme.data["list"]:blit(0,0) end

		if buttons[cancel] then
			--buttons.interval(10,6)
			break
		end

		if buttons.up or buttons.analogly < -60 then srcn:up() elseif buttons.down or buttons.analogly > 60 then srcn:down() end

		screen.print(10,15,(handle.name or handle.path))
		local y = 70
		for i=srcn.ini,srcn.lim do
			if i == srcn.sel then draw.fillrect(10,y,__DISPLAYW-50,20,theme.style.SELCOLOR) end
			screen.print(15,y,cont[i],1,color.white)
			y+=26
		end
		screen.flip()
	end
	buttons.read()
end
