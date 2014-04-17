-------------------------------
--  LOAD/WRITE SQL SETTINGS  --
-------------------------------

-- ANTISPAM AND PROP PROTECTION
function sv_PPlay.loadStreamSettings( )

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

function sv_PPlay.saveNewStream( name, url )

	sql.Query( "INSERT INTO pplay_streamlist( 'name', 'stream' ) VALUES( '" .. name .. "', '" .. url .. "')" )

end

function sv_PPlay.deleteStream( where )

	sql.Query( "DELETE FROM pplay_streamlist WHERE stream = '" .. where .. "'" )

end

function sv_PPlay.sendStreamList( ply )

	net.Start("pplay_sendstreamlist")
        net.WriteTable( sql.Query("SELECT * FROM pplay_streamlist") )
    if ply != nil then
    	net.Send( ply )
    else
    	net.Broadcast()
    end

end

sv_PPlay.loadStreamSettings( )

MsgC(
	Color(255, 150, 0),
	"\n[PatchPlay] Successfully loaded!\n\n"
)

function sv_PPlay.firstspawn( ply )

	sv_PPlay.sendStreamList( ply )

end
hook.Add( "PlayerInitialSpawn", "pplay_firstspawn", sv_PPlay.firstspawn )

net.Receive("pplay_deletestream", function( len, pl )

	sv_PPlay.deleteStream( net.ReadString() )

	sv_PPlay.sendStreamList( )


end)

net.Receive("pplay_savestream", function( len, pl )

	local newStream = net.ReadTable()

	sv_PPlay.saveNewStream( newStream["name"], newStream["url"] )

	sv_PPlay.sendStreamList( )


end)
