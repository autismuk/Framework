--- ************************************************************************************************************************************************************************
---
---				Name : 		title.lua
---				Purpose :	Title Page
---				Created:	12 August 2014
---				Updated:	12 August 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

require("utils.gui")

local TitleMain = Framework:createClass("scene.titleScene.main")

function TitleMain:constructor(info)
	self.m_group = display.newGroup()
	local txt = display.newText(self.m_group,ApplicationVersion,0,display.contentHeight,native.systemFont,14)
	txt.anchorX,txt.anchorY = 0,1
	display.newBitmapText(self.m_group,"Turmoil",display.contentWidth/2,display.contentHeight/5,"grapple",128):setTintColor(1,1,0)
	display.newBitmapText(self.m_group,"(c) Paul Robson 2014",display.contentWidth/2,display.contentHeight*0.43,"grapple",40):setTintColor(0,1,1)
end 

function TitleMain:destructor()
	self.m_group:removeSelf()
	self.m_group = nil
end 

function TitleMain:getDisplayObjects()
	return { self.m_group }
end

local titleScene = Framework:createClass("scene.titleScene","game.sceneManager")

--//	Before opening a main scene, create it.

function titleScene:preOpen(manager,data,resources)
	local scene = Framework:new("game.scene")
	scene:new("scene.titleScene.main",data)
	scene:new("gui.icon.pulsing", { image = "images/go.png", width = 17, x = 87, y = 87, listener = self, message = "start" })
	scene:new("gui.text.list", { x = 50, y = 65, listener = self, message = "active" , tint = { 1,0.8,0.5 },font = { name = "grapple", size = 40 },
								 items = { "Start at Level 1","Start at Level 5","Start at Level 10"} } ):name("startLevel")
	return scene
end 

function titleScene:onMessage(sender,message,data)
	local startLevel = Framework.fw.startLevel:getSelected()
	startLevel = math.max(1,(startLevel-1) * 5)
	Framework.fw.status:setStartLevel(startLevel)
	Framework.fw.status:reset()
	if Framework.fw.enemyFactory ~= nil then Framework.fw.enemyFactory:delete() end 
	Framework:new("game.enemyFactory")
	self:performGameEvent("start")
end 

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		12-Aug-2014	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************