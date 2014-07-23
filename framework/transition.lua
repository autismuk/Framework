--- ************************************************************************************************************************************************************************
---
---				Name : 		transition.lua
---				Purpose :	Object which transitions between two displays (independent of Framework)
---				Created:	23 July 2014
---				Updated:	23 July 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

local Transitioner = Framework:createClass("system.transition")

function Transitioner:constructor(info)
	self.m_transitionLibrary = {}
	self:setupStandardTransitions()
end

function Transitioner:destructor()
	self.m_transitionLibrary = nil
end 

function Transitioner:execute(display1,display2,transitionType,transitionTime,notifier,notifyMethod)
	self.m_fromDisplay = display1 self.m_toDisplay = display2 
	self.m_transition = self.m_transitionLibrary[transitionType:lower()]
	self.m_time = transitionTime 
	self.m_notifier = notifier
	self.m_method = notifyMethod
	print("Executing transition",display1,display2,transitionType,transitionTime)
	self:exitTransition()
end 

function Transitioner:exitTransition()
	if self.m_fromDisplay ~= nil then self:resetScene(self.m_fromDisplay) end 
	self:resetScene(self.m_toDisplay)
	self.m_toDisplay:toFront()
	self.m_notifier[self.m_method](self.m_notifier)
end 

Transitioner.defaults = { 	alphaStart = 1.0, alphaEnd = 1.0,									-- List of transition default values
					   	  	xScaleStart = 1.0,xScaleEnd = 1.0,yScaleStart = 1.0,yScaleEnd = 1.0,
					  	 	xStart = 0,yStart = 0,xEnd = 0,yEnd = 0, 
					   		rotationStart = 0,rotationEnd = 0}

function Transitioner:resetScene(display)
	if display == nil then return end
	local def = Transitioner.defaults
	display.alpha = def.alphaEnd
	display.xScale,display.yScale = def.xScaleEnd,def.yScaleEnd
	display.x,display.y = def.xEnd,def.yEnd 
	display.rotaition = def.rotationEnd 
end 

--//	Support function for transition creations.

function Transitioner:define(name,fromTransition,toTransition,options)
	self.m_transitionLibrary[name] = { from = fromTransition, to = toTransition, concurrent = false }
	if options ~= nil and options.concurrent then self.m_transitionLibrary[name].concurrent = true end
end 

--//	Create the table of standard transitions

