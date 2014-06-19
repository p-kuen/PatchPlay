function cl_PPlay.openMy( args )

	local strings = {}

	local mode = args[1]
	local kind = args[2]
	
	local singleKind = string.sub(kind, 0, -2)

	if mode == "private" then

		strings = {
			frametitle = "PatchPlay - My Private " .. kind:gsub("^%l", string.upper)
		}
		
	elseif mode == "server" then
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
		if mode == "private" then

			table.foreach( cl_PPlay.privateStreamList, function( key, value )

				if value["kind"] == singleKind then

					local line = tlv:AddLine( value["name"] )
					line.url = value["stream"]
					line.kind = value["kind"]

				end

			end)
			
		elseif mode == "server" then

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

	local function delete()

		if selectedLine != nil then

			if mode == "private" then

				cl_PPlay.deleteStream( selectedLine.url )
				cl_PPlay.getStreamList()
				fillList()
				
			elseif mode == "server" then

				net.Start( "pplay_deletestream" )
					net.WriteString( selectedLine.url )
				net.SendToServer()

				timer.Simple(0.1, fillList)

			end
		end

	end

	-- DELETE BUTTON IN FRAME
	local dbtn = cl_PPlay.addbtn( frm, "Delete", delete, { 15, h - 40 }, { 80, 25 } )

	local function play()

		if selectedLine != nil then

			if mode == "private" then

					if selectedLine.kind == "playlist" then

						cl_PPlay.getJSONInfo( selectedLine.url, function(entry)

							cl_PPlay.fillPlaylist( entry.tracks, false )
							cl_PPlay.playPlaylist( false )

						end)

					else

						cl_PPlay.play( selectedLine.url, selectedLine:GetValue(1), "private" )

					end
				
					
				
			elseif mode == "server" then

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

	-- PLAY BUTTON IN FRAME
	local pbtn = cl_PPlay.addbtn( frm, "Play", play, { w - 115, h - 40 }, { 100, 25 } )

end

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

local function enableIfDisabled( button, bool )

	if bool == nil then bool = true end

	if button != nil and button:GetDisabled() and bool then
		button:SetDisabled(false)
		return true
	elseif button == nil then
		return false
	end

end

local function disableIfEnabled( button, bool )

	if bool == nil then bool = true end

	if button != nil and !button:GetDisabled() and bool then
		button:SetDisabled(true)
		return true
	elseif button == nil then
		return false
	end

end

function cl_PPlay.openHTML( args )

	local w = 680
	local h = 470

	local frm = cl_PPlay.addfrm(w, h, "TEST", true)

	local html = cl_PPlay.addhtml( frm )
	html:SetSize( w - 10, h - 25)
	html:SetPos( 5, 25 )

end

