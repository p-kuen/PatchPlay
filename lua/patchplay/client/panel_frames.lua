local function enableIfDisabled( button, bool )

	if bool == nil then bool = true end

	if button != nil and button:GetDisabled() and bool then
		button:SetDisabled(false)
		return true
	elseif button == nil then
		return false
	end

end

local function disableIfEnabled( button, bool )

	if bool == nil then bool = true end

	if button != nil and !button:GetDisabled() and bool then
		button:SetDisabled(true)
		return true
	elseif button == nil then
		return false
	end

end

function cl_PPlay.openSettings( mode )

	local server = false

	if mode == "server" then server = true end

	local frmW = 300
	local frmH = 310
	local shift = 0

	local frame = cl_PPlay.addfrm( frmW, frmH, "Settings - " .. mode, true)

	if tobool( cl_PPlay.getSetting( "globalSettings", true ) ) and !server then

		local errorLabel = cl_PPlay.addlbl(frame, "These settings have no effect, because global settings are activated! If the server disables global settings, the settings below will have effect again!", 15,30)
		errorLabel:SetWrap(true)
		errorLabel:SetSize(frmW-30, 60)
		errorLabel:SetColor(Color(220,0,0))
		errorLabel:SetFont("BoldRoboto")
		shift = 0
		
	end

	if server then

		local currentPrivateKey = tonumber( cl_PPlay.getSetting( "privateKey", true ) )
		local currentServerKey = tonumber( cl_PPlay.getSetting( "serverKey", true ) )

		cl_PPlay.addlbl( frame, "Button to open the Private Player", 15, 30 + shift)
		local binder_private = cl_PPlay.addbinder( frame, currentPrivateKey, frmW - 30, 30, 15, 50 + shift )

		shift = 60

		cl_PPlay.addlbl( frame, "Button to open the Server Player", 15, 30 + shift)

		local binder_server = cl_PPlay.addbinder( frame, currentServerKey, frmW - 30, 30, 15, 50 + shift )

		function binder_private:SetValue( iNumValue )

			binder_private:SetSelected( iNumValue )

			if currentPrivateKey != iNumValue then

				cl_PPlay.saveSetting( "privateKey", tonumber( iNumValue ), true )

			end

		end

		function binder_server:SetValue( iNumValue )

			binder_server:SetSelected( iNumValue )

			if currentServerKey != iNumValue then

				cl_PPlay.saveSetting( "serverKey", tonumber( iNumValue ), true )

			end

		end

	end

	local grid = vgui.Create( "DGrid", frame )
	grid:SetPos( 15, 100 + shift )
	grid:SetCols( 1 )
	grid:SetColWide( frmW - 30 )

	local clientSettings = {

	}
	local serverSettings = {

		globalSettings = "Make Settings global"

	}
	local sharedSettings = {
		bigNotification = "Show big notification",
		queue = "Show Play Queue",
		nowPlaying = "Show Now Playing"
	}

	local function addVGUI(tbl, disabled)

		table.foreach(tbl, function(setting, description)

			local switch = cl_PPlay.addswitch( grid, description, cl_PPlay.getSetting( setting, server, true ) )

			if disabled then switch:SetDisabled(true) end

			function switch:OnChange()

				cl_PPlay.saveSetting( setting, tobool(switch:GetChecked()), server )

			end

		end)

	end

	if server then addVGUI(serverSettings) else addVGUI(clientSettings) end

	addVGUI(sharedSettings--[[, !server and cl_PPlay.getSetting( "globalSettings", true)--]])

end

