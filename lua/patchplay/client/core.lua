cl_PPlay.APIKeys = {
	
	dirble = "4fb8ff3c26a13ccbd6fd895ccbf5645845911ce9",
	soundcloud = "92373aa73cab62ccf53121163bb1246e"
}

cl_PPlay.showLoading = false

function cl_PPlay.saveNewStream( url, name, kind, server )

	if server then

		local newStream = {
			name = name,
			url = url,
			kind = kind
		}

		net.Start( "pplay_savestream" )
			net.WriteTable( newStream )
		net.SendToServer()

	else

		sql.Query( "INSERT INTO pplay_privatestreamlist( 'name', 'stream', 'kind' ) VALUES( '" .. name .. "', '" .. url .. "', '".. kind .."')" )

	end

	cl_PPlay.showNotify( "Successfully saved!", "info", 5)

end

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
				cl_PPlay.showNotify( "Unknown error!", "error", 10)
				cl_PPlay.showLoading = false
				return
			end

			if urlType == "SoundCloud" then
			
				if !entry.streamable or entry.original_format == "wav" then
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