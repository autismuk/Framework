--
--		Typical definition file. This is an actual lua script which leverages tosprite.lua and graphics magick
--	
require("tosprite") 																-- we need this library to make things work.

--
--		Set I/O Files. These are where files are stored or accessed when building, relative to where this script is run.
--

output("../images/")
input("static/")
scale = "@50%"

--
-- 		Set Image Directory. This is where the file is stored when the application is run, e.g. a relative directory to main.lua
--
target("images/")

--
--		Import some images in various ways.
--

import("arrow"..scale,"ghost"..scale,"player"..scale,"player_banked"..scale)
import3D("enemy1",scale)
import3D("enemy2",scale)
import3D("enemy3",scale)
import3D("enemy4",scale)
import3D("enemy5",scale)
import3D("prize",scale)
import3D("tank",scale)

create("sprites.png","sprites.lua")													-- imagesheet, library file, imagesheet width (default 256), retries (default 40)


-- this generates a library .lua class which can be required(), returns an object, it has the following members
-- 
-- xxx:getImageSheet() 					returns an image sheet, encapsulates the various bits (display.newImageSheet)
-- xxx:getFrameNumber(name)				given a name, return the frame number.
-- xxx.newSprite([sequenceData])		get a new sprite/image with optional parent (display.newSprite) 	
-- xxx.newImage(frame)					extract a single frame - can be either the ID (from getFrameNumber() or the image name)	
-- xxx.cloneSequence(name) 				create a shallow copy of an existing sequence.
-- xxx.addSequence(sequence) 			add a sequence to the sequence list.
