--- ************************************************************************************************************************************************************************
---
---				Name : 		pageselector.lua
---				Purpose :	Page Selector - shows what page of swipe left/right (or anything else) we are on.
---				Updated:	13 October 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************


--- ************************************************************************************************************************************************************************
--											Page Selector base object - can be subclassed for different display effects
--- ************************************************************************************************************************************************************************

local PageIdentifier = Framework:createClass("control.selector.circle")

--//	Create a new object with a certain number of pages, can be changed.

function PageIdentifier:constructor(info)
	self.m_group = display.newGroup()												-- group for all display objects
	self.m_selectors = {}															-- selector objects - normally one per page.
	self:create(info.count or 0) 													-- create a default set, normally the swipe scene sets this
	self:tag("swipepagetracker")													-- tag it as something that displays swipe pages
end 

--//	Tidy up

function PageIdentifier:destructor()
	self.m_group:removeSelf() self.m_group = nil self.m_selectors = nil
end 

--//	Recreate the page identifier.
--//	@count 	[number]		number of pages

function PageIdentifier:create(count)
	self.m_count = count 															-- save the page count
	for i = 1,#self.m_selectors do self.m_selectors[i]:removeSelf() end 			-- remove any old selectors
	self.m_selectors = {} 															-- new list
	for i = 1,count do  															-- create it
		self.m_selectors[i] = self:createItem(i)
	end 
	self:select(1)																	-- select first as default
	self.m_group.anchorX,self.m_group.anchorY = 0.5,0.5 							-- centre it at the bottom of the screen
	self.m_group.x,self.m_group.y = display.contentWidth/2,display.contentHeight * 0.92
	self.m_group.anchorChildren = true 												-- we need anchoring
end

--//	Select current page
--//	@n 	[number]	Page to select

function PageIdentifier:select(n)
	for i = 1,#self.m_selectors do 													-- go through all selectors
		self:setSelected(self.m_selectors[i],i == n) 								-- turning off/on as required.
	end 
end 

--//	Required for scene support
--//	@return [array]	array of display objects

function PageIdentifier:getDisplayObjects()
	return { self.m_group }
end 

--//	Handle messages from abstract swipable that allow things to be set up
--//	@sender 	[object]	who sent it
--//	@message 	[string]	the message
--//	@body 		[object]	other informaiton

function PageIdentifier:onMessage(sender,message,body)
	if message == "count" then 														-- set the number of pages
		self:create(body.count) 
	end 
	if message == "select" then 													-- set the current page
		self:select(body.page)
	end
end 

--//	Create a new selector in position n - can be overridden to change visual display
--//	@n 	[number]	position, 1 up.

function PageIdentifier:createItem(n)
	local c = display.newCircle(self.m_group,										-- this is a circle
									n*display.contentWidth/16,0,display.contentWidth/64)
	c.strokeWidth = math.max(1,display.contentWidth/320) c:setStrokeColor(1,1,1)	-- framed in white
	return c
end 

--//	Set a selectors state - can be overridden to change display
--//	@obj 	[obj]	display object used to select this page
--//	@state  [boolean] 	true if this page is selected

function PageIdentifier:setSelected(obj,state)
	obj:setFillColor(1,0,0) if state then obj:setFillColor(0,0.6,0) end 			-- set colour to red/green accordingly.
end 

--- ************************************************************************************************************************************************************************
--//										Simple subclass of Page Identifier using squares rather than diamonds
--- ************************************************************************************************************************************************************************

local PageIdentifierDiamond = Framework:createClass("control.selector.diamond","control.selector.circle")

--//	Create a new selector in position n - can be overridden to change visual display
--//	@n 	[number]	position, 1 up.

function PageIdentifierDiamond:createItem(n)
	local c = display.newRect(self.m_group,											-- this is a square
									n*display.contentWidth/16,0,display.contentWidth/32,display.contentWidth/32)
	c.rotation = 45 																-- it's now a diamond.
	c.strokeWidth = math.max(1,display.contentWidth/320) c:setStrokeColor(1,1,1)	-- framed in white
	return c
end 

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		13-Oct-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
