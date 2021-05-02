/*
..
*/

local str_upper = utf8.Utf8_upper	or utf8.upper
local str_gmatch= utf8.Utf8_gmatch	or utf8.gmatch
local str_len	= utf8.Utf8_len		or utf8.len
local str_find	= utf8.Utf8_find	or utf8.find
local str_cfind = utf8.cfind
local str_format= utf8.format
local math_max	= math.max
local tbl_concat= table.concat
local far_LIsUpper = far.LIsUpper

/*
..
*/

	local tbl_areas = {
		{ s = "S", l = " SHELL "	},
		{ s = "I", l = " INFO "		},
		{ s = "Q", l = " QVIEW "	},
		{ s = "T", l = " TREE "		},
		{ s = "s", l = " SEARCH "	},
		{ s = "F", l = " FINDFOLDER "	},
		{ s = "V", l = " VIEWER "	},
		{ s = "E", l = " EDITOR "	},
		{ s = "D", l = " DIALOG "	},
		{ s = "m", l = " MENU "		},
		{ s = "M", l = " MAINMENU "	},
		{ s = "U", l = " USERMENU "	},
		{ s = "d", l = " DISKS "	},
		{ s = "A", l = " SHELLAUTOCOMPLETION "	},
		{ s = "a", l = " DIALOGAUTOCOMPLETION "	},
		{ s = "H", l = " HELP "		},
		{ s = "G", l = " GRABBER "	},
		{ s = "e", l = " DESKTOP "	},
		{ s = "O", l = " OTHER "	},
		{ s = "C", l = " COMMON "	}
	}

	-- сворачивает список областей в короткую строку фиксированной длины
	local function ShortArea(area)
	--	local a  = ""
		local au = " "..str_upper(area).." "
		local tbl_a = { }
		for _, sl in ipairs(tbl_areas) 
		do--	a = a..(au:find(sl.l) and sl.s or "·") 
			tbl_a[#tbl_a + 1] = str_find(au, sl.l) and sl.s or "·" 
		end
	--	return a
		return tbl_concat(tbl_a)
	end

	local tbl_evt_groups = {
		{ s = " DE", l = "DIALOGEVENT"},
		{ s = " VE", l = "VIEWEREVENT"},
		{ s = " EE", l = "EDITOREVENT"},
		{ s = " EI", l = "EDITORINPUT"},
		{ s = " CI", l = "CONSOLEINPUT"},
		{ s = " EF", l = "EXITFAR"}
	}
	--
	-- сворачивает список областей в короткую строку фиксированной длины
	local function ShortGroup(group)
	--	local g = ""
		local gu= " "..str_upper(group).." "
		local tbl_g = { }
		for _, sl in ipairs(tbl_evt_groups)
		do--	g = g..(gu:find(sl.l) and sl.s or " · ") 
			tbl_g[#tbl_g + 1] = str_find(gu, sl.l) and sl.s or " · "
		end
	--	return g
		return tbl_concat(tbl_g)
	end

	local Area_Current_upper = str_upper(Area.Current)
	--
	-- сравнение 2 макросов по: "COMMON"?, текущая?, по областям, по клавишам, по маскам файлов, по описаниям
	local function CompareMacros(a, b)
		local as, bs, a1, b1, f, c_upper = "", ""
		local tbl_as, tbl_bs = { }, { }
		local a_area_upper = str_upper(a.area)
		local b_area_upper = str_upper(b.area)
	--	local Area_Current_upper = str_upper(Area.Current)
		for c in str_gmatch(S.SO.M, ".")
		do	c_upper = str_upper(c)
			a1, b1 = "", ""
			if	c_upper == "O"
			then	a1 = not str_cfind(a_area_upper, "COMMON")
				b1 = not str_cfind(b_area_upper, "COMMON")
			--	a1 = not a.area:upper():cfind("COMMON")
			--	b1 = not b.area:upper():cfind("COMMON")
			elseif	c_upper == "C"
			then	a1 = not str_cfind(a_area_upper, Area_Current_upper)
				b1 = not str_cfind(b_area_upper, Area_Current_upper)
			--	a1 = not a.area:upper():cfind(Area.Current:upper())
			--	b1 = not b.area:upper():cfind(Area.Current:upper())
			elseif	c_upper == "A"
			then	a1 = ShortArea(a.area)
				b1 = ShortArea(b.area)
			elseif	c_upper == "K"
			then	a1 = str_upper(a.key)
				b1 = str_upper(b.key)
			elseif	c_upper == "F"
			then	a1 = a.filemask or ""
				b1 = b.filemask or ""
			elseif	c_upper == "D"
			then	a1 = a.description
				b1 = b.description
			end
			--[[
			if	far_LIsUpper(c)
			then	a1 = tostring(a1)
				b1 = tostring(b1)
			else	a1 = tostring(b1)
				b1 = tostring(a1)
			end --]]
			a1 = tostring(a1)
			b1 = tostring(b1)
			a1, b1 = a1 == "nil" and "" or a1, b1 == "nil" and "" or b1
			f = "%-"..math_max(str_len(a1), str_len(b1)).."s"
		--	as, bs = as..str_format(f, a1), bs..str_format(f, b1)
			tbl_as[#tbl_as + 1] = str_format(f, a1)
			tbl_bs[#tbl_bs + 1] = str_format(f, b1)
		end
		as = tbl_concat(tbl_as)
		bs = tbl_concat(tbl_bs)
		return as < bs
	end -- CompareMacros
	--
	-- сравнение 2 обработчиков событий по: 1 - по группам; 2 - по маскам файлов; 3 - по описаниям
	local function CompareEvents(a, b)
		local as, bs, a1, b1, f, c_upper = "", ""
		local tbl_as, tbl_bs = { }, { }
		for c in str_gmatch(S.SO.E, ".")
		do      c_upper = str_upper(c)
			a1, b1 = "", ""
			if	c_upper == "G"
			then	a1 = ShortGroup(a.group)
				b1 = ShortGroup(b.group)
			elseif	c_upper == "F"
			then	a1, b1 = a.filemask or "", b.filemask or ""
			elseif	c_upper == "D"
			then	a1, b1 = a.description, b.description
			end
			--[[
			if	far_LIsUpper(c)
			then	a1, b1 = tostring(a1), tostring(b1)
			else    a1, b1 = tostring(b1), tostring(a1)
			end --]]
			a1 = tostring(a1)
			b1 = tostring(b1)
			a1, b1 = a1 == "nil" and "" or a1, b1 == "nil" and "" or b1
			f = "%-"..math_max(str_len(a1), str_len(b1)).."s"
		--	as, bs = as..f:format(a1), bs..f:format(b1)
			tbl_as[#tbl_as + 1] = str_format(f, a1)
			tbl_bs[#tbl_bs + 1] = str_format(f, b1)
		end
		as = tbl_concat(tbl_as)
		bs = tbl_concat(tbl_bs)
		return as < bs
	end
	--
	-- сравнение 2 модулей по: 1 - тип; 2 - маска поиска; 3 - имя
	local function CompareModules(a, b)
		local as, bs, a1, b1, f, c_upper = "", ""
		local tbl_as, tbl_bs = { }, { }
		for c in S.SO.O:gmatch(".")
		do	c_upper = str_upper(c)
			a1, b1 = "", ""
			if	c_upper == "T"
			then	a1, b1 = a.type, b.type
			elseif	c_upper == "M"
			then	a1, b1 = a.mask, b.mask
			elseif	c_upper == "N"
			then    a1, b1 = a.name, b.name
			end
			--[[
			if far.LIsUpper(c)
			then	a1, b1 = tostring(a1), tostring(b1)
			else	a1, b1 = tostring(b1), tostring(a1)
			end --]]
			a1 = tostring(a1)
			b1 = tostring(b1)
			a1, b1 = a1 == "nil" and "" or a1, b1 == "nil" and "" or b1
			f = "%-"..math.max(a1:len(), b1:len()).."s"
		--	as, bs = as..str_format(f, a1), bs..str_format(f, b1)
			tbl_as[#tbl_as + 1] = str_format(f, a1)
			tbl_bs[#tbl_bs + 1] = str_format(f, b1)
		end
		as = tbl_concat(tbl_as)
		bs = tbl_concat(tbl_bs)
		return as < bs
	end
	--
	-- сравнение 2 пунктов меню плагинов по: использующие меню, область, "COMMON"?, текущая?, описание
	local function CompareMenuItems(a, b)
		local as, bs, a1, b1, f, c_upper = "", ""
		local tbl_as, tbl_bs = { }, { }
		for c in S.SO.I:gmatch(".")
		do	c_upper = str_upper(c)
			a1, b1 = "", ""
			if	c_upper == "M"
			then	for _, m in pairs({"plugins", "disks", "config"})
				do	a1, b1 = a1..(a.flags[m] and "1" or "2"), b1..(b.flags[m] and "1" or "2")
				end
			elseif	c_upper == "O"
			then	a1, b1 = not a.flags.common, not b.flags.common
			elseif	c_upper == "C"
			then	local num
				for n, v in pairs(Areas) do if Area.Current:lower() == v:lower() then num = n end end
				a1, b1 = not a.flags[num], not b.flags[num]
			elseif	c_upper == "A"
			then	for _, n in pairs({1, 10, 11, 12, 5, 13, 2, 3, 4, 8, 7, 14, 6, 15, 16, 9, 17, 18, 0, "common"})
				do	a1, b1 = a1..(a.flags[n] and "1" or "2"), b1..(b.flags[n] and "1" or "2")
				end
			elseif	c_upper == "D"
			then	a1, b1 = a.description, b.description
			end
			--[[
			if far.LIsUpper(c)
			then	a1, b1 = tostring(a1), tostring(b1)
			else    a1, b1 = tostring(b1), tostring(a1)
			end --]]
			a1 = tostring(a1)
			b1 = tostring(b1)
			a1, b1 = a1 == "nil" and "" or a1, b1 == "nil" and "" or b1
			f = "%-"..math.max(a1:len(), b1:len()).."s"
		--	as, bs = as..str_format(f, a1), bs..str_format(f, b1)
			tbl_as[#tbl_as + 1] = str_format(f, a1)
			tbl_bs[#tbl_bs + 1] = str_format(f, b1)
		end
		as = tbl_concat(tbl_as)
		bs = tbl_concat(tbl_bs)
		return as < bs
	end
	--
	-- сравнение 2 префиксов командной строки по: 1 - префикс; 2 - описание
	local function ComparePrefixes(a, b)
		local as, bs, a1, b1, f, c_upper = "", ""
		local tbl_as, tbl_bs = { }, { }
		for c in S.SO.P:gmatch(".")
		do	c_upper = str_upper(c)
			a1, b1 = "", ""
			if	c_upper == "P"
			then	a1, b1 = a.prefix, b.prefix
			elseif	c_upper == "D"
			then	a1, b1 = a.description, b.description
			end
			--[[
			if far.LIsUpper(c)
			then a1, b1 = tostring(a1), tostring(b1)
			else a1, b1 = tostring(b1), tostring(a1)
			end --]]
			a1 = tostring(a1)
			b1 = tostring(b1)
			a1, b1 = a1 == "nil" and "" or a1, b1 == "nil" and "" or b1
			f = "%-"..math.max(a1:len(), b1:len()).."s"
		--	as, bs = as..str_format(f, a1), bs..str_format(f, b1)
			tbl_as[#tbl_as + 1] = str_format(f, a1)
			tbl_bs[#tbl_bs + 1] = str_format(f, b1)
		end
		as = tbl_concat(tbl_as)
		bs = tbl_concat(tbl_bs)
		return as < bs
	end
	--
	-- сравнение 2 панельных модулей по: 1 - описание
	local function ComparePanels(a, b)
		local as, bs, a1, b1, f, c_upper = "", ""
		local tbl_as, tbl_bs = { }, { }
		for c in S.SO.N:gmatch(".")
		do	c_upper = str_upper(c)
			a1, b1 = "", ""
			if	c_upper == "D"
			then	a1, b1 = a.Info.Description, b.Info.Description
			elseif	c_upper == "T"
			then	a1, b1 = a.Info.Title, b.Info.Title
			elseif	c_upper == "A"
			then	a1, b1 = a.Info.Author, b.Info.Author
			end
			--[[
			if far.LIsUpper(c)
			then	a1, b1 = tostring(a1), tostring(b1)
			else	a1, b1 = tostring(b1), tostring(a1)
			end--]]
			a1 = tostring(a1)
			b1 = tostring(b1)
			a1, b1 = a1 == "nil" and "" or a1, b1 == "nil" and "" or b1
			f = "%-"..math_max(a1:len(), b1:len()).."s"
		--	as, bs = as..str_format(f, a1), bs..str_format(f, b1)
			tbl_as[#tbl_as + 1] = str_format(f, a1)
			tbl_bs[#tbl_bs + 1] = str_format(f, b1)
		end
		as = tbl_concat(tbl_as)
		bs = tbl_concat(tbl_bs)
		return as < bs
	end -- ComparePanels

/*
..
*/
		-- [[ теперь таблица индексирована числами
		-- отсортируем всё
		Area_Current_upper = str_upper(Area.Current)
		table.sort(macros,	CompareMacros)
		table.sort(keymacros,	CompareMacros)
		table.sort(events,	CompareEvents)
		table.sort(modules,	CompareModules)
		table.sort(menuitems,	CompareMenuItems)
		table.sort(prefixes,	ComparePrefixes)
		table.sort(panels,	ComparePanels) --]]
