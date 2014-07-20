--- ************************************************************************************************************************************************************************
---
---				Name : 		scenemgr.lua
---				Purpose :	Scene Manager class, used as a base class for Scene Manager instances.
---				Created:	20 July 2014
---				Updated:	20 July 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

local SceneManager = Framework:createClass("game.scenemanager")

--//	Create a new Game Scene Manager
--//	@info 	[table] 	Unused

function SceneManager:constructor(info)
	self.m_resources = {} 																		-- resources associated with this.
	self:resourceConstructor(self.m_resources) 													-- construct the resources.
	self.m_info = info or {}																	-- save the base information passed in.
	self:setEventData({})																		-- event data is initially empty.
end

--//	Tidy up.

function SceneManager:destructor()
	self:resourceDestructor(self.m_resources) 													-- destruct resources
	self.m_resources = nil 																		-- clear references.
	self.m_scene = nil self.m_data = nil self.m_info = nil 
end 


--//	Set the associated event data, combined with the info table passed into the constructor
--//	@data 	[table]		event provided data.

function SceneManager:setEventData(data)
	self.m_data = data 																			-- set data from data.
	setmetatable(self.m_data,self.m_info) 														-- use the base info passed in as a metatable
	self.m_info.__index = self.m_info 															-- so you can access both information, event data overrides
end 

--//%	Pre-Open code

function SceneManager:doPreOpen()
	self.m_scene = Framework:new("game.scene")													-- create a new game scene
	Framework:setEnterFrameEnabled(false) 														-- stop enter frame, effectively pausing everything.
	self:preOpen(self.m_scene,self,self.m_data) 												-- call pre-open to create scene.
end 

--//%	Post-Open code

function SceneManager:doPostOpen() 
	self:postOpen(self.m_scene,self,self.m_data) 												-- call post open, which usually does nothing.
	Framework:setEnterFrameEnabled(true) 														-- start everything off.
end 

--//%	Pre-Close Code

function SceneManager:doPreClose()
	Framework:setEnterFrameEnabled(false) 														-- stop enter frame, effectively pausing everything.
	self:preClose(self.m_scene,self,self.m_data) 												-- call pre-close, which usually does nothing.
end 

--//%	Post-Close Code 

function SceneManager:doPostClose()
	self:postClose(self.m_scene,self,self.m_data) 												-- call post-close, which usually does nothing.
	self.m_scene:delete() 																		-- delete the scene, which is no longer required.
	self.m_scene = nil 																			-- nil the reference.
	Framework:setEnterFrameEnabled(true) 														-- turn enterFrame back on.
end

--//	Create/Load resources
--//	@rt 	[table] 	Resource table

function SceneManager:resourceConstructor(rt) end 												

--//	Free/Tidy up resources
--//	@rt 	[table] 	Resource table

function SceneManager:resourceDestructor(rt) end 												

--//	Handler for preOpen event, creates a new scene, before starting to transition it on.
--//	@scene 		[object]		game.scene object being worked on
--//	@manager 	[object]		manager controlling it.
--//	@data 		[table]			control data passed by event
--//	@resources 	[table]			Resource table

function SceneManager:preOpen(scene,manager,data,resources) end 											

--//	Handler for preOpen event, called when scene displayed on stage but has not been started
--//	@scene 		[object]		game.scene object being worked on
--//	@manager 	[object]		manager controlling it.
--//	@data 		[table]			control data passed by event
--//	@resources 	[table]			Resource table

function SceneManager:postOpen(scene,manager,data,resources) end 											

--//	Handler for preClose event, called when scene has been exited but it is still visible, about to be transitioned off.
--//	@scene 		[object]		game.scene object being worked on
--//	@manager 	[object]		manager controlling it.
--//	@data 		[table]			control data passed by event
--//	@resources 	[table]			Resource table

function SceneManager:preClose(scene,manager,data,resources) end 											

--//	Handler for postClose event, called when scene transitioned off and about to be deleted.
--//	@scene 		[object]		game.scene object being worked on
--//	@manager 	[object]		manager controlling it.
--//	@data 		[table]			control data passed by event
--//	@resources 	[table]			Resource table

function SceneManager:postClose(scene,manager,data,resources) end 											

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		20-Jul-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
