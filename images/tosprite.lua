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
_G.Base =  _G.Base or { new = function(s) local o = {} setmetatable(o,s) s.__index = s s:initialise() return o end, initialise = function() end }

local Control = {
	debug = false
}

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
	if newHeight == nil then 
		newWidth = newWidth or 100
		cmd = ("convert -resize %dx%d%%! %s %s"):format(newWidth,newWidth,originalFile,targetFile)
	else
		cmd = ("convert -resize %dx%d! %s %s"):format(newWidth,newHeight,originalFile,targetFile)
	end
	self:_execute(cmd)
end

gm = Graphics:new()
gm:createImage("demo.png",384,384)
sz = gm:getSize("images/teeth1.png")
print(sz.width,sz.height)
gm:composite("demo.png","images/teeth1.png",0,0)
gm:resize("teethlarge.png","images/teeth1.png",240,250)
sz = gm:getSize("teethlarge.png")
print(sz.width,sz.height)
gm:composite("demo.png","teethlarge.png",30,30)
