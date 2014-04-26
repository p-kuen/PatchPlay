--------------------
--  SQL SETTINGS  --
--------------------

-----------------
-- STREAM LIST --
-----------------
function cl_PPlay.loadStreamSettings( )

	--sql.Query( "DROP TABLE pplay_privatestreamlist" )

	if !sql.TableExists( "pplay_privatestreamlist" ) then

		sql.Query( "CREATE TABLE IF NOT EXISTS pplay_privatestreamlist('name' TEXT, 'stream' TEXT);" )

		cl_PPlay.saveNewStream( "HouseTimeFM", "http://mp3.stream.tb-group.fm/ht.mp3?" )
		cl_PPlay.saveNewStream( "TechnoBaseFM", "http://mp3.stream.tb-group.fm/tb.mp3?" )
		cl_PPlay.saveNewStream( "HardBaseFM", "http://mp3.stream.tb-group.fm/hb.mp3?" )
		cl_PPlay.saveNewStream( "CoreBaseFM", "http://mp3.stream.tb-group.fm/ct.mp3?" )
		
		MsgC(
			Color(255, 150, 0),
			"[PatchPlay] Created new private Streamlist-Table\n"
		)

	end
	
end

function cl_PPlay.saveNewStream( url, name )

	sql.Query( "INSERT INTO pplay_privatestreamlist( 'name', 'stream' ) VALUES( '" .. name .. "', '" .. url .."?client_id=92373aa73cab62ccf53121163bb1246e" .. "')" )

end

function cl_PPlay.deleteStream( where )

	sql.Query( "DELETE FROM pplay_privatestreamlist WHERE stream = '" .. where .. "'" )

end

function cl_PPlay.getStreamList()

	cl_PPlay.privateStreamList = sql.Query("SELECT * FROM pplay_privatestreamlist")

end

--------------
-- PLAYLIST --
--------------

function cl_PPlay.loadPlaylistSettings( )

	--sql.Query( "DROP TABLE pplay_privatestreamlist" )

	if !sql.TableExists( "pplay_privateplaylist" ) then

		sql.Query( "CREATE TABLE IF NOT EXISTS pplay_privateplaylist('name' TEXT, 'stream' TEXT);" )
		
		MsgC(
			Color(255, 150, 0),
			"[PatchPlay] Created new private PlayList-Table\n"
		)

	end
	
end

function cl_PPlay.addToPlaylist( url, name )

	sql.Query( "INSERT INTO pplay_privateplaylist( 'name', 'stream' ) VALUES( '" .. name .. "', '" .. url --[[.."?client_id=92373aa73cab62ccf53121163bb1246e"]] .. "')" )

end

function cl_PPlay.removeFromPlaylist( where )

	sql.Query( "DELETE FROM pplay_privateplaylist WHERE stream = '" .. where .. "'" )

end

function cl_PPlay.clearPlaylist( )

	sql.Query( "DELETE FROM pplay_privateplaylist" )

end

function cl_PPlay.getPlaylist()

	cl_PPlay.privatePlaylist = sql.Query("SELECT * FROM pplay_privateplaylist")

end

cl_PPlay.loadStreamSettings( )
cl_PPlay.loadPlaylistSettings( )

MsgC(
	Color(255, 150, 0),
	"\n[PatchPlay] Successfully loaded!\n\n"
)
