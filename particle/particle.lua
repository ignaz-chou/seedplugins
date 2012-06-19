--[[
Seed ���
	particle
	�����ļ�
		particle.lua - �ṩͨ������table��plist�ļ�����UI�ķ���
	�������
		transition
		plist
		lua_ex
	����޸�����
		2012-6-15
	���¼�¼
		2012-6-15��������self:pause(),self:resume(),self:stop(),self:start()�������������ӳ�size
]]--
math.randomseed(os.time())	
local urilib = require("uri")
local r2d = require("render2d")
local plistParser = require("plist")
require("lua_ex")

local function numToBlendState(num)
	if num == 0 then return "zero"
	elseif num == 1 then return "one"
	elseif num == 770 then return "srcAlpha"
	elseif num == 772 then return "dstAlpha"
	elseif num == 771 then return "invSrcAlpha"
	elseif num == 773 then return "invDstAlpha"
	elseif num == 768 then return "srcColor"
	elseif num == 774 then return "dstColor"
	elseif num == 769 then return "invSrcColor"
	elseif num == 775 then return "invDestColor"
	else
		print("blend func id:", num, " not supported yet, setted it to GL_ONE")
		return "one"
	end
end

function __init__()
	error("Use newWithPlist/newWithData instead!")
end


--����ƽ��ֵ�Ͷ�����Χ��������ֵ�����Լӵ���ѧ����
local function calcVariance(value, variance)
	return value + (math.random() - 0.5) * variance * 2
end

local function createNodePool(emit, psd, parentNode)
	for i = 1, psd.maxParticles * 1.2 do
		if(emit.debugMode) then 
			emit.node[i] = parentNode:newNode()
			emit.node[i].presentation = function()
				r2d.drawPoint(0,0)
			end
		elseif emit.texture == nil then
			emit.node[i] = parentNode:newNode()
			emit.node[i].presentation = function()
				r2d.fillRect(-emit.imgW / 2, -emit.imgH / 2, emit.imgW / 2, emit.imgH / 2)
			end
		else
			--ʹ����image��ȡ���˿��
			emit.node[i] = parentNode:newImage(emit.texture) -- ������ȫ�����ӵ�Node
			emit.node[i]:setAnchor(0, 0)
		end
		emit.node[i]:hide()
		emit.particlesNeedActive[i] = i
		emit.node[i]:addEffect(emit.blendState) 
	end
end

--��ʼ������ϵͳ�������ԣ�������Ч�Լ�鶼���������
local function initAttr(data, emit, parentNode)
	local psd = {}
	psd = data
	
	--��Ч�Լ�飬������Ϊnil�򸳳�ֵ
	psd.maxParticles = psd.maxParticles or 3500

	psd.particleLifespan = psd.particleLifespan or 0
	psd.particleLifespanVariance = psd.particleLifespanVariance or 0

	psd.sourcePositionx = psd.sourcePositionx or 0
	psd.sourcePositiony = psd.sourcePositiony or 0
	psd.sourcePositionVariancex = psd.sourcePositionVariancex or 0
	psd.sourcePositionVariancey = psd.sourcePositionVariancey or 0

	psd.startColorRed = psd.startColorRed or 1
	psd.startColorGreen = psd.startColorGreen or 1
	psd.startColorBlue = psd.startColorBlue or 1
	psd.startColorAlpha = psd.startColorAlpha or 1
	psd.startColorVarianceRed = psd.startColorVarianceRed or 0
	psd.startColorVarianceGreen = psd.startColorVarianceGreen or 0
	psd.startColorVarianceBlue = psd.startColorVarianceBlue or 0
	psd.startColorVarianceAlpha = psd.startColorVarianceAlpha or 0

	psd.startParticleSize = psd.startParticleSize or 0 
	psd.startParticleSizeVariance = psd.startParticleSizeVariance or 1
	psd.finishParticleSize = psd.finishParticleSize or 1	
	psd.finishParticleSizeVariance = psd.finishParticleSizeVariance or 0

	psd.finishColorVarianceRed = psd.finishColorVarianceRed or 0
	psd.finishColorVarianceGreen = psd.finishColorVarianceGreen or 0
	psd.finishColorVarianceBlue = psd.finishColorVarianceBlue or 0
	psd.finishColorVarianceAlpha = psd.finishColorVarianceAlpha or 0
	
	psd.finishColorRed = psd.finishColorRed or 0
	psd.finishColorGreen = psd.finishColorGreen or 0
	psd.finishColorBlue = psd.finishColorBlue or 0
	psd.finishColorAlpha = psd.finishColorAlpha or 0
	
	psd.angle = psd.angle or 0
	psd.angleVariance = psd.angleVariance or 0
	psd.speed = psd.speed or 0
	psd.speedVariance = psd.speedVariance or 0

	psd.gravityx = psd.gravityx or 0
	psd.gravityy = psd.gravityy or 0
	
	psd.tangentialAcceleration = psd.tangentialAcceleration or 0	-- ������ٶ�
	psd.tangentialAccelVariance = psd.tangentialAccelVariance or 0	
	psd.radialAcceleration = psd.radialAcceleration or 0			-- ������ٶ�
	psd.radialAccelVariance = psd.radialAccelVariance or 0

	psd.rotationStart = psd.rotationStart or 0						-- 
	psd.rotationEnd = psd.rotationEnd or 0							-- 
	psd.rotationStartVariance = psd.rotationStartVariance or 0		-- 
	psd.rotationEndVariance = psd.rotationEndVariance or 0			-- 
	
	psd.minRadius = psd.minRadius or 0
	psd.minRadiusVariance = psd.minRadiusVariance or 0
	psd.maxRadius = psd.maxRadius or 0
	psd.maxRadiusVariance = psd.maxRadiusVariance or 0
	psd.emitterType = psd.emitterType or 0							-- ���ֱ�߷��仹�ǻ�������
	psd.rotatePerSecond = psd.rotatePerSecond or 0					-- ���ٶ�
	psd.rotatePerSecondVariance = psd.rotatePerSecondVariance or 0	-- ���ٶȶ�����Χ
	psd.omegaAcceleration = psd.omegaAcceleration or 0				-- �Ǽ��ٶ�
	psd.omegaAccelVariance = psd.omegaAccelVariance or 0			-- �Ǽ��ٶȶ�����Χ
	
	psd.textureFileName = emit.texture
	
	createNodePool(emit, psd, parentNode)							-- ���������	
	
	return psd
