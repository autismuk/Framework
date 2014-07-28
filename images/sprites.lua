-- Automatically generated.
local options = { frames={}, names={}, sequenceData={}, sequenceNames={} }
options.spriteFileName = "sprites.png"
options.sheetContentWidth = 512
options.sheetContentHeight = 472
options.frames[1] = { x = 164,y = 0, width = 200, height = 200 }
options.names["circlemask"] = 1
options.frames[2] = { x = 259,y = 203, width = 203, height = 197 }
options.names["bigteeth2"] = 2
options.frames[3] = { x = 22,y = 204, width = 203, height = 197 }
options.names["bigteeth1"] = 3
options.frames[4] = { x = 5,y = 31, width = 145, height = 141 }
options.names["teeth1"] = 4
options.frames[5] = { x = 367,y = 6, width = 145, height = 141 }
options.names["teeth2"] = 5
options.frames[6] = { x = 467,y = 159, width = 40, height = 240 }
options.names["warped"] = 6
options.frames[7] = { x = 406,y = 422, width = 73, height = 32 }
options.names["button1"] = 7
options.frames[8] = { x = 209,y = 432, width = 73, height = 32 }
options.names["button2"] = 8
options.frames[9] = { x = 334,y = 451, width = 35, height = 15 }
options.names["brick"] = 9
options.frames[10] = { x = 145,y = 453, width = 16, height = 16 }
options.names["ball"] = 10
options.defaultSheet = graphics.newImageSheet(options.spriteFileName,options)
options.getImageSheet = function(self) return graphics.newImageSheet(self.spriteFileName,self) end
options.getFrameNumber = function(self,name) return self.names[name:lower()] end
options.newImage = function(self,id) if type(id) == 'string' then id = self.names[id:lower()] end return display.newImage(self.defaultSheet,id) end
return options
