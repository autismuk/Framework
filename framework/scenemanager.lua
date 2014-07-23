--- ************************************************************************************************************************************************************************
---
---				Name : 		scenemanager.lua
---				Purpose :	Scene Manager class, used as a base class for Scene Manager instances.
---				Created:	20 July 2014
---				Updated:	22 July 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

local SceneManager = Framework:createClass("game.scenemanager")

--//	Create a new Game Scene Manager
--//	@info 	[table] 	Unused

function SceneManager:constructor(info)
	self.msm_resources = {} 																	-- resources associated with this.
	self:resourceConstructor(self.msm_resources) 												-- construct the resources.
	self.msm_info = info or {}																	-- save the base information passed in.
	self:setEventData({})																		-- event data is initially empty.
end

--//	Tidy up.

function SceneManager:destructor()
	self:resourceDestructor(self.msm_resources) 												-- destruct resources
	self.msm_resources = nil 																	-- clear references.
	self.msms_scene = nil self.msm_data = nil self.msm_info = nil 
end 


--//	Set the associated event data, combined with the info table passed into the constructor
--//	@data 	[table]		event provided data.

function SceneManager:setEventData(data)
	self.msm_data = {}
	for k,v in pairs(self.msm_info) do self.msm_data[k] = v end 								-- copy the constructor data in first
	for k,v in pairs(data) do self.msm_data[k] = v end 											-- then any data passed as part of the event.
end 

--//	Get the scene associated with the scene manager instance
--//	@return 	[object]		Scene object

function SceneManager:getScene()
	return self.msm_scene 
end 

--//%	Pre-Open code

function SceneManager:doPreOpen()
	Framework:setEnterFrameEnabled(false) 														-- stop enter frame, effectively pausing everything.
	self.msm_scene = self:preOpen(self,self.msm_data,self.msm_resources) 						-- call pre-open to create scene.
end 

--//%	Post-Open code

function SceneManager:doPostOpen() 
	self:postOpen(self.msm_scene,self,self.msm_data,self.msm_resources) 						-- call post open, which usually does nothing.
	Framework:setEnterFrameEnabled(true) 														-- start everything off.
end 

--//%	Pre-Close Code

function SceneManager:doPreClose()
	Framework:setEnterFrameEnabled(false) 														-- stop enter frame, effectively pausing everything.
	self:preClose(self.msm_scene,self,self.msm_data,self.msm_resources) 						-- call pre-close, which usually does nothing.
end 

--//%	Post-Close Code 

function SceneManager:doPostClose()
	self:postClose(self.msm_scene,self,self.msm_data,self.msm_resources) 						-- call post-close, which usually does nothing.
	self.msm_scene:delete() 																	-- delete the scene, which is no longer required.
	self.msm_scene = nil 																		-- nil the reference.
	Framework:setEnterFrameEnabled(true) 														-- turn enterFrame back on.
end

--//	Create/Load resources
--//	@rt 	[table] 	Resource table

function SceneManager:resourceConstructor(rt) end 												

--//	Free/Tidy up resources
--//	@rt 	[table] 	Resource table

function SceneManager:resourceDestructor(rt) end 												

--//	Handler for preOpen event, creates a new scene, before starting to transition it on.
--//	@manager 	[object]		manager controlling it.
--//	@data 		[table]			control data passed by event
--//	@resources 	[table]			Resource table
--//	@return 	[object]		game.scene object

function SceneManager:preOpen(manager,data,resources) 
	error("SceneManager is an abstract class. preOpen() must be implemented.")
end 											

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