end


local tr = require("transition")

--�����ٶȡ�λ�á�������ٶȡ�������ٶ�
local function updateLineVA(sx,sy,vx,vy,gx,gy,ra,ta,dt)
	local rax,ray = 0, 0
	local tax,tay = 0, 0
	local angle = math.atan2 (sy, sx)
	rax, ray = math.cos(angle) * ra, math.sin(angle) * ra
	tax, tay = math.cos(angle + math.pi / 2) * ta, math.sin(angle + math.pi / 2) * ta
	vx = vx + (gx + rax + tax) * dt
	vy = vy + (gy + ray + tay) * dt
	sx = sx + vx * dt
	sy = sy + vy * dt
	return sx,sy,vx,vy
end

local function updaterotateVA(theta, omega, omegaAccel, dt)
	omega = omega + omegaAccel * dt
	theta = theta + omega * dt
	return theta, omega
end



local function createParticleWithGravity(emit,id,osx,osy,spd,angle,span,ss,es,scr,scg,scb,sca,ecr,ecg,ecb,eca,ra,ta,sspin,espin)
	--����Ԥ����
	if es == -1 then es = ss end 
	ss = ss / emit.imgW
	es = es / emit.imgW
	sspin = math.rad(sspin)
	espin = math.rad(espin)
	span = math.abs(span)

	--����������õı��ر���
	local sx,sy = 0, 0
	local vx, vy = spd * math.cos(math.rad(angle)), spd * math.sin(math.rad(angle))
	local ds,dr = es - ss, espin - sspin
	
	local dcr, dcg, dcb, dca = ecr - scr, ecg - scg, ecb - scb, eca - sca
	
	--ȷ����ʼ״̬
	emit.node[id].rotation = sspin
	emit.node[id]:show()
	emit.node[id].x, emit.node[id].y = osx, osy
	emit.node[id].scalex, emit.node[id].scaley = ss, ss
	emit.node[id]:setMaskColor(scr,scg,scb,sca)
	local r, g, b, a

	tr.start(emit.runtime, function()
		if(span > 0) then
			tr.timePeriod(span, function(t, dt)
				-- ����Ҫ��������ٶȡ̡����ٶȡ̡�������ٶȡ̡�������ٶȡ̡���ɫ�仯�̵Ĺ�ʽ

				a = sca + dca * t / span
				if a > 0.001 then			--����RGB��Ԥ��
					r = (scr + dcr * t / span) / a
					g = (scg + dcg * t / span) / a
					b = (scb + dcb * t / span) / a
				else
					r = scr + dcr * t / span
					g = scg + dcg * t / span
					b = scb + dcb * t / span
				end

				emit.node[id]:setMaskColor(r, g, b, a)
				emit.node[id]:setAlpha(sca + dca * t / span)											--color
				
				emit.node[id].rotation = sspin + dr * t / span
				emit.node[id].scalex, emit.node[id].scaley = ss + ds * t / span, ss + ds * t / span 	--scale
				sx,sy,vx,vy = updateLineVA(sx,sy,vx,vy,emit.psd.gravityx,emit.psd.gravityy,ra,ta,dt)
				emit.node[id].x, emit.node[id].y = osx + sx, osy - sy
			end)

		end
		emit.node[id]:hide()
		table.insert(emit.particlesNeedActive,id)
	end)
	
