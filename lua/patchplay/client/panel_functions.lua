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
	frm:ShowCloseButton( true )
	frm:SetBackgroundBlur( blur )
	frm:MakePopup()

	function frm:Paint()
		draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 150, 0, 255 ) )
		draw.RoundedBox( 0, 5, 25, w - 10, h - 30, Color( 255, 255, 255, 255 ) )
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

function cl_PPlay.addlbl( plist, text, typ )

	if typ == "category" then

		local lbl = plist:Add( "DLabel" )

		lbl:SetText( text )
		lbl:SetDark( true )

	elseif typ == "panel" then

		plist:AddControl( "Label", { Text = text } )

	end
	
end

----------------
--   BUTTON   --
----------------

function cl_PPlay.addbtn( plist, text, cmd, args )

	local btn = vgui.Create( "DButton" )

	btn:Center()
	btn:SetText( text )
	btn:SetDark( true )

	local col =  Color( 200, 200, 200, 255 )

	if string.find(text, "Stop") != nil or string.find(text, "Delete") != nil then
		col =  Color( 255, 106, 106, 200 )
	end

	function btn:Paint()
		draw.RoundedBox( 0, 0, 0, btn:GetWide(), btn:GetTall(), col)
	end

	btn.DoClick = function()

		if cmd == "" then return end

		if args != nil then
			RunConsoleCommand( "pplay_" .. cmd, args )
		else
			RunConsoleCommand( "pplay_" .. cmd )
		end

		cl_PPlay.UpdateMenus()

	end

	plist:AddItem( btn )

end



---------------
--  TEXTBOX  --
---------------

function cl_PPlay.addtext( plist, text )

	local tentry = plist:Add( "DTextEntry" )
	
	tentry:SetText( text )

end

--------------
--  SLIDER  --
--------------

function cl_PPlay.addsldr( plist )

	local sldr = vgui.Create( "Slider" )
	sldr:SetMin( 0 )
	sldr:SetMax( 100 )
	sldr:SetValue( 100 )
	sldr:SetDecimals( 0 )

	plist:AddItem( sldr )

	return sldr

end
