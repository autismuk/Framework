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
function CL:constructor(info) self.m_name = info.name end 

function CL:destructor() end 

function CL:onTimer(tag)
	print(tag,"fired by",self.m_name)
end 

local c1 = Framework:new("query.x", { name = "name c1" }):tag("a,b,c")

c1:addSingleTimer(2,"fred")

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		14-Jul-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