end

local function createParticleWithRotation(emit,id,osx,osy,omega,omegaAccel,fai,span,ss,es,scr,scg,scb,sca,ecr,ecg,ecb,eca,sr,er,sspin,espin)
	emit.node[id]:show()
	local sx,sy = 0, 0
	if es == -1 then es = ss end
	ss = ss / emit.imgW 
	es = es / emit.imgW
	local theta = fai + 180
	local radius = sr
	sx, sy = radius * math.cos(math.rad(theta)), radius * math.sin(math.rad(theta))
	emit.node[id].x, emit.node[id].y = osx + sx, osy - sy
	emit.node[id].scalex, emit.node[id].scaley = ss, ss
	emit.node[id]:setMaskColor(scr,scg,scb)
	emit.node[id]:setAlpha(sca)
	sspin = math.rad(sspin)
	espin = math.rad(espin)
	emit.node[id].rotation = sspin
	local ds,dr = es - ss, espin - sspin
	local dcr, dcg, dcb, dca = ecr - scr, ecg - scg, ecb - scb, eca - sca
	span = math.abs(span)
	local r, g, b, a

	tr.start(emit.runtime, function()
		if(span > 0) then
			tr.timePeriod(span, function(t, dt)
				-- ����Ҫ������н��ٶȡ���λ���뾶�仯����ɫ�仯�̵Ĺ�ʽ
				a = sca + dca * t / span
				if a > 0.001 then			--����RGB��Ԥ��
					r = (scr + dcr * t / span) / a
					g = (scg + dcg * t / span) / a
					b = (scb + dcb * t / span) / a
				else
					r = scr + dcr * t / span
					g = scg + dcg * t / span
					b = scb + dcb * t / span
				end
				emit.node[id]:setMaskColor(r, g, b, a)			--color
				emit.node[id].rotation = sspin + dr * t / span
				emit.node[id].scalex, emit.node[id].scaley = ss + ds * t / span, ss + ds * t / span --scale
				radius = sr + (er - sr) * t / span
				theta, omega = updaterotateVA(theta, omega, omegaAccel, dt)
				sx, sy = radius * math.cos(math.rad(theta)), radius * math.sin(math.rad(theta))
				emit.node[id].x, emit.node[id].y = osx + sx, osy - sy
			end)
		end
		emit.node[id]:hide()
		table.insert(emit.particlesNeedActive,id)
	end)
end

local function shootParticle(posx, posy, emit, psd)
	if psd.emitterType == 0 then
		createParticleWithGravity(
			emit,
			table.remove(emit.particlesNeedActive),
			calcVariance(posx, psd.sourcePositionVariancex),
			calcVariance(posy, psd.sourcePositionVariancey),
			calcVariance(psd.speed, psd.speedVariance),
			calcVariance(psd.angle, psd.angleVariance),
			calcVariance(psd.particleLifespan, psd.particleLifespanVariance),
			calcVariance(psd.startParticleSize, psd.startParticleSizeVariance),
			calcVariance(psd.finishParticleSize, psd.finishParticleSizeVariance),
			calcVariance(psd.startColorRed, psd.startColorVarianceRed),
			calcVariance(psd.startColorGreen, psd.startColorVarianceGreen),
			calcVariance(psd.startColorBlue, psd.startColorVarianceBlue),
			calcVariance(psd.startColorAlpha, psd.startColorVarianceAlpha),
			calcVariance(psd.finishColorRed, psd.finishColorVarianceRed),
			calcVariance(psd.finishColorGreen, psd.finishColorVarianceGreen),
			calcVariance(psd.finishColorBlue, psd.finishColorVarianceBlue),
			calcVariance(psd.finishColorAlpha, psd.finishColorVarianceAlpha),
			calcVariance(psd.radialAcceleration, psd.radialAccelVariance),
			calcVariance(psd.tangentialAcceleration, psd.tangentialAccelVariance),
			calcVariance(psd.rotationStart, psd.rotationStartVariance),
			calcVariance(psd.rotationEnd, psd.rotationEndVariance)
		)
	else
		createParticleWithRotation(
			emit,
			table.remove(emit.particlesNeedActive),
			posx,
			posy,																-- Ŀǰ���ݵı༭����֧����תʱԲ�ĵ�ƫ��
			calcVariance(psd.rotatePerSecond, psd.rotatePerSecondVariance),
			calcVariance(psd.omegaAcceleration, psd.omegaAccelVariance),		-- Ŀǰ���ݵı༭����֧�ֽǼ��ٶ�
			calcVariance(psd.angle, psd.angleVariance),							
			calcVariance(psd.particleLifespan, psd.particleLifespanVariance),	
			calcVariance(psd.startParticleSize, psd.startParticleSizeVariance),	
			calcVariance(psd.finishParticleSize, psd.finishParticleSizeVariance),	
			calcVariance(psd.startColorRed, psd.startColorVarianceRed),			
			calcVariance(psd.startColorGreen, psd.startColorVarianceGreen),		
			calcVariance(psd.startColorBlue, psd.startColorVarianceBlue),		
			calcVariance(psd.startColorAlpha, psd.startColorVarianceAlpha),		
			calcVariance(psd.finishColorRed, psd.finishColorVarianceRed),		
			calcVariance(psd.finishColorGreen, psd.finishColorVarianceGreen),	
			calcVariance(psd.finishColorBlue, psd.finishColorVarianceBlue),		
			calcVariance(psd.finishColorAlpha, psd.finishColorVarianceAlpha),	
			calcVariance(psd.maxRadius, psd.maxRadiusVariance),
			calcVariance(psd.minRadius, psd.minRadiusVariance),					-- Ŀǰ���ݵı༭����֧����ת�����뾶�Ķ���
			calcVariance(psd.rotationStart, psd.rotationStartVariance),			-- ��һ���ӵ���ת�仯
			calcVariance(psd.rotationEnd, psd.rotationEndVariance)				
		)
	end
