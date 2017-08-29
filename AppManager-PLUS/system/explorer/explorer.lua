--\
-- ## Explorer ## --
icons_mimes={1,pbp=2,prx=2,bin=2,suprx=2,skprx=2,dat=2,db=2,a=2,prs=2,pmf=2,at9=2,dds=2,tmp=2,html=2,gft=2,sfm=2,icv=2,cer=2,dic=2,pgf=2,
rsc=2,rco=2,res=2,dreg=2,ireg=2,pdb=2,mai=2,bin_bak=2,psp2dmp=2,rif=2,trp=2,self=2,mp4=2,edat=2,log=2,ptf=2,ctf=2,
png=3,gif=3,jpg=3,bmp=3,
mp3=4,s3m=4,wav=4,at3=4,ogg=4,
rar=5,zip=5,vpk=5,gz=5,
cso=6,iso=6,dax=6
}

-- Create two scrolls :P
scroll = {
   list = newScroll(),
   menu = newScroll(),
}

usb_on=false
xtitle,movx = 35,0
title_scr_x = 5
maxim_files=16
backl, explorer, multi = {},{},{} -- All explorer functions
slidex=0

-- ## Explorer Drawer List ## --
function explorer.listshow(posy)

	if movx==0 then
		if scroll.list.maxim >= maxim_files then len_selector = __DISPLAYW-45 else len_selector = __DISPLAYW-11 end
	else
		len_selector = __DISPLAYW-173
	end

	if menu_ctx.close and slidex > 0 then slidex -= 10 end
	if not menu_ctx.close and slidex < 130 then slidex += 10 end

	for i=scroll.list.ini, scroll.list.lim do
		if i==scroll.list.sel then
			draw.fillrect(5+movx, posy-3, len_selector, 22, theme.style.SELCOLOR)
			if screen.textwidth(explorer.list[i].name or "",1) > 480 then 
				xtitle = screen.print(xtitle+movx, posy, explorer.list[i].name,1, isopened[explorer.list[i].ext] or color.white, color.black, __SLEFT, 480)
				xtitle -= movx
			else
				screen.clip(35+movx,0,480+movx,544)
				screen.print(35+movx, posy, explorer.list[i].name,1, isopened[explorer.list[i].ext] or color.white, color.black, __ALEFT)
			end
		else
			screen.clip(35+movx,0,480+movx,544)
			screen.print(35+movx, posy, explorer.list[i].name,1, isopened[explorer.list[i].ext] or color.white, color.black, __ALEFT)
		end
		screen.clip() -- disable clip

		if explorer.list[i].size then
			if icons_mimes[explorer.list[i].ext] then theme.data["icons"]:blitsprite(10+movx, posy, icons_mimes[explorer.list[i].ext]) -- mime type
			else theme.data["icons"]:blitsprite(10+movx, posy, 0) end -- file unk
		else
			theme.data["icons"]:blitsprite(10+movx, posy, 1) -- folder xD
		end

		if explorer.list[i].multi then draw.fillrect(5+movx, posy-3, len_selector, 22, theme.style.MARKEDCOLOR) end

		screen.print(((905-250)+movx)+slidex, posy, explorer.list[i].size or strings.dir, 1, color.white, color.black, __ARIGHT)
		screen.print((905+movx)+slidex, posy, explorer.list[i].mtime, 1.0, color.white, color.black, __ARIGHT)
		posy += 26

	end--for

end