function Transitioner:setupStandardTransitions()
	local displayW = display.contentWidth
	local displayH = display.contentHeight

	self:define("fade",
		{ alphaStart = 1.0, alphaEnd = 0 }, 
		{ alphaStart = 0, alphaEnd = 1.0 })

	self:define("zoomoutin",
		{ xEnd = displayW*0.5, yEnd = displayH*0.5, xScaleEnd = 0.001, yScaleEnd = 0.001 }, 
		{ xScaleStart = 0.001, yScaleStart = 0.001, xScaleEnd = 1.0, yScaleEnd = 1.0, xStart = displayW*0.5, yStart = displayH*0.5, xEnd = 0, yEnd = 0 }, 
		{ hideOnOut = true })

	self:define("zoomoutinfade",		
		{ xEnd = displayW*0.5, yEnd = displayH*0.5, xScaleEnd = 0.001, yScaleEnd = 0.001, alphaStart = 1.0, alphaEnd = 0 }, 
		{ xScaleStart = 0.001, yScaleStart = 0.001, xScaleEnd = 1.0, yScaleEnd = 1.0, xStart = displayW*0.5, yStart = displayH*0.5, xEnd = 0, yEnd = 0, alphaStart = 0, alphaEnd = 1.0 }, 
		{ hideOnOut = true })

	self:define("zoominout",		
		{ xEnd = -displayW*0.5, yEnd = -displayH*0.5, xScaleEnd = 2.0, yScaleEnd = 2.0 }, 
		{ xScaleStart = 2.0, yScaleStart = 2.0, xScaleEnd = 1.0, yScaleEnd = 1.0, xStart = -displayW*0.5, yStart = -displayH*0.5, xEnd = 0, yEnd = 0 }, 
		{ hideOnOut = true })

	self:define("zoominoutfade",
		{ xEnd = -displayW*0.5, yEnd = -displayH*0.5, xScaleEnd = 2.0, yScaleEnd = 2.0, alphaStart = 1.0, alphaEnd = 0 }, 
		{ xScaleStart = 2.0, yScaleStart = 2.0, xScaleEnd = 1.0, yScaleEnd = 1.0, xStart = -displayW*0.5, yStart = -displayH*0.5, xEnd = 0, yEnd = 0, alphaStart = 0, alphaEnd = 1.0 }, 
		{ hideOnOut = true })

	self:define("flip",
		{ xEnd = displayW*0.5, xScaleEnd = 0.001 }, 
		{ xScaleStart = 0.001, xScaleEnd = 1.0, xStart = displayW*0.5, xEnd = 0 })

	self:define("flipfadeoutin",		
		{ xEnd = displayW*0.5, xScaleEnd = 0.001, alphaStart = 1.0, alphaEnd = 0 }, 
		{ xScaleStart = 0.001, xScaleEnd = 1.0, xStart = displayW*0.5, xEnd = 0, alphaStart = 0, alphaEnd = 1.0 })

	self:define("zoomoutinrotate",
		{ xEnd = displayW*0.5, yEnd = displayH*0.5, xScaleEnd = 0.001, yScaleEnd = 0.001, rotationStart = 0, rotationEnd = -360 }, 
		{ xScaleStart = 0.001, yScaleStart = 0.001, xScaleEnd = 1.0, yScaleEnd = 1.0, xStart = displayW*0.5, yStart = displayH*0.5, xEnd = 0, yEnd = 0, rotationStart = -360, rotationEnd = 0 }, 
		{ hideOnOut = true })

	self:define("zoomoutinfaderotate",
 		{ xEnd = displayW*0.5, yEnd = displayH*0.5, xScaleEnd = 0.001, yScaleEnd = 0.001, rotationStart = 0, rotationEnd = -360, alphaStart = 1.0, alphaEnd = 0 }, 
 		{ xScaleStart = 0.001, yScaleStart = 0.001, xScaleEnd = 1.0, yScaleEnd = 1.0, xStart = displayW*0.5, yStart = displayH*0.5, xEnd = 0, yEnd = 0, rotationStart = -360, rotationEnd = 0, alphaStart = 0, alphaEnd = 1.0 }, 
 		{ hideOnOut = true })

	self:define("zoominoutrotate",	
		{ xEnd = displayW*0.5, yEnd = displayH*0.5, xScaleEnd = 2.0, yScaleEnd = 2.0, rotationStart = 0, rotationEnd = -360 }, 
		{ xScaleStart = 2.0, yScaleStart = 2.0, xScaleEnd = 1.0, yScaleEnd = 1.0, xStart = displayW*0.5, yStart = displayH*0.5, xEnd = 0, yEnd = 0, rotationStart = -360, rotationEnd = 0 }, 
		{ hideOnOut = true })
	
	self:define("zoominoutfaderotate",		
		{ xEnd = displayW*0.5, yEnd = displayH*0.5, xScaleEnd = 2.0, yScaleEnd = 2.0, rotationStart = 0, rotationEnd = -360, alphaStart = 1.0, alphaEnd = 0 }, 
		{ xScaleStart = 2.0, yScaleStart = 2.0, xScaleEnd = 1.0, yScaleEnd = 1.0, xStart = displayW*0.5, yStart = displayH*0.5, xEnd = 0, yEnd = 0, rotationStart = -360, rotationEnd = 0, alphaStart = 0, alphaEnd = 1.0 }, 
		{ hideOnOut = true })
	
	self:define("fromright",
 		{ xStart = 0, yStart = 0, xEnd = 0, yEnd = 0, transition = easing.outQuad }, 
 		{ xStart = displayW, yStart = 0, xEnd = 0, yEnd = 0, transition = easing.outQuad }, 
 		{ concurrent = true, displayAbove = true })
	

	self:define("fromleft",
		{ xStart = 0, yStart = 0, xEnd = 0, yEnd = 0, transition = easing.outQuad }, 
		{ xStart = -displayW, yStart = 0, xEnd = 0, yEnd = 0, transition = easing.outQuad }, 
		{ concurrent = true, displayAbove = true })

	self:define("fromtop",
		{ xStart = 0, yStart = 0, xEnd = 0, yEnd = 0, transition = easing.outQuad }, 
		{ xStart = 0, yStart = -displayH, xEnd = 0, yEnd = 0, transition = easing.outQuad }, 
		{ concurrent = true, displayAbove = true })

	self:define("frombottom",
		{ xStart = 0, yStart = 0, xEnd = 0, yEnd = 0, transition = easing.outQuad }, 
		{ xStart = 0, yStart = displayH, xEnd = 0, yEnd = 0, transition = easing.outQuad }, 
		{ concurrent = true, displayAbove = true })

	self:define("slideleft",
		{ xStart = 0, yStart = 0, xEnd = -displayW, yEnd = 0, transition = easing.outQuad }, 
		{ xStart = displayW, yStart = 0, xEnd = 0, yEnd = 0, transition = easing.outQuad }, 
		{ concurrent = true, displayAbove = true })

	self:define("slideright",
 		{ xStart = 0, yStart = 0, xEnd = displayW, yEnd = 0, transition = easing.outQuad }, 
 		{ xStart = -displayW, yStart = 0, xEnd = 0, yEnd = 0, transition = easing.outQuad }, 
 		{ concurrent = true, displayAbove = true })

	self:define("slidedown",
 		{ xStart = 0, yStart = 0, xEnd = 0, yEnd = displayH, transition = easing.outQuad }, 
 		{ xStart = 0, yStart = -displayH, xEnd = 0, yEnd = 0, transition = easing.outQuad }, 
 		{ concurrent = true, displayAbove = true })

	self:define("slideup",		
		{ xStart = 0, yStart = 0, xEnd = 0, yEnd = -displayH, transition = easing.outQuad }, 
		{ xStart = 0, yStart = displayH, xEnd = 0, yEnd = 0, transition = easing.outQuad }, 
		{ concurrent = true, displayAbove = true })

	self:define("crossfade",		
		{ alphaStart = 1.0, alphaEnd = 0, }, 
		{ alphaStart = 0, alphaEnd = 1.0 }, 
		{ concurrent = true })

end

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		23-Jul-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
