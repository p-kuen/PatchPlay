--------------
--  FONTS  --
--------------

surface.CreateFont( "DefaultRoboto", {
	font = "Roboto",
	size = 14,
	weight = 400,
} )

surface.CreateFont( "BoldRoboto", {
	font = "Roboto",
	size = 14,
	weight = 600,
} )


-------------
--  PANEL  --
-------------

function cl_PPlay.addpnl( plist, pos, size )

	local pnl
	local classname = plist:GetClassName()

	if classname != "Panel" then

		pnl = vgui.Create( "DPanel", plist )
		pnl:SetPos( unpack(pos) ) -- Set the position of the panel

	else

		pnl = vgui.Create( "DPanel" )

	end

	pnl:SetSize( unpack(size) ) -- Set the size of the panel

	if classname == "Panel" then
		plist:AddItem( pnl )
	end

	return pnl

end




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

	cl_PPlay.addlbl( frm, title, 5, 5.5 )
	-- Close Button
	cl_PPlay.addbtn( frm, "X", function() frm:Close() end, { w - 45 - 3, 0 }, { 45, 19 } )

	function frm:Paint()
		draw.RoundedBox( 0, 0, 0, self:GetWide(), self:GetTall(), Color( 255, 150, 0, 255 ) )
		draw.RoundedBox( 0, 5, 25, self:GetWide() - 10, self:GetTall() - 30, Color( 255, 255, 255 ) )
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

--------------
--  SWITCH  --
--------------

function cl_PPlay.addswitch( plist, text, on, x, y )

	local switch
	local classname = plist:GetClassName()

	if classname != "Panel" then

		switch = vgui.Create( "DCheckBoxLabel", plist )

	else

		switch = vgui.Create( "DCheckBoxLabel" )

	end

	if classname != "Panel" then
		switch:SetPos( x, y )
	end

	function switch:PerformLayout()

		local x = self.m_iIndent or 0

		self.Button:SetSize( 40, 19 )
		self.Button:SetPos( x, 0 )
		
		if ( self.Label ) then
			self.Label:SizeToContents()
			self.Label:SetPos( x + 35 + 10, self.Button:GetTall() / 2 - 7 )
		end

	end

	


	switch:SetText( text )
	switch:SetDark( true )
	switch.Label:SetFont("DefaultRoboto")

	switch:SizeToContents()
	switch:SetChecked( on )

	local curx = 0
	local function smooth(goal)

		local speed = math.abs(goal - curx) / 3

		if curx > goal then

			curx = curx - speed

		elseif curx < goal then

			curx = curx + speed

		end

		return curx

	end

	function switch.Button:Paint()

		local switchColor = {

			checked = Color( 255,116,0 ),
			unchecked = Color( 200,200,200 ),
			disabled = Color( 210,210,210 )

		}

		local knobColor = {

			regular = Color( 240, 240, 240 ),
			disabled = Color( 212, 212, 212 )

		}

		if switch:GetChecked() then

			local curSwitchCol
			local curKnobCol

			if switch:GetDisabled() then

				curSwitchCol = switchColor["disabled"]
				curKnobCol = knobColor["disabled"]
			else

				curSwitchCol = switchColor["checked"]
				curKnobCol = knobColor["regular"]
			end

			draw.RoundedBox( 8, 0, 0, self:GetWide(), self:GetTall(), curSwitchCol )
			draw.RoundedBox( 6, smooth(self:GetWide() - switch:GetTall() / 1.5 - 3), switch:GetTall() / 2 - switch:GetTall() / 1.5 / 2, switch:GetTall() / 1.5, switch:GetTall() / 1.5, curKnobCol )
			
		else

			local curSwitchCol
			local curKnobCol

			if switch:GetDisabled() then

				curSwitchCol = switchColor["disabled"]
				curKnobCol = knobColor["disabled"]
			else

				curSwitchCol = switchColor["unchecked"]
				curKnobCol = knobColor["regular"]
			end

			draw.RoundedBox( 8, 0, 0, self:GetWide(), self:GetTall(), curSwitchCol )
			draw.RoundedBox( 6, smooth(3), switch:GetTall() / 2 - switch:GetTall() / 1.5 / 2, switch:GetTall() / 1.5, switch:GetTall() / 1.5, curKnobCol )
		
		end

	end

	if classname == "Panel" then
		plist:AddItem( switch )
	end

	return switch

end



-------------
--  LABEL  --
-------------

function cl_PPlay.addlbl( plist, text, x, y )

	local lbl
	local classname = plist:GetClassName()

	if classname != "Panel" then

		lbl = vgui.Create( "DLabel", plist )

	else

		lbl = vgui.Create( "DLabel" )

	end

	if classname != "Panel" then
		lbl:SetPos( x, y )
	end

	lbl:SetText( text )
	lbl:SetDark( true )
	lbl:SetFont("DefaultRoboto")
	lbl:SizeToContents()

	if classname == "Panel" then
		plist:AddItem( lbl )
	end

	return lbl
	
end

----------------
--   BUTTON   --
----------------

