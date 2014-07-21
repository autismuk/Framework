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

function FSMListener:constructor(info) self:tag("fsmListener") end 
function FSMListener:destructor() end 
function FSMListener:onMessage(sender,name,body)
	print("MSG",name,body.triggerEvent,body.currentState,body.newState,body.eventData,body.eventData.target,body.eventData.x)
end

Framework:new("demo.listener")

local cto = Framework:new("system.fsm")
print(cto)

cto:addState("state1",  {  go2 = "state2" , go1 = { target  = "state1" , x = 42 }})
cto:addState("state2", { next = { target = "state1", x = "back to state1" }})

cto:start("state1")
cto:event("go1")
cto:event("go2")
cto:event("next")
cto:event("go1")

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		14-Jul-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
