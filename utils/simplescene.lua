--- ************************************************************************************************************************************************************************
---
---				Name : 		simplescene.lua
---				Purpose :	Skeleton for very simple pages - title page and so on.
---				Updated:	30 September 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

--- ************************************************************************************************************************************************************************
--//	This class physically builds the scene using the constructor function passed in 'info'
--- ************************************************************************************************************************************************************************

local SimpleSceneConstructor = Framework:createClass("scene.simple.constructor")

function SimpleSceneConstructor:constructor(info)
	self.m_group = display.newGroup()												-- create group for new gfx
	self.m_info = info 																-- preserve info
	self.m_storage = {} 															-- storage for simple scene if required
	info.constructor(self.m_storage,self.m_group,info.scene,info.manager) 			-- call the constructor
	self.m_group.xScale = display.contentWidth / self.m_group.width 				-- make it fit on the full screen
	self.m_group.yScale = display.contentHeight / self.m_group.height
end 

function SimpleSceneConstructor:destructor()
	if self.m_info.destructor ~= nil then 											-- if destructor exists, call it.
		self.m_info.destructor(self.m_storage,self.m_group,self.m_info.scene,self.m_info.manager)
	end
	self.m_group:removeSelf()														-- destroy and make vanish.
	self.m_group = nil self.m_info = nil self.m_storage = nil 						-- null everything out.
end

function SimpleSceneConstructor:getDisplayObjects()
	return { self.m_group }
end 

--- ************************************************************************************************************************************************************************
--//	This class constructs the scene , i.e. it's the scene manager
--- ************************************************************************************************************************************************************************

local SimpleSceneManager = Framework:createClass("scene.simple","game.sceneManager")

function SimpleSceneManager:preOpen(manager,data,resources)
	local scene = Framework:new("game.scene")										-- create a new scene.
	scene:new("scene.simple.constructor", { scene = scene, manager = self, 			-- create the scene, telling it what it needs to know.
																constructor = data.constructor, destructor = data.destructor })
	return scene
end 

--- ************************************************************************************************************************************************************************
--//	This one appears for a period of time, then goes on to the next entry in the FSM
--- ************************************************************************************************************************************************************************

local SimpleTimedSceneManager,SuperClass = Framework:createClass("scene.simple.timed","scene.simple")

function SimpleTimedSceneManager:preOpen(manager,data,resources)
	local scene = SuperClass.preOpen(self,manager,data,resources) 					-- call the super class
	self:addSingleTimer(data.time or 4,"nextScene") 								-- fire a timer in data.time (default 4) seconds
	return scene 
end 

function SimpleTimedSceneManager:onTimer(tag)
	if tag == "nextScene" then 														-- was this the timer set up in preOpen ?
		self:performGameEvent("next") 												-- if so, sent next to the game FSM
	else 
		assert(SuperClass.onTimer == nil) 											-- if this fails, game.sceneManager has started using timers.
	end 
end 

--- ************************************************************************************************************************************************************************
--//	This is an almost invisible (very low alpha) rectangle which goes on top to detect
--//	scene wide clicks.  When touched, it performs the 'next' game event.
--- ************************************************************************************************************************************************************************

local ClickableInvisible = Framework:createClass("scene.simple.touch.clickable")

function ClickableInvisible:constructor(info)
	self.m_rectangle = display.newRect(0,0,display.contentWidth,display.contentHeight) -- create covering rectangle
	self.m_rectangle.anchorX,self.m_rectangle.anchorY = 0,0 						-- anchor it
	self.m_rectangle.alpha = 0.01 													-- make nearly invisible
	self.m_rectangle:addEventListener("tap",self) 									-- handle taps
end 

function ClickableInvisible:destructor()
	self.m_rectangle:removeEventListener("tap",self) 								-- tidy up
	self.m_rectangle:removeSelf() self.m_rectangle = nil 
end 

function ClickableInvisible:tap(event)
	self:performGameEvent("next")
	return true
end 

function ClickableInvisible:getDisplayObjects()
	return { self.m_rectangle }
end

--- ************************************************************************************************************************************************************************
--//										This goes onto the 'next' entry in the FSM when the screen is touched.
--- ************************************************************************************************************************************************************************

local SimpleTouchSceneManager,SuperClass = Framework:createClass("scene.simple.touch","scene.simple")

function SimpleTouchSceneManager:preOpen(manager,data,resources)
	local scene = SuperClass.preOpen(self,manager,data,resources) 					-- call the super class to build it.
	scene:new("scene.simple.touch.clickable",{})
	return scene 
end 

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		30-Sep-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
