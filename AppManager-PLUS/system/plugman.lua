plugman = { -- Modulo Plugins Manager.
	cfg = {}, -- Have original state of file.
	list = {}, -- Handle list of plugins.
	scroll = newScroll({},10), -- Scroll of plugins.
	gameid = "", -- Gameid of select.
}

function plugman.load()
    local path = "ux0:tai/config.txt"
	plugman.cfg = {} -- Set to Zero
	plugman.list = {} -- Set to Zero
if not files.exists(path) then path = "ur0:tai/config.txt" end
	if files.exists(path) then
		local id_sect = nil
		local i = 1;
		for line in io.lines(path) do
			table.insert(plugman.cfg,line)
			
			if line:find("*",1) then -- Secction Found
				id_sect = line:sub(2)
				if not plugman.list[id_sect] then plugman.list[id_sect] = {sectln = i} end
				continue
			end
			
			if id_sect then
				if #line > 0 then
					local state = line:find("#",1)
					line = line:gsub('#',''):lower()
					if line:sub(1,4) == "ux0:" or line:sub(1,4) == "ur0:" then
						table.insert(plugman.list[id_sect],{name = files.nopath(line), path = line, exists = files.exists(line), line = i, state = state})
					end
				end
			end
			
			i += 1
		end
	end
end

function plugman.ctrl()

	if buttons.up then plugman.scroll:up() elseif buttons.down then plugman.scroll:down() end

	if plugman.scroll.maxim > 0 then

		if buttons.start then -- No Utility if only show plugins for id specific
			os.taicfgreload()
			os.delay(100)
			os.message(strings.reloadconfig)
			plugman.load()
			plugman.scroll:set(plugman.list[plugman.gameid], 10)
		end

		if buttons.square then -- Delete prx!
			if os.message(strings.disablesuprx.."\n"..plugman.list[plugman.gameid][plugman.scroll.sel].name,1)==1 then
				for i=1,#plugman.cfg do
					--if plugman.cfg[i] == plugman.list[plugman.gameid][plugman.scroll.sel].path then
						table.remove(plugman.list[plugman.gameid], plugman.scroll.sel) -- remove entry in list
						table.remove(plugman.cfg, plugman.list[plugman.gameid].ln) -- remove line in cfg!
						if #plugman.list[plugman.gameid] < 1 then -- No have more prx!, delete id!
							table.remove(plugman.cfg, plugman.list[plugman.gameid].ln-1) -- remove line in cfg!
						end
						plugman.scroll:set(plugman.list[plugman.gameid], 10) -- Update list
						break
					--end
				end
				write_txt("ux0:tai/config.txt", plugman.cfg)
				--reload config.txt
				--os.delay(100)
				--os.taicfgreload()
				--os.delay(100)
			end
		end

	end
end

function plugman.draw()

	screen.print(480,15,strings.plugsmanager.." - "..plugman.gameid,1,color.white,color.blue,__ACENTER)
	screen.print(950,15,strings.count+plugman.scroll.maxim,1,color.red,theme.style.BKGCOLOR,__ARIGHT)
	
	if plugman.scroll.maxim > 0 then
		local y = 70
		for i=plugman.scroll.ini, plugman.scroll.lim do
			if i == plugman.scroll.sel then draw.fillrect(20,y-2,670,22,theme.style.SELCOLOR) end
			screen.print(30,y,plugman.list[plugman.gameid][i].name + " " + plugman.list[plugman.gameid][i].path + " " + tostring(plugman.list[plugman.gameid][i].exists),1.0,color.white,theme.style.BKGCOLOR,__ALEFT)
			y += 26
		end
	else
		screen.print(10,30,strings.empty,1.0,color.white,color.blue)
	end
	
end

function plugman.run()
	plugman.draw()
	plugman.ctrl()
end

function plugman.launch(id)
	if not plugman.list[id] then return false end -- Exit if not have plugin, TODO: if not have plugs create obj!
	plugman.gameid = id
	plugman.scroll:set(plugman.list[plugman.gameid], 10)
	while true do
		buttons.read()
		plugman.run()
		screen.flip()
		if buttons.circle then break end
	end
end
