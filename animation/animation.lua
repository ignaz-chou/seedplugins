require("sprite_ex")
require("seed_ex")
require("lua_ex")
local urilib = require("uri")
local plist = require("plist")

local Animation = {}

local _loaded = newWeakValueTable()

function Animation:__init__()
	error("Use newWith/newWithPlist/newWithData instead!")
end

function Animation:__init__With(sheet, set, shedata, setdata, framemap, imguri)
	self._sheet = sheet
	self._set = set
	
	self._shedata = shedata
	self._framemap = framemap
	self._imguri = imguri
end

--flags���������壺
--	0 - ����Ϊ���ŵ�ͼƬ��1 - �������ƽ���Ϊ��������
function Animation:__init__WithPlist(uri,fps,flags)
	local flags = flags or "sprite"
	uri = urilib.absolute(uri, 2)
	local org = _loaded[uri]
	if (org) then
		self:__init_With(org._sheet, org._set)
	else
		self:__init__With(plist.loadPlistSheet(uri,fps,flags))
	end
end
function Animation:__init__WithArray(uri,array)
	uri = urilib.absolute(uri, 2)
	local org = _loaded[uri]
	if (org) then
		self:__init_With(org._sheet, org._set)
	else
		self:__init__With(plist.loadPlistSheet(uri,array))
	end
end

function Animation:WithDirections(dt)
	self._dt = dt
	return self
end

define_type("Animation", Animation)

local pss = display.presentations
pss.newSpriteWith = function(rt, ani, action)
	local ret = nil
	if (ani.type == Animation.type) then
		if (ani._dt) then
			ret = pss.newDSprite(rt, ani._sheet, ani._set, ani._dt, action)
		else
			ret = pss.newSprite(rt, ani._sheet, ani._set, action)
		end

		function ret:getSize()
			local id = ani._framemap[ret:getAction()]
			assert(id)
			local w, h = ani._sheet.data[id][10], ani._sheet.data[id][9] 
			return w, h
		end
	end
	return ret
end

--[[
	ʹ��newSpriteWith�����Ķ��󣬿���ʹ��node:getSize()������õ�ǰ�����Ŀ�͸�
]]--

--[[
--����newImageRectWithAni�ѹ�ʱ
--��ʹ�����·�������֮��
local sheet_set = Animation:newWithPlist(uri, fps, 0)
--���������������壺0 - ����Ϊ���ŵ�ͼƬ��1 - �������ƽ���Ϊ��������
--��Ϊ0ʱ���൱��newImageRectWithAni
node = self:newSpriteWith(runtime, sheet_set, action)
]]--

local unpack = table.unpack
pss.newImageRectWithAni = function(self, name)
	local id = self._framemap[name]
	assert(id)
	local r = self._shedata[id]
	assert(r)
	local sx, sy, sr, sb = unpack(r, 1, 4)
	local dx, dy, dr, db = unpack(r, 5, 8)
	local ret = pss.newImageRect(self._imguri, 
			{sx, sy, sr-sx, sb-sy},
			{dx, dy, dr-dx, db-dy}
		)
	local w,h =  dr-dx, db-dy
	
	function ret:getSize()
		return w,h
	end
	return ret
end
