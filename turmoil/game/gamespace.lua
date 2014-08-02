--- ************************************************************************************************************************************************************************
---
---				Name : 		gamespace.lua
---				Purpose :	Object representing play area
---				Created:	2 August 2014
---				Updated:	2 August 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

local GameSpace = Framework:createClass("game.gamespace")

function GameSpace:constructor(info)
	self.m_headerSize = info.header or 0 														-- extract out parameters.
	self.m_channelCount = info.channels or 7 
	self.m_currentLevel = info.level or 1
	self.m_borderSize = 2 																		-- width of border.
	self.m_borderList = {} 																		-- list of border objects
	self:addBorder(0,display.contentWidth,0) 													-- top and bottom borders.
	self:addBorder(0,display.contentWidth,display.contentHeight - 				
												self.m_headerSize - 1 - self.m_borderSize)
	self.m_channelSize = math.floor((display.contentHeight - self.m_borderSize 					-- size of each channel
												- self.m_headerSize) / self.m_channelCount)
	self.m_spriteSize = self.m_channelSize - self.m_borderSize 									-- size of each sprite (w and h)
	self.m_channelObjects = {} 																	-- object in each channel, or nil if empty.
	self.m_channelObjectCount = 0 																-- number of objects in channels in total.

	for c = 1,self.m_channelCount-1 do  														-- create channels.
		local y = self.m_borderSize + self.m_channelSize * c 
		self:addBorder(0,display.contentWidth/2-self.m_channelSize,y)
		self:addBorder(display.contentWidth,display.contentWidth/2+self.m_channelSize,y)
	end
	display.getCurrentStage():addEventListener("tap",self)										-- listen for taps.
end

function GameSpace:destructor()
	display.getCurrentStage():removeEventListener("tap",self)									-- stop listening for taps.
	for c = 1,self.m_channelCount do 															-- delete any objects that haven't been deleted.
		if self.m_channelObjects[c] ~= nil then 
			self.m_channelObjects[c]:delete()
		end 
	end 
	for _,ref in ipairs(self.m_borderList) do ref:removeSelf() end 
	self.m_borderList = nil
end 

--//	Add a single border part to the gamespace - this is purely visual.
--//	@x1 	[number]		horizontal position
--//	@x2 	[number]		horizontal position
--//	@y 		[number]		vertical position (advert space is added)

function GameSpace:addBorder(x1,x2,y)
	local line = display.newLine(x1,y+self.m_headerSize,x2,y+self.m_headerSize) 				-- create line, offset for advert
	line:setStrokeColor(0,0,1) line.strokeWidth = 2 											-- set it up.
	self.m_borderList[#self.m_borderList+1] = line  											-- add it to the object list.
end 

--//	Get a list of display objects in this scene.
--//	@return [list]			list of display objects.

function GameSpace:getDisplayObjects() 
	return self.m_borderList 
end 

--//	Assign an object to a random channel.
--//	@object  	[enemy object]	object to assign.
--//	@return 	[number]		channel number or nil if cannot assign.

function GameSpace:assignChannel(object)
	if self.m_channelObjectCount == self.m_channelCount then return nil end 					-- return nil if no space available.
	local c
	repeat c = math.random(1,self.m_channelCount) until self.m_channelObjects[c] == nil 		-- find an empty channel.
	self.m_channelObjects[c] = object 															-- put object in channel.
	return c 																					-- return channel number.
end 

--//	Deassign an object from its channel
--//	@object 	[enemyObject]	object to remove.

function GameSpace:deassignChannel(object)
	for i = 1,#self.m_channelCount do 															-- work through all channels.
		if self.m_channelObjects[i] == object then 												-- found the relevant object ?
			self.m_channelObjects[i] = nil 														-- mark channel as empty.
			return 																				-- and exit
		end 
	end 
	error("Cannot deassign gamespace channel")													-- object was not found.
end 

--//	Check to see if a channel is occupied
--//	@channel 	[number]		Channel number
--//	@return 	[boolean]		true if channel is occupied.

function GameSpace:isChannelInUse(channel)
	return self.m_channelObjects[channel] ~= nil 
end 

--//	Check to see if any channel is available, e.g. the game space is not full.
--//	@return 	[boolean]		true if there is at least one empty channel.

function GameSpace:isAnyChannelAvailable()
	return self.m_channelObjectCount < self.m_channelCount 
end 

--//	Convert logical position to physical position.
--//	@xPercent 	[number]		Percentage across l->r
--//	@yChannel 	[number]		Channel Number
--//	@return 	[number,number]	Physical coordinates.

function GameSpace:getPos(xPercent,yChannel)
	return xPercent * display.contentWidth / 100, self.m_channelSize * (yChannel - 0.5)+ self.m_headerSize
end 

--//	Handle tap messages, convert to the logical system.
--//	@event 		[event]			Event Data
--//	@return 	[boolean]		True as processed.

function GameSpace:tap(event)
	local x = math.min(100,math.max(0,event.x / display.contentWidth * 100))					-- Work out logical X
	local y = event.y - self.m_borderSize - self.m_headerSize  									-- Work out y offset
	if y >= 0 then  																			-- if in game area
		y = math.min(math.floor(y/self.m_channelSize)+1,self.m_channelCount) 					-- work out channel.
		self:sendMessage("taplistener","tap",{ x = x, y = y })									-- tell all listeners about it.
		return true 																			-- message processed.
	end
	return false
end

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		2-Aug-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************