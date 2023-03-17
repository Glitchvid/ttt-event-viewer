--[[
	Created by the Throne Ridge Group, 2020
	All rights reserved.
--]]
--[[---------------------------------PURPOSE-----------------------------------
	Implements the new event viewer / damage log system.
---------------------------------------------------------------------------]]--
TREventViewer = {}
TREventViewer.VERSION = 1
-------------------------------------------------------------------------------

-- Debug message printing, adapted from Throne Ridge misc scripts.
local function PD(meta, ... )
	local prefix = "Event Viewer"
	local dlevel = 1
	if meta then
		prefix = meta[1] or prefix
		dlevel = meta[2] or dlevel
	end
	if (GetConVar("developer"):GetInt() or 0) >= dlevel then
		MsgC(Color(255, 222, 102), "(" .. prefix .. "): ")
		MsgC(Color(255, 255, 255), table.concat({...}, "\t") .. "\n")
	end
end

local PrintDeveloper = PrintDeveloper or PD

local ___prefix = "Event Viewer"
local function PrintDebug(...)
	PrintDeveloper({___prefix, 1}, ...)
end
local function PrintDebugNotify(...)
	PrintDeveloper({___prefix, 0}, ...)
end


--[[
	GLOBAL VALUES
--]]

TREventViewer.PrintDebug = PrintDebug
TREventViewer.PrintDebugNotify = PrintDebugNotify

if SERVER then
	-- Neat!
elseif CLIENT then
	TREventViewer.currentEvents = {}
end


--[[
	INCLUDES
--]]

if SERVER then
	include("event_viewer/sv_damagelogs.lua")
	AddCSLuaFile("event_viewer/cl_eventstring.lua")
	AddCSLuaFile("event_viewer/cl_filtering.lua")
	AddCSLuaFile("event_viewer/cl_process_events.lua")
	AddCSLuaFile("event_viewer/cl_vgui.lua")
elseif CLIENT then
	include("event_viewer/cl_eventstring.lua")
	include("event_viewer/cl_filtering.lua")
	include("event_viewer/cl_process_events.lua")
	include("event_viewer/cl_vgui.lua")
end

--[[
	GLOBAL FUNCTIONS
--]]

--[[---------------------------------------------------------------------------
	Name: SetNewCurrentEvents( logtab )
	Description:	Sets the new current event log being viewed.
	Arg 1:		Table, The damagelog to save.
	Return: 	Boolean, false on failure, true otherwise.
---------------------------------------------------------------------------]]--
function TREventViewer.SetNewCurrentEvents( logtab )
	if not logtab or type(logtab) != "table" then -- TODO: real struct validation.
		error("Tried updating currentEvents with invalid data", 2)
	end

	TREventViewer.currentEvents = logtab

	if CLIENT then
		TREventViewer.GUI.UpdateDlist()
	end
	return true
end

PrintDebugNotify("Loaded!")