function cl_PPlay.openPlayer( mode )

	local frame_w = 128 * 3 + 15 * 4
	local frame_h = 350

	local frame = cl_PPlay.addfrm( frame_w, frame_h, "PatchPlay", true)
	cl_PPlay.PlayerFrame = frame

	local server = false

	if mode == "server" then server = true end

	if mode == "private" then

		--PCore.derma.switch( frame, "Turn on", function( checked ) chat.AddText("Player is " .. tostring( checked ) ) end, { 15, 70 }, true )
	end

	

	cl_PPlay.addbtn( frame, "IMG:soundcloud;", cl_PPlay.openBrowser, { 15, 100 }, mode, "soundcloud" )
	cl_PPlay.addbtn( frame, "IMG:dirble;", cl_PPlay.openBrowser, { 15 + 128 + 15, 100 }, mode, "station" )

	--MY STUFF
	local pnl_mystuff = cl_PPlay.addpnl( frame, {15 + 128 + 15 + 128 + 15, 100}, {128, 128} )

	cl_PPlay.addbtn( pnl_mystuff, "IMG:stations;", cl_PPlay.openMy, { 10, 32 + 11 }, { 49, 32}, server, "stations" )
	cl_PPlay.addbtn( pnl_mystuff, "IMG:tracks;", cl_PPlay.openMy, { 10 + 49 + 10, 32 + 11 }, { 49, 32}, server, "tracks" )
	cl_PPlay.addbtn( pnl_mystuff, "IMG:playlists;", cl_PPlay.openMy, { 10, 32 + 11 + 33 + 10 }, { 49, 32}, server, "playlists" )

	--Settings
	cl_PPlay.addbtn( frame, "IMG:settings;", cl_PPlay.openSettings, { frame_w - 15 - 32, 30 }, mode )


	--cl_PPlay.addbtn( frame, "IMG:mixcloud;", cl_PPlay.openBrowser, { 414, 100 }, mode, "mixcloud" )

	--Volume Slider

	local sldr_volume = cl_PPlay.addsldr( frame, math.floor(cl_PPlay.Volume + 0.5), { 15, 100 + 128 + 15}, { frame_w - 30, 25 })

	function sldr_volume.OnValueChanged( panel, value )

		cl_PPlay.Volume = value

		if cl_PPlay.isMusicPlaying() then cl_PPlay.cStream.station:SetVolume( cl_PPlay.Volume / 100 ) end

	end
	

	local btn_switch
	local btn_stop

	if !server then
		btn_switch = cl_PPlay.addbtn( frame, "Switch", cl_PPlay.play, { frame_w - 130 - 15, 350 - 15 - 25 - 5 - 25 }, {130, 25}, cl_PPlay.sStream.info, true, 1 )
		btn_stop = cl_PPlay.addbtn( frame, "Stop player", cl_PPlay.stop, { frame_w - 130 - 15, 350 - 15 - 25 }, {130, 25} )
	else
		btn_stop = cl_PPlay.addbtn( frame, "Stop player", cl_PPlay.sendToServer, { frame_w - 130 - 15, 350 - 15 - 25 }, {130, 25}, "stop", nil )
	end
	
	

	local lbl_music_server = cl_PPlay.addlbl( frame, "", 50, 350 - 15 - 15 - 5 - 15 )
	local lbl_music_private = cl_PPlay.addlbl( frame, "", 50, 350 - 15 - 15 )

	lbl_music_private:SetSize(295, 25)
	lbl_music_server:SetSize(295, 25)

	local aniheight = 10
	local op = -0.5

	surface.CreateFont( "TitleBig", {
		font = "Roboto",
		size = 30,
		weight = 300,
	} )

	function frame:PaintOver()

		draw.SimpleText( string.firstupper(mode) .. " Player", "TitleBig", 15, 30, Color(0,0,0), 0, 0 )

		-- My Stuff Background
		--draw.RoundedBox( 0, 15 + 128 + 15 + 128 + 15, 100, 128, 128, Color( 0, 0, 0, 150 ) )
		draw.RoundedBox( 0, 15 + 128 + 15 + 128 + 15, 100, 128, 32, Color( 255, 150, 0, 255 ) )
		draw.SimpleText( "My Stuff", "DefaultRoboto", 15 + 128 + 15 + 128 + 15 + 5, 100 + 9, Color(255, 255, 255), 0, 0 )
		

		function drawAnimation( x, y, color )
			if aniheight >= 10 then
				op = -0.5
			elseif aniheight <= 1 then
				op = 0.5
			end

			aniheight = aniheight + op
			
			draw.RoundedBox( 0, x, y + 10 - aniheight * 0.4, 5, aniheight * 0.4, color )
			draw.RoundedBox( 0, x + 6, y + 10 - aniheight, 5, aniheight, color )
			draw.RoundedBox( 0, x + 12, y + 10 - aniheight * 0.6, 5, aniheight * 0.6, color )
		end

		function getServerTitle()

			if cl_PPlay.sStream.info == nil then return "" end

			if cl_PPlay.sStream.info.title != nil and cl_PPlay.sStream.info.title != "" then
				return cl_PPlay.sStream.info.title
			else
				return cl_PPlay.sStream.info.streamurl
			end

		end

		function getPrivateTitle()

			if cl_PPlay.cStream.info == nil then return "" end

			if cl_PPlay.cStream.info.title != nil and cl_PPlay.cStream.info.title != "" then
				return cl_PPlay.cStream.info.title
			else
				return cl_PPlay.cStream.info.streamurl
			end

		end

		if !server then
			if cl_PPlay.isMusicPlaying( true ) and !cl_PPlay.cStream.server then
				btn_switch:SetDisabled(false);
			else
				btn_switch:SetDisabled(true);
			end
		end

		if !server and getServerTitle() != "" then
			lbl_music_server:SetText(getServerTitle())
		end

		if !server then
			lbl_music_private:SetText(getPrivateTitle())
		else
			lbl_music_private:SetText(getServerTitle())
		end

		if server and cl_PPlay.isMusicPlaying( true ) then

			drawAnimation( 25, 325, Color( 0, 0, 153, 255 ) )
			btn_stop:SetDisabled( false )

		elseif server and !cl_PPlay.isMusicPlaying( true ) then

			btn_stop:SetDisabled( true )

		elseif !server then

			if cl_PPlay.isMusicPlaying( true ) then

				drawAnimation( 25, 325 - 10 - 10, Color( 0, 0, 153, 255 ) )

			end

			if cl_PPlay.isMusicPlaying() then

				drawAnimation( 25, 325, Color( 0, 0, 0, 255 ) )
				btn_stop:SetDisabled( false )
			else
				btn_stop:SetDisabled( true )
			end

		end
		
		
		
	end

