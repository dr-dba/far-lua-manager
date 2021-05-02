/*
...
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
...
*/


	local tbl_areas_upper = {
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
	local function ShortArea(area, in_upper)
	--	local a  = ""
	--	local au = " "..str_upper(area).." "
		-- Should be already in upper case:
		local au = " "..(in_upper and area or str_upper(area)).." "
		local tbl_a = { }
		for _, sl in ipairs(tbl_areas_upper) 
		do--	a = a..(au:find(sl.l) and sl.s or "·") 
			tbl_a[#tbl_a + 1] = str_find(au, sl.l) and sl.s or "·" 
		end
	--	return a
		return tbl_concat(tbl_a)
	end

	local tbl_evt_groups_upper = {
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
		for _, sl in ipairs(tbl_evt_groups_upper)
		do--	g = g..(gu:find(sl.l) and sl.s or " · ") 
			tbl_g[#tbl_g + 1] = str_find(gu, sl.l) and sl.s or " · "
		end
	--	return g
		return tbl_concat(tbl_g)
	end

	local Area_Current_upper = str_upper(Area.Current)
	local Area_Current_lower = str_lower(Area.Current)
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
		--	a1, b1 = "", ""
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
			then	a1 = ShortArea(a_area_upper, true)
				b1 = ShortArea(b_area_upper, true)
			elseif	c_upper == "K"
			then	a1 = str_upper(a.key)
				b1 = str_upper(b.key)
			elseif	c_upper == "F"
			then	a1 = a.filemask or ""
				b1 = b.filemask or ""
			elseif	c_upper == "D"
			then	a1 = a.description
				b1 = b.description
			else	a1, b1 = "", ""
			end
			--[[
			if	far_LIsUpper(c)
			then	a1 = tostring(a1)
				b1 = tostring(b1)
			else	a1 = tostring(b1)
				b1 = tostring(a1)
			end --]]
		--	a1, b1 = a1 == "nil" and "" or a1, b1 == "nil" and "" or b1
			a1 = a1 == nil and "" or tostring(a1)
			b1 = b1 == nil and "" or tostring(b1)
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
			if	c_upper == "G"
			then	a1 = ShortGroup(a.group)
				b1 = ShortGroup(b.group)
			elseif	c_upper == "F"
			then	a1, b1 = a.filemask or "", b.filemask or ""
			elseif	c_upper == "D"
			then	a1, b1 = a.description, b.description
			else	a1, b1 = "", ""
			end
			--[[
			if	far_LIsUpper(c)
			then	a1, b1 = tostring(a1), tostring(b1)
			else    a1, b1 = tostring(b1), tostring(a1)
			end --]]
		--	a1, b1 = a1 == "nil" and "" or a1, b1 == "nil" and "" or b1
			a1 = a1 == nil and "" or tostring(a1)
			b1 = b1 == nil and "" or tostring(b1)
			f = "%-"..math_max(str_len(a1), str_len(b1)).."s"
		--	as, bs = as..f:format(a1), bs..f:format(b1)
			tbl_as[#tbl_as + 1] = str_format(f, a1)
			tbl_bs[#tbl_bs + 1] = str_format(f, b1)
		end
		as = tbl_concat(tbl_as)
		bs = tbl_concat(tbl_bs)
		return as < bs
	end -- CompareEvents
	--
	-- сравнение 2 модулей по: 1 - тип; 2 - маска поиска; 3 - имя
	local function CompareModules(a, b)
		local as, bs, a1, b1, f, c_upper = "", ""
		local tbl_as, tbl_bs = { }, { }
		for c in str_gmatch(S.SO.O, ".")
		do	c_upper = str_upper(c)
		--	a1, b1 = "", ""
			if	c_upper == "T"
			then	a1, b1 = a.type, b.type
			elseif	c_upper == "M"
			then	a1, b1 = a.mask, b.mask
			elseif	c_upper == "N"
			then    a1, b1 = a.name, b.name
			else	a1, b1 = "", ""
			end
			--[[
			if far.LIsUpper(c)
			then	a1, b1 = tostring(a1), tostring(b1)
			else	a1, b1 = tostring(b1), tostring(a1)
			end --]]
		--	a1, b1 = a1 == "nil" and "" or a1, b1 == "nil" and "" or b1
			a1 = a1 == nil and "" or tostring(a1)
			b1 = b1 == nil and "" or tostring(b1)
			f = "%-"..math_max(str_len(a1), str_len(b1)).."s"
		--	as, bs = as..str_format(f, a1), bs..str_format(f, b1)
			tbl_as[#tbl_as + 1] = str_format(f, a1)
			tbl_bs[#tbl_bs + 1] = str_format(f, b1)
		end
		as = tbl_concat(tbl_as)
		bs = tbl_concat(tbl_bs)
		return as < bs
	end -- CompareModules

	local tbl_menu_areas = { "plugins", "disks", "config" }
	--
	-- сравнение 2 пунктов меню плагинов по: использующие меню, область, "COMMON"?, текущая?, описание
	local function CompareMenuItems(a, b)
		local as, bs, a1, b1, f = "", ""
		local tbl_as, tbl_bs = { }, { }
		local tbl_a1, tbl_b1, c_upper, area_num
		local a_flags, b_flags= a.flags, b.flags
		for c in str_gmatch(S.SO.I, ".")
		do	c_upper = str_upper(c)
		--	a1, b1 = "", ""
			if	c_upper == "M"
			then	tbl_a1, tbl_b1 = { }, { }
				for _, m in pairs(tbl_menu_areas)
				do--	a1, b1 = a1..(a_flags[m] and "1" or "2"), b1..(b_flags[m] and "1" or "2")
					tbl_a1[#tbl_a1 + 1] = a_flags[m] and "1" or "2"
					tbl_b1[#tbl_b1 + 1] = b_flags[m] and "1" or "2"
				end
				a1 = tbl_concat(tbl_a1)
				b1 = tbl_concat(tbl_b1)
			elseif	c_upper == "O"
			then	a1, b1 = not a_flags.common, not b_flags.common
			elseif	c_upper == "C"
			then	area_num = nil
			--	for n, v in pairs(Areas) do if Area.Current:lower() == v:lower() then num = n end end
				for n, v in pairs(Areas_lower) do if Area_Current_lower == v then area_num = n; break end end
				a1, b1 = not a_flags[area_num], not b_flags[area_num]
			elseif	c_upper == "A"
			then	tbl_a1, tbl_b1 = { }, { }
				for _, n in pairs(Areas_index)
				do--	a1, b1 = a1..(a_flags[n] and "1" or "2"), b1..(b_flags[n] and "1" or "2")
					tbl_a1[#tbl_a1 + 1] = a_flags[n] and "1" or "2"
					tbl_b1[#tbl_b1 + 1] = b_flags[n] and "1" or "2"
				end
				a1 = tbl_concat(tbl_a1)
				b1 = tbl_concat(tbl_b1)
			elseif	c_upper == "D"
			then	a1, b1 = a.description, b.description
			else	a1, b1 = "", ""			
			end
			--[[
			if far.LIsUpper(c)
			then	a1, b1 = tostring(a1), tostring(b1)
			else    a1, b1 = tostring(b1), tostring(a1)
			end --]]
		--	a1, b1 = a1 == "nil" and "" or a1, b1 == "nil" and "" or b1
			a1 = a1 == nil and "" or tostring(a1)
			b1 = b1 == nil and "" or tostring(b1)
			f = "%-"..math_max(str_len(a1), str_len(b1)).."s"
		--	as, bs = as..str_format(f, a1), bs..str_format(f, b1)
			tbl_as[#tbl_as + 1] = str_format(f, a1)
			tbl_bs[#tbl_bs + 1] = str_format(f, b1)
		end
		as = tbl_concat(tbl_as)
		bs = tbl_concat(tbl_bs)
		return as < bs
	end -- CompareMenuItems
	--
	-- сравнение 2 префиксов командной строки по: 1 - префикс; 2 - описание
	local function ComparePrefixes(a, b)
		local as, bs, a1, b1, f, c_upper = "", ""
		local tbl_as, tbl_bs = { }, { }
		for c in str_gmatch(S.SO.P, ".")
		do	c_upper = str_upper(c)
		--	a1, b1 = "", ""
			if	c_upper == "P"
			then	a1, b1 = a.prefix, b.prefix
			elseif	c_upper == "D"
			then	a1, b1 = a.description, b.description
			else	a1, b1 = "", ""
			end
			--[[
			if far.LIsUpper(c)
			then a1, b1 = tostring(a1), tostring(b1)
			else a1, b1 = tostring(b1), tostring(a1)
			end --]]
		--	a1, b1 = a1 == "nil" and "" or a1, b1 == "nil" and "" or b1
			a1 = a1 == nil and "" or tostring(a1)
			b1 = b1 == nil and "" or tostring(b1)
			f = "%-"..math_max(str_len(a1), str_len(b1)).."s"
		--	as, bs = as..str_format(f, a1), bs..str_format(f, b1)
			tbl_as[#tbl_as + 1] = str_format(f, a1)
			tbl_bs[#tbl_bs + 1] = str_format(f, b1)
		end
		as = tbl_concat(tbl_as)
		bs = tbl_concat(tbl_bs)
		return as < bs
	end -- ComparePrefixes
	--
	-- сравнение 2 панельных модулей по: 1 - описание
	local function ComparePanels(a, b)
		local as, bs, a1, b1, f, c_upper = "", ""
		local tbl_as, tbl_bs = { }, { }
		local a_info, b_info = a.Info, b.Info
		for c in str_gmatch(S.SO.N, ".")
		do	c_upper = str_upper(c)
		--	a1, b1 = "", ""
			if	c_upper == "D"
			then	a1, b1 = a_info.Description,	b_info.Description
			elseif	c_upper == "T"
			then	a1, b1 = a_info.Title,		b_info.Title
			elseif	c_upper == "A"
			then	a1, b1 = a_info.Author,		b_info.Author
			else	a1, b1 = "", ""
			end
			--[[
			if far.LIsUpper(c)
			then	a1, b1 = tostring(a1), tostring(b1)
			else	a1, b1 = tostring(b1), tostring(a1)
			end--]]
		--	a1, b1 = a1 == "nil" and "" or a1, b1 == "nil" and "" or b1
			a1 = a1 == nil and "" or tostring(a1)
			b1 = b1 == nil and "" or tostring(b1)
			f = "%-"..math_max(str_len(a1), str_len(b1)).."s"
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
