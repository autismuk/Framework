--- ************************************************************************************************************************************************************************
---
---				Name : 		framework.lua
---				Purpose :	Framework Object
---				Created:	15 July 2014
---				Updated:	21 July 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

--[[
local Framework = Framework:createClass("system.framework")										-- keeps documenter happy :)
--]]

Framework = {} 																					-- the framework object.
Framework.copyright = "Framework (C) Paul Robson 2014"											-- copyright message

Framework.m_classes = {} 																		-- class table. Maps class identifier (l/c) to a prototype/factory table.
Framework.m_index = {} 																			-- tag index - Maps tag (l/c) to a table contain object => object values
Framework.m_indexCount = {} 																	-- tag index count - Maps tag (l/c) to number of tags in that index.
Framework.m_objectMembers = {} 																	-- members to decorate new objects.

Framework.m_index["frameworkobject"] = {} 														-- create an empty index and count for the frameworkobject tag, this is 
Framework.m_indexCount["frameworkobject"] = 0 													-- tagged for every object, so effectively it is a table of the objects.

Framework.fw = {} 																				-- Framework globals.

Framework.m_enterFrameEnabled = true 															-- enter frame enabled.

--//	Register a new class in the class list.
--//	@className 			[string]	Class identifier.
--//	@classPrototype 	[table]		Class prototype.

function Framework:register(className,classPrototype)
	className = className:lower() 																-- class name L/C
	assert(self:validateClassIdentifier(className),className .. " is a bad class identifier") 	-- validate parameters.
	assert(type(classPrototype) == "table","Bad class prototype")
	assert(self.m_classes[className] == nil,"Duplicate class " .. className) 					-- check class not already defined.
	self.m_classes[className] = { class = "normal", prototype = classPrototype } 				-- add the definition.
end 

--//	Create and register a new class, which may be subclassed from another class.
--//	@className 			[string]			Class identifier.
--//	@superClass 		[string/table]		Superclass, may be nil.
--//	@return 			[class,super]		New class prototype, superclass prototype (if any)
function Framework:createClass(className,superClass)
	className = className:lower() 																-- class name L/C
	assert(self:validateClassIdentifier(className),className .. " is a bad class identifier") 	-- validate parameters.
	local newClass = {} 																		-- this is the class
	if superClass ~= nil then 																	-- if it has a superclass
		if type(superClass) == "string" then 													-- is the superclass a name ?
			superClass = superClass:lower() 													-- validate it.		
			assert(self:validateClassIdentifier(superClass),superClass .. " is a bad superclass identifier") 	
			assert(self.m_classes[superClass] ~= nil,superClass .. " undefined") 				-- check class exists.
			superClass = self.m_classes[superClass].prototype 									-- get its reference.
		end 
		setmetatable(newClass,superClass) 														-- set up the metatable
		superClass.__index = superClass 
	end 
	self:register(className,newClass)															-- register this new class
	return newClass,superClass 																	-- and return it.
end

--//	Create a new object, given a class name or prototype, and optional initialisation data. Create the object, then set it up
--//	(add framework stuff, and call constructor)
--//	@className 	[string/object] 				Name of class to create instance of or prototype object.
--//	@data 		[table]							Optional instantiation data (is passed to constructor as {} if nil)

