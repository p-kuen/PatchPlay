-- CLIENT VARIABLES

cl_PPlay.use = true
cl_PPlay.showNowPlaying = true

cl_PPlay.currentStream = {
	stream = "",
	name = "",
	stream_type = "",
}

cl_PPlay.serverStream = {
	stream = "",
	name = "",
	stream_type = "",
	playing = false
}

cl_PPlay.streamList = {}
cl_PPlay.privateStreamList = {}

-- PLAY FUNCTION
function cl_PPlay.play( url, name, mode, switch )

	if mode == "server" and cl_PPlay.currentStream["stream_type"] == "private" and switch == nil or !cl_PPlay.use then return end
	if cl_PPlay.station != nil and cl_PPlay.station:IsValid() then cl_PPlay.station:Stop() end

	sound.PlayURL ( url, "play", function( station )

		if station != nil and station:IsValid() then
			local notify_text
			if name != "" then
				notify_text = name
			else
				notify_text = url
			end

			cl_PPlay.currentStream["stream"] = url
			cl_PPlay.currentStream["name"] = name
			cl_PPlay.currentStream["stream_type"] = mode
			cl_PPlay.showNotify( notify_text, "play", 10)

			cl_PPlay.station = station
		else
			cl_PPlay.showNotify( "INVALID URL!", "error", 10)
		end
		
	end )
	
end

function cl_PPlay.getNameFromURL( url )

	local found = ""

	table.foreach( cl_PPlay.streamList, function(key, value)
		if value["stream"] == url then
			found = value["name"]
		end
	end)

	if found == "" then
		table.foreach( cl_PPlay.privateStreamList, function(key, value)
			if value["stream"] == url then
				found = value["name"]
			end
		end)
	end

	if found == "" then	return url else return found end

end

-- STOP FUNCTOIN
function cl_PPlay.stop( url )

	cl_PPlay.station:Stop()
	cl_PPlay.showNotify( cl_PPlay.getNameFromURL( url ), "stop", 10)
	
end

-- NETWORKING
net.Receive( "pplay_sendstream", function( len, pl )

	local info = net.ReadTable()

	if info[ "command" ] == "stop" then
		cl_PPlay.stop( info[ "stream" ] )
	else
		cl_PPlay.play( info[ "stream" ], info[ "name" ], "server" )
		cl_PPlay.serverStream["stream"] = info["stream"]
		cl_PPlay.serverStream["name"] = info["name"]
		cl_PPlay.serverStream["playing"] = true
	end

end )

net.Receive("pplay_sendstreamlist", function( len, pl )

	cl_PPlay.streamList = net.ReadTable()
	cl_PPlay.getStreamList()

end)
