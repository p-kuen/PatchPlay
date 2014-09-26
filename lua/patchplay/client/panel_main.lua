------------------
--  ADMIN MENU  --
------------------

function cl_PPlay.AMenu( Panel )

	-- DELETE CONTROLS
	Panel:ClearControls()

	-- UPDATE PANELS
	if not cl_PPlay.ACPanel then
		cl_PPlay.ACPanel = Panel
	end

	-- CHECK ADMIN
	if game.SinglePlayer() then
		cl_PPlay.addlbl( Panel, "You are playing in SinglePlayer! This only works on Multiplayer-Servers." )
		return
	elseif !LocalPlayer():IsSuperAdmin() then
		cl_PPlay.addlbl( Panel, "You are not an admin!" )
		return
	end

	-- PANEL ELEMENTS
	cl_PPlay.addlbl( Panel, "Admin Panel for PatchPlay" )
	cl_PPlay.addbtn( Panel, "Server Stations", cl_PPlay.openMy, true, "stations" )
	cl_PPlay.addbtn( Panel, "Server Tracks", cl_PPlay.openMy, true, "tracks" )
	cl_PPlay.addbtn( Panel, "Server Playlists", cl_PPlay.openPlaylist, true )
	cl_PPlay.addlbl( Panel, "" )
	cl_PPlay.addbtn( Panel, "Open Station Browser", cl_PPlay.openBrowser, "server", "station" )
	cl_PPlay.addbtn( Panel, "Open SoundCloud Browser", cl_PPlay.openBrowser, "server", "soundcloud" )

	if cl_PPlay.sStream != nil and cl_PPlay.sStream.playing then
		cl_PPlay.addlbl( Panel, "" )
		if cl_PPlay.sStream.info.title != "" then
			cl_PPlay.addlbl( Panel, "Currently streaming " .. cl_PPlay.sStream.info.title )
		else
			cl_PPlay.addlbl( Panel, "Currently streaming " .. cl_PPlay.sStream.info.streamurl )
		end
		cl_PPlay.addbtn( Panel, "Stop streaming", cl_PPlay.sendToServer, "stop", nil )
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
	local chk_cl_main = cl_PPlay.addchk( Panel, "Use PatchPlay", cl_PPlay.use )

	function chk_cl_main:OnChange()

		if chk_cl_main:GetChecked() then

			cl_PPlay.use = true
			if cl_PPlay.isMusicPlaying( true ) and cl_PPlay.cStream.server then

				cl_PPlay.playStream( cl_PPlay.sStream.url, cl_PPlay.sStream.name, true )

			end

		else

			cl_PPlay.use = false
			cl_PPlay.stop()

		end

		cl_PPlay.UpdateMenus()

	end

	Panel:AddItem( chk )

	if !cl_PPlay.use then return end

	if cl_PPlay.isMusicPlaying() then
		cl_PPlay.addlbl( Panel, "You are listening in " .. cl_PPlay.cStream.serverText .. "-mode" )
	end

	if cl_PPlay.cStream.server then
		cl_PPlay.addlbl( Panel, "If the server is playing music you don't like, you can switch to\nprivate mode: You can decide what you hear and " ..
			"nobody\nelse will hear this music, just you. There are special panels\nfor SoundCloud and Internet Radio Streams.\n" ..
			"(Note, that may not every station or track is really working)" )
	end

	cl_PPlay.addbtn( Panel, "My Stations", cl_PPlay.openMy, false, "stations" )
	cl_PPlay.addbtn( Panel, "My Tracks", cl_PPlay.openMy, false, "tracks" )
	cl_PPlay.addbtn( Panel, "My Playlists", cl_PPlay.openPlaylist, false )
	cl_PPlay.addlbl( Panel, "" )
	cl_PPlay.addbtn( Panel, "Open Station Browser", cl_PPlay.openBrowser, "private", "station" )
	cl_PPlay.addbtn( Panel, "Open SoundCloud Browser", cl_PPlay.openBrowser, "private", "soundcloud" )
	--cl_PPlay.addbtn( Panel, "Open YouTube Browser", cl_PPlay.openHTML, { "private", "youtube" } )

	if cl_PPlay.isMusicPlaying() then
		cl_PPlay.addlbl( Panel, "" )
		cl_PPlay.addbtn( Panel, "Stop streaming", cl_PPlay.stop )
	end
	

	-- Volume Slider
	
	local sldr_vol

	if cl_PPlay.isMusicPlaying() then
		cl_PPlay.addlbl( Panel, "\nSet Volume:" )
		
		sldr_vol = cl_PPlay.addsldr( Panel, cl_PPlay.cStream.station:GetVolume() * 100 )

		sldr_vol.OnValueChanged = function( panel, value )
			if cl_PPlay.isMusicPlaying() then cl_PPlay.cStream.station:SetVolume( value / 100 ) end
		end
	end

	if cl_PPlay.isMusicPlaying( true ) then

		if cl_PPlay.sStream.info.title != nil and cl_PPlay.sStream.info.title != "" then
			cl_PPlay.addlbl( Panel, "The server currently streams " .. cl_PPlay.sStream.info.title, "panel" )
		else
			cl_PPlay.addlbl( Panel, "The server currently streams this Stream-URL: " .. cl_PPlay.sStream.info.streamurl, "panel" )
		end

		if !cl_PPlay.cStream.server then
			cl_PPlay.addbtn( Panel, "Switch to Server-Stream", cl_PPlay.play, cl_PPlay.sStream.info, true, 1 )
		end

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

	local function addchecks()

		-- PANEL ELEMENTS

		local binder = vgui.Create( "DBinder" )
		local currentKey = tonumber( cl_PPlay.getSetting( "openKey", false ) )

		binder:SetValue( currentKey )

		Panel:AddItem( binder )

		function binder:SetValue( iNumValue )

			binder:SetSelected( iNumValue )

			if currentKey != iNumValue then

				cl_PPlay.saveSetting( "openKey", tonumber( iNumValue ), false )

			end

		end

		if tobool(cl_PPlay.getSetting( "allowClients", true )) == true then

			cl_PPlay.addlbl( Panel, "Client Settings for PatchPlay\nThese settings only affect you", "panel" )

			local chk_cl_showNP = cl_PPlay.addchk( Panel, "Show NowPlaying", cl_PPlay.getSetting( "nowPlaying", false ) )

			function chk_cl_showNP:OnChange()

				cl_PPlay.saveSetting( "nowPlaying", tobool(chk_cl_showNP:GetChecked()), false )

			end

			local chk_cl_showQ = cl_PPlay.addchk( Panel, "Show Play Queue", cl_PPlay.getSetting( "queue", false ) )

			function chk_cl_showQ:OnChange()

				cl_PPlay.saveSetting( "queue", tobool(chk_cl_showQ:GetChecked()), false )

			end

			local chk_cl_showBN = cl_PPlay.addchk( Panel, "Show Big Notification", cl_PPlay.getSetting( "bigNotification", false ) )

			function chk_cl_showBN:OnChange()

				cl_PPlay.saveSetting( "bigNotification", tobool(chk_cl_showBN:GetChecked()), false )
				
			end

		else

			cl_PPlay.addlbl( Panel, "Changing the settings on the client is disabled for this server! Contact the server admin!", "panel" )

		end

		-- CHECK ADMIN
		if !game.SinglePlayer() and !LocalPlayer():IsSuperAdmin() then
			return
		elseif LocalPlayer():IsSuperAdmin() then

			cl_PPlay.addlbl( Panel, "Server Settings for PatchPlay\nThese settings affect everybody on this server!", "panel" )

		end

		--SERVER SETTINGS

		local chk_sv_showNP = cl_PPlay.addchk( Panel, "Show NowPlaying", cl_PPlay.getSetting( "nowPlaying", true ) )

		function chk_sv_showNP:OnChange()

			cl_PPlay.saveSetting( "nowPlaying", tobool(chk_sv_showNP:GetChecked()), true )
			
		end

		local chk_sv_showQ = cl_PPlay.addchk( Panel, "Show Play Queue", cl_PPlay.getSetting( "queue", true ) )

		function chk_sv_showQ:OnChange()

			cl_PPlay.saveSetting( "queue", tobool(chk_sv_showQ:GetChecked()), true )
			
		end

		local chk_sv_showBN = cl_PPlay.addchk( Panel, "Show Big Notification", cl_PPlay.getSetting( "bigNotification", true ) )

		function chk_sv_showBN:OnChange()

			cl_PPlay.saveSetting( "bigNotification", tobool(chk_sv_showBN:GetChecked()), true )
			
		end

		local chk_sv_allowC = cl_PPlay.addchk( Panel, "Allow clients to change the settings for themselves", cl_PPlay.getSetting( "allowClients", true ) )

		function chk_sv_allowC:OnChange()

			cl_PPlay.saveSetting( "allowClients", tobool(chk_sv_allowC:GetChecked()), true, false )
			
		end

	end

	sh_PPlay.getSQLTable( "pplay_settings", function( result )

		cl_PPlay.settings.server = result
		addchecks()

	end, true, LocalPlayer() )

	sh_PPlay.getSQLTable( "pplay_settings", function( result )

		cl_PPlay.settings.client = result

	end, false, LocalPlayer() )

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
