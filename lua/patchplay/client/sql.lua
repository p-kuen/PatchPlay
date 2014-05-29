--------------------
--  SQL SETTINGS  --
--------------------

cl_PPlay.Settings = {}

function cl_PPlay.loadGeneralSettings()

	local function createTable()

		sql.Query( "CREATE TABLE IF NOT EXISTS pplay_settings('name' TEXT, 'value' TEXT);" )

		cl_PPlay.addSetting( "bigNotification", "true" )
		cl_PPlay.addSetting( "nowPlaying", "true" )

		MsgC(
			Color(255, 150, 0),
			"[PatchPlay] Created new Settings-Table\n"
		)

	end

	if sql.TableExists( "pplay_settings" ) then

		local existingsettings = sql.Query( "PRAGMA table_info(pplay_settings);" )

		if existingsettings[2] == nil then
			MsgC(
				Color(255, 0, 0),
				"[PatchPlay] The Settings-structure got updated, so we have to delete the Settings and create a new one. We are sorry for that!\n"
			)

			sql.Query( "DROP TABLE pplay_settings" )

		end

	end

	if !sql.TableExists( "pplay_settings" ) then

		createTable()

	end

	cl_PPlay.getSettings()

end

function cl_PPlay.addSetting( name, value )

	sql.Query( "INSERT INTO pplay_settings( 'name', 'value' ) VALUES( '" .. name .. "', '" .. value .. "')" )

end

function cl_PPlay.getSettings()

	cl_PPlay.Settings.Client = sql.Query("SELECT * FROM pplay_settings")

end

function cl_PPlay.saveSetting( n, v, server, clchange )

	local setting = { name = n, value = v }

	local function send()

		net.Start("pplay_settings")
			net.WriteTable(setting)
		net.SendToServer()

	end

	if !server or clchange then

		sql.Query( "UPDATE pplay_settings SET value = '" .. setting.value .. "' WHERE name = '" .. setting.name .. "';" )
		cl_PPlay.getSettings()

	end

	if server then

		local success = timer.Adjust( "pplay_savedelay", 1, 1, send )

		if !success then timer.Create( "pplay_savedelay", 1, 1, send ) end

	end


end

function cl_PPlay.getSetting( name, server )

	local result = false

	local function search( k, v )

		if v.name == name then
			result = tobool(v.value)
		end

	end

	if server then
		table.foreach(cl_PPlay.Settings.Server, search)
	else
		table.foreach(cl_PPlay.Settings.Client, search)
	end

	return result

end

net.Receive( "pplay_sendsettings", function( len, pl )

	cl_PPlay.Settings.Server = net.ReadTable()
	PrintTable(cl_PPlay.Settings.Server)

end )

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

cl_PPlay.loadGeneralSettings()
cl_PPlay.loadStreamSettings( )
cl_PPlay.loadPlaylistSettings( )

MsgC(
	Color(255, 150, 0),
	"\n[PatchPlay] Successfully loaded!\n\n"
)





