--- ************************************************************************************************************************************************************************
---
---				Name : 		controlobject.lua
---				Purpose :	Adapted Finite State Machine Object for Game control
---				Created:	21 July 2014
---				Updated:	21 July 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

local ControlObject = Framework:createClass("game.controlobject")

--//	Create a new Control Object
--//	@info 	[table] 	Unused

function ControlObject:constructor(info)
	self.m_fsm = Framework:new("system.fsm")													-- it wraps a FSM
	self.m_stateInformation = {} 																-- hold the rest of the state information
	self.m_sceneManager = {} 																	-- table of scene manangers.
	local uniqueTag = "ControlObject"..tostring(self):gsub("%W","")								-- create a unique tag for this control object
	self:tag(uniqueTag)																			-- tag the object with it.
	self.m_fsm:setBroadcastTag(uniqueTag) 														-- and set the FSM to broadcast to it.
end 


--//	Tidy up.

function ControlObject:destructor()
	self.m_fsm:delete() self.m_fsm = nil 														-- delete the FSM
	self.m_lastEventSender = nil self.m_stateInformation = nil self.m_sceneManager = nil 		-- nil out references.
	self.m_eventData = nil
end 

--//	Add a game state and its event/new state pairs.
--//	@stateName 		[string]		new state name
--//	@sceneManager 	[string/table]	class or instance associated with this game state.
--//	@eventTable 	[table] 		pairs of event / new state
--//	@return 		[object] 		self,chainable

function ControlObject:addState(stateName,sceneManager,eventTable)
	local eventFSM = {} 																		-- build an event/target table for the FSM.
	for k,v in pairs(eventTable) do eventFSM[k] = v.target end 									-- string pairs of events and targets.
	self.m_fsm:addState(stateName,eventFSM) 													-- add that into the FSM.
	stateName = stateName:lower() 																-- everything is in lower case.
	self.m_stateInformation[stateName] = eventTable 											-- store the full table (e.g. w/extra information)
	if type(sceneManager) == "string" then 														-- if scene Manager is class name
		sceneManager = Framework:new(sceneManager)												-- create an instance.
	end
	self.m_sceneManager[stateName] = sceneManager 												-- save the scene Manager for this event.
	return self
end 

--//	If it receives an 'event' message, then it applies that event to the FSM, and listens for the change.
--//	If it receives an enterState FSM message it sends it back out to the listener asked for in an event. 
--//	If it receives a leaveState FSM message it remembers which state it left.

function ControlObject:onMessage(sender,name,body)

	if name == "enterState" then 																-- on enetering a state.
		local newState = body.newState
		local newBody = { 
			sceneIdentifier = newState, 														-- scene alphanumeric identifier.
			sceneInstance = self.m_sceneManager[newState], 										-- state or class associated with the scene.
			sceneData = self.m_eventData, 														-- data associated with the event.
		}

		if self.m_previousState ~= nil then 													-- if there was a previous state.
			local info = self.m_stateInformation[self.m_previousState][self.m_eventName] 		-- get the information for that transition
			newBody.transitionType = info.transitionType										-- transition type (optional)
			newBody.transitionTime = info.transitionTime										-- transition time (optional)
		end

		self:sendMessage(self.m_lastEventSender,"notify",newBody)  								-- send message to game manager.
		self.m_eventData = nil self.m_lastEventSender = nil 									-- stop valuess being reused.
		self.m_previousState = nil self.m_eventName = nil 
	end

	if name == "leaveState" then 																-- on leaving a state
		self.m_previousState = body.currentState												-- remember the state left.
	end 

	if name == "event" then 
		assert(self.m_lastEventSender == nil,													-- if you send another message before it has processed this one
						"Event has been sent before Control Object Messaging system worked") 	-- it doesn't work. Should not normally be an issue.
		self.m_lastEventSender = body.notify 													-- remember who to send information to.
		self.m_eventData = body.data or {} 														-- remember data sent by it.
		self.m_eventName = body.name 															-- remember event that caused it.
		if body.name == nil or body.name == "" then 												-- is it the first event, e.g. start up.
			self.m_fsm:start()
		else 
			self.m_fsm:event(body.name)
		end

	end
end


--	What this does - event messages are sent to it. Those then are forwarded to the FSM, either in the form of start or event calls. Both of those generate
--	FSM messages, which are picked up asynchronously and sent back out to the interested object, the game manager.

--  The object remembers the last data and notifier. If another event message is in the queue before the leaveState/enterState has been processed, this will
-- 	cause an assertion. It is the responsibility of the controlling object (game.manager) not to forward performGameEvent() calls until it is ready (in practice, 
-- 	this means the notify message has been received and the objects have been transitioned on and off)

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		21-Jul-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
