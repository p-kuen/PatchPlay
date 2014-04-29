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
	cl_PPlay.addbtn( Panel, "Open Stream-List", "openStreamList", nil, "server" )
	cl_PPlay.addbtn( Panel, "Open URL-Panel", "openCustom", nil, "server" )
	cl_PPlay.addbtn( Panel, "Open SoundCloud Panel", "openSoundCloud", nil, "server" )

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

	cl_PPlay.addbtn( Panel, "Open Server-Playlist", "openPlaylist", nil, "server" )

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
			"nobody else will hear this music, just you. At the moment, just Internet radio streams are possible URLs.", "panel" )
	end

	cl_PPlay.addbtn( Panel, "Open Private Stream-List", "openStreamList", nil, "private" )
	cl_PPlay.addbtn( Panel, "Open Private URL-Panel", "openCustom", nil, "private" )
	cl_PPlay.addbtn( Panel, "Open SoundCloud Panel", "openSoundCloud", nil, "private" )
	if cl_PPlay.station != nil and cl_PPlay.station:IsValid() and cl_PPlay.station:GetState() != 0 then
		cl_PPlay.addlbl( Panel, "", "panel" )
		cl_PPlay.addbtn( Panel, "Stop streaming", "stopStreaming", nil, "private" )
	end
	

	-- Volume Slider
	cl_PPlay.addlbl( Panel, "\nSet Volume:", "panel" )
	local sldr_vol

	if cl_PPlay.station != nil and cl_PPlay.station:IsValid() then
		sldr_vol = cl_PPlay.addsldr( Panel, cl_PPlay.station:GetVolume() * 100 )

		sldr_vol.OnValueChanged = function( panel, value )
			if cl_PPlay.station != nil and cl_PPlay.station:IsValid() then cl_PPlay.station:SetVolume( value / 100 ) end
		end
	end

	local chk_nowplay = cl_PPlay.addchk( Panel, "Show NowPlaying", cl_PPlay.showNowPlaying )

	function chk_nowplay:OnChange()

		if !chk_nowplay:GetChecked() then
			cl_PPlay.showNowPlaying = false
		else
			cl_PPlay.showNowPlaying = true
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

	cl_PPlay.addbtn( Panel, "Open Playlist", "openPlaylist", nil, "private" )

end



--------------------
--  CREATE MENUS  --
--------------------

local function CreateMenus()

	-- ADMIN MENU
	spawnmenu.AddToolMenuOption("Utilities", "PatchPlay", "PPlay_Admin", "Admin Settings", "", "", cl_PPlay.AMenu)
	
	-- USER MENU
	spawnmenu.AddToolMenuOption("Utilities", "PatchPlay", "PPlay_User", "Settings", "", "", cl_PPlay.UMenu)

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

end
hook.Add( "SpawnMenuOpen", "PPlay_UpdateMenus", cl_PPlay.UpdateMenus )
