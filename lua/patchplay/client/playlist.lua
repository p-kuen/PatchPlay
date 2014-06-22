--------------
-- PLAYLIST --
--------------

cl_PPlay.playlistPos = {}
cl_PPlay.playlistPos.client = 0
cl_PPlay.playlistPos.server = 0

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

		cl_PPlay.sendToServer( "playlist_clear" )

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

function cl_PPlay.deleteFromServerPlaylist( stream )

	cl_PPlay.sendToServer( "playlist_remove", stream)

end

function cl_PPlay.getServerPlaylist( )

	cl_PPlay.sendToServer( "playlist_get" )

end

net.Receive( "pplay_sendplaylist", function( len, pl )

	cl_PPlay.playList.server = net.ReadTable()

end )

function cl_PPlay.playlistCheck()

	if cl_PPlay.isMusicPlaying() and cl_PPlay.cStream.playlist and !cl_PPlay.cStream.server and cl_PPlay.cStream.station:GetTime() >= (cl_PPlay.cStream.station:GetLength() - 5) then

		if table.Count(cl_PPlay.currentPlaylist) <= cl_PPlay.playlistPos.client then return end

		cl_PPlay.playlistPos.client = cl_PPlay.playlistPos.client + 1

		cl_PPlay.playStream( cl_PPlay.currentPlaylist[ cl_PPlay.playlistPos.client ].info, false, 2 )

	end

end
hook.Add( "Think", "pplay_playlistcheck", cl_PPlay.playlistCheck )