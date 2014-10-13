--- ************************************************************************************************************************************************************************
---
---				Name : 		text.lua
---				Purpose :	Bitmap Text Scene Object - used for 'Get Ready' type things that animate then remove.
---				Created:	15 August 2014
---				Updated:	26 September 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

require("utils.fontmanager")																	-- leverages font manager

local TextScene = Framework:createClass("control.text")

function TextScene:constructor(info)
	assert(info.font ~= nil,"No font defined")
	local txt = display.newBitmapText(info.text or "(no text)", 								-- put up text message with defaults
									  info.x or display.contentWidth/2, 						-- centre screen
									  info.y or display.contentHeight/2,
									  info.font,	 											-- mandatory
									  (info.fontSize or 25) * display.contentWidth/100) 	
	txt.xScale = info.xScale or 1 txt.yScale = info.yScale or 1 txt.alpha = info.alpha or 1
	if info.alpha then txt.alpha = info.alpha end 												-- copy alpha, if any
	if info.tint then txt:setTintColor(info.tint.r,info.tint.g,info.tint.b) end 				-- copy tint, if any	
	if info.transition then 																	-- if there's a transition.
		info.transition.onComplete = info.transition.onComplete or 								-- by default, it just removes itself.
													function(obj) obj:removeSelf() end 						 	
		transition.to(txt,info.transition) 														-- do the transition.
	end 

	self.m_text = txt 																			-- remember the text object
end

function TextScene:destructor()
	self.m_text:removeSelf() 
	self.m_text = nil 
end 

function TextScene:getDisplayObjects()
	return { self.m_text }
end 

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		30-Aug-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
