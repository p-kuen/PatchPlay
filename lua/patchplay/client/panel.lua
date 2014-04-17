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
	cl_PPlay.addbtn( Panel, "Open Custom URL", "openCustom" )

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

function cl_PPlay.openStreamList( ply, cmd, args )

	-- FRAME
	local frm = vgui.Create( "DFrame" )
	local w, h = 400, 320
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
	cl_PPlay.slv = vgui.Create( "DListView", frm )
	local SelectedStreamName = ""
	local SelectedStream = ""
	cl_PPlay.slv:SetPos( 15, 50 )
	cl_PPlay.slv:SetSize( w - 30, h - 100 )
	cl_PPlay.slv:SetMultiSelect( false )
	cl_PPlay.slv:AddColumn( "Name" )
	cl_PPlay.slv:AddColumn( "Stream" )

	table.foreach( cl_PPlay.streamList, function( key, value )

		cl_PPlay.slv:AddLine( value["name"], value["stream"] )

	end)

	function cl_PPlay.slv:OnClickLine( line, selected )
		SelectedStreamName = line:GetValue(1)
		SelectedStream = line:GetValue(2)
		cl_PPlay.slv:ClearSelection()
		line:SetSelected( true )
	end

	-- DELETE BUTTON IN FRAME
	local dbtn = vgui.Create( "DButton", frm )
	dbtn:Center()
	dbtn:SetPos( 15, h - 40 )
	dbtn:SetSize( 80, 25 )
	dbtn:SetText( "Delete" )
	dbtn:SetDark( false )

	function dbtn:Paint()
		draw.RoundedBox( 0, 0, 0, dbtn:GetWide(), dbtn:GetTall(), Color( 200, 200, 200, 255 ) )
	end

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

	-- DELETE BUTTON FUNCTION
	function dbtn:OnMousePressed()

		if SelectedStream != "" then
			net.Start( "pplay_deletestream" )
				net.WriteString( SelectedStream )
			net.SendToServer()
		end
		
	end

	-- PLAY BUTTON FUNCTION
	function pbtn:OnMousePressed()

		if SelectedStream != "" then
			cl_PPlay.sendToServer( SelectedStream, "play", SelectedStreamName )
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
concommand.Add( "pplay_openStreamList", cl_PPlay.openStreamList )


--CUSTOM FRAME


function cl_PPlay.openCustom( ply, cmd, args )
	-- FRAME
	local frm = vgui.Create( "DFrame" )
	local w, h = 400, 200
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

	-- LABEL IN FRAME
	local clbl = vgui.Create( "DLabel", frm )
	clbl:SetPos( 15, 30 )
	clbl:SetText( "Stream URL:" )
	clbl:SetDark( true )

	-- TEXTENTRY IN FRAME
	local te_url = vgui.Create( "DTextEntry", frm )
	te_url:SetPos( 15, 50 )
	te_url:SetSize( w - 30, 22 )

	-- PLAY BUTTON IN FRAME
	local pbtn = vgui.Create( "DButton", frm )
	pbtn:Center()
	pbtn:SetPos( w - 115, 82 )
	pbtn:SetSize( 100, 20 )
	pbtn:SetText( "Play" )
	pbtn:SetDark( false )

	function pbtn:Paint()
		draw.RoundedBox( 0, 0, 0, pbtn:GetWide(), pbtn:GetTall(), Color( 200, 200, 200, 255 ) )
	end

	-- STREAM LABEL
	local slbl = vgui.Create( "DLabel", frm )
	slbl:SetPos( 15, 112 )
	slbl:SetSize( w - 30, 15 )
	slbl:SetText( "If you want to save the stream to the streamlist, choose a name:" )
	slbl:SetDark( true )

	-- TEXTENTRY IN FRAME
	local te_name = vgui.Create( "DTextEntry", frm )
	te_name:SetPos( 15, 132 )
	te_name:SetSize( w - 30, 22 )

	-- SAVE BUTTON IN FRAME
	local sabtn = vgui.Create( "DButton", frm )
	sabtn:Center()
	sabtn:SetPos( w - 115, h - 37 )
	sabtn:SetSize( 100, 22 )
	sabtn:SetText( "Save" )
	sabtn:SetDark( false )

	function sabtn:Paint()
		draw.RoundedBox( 0, 0, 0, sabtn:GetWide(), sabtn:GetTall(), Color( 200, 200, 200, 255 ) )
	end

	-- SAVE BUTTON FUNCTION
	function sabtn:OnMousePressed()

		if te_name:GetValue() != "" and  te_url:GetValue() != "" then

			local newStream = {
				name = te_name:GetValue(),
				url = te_url:GetValue()
			}

			net.Start( "pplay_savestream" )
				net.WriteTable( newStream )
			net.SendToServer()

			frm:Close()

		end
		
	end

	-- PLAY BUTTON FUNCTION
	function pbtn:OnMousePressed()

		if te_url:GetValue() != "" then
			cl_PPlay.sendToServer( te_url:GetValue(), "play", "" )
		else
			cl_PPlay.sendToServer( "", "play", "" )
		end
	end
end
concommand.Add( "pplay_openCustom", cl_PPlay.openCustom )
