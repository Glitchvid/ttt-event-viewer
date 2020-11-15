--[[
	Created by the Throne Ridge Group, 2020
	All rights reserved.
--]]
--[[---------------------------------PURPOSE-----------------------------------
	Implements new damagelogs system.
---------------------------------------------------------------------------]]--
util.AddNetworkString( "TR_TTT_EventLogs" )
-------------------------------------------------------------------------------

-- Developer Printing Funcionality...
local PrintDebug = TREventViewer.PrintDebug
local PrintDebugNotify = TREventViewer.PrintDebugNotify

local damageLogTab = damageLogTab
local cachedLogsCompressed = {dirty = true}


-- Session ID
local function GenerateSessionID()
	local sessTab = {}
	for i = 1, 8 do
		if math.random( 0, 1 ) == 1 then
			sessTab[i] = math.random( 65, 90 ) -- A-Z ASCII decimals
		else
			sessTab[i] = math.random( 48, 57 ) -- 0-9 ASCII decimals
		end
	end
	return string.char( unpack( sessTab ) )
end
local sessionID = GenerateSessionID()

PrintDebug( "Session ID: " .. sessionID )


-- Cached Compressed JSON
local function SetCachedLogs( damageLogTab )
	cachedLogsCompressed.logs = util.Compress( util.TableToJSON( damageLogTab ) )
	cachedLogsCompressed.dirty = false
end

local function GetCachedLogs()
	if cachedLogsCompressed.dirty then
		-- This operation is expensive, so we're caching it.
		SetCachedLogs( damageLogTab )
	end
	return cachedLogsCompressed.logs
end


-- Damage Log Table
local function NewDamageLog()
	damageLogTab = {}
	damageLogTab.index = 1

	damageLogTab.meta = {}
	damageLogTab.meta.date = os.time()
	damageLogTab.meta.version = TREventViewer.VERSION
	damageLogTab.meta.round = GetConVar("ttt_round_limit"):GetInt() - GetGlobalInt("ttt_rounds_left", 1)
	damageLogTab.meta.map = game.GetMap():lower()
	damageLogTab.meta.session = sessionID

	cachedLogsCompressed.dirty = true
	cachedLogsCompressed.logs = nil
end

NewDamageLog() -- Build initial one.


-- Net Library
local function SendEventsNet( ply, autosave )
	local logs = GetCachedLogs()
	net.Start( "TR_TTT_EventLogs" )
	net.WriteUInt( logs:len(), 16 )
	net.WriteData( logs, logs:len() )
	net.WriteBool( autosave )
	net.Send( ply )
end


-- ConCommands
local function SendEvents( ply, cmd, args )
	local autosave = false
	if args and args[1] == "AUTOSAVE" then
		autosave = true
	end
	if ply:IsAdmin() then
		if #damageLogTab == 0 then
			ply:PrintMessage( HUD_PRINTCONSOLE, "No logs currently..." )
			return
		end
		SendEventsNet( ply, autosave )
	else
		if GetRoundState() == ROUND_POST or GetRoundState() == ROUND_PREP then
			SendEventsNet( ply, autosave )
		else
			ply:PrintMessage( HUD_PRINTCONSOLE, "> Non-Admins cannot get damagelogs during round")
		end
	end
end
concommand.Add("ttt_damagelogs_getevents", SendEvents)


--[[
	HOOKS
--]]

local function BeginNewDamageLogs()
	NewDamageLog()
end
hook.Add( "TTTBeginRound", "TTTBeginNewDamageLogs", BeginNewDamageLogs)

local function HandleDamageLogs()
	-- TODO!!
	-- Should probably compile and save them here.
end
hook.Add( "TTTEndRound", "TTTEndRoundDamageLogs", HandleDamageLogs)

local function FoundCorpse( ply, deadply, rag )
	local entry = {}
	entry["time"]		= math.max(0, CurTime() - GAMEMODE.RoundStartTime)
	entry["event"]		= "BODY"

	-- Victim can be nil/false
	if deadply then
		entry["vic64"]		= deadply:SteamID64()
		entry["vicnick"]	= deadply:Nick()
		entry["vicrole"]	= deadply:GetRoleString()
	else
		entry["vic64"]		= rag.sid
		entry["vicnick"]	= CORPSE.GetPlayerNick(rag)
		entry["vicrole"]	= rag.was_role
	end

	entry["att64"]		= ply:SteamID64()
	entry["attnick"]	= ply:Nick()
	entry["attrole"]	= ply:GetRoleString()

 
	damageLogTab[damageLogTab.index] = entry
	damageLogTab.index = damageLogTab.index + 1
	cachedLogsCompressed.dirty = true
end
hook.Add( "TTTBodyFound", "TTTEventViewerBodyFound", FoundCorpse)


--[[
	GLOBAL FUNCTIONS
--]]

--[[---------------------------------------------------------------------------
	Name: DamageLog( event, vic, att, dmginfo )
	Description:	Adds an event to the damage logs system.
	Arg 1:	String, Event type.
	Arg 2:	Player, Victim
	Arg 3:	Player, Attacker
	Arg 4:	CTakeDamageInfo, Damage Info
	Return:			True
---------------------------------------------------------------------------]]--
function DamageLog( event, vic, att, dmginfo )

	local entry = {}
	entry["time"]		= math.max(0, CurTime() - GAMEMODE.RoundStartTime)
	entry["event"]		= event

	-- Victim can be nil/false
	if vic then
		entry["vic64"]		= vic:SteamID64()
		entry["vicnick"]	= vic:Nick()
		entry["vicrole"]	= vic:GetRoleString()
	end
	-- Attacker can be nil/false
	if att then
		entry["att64"]		= att:SteamID64()
		entry["attnick"]	= att:Nick()
		entry["attrole"]	= att:GetRoleString()

		local wep = att:GetActiveWeapon()
		if IsValid( wep ) then
			entry["DMGweapon"]	= wep:GetClass()
		end
	end
	-- Damage Info can be nil/false
	if dmginfo then
		entry["DMGdamage"]	= dmginfo:GetDamage()
		entry["DMGinflictor"]	= IsValid(dmginfo:GetInflictor()) and dmginfo:GetInflictor():GetClass()
		entry["DMGtype"]	= dmginfo:GetDamageType()
	end
 
	damageLogTab[damageLogTab.index] = entry
	damageLogTab.index = damageLogTab.index + 1
	cachedLogsCompressed.dirty = true
end