function Framework:new(className,data)
	if type(className) == "string" then 														-- class name is a string 
		className = className:lower() 															-- class name L/C
		assert(self:validateClassIdentifier(className),className.." is a bad class identifier") -- validate parameters.
		assert(self.m_classes[className] ~= nil,className .. " undefined") 						-- check class exists.
		className = self.m_classes[className]													-- it is now a reference.
	end 
	assert(type(className) == "table","className should be a reference") 						-- check we now have a class prototype.

	assert(className.class == "normal","Type not implemented "..className.class)				-- check it is 'normal' e.g. standard type.
	local newObject
	if className.prototype.createMixinObject == nil then 										-- if not a mixin create object
		newObject = {} 																			-- create a new object
		setmetatable(newObject,className.prototype)												-- set the metatable
		className.prototype.__index = className.prototype
	else 																						-- a mixin object
		newObject = className.prototype.createMixinObject(nil,data)  							-- get or create the object you are going to use.
		local protoList = className.prototype  													-- work backwards through the metatable.
		while protoList ~= nil do
			for k,v in pairs(protoList) do 														-- work through the metatable contents
				if type(v) == "function" then 													-- put functions in if they don't already exist.
					newObject[k] = newObject[k] or v
				end 
			end
			protoList = getmetatable(protoList) 												-- follow the metatable chain.
		end
	end  
	self:convert(newObject,data) 																-- use convert code to set it up
	return newObject 																			-- return object reference.
end 

--//	Convert a lua object into one useable by the framework and store it in the framework. After validation, add the default
--//	__frameworkData storage element, add in the mixins, tag it as "frameworkObject", and call the constructor
--//	@object 	[table]							Object to be converted. Can come from framework or could be a Corona object, say.
--//	@data 		[table]							Optional instantiation data (is passed to constructor as {} if nil)

function Framework:convert(object,data)
	data = data or {} 																			-- default data value.
	assert(type(object) == "table","object should be a prototype")								-- validation
	assert(type(data) == "table","instantitation data should be nil or a table")
	object.__frameworkData = { isAlive = true } 												-- initialise the framework data.
	object.fw = Framework.fw 																	-- link to named objects.

	for name,element in pairs(self.m_objectMembers) do 											-- work through the members.
		object[name] = object[name] or element 
	end 

	self.m_index["frameworkobject"][object] = object 											-- this effectively tags it as 'frameworkobject'
	self.m_indexCount["frameworkobject"] = self.m_indexCount["frameworkobject"] + 1 			-- this is quicker than calling Framework:tag

	assert(object.constructor ~= nil,"Object is missing a constructor") 						-- check there is a constructor.
	object:constructor(data) 																	-- call the constructor.
	if object.destructor == nil then print("Destructor not present, warning") end 				-- only warn if no destructor.
end 

--//	Delete an object, calling the destructor, then fixing up the indexes so they do not contain this object any more.
--//	@object 	[object]						Object you want to delete.

function Framework:delete(object)
	if not object:isAlive() then return end 													-- already dead.
	if object.destructor ~= nil then object:destructor() end 									-- call destructor if it exists
	object.__frameworkData.isAlive = false 														-- mark as no longer alive.
	if object.__frameworkData.givenName ~= nil then 											-- did the object have a name ?
		Framework.fw[object.__frameworkData.givenName] = nil 									-- if so, remove it
	end
	assert(self.m_index["frameworkobject"][object] ~= nil,"Unknown object") 					-- check object is present.
	for tag,_ in pairs(self.m_index) do 														-- work through all known tags.
		if self.m_index[tag][object] ~= nil then 												-- is this object in this index ?
			self.m_index[tag][object] = nil 													-- remove it from the index
			self.m_indexCount[tag] = self.m_indexCount[tag] - 1 								-- adjust the count.
		end
	end
end 

--//	Validate a class identifier. It should be a sequence of alphanumeric words, beginning with a letter, seperated by
--//	full stops.
--//	@identifier 	[string] 		string to validate
--//	@return 		[boolean]		true if valid.

function Framework:validateClassIdentifier(identifier)
	if type(identifier) ~= "string" then return false end 										-- must be a string
	repeat
		local temp temp,identifier = identifier:match("^([a-z][0-9a-z]*)(.*)$") 				-- split it up.
		if identifier == nil then return false end 												-- didn't match up.
		if identifier ~= "" then 																-- something follows ?
			if identifier:sub(1,1) ~= "." then return false end 								-- must be aaa.bbb etc.
			identifier = identifier:sub(2)
		end 
	until identifier == "" 																		-- processed the entire string.
	return true 
end 

