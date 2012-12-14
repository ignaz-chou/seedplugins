--[[
Seed ���
	ui_menu

	�����ļ�
		ui_menu.lua - �ṩ������ť�ķ���

	�������
		animation

	����޸�����
		2012-8-6

	��������
		2012-8-6���ڹ����ק����ť�ķ�Χ֮����ɿ���갴������ָ����Ļ���ƿ�ʱ�����ᴥ����ť�¼�������ť����enabledΪfalseʱ���������Ҳ��������ť�¼���
					��ע�⣺���θ�������input_exͬ�����¡�
		2012-7-13�������˰�ť��stateAuto��setEnabled����
		2012-6-15��������state���ԣ�������ȡ��ǰ��ť��״̬

		2012-6-14��������һϵ�е����Ժͷ���������menuItem�����������ʹ��

		2012-6-8��������ʹ��imageRect������menuItem��setDestRect����
				������ʹ��imageRect������menuItem������״̬��presentation��ʹ��node.pssNormal_, pssSelected_, pssDisabled_ ����ȡ

		2012-6-4�����ӵ���������ֵ�����õ���ͼƬ��Դ�б�
]]--
require("animation")
local selectors = {}

local function _newMenu(self, x, y)
	local posx, posy = x or 0, y or 0
	local node
	node = self:newNode()
	node.x, node.y = posx, posy
	return node
end

display.Stage2D.methods.newMenu = _newMenu
display.Stage2D.Node.methods.newMenu = _newMenu

--[[
������stage:newMenuItemImage(plist, args, input_ex, anchorx, anchory, enabled)

	˵����
		����һ����̬��ť������ť��Ч����Ч�ͱ�����ʱ�������ֲ�ͬ��״̬

	������
		plist - ��Դͼ����plist�ļ������û�У���nil��������ʹ�����ŵ�����pngͼƬ������̬��ť
		args - args��һ��table�����plistΪnil��{ {��ͨ״̬��ť��ͼƬuri, ��, ��}, {ѡ��״̬��ť��ͼƬuri, ��, ��}, {��Ч״̬��ť��ͼƬuri, ��, ��} }
				����args������Ϊ { {��ͨ״̬��ť��ͼƬ��plist�е�����}, {ѡ��״̬��ť��ͼƬ��plist�е�����}, {��Ч״̬��ť��ͼƬ��plist�е�����} }
		input_ex - input_ex����
		anchorx - ê��x
		anchory - ê��y
		enabled - �Ƿ�����

	����ֵ��Stage2D.Node����

	��Stage2D.NodeĬ���ṩ�ķ����⣬��node���������·�����
		self:setNormal()
		self:setDisabled()
		self:setSelected()
		self:setEnabled(enabled) ������true - enable, false - disable
		self:autoState(isAuto) ������true - �Զ�������֮��ͼƬ�ı仯��false - ���°�ť��̧��֮��Ĭ��ͼƬû�б仯

	���ԣ�
		self.event ʹ��input_ex������event�����Ը�������onTouchUp,onTouchDown���¼�
		self.enabled  �����Ƿ���Ч
		self.state	������ǰ��״̬
		self.pssNormal_		��ͨ״̬�µ�presentation
		self.pssSelected_	ѡ��״̬�µ�presentation
		self.pssDisabled_	��Ч״̬�µ�presentation
]]--

--����һ���û������û����°���֮��
local function _newMenuItemImage(self, plist, args, input_ex, anchorx, anchory, enabled)
	local node
	
	local normal = {}
	local selected = {}
	local disabled = {}

	local imguri = {}
	

	if type(args) == "table" then
		normal = args[1]
		selected = args[2] or args[1]
		disabled = args[3] or args[1]
	end

	if plist == nil then
		node = self:newNode()
		node.pssNormal_ = display.presentations.newImageRect(normal[1], normal[2], normal[3])
		node.pssSelected_ = display.presentations.newImageRect(disabled[1], disabled[2], disabled[3])
		node.pssDisabled_ = display.presentations.newImageRect(selected[1], selected[2], selected[3])
		node.presentation = node.pssNormal_
		node.state = "normal"
		node.setNormal = function(self) self.presentation = self.pssNormal_; node.state = "normal" end
		node.setDisabled = function(self) self.presentation = self.pssSelected_; node.state = "disabled" end
		node.setSelected = function(self) self.presentation = self.pssDisabled_; node.state = "selected" end
		imguri[1] = normal[1]
		imguri[2] = disabled[1]
		imguri[3] = selected[1]
		--ʹ������Ŀ�ľ��εķ�ʽʵ�ַ�ת
		node.setDestRect = function(self, l, t, w, h)
			self.pssNormal_:setDestRect(l, t, w, h)
			self.pssSelected_:setDestRect(l, t, w, h)
			self.pssDisabled_:setDestRect(l, t, w, h)
		end
	else
		local data = Animation.newWithPlist(plist, 1, 0)
		node = self:newSpriteWith(self.stage.runtime, data, normal[1])
		node.state = "normal"
		node.setNormal = function(self) self:changeAction(normal[1]); node.state = "normal" end
		node.setDisabled = function(self) self:changeAction(disabled[1]); node.state = "disabled" end
		node.setSelected = function(self) self:changeAction(selected[1]); node.state = "selected" end
		imguri[1] = data._imguri
		imguri[2] = data._imguri
		imguri[3] = data._imguri
	end
	node.auto = true
	node.ax, node.ay = anchorx, anchory
	node:setAnchor(node.ax, node.ay)
	node.enabled = enabled or true
	local input_node
	if type(normal[2]) == "table" then
		input_node = input_ex:addSpriteRect(node, normal[2][#normal[2] - 1], normal[2][#normal[2]], anchorx, anchory)
	else
		input_node = input_ex:addSpriteRect(node, normal[2] or 64, normal[3] or 64, anchorx, anchory)
	end
	ev = event.Dispatcher.new()
	--input_node.dragable = true
	
	input_node.onTouchDown:addListener(function()
		if node.auto and node.enabled then node:setSelected() end
		node:setAnchor(node.ax, node.ay)
	end)

	input_node.onTouchUp:addListener(function(e, args)
		if node.auto and node.enabled then node:setNormal() end
		node:setAnchor(node.ax, node.ay)
		if node.enabled and ev and input_node:testHit(args.x, args.y) then
			ev(e, args)
		end
	end)

--	input_node.onTouchUp:addListener(ev)

	node.autoState = function(self, value)
		self.auto = value

	end

	node.setEnabled = function(self, value)
		if value then
			self:setNormal()
		else
			self:setDisabled()
		end
		self.enabled = value
		self:setAnchor(self.ax, self.ay)
	end

	node.event = input_node

	return node, ev, imguri
end

display.Stage2D.Node.methods.newMenuItemImage = _newMenuItemImage
display.Stage2D.methods.newMenuItemImage = _newMenuItemImage