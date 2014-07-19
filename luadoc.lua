--- ************************************************************************************************************************************************************************
---
---				Name : 		luadoc.lua
---				Purpose :	Script providing simple inline documentation features for my personal coding style.
---							Modified to work with Framework system 19-Jul-2014
---				Created:	6 May 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	MIT
---
--- ************************************************************************************************************************************************************************

-- Standard OOP (with Constructor parameters added.)
_G.Base =  _G.Base or { new = function(s,...) local o = { } setmetatable(o,s) s.__index = s o:initialise(...) return o end, initialise = function() end }

--- ************************************************************************************************************************************************************************
--//	This is the main storage class which holds a 'chunk' of comments and attributes, it is general purpose because at the time of creation
--//	we don't know whether it refers to a class or a method.
--- ************************************************************************************************************************************************************************

local DocStore = Base:new()

--//	Creates an empty storage element

function DocStore:initialise()
	self.name = "" 																				-- name of class or method
	self.parameters = "" 																		-- parameter list (if method)
	self.baseClass = "" 																		-- base class (if class)
	self.attributes = {} 																		-- attribute hash (l/c name => text)
	self.methods = {} 																			-- methods defined (if class)
	self.comment = "" 																			-- main comment string 
end

--//	Add a comment line (e.g. one that is prefixed with the -- // sequence) to a documentation store 
--//  	@line [string]	the line to add (should still have --// prefix)

function DocStore:addLine(line)
	assert(line:sub(1,4) == "--//")																-- check it does indeed still have --// on the front.
	line = self:strip(line:sub(5)) 																-- remove spaces
	local key,comment = line:match("^%@(%w+)%s+(.*)$") 											-- look for @x xxxxx pattern
	if key ~= nil then 																			-- parameter provided (e.g. @something)
		key = key:lower() 																		-- case insensitive.
		assert(self.attributes[key] == nil,"Duplicate attribute "..key)							-- not already defined.
		self.attributes[key] = self:strip(comment)												-- assign the data to it.
	else 
		self.comment = self.comment .. " " .. line 												-- add line to main comment
		self.comment = self:strip(self.comment):gsub("  "," ") 									-- remove leading/trailing spaces and double spaces
	end
end

--//	Remove leading and trailing spaces from a line, and convert tabs to spaces.
--//	@line 	[string] 	line to strip of spaces
--//	@return [string]	stripped line

function DocStore:strip(line)
	line = line:gsub("\t"," ") 																	-- tabs to spaces.
	line = line:match("^%s*(.*)$") 																-- strip leading spaces.
	while line:match("%s$") do line = line:sub(1,-2) end 										-- strip trailing spaces.
	return line
end

--- ************************************************************************************************************************************************************************
--//							This class processes a file, scanning for the inline document text and class and method signatures
--- ************************************************************************************************************************************************************************

local SourceProcessor = Base:new()

--//	Constructor

function SourceProcessor:initialise()
	self.current = DocStore:new() 																-- current commented being collected.
	self.classes = {} 																			-- classes collected (class name => DocStore object)
end

--//	Scan a source file for inline comments, classes and methods and store them appropriately.
--//	@sourceFile [string]	File to scan.

