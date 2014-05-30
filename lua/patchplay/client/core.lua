cl_PPlay.APIKeys = {
	
	dirble = "4fb8ff3c26a13ccbd6fd895ccbf5645845911ce9",
	soundcloud = "92373aa73cab62ccf53121163bb1246e"
}

function cl_PPlay.saveNewStream( url, name, kind, server )

	if server then

		local newStream = {
			name = name,
			url = url
			kind = kind
		}

		net.Start( "pplay_savestream" )
			net.WriteTable( newStream )
		net.SendToServer()

	else

		sql.Query( "INSERT INTO pplay_privatestreamlist( 'name', 'stream', 'kind' ) VALUES( '" .. name .. "', '" .. url .. "', '".. kind .."')" )

	end

end