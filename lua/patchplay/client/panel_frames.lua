function cl_PPlay.openMy( ply, cmd, args )

	local strings = {}

	local kind = args[2]
	local singleKind = string.sub(kind, 0, -2)

	if args[1] == "private" then

		strings = {
			frametitle = "PatchPlay - My Private " .. kind:gsub("^%l", string.upper)
		}
		
	elseif args[1] == "server" then
		strings = {
			frametitle = "PatchPlay - Server " .. kind:gsub("^%l", string.upper)
		}
	end

	local selectedLine

	local w, h = 500, 350

	-- FRAME
	local frm = cl_PPlay.addfrm(w, h, strings["frametitle"], true)

	cl_PPlay.addlbl( frm, "Choose a " .. singleKind .. ":", "frame", 15, 30 )

	-- TRACK LIST
	local tlv = cl_PPlay.addlv( frm, 15, 50, w - 30, h - 100, {"Title"} )

	function fillList()
		

		tlv:Clear()
		if args[1] == "private" then

			table.foreach( cl_PPlay.privateStreamList, function( key, value )

				if value["kind"] == singleKind then

					local line = tlv:AddLine( value["name"] )
					line.url = value["stream"]
					line.kind = value["kind"]

				end

			end)
			
		elseif args[1] == "server" then

			table.foreach( cl_PPlay.streamList, function( key, value )

				if value["kind"] == singleKind then

					local line = tlv:AddLine( value["name"] )
					line.url = value["stream"]
					line.kind = value["kind"]

				end

			end)

		end
	end

	fillList()

	function tlv:OnClickLine( line, selected )

		selectedLine = line
		tlv:ClearSelection()
		line:SetSelected( true )
	end

	-- DELETE BUTTON IN FRAME
	local dbtn = cl_PPlay.addbtn( frm, "Delete", nil, "frame", {15, h - 40, 80, 25} )

	-- DELETE BUTTON FUNCTION
	function dbtn:OnMousePressed()

		if selectedLine != nil then

			if args[1] == "private" then

				cl_PPlay.deleteStream( selectedLine.url )
				cl_PPlay.getStreamList()
				fillList()
				
			elseif args[1] == "server" then

				net.Start( "pplay_deletestream" )
					net.WriteString( selectedLine.url )
				net.SendToServer()

				timer.Simple(0.1, fillList)

			end
		end
		
	end

	-- PLAY BUTTON IN FRAME
	local pbtn = cl_PPlay.addbtn( frm, "Play", nil, "frame", {w - 115, h - 40, 100, 25} )

	-- PLAY BUTTON FUNCTION
	function pbtn:OnMousePressed()

		if selectedLine != nil then

			if args[1] == "private" then

					print(selectedLine.kind)

					if selectedLine.kind == "playlist" then

						print("playlist!")

						cl_PPlay.getSoundCloudInfo( selectedLine.url, function(entry)

							cl_PPlay.fillPlaylist( entry.tracks, false )
							cl_PPlay.playPlaylist( false )

						end)

					else

						print("no playlist")
						cl_PPlay.play( selectedLine.url, selectedLine:GetValue(1), "private" )

					end
				
					
				
			elseif args[1] == "server" then

				if selectedLine.kind == "playlist" then

					cl_PPlay.getSoundCloudInfo( selectedLine.url, function(entry)

						cl_PPlay.fillPlaylist( entry.tracks, true )
						timer.Simple(0.1, function()
							cl_PPlay.playPlaylist( true )
						end)

					end)

				else

					cl_PPlay.sendToServer( selectedLine.url, selectedLine:GetValue(1), "play" )

				end

			end

			frm:Close()
			cl_PPlay.UpdateMenus()

		end

	end

end
concommand.Add( "pplay_openMy", cl_PPlay.openMy )


