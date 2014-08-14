--- ************************************************************************************************************************************************************************
---
---				Name : 		particle.lua
---				Purpose :	Particle Classes ported from Executive
---				Created:	14 July 2014
---				Updated:	06 August 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

--- ************************************************************************************************************************************************************************
--																						Basic Emitter Class
--- ************************************************************************************************************************************************************************

local Emitter = Framework:createClass("graphics.particle")

local JSONInstance = require("json") 														-- instance of json required to decode effects
local effectsFolder = "effects" 															-- effects folder

--//	Create a new emitter using the emitter file given
--//	@emitterFile [string] 		Name of emitter file in folder, without .json suffix

function Emitter:constructor(info)
	self.emitterFile = info.emitter  														-- save emitter file name
	self.scale = info.scale or 1 															-- save scale, default to 1
	if self.emitterFile ~= nil then  														-- if one provided, load it.
		self:loadParameters(self.emitterFile)
	end
	if info.x ~= nil and info.y ~= nil then self:start(info.x,info.y) end 					-- auto start it if x,y provided
end

--//	Start an emitter 
--//	@x 	[number] 				Where to start it
--//	@y 	[number]				Where to start it
--//	@return [Emitter]			Chaining option

function Emitter:start(x,y)
	assert(self.emitter == nil,"Emitter started twice")
	self.emitter = display.newEmitter(self.emitterParams) 									-- create a new emitter
	self.emitter.x,self.emitter.y = x,y  													-- move it
	self.emitter.xScale,self.emitter.yScale = self.scale,self.scale 						-- scale it.
	return self
end 

--//	Destroy an emitter

function Emitter:destructor() 
	self.emitter:removeSelf() 																-- remove it
end

--//%	Load a parameter file

function Emitter:loadParameters()	
	local filePath = system.pathForFile(effectsFolder .. "/" .. 							-- the file to load with the parameters
															self.emitterFile .. ".json")
	local handle = io.open(filePath,"r") 													-- read it in.
	local fileData = handle:read("*a")
	handle:close()
	self.emitterParams = JSONInstance.decode(fileData) 										-- convert from JSON to LUA
	self:fixParameter("textureFileName") 													-- update files used with full path.
end 

--//%	Fix an effects parameter parameter (er..) by giving it the full effects folder path
--//	@paramName [string] 	parameter to fix 

function Emitter:fixParameter(paramName)
	if self.emitterParams[paramName] ~= nil then  											-- if present
		self.emitterParams[paramName] = effectsFolder .. "/" .. 							-- fix it
																self.emitterParams[paramName]	
	end
end

--- ************************************************************************************************************************************************************************
--													This emitter class self-destructs after a given time period
--- ************************************************************************************************************************************************************************

local ShortEmitter = Framework:createClass("graphics.particle.short","graphics.particle")

--//	Create a new emitter using the emitter file given
--//	@emitterFile [string] 		Name of emitter file in folder, without .json suffix
--//	@timeFrame [number]			Period of emitter life, if you don't want to use the duration parameter

function ShortEmitter:constructor(info)
	self.timeFrame = info.time * 1000														-- copy and scale from seconds to milliseconds
	Emitter.constructor(self,info) 															-- call super constructor.
end 

--//	Start an emitter 
--//	@x 	[number] 				Where to start it
--//	@y 	[number]				Where to start it
--//	@return [Emitter]			Chaining option

function ShortEmitter:start(x,y)
	Emitter.start(self,x,y) 																-- start via superclass
	timer.performWithDelay( self.timeFrame, function() self:timeOut() end) 					-- tell it to self destruct after that time.
end 

--//	Function called when timer times out.

function ShortEmitter:timeOut()
	self:delete()																			-- stop after timeout
end 


--- ************************************************************************************************************************************************************************
--												Looping Particle Emitter. Continually restarts until told not to
--- ************************************************************************************************************************************************************************

local LoopingShortEmitter = Framework:createClass("graphics.particle.looping","graphics.particle.short")

--//	Create a new emitter using the emitter file given
--//	@emitterFile [string] 		Name of emitter file in folder, without .json suffix
--//	@timeFrame [number]			Period of emitter life, if you don't want to use the duration parameter

function LoopingShortEmitter:constructor(info)
	ShortEmitter.constructor(self,info)
	self.isCancelled = false 																-- set this to cancel it.
end

--//	Subclassed timeout which either kills or restarts the emitter dependent on the time.

function LoopingShortEmitter:timeOut()
	if self.isCancelled then  																-- if cancelled then self destruct
		ShortEmitter.timeOut(self)
	else  																					-- otherwise restart
		local x,y = self.emitter.x,self.emitter.y 											-- remember where it is
		self.emitter:removeSelf() 															-- destroy the actual emitter
		self.emitter = nil 																	-- stops start complaining its been started twice
		self:start(x,y) 																	-- and restart it
	end 
end 

--//	Stop a looping emitter. Physically stops the display,and the object and timer will self destruct the net time we call timeOut()

function LoopingShortEmitter:cancel()
	self.emitter:stop() 																	-- stop it being delayed
	self.isCancelled = true 																-- on the next time out it will actually stop & clear up
end 

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		06-Aug-14	0.1 		Initial version of file
		14-Aug-14 	1.0 		Advance to releasable version 1.0

--]]
--- ************************************************************************************************************************************************************************

