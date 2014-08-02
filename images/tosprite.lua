--- ************************************************************************************************************************************************************************
---
---				Name : 		tosprite.lua
---				Purpose :	Converting images to Corona Sprite format, leverages the 'graphcismagick' packages
---							Note, this is a library (see define.lua for typical example)
---				Created:	28 July 2014
---				Updated:	28 July 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

-- Standard Stub OOP create as a global.
_G.Base =  _G.Base or { new = function(s,...) local o = { } setmetatable(o,s) s.__index = s o:initialise(...) return o end, initialise = function() end }

local Control = {
	debug = false
}

local outputDirectory = "" 																		-- where to store the resulting files.
local imageDirectory = "" 																		-- where to find images
local targetDirectory = "" 																		-- where final image is relative to main.lua

--- ************************************************************************************************************************************************************************
-- Class encapsulating the Graphic Image Manipulation library. You could replace the main methods  to use ImageMagick 
-- or any library you like. This was tested with version 1.3.18 - composite() is straightforward, getSize() is dependent on the return format of the identity
-- command having the size as <nnn>x<nnn> in it, and createImage() was done by trial and error to get it to work. 
--- ************************************************************************************************************************************************************************

Graphics = Base:new()

--//	Constructor

function Graphics:initialise()
	self.m_Command = "gm"																			-- command to run graphicsmagick which MUST be installed. 
	-- overwrite self.m_Command here if it is not on the path e.g. self.m_command = "c:\Program Files\Graphics\bin\gm.exe"
end

--//	Execute a graphics magick command
--//	@command [string]	Command to execute

function Graphics:_execute(command)
	command = self.m_Command .. " " .. command 														-- build actual command line
	if Control.debug then print("Calling '"..command.."'") end 										-- debugging ?
	local p = io.popen(command)																		-- open pipe
	local result = p:read("*all")																	-- read return value
	p:close()																						-- close pipe
	return result
end

--//	Get the size of an image in pixels
--//	@imageFile 	[string] 	image to examine
--//	@return 	[table]		size in table with width and height members.

function Graphics:getSize(imageFile)
	local info = self:_execute('identify "' .. imageFile .. '"')										-- use GD to ascertain this.
	local width,height = info:match("(%d+)x(%d+)")													-- extract the size information
	assert(width ~= nil and height ~= nil, 															-- gm identify format has changed !
						"Problem with identify return text format. Either it has changed or Graphics is not installed")				
	return { width = tonumber(width), height = tonumber(height) } 									-- return in a table.
end

--//	Create a new image of a given size which is completely transparent
--//	@imageFile 	[string]	Image to create
--//	@width 		[number]	Width of new image
--//	@height 	[number]	Height of new image

function Graphics:createImage(imageFile,width,height)
	local cmd = 'convert null: -background "#000000FF" -extent '..width.."x"..height..				-- it works ... after a lot of fiddling.
																					"  "..imageFile
	self:_execute(cmd)
	return self
end

--//	Composite one image onto another
--//	@mainFile 	[string]	File to composite onto
--//	@imageFile 	[string]	File to composite
--//	@x 			[number]	Position of composite image
--//	@y 			[number]	Position of composite image

function Graphics:composite(mainFile,imageFile,x,y)
	--print(x,y,imageFile)
	local cmd = 'composite -compose Over "'..imageFile..'"  -geometry +'..x..'+'..y..' "'..mainFile..'" "'..mainFile..'"'
	--print(cmd)
	self:_execute(cmd)
	return self
end

--//	Resize an image - note that aspect ratio is not enforced.
--//	@targetFile [string]	final image
--//	@imageFile 	[string]	image to resize
--//	@newWidth 	[number]	Width in pixels or percentage scaling if newHeight is nil. If both nil it is copy.
--//	@newHeigh 	[number]	Height in pixels or if nil, use newWidth to calculate percent scaling.

function Graphics:resize(targetFile,originalFile,newWidth,newHeight)
	local cmd 
	if newHeight == nil then 																	-- no height, its percent
		newWidth = newWidth or 100 																-- default to 100%
		cmd = ("convert -resize %dx%d%%! %s %s"):format(newWidth,newWidth,originalFile,targetFile)
	else 																						-- otherwise absolute size
		cmd = ("convert -resize %dx%d! %s %s"):format(newWidth,newHeight,originalFile,targetFile)
	end
	self:_execute(cmd)																			-- then do it.
