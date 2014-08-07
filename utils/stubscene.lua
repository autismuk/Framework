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

function StubSceneDisplay:constructor(info) 
	self.m_group = display.newGroup()
	local background = display.newRect(self.m_group,0,0,display.contentWidth,display.contentHeight)
	background.anchorX,background.anchorY = 0,0 background:setFillColor(0.5,0,0)
	background.strokeWidth = 16 background:setStrokeColor(1,1,1)
	local text = display.newText(self.m_group,'Stub:"'..info.name..'"',display.contentWidth/2,42,native.systemFont,40)
	text:setFillColor(1,1,0)
end 

function StubSceneDisplay:destructor()
	self.m_group:removeSelf() self.m_group = nil 
end 

function StubSceneDisplay:getDisplayObjects() 
	return { self.m_group }
end 

local StubScene = Framework:createClass("utils.stubscene","game.sceneManager")

--//	Constructor - creates stub scene.

function StubScene:constructor(info) 
	self.super.constructor(self,info)
	self.m_name = info.name 
	self.m_targets = info.targets 
	self.m_targetCount = 0 
	for _,_ in pairs(self.m_targets) do self.m_targetCount = self.m_targetCount + 1 end 
end 

--//	Destructor - throws object

function StubScene:destructor()
	self.m_targets = nil self.m_name = nil self.m_targetCount = nil
end 

function StubScene:preOpen(manager,data,resources)
	local scene = Framework:new("game.scene")
	scene:new("utils.stubscene.display",{ name = self.m_name, targets = self.m_targets, count = self.m_targetCount })
	return scene 
end 


--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		7-Aug-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
