--- ************************************************************************************************************************************************************************
---
---				Name : 		gui.lua
---				Purpose :	Simple Gui Objects
---				Created:	12 August 2014
---				Updated:	12 August 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

--- ************************************************************************************************************************************************************************
--//													Button that sends a message when clicked, uses an image
--- ************************************************************************************************************************************************************************

local IconButton = Framework:createClass("gui.icon")

--//	Create a new button
--//	@info 	[table]			Constructor information

function IconButton:constructor(info)
	self.m_image = display.newImage(info.image,0,0) 											-- create button
	self.m_image.anchorX,self.m_image.anchorY = 0.5,0.5
	self.m_image.width = (info.width or 10) * display.contentWidth/100
	self.m_image.height = (info.height or info.width or 10) * display.contentWidth / 100
	self.m_image.x,self.m_image.y = info.x * display.contentWidth/100,info.y * display.contentHeight/100
	self.m_listenerObject = info.listener 														-- remember who to tell and what to send
	self.m_listenerMessage = info.message or "click"
	self.m_image:addEventListener("tap",self) 													-- add an event listener
end 

--//	Tidy up

function IconButton:destructor()
	self.m_image:removeEventListener("tap",self) 												-- remove an event listener and null refs
	self.m_image:removeSelf() self.m_image = nil self.m_listenerObject = nil
end 

--//	Handle tap events
--//	@event 	[table]		Corona Event structure

function IconButton:tap(event)
	if self.m_listenerObject ~= nil then 														-- if something to send to.
		self:sendMessage(self.m_listenerObject,self.m_listenerMessage,{}) 						-- on click, send the message
	end
	return true
end

function IconButton:getDisplayObjects() 
	return { self.m_image }
end 

--- ************************************************************************************************************************************************************************
--//																	Button as above, but pulses to show it is active
--- ************************************************************************************************************************************************************************

local IconButtonPulse,SuperClass = Framework:createClass("gui.icon.pulsing","gui.icon")

--//	Handle update message (requires scene membership)
--//	@deltaTime 	[number] 	Elapsed time in seconds 

function IconButtonPulse:onUpdate(deltaTime)
	self.m_clock = (self.m_clock or 0) + deltaTime 												-- keep track of time
	local scale = math.sin(self.m_clock * 3) * 0.2 + 1 											-- work out the pulsing
	self.m_image.xScale,self.m_image.yScale = scale,scale  										-- and adjust the scale.
end 

--- ************************************************************************************************************************************************************************
--//												Active Text is text that does something when clicked, e.g. set up options
--- ************************************************************************************************************************************************************************

local ActiveText = Framework:createClass("gui.text")

--//	Create active text object
--//	@info 	[table]			Constructor information

function ActiveText:constructor(info)
	self.m_text = display.newBitmapText(info.text or "?", 										-- create initial text
										info.x * display.contentWidth / 100,
										info.y * display.contentHeight / 100,
										info.font.name,info.font.size or 64)
	if info.tint then  																			-- tint it if provided
		self.m_text:setTintColor(info.tint[1],info.tint[2],info.tint[3])
	end
	self.m_listener = info.listener 															-- remember target and message
	self.m_message = info.message or "click"
	self.m_text:addEventListener("tap",self)													-- add event listener
	self.m_pulseOnClick = info.pulse 															-- set up pulse on click and vibration (to make noticeable)
	self.m_vibration = info.vibration
	if self.m_pulseOnClick == nil then self.m_pulseOnClick = true end 							-- both default to on
	if self.m_vibration == nil then self.m_vibration = true end 
	self.m_wobbleTime = 0
	self.m_yOriginal = self.m_text.y 															-- wobbling, need to know where it actually should be.
end 

--//	Tidy up

function ActiveText:destructor()
	self.m_text:removeEventListener("tap",self)													-- remove listener
	self.m_text:removeSelf() 																	-- remove object.
	self.m_text = nil self.m_listener = nil 													-- null references
end 

--//	Handle tap events
--//	@event 	[table]		Corona Event structure

