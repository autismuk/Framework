--- ************************************************************************************************************************************************************************
---
---				Name : 		main.lua
---				Purpose :	Top level code for Framework library.
---				Created:	14 July 2014
---				Updated:	14 July 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

display.setStatusBar(display.HiddenStatusBar)													-- hide status bar.
require("strict")																				-- install strict.lua to track globals etc.
require("framework.framework")																	-- framework.
--require("main_test")
--require("main_numbers")



local FSMListener = Framework:createClass("demo.listener")
function FSMListener:constructor(info) self:tag("ctoListener") end 
function FSMListener:destructor() end 
function FSMListener:onMessage(sender,name,body)
	print("MSG",name)
	print(body.sceneIdentifier,body.sceneInstance,body.transitionType,body.transitionTime,body.sceneData.x)
end

local SomeSM = Framework:createClass("game.smclass1","game.scenemanager")
local SomeSM2 = Framework:createClass("game.smclass2","game.scenemanager")
local listen = Framework:new("demo.listener")

local cto = Framework:new("game.controlObject")
print(cto)

cto:addState("start", "game.smclass1", {  go2 = { target = "state2", transitionType = "type"} , go1 = { target = "start" , transitionType = "fade", transitionTime = 0.7 } })
cto:addState("state2", "game.smclass2", {  next = { target = "start" } })

cto:sendMessage(cto,"event",{ name = nil, data = { x = 9 }, notify = listen })
timer.performWithDelay(100,function() cto:sendMessage(cto,"event",{ name = "go1", data = { x = 32 }, notify = listen }) end)
timer.performWithDelay(200,function() cto:sendMessage(cto,"event",{ name = "go2", data = { x = 132 }, notify = listen }) end)
--cto:sendMessage(cto,"event",{ name = "go1", data = { x = 32 }, notify = listen })

-- fix this problem. is it fixable with asynchronous messaging ? Queue up performGameEvents ?
-- not required. The synchronising / pass on is handled as part of game.manager.

--[[
cto:start("state1")
cto:event("go1")
cto:event("go2")
cto:event("next")
cto:event("go1")
--]]

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		14-Jul-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