--CUSTOM FRAME
function cl_PPlay.openCustom( ply, cmd, args )

	local strings = {}

	if args[1] == "private" then
		strings = {
			frametitle = "PatchPlay - Private URL Player"
		}
		
	elseif args[1] == "server" then
		strings = {
			frametitle = "PatchPlay - URL Player"
		}
	end

	local w, h = 400, 200

	-- FRAME
	local frm = cl_PPlay.addfrm(w, h, strings["frametitle"], true)

	-- LABEL IN FRAME
	cl_PPlay.addlbl( frm, "Stream URL:", "frame", 15, 30 )

	-- TEXTENTRY IN FRAME
	local te_url = cl_PPlay.addtext( frm, "frame", { 15, 50 }, { w - 30, 22 } )

	-- PLAY BUTTON IN FRAME
	local pbtn = cl_PPlay.addbtn( frm, "Stream", nil, "frame", {w - 115, 82, 100, 20} )

	-- PLAY BUTTON FUNCTION
	function pbtn:OnMousePressed()

		if te_url:GetValue() != "" and te_name != nil and te_name:GetValue() != "" then

				if args[1] == "private" then

					cl_PPlay.play( te_url:GetValue(), te_name:GetValue(), "private" )
					
				elseif args[1] == "server" then

					cl_PPlay.sendToServer( te_url:GetValue(), te_Name:GetValue(), "play" )

				end

		elseif te_url:GetValue() != "" then

				if args[1] == "private" then

					cl_PPlay.play( te_url:GetValue(), "", "private" )
					
				elseif args[1] == "server" then

					cl_PPlay.sendToServer( te_url:GetValue(), "", "play" )

				end

		end
	end

	-- STREAM LABEL
	cl_PPlay.addlbl( frm, "If you want to save the stream to the streamlist, choose a name:", "frame", 15, 112 )

	-- TEXTENTRY IN FRAME
	local te_name = cl_PPlay.addtext( frm, "frame", { 15, 132 }, { w - 30, 22 } )

	-- SAVE BUTTON IN FRAME
	local sabtn = cl_PPlay.addbtn( frm, "Save", nil, "frame", {w - 115, h - 37, 100, 20} )

	-- SAVE BUTTON FUNCTION
	function sabtn:OnMousePressed()

		if te_name:GetValue() != "" and  te_url:GetValue() != "" then

			if args[1] == "private" then

				cl_PPlay.saveNewStream( { name = te_name:GetValue(),  url = te_url:GetValue() .. "?client_id=92373aa73cab62ccf53121163bb1246e", mode = "station" } )
				cl_PPlay.getStreamList()
				
			elseif args[1] == "server" then

				cl_PPlay.saveNewServerStream(te_url:GetValue(), te_name:GetValue(), "station")
				
			end

			cl_PPlay.showNotify( "Successfully saved!", "info", 5)

			frm:Close()
			cl_PPlay.UpdateMenus()

		elseif te_url:GetValue() == "" then
			cl_PPlay.showNotify( "Not saved! URL is empty!", "error", 5)
		elseif te_name:GetValue() == "" then
			cl_PPlay.showNotify( "Not saved! Name is empty!", "error", 5)
		end
		
	end
end
concommand.Add( "pplay_openCustom", cl_PPlay.openCustom )


