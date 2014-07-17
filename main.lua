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

function CL:constructor(info) 
	self.m_name = info.name 
	print("Constructed",info.name) 
	self.m_circle = display.newCircle(info.x,info.y,32)
	self.m_circle:setFillColor(info.red,info.green,info.blue)
end 

function CL:destructor() 
	print("Destructed",self.m_name) 
end 

function CL:getDisplayObjects() return { self.m_circle } end 

local CL2 = Framework:createClass("timer.x","query.x")

-- function CL2:onUpdate(dt) print("Updating",self.m_name,dt) end

local sc = Framework:new("game.scene")

local c1 = sc:new("query.x", { name = "name c1", x = 64, y = 32, red = 1,green = 0,blue = 0 })
local c2 = sc:new("timer.x", { name = "name c1", x = 164, y = 32, red = 1,green = 1,blue = 0 })

print(sc:getCollection())

sc:getContainer().alpha = 0
transition.to(sc:getContainer(), { time = 1000,alpha = 1 })

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		14-Jul-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