--//	Validate a lua identifier. This is defined as a alphabetic character followed by a number alphanumeric characters,
--//	this number may be zero.
--//	@identifier 	[string] 		string to validate
--//	@return 		[boolean]		true if valid.

function Framework:validateLuaIdentifier(identifier)
	if type(identifier) ~= "string" then return false end 										-- must be a string
	return identifier:match("^[a-zA-Z][a-zA-Z0-9]*$") ~= nil 
end 

--//	Add a method to the object method structure
--//	@methodName 	[string]		Name of method
--//	@methodEntity 	[anything]		Whatever you want to add, normally a function.

function Framework:addObjectMethod(methodName,methodEntity)
	assert(type(methodName) == "string","Bad method name")										-- validate.
	assert(self.m_objectMembers[methodName] == nil,"Duplicate mixin "..methodName) 				-- check not already defined
	self.m_objectMembers[methodName] = methodEntity  											-- add it to the mixins.
end 

--//	Add or remove a tag from an object, updating the tag indices as you go. 
--//	@object 		[table]			Object to tag/detag
--//	@tagName 		[string]		tag to apply/remove
--//	@command 		[number] 		Command to do with tag.

function Framework:tag(object,tagName,command)
	assert(type(object) == "table","Cannot tag a non-object") 									-- verify
	assert(type(tagName) == "string" and tagName:match("^%w+$") ~= nil ,"Tag must be a alphanumeric string")
	assert(command == Framework.ADDTAG or command == Framework.REMOVETAG,"Bad tagging command")
	tagName = tagName:lower() 																	-- tags are case insensitive.

	if command == Framework.ADDTAG then 
		if self.m_index[tagName] == nil then 													-- does the tag index exist ?
			self.m_index[tagName] = {} self.m_indexCount[tagName] = 0 							-- if not, create an empty index.
		end 
		if self.m_index[tagName][object] == nil then 											-- if it is not in there.
			self.m_index[tagName][object] = object 												-- put it in the tag index
			self.m_indexCount[tagName] = self.m_indexCount[tagName] + 1 						-- bump the counter 
		else
			print("Warning ! Duplicate tag added "..tagName) 									-- already there, warning !
		end
	else 
		assert(self.m_index[tagName] ~= nil,"Object not tagged with "..tagName.." (index)")		-- no tag index.
		assert(self.m_index[tagName][object] ~= nil,"Object not tagged with "..tagName)			-- check it is tagged with the tag
		self.m_index[tagName][object] = nil 													-- remove from tag index
		self.m_indexCount[tagName] = self.m_indexCount[tagName] - 1 							-- decrement the counter 
	end
	--print(object,tagName,command)
end 

Framework.ADDTAG = 1 																			-- tag commands.
Framework.REMOVETAG = 2 																	

--//	Convert a string to an array of strings, using the given separator
--//	@string 	[string]		String to split
--//	@split 		[string]		Characters to split over.
--//	@return 	[list]			List of strings.

