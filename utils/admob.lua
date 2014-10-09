--- ************************************************************************************************************************************************************************
---
---				Name : 		admob.lua
---				Purpose :	Admob v2 Object for Framework
---				Created:	20 July 2014
---				Updated:	09 Oct 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

local Ads = require("ads")

--- ************************************************************************************************************************************************************************
--//									Advert object. admob for iOS and Android, provides a fake if running in simulator.
--- ************************************************************************************************************************************************************************

local AdvertManager = Framework:createClass("ads.admob.manager")

AdvertManager.defaults = { ios = {}, android = {} }												-- these are default admob IDs for banner and interstitial adverts
AdvertManager.defaults.ios.interstitial = 	  "ca-app-pub-8354094658055499/7057436417" 			-- iOS and Android.
AdvertManager.defaults.ios.banner = 		  "ca-app-pub-8354094658055499/9860763610"
AdvertManager.defaults.android.interstitial = "ca-app-pub-8354094658055499/2348035218"
AdvertManager.defaults.android.banner = 	  "ca-app-pub-8354094658055499/839456881"

function AdvertManager:constructor(info)
	self.m_isDevice = system.getInfo("environment") == "device"									-- device or simulator.
	self.m_isAndroid = system.getInfo("platformName") == "Android"								-- running on Android or iOS ?

	local type = ApplicationDescription.advertType 												-- check type
	assert(type == "banner" or type == "interstitial") 											-- must be banner or interstitial

	if self.m_isDevice then 																	-- if it is a device.
		ApplicationDescription.admobIDs = ApplicationDescription.admobIDs or {} 				-- make sure there is an admobIDs.

		if self.m_isAndroid then 																
			adID = ApplicationDescription.admobIDs.android 										-- get AppID (Android)
			adID = adID or AdvertManager.defaults.android[type] 								-- apply default
		else 																					
			adID = ApplicationDescription.admobIDs.ios 											-- get AppID (iOS)
			adID = adID or AdvertManager.defaults.ios[type] 									-- apply default.
		end 
		
		assert(adID ~= nil,"Warning, App-ID Missing") 											-- check there actually is one.
		Ads.init("admob",adID) 																	-- and initialise the AdMob code.

		if ApplicationDescription.advertType == "interstitial" then 							-- if this application uses interstitial ads
			Ads.load("interstitial")															-- start the preloader.
		end

	end 
	self.m_showCount = 0 																		-- zero the show count.
	self.m_isSuccessfullyShown = false 															-- not shown yet.
end 

function AdvertManager:destructor()
	while self.m_showCount > 0 do 															-- keep hiding until the advert has gone away.
		self:hide()
	end
end 


function AdvertManager:show()
	assert(ApplicationDescription.advertType == "banner")										-- this is only allowed for *banners*

	if self.m_showCount == 0 then 																-- is it the first show (e.g. showing from)
		if self.m_isDevice then 																-- if on a real device, show the banner.
			Ads.show("banner")
		else
			if ApplicationDescription.showDebug then  											-- otherwise, fake one.
				self.m_fakeAdGroup = display.newGroup()
				local r = display.newRect(self.m_fakeAdGroup,0,0,display.contentWidth,self:getSimulatorHeight())
				r:setFillColor(1,0.5,0) r.strokeWidth = 2	r.anchorX = 0 r.anchorY = 0 
				local t = display.newText(self.m_fakeAdGroup,"Your ad goes here ....",display.contentWidth/2,
														self:getSimulatorHeight()/2,native.systemFont,display.contentWidth/15)
				t:setFillColor(0,0,0) 
			end
		end
		self.m_isSuccessfullyShown = true 														-- setting this flag means we can now legally call getHeight()
	else 
		if not self.m_isDevice and ApplicationDescription.showDebug then  						-- bring the fake advert to the front.
			self.m_fakeAdGroup:toFront()
		end
	end
	self.m_showCount = self.m_showCount + 1 													-- increment global count of shows
end 


function AdvertManager:hide()
	self.m_showCount = self.m_showCount - 1 													-- decrement global count of shows

	if self.m_showCount == 0 then 
		if self.m_isDevice then 																-- remove the real ad or the fake one.
			Ads.hide()
		else 
			if ApplicationDescription.showDebug then
				self.m_fakeAdGroup:removeSelf() self.m_fakeAdGroup = nil 
			end
		end
	end 
end 

function AdvertManager:getSimulatorHeight()
	return 42 * display.contentHeight / 320 
end 

local adManager = Framework:new("ads.admob.manager")											-- create an instance.
AdvertManager.constructor = nil 																-- stop any more being created.


local AdvertObject = Framework:createClass("ads.admob")

function AdvertObject:constructor(info)
	adManager:show()
end 

function AdvertObject:destructor()
	adManager:hide()
end

function AdvertObject:getHeight()
	assert(adManager.m_isSuccessfullyShown == true,												-- Ads.getHeight() does not work until Ads.show() has been called
							"getHeight() called before an advert has been shown successfully")
	if not adManager.m_isDevice then return adManager:getSimulatorHeight() end 					-- this is an arbitrary value for the simulator
	return Ads.height() 																		-- otherwise use the actual height.
end 

function AdvertObject:getHeightAfterGap()
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
		09-Oct-14 	2.0 		Now a singleton and a device object

--]]
--- ************************************************************************************************************************************************************************
