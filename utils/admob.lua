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

require("utils.buttons")

--- ************************************************************************************************************************************************************************
--//									Advert object. admob for iOS and Android, provides a fake if running in simulator.
--- ************************************************************************************************************************************************************************

local AdvertManager = Framework:createClass("ads.admob.manager")

AdvertManager.defaults = { ios = {}, android = {} }												-- these are default admob IDs for banner and interstitial adverts
AdvertManager.defaults.ios.interstitial = 	  "ca-app-pub-8354094658055499/7057436417" 			-- iOS and Android.
AdvertManager.defaults.ios.banner = 		  "ca-app-pub-8354094658055499/9860763610"
AdvertManager.defaults.android.interstitial = "ca-app-pub-8354094658055499/2348035218"
AdvertManager.defaults.android.banner = 	  "ca-app-pub-8354094658055499/839456881"

--//	Create the advert manager singleton 
--//	@info 	[table] 	constructor info (not used)

function AdvertManager:constructor(info)
	self.m_isDevice = system.getInfo("environment") == "device"									-- device or simulator.
	self.m_isAndroid = system.getInfo("platformName") == "Android"								-- running on Android or iOS ?

	local type = ApplicationDescription.advertType 												-- check type
	assert(type == "banner" or type == "interstitial") 											-- must be banner or interstitial

	self.m_showCount = 0 																		-- zero the show count.
	self.m_isSuccessfullyShown = false 															-- not shown yet.
	self.m_isLiveInterstitial = false 															-- true if interstitial on a device.

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

		Ads.init("admob",adID,function(event) 													-- and initialise the AdMob code.

			--print("[ADMOB] Listener event",event.phase)

			if event.phase == "shown" then 														-- in the shown phase (e.g. interstitial closed)
				self:sendMessage("interstitialadvert","next",{})
			end
			--print("[ADMOB] Listener exit")
		end)

		if ApplicationDescription.advertType == "interstitial" then 							-- if this application uses interstitial ads
			Ads.load("interstitial")															-- start the preloader.
			self.m_isLiveInterstitial = true 													-- mark as a live interstitial.
		end

	end 
end 

--//	Close the advert manager singleton

function AdvertManager:destructor()
	while self.m_showCount > 0 do 															-- keep hiding until the advert has gone away.
		self:hide()
	end
end 

--//	Show an advert (banner only). This keeps a count of shows vs hides and displays the advert when the shows outnumber the hides. This is required
--//	because scenes are created and opened before the previous scene is destroyed, so consecutive scenes with adverts never actually hide the ad.

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

--//	Hide an advert (banner only)

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

--//	Get the simulated height of an advert (debugging only)
--//	@return 	[number]		height of advert in display pixels

function AdvertManager:getSimulatorHeight()
	return 42 * display.contentHeight / 320 													-- scale for contentHeight
end 

--//	Test to see if running on real hardware
--//	@return 	[boolean]		true if running on real hardware.

function AdvertManager:isPhysicalDevice()
	return self.m_isDevice 
end 

function AdvertManager:isInterstitialLoaded()
	local isLoaded = false 																		-- will be true if ads loaded
	if self:isPhysicalDevice() then 														-- are we on a physical device ?
		isLoaded = Ads.isLoaded("interstitial")													-- if so, we can check if the ad is loaded.
	end
	return isLoaded
end

local adManager = Framework:new("ads.admob.manager")											-- create an instance.
AdvertManager.constructor = nil 																-- stop any more being created.

--- ************************************************************************************************************************************************************************
--//			Creating this object will add it to the current scene. Note this does not behave like other visual objects, because it can't do it.
--- ************************************************************************************************************************************************************************

local AdvertObject = Framework:createClass("ads.admob")

--//	Constructing it causes 'show'

function AdvertObject:constructor(info)
	adManager:show()
end 

--//	Destructing it causes 'hide'.

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
--//									This scene is an admob interstitial scene, which goes to 'next' when closed.
--- ************************************************************************************************************************************************************************

local InterstitialScene = Framework:createClass("admob.interstitialscene","game.sceneManager")

function InterstitialScene:preOpen(manager,data,resources)
	local scene = Framework:new("game.scene")													-- create a new, empty, scene.
	self.m_passedData = data
	return scene 																				-- construction is in postOpen()
end 

function InterstitialScene:postOpen(manager,data,resources)
	local isLoaded = adManager:isInterstitialLoaded()											-- check if interstitial loaded
	InterstitialScene.lastSceneShowed = system.getTimer() 										-- remember last time i/s showed.
	local scene = self:getScene()																-- access current scene.
	self:tag("interstitialadvert")
	--print("[ADMOB] Loaded",isLoaded)

	if adManager:isPhysicalDevice() and isLoaded then 
		Ads.show("interstitial") 																-- show the interstitial scene.
	else 
		scene:new("control.rightarrow", { x = 90, y = 5,r = 139/255, g = 69/255, b = 19/255, 	-- add right arrow to go to next scene.
													listener = self, message = "continue" }) 	-- this is the 'fake' interstitial advert.
	end 	
end 

function InterstitialScene:postClose(manager,data,resources)
	self.m_passedData = nil 
end

function InterstitialScene:onMessage(sender,message,body)

	--print("[ADMOB] Scene exit message")
	if adManager:isPhysicalDevice() then 														-- on a real device
		--print("ADMOB] call hide")
		Ads.hide()																				-- hide it
		Ads.load("interstitial") 																-- and reload the next.
	end
	self:performGameEvent("next",self.m_passedData)
	--print("[ADMOB] Next done.")
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
		10-Oct-14 	2.1 		Got a working Interstitial Scene Object

--]]
--- ************************************************************************************************************************************************************************

-- TODO: Repeat time manager.
