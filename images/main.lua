--
-- 	test program for tosprite library
--

local demoSprites = require("sprites")

local imageSheet = demoSprites:getImageSheet()

print(demoSprites:getFrameNumber("ball")," should be 10")

for i = 1,10 do 
	local d = demoSprites:newImage(i)
	d.x = (i - 1) % 3 * 100
	d.y = math.floor((i - 1) / 3) * 100
	d.anchorX,d.anchorY = 0,0
	d.width,d.height = 100,100
end

local sequenceData = { 
	{ name = "demo1", frames = { 2,3,4 }, time = 400 }
}

local animation = display.newSprite(imageSheet,sequenceData)
animation.x,animation.y = 200,400
animation:setSequence("demo1")
animation:play()
sequenceData.time = 200