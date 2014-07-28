--
--		Typical definition file. This is an actual lua script which leverages tosprite.lua and graphics magick
--	
require("tosprite.lua") 															-- we need this library to make things work.

--
--		Set I/O Files.
--

output("./")
input("images/")

--
--		Import some images in various ways.
--
import({ "ball", "brick "}) 														-- table
import( "circlemask","teeth1","teeth2" ) 											-- multiple parameters
import( { button1 = "buttonBlueSmall", button2 = "buttonBlueSmallOver" }) 			-- renamed some files
import( { warped = "teeth1@40x240" }) 												-- scaling and resizing
import({ bigteeth1 = "teeth1@140%" })
import({ bigteeth2 = "teeth2@140%" })

--
-- 		Now lets define some sequences
--

sequence("teeth", { "teeth1","teeth2"}, { time = 500, loopCount = 4 }) 				-- sequences - name, frames, and sequence options
sequence("bigteeth", { "bigteeth1","bigteeth2"}, { time = 200 })

--
-- 		Now pack them and generate the image sheet stuff.
--

create("sprites.png","sprites.lua",512,40)											-- imagesheet, library file, imagesheet width (default 256), retries (default 25)


-- this generates a library .lua class which can be required(), returns an object, it has the following members
-- 
-- xxx.getImageSheet() 					returns an image sheet, encapsulates the various bits (display.newImageSheet)
-- xxx.getFrameNumber(name)				given a name, return the frame number.
-- xxx.newSprite([parent])				get a new sprite/image with optional parent (display.newSprite) 	
-- xxx.newImage([parent],frame)			extract a single frame - can be either the ID (from getFrameNumber() or the image name)	
