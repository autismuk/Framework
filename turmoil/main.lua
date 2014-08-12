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

ApplicationVersion = "v0.1"

display.setStatusBar(display.HiddenStatusBar)													-- hide status bar.
--require("main_spritetest")
require("strict")																				-- install strict.lua to track globals etc.
require("framework.framework")																	-- framework.
require("utils.sound")
require("game.status")
require("scene.title")
require("scene.info")
require("scene.mainscene")

Framework:new("audio.sound",																	-- create sounds object
					{ sounds = { "dead", "move","prize","shoot","levelcomplete","bomb","appear" } })
Framework:new("game.status", { lives = 2 }) 													-- create game status object.

Framework.fw.status:reset()

local eFactory = Framework:new("game.enemyFactory") 											-- create an enemy factory (todo: not eventually required)

local manager = Framework:new("game.manager")

manager:addManagedState("start",																-- Title Page
						Framework:new("scene.titleScene"), 
						{ start = "info" })														-- title page (and options)

manager:addManagedState("info", 																-- Scene before starting, no exit.
						Framework:new("scene.infoScene", { }),
						{ start = "main", exit = "start" }) 									-- Level nn [complete] , Score, play on or go back.

manager:addManagedState("main",																	-- Main play scene.
						Framework:new("scene.mainScene"),
						{ continue = "info", lost = "end" })									-- Continue if lives left, lost if lives zero.

manager:addManagedState("end",
						Framework:new("scene.infoScene", { message = "Game Over"}),
						{ start = "start", exit = "start"}) 									-- Game Over, Score, go back, or go back.

manager:start("start",{ })

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		02-Aug-2014	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************

--[[
	
6.7) Prize gives short shield. Implement shield (non graphic bits)
9) Title Screen, go resets status and creates a new factory.
10) Testing esp. Admob.

Dump super and patch it out.

--]]