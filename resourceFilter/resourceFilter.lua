require("lua_ex")
local uri = require("uri")

-- ���ģ�multi-filter����
local filters = {}

-- ���Թ�����Դ������һ����Դ�����б�
local function filter(uri)
	local list = { {uri, 1} }
	
	for i,v in ipairs(filters) do
		list = v(list)
	end
	return list
end

local function mainFilter(uri)
	-- @��ͷ����Ϊ����·������"@res://config.lua"
	if (uri:sub(1,1)=='@') then
		return uri:sub(2), true
	end

	print(uri, '\n', require("stringize")(filter(uri)))
	for i,v in ipairs(filter(uri)) do
		local uri, scale = table.unpack(v)
		if (os.exists('@'..uri)) then
			print(uri, scale)
			return uri, scale
		end
	end
end

display.setResourceFilter(mainFilter)
local orgsetResourceFilter = display.setResourceFilter
display.setResourceFilter = function(...)
	print("warning: don't manually setResourceFilter. use resourceFilter.addFilter/removeFilter instead!")
	print(debug.traceback())

	return orgsetResourceFilter(...)
end

local function replaceFilter(func, oldfunc)
	local id = oldfunc and table.find(filters, oldfunc)
	if (id) then
		if (func) then
			filters[id] = func
		else
			table.remove(filters, id)
		end
	else
		table.insert(filters, func)
	end
	return func
end

local function addFilter(func)
	return replaceFilter(func, nil)
end
local function removeFilter(func)
	return replaceFilter(nil, func)
end

-- scale filter
local scaleFilter
local function removeScaleFilter(i)
	scaleFilter = removeFilter(scaleFilter)
end

--[[
����map��display.setResourceFilter�ı��������
{
	["_x3.5"] = 3.5,
	["@2"] = 2,
}
����ָ��Ĭ�ϵķŴ�����
{
	[""] = 2,
	["@1"] = 1,
}
]]
local function setContentScaleSuffixFilter(map)
	map[""] = map[""] or 1
	
	local sorts = {}
	for k,v in pairs(map) do
		table.insert(sorts, {k,v})
	end
	
	-- ����ӽ�content scale��˳������
	local lastScale
	local function sortMap()
		local scale = display.getContentScale()
		if (scale ~= lastScale) then
			-- scale�ı䣬��������
			table.sort(sorts, function(a, b)
				return math.abs(a[2]-scale)<math.abs(b[2]-scale)
			end)
		end
	end
	
	scaleFilter = replaceFilter(function (list)
		sortMap()
		
		local ret = {}
		for j,ud in ipairs(list) do
			local u, oldscale = table.unpack(ud)
			local b, ext = uri.splitext(u)
			
			for i,v in ipairs(sorts) do
				local suffix, scale = table.unpack(v)
				table.insert(ret, {b..suffix..ext, oldscale * scale})
			end
		end
		return ret
	end, scaleFilter)
end


--locale filter
local localeFilter
local function removeLocaleFilter()
	localeFilter = removeFilter(localeFilter)
end

local function setLocaleSubdirFilter()
	localeFilter = replaceFilter(function(list)
		local locale = os.getLocale()
		local ret = {}
		for j,ud in ipairs(list) do
			local u, scale = table.unpack(ud)
			local base, name = uri.split(u)
			table.insert(ret, {uri.join(base, locale, name), scale})
			table.insert(ret, ud)
		end
		return ret
	end, localeFilter)
end

return {
	addFilter = addFilter,
	replaceFilter = replaceFilter,
	removeFilter = removeFilter,
	filter = filter,
	filters = filters,
	
	removeScaleFilter = removeScaleFilter,
	setContentScaleSuffixFilter = setContentScaleSuffixFilter,
	
	removeLocaleFilter = removeLocaleFilter,
	setLocaleSubdirFilter = setLocaleSubdirFilter,
}
