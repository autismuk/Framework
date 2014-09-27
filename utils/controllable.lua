--- ************************************************************************************************************************************************************************
---
---				Name : 		controllable.lua
---				Purpose :	controllable object (sub part of Framework)
---				Created:	27 Sept 2014
---				Updated:	27 Sept 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

--// 	ControllableObject, if a superclass of an object, gets an isEnabled() method which allows an object to be 'not enabled'
--//	until it has been requested to do so - for example, pausing a game while a "Get Ready !" logo is shown.

local ControllableObject = Framework:createClass("system.controllable")

ControllableObject.co_thisIsAMarkerForControllableObjects = true 					-- as it says, it's a marker !

--//	Check to  see if the object is enabled, or not.
--//	@return 	[boolean]	true if the object has been enabled

function ControllableObject:isEnabled() 
	return not(not self.m_internalControllableFlag) 								-- return state of flag monitoring controllability
end 

--//	This globally added method allows either all to be turned on, or just a subset (using one or more tags)

Framework:addObjectMethod("setControllableEnabled", function(self,query,newState)
	if newState == nil then 														-- if one parameter, it is a newState for all objects
		newState = query 															-- copy parameter over
		query = "" 																	-- blank parameter means *all* objects
	end 
	local count,result = self:query(query)											-- evaluate the query
	for _,object in pairs(result) do 												-- work through all the objects
		if object.co_thisIsAMarkerForControllableObjects ~= nil then 				-- if they have a controllable object marker
			object.m_internalControllableFlag = newState 							-- e.g. a superclass of controllableobject
		end 																		-- then set the state.
	end 
end)

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		27-Sep-14 	0.1 		First version.

--]]
--- ************************************************************************************************************************************************************************
