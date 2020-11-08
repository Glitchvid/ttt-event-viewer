--[[
	Created by the Throne Ridge Group, 2020
	All rights reserved.
--]]
--[[---------------------------------PURPOSE-----------------------------------
	Implements filtering events.
---------------------------------------------------------------------------]]--
TREventViewer.FilterEvents = {}
-------------------------------------------------------------------------------

local eventTypeFilters, vic64Filters, att64Filters, alertFilter

local function ResetAllFilters()
	eventTypeFilters = {} -- Blocklist
	vic64Filters = {index = 1} -- Allowlist
	att64Filters = {index = 1} -- Allowlist
	alertFilter = {index = 1} -- Allowlist
end

ResetAllFilters() -- Run this now.

-- Developer Printing Funcionality...
local PrintDebug = TREventViewer.PrintDebug
local PrintDebugNotify = TREventViewer.PrintDebugNotify


--[[
	GLOBAL FUNCTIONS
--]]

--[[---------------------------------------------------------------------------
	Name: PassesFilter( entry )
	Description:	Returns if the entry passes the filters or not.
	Arg 1:		Table, Event Entry.
	Return: 	Boolean, True if passes filters, false otherwise.
---------------------------------------------------------------------------]]--
function TREventViewer.FilterEvents.PassesFilter( entry )

	-- Filter Events
	if eventTypeFilters[entry.event] then
		return false
	end
	-- Filter Victim Steam 64
	if vic64Filters.index > 1 and not vic64Filters[entry.vic64] then
		return false
	end
	-- Filter Attacker Steam 64
	if att64Filters.index > 1 and not att64Filters[entry.att64] then
		return false
	end

	if alertFilter.index > 1 and not alertFilter[TREventViewer.Strings.GenerateAlertString( entry )] then
		return false
	end


	return true -- ;)
end

-- Basically no documentation here, sorry. TODO / Coming Soon.
function TREventViewer.FilterEvents.HideEvent( event )
	eventTypeFilters[tostring(event)] = true
end

function TREventViewer.FilterEvents.ShowEvent( event )
	eventTypeFilters[tostring(event)] = false
end

function TREventViewer.FilterEvents.Addvic64Filter( vic64 )
	if not vic64Filters[vic64] then
		vic64Filters[vic64] = true
		vic64Filters.index = vic64Filters.index + 1
		return true
	end
	return false
end

function TREventViewer.FilterEvents.Removevic64Filter( vic64 )
	if vic64Filters[vic64] then
		vic64Filters[vic64] = nil
		vic64Filters.index = vic64Filters.index - 1
		return true
	end
	return false
end

function TREventViewer.FilterEvents.Addatt64Filter( att64 )
	if not att64Filters[att64] then
		att64Filters[att64] = true
		att64Filters.index = att64Filters.index + 1
		return true
	end
	return false
end

function TREventViewer.FilterEvents.Removeatt64Filter( att64 )
	if att64Filters[att64] then
		att64Filters[att64] = nil
		att64Filters.index = att64Filters.index - 1
		return true
	end
	return false
end

function TREventViewer.FilterEvents.AddAlertFilter( eType )
	if not alertFilter[eType] then
		alertFilter[eType] = true
		alertFilter.index = alertFilter.index + 1
		return true
	end
	return false
end

function TREventViewer.FilterEvents.RemoveAlertFilter( eType )
	if alertFilter[eType] then
		alertFilter[eType] = nil
		alertFilter.index = alertFilter.index - 1
		return true
	end
	return false
end

function TREventViewer.FilterEvents.FireFilter( newVal )
	friendlyfireFilter = tobool( newVal )
	return true
end

function TREventViewer.FilterEvents.ResetAllFilters()
	ResetAllFilters()
end