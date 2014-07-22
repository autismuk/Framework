--- ************************************************************************************************************************************************************************
---
---				Name : 		admob.lua
---				Purpose :	Admob v2 Object for Framework
---				Created:	20 July 2014
---				Updated:	20 July 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

local Ads = require("ads")

--- ************************************************************************************************************************************************************************
--//									Advert object. admob for iOS and Android, provides a fake if running in simulator.
--- ************************************************************************************************************************************************************************

local Advert = Framework:createClass("ads.admob")

--//	Create an advert. Parameters passed are android/ios/universal (Admob AppIDs), advertType, defaults to banner. Must provide the admob app-IDs
--//	@info 	[table]		Constructor information.

function Advert:constructor(info)
	self.m_isDevice = system.getInfo("environment") == "device"									-- device or simulator.
	self.m_isAndroid = system.getInfo("platformName") == "Android"								-- running on Android or iOS ?

	if self.m_isDevice and Advert.isInitialised ~= true then 									-- is it a device, and has Ads.* not been initialised
		Advert.isInitialised = true 															-- only initialise it once.
		local adID 
		if self.m_isAndroid then 																-- get AppID (Android)
			adID = info.android
		else 																					-- get AppID (iOS)
			adID = info.ios 
		end 
		adID = adID or info.universal 															-- possible universal App ID
		assert(adID ~= nil,"Warning, App-ID Missing") 											-- check there actually is one.
		Ads.init(info.provider or "admob",adID) 												-- and initialise the AdMob code.
	end 

	if self.m_isDevice then 																	-- if on a real device, show the banner.
		Ads.show(info.advertType or "banner")
	else 																						-- otherwise, fake one.
		self.m_fakeAdGroup = display.newGroup()
		local r = display.newRect(self.m_fakeAdGroup,0,0,display.contentWidth,Advert.simulatorHeight)
		r:setFillColor(0,0,0) r.strokeWidth = 2	r.anchorX = 0 r.anchorY = 0 
		local t = display.newText(self.m_fakeAdGroup,"Your ad goes here ....",2,2,native.systemFont,15)
		t.anchorX,t.anchorY = 0,0 t:setFillColor(0,1,0) self.m_fakeAdGroup.alpha = 0
		self:addSingleTimer(math.random(1000,2500)/1000)										-- make it appear, pretty much randomly after a second or two
	end
	Advert.isSuccessfullyShown = true 															-- setting this flag means we can now legally call getHeight()
end 

function Advert:getDisplayObjects()
	return { self.m_fakeAdGroup }
end 

--//	This fakes the 'late' arrival of the actual advert, rather than it being put up straight away.

function Advert:onTimer(tag,timerID)
	self.m_fakeAdGroup.alpha = 1 																-- only one timer, which makes the fake advert visible.
end 

--//	Tidy up.

function Advert:destructor()
	if self.m_isDevice then 																	-- remove the real ad or the fake one.
		Ads.hide()
	else 
		self.m_fakeAdGroup:removeSelf() self.m_fakeAdGroup = nil 
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
	if not self.m_isDevice then return Advert.simulatorHeight end 								-- this is an arbitrary value for the simulator
	return Ads.height() 																		-- otherwise use the actual height.
end 

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		20-Jul-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
