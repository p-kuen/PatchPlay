-------------------
--  ADMIN MENU  --
--------------------

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
	cl_PPlay.addbtn( Panel, "Open Panel", "openPanel" )

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
	chk:SetValue( 1 )
	chk:SetDark( true )
	Panel:AddItem( chk )

	function chk:OnChange()

		if !chk:GetChecked() and cl_PPlay.station != nil and cl_PPlay.station:IsValid() then
			cl_PPlay.station:Pause()
		else
			cl_PPlay.station:Play()
		end
		
	end

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
hook.Add( "SpawnMenuOpen", "PProtectMenus", cl_PPlay.UpdateMenus )



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

function cl_PPlay.openPanel( ply, cmd, args )

	-- FRAME
	local frm = vgui.Create( "DFrame" )
	local w, h = 400, 310
	frm:SetPos( surface.ScreenWidth() / 2 - ( w / 2 ), surface.ScreenHeight() / 2 - ( h / 2 ) )
	frm:SetSize( w, h )
	frm:SetTitle( "PatchPlay - Stream Player" )
	frm:SetVisible( true )
	frm:SetDraggable( true )
	frm:ShowCloseButton( true )
	frm:SetBackgroundBlur( true )
	frm:MakePopup()

	function frm:Paint()
		draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 150, 0, 255 ) )
		draw.RoundedBox( 0, 5, 25, w - 10, h - 30, Color( 255, 255, 255, 255 ) )
	end

	-- LIST VIEW LABEL
	local llbl = vgui.Create( "DLabel", frm )
	llbl:SetPos( 15, 30 )
	llbl:SetSize( w - 30, 20 )
	llbl:SetText( "Choose a Stream:" )
	llbl:SetDark( true )

	-- STREAM LIST
	local slv = vgui.Create( "DListView", frm )
	local SelectedStreamName = ""
	local SelectedStream = ""
	slv:SetPos( 15, 50 )
	slv:SetSize( w - 30, h - 150 )
	slv:SetMultiSelect( false )
	slv:AddColumn( "Name" )
	slv:AddColumn( "Stream" )
	slv:AddLine( "HouseTimeFM", "http://mp3.stream.tb-group.fm/ht.mp3?" )
	slv:AddLine( "TechnoBaseFM", "http://mp3.stream.tb-group.fm/tb.mp3?" )
	slv:AddLine( "HardBaseFM", "http://mp3.stream.tb-group.fm/hb.mp3?" )
	slv:AddLine( "CoreBaseFM", "http://mp3.stream.tb-group.fm/cb.mp3?" )

	function slv:OnClickLine( line, selected )
		print( "selected: " .. line:GetValue(2) )
		SelectedStreamName = line:GetValue(1)
		SelectedStream = line:GetValue(2)
		slv:ClearSelection()
		line:SetSelected( true )
	end

	-- LABEL IN FRAME
	local clbl = vgui.Create( "DLabel", frm )
	clbl:SetPos( 15, h - 95 )
	clbl:SetText( "Stream URL:" )
	clbl:SetDark( true )

	-- TEXTENTRY IN FRAME
	local tEntry = vgui.Create( "DTextEntry", frm )
	tEntry:SetPos( 15, h - 75 )
	tEntry:SetSize( w - 30, 22 )

	-- PLAY BUTTON IN FRAME
	local pbtn = vgui.Create( "DButton", frm )
	pbtn:Center()
	pbtn:SetPos( w - 225, h - 40 )
	pbtn:SetSize( 100, 25 )
	pbtn:SetText( "Start Stream" )
	pbtn:SetDark( false )

	function pbtn:Paint()
		draw.RoundedBox( 0, 0, 0, pbtn:GetWide(), pbtn:GetTall(), Color( 200, 200, 200, 255 ) )
	end

	-- STOP BUTTON IN FRAME
	local sbtn = vgui.Create( "DButton", frm )
	sbtn:Center()
	sbtn:SetPos( w - 115, h - 40 )
	sbtn:SetSize( 100, 25 )
	sbtn:SetText( "Stop Stream" )
	sbtn:SetDark( true )

	function sbtn:Paint()
		draw.RoundedBox( 0, 0, 0, sbtn:GetWide(), sbtn:GetTall(), Color( 200, 200, 200, 255 ) )
	end



	-- PLAY BUTTON FUNCTION
	function pbtn:OnMousePressed()

		if SelectedStream != "" then
			cl_PPlay.sendToServer( SelectedStream, "play", SelectedStreamName )
		elseif tEntry:GetValue() != "" then
			cl_PPlay.sendToServer( tEntry:GetValue(), "play", "" )
		else
			cl_PPlay.sendToServer( "", "play", "" )
		end
		frm:Close()
	end

	-- STOP BUTTON FUNCTION
	function sbtn:OnMousePressed()

		cl_PPlay.sendToServer( cl_PPlay.currentStream, "stop" )

	end

end
concommand.Add( "pplay_openPanel", cl_PPlay.openPanel )
