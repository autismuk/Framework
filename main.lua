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
require("main_test")

--[[
require("framework.framework")

local CL = Framework:createClass("query.x")
function CL:constructor(info) self.m_name = info.name end 
function CL:destructor() end 

local c1 = Framework:new("query.x", { name = "name c1" }):tag("a,b,c")
local c2 = Framework:new("query.x", { name = "name c2" }):tag("a,b")
local c3 = Framework:new("query.x", { name = "name c3" }):tag("a,c")
local c4 = Framework:new("query.x", { name = "name c4" }):tag("a,b,c")
local c5 = Framework:new("query.x", { name = "name c6" }):tag("b,d,a")

local count,list = c1:query("a,b")
print(count," objects")
for k,v in pairs(list) do print(v.m_name) end
--]]

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		14-Jul-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************

-- messages (seperate unit)
-- timers (seperate unit)
-- collection (group of objects)
-- scene (collection with display group, updating.)