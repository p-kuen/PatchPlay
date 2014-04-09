----------------
--  SETTINGS  --
----------------

--------------------
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

	-- CLEANUP CONTROLS
	cl_PPlay.addlbl( Panel, "This is the admin panel", "panel" )
	cl_PPlay.addbtn( Panel, "Open Panel", "openPanel" )

	--cl_PProtect.addlbl( Panel, "\nCleanup props of disconnected Players:", "panel" )
	--cl_PProtect.addbtn( Panel, "Cleanup all Props from disc. Players", "cleandiscprops" )

	--cl_PProtect.addlbl( Panel, "\nCleanup Player's props:", "panel" )
		
	--net.Start( "getCount" )
		--net.WriteString( "value" )
	--net.SendToServer()

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

	-- BUDDY CONTROLS
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

	local sldr = vgui.Create( "Slider" )

	sldr:SetMin( 0 )
	sldr:SetMax( 100 )
	sldr:SetValue( 100 )
	sldr:SetDecimals( 0 )

	sldr.OnValueChanged = function( panel, value )
		if cl_PPlay.station != nil and cl_PPlay.station:IsValid() then cl_PPlay.station:SetVolume( value / 100 ) end
	end

	Panel:AddItem(sldr)

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
		--RunConsoleCommand("sh_PProtect.reloadSettings", LocalPlayer())
	end
	
	-- USER MENU
	if cl_PPlay.UCPanel then
		cl_PPlay.UMenu(cl_PPlay.UCPanel)
		--RunConsoleCommand("sh_PProtect.reloadSettings", LocalPlayer())
	end

end
hook.Add( "SpawnMenuOpen", "PProtectMenus", cl_PPlay.UpdateMenus )

------------------
--  NETWORKING  --
------------------
function cl_PPlay.sendToServer( url, cmd )
	
	local streamInfo = {
		stream = url,
		command = cmd
	}

		net.Start("pplay_sendtoserver")
			net.WriteTable( streamInfo )
		net.SendToServer()
	

end

function cl_PPlay.openPanel( ply, cmd, args )

	local frm = vgui.Create( "DFrame" )
	local w, h = 400, 300

	frm:SetPos( surface.ScreenWidth() / 2 - ( w / 2 ), surface.ScreenHeight() / 2 - ( h / 2 ) )
	frm:SetSize( w, h )
	frm:SetTitle( "PatchPlay - Stream Player" )
	frm:SetVisible( true )
	frm:SetDraggable( true )
	frm:ShowCloseButton( true )
	frm:SetBackgroundBlur( true )
	frm:MakePopup()

	-- PLAY BUTTON IN FRAME
	local pbtn = vgui.Create( "DButton", frm )

	pbtn:Center()
	pbtn:SetPos( w - 160, h - 80 )
	pbtn:SetSize( 150, 30 )
	pbtn:SetText( "Start Stream" )
	pbtn:SetDark( true )

	-- STOP BUTTON IN FRAME
	local sbtn = vgui.Create( "DButton", frm )

	sbtn:Center()
	sbtn:SetPos( w - 160, h - 40 )
	sbtn:SetSize( 150, 30 )
	sbtn:SetText( "Stop Stream" )
	sbtn:SetDark( true )

	-- LABEL IN FRAME
	local lbl = vgui.Create( "DLabel", frm )

	lbl:SetPos( 15, 40 )
	lbl:SetText( "Stream URL:" )
	lbl:SetDark( true )

	-- TEXTENTRY IN FRAME
	local tEntry = vgui.Create( "DTextEntry", frm )

	tEntry:SetPos( 15, 65 )
	tEntry:SetSize( 270, 25 )

	





	function pbtn:OnMousePressed()

		if tEntry:GetValue() != "" then
			cl_PPlay.sendToServer( tEntry:GetValue(), "play" )
		else
			cl_PPlay.sendToServer( "", "play" )
		end
		frm:Close()
	end

	function sbtn:OnMousePressed()

		cl_PPlay.sendToServer( cl_PPlay.currentStream, "stop" )

	end

	

end
concommand.Add( "pplay_openPanel", cl_PPlay.openPanel )