--SOUNDCLOUD FRAME
function cl_PPlay.openSoundCloud( ply, cmd, args )

	local strings = {}

	if args[1] == "private" then
		strings = {
			frametitle = "PatchPlay - Private SoundCloud Player"
		}
		
	elseif args[1] == "server" then
		strings = {
			frametitle = "PatchPlay - SoundCloud Player"
		}
	end

	local w, h = 400, 130

	-- FRAME
	local frm = cl_PPlay.addfrm(w, h, strings["frametitle"], true)

	-- LABEL IN FRAME
	cl_PPlay.addlbl( frm, "SoundCloud URL:", "frame", 15, 30 )

	-- TEXTENTRY IN FRAME
	local te_url = cl_PPlay.addtext( frm, "frame", { 15, 50 }, { w - 30, 22 } )

	-- STREAM LABEL
	cl_PPlay.addlbl( frm, "PatchPlay detects the title of the inserted stream!", "frame", 15, 75 )

	-- PLAY BUTTON IN FRAME
	local pbtn = cl_PPlay.addbtn( frm, "Stream", nil, "frame", {w - 115, 95, 100, 20} )

	-- PLAY BUTTON FUNCTION
	function pbtn:OnMousePressed()

		cl_PPlay.getSoundCloudInfo( te_url:GetValue(), function(entry)
			if args[1] == "private" then

					if entry.kind == "track" then

						cl_PPlay.playStream( entry.stream_url, entry.title, false )

					elseif entry.kind == "playlist" then

						cl_PPlay.fillPlaylist( entry.tracks, false )
						cl_PPlay.playPlaylist( false )

					end
				
			elseif args[1] == "server" then

					if entry.kind == "track" then

						cl_PPlay.playStream( entry.stream_url, entry.title, true )

					elseif entry.kind == "playlist" then

						cl_PPlay.fillPlaylist( entry.tracks, true )
						timer.Simple(0.1, function()
							cl_PPlay.playPlaylist( true )
						end)

					end

			end
		end)
		

	end

	-- SAVE BUTTON IN FRAME
	local sabtn = cl_PPlay.addbtn( frm, "Save", nil, "frame", {w - 220, 95, 100, 20} )

	-- SAVE BUTTON FUNCTION
	function sabtn:OnMousePressed()

		if te_url:GetValue() == "" then
			cl_PPlay.showNotify( "Not saved! URL is empty!", "error", 5)
			return
		end

		cl_PPlay.getSoundCloudInfo( te_url:GetValue(), function(entry)
			if args[1] == "private" then

				if entry.kind == "playlist" then

					cl_PPlay.saveNewStream( { name = entry.title,  url = te_url:GetValue() .. "?client_id=92373aa73cab62ccf53121163bb1246e", mode = "playlist" } )

				else

					cl_PPlay.saveNewStream( { name = entry.title,  url = entry.stream_url .. "?client_id=92373aa73cab62ccf53121163bb1246e", mode = "track" } )

				end

					cl_PPlay.getStreamList()
				
			elseif args[1] == "server" then

				if entry.kind == "playlist" then

					cl_PPlay.saveNewServerStream( te_url:GetValue(), entry.title, "playlist" )

				else

					cl_PPlay.saveNewServerStream( entry.stream_url, entry.title, "track" )

				end

			end

			cl_PPlay.showNotify( "Successfully saved!", "info", 5)

			frm:Close()
			cl_PPlay.UpdateMenus()
		end)
		
	end

end
concommand.Add( "pplay_openSoundCloud", cl_PPlay.openSoundCloud )

--PLAYLIST
function cl_PPlay.openPlayList( ply, cmd, args )

	local strings = {}

	if args[1] == "private" then
		strings = {
			frametitle = "PatchPlay - Private Playlist"
		}
		
	elseif args[1] == "server" then
		strings = {
			frametitle = "PatchPlay - Server-Playlist"
		}
	end

	local w, h = 400, 450

	-- FRAME
	local frm = cl_PPlay.addfrm(w, h, strings["frametitle"], true)

	-- LABEL IN FRAME
	cl_PPlay.addlbl( frm, "You can see the current playlist here:", "frame", 15, 30 )

	-- STREAM LIST
	local plv = cl_PPlay.addlv( frm, 15, 50, w - 30, h - 100, {"Name"} )

	function fillPlaylist()
		plv:Clear()
		if args[1] == "private" and cl_PPlay.privatePlaylist != nil then
			cl_PPlay.getPlaylist()
			table.foreach( cl_PPlay.privatePlaylist, function( key, value )

				local line = plv:AddLine( value["name"] )
				line.id = key
				line.url = value["stream"]

			end)
			
		elseif args[1] == "server" and cl_PPlay.serverPlaylist != nil then
			cl_PPlay.getServerPlaylist( )
			table.foreach( cl_PPlay.serverPlaylist, function( key, value )

				local line = plv:AddLine( value["name"] )
				line.id = key
				line.url = value["stream"]

			end)
		end
	end
	
	fillPlaylist()

end
concommand.Add( "pplay_openPlaylist", cl_PPlay.openPlayList)

function cl_PPlay.saveNewServerStream( stream, text, streamtype )
	local newStream = {
		name = text,
		url = stream .. "?client_id=92373aa73cab62ccf53121163bb1246e", --Adding the client ID
		mode = streamtype
	}

	net.Start( "pplay_savestream" )
		net.WriteTable( newStream )
	net.SendToServer()
end