--- ************************************************************************************************************************************************************************
---
---				Name : 		stubscene.lua
---				Purpose :	"Stub" Scene for development
---				Created:	7th August 2014
---				Updated:	7th August 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

require("framework.framework")

local StubSceneDisplay = Framework:createClass("utils.stubscene.display")

--//	Construct a stub scene. info.name is the stub name, info.data is passed data to event, info.targets are action/description pairs

function StubSceneDisplay:constructor(info) 
	self.m_group = display.newGroup()															-- create a group for display objects
	self.m_listenerList = {} 																	-- list of everything with listeners
	self.m_data = info.data 																	-- preserve data that's to be passed in.
	local background = display.newRect(self.m_group,0,0,										-- create background frame.
											display.contentWidth,display.contentHeight)
	background.anchorX,background.anchorY = 0,0 background:setFillColor(0.5,0,0)
	background.strokeWidth = 16 background:setStrokeColor(1,1,1)
	local text = display.newText(self.m_group,'Stub:"'..info.name..'"',							-- create titile
											display.contentWidth/2,42,native.systemFont,40)
	text:setFillColor(1,1,0)
	local yPos = display.contentHeight / 2 + 40 - 45 * info.count / 2 							-- centre menu
	for action,description in pairs(info.targets) do 											-- display each item
		local button = display.newRect(self.m_group,0,0,display.contentWidth*0.8,40)
		button.x,button.y = display.contentWidth/2,yPos button:setFillColor(0,0,1) button.strokeWidth = 2
		local text = display.newText(self.m_group,description,0,0,native.systemFont,24)
		text.x,text.y = button.x,button.y text:setFillColor(1,1,0)
		yPos = yPos + 45
		button:addEventListener("tap",self)														-- add a listener to it
		self.m_listenerList[#self.m_listenerList+1] = button 									-- add button to listener list
		button.framework_action = action 														-- attach an action to it.
	end
end 

--//	Tidy up

function StubSceneDisplay:destructor()
	for _,ref in ipairs(self.m_listenerList) do ref:removeEventListener("tap",self) end 		-- remove all listeners
	self.m_group:removeSelf() self.m_group = nil self.m_listenerList = nil self.m_data = nil 	-- remove display group and null pointers
end 

--//	Get the display objects

function StubSceneDisplay:getDisplayObjects() 
	return { self.m_group }																		-- all in this group
end 

--//	Handle tap events
--//	@event 		[object]	event information

function StubSceneDisplay:tap(event)
	---print(event.target,event.target.framework_action)
	self:performGameEvent(event.target.framework_action,self.m_data)							-- fire game event with given data.
end

local StubScene,SuperClass = Framework:createClass("utils.stubscene","game.sceneManager")

--//	Constructor - creates stub scene.
--//	@info 	[table]			has name, targets, same as stubscenedisplay

function StubScene:constructor(info) 
	SuperClass.constructor(self,info)															-- superclass constructor
	self.m_name = info.name 																	-- remember stuff
	self.m_targets = info.targets 
	self.m_data = info.data
	self.m_targetCount = 0 																		-- count the number of targets
	for _,_ in pairs(self.m_targets) do self.m_targetCount = self.m_targetCount + 1 end 
end 

--//	Destructor - throws object

function StubScene:destructor()
	self.m_targets = nil self.m_name = nil self.m_targetCount = nil self.m_data = nil
end 

--//	Handle preopen of stubscene manager. Creates a new scene using utils.stubscene.display class.

function StubScene:preOpen(manager,data,resources)
	local scene = Framework:new("game.scene")
	scene:new("utils.stubscene.display",{ name = self.m_name, targets = self.m_targets, count = self.m_targetCount,data = self.m_data })
	return scene 
end 


--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		7-Aug-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
