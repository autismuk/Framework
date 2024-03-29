--
--		Typical definition file. This is an actual lua script which leverages tosprite.lua and graphics magick
--	
require("tosprite") 																-- we need this library to make things work.

--
--		Set I/O Files. These are where files are stored or accessed when building, relative to where this script is run.
--

output("./")
input("pictures/")

--
-- 		Set Image Directory. This is where the file is stored when the application is run, e.g. a relative directory to main.lua
--
target("images/")
--
--		Import some images in various ways.
--
import({ "ball", "brick"}) 															-- table
import( "circlemask@30%","teeth1","teeth2" ) 											-- multiple parameters
import( { button1 = "buttonBlueSmall", button2 = "buttonBlueSmallOver" }) 			-- renamed some files
import( { warped = "teeth1@40x240" }) 												-- scaling and resizing
import({ bigteeth1 = "teeth1@140%" })
import({ bigteeth2 = "teeth2@140%" })

local x = { "buttonBlueMini", "buttonBlueMiniOver","buttonBlueOver","buttonBlueSmall","buttonBlueSmallOver1",
		"closebtn-over","crane arm","crateB 2","crateB" }
import(x)

x = { "default", "egg", "facebookbtn-over", "glow", "grass@25%", "level1btn", "moon", "ofbtn-over", "pausebtn", "star" }
import(x)

--
-- 		Now lets define some sequences
--

sequence("teeth", { "teeth1","teeth2"}, { time = 500, loopCount = 4 }) 				-- sequences - name, frames, and sequence options
sequence("bigteeth", { "bigteeth1","bigteeth2"}, { time = 400 })

--
-- 		Now pack them and generate the image sheet stuff.
--

create("sprites.png","sprites.lua")													-- imagesheet, library file, imagesheet width (default 256), retries (default 40)


-- this generates a library .lua class which can be required(), returns an object, it has the following members
-- 
-- xxx:getImageSheet() 					returns an image sheet, encapsulates the various bits (display.newImageSheet)
-- xxx:getFrameNumber(name)				given a name, return the frame number.
-- xxx.newSprite([sequenceData])		get a new sprite/image with optional parent (display.newSprite) 	
-- xxx.newImage(frame)					extract a single frame - can be either the ID (from getFrameNumber() or the image name)	
-- xxx.cloneSequence(name) 				create a shallow copy of an existing sequence.
-- xxx.addSequence(sequence) 			add a sequence to the sequence list.