end

function cl_PPlay.openPlaylist( server )

	local strings = {}

	if !server then

		strings.frametitle = "PatchPlay - My Private Playlists"
		
	else

		strings.frametitle = "PatchPlay - Server Playlists"

	end

	-- Variables
	local w, h = 500, 350
	local data = {}
	local panel = {}
	local functions = {}

	-- Initialization
	data.selected = {}
	panel.buttons = {}
	panel.lists = {}

	-- FRAME
	panel.frame = cl_PPlay.addfrm( w, h, strings["frametitle"], true )

	-- DESCRIPTION
	cl_PPlay.addlbl( panel.frame, "Choose a playlist:", 15, 30 )

	-- LISTS
	panel.lists.playlists = cl_PPlay.addlv( panel.frame, 15, 50, ( w - 30 ) / 3, h - 100, {"Playlists"} )
	panel.lists.tracks = cl_PPlay.addlv( panel.frame, 15 + (w - 30) / 3 + 5, 50, (w - 30) / 3 * 2, h - 100, {"Tracks"} )

	-- FILL PLAYLISTS FUNCTION
	function functions.fillPlaylists()

		panel.lists.playlists:Clear()

		sh_PPlay.getSQLTable( "pplay_playlistnames", function( result )

			data.selected.playlist = nil

			table.foreach( result, function( key, playlist )

				local line = panel.lists.playlists:AddLine( playlist.name )
				line.id =  playlist.id

			end)

		end, server, LocalPlayer() )

	end
	functions.fillPlaylists()

	-- FILL TRACKS FUNCTION
	function functions.fillTracks( playlist_id )

		panel.lists.tracks:Clear()

		sh_PPlay.getSQLTable( "pplay_playlist", function( result )

			data.selected.track = nil
			data.selected.playlist.tracks = {}

			table.foreach( result, function( key, stream )

				if stream.playlist_id == data.selected.playlist.id then

					local line = panel.lists.tracks:AddLine( stream.info.title )
					--line.info = stream.info
					line.id = stream.id
					line.playlist_id = stream.playlist_id

					table.insert( data.selected.playlist.tracks, stream )

				end

			end)

		end, server, LocalPlayer() )

	end

	-- PLAYLIST CLICK FUNCTION
	function panel.lists.playlists:OnClickLine( line, selected )

		enableIfDisabled( panel.buttons.deletePlaylist )
		enableIfDisabled( panel.buttons.play )

		data.selected.playlist = {}
		data.selected.playlist.id = line.id

		panel.lists.playlists:ClearSelection()
		line:SetSelected( true )

		functions.fillTracks( line.id )

	end

	-- TRACK CLICK FUNCTION
	function panel.lists.tracks:OnClickLine( line, selected )

		enableIfDisabled( panel.buttons.deleteTrack )

		data.selected.track = line.id

		panel.lists.tracks:ClearSelection()
		line:SetSelected( true )

	end

	-- DELETE PLAYLIST FUNCTION
	function functions.deletePlaylist()

		sh_PPlay.deleteRow( server, "pplay_playlist", "playlist_id", tostring( data.selected.playlist.id ) )
		sh_PPlay.deleteRow( server, "pplay_playlistnames", "id", tostring( data.selected.playlist.id ) )

		functions.fillPlaylists()
		panel.lists.tracks:Clear()

	end

	-- DELETE TRACK FUNCTION
	function functions.deleteTrack()

		sh_PPlay.deleteRow( server, "pplay_playlist", "id", tostring( data.selected.track ) )
		functions.fillTracks( data.selected.playlist.id )

	end

	-- PLAY PLAYLIST FUNCTION
	function functions.play()

		cl_PPlay.currentPlaylist = data.selected.playlist.tracks

		if server then

			cl_PPlay.playStream( cl_PPlay.currentPlaylist, server, 2 )

		else

			cl_PPlay.playlistPos.client = 1
			cl_PPlay.playStream( cl_PPlay.currentPlaylist[ cl_PPlay.playlistPos.client ].info, server, 2 )

		end

	end

	-- PLAY BUTTON IN FRAME
	panel.buttons.play = cl_PPlay.addbtn( panel.frame, "Play", functions.play, { w - 115, h - 40 }, { 100, 25 } )
	panel.buttons.play:SetDisabled( true )

	-- DELETE PLAYLIST BUTTON
	panel.buttons.deletePlaylist = cl_PPlay.addbtn( panel.frame, "Delete Playlist", functions.deletePlaylist, { 15, h - 40 }, { 80, 25 } )
	panel.buttons.deletePlaylist:SetDisabled( true )

	-- DELETE TRACK BUTTON
	panel.buttons.deleteTrack = cl_PPlay.addbtn( panel.frame, "Delete track", functions.deleteTrack, { 15 + 80 + 5, h - 40 }, { 80, 25 } )
	panel.buttons.deleteTrack:SetDisabled( true )

