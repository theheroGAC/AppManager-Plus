menuadv = {}

local themesAppManager_callback = function ()
	menuadv.wakefunct()
	theme.manager()
	advanced_options()
end

local themesLiveArea_callback = function ()
	menuadv.wakefunct()
	theme_mgr.launch()
	advanced_options()
end

local scanvpk_callback = function ()
	menuadv.wakefunct()

	local titlew = screen.textwidth(strings.wait) + 30
	draw.fillrect(480-(titlew/2),272-40,titlew,70,theme.style.BARCOLOR)
	draw.rect(480-(titlew/2),272-40,titlew,70,color.white)
	screen.print(480,(272-40)+13,strings.wait,1,color.white,color.black,__ACENTER)
	screen.flip()

	scan(0)
	advanced_options()
end

local reloadconfig_callback = function ()
	menuadv.wakefunct()

	os.taicfgreload()
	os.delay(100)
	os.message(strings.configtxt)
end

local rebuilddb_callback = function ()
	menuadv.wakefunct()

	os.delay(150)
	_print=false
	os.rebuilddb()
	os.message(strings.restartredb)
	os.delay(1500)
	power.restart()
end

local updatedb_callback = function ()
	menuadv.wakefunct()

	os.delay(150)
	_print=false
	os.updatedb()
	os.message(strings.restartupdb)
	os.delay(1500)
	power.restart()
end

function menuadv.wakefunct()
	menuadv.options = {
		{ text = strings.refreshdb, 	funct = updatedb_callback },
		{ text = strings.rebuilddb, 	funct = rebuilddb_callback },
		{ text = strings.reloadconfig,	funct = reloadconfig_callback },
		{ text = strings.scanvpks,		funct = scanvpk_callback },
		{ text = strings.themes,      	funct = themesAppManager_callback },
		{ text = strings.cthemesman,   	funct = themesLiveArea_callback },
	}
end

menuadv.wakefunct()

function advanced_options()

	local scroll = newScroll(menuadv.options, #menuadv.options)--10)
	buttons.interval(10,10)

	while true do
		buttons.read()

		if theme.data["list"] then theme.data["list"]:blit(0,0) end

		screen.print(480,15,strings.advanced,1,theme.style.TITLECOLOR,color.gray,__ACENTER)

		if buttons.up or buttons.analogly < -60 then scroll:up() end
		if buttons.down or buttons.analogly > 60 then scroll:down() end

		if buttons[accept] then
			menuadv.options[scroll.sel].funct()
		end

		local y = 70
		for i=scroll.ini,scroll.lim do
			if i == scroll.sel then draw.fillrect(10,y-2,930,23,theme.style.SELCOLOR) end

			screen.print(480,y, menuadv.options[i].text,1.0,color.white,theme.style.BKGCOLOR,__ACENTER)

			y+=26
		end

		if buttons[cancel] then os.delay(200) selmenu = 2 break end
		if (buttons.held.l and buttons.held.r and buttons.up) and reboot then os.restart() end
		if (buttons.held.l and buttons.held.r and buttons.down) and reboot then power.restart() end

		screen.flip()

	end
end