end

--��������update����
local function update(emit, psd, t, dt) 				
	local posx, posy = emit:localToParent(emit.x, emit.y)
	local n = 0
	if t - emit.shoot_t > emit.period then
		while dt > n * emit.period and #emit.particlesNeedActive > 1 do	
			shootParticle(posx, posy, emit, psd)
			n = n + 1
		end
		emit.shoot_t = t
	end
end

function removeEmit(emit)
	emit.runtime.enterFrame:removeListener(emit.update)
	emit:remove()
end

--�������Ӵ�����self���󣬷�����������self���󣬷��������ƶ�������֪�����Ӳ�Ӱ��
local function _newParticleEmit(self, texture, data, ra )
	local runtime = ra:newAgent()

	local img = self:newImage(texture)
	img:hide()
	texW = img.width
	texH = img.height

	local emit = self:newNode()
	emit.debugMode = false
	emit.texture = texture

	emit.node = {}									--�������ӵ�node����
	emit.particlesNeedActive = {}					--��¼�����Ƿ���Ҫ������
	emit.imgW, emit.imgH = texW, texH				--����ߴ�
	data.emissionRate = math.floor(data.emissionRate or data.maxParticles / data.particleLifespan)
	emit.period = 1 / data.emissionRate				--��������
	emit.shoot_t = 0

	local eff = display.BlendStateEffect.new()
	eff.srcFactor = numToBlendState(data.blendFuncSource)
	eff.destFactor = numToBlendState(data.blendFuncDestination)
	emit.blendState = eff

	emit.psd = initAttr(data,emit,self)
	emit.update = function(t, dt) update(emit, emit.psd, t, dt) end
	
	emit.x = emit.psd.sourcePositionx
	emit.y = emit.psd.sourcePositiony
	
	emit.useGlobleGravity = false
	emit.runtime = runtime

	emit.setGravity = function(gx, gy)
		emit.psd.gravityx = gx
		emit.psd.gravityy = gy
	end

	emit.pause = function(self)
		runtime:pause()
	end

	emit.resume = function(self)
		runtime:resume()
	end

	emit.stop = function(self)
		self.period = math.huge
	end

	emit.start = function(self)
		self.period = 1 / data.emissionRate
	end

	runtime.enterFrame:addListener(emit.update)
	return emit
end

local function _newParticleEmitWithPlist(self, data, runtime, textureFileName)
	local data = plistParser.parseUri(urilib.absolute(data, 2))
	local textureFileName = textureFileName or data.textureFileName
	textureFileName = urilib.absolute(textureFileName, 2)
	return _newParticleEmit(self, textureFileName, data, runtime)
end

display.Stage2D.methods.newParticleEmit = _newParticleEmit
display.Stage2D.Node.methods.newParticleEmit = _newParticleEmit

display.Stage2D.methods.newParticleEmitWithPlist = _newParticleEmitWithPlist
display.Stage2D.Node.methods.newParticleEmitWithPlist = _newParticleEmitWithPlist