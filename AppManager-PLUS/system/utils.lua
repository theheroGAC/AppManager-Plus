--[[ 
	APP Manager Plus
	Application, themes and files manager.
	
	Licensed by Creative Commons Attribution-ShareAlike 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Designed By Gdljjrod & DevDavisNunez.
	Collaborators: BaltaR4 & Wzjk.
]]

accept,cancel = "cross","circle"
textXO = "O: "
accept_x = 1
if buttons.assign()==0 then
	accept,cancel = "circle","cross"
	textXO = "X: "
	accept_x = 0
end

function ini.load(path) -- Translate a ini file to table lua! :D
    if not files.exists(path) then return nil end
    local fp = io.open(path, "r")
    local data = {}
    local rejected = {}
    local parent = data
    local i = 0
    local m, n

    local function parse(line)
        local m, n

        -- kv-pair
        m,n = line:match('^([%w%p]-)="(.*)"') -- parche para darle espacio al =
        if m then
			if tonumber(n) then
				if not(string.len(n) > 1 and tonumber(n) == 0) then -- parche para que reconosca 0000 como string xD pues si no retorna solo 0 como numero, 
					n = tonumber(n) 
				end
			end
			if n == "true" then n = true end
			if n == "false" then n = false end
            parent[tonumber(m) or m] = n
            return true
        end

        -- section opening
        m = line:match("^%[([%w%p]+)%][%s]*")
        if m then
			if tonumber(m) then m = tonumber(m) end
            data[m] = {}
            parent = data[m]
            return true
        end

        if line:match("^$") then
            return true
        end

        -- comment
        if line:match("^#") then
            return true
        end

        return false
    end

    for line in fp:lines() do
        i = i + 1
        if not parse(line) then
            table.insert(rejected, i)
        end
    end
    fp:close()
    return data
end

function write_txt(pathini, tb)
    local file = io.open(pathini, "w+")
	for s,t in pairs(tb) do
		file:write(string.format('%s\n', tostring(t)))
	end
	file:close()
end

function write_ini(pathini, tb)
    local file = io.open(pathini, "w+")
	file:write("config = {\n")
	for s,t in pairs(tb) do
		if type(t) == "string" then
			file:write(string.format('"%s",\n', tostring(t)))
		else
			--file:write(string.format('%s,\n', tostring(t)))
			file:write(string.format('0x%x,\n', t))
		end
	end
	file:write("}")
	file:close()
end

function save_config()
	write_ini(pathini, config)
end

function files.readlinesSFO(path)
	local sfo = game.info(path)
	if not sfo then return nil end
	local data = {}
	for k,v in pairs(sfo) do
		table.insert(data,tostring(k).." = "..tostring(v))
	end
	return data
end

function files.readlines(path,index) -- Lee una table o string si se especifica linea
	if files.exists(path) then
		local contenido = {}
		for linea in io.lines(path) do
			table.insert(contenido,linea)
		end

		if index == nil then return contenido
		else return contenido[index] end
	end
end

function files.listsort(path)
	local tmp1 = files.listdirs(path)

	if tmp1 then
		table.sort(tmp1,function(a,b) return string.lower(a.name)<string.lower(b.name) end)
	else
		tmp1 = {}
	end

	local tmp2 = files.listfiles(path)

	if tmp2 then
		table.sort(tmp2,function(a,b) return string.lower(a.name)<string.lower(b.name) end)
		for s,t in pairs(tmp2) do
			t.sizenum = t.size
			t.size = files.sizeformat(t.size)
			table.insert(tmp1,t)-- esto es por que son subtablas, realmente no puedo hacer un cont con tmp2
		end
	end

	return tmp1

end

--[[
	## Library Scroll ##
	Designed By DevDavis (Davis Nuñez) 2011 - 2016.
	Based on library of Robert Galarga.
	Create a obj scroll, this is very usefull for list show
	]]
function newScroll(a,b,c)
	local obj = {ini=1,sel=1,lim=1,maxim=1,minim = 1}

	function obj:set(tab,mxn,modemintomin) -- Set a obj scroll
		obj.ini,obj.sel,obj.lim,obj.maxim,obj.minim = 1,1,1,1,1
		--os.message(tostring(type(tab)))
		if(type(tab)=="number")then
			if tab > mxn then obj.lim=mxn else obj.lim=tab end
			obj.maxim = tab
		else
			if #tab > mxn then obj.lim=mxn else obj.lim=#tab end
			obj.maxim = #tab
		end
		if modemintomin then obj.minim = obj.lim end
	end

	function obj:max(mx)
		obj.maxim = #mx
	end

	function obj:up()
		if obj.sel>obj.ini then obj.sel=obj.sel-1
		elseif obj.ini-1>=obj.minim then
			obj.ini,obj.sel,obj.lim=obj.ini-1,obj.sel-1,obj.lim-1
		end
	end

	function obj:down()
		if obj.sel<obj.lim then obj.sel=obj.sel+1
		elseif obj.lim+1<=obj.maxim then
			obj.ini,obj.sel,obj.lim=obj.ini+1,obj.sel+1,obj.lim+1
		end
	end

	--[[function obj:test(x,y,h,tabla,high,low,size)
		local py = y
		for i=obj.ini,obj.lim do 
			if i==obj.sel then screen.print(x,py,tabla[i],size,high)
			else screen.print(x,py,tabla[i],size,low)
			end
			py += h
		end
	end
	]]

	if a and b then
		obj:set(a,b,c)
	end

	return obj

end

function reload_configtxt()
	os.taicfgreload()
	os.delay(100)
	os.message(strings.configtxt)
end

function usbMassStorage()

    local buff = screen.buffertoimage()
	local titlew = screen.textwidth(strings.connectusb) + 30

	while usb.cable() != 1 and usb.state() != 1 do
		power.tick(1)
		buttons.read()
		buff:blit(0,0)

		draw.fillrect(450-(titlew/2),272-20,titlew,70,theme.style.BARCOLOR)
		draw.rect(450-(titlew/2),272-20,titlew,70,color.white)
		screen.print(450,272-20+13, strings.connectusb,1,color.white,color.black,__ACENTER)
		screen.print(450,272-20+40, textXO..strings.cancelusb,1,color.white,color.black,__ACENTER)

		screen.flip()

		if buttons[cancel] then
			return false
		end
	end

	usb.start()

	titlew = screen.textwidth(strings.usbconnection) + 30
	while not buttons[cancel] do
		power.tick(1)
		buttons.read()
		buff:blit(0,0)

		draw.fillrect(450-(titlew/2),272-20,titlew,70,theme.style.BARCOLOR)
		draw.rect(450-(titlew/2),272-20,titlew,70,color.white)
		screen.print(450,272-20+13, strings.usbconnection,1,color.white,color.black,__ACENTER)
		screen.print(450,272-20+40, textXO..strings.cancelusb,1,color.white,color.black,__ACENTER)

		screen.flip()
	end

	usb.stop()

end
