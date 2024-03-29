--- ************************************************************************************************************************************************************************
---
---				Name : 		controller.lua
---				Purpose :	4-Way Controller Class
---				Created:	17 July 2014
---				Updated:	18 July 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

require("framework.framework")

--- ************************************************************************************************************************************************************************
--//															Four way controller class
--- ************************************************************************************************************************************************************************

local Controller = Framework:createClass("io.controller.fouraxis")

--//	Create a new controller.
--//	@info 	[table]			contains (optionally x,y and radius)

function Controller:constructor(info)
	info.radius = info.radius or math.min(display.contentWidth,display.contentHeight) / 5 		-- default values for x,y,radius
	info.x = info.x or display.contentWidth - 5 - info.radius 
	info.y = info.y or display.contentHeight - 5 - info.radius 
	self.group = display.newGroup() 															-- this group contains all objects
	self.group.x, self.group.y = info.x,info.y  												-- move to the middle
	self.outerRadius = info.radius 																-- calculate inner/outer radii
	self.innerRadius = info.radius * 0.6
	self:createDisplay(self.innerRadius,self.outerRadius)										-- create display elements
	self.group:addEventListener("touch",self)													-- listen for touch messages
end 

--//	Get display objects for Scenes
--//	@return [list] 	List of display objects

function Controller:getDisplayObjects()
	return { self.group }
end 

--//%	Create display. Can be pretty much anything, except there must be a member 'button' which is the moveable button
--//	(may be a group itself) and it needs to be centred around 0,0 in the group and the working max radius is the outer one.
--//	@ri 	[number]			inner radius
--//	@ro 	[number]			outer radius

function Controller:createDisplay(ri,ro)
	local outer = display.newCircle(self.group,0,0,ro)											-- draw inner and outer lines
	outer:setFillColor(0,0,0,0.01) outer.strokeWidth = math.max(2,ro/20) 						-- note the alpha is non-zero so they can be picked up.
	local inner = display.newCircle(self.group,0,0,ri)
	inner:setFillColor(0,0,0,0.01) inner.strokeWidth = 1
	inner:setStrokeColor(1,1,0) outer:setStrokeColor(1,1,0)
	display.newLine(self.group,-ro,0,ro,0):setStrokeColor(1,1,0) 								-- cross lines
	display.newLine(self.group,0,-ro,0,ro):setStrokeColor(1,1,0)
	self.button = display.newCircle(self.group,0,0,ri) 											-- button
	self.button.fill.effect = "generator.radialGradient"
	self.button.fill.effect.color1 = { 1,0,0,1 }
	self.button.fill.effect.color2 = { 0.6,0,0,1 }
	self.button.fill.effect.center_and_radiuses = { 0.5,0.5,0,0.5 }
end

--//	Remove a controller.

function Controller:destructor()
	self.group:removeEventListener("touch",self) 												-- no longer listening
	self.group:removeSelf() 																	-- remove display objects and tidy up
	self.group = nil self.outerRadius = nil self.innerRadius = nil self.button = nil
end

--//%	Handle touches
--//	@e 	[event]			event info

function Controller:touch(e)
	if e.phase == "began" or e.phase == "moved" then 											-- treat them the same - we WANT that 'jump'
		local newx = e.x-self.group.x  															-- adjust to relative coordinates
		local newy = e.y-self.group.y
		self.button.x = newx 																	-- put button there. We don't limit where it goes
		self.button.y = newy  																	-- but its range is determined by the radius
	end

	if e.phase == "ended" or e.phase == "cancelled" then 										-- end of button
		transition.to(self.button,{ x = 0,y = 0, time = 100 }) 									-- back to middle
	end
end

--//%	Force number into range -1 .. 1
--//	@a 	[number]		number to force
--//	@result [number]	result

function Controller:minimax(a) 
	return math.max(-1,math.min(a,1)) 
end 

--//	Get current stick position horizontal
--//	@return [number]	value from -1 to 1

function Controller:getX() 
	return self:minimax(self.button.x / (self.outerRadius - self.innerRadius)) 
end 

--//	Get current stick position vertical
--//	@return [number]	value from -1 to 1

function Controller:getY() 
	return self:minimax(self.button.y / (self.outerRadius - self.innerRadius)) 
end 

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		17-Jul-14	0.1 		Initial version of file
		14-Aug-14 	1.0 		Advance to releasable version 1.0

--]]
--- ************************************************************************************************************************************************************************