end

local graphicInstance = Graphics:new()

--- ************************************************************************************************************************************************************************
--																	Image information/representation class
--- ************************************************************************************************************************************************************************

local Image = Base:new()

function Image:initialise(imageName,imageDef)
	self.m_imageName = imageName:lower() 														-- save name
	self.m_imageIsScaled = false  																-- simply, just file name, no scaling
	self.m_imageFileName = imageDef  											
	if imageName:find("@") ~= nil then imageName = imageName:match("^(.*)@") end 				-- remove any @ part from the short name
	self.m_name = imageName 																	-- and store it.
	local scaling = ""
	if imageDef:find("@") ~= nil then  															-- @ present means scaling
		self.m_imageFileName,scaling = imageDef:match("^(.*)@(.*)$") 							-- get scaling bit
		self.m_imageIsScaled = true 															-- mark that it is scaled.
	end
	self.m_imageFileName = imageDirectory .. self.m_imageFileName 								-- filename from directory
	if self.m_imageFileName:match("%.%w+$") == nil then 										-- add .png if no file type
		self.m_imageFileName = self.m_imageFileName .. ".png"
	end
	local size = graphicInstance:getSize(self.m_imageFileName) 									-- get size
	self.m_width = size.width self.m_height = size.height
	if scaling ~= "" then  																		-- scaling ?
		local a,b 
		a,b = scaling:match("^(%d+)x(%d+)") 													-- check absolute size
		if b ~= nil then 
			self.m_width = tonumber(a) self.m_height = tonumber(b)
		elseif scaling:match("^(%d+)%%$") ~= nil then 											-- check scaled by percentage
			a = tonumber(scaling:sub(1,-2))
			self.m_width = math.floor(self.m_width * a / 100)
			self.m_height = math.floor(self.m_height * a / 100)
		else
			error("Do not understand scaling "..imageDef)
		end 
	end
	self.m_pixels = self.m_width * self.m_height 												-- calculate pixels.
	--print(self.m_imageName,self.m_imageIsScaled,self.m_imageFileName,scaling,self.m_width,self.m_height)
end 

function Image:getShortName() return self.m_name end 											-- get the working name.

--- ************************************************************************************************************************************************************************
--																	Packing Descriptor Object
--- ************************************************************************************************************************************************************************

local PackingDescriptor = Base:new()

function PackingDescriptor:initialise(width)
	self.m_items = {}																			-- list of x,y,w,h,ref 
	self.m_width = width self.m_height = 16 													-- width and height of packing space.
end 