end

function cl_PPlay.openMy( server, kind )

	local strings = {}
	
	if !server then

		strings.frametitle = "PatchPlay - My Private " .. kind:gsub("^%l", string.upper)
		
	else

		strings.frametitle = "PatchPlay - Server " .. kind:gsub("^%l", string.upper)

	end

	-- Variables
	local w, h = 500, 350
	local data = {}
	local panel = {}
	local functions = {}

	-- Initialization
	data.selected = {}
	data.singleKind = string.sub(kind, 0, -2)
	panel.buttons = {}
	panel.textfields = {}
	panel.lists = {}
	panel.frames = {}

	-- FRAME
	panel.frame = cl_PPlay.addfrm(w, h, strings["frametitle"], true)

	-- DESCRIPTION
	cl_PPlay.addlbl( panel.frame, "Choose a " .. data.singleKind .. ":", 15, 30 )

	-- STREAM LIST
	panel.lists.streamList = cl_PPlay.addlv( panel.frame, 15, 50, w - 30, h - 100, {"Title"} )

	-- FILL STREAMLIST FUNCTION
	function functions.fillList()

		panel.lists.streamList:Clear()

		sh_PPlay.getSQLTable( "pplay_streamlist", function( result )

			table.foreach( result, function( key, stream )

				if stream.kind == data.singleKind then

					local line = panel.lists.streamList:AddLine( stream.info.title )
					line.id = stream.id
					line.info = stream.info
					--line.kind = stream.kind

				end

			end)

		end, server, LocalPlayer() )
	end
	functions.fillList()
	
	function panel.lists.streamList:OnClickLine( line, selected )

		enableIfDisabled( panel.buttons.play )
		enableIfDisabled( panel.buttons.delete )
		enableIfDisabled( panel.buttons.addToPlaylist )

		data.selected.id = line.id
		data.selected.info = line.info

		panel.lists.streamList:ClearSelection()
		line:SetSelected( true )

	end

	function functions.delete()

		sh_PPlay.deleteRow( server, "pplay_streamlist", "id", tostring( data.selected.id ) )
		functions.fillList()

	end

	function functions.play()

		cl_PPlay.playStream( data.selected.info, server )

		panel.frame:Close()

	end

	function functions.addToPlaylist()

		-- ADD FRAME
		panel.frames.add = cl_PPlay.addfrm( 150, 150, "Add To Playlist", true )

		-- PLAYLIST FRAMES
		panel.lists.playlists = cl_PPlay.addlv( panel.frames.add, 10, 50, 130, 70, { "Playlists" } )

		-- FILL PLAYLISTS FUNCTION
		function functions.fillPlaylists()

			panel.lists.playlists:Clear()

			sh_PPlay.getSQLTable( "pplay_playlistnames", function( result )

				table.foreach( result, function( key, playlist )

					local line = panel.lists.playlists:AddLine( playlist.name )
					line.id = playlist.id

				end)

			end, server, LocalPlayer() )

		end
		functions.fillPlaylists()

		-- CLICK PLAYLISTS FUNCTION
		function panel.lists.playlists:OnClickLine( line, selected )

			enableIfDisabled( panel.buttons.add )

			data.selected.playlist = line.id
			panel.lists.streamList:ClearSelection()
			line:SetSelected( true )

		end

		-- CREATE PLAYLIST FRAME FUNCTION
		function functions.openCreatePlaylist()

			-- CREATE PLAYLIST FUNCTION
			function functions.createPlaylist()

				sh_PPlay.insertRow( server, "pplay_playlistnames", panel.textfields.newPlaylist:GetValue() )
				panel.frames.createPlaylist:Close()
				functions.fillPlaylists()

			end

			panel.frames.createPlaylist = cl_PPlay.addfrm( 150, 80, "Create new playlist", true )
			panel.textfields.newPlaylist = cl_PPlay.addtext( panel.frames.createPlaylist, "Name:", "frame", { 10, 30 }, { 130, 15 } )

			function panel.textfields.newPlaylist:OnTextChanged()

				if panel.textfields.newPlaylist:GetValue() != "" then

					enableIfDisabled( panel.buttons.createPlaylist )

				else

					disableIfEnabled( panel.buttons.createPlaylist )

				end

			end

			-- CREATE BUTTON
			panel.buttons.createPlaylist = cl_PPlay.addbtn( panel.frames.createPlaylist, "Create", functions.createPlaylist, { 10, 50 }, { 130, 20 })
			panel.buttons.createPlaylist:SetDisabled( true )

		end

		function functions.add()

			if string.find(data.selected.info.streamurl, "soundcloud") and !string.find(data.selected.info.streamurl, "?client_id") then

				data.selected.info.streamurl = data.selected.info.streamurl .. "?client_id=92373aa73cab62ccf53121163bb1246e"

			end

			sh_PPlay.insertRow( server, "pplay_playlist", tostring(data.selected.playlist), data.selected.info )
			panel.frames.add:Close()

		end

		-- CREATE NEW PLAYLIST BUTTON
		cl_PPlay.addbtn( panel.frames.add, "Create new playlist", functions.openCreatePlaylist, { 10, 30 }, { 130, 15 } )

		-- ADD BUTTON
		panel.buttons.add = cl_PPlay.addbtn( panel.frames.add, "Add", functions.add, { 10, 125 }, { 130, 15 } )
		panel.buttons.add:SetDisabled( true )

	end

	-- DELETE BUTTON
	panel.buttons.delete = cl_PPlay.addbtn( panel.frame, "Delete", functions.delete, { 15, h - 40 }, { 80, 25 } )
	panel.buttons.delete:SetDisabled( true )

	-- PLAY BUTTON IN FRAME
	panel.buttons.play = cl_PPlay.addbtn( panel.frame, "Play", functions.play, { w - 115, h - 40 }, { 100, 25 } )
	panel.buttons.play:SetDisabled( true )

	--ADD TO PLAYLIST BUTTON
	if kind == "tracks" then

		panel.buttons.addToPlaylist = cl_PPlay.addbtn( panel.frame, "Add to Playlist", functions.addToPlaylist, { w - 230, h - 40}, { 100, 25 })
		panel.buttons.addToPlaylist:SetDisabled( true )

	end

