--- ************************************************************************************************************************************************************************
---
---				Name : 		main.lua
---				Purpose :	Testing code for game.manager and associated classes.
---				Created:	22 July 2014
---				Updated:	22 July 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

local FSMListener = Framework:createClass("demo.listener")

function FSMListener:constructor(info) self:tag("fsmListener") end 
function FSMListener:destructor() end 
function FSMListener:onMessage(sender,name,body)
	print("MSG",name,body.triggerEvent,body.currentState,body.newState,body.eventData,body.eventData.target,body.eventData.x)
end

Framework:new("demo.listener")

local fsm = Framework:new("system.fsm")


fsm:addState("state1",  {  go2 = "state2" , go1 = { target  = "state1" , x = 42 }})
fsm:addState("state2", { next = { target = "state1", x = "back to state1" }})

fsm:start("state1")
fsm:event("go1")
fsm:event("go2")
fsm:event("next")
fsm:event("go1")

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		22-Jul-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
