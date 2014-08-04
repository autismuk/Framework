--- ************************************************************************************************************************************************************************
---
---				Name : 		enemies.lua
---				Purpose :	Enemy Classes
---				Created:	4 August 2014
---				Updated:	4 August 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

local EnemyBase = Framework:createClass("game.enemybase")

local Sprites = require("images.sprites")

function EnemyBase:constructor(info)

	self.m_gameSpace = info.gameSpace 															-- remember game space
	self.m_enemyFactory = info.factory 															-- remember factory
	self.m_enemyType = info.type 																-- type reference.
	self.m_sprite = Sprites:newSprite() 														-- sprite for this enemy
	self.m_sprite:setSequence(self:getSpriteSequence()) 										-- set sequence and play
	self.m_sprite:play()
	self.m_speedScalar = math.min(1 + (info.level - 1) / 8,3)
	self.m_channel = self.m_gameSpace:assignChannel(self,info.preferred) 						-- assign it to a channel, possible preference
	self.m_xPosition = 0 self.m_xDirection = 1 													-- start on left
	if math.random(1,2) == 1 then  																-- or right, random choice
		self.m_xPosition = 100 self.m_xDirection = -1 
	end
	self.m_elapsedTime = 0 																		-- object life timer
	self:reposition() 																			-- draw initial position.

end 

function EnemyBase:destructor()
	self:deassignChannel(self) 																	-- remove from channel
	self.m_sprite:removeSelf() 																	-- remove sprite and null references
	self.m_sprite = nil self.m_gameSpace = nil self.m_enemyFactory = nil 
end 

function EnemyBase:getDisplayObjects()
	return { self.m_sprite }
end 

function EnemyBase:onUpdate(deltaTime)
	self.m_elapsedTime = self.m_elapsedTime + deltaTime  										-- update object life timer
	local adjSpeed = math.min(200,self:getSpeed() * self.m_speedScalar)
	self.m_xPosition = self.m_xPosition + adjSpeed * self.m_xDirection * deltaTime 				-- new position
	if self.m_xPosition < 0 or self.m_xPosition > 100 then  									-- off left or right ?
		self.m_xPosition = math.min(100,math.max(0,self.m_xPosition)) 							-- put in 0-100 limit
		self:bounce() 																			-- and bounce.
	end
	self:reposition() 																			-- redraw.
end 

function EnemyBase:kill()
	self.m_enemyFactory:killedEnemy(self.m_enemyType)											-- tell the factory it has died
	-- TODO: explosion
	-- TODO: score points11
	self:delete()																				-- and kill object.
end 

function EnemyBase:bounce() 
	self.m_xDirection = -self.m_xDirection 														-- reverse horizontal direction.
end 

function EnemyBase:reposition()
	local x,y = self.m_gameSpace:getPos(self.m_xPosition,self.m_channel) 						-- get physical position
	self.m_sprite.x,self.m_sprite.y = x,y 														-- update position
	self.m_sprite.xScale = self.m_gameSpace:getSpriteSize()/64									-- reset sprite size
	self.m_sprite.yScale = self.m_gameSpace:getSpriteSize()/64
	if self.m_xDirection < 0 then self.m_sprite.xScale = -self.m_sprite.xScale end 				-- adjust for right-left movement
end 

local Enemy1 = Framework:createClass("game.enemy.type1","game.enemybase") 						
function Enemy1:getSpriteSequence() return "enemy1" end 
function Enemy1:getSpeed() return 20 end

local Enemy2 = Framework:createClass("game.enemy.type2","game.enemybase")
function Enemy2:getSpriteSequence() return "enemy2" end 
function Enemy2:getSpeed() return 8 end

local Enemy3 = Framework:createClass("game.enemy.type3","game.enemybase")
function Enemy3:getSpriteSequence() return "enemy3" end 
function Enemy3:getSpeed() return 16 end

local Enemy4 = Framework:createClass("game.enemy.type4","game.enemybase")
function Enemy4:getSpriteSequence() return "enemy4" end 
function Enemy4:getSpeed() return 12 end

local Enemy5 = Framework:createClass("game.enemy.type5","game.enemybase")
function Enemy5:getSpriteSequence() return "enemy5" end 
function Enemy5:getSpeed() return 14 end

local Enemy6 = Framework:createClass("game.enemy.type6","game.enemybase") 						-- the prize class.

function Enemy6:constructor(info)
	self.super.constructor(self,info)															-- superconstructor
	self.m_hasStarted = false  																	-- set to true when has started pinging
	self.m_startTime = 4 																		-- when it starts pinging (seconds)
end 

function Enemy6:getSpriteSequence() return "prize" end 

function Enemy6:getSpeed() 
	return self.m_hasStarted and 100 or 0 														-- stationary until it starts pinging
end

function Enemy6:onUpdate(deltaTime)
	self.super.onUpdate(self,deltaTime) 														-- super update
	if self.m_elapsedTime > self.m_startTime then 												-- has it reached pinging time
		self.m_hasStarted = true 																-- if so, mark as such.
	end 
end 

local Enemy7 = Framework:createClass("game.enemy.type7","game.enemybase") 						-- the arrow to tank class.

function Enemy7:constructor(info)
	self.super.constructor(self,info) 															-- superconstructor
	self.m_isTank = false 																		-- true if tank
end 

function Enemy7:bounce()
	self.super.bounce(self) 																	-- still bounce
	if not self.m_isTank then 																	-- but if arrow, make a tank on bounce.
		self.m_isTank = true 
		self.m_sprite:setSequence("tank")
		self.m_sprite:play()
	end
end 

function Enemy7:getSpriteSequence() 
	return "arrow" 
end 

function Enemy7:getSpeed() 
	return self.m_isTank and 6 or 10 															-- tanks are slower.
end

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		04-Aug-2014	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
