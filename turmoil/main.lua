--- ************************************************************************************************************************************************************************
---
---				Name : 		main.lua
---				Purpose :	Top level code "Turmoil"
---				Created:	2 August 2014
---				Updated:	2 August 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

display.setStatusBar(display.HiddenStatusBar)													-- hide status bar.
require("strict")																				-- install strict.lua to track globals etc.
require("framework.framework")																	-- framework.
require("utils.admob")

--require("main_spritetest")

local GameSpace = Framework:createClass("game.gamespace")

function GameSpace:constructor(info)
	self.m_headerSize = info.header or 0 														-- extract out parameters.
	self.m_channelCount = info.channels or 7 
	self.m_currentLevel = info.level or 1
	self.m_borderSize = 2 																		-- width of border.
	self.m_borderList = {} 																		-- list of border objects
	self:addBorder(0,display.contentWidth,0) 													-- top and bottom borders.
	self:addBorder(0,display.contentWidth,display.contentHeight - self.m_headerSize - 1 - self.m_borderSize)
	self.m_channelSize = math.floor((display.contentHeight - self.m_borderSize - self.m_headerSize) / self.m_channelCount)
	self.m_spriteSize = self.m_channelSize - self.m_borderSize 
	for c = 1,self.m_channelCount-1 do 
		local y = self.m_borderSize + self.m_channelSize * c 
		self:addBorder(0,display.contentWidth/2-self.m_channelSize,y)
		self:addBorder(display.contentWidth,display.contentWidth/2+self.m_channelSize,y)
	end
	print(self.m_spriteSize)

	local x,y = self:getPos(100,1)
	local demoSprites = require("images.sprites")
	local s = demoSprites:newSprite()
	s.x,s.y = x,y
	s.xScale,s.yScale = self.m_spriteSize / 64, self.m_spriteSize / 64
	s:setSequence("enemy1")
	s:play()
end

function GameSpace:addBorder(x1,x2,y)
	local line = display.newLine(x1,y+self.m_headerSize,x2,y+self.m_headerSize)
	line:setStrokeColor(0,0,1) line.strokeWidth = 2
	self.m_borderList[#self.m_borderList+1] = line 
end 

function GameSpace:getDisplayObjects() 
	return self.m_borderList 
end 

function GameSpace:getPos(xPercent,yChannel)
	return xPercent * display.contentWidth / 100, self.m_channelSize * (yChannel - 0.5)+ self.m_headerSize
end 

local SCManager = Framework:createClass("test.sceneManager","game.sceneManager")

function SCManager:preOpen(manager,data,resources)
	local scene = Framework:new("game.scene")
	local adIDs = { ios = "ca-app-pub-8354094658055499/9860763610", android = "ca-app-pub-8354094658055499/9860763610" }
	scene.m_advertObject = scene:new("ads.admob",adIDs)
	local headerSpace = scene.m_advertObject:getHeight()
	scene.m_gameSpace = scene:new("game.gamespace", { header = headerSpace, level = 1, channels = 7 })
	return scene
end 

local manager = Framework:new("game.manager")
scene = Framework:new("test.sceneManager")
manager:addManagedState("start",scene,{ same = "start" })
manager:start()

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		14-Jul-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
