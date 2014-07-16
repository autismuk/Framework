--- ************************************************************************************************************************************************************************
---
---				Name : 		timer.lua
---				Purpose :	timer object (sub part of Framework)
---				Created:	16 July 2014
---				Updated:	16 July 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

local TimerClass = Framework:createClass("system.timer")

--//	Construct the timer object.

function TimerClass:constructor(info)
	self:tag("enterFrame") 																		-- tag as enter frame so called every frame
	self.m_timerList = {}  																		-- timer event list
end

--//	Destroy the timer object.

function TimerClass:destructor() 
	self.m_timerList = nil 
end 

--//	Add a new timer event
--//	@target 	[object] 			who the event is for
--//	@period 	[number]			time period of event, in seconds
--//	@count 		[number]			number of times to fire in total
--//	@tag 		[string]			timer identification tag.

function TimerClass:add(target,period, count, tag)
	tag = tag or "" 																			-- default tag.
	assert(type(period) == "number","Period should be numeric")									-- validation.
	assert(type(count) == "number","Count should be numeric")
	assert(type(tag) == "string","Tag should be a string")

	local newTimerItem = { target = target,														-- who gets the message
						   fireTime = system.getTimer() / 1000 + period, 						-- when it next fires
						   period = period, 													-- gaps between firing.
						   count = count - 1, 													-- how many fires remaining (hence -1)
						   tag = tag } 															-- tag for timer.
	self.m_timerList[#self.m_timerList+1] = newTimerItem 										-- add the new timer item
	self:sortTimerList() 																		-- sort list by fire time.
end

--//	Sort the timer items so the next triggered ones (e.g. earliest fire time) are up front.

function TimerClass:sortTimerList()
	table.sort(self.m_timerList, 
			   function(a,b) return a.fireTime < b.fireTime end)
end 

--//	Called every frame. Dispatches messages that are due.
--//	@deltaTime 	[number]				elapsed time in seconds
--//	@currentTime [number]				current time in seconds

function TimerClass:onEnterFrame(deltaTime,currentTime) 
	-- While still timer due.
	-- Remove from front.
	-- Fire it
	-- Reinsert it if some time left.
end


--//	Cancel a timer.
--//	@target 	[object] 			who the timer event is for
--//	@tag 		[string]			timer identification tag.

function TimerClass:cancelTimer(target,tag)
	-- Validate tag
	-- Look for matching timer(s) and remove them.
end 

local timerInstance = Framework:new("system.timer",{})											-- create an instance of the messaging class.

Framework:addObjectMethod("addSingleTimer", function(self,period,tag) 							-- add mixin methods.
		timerInstance:add(self,period,1,tag)
	end)

Framework:addObjectMethod("addRepeatingTimer", function(self,period,tag)
		timerInstance:add(self,period,-1,tag)
	end)

Framework:addObjectMethod("addMultiTimer", function(self,period,count,tag)
		timerInstance:add(self,period,count,tag)
	end)

Framework:addObjectMethod("cancelTimer",function(self,tag)
		timerInstance:cancelTimer(self,tag)
	end)

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		16-Jul-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
