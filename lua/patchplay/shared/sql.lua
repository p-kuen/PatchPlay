function sh_PPlay.createTable( name, values, cb, drop )

	if drop == nil then drop = false end

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

		local columns = sql.Query( "PRAGMA table_info(" .. name .. ");" )
		local rows = sql.Query("SELECT * FROM " .. name)

		--Check if the right column names are set in the existing table
		local rightcols = 0
		table.foreach(columns, function(key, col)

			table.foreach(values, function(key, value)

				if col.name == value then
					rightcols = rightcols + 1
				end

			end)

		end)

		if rightcols != #values then drop = true end

		if columns[#values] == nil or drop then

			MsgC(
				Color(255, 0, 0),
				"[PatchPlay] The table-structure of " .. name .. " is outdated! Recreating table now...\n"
			)

			sql.Query( "DROP TABLE " .. name )
			create()

		end

	end

end

sh_PPlay.load = {}

function sh_PPlay.load.general()

	local drop = false

	if sql.TableExists( "pplay_settings" ) then

		local sl = sql.Query("SELECT * FROM pplay_settings")

		if sl != nil then

			if SERVER then
				if sl[7] == nil then drop = true end
			else
				if sl[3] == nil then drop = true end
			end
			

		else

			drop = true

		end

	end

	sh_PPlay.sharedSettings = {
		bigNotification = true,
		nowPlaying = true,
		queue = true
	}

	sh_PPlay.createTable( "pplay_settings", {"name", "value"}, function()

		table.foreach( sh_PPlay.sharedSettings, function( setting, default )
			sh_PPlay.addSetting( tostring(setting), tostring(default) )
		end)

		if SERVER then

			sh_PPlay.addSetting( "globalSettings", "true" )
			sh_PPlay.addSetting( "privateKey", "26" )
			sh_PPlay.addSetting( "serverKey", "25" )
			sh_PPlay.addSetting( "advertTime", "2" )
			
		else

			

		end

	end, drop)

end

function sh_PPlay.load.streamlist()

	local id = 0

	sh_PPlay.createTable( "pplay_streamlist", {"id", "info", "kind"}, function()

		sh_PPlay.insertRow( false, "pplay_streamlist", "|streamurl:http://uk3.internet-radio.com:11131/listen.pls|title:Rock - Champion Radio Uk - Juke Box - Hits From All Eras.|", "station" )
		sh_PPlay.insertRow( false, "pplay_streamlist", "|streamurl:http://s4.radiohost.pl:8154/listen.pls|title:Dubstep - www.radio-tube.pl - Dubstep 247|", "station" )
		sh_PPlay.insertRow( false, "pplay_streamlist", "|streamurl:http://uk3.internet-radio.com:10138/listen.pls|title:Dance - Real Dance Radio|", "station" )
		sh_PPlay.insertRow( false, "pplay_streamlist", "|streamurl:http://188.65.152.205:8500/listen.pls|title:House - Radioseven - www.radioseven.se|", "station" )
		sh_PPlay.insertRow( false, "pplay_streamlist", "|streamurl:http://api.soundcloud.com/tracks/151690373/stream?client_id=92373aa73cab62ccf53121163bb1246e|title:Calvin Harris - Summer (R3hab & Ummet Ozcan Remix)|duration:202598|", "track" )

	end, false)
	
end

function sh_PPlay.load.playlist()

	sh_PPlay.createTable( "pplay_playlist", { "id", "playlist_id", "info"}, function()

		sh_PPlay.insertRow( false, "pplay_playlist", "1", "|streamurl:http://api.soundcloud.com/tracks/151690373/stream?client_id=92373aa73cab62ccf53121163bb1246e|title:Calvin Harris - Summer (R3hab & Ummet Ozcan Remix)|duration:202598|" )

	end, false)
	
end

function sh_PPlay.load.playlistnames()

	sh_PPlay.createTable( "pplay_playlistnames", { "id", "name" }, function()

		--sql.Query( "INSERT INTO pplay_playlistnames( 'playlist_id', 'name' ) VALUES( '1', 'Favourites')" )

		sh_PPlay.insertRow( false, "pplay_playlistnames", "Favourites" )

	end, false)
	
end

function sh_PPlay.getColumns( name )

	local result = {}
	table.foreach(sql.Query( "PRAGMA table_info( " .. name .. " );"), function(key, value)

		result[key] = value.name

	end)

	return result

end

local id = {}
function sh_PPlay.insertRow( onServer, name, ... )

	local values = {...}

	if !SERVER and onServer then
		
		local insert = {}
		insert.tblinfo = {}
		local add = 0
		table.foreach(sql.Query( "PRAGMA table_info( " .. name .. " );"), function(key, value)

			if value.name == "id" then
				add = -1
				return
			end

			insert.tblinfo[ key ] = values[key + add]

		end)

		insert.tblname = name

		cl_PPlay.sendToServer( "addrow", insert )
		return

	end

	local colnames = sh_PPlay.getColumns( name )
	if table.HasValue( colnames, "id" ) then

		local shortName = string.sub(name, 7)

		if id[shortName] == nil then
			local extbl = sql.Query("SELECT * FROM " .. name)

			id[shortName] = table.Count(extbl or {}) + 1
		else
			id[shortName] = id[shortName] + 1
		end

		table.insert( values, 1, id[shortName] )
		values = table.ClearKeys(values)

	end
	
	local multiple = false
	table.foreach(values, function( k, v )

		if type(v) == "table" then

			table.foreach(v, function( field, value ) -- prevent adding songs multiple times

				if field != "streamurl" then return end

				local sql_existing = sql.Query("SELECT info FROM " .. name)
				if sql_existing == nil then return end

				table.foreach( sql_existing, function( sql_k, sql_v )

					table.foreach( sh_PPlay.syntaxToTable(sql_v.info), function( syn_k, syn_v )

						if syn_k == "streamurl" and syn_v == value then

							multiple = true

						end

					end)

				end)		

			end)

			values[k] = sh_PPlay.tableToSyntax( v )

		end

	end)

	if multiple then return end

	if table.Count(values) != table.Count(colnames) then
		print("Not saved! Number of Savevalues is not equal to the number of the needed values!")
		return
	end

	sql.Query( "INSERT INTO " .. name .. "( '" .. table.concat( colnames, "', '") .. "' ) VALUES( '" .. table.concat( values, "', '") .. "')" )

	if !SERVER then

		cl_PPlay.showNotify( "Saved!", "info", 10)

	end

end

function sh_PPlay.changeRow( onServer, name, wherecol, whereval, ... )

	local values = {...}

	if !SERVER and onServer then
		
		local change = {}
		change.values = {}
		table.foreach(sql.Query( "PRAGMA table_info( " .. name .. " );"), function(key, value)

			change.values[ value.name ] = values[key]

		end)

		change.where = {

			wherecol,
			whereval

		}

		cl_PPlay.sendToServer( string.sub(name, 7) .. "_change", change )
		return

	end

	local colnames = sh_PPlay.getColumns( name )

	table.foreach(values, function( k, v )

		if type(v) == "table" then

			values[k] = sh_PPlay.tableToSyntax( v )

		end

	end)

	if table.Count(values) != table.Count(colnames) then
		print("Not saved! Number of Savevalues is not equal to the number of the needed values!")
		return
	end

	local set = ""
	table.foreach( colnames, function( key, col )

		set = set .. colnames[key] .. "='" .. values[key] .. "'"

		if key != #colnames then set = set .. "," end

	end )

	sql.Query( "UPDATE " .. name .. " SET " .. set .. " WHERE " .. wherecol .. "='" .. whereval .. "';" )

	if SERVER and onServer then
		sv_PPlay.getSettings()
	end

end

function sh_PPlay.deleteRow( onServer, name, wherecol, whereval )

	if !SERVER and onServer then
		
		local delete = {}

		delete.where = {

			wherecol,
			whereval

		}
		delete.name = name

		cl_PPlay.sendToServer( "deleterow", delete )
		return

	end

	sql.Query( "DELETE FROM " .. name .. " WHERE " .. wherecol .. "='" .. whereval .. "';" )

end

cl_PPlay.tblFunc = nil
function sh_PPlay.getSQLTable( name, cb, server, ply )

	if server == 2 then

		local package = {}
		package.tblname = name
		package.result = sh_PPlay.clearSyntax( sql.Query("SELECT * FROM " .. name) )

		net.Start( "pplay_sendtable" )

			net.WriteTable( package )
			
		net.Send( ply )

		return

	end

	if server then

		if SERVER then return end

		cl_PPlay.tblFunc = cb
		local info = {}
		info.ply = ply
		info.tblname = name

		cl_PPlay.sendToServer( "sendtable", info )

	else

		local result = sh_PPlay.clearSyntax( sql.Query("SELECT * FROM " .. name) )

		if result == nil then return end
		
		cb( result )

	end

end

function sh_PPlay.tableToSyntax( tbl )

	local string = "|"
	table.foreach( tbl, function( field, val )

		string = string .. field .. ":" .. val .. "|"

	end)
	return string

end

function sh_PPlay.syntaxToTable( syntax )

	local tbl = {}

	local raw = string.Explode( "|", syntax, false )
	table.remove( raw, 1 )
	table.remove( raw, #raw )

	table.foreach( raw, function( key, syn )

		local sep = string.find( syn, ":" )
		local newKey = string.sub( syn, 1, sep - 1 )
		tbl[newKey] = string.sub( syn, sep + 1 )

	end)
	return tbl

end

function sh_PPlay.isSyntax( val )
	
	if type( val ) != "string" then return false end

	if string.find( val, "|" ) and string.find( val, ":" ) and string.find( val, "|", -1 ) then	return true	end

	return false

end

function sh_PPlay.clearSyntax( tbl )

	if tbl == nil then return end

	table.foreach( tbl, function( key, value )

		if sh_PPlay.isSyntax( value ) then

			tbl[key] = sh_PPlay.syntaxToTable( value )

		end

		if type( value ) != "table" then return end

		table.foreach( value, function( k, v )

			if sh_PPlay.isSyntax( v ) then

				value[k] = sh_PPlay.syntaxToTable( v )

			end

		end)

	end)

	return tbl

end