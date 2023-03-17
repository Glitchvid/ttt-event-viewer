--[[
	Created by the Throne Ridge Group, 2020
	All rights reserved.
--]]
--[[---------------------------------PURPOSE-----------------------------------
	Utilities for generating the event strings.
---------------------------------------------------------------------------]]--
TREventViewer.Strings = {}
-------------------------------------------------------------------------------

-- Developer Printing Funcionality...
local PrintDebug = TREventViewer.PrintDebug
local PrintDebugNotify = TREventViewer.PrintDebugNotify

local function GetInfWepClassString( infl, wep )
	-- Get the print name of our weapon.
	local cstring = ((infl and not infl == "player") or wep) or infl
	local wep = weapons.Get( cstring )
	if not wep then
		return cstring or "<SOMETHING>"
	end
	return LANG.TryTranslation( wep.PrintName ) .. " / " .. tostring( infl )
end

local function RoleENUMToString( role )
	-- This sucks, but it eez what it eez.
	if role == 0 then
		return "Innocent"
	elseif role == 1 then
		return "Traitor"
	elseif role == 2 then
		return "Detective"
	else
		return "Innocent"
	end
end

local function _NF( entry, outtab )
	return function( outtab ) return outtab end -- Catch all event types
end

-- Event Type Generators
local EventTypeMethods = {}
setmetatable(EventTypeMethods, {__index = _NF })
function EventTypeMethods.DMG( entry, outtab )
	outtab[03] = "damaged"
	outtab[06] = "for"
	outtab[07] = math.Round(entry.DMGdamage)
	outtab[08] = "with"
	outtab[09] = GetInfWepClassString( entry.DMGinflictor, entry.DMGweapon )
	outtab[10] = entry.DMGtype and "<" .. entry.DMGtype .. ">"
	return outtab
end

function EventTypeMethods.HSDMG( entry, outtab )
	outtab[03] = "damaged"
	outtab[04] = outtab[04] .. "'s health station"
	outtab[06] = "for"
	outtab[07] = math.Round(entry.DMGdamage)
	outtab[08] = "with"
	outtab[09] = GetInfWepClassString( entry.DMGinflictor, entry.DMGweapon )
	outtab[10] = entry.DMGtype and "<" .. entry.DMGtype .. ">"
	return outtab
end

function EventTypeMethods.KILL( entry, outtab )
	outtab[03] = "killed"
	outtab[06] = "with"
	outtab[07] = GetInfWepClassString( entry.DMGinflictor, entry.DMGweapon )
	return outtab
end

function EventTypeMethods.DNA( entry, outtab )
	outtab[03] = "retrieved"
	outtab[04] = outtab[04] .. "'s DNA"
	if entry.DMGinflictor then
		outtab[06] = "from a " .. GetInfWepClassString( entry.DMGinflictor )
	end
	return outtab
end

function EventTypeMethods.BODY( entry, outtab )
	outtab[03] = "found"
	outtab[04] = outtab[04] .. "'s corpse"
	outtab[05] = "[" .. RoleENUMToString( entry.vicrole ):upper() .. "]"
	return outtab
end

local function PadNickLength( nick, len )
	if nick:len() >= len then
		return nick
	end

	local padtab = {}
	for i = 1, len - nick:len() do
		padtab[i] = " "
	end
	return nick .. table.concat( padtab )
end


--[[
	GLOBAL FUNCTIONS
--]]

--[[---------------------------------------------------------------------------
	Name: GenerateTimeString( time )
	Description:	Generates a formatted time string from seconds.
	Arg 1:		Number, Seconds since round start.
	Return: 	String, Formatted time string.
---------------------------------------------------------------------------]]--
function TREventViewer.Strings.GenerateTimeString( time )
	return string.FormattedTime( time, "%02i:%02i:%02i" )
end

--[[---------------------------------------------------------------------------
	Name: GenerateEntryString( entry )
	Description:	Generates an event string from events.
	Arg 1:		Table, Entry object
	Return: 	String, ready to be inserted wholesale.
---------------------------------------------------------------------------]]--
function TREventViewer.Strings.GenerateEntryString( entry )
	local outtab = {}

	if entry.attnick then
		outtab[01] = entry.attnick
		outtab[02] = "[" .. tostring(entry.attrole):upper() .. "]"
	else
		outtab[01] = "<SOMEONE>"
		outtab[02] = "[INVALID]"
	end

	if entry.vicnick then
		outtab[04] = entry.vicnick
		outtab[05] = "[" .. tostring(entry.vicrole):upper() .. "]"
	else
		outtab[04] = "<SOMEONE>"
		outtab[05] = "[INVALID]"
	end

	local eType = entry.event
	outtab = EventTypeMethods[eType]( entry, outtab )

	return table.concat( outtab, " " )
end

--[[---------------------------------------------------------------------------
	Name: GenerateAlertString( entry )
	Description:	Returns the alert type for an event
	Arg 1:		Table, Entry object
	Return: 	String, alert type.
---------------------------------------------------------------------------]]--
function TREventViewer.Strings.GenerateAlertString( entry )
	if entry.event == "DNA" or entry.event == "BODY" then
		return ""
	end

	if entry.vic64 == entry.att64 then
		return "SU"
	end

	if entry.vicrole == "detective" then
		if entry.attrole == "innocent" then
			return "DF"
		elseif entry.attrole == "detective" then
			return "FF"
		end
	end

	if entry.vicrole == "traitor" and entry.attrole == "traitor" then
		return "FF"
	end

	return ""
end