--[[
Seed ���
	bmFnt

	�����ļ�
		bmFnt.lua - �ṩͼƬ�ֵĴ�����

	�������
		uri
		xmlParser

	����޸�����
		2012-7-2

	��������
		2012-7-2��
			�ṩǿ���ַ��ȿ��ܵ�֧��
		2012-6-14��
			1���ṩͨ�����·������lable�����֧��
			2���ṩAscii��ļ���
]]--
local xmlParser = require("xmlParser")
local uri = require("uri")

local absolute = uri.absolute
local basename = uri.basename
local splitext = uri.splitext
local splituri = uri.split
local normjoin = uri.normjoin
local joinuri = uri.join

local xmlhandler_mt = {
	__index = {
		starttag = function(self,t,a,s,e)
			if (t == "font") then
				self.pages = {}
				self.chars = {}
				self.kernings = {}
			elseif (t == "info") then
				self.info = a
			elseif (t == "common") then
				self.common = a
			elseif (t == "page") then
				table.insert(self.pages, a)
			elseif (t == "char") then
				table.insert(self.chars, a)
			elseif (t == "kerning") then
				table.insert(self.kernings, a)
			end
		end,

		endtag = function(self,t,s,e)
			
		end
	}
}

local function parseXml(s)
	local h = {}
	setmetatable(h, xmlhandler_mt)
	xmlParser.parse(h, s)
	return h
end

local function parseUri(uri)
	local f = io.open(uri, "r")
	if (not f) then
		error("Cannot open uri "..uri)
	end
	local s = f:read()
	f:close()
	return parseXml(s)
end

local function getAmount(kernings, first, second)
	if second == -1 or kernings == nil then
		return 0
	end
	for i,kerning in pairs(kernings) do 
		if first == kerning.first and second == kerning.second then
			return kerning.amount
		end
	end
	return 0
end

local function _setString(self, str, fnt, forcedSize)

	local group = self:newNode()

	group.ax, group.ay = 0, 0

	local BMStr = str or ""

	group.width, group.height = 0, 0
	local count = string.len(BMStr)
	local index = 1
	local nextFontPositionX = 0
	local nextFontPositionY = 0
	local kerningAmount
	local prev = -1

	local fntSizeW, fntSizeH = 0, 0

	if forcedSize then
		if type(forcedSize) == "boolean" then
			print("+++")
			for k, v in pairs(fnt.chars) do
				if fntSizeW < tonumber(v.xadvance) then
					fntSizeW = tonumber(v.xadvance)
				end
				if fntSizeH < tonumber(v.height) then
					fntSizeH = tonumber(v.height)
				end
			end
		else
			fntSizeW = forcedSize
			print("---")
			for k, v in pairs(fnt.chars) do
				if fntSizeH < tonumber(v.height) then
					fntSizeH = tonumber(v.height)
				end
			end
		end
	end

	while index <= count do
		local charRes = string.sub(BMStr,index,index)
		
		local charIndex
		local charInfo
		local texture
		local kerning
		
		for i,char in pairs(fnt.chars) do
			if charRes == char.letter or string.byte(charRes) == char.id then
				charIndex = i
			end
		end
		
		charInfo = fnt.chars[charIndex]
		if fnt.kernings then
			kerning = fnt.kernings[charIndex]
		end

		for i,page in pairs(fnt.pages) do
			if charInfo.page == page.id then
				--����ͼƬ�����û��ͼƬ�����Ϣ��������uriͬ����ͼƬ
				texture = (page.file and joinuri(fnt.dir, page.file)) or joinuri(fnt.dir, fnt.name..'.png')
			end
		end

		--���ǿ��ʹ�����ߴ�
		if not forcedSize then
			fntSizeW, fntSizeH = charInfo.xadvance/fnt.scale, charInfo.height/fnt.scale
		end
		
		kerningAmount = getAmount(fnt.kernings, charInfo.id, prev) or 0	
		local ss = group:newImageRect(texture, {charInfo.x, charInfo.y, charInfo.width, charInfo.height})
												
		group.width = group.width + fntSizeW
		group.height = fnt.common.lineheight/fnt.scale

		ss.x = nextFontPositionX + kerningAmount - charInfo.x/fnt.scale + charInfo.xoffset/fnt.scale
		ss.y = nextFontPositionY - charInfo.y/fnt.scale + charInfo.yoffset/fnt.scale

		ss:setAnchor(-0.5, -0.5)
		
		ss:newNode().presentation = function()
			render2d.drawCircle(0, 0, 1)
		end
		
		nextFontPositionX = nextFontPositionX + fntSizeW
		prev = charInfo.id
		index = index + 1
	end
	self.group = group
