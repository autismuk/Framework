--- ************************************************************************************************************************************************************************
---
---				Name : 		main.lua
---				Purpose :	Testing code for game.manager and associated classes.
---				Created:	22 July 2014
---				Updated:	24 July 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

--- ************************************************************************************************************************************************************************
--												Display Object - it is  a framed background with moving text in it.
--- ************************************************************************************************************************************************************************

local DisplayObject = Framework:createClass("test.display")

function DisplayObject:constructor(info)
	self.m_background = display.newRect(0,0,display.contentWidth,display.contentHeight)
	self.m_background.anchorX,self.m_background.anchorY = 0,0
	self.m_background:setFillColor(info.br or 0,info.bg or 0,info.bb or 0)
	self.m_background.strokeWidth = 20 self.m_background:setStrokeColor(0,1,1)
	self.m_text = display.newText("Scene "..(info.name or "?"),display.contentWidth/2,display.contentHeight/2,system.nativeFont,64)
	self.m_text:setFillColor(1,1,0)
	self.m_rate = info.rate or 300
	self.m_background:addEventListener("tap",self)
end 

function DisplayObject:tap(e)
	self:performGameEvent("change")
end 

function DisplayObject:destructor()
	self.m_background:removeEventListener("tap",self)
	self.m_background:removeSelf()
	self.m_text:removeSelf()
end 

function DisplayObject:getDisplayObjects()
	return { self.m_background,self.m_text }
end 

function DisplayObject:onUpdate(deltaTime)
	self.time = (self.time or 0) + deltaTime
	self.m_text.y = math.abs(200 - math.floor(self.time * self.m_rate) % 400)+60 
end 

--- ************************************************************************************************************************************************************************
--							A simple scene class that just adds a test object, using the constructor to produce 'different' scenes.
--- ************************************************************************************************************************************************************************

local SCManager = Framework:createClass("test.sceneManager","game.sceneManager")

function SCManager:preOpen(manager,data,resources)
	local scene = Framework:new("game.scene")
	scene:new("test.display",data)
	return scene
end 

--- ************************************************************************************************************************************************************************
--																	Set up and go
--- ************************************************************************************************************************************************************************

local scm1 = Framework:new("test.sceneManager",{ br = 1,name = "One", rate = 200 })
local scm2 = Framework:new("test.sceneManager",{ bb = 1,name = "Two", rate = 400 })

local manager = Framework:new("game.manager")
manager:addManagedState("start",scm1,{ same = "start", 
									   change = { target = "state2", transitionType = "zoomOutInRotate" }})
manager:addManagedState("state2",scm2, { change = { target = "start", transitionType = "slideLeft"}})
manager:start()   

--timer.performWithDelay(1000,function() manager:performGameEvent("change", { someData = 142 }) end)
--timer.performWithDelay(6000,function() manager:performGameEvent("change", { someData = 42 }) end)

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		22-Jul-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
