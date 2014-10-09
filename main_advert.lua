
ApplicationDescription = { 																		-- application description.
	appName = 		"Interstitial Test",
	version = 		"1.0",
	developers = 	{ "Paul Robson" },
	email = 		"paul@robsons.org.uk",
	fqdn = 			"uk.org.robsons.brainwash", 												-- must be unique for each application.
	advertType = 	"interstitial",
	showDebug = 	true 																		-- show debug info and adverts.
}

require("utils.stubscene")
require("utils.admob")

local manager = Framework:new("game.manager") 													-- Create a new game manager and then add states.


manager:addManagedState("start",																-- set up scene
						Framework:new("utils.stubscene",{  name = "Scene 1",  targets = { next = "next page"} }),
						{ next = "advert" })

manager:addManagedState("advert",																-- set up scene
						Framework:new("utils.stubscene",{  name = "Scene 2 (AD)",  targets = { next = "next page"} }),
						{ next = "end" })

manager:addManagedState("end",																-- set up scene
						Framework:new("utils.stubscene",{  name = "Scene 3",  targets = { next = "next page"} }),
						{ next = "start" })

manager:start("start") 																			-- and start.

--[[

		Check defaults work by hacking BrainDrain and putting in hardware platforms
		Implement interstitial code.

--]]