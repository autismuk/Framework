--- ************************************************************************************************************************************************************************
---
---				Name : 		miscellany.lua
---				Purpose :	Assorted small classes
---				Created:	11 August 2014
---				Updated: 	11 August 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************


require("utils.fontmanager")

local Intro = Framework:createClass("game.intro")

function Intro:constructor(info)
	self.m_text = display.newBitmapText("Let's go for\na kill time !",
										display.contentWidth/2,
										display.contentHeight/2,
										"grapple",48)
	self.m_text:setJustification()
	self.m_text:setTintColor(1,1,0)
	self:tag("introText")
end

function Intro:destructor()
	self.m_text:removeSelf()
	self.m_text = nil
end 

function Intro:getDisplayObjects() 
	return { self.m_text }
end

function Intro:onMessage(sender,message,data)
	transition.to(self.m_text,{ time = 1500,y = -320, alpha = 0,
					onComplete = function() self:delete() end })
end

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		11-Aug-2014	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
