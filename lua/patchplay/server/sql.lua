--------------------
--  SQL SETTINGS  --
--------------------

function sv_PPlay.changeSetting( len, pl )

	local setting = net.ReadTable()

	sql.Query( "UPDATE pplay_settings SET value = '" .. setting.value .. "' WHERE name = '" .. setting.name .. "';" )
	sv_PPlay.getSettings()

	print(pl:Nick() .. " changed " .. setting.name .. " to " .. setting.value .. "!")

end

function sv_PPlay.getSettings( ply )

	sv_PPlay.Settings = sql.Query("SELECT * FROM pplay_settings")

	net.Start("pplay_sendsettings")
		net.WriteTable( sv_PPlay.Settings )
	if ply != nil then net.Send( ply ) else net.Broadcast() end

end

-----------------
-- STREAM LIST --
-----------------

function sv_PPlay.sendStreamList( ply )

	net.Start("pplay_sendstreamlist")
		net.WriteTable( sql.Query("SELECT * FROM pplay_streamlist") )
	if ply != nil then net.Send( ply ) else net.Broadcast() end

end

function sv_PPlay.firstspawn( ply )

	sv_PPlay.sendStreamList( ply )
	sv_PPlay.getSettings( ply )

end
hook.Add( "PlayerInitialSpawn", "pplay_firstspawn", sv_PPlay.firstspawn )

--------------
-- PLAYLIST --
--------------

function sv_PPlay.sendPlayList( len, pl )

	net.Start("pplay_sendplaylist")
		net.WriteTable( sql.Query("SELECT * FROM pplay_playlist") )
	if pl != nil then net.Send( pl ) else net.Broadcast() end

end

sh_PPlay.load.general()
sh_PPlay.load.streamlist()
sh_PPlay.load.playlistnames()
sh_PPlay.load.playlist()

MsgC(
	Color(255, 150, 0),
	"\n[PatchPlay] Successfully loaded!\n\n"
)