function cl_PPlay.addbtn( plist, raw, cmd, ... )

	local btn
	local content = {
		sort = "text",
		arguments = "",
		text = raw
	}
	local create = "DButton"
	local isForm = plist:GetTable().Base == "DForm"

	if string.find(raw, "IMG:") then

		create = "DImageButton"

		content.sort = "image"


	elseif string.find(raw, "COL:") then

		create = "DColorButton"

		content.sort = "color"
		

	end

	if content.sort != "text" then

		local idx = string.find(raw, ";")
		content.arguments = string.sub( raw, 5, idx - 1 )
		content.text = string.sub( raw, idx + 1 )

	end

	if !isForm then

		btn = vgui.Create( create, plist )		
		btn:SetDark( false )

	else

		btn = vgui.Create( create )
		btn:SetDark( true )

	end

	btn.vararg = {...}
	btn:Center()

	if content.sort == "text" then

		btn:SetText( content.text )

	elseif content.sort == "image" then

		btn:SetImage( "materials/patchplay/" .. content.arguments .. ".png" )

	elseif content.sort == "color" then

		local color = string.Explode(",",content.arguments )

		btn:SetColor( Color( unpack(color) ) )
		btn:SetText( content.text )
		btn:SetContentAlignment( 5 )
		btn:SetDrawBorder( false )
		btn:SetToolTip( false )
		
	end

	if !isForm then
		btn:SetPos( btn.vararg[1][1], btn.vararg[1][2] )

		if btn.vararg[2] != nil and tonumber(btn.vararg[2][1]) != nil then

			btn:SetSize( btn.vararg[2][1], btn.vararg[2][2] )
			table.remove( btn.vararg, 1 )

		else

			btn:SizeToContents()

		end

		table.remove( btn.vararg, 1 )
	end

	local col =  Color( 200, 200, 200, 255 )
	local tcol = Color( 0, 0, 0, 255 )

	if string.find(content.text, "Stop") or string.find(content.text, "Delete") or string.find(content.text, "X") then
		col =  Color( 199, 80, 80, 255 )
		tcol = Color( 255,255,255,255 )

	end



	if isForm then
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

	if content.sort != "text" then return btn end

	function btn:Paint()

		local buttonColor = col
		local textColor = tcol

		if btn:GetDisabled() then

			buttonColor = Color( 230, 230, 230, 150 )
			textColor = Color( 0, 0, 0, 150 )

		end

		draw.RoundedBox( 0, 0, 0, btn:GetWide(), btn:GetTall(), buttonColor )
		btn:SetTextColor( textColor )
		
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

			cl_PPlay.addlbl( plist, desc, pos[1], pos[2] )
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

function cl_PPlay.addsldr( plist, value, pos, size )

	local sldr
	local isForm = plist:GetTable().Base == "DForm"

	if isForm then

		sldr = vgui.Create( "Slider" )

	else

		sldr = vgui.Create( "Slider", plist )
		sldr:SetPos( unpack(pos) )
		sldr:SetSize( unpack(size) )

	end

	sldr:SetMin( 0 )
	sldr:SetMax( 100 )
	sldr:SetValue( value )
	sldr:SetDecimals( 0 )

	if isForm then

		plist:AddItem( sldr )

	end

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

--------------
--  BINDER  --
--------------

function cl_PPlay.addbinder( plist, value, w, h, x, y )

	local binder
	local classname = plist:GetClassName()

	if classname != "Panel" then

		binder = vgui.Create( "DBinder", plist )
		binder:SetPos(x,y)		

	else

		binder = vgui.Create( "DBinder" )

	end

	binder:SetValue( value )
	binder:SetSize( w,h)

	if classname == "Panel" then
		plist:AddItem( binder )
	end

	function binder:Paint()

		local linespace = 5
		local linelength = 5

		local xparts = binder:GetWide() / (linespace + linelength)
		local yparts = binder:GetTall() / (linespace + linelength)
		local color = Color( 255,116,0 )

		for cur_x = 1, xparts, 1 do

			draw.RoundedBox( 0, binder:GetWide() / xparts * (cur_x - 1), 0, binder:GetWide() / xparts - 4, 2, color )
			draw.RoundedBox( 0, binder:GetWide() / xparts * (cur_x - 1), binder:GetTall() - 2, binder:GetWide() / xparts - 4, 2, color )

		end

		for cur_y = 1, yparts, 1 do

			draw.RoundedBox( 0, 0, binder:GetTall() / yparts * (cur_y - 1), 2, binder:GetTall() / yparts - 4, color )
			draw.RoundedBox( 0, binder:GetWide() - 2, binder:GetTall() / yparts * (cur_y - 1), 2, binder:GetTall() / yparts - 4, color )

		end

	end
	
	return binder

end


------------------
--  NUMBERWANG  --
------------------

function cl_PPlay.addnwang( plist, text, value, x, y )

	local nwang
	local classname = plist:GetClassName()

	if classname != "Panel" then

		nwang = vgui.Create( "DNumberWangLabel", plist )

	else

		nwang = vgui.Create( "DNumberWangLabel" )

	end

	if classname != "Panel" then
		
		nwang:SetPos( x, y )

	end

	nwang:SetValue( value )
	nwang:SetMin(1)
	nwang:SetText( text )
	nwang:SetDark(true)

	nwang.Label:SetFont("DefaultRoboto")
	nwang.Label:SizeToContents()
	nwang:SizeToContents()

	if classname == "Panel" then
		plist:AddItem( nwang )
	end

	return nwang

end
