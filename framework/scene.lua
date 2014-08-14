--- ************************************************************************************************************************************************************************
---
---				Name : 		scene.lua
---				Purpose :	Framework Scene Class
---				Created:	17 July 2014
---				Updated:	17 July 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

local Scene,SuperClass = Framework:createClass("game.scene","system.collection")				-- create collection class.


--//	Construct a scene, which is a collection with updating and a possible global container.
--//	@info 	[table]		Initialisation info (ignored)

function Scene:constructor(info)
	SuperClass.constructor(self,info)
	self.m_container = nil
	self:tag("enterFrame")
end 

--//	Handle enterFrame message, dispatch to all collection objects which implement onUpdate()
--//	@deltaTime [number]		elapsed time in seconds

function Scene:onEnterFrame(deltaTime)
	local count,hash = self:getCollection() 													-- get the collection objects
	if count == 0 then return end  																-- exit if nothing
	for _,ref in pairs(hash) do 																-- work through them
		if ref.onUpdate ~= nil and Framework:isAsyncEnabled() then 								-- perform onUpdate() on them if they implement it.
			ref:onUpdate(deltaTime) 
		end 			
	end
end 

--//	Create a new object, add to the collection, and check for a getDisplayObjects() method.
--//	@className 	[string/object] 				Name of class to create instance of or prototype object.
--//	@data 		[table]							Optional instantiation data (is passed to constructor as {} if nil)

function Scene:new(className,data) 
	local newObject = SuperClass.new(self,className,data) 										-- create a new object
	if newObject.getDisplayObjects ~= nil then  												-- does it have a getDisplayObjects() method
		local objects = newObject:getDisplayObjects() 											-- if so get them
		local container = self:getContainer() 													-- make sure it is created.
		if #objects > 0 then 																	-- if not an empty list
			for _,ref in pairs(objects) do container:insert(ref) end 							-- add all the objects into it.
		end
	end 
	return newObject 
end 

--//	Get the container, creating it if necessary.
--//	@return 	[container]		Corona container clipped to display limits.

function Scene:getContainer()
	if self.m_container == nil then  															-- create a container if required.
		self.m_container = 	display.newContainer(display.contentWidth,display.contentHeight) 	-- create a new container
		self.m_container.anchorX,self.m_container.anchorY = 0,0 								-- set it up correctly.
		self.m_container.anchorChildren = false
	end 
	return self.m_container
end 

--//	Delete collection ; deletes objects in the collection too.

function Scene:destructor()
	SuperClass.destructor(self)																	-- delete all owning objects
	if self.m_container ~= nil then  															-- if a container exists
		self.m_container:removeSelf() 															-- remove it and any objects contained in it.
	end
end


--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		17-Jul-14	0.1 		Initial version of file
		14-Aug-14 	1.0 		Advance to releasable version 1.0

--]]
--- ************************************************************************************************************************************************************************
