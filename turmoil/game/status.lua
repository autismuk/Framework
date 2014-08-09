--- ************************************************************************************************************************************************************************
---
---				Name : 		status.lua
---				Purpose :	Game Status Object
---				Created:	8 August 2014
---				Updated:	8 August 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

local StatusObject = Framework:createClass("game.status")

--//	Initialise Status Object

function StatusObject:constructor(info)
	self.m_highScore = 0
	self:reset()
end 

function StatusObject:reset()
	self.m_lives = info.lives or 4
	self.m_score = 0
	self.m_level = info.level or 1
	self.m_channels = info.channel or 7
	self:name("status")
end 

function StatusObject:destructor() end

--//	Simple Accessors

function StatusObject:getLives() return self.m_lives end 
function StatusObject:getScore() return self.m_score end 
function StatusObject:getHighScore() return self.m_highScore end 
function StatusObject:getLevel() return self.m_level end 
function StatusObject:getChannels() return self.m_channels end 

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		08-Aug-2014	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************

