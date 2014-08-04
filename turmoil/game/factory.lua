--- ************************************************************************************************************************************************************************
---
---				Name : 		factory.lua
---				Purpose :	Code for spawning enemies, keeps track of those killed.
---				Created:	4 August 2014
---				Updated:	4 August 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

local EnemyFactory = Framework:createClass("game.enemyFactory")

EnemyFactory.TYPE_COUNT = 7 

function EnemyFactory:constructor(info)
	self.m_enemyTotals = {} 																	-- count of enemies to kill of each type.
	self.m_enemyCount = info.level * 4 + 10 													-- number of bad guys in each level.
	for i = 1,EnemyFactory.TYPE_COUNT do self.m_enemyTotals[i] = 0 end 							-- clear individual count
	for i = 1,self.m_enemyCount do 																-- add them distributed randomly.
		local n = math.random(1,EnemyFactory.TYPE_COUNT)
		self.m_enemyTotals[n] = self.m_enemyTotals[n] + 1
	end 
	self:createEnemyQueue() 																	-- reset the queue of enemies
	self.m_level = info.level 																	-- save the game level.
end

function EnemyFactory:destructor() 
end 

function EnemyFactory:createEnemyQueue()
	self.m_enemyQueue = {} 																		-- queue of enemies to spawn.
	self.m_nextQueueItem = 1 																	-- number of next to spawn.
	for i = 1,#self.m_enemyTotals do 															-- work through all the enemy totals.
		for j = 1,self.m_enemyTotals[i] do 														-- add an enemy for each count of enemies.
			self.m_enemyQueue[#self.m_enemyQueue+1] = i 										-- use the number as an ID.
		end
	end 
	if #self.m_enemyQueue > 1 then 																-- randomise it by shuffling simply.
		for i = 1,#self.m_enemyQueue do 
			local j = math.random(1,#self.m_enemyQueue)
			local t = self.m_enemyQueue[i] 
			self.m_enemyQueue[i] = self.m_enemyQueue[j]
			self.m_enemyQueue[j] = t 
		end
	end
end 

function EnemyFactory:killedEnemy(typeID)
	self.m_enemyTotals[typeID] = self.m_enemyTotals[typeID] - 1 								-- reduce one for the totals for this type
	self.m_enemyCount = self.m_enemyCount - 1 													-- and the overall total.
end 

function EnemyFactory:spawn(sceneRef,gameSpace)
	local tID = self.m_enemyQueue[self.m_nextQueueItem] 										-- get the next one to spawn.
	self.m_nextQueueItem = self.m_nextQueueItem + 1 											-- bump the queue.
	sceneRef:new("game.enemy.type"..tID,{ gameSpace = gameSpace, factory = self,type = tID, 	-- spawn one.
																					level = self.m_level })
end 

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		04-Aug-2014	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
