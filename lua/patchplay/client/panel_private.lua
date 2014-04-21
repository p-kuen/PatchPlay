function cl_PPlay.openPrivateStreamList( ply, cmd, args )

	local selectedStream = {
		name = "",
		url = ""
	}

	local w, h = 400, 320

	-- FRAME
	local frm = cl_PPlay.addfrm(w, h, "PatchPlay - Private Stream Player", true)

	-- LIST VIEW LABEL
	local llbl = vgui.Create( "DLabel", frm )
	llbl:SetPos( 15, 30 )
	llbl:SetSize( w - 30, 20 )
	llbl:SetText( "Choose a Stream:" )
	llbl:SetDark( true )

	-- STREAM LIST
	cl_PPlay.slv = vgui.Create( "DListView", frm )
	cl_PPlay.slv:SetPos( 15, 50 )
	cl_PPlay.slv:SetSize( w - 30, h - 100 )
	cl_PPlay.slv:SetMultiSelect( false )
	cl_PPlay.slv:AddColumn( "Name" )
	cl_PPlay.slv:AddColumn( "Stream" )

	table.foreach( cl_PPlay.privateStreamList, function( key, value )

		cl_PPlay.slv:AddLine( value["name"], value["stream"] )

	end)

	function cl_PPlay.slv:OnClickLine( line, selected )
		selectedStream["name"] = line:GetValue(1)
		selectedStream["url"] = line:GetValue(2)
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
	pbtn:SetPos( w - 115, h - 40 )
	pbtn:SetSize( 100, 25 )
	pbtn:SetText( "Start Stream" )
	pbtn:SetDark( false )

	function pbtn:Paint()
		draw.RoundedBox( 0, 0, 0, pbtn:GetWide(), pbtn:GetTall(), Color( 200, 200, 200, 255 ) )
	end

	-- DELETE BUTTON FUNCTION
	function dbtn:OnMousePressed()

		if selectedStream["url"] != "" then
			cl_PPlay.deleteStream( selectedStream["url"] )
		end
		
	end

	-- PLAY BUTTON FUNCTION
	function pbtn:OnMousePressed()

		if selectedStream["url"] != "" then
			cl_PPlay.play( selectedStream["url"], selectedStream["name"], "private" )
			cl_PPlay.getStreamList()
		end
		frm:Close()
		cl_PPlay.UpdateMenus()
	end

end
concommand.Add( "pplay_openPrivateStreamList", cl_PPlay.openPrivateStreamList )


--CUSTOM FRAME


function cl_PPlay.openPrivateCustom( ply, cmd, args )
	-- FRAME
	local frm = vgui.Create( "DFrame" )
	local w, h = 400, 200
	frm:SetPos( surface.ScreenWidth() / 2 - ( w / 2 ), surface.ScreenHeight() / 2 - ( h / 2 ) )
	frm:SetSize( w, h )
	frm:SetTitle( "PatchPlay - Private URL-Panel" )
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

			cl_PPlay.saveNewStream( te_name:GetValue(),  te_url:GetValue() )
			cl_PPlay.getStreamList()

			frm:Close()
			cl_PPlay.UpdateMenus()

		end
		
	end

	-- PLAY BUTTON FUNCTION
	function pbtn:OnMousePressed()

		if te_url:GetValue() != "" and te_name:GetValue() != "" then
			cl_PPlay.play( te_url:GetValue(), te_name:GetValue(), "private" )
		elseif te_url:GetValue() != "" then
			cl_PPlay.play( te_url:GetValue(), "", "private" )
		end
	end
end
concommand.Add( "pplay_openPrivateCustom", cl_PPlay.openPrivateCustom )


--SOUNDCLOUD FRAME
function cl_PPlay.openPrivateSoundCloud( ply, cmd, args )

	local url = ""

	-- FRAME
	local frm = vgui.Create( "DFrame" )
	local w, h = 400, 200
	frm:SetPos( surface.ScreenWidth() / 2 - ( w / 2 ), surface.ScreenHeight() / 2 - ( h / 2 ) )
	frm:SetSize( w, h )
	frm:SetTitle( "PatchPlay - Private SoundCloud" )
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
	clbl:SetSize( w - 30, 20 )
	clbl:SetText( "SoundCloud URL:" )
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
	slbl:SetText( "If you want to save the track to the streamlist, choose a name:" )
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

		http.Fetch( "http://api.soundcloud.com/resolve.json?url="..te_url:GetValue().."&client_id=92373aa73cab62ccf53121163bb1246e",
			function( body, len, headers, code )
				local entry = util.JSONToTable( body )

				local url = entry.stream_url .. "?client_id=92373aa73cab62ccf53121163bb1246e"
				if te_name:GetValue() != "" and url != "" then
					if entry.streamable then
						cl_PPlay.saveNewStream( url, te_name:GetValue() )
						cl_PPlay.getStreamList()

						frm:Close()
						cl_PPlay.UpdateMenus()
					else
						cl_PPlay.showNotify( "SoundCloud URL not streamable", "error", 10)
					end
					

				elseif url == "" then
					print("Not saved! URL is empty!")
				elseif te_name:GetValue() == "" then
					print("Not saved! Name is empty!")
				end
			end,
			function( error )
				print("ERROR with fetching!")
			end
		);
		
	end

	-- PLAY BUTTON FUNCTION
	function pbtn:OnMousePressed()

		local function playSC( url )
			if url != "" then
				if te_name != nil and te_name:GetValue() != "" then
					cl_PPlay.play( url, te_name:GetValue(), "private" )
				else
					cl_PPlay.play( url, "", "private" )
				end
			end
		end

		http.Fetch( "http://api.soundcloud.com/resolve.json?url="..te_url:GetValue().."&client_id=92373aa73cab62ccf53121163bb1246e",
			function( body, len, headers, code )
				local entry = util.JSONToTable( body )
				if entry.streamable then
					playSC(entry.stream_url .. "?client_id=92373aa73cab62ccf53121163bb1246e")
				else
					cl_PPlay.showNotify( "SoundCloud URL not streamable", "error", 10)
				end
			end,
			function( error )
				print("ERROR with fetching!")
			end
		);

	end
end
concommand.Add( "pplay_openPrivateSoundCloud", cl_PPlay.openPrivateSoundCloud )