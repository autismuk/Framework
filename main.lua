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
local Framework = require("framework.framework") 												-- require the framework library.


local nc = Framework:createClass("demo1")

function nc:constructor(initData)
	print("Constructor")
	for k,v in pairs(initData) do print(k,v) end 
end 

function nc:destructor() 
	print("Destructor")
end 

Framework:addFrameworkMixinEntity("demofn",function(self,a) print(a,a*a) end)


local ob = Framework:createObject("demo1",{ a = 2, b = 3,c = 42})
ob.fw:demofn(42)
Framework:deleteObject(ob)

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		14-Jul-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
