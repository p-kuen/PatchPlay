----------------
--  CHECKBOX  --
----------------

function cl_PPlay.addchk( plist, text, typ, var, var2 )

	local chk = vgui.Create( "DCheckBoxLabel" )

	chk:SetText( text )
	chk:SetDark( true )

	function chk:PaintOver()

		draw.RoundedBox( 2, 0, 0, chk:GetTall(), chk:GetTall(), Color( 150, 150, 150, 255 ) )
		draw.RoundedBox( 2, 1, 1, chk:GetTall() - 2, chk:GetTall() - 2, Color( 240, 240, 240, 255 ) )
		if chk:GetChecked() == false then return end
		draw.RoundedBox( 2, 2, 2, chk:GetTall() - 4, chk:GetTall() - 4, Color( 88, 144, 222, 255 ) )

	end

	plist:AddItem( chk )

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

	btn.DoClick = function()

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
