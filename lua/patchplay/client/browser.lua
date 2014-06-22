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

	},

	youtube = {

		search = "search?part=snippet&q=[searchquery]&key=" .. cl_PPlay.APIKeys.youtube,
		player = "http://jwpsrv.com/library/9vZUqPWKEeO3lyIACtqXBA.js"

	}

}

function cl_PPlay.browse( info, back )

	local serverbool = false
	if info.mode == "server" then serverbool = true end
	if back == nil then back = false end

	if !back and info.directurl != nil and info.directurl:GetValue() != "" then

		local streaminfo = {

			streamurl = info.directurl:GetValue(),
			title = ""

		}

		cl_PPlay.playStream( streaminfo, serverbool )
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

			local streaminfo = {

				title = entry.name,
				streamurl = entry.streamurl

			}

			cl_PPlay.playStream( streaminfo, serverbool )
			return
		
		end

		info.browse.target:Clear()

		table.foreach(entry, function( key, value )

			local line = info.browse.target:AddLine( value.name )

			line.info = {

				id = value.id

			}

		end)

		info.selectedLine = nil

	end)



end

function cl_PPlay.browseBack( info )

	cl_PPlay.browse( info, true )

end

function cl_PPlay.search( info )

	local rawURL

	if info.kind == "youtube" then

		rawURL = "https://www.googleapis.com/youtube/v3/" .. cl_PPlay.BrowseURL.youtube.search

	elseif info.kind == "soundcloud" then

		rawURL = "http://api.soundcloud.com/" .. cl_PPlay.BrowseURL.soundcloud.search

	end

	local newURL = string.gsub( rawURL, "%[(%w+)%]", string.lower(info.search.searchField:GetValue()) )
	newURL = string.gsub( newURL, "%s", "%%20" ) --Replace spaces with the %20 character

	local fails = 0
	cl_PPlay.getJSONInfo( newURL, function(entry)

		info.search.target:Clear()

		local src

		if info.kind == "youtube" then src = entry.items else src = entry end

		table.foreach(src, function(key, track)

			if info.kind == "soundcloud" then

				if track.streamable then

					local line = info.search.target:AddLine( track.title )
					line.info = {

						title = track.title,
						streamurl = track.stream_url,
						id = track.id,
						duration = track.duration,
						format = track.original_format

					}
		
					--[[
					line.name = track.title
					line.streamurl = track.stream_url .. "?client_id=" .. cl_PPlay.APIKeys.soundcloud
					]]

				else

					fails = fails + 1
					if info.fails != nil then info.fails:SetText("Tracks, which cannot be played: " .. fails) end

				end

			else

				local line = info.search.target:AddLine( track.snippet.title )

			end

		end)
		
	end)

end

function cl_PPlay.searchplay( info )

	if info.directurl != nil and info.directurl:GetValue() != "" then

		cl_PPlay.getJSONInfo( info.directurl:GetValue(), function(entry)

			local streaminfo = {

				title = entry.title,
				streamurl = entry.stream_url,
				duration = entry.duration

			}

			if info.mode == "private" then

					if entry.kind == "track" then

						cl_PPlay.playStream( streaminfo, false )

					elseif entry.kind == "playlist" then

						cl_PPlay.fillPlaylist( entry.tracks, false )
						cl_PPlay.playPlaylist( false )

					end
				
			elseif info.mode == "server" then

					if entry.kind == "track" then

						cl_PPlay.playStream( streaminfo, true )

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

	if info.selectedLine == nil then return end

	local serverbool = false
	if info.mode == "server" then serverbool = true end

	cl_PPlay.playStream( info.selectedLine, serverbool )

end

function cl_PPlay.addtomy( info )

	local serverbool = false
	if info.mode == "server" then serverbool = true end

	if info.directurl != nil and info.directurl:GetValue() != "" then

		if info.kind == "soundcloud" then

			cl_PPlay.getJSONInfo( info.directurl:GetValue(), function(entry)

				local streaminfo = {}
				streaminfo.title = entry.title
				streaminfo.streamurl = entry.stream_url
				streaminfo.duration = entry.duration

				sh_PPlay.insertRow( serverbool, "pplay_streamlist", streaminfo, "track" )
				--sh_PPlay.stream.new( entry.stream_url, entry.title, "tracks", serverbool )

			end)

		else

			local w, h = ScrW() / 6, ScrH() / 10

			local frm = cl_PPlay.addfrm( w, h, "Save A Station", true)
			local txt_name = cl_PPlay.addtext( frm, "Enter a name for the station:", "frame", { 15, 30 }, { w - 30, 18} )
			

			cl_PPlay.addbtn( frm, "Save", function()

				local streaminfo = {}
				streaminfo.title = txt_name:GetValue()
				streaminfo.streamurl = info.directurl:GetValue()

				sh_PPlay.insertRow( serverbool, "pplay_streamlist", streaminfo, "station" )

				frm:Close()

			end, { w - 115, h - 35 }, { 100, 20 }, info )

		end

		return

	end

	if info.selectedLine == nil then return end
	if info.kind == "soundcloud" then

		sh_PPlay.insertRow( serverbool, "pplay_streamlist", info.selectedLine, "track" )

		--sh_PPlay.stream.new( info.selectedLine.streamurl, info.selectedLine.name, "track", serverbool )

	else

		local stationURL = cl_PPlay.BrowseURL.dirble[table.Count(cl_PPlay.BrowseURL.dirble)]
		stationURL = string.gsub( stationURL, "%[(%w+)%]", info.selectedLine.id )
		stationURL = "http://api.dirble.com/v1/" .. stationURL .. "/format/json"

		cl_PPlay.getJSONInfo( stationURL, function(entry)

			local streaminfo = {}
			streaminfo.title = entry.name
			streaminfo.streamurl = entry.streamurl

			sh_PPlay.insertRow( serverbool, "pplay_streamlist", streaminfo, "station" )

		end)

	end

end