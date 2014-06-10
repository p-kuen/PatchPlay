------------------
--  ADMIN MENU  --
------------------

function cl_PPlay.AMenu( Panel )

	-- DELETE CONTROLS
	Panel:ClearControls()

	-- CHECK ADMIN
	if game.SinglePlayer() then
		cl_PPlay.addlbl( Panel, "You are playing in SinglePlayer! This only works on Multiplayer-Servers.", "panel" )
		return
	elseif !LocalPlayer():IsSuperAdmin() then
		cl_PPlay.addlbl( Panel, "You are not an admin!", "panel" )
		return
	end

	-- UPDATE PANELS
	if not cl_PPlay.ACPanel then
		cl_PPlay.ACPanel = Panel
	end

	-- PANEL ELEMENTS
	cl_PPlay.addlbl( Panel, "Admin Panel for PatchPlay", "panel" )
	cl_PPlay.addbtn( Panel, "Server Stations", cl_PPlay.openMy, "panel", { "server", "stations" } )
	cl_PPlay.addbtn( Panel, "Server Tracks", cl_PPlay.openMy, "panel", { "server", "tracks" } )
	cl_PPlay.addbtn( Panel, "Server Playlists", cl_PPlay.openMy, "panel", { "server", "playlists" } )
	cl_PPlay.addlbl( Panel, "", "panel" )
	cl_PPlay.addbtn( Panel, "Open Station Browser", "openStationBrowser", nil, "server" )
	cl_PPlay.addbtn( Panel, "Open SoundCloud Browser", "openSoundCloudBrowser", nil, "server" )

	if cl_PPlay.currentStream != nil and cl_PPlay.currentStream["stream_type"] == "server" and cl_PPlay.station:IsValid() and cl_PPlay.station:GetState() == 0 then cl_PPlay.serverStream["playing"] = false end

	if cl_PPlay.serverStream != nil and cl_PPlay.serverStream["playing"] then
		cl_PPlay.addlbl( Panel, "", "panel" )
		if cl_PPlay.serverStream["name"] != "" then
			cl_PPlay.addlbl( Panel, "Currently streaming " .. cl_PPlay.serverStream["name"], "panel" )
		else
			cl_PPlay.addlbl( Panel, "Currently streaming " .. cl_PPlay.serverStream["stream"], "panel" )
		end
		cl_PPlay.addbtn( Panel, "Stop streaming", "stopServerStreaming", nil, "server" )
	end

	if cl_PPlay.serverPlaylist != nil and table.Count(cl_PPlay.serverPlaylist) != 0 then

		cl_PPlay.addbtn( Panel, "Open Server-Playlist", "openPlaylist", nil, "server" )

	end

end

------------------
--  USER MENU  --
------------------

function cl_PPlay.UMenu( Panel )

	-- DELETE CONTROLS
	Panel:ClearControls()

	-- UPDATE PANELS
	if not cl_PPlay.UCPanel then
		cl_PPlay.UCPanel = Panel
	end

	-- PANEL ELEMENTS

	-- Main Switch
	cl_PPlay.addlbl( Panel, "Main Switch:", "panel" )
	local chk = vgui.Create( "DCheckBoxLabel" )
	chk:SetText( "Activate PatchPlay" )
	chk:SetChecked( cl_PPlay.use )
	chk:SetDark( true )
	

	function chk:OnChange()

		if !chk:GetChecked() and cl_PPlay.station != nil and cl_PPlay.station:IsValid() then
			cl_PPlay.use = false
			cl_PPlay.stop(cl_PPlay.currentStream["stream"])
		elseif cl_PPlay.currentStream["stream_type"] == "server" and cl_PPlay.serverStream["playing"] then
			cl_PPlay.use = true
			cl_PPlay.play( cl_PPlay.serverStream["stream"], cl_PPlay.serverStream["name"], "server" )
		elseif cl_PPlay.currentStream["stream_type"] == "private" then
			cl_PPlay.use = true
		end
		cl_PPlay.UpdateMenus()
		
	end

	Panel:AddItem( chk )

	if cl_PPlay.station != nil and cl_PPlay.station:IsValid() and cl_PPlay.station:GetState() != 0 then
		Panel:AddControl( "Label", {Text = "You are listening in " .. cl_PPlay.currentStream["stream_type"] .. "-mode"})
	end

	if cl_PPlay.currentStream["stream_type"] == "server" then
		cl_PPlay.addlbl( Panel, "If the server is playing music you don't like, you can go in private mode: You can decide what you hear and " ..
			"nobody else will hear this music, just you. There are special panels for SoundCloud and Internet Radio Streams (mp3/m3u)", "panel" )
	end

	cl_PPlay.addbtn( Panel, "My Stations", cl_PPlay.openMy, { "private", "stations" } )
	cl_PPlay.addbtn( Panel, "My Tracks", cl_PPlay.openMy, { "private", "tracks" } )
	cl_PPlay.addbtn( Panel, "My Playlists", cl_PPlay.openMy, { "private", "playlists" } )
	cl_PPlay.addlbl( Panel, "", "panel" )
	cl_PPlay.addbtn( Panel, "Open Station Browser", cl_PPlay.openBrowser, { "private", "station" } )
	cl_PPlay.addbtn( Panel, "Open SoundCloud Browser", cl_PPlay.openBrowser, { "private", "soundcloud" } )

	if cl_PPlay.station != nil and cl_PPlay.station:IsValid() and cl_PPlay.station:GetState() != 0 then
		cl_PPlay.addlbl( Panel, "", "panel" )
		cl_PPlay.addbtn( Panel, "Stop streaming", "stopStreaming", "private" )
	end
	

	-- Volume Slider
	
	local sldr_vol

	if cl_PPlay.station != nil and cl_PPlay.station:IsValid() then
		cl_PPlay.addlbl( Panel, "\nSet Volume:", "panel" )
		
		sldr_vol = cl_PPlay.addsldr( Panel, cl_PPlay.station:GetVolume() * 100 )

		sldr_vol.OnValueChanged = function( panel, value )
			if cl_PPlay.station != nil and cl_PPlay.station:IsValid() then cl_PPlay.station:SetVolume( value / 100 ) end
		end
	end

	if cl_PPlay.currentStream["stream_type"] == "private" or !cl_PPlay.use then

		if cl_PPlay.serverStream["playing"] and cl_PPlay.serverStream["name"] != "" then
			cl_PPlay.addlbl( Panel, "The server currently streams " .. cl_PPlay.serverStream["name"], "panel" )
		elseif cl_PPlay.serverStream["playing"] then
			cl_PPlay.addlbl( Panel, "The server currently streams this Stream-URL: " .. cl_PPlay.serverStream["stream"], "panel" )
		end

		if cl_PPlay.serverStream["playing"] and cl_PPlay.currentStream["stream_type"] == "private" and cl_PPlay.use then
			cl_PPlay.addbtn( Panel, "Switch to Server-Stream", "switchToServer", nil, "private" )
		end

	end

	if cl_PPlay.privatePlaylist != nil and table.Count(cl_PPlay.privatePlaylist) != 0 then

		cl_PPlay.addbtn( Panel, "Open Playlist", "openPlaylist", nil, "private" )

	end

