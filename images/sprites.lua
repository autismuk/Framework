-- Automatically generated.
local options = { frames={}, names={}, sequenceData={}, sequenceNames={} }
options.spriteFileName = "sprites.png"
options.sheetContentWidth = 512
options.sheetContentHeight = 996
-- image sheet data
options.frames[1] = { x = 16,y = 2, width = 480, height = 150 }
options.names["grass"] = 1
options.frames[2] = { x = 90,y = 153, width = 200, height = 200 }
options.names["circlemask"] = 2
options.frames[3] = { x = 291,y = 161, width = 203, height = 197 }
options.names["bigteeth2"] = 3
options.frames[4] = { x = 162,y = 364, width = 203, height = 197 }
options.names["bigteeth1"] = 4
options.frames[5] = { x = 15,y = 409, width = 145, height = 141 }
options.names["teeth2"] = 5
options.frames[6] = { x = 365,y = 370, width = 145, height = 141 }
options.names["teeth1"] = 6
options.frames[7] = { x = 3,y = 562, width = 298, height = 56 }
options.names["buttonblueover"] = 7
options.frames[8] = { x = 375,y = 542, width = 125, height = 119 }
options.names["crane arm"] = 8
options.frames[9] = { x = 141,y = 618, width = 200, height = 60 }
options.names["level1btn"] = 9
options.frames[10] = { x = 27,y = 624, width = 100, height = 100 }
options.names["facebookbtn-over"] = 10
options.frames[11] = { x = 344,y = 668, width = 100, height = 100 }
options.names["moon"] = 11
options.frames[12] = { x = 34,y = 164, width = 40, height = 240 }
options.names["warped"] = 12
options.frames[13] = { x = 131,y = 698, width = 96, height = 96 }
options.names["glow"] = 13
options.frames[14] = { x = 326,y = 783, width = 90, height = 90 }
options.names["crateb 2"] = 14
options.frames[15] = { x = 111,y = 801, width = 90, height = 90 }
options.names["crateb"] = 15
options.frames[16] = { x = 20,y = 764, width = 90, height = 90 }
options.names["closebtn-over"] = 16
options.frames[17] = { x = 223,y = 849, width = 90, height = 90 }
options.names["pausebtn"] = 17
options.frames[18] = { x = 353,y = 874, width = 60, height = 60 }
options.names["ofbtn-over"] = 18
options.frames[19] = { x = 258,y = 730, width = 60, height = 60 }
options.names["egg"] = 19
options.frames[20] = { x = 20,y = 936, width = 73, height = 32 }
options.names["button2"] = 20
options.frames[21] = { x = 3,y = 730, width = 73, height = 32 }
options.names["buttonbluesmallover1"] = 21
options.frames[22] = { x = 76,y = 899, width = 73, height = 32 }
options.names["buttonbluesmall"] = 22
options.frames[23] = { x = 232,y = 815, width = 73, height = 32 }
options.names["button1"] = 23
options.frames[24] = { x = 13,y = 864, width = 60, height = 30 }
options.names["default"] = 24
options.frames[25] = { x = 443,y = 804, width = 45, height = 32 }
options.names["buttonbluemini"] = 25
options.frames[26] = { x = 120,y = 966, width = 45, height = 30 }
options.names["buttonblueminiover"] = 26
options.frames[27] = { x = 465,y = 876, width = 30, height = 30 }
options.names["star"] = 27
options.frames[28] = { x = 79,y = 369, width = 35, height = 15 }
options.names["brick"] = 28
options.frames[29] = { x = 199,y = 949, width = 16, height = 16 }
options.names["ball"] = 29
-- sequence data
options.sequenceData[1] = { name = "teeth", frames = { 6,5 }, time = 500, loopCount = 4 }
options.sequenceNames["teeth"] = options.sequenceData[1]
options.sequenceData[2] = { name = "bigteeth", frames = { 4,3 }, time = 400 }
options.sequenceNames["bigteeth"] = options.sequenceData[2]
-- method prototyping
options.defaultSheet = graphics.newImageSheet(options.spriteFileName,options)
options.getImageSheet = function(self) return graphics.newImageSheet(self.spriteFileName,self) end
options.getFrameNumber = function(self,name) return self.names[name:lower()] end
options.newImage = function(self,id) if type(id) == 'string' then id = self.names[id:lower()] end return display.newImage(self.defaultSheet,id) end
options.newSprite = function(self,seqData) return display.newSprite(options.defaultSheet,seqData or options.sequenceData) end
options.cloneSequence = function(self,name) local c = {} for k,v in pairs(self.sequenceNames[name:lower()]) do c[k] = v end return c end
options.addSequence = function(self,name,seq) name = name:lower() seq.name = name options.sequenceNames[name] = seq options.sequenceData[#options.sequenceData+1] = seq end
return options
