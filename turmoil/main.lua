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
--require("main_spritetest")
require("strict")																				-- install strict.lua to track globals etc.
require("framework.framework")																	-- framework.
require("utils.admob")
require("utils.registry")
require("utils.stubscene")
require("utils.sound")
require("game.gamespace")
require("game.player")
require("game.enemies")
require("game.factory")
require("game.missiles")
require("game.status")

local SCManager = Framework:createClass("test.sceneManager","game.sceneManager")

function SCManager:preOpen(manager,data,resources)
	local scene = Framework:new("game.scene")													-- create a new scene
	local adIDs = { ios = "ca-app-pub-8354094658055499/9860763610", 							-- admob identifiers.
					android = "ca-app-pub-8354094658055499/9860763610" }
	scene.m_advertObject = scene:new("ads.admob",adIDs)											-- create a new advert object
	local headerSpace = scene.m_advertObject:getHeight() 										-- get the advert object height

	scene.m_gameSpace = scene:new("game.gamespace", { header = headerSpace, scene = scene }) 	-- create a game space as required.
																					
	scene:new("game.player", { gameSpace = scene.m_gameSpace }) 								-- add a player.
	scene:new("game.missilemanager", { gameSpace = scene.m_gameSpace, scene = scene }) 			-- add a missile manager.
	return scene
end 

Framework:new("audio.sound",{ sounds = { "dead", "move","prize","shoot","start","bomb","appear" } })
Framework:new("game.status")

local manager = Framework:new("game.manager")
scene = Framework:new("test.sceneManager")

local eFactory = Framework:new("game.enemyFactory") 											-- create an enemy factory.

local stub = Framework:new("utils.stubscene", { name = "start", targets = { play = "Start Game", instructions = "Instructions" }, data = { }})

manager:addManagedState("start",stub, { play = "main" })
manager:addManagedState("main",scene,{ same = "main" })

manager:start("main",{ })

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		02-Aug-2014	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************

--[[

5.7) Intro bit
6.5) Collisions (enemies/player)
6.6) Outro

9) Wrapper, level selection, title screen etc.
10) Testing esp. Admob.


--]]