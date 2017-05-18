--CallBacks LUA
function onAppInstall(step, size_argv, written, file, totalsize, totalwritten)

    if step == 1 then -- Only msg of state
    	if theme.data["back"] then theme.data["back"]:blit(0,0) end

		draw.fillrect(0,0,960,30, theme.style.BARCOLOR)
		screen.print(10,10,strings.searchunsafe)

		screen.flip()
	elseif step == 2 then -- Alerta Vpk requiere confirmacion!
		while true do
			buttons.read()
			if buttons[accept] then
				buttons.read() -- Flush
				return 10 -- Ok code
			elseif buttons[cancel] then
				buttons.read() -- Flush
				return 0; -- Any other code xD
			end

			if theme.data["back"] then theme.data["back"]:blit(0,0)	end

			if size_argv == 1 then
				screen.print(10,10,strings.unsafevpk)
			elseif size_argv == 2 then
				screen.print(10,10,strings.dangerousvpk)
			end

			if accept_x == 1 then
				screen.print(10,505,"X "..strings.confirm.." | ".."O "..strings.cancel,1.0,color.white, color.blue)
			else
				screen.print(10,505,"O "..strings.confirm.." | ".."X "..strings.cancel,1.0,color.white, color.blue)
			end
			screen.flip()
		end
	elseif step == 3 then -- Unpack :P
		if theme.data["back"] then theme.data["back"]:blit(0,0)	end

		draw.fillrect(0,0,960,30, theme.style.BARCOLOR)

		screen.print(10,10,strings.vpkunpack)
		screen.print(925,10,strings.percent_total..math.floor((totalwritten*100)/totalsize).." %",1.0,color.white, color.black, __ARIGHT)
		screen.print(10,35,strings.file..tostring(file))
		screen.print(10,55,strings.percent..math.floor((written*100)/size_argv).." %")
		
		draw.fillrect(0,544-30,(totalwritten*960)/totalsize,30, color.new(0,255,0))

		screen.flip()
	elseif step == 4 then -- Promote o install :P
		if theme.data["back"] then theme.data["back"]:blit(0,0)	end

		draw.fillrect(0,0,960,30, theme.style.BARCOLOR)
		screen.print(10,10,strings.install)
		screen.flip()
	end
end

-- CallBack Extraction
function onExtractFiles(size,written,file,totalsize,totalwritten)

	if theme.data["back"] then theme.data["back"]:blit(0,0)	end
	draw.fillrect(0,0,__DISPLAYW,30, theme.style.BARCOLOR)

	if explorer.dst then
		screen.print(10,10,strings.extraction+" <--> "+explorer.dst)
	else
		screen.print(10,10,strings.extraction)
	end

	screen.print(925,10,strings.percent_total..math.floor((totalwritten*100)/totalsize).." %",1.0,color.white, color.black, __ARIGHT)
	screen.print(10,35,strings.file..tostring(file))
	screen.print(10,55,strings.percent..math.floor((written*100)/size).." %")

	screen.flip()
	
	buttons.read()
	if buttons[cancel] then
		return 0;
	end
	return 1;
end

function onScanningFiles(file,unsize,position,unsafe)
	if not bufftmp then
		if theme.data["back"] then theme.data["back"]:blit(0,0)	end
	else bufftmp:blit(0,0) end

	draw.fillrect(0,0,__DISPLAYW,30, theme.style.BARCOLOR)

	local ccc=color.white
	if unsafe==1 then ccc=color.yellow elseif unsafe==2 then ccc=color.red end

	local x,y = (960-420)/2,(544-420)/2

	screen.print(__DISPLAYW/2,y+7,strings.file..tostring(file),1,ccc,color.black,__ACENTER)
	screen.print(__DISPLAYW/2,y+37,strings.unsafe..tostring(unsafe),1,ccc,color.black,__ACENTER)

	draw.fillrect(x,y,420,420,theme.style.BARCOLOR)
	draw.rect(x,y,420,420,color.black)

	if not angle then angle = 0 end
	angle += 24
	if angle > 360 then angle = 0 end
	draw.framearc(__DISPLAYW/2, __DISPLAYH/2, 40, color.new(255,255,255), 0, 360, 20, 30);
	draw.framearc(__DISPLAYW/2, __DISPLAYH/2, 40, color.new(0,255,0), angle, 90, 20, 30);

	screen.print(__DISPLAYW/2,(__DISPLAYH/2)+45,strings.scanning,1,color.white,color.black,__ACENTER)

	screen.flip()
end

 -- CallBack CopyFiles
function onCopyFiles(size,written,file)

	if theme.data["back"] then theme.data["back"]:blit(0,0)	end
	draw.fillrect(0,0,__DISPLAYW,30, theme.style.BARCOLOR)

	if explorer.dst then
		screen.print(10,10,strings.copyfile+" <--> "+explorer.dst)
	else
		screen.print(10,10,strings.copyfile)
	end

	screen.print(925,10,strings.percent..math.floor((written*100)/size).." %",1.0,color.white, color.black, __ARIGHT)
	screen.print(10,35,strings.file..tostring(file))

	screen.flip()
end

 -- CallBack DeleteFiles
function onDeleteFiles(file)

	if theme.data["back"] then theme.data["back"]:blit(0,0) end
	draw.fillrect(0,0,__DISPLAYW,30, theme.style.BARCOLOR)

	screen.print(10,10,strings.delfile,0.9,color.white)
	screen.print(10,35,strings.file..tostring(file))

	os.delay(10)
	screen.flip()
end
