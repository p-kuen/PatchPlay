function cl_PPlay.openStreamList( ply, cmd, args )

	local selectedStream = {
		name = "",
		url = ""
	}

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
	cl_PPlay.slv:SetPos( 15, 50 )
	cl_PPlay.slv:SetSize( w - 30, h - 100 )
	cl_PPlay.slv:SetMultiSelect( false )
	cl_PPlay.slv:AddColumn( "Name" )
	cl_PPlay.slv:AddColumn( "Stream" )

	function fillStreamList()
		cl_PPlay.slv:Clear()
		table.foreach( cl_PPlay.streamList, function( key, value )

			cl_PPlay.slv:AddLine( value["name"], value["stream"] )

		end)
	end

	fillStreamList()

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
			net.Start( "pplay_deletestream" )
				net.WriteString( selectedStream["url"] )
			net.SendToServer()

			timer.Simple(0.1, fillStreamList)
		end
		
	end

	-- PLAY BUTTON FUNCTION
	function pbtn:OnMousePressed()

		if selectedStream["url"] != "" then
			cl_PPlay.sendToServer( selectedStream["url"], selectedStream["name"], "play" )
			frm:Close()
			cl_PPlay.UpdateMenus()
		end
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

			cl_PPlay.saveNewServerStream(te_url:GetValue(), te_name:GetValue())

			frm:Close()
			cl_PPlay.UpdateMenus()

		elseif te_url:GetValue() == "" then
			print("Not saved! URL is empty!")
		elseif te_name:GetValue() == "" then
			print("Not saved! Name is empty!")
		end
		
	end

	-- PLAY BUTTON FUNCTION
	function pbtn:OnMousePressed()

		if te_url:GetValue() != "" then
			if te_name != nil and te_name:GetValue() != "" then
				cl_PPlay.sendToServer( te_url:GetValue(), te_Name:GetValue(), "play" )
			else
				cl_PPlay.sendToServer( te_url:GetValue(), "", "play" )
			end
		end

	end
end
concommand.Add( "pplay_openCustom", cl_PPlay.openCustom )

--SOUNDCLOUD FRAME
function cl_PPlay.openSoundCloud( ply, cmd, args )

	-- FRAME
	local frm = vgui.Create( "DFrame" )
	local w, h = 400, 200
	frm:SetPos( surface.ScreenWidth() / 2 - ( w / 2 ), surface.ScreenHeight() / 2 - ( h / 2 ) )
	frm:SetSize( w, h )
	frm:SetTitle( "PatchPlay - SoundCloud" )
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
						cl_PPlay.saveNewServerStream( url, te_name:GetValue() )

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
			if url != "" and url != nil then
				if te_name != nil and te_name:GetValue() != "" then
					cl_PPlay.sendToServer( url, te_Name:GetValue(), "play" )
				else
					cl_PPlay.sendToServer( url, "", "play" )
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
concommand.Add( "pplay_openSoundCloud", cl_PPlay.openSoundCloud )

function cl_PPlay.saveNewServerStream(stream, text)
	local newStream = {
		name = text,
		url = stream
	}

	net.Start( "pplay_savestream" )
		net.WriteTable( newStream )
	net.SendToServer()
end