function SourceProcessor:process(sourceFile)
	print("Now parsing "..sourceFile)
	local h = io.open(sourceFile,"r")															-- open source file
	assert(h ~= nil,"Could not open file " .. sourceFile)
	for line in h:lines() do 																	-- scan through the file
		if line:sub(1,4) == "--//" then 														-- inline comment data
			self.current:addLine(line)															-- add it to the inline comment store
		else 												
			local p = line:find("%-%-")															-- remove comments if any. Hopefully [[ ]] comments shouldn't matter.
			if p ~= nil then line = line:sub(1,p) end
			local newClass,classRef,baseClass

			newClass,classRef = line:match('(%w+)%s*%=%s*Framework%:createClass%(%"(.*)%"%)')
			if classRef ~= nil then 
				baseClass = ""
				if classRef:find(",") ~= nil then classRef,baseClass = classRef:match('(.*)%"%,%"(.*)') end
			end


																								-- but newClass must be capitalised in class definitions.
			if newClass ~= nil then 															-- found such a class.
				assert(self.classes[newClass] == nil,"Class duplicated "..newClass)				-- check it doesn't already exist (consequences for local classes)
				self.current.name = newClass 													-- update member variables in current saved class - saves lots of accessors :)
				self.current.baseClass = baseClass 										
				self.current.classFQDN = classRef 												-- save the FQDN.
				self.classes[newClass] = self.current 											-- make the current document store the info for this class.
				self.current = DocStore:new() 													-- and we have a new document store.
				-- print("    Found class " .. newClass)
				-- print("*",newClass,baseClass,line,self.classes[newClass].comment)
			end 
								
			local class,method,parameters =														-- detect a function definition <class>:<method>(<parameters>), again class capitalised. 
									line:match("function%s+([A-Z]%w*)%:([%w%_]+)%(%s*([%w%.%,]*)%s*%)")		-- this is very specific to my coding style :)

			if class ~= nil then 																-- found a method definition.
				assert(self.classes[class] ~= nil,"Class unknown in method def "..line) 		-- the class must have been defined already.
				local thisClass = self.classes[class] 											-- keep a reference to it.
				if method == "initialise" then method = "(constructor)" end 					-- rename initialise.
				assert(thisClass.methods[method] == nil,"Duplicate method "..line)				-- check the method doesn't already exist.
				thisClass.methods[method] = self.current 										-- save doc store in methods table for the class.
				self.current.name = method 														-- name is method - this is kept in the methods table of the class
				self.current.parameters = parameters:gsub("%,%.%.%.","") 						-- save the parameter list
				self.current = DocStore:new() 													-- a new document store
				-- print("        Found method "..class..":"..method.."("..parameters..")")
				-- print(">",class,method,parameters,thisClass.methods[method].comment)
			end
		end
	end
	h:close() 																					-- and completed.
	print("Parsing complete.")
end

--//	Render the complete scanned documentation as HTML
--// 	@handle [I/O Handle] handle to render it to.

function SourceProcessor:renderHTML(handle)
	local css = "body { background:#333; color:#0F0; font-family:Arial,Verdana;} a { color:#0AA } h1 { color:#FF0; } h2 { color:#0FF } table,tr,td { color: #CCC; padding:4px;border:1px solid white; border-collapse:collapse; }"
	local css = "<style>"..css.."</style>"
	handle:write("<!DOCTYPE html><html><head>"..css.."</head><body>\n")							-- header
	local classList = self:getSortedClassKeys(self.classes) 	 								-- get all the names of the classes
	for _,class in ipairs(classList) do 														-- work through the classes
		self:renderClass(handle,self.classes[class]) 											-- render the class.
		local methodlist = self:getSortedKeys(self.classes[class].methods) 						-- get all the names of its methods
		for _,method in ipairs(methodlist) do 													-- work through them
			self:renderMethod(handle,self.classes[class].methods[method],self.classes[class]) 	-- and render them.
		end
	end
	handle:write("<hr><p><i>LUA Autodoc by Paul Robson 2014</i></p><hr>")
	handle:write("</body></html>\n") 															-- get sorted list of classes
end


--//	Render documentation for a class in HTML
--//	@handle 	[i/o handle]		File handle
--//	@class 		[DocStore]			Documentation for that class

