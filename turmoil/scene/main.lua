--- ************************************************************************************************************************************************************************
---
---				Name : 		main.lua
---				Purpose :	Main Scene
---				Created:	11 August 2014
---				Updated:	11 August 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

require("utils.admob")
require("game.gamespace")
require("game.player")
require("game.enemies")
require("game.factory")
require("game.missiles")
require("game.miscellany")


local MainScene = Framework:createClass("scene.mainScene","game.sceneManager")

--//	Before opening a main scene, create it.

function MainScene:preOpen(manager,data,resources)
	local scene = Framework:new("game.scene")													-- create a new scene
	local adIDs = { ios = "ca-app-pub-8354094658055499/9860763610", 							-- admob identifiers.
					android = "ca-app-pub-8354094658055499/9860763610" }
	scene.m_advertObject = scene:new("ads.admob",adIDs)											-- create a new advert object
	local headerSpace = scene.m_advertObject:getHeight() 										-- get the advert object height

	scene.m_gameSpace = scene:new("game.gamespace", { header = headerSpace, scene = scene }) 	-- create a game space as required.
																					
	scene:new("game.player", { gameSpace = scene.m_gameSpace }) 								-- add a player.
	scene:new("game.missilemanager", { gameSpace = scene.m_gameSpace, scene = scene }) 			-- add a missile manager.
	scene:new("game.intro") 																	-- the overlaid text
	return scene
end 

--//	This is called once the screen has actually been opened

function MainScene:postOpen(manager,data,resources)
	self:sendMessageLater("introText","start",nil,2)											-- animate intro text off, eventually.
	self:sendMessageLater("enemyFactory","start",nil,2.5)										-- start enemy factory eventually
end 

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		11-Aug-2014	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************