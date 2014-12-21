-- GLOBAL VARIABLES
sv_PPlay.currentStream = {}
sv_PPlay.currentPlaylist = {}

-- SENDING FUNCTION
function sv_PPlay.broadcast( stream )

	if type(stream) == "string" then

		stream = { stream }

	end

	net.Start( "pplay_broadcast" )

		net.WriteTable( stream )
		
	net.Broadcast()

end

local playlistPos = 0
function sv_PPlay.nextSong()

	if playlistPos == table.Count(sv_PPlay.currentPlaylist) then return end

	local stream = {}
	playlistPos = playlistPos + 1
	stream.info = sv_PPlay.currentPlaylist[playlistPos].info
	stream.specials = 2

	if timer.Exists( "pplay_playlist_worker" ) then

		timer.Adjust( "pplay_playlist_worker", tonumber(stream.info.duration) / 1000, 1, sv_PPlay.nextSong )

	else

		timer.Create( "pplay_playlist_worker", tonumber(stream.info.duration) / 1000, 1, sv_PPlay.nextSong )

	end

	sv_PPlay.broadcast( stream )

end

----------------
-- NETWORKING --
----------------



-- Player

net.Receive( "pplay_play", function( len, pl )

	local Raw = net.ReadTable()
	local stream = {}
	stream.info = Raw[1]
	stream.specials = Raw[2]

	sv_PPlay.broadcast( stream )

end )

net.Receive( "pplay_stop", function( len, pl )

	sv_PPlay.broadcast( "stop" )

end )

net.Receive( "pplay_playPlaylist", function( len, pl )

	local Raw = net.ReadTable()
	sv_PPlay.currentPlaylist = Raw[1]

	playlistPos = 1
	local stream = {}
	stream.info = sv_PPlay.currentPlaylist[playlistPos].info
	stream.specials = Raw[2]


	timer.Create( "pplay_playlist_worker", tonumber(stream.info.duration) / 1000, 1, sv_PPlay.nextSong )

	sv_PPlay.broadcast( stream )

end )



-- SQL

net.Receive( "pplay_sendstreamlist", function( len, pl )

	sh_PPlay.getSQLTable( "pplay_streamlist", nil, true, nil )

end )

net.Receive( "pplay_sendtable", function( len, pl )

	local info = net.ReadTable()

	sh_PPlay.getSQLTable( info.tblname, nil, 2, info.ply )

end )

net.Receive( "pplay_addrow", function( len, pl )

	local info = net.ReadTable()
	sh_PPlay.insertRow( true, info.tblname, unpack( info.tblinfo ) )

end )

net.Receive( "pplay_deleterow", function( len, pl )

	local info = net.ReadTable()
	sh_PPlay.deleteRow( true, info.name, info.where[1], info.where[2] )

end )

net.Receive( "pplay_playlist_send", sv_PPlay.sendPlayList )

net.Receive( "pplay_stream_save", function( len, pl )

	sh_PPlay.stream.new( net.ReadTable() )
	sv_PPlay.sendStreamList( )

end )

net.Receive( "pplay_settings_change", function( len, pl )

	local setting = net.ReadTable()
	sh_PPlay.changeRow( true, "pplay_settings", setting.where[1], setting.where[2], setting.values.name, setting.values.value )

end )



--AB HIER ALT



net.Receive( "pplay_deletestream", function( len, pl )

	sh_PPlay.deleteStream( net.ReadString() )
	sv_PPlay.sendStreamList( )

end )



net.Receive( "pplay_playlist_remove", function( len, pl )

	sh_PPlay.playlist.remove(  net.ReadString() )

end )

net.Receive( "pplay_clearplaylist", sh_PPlay.playlist.clear )