----------------
--  FRAME  --
----------------

function cl_PPlay.addfrm( width, height, title, blur )

	local frm = vgui.Create( "DFrame" )
	local w = width
	local h = height
	frm:SetPos( surface.ScreenWidth() / 2 - ( w / 2 ), surface.ScreenHeight() / 2 - ( h / 2 ) )
	frm:SetSize( w, h )
	frm:SetTitle( title )
	frm:SetVisible( true )
	frm:SetDraggable( true )
	frm:SetSizable( false )
	frm:ShowCloseButton( false )
	frm:SetBackgroundBlur( blur )
	frm:MakePopup()

	cl_PPlay.addlbl( frm, title, "frametitle", 5, 5 )
		-- Close Button
	local cbtn = cl_PPlay.addbtn( frm, "X", nil, "frame", {w - 35, 5, 30, 15} )

	-- SAVE BUTTON FUNCTION
	function cbtn:OnMousePressed()

		frm:Close()
		
	end

	function frm:Paint()
		draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, 255 ) )
		draw.RoundedBox( 0, 0, 25, w, 3, Color( 255, 150, 0, 255 ) )
	end

	return frm

end

----------------
--  CHECKBOX  --
----------------

function cl_PPlay.addchk( plist, text, checked )

	local chk = vgui.Create( "DCheckBoxLabel" )

	chk:SetText( text )
	chk:SetDark( true )
	chk:SetChecked( checked )

	function chk:PaintOver()

		draw.RoundedBox( 2, 0, 0, chk:GetTall(), chk:GetTall(), Color( 150, 150, 150, 255 ) )
		draw.RoundedBox( 2, 1, 1, chk:GetTall() - 2, chk:GetTall() - 2, Color( 240, 240, 240, 255 ) )
		if chk:GetChecked() == false then return end
		draw.RoundedBox( 2, 2, 2, chk:GetTall() - 4, chk:GetTall() - 4, Color( 88, 144, 222, 255 ) )

	end

	plist:AddItem( chk )

	return chk

end



-------------
--  LABEL  --
-------------

function cl_PPlay.addlbl( plist, text, typ, x, y )

	if typ == "category" then

		local lbl = plist:Add( "DLabel" )

		lbl:SetText( text )
		lbl:SetDark( true )

	elseif typ == "panel" then

		local lbl = vgui.Create( "DLabel" )
		lbl:SetText( text )
		lbl:SetDark( true )
		lbl:SizeToContents()

		plist:AddItem( lbl )

	elseif typ == "frame" then

		local lbl = vgui.Create( "DLabel", plist )
		lbl:SetPos( x, y )
		lbl:SetText( text )
		lbl:SizeToContents()
		lbl:SetDark( true )

	elseif typ == "frametitle" then

		surface.CreateFont( "TitleFont", {
			font = "Roboto",
			size = 20,
			weight = 500,
			blursize = 0,
			scanlines = 0,
			antialias = true,
			underline = false,
			italic = false,
			strikeout = false,
			symbol = false,
			rotary = false,
			shadow = false,
			additive = false,
			outline = false,
		} )

		local lbl = vgui.Create( "DLabel", plist )
		lbl:SetPos( x, y )
		lbl:SetFont("TitleFont")
		lbl:SetText( text )
		lbl:SizeToContents()
		lbl:SetDark( true )


	end
	
end

----------------
--   BUTTON   --
----------------

function cl_PPlay.addbtn( plist, text, cmd, typ, args )

	local btn
	if typ == "frame"  then btn = vgui.Create( "DButton", plist ) else btn = vgui.Create( "DButton" ) end

	btn:Center()
	btn:SetText( text )

	if typ == "frame" then
		btn:SetPos( args[1], args[2] )
		btn:SetSize( args[3], args[4] )
		btn:SetDark( false )
	else
		btn:SetDark( true )
	end

	local col =  Color( 200, 200, 200, 255 )

	if string.find(text, "Stop") != nil or string.find(text, "Delete") != nil then
		col =  Color( 255, 106, 106, 200 )
	end

	function btn:Paint()
		draw.RoundedBox( 0, 0, 0, btn:GetWide(), btn:GetTall(), col)
	end

	if typ != "frame" then plist:AddItem( btn ) else return btn end

	btn.DoClick = function()

		if cmd == "" then return end

		if args != nil then
			if typ == "my" then
				RunConsoleCommand( "pplay_" .. cmd, args[1], args[2] )
			else
				RunConsoleCommand( "pplay_" .. cmd, args )
			end
			
		else
			RunConsoleCommand( "pplay_" .. cmd )
		end

		cl_PPlay.UpdateMenus()

	end

	

end

function cl_PPlay.addlinkbtn( plist, text, args )

	local btn = vgui.Create( "DButton" )
	btn:Center()
	btn:SetText( text )
	btn:SetDark( true )

	btn.args = args

	plist:AddItem( btn )

	btn.DoClick = function()

		print(btn.args)

	end

end

---------------
--  TEXTBOX  --
---------------

function cl_PPlay.addtext( plist, typ, pos, size )

	local tentry
	
	if typ == "frame" then
		tentry = vgui.Create( "DTextEntry", plist )
		tentry:SetPos( pos[1], pos[2] )
		tentry:SetSize( size[1], size[2] )

		return tentry
	else
		tentry = plist:Add( "DTextEntry" )
	end

end

--------------
--  SLIDER  --
--------------

function cl_PPlay.addsldr( plist, value )

	local sldr = vgui.Create( "Slider" )
	sldr:SetMin( 0 )
	sldr:SetMax( 100 )
	sldr:SetValue( value )
	sldr:SetDecimals( 0 )

	plist:AddItem( sldr )

	return sldr

end

----------------
--  LISTVIEW  --
----------------

function cl_PPlay.addlv( plist, x, y, w, h, cols )

	local lv = vgui.Create( "DListView", plist )

	lv:SetPos( x, y )
	lv:SetSize( w, h )
	lv:SetMultiSelect( false )
	
	table.foreach( cols, function( key, value )
		lv:AddColumn( value )
	end )

	function lv:Paint()
		draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, 255 ) )
		--draw.RoundedBox( 0, 5, 25, w - 10, h - 30, Color( 255, 255, 255, 255 ) )
	end
	
	return lv

end

-------------------
--  SCROLLPANEL  --
-------------------

function cl_PPlay.addsp( plist, x, y, w, h )

	local sp = vgui.Create( "DScrollPanel", plist )

	sp:SetPos( x, y )
	sp:SetSize( w, h )
	
	return sp

end

-------------------
--  GRIDPANEL  --
-------------------

function cl_PPlay.addgrid( plist, x, y, cols, colswide )

	local grid = vgui.Create( "DGrid", plist )

	grid:SetPos( x, y )
	grid:SetCols( cols )
	grid:SetColWide( colswide )
	
	return grid

end
