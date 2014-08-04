--- ************************************************************************************************************************************************************************
---
---				Name : 		player.lua
---				Purpose :	Player ship code
---				Created:	3 August 2014
---				Updated:	3 August 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

local Sprites = require("images.sprites")

local Player = Framework:createClass("game.player")

--	Players have four states

Player.WAIT_STATE = 0 																			-- state, waiting for command.
Player.MOVE_STATE = 1 																			-- moving to a specific position.
Player.FETCH_STATE = 2 																			-- going to grab a prize
Player.RETURN_STATE = 3 																		-- returning from grabbing a prize.

--//	Create a new player - needs a gameSpace parameter so it knows where it is operating.
--//	@info 	[table]	cosntructor info

function Player:constructor(info)
	self.m_gameSpace = info.gameSpace 															-- space player is operating in.
	self.m_sprite = Sprites:newSprite() 														-- graphic used.
	self.m_xPosition = 50 																		-- current position.
	self.m_channel = math.floor(self.m_gameSpace:getSize()/2) 									-- start channel
	self.m_faceRight = true  																	-- facing right
	self.m_playerState = Player.WAIT_STATE  													-- waiting for command
	self:reposition() 																			-- can reposition.
	self:tag("taplistener")																		-- want to listen ?
end 

--//	Tidy up

function Player:destructor()
	self.m_sprite:removeSelf() 																	-- remove sprite object
	self.m_gameSpace = nil  																	-- null reference.
end 

--//	Get objects that are part of the scene.
--//	@return 	[list]	List of display objects

function Player:getDisplayObjects() 
	return { self.m_sprite }
end 

--//	Reposition and put correct sprite up for the current player status

function Player:reposition()
	self.m_sprite:setSequence("player") 														-- set to player sprite (e.g. not moving)
	local x,y = self.m_gameSpace:getPos(self.m_xPosition,self.m_channel) 						-- find out where to draw it
	self.m_sprite.x,self.m_sprite.y = x,y  														-- put it there.
	local s = self.m_gameSpace:getSpriteSize()/64 												-- scale to required size.
	self.m_sprite.yScale = s  																	-- set y scale
	if not self.m_faceRight then s = -s end 													-- facing left ?
	if self.m_playerState == Player.RETURN_STATE then s = -s end  								-- returning from prize grab, so face other way
	self.m_sprite.xScale = s 																	-- set x scale, sign shows sprite direction.
end

--//	Handle message - listens for control messages
--//	@sender 	[object]	who sent it
--//	@message 	[string]	what it is
--//	@data 		[object]	associated data

function Player:onMessage(sender,message,data)
	if self.m_playerState == Player.RETURN_STATE or 											-- if fetching a prize, can do nothing till
	   self.m_playerState == Player.FETCH_STATE then return end  								-- finished.

	self.m_faceRight = data.x >= 50 															-- set face left/right
	self:reposition() 																			-- and reposition sprite.
	if data.y == self.m_channel then return end 												-- do nothing if same position.

	local _,yNew = self.m_gameSpace:getPos(0,data.y)											-- this is where we are moving to.

	if self.m_playerState == Player.MOVE_STATE then 											-- cancel any current transaction.
		transition.cancel(self.m_transaction)
	end 

	self.m_sprite:setSequence("player_banked")													-- display banked ship graphic.
	if data.y < self.m_channel then self.m_sprite.yScale = -self.m_sprite.yScale end
	self.m_playerState = Player.MOVE_STATE 	 													-- we are now moving.
	self.m_transaction = transition.to(self.m_sprite,{ 	time = 90 * math.abs(data.y - self.m_channel), 
									  					y = yNew,
									  					transition = easing.inOutSine,
									  					onComplete = function() self:endMovement() end })
	self.m_channel = data.y 																	-- update position.
	self:playSound("move")
end 

--//	Called to end movement of player

function Player:endMovement()
	self.m_playerState = Player.WAIT_STATE 														-- back to wait state, can fire now.
	self.m_transaction = nil 																	-- forget transaction reference
	self:reposition() 																			-- tidy up display.
	-- TODO: If prize available go and get it.
end 

function Player:onUpdate(deltaTime)
	-- TODO: Update firing time.
	-- TODO: Move if fetching a prize
	-- TODO: Check for fire if in wait_state and time elapsed.
end 

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		3-Aug-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
