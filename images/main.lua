--
-- 	test program for tosprite library
--
display.setStatusBar(display.HiddenStatusBar)

local demoSprites = require("sprites")															-- library which has been generated

local imageSheet = demoSprites:getImageSheet()													-- get an image sheet

print(demoSprites:getFrameNumber("ball")," should be 10") 										-- show getFrameNumber() works.

for i = 1,29 do 																				-- display all images.
	local d = demoSprites:newImage(i)															-- create an image
	d.x = (i - 1) % 6 * 50																		-- position it etc.
	d.y = math.floor((i - 1) / 6) * 50		
	d.anchorX,d.anchorY = 0,0
	d.width,d.height = 50,50
end

local d2 = demoSprites:newImage("ball") 														-- create image by name.
d2.x = 280 d2.y = 350

local altSequence = demoSprites:cloneSequence("teeth") 											-- create copy of teeth.
--for k,v in pairs(altSequence) do print(k,v) end 
altSequence.time = 150 altSequence.loopCount = 0 												-- modify it.
demoSprites:addSequence("qteeth",altSequence)													-- add it called 'qteeth'

local animation = demoSprites:newSprite()														-- new sprite
animation.x,animation.y = 200,400 																-- move to correct place
animation:setSequence("bigteeth")																-- select and play an animation.
animation:play()
transition.to(animation, { time = 10000, rotation = 360 })										-- rotate it slowly.

timer.performWithDelay(2000, function() animation:setSequence("qteeth") animation:play() end)	-- change animation after two seconds.