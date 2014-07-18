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
require("utils.music")																			-- background music player
require("utils.sound") 																			-- sound manager.

local Score = Framework:createClass("numbers.score")

--- ************************************************************************************************************************************************************************
--																				Score Object
--- ************************************************************************************************************************************************************************

function Score:createMixinObject()
	return display.newText("xxxx",100,100,system.nativeFont,40) 								-- demonstrates a mixin object
end 

function Score:constructor(info) 
	self.anchorX,self.anchorY = 1,0 self.x,self.y = display.contentWidth-5,5 					-- position and colour
	self:setFillColor(1,1,0)
	self.m_elapsed = 0 																			-- elapsed time in seconds
	self.m_counting = false 																	-- true if counting
	self:updateScore()																			-- refresh score
end 

function Score:onMessage(sender,name,body)
	self.m_counting = name:lower() == "on" 														-- turn timer/counter on/off
end

function Score:getDisplayObjects() 
	return { self } 																			-- display objects herein
end 

function Score:destructor() 
	self:removeSelf()
end 

function Score:onUpdate(deltaTime)
	if self.m_counting then  																	-- add elapsed time if counter
		self.m_elapsed = self.m_elapsed + deltaTime 
		self:updateScore()
	end
end 

function Score:updateScore()
	self.text = tostring("00000"..math.floor(self.m_elapsed*10)):sub(-5) 						-- refresh score
end 

--- ************************************************************************************************************************************************************************
--																			Collectable object
--- ************************************************************************************************************************************************************************

local Collectable = Framework:createClass("numbers.collectable")

function Collectable:constructor(info)
	self.m_radius = info.radius or 24 															-- default values 
	self.m_number = info.number or 0
	local checkCount = 1000 																	-- stop it doing it forever.
	repeat 
		self.m_x = math.random(self.m_radius, display.contentWidth - self.m_radius) 			-- new position
		self.m_y = math.random(self.m_radius, display.contentHeight - self.m_radius) 
		local isOk = true 
		local count,objects = self:query("collectable") 										-- get list of collectables, doesn't include this one.
		for _,ref in pairs(objects) do 
			if ref:collides(self.m_x,self.m_y,self.m_radius) then isOk = false end 				-- if collides with it, then reject it
		end 
		checkCount = checkCount - 1
	until isOk or checkCount == 0 																-- until noncolliding or give up

	self.m_object = display.newCircle(self.m_x,self.m_y,self.m_radius)							-- create a collectable.
	self.m_object:setFillColor(1,0,0) self.m_object.strokeWidth = 2 self.m_object:setStrokeColor(0,1,1)
	self.m_text = display.newText(self.m_number,self.m_x,self.m_y,system.nativeFont,self.m_radius*1.2)
	self.m_text:setFillColor(1,1,0)
	self:tag("collectable") 																	-- and tag it.
end 

function Collectable:getDisplayObjects() 
	return { self.m_object,self.m_text } 														-- display objects herein.
end 

function Collectable:destructor()
	self.m_object:removeSelf() 																	-- tidy up
	self.m_text:removeSelf()
	self.m_text = nil
	self.m_object = nil
end 

function Collectable:collides(x,y,collisionRadius)
	x = math.abs(x - self.m_x) y = math.abs(y - self.m_y) 										-- calculate dx,dy
	local dist = math.sqrt(x * x + y * y) 														-- calculate distance
	return dist < collisionRadius + self.m_radius 												-- collide if < sum of radii
end 

function Collectable:getNumber()
	return self.m_number 
end 

--- ************************************************************************************************************************************************************************
--- ************************************************************************************************************************************************************************

local sc = Framework:new("game.scene")															-- create a scene

sc:new("audio.music")
sc:new("audio.sound", { sounds = { "click","complete","score" } })

local cont = sc:new("io.controller.fouraxis", { radius = 40 })									-- add the controller to it.
for i = 1,9 do sc:new("numbers.collectable", { number = i }) end

local score = sc:new("numbers.score"):tag("timing")

--sc:delete()
--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		18-Jul-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
