--[[
Seed ���
	bmFnt

	�����ļ�
		bmFnt.lua - �ṩͼƬ�ֵĴ�����

	�������
		uri
		xmlParser

	����޸�����
		2012-6-14

	��������
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

local function _setString(self, str, fnt)

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
		
		kerningAmount = getAmount(fnt.kernings, charInfo.id, prev) or 0
		local ss = group:newImageRect(texture, {charInfo.x, charInfo.y, charInfo.width, charInfo.height},
													{charInfo.xoffset + nextFontPositionX + kerningAmount,
													charInfo.yoffset + nextFontPositionY,
													charInfo.width, charInfo.height})
								
		group.width = group.width + charInfo.width
		group.height = charInfo.height
		nextFontPositionX = nextFontPositionX + charInfo.xadvance + kerningAmount
		prev = charInfo.id
		index = index + 1
	end
	self.group = group
end



--[[
������Stage2D/Node:lableWithString(string, fntUri)
	
	˵����
		ͨ���ַ�����fnt�ļ�������һ��lable����

	������
		string - Ҫ�������ַ�������
		fntUri - fnt�ļ���URI

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
				self:setString(str) - ����������������
]]--

function _labelWithString(self, str, fntUri)

	local node = self:newNode()

	--uri�ľ��Ի�
	fntUri = absolute(fntUri, 2)
	--����Ŀ¼���ļ���
	local dir, name = splituri(fntUri)

	local fnt = parseUri(fntUri)

	fnt.dir, fnt.name = dir, name
	
	_setString(node, str, fnt)

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
	end
	
	function node:setString(str)
		self.group:remove()
		_setString(node, str, fnt)
		self:setAnchor(self.ax, self.ay)
	end

	node:setAnchor(0, 0)
	return node
end


display.Stage2D.Node.methods.newLabelWithString = _labelWithString
display.Stage2D.methods.newLabelWithString = _labelWithString

