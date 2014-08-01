-- Automatically generated.
local options = { frames={}, names={}, sequenceData={}, sequenceNames={} }
options.spriteFileName = "images/sprites.png"
options.sheetContentWidth = 512
options.sheetContentHeight = 64
-- image sheet data
options.frames[1] = { x = 397,y = 0, width = 64, height = 64 }
options.names["arrow"] = 1
options.frames[2] = { x = 208,y = 0, width = 64, height = 64 }
options.names["player"] = 2
options.frames[3] = { x = 320,y = 0, width = 64, height = 64 }
options.names["ghost"] = 3
options.frames[4] = { x = 141,y = 0, width = 64, height = 64 }
options.names["player_banked"] = 4
-- sequence data
-- method prototyping
options.defaultSheet = graphics.newImageSheet(options.spriteFileName,options)
options.getImageSheet = function(self) return graphics.newImageSheet(self.spriteFileName,self) end
options.getFrameNumber = function(self,name) return self.names[name:lower()] end
options.newImage = function(self,id) if type(id) == 'string' then id = self.names[id:lower()] end return display.newImage(self.defaultSheet,id) end
options.newSprite = function(self,seqData) return display.newSprite(options.defaultSheet,seqData or options.sequenceData) end
options.cloneSequence = function(self,name) local c = {} for k,v in pairs(self.sequenceNames[name:lower()]) do c[k] = v end return c end
options.addSequence = function(self,name,seq) name = name:lower() seq.name = name options.sequenceNames[name] = seq options.sequenceData[#options.sequenceData+1] = seq end
return options
