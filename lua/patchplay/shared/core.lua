--------------
-- SETTINGS --
--------------

function sh_PPlay.addSetting( name, value )

	sql.Query( "INSERT INTO pplay_settings( 'name', 'value' ) VALUES( '" .. name .. "', '" .. value .. "')" )

end

-----------------
-- STREAM LIST --
-----------------

sh_PPlay.stream = {}

function sh_PPlay.stream.new( info, kind, saveToServer )

	if !SERVER and saveToServer then

		local newStream = {
			name = name,
			url = url,
			kind = kind
		}

		cl_PPlay.sendToServer( "stream_save", newStream )
		return

	end

	sql.Query( "INSERT INTO pplay_streamlist( 'info', 'kind' ) VALUES( '" .. info .. "', '".. kind .."')" )

end

function sh_PPlay.stream.remove( url, doOnServer )

	if !SERVER and doOnServer then
		cl_PPlay.sendToServer( "stream_remove", selectedLine.url )
		return
	end

	sql.Query( "DELETE FROM pplay_streamlist WHERE stream = '" .. url .. "'" )

end

--------------
-- PLAYLIST --
--------------

sh_PPlay.playlist = {}

function sh_PPlay.playlist.add( info, doOnServer )

	if doOnServer then

		cl_PPlay.sendToServer( "playlist_add", info )

	else
		
		sh_PPlay.insertRow( "pplay_playlist", info )

	end

end

function sh_PPlay.playlist.remove( url )

	sql.Query( "DELETE FROM pplay_playlist WHERE url = '" .. url .. "'" )

end

function sh_PPlay.playlist.clear()

	sql.Query( "DELETE FROM pplay_playlist" )

end
