-- Automatically generated.
local options = { frames={}, names={}, sequenceData={}, sequenceNames={} }
options.spriteFileName = "images/sprites.png"
options.sheetContentWidth = 512
options.sheetContentHeight = 748
-- image sheet data
options.frames[1] = { x = 46,y = 0, width = 203, height = 197 }
options.names["bigteeth1"] = 1
options.frames[2] = { x = 274,y = 1, width = 203, height = 197 }
options.names["bigteeth2"] = 2
options.frames[3] = { x = 134,y = 201, width = 145, height = 141 }
options.names["teeth2"] = 3
options.frames[4] = { x = 323,y = 200, width = 145, height = 141 }
options.names["teeth1"] = 4
options.frames[5] = { x = 115,y = 342, width = 298, height = 56 }
options.names["buttonblueover"] = 5
options.frames[6] = { x = 2,y = 212, width = 125, height = 119 }
options.names["crane arm"] = 6
options.frames[7] = { x = 236,y = 415, width = 200, height = 60 }
options.names["level1btn"] = 7
options.frames[8] = { x = 114,y = 400, width = 100, height = 100 }
options.names["facebookbtn-over"] = 8
options.frames[9] = { x = 11,y = 384, width = 100, height = 100 }
options.names["moon"] = 9
options.frames[10] = { x = 472,y = 275, width = 40, height = 240 }
options.names["warped"] = 10
options.frames[11] = { x = 2,y = 484, width = 96, height = 96 }
options.names["glow"] = 11
options.frames[12] = { x = 337,y = 497, width = 90, height = 90 }
options.names["pausebtn"] = 12
options.frames[13] = { x = 116,y = 503, width = 90, height = 90 }
options.names["closebtn-over"] = 13
options.frames[14] = { x = 227,y = 479, width = 90, height = 90 }
options.names["crateb 2"] = 14
options.frames[15] = { x = 235,y = 584, width = 90, height = 90 }
options.names["crateb"] = 15
options.frames[16] = { x = 40,y = 611, width = 120, height = 37 }
options.names["grass@25%"] = 16
options.frames[17] = { x = 335,y = 605, width = 60, height = 60 }
options.names["ofbtn-over"] = 17
options.frames[18] = { x = 443,y = 577, width = 60, height = 60 }
options.names["circlemask@30%"] = 18
options.frames[19] = { x = 447,y = 516, width = 60, height = 60 }
options.names["egg"] = 19
options.frames[20] = { x = 230,y = 680, width = 73, height = 32 }
options.names["button1"] = 20
options.frames[21] = { x = 347,y = 684, width = 73, height = 32 }
options.names["buttonbluesmall"] = 21
options.frames[22] = { x = 404,y = 645, width = 73, height = 32 }
options.names["button2"] = 22
options.frames[23] = { x = 76,y = 656, width = 73, height = 32 }
options.names["buttonbluesmallover1"] = 23
options.frames[24] = { x = 154,y = 680, width = 60, height = 30 }
options.names["default"] = 24
options.frames[25] = { x = 41,y = 331, width = 45, height = 32 }
options.names["buttonbluemini"] = 25
options.frames[26] = { x = 10,y = 656, width = 45, height = 30 }
options.names["buttonblueminiover"] = 26
options.frames[27] = { x = 421,y = 679, width = 30, height = 30 }
options.names["star"] = 27
options.frames[28] = { x = 439,y = 726, width = 35, height = 15 }
options.names["brick"] = 28
options.frames[29] = { x = 93,y = 691, width = 16, height = 16 }
options.names["ball"] = 29
-- sequence data
options.sequenceData[1] = { name = "teeth", frames = { 4,3 }, time = 500, loopCount = 4 }
options.sequenceNames["teeth"] = options.sequenceData[1]
options.sequenceData[2] = { name = "bigteeth", frames = { 1,2 }, time = 400 }
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
