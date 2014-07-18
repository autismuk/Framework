--- ************************************************************************************************************************************************************************
---
---				Name : 		sound.lua
---				Purpose :	Sound cache/management class
---				Created:	18 July 2014
---				Updated:	18 July 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

require("framework.framework")

local AudioCache = Framework:createClass("audio.sound")

--//	Constructor - info.sounds is a list of samples, default is mp3.
--//	@info 	[table]		Constructor parameters

function AudioCache:constructor(info)
	self.m_soundCache = {} 																		-- cached audio
	for _,name in ipairs(info.sounds) do  														-- work through list of audio filenames
		local fName = self:getFileName(name)													-- get full file name
		local stub = fName:match("%/(.*)%."):lower() 											-- get the 'stub', the name without the extension as l/c 
		self.m_soundCache[stub] = audio.loadSound(fName) 										-- load and store in cache.
	end
	self:tag("+soundplayer")
end 

--//	Play a sound effect from the cache.
--//	@name 	[string]			stub name, case insensitive
--//	@options [table] 			options for play, see audio.play() documents

function AudioCache:play(name,options)
	name = name:lower() 																		-- case irrelevant
	assert(self.m_soundCache[name] ~= nil,"Unknown sound "..name) 								-- check sound actually exists
	audio.play(self.m_soundCache[name],options) 												-- play it 
end 

--//	Handle the message which instructs a sfx to play.
--//	@sender 	[object]		Who sent the message
--//	@name 		[string]		Should be 'play'
--//	@body 		[table]			sound and options members for the play call

function AudioCache:onMessage(sender,name,body)
	assert(name == "play")																		-- check message name correct.
	self:play(body.sound,body.options) 															-- play the sound.
end 

--//	Given a stub file, get the full file name
--//	@name 	[string]		short file name
--//	@return [string]		reference to file, in audio subdirectory.

function AudioCache:getFileName(name)
	if name:find("%.") == nil then name = name .. ".mp3" end  									-- no extension, default to .mp3
	return "audio/"..name 																		-- actual name of file in audio subdirectory.
end 

--//	Check if sound present.
--//	@name 	[string]		short name of sound
--//	@return [boolean]		true if present.

function AudioCache:isSoundPresent(name)
	return (self.m_soundCache[name:lower()] ~= nil)
end 

--//	Destructor

function AudioCache:destructor()
	for _,ref in pairs(self.m_soundCache) do audio.dispose(ref) end 							-- clear out the cache.
	self.m_soundCache = nil 																	-- nil so references lost.
end 

Framework:addObjectMethod("playSound",function(self,sound,options) 								-- add playSound method to all objects.
		self:sendMessage("soundplayer","play",{ sound = sound, options = options})
	end)

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		18-Jul-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
