--------------------
--  SQL SETTINGS  --
--------------------

-----------------
-- STREAM LIST --
-----------------
function sv_PPlay.loadStreamSettings()

	local function createTable()

		sql.Query( "CREATE TABLE IF NOT EXISTS pplay_streamlist('name' TEXT, 'stream' TEXT, 'kind' TEXT);" )

		sv_PPlay.saveNewStream( { name = "Rock - 181.fm - Rock 181 (Active Rock)", url = "http://dir.xiph.org/listen/674163/listen.m3u", mode = "station" } )
		sv_PPlay.saveNewStream( { name = "Dubstep - R1 Dubstep", url = "http://dir-xiph.osuosl.org/listen/364996/listen.m3u", mode = "station" } )
		sv_PPlay.saveNewStream( { name = "Dance - Fusion Radio", url = "http://dir-xiph.osuosl.org/listen/349400/listen.m3u", mode = "station" } )
		sv_PPlay.saveNewStream( { name = "House - ClubbingStation", url = "http://dir-xiph.osuosl.org/listen/573471/listen.m3u", mode = "station" } )
		
		MsgC(
			Color(255, 150, 0),
			"[PatchPlay] Created new Streamlist-Table\n"
		)

	end

	if sql.TableExists( "pplay_streamlist" ) then

		local existingstreamlist = sql.Query( "PRAGMA table_info(pplay_streamlist);" )

		if existingstreamlist[3] == nil then
			MsgC(
				Color(255, 0, 0),
				"[PatchPlay] The Streamlist-structure got updated, so we have to delete the Streamlist and create a new one. We are sorry for that!\n"
			)

			sql.Query( "DROP TABLE pplay_streamlist" )

		end

	end

	if !sql.TableExists( "pplay_streamlist" ) then

		createTable()

	end
	
end

function sv_PPlay.sendStreamList( ply )

	net.Start("pplay_sendstreamlist")
		net.WriteTable( sql.Query("SELECT * FROM pplay_streamlist") )
	if ply != nil then net.Send( ply ) else net.Broadcast() end

end

function sv_PPlay.saveNewStream( stream )

	sql.Query( "INSERT INTO pplay_streamlist( 'name', 'stream', 'kind' ) VALUES( '" .. stream[ "name" ] .. "', '" .. stream[ "url" ] .. "', '".. stream[ "mode" ] .."')" )
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

	sv_PPlay.saveNewStream( net.ReadTable() )
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