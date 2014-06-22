cl_PPlay.APIKeys = {
	
	dirble = "4fb8ff3c26a13ccbd6fd895ccbf5645845911ce9",
	soundcloud = "92373aa73cab62ccf53121163bb1246e",
	youtube = "AIzaSyA-UvMz6-Y71cz3HK4SH3MOhhZoM_3L4qY"
}

cl_PPlay.streamList = {}
cl_PPlay.playList = {}
cl_PPlay.settings = {}

cl_PPlay.serverTables = {}

cl_PPlay.showLoading = false

function cl_PPlay.getJSONInfo( rawURL, cb )

	cl_PPlay.showLoading = true

	local entry = {}
	local urlType

	local url
	if string.match(rawURL, "api.soundcloud") then

		urlType = "SoundCloud API"
		url = rawURL

	elseif string.match(rawURL, "soundcloud") then

		urlType = "SoundCloud"
		url = "http://api.soundcloud.com/resolve.json?url="..rawURL.."&client_id=92373aa73cab62ccf53121163bb1246e"

	elseif string.match(rawURL, "dirble") then

		urlType = "Dirble"
		url = rawURL

	else

		urlType = "Other"
		url = rawURL

	end

	http.Fetch( url,
		function( body, len, headers, code )
			entry = util.JSONToTable( body )
			if entry == nil then
				cl_PPlay.showNotify( "Unknown error - try again or use another stream!", "error", 10)
				cl_PPlay.showLoading = false
				return
			end

			if urlType == "SoundCloud" then
			
				if !entry.streamable --[[or entry.original_format == "wav"]] then
					cl_PPlay.showNotify( "SoundCloud URL not streamable", "error", 10)
					cl_PPlay.showLoading = false
					return
				end

			end
			cl_PPlay.showLoading = false

			cb(entry)
		end,
		function( error )
			cl_PPlay.showLoading = false
			print("ERROR with fetching!")
		end
	);

end

function cl_PPlay.sendToServer( name, info )

	if name == nil then name = "sendtoserver" end

	net.Start( "pplay_" .. name )

	if type(info) == nil then

		return

	elseif type(info) == "string" then

		net.WriteString( info )

	elseif type(info) == "table" then

		net.WriteTable( info )

	end
		
	net.SendToServer()

end

function cl_PPlay.getPlayList( server )

	if server then

		cl_PPlay.sendToServer( "sendplaylist" )

	else

		cl_PPlay.playList.private = sql.Query("SELECT * FROM pplay_playlist")

	end

end

function cl_PPlay.saveSetting( name, value, server, alsoClient )

	if server == nil then server = false end
	if alsoClient == nil then alsoClient = true end

	sh_PPlay.changeRow( server, "pplay_settings", "name", name, name, tostring(value) )
	
	if server and alsoClient then

		sh_PPlay.changeRow( false, "pplay_settings", "name", name, name, tostring(value) )

	end

	if server then

		cl_PPlay.UpdateMenus()

	else

		sh_PPlay.getSQLTable( "pplay_settings", function( result )

			cl_PPlay.settings.client = result

		end, false, LocalPlayer() )

	end

end

function cl_PPlay.getSetting( name, server )

	local result = false

	if server == nil then server = false end

	if server then

		table.foreach( cl_PPlay.settings.server, function(key, setting)

			if setting.name == name then result = tobool( setting.value ) end

		end )

	else

		table.foreach( cl_PPlay.settings.client, function(key, setting)

			if setting.name == name then result = tobool( setting.value ) end

		end )

	end

	return result

end

--Load the settings
sh_PPlay.getSQLTable( "pplay_settings", function( result )

		cl_PPlay.settings.server = result
		addchecks()

	end, true, LocalPlayer() )

	sh_PPlay.getSQLTable( "pplay_settings", function( result )

		cl_PPlay.settings.client = result

	end, false, LocalPlayer() )

net.Receive( "pplay_broadcast", function( len, pl )

	local info = net.ReadTable()

	if info[1] != nil and info[1] == "stop" then

		if cl_PPlay.cStream.server then
			cl_PPlay.stop()
		end
		cl_PPlay.sStream.playing = false
		cl_PPlay.sStream = {}
		return

	end

	if info.specials == 2 then cl_PPlay.playlistPos.server = cl_PPlay.playlistPos.server + 1 else cl_PPlay.playlistPos.server = 0 end

	cl_PPlay.play( info.info, true, info.specials )

end )

net.Receive( "pplay_sendstreamlist", function( len, pl )

	cl_PPlay.streamList.server = net.ReadTable()

end )

net.Receive( "pplay_sendtable", function( len, pl )

	local package = net.ReadTable()
	if cl_PPlay.tblFunc != nil then

		if package.result != nil then 

			cl_PPlay.tblFunc( package.result )

		end
		cl_PPlay.tblFunc = nil

	else

		local sub = string.sub(package.tblname, 7)
		if cl_PPlay[ sub ] == nil then
			cl_PPlay[ sub ] = {}
		end
		cl_PPlay[ sub ].server = package.result

	end

end )