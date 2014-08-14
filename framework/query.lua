--- ************************************************************************************************************************************************************************
---
---				Name : 		query.lua
---				Purpose :	Querying routines (sub part of Framework)
---				Created:	15 July 2014
---				Updated:	15 July 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

--//	Query the Framework object database for all objects with all the named tags.
--//	@queryString 	[string] 		Comma seperated list of tags (defaults to "", which is the frameworkObject tag)
--//	@return 		[number,table]	Two elements, number of items and hash of items

function Framework:query(queryString)
	queryString = queryString or "" 															-- default query, empty string
	assert(type(queryString) == "string","query must be a string") 								-- check query actually is a string.

	if queryString == "" then 																	-- nothing provided at all.
		return self.m_indexCount.frameworkobject,self.m_index.frameworkobject 					-- return the framework object.
	end

	queryString = queryString:lower() 															-- make lower case.

	if queryString:find(",") == nil then 														-- only a single query entry. 
		if self.m_indexCount[queryString] == nil then return 0,{} end 							-- no index entry for that query item.
		return self.m_indexCount[queryString],self.m_index[queryString] 						-- otherwise return count and index
	end

	local queryItems = self:split(queryString,",") 												-- list of query items.
	local queryItemCount = {} 																	-- tag -> count mapping.
	local queryResult = {} 																		-- result.

	for _,tag in ipairs(queryItems) do  														-- work through the tags
		queryItemCount[tag] = self.m_indexCount[tag] or 0 										-- get the count for that tag.
		if queryItemCount[tag] == 0 then return 0,queryResult end 								-- if zero, there can't be any successful values.
	end 

	table.sort(queryItems,function(a,b) return queryItemCount[a] < queryItemCount[b] end) 		-- sort so the tag with the smallest no. of members is at the start.

	local resultCount = 0
	for _,ref in pairs(self.m_index[queryItems[1]]) do 											-- work through all the entries at the outermost level.
		local isOk = true 
		for tagNumber = 2,#queryItems do 	 													-- check all the other entries.
			if self.m_index[queryItems[tagNumber]][ref] == nil then 							-- is it not tagged ?
				isOk = false 																	-- mark as failed
				break 																			-- don't check any further
			end
		end
		if isOk then queryResult[ref] = ref resultCount = resultCount + 1 end 					-- if it passes the test , add to the result set.
	end
	return resultCount,queryResult																-- return the query result count and entries.
end

Framework:addObjectMethod("query",function(self,queryString)									-- add query method to object's mixin methods.
	return Framework:query(queryString)
end)

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		15-Jul-14	0.1 		Initial version of file
		14-Aug-14 	1.0 		Advance to releasable version 1.0

--]]
--- ************************************************************************************************************************************************************************