function cl_PPlay.openBrowser( args )

	local info = {}
	info.mode = args[1]
	info.kind = args[2]

	local addition
	local offsetY = 0
	if info.kind == "soundcloud" then
		info.type = "track"
		addition = "powered by SoundCloud API"
		offsetY = 30
	elseif info.kind == "station" then
		info.type = "station"
		addition = "powered by Dirble API"
	elseif info.kind == "youtube" then
		info.type = "track"
		addition = " powered by YouTube Data API V3"
	end

	if info.mode == "private" then

		strings = {
			frametitle = "PatchPlay - Private " .. info.kind:gsub("^%l", string.upper) .. " Browser " .. addition
		}
		
	elseif info.mode == "server" then
		strings = {
			frametitle = "PatchPlay - Server " .. info.kind:gsub("^%l", string.upper) .. " Browser " .. addition
		}
	end

	local w = ScrW() / 4
	local h = ScrH() / 3

	local frm = cl_PPlay.addfrm(w, h, strings.frametitle, true)

	--Browser
	local blist = cl_PPlay.addlv( frm, 5, 25 + offsetY, w - 10, h - 140 + 30 - offsetY, {"Choose"} )

	info.directurl = cl_PPlay.addtext( frm, "OR enter a " .. info.kind:gsub("^%l", string.upper) .. "-URL here:", "frame", { 15, h - 60 }, { w - 30, 15 } )

	local pbtn = nil
	local addbtn = nil

	function blist:OnClickLine( line, selected )

		enableIfDisabled( pbtn )
		if info.kind == "soundcloud" or info.kind == "station" and info.browse.stage == table.Count(cl_PPlay.BrowseURL.dirble) - 1 then
			enableIfDisabled( addbtn )
		end

		info.selectedLine = line
		blist:ClearSelection()
		line:SetSelected( true )

	end

	if info.kind == "soundcloud" then

		local txt_search = cl_PPlay.addtext( frm, "Search: ", "frame", { 15, 30 }, { w - 100, 20} )
		txt_search:RequestFocus()

		info.search = {}
		info.search.searchField = txt_search
		info.search.target = blist

		txt_search.OnEnter = function()

			cl_PPlay.search( info )
			
		end

		txt_search.OnTextChanged = function()

			enableIfDisabled( srcbtn, txt_search:GetValue() != "" )
			disableIfEnabled( srcbtn, txt_search:GetValue() == "" )

		end

		info.fails = cl_PPlay.addlbl( frm, "", "frame", 15, h - 90 )

		pbtn = cl_PPlay.addbtn( frm, "Play", cl_PPlay.searchplay, { w - 115, h - 35 }, { 100, 20 }, info )
		pbtn:SetDisabled(true)

		addbtn = cl_PPlay.addbtn( frm, "Add To My Tracks", cl_PPlay.addtomy, { w - 230, h - 35 }, { 100, 20 }, info )
		addbtn:SetDisabled(true)

		srcbtn = cl_PPlay.addbtn( frm, "Search", cl_PPlay.search, { w - 70, 30 }, { 55, 20 }, info )
		srcbtn:SetDisabled(true)
		

	elseif info.kind == "station" then

		info.browse = {}
		info.browse.history = {}
		info.browse.target = blist

		cl_PPlay.browse( info )

		cl_PPlay.addbtn( frm, "Back", cl_PPlay.browseBack, { 15, h - 35 }, { 100, 20 }, info )

		addbtn = cl_PPlay.addbtn( frm, "Add to My Stations", cl_PPlay.addtomy, { 120, h - 35 }, { 100, 20 }, info )
		addbtn:SetDisabled(true)

		cl_PPlay.addbtn( frm, "Browse/Play", cl_PPlay.browse, { w - 115, h - 35 }, { 100, 20 }, info )

	elseif info.kind == "youtube" then

		local txt_search = cl_PPlay.addtext( frm, "Search: ", "frame", { 15, 30 }, { w - 100, 20} )
		txt_search:RequestFocus()

		info.search = {}
		info.search.searchField = txt_search
		info.search.target = blist

		txt_search.OnEnter = function()

			cl_PPlay.search( info )
			
		end

		txt_search.OnTextChanged = function()

			enableIfDisabled( srcbtn, txt_search:GetValue() != "" )
			disableIfEnabled( srcbtn, txt_search:GetValue() == "" )

		end

		info.fails = cl_PPlay.addlbl( frm, "", "frame", 15, h - 90 )

		pbtn = cl_PPlay.addbtn( frm, "Play", cl_PPlay.searchplay, { w - 115, h - 35 }, { 100, 20 }, info )
		pbtn:SetDisabled(true)

		addbtn = cl_PPlay.addbtn( frm, "Add To My Tracks", cl_PPlay.addtomy, { w - 230, h - 35 }, { 100, 20 }, info )
		addbtn:SetDisabled(true)

		srcbtn = cl_PPlay.addbtn( frm, "Search", cl_PPlay.search, { w - 70, 30 }, { 55, 20 }, info )
		srcbtn:SetDisabled(true)

	end

	info.directurl.OnTextChanged = function()

		enableIfDisabled( pbtn, info.directurl:GetValue() != "" )
		enableIfDisabled( addbtn, info.directurl:GetValue() != "" )
		disableIfEnabled( pbtn, info.directurl:GetValue() == "" )
		disableIfEnabled( addbtn, info.directurl:GetValue() == "")

	end

	info.directurl.OnEnter = function()

		if info.kind == "soundcloud" then cl_PPlay.search( info ) else cl_PPlay.browse( info ) end
			
	end

end

