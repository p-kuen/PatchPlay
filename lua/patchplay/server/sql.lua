--------------------
--  SQL SETTINGS  --
--------------------

-----------------
-- STREAM LIST --
-----------------
function sv_PPlay.loadStreamSettings()

	if !sql.TableExists( "pplay_streamlist" ) then

		sql.Query( "CREATE TABLE IF NOT EXISTS pplay_streamlist('name' TEXT, 'stream' TEXT);" )

		sv_PPlay.saveNewStream( "HouseTimeFM", "http://mp3.stream.tb-group.fm/ht.mp3?" )
		sv_PPlay.saveNewStream( "TechnoBaseFM", "http://mp3.stream.tb-group.fm/tb.mp3?" )
		sv_PPlay.saveNewStream( "HardBaseFM", "http://mp3.stream.tb-group.fm/hb.mp3?" )
		sv_PPlay.saveNewStream( "CoreBaseFM", "http://mp3.stream.tb-group.fm/ct.mp3?" )
		
		MsgC(
			Color(255, 150, 0),
			"[PatchPlay] Created new Streamlist-Table\n"
		)

	end
	
end

function sv_PPlay.sendStreamList( ply )

	net.Start("pplay_sendstreamlist")
		net.WriteTable( sql.Query("SELECT * FROM pplay_streamlist") )
	if ply != nil then net.Send( ply ) else net.Broadcast() end

end

function sv_PPlay.saveNewStream( name, url )

	sql.Query( "INSERT INTO pplay_streamlist( 'name', 'stream' ) VALUES( '" .. name .. "', '" .. url .. "?client_id=92373aa73cab62ccf53121163bb1246e" .. "')" )

end

function sv_PPlay.deleteStream( where )

	sql.Query( "DELETE FROM pplay_streamlist WHERE stream = '" .. where .. "'" )
	sv_PPlay.sendStreamList()

end

function sv_PPlay.firstspawn( ply )

	sv_PPlay.sendStreamList( ply )

end
hook.Add( "PlayerInitialSpawn", "pplay_firstspawn", sv_PPlay.firstspawn )

net.Receive( "pplay_deletestream", function( len, pl )

	sv_PPlay.deleteStream( net.ReadString() )
	sv_PPlay.sendStreamList( )

end )

net.Receive( "pplay_savestream", function( len, pl )

	local newStream = net.ReadTable()
	sv_PPlay.saveNewStream( newStream[ "name" ], newStream[ "url" ] )
	sv_PPlay.sendStreamList( )

end )

--------------
-- PLAYLIST --
--------------

function sv_PPlay.loadPlaylistSettings( )

	--sql.Query( "DROP TABLE pplay_privatestreamlist" )

	if !sql.TableExists( "pplay_playlist" ) then

		sql.Query( "CREATE TABLE IF NOT EXISTS pplay_playlist('name' TEXT, 'stream' TEXT);" )
		
		MsgC(
			Color(255, 150, 0),
			"[PatchPlay] Created new Playlist-Table\n"
		)

	end
	
end

function sv_PPlay.addToPlaylist( url, name )

	sql.Query( "INSERT INTO pplay_playlist( 'name', 'stream' ) VALUES( '" .. name .. "', '" .. url --[[.."?client_id=92373aa73cab62ccf53121163bb1246e"]] .. "')" )

end
net.Receive( "pplay_addtoplaylist", function( pl, len )

	local track = net.ReadTable()

	sv_PPlay.addToPlaylist( track["url"], track["name"] )

end )

function sv_PPlay.removeFromPlaylist( where )

	sql.Query( "DELETE FROM pplay_playlist WHERE stream = '" .. where .. "'" )
	

end
net.Receive( "pplay_removefromplaylist", function( len, pl )

	local where = net.ReadString()
	sv_PPlay.removeFromPlaylist( where )

end )

function sv_PPlay.clearPlaylist( len, pl )

	sql.Query( "DELETE FROM pplay_playlist" )

end
net.Receive( "pplay_clearplaylist", sv_PPlay.clearPlaylist )

function sv_PPlay.sendPlaylist( len, pl )

	local serverplaylist = sql.Query("SELECT * FROM pplay_playlist")

	net.Start("pplay_sendplaylist")
		net.WriteTable( serverplaylist )
	if pl != nil then net.Send( pl ) else net.Broadcast() end

end
net.Receive( "pplay_getplaylist", sv_PPlay.sendPlaylist )


sv_PPlay.loadStreamSettings( )
sv_PPlay.loadPlaylistSettings( )

MsgC(
	Color(255, 150, 0),
	"\n[PatchPlay] Successfully loaded!\n\n"
)