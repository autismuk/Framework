--- ************************************************************************************************************************************************************************
---
---				Name : 		messaging.lua
---				Purpose :	messaging object (sub part of Framework)
---				Created:	16 July 2014
---				Updated:	17 July 2014
---				Author:		Paul Robson (paul@robsons.org.uk)
---				License:	Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

local MessagingClass = Framework:createClass("system.messaging")

--//	Construct the messaging object.

function MessagingClass:constructor(info)
	self:tag("enterFrame") 																		-- tag as enter frame so called every frame
	self.m_messageList = {}  																	-- message list.
end

--//	Destroy the messaging object.

function MessagingClass:destructor() 
	self.m_messageList = nil 
end 

--//	Send a message via the queue.
--//	@target 	[string/object]			query or recipient, can be a single entity or a hash of them.
--//	@name 		[string]				message name. (optional)
--//	@body 		[table]					anything else you want to send other than the name  (optional)
--//	@delay 		[number]				delay sending the message this many seconds.

function MessagingClass:sendMessage(target,name,body,delay)
	name = name or "" body = body or {} delay = delay or -1 									-- default values.
	assert(type(target) == "string" or type(target) == "table","Message must be sent to object(s) or a query")
	assert(type(name) == "string","Message name should be a string")
	--print(type(body),name)
	assert(type(body) == "table","Message body should be a table")
	assert(type(delay) == "number","Delay time should be a number")
	local newMessage = { sender = self,  														-- from me
						 recipient = target, 													-- to this or them
						 name = name, 															-- called this
						 body = body, 															-- with this data
						 timeToSend = delay 													-- time left before sending.
					   }
	self.m_messageList[#self.m_messageList+1] = newMessage 										-- add to message list.
end 

--//	Called every frame. Dispatches messages that are due.
--//	@deltaTime 	[number]				elapsed time in seconds
--//	@currentTime [number]				current time in seconds

function MessagingClass:onEnterFrame(deltaTime) 
	if #self.m_messageList == 0 then return end 												-- no messages, do nothing.
	local toSendList = self.m_messageList 														-- make a copy of the messages
	self.m_messageList = {} 																	-- clear the list - messages not due will be added back.
	for _,msg in ipairs(toSendList) do 															-- work through the message list.
		msg.timeToSend = msg.timeToSend - deltaTime 											-- subtract time elapsed.
		if msg.timeToSend <= 0 and Framework:isAsyncEnabled() then 								-- is it time to send ?
			self:sendSingleMessage(msg)															-- send it.
		else 																					-- not time to send it, put it in the queue.
			self.m_messageList[#self.m_messageList+1] = msg
		end 
	end
end 

--//	Send a single message
--//	@message 	[table]		message structure.

function MessagingClass:sendSingleMessage(message)
	local target = message.recipient 															-- this is the target.
	if type(target) == "table" and target.__frameworkData ~= nil then 							-- is it a single item ?
		target = { item = target }																-- put it in a table as the single value.
	end 
	if type(target) == "string" then 															-- is it a query.
		local count 
		count,target = Framework:query(target) 													-- run the query.
		if count == 0 then return end 															-- if query is empty, then exit straight away.
	end 
	Framework:perform(target,"onMessage",message.sender,message.name,message.body) 				-- call onMessage() for all of them.
end

local messagingInstance = Framework:new("system.messaging",{})									-- create an instance of the messaging class.

Framework:addObjectMethod("sendMessage", function(self,target,name,body) 						-- add methods to the mixin list.
		messagingInstance:sendMessage(target,name,body,0) 										-- both actually call the same method.
	end)

Framework:addObjectMethod("sendMessageLater", function(self,target,name,body,delay)
		messagingInstance:sendMessage(target,name,body,delay)
	end)

--- ************************************************************************************************************************************************************************
--[[

		Date 		Version 	Notes
		---- 		------- 	-----
		16-Jul-14	0.1 		Initial version of file

--]]
--- ************************************************************************************************************************************************************************
