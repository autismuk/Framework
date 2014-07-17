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
--require("main_test")

require("framework.framework")

local CL = Framework:createClass("query.x")
function CL:constructor(info) self.m_name = info.name print("Constructed",info.name) end 
function CL:destructor() end 

function CL:onTimer(tag)
	print(tag,"fired by",self.m_name)
end 

local CL2 = Framework:createClass("timer.x","query.x")

function CL2:onTimer(tag) 
	print("CL2 Fired") 
	self.super.onTimer(self,tag)
end

function CL2:onMessage(sender,body,data) 
	print(sender,body,data)
end 

local c1 = Framework:new("query.x", { name = "name c1" })
local c2 = Framework:new("timer.x", { name = "name c2" }):tag("a")

Framework:setEnterFrameEnabled(false)
timer.performWithDelay( 2000,function() Framework:setEnterFrameEnabled(true) print("Start") end)
c1:addMultiTimer(1,4,"four")
c2:addSingleTimer(1.5,"one")
c1:sendMessageLater("a","hi !",nil,5)

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		14-Jul-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