end

---------------------
--  SETTINGS MENU  --
---------------------

function cl_PPlay.SMenu( Panel )

	-- DELETE CONTROLS
	Panel:ClearControls()

	-- UPDATE PANELS
	if not cl_PPlay.SCPanel then
		cl_PPlay.SCPanel = Panel
	end

	-- PANEL ELEMENTS

	if cl_PPlay.getSetting( "allowClients", true ) then

		cl_PPlay.addlbl( Panel, "Client Settings for PatchPlay\nThese settings only affect you", "panel" )

		local chk_cl_showNP = cl_PPlay.addchk( Panel, "Show NowPlaying", cl_PPlay.getSetting( "nowPlaying", false ) )

		function chk_cl_showNP:OnChange()

			cl_PPlay.saveSetting( "nowPlaying", tostring(tobool(chk_cl_showNP:GetChecked())), false )

		end

		local chk_cl_showBN = cl_PPlay.addchk( Panel, "Show Big Notification", cl_PPlay.getSetting( "bigNotification", false ) )

		function chk_cl_showBN:OnChange()

			cl_PPlay.saveSetting( "bigNotification", tostring(tobool(chk_cl_showBN:GetChecked())), false )
			
		end

	else

		cl_PPlay.addlbl( Panel, "Changing the settings clientside is disabled for this server!", "panel" )

	end

	-- CHECK ADMIN
	if !game.SinglePlayer() and !LocalPlayer():IsSuperAdmin() then
		return
	elseif game.SinglePlayer() then

	else

		cl_PPlay.addlbl( Panel, "Server Settings for PatchPlay\nThese settings affect everybody on this server!", "panel" )

	end

	--SERVER SETTINGS

	local chk_sv_showNP = cl_PPlay.addchk( Panel, "Show NowPlaying", cl_PPlay.getSetting( "nowPlaying", true ) )

	function chk_sv_showNP:OnChange()

		cl_PPlay.saveSetting( "nowPlaying", tostring(tobool(chk_sv_showNP:GetChecked())), true, true )
		
	end

	local chk_sv_showBN = cl_PPlay.addchk( Panel, "Show Big Notification", cl_PPlay.getSetting( "bigNotification", true ) )

	function chk_sv_showBN:OnChange()

		cl_PPlay.saveSetting( "bigNotification", tostring(tobool(chk_sv_showBN:GetChecked())), true, true )
		
	end

	local chk_sv_allowC = cl_PPlay.addchk( Panel, "Allow clients to change the settings for themselves", cl_PPlay.getSetting( "allowClients", true ) )

	function chk_sv_allowC:OnChange()

		cl_PPlay.saveSetting( "allowClients", tostring(tobool(chk_sv_allowC:GetChecked())), true, false )
		
	end

end



--------------------
--  CREATE MENUS  --
--------------------

local function CreateMenus()

	-- ADMIN MENU
	spawnmenu.AddToolMenuOption("Utilities", "PatchPlay", "PPlay_Admin", "Server Player", "", "", cl_PPlay.AMenu)
	
	-- USER MENU
	spawnmenu.AddToolMenuOption("Utilities", "PatchPlay", "PPlay_User", "Client Player", "", "", cl_PPlay.UMenu)

	-- SETTINGS MENU
	spawnmenu.AddToolMenuOption("Utilities", "PatchPlay", "PPlay_Settings", "Settings", "", "", cl_PPlay.SMenu)

end
hook.Add( "PopulateToolMenu", "PPlayMakeMenus", CreateMenus )



--------------------
--  UPDATE MENUS  --
--------------------

function cl_PPlay.UpdateMenus()

	-- ADMIN MENU
	if cl_PPlay.ACPanel then
		cl_PPlay.AMenu(cl_PPlay.ACPanel)
	end
	
	-- USER MENU
	if cl_PPlay.UCPanel then
		cl_PPlay.UMenu(cl_PPlay.UCPanel)
	end

	-- SETTINGS MENU
	if cl_PPlay.SCPanel then
		cl_PPlay.SMenu(cl_PPlay.SCPanel)
	end

end
hook.Add( "SpawnMenuOpen", "PPlay_UpdateMenus", cl_PPlay.UpdateMenus )
