-------------------------------
--  LOAD/WRITE SQL SETTINGS  --
-------------------------------

-- ANTISPAM AND PROP PROTECTION
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

function cl_PPlay.saveNewStream( name, url )

	sql.Query( "INSERT INTO pplay_privatestreamlist( 'name', 'stream' ) VALUES( '" .. name .. "', '" .. url .. "')" )

end

function cl_PPlay.deleteStream( where )

	sql.Query( "DELETE FROM pplay_privatestreamlist WHERE stream = '" .. where .. "'" )

end

function cl_PPlay.getStreamList()

	cl_PPlay.privateStreamList = sql.Query("SELECT * FROM pplay_privatestreamlist")

end

cl_PPlay.loadStreamSettings( )

MsgC(
	Color(255, 150, 0),
	"\n[PatchPlay] Successfully loaded!\n\n"
)
