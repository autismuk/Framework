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
require("game.gamespace")
require("main_spritetest")

--[[
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
--]]
--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		14-Jul-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
