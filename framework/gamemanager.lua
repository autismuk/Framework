--- ************************************************************************************************************************************************************************
---
---				Name : 		gamemanager.lua
---				Purpose :	Object which controls the game state and scenes.
---				Created:	23 July 2014
---				Updated:	23 July 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

local GameManager = Framework:createClass("game.manager")

function GameManager:constructor(info)
	self.m_controller = info.controller 														-- get controller.
	self.m_ownsController = false 																-- did we create it.
	if self.m_controller == nil then 															-- if no controller, create an FSM.
		self.m_controller = Framework:new("system.fsm")
		self.m_ownsController = true
	end
	self.m_sceneInstances = {} 																	-- table of states -> scene instances.
	self.m_localTag = "gmlistener" .. tostring(self):gsub("%W","") 								-- create a unique identifier.
	self:tag(self.m_localTag) 																	-- tag us with it.
	self.m_controller:setBroadcastTag(self.m_localTag) 											-- and the controller to broadcast to it.
end

function GameManager:destructor()
	if self.m_ownsController then self.m_controller:delete() end 								-- delete controller if we made it.
	self.m_controller = nil self.m_sceneInstances = nil 										-- nil references
end 

function GameManager:addManagedState(stateName,sceneManagerInstance,eventTarget)
	self.m_controller:addState(stateName,eventTarget) 											-- add state information to FSM
	self:assignManager(stateName,sceneManagerInstance) 											-- remember scene manager instance for this state.
end 

function GameManager:assignManager(stateName,sceneManagerInstance)
	assert(type(stateName) == "string") assert(type(sceneManagerInstance) == "table") 			-- validate parameters
	stateName = stateName:lower() 																-- case irrelevant
	assert(self.m_sceneInstances[stateName] == nil,"Duplicate sceneManager instance assigned") 	-- duplicate check
	self.m_sceneInstances[stateName] = sceneManagerInstance 									-- remember instance value.
end

function GameManager:start(startState)
	self.m_controller:start(startState) 														-- pass start state to controlling object.
end 

function GameManager:onMessage(sender,name,body)
	print("MSG",name,body.triggerEvent,body.currentState,body.newState,body.eventData) 
end

Framework:addObjectMethod("performGameEvent", function(self,eventName,eventData)
	-- TODO: Figure out some way of getting the event data into the sceneManager instance.
	-- TODO: Handle onMessage enterStates as a reason to switch state, dummy transitions.
	-- TODO: Proper transitions.
	self.m_controller:event(eventName) 	
end)

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		23-Jul-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
