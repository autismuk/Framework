--- ************************************************************************************************************************************************************************
---
---				Name : 		main_sprite.lua
---				Purpose :	Test for image packing library
---				Created:	29 July 2014
---				Updated:	30 July 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

local demoSprites = require("images.sprites")													-- library which has been generated

local imageSheet = demoSprites:getImageSheet()													-- get an image sheet


for i = 1,29 do 																				-- display all images.
	local d = demoSprites:newImage(i)															-- create an image
	d.x = (i - 1) % 6 * 50																		-- position it etc.
	d.y = math.floor((i - 1) / 6) * 50		
	d.anchorX,d.anchorY = 0,0
	d.width,d.height = 50,50
end

local animation = demoSprites:newSprite()														-- new sprite
animation.x,animation.y = 200,300 																-- move to correct place
animation:setSequence("enemy1")																-- select and play an animation.
animation:play()

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		29-Jul-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
