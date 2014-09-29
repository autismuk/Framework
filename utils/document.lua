--- ************************************************************************************************************************************************************************
---
---             Name :      document.lua
---             Purpose :   Document storage class
---             Created:    28 September 2014
---             Updated:    29 September 2014
---             Author:     Paul Robson (paul@robsons.org.uk)
---             License:    Copyright Paul Robson (c) 2014+
---
--- ************************************************************************************************************************************************************************

local json = require("json")
local DocumentStore = Framework:createClass("document.store")

--//    Open/Create a document store. The filename is built from the fqdn in the ApplicationDescriptor

function DocumentStore:constructor(info)
    self.m_fileName = ApplicationDescription.fqdn:lower():gsub("%.","_")            -- make lower case, documents to underscores.
    self.m_fileName = "corona_psr_" .. self.m_fileName .. ".json"                   -- make it a .json file name.
    local path = system.pathForFile(self.m_fileName,system.DocumentsDirectory)      -- actual file name
    self.m_documentData = { application = info.appName }                            -- document data
    local file = io.open(path, "r")                                                 -- try to read it
    if file then                                                                    -- if opened okay
         local contents = file:read("*a")                                           -- read it all, decode from JSON
         self.m_documentData = json.decode(contents);
         io.close(file)                                                             -- close file.
    end
    self:name("documentStore") self:tag("documentStore")                            -- name and tag it.
end 

--//    On deletion, just update the stored file.

function DocumentStore:destructor()
    self:update()                                                                   -- update the .json file.
end 

--//    Get access to the applications data.

function DocumentStore:access()
    return self.m_documentData 
end 

--//    Write the document data back to the document storage.

function DocumentStore:update()
    local path = system.pathForFile(self.m_fileName,system.DocumentsDirectory)      -- get the path
    local file = io.open(path,"w")                                                  -- open it for writing
    assert(file ~= nil,"Couldn't write document file.")                             -- problems if this fails
    local contents = json.encode(self.m_documentData)                               -- convert structure to JSON
    file:write(contents)                                                            -- write file out and close.
    io.close(file)
end

Framework:new("document.store")                                                     -- create an instance.
Framework.constructor = nil                                                         -- and cause an error if any others are created.

--- ************************************************************************************************************************************************************************
--[[
        Date        Version     Notes
        ----        -------     -----
        28-Sep-14   0.1         Initial version of file

--]]
--- ************************************************************************************************************************************************************************

