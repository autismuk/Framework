--- ************************************************************************************************************************************************************************
---
---				Name : 		gui.lua
---				Purpose :	Simple Gui Objects
---				Created:	12 August 2014
---				Updated:	12 August 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

local IconButton = Framework:createClass("gui.icon")

function IconButton:constructor(info)
	self.m_image = display.newImage(info.image,0,0)
	self.m_image.anchorX,self.m_image.anchorY = 0.5,0.5
	self.m_image.width = (info.width or 10) * display.contentWidth/100
	self.m_image.height = (info.height or info.width or 10) * display.contentWidth / 100
	self.m_image.x,self.m_image.y = info.x * display.contentWidth/100,info.y * display.contentHeight/100
	self.m_listenerObject = info.listener 
	self.m_listenerMessage = info.message or "click"
	self.m_image:addEventListener("tap",self)
end 

function IconButton:destructor()
	self.m_image:removeEventListener("tap",self)
	self.m_image:removeSelf() self.m_image = nil self.m_listenerObject = nil
end 

function IconButton:tap(event)
	self:sendMessage(self.m_listenerObject,self.m_listenerMessage,{})
	return true
end

function IconButton:getDisplayObjects() 
	return { self.m_image }
end 

local IconButtonPulse = Framework:createClass("gui.icon.pulsing","gui.icon")

function IconButtonPulse:onUpdate(deltaTime)
	self.m_clock = (self.m_clock or 0) + deltaTime 
	local scale = math.sin(self.m_clock * 3) * 0.2 + 1
	self.m_image.xScale,self.m_image.yScale = scale,scale 
end 

local ActiveText = Framework:createClass("gui.text")

function ActiveText:constructor(info)
	self.m_text = display.newBitmapText(info.text or "?", 
										info.x * display.contentWidth / 100,
										info.y * display.contentHeight / 100,
										info.font.name,info.font.size or 64)
	if info.tint then 
		self.m_text:setTintColor(info.tint[1],info.tint[2],info.tint[3])
	end
	self.m_listener = info.listener 
	self.m_message = info.message or "click"
	self.m_text:addEventListener("tap",self)
	self.m_pulseOnClick = info.pulse
	if self.m_pulseOnClick == nil then self.m_pulseOnClick = true end
end 

function ActiveText:destructor()
	self.m_text:removeEventListener("tap",self)
	self.m_text:removeSelf()
	self.m_text = nil self.m_listener = nil
end 

function ActiveText:tap(event)
	if self.m_pulseOnClick then 
		transition.to(self.m_text,{ time = 100,xScale = 1.1,yScale = 1.1,
		onComplete = function(e) transition.to(e, { time = 100,xScale = 1,yScale = 1}) end })
	end 
end 

function ActiveText:getDisplayObjects()
	return { self.m_text }
end 

local ActiveTextRotateAbstract = Framework:createClass("gui.text.rotate.abstract","gui.text")

function ActiveTextRotateAbstract:constructor(info)
	self.m_current = 1
	self.super.constructor(self,info)
	self.m_text:setText(self:getEntry(self.m_current))
end 

function ActiveTextRotateAbstract:getEntry(n)
	if n > 3 then return nil else return "Abstract "..n end 
end

function ActiveTextRotateAbstract:tap(event)
	self.m_current = self.m_current + 1
	local newText = self:getEntry(self.m_current)
	if newText == nil then 
		self.m_current = 1
		newText = self:getEntry(1)
	end 
	self.m_text:setText(newText)
	self:updateFont(self.m_text)
	self.super.tap(self,event)
end

function ActiveTextRotateAbstract:getSelected()
	return self.m_current 
end 

function ActiveTextRotateAbstract:updateFont(textObject) end 

local ActiveTextList = Framework:createClass("gui.text.list","gui.text.rotate.abstract")

function ActiveTextList:constructor(info)
	print("Constructor")
	self.super.constructor(self,info)
end

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		12-Aug-2014	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************