function SourceProcessor:renderClass(handle,class)
	handle:write('<a name="'..class.classFQDN..'"></a>\n')
	handle:write("<hr><h1>" .. class.classFQDN .. "</h1>\n")
	handle:write("<p><h3>Extends " .. class.baseClass .. "</h3></p>\n")
	handle:write("<p>"..class.comment.."</p>\n")
	local methodList = {} 																		-- work out all the known methods.
	local completed = false
	local currentClass = class
	while not completed do  																	-- while still going back up the tree.
		for _,method in pairs(currentClass.methods) do 											-- work through all the methods
			if method.comment == "" or method.comment:sub(1,1) ~= "%" then
				if methodList[method.name] == nil then 											-- if doesn't already exist.
					methodList[method.name] = currentClass 										-- put in hash with their class.
				end
			end
		end
		currentClass = self.classes[currentClass.baseClass] 									-- back up the tree.
		if currentClass == nil then completed = true end
	end
	local methods = self:getSortedKeys(methodList) 												-- make it a sorted list.
	handle:write("<p>Methods : ")
	for i = 1,#methods do 
		if i > 1 then handle:write(",") end
		handle:write('<a href="#'..methodList[methods[i]].name..'_'..methods[i]..'"/>')
		if methodList[methods[i]] ~= class then
			handle:write("<i>"..methods[i].."</i>")
		else
			handle:write(methods[i])
		end
		handle:write("</a>")
	end
	handle:write("</p><hr>")
end

--//	Render documentation for a method in HTML
--//	@handle 	[i/o handle]		File handle
--//	@method 	[DocStore]			Documentation for that method

function SourceProcessor:renderMethod(handle,method,class)
	handle:write('<a name="'..class.name..'_'..method.name..'"></a>\n')
	if method.comment ~= "" and method.comment:sub(1,1) == "%" then return end 					-- do not comment anything whose comments prefix with %
	handle:write("<h2>"..method.name.."("..method.parameters..")</h2>\n")
	if method.parameters ~= "" or method.attributes["return"] ~= nil then 						-- process parameters/return
		handle:write("<table>\n")
		local params = method.parameters 														-- get parameters, if any.
		if params ~= "" then params = params .. "," end 										-- add trailing comma if there are already parameters
		if method.attributes["return"] ~= nil then params = params .. "return," end 			-- if @return was specified add it.
		while params ~= "" do 																	-- keep going till finished.
			local p = params:match("^([%w%.]+),") 												-- extract parameter.
			params = params:sub(#p+2) 															-- remove from string.
			handle:write("<tr>")
			handle:write("<td>"..p.."</td>")
			local typeDesc = "" 																-- type descriptor
			local paramComment = method.attributes[p:lower()] or "" 							-- get the attribute if there is one.
			local td,pc = paramComment:match("^%[(.*)%]%s*(.*)$")
			if td ~= nil then typeDesc = td paramComment = pc end

			handle:write("<td>"..typeDesc.."</td><td>"..paramComment.."</td>")
			handle:write("</tr>\n")
		end
		handle:write("</table>\n")
	end
	handle:write("<p>"..method.comment.."</p>\n")
end

--//	Return a sorted list of the keys in a table
--//	@inTable [table]	table whose keys are required
--//	@return 			sorted list of the keys

function SourceProcessor:getSortedKeys(inTable)
	local keys = {} 																			-- result
	for key,_ in pairs(inTable) do keys[#keys+1] = key end 										-- copy keys into list
	table.sort(keys)
	return keys
end

--//	Return a sorted list of the keys in a table
--//	@inTable [table]	table whose keys are required
--//	@return 			sorted list of the keys

function SourceProcessor:getSortedClassKeys(inTable)
	local keys = {} 																			-- result
	for key,_ in pairs(inTable) do keys[#keys+1] = key end 										-- copy keys into list
	table.sort(keys,function(a,b) return self.classes[a].classFQDN < self.classes[b].classFQDN end)
	return keys
end

local sp = SourceProcessor:new() 																-- create a source processor
for _,file in ipairs(arg) do sp:process(file) end 												-- process all the command line files

h = io.open("doc.html","w") 																	-- output the result
sp:renderHTML(h)
h:close()
