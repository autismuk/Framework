--- ************************************************************************************************************************************************************************
---
---				Name : 		main_numbers.lua
---				Purpose :	Simple 'collect the numbers' game.
---				Created:	18 July 2014
---				Updated:	18 July 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

display.setStatusBar(display.HiddenStatusBar)													-- hide status bar.
require("strict")																				-- install strict.lua to track globals etc.
--require("main_test")

require("utils.controller")																		-- load the controller.
require("utils.music")

local Score = Framework:createClass("numbers.score")

function Score:createMixinObject()
	return display.newText("xxxx",100,100,system.nativeFont,40)
end 

function Score:constructor(info) 
	self.anchorX,self.anchorY = 1,0 self.x,self.y = display.contentWidth-5,5
	self:setFillColor(1,1,0)
	self.m_elapsed = 0
	self.m_counting = false
	self:updateScore()
end 

function Score:onMessage(sender,name,body)
	self.m_counting = name:lower() == "on"
end

function Score:getDisplayObjects() 
	return { self }
end 

function Score:destructor() 
	self:removeSelf()
end 

function Score:onUpdate(deltaTime)
	if self.m_counting then 
		self.m_elapsed = self.m_elapsed + deltaTime 
		self:updateScore()
	end
end 

function Score:updateScore()
	self.text = tostring("00000"..math.floor(self.m_elapsed*10)):sub(-5)
end 


local sc = Framework:new("game.scene")															-- create a scene
local cont = sc:new("io.controller.fouraxis", { radius = 40 })									-- add the controller to it.
local score = sc:new("numbers.score"):tag("timing")
sc:new("audio.music")
sc:sendMessage("timing","on")

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		18-Jul-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
