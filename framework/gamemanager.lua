--- ************************************************************************************************************************************************************************
---
---				Name : 		gamemanager.lua
---				Purpose :	Object which controls the game state and scenes.
---				Created:	23 July 2014
---				Updated:	24 July 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

local GameManager = Framework:createClass("game.manager")

--//	Construct a game manager object
--//	@info [table] 	constructor information.

function GameManager:constructor(info)
	assert(GameManager.s_instance == nil)														-- only one of these.
	GameManager.s_instance = self
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
	self.m_isLocked = false 																	-- not locked.
	self.m_associatedEventData = nil 															-- data passed to event.
	self.m_currentSceneInstance = nil 															-- reference to currently displayed scene
	self.m_transitioner = Framework:new("system.transition")									-- create transitioning object.
end

--//	Tidy up

function GameManager:destructor()
	if self.m_ownsController then self.m_controller:delete() end 								-- delete controller if we made it.
	GameManager.s_instance = nil 																-- instance no longer exists.
	self.m_controller = nil self.m_sceneInstances = nil self.m_associatedEventData = nil		-- nil references
	self.m_currentSceneInstance = nil
end 

--//	Add a state, a sceneManager instance and a series of events and targets - helper function.
--//	@stateName 				[string]	name of state
--//	@sceneManagerInstance 	[object]	sceneManager associated with scene
--//	@eventTarget 			[table]		events and targets, see system.fsm

function GameManager:addManagedState(stateName,sceneManagerInstance,eventTarget)
	self.m_controller:addState(stateName,eventTarget) 											-- add state information to FSM
	self:assignManager(stateName,sceneManagerInstance) 											-- remember scene manager instance for this state.
end 

--//	Assign a scene manager instance to a specific state.
--//	@stateName 				[string]	name of state
--//	@sceneManagerInstance 	[object]	sceneManager associated with scene

function GameManager:assignManager(stateName,sceneManagerInstance)
	assert(type(stateName) == "string") assert(type(sceneManagerInstance) == "table") 			-- validate parameters
	stateName = stateName:lower() 																-- case irrelevant
	assert(self.m_sceneInstances[stateName] == nil,"Duplicate sceneManager instance assigned") 	-- duplicate check
	self.m_sceneInstances[stateName] = sceneManagerInstance 									-- remember instance value.
end

--//	Start the game manager, go to first scene
--//	@startState 	[string]	First scene, defaults to 'start'

function GameManager:start(startState)
	assert(not self.m_isLocked,"start() called before transition completed.") 					-- check a state transition is not in progress,
	self.m_isLocked = true 																		-- it will now be locked
	self.m_controller:start(startState) 														-- pass start state to controlling object.
end 

--//	Handle message. These are sent by the controller object. While the transition is in progress the messaging, timers, updates are off
--//	@sender 	[object]	controller object
--//	@name 		[string]	name of message

function GameManager:onMessage(sender,name,body)
	if name == "enterState" then 																-- are we entering a new state ?
		self:startSceneTransition(body.newState,												-- start a transition to this state.
						body.eventData.transitionType,body.eventData.transitionTime) 			-- get the transition info from associated data.
	end
end 

--//	Start a transition to a new state
--//	@newState 		[string]		state to go to
--//	@transitionType [string]		transition type
--//	@transitionTime [number]		transition time in seconds

function GameManager:startSceneTransition(newState,transitionType,transitionTime)
	transitionType = transitionType or "fade" transitionTime = transitionTime or 0.75 			-- default transition stuff.
	self.m_newScene = self.m_sceneInstances[newState] 											-- get the new scene instance.
	assert(self.m_newScene ~= nil,"Scene "..newState.." does not have associated sceneManager")	-- check it has a scene manager instance.
	--print("Transition to "..newState,transitionType,transitionTime,self.m_newScene,self.m_currentSceneInstance)
	self.m_newScene:setEventData(self.m_associatedEventData or {})								-- tell it about the associated data.
	self.m_newScene:doPreOpen() 																-- do the pre-open on the new scene.
	if self.m_currentSceneInstance ~= nil then self.m_currentSceneInstance:doPreClose() end 	-- do the pre-close on the current scene if there was one.
	local fromContainer = self.m_currentSceneInstance 											-- get current scene
	if fromContainer ~= nil then fromContainer = fromContainer:getScene():getContainer() end 	-- if there is one, access its container
	self.m_transitioner:execute(fromContainer, 													-- run transitioner between these two scenes
								self.m_newScene:getScene():getContainer(),				
								transitionType,transitionTime, 									-- doing this
								self,"endSceneTransition") 										-- calling this afterwards.
end 

--//	Complete the transition practicalities after the visual transition has been done
--//	this method is called by the transitioner, see above.

function GameManager:endSceneTransition()
	if self.m_currentSceneInstance ~= nil then self.m_currentSceneInstance:doPostClose() end 	-- do the post close on the current scene if there was one.
	self.m_newScene:doPostOpen() 																-- do the post open on the new scene.
	self.m_currentSceneInstance = self.m_newScene self.m_newScene = nil 						-- update the current scene instance member variable
	self.m_isLocked = false 																	-- and we can now take transition changes again.
end

Framework:addObjectMethod("performGameEvent", function(self,eventName,eventData)
	if GameManager.s_instance.m_isLocked then return false end 									-- cannot transition, as a transition is in progress.
	GameManager.s_instance.m_isLocked = true 													-- now locked, a transition is in progress.
	GameManager.s_instance.m_associatedEventData = eventData or {} 								-- save the data associated with the call.
	GameManager.s_instance.m_controller:event(eventName) 										-- trigger an event, which should fire onMessage()
	return true
end)

-- TODO: Proper transitions.

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		23-Jul-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
