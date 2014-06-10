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
	"stations/apikey/" .. cl_PPlay.APIKeys.dirble .. "/id/[id]"

	},

	soundcloud = {

		search = "tracks.json?client_id=" .. cl_PPlay.APIKeys.soundcloud .. "&q=[searchquery]"

	}

}

function cl_PPlay.resetBrowse()

	cl_PPlay.browser.currentBrowse = {

		url = "",
		stage = 0,
		args = {}
	}

	cl_PPlay.browser.history = {}

end

function cl_PPlay.browse( list )

	if list.directurl != nil and list.directurl:GetValue() != "" then
		if list.mode == "server" then
			cl_PPlay.sendToServer( list.directurl:GetValue(), "", "play" )
		else
			cl_PPlay.play( list.directurl:GetValue(), "", "private" )
		end
		return
	end

	if list.selected != nil and table.Count(list.selected) == 0 and cl_PPlay.browser.currentBrowse.stage != 0 then return end

	if cl_PPlay.browser.currentBrowse.stage == 3 then

		if list.mode == "server" then
			cl_PPlay.sendToServer( list.selected.streamurl, list.selected.name, "play" )
		else
			cl_PPlay.play( list.selected.streamurl, list.selected.name, "private" )
		end
		return

	end

	cl_PPlay.browser.currentBrowse.url = ""

	cl_PPlay.browser.currentBrowse.stage = cl_PPlay.browser.currentBrowse.stage + 1

	local rawURL = cl_PPlay.BrowseURL.dirble[cl_PPlay.browser.currentBrowse.stage]
	local newURL = rawURL
	if list.selected != nil then
		newURL = string.gsub( rawURL, "%[(%w+)%]", list.selected )
	end

	cl_PPlay.browser.currentBrowse.url = "http://api.dirble.com/v1/" .. newURL .. "/format/json"

	table.insert( cl_PPlay.browser.history, cl_PPlay.browser.currentBrowse.url )

	cl_PPlay.getJSONInfo( cl_PPlay.browser.currentBrowse.url, function(entry)

		list:Clear()

		table.foreach(entry, function( key, value )

			if cl_PPlay.browser.currentBrowse.stage == 3 and !cl_PPlay.checkValidURL( value.streamurl ) or value.status == 0 then return end
			

			local line = list:AddLine( value.name )
			if cl_PPlay.browser.currentBrowse.stage == 3 then
				line.url = value.streamurl
				line.name = value.name
			end
			line.id = value.id

		end)

		list.selected = {}


	end)



end

function cl_PPlay.browseback( list )

	if #cl_PPlay.browser.history == 0 then return end

	cl_PPlay.browser.currentBrowse.url = cl_PPlay.browser.history[#cl_PPlay.browser.history - 1]

	cl_PPlay.getJSONInfo( cl_PPlay.browser.currentBrowse.url, function(entry)

		list:Clear()

		table.foreach(entry, function( key, value )

			local line = list:AddLine( value.name )
			line.id = value.id

		end)

	end)

	table.remove( cl_PPlay.browser.history, #cl_PPlay.browser.history )
	cl_PPlay.browser.currentBrowse.stage = cl_PPlay.browser.currentBrowse.stage - 1

end

function cl_PPlay.search( info )

	local rawURL = "http://api.soundcloud.com/" .. cl_PPlay.BrowseURL.soundcloud.search
	local newURL = string.gsub( rawURL, "%[(%w+)%]", string.lower(info.search.searchField:GetValue()) )
	newURL = string.gsub( newURL, "%s", "%%20" ) --Replace spaces with the %20 character

	cl_PPlay.getJSONInfo( newURL, function(entry)

		table.foreach(entry, function(key, track)

			if track.streamable then

				local line = info.search.target:AddLine( track.title )
				line.name = track.title
				line.streamurl = track.stream_url .. "?client_id=" .. cl_PPlay.APIKeys.soundcloud

			end

		end)

	end)

end

function cl_PPlay.searchplay( list )

	if list.directurl != nil and list.directurl != "" then

		cl_PPlay.getJSONInfo( list.directurl:GetValue(), function(entry)
			if list.mode == "private" then

					if entry.kind == "track" then

						cl_PPlay.playStream( entry.stream_url, entry.title, false )

					elseif entry.kind == "playlist" then

						cl_PPlay.fillPlaylist( entry.tracks, false )
						cl_PPlay.playPlaylist( false )

					end
				
			elseif list.mode == "server" then

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

	if !list.selected.streamurl then return end

	if list.mode == "server" then
		cl_PPlay.sendToServer( list.selected.streamurl, list.selected.name, "play" )
	else
		cl_PPlay.play( list.selected.streamurl, list.selected.name, "private" )
	end

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