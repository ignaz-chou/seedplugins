--[[
seed�����
	director
	˵����
		�������ƶ������֮����л�
	ע�⣺��Ȼ��doscript�÷����񣬵�director���ͷŵ�֮ǰ��runtime�����´���runtime�������֮ǰ��stage
]]--
module(..., package.seeall)

local runtime = require("runtime")

local current = nil
local currt = nil

leavingModule = event.Dispatcher.new()
enterModule = event.Dispatcher.new()

--[[
������director.load(module [, ...])

	������
		module - Ҫ�����module,һ����������.lua�ű��ļ�
			���Ҫ����"sample\sample_1\main.lua"����ô��һ������Ҫ��д��"sample.sample_1.main"
		... - ����ѡ��������Ҫ����Ľű��ļ���ʹ�� ... ����ȡruntime�Լ��������
	
	����ֵ��
		�����module�ᱻ����һ����������

	�÷�ʾ����
		=============================================================
		
		--�ļ���main.lua
			local a, b = 12, 24
			local ret = director.load("sample.sample_1.main", a, b)
			print(ret)						--���Ϊ��36

		=============================================================
		
		--�ļ���sample\sample_1\main.lua
			local runtime, a, b = ...		--runtimeΪdirector������
			print(a, b)						--���Ϊ��12 24
			return a + b
		
		=============================================================

]]--
function load(module, ...)
	if (currt) then
		leavingModule(current, currt)
		currt:remove()
	end
	
	display:clearStages()
	
	local m = module
	if (type(m) == 'string') then
		m = loadscript(m)
	end
	
	local rt = runtime:newAgent()
	local ret = m(rt, ...)
	
	current = ret
	currt = rt
	enterModule(ret, rt)
	return ret
end
