--------------------
--  SQL SETTINGS  --
--------------------

-----------------
-- STREAM LIST --
-----------------
function cl_PPlay.loadStreamSettings( )

	--sql.Query( "DROP TABLE pplay_privatestreamlist" )

	local function createTable()

		sql.Query( "CREATE TABLE IF NOT EXISTS pplay_privatestreamlist('name' TEXT, 'stream' TEXT, 'kind' TEXT);" )

		cl_PPlay.saveNewStream( { name = "Rock - 181.fm - Rock 181 (Active Rock)", url = "http://dir.xiph.org/listen/674163/listen.m3u", mode = "station" } )
		cl_PPlay.saveNewStream( { name = "Dubstep - R1 Dubstep", url = "http://dir-xiph.osuosl.org/listen/364996/listen.m3u", mode = "station" } )
		cl_PPlay.saveNewStream( { name = "Dance - Fusion Radio", url = "http://dir-xiph.osuosl.org/listen/349400/listen.m3u", mode = "station" } )
		cl_PPlay.saveNewStream( { name = "House - ClubbingStation", url = "http://dir-xiph.osuosl.org/listen/573471/listen.m3u", mode = "station" } )

		MsgC(
			Color(255, 150, 0),
			"[PatchPlay] Created new private Streamlist-Table\n"
		)

	end

	if sql.TableExists( "pplay_privatestreamlist" ) then

		local existingstreamlist = sql.Query( "PRAGMA table_info(pplay_privatestreamlist);" )

		if existingstreamlist[3] == nil then
			MsgC(
				Color(255, 0, 0),
				"[PatchPlay] The Streamlist-structure got updated, so we have to delete the Streamlist and create a new one. We are sorry for that!\n"
			)

			sql.Query( "DROP TABLE pplay_privatestreamlist" )

		end

	end

	if !sql.TableExists( "pplay_privatestreamlist" ) then

		createTable()

	end

	cl_PPlay.getStreamList()
	
end

function cl_PPlay.saveNewStream( stream )

	sql.Query( "INSERT INTO pplay_privatestreamlist( 'name', 'stream', 'kind' ) VALUES( '" .. stream[ "name" ] .. "', '" .. stream[ "url" ] .. "', '".. stream[ "mode" ] .."')" )

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
