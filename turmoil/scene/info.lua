--- ************************************************************************************************************************************************************************
---
---				Name : 		info.lua
---				Purpose :	Information Scene.
---				Created:	11 August 2014
---				Updated:	11 August 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

local InfoMain = Framework:createClass("scene.infoScene.main")

require("utils.particle")

local Sprites = require("images.sprites")

--//	Create the Information Screen

function InfoMain:constructor(info)
	local msg = info.message 																	-- provided message
	if msg == nil then 																			-- otherwise display level message
		msg = "Level ".. Framework.fw.status:getLevel()
	end 
	self.m_group = display.newGroup() 															-- containing group
	display.newBitmapText(self.m_group, 														-- message text
						  msg,
						  display.contentWidth/2,
						  display.contentHeight/4,
						  "grapple",72):setTintColor(1,0.5,0)

	self.m_score = {} 																			-- score digits
	for i = 1,6 do 
		self.m_score[i] = display.newBitmapText(self.m_group, 									-- create each one
										 "-",
										 display.contentWidth/2 + i * 36-125,
										 display.contentHeight/2,
										 "grapple",64):setTintColor(0,1,1)
		self.m_score[i].yScale = 1.7
	end

	if Framework.fw.status:getLives() > 0 then
		local yPos = display.contentHeight * 3 / 4 													-- lives display
		local sprite = Sprites:newImage("player")
		sprite.x,sprite.y = display.contentWidth * 0.35, yPos
		self.m_group:insert(sprite)

		display.newBitmapText(self.m_group,
							  "x "..Framework.fw.status:getLives(),
							  display.contentWidth * 0.6,yPos,
							  "grapple",64):setTintColor(0,1,0.5)
	end 

	self.m_homeIcon = display.newImage(self.m_group,"images/home.png",							-- home icon in bottom right
														display.contentWidth-40,display.contentHeight-40)
	self.m_homeIcon.width,self.m_homeIcon.height = 64,64
	self.m_homeIcon.anchorX,self.m_homeIcon.anchorY = 0.5,0.5

	self.m_requiredScore = ("000000" .. Framework.fw.status:getScore()):sub(-6) 				-- final score display
	self.m_displayedScore = "000000"															-- current display
	self.m_currentDigit = 1 																	-- current digit rolled in
	self.m_digitTime = 0 																		-- roll in timer.

	display.getCurrentStage():addEventListener("tap",self) 										-- add event listeners
	self.m_homeIcon:addEventListener("tap",self)

	self.m_emitter = Framework:new("graphics.particle",{ emitter = "stars"})					-- starfield effect
	self.m_emitter:start(display.contentWidth/2,display.contentHeight/2)
	self.m_group:insert(self.m_emitter.emitter)
	self.m_emitter.emitter:toBack()
end 

--//	Tidy up

function InfoMain:destructor() 
	display.getCurrentStage():removeEventListener("tap",self)									-- remove listeners
	self.m_homeIcon:removeEventListener("tap",self) 	
	self.m_emitter:delete()
	self.m_group:removeSelf() 																	-- remove graphics
	self.m_score = nil 																			-- null references.
	self.m_group = nil 
	self.m_homeIcon = nil
end 

function InfoMain:tap(event)
	local nextTarget = "start" 																	-- decide if start or exit event
	if event.target == self.m_homeIcon then nextTarget = "exit" end 
	self:performGameEvent(nextTarget) 															-- and run it
end 

function InfoMain:getDisplayObjects() return { self.m_group } end

function InfoMain:onUpdate(deltaTime)
	self.m_elapsed = (self.m_elapsed or 0) + deltaTime * 3 										-- make the home thing pulse.
	local scale = 1 + math.sin(self.m_elapsed) / 7
	self.m_homeIcon.xScale,self.m_homeIcon.yScale = scale,scale
	if self.m_currentDigit > 6 then return end 													-- end if displayed all digits
	self.m_digitTime = self.m_digitTime + deltaTime 											-- bump counter
	local d = self.m_currentDigit
	if self.m_digitTime > 0.15 and 																-- time up and right digit displayed
					self.m_displayedScore:sub(d,d) == self.m_requiredScore:sub(d,d) then 
		self.m_currentDigit = self.m_currentDigit + 1 											-- go to next
		self.m_digitTime = 0 																	-- reset counter
	else 
		local c = (self.m_displayedScore:sub(d,d) * 1 + 1) % 10 								-- otherwise rotate digit.
		self.m_displayedScore = self.m_displayedScore:sub(1,d-1) .. c .. self.m_displayedScore:sub(d+1)
		self.m_score[d]:setText(c.."")
	end 
end 


local InfoScene = Framework:createClass("scene.infoScene","game.sceneManager")

--//	Before opening a main scene, create it.

function InfoScene:preOpen(manager,data,resources)
	local scene = Framework:new("game.scene")
	scene:new("scene.infoScene.main",data)
	return scene
end 

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		11-Aug-2014	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************