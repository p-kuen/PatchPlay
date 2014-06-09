--------------------
--  SQL SETTINGS  --
--------------------

cl_PPlay.Settings = {}

local function createTable( name, values, cb)

	local function create()

		local v = "'" .. table.concat( values, "' TEXT, '") .. "' TEXT"

		sql.Query( "CREATE TABLE IF NOT EXISTS " .. name .. "(" .. v .. ");" )

		MsgC(
			Color(0, 255, 0),
			"[PatchPlay] Created new table: " .. name .. "\n"
		)

		cb()

	end

	if !sql.TableExists( name ) then

		create()

	else

		local existingsettings = sql.Query( "PRAGMA table_info(" .. name .. ");" )

		if existingsettings[#values] == nil then
			MsgC(
				Color(255, 0, 0),
				"[PatchPlay] The table-structure of " .. name .. " is outdated! Recreating table now...\n"
			)

			sql.Query( "DROP TABLE " .. name )
			create()

		end

	end

end

function cl_PPlay.loadGeneralSettings()

	createTable( "pplay_settings", {"name", "value"}, function()

		cl_PPlay.addSetting( "bigNotification", "true" )
		cl_PPlay.addSetting( "nowPlaying", "true" )

	end)

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

end )

-----------------
-- STREAM LIST --
-----------------
function cl_PPlay.loadStreamSettings( )

	createTable( "pplay_privatestreamlist", {"name", "stream", "kind"}, function()

		cl_PPlay.saveNewStream( "http://dir.xiph.org/listen/674163/listen.m3u", "Rock - 181.fm - Rock 181 (Active Rock)", "station" )
		cl_PPlay.saveNewStream( "http://dir-xiph.osuosl.org/listen/364996/listen.m3u", "Dubstep - R1 Dubstep", "station" )
		cl_PPlay.saveNewStream( "http://dir-xiph.osuosl.org/listen/349400/listen.m3u", "Dance - Fusion Radio", "station" )
		cl_PPlay.saveNewStream( "http://dir-xiph.osuosl.org/listen/573471/listen.m3u", "House - ClubbingStation", "station" )

	end)

	cl_PPlay.getStreamList()
	
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

	createTable( "pplay_privateplaylist", {"name", "stream"}, function()

	end)
	
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