function show_explorer_list()
	movx = menu_ctx.x+menu_ctx.w

	if screen.textwidth(Root[Dev] or "",1) > 800 then 
		title_scr_x = screen.print(title_scr_x+movx,5,Root[Dev],1,theme.style.PATHCOLOR,color.black,__SLEFT,950)
		title_scr_x -= movx
	else
		screen.print(5+movx,5,Root[Dev],1,theme.style.PATHCOLOR,color.black,__ALEFT)
	end

	screen.print(5+movx,26,files.sizeformat(infosize.max or 0).."/"..files.sizeformat(infosize.free or 0),1.0,color.white,color.black,__ALEFT)

	screen.print(940+movx,5,scroll.list.maxim,1,color.new(255,69,0),color.black,__ARIGHT)

	if (multi and #multi > 0) and action then
		if movx==0 then
			screen.print(940-movx,515,strings.items+#multi,1,color.new(255,69,0),color.black,__ARIGHT)
		else
			screen.print((940-movx)+160,515,strings.items+#multi,1,color.new(255,69,0),color.black,__ARIGHT)
		end
	end

	local y,h=70, (maxim_files*26)-2
	if scroll.list.maxim > 0 then
		if scroll.list.maxim >= maxim_files then -- Draw Scroll Bar
			local pos_height = math.max(h/scroll.list.maxim, maxim_files)
			--Barrita Scroll
			draw.fillrect(920+movx, y-2, 8, h, color.new(255,255,255,100))
			draw.fillrect(920+movx, y-2 + ((h-pos_height)/(scroll.list.maxim-1))*(scroll.list.sel-1), 8, pos_height, color.new(0,255,0))
		end
		explorer.listshow(y)
	else
		screen.print(10+movx,80,"...".."\n"..strings.back,1.1,color.white,0x0)
	end

	screen.print(10+movx,515,os.date("%r  %d/%m/%y"),1,theme.style.DATETIMECOLOR,color.gray,__ALEFT)
	if usb_on then
		screen.print(940/2,515,strings.usb,1,theme.style.DATETIMECOLOR,color.gray,__ACENTER)
	else
		screen.print(940/2,515,strings.ftp,1,theme.style.DATETIMECOLOR,color.gray,__ACENTER)
	end
end

function explorer.refresh()
	infosize = os.devinfo(Root[ Dev + NDev])
	explorer.list = files.listsort(Root[Dev])
	scroll.list:set(explorer.list,maxim_files)
	os.delay(100)
end

function ctrls_explorer_list()
	if menu_ctx.open then return end

	if buttons[cancel] then -- return directory
			if (Root[Dev]=="ux0:" or Root[Dev]=="ux0:/") or (Root[Dev]=="ur0:" or Root[Dev]=="ur0:/") or
				(Root[Dev]=="uma0:" or Root[Dev]=="uma0:/") then return end
		Root[Dev]=files.nofile(Root[Dev])
		explorer.refresh()

		if #backl>0 then
			if scroll.list.maxim == backl[#backl].maxim then
				scroll.list.ini = backl[#backl].ini
				scroll.list.lim = backl[#backl].lim
				scroll.list.sel = backl[#backl].sel
			end
			backl[#backl] = nil
		end
	end

	if scroll.list.maxim > 0 then -- Is exists any?
		if buttons.up or buttons.analogly < -60 then scroll.list:up() end
		if buttons.down or buttons.analogly > 60 then scroll.list:down() end

		if buttons[accept] then
			if explorer.list[scroll.list.sel].size then
				handle_files(explorer.list[scroll.list.sel])
			else
				table.insert(backl, {maxim = scroll.list.maxim, ini = scroll.list.ini, sel = scroll.list.sel, lim = scroll.list.lim, })
				Root[Dev]=explorer.list[scroll.list.sel].path
				explorer.refresh()
			end
		end
	end

	if buttons.released.r or buttons.released.l then
		if menu_ctx.open then return end                 -- Switch device
		if buttons.released.l then Dev -= 1 else Dev += 1 end

		if Dev > NDev then Dev = 1 end
		if Dev < 1 then Dev = NDev end

		os.delay(55)
		explorer.refresh()
	end

	if buttons.start then                                 -- FTP
		startftp()
		explorer.refresh()
		explorer.action = 0
		multi={}
	end

   if buttons.square then
      explorer.list[scroll.list.sel].multi = not explorer.list[scroll.list.sel].multi
      if explorer.list[scroll.list.sel].multi then
         table.insert(multi, explorer.list[scroll.list.sel].path)
         explorer.list[scroll.list.sel].index = #multi
      else
         table.remove(multi, explorer.list[scroll.list.sel].index)
      end
   end

end

function handle_files(cnt)
	local extension = cnt.ext

	if extension == "png" or extension == "jpg" or extension == "bmp" or extension == "gif" then
		visorimg(cnt.path)
	elseif extension == "vpk" then
		buttons.homepopup(0)
			show_msg_vpk(cnt)
			if vpkdel then explorer.refresh() end
		buttons.homepopup(1)
	elseif extension == "zip" or extension == "rar" or extension == "7z" or extension == "gz" then
		show_scan(cnt)
	elseif extension == "pbp" or extension == "iso" or extension == "cso" then 
		show_msg_pbp(cnt)
	elseif extension == "mp3" or extension == "wav" or extension == "ogg" then
		MusicPlayer(cnt)
	elseif extension == "txt" or extension == "lua" or extension == "ini" or extension == "sfo" or extension == "xml" or extension == "trp" then 
		visortxt(cnt)
	end

end

--===============================   vpk      ==========================================================================
function moveapp()
	reboot=false
	game.move(applist.data[posapp].name, 2)
	reboot=true
end

function returnvpk()
	reboot=false
	files.copy(newpath, files.nofile(infovpk.path))
	if files.exists(infovpk.path) then
		files.delete(newpath)
	end
	reboot=true
end

function movervpkur0()
	if newpath:sub(1,3) == "ux0" then
		if (Sizeux0.free + sizevpk) > vpkreal then                --Se puede mover e instalar
			--pero antes comprobamos que quepa en ur0
			if Sizeur0.free > sizevpk then                     --movemos a ur0
				if os.message(strings.vpktour0,1)==1 then
					reboot=false
					files.copy(infovpk.path, ur0tmpvk)            --copiamos a ur0
					if files.exists(ur0tmpvk+infovpk.name) then
						files.delete(infovpk.path)                        --borramos ya de ux0
						newpath=ur0tmpvk+infovpk.name
						vpkmove=true
					end
					reboot=true
				else
					return
				end
			else
				os.message(strings.nomemory)
				return
			end
		else
			os.message(strings.stillnomemory)
			return
		end
	else
		os.message(vpkinur0)
		return
	end
end

function show_scan(infovpk)
	bufftmp = screen.buffertoimage()
	local x,y = (960-420)/2,(544-420)/2

	newpath,vpk=nil,nil
	local vpk = {scan = {}, len = 0 }

	reboot=false
	vpk.scan = files.scan(infovpk.path,1)

	if not vpk.scan then return end
	if not #vpk.scan or #vpk.scan<=0 then return end

	vpk.len = #vpk.scan
	reboot=true

	local realsize = files.sizeformat(vpk.scan.realsize or 0)
	while true do
		buttons.read()
		bufftmp:blit(0,0)

		draw.fillrect(x,y,420,420,color.shine)
		draw.framerect(x,y,420,420,color.black, color.shine,6)

		screen.print(960/2,y+35,infovpk.name,1,color.black,color.blue,__ACENTER)
		screen.print(960/2,y+85,strings.total_sizevpk..tostring(realsize),1,color.black,color.blue,__ACENTER)
		screen.print(960/2,y+115,strings.count..tostring(vpk.len),1,color.black,color.blue,__ACENTER)
		screen.flip()

		if buttons[accept] or buttons[cancel] then
			break
		end

	end
end

function show_msg_vpk(infovpk)
	bufftmp = screen.buffertoimage()
	local x,y = (960-420)/2,(544-420)/2

	newpath,vpk=nil,nil
	local vpk = {scan = {}, len = 0 }

	reboot=false
	vpk.scan = files.scan(infovpk.path,1)

	if not vpk.scan then return end
	if not #vpk.scan or #vpk.scan<=0 then return end

	vpk.len = #vpk.scan
	reboot=true

	ebootbin,icon,sfo=-1,-1,-1
	local unsafe=0
	local dang,dangname=false,""

	if vpk.scan and vpk.len>0 then
		for i=1,vpk.len do

			if vpk.scan[i].unsafe >= 1 then
				if vpk.scan[i].unsafe == 2 then
					dang = true
					dangname = vpk.scan[i].name:lower()
				else
					unsafe = 1
				end
			end

			local name = vpk.scan[i].name:lower()
			if name == "sce_sys/icon0.png" then icon = vpk.scan[i].pos
				elseif name == "sce_sys/param.sfo" then sfo = vpk.scan[i].pos
					elseif name == "eboot.bin" then ebootbin = vpk.scan[i].pos
			end

		end
	end

	local realsize = files.sizeformat(vpk.scan.realsize or 0)

	if icon != -1 then
		icon0vpk = game.geticon0(infovpk.path, icon)
	else icon0vpk = game.geticon0(infovpk.path)   end

	if sfo != -1 then
		sfoPVK = game.info(infovpk.path, sfo)
	else sfoPVK = game.info(infovpk.path) end

	if ebootbin == -1 or sfo == -1 then return end

	local ccc = color.shine
	if dang then ccc=color.red
	elseif unsafe == 1 then ccc=color.yellow end

	local res,xscr = false,290
	local version = ""
	if sfoPVK.APP_VER then version = "v"..sfoPVK.APP_VER end

	while true do
		buttons.read()
		bufftmp:blit(0,0)

		draw.fillrect(x,y,420,420,ccc)
		draw.framerect(x,y,420,420,color.black, ccc,6)

		if sfoPVK then
			if screen.textwidth(tostring(sfoPVK.TITLE) or "UNK") > 380 then
				xscr = screen.print(xscr, y+12, tostring(sfoPVK.TITLE) or "UNK",1,color.black,color.blue,__SLEFT,380)
			else
				screen.print(960/2,y+12,tostring(sfoPVK.TITLE) or "UNK",1,color.black,color.blue,__ACENTER)
			end
			if sfoPVK.CATEGORY == "gp" then
				screen.print(960/2,y+35,"UPDATE: "..version,1,color.black,color.blue,__ACENTER)
			else
				screen.print(960/2,y+35,version,1,color.black,color.blue,__ACENTER)
			end
			screen.print(960/2,y+60,tostring(sfoPVK.TITLE_ID),1,color.black,color.blue,__ACENTER)
		end
		screen.print(960/2,y+85,strings.total_sizevpk..tostring(realsize),1,color.black,color.blue,__ACENTER)

		if icon0vpk then
			icon0vpk:setfilter(__ALINEAR, __ALINEAR)
			icon0vpk:scale(150)
			icon0vpk:center()
			icon0vpk:blit(960/2,544/2)
		end

		screen.print(960/2,y+315,strings.installvpk +" ?",1,color.black,color.blue,__ACENTER)
		if dang then
			screen.print(960/2,y+340,strings.alertdang,1,color.black,color.blue,__ACENTER)
			screen.print(960/2,y+365,dangname,0.8,color.black,color.blue,__ACENTER)
		elseif unsafe == 1 then 
			screen.print(960/2,y+340,strings.alertunsafe,1,color.black,color.blue,__ACENTER)
      end

		if accept_x == 1 then
			screen.print(960/2,y+395,string.format("%s"..strings.confirm.." | %s "..strings.cancel,SYMBOL_CROSS, SYMBOL_CIRCLE),1,color.black,color.blue,__ACENTER)
		else
			screen.print(960/2,y+395,string.format("%s"..strings.confirm.." | %s "..strings.cancel,SYMBOL_CIRCLE, SYMBOL_CROSS),1,color.black,color.blue,__ACENTER)
		end
		screen.flip()

		if buttons[accept] or buttons[cancel] then
			if buttons[accept] then res = true end
			break
		end

	end

	if res == false then return end

	Sizeux0=os.devinfo("ux0:")
	Sizeur0=os.devinfo("ur0:")

	newpath=infovpk.path

	--Primero si el juego completo ya extraido no cabe en ux0
	vpkreal = vpk.scan.realsize + 40*1024*1024               --+40MB extras
	sizeocuped = vpkreal-Sizeux0.free
	if not infovpk.size2 then
		sizevpk = files.size(infovpk.path)                  --sacamos el size del puro vpk
	else
		sizevpk = infovpk.size2
	end
	ur0tmpvk = "ur0:datavpk/tempvpk/"

	if (vpkreal  > Sizeux0.free) then
		install=0
		if os.message(strings.required+files.sizeformat(sizeocuped)+strings.searchapp,1)==1 then
			install=1
			--ok intentaremos mover una app de ux0 a ur0
			applist = {data = {}, len = 0 }
			applist.data = files.listdirs("ux0:app/")
			applist.len = #applist.data

			if applist.data and applist.len>0 then
				for i=1,applist.len do
					--obtener el size completo de una carpeta en ux0/app/GAMEIDXXXX
					applist.data[i].size = files.size(applist.data[i].path)
				end
			end
			--ordenamos de menor a mayor asi empezaremos a comparar una app desde la menor...
			table.sort(applist.data,function(a,b) return a.size<b.size end)

			moveapp,posapp,appmove,vpkmove=false,0,false,false
			for i=1,applist.len do
				if applist.data[i].size > sizeocuped then
					moveapp,posapp=true,i
					break
				end
			end

			--Ahora a checar si podemos hacer los movimientos
			tittleapp = "unk"
			if moveapp then
				--Deseas mover la app a ur0
				for i=1, list_apps.len do
					if applist.data[posapp].name == list_apps.data[i].id then
						tittleapp=list_apps.data[i].title
						break
					end
				end
				if os.message(strings.apptour0+"\n"+applist.data[posapp].name+"\n"+strings.tittle+tittleapp+" ?",1)==1 then
					reboot=false
					if game.move(applist.data[posapp].name, 1) == 1 then appmove = true
					else
						os.message(strings.errorapp)
						return
					end
					reboot=true
				else
					movervpkur0()
				end
			else
				movervpkur0()
			end--moveapp
		end
	end   --if (vpkreal  > Sizeux0.free) 

	if install == 0 then return end

	--comienza instalación
	reboot=false
	local result = game.install(newpath, vpk.scan.realsize,false)
	reboot=true
	appman.refresh()
	plugman.load()
	--os.message(strings.installvpk..strings.result..result)
	if result == 1 then
		reboot=false
		if os.message(strings.delete+"\n"+newpath+" ? ",1)==1 then files.delete(newpath) vpkdel=true end
		reboot=true

		--actualizar sizes en ux0 y ur0
		Sizeux0=os.devinfo("ux0:")
		if appmove and applist.data[posapp].size< Sizeux0.free then
			if os.message(strings.ur0toapp,1) ==1 then moveapp() end
		end

		if os.message(strings.launchpbp+"\n"+sfoPVK.TITLE+" ?",1) == 1 then
			if game.exists(sfoPVK.TITLE_ID) then
				game.launch(sfoPVK.TITLE_ID)
			end
		end

	else
		os.message(strings.errorinstall)

		--actualizar sizes en ux0 y ur0
		Sizeux0=os.devinfo("ux0:")
		if appmove and applist.data[posapp].size< Sizeux0.free then
			if os.message(strings.ur0toapp,1) ==1 then moveapp() end
		end
		if vpkmove then
			if os.message(strings.vpktoux0,1) ==1 then returnvpk() end
		end
	end

	bufftmp:blit(0,0)
	buttons.read()--flush xD
	--return res
end

-- ## Menu Contextual ##

local src_path_callback = function ()
   if #explorer.list > 0 then
      local ext = explorer.list[scroll.list.sel].ext or ""
      if menu_ctx.scroll.sel != 3 or (menu_ctx.scroll.sel == 3 and (ext:lower()=="zip" or ext:lower()=="rar" or ext:lower()=="vpk")) then
         if not multi or #multi < 1 then
            table.insert(multi, explorer.list[scroll.list.sel].path)
         end
         explorer.action = menu_ctx.scroll.sel

         if menu_ctx.scroll.sel != 3 then menu_ctx.wakefunct(strings.paste) else menu_ctx.wakefunct(strings.extractto) end
         menu_ctx.close = true
         action = true
      end
   end
end

local paste_callback = function ()
	explorer.dst = Root[Dev]

	if explorer.action == 1 then                        --Paste from Copy
		if #multi>0 then
			buttons.homepopup(0)
			reboot=false
			for i=1,#multi do
				files.copy(multi[i],explorer.dst)
			end
			buttons.homepopup(1)
			reboot=true
		end

	elseif explorer.action == 2 then                     --Paste from Move
		if #multi>0 then
			reboot=false
			local _dst = explorer.dst:sub(1,3)
			for i=1,#multi do
				if multi[i]:sub(1,3) == _dst then
					files.move(multi[i],explorer.dst)
				else
					if files.copy(multi[i],explorer.dst)==1 then files.delete(multi[i]) end
				end
			end
			reboot=true
		end

	elseif explorer.action == 3 then                     --Extract
		if #multi>0 then
			reboot=false
			for i=1,#multi do
				if os.message(multi[i]+"\n"+strings.pass,1)==1 then
					local pass = osk.init(strings.ospass,"")
					if pass then
						buttons.homepopup(0)
							files.extract(multi[i],explorer.dst,pass)
						buttons.homepopup(1)
					end
				else
					buttons.homepopup(0)
						files.extract(multi[i],explorer.dst)
					buttons.homepopup(1)
				end
			end
			reboot=true
		end
	end

--clean
	menu_ctx.wakefunct()
	menu_ctx.close = true
	action = false
	explorer.refresh()
	explorer.action = 0
	explorer.dst = ""
	multi={}
end

local delete_callback = function () -- TODO: add move to -1 pos of the deleted element in list
	if #explorer.list > 0 then
		if explorer.list[scroll.list.sel].multi then
			if #multi>0 then
				if os.message(strings.delete.." "..#multi.."\n"..strings.filesfolders.."(s) ?",1) == 1 then
					reboot=false
						for i=1,#multi do files.delete(multi[i]) end
					reboot=true
				end
			end
		else
			if os.message(strings.delete.." "..explorer.list[scroll.list.sel].name.." ?",1) == 1 then
				reboot=false
					files.delete(explorer.list[scroll.list.sel].path)
				reboot=true
			end
		end
--clean
		menu_ctx.wakefunct()
		menu_ctx.close = true
		action = false
		explorer.refresh()
		explorer.action = 0
		multi={}
	end
end

local makedir_callback = function () -- Added suport multi-new-folder
	local i=1
	while files.exists(Root[Dev].."/"..string.format("%s%03d",strings.newfolder,i)) do
		i+=1
	end
	local name_folder = osk.init(strings.creatfolder, string.format("%s%03d",strings.newfolder,i))
	if name_folder then
		local dest = Root[Dev].."/"..name_folder
		if Root[Dev]:sub(#Root[Dev]) == "/" then dest = Root[Dev]..name_folder end
		files.mkdir(dest)
--clean
		menu_ctx.wakefunct()
		menu_ctx.close = true
		action = false
		explorer.refresh()
		explorer.action = 0
		multi={}
	end
end

local rename_callback = function ()
	if #explorer.list > 0 then
		local new_name = osk.init(strings.rename,files.nopath(explorer.list[scroll.list.sel].path))
		if new_name then
			local fullpath = files.nofile(explorer.list[scroll.list.sel].path)
			files.rename(explorer.list[scroll.list.sel].path, new_name)
			explorer.list[scroll.list.sel].path = fullpath+new_name
			explorer.list[scroll.list.sel].name = new_name
			explorer.list[scroll.list.sel].ext = files.ext(new_name)
--clean
			menu_ctx.wakefunct()
			menu_ctx.close = true
			action = false
			explorer.action = 0
		end
	end
end

local installgame_callback = function ()
	if #explorer.list > 0 then
		if explorer.list[scroll.list.sel].ext == "vpk" then
			buttons.homepopup(0)
				show_msg_vpk(explorer.list[scroll.list.sel])
			buttons.homepopup(1)
			return
		end

		if not files.exists(string.format("%s/eboot.bin",explorer.list[scroll.list.sel].path)) and
			not files.exists(string.format("%s/sce_sys/param.sfo",explorer.list[scroll.list.sel].path)) then return end

		local bufftmp = screen.buffertoimage()
		local x,y = (960-420)/2,(544-420)/2
		local resp=0
		local info = game.info(string.format("%s/sce_sys/param.sfo",explorer.list[scroll.list.sel].path))
		local img =    image.load(string.format("%s/sce_sys/icon0.png",explorer.list[scroll.list.sel].path))

		local res,xscr = false,290
		local Xa = "O: "
		local Oa = "X: "
		if accept_x == 1 then Xa,Oa = "X: ","O: " end
		while true do
			buttons.read()
			bufftmp:blit(0,0)

			draw.fillrect(x,y,420,420,color.shine)
			draw.framerect(x,y,420,420,color.black, color.shine,6)
   
			if info then
				if screen.textwidth(tostring(info.TITLE) or "UNK") > 380 then
					xscr = screen.print(xscr, y+12, tostring(info.TITLE) or "UNK",1,color.black,color.blue,__SLEFT,380)
				else
					screen.print(960/2,y+12,tostring(info.TITLE),1,color.black,color.blue,__ACENTER)
				end
				if info.CATEGORY == "gp" then
					screen.print(960/2,y+35,"UPDATE: "..tostring(info.APP_VER) or "",1,color.black,color.blue,__ACENTER)
				else
					screen.print(960/2,y+35,tostring(info.APP_VER) or "",1,color.black,color.blue,__ACENTER)
				end
				screen.print(960/2,y+55,tostring(info.TITLE_ID),1,color.black,color.blue,__ACENTER)
			end
			if img then
				img:setfilter(__ALINEAR, __ALINEAR)
				img:scale(150)
				img:center()
				img:blit(960/2,544/2)
			end

			screen.print(960/2,y+325,strings.installvpk +" ?",1,color.black,color.blue,__ACENTER)
			screen.print(960/2,y+395,Xa..strings.confirm.." | "..Oa..strings.cancel,1,color.black,color.blue,__ACENTER)
			screen.flip()

			if buttons[accept] or buttons[cancel] then
				if buttons[accept] then res = true end
				break
			end
		end

		if res == false then return end

		buttons.homepopup(0)
		reboot=false
		local result = game.installdir(explorer.list[scroll.list.sel].path)
		buttons.homepopup(1)
		reboot=true
		appman.refresh()
		plugman.load()
		os.message(strings.installvpkdir..strings.result..result)

		bufftmp,img = nil,nil
		if result ==1 then
			if os.message(strings.launchpbp+"\n"+info.TITLE_ID+" ?",1) == 1 then
				if game.exists(info.TITLE_ID) then
					game.launch(info.TITLE_ID)
				end
			end
		end

--clean
		menu_ctx.wakefunct()
		menu_ctx.close = true
		action = false
		explorer.refresh()
		explorer.action = 0
		multi={}
	end
end

local installtheme_callback = function ()
	if #explorer.list > 0 then

		if not files.exists(string.format("%s/theme.xml",explorer.list[scroll.list.sel].path)) then return end
		
		local path_tmp = explorer.list[scroll.list.sel].path

		if Root[Dev + NDev] != "ux0:" then --return end
			if files.copy(explorer.list[scroll.list.sel].path,"ux0:data/customtheme")==1 then files.delete(explorer.list[scroll.list.sel].path) end
			path_tmp = "ux0:data/customtheme/"..explorer.list[scroll.list.sel].name
		end

		buttons.homepopup(0)
			reboot=false
				local result = themes.install(path_tmp)
			buttons.homepopup(1)
		reboot=true

		os.message(strings.instheme..strings.result..result)
		if result == 1 then
			if os.message(strings.settinsthemes,1)==1 then
				os.delay(150)
				os.uri("settings_dlg:custom_themes")
			end
		end

--clean
		menu_ctx.wakefunct()
		menu_ctx.close = true
		action = false
		explorer.refresh()
		explorer.action = 0
		multi={}
	end
end

local sizedir_callback = function ()
	if #explorer.list > 0 then
		local sizedir=0
		if explorer.list[scroll.list.sel].multi then
			if #multi>0 then
				for i=1,#multi do
					sizedir += files.size(multi[i])
				end--for
				os.message(strings.total_size+"\n"+strings.sizeis+files.sizeformat(sizedir or "-1",3))
			end
		else
			if not explorer.list[scroll.list.sel].size then                -- Its Dir
				sizedir = files.size(explorer.list[scroll.list.sel].path)
				os.message(explorer.list[scroll.list.sel].name+"\n"+strings.sizeis+files.sizeformat(sizedir or "-1"))
			else
				os.message(explorer.list[scroll.list.sel].name+"\n"+strings.sizeis+explorer.list[scroll.list.sel].size)
			end
		end
--clean
		sizedir=0
		menu_ctx.wakefunct()
		menu_ctx.close = true
		action = false
		explorer.refresh()
		explorer.action = 0
		multi={}
	end
end

local filesexport_callback = function ()
	if #explorer.list > 0 then
		local ext = explorer.list[scroll.list.sel].ext or ""
		if ext:lower() == "png" or ext:lower() == "jpg" or ext:lower() == "bmp" or ext:lower() == "gif" or ext:lower() == "mp3" or ext:lower() == "mp4" then
			reboot=false
				local titlew = screen.textwidth(strings.wait) + 30
				draw.fillrect(450-(titlew/2),272-20,titlew,70,theme.style.BARCOLOR)
				draw.rect(450-(titlew/2),272-20,titlew,70,color.white)
				screen.print(450,272-20+13,strings.wait,1,color.white,color.black,__ACENTER)
				screen.flip()
				local result = files.export(explorer.list[scroll.list.sel].path)
			reboot=true

			if result == 1 then
				if os.message(strings.opensettings,1)==1 then
					os.delay(150)
					if ext:lower() == "mp3" then os.uri("music:browse?category=ALL")
					elseif ext:lower() == "mp4" then os.uri("video:browse?category=ALL")
					else os.uri("photo:browse?category=ALL") end
				end
			end
--clean
			menu_ctx.wakefunct()
			menu_ctx.close = true
			action = false
			infosize = os.devinfo(Root[Dev + NDev])
			if ext:lower() == "mp4" and result == 1 then
				explorer.refresh()
				multi={}
			end
			explorer.action = 0
		end
	end
end

--[[
local pluginsman_callback = function ()
   menu_ctx.wakefunct()
   pluginsman()
--clean
   menu_ctx.close = true
   action = false
   explorer.refresh()
   explorer.action = 0
   multi={}
end
]]

function startftp()
	if not wlan.isconnected() then wlan.connect() end
	if wlan.isconnected() then ftp.init() end

	while ftp.state() do
		reboot=false
		power.tick(1)
		buttons.read()
		if theme.data["ftp"] then theme.data["ftp"]:blit(0,0) end
		screen.print(960/2,300,strings.textftp,1,color.white,color.blue,__ACENTER)
		screen.print(327,333,"FTP://"+tostring(wlan.getip())..":1337",1,theme.style.FTPCOLOR,color.black)
		screen.print(960/2,375,strings.closeftp,1,color.white,color.blue,__ACENTER)
		screen.flip()

		if buttons.start then
			if theme.data["ftp"] then theme.data["ftp"]:blit(0,0) end
			screen.print(960/2,300,strings.textftp,1,color.white,color.blue,__ACENTER)
			screen.print(327,333,"FTP://"+tostring(wlan.getip())..":1337",1,theme.style.FTPCOLOR,color.black)
			screen.print(960/2,375,strings.loseftp,1,color.white,color.blue,__ACENTER)
			screen.flip()
			ftp.term()
			os.delay(250)
			explorer.refresh()
		end

	end
	reboot=true
end

local advanced_callback = function ()
	menu_ctx.wakefunct()
--clean
	menu_ctx.close = true
	action = false
	explorer.refresh()
	explorer.action = 0
	multi={}

	advanced_options()
end

local restart_callback = function ()
	menu_ctx.wakefunct()
	os.restart()
end

local reboot_callback = function ()
	menu_ctx.wakefunct()
	os.message(strings.restart)
	power.restart()
end

local shutdown_callback = function ()
	menu_ctx.wakefunct()
	os.delay(150)
	os.message(strings.shutdown)
	os.delay(1500)
	power.shutdown()
end

local cancel_callback = function ()
	menu_ctx.wakefunct()
--clean
	menu_ctx.close = true
	action = false
	explorer.refresh()
	explorer.action = 0
	multi={}
end

menu_ctx = { -- Creamos un objeto menu contextual
	h = (maxim_files*26)-2, -- Height of menu
	w = 160, -- Width of menu
	x = -160, -- X origin of menu
	y = 45, -- Y origin of menu
	open = false, -- Is open the menu?
	close = true,
	speed = 10, -- Speed of Effect Open/Close.
	ctrl = "triangle", -- The button handle Open/Close menu.
	scroll = newScroll(), -- Scroll of menu options.
}

function menu_ctx.wakefunct(var)
	menu_ctx.options = { -- Handle Option Text and Option Function
		{ text = strings.delete,		state = true, funct = delete_callback },
		{ text = strings.makedir,      	state = true, funct = makedir_callback },
		{ text = strings.rename,      	state = true, funct = rename_callback },
		{ text = strings.size,         	state = true, funct = sizedir_callback },
		{ text = strings.export,      	state = true, funct = filesexport_callback },
		{ text = strings.insvpkfromdir, state = true, funct = installgame_callback },
		{ text = strings.instheme,      state = true, funct = installtheme_callback },
		--{ text = strings.pluginsman,  state = true, funct = pluginsman_callback },
		{ text = strings.advanced,      state = true, funct = advanced_callback },
		{ text = strings.restarthb,    	state = true, funct = restart_callback },
		{ text = strings.reset,      	state = true, funct = reboot_callback },
		{ text = strings.off,      		state = true, funct = shutdown_callback },
		{ text = strings.cancel,      	state = true, funct = cancel_callback },
	}
	if var==strings.paste then
		table.insert(menu_ctx.options, 1, { text = strings.paste,      	state = true, funct = paste_callback })
	elseif var==strings.extractto then
		table.insert(menu_ctx.options, 1, { text = strings.extractto,   state = true, funct = paste_callback })
	else
		table.insert(menu_ctx.options, 1, { text = strings.copy,      	state = true, funct =  src_path_callback })
		table.insert(menu_ctx.options, 2, { text = strings.move,      	state = true, funct = src_path_callback })
		table.insert(menu_ctx.options, 3, { text = strings.extract,     state = true, funct = src_path_callback })
	end
	menu_ctx.scroll = newScroll(menu_ctx.options, #menu_ctx.options)
end

menu_ctx.wakefunct()

function menu_ctx.run()
	if buttons[menu_ctx.ctrl] then menu_ctx.close = not menu_ctx.close end -- Open/Close Menu
	menu_ctx.draw()
	menu_ctx.buttons()
end

function menu_ctx.draw()

	if not menu_ctx.close and menu_ctx.x < 0 then
		menu_ctx.x += menu_ctx.speed
	elseif menu_ctx.close and menu_ctx.x > -menu_ctx.w then
		menu_ctx.x -= menu_ctx.speed
	end

	if menu_ctx.x > -menu_ctx.w then
		if theme.data["menu"] then
			theme.data["menu"]:blit(menu_ctx.x, menu_ctx.y)
		else
			draw.fillrect(menu_ctx.x, menu_ctx.y, menu_ctx.w, menu_ctx.h, theme.style.BARCOLOR)
		end
	end

	if menu_ctx.x >= 0 then
		menu_ctx.open = true
		local h = menu_ctx.y + 30 -- Punto de origen de las opciones
		for i=menu_ctx.scroll.ini,menu_ctx.scroll.lim do
			if i==menu_ctx.scroll.sel then cc=color.green else cc=color.white end
			if menu_ctx.options[i].state then
				screen.print(5, h, menu_ctx.options[i].text, 1, cc, color.blue, __ALEFT)
				h += 25
			end
		end
	else
		menu_ctx.open = false
	end
end

function menu_ctx.buttons()
	if not menu_ctx.open then return end

	if buttons.up or buttons.analogly < -60 then menu_ctx.scroll:up() end
	if buttons.down or buttons.analogly > 60 then menu_ctx.scroll:down() end

	if buttons[accept] and menu_ctx.options[menu_ctx.scroll.sel].funct then
		menu_ctx.options[menu_ctx.scroll.sel].funct()
	end

	if buttons[cancel] then -- Run function of cancel option.
		menu_ctx.close = not menu_ctx.close
	end
end
