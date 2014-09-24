--- ************************************************************************************************************************************************************************
---
---				Name : 		registry.lua
---				Purpose :	Global Storage Object
---				Created:	3rd August 2014
---				Updated:	3rd August 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

require("framework.framework")

local Registry = Framework:createClass("system.registry")

--//	Constructor - creates global storage object.

function Registry:constructor(info) 
	self.m_keys = {}
	print("Registry")
end 

--//	Destructor - throws object

function Registry:destructor()
	self.m_keys = nil 
end 

--//	Read from a storage object
--//	@key 	[string]		key to read - format is xxx.xxx.xxx, case does not matter
--//	@return [value]			associated value, or nil if no value provided.

function Registry:read(key)
	return self.m_keys[key:lower()]
end 

--//	Write to a storage object
--//	@key 	[string]		key to read - format is xxx.xxx.xxx, case does not matter
--//	@data 	[value]			data associated with it

function Registry:write(key,data)
	self.m_keys[key:lower()] = data 
end 

local registryInstance = Framework:new("system.registry") 										-- add an instance as this is a singleton.

Framework:addObjectMethod("readRegistry",														-- methods to access the singleton.
				function(self,key) return registryInstance:read(key) end)
Framework:addObjectMethod("writeRegistry",
				function(self,key,data) registryInstance:write(key,data) end)

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		3-Aug-14	0.1 		Initial version of file
		14-Aug-14 	1.0 		Advance to releasable version 1.0

--]]
--- ************************************************************************************************************************************************************************