end

function cl_PPlay.openHTML( args )

	local w = 680
	local h = 470

	local frm = cl_PPlay.addfrm(w, h, "TEST", true)

	local html = cl_PPlay.addhtml( frm )
	html:SetSize( w - 10, h - 25)
	html:SetPos( 5, 25 )

end

function cl_PPlay.openBrowser( mode, kind )

	local info = {}
	info.mode = mode
	info.kind = kind

	local addition
	local offsetY = 0
	if info.kind == "soundcloud" then
		info.type = "track"
		addition = "powered by SoundCloud API"
		offsetY = 30
	elseif info.kind == "station" then
		info.type = "station"
		addition = "powered by Dirble API"
	elseif info.kind == "youtube" then
		info.type = "track"
		addition = " powered by YouTube Data API V3"
	end

	if info.mode == "private" then

		strings = {
			frametitle = "PatchPlay - Private " .. info.kind:gsub("^%l", string.upper) .. " Browser " .. addition
		}
		
	elseif info.mode == "server" then
		strings = {
			frametitle = "PatchPlay - Server " .. info.kind:gsub("^%l", string.upper) .. " Browser " .. addition
		}
	end

	local w = ScrW() / 4
	local h = ScrH() / 3

	local frm = cl_PPlay.addfrm(w, h, strings.frametitle, true)

	--Browser
	local blist = cl_PPlay.addlv( frm, 5, 25 + offsetY, w - 10, h - 140 + 30 - offsetY, {"Choose"} )

	info.directurl = cl_PPlay.addtext( frm, "OR enter a " .. info.kind:gsub("^%l", string.upper) .. "-URL here:", "frame", { 15, h - 60 }, { w - 30, 15 } )

	local pbtn = nil
	local addbtn = nil

	function blist:OnClickLine( line, selected )

		enableIfDisabled( pbtn )
		if info.kind == "soundcloud" or info.kind == "station" and info.browse.stage == table.Count(cl_PPlay.BrowseURL.dirble) - 1 then
			enableIfDisabled( addbtn )
		end

		info.selectedLine = line.info
		blist:ClearSelection()
		line:SetSelected( true )

	end

	if info.kind == "soundcloud" then

		local txt_search = cl_PPlay.addtext( frm, "Search: ", "frame", { 15, 30 }, { w - 100, 20} )
		txt_search:RequestFocus()

		info.search = {}
		info.search.searchField = txt_search
		info.search.target = blist

		txt_search.OnEnter = function()

			cl_PPlay.search( info )
			
		end

		txt_search.OnTextChanged = function()

			enableIfDisabled( srcbtn, txt_search:GetValue() != "" )
			disableIfEnabled( srcbtn, txt_search:GetValue() == "" )

		end

		info.fails = cl_PPlay.addlbl( frm, "", 15, h - 90 )

		pbtn = cl_PPlay.addbtn( frm, "Play", cl_PPlay.searchplay, { w - 115, h - 35 }, { 100, 20 }, info )
		pbtn:SetDisabled(true)

		addbtn = cl_PPlay.addbtn( frm, "Add To My Tracks", cl_PPlay.addtomy, { w - 230, h - 35 }, { 100, 20 }, info )
		addbtn:SetDisabled(true)

		srcbtn = cl_PPlay.addbtn( frm, "Search", cl_PPlay.search, { w - 70, 30 }, { 55, 20 }, info )
		srcbtn:SetDisabled(true)
		

	elseif info.kind == "station" then

		info.browse = {}
		info.browse.history = {}
		info.browse.target = blist

		cl_PPlay.browse( info )

		cl_PPlay.addbtn( frm, "Back", cl_PPlay.browseBack, { 15, h - 35 }, { 100, 20 }, info )

		addbtn = cl_PPlay.addbtn( frm, "Add to My Stations", cl_PPlay.addtomy, { 120, h - 35 }, { 100, 20 }, info )
		addbtn:SetDisabled(true)

		cl_PPlay.addbtn( frm, "Browse/Play", cl_PPlay.browse, { w - 115, h - 35 }, { 100, 20 }, info )

	elseif info.kind == "youtube" then

		local txt_search = cl_PPlay.addtext( frm, "Search: ", "frame", { 15, 30 }, { w - 100, 20} )
		txt_search:RequestFocus()

		info.search = {}
		info.search.searchField = txt_search
		info.search.target = blist

		txt_search.OnEnter = function()

			cl_PPlay.search( info )
			
		end

		txt_search.OnTextChanged = function()

			enableIfDisabled( srcbtn, txt_search:GetValue() != "" )
			disableIfEnabled( srcbtn, txt_search:GetValue() == "" )

		end

		info.fails = cl_PPlay.addlbl( frm, "", 15, h - 90 )

		pbtn = cl_PPlay.addbtn( frm, "Play", cl_PPlay.searchplay, { w - 115, h - 35 }, { 100, 20 }, info )
		pbtn:SetDisabled(true)

		addbtn = cl_PPlay.addbtn( frm, "Add To My Tracks", cl_PPlay.addtomy, { w - 230, h - 35 }, { 100, 20 }, info )
		addbtn:SetDisabled(true)

		srcbtn = cl_PPlay.addbtn( frm, "Search", cl_PPlay.search, { w - 70, 30 }, { 55, 20 }, info )
		srcbtn:SetDisabled(true)

	end

	info.directurl.OnTextChanged = function()

		enableIfDisabled( pbtn, info.directurl:GetValue() != "" )
		enableIfDisabled( addbtn, info.directurl:GetValue() != "" )
		disableIfEnabled( pbtn, info.directurl:GetValue() == "" )
		disableIfEnabled( addbtn, info.directurl:GetValue() == "")

	end

	info.directurl.OnEnter = function()

		if info.kind == "soundcloud" then cl_PPlay.search( info ) else cl_PPlay.browse( info ) end
			
	end

end
