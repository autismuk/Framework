--- ************************************************************************************************************************************************************************
---
---				Name : 		buttons.lua
---				Purpose :	Various Button types - up down left right home and sound.
---				Created:	15 August 2014
---				Updated:	26 September 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

require("framework.framework")

--- ************************************************************************************************************************************************************************
--																Abstract controller base type
--- ************************************************************************************************************************************************************************

local AbstractController = Framework:createClass("control.abstract")

function AbstractController:constructor(info)
	self.m_group = display.newGroup()															-- speaker and cross in groups
	local colour = { info.r or 0,info.g or 1,info.b or 0 }
	self:draw(colour)
	if info.width == nil then  																	-- calculate size if not provided
		self.m_group.xScale =  (display.contentWidth / 12) / 40
	else 
		self.m_group.xScale = (info.width * display.contentWidth) / 100 
	end
	self.m_scale = self.m_group.xScale 															-- save scale and copy to Y
	self.m_group.yScale = self.m_group.xScale
	self.m_group.x,self.m_group.y = 10,display.contentHeight - self.m_group.height-10 			-- calculate position
	if info.x ~= nil then 
		self.m_group.x = display.contentWidth * info.x / 100 
		self.m_group.y = display.contentHeight * info.y / 100 
	end
	self.m_group.x = self.m_group.x + self.m_group.width/2 										-- centre so pulses around centre
	self.m_group.y = self.m_group.y + self.m_group.height/2
	self.m_group.rotation = info.rotation or 0 													-- rotate accordingly
	self.m_group:addEventListener("tap",self)													-- add tap listener
	self.m_owner = info.owner 																	-- remember who to send the messages to.
	self.m_name = info.name or "button" 														-- what to send
end 

--//	Tidy up

function AbstractController:destructor()
	self.m_group:removeEventListener("tap",self)												-- remove tap listener
	self.m_group:removeSelf()
	self.m_group = nil
	self.m_owner = nil
end 

--//	Get objects

function AbstractController:getDisplayObjects()
	return { self.m_group }
end 

function AbstractController:tap(e)
	print("Tap !",self.m_owner,self.m_name)
	if self.m_owner ~= nil then 																-- is something listening - it should be :)
		self:sendMessage(self.m_owner,"iconbutton", { type = self.m_name }) 					-- send it a message saying we have tapped the button.
	end
end

--- ************************************************************************************************************************************************************************
--														Arrow Button (defaults to right)
--- ************************************************************************************************************************************************************************

local RightArrowButton = Framework:createClass("control.rightarrow","control.abstract")

function RightArrowButton:draw(colour)
	local s = display.newCircle(self.m_group,40,40)
	s:setFillColor(colour[1],colour[2],colour[3])
end 

--- ************************************************************************************************************************************************************************
--										Audio Controller - speaker on/off which actually handles itself.
--- ************************************************************************************************************************************************************************

local AudioController = Framework:createClass("control.audio","control.abstract") 									

AudioController.isSoundEnabled = true 															-- set to true when audio is enabled.

function AudioController:constructor(info)
	AbstractController.constructor(self,info)
	self:setEnabled(AudioController.isSoundEnabled) 											-- status kept between instances.
end 

function AudioController:destructor()
	AbstractController.destructor(self)
	self.m_crossGroup = nil self.m_soundGroup = nil
end

function AudioController:draw(colour)
	self.m_soundGroup = display.newGroup()
	self.m_crossGroup = display.newGroup()
	self.m_group:insert(self.m_soundGroup) self.m_group:insert(self.m_crossGroup)

	display.newRect(self.m_group,0,0,50,40).alpha = 0.01

	local p = display.newPolygon(self.m_group,0,0, { -15,-10,0,-20,0,20, -15,10 })
	p.anchorX,p.anchorY = 1,0.5 p:setFillColor(colour[1],colour[2],colour[3])
	local r = display.newRect(self.m_group,-18,0,7,20)
	r.anchorX,r.anchorY = 1,0.5 r:setFillColor(colour[1],colour[2],colour[3])

	local l1 = display.newLine(self.m_crossGroup,4,-5,14,5)
	local l2 = display.newLine(self.m_crossGroup,4,5,14,-5)
	l1.strokeWidth = 3 l2.strokeWidth = 3
	l1:setStrokeColor(colour[1],colour[2],colour[3])
	l2:setStrokeColor(colour[1],colour[2],colour[3])
	self:addArc(-5,-20,29,40,110,250):setStrokeColor(colour[1],colour[2],colour[3])
	self:addArc(-5,-15,22,30,110,250):setStrokeColor(colour[1],colour[2],colour[3])
	self:addArc(-5,-10,15,20,110,250):setStrokeColor(colour[1],colour[2],colour[3])
end 

--//	Create an AudioController object (a speaker with a toggleable cross)
--//	@info 	[table]	constructor inormation 	(x,y,width)

function AudioController:addArc(x,y,w,h,s,e)
		local xc,yc,xt,yt,cos,sin = x+w/2,y+h/2,0,0,math.cos,math.sin
		s,e = s or 0, e or 360
		s,e = math.rad(s),math.rad(e)
		w,h = w/2,h/2
		local l = display.newLine(self.m_soundGroup,0,0,0,0)
		for t=s,e,0.1 do l:append(xc - w*cos(t), yc - h*sin(t)) end
		l.strokeWidth = 3
		return l
end

--//	Handle tap event
--//	@event 	[event]		event data

function AudioController:tap(event)
	self:setEnabled(not AudioController.isSoundEnabled) 										-- toggle enabled sound.
	return true 																				-- don't pass through.
end 

--//	Enable/Disable sound
--//	@soundOn 	[boolean]		new sound state

function AudioController:setEnabled(soundOn)
	--print("Audio level",soundOn)
	AudioController.isSoundEnabled = (soundOn == true)											-- copy new sound enabled value
	self.m_soundGroup.isVisible = AudioController.isSoundEnabled
	self.m_crossGroup.isVisible = not AudioController.isSoundEnabled
	--AudioController.isSoundEnabled = false

	if AudioController.isSoundEnabled then  													-- set the master volume accordingly.
		audio.setVolume(1.0)
	else 
		audio.setVolume(0.0)
	end 
end

--//	Handle update message (requires scene membership)
--//	@deltaTime 	[number] 	Elapsed time in seconds 

function AudioController:onUpdate(deltaTime)
	self.m_clock = (self.m_clock or 0) + deltaTime 												-- keep track of time
	local scale = math.sin(self.m_clock * 3) * 0.1 + 1 											-- work out the pulsing
	scale = scale * self.m_scale
	self.m_group.xScale,self.m_group.yScale = scale,scale  										-- and adjust the scale.
end 

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		15-Aug-14	0.1 		Initial version of file
		26-Sep-14 	0.2 		Generalised (became buttons.lua), audio.control became control.audio and added other buttons and 
								generalised the code.

--]]
--- ************************************************************************************************************************************************************************
