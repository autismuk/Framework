--- ************************************************************************************************************************************************************************
---
---				Name : 		admob.lua
---				Purpose :	Admob v2 Object for Framework
---				Created:	20 July 2014
---				Updated:	04 Oct 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

local Ads = require("ads")

--- ************************************************************************************************************************************************************************
--//									Advert object. admob for iOS and Android, provides a fake if running in simulator.
--- ************************************************************************************************************************************************************************

local Advert = Framework:createClass("ads.admob")

--//	Create an advert. Information is passed in ApplicationDescription global
--//	@info 	[table]		Constructor information (not used)

function Advert:constructor(info)
	Advert.m_isDevice = system.getInfo("environment") == "device"								-- device or simulator.
	Advert.m_isAndroid = system.getInfo("platformName") == "Android"							-- running on Android or iOS ?

	if Advert.m_isDevice and Advert.isInitialised ~= true then 									-- is it a device, and has Ads.* not been initialised
		Advert.isInitialised = true 															-- only initialise it once.
		local adID 
		if Advert.m_isAndroid then 																-- get AppID (Android)
			adID = ApplicationDescription.admobIDs.android
		else 																					-- get AppID (iOS)
			adID = ApplicationDescription.admobIDs.ios
		end 
		assert(adID ~= nil,"Warning, App-ID Missing") 											-- check there actually is one.
		Ads.init("admob",adID) 																	-- and initialise the AdMob code.
	end 

	Advert.showCount = Advert.showCount or 0 													-- put default show-count value in.

	--print("Ad show",Advert.showCount)
	if Advert.showCount == 0 then 
		if Advert.m_isDevice then 																-- if on a real device, show the banner.
			Ads.show("banner")
		else
			if ApplicationDescription.showDebug then  											-- otherwise, fake one.
				Advert.m_fakeAdGroup = display.newGroup()
				local r = display.newRect(Advert.m_fakeAdGroup,0,0,display.contentWidth,Advert.simulatorHeight)
				r:setFillColor(0,0,0) r.strokeWidth = 2	r.anchorX = 0 r.anchorY = 0 
				local t = display.newText(Advert.m_fakeAdGroup,"Your ad goes here ....",2,2,native.systemFont,15)
				t.anchorX,t.anchorY = 0,0 t:setFillColor(0,1,0) Advert.m_fakeAdGroup.alpha = 0
				self:addSingleTimer(math.random(1000,2500)/1000)								-- make it appear, pretty much randomly after a second or two
			end
		end
		Advert.isSuccessfullyShown = true 														-- setting this flag means we can now legally call getHeight()
	else 
		if not Advert.m_isDevice and ApplicationDescription.showDebug then  
			Advert.m_fakeAdGroup:toFront()
		end
	end
	Advert.showCount = Advert.showCount + 1 													-- increment global count of shows
end 

function Advert:getDisplayObjects()
	return { Advert.m_fakeAdGroup }
end 

--//	This fakes the 'late' arrival of the actual advert, rather than it being put up straight away.

function Advert:onTimer(tag,timerID)
	Advert.m_fakeAdGroup.alpha = 1 																-- only one timer, which makes the fake advert visible.
end 

--//	Tidy up.

function Advert:destructor()
	Advert.showCount = Advert.showCount - 1 													-- decrement global count of shows
	-- print("Ad hide",Advert.showCount)
	if Advert.showCount == 0 then 
		if Advert.m_isDevice then 																-- remove the real ad or the fake one.
			Ads.hide()
		else 
			if ApplicationDescription.showDebug then
				Advert.m_fakeAdGroup:removeSelf() Advert.m_fakeAdGroup = nil 
			end
		end
	end 
end 

Advert.simulatorHeight = 42 																	-- arbitrary-ish size chosen for simulator advert.

--//	Gets the height of the banner in Corona device units. This function can only be called once the first advert is created, due to a limitation 
--//	in Corona. Therefore if you must know the height of a banner, you will have to create one and destroy one. 
--//
--//	@return 	[number]		height.

function Advert:getHeight()
	assert(Advert.isSuccessfullyShown == true,													-- Ads.getHeight() does not work until Ads.show() has been called
							"getHeight() called before an advert has been shown successfully")
	if not Advert.m_isDevice then return Advert.simulatorHeight end 								-- this is an arbitrary value for the simulator
	return Ads.height() 																		-- otherwise use the actual height.
end 

--//	Gets the height of the banner allowing for the gap at the top of the screen

function Advert:getHeightAfterGap()
	return self:getHeight()
end

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		20-Jul-14	0.1 		Initial version of file
		14-Aug-14 	1.0 		Advance to releasable version 1.0
		03-Oct-14 	1.1 		Made into a sort of singleton - all its variables are static. This is because there is only one Ads.x instance in Corona, and the
								effective sequencing in consecutive scenes with ads was show then show, hide on the transition, which meant the 2nd one didn't 
								display. Hence the counter "Advert.showCount" which tracks shows (constructors) vs hides (destructors).  Effectively when the ads is
								on the next scene, it doesn't disappear from the screen.  Consideration should be given to making this an actual singleton ?
		04-Oct-14 	1.2 		Moved stuff out of info into ApplicationDescription

--]]
--- ************************************************************************************************************************************************************************
