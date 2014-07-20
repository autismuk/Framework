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


local sm = Framework:new("game.sceneManager")

local FSMListener = Framework:createClass("demo.listener")
function FSMListener:constructor(info) self:tag("fsmListener") end 
function FSMListener:destructor() end 
function FSMListener:onMessage(sender,name,body)
	print(sender,name,body.currentState,body.triggerEvent,body.newState)
end

Framework:new("demo.listener")

local fsm = Framework:new("system.fsm")
print(fsm)

fsm:addState("state1", {  go2 = "state2" , go1 = "state1"})
fsm:addState("state2", {  next = "state1" })
fsm:start("state1")
fsm:event("go1")
fsm:event("go2")
fsm:event("next")
fsm:event("go1")

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		14-Jul-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
