--- ************************************************************************************************************************************************************************
---
---				Name : 		fsm.lua
---				Purpose :	Basic Finite State Machine Object
---				Created:	19 July 2014
---				Updated:	20 July 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

local FSMachine = Framework:createClass("system.fsm")

--//	Create a new FSM
--//	@info 	[table] 	Unused

function FSMachine:constructor(info)
	self.m_states = {} 																			-- defined states.
	self.m_currentState = nil 																	-- current state
	self.m_broadcastTag = "fsmListener"															-- messages by default sent out on this.
end 


--//	Tidy up.

function FSMachine:destructor()
	self.m_states = nil 
end 

--//	Add a state and its event/new state pairs.
--//	@stateName 	[string]		new state name
--//	@eventTable [table] 		pairs of event / new state
--//	@return 	[object] 		self,chainable

function FSMachine:addState(stateName,eventTable)
	eventTable = eventTable or {} 																-- events are not required.
	assert(type(stateName) == "string" and #stateName > 0,"Bad state name") 					-- validate
	assert(type(eventTable) == "table")
	stateName = stateName:lower() 							 									-- caps do not matter.
	assert(self.m_states[stateName] == nil,"Duplicate state name "..stateName) 					-- check for duplication.
	self.m_states[stateName] = {} 																-- no events defined yet.
	for event,state in pairs(eventTable) do 													-- work through the event/state pairs.
		assert(type(event) == "string")
		if type(state) == "string" then state = { target = state:lower() } end 					-- convert string target to table
		event = event:lower() 																	-- make event lower case.
		assert(self.m_states[stateName][event] == nil,"Duplicate event "..event)				-- check doesn't already exist.
		self.m_states[stateName][event] = state 												-- put in table.
	end
	return self
end 

--//	Set broadcast tag
--//	@tagName 	[string]		New broadcast tag, defaults to fsmListener
--//	@return 	[object] 		self,chainable

function FSMachine:setBroadcastTag(tagName)
	tagName = tagName or "fsmListener" 															-- default value
	assert(type(tagName) == "string")
	self.m_broadcastTag = tagName 																-- update the broadcast tag.
	return self
end 

--//	Start the FSM
--//	@startState [string]		State to start from, defaults to 'start'.

function FSMachine:start(startState)
	startState = startState or "start" assert(type(startState) == "string")						-- default is start, and check.
	assert(self.m_currentState == nil,"FSM Already started")									-- check not started already.
	assert(self.m_states[startState] ~= nil,"Unknown state "..startState)						-- check it exists
	for _,state in pairs(self.m_states) do 														-- work through all states
		for _,target in pairs(state) do 	 													-- work through all event/state pairs
			assert(self.m_states[target.target] ~= nil,"State does not exist "..target.target)	-- checking the target state exists
		end 
	end
	self.m_currentState = startState 															-- set current state
	self:sendMessage(self.m_broadcastTag,"enterState", 											-- send first enter state message.
						{ currentState = startState, newState = startState, eventData = {} }) 	-- there is no data, no leaving state.
end 

--//	Process an FSM event - find the new state and send the asynchronous messages.
--//	@event 	[string] 	FSM event to cause a state transition.

function FSMachine:event(event)
	assert(type(event) == "string","Bad event")													-- check event.
	event = event : lower() 																	-- not interested in case.
	assert(self.m_states[self.m_currentState][event] ~= nil,									-- check it actually exists as a transition
									"Unknown event "..event.." for state "..self.m_currentState)
	local eventData = self.m_states[self.m_currentState][event] 								-- data associated with this event.
	local newState = self.m_states[self.m_currentState][event].target 							-- the next state
	self:sendMessage(self.m_broadcastTag,"leaveState",
						{ currentState = self.m_currentState, newState = newState, triggerEvent = event, eventData = eventData })
	self.m_currentState = newState 																-- set up new state.
	self:sendMessage(self.m_broadcastTag,"enterState",
						{ currentState = self.m_currentState, newState = self.m_currentState, triggerEvent = event, eventData = eventData })
end 

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		19-Jul-14	0.1 		Initial version of file
		14-Aug-14 	1.0 		Advance to releasable version 1.0

--]]
--- ************************************************************************************************************************************************************************
