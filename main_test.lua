--- ************************************************************************************************************************************************************************
---
---				Name : 		main.lua
---				Purpose :	Top level code for Framework library.
---				Created:	14 July 2014
---				Updated:	17 July 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

require("framework.framework") 																	-- require the framework library.

local WorkingClass = Framework:createClass("test.class")										-- we create a class to work with.

function WorkingClass:constructor(info)															-- a simple constructor and destructor.
	self.m_name = info.name 
end 

function WorkingClass:destructor() end

function tagName(n) return "tag"..n end  														-- get tag alphabetic name.

function countTable(table) 
	local n = 0
	for _,_ in pairs(table) do n = n + 1 end 
	return n 
end 

function passesTest(tagList,queryList) 
	for _,tagID in ipairs(queryList) do 
		if tagList[tagID] ~= true then return false end 
	end 
	return true
end 

local objectCount = 100 																		-- up to 100 objects.
local tagCount = 30 																			-- up to 30 tags.
local objectRefs = {} 																			-- object references.
local tagLists = {} 																			-- for each object, a list of tags it has (except frameworkObject)
local querySize = 5 																			-- up to 1 element in a query.

local initialCount = countTable(Framework.m_index.frameworkobject)								-- Objects defined by the framework.

--
--		Do one set of changes, tests etc.
--

function onePass()

	--
	--	Add or remove one object and check the frameworkObject tag is correct.
	--
	local n = math.random(1,objectCount)  														-- pick an object slot.
	if objectRefs[n] == nil then 																-- no object ?
		objectRefs[n] = Framework:new("test.class", { name = "obj#"..n })						-- create one.
		tagLists[n] = {} 																		-- clear the tag list.
	else 
		if math.random(1,2) == 1 then 															-- only remove one time in two so table is fairly full.
			objectRefs[n]:delete()																-- one present, delete it.
			objectRefs[n] = nil 																-- nil the reference.
			tagLists[n] = nil 																	-- and the tag lists.
		end
	end 

	assert(countTable(objectRefs) == countTable(Framework.m_index.frameworkobject) - initialCount) 			-- check the frameworkObject tag index is right.
	for k,v in pairs(objectRefs) do assert(Framework.m_index.frameworkobject[v] ~= nil) end 	-- compare table counts and check reference presence.


	n = math.random(1,objectCount) 																-- pick an object to add or remove a tag from.
	if objectRefs[n] ~= nil then 																-- actually found an object.
		local tag = math.random(1,tagCount) 													-- pick a tag.
		if math.random(2) == 1 then 															-- randomly add/remove it
			Framework:tag(objectRefs[n],tagName(tag),Framework.REMOVETAG) 						-- remove the tag.
			tagLists[n][tag] = nil 																-- keep parallel structure up to date.
		else
			Framework:tag(objectRefs[n],tagName(tag),Framework.ADDTAG) 							-- if not tageed, then add the tag.
			tagLists[n][tag] = true
		end
	end 

	for tag = 1,tagCount do 																	-- check all the tags.
		local name = tagName(tag) 																-- get the tags name.
		local index = Framework.m_index[name] or {}
		for objects = 1,objectCount do 															-- check all the objects.
			if objectRefs[objects] ~= nil then 													-- is there an object
				if index[objectRefs[objects]] ~= nil then 										-- is it present in the index
					assert(tagLists[objects][tag] ~= nil)										-- check present in our copy.
				else 
					assert(tagLists[objects][tag] == nil) 										-- or not.
				end
			end
		end 
	end 

	for tag,_ in pairs(Framework.m_index) do 													-- check all the index counts and numbers of index items match.
		assert(countTable(Framework.m_index[tag]) == Framework.m_indexCount[tag])
	end

	local q = math.random(1,querySize) 															-- work out the size of the query.
	local queryItems = {}
	local queryString = ""
	for i = 1,q do 
		local tagID = math.random(1,tagCount) 													-- tag to test.
		queryItems[i] = tagID 																	-- save the tag. 
		if i > 1 then queryString = queryString .. "," end 
		queryString = queryString .. tagName(tagID) 
	end 
	local resultCount,resultHash = Framework:query(queryString) 								-- evaluate the query.
	assert(countTable(resultHash) == resultCount) 												-- check the result matches up.

	local successList = {} 																		-- calculated result hash
	for i = 1,objectCount do  																	-- add all passing objects
		if objectRefs[i] ~= nil then 
			if passesTest(tagLists[i],queryItems) then 											-- if they pass the query
				successList[objectRefs[i]] = objectRefs[i] 										-- add to the list
			end
		end 
	end 
	assert(countTable(successList) == resultCount) 												-- check the query and calculated result match.
	for _,ref in pairs(successList) do assert(resultHash[ref] ~= nil) end
end 

math.random(42)
print("Start.")
for i = 1,1000*1000 do 
	if i % 5000 == 0 then print("Test",i) end
	onePass()
end 
print("End.")