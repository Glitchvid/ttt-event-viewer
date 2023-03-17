--[[
	Created by the Throne Ridge Group, 2020
	All rights reserved.
--]]
--[[---------------------------------PURPOSE-----------------------------------
	Implements processing of events.
---------------------------------------------------------------------------]]--
CreateConVar("ttt_damagelogs_autosave", "false", {FCVAR_ARCHIVE, FCVAR_CLIENTCMD_CAN_EXECUTE}, "Auto-saves damage logs to data folder each round.  Admins only.")
TREventViewer.ProcessEvents = {}
-------------------------------------------------------------------------------

-- Developer Printing Funcionality...
local PrintDebug = TREventViewer.PrintDebug
local PrintDebugNotify = TREventViewer.PrintDebugNotify

local function ProcessMetaData( logfile )
	-- Read the metadata first.
	local meta = util.JSONToTable( logfile:ReadLine() )
	if not meta then
		PrintDebugNotify( "FAILURE: Cannot import metadata!" )
		logfile:Close()
		return false
	end
	meta.filesize = math.Round(logfile:Size() / 1024, 1)  .. " KiB"
	PrintDebug( "Reading Metadata: ")
	for k,v in pairs(meta) do
		PrintDebug( "-", k, v )
	end
	return meta
end

--[[
	GLOBAL FUNCTIONS
--]]

--[[---------------------------------------------------------------------------
	Name: LoadDamageLog( path, onlymeta )
	Description:	Loads the damagelog from the specified file.
	Arg 1:		String, Path to the file relative to garrysmod/data
	Arg 2:		Boolean, If true, only reads the log metadata and returns it
	Return: 	Mixed, False if log cannot be read -
					Metadata if Arg 2 is true -
					True otherwise.
---------------------------------------------------------------------------]]--
function TREventViewer.ProcessEvents.LoadDamageLog( path, onlymeta )
	local logfile = file.Open( path , "rb", "DATA" ) -- Our file handle.
	if not logfile then
		PrintDebugNotify( "FAILURE: Cannot open file located at:" )
		PrintDebugNotify( "-", path )
		return false
	end

	-- Process Metadata
	local meta = ProcessMetaData( logfile )
	if onlymeta then
		logfile:Close()
		return meta
	end

	-- Read log data.
	local dlogbin = logfile:Read(logfile:Size() - logfile:Tell())
	logfile:Close()

	local dlogbinhash = util.CRC( dlogbin )
	if not (meta.binhash == dlogbinhash) then -- Expected binary data and read binary data do not match!
		PrintDebugNotify( "FAILURE: Binary hash mismatch!")
		PrintDebugNotify( "-", "Expected: '" .. tostring(meta.binhash) .. "' Got: '" .. dlogbinhash .. "'" )
		return false
	end

	local dlogstr = util.Decompress( dlogbin )
	local dlog = util.JSONToTable( dlogstr )

	if not dlog then
		PrintDebugNotify( "FAILURE: Cannot deserialize log data!" )
		return false
	end

	-- Everything looks good, SHIP IT!
	dlog.meta = meta

	if not TREventViewer.SetNewCurrentEvents(dlog) then
		PrintDebugNotify( "FAILURE: Cannot set current log data!" )
		return false
	else
		PrintDebugNotify( "Successfully loaded events from: " .. path)
		return true
	end

end

--[[---------------------------------------------------------------------------
	Name: SaveDamageLog( dlog )
	Description:	Saves the specified damagelog to data.
	Arg 1:		Table, The damagelog to save.
	Return: 	Boolean, false on failure, true otherwise.
---------------------------------------------------------------------------]]--
function TREventViewer.ProcessEvents.SaveDamageLog( dlog )
	local dlog = dlog or TREventViewer.currentEvents -- Save the currentEvents log if we aren't passed one.

	if not dlog then
		PrintDebugNotify( "FAILURE: No damage logs active." ) -- Can happen, actually.
		return false
	end

	-- Get and create paths.
	local datetab = os.date( "*t" , dlog.meta.date )
	local directory = Format( "ttt/event_viewer/%02d/%02d/%02d", datetab.year, datetab.month, datetab.day )
	local filepath = directory .. "/" .. Format( "%02d-%02d-%02d", datetab.hour, datetab.min, datetab.sec ) .. ".dat"

	file.CreateDir( directory )
	local logfile = file.Open( filepath  , "wb", "DATA" ) -- Our file handle.
	if not logfile then
		PrintDebugNotify( "FAILURE: Cannot open file located at:" )
		PrintDebugNotify( "-", filepath )
		return false
	end

	-- Break off the meta table into its own thing.
	local metatab = dlog.meta
	dlog.meta = nil

	local dlogserial = util.TableToJSON( dlog )
	local dlogbin = util.Compress( dlogserial )
	metatab.binhash = util.CRC( dlogbin )
	PrintDebug( "Saving...", "Compressed / Total Size: [ " .. dlogbin:len() .. " / " .. dlogserial:len() .. " ]", "Hash: " .. metatab.binhash)

	-- Write the file now.
	local metastring = util.TableToJSON( metatab )

	logfile:Write( metastring )
	logfile:Write( "\n" ) -- Newline for easier reading back via file operations.
	logfile:Write( dlogbin )
	logfile:Close()

	PrintDebugNotify( "Wrote damagelogs to: " .. filepath )
	return true
end

--[[---------------------------------------------------------------------------
	Name: RequestEvents( )
	Description:	Requests the current events from the server.
	Return: 	Nil
---------------------------------------------------------------------------]]--
function TREventViewer.ProcessEvents.RequestEvents()
	RunConsoleCommand("ttt_damagelogs_getevents")
end

local lognetbuff = {}
local function ProcessEventLogs()
	local EoS = net.ReadBool()
	local length = net.ReadUInt( 16 )
	lognetbuff[#lognetbuff + 1] = net.ReadData( length )
	PrintDebug( "R Size [ " .. lognetbuff[#lognetbuff]:len() .. " ]" , "EoS: " .. tostring(tobool(EoS)) )

	if not EoS then return end -- More coming down the pipe.
	local autosave = net.ReadBool()

	local binary = table.concat( lognetbuff )
	lognetbuff = {} -- flush

	local decompressed = util.Decompress( binary )
	local dlog =  util.JSONToTable( decompressed )
	PrintDebug( "Received events.", "Compressed / Total Size: [ " .. binary:len() .. " / " .. decompressed:len() .. " ]")
	if autosave then
		TREventViewer.ProcessEvents.SaveDamageLog( dlog )
		return
	end
	TREventViewer.SetNewCurrentEvents( dlog )
end
net.Receive( "TR_TTT_EventLogs", ProcessEventLogs )

--[[
	HOOKS
--]]

hook.Add("TTTEndRound", "ttt_damagelog_save_hook", function()
	if tobool(GetConVar("ttt_damagelogs_autosave"):GetString()) then
		RunConsoleCommand("ttt_damagelogs_getevents", "AUTOSAVE")
	end
end )