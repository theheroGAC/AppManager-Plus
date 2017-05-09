function getvpks(path)
	local tmp = files.listfiles(path)

	if tmp and #tmp > 0 then
		for i=1,#tmp do
			local extension = tmp[i].ext:lower()

			if extension == "vpk" or extension == "mp4" or extension == "cso" or extension == "iso" then
				if files.type(tmp[i].path) == 5 then										--Its really zip/vpk
					if extension != "vpk" then
						local new_name =  tmp[i].name+".vpk"
						local fullpath = files.nofile(tmp[i].path)
						files.rename(tmp[i].path,new_name)
						tmp[i].path = fullpath+new_name
						tmp[i].name = new_name
						tmp[i].ext = "vpk"
					end
					table.insert(list_vpks.data, tmp[i])
				elseif files.type(tmp[i].path) == 2 or files.type(tmp[i].path) == 3 then	--Its really iso/cso
					if extension == "iso" or extension == "cso" then table.insert(list_vpks.data, tmp[i])
					else
						if files.type(tmp[i].path) == 2 then _ext=".iso" __ext="iso"
						elseif files.type(tmp[i].path) == 3 then _ext=".cso" __ext="cso" end

						local new_name =  tmp[i].name+_ext
						local fullpath = files.nofile(tmp[i].path)
						files.rename(tmp[i].path,new_name)
						tmp[i].path = fullpath+new_name
						tmp[i].name = new_name
						tmp[i].ext = __ext
						table.insert(list_vpks.data, tmp[i])
					end
				end
			end

		end--for
	end
	tmp=nil
end

function scan()
	list_vpks = nil
	list_vpks = {data = {}, len = 0}

	getvpks("ux0:video/")
	getvpks("ux0:data/")
	getvpks("ux0:data/vpk/")
	getvpks("ux0:/vpk/")
	getvpks("ux0:/vpks/")
	getvpks("ur0:data/")
	getvpks("ur0:data/vpk/")
	getvpks("ur0:/vpk/")
	getvpks("ur0:/vpks/")

	list_vpks.len = #list_vpks.data
	table.sort(list_vpks.data,function(a,b) return string.lower(a.name)<string.lower(b.name) end)

	local srcn = newScroll(list_vpks.data,15)
	buttons.interval(10,10)
	while true do
		buttons.read()

		if theme.data["list"] then theme.data["list"]:blit(0,0) end

		screen.print(480,15,strings.vpktittle,1,theme.style.TITLECOLOR,color.blue,__ACENTER)
		screen.print(950,15,strings.count + list_vpks.len,1,color.red,theme.style.BKGCOLOR,__ARIGHT)

		if list_vpks.len > 0 then
			if buttons.up then srcn:up() elseif buttons.down then srcn:down() end

			if buttons.cross then
				if list_vpks.data[srcn.sel].ext:lower() == "vpk" then

					buttons.homepopup(0)
						show_msg_vpk(list_vpks.data[srcn.sel])
					buttons.homepopup(1)
					--infosize = os.devinfo(Root[Dev]:sub(1,4))

				elseif list_vpks.data[srcn.sel].ext:lower() == "iso" or list_vpks.data[srcn.sel].ext:lower() == "cso" then

					if list_vpks.data[srcn.sel].path:sub(1,3) == "ux0" then
						reboot=false
						files.move(list_vpks.data[srcn.sel].path,"ux0:pspemu/ISO")
						reboot=true

						if not files.exists(list_vpks.data[srcn.sel].path) then
							table.remove(list_vpks.data, srcn.sel)
							srcn:set(list_vpks.data,15)
							os.message(strings.moveiso2ux0)
						end

					elseif list_vpks.data[srcn.sel].path:sub(1,3) == "ur0" then
						reboot=false
						files.move(list_vpks.data[srcn.sel].path,"ur0:pspemu/ISO")
						reboot=true
	
						if not files.exists(list_vpks.data[srcn.sel].path) then
							table.remove(list_vpks.data, srcn.sel)
							srcn:set(list_vpks.data,15)
							os.message(strings.moveiso2ur0)
						end
					end
				end

				buttons.read()
				if vpkdel then
					table.remove(list_vpks.data, srcn.sel)
					srcn:set(list_vpks.data,15)
					vpkdel=false
				end
			end

			local y = 70
			for i=srcn.ini,srcn.lim do
				if i == srcn.sel then draw.fillrect(25,y-2,700,22,theme.style.SELCOLOR) end

				screen.print(40,y,'#'+string.format("%02d",i)+' ) '+list_vpks.data[i].path,1.0,color.white,theme.style.BKGCOLOR,__ALEFT)

				y+=26
			end

		else
			screen.print(10,30,strings.empty,1.0,color.white,color.blue)
		end

		if buttons.circle then selmenu = 2 break end
		if (buttons.held.l and buttons.held.r and buttons.up) and reboot then os.restart() end

		screen.flip()

	end
end
