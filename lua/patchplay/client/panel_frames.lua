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

					if selectedLine.kind == "playlist" then

						cl_PPlay.getJSONInfo( selectedLine.url, function(entry)

							cl_PPlay.fillPlaylist( entry.tracks, false )
							cl_PPlay.playPlaylist( false )

						end)

					else

						cl_PPlay.play( selectedLine.url, selectedLine:GetValue(1), "private" )

					end
				
					
				
			elseif args[1] == "server" then

				if selectedLine.kind == "playlist" then

					cl_PPlay.getJSONInfo( selectedLine.url, function(entry)

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

function cl_PPlay.openStationBrowser( ply, cmd, args )

	local strings = {}

	if args[1] == "private" then
		strings = {
			frametitle = "PatchPlay - Private Station Browser powered by Dirble API"
		}
		
	elseif args[1] == "server" then
		strings = {
			frametitle = "PatchPlay - Server Station Browser powered by Dirble API"
		}
	end

	local w = ScrW() / 4
	local h = ScrH() / 3

	local frm = cl_PPlay.addfrm(w, h, strings.frametitle, true)

	local url = "primaryCategories/apikey/" .. cl_PPlay.APIKeys.dirble .. "/format/json"

	local blist = cl_PPlay.addlv( frm, 5, 30, w - 10, h - 70, {"Choose"} )
	blist.mode = args[1]
	blist.type = "station"

	cl_PPlay.resetBrowse()
	cl_PPlay.browse( blist )

	function blist:OnClickLine( line, selected )

		if cl_PPlay.browser.currentBrowse.stage != 3 then

			blist.selected = { id = line.id }

		else

			blist.selected = { id = line.id, streamurl = line.url, name = line.name }

		end
		blist:ClearSelection()
		line:SetSelected( true )

	end

	blist.directurl = cl_PPlay.addtext( frm, "OR enter a Station-URL here:", "frame", { 15, h - 60 }, { w - 30, 15} )

	cl_PPlay.addbtn( frm, "Back", cl_PPlay.browseback, "function", { 15, h - 35, 100, 20, blist} )
	cl_PPlay.addbtn( frm, "Add to My Stations", cl_PPlay.addtomy, "function", { 120, h - 35, 100, 20, blist} )
	cl_PPlay.addbtn( frm, "Browse", cl_PPlay.browse, "function", { w - 115, h - 35, 100, 20, blist} )

end
concommand.Add( "pplay_openStationBrowser", cl_PPlay.openStationBrowser)

function cl_PPlay.openSoundCloudBrowser( ply, cmd, args )

	local strings = {}

	if args[1] == "private" then
		strings = {
			frametitle = "PatchPlay - Private SoundCloud Browser powered by SoundCloud API"
		}
		
	elseif args[1] == "server" then
		strings = {
			frametitle = "PatchPlay - Server SoundCloud Browser powered by SoundCloud API"
		}
	end

	local w = ScrW() / 4
	local h = ScrH() / 3

	local frm = cl_PPlay.addfrm(w, h, strings.frametitle, true)

	local txt_search = cl_PPlay.addtext( frm, "Search: ", "frame", { 15, 30 }, { w - 100, 20} )
	local blist = cl_PPlay.addlv( frm, 5, 55, w - 10, h - 130, {"Choose"} )

	txt_search.target = blist
	txt_search:RequestFocus()
	txt_search.OnEnter = function()

		cl_PPlay.search( txt_search )
		
	end
	
	blist.mode = args[1]
	blist.type = "track"

	function blist:OnClickLine( line, selected )

		blist:ClearSelection()
		blist.selected = line
		line:SetSelected( true )

	end

	blist.directurl = cl_PPlay.addtext( frm, "OR enter a SoundCloud-URL here:", "frame", { 15, h - 60 }, { w - 30, 15} )

	cl_PPlay.addbtn( frm, "Search", cl_PPlay.search, "function", { w - 70, 30, 55, 20, txt_search} )
	cl_PPlay.addbtn( frm, "Add To My Tracks", cl_PPlay.addtomy, "function", { w - 230, h - 35, 100, 20, blist} )
	cl_PPlay.addbtn( frm, "Play", cl_PPlay.searchplay, "function", { w - 115, h - 35, 100, 20, blist} )

end
concommand.Add( "pplay_openSoundCloudBrowser", cl_PPlay.openSoundCloudBrowser)

