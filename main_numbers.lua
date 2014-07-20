--- ************************************************************************************************************************************************************************
---
---				Name : 		main_numbers.lua
---				Purpose :	Simple 'collect the numbers' game.
---				Created:	18 July 2014
---				Updated:	19 July 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

display.setStatusBar(display.HiddenStatusBar)													-- hide status bar.
require("strict")																				-- install strict.lua to track globals etc.
require("utils.controller")																		-- load the controller.
require("utils.music")																			-- background music player
require("utils.sound") 																			-- sound manager.
require("utils.admob")																			-- admob class

--- ************************************************************************************************************************************************************************
--																				Score Object
--- ************************************************************************************************************************************************************************

local Score = Framework:createClass("numbers.score")

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

function Collectable:destroy()
	self:playSound("score")
	transition.to(self.m_object, { time = 1000, alpha = 0})
	transition.to(self.m_text, { time = 1000, alpha = 0,onComplete = function() self:delete() end })
end

--- ************************************************************************************************************************************************************************
--																		Player character
--- ************************************************************************************************************************************************************************

local Player = Framework:createClass("numbers.player")

function Player:constructor(info)
	self.m_x = display.contentWidth / 2 														-- start position
	self.m_y = display.contentHeight / 2 
	self.m_radius = 32 																			-- player size
	self.m_images = {}
	self.m_images[1] = display.newImage("images/teeth1.png",self.m_x,self.m_y) 					-- we cheat the animation 
	self.m_images[2] = display.newImage("images/teeth2.png",self.m_x,self.m_y)
	self.m_images[1].isVisible = false 
	self.m_images[2].isVisible = false
	self.m_controller = info.controller 														-- remember the controller
	self.m_speed = 115
	self.m_current = 1 																			-- want number 1
	self.m_last = info.last 																	-- get this one and it is game over.
end 

function Player:getDisplayObjects()
	return self.m_images  																		-- get the display objects
end 

function Player:onUpdate(deltaTime)
	local image = math.floor(system.getTimer() / 150) % 2 + 1 									-- which of 2 frames
	self.m_images[image].isVisible = true 														-- hide one, show the other
	self.m_images[3-image].isVisible = false
	image = self.m_images[image] 																-- current image
	image.width,image.height = self.m_radius*2,self.m_radius*2 									-- set it up
	image.anchorX,image.anchorY = 0.5,0.5
	local dx,dy  
	dx = self.m_controller:getX() dy = self.m_controller:getY()									-- get controller positions
	if dx < 0 then image.xScale = -1 else image.xScale = 1 end 									-- set teeth direction
	self.m_x = self.m_x + deltaTime * dx * self.m_speed 										-- work out new position
	self.m_y = self.m_y + deltaTime * dy * self.m_speed
	self.m_x = math.max(self.m_radius,math.min(display.contentWidth-self.m_radius,self.m_x)) 	-- force in range
	self.m_y = math.max(self.m_radius,math.min(display.contentHeight-self.m_radius,self.m_y))
	image.x,image.y = self.m_x,self.m_y 														-- move image
	local count,collectables = self:query("collectable")										-- get all the collectables.
	for _,ref in pairs(collectables) do 														-- scan through tme
		if ref:collides(self.m_x,self.m_y,self.m_radius) and 									-- if collision, and the correct number
												ref:getNumber() == self.m_current then 
			self.m_current = self.m_current + 1 												-- look for the next number
			ref:destroy()																		-- ask it to self destruct
			if self.m_current > self.m_last then  												-- complete ?
				self:sendMessage("timing","off") 												-- timer counter off
				self:sendMessage("backgroundmusic","stop") 										-- background music off
				self:playSound("complete") 														-- play completely original ending fanfare.
				self:addSingleTimer(10)															-- fire timer after ten seconds.
			end
			break
		end 
	end
end 

function Player:onTimer(tag)
	self.fw.owner:delete()																		-- on timer, delete the owning object.
end 

function Player:destructor()
	self.m_images[1]:removeSelf() 																-- yes, I know !
	self.m_images[2]:removeSelf()
	self.m_images = nil
	self.m_controller = nil
end 

--- ************************************************************************************************************************************************************************
--	 																	Background Object
--- ************************************************************************************************************************************************************************

local Background = Framework:createClass("numbers.background")

function Background:constructor()
	self.m_background = display.newRect(0,0,display.contentWidth,display.contentHeight)
	self.m_background.anchorX,self.m_background.anchorY = 0,0
	self.m_background:setFillColor(0,0.4,0) self.m_background.strokeWidth = 3
end 

function Background:destructor()
	self.m_background:removeSelf()
	self.m_background = nil 
end 

function Background:getDisplayObjects()
	return { self.m_background }
end 

--- ************************************************************************************************************************************************************************
--																			Main Game
--- ************************************************************************************************************************************************************************

local sc = Framework:new("game.scene"):name("owner")											-- create a scene

sc:new("audio.music"):tag("backgroundmusic") 													-- add original background tune
sc:new("audio.sound", { sounds = { "click","complete","score" } }) 								-- add sfx

sc:new("numbers.background") 																	-- background

local adIDs = { ios = "ca-app-pub-8354094658055499/9860763610", android = "ca-app-pub-8354094658055499/9860763610" }
sc:new("ads.admob",adIDs)

local cont = sc:new("io.controller.fouraxis", { radius = 40 })									-- add the controller to it.
local numberCount = 9
for i = 1,numberCount do sc:new("numbers.collectable", { number = i }) end 						-- add the collectable numbers

local score = sc:new("numbers.score"):tag("timing") 											-- add the score
score:sendMessage("timing","on")																-- start the score turning
local player = sc:new("numbers.player",{ controller = cont, last = numberCount }) 				-- create the player.

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		18-Jul-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
