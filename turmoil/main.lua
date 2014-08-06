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
require("game.missiles")

local SCManager = Framework:createClass("test.sceneManager","game.sceneManager")

function SCManager:preOpen(manager,data,resources)
	local scene = Framework:new("game.scene")													-- create a new scene
	local adIDs = { ios = "ca-app-pub-8354094658055499/9860763610", 							-- admob identifiers.
					android = "ca-app-pub-8354094658055499/9860763610" }
	scene.m_advertObject = scene:new("ads.admob",adIDs)											-- create a new advert object
	local headerSpace = scene.m_advertObject:getHeight() 										-- get the advert object height

	scene.m_gameSpace = scene:new("game.gamespace", { header = headerSpace, channels = 7, 		-- create a game space as required.
																		scene = scene, factory = data.factory, level = 1 })

	scene:new("game.player", { gameSpace = scene.m_gameSpace,level = 1 }) 						-- add a player.
	scene:new("game.missilemanager", { gameSpace = scene.m_gameSpace, scene = scene }) 			-- add a missile manager.

	return scene
end 

local manager = Framework:new("game.manager")
scene = Framework:new("test.sceneManager")

manager:addManagedState("main",scene,{ same = "main" })
Framework:new("audio.sound",{ sounds = { "dead", "move","prize","shoot","start"} })

local eFactory = Framework:new("game.enemyFactory",{ level = 1 }) 							-- create an enemy factory.
manager:start("main",{ factory = eFactory })


--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		02-Aug-2014	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************

--[[

5) Missile objects/manager.
6) Collisions (game over/shooting) (note collision when fetching, not ghost.)
7) Scoring
8) Audio
9) Wrapper, level selection, title screen etc.
10) Testing esp. Admob.

--]]