--- ************************************************************************************************************************************************************************
---
---				Name : 		transition.lua
---				Purpose :	Object which transitions between two displays (independent of Framework)
---				Created:	23 July 2014
---				Updated:	24 July 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

local Transitioner = Framework:createClass("system.transition")

--//	Constructor

function Transitioner:constructor(info)
	self.m_transitionLibrary = {}																-- Storage of transitions
	self:setupStandardTransitions() 															-- Load them.
end

--// 	Destructor

function Transitioner:destructor()
	self.m_transitionLibrary = nil
end 

--//	Run a transition. This consiss of two parts ; phase 1, which transitions the old scene off, phase 2 which transitions
--//	the new scene on (and the old scene off if it is concurrent)
--//	@display1 			[container/group]			scene to transition out (may be nil)
--//	@display2 			[continaer/group]			scene to transition in
--//	@transitionType 	[string]					transition name
--//	@transitionTime 	[number]					time in seconds
--//	@notifier 			[object]					object to notify when complete
--//	@notifyMethod 		[string]					method in that object to call.

function Transitioner:execute(display1,display2,transitionType,transitionTime,notifier,notifyMethod)
	self.m_fromDisplay = display1 self.m_toDisplay = display2  									-- save display
	self.m_transition = self.m_transitionLibrary[transitionType:lower()]						-- get the transition.
	assert(self.m_transition ~= nil,"Transition unknown "..transitionType)						-- check it exists
	assert(transitionTime > 0 and transitionTime < 10,"Bad transition time") 					-- these are in seconds.
	self.m_time = transitionTime  																-- save time, notifier and method.
	self.m_notifier = notifier
	self.m_method = notifyMethod
	self.m_nextPhase = 1 																		-- next phase is phase 1.
	self:executePhase()
end 

--//	Execute the next phase of the transition - 1 = phase out first (not concurrent), 2 phase in second (phase out first if concurrent)
--//	3 notify we have finished.

function Transitioner:executePhase()
	local phase = self.m_nextPhase 																-- get phase
	self.m_nextPhase = self.m_nextPhase + 1 													-- next time, do the next phase.
	self.m_toDisplay.isVisible = false 															-- hide both of them originally
	if self.m_fromDisplay ~= nil then self.m_fromDisplay.isVisible = false  end
	--print("Phase",phase)
	if phase == 1 then 																			-- phase 1.
		if self.m_fromDisplay ~= nil and not self.m_transition.concurrent then  				-- if there is a from, and it is not concurrent run it first.
			self:setupTransform(self.m_fromDisplay,self.m_transition.from,true)
		else
			self:executePhase() 																-- otherwise go to the next phase, as phase 1 may not happen.
		end
	elseif phase == 2 then   																	-- phase 2. out (if concurrent) and new one in.
		if self.m_fromDisplay ~= nil and self.m_transition.concurrent then 						-- if concurrent transition, run from-out simultaneously.
			self:setupTransform(self.m_fromDisplay,self.m_transition.from,false)
		end 
		self:setupTransform(self.m_toDisplay,self.m_transition.to,true) 						-- transition the new one in.
	else 																						-- phase 3, which means its exit time.
		self:exitTransition()																	-- call the function to exit.
	end
end 

--//	Start a transform on the given display object, optionally running executePhase() when done.
--//	@displayObject 			[displayObject]		Object to transform
--//	@transformDefinition	[transform]			Transform definition (collection of xEnd/yEnd/xStart etc.)
--//	@executeOnCompletion	[boolean]			If true, then when the transform is finished, call executePhase() to do the next phase.

function Transitioner:setupTransform(displayObject,transformDefinition,executeOnCompletion)
	local def = Transitioner.defaults 															-- saves a lot of typing :)
	displayObject.x = transformDefinition.xStart or def.xStart 									-- set display object to start point.
	displayObject.y = transformDefinition.yStart or def.yStart 									-- using transition definitions or default values.
	displayObject.xScale = transformDefinition.xScaleStart or def.xScaleStart
	displayObject.yScale = transformDefinition.yScaleStart or def.yScaleStart
	displayObject.alpha = transformDefinition.alphaStart or def.alphaStart
	displayObject.rotation = transformDefinition.rotationStart or def.rotationStart

	local transform = {} 																		-- now work out the finishing point.
	transform.x = transformDefinition.xEnd or def.xEnd 									
	transform.y = transformDefinition.yEnd or def.yEnd 									
	transform.xScale = transformDefinition.xScaleEnd or def.xScaleEnd
	transform.yScale = transformDefinition.yScaleEnd or def.yScaleEnd
	transform.alpha = transformDefinition.alphaEnd or def.alphaEnd
	transform.rotation = transformDefinition.rotationEnd or def.rotationEnd

	if executeOnCompletion then 																-- execute when phase ends.
		transform.onComplete = function(obj) self:executePhase() end 
	end 

	transform.time = self.m_time * 1000 														-- time in milliseconds, not seconds
	displayObject.isVisible = true 																-- make it visible.
	displayObject:toFront() 																	-- bring it to the front.
	transition.to(displayObject,transform)														-- and do it.

	--print(self.m_nextPhase-1,displayObject,transformDefinition,executeOnCompletion)

end 

--//	Transition is complete - tidy everything up and reset things back for continuation, notify the listener
--//	we've done, and null all references.

function Transitioner:exitTransition()
	if self.m_fromDisplay ~= nil then self:resetScene(self.m_fromDisplay) end 					-- reset from scene
	self:resetScene(self.m_toDisplay) 															-- reset to scene
	self.m_toDisplay:toFront() 																	-- bring scene to the front
	self.m_fromDisplay = nil self.m_toDisplay = nil 											-- null stuff out
	self.m_notifier[self.m_method](self.m_notifier)
	self.m_notifier = nil 																		-- forget about notifier
end 

Transitioner.defaults = { 	alphaStart = 1.0, alphaEnd = 1.0,									-- List of transition default values
					   	  	xScaleStart = 1.0,xScaleEnd = 1.0,yScaleStart = 1.0,yScaleEnd = 1.0,
					  	 	xStart = 0,yStart = 0,xEnd = 0,yEnd = 0, 
					   		rotationStart = 0,rotationEnd = 0}

--//	Reset a scene back to the default state.
--//	@display 		[container/group]		thing to reset.

function Transitioner:resetScene(display)
	if display == nil then return end
	local def = Transitioner.defaults
	display.alpha = def.alphaEnd
	display.xScale,display.yScale = def.xScaleEnd,def.yScaleEnd
	display.x,display.y = def.xEnd,def.yEnd 
	display.rotation = def.rotationEnd 
	display.isVisible = true
end 

--//	Support function for transition creations. It's purpose is to get the transition date (below) into the m_transitionLibrary table.

function Transitioner:define(name,fromTransition,toTransition,options)
	self.m_transitionLibrary[name:lower()] = { from = fromTransition, to = toTransition, concurrent = false }
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