function PackingDescriptor:append(reference,width,height)
	if height > self.m_height then return false end 											-- it is just too small.
	local newRec = { x1 = math.random(0,self.m_width-width),									-- create a new record, which is a possible placement.
					 y1 = math.random(0,self.m_height-height),
					 width = width, height = height,
					 reference = reference }
	newRec.x2 = newRec.x1 + width -1 newRec.y2 = newRec.y1 + height - 1 						-- calculate x2,y2
	for _,ref in ipairs(self.m_items) do 														-- check against all current
		if self:overlaps(newRec,ref) then return false end 										-- fail if overlapped.
	end 
	self.m_items[#self.m_items+1] = newRec 														-- okay, add to the list
	return true 																				-- and return okay.
end 

function PackingDescriptor:overlaps(r1,r2)
	return not (r1.x1 > r2.x2 or r2.x1 > r1.x2 or r1.y1 > r2.y2 or r2.y1 > r1.y2)
end 

function PackingDescriptor:extendHeight(pixels)
	self.m_height = self.m_height + pixels
end 

function PackingDescriptor:render(outputFile)
	graphicInstance:createImage(outputFile,self.m_width,self.m_height)							-- empty sprite sheet
	for _,ref in pairs(self.m_items) do  														-- work through all packed
		local fileName = ref.reference.m_imageFileName 											-- get file name
		if ref.reference.m_imageIsScaled then 													-- if scaled
			local tmpFile = "tmpfile.png" 														-- produce a temporary scaled image
			graphicInstance:resize(tmpFile,fileName,ref.reference.m_width,ref.reference.m_height)
			fileName = tmpFile
		end 
		graphicInstance:composite(outputFile,fileName,ref.x1,ref.y1)							-- put on the sprite sheet
	end 
	os.remove("tmpfile.png")
end 

function PackingDescriptor:copyReferences()
	for _,ref in pairs(self.m_items) do 														-- work through all the entries.
		ref.reference.m_position = ref 															-- put a pointer to the position data 
	end 
end

--- ************************************************************************************************************************************************************************
--
--															Global Methods used by image generating scripts
--
--- ************************************************************************************************************************************************************************

local images = {} 																				-- mapping of image names to image objects
local imageList = {} 																			-- same but a straight list.
local sequences = {} 																			-- sequence name => frames,options

function input(directory) imageDirectory = directory or "" end  								-- set directories.
function output(directory) outputDirectory = directory or "" end 
function target(directory) targetDirectory = directory or "" end 

function sequence(name,frames,options)
	name = name:lower() 																		-- case irrelevant
	assert(sequences[name] == nil,"Sequence duplicated "..name)									-- check unique
	sequences[name] = { frames = frames, options = options or {} }								-- save stuff
end

function addImage(imageName,imageDefinition)
	local image = Image:new(imageName,imageDefinition) 											-- create a new image
	local name = image:getShortName()
	assert(images[name] == nil,"Image duplicated "..name) 										-- check not duplicated
	images[name] = image 																		-- save required image.
	imageList[#imageList+1] = image 															-- add to list.
	return image
end 

function import(...) 																			-- import images for use in the spritesheet
	local argList = { ... }
	for _,argument in ipairs(argList) do 														-- work through all arguments
		if type(argument) == "string" then 														-- handle single strings.
			local newArg = {}
			newArg[argument] = argument 
			argument = newArg 
		end 
		for k,v in pairs(argument) do 															-- work through pairs
			if type(k) == "number" then k = v end 												-- handle list input.
			local imageName = addImage(k,v):getShortName()
			sequence(imageName,{imageName},{})
		end
	end 
end 

function import3D(directory,name,scaling,options,forgetLast)
	local imageCount = 0
	options = options or { time = 1000 }														-- defaults.
	local seq = { frames = {}, options = options } 												-- sequence for this.
	repeat 																						-- figure out how many images there are
		local fileName = imageDirectory..directory.."/image_"..("%05d"):format(imageCount)..".png"
		local h = io.open(fileName,"r")
		if h ~= nil then h:close() end 
		imageCount = imageCount + 1
	until h == nil

	if forgetLast == true then imageCount = imageCount - 1 end 									-- optionally ignore the last one (repeating sequences)

	for img = 0,imageCount-2 do  																-- work through all images
		local fileName = imageDirectory..directory.."/image_"..("%05d"):format(img)..".png" 	-- this is the file name.
		local imageName = name .. "_" .. img 													-- short name
		local image = addImage(imageName,fileName .. scaling) 									-- add it in.
		seq.frames[#seq.frames+1] = image:getShortName() 										-- add it to the sequence
	end
	sequence(name,seq.frames,seq.options) 														-- add the sequence to the sequence list.
end 

function create(imageSheetFile,libraryFile,sheetWidth,packTries) 
	sheetWidth = sheetWidth or 512 packTries = packTries or 20 									-- default values
	table.sort(imageList, function(a,b) return a.m_pixels > b.m_pixels end) 					-- sort so biggest first.
	for _,ref in ipairs(imageList) do sheetWidth = math.max(sheetWidth,ref.m_width) end 		-- make sure sheet is at *least* wide enough.
	local bestSize = 99999999 																	-- best overall image sheet size
	local bestSheet = nil 																		-- best image sheet result.
	for i = 1,packTries do 																		-- repeatedly try packing.
		local sheet = PackingDescriptor:new(sheetWidth) 										-- create a new packing descriptor
		for _,ref in ipairs(imageList) do 														-- work through the image list.
			repeat 
				local isInserted = sheet:append(ref,ref.m_width,ref.m_height) 					-- try to add a graphic square in.
				if not isInserted and math.random(1,19) == 1 then sheet:extendHeight(4) end 	-- if failed, then make it bigger, very occasionally.
			until isInserted 																	-- until it is put in.
		end 																					-- put all objects in.
		if sheet.m_height < bestSize then 														-- best result so far.
			bestSize = sheet.m_height 															-- save the height
			bestSheet = sheet  																	-- and the packing information.
		end 
		--print(sheet.m_height,sheet.m_width)
	end 																						-- do as many times as you want to get best packing.
	bestSheet:render(outputDirectory..imageSheetFile)											-- create the images file.
	bestSheet:copyReferences() 																	-- copy references to the position data into the images
	for _,ref in ipairs(imageList) do ref.m_index = _ end 										-- copy indexes into image structure
	--print("Packed into ",bestSheet.m_width,bestSheet.m_height)

	local h = io.open(outputDirectory..libraryFile,"w") 										-- create the library file.
	h:write("-- Automatically generated.\n")
	h:write("local options = { frames={}, names={}, sequenceData={}, sequenceNames={} }\n")		-- create empty structures.
	h:write("options.spriteFileName = \"" .. targetDirectory .. imageSheetFile .. "\"\n")		-- tell it which file to use.
	h:write("options.sheetContentWidth = "..bestSheet.m_width.."\n") 							-- sheet content width/height
	h:write("options.sheetContentHeight = "..bestSheet.m_height.."\n")
	h:write("-- image sheet data\n")
	local pixelCount = 0
	for _,ref in ipairs(imageList) do 															-- for each item
		local pos = ref.m_position
		h:write(("options.frames[%d] = { x = %d,y = %d, width = %d, height = %d }\n"):			-- create a frame
													format(_,pos.x1,pos.y1,pos.width,pos.height))
		h:write(("options.names[\"%s\"] = %d\n"):format(ref:getShortName(),_)) 					-- and a back-reference
		pixelCount = pixelCount + ref.m_pixels
	end

	print("ImageSheet size is "..bestSheet.m_width.." x "..bestSheet.m_height.." pixels")		-- status information.
	print("Pixels in images",pixelCount) 													
	local sheetCount = bestSheet.m_width * bestSheet.m_height 
	print("Pixels in sheet ",sheetCount)
	print("Packing percent ",math.floor(100*pixelCount/sheetCount))

	h:write("-- sequence data\n")
	local seqCount = 1
	for name,ref in pairs(sequences) do 														-- work through the sequence.
		local s = ("{ name = \"%s\", frames = {"):format(name) 									-- start to build definition.
		for _,name in ipairs(ref.frames) do 													-- work through frame
			if s:sub(-1,-1) == "{" then s = s .." " else s = s .. "," end 						-- add seperator.
			local image = images[name:lower()]													-- get image data.
			assert(image ~= null,"Animation frame unknown "..name)								-- check it exists
			s = s .. tostring(image.m_index)													-- append the index value.
		end
		s = s .. " }" 																			-- end frames list.
		for k,v in pairs(ref.options) do 
			if type(v) == "string" then v = '"'..v..'"' end
			s = s .. ", " .. k .. " = "..v
		end
		h:write(("options.sequenceData[%d] = %s }\n"):format(seqCount,s))
		h:write(("options.sequenceNames[\"%s\"] = options.sequenceData[%d]\n"):format(name,seqCount))
		seqCount = seqCount + 1
	end
	h:write("-- method prototyping\n")
	h:write("options.defaultSheet = graphics.newImageSheet(options.spriteFileName,options)\n")
	h:write("options.getImageSheet = function(self) return graphics.newImageSheet(self.spriteFileName,self) end\n")
	h:write("options.getFrameNumber = function(self,name) return self.names[name:lower()] end\n")
	h:write("options.newImage = function(self,id) if type(id) == 'string' then id = self.names[id:lower()] end return display.newImage(self.defaultSheet,id) end\n")
	h:write("options.newSprite = function(self,seqData) return display.newSprite(options.defaultSheet,seqData or options.sequenceData) end\n")
	h:write("options.cloneSequence = function(self,name) local c = {} for k,v in pairs(self.sequenceNames[name:lower()]) do c[k] = v end return c end\n")
	h:write("options.addSequence = function(self,name,seq) name = name:lower() seq.name = name options.sequenceNames[name] = seq options.sequenceData[#options.sequenceData+1] = seq end\n")
	h:write("return options\n")
	h:close()
end 

--[[

	Sequential import (e.g. teeth1,teeth2,teeth3)
	Wildcard import (e.g. teeth*)
	Retro fit into numbers ?

--]]