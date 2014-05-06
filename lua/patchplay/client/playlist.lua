--------------
-- PLAYLIST --
--------------

function cl_PPlay.playPlaylist( server )

	if server == nil then server = false end

	if server then

		if cl_PPlay.serverPlaylist == nil then
			cl_PPlay.showNotify( "Server playlist is empty!", "error", 10)
			return
		end

		local firstTrack = cl_PPlay.serverPlaylist[1]

		cl_PPlay.playStream( firstTrack["stream"], firstTrack["name"], server, { play_type = 2 } )

	else

		if cl_PPlay.privatePlaylist == nil then
			cl_PPlay.showNotify( "Private playlist is empty!", "error", 10)
			return
		end

		local firstTrack = cl_PPlay.privatePlaylist[1]

		cl_PPlay.playStream( firstTrack["stream"], firstTrack["name"], server, { play_type = 2 } )

	end

end

function cl_PPlay.fillPlaylist( filltable, server )

	if filltable == nil then return end
	if server == nil then server = false end

	if server then

		local added = 0

		cl_PPlay.clearServerPlaylist()

		table.foreach( filltable, function(id, track)

			if track.streamable and track.original_format != "wav" then
				cl_PPlay.addToServerPlaylist( track.stream_url, track.title )
				added = added + 1
			end

		end)
		cl_PPlay.showNotify( "Added " .. added .. " tracks to the server playlist!", "info", 5)

		cl_PPlay.getServerPlaylist()

	else

		local added = 0

		cl_PPlay.clearPlaylist()

		table.foreach( filltable, function(id, track)

			if track.streamable and track.original_format != "wav" then
				cl_PPlay.addToPlaylist( track.stream_url, track.title )
				added = added + 1
			end

		end)
		cl_PPlay.showNotify( "Added " .. added .. " tracks to the playlist!", "info", 5)

		cl_PPlay.getPlaylist()

	end

end

function cl_PPlay.clearServerPlaylist()

	net.Start( "pplay_clearplaylist" )
		net.WriteString( "" )
	net.SendToServer()

end

function cl_PPlay.addToServerPlaylist( stream, streamname )

	local track = {

		url = stream,
		name = streamname
	}

	net.Start( "pplay_addtoplaylist" )
		net.WriteTable( track )
	net.SendToServer()

end

function cl_PPlay.deleteFromServerPlaylist( stream )

	net.Start( "pplay_addtoplaylist" )
		net.WriteString( stream )
	net.SendToServer()

end

function cl_PPlay.getServerPlaylist( )

	net.Start( "pplay_getplaylist" )
		net.WriteString( "" )
	net.SendToServer()

end

net.Receive( "pplay_sendplaylist", function( len, pl )

	cl_PPlay.serverPlaylist = net.ReadTable()

end )