function ActiveText:tap(event)
	if self.m_pulseOnClick then 																-- are we pulsing on click
		transition.to(self.m_text,{ time = 100,xScale = 1.1,yScale = 1.1, 						-- then do so.
		onComplete = function(e) transition.to(e, { time = 100,xScale = 1,yScale = 1}) end })
	end 
	if self.m_listener ~= nil then 																-- something listening ?
		self:sendMessage(self.m_listener,self.m_message,{})										-- send a message.
    end
	return true
end 

function ActiveText:getDisplayObjects()
	return { self.m_text }
end 

--//	Animate active text - wobbles a little every few seconds to indicate it is active.
--//	@deltaTime 	[number] 	Elapsed time in seconds 

function ActiveText:onUpdate(deltaTime)
	self.m_wobbleTime = self.m_wobbleTime - deltaTime 											-- keep track of time
	if self.m_wobbleTime < 0.25 and self.m_vibration then  										-- wobble in the last quarter second
		local w = math.floor(self.m_wobbleTime * 100) % 10 - 5
		self.m_text.y = self.m_yOriginal + w 
	end 
	if self.m_wobbleTime <= 0 then 																-- time out 	
		self.m_wobbleTime = math.random(200,400) / 100 											-- reset timer to 2-4 seconds
		self.m_text.y = self.m_yOriginal 														-- back to original position.
	end
end

--- ************************************************************************************************************************************************************************
--							Abstract class which can be used to display rotating text options, e.g. click to change the selected value
--- ************************************************************************************************************************************************************************

local ActiveTextRotateAbstract,SuperClass = Framework:createClass("gui.text.rotate.abstract","gui.text")

--//	Create Object
--//	@info 	[table]			Constructor information

function ActiveTextRotateAbstract:constructor(info)
	self.m_current = 1 																			-- currently displayed object
	SuperClass.constructor(self,info) 															-- call the constructor
	self.m_text:setText(self:getEntry(self.m_current)) 											-- update the current text value
end 

--//	Dummy getEntry() method which should be overridden
--//	@n 		[number]		Entry number
--//	@return [string]		Text to display or nil if past end of selections.

function ActiveTextRotateAbstract:getEntry(n)
	if n > 3 then return nil else return "Abstract "..n end 									-- return values for 1,2,3
end

--//	Handle tap events
--//	@event 	[table]		Corona Event structure

function ActiveTextRotateAbstract:tap(event)
	self.m_current = self.m_current + 1 														-- bump current
	local newText = self:getEntry(self.m_current) 												-- get text
	if newText == nil then  																	-- if nil, back to first
		self.m_current = 1
		newText = self:getEntry(1)
	end 
	self.m_text:setText(newText) 																-- update text
	self:updateFont(self.m_current,self.m_text) 												-- allow update of font, say colour.
	SuperClass.tap(self,event) 																	-- call the message sender superclass
end

--//	Return current selection as an integer
--//	@return 	[number]		Selected entry, 1,2,3 .....

function ActiveTextRotateAbstract:getSelected()
	return self.m_current 
end 

--//	Allow modification of text object (e.g. change colour)
--//	@currentEntry 	[number]	index of current entry
--//	@textObject 	[object]	fontmanager object

function ActiveTextRotateAbstract:updateFont(currentEntry,textObject) end 

--- ************************************************************************************************************************************************************************
--//	Text object which rotates through a list of selections when clicked
--- ************************************************************************************************************************************************************************

local ActiveTextList,SuperClass = Framework:createClass("gui.text.list","gui.text.rotate.abstract")

--//	@info 	[table]			Constructor information

function ActiveTextList:constructor(info)
	self.m_items = info.items 																	-- preserve the list of items
	SuperClass.constructor(self,info) 															-- call super constructor
end

--//	Get the current list entry
--//	@n 		[number]		Entry number
--//	@return [string]		Text to display or nil if past end of selections.

function ActiveTextList:getEntry(n)
	return self.m_items[n]
end

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		12-Aug-14	0.1 		Initial version of file
		14-Aug-14 	1.0 		Advance to releasable version 1.0

--]]
--- ************************************************************************************************************************************************************************