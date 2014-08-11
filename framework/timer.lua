--- ************************************************************************************************************************************************************************
---
---				Name : 		timer.lua
---				Purpose :	timer object (sub part of Framework)
---				Created:	16 July 2014
---				Updated:	17 July 2014
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
						   timeToFire = period, 												-- time till next firing.
						   period = period, 													-- gaps between firing.
						   count = count - 1, 													-- how many fires remaining (hence -1)
						   tag = tag } 															-- tag for timer.
	self.m_timerList[#self.m_timerList+1] = newTimerItem 										-- add the new timer item
	self:sortTimerList() 																		-- sort list by fire time.
end

--//	Sort the timer items so the next triggered ones (e.g. earliest fire time) are up front.

function TimerClass:sortTimerList()
	table.sort(self.m_timerList, 
			   function(a,b) return a.timeToFire < b.timeToFire end)
end 

--//	Called every frame. Dispatches messages that are due.
--//	@deltaTime 	[number]				elapsed time in seconds

function TimerClass:onEnterFrame(deltaTime) 
	if #self.m_timerList == 0 then return end 													-- no timers.
	for _,ref in ipairs(self.m_timerList) do ref.timeToFire = ref.timeToFire - deltaTime end 	-- subtract delta time from all timers.
	while #self.m_timerList > 0 and self.m_timerList[1].timeToFire < 0 and 						-- is there something to fire ?
																	Framework:isAsyncEnabled() do
		local timerEvent = self.m_timerList[1] 													-- get the first event
		table.remove(self.m_timerList,1) 														-- remove it from the timer list.
		Framework:perform({ soleitem = timerEvent.target },"onTimer",timerEvent.tag)			-- fire the timer event for just that one object.
		if timerEvent.count ~= 0 and timerEvent.target:isAlive() then 							-- if count is nonzero, e.g. there are more to fire & not dead.
			timerEvent.count = timerEvent.count - 1 											-- decrement counter, hence use of -1 for forever.
			assert(timerEvent.period > 0.01,"timer periods cannot be very small") 				-- will just cause endless loop firing.
			timerEvent.timeToFire = timerEvent.period 											-- work out next fire time.
			self.m_timerList[#self.m_timerList+1] = timerEvent 									-- add the timer event back to the queue
			self:sortTimerList() 																-- make sure it is in order.
		end
	end
end

--//	Cancel a timer, using the tag to identify it.
--//	@target 	[object] 			who the timer event is for
--//	@tag 		[string]			timer identification tag (not optional)

function TimerClass:cancelTimer(target,tag)
	assert(type(tag) == "string","timer tag should be a string")								-- validate tag.
	repeat 																						-- keep going until nothing removed.
		local hasRemoved = false  																-- set to true if something was removed.
		for index,ref in ipairs(self.m_timerList) do 											-- work through the objects
			if ref.target == target and ref.tag == tag then 									-- found a match.
				hasRemoved = true 																-- removed one.
				table.remove(self.m_timerList,index) 											-- actually remove it.
				break 																			-- exit the for loop.
			end 
		end
	until not hasRemoved 																		-- until haven't removed something
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
