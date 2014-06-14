cl_PPlay.browser = {}

cl_PPlay.browser.currentBrowse = {

	url = "",
	stage = 0,
	args = {}

}

cl_PPlay.browser.history = {}

cl_PPlay.BrowseURL = {

	dirble = { 

	"primaryCategories/apikey/" .. cl_PPlay.APIKeys.dirble,
	"childCategories/apikey/" .. cl_PPlay.APIKeys.dirble .. "/primaryid/[id]",
	"stations/apikey/" .. cl_PPlay.APIKeys.dirble .. "/id/[id]",
	"station/apikey/" .. cl_PPlay.APIKeys.dirble .. "/id/[id]"

	},

	soundcloud = {

		search = "tracks.json?client_id=" .. cl_PPlay.APIKeys.soundcloud .. "&q=[searchquery]"

	}

}

function cl_PPlay.browse( info, back )

	local serverbool = false
	if info.mode == "server" then serverbool = true end
	if back == nil then back = false end

	if !back and info.directurl != nil and info.directurl:GetValue() != "" then

		cl_PPlay.playStream( info.directurl:GetValue(), "", serverbool )
		return

	end

	info.browse.url = ""

	if info.browse.stage == nil then info.browse.stage = 0 end

	local add = 0
	if back and info.browse.stage > 1 then add = -1 elseif !back and info.browse.stage < table.Count( cl_PPlay.BrowseURL.dirble) then add = 1 end
	info.browse.stage = info.browse.stage + add

	if back then

		info.browse.url = info.browse.history[info.browse.stage] -- Load url from the history

	else

		info.browse.url = cl_PPlay.BrowseURL.dirble[info.browse.stage]
		if string.find( info.browse.url, "%[(%w+)%]" ) then

			info.browse.url = string.gsub( info.browse.url, "%[(%w+)%]", info.selectedLine.id )

		end

		info.browse.url = "http://api.dirble.com/v1/" .. info.browse.url .. "/format/json"

		info.browse.history[info.browse.stage] = info.browse.url

	end

	cl_PPlay.getJSONInfo( info.browse.url, function(entry)

		if !back and info.browse.stage == table.Count( cl_PPlay.BrowseURL.dirble ) then

			cl_PPlay.playStream( entry.streamurl, entry.name, serverbool )
			return
		
		end

		info.browse.target:Clear()

		table.foreach(entry, function( key, value )

			local line = info.browse.target:AddLine( value.name )

			line.id = value.id

		end)

		info.selectedLine = nil

	end)



end

function cl_PPlay.browseBack( info )

	cl_PPlay.browse( info, true )

end

function cl_PPlay.search( info )

	local rawURL = "http://api.soundcloud.com/" .. cl_PPlay.BrowseURL.soundcloud.search
	local newURL = string.gsub( rawURL, "%[(%w+)%]", string.lower(info.search.searchField:GetValue()) )
	newURL = string.gsub( newURL, "%s", "%%20" ) --Replace spaces with the %20 character

	local fails = 0
	cl_PPlay.getJSONInfo( newURL, function(entry)

		info.search.target:Clear()

		table.foreach(entry, function(key, track)

			if track.streamable then

				local line = info.search.target:AddLine( track.title )
				line.name = track.title
				line.streamurl = track.stream_url .. "?client_id=" .. cl_PPlay.APIKeys.soundcloud

			else

				fails = fails + 1
				if info.fails != nil then info.fails:SetText("Tracks, which cannot be played: " .. fails) end

			end

		end)

	end)

end

function cl_PPlay.searchplay( info )

	if info.directurl != nil and info.directurl:GetValue() != "" then

		cl_PPlay.getJSONInfo( info.directurl:GetValue(), function(entry)
			if info.mode == "private" then

					if entry.kind == "track" then

						cl_PPlay.playStream( entry.stream_url, entry.title, false )

					elseif entry.kind == "playlist" then

						cl_PPlay.fillPlaylist( entry.tracks, false )
						cl_PPlay.playPlaylist( false )

					end
				
			elseif info.mode == "server" then

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
		return

	end

	if info.selectedLine.streamurl == nil or info.selectedLine.name == nil then return end

	local serverbool = false
	if info.mode == "server" then serverbool = true end

	cl_PPlay.playStream( info.selectedLine.streamurl, info.selectedLine.name, serverbool )

end

function cl_PPlay.addtomy( list )

	local stream = {}

	if list.directurl:GetValue() != "" then

		if list.type == "station" then

			local w, h = ScrW() / 6, ScrH() / 10

			local frm = cl_PPlay.addfrm( w, h, "Save DirectURL", true)
			local txt_name = cl_PPlay.addtext( frm, "Enter a name for the station:", "frame", { 15, 30 }, { w - 30, 18} )

			cl_PPlay.addbtn( frm, "Save", function()

				if list.mode == "server" then
					cl_PPlay.saveNewStream( list.directurl:GetValue(), txt_name:GetValue(), list.type, true )
				else
					cl_PPlay.saveNewStream( list.directurl:GetValue(), txt_name:GetValue(), list.type )
					cl_PPlay.getStreamList()
				end

				frm:Close()

			end, "function", { w - 115, h - 35, 100, 20, list} )

		elseif list.type == "track" then

			cl_PPlay.getJSONInfo( list.directurl:GetValue(), function(entry)
				if list.mode == "private" then

					if entry.kind == "playlist" then

						cl_PPlay.saveNewStream( list.directurl:GetValue() .. "?client_id=" .. cl_PPlay.APIKeys.soundcloud, entry.title, "playlist" )

					else

						cl_PPlay.saveNewStream( entry.stream_url .. "?client_id=" .. cl_PPlay.APIKeys.soundcloud, entry.title, "track" )

					end

						cl_PPlay.getStreamList()
					
				elseif list.mode == "server" then

					if entry.kind == "playlist" then

						cl_PPlay.saveNewStream( list.directurl:GetValue()  .. "?client_id=" .. cl_PPlay.APIKeys.soundcloud, entry.title, "playlist", true )

					else

						cl_PPlay.saveNewStream( entry.stream_url .. "?client_id=" .. cl_PPlay.APIKeys.soundcloud, entry.title, "track", true )

					end

				end

				cl_PPlay.UpdateMenus()
			end)

		end

		return
	end

	if list.type == "station" then

		stream = cl_PPlay.browser.currentBrowse.args

	elseif list.type == "track" then

		stream = list.selected

	end

	if table.Count(stream) == 0 then return end

	if list.mode == "server" then

		cl_PPlay.saveNewStream(stream.streamurl, stream.name, list.type, true)

	else

		cl_PPlay.saveNewStream( stream.streamurl, stream.name, list.type )
		cl_PPlay.getStreamList()

	end

end