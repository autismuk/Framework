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
require("utils.registry")

--require("main_spritetest")
require("utils.sound")
require("game.gamespace")
require("game.player")
require("game.enemies")
require("game.factory")

local SCManager = Framework:createClass("test.sceneManager","game.sceneManager")

function SCManager:preOpen(manager,data,resources)
	local scene = Framework:new("game.scene")													-- create a new scene
	local adIDs = { ios = "ca-app-pub-8354094658055499/9860763610", 							-- admob identifiers.
					android = "ca-app-pub-8354094658055499/9860763610" }
	scene.m_advertObject = scene:new("ads.admob",adIDs)											-- create a new advert object
	local headerSpace = scene.m_advertObject:getHeight() 										-- get the advert object height
	scene.m_gameSpace = scene:new("game.gamespace", { header = headerSpace, channels = 7 })		-- create a gamespace allowing for that

	local eFactory = Framework:new("game.enemyFactory",{ enemyCount = { 3,3,3,3,3,3,3 }, level = 1 })
	scene:new("game.player", { gameSpace = scene.m_gameSpace,factory = eFactory, level = 1 }) 	-- add a player.
	for i = 1,7 do eFactory:spawn(scene,scene.m_gameSpace) end
	return scene
end 

local manager = Framework:new("game.manager")
scene = Framework:new("test.sceneManager")
manager:addManagedState("start",scene,{ same = "start" })
Framework:new("audio.sound",{ sounds = { "dead", "move","prize","shoot","start"} })
manager:start()

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		02-Aug-2014	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************

--[[

4) Auto spawning in game space.
5) Missile objects and autofiring.
6) Collisions (game over/shooting)
7) Scoring
8) Audio
9) Wrapper
10) Testing

--]]