end



--[[
������Stage2D/Node:newLableWithString(string, fntUri[, forcedSize])
	
	˵����
		ͨ���ַ�����fnt�ļ�������һ��lable����

	������
		string - Ҫ�������ַ�������
		fntUri - fnt�ļ���URI
		forcedSize - ǿ�ƽ�����ת��Ϊ�ȿ�ȸ����壬������������һ����������֣���ô��ǿ�ƽ����ֵĿ��ָ��Ϊ��ֵ

	����ֵ��
		lableNode����

	��ע��
		lableNode��������������Ժͷ�����
			
			���ԣ�
				self.group - ����ͼƬ���
		
			������
				self:setPostion(x, y) - ��������λ��
				self:getSize() - ��ȡ��С
				self:setAnchor(ax, ay) - ����ê��
				self:setString(str[, forcedSize]) - ���������������ݣ�ͬʱ���������Ƿ�Ϊ�ȿ�
				self:toBaseLine() - �����ֶ�������д���ߣ�����д��ĸ�ĵױߣ�

	ʹ�����ӣ�
		fnt = stage:newLabelWithString("Emlyn", "Letter1.fnt", false)	--����label
		fnt:setPostion(sw/2, sh/2)										--����λ��
		fnt:setAnchor(0,0)												--����ê��
		local w, h = fnt:getSize()										--��ȡ��߲����浽w, h������

		fnt:setString("Susie", true)									--�����иı��ַ����Ų�������ǿ�Ƶȿ�
]]

function _labelWithString(self, str, fntUri, forcedSize, _debugMode)

	local suri, scale
	if display.resourceFilter then
		suri, scale = display.resourceFilter(fntUri)
		if suri == true then
			scale = 1
		end
	end
	

	local node = self:newNode()
	node.forcedSize = forcedSize
	node._base = true

	--uri�ľ��Ի�
	fntUri = absolute(fntUri, 2)
	--����Ŀ¼���ļ���
	local dir, name = splituri(fntUri)

	local fnt = parseUri(fntUri)
	
	fnt.dir, fnt.name = dir, name
	fnt.scale = scale

	_setString(node, str, fnt, forcedSize)
	
	function node:setPostion(dx,dy)
		self.x = dx
		self.y = dy
	end

	function node:getSize()
		return node.group.width, node.group.height
	end

	function node:setAnchor(ax, ay)
		self.ax, self.ay = ax, ay
		self.group.x = -(self.ax + 0.5) * self.group.width 
		self.group.y = -(self.ay + 0.5) * self.group.height
		_base = false
	end

	function node:toBaseLine()
		self.group.x = -(self.ax + 0.5) * self.group.width  
		self.group.y = -fnt.common.base/fnt.scale
		_base = true
	end

	function node:setString(str, _forcedSize)
		self.group:remove()
		if _forcedSize ~= nil then
			node.forcedSize = _forcedSize
		end
		_setString(node, str, fnt, node.forcedSize)
		self:setAnchor(self.ax, self.ay)
		if self._base then self:toBaseLine() end
	end

	if _debugMode then
		local _debugNode = node:newNode()
		_debugNode:setMaskColor(1, 0, 1)
		_debugNode.presentation = function()
			render2d.drawRect(node.group.x, node.group.y, node.group.x + node.group.width, node.group.y + node.group.height)
		end
	end

	node:setAnchor(0, 0)
	node:toBaseLine()
	return node
end

display.Stage2D.Node.methods.newLabelWithString = _labelWithString
display.Stage2D.methods.newLabelWithString = _labelWithString