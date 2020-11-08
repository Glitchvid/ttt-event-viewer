--[[
	Created by the Throne Ridge Group, 2020
	All rights reserved.
--]]
--[[---------------------------------PURPOSE-----------------------------------
	VGUI for Event Viewer.
---------------------------------------------------------------------------]]--
-------------------------------------------------------------------------------

-- Developer Printing Funcionality...
local PrintDebug = TREventViewer.PrintDebug
local PrintDebugNotify = TREventViewer.PrintDebugNotify

-- Build Filters
local function CloseAllPanels( tab )
	for i = 1, #tab do
		tab[i]:Close()
	end
end


local function ShowEventWindow()
	-- Derma
	local sX, sY = ScrW(), ScrH()
	local paneltab = {} -- All our panels
	local sizeX, sizeY = 1000, 540
	local frame = vgui.Create( "DFrame" )
	local TC_dark_grey = Color( 90, 90, 90)

	frame:SetPos( (sX / 2) - (sizeX / 2) + 256 , (sY / 2) - (sizeY / 2) )
	frame:SetSize( sizeX, sizeY ) 
	frame:SetTitle( "Event Viewer –  Version " .. TREventViewer.VERSION ) 
	frame:SetVisible( true ) 
	frame:SetDraggable( false ) 
	frame:ShowCloseButton( false )
	table.insert( paneltab, frame )

	local lPan = vgui.Create( "DPanel", frame )
	local rPan = vgui.Create( "DPanel", frame )

	local div = vgui.Create( "DHorizontalDivider", frame )
	div:Dock( FILL )
	div:SetLeft( lPan )
	div:SetRight( rPan )
	div:SetDividerWidth( 2 )
	div:SetLeftMin( 20 )
	div:SetRightMin( 256 )
	div:SetLeftWidth( 20 )

	-- DList
	local dlist = rPan:Add( "DListView" )
	dlist:SetSize( 1, 1 ) 
	dlist:DockMargin( 4, 4, 4, 5 )
	dlist:Dock( 1 )
	dlist:SetPos( 8, 32 )
	-- Columns
	local timc = dlist:AddColumn("Time", 1):SetWidth(48)
	dlist:AddColumn("Type", 2):SetWidth(8)
	dlist:AddColumn("Event", 3):SetWidth(660)
	dlist:AddColumn("!", 4):SetWidth(8)

	-- Action Buttons
	lPan:SetPaintBackground(false)

	DIBrefreshDlist = lPan:Add( "DImageButton" )
	DIBrefreshDlist:SetSize( 16, 16 )
	DIBrefreshDlist:SetImage( "icon16/arrow_refresh.png" )
	DIBrefreshDlist:SizeToContents()
	DIBrefreshDlist:DockMargin( 2, 2, 2, 2 )
	DIBrefreshDlist:Dock( TOP )
	DIBrefreshDlist:SetStretchToFit( false )
	DIBrefreshDlist:SetTooltip( "Refresh View" )
	function DIBrefreshDlist:DoClick()
		TREventViewer.ProcessEvents.UpdateDlist( dlist )
	end

	DIBgetDamageLogs = lPan:Add( "DImageButton" )
	DIBgetDamageLogs:SetSize( 16, 16 )
	DIBgetDamageLogs:SetImage( "icon16/application_put.png" )
	DIBgetDamageLogs:SizeToContents()
	DIBgetDamageLogs:DockMargin( 2, 2, 2, 2 )
	DIBgetDamageLogs:Dock( TOP )
	DIBgetDamageLogs:SetStretchToFit( false )
	DIBgetDamageLogs:SetTooltip( "Get current damagelogs" )
	function DIBgetDamageLogs:DoClick()
		TREventViewer.ProcessEvents.RequestEvents( false )
		TREventViewer.ProcessEvents.UpdateDlist( dlist )
	end

	DIBsaveLogs = lPan:Add( "DImageButton" )
	DIBsaveLogs:SetSize( 16, 16 )
	DIBsaveLogs:SetImage( "icon16/disk.png" )
	DIBsaveLogs:SizeToContents()
	DIBsaveLogs:DockMargin( 2, 2, 2, 2 )
	DIBsaveLogs:Dock( TOP )
	DIBsaveLogs:SetStretchToFit( false )
	DIBsaveLogs:SetTooltip( "Save current logs" )
	function DIBsaveLogs:DoClick()
		TREventViewer.ProcessEvents.SaveDamageLog()
	end

	DIBclearLogs = lPan:Add( "DImageButton" )
	DIBclearLogs:SetSize( 16, 16 )
	DIBclearLogs:SetImage( "icon16/delete.png" )
	DIBclearLogs:SizeToContents()
	DIBclearLogs:DockMargin( 2, 2, 2, 2 )
	DIBclearLogs:Dock( TOP )
	DIBclearLogs:SetStretchToFit( false )
	DIBclearLogs:SetTooltip( "Clear current view" )
	function DIBclearLogs:DoClick()
		dlist:Clear()
	end



	--[[	Control Panel	]]

	local cpframe = vgui.Create( "DFrame" )
	cpframe:SetSize( 384, sizeY )
	cpframe:MoveLeftOf( frame, 8 ) 
	cpframe:MoveBelow( frame, (-1 * sizeY) ) 
	cpframe:SetTitle( "Controls" ) 
	cpframe:SetVisible( true ) 
	cpframe:SetDraggable( false ) 
	cpframe:ShowCloseButton( true ) 
	function cpframe:OnClose() CloseAllPanels(paneltab) end

	local tabviews = vgui.Create( "DPropertySheet", cpframe )
	tabviews:Dock( FILL )

	-- Filters View
	local filtersPanel = vgui.Create( "DPanel", tabviews )
	tabviews:AddSheet( "Filters", filtersPanel, "icon16/page_find.png" )

	local filtersList = vgui.Create( "DCategoryList", filtersPanel )
	filtersList:Dock( FILL )

	local filterPlayersPContainer = vgui.Create( "DPanel", filtersPanel)
	filterPlayersPContainer:DockPadding( 8, 8, 8, 8 )

	local filterPlayers = filtersList:Add( "Filter Players" )
	filterPlayers:SetContents( filterPlayersPContainer )
	filterPlayers:SetExpanded( true )

	local textentersize = {128, 22}
	local textenterpos = {48,14}

	local vicfiltertext = filterPlayersPContainer:Add("DLabel")
	vicfiltertext:SetText( "Filter Victims" )
	vicfiltertext:Dock( TOP )
	vicfiltertext:DockMargin( 0, 4, 0, 4)
	vicfiltertext:SizeToContents()
	vicfiltertext:SetTextColor( TC_dark_grey )

	local vicfilter = filterPlayersPContainer:Add( "DComboBox")
	vicfilter:SetSize( 196, 22 )
	vicfilter:Dock( TOP )
	vicfilter:DockMargin( 0, 0, 0, 4)
	function vicfilter:OnSelect( index, text, data )
		if data != -1 then
			TREventViewer.FilterEvents.Removevic64Filter( vicfilter.olddata )
			TREventViewer.FilterEvents.Addvic64Filter( data )
			vicfilter.olddata = data
		else
			TREventViewer.FilterEvents.Removevic64Filter( vicfilter.olddata )
			vicfilter.olddata = nil
			vicfilter:SetValue( "Select Player" )
		end
		TREventViewer.ProcessEvents.UpdateDlist( dlist )	
	end
	function vicfilter:RefreshList()
		self:Clear()
		self:SetValue( "Select Player" )
		self:AddChoice( "CLEAR", -1 )
		if TREventViewer.currentPlayerList.vic then
			for k, v in pairs(TREventViewer.currentPlayerList.vic) do
				self:AddChoice( v .. " / " .. k, k ) -- Insert name, steam64, with the s64 as a value.
			end
		end
		TREventViewer.FilterEvents.Removevic64Filter( self.olddata )
		self.olddata = nil
	end
	vicfilter:RefreshList()

	local attfiltertext = filterPlayersPContainer:Add("DLabel")
	attfiltertext:SetText( "Filter Attackers" )
	attfiltertext:Dock( TOP )
	attfiltertext:DockMargin( 0, 4, 0, 4)
	attfiltertext:SizeToContents()
	attfiltertext:SetTextColor( Color( 90, 90, 90) )

	local attfilter = filterPlayersPContainer:Add("DComboBox")
	attfilter:SetSize( 196, 22 )
	attfilter:Dock( TOP )
	attfilter:DockMargin( 0, 0, 0, 4)
	function attfilter:OnSelect( index, text, data )
		if data != -1 then
			TREventViewer.FilterEvents.Removeatt64Filter( attfilter.olddata )
			TREventViewer.FilterEvents.Addatt64Filter( data )
			attfilter.olddata = data
		else
			TREventViewer.FilterEvents.Removeatt64Filter( attfilter.olddata )
			attfilter.olddata = nil
			attfilter:SetValue( "Select Player" )
		end
		TREventViewer.ProcessEvents.UpdateDlist( dlist )	
	end
	function attfilter:RefreshList()
		self:Clear()
		self:SetValue( "Select Player" )
		self:AddChoice( "CLEAR", -1 )
		if TREventViewer.currentPlayerList.att then
			for k, v in pairs(TREventViewer.currentPlayerList.att) do
				self:AddChoice( v .. " / " .. k, k ) -- Insert name, steam64, with the s64 as a value.
			end
		end	
		TREventViewer.FilterEvents.Removeatt64Filter( self.olddata )
		self.olddata = nil
	end
	attfilter:RefreshList()

	-- Checkbox Filters
	local filterEventsPContainer = vgui.Create( "DPanel", filtersPanel)
	filterEventsPContainer:DockPadding( 8, 8, 8, 8 )
	
	local eventsFilterCollapsible = filtersList:Add( "Event Types" )
	eventsFilterCollapsible:SetContents( filterEventsPContainer )
	eventsFilterCollapsible:SetExpanded( true )

	local cbeDMG = filterEventsPContainer:Add("DCheckBoxLabel")
	cbeDMG:SetText( "DMG" )
	cbeDMG:SizeToContents()
	cbeDMG:Dock( TOP )
	cbeDMG:DockMargin( 2, 0, 0, 2)
	cbeDMG:SetChecked( true )
	cbeDMG:SetTextColor( TC_dark_grey )
	function cbeDMG:OnChange( newVal ) 
		if newVal then
			TREventViewer.FilterEvents.ShowEvent( "DMG" )
		else
			TREventViewer.FilterEvents.HideEvent( "DMG" )
		end
		TREventViewer.ProcessEvents.UpdateDlist( dlist )
	end

	local cbeKILL = filterEventsPContainer:Add("DCheckBoxLabel")
	cbeKILL:SetText( "KILL" )
	cbeKILL:SizeToContents()
	cbeKILL:Dock( TOP )
	cbeKILL:DockMargin( 2, 0, 0, 2)
	cbeKILL:SetChecked( true )
	cbeKILL:SetTextColor( TC_dark_grey )
	function cbeKILL:OnChange( newVal ) 
		if newVal then
			TREventViewer.FilterEvents.ShowEvent( "KILL" )
		else
			TREventViewer.FilterEvents.HideEvent( "KILL" )
		end
		TREventViewer.ProcessEvents.UpdateDlist( dlist )
	end

	local cbeDNA = filterEventsPContainer:Add("DCheckBoxLabel")
	cbeDNA:SetText( "DNA" )
	cbeDNA:SizeToContents()
	cbeDNA:Dock( TOP )
	cbeDNA:DockMargin( 2, 0, 0, 2)
	cbeDNA:SetChecked( true )
	cbeDNA:SetTextColor( TC_dark_grey )
	function cbeDNA:OnChange( newVal ) 
		if newVal then
			TREventViewer.FilterEvents.ShowEvent( "DNA" )
		else
			TREventViewer.FilterEvents.HideEvent( "DNA" )
		end
		TREventViewer.ProcessEvents.UpdateDlist( dlist )
	end
	
	local cbeBODY = filterEventsPContainer:Add("DCheckBoxLabel")
	cbeBODY:SetText( "BODY" )
	cbeBODY:SizeToContents()
	cbeBODY:Dock( TOP )
	cbeBODY:DockMargin( 2, 0, 0, 2)
	cbeBODY:SetChecked( true )
	cbeBODY:SetTextColor( TC_dark_grey )
	function cbeBODY:OnChange( newVal ) 
		if newVal then
			TREventViewer.FilterEvents.ShowEvent( "BODY" )
		else
			TREventViewer.FilterEvents.HideEvent( "BODY" )
		end
		TREventViewer.ProcessEvents.UpdateDlist( dlist )
	end

	local cbeHSDMG = filterEventsPContainer:Add("DCheckBoxLabel")
	cbeHSDMG:SetText( "HSDMG" )
	cbeHSDMG:SizeToContents()
	cbeHSDMG:Dock( TOP )
	cbeHSDMG:DockMargin( 2, 0, 0, 2)
	cbeHSDMG:SetChecked( true )
	cbeHSDMG:SetTextColor( TC_dark_grey )
	function cbeHSDMG:OnChange( newVal ) 
		if newVal then
			TREventViewer.FilterEvents.ShowEvent( "HSDMG" )
		else
			TREventViewer.FilterEvents.HideEvent( "HSDMG" )
		end
		TREventViewer.ProcessEvents.UpdateDlist( dlist )
	end

	--[[
		-- One day...
		local cbeNADE = filterEventsPContainer:Add("DCheckBoxLabel")
		cbeNADE:SetText( "NADE" )
		cbeNADE:SizeToContents()
		cbeNADE:Dock( TOP )
		cbeNADE:DockMargin( 2, 0, 0, 2)
		cbeNADE:SetChecked( true )
		cbeNADE:SetTextColor( TC_dark_grey )
		function cbeNADE:OnChange( newVal ) 
			if newVal then
				TREventViewer.FilterEvents.ShowEvent( "NADE" )
			else
				TREventViewer.FilterEvents.HideEvent( "NADE" )
			end
			TREventViewer.ProcessEvents.UpdateDlist( dlist )
		end
	--]]

	-- Alerts
	local ffPContainer = vgui.Create( "DPanel", filtersPanel)
	ffPContainer:DockPadding( 8, 8, 8, 8 )
	
	local ffFilterCollapsible = filtersList:Add( "Alerts" )
	ffFilterCollapsible:SetContents( ffPContainer )
	ffFilterCollapsible:SetExpanded( true )

	local cbFF = ffPContainer:Add("DCheckBoxLabel")
	cbFF:SetText( "Friendly Fire" )
	cbFF:SizeToContents()
	cbFF:Dock( TOP )
	cbFF:DockMargin( 2, 0, 0, 2)
	cbFF:SetChecked( false )
	cbFF:SetTextColor( TC_dark_grey )
	function cbFF:OnChange( newVal ) 
		if newVal == true then
			TREventViewer.FilterEvents.AddAlertFilter( "FF" )
		else
			TREventViewer.FilterEvents.RemoveAlertFilter( "FF" )
		end
		TREventViewer.ProcessEvents.UpdateDlist( dlist )
	end

	local cbDF = ffPContainer:Add("DCheckBoxLabel")
	cbDF:SetText( "Detective Fire" )
	cbDF:SizeToContents()
	cbDF:Dock( TOP )
	cbDF:DockMargin( 2, 0, 0, 2)
	cbDF:SetChecked( false )
	cbDF:SetTextColor( TC_dark_grey )
	function cbDF:OnChange( newVal ) 
		if newVal == true then
			TREventViewer.FilterEvents.AddAlertFilter( "DF" )
		else
			TREventViewer.FilterEvents.RemoveAlertFilter( "DF" )
		end
		TREventViewer.ProcessEvents.UpdateDlist( dlist )
	end

	local cbSU = ffPContainer:Add("DCheckBoxLabel")
	cbSU:SetText( "Suicide" )
	cbSU:SizeToContents()
	cbSU:Dock( TOP )
	cbSU:DockMargin( 2, 0, 0, 2)
	cbSU:SetChecked( false )
	cbSU:SetTextColor( TC_dark_grey )
	function cbSU:OnChange( newVal ) 
		if newVal == true then
			TREventViewer.FilterEvents.AddAlertFilter( "SU" )
		else
			TREventViewer.FilterEvents.RemoveAlertFilter( "SU" )
		end
		TREventViewer.ProcessEvents.UpdateDlist( dlist )
	end

	local resetFiltersButton = filtersPanel:Add("DButton")
	resetFiltersButton:SetSize( 164, 30 )
	resetFiltersButton:Dock( BOTTOM )
	resetFiltersButton:DockMargin( 4, 4, 4, 4)
	resetFiltersButton:SetText( "RESET FILTERS" )
	function resetFiltersButton:DoClick()
		attfilter:RefreshList()
		vicfilter:RefreshList()
		cbeDMG:SetChecked( true )
		cbeKILL:SetChecked( true )
		cbeDNA:SetChecked( true )
		cbeHSDMG:SetChecked( true )
		--cbeNADE:SetChecked( true )
		cbFF:SetChecked( false )
		cbDF:SetChecked( false )
		cbSU:SetChecked( false )
		TREventViewer.FilterEvents.ResetAllFilters()
		TREventViewer.ProcessEvents.UpdateDlist( dlist )
	end


	-- File Loading UI
	local loadingPanel = vgui.Create( "DPanel", tabviews )
	tabviews:AddSheet( "Load", loadingPanel, "icon16/drive_magnify.png" )

	local fileBrowser = vgui.Create( "DFileBrowser", loadingPanel )
	fileBrowser:Dock( TOP )
	fileBrowser:SetPath( "DATA" )
	fileBrowser:SetBaseFolder( "ttt/event_viewer" )
	fileBrowser:SetOpen( false )
	fileBrowser:SetOpen( "*.dat" )
	fileBrowser:SetHeight(256)
	fileBrowser:DockPadding( 0, 0, 0, 8 )

	local metaDataPanel = vgui.Create( "DScrollPanel", loadingPanel)
	metaDataPanel:SetSize( 32, 128 )
	metaDataPanel:Dock( TOP )
	metaDataPanel:DockPadding( 8, 8, 8, 8 )
	metaDataPanel:SetBackgroundColor( Color(200, 200, 200, 255) )
	
	function fileBrowser:OnSelect( path, pnl ) -- Called when a file is clicked
		local meta = TREventViewer.ProcessEvents.LoadDamageLog( path, true )

		if not meta then
			return
		end
		metaDataPanel.CurrentPath = path

		metaDataPanel:Clear()
		for k,v in pairs(meta) do
			local lab = metaDataPanel:Add("DLabel")
			lab:SetText( k .. "      " .. v )
			lab:Dock( TOP )
			lab:DockMargin( 8, 2, 8, 2)
			lab:SizeToContents()
			lab:SetTextColor( Color( 50, 50, 50) )
		end
	end

	local loadButton = loadingPanel:Add("DButton")
	loadButton:Dock( TOP )
	loadButton:DockMargin( 0, 4, 0, 4)
	loadButton:SetText( "LOAD SELECTED LOG" )
	function loadButton:DoClick()
		if not metaDataPanel.CurrentPath then
			return
		end
		TREventViewer.ProcessEvents.LoadDamageLog( metaDataPanel.CurrentPath ) 
		TREventViewer.ProcessEvents.UpdateDlist( dlist )
		attfilter:RefreshList()
		vicfilter:RefreshList()
	end

	-- File Loading UI
	local settingsPanel = vgui.Create( "DPanel", tabviews )
	tabviews:AddSheet( "Settings", settingsPanel, "icon16/cog.png" )

	local settingsList = vgui.Create( "DCategoryList", settingsPanel )
	settingsList:Dock( FILL )

	local settingsPContainer = vgui.Create( "DPanel", settingsPanel)
	settingsPContainer:DockPadding( 8, 8, 8, 8 )

	local settingsCat = settingsList:Add( "Primary" )
	settingsCat:SetContents( settingsPContainer )
	settingsCat:SetExpanded( true )

	local cbAutoSave = settingsPContainer:Add("DCheckBoxLabel")
	cbAutoSave:SetText( "Autosave damagelogs on round end" )
	cbAutoSave:SizeToContents()
	cbAutoSave:Dock( TOP )
	cbAutoSave:DockMargin( 2, 0, 0, 2)
	cbAutoSave:SetChecked( tobool(GetConVar("ttt_damagelogs_autosave"):GetString()) )
	cbAutoSave:SetTextColor( TC_dark_grey )
	function cbAutoSave:OnChange( newVal ) 
		if newVal then
			GetConVar("ttt_damagelogs_autosave"):SetBool(true)
		else
			GetConVar("ttt_damagelogs_autosave"):SetBool(false)
		end
	end


	--[[	Logs	]]

	--[[
	-- Eventually...
	local logFrame = vgui.Create( "DFrame" )
	logFrame:SetSize( sizeX, 128 )
	logFrame:MoveBelow( frame, 8 ) 
	logFrame:MoveLeftOf( frame, (-1 * sizeX) ) 
	logFrame:SetTitle( "LOGS" ) 
	logFrame:SetVisible( true ) 
	logFrame:SetDraggable( false ) 
	logFrame:ShowCloseButton( false ) 

	table.insert( paneltab, logFrame )

	local logScroll = logFrame:Add( "DScrollPanel" )
	logScroll:Dock( FILL )
	local scrollPanel = logScroll:Add( "DPanel" )
	scrollPanel:Dock( FILL )
	--]]


	cpframe:MakePopup()
	if TREventViewer.currentEvents then
		TREventViewer.ProcessEvents.UpdateDlist( dlist )
	end


end

concommand.Add("ttt_damagelogs_ui", ShowEventWindow, nil, "Opens Event Viewer")