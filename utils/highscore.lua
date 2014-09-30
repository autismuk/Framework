-- ************************************************************************************************************************************************************************
---
---             Name :      highscore.lua
---             Purpose :   High Score Class
---             Created:    29 September 2014
---             Updated:    29 September 2014
---             Author:     Paul Robson (paul@robsons.org.uk)
---             License:    Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

require("utils.document")															-- requires the document storage to work.

local HighScore = Framework:createClass("document.highscore")

--//	Construct a high score table (kept in document.store)

function HighScore:constructor(info)
	local ref = Framework.fw.documentStore:access() 								-- get access to the document score
	if ref.highScoreTable == nil then 												-- no high score table ?
		ref.highScoreTable = { scores = {}, scoreCount = 20 }						-- create an empty high score table.
		for i = 1,ref.highScoreTable.scoreCount do 									-- put zero in all the high scores
			ref.highScoreTable.scores[i] = { score = 0, scoreData = nil} 
		end 
		Framework.fw.documentStore:update() 										-- write it back.
	end
	self:name("highScoreTable") 													-- name the object 'high score table'
end 

--//	Destructor updates before termination

function HighScore:destructor()
	Framework.fw.documentStore:update() 											-- write it back.
end	

--//	Add a new score, and optionally score data, to the high score table and sort it.
--//	@score 		[number]		Score
--//	@scoreData 	[table]			Optional associated data (e.g. name)

function HighScore:add(score,scoreData)
	assert(type(score) == "number","Bad parameter")
	local ref = Framework.fw.documentStore:access() 								-- get access to the document score
	local hst = ref.highScoreTable 													-- high score table constructor.
	hst.scores[hst.scoreCount+1] = { score = score, scoreData = scoreData } 		-- put the score in the n+1th entry
	table.sort(hst.scores, function(a,b) return a.score > b.score end) 				-- sort in increasing score order.
	hst.scores[hst.scoreCount+1] = nil 												-- remove the last entry
	Framework.fw.documentStore:update() 											-- write it back.
end

--//	Get the size of the high score table
--//	@return 	[number]		Number of table entries

function HighScore:getTableSize()
	return Framework.fw.documentStore:access().highScoreTable.scoreCount 
end 

--//	Get the score and data from the high score table
--//	@n 			[number]		Table entry
--//	@return 	[number,table]	Score for that entry and associated data (note, this will be not nil)

function HighScore:get(n)
	assert(n >= 1 and 																-- check validity
					n <= Framework.fw.documentStore:access().highScoreTable.scoreCount,"Bad score number")
	local entry = Framework.fw.documentStore:access().highScoreTable.scores[n] 		-- fetch the nth entry
	return entry.score,entry.scoreData or {} 										-- return score and associate data.
end 

Framework:new("document.highscore")													-- create a new high score table, this is a singleton
HighScore.constructor = nil 														-- stop any more being created.

--- ************************************************************************************************************************************************************************
--[[
        Date        Version     Notes
        ----        -------     -----
        29-Sep-14   0.1         Initial version of file

--]]
--- ************************************************************************************************************************************************************************

