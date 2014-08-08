--- ************************************************************************************************************************************************************************
---
---				Name : 		main.lua
---				Purpose :	Top level code "Turmoil"
---				Created:	8 August 2014
---				Updated:	8 August 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

local ScoreObject = Framework:createClass("game.status")

function ScoreObject:constructor(info)
	self.m_lives = info.lives or 4
	self.m_score = 0
	self.m_level = info.level or 1
	self.m_channels = info.channel or 7
	self:name("status")
end 

function ScoreObject:destructor() end
function ScoreObject:getLives() return self.m_lives end 
function ScoreObject:getScore() return self.m_score end 
function ScoreObject:getLevel() return self.m_level end 
function ScoreObject:getChannels() return self.m_channels end 

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		08-Aug-2014	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************

