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

function CL:createMixinObject()
	return display.newCircle(0,0,2)
end 

function CL:constructor(info) 
	self.x = info.x self.y = info.y self.path.radius = 42
	self:setFillColor(info.red,info.green,info.blue)
end 

function CL:destructor() 
end 

function CL:getDisplayObjects() return { self } end 

local CL2 = Framework:createClass("timer.x","query.x")

-- function CL2:onUpdate(dt) print("Updating",self.m_name,dt) end

local sc = Framework:new("game.scene")

local c1 = sc:new("query.x", { name = "name c1", x = 64, y = 32, red = 1,green = 0,blue = 0 })
local c2 = sc:new("timer.x", { name = "name c2", x = 164, y = 32, red = 1,green = 1,blue = 0 })

sc:getContainer().alpha = 0.5
sc:delete()

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		14-Jul-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
