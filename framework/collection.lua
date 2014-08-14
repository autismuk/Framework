--- ************************************************************************************************************************************************************************
---
---				Name : 		collection.lua
---				Purpose :	Framework Collection Class
---				Created:	17 July 2014
---				Updated:	17 July 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

local Collection = Framework:createClass("system.collection")									-- create collection class.

--//	Construct a collection of objects
--//	@info 	[table]		Initialisation info (ignored)

function Collection:constructor(info)
	--print("Constructor")
	self.m_uniqueID = "col"..tostring(self):gsub("%W","")										-- get a unique identifier for this instance
	self.m_collectorTag = self:makeTag("xtag")													-- get a unique tag.
end 

--//	Create a new object and attach it to this collection using a tag.
--//	@className 	[string/object] 				Name of class to create instance of or prototype object.
--//	@data 		[table]							Optional instantiation data (is passed to constructor as {} if nil)

function Collection:new(className,data) 
	local newObject = Framework:new(className,data)
	newObject:tag(self.m_collectorTag)
	return newObject 
end 

--//	Delete collection ; deletes objects in the collection too.

function Collection:destructor()
	--print("Destructor")
	local count,objList = self:getCollection() 													-- get all owned objects.
	for _,ref in pairs(objList) do ref:delete() end 											-- delete them.
end

--//	Get all objects in the collection
--//	@return 		[number,table]	Two elements, number of items and hash of items

function Collection:getCollection() 
	return Framework:query(self.m_collectorTag)
end 

--//	Create a unique tag for this collection, useful for multiple instances.
--//	@base 	[string]				tag to use to make a unique one.
--//	@return [string]				tag unique to this

function Collection:makeTag(base) 
	return self.m_uniqueID .. base
end 

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		17-Jul-14	0.1 		Initial version of file
		14-Aug-14 	1.0 		Advance to releasable version 1.0

--]]
--- ************************************************************************************************************************************************************************