function Framework:split(string,split)
	local result = {}
	while string ~= "" do 																		-- keep going till finished
		local p = string:find(split) 															-- find split
		if p == nil then  																		-- no split found
			result[#result+1] = string string = ""
		else 
			result[#result+1] = string:sub(1,p-1) string = string:sub(p+#split)  				-- split found.
		end 
	end 
	return result
end

--//	Perform a method call on a table of objects.
--//	@objectTable 	[table]			table of objects (use value, non consecutive)
--//	@method 		[string]		method name.
--//	@p1 			[anything]		parameter
--//	@p2 			[anything]		parameter
--//	@p3 			[anything]		parameter

function Framework:perform(objectTable,method,p1,p2,p3)
	if self.m_stopDispatch == true then return end 												-- if perform has previously crashed, then don't do it.
	for _,ref in pairs(objectTable) do 															-- scan the object list
		if ref:isAlive() and self.m_stopDispatch ~= true then  									-- check the object is not dead
			local ok,message = pcall(function() 												-- call the method, getting an error.
										assert(ref[method] ~= nil,"Object does not implement "..method.."()")
										ref[method](ref,p1,p2,p3)
									 end)
			if not ok then 																		-- if failed
				self.m_stopDispatch = true 														-- stop any further attempts
				print("Warning ! Framework:perform() failed")									-- print a warning error.
				print("    Returned error : "..message)
			end 
		end 
	end
end 

--//	Handle enterFrame event. If there are any objects tagged enterFrame call their onEnterFrame() method.
--//	@event 	[table]		Event data.

function Framework:enterFrame(event)
	if (self.m_indexCount.enterframe or 0) == 0 or not self.m_enterFrameEnabled then return end -- nothing to actually handle the frame time.
	local time = system.getTimer()																-- get current time, in milliseconds
	local elapsed = math.min(100,time - (self.m_lastFrameTimer or 0)) 							-- work out elapsed time, top out at 100ms.
	self.m_lastFrameTimer = time 																-- update last time.
	Framework:perform(self.m_index.enterframe,"onEnterFrame",elapsed/1000)						-- call the enterframe method.
end 

--//	Check to see if asynchromous stuff - messages, updates, etc. should be dispatched. 

function Framework:isAsyncEnabled()
	return self.m_enterFrameEnabled 
end 


--//	Enable or disable the enterFrame event.
--//	@isEnabled [boolean]	true to enable, false to disable

function Framework:setEnterFrameEnabled(isEnabled)
	assert(isEnabled == true or isEnabled == false,"setEnterFrameEnabled must have a boolean")
	self.m_enterFrameEnabled = isEnabled 
end 

Runtime:addEventListener( "enterFrame",Framework ) 												-- add event listener.

--//	Name an object
--//	@object 	[table]		object to name
--//	@name 		[string]	name to give object.

function Framework:name(object,name)
	assert(type(object) == "table","Must name an object") 										-- validate
	assert(type(name) == "string" and #name > 0,"Bad object name")
	assert(Framework.fw[name] == nil,"Duplicate object name "..name)							-- check not already defined.
	assert(object.__frameworkData.givenName == nil,"Object already name")						-- object can only have *one* name.
	Framework.fw[name] = object 																-- store the name.
	object.__frameworkData.givenName = name 													-- store the record that the object has been given a name.
end

--
-- 		Mixin methods.
--

Framework:addObjectMethod("isAlive", 															-- add method to check if alive.
	function(self) 
		return self.__frameworkData.isAlive 
	end)

Framework:addObjectMethod("delete",																-- add method to delete self.
	function(self)
		Framework:delete(self)
	end)

Framework:addObjectMethod("tag",																-- add method to tag objects.
	function(self,tagString)
		assert(type(tagString) == "string","Bad tag parameter") 								-- check parameter is a string.
		tagString = Framework:split(tagString,",") 												-- convert tag string into array of substrings.
		for _,tag in ipairs(tagString) do 														-- work through the tag strings.
			if tag:sub(1,1) == "+" then tag = tag:sub(2) end 									-- remove leading +
			if tag:sub(1,1) == "-" then  														-- if -x remove tag
				Framework:tag(self,tag:sub(2),Framework.REMOVETAG)
			else 																				-- otherwise add tag.
				Framework:tag(self,tag,Framework.ADDTAG)
			end
		end
		return self
	end)

Framework:addObjectMethod("name",																-- add method to name objects
	function(self,name) 
		Framework:name(self,name)
		return self
	end)

require("framework.query") 																		-- query code
require("framework.messaging") 																	-- messaging code.
require("framework.timer")																		-- timer code.
require("framework.collection")																	-- collection code.
require("framework.scene") 																		-- game scene code.
require("framework.fsm")																		-- finite state machine code.
require("framework.scenemanager")																-- game scene management code.
require("framework.gamemanager")																-- game management code.
require("framework.transition") 																-- transitioning object.

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		15-Jul-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
