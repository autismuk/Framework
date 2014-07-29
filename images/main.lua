--
-- 	test program for tosprite library
--
display.setStatusBar(display.HiddenStatusBar)

local demoSprites = require("sprites")															-- library which has been generated

local imageSheet = demoSprites:getImageSheet()													-- get an image sheet

print(demoSprites:getFrameNumber("ball")," should be 10") 										-- show getFrameNumber() works.

for i = 1,10 do 																				-- display all images.
	local d = demoSprites:newImage(i)															-- create an image
	d.x = (i - 1) % 3 * 70																		-- position it etc.
	d.y = math.floor((i - 1) / 3) * 70		
	d.anchorX,d.anchorY = 0,0
	d.width,d.height = 70,70
end

local d2 = demoSprites:newImage("ball") 														-- create image by name.
d2.x = 280 d2.y = 50

local animation = demoSprites:newSprite()														-- new sprite
animation.x,animation.y = 200,400 																-- move to correct place
animation:setSequence("bigteeth")																-- select and play an animation.
animation:play()
transition.to(animation, { time = 10000, rotation = 360 })										-- rotate it slowly.

timer.performWithDelay(2000, function() animation:setSequence("teeth") animation:play() end)	-- change animation after two seconds.