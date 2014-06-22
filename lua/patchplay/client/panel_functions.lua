----------------
--  FRAME  --
----------------

function cl_PPlay.addfrm( width, height, title, blur )

	local frm = vgui.Create( "DFrame" )
	local w = width
	local h = height
	frm:SetPos( surface.ScreenWidth() / 2 - ( w / 2 ), surface.ScreenHeight() / 2 - ( h / 2 ) )
	frm:SetSize( w, h )
	frm:SetTitle( "" )
	frm:SetVisible( true )
	frm:SetDraggable( true )
	frm:SetSizable( false )
	frm:ShowCloseButton( false )
	frm:SetBackgroundBlur( blur )
	frm:MakePopup()

	cl_PPlay.addlbl( frm, title, "frametitle", 5, 5.5 )
	-- Close Button
	cl_PPlay.addbtn( frm, "X", function() frm:Close() end, { w - 45, 0 }, { 40, 18 } )

	function frm:Paint()
		draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 150, 0, 255 ) )
		draw.RoundedBox( 0, 5, 25, w - 10, h - 30, Color( 255, 255, 255 ) )
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

		draw.RoundedBox( 2, 0, 0, chk:GetTall(), chk:GetTall(), Color( 150, 150, 150 ) )
		draw.RoundedBox( 2, 1, 1, chk:GetTall() - 2, chk:GetTall() - 2, Color( 240, 240, 240 ) )
		if chk:GetChecked() == false then return end
		draw.RoundedBox( 2, 2, 2, chk:GetTall() - 4, chk:GetTall() - 4, Color( 255, 150, 0 ) )

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

		return lbl

	elseif typ == "frametitle" then

		surface.CreateFont( "TitleFont", {
			font = "Roboto",
			size = 14,
			weight = 300,
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

function cl_PPlay.addbtn( plist, text, cmd, ... )

	local btn
	local classname = plist:GetClassName()

	if classname != "Panel" then

		btn = vgui.Create( "DButton", plist )		
		btn:SetDark( false )

	else

		btn = vgui.Create( "DButton" )
		btn:SetDark( true )

	end

	btn.vararg = {...}
	btn:Center()
	btn:SetText( text )

	if classname != "Panel" then
		btn:SetPos( btn.vararg[1][1], btn.vararg[1][2] )
		btn:SetSize( btn.vararg[2][1], btn.vararg[2][2] )
		table.remove( btn.vararg, 1 )
		table.remove( btn.vararg, 1 )
	end

	local col =  Color( 200, 200, 200, 255 )

	if string.find(text, "Stop") or string.find(text, "Delete") or string.find(text, "X") then
		col =  Color( 255, 106, 106, 200 )
		btn:SetTextColor( Color( 255,255,255,255 ) )
	end

	local oldcol = col

	function btn:Paint()
		if btn:GetDisabled() then col = Color( 230, 230, 230, 150 ) else col = oldcol end
		draw.RoundedBox( 0, 0, 0, btn:GetWide(), btn:GetTall(), col)
	end

	if classname == "Panel" then
		plist:AddItem( btn )
	end

	btn.DoClick = function()

		if cmd == nil or btn:GetDisabled() then return end

		if type(cmd) == "function" then

			cmd(unpack(btn.vararg))

		elseif type(cmd) == "string" then

			if cmd == "" then return end

			RunConsoleCommand( "pplay_" .. cmd, args )

		else

			return

		end

		cl_PPlay.UpdateMenus()

	end

	return btn

end

function cl_PPlay.addlinkbtn( plist, text, args )

	local btn = vgui.Create( "DButton" )
	btn:Center()
	btn:SetText( text )
	local tw, th = surface.GetTextSize( text )
	btn:SetSize( 100 , 30 )
	btn:SetDark( true )

	function btn:Paint()
		draw.RoundedBox( 0, 0, 0, btn:GetWide(), btn:GetTall(), Color( 200, 200, 200, 255 ))
	end

	btn.args = args

	plist:AddItem( btn )

	btn.DoClick = function()

		local apikey = "4fb8ff3c26a13ccbd6fd895ccbf5645845911ce9"
		cl_PPlay.browse( plist, "childCategories/apikey/"..apikey.."/primaryid/"..btn.args, btn.args )

	end

end

---------------
--  TEXTBOX  --
---------------

function cl_PPlay.addtext( plist, desc, typ, pos, size )

	local tentry
	
	if typ == "frame" then
		local w, h = 0, 0
		local posH = pos[2]

		if desc != "" then
			surface.SetFont( "Default" )
			w, h = surface.GetTextSize( desc ) + 3

			cl_PPlay.addlbl( plist, desc, "frame", pos[1], pos[2] )
		end

		if w >= (size[1] * 0.8) then

			w = 0
			posH = posH + h + 5

		end

		tentry = vgui.Create( "DTextEntry", plist )
		tentry:SetPos( pos[1] + w, posH )
		tentry:SetSize( size[1] - w, size[2] )

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

surface.CreateFont( "Little", {
	font = "Roboto",
	size = 16,
	weight = 300,
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

----------------
--  LISTVIEW  --
----------------

function cl_PPlay.addlv( plist, x, y, w, h, cols )

	local lv = vgui.Create( "DListView", plist )

	lv:SetPos( x, y )
	lv:SetSize( w, h )
	lv:SetMultiSelect( false )

	if #cols == 1 then
		lv:SetHideHeaders( true )
	end
	
	table.foreach( cols, function( key, value )
		lv:AddColumn( value )
	end )

	function lv.VBar:Paint()

		draw.RoundedBox( 0, 0, 0, 20, lv.VBar:GetTall(), Color( 240, 240, 240, 255 ) )

	end

	function lv.VBar.btnGrip:Paint()

		draw.RoundedBox( 0, 0, 0, 20, lv.VBar.btnGrip:GetTall(), Color( 200, 200, 200, 255 ) )

	end

	function lv.VBar.btnUp:Paint()

		draw.RoundedBox( 0, 0, 0, 20, 20, Color( 220, 220, 220, 255 ) )
		draw.SimpleText( "-", "Little", 8, 7, Color( 40, 40, 40, 255), 1, 1 )

	end

	function lv.VBar.btnDown:Paint()

		draw.RoundedBox( 0, 0, 0, 20, 20, Color( 220, 220, 220, 255 ) )
		draw.SimpleText( "-", "Little", 8, 7, Color( 40, 40, 40, 255), 1, 1 )

	end

	function lv:Paint()
		draw.RoundedBox( 0, 0, 0, w, h, Color( 220, 220, 220, 255 ) )
		draw.RoundedBox( 0, 1, 1, w - 2, h - 2, Color( 255, 255, 255, 255 ) )
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

function cl_PPlay.addgrid( plist, x, y, cols, size )

	local grid = vgui.Create( "DGrid", plist )

	grid:SetPos( x, y )
	grid:SetCols( cols )
	grid:SetColWide( size )
	grid:SetRowHeight( size/2 )
	
	return grid

end

function cl_PPlay.addhtml( plist )

	local html = vgui.Create( "HTML", plist )

	local content = [[<!DOCTYPE html>
	<html>
	<head>
		<link href='http://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,600,700' rel='stylesheet' type='text/css'>
		<script src="http://www.averi.at/jwplayer/jwplayer.js"></script>
	</head>
	<body>
		<span style="font-family:'Source Sans Pro', sans-serif; font-size: "><div id="myElement">Loading the player...</div></span>
		<iframe width="560" height="315" src="//www.youtube.com/embed/5JhXaF6GARQ?rel=0" frameborder="0" allowfullscreen></iframe>
	</body>
	</html>
	]]

	html:OpenURL( "http://www.youtube.com/embed/5JhXaF6GARQ?rel=0?&autoplay=1" )

	
	return html

end
