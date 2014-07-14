--- ************************************************************************************************************************************************************************
---
---				Name : 		framework.lua
---				Purpose :	Framework Object
---				Created:	14 July 2014
---				Updated:	14 July 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

local Framework = {} 																			-- the framework object.

Framework.m_objectTable = {} 																	-- dictionary of object reference -> framework element.
Framework.m_classTable = {} 																	-- dictionary of class name -> prototype.

--//	Register a class with the framework.
--//	@className 			[string] 		name of class - alphanumerics and full stops, case insensitive.
--//	@classPrototype 	[table]			class prototype object.

function Framework:registerClass(className,classPrototype)
	assert(type(className) == "string","className should be a string") 							-- parameter validation.
	assert(type(classPrototype) == "table","classPrototype should be a table")
	className = className:lower() 																-- lower case class name
	assert(className:match("^[a-z0-9%.]+$"),"Bad className, alphanumerics and full stop only")
	assert(self.m_classTable[className] == nil,"Class '"..className.."' duplicated") 			-- check class name is unique.
	self.m_classTable[className] = classPrototype 												-- store the prototype.
end 

--//	Create and register a class with the framework.
--//	@className 			[string] 		name of class - alphanumerics and full stops, case insensitive.
--//	@parentClass		[table] 		optional class to use as parent for the new class.
--//	@return 			[table] 		class prototype object.

_G.Base =  _G.Base or { new = function(s) local o = {} setmetatable(o,s) s.__index = s o:initialise() return o end, initialise = function() end }

function Framework:createClass(className,parentClass)
	assert(type(className) == "string","className should be a string") 							-- parameter validation.
	if parentClass ~= nil then assert(type(parentClass) == "table","parentClass should be a table or nil") end
	className = className:lower() 																-- lower case class name
	assert(className:match("^[a-z0-9%.]+$"),"Bad className, alphanumerics and full stop only")

	local newClass = {} 																		-- create a new class.
	if parentClass ~= nil then  																-- does it have a parent class
		setmetatable(newClass,parentClass) 														-- set up the metatable etc. appropriately.
		parentClass.__index = parentClass 
	end 
	self:registerClass(className,newClass) 														-- register the new class.
	return newClass 																			-- return the class prototype.
end 

--//	Create an object of the given class. Call its constructor using the provided data.
--//	@className 			[string] 		name of class - alphanumerics and full stops, case insensitive.
--//	@setupData 			[table] 		optional setup data (passes {} to constructor)
--//	@return 			[table] 		reference to new object.

function Framework:createObject(className,setupData)
	assert(type(className) == "string","className should be a string") 							-- parameter validation.
	setupData = setupData or {} 																-- default set up data parameter
	assert(type(setupData) == "table","setupData should be a table or nil")
	className = className:lower() 																-- lower case class name
	assert(className:match("^[a-z0-9%.]+$"),"Bad className, alphanumerics and full stop only")
	local classRef = self.m_classTable[className] 												-- get the class reference.
	assert(classRef ~= nil,"class Name '"..className.."' not known to framework")				-- check the class actually exists.
	local newObject = {} 																		-- create a new object
	setmetatable(newObject,classRef) 															-- set up the metatable.
	classRef.__index = classRef 
	if newObject.constructor ~= nil then  														-- if there is a constructor
		newObject:constructor(setupData) 														-- call it.
	end 
	assert(self.m_objectTable[newObject] == nil,"Internal error")								-- this is a major issue - object already in table ????
	self.m_objectTable[newObject] = "fw" 														-- set the object framework functions reference.
	newObject.fw = Framework.MixinObject 														-- framework methods here.
	return newObject
end 

--//	Delete an object of the given class. Call its destructor, if it exists. If it is a mixin object, remove its mixin.
--//	@object 			[table] 		object to delete.

function Framework:deleteObject(object)
	assert(type(object) == "table","object should be a table") 									-- parameter validation
	assert(self.m_objectTable[object] ~= nil,"Object is not known to framework")				-- do we know about this object ?
	if object.destructor ~= nil then 															-- destroy the object.
		object:destructor()
	end 
	self.m_objectTable[object] = nil 															-- remove it from the table. 
end 

--//	Given an object, decorate it to be a framework object by adding an entry to its table.
--//	@object 			[table] 		object to decorate
--//	@mixinBase 			[string] 		the element to store the framework data in, by default this is "fw"

function Framework:decorateObject(object,mixinBase)
	assert(type(object) == "table","object should be a table")								    -- parameter validation
	mixinBase = mixinBase or "fw" 																-- default mixin base.
	assert(type(mixinBase) == "string","mixinBase should be a string or nil")
end 

Framework.MixinObject = {} 																		-- Framework.MixinObject methods are added to new objects.

--//	Add items to the mixin used when objects are created.
--//	@entityName  	  [string] 			Name of entity to be added
--//	@entityReference  [object] 			Entity Reference.

function Framework:addFrameworkMixinEntity(entityName,entityReference)
	assert(type(entityName) == "string") assert(type(entityReference) == "function") 			-- add methods to the object creation mixin.
	assert(Framework.MixinObject[entityName] == nil)
	Framework.MixinObject[entityName] = entityReference 
end 

return Framework 

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		14-Jul-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
