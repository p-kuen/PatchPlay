------------------
--  ADMIN MENU  --
------------------

function cl_PPlay.AMenu( Panel )

	-- DELETE CONTROLS
	Panel:ClearControls()

	-- CHECK ADMIN
	if !LocalPlayer():IsSuperAdmin() then
		cl_PPlay.addlbl( Panel, "You are not an admin!", "panel" )
		return
	end

	-- UPDATE PANELS
	if not cl_PPlay.ACPanel then
		cl_PPlay.ACPanel = Panel
	end

	-- PANEL ELEMENTS
	cl_PPlay.addlbl( Panel, "Admin Panel for PatchPlay", "panel" )
	cl_PPlay.addbtn( Panel, "Open Stream-List", "openStreamList" )
	cl_PPlay.addbtn( Panel, "Open URL-Panel", "openCustom" )

	if cl_PPlay.serverStream != nil and cl_PPlay.serverStream["playing"] then
		if cl_PPlay.serverStream["name"] != "" then
			cl_PPlay.addlbl( Panel, "Currently streaming " .. cl_PPlay.serverStream["name"], "panel" )
		else
			cl_PPlay.addlbl( Panel, "Currently streaming " .. cl_PPlay.serverStream["stream"], "panel" )
		end
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
	Panel:AddControl( "Label", { Text = "Main Switch:" } )
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

	if cl_PPlay.station != nil and cl_PPlay.station:IsValid() and cl_PPlay.station:GetState() == 1 then
		Panel:AddControl( "Label", {Text = "You are listening in " .. cl_PPlay.currentStream["stream_type"] .. "-mode"})
	end

	if cl_PPlay.currentStream["stream_type"] == "server" then
		Panel:AddControl( "Label", {Text = "If the server is playing music you don't like, you can go in private mode: You can decide what you hear and " ..
			"nobody else will hear this music, just you. At the moment, just Internet radio streams are possible URLs."})
	end

	cl_PPlay.addbtn( Panel, "Open Private Stream-List", "openPrivateStreamList" )
	cl_PPlay.addbtn( Panel, "Open Private URL-Panel", "openPrivateCustom" )
	cl_PPlay.addbtn( Panel, "Open SoundCloud Panel", "openPrivateSoundCloud" )

	-- Volume Slider
	Panel:AddControl( "Label", { Text = "\nSet Volume:" } )
	local sldr = vgui.Create( "Slider" )
	sldr:SetMin( 0 )
	sldr:SetMax( 100 )
	sldr:SetValue( 100 )
	sldr:SetDecimals( 0 )

	sldr.OnValueChanged = function( panel, value )
		if cl_PPlay.station != nil and cl_PPlay.station:IsValid() then cl_PPlay.station:SetVolume( value / 100 ) end
	end

	Panel:AddItem( sldr )

	local chk_nowplay = vgui.Create( "DCheckBoxLabel" )
	chk_nowplay:SetText( "Show NowPlaying" )
	chk_nowplay:SetChecked( cl_PPlay.showNowPlaying )
	chk_nowplay:SetDark( true )
	

	function chk_nowplay:OnChange()

		if !chk_nowplay:GetChecked() then
			cl_PPlay.showNowPlaying = false
		else
			cl_PPlay.showNowPlaying = true
		end
		
	end

	Panel:AddItem( chk_nowplay )

	if cl_PPlay.currentStream["stream_type"] == "private" or !cl_PPlay.use then

		if cl_PPlay.serverStream["playing"] and cl_PPlay.serverStream["name"] != "" then
			Panel:AddControl( "Label", {Text = "The server currently streams " .. cl_PPlay.serverStream["name"]})
		elseif cl_PPlay.serverStream["playing"] then
			Panel:AddControl( "Label", {Text = "The server currently streams this Stream-URL: " .. cl_PPlay.serverStream["stream"]})
		end

		if cl_PPlay.serverStream["playing"] and cl_PPlay.currentStream["stream_type"] == "private" and cl_PPlay.use then
			cl_PPlay.addbtn( Panel, "Switch to Server-Stream", "switchToServer" )
		end

	end

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



------------------
--  NETWORKING  --
------------------

function cl_PPlay.sendToServer( url, cmd, streamname )
	
	local streamInfo = {
		stream = url,
		command = cmd,
		name = streamname
	}

	net.Start( "pplay_sendtoserver" )
		net.WriteTable( streamInfo )
	net.SendToServer()
end


