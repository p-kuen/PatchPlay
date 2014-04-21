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
	length = 0,
	playing = false
}

cl_PPlay.streamList = {}
cl_PPlay.privateStreamList = {}

-- PLAY FUNCTION
function cl_PPlay.play( url, name, mode, switch )

	if mode == "server" and cl_PPlay.currentStream[ "stream_type" ] == "private" and switch == nil or !cl_PPlay.use then return end
	if cl_PPlay.station != nil and cl_PPlay.station:IsValid() then cl_PPlay.station:Stop() end

	sound.PlayURL( url, "play", function( station )

		if station != nil and station:IsValid() then

			local notify_text
			if name != "" then
				notify_text = name
			else
				notify_text = url
			end

			cl_PPlay.currentStream[ "stream" ] = url
			cl_PPlay.currentStream[ "name" ] = name
			cl_PPlay.currentStream[ "stream_type" ] = mode

			if mode == "server" then
				cl_PPlay.serverStream[ "playing" ] = true
				cl_PPlay.serverStream[ "length" ] = station:GetLength()
			end
			
			cl_PPlay.showNotify( notify_text, "play", 10 )

			cl_PPlay.station = station
		else
			cl_PPlay.showNotify( "INVALID URL!", "error", 10 )
			cl_PPlay.serverStream[ "playing" ] = false
		end
		
	end )
	
end

function cl_PPlay.getNameFromURL( url )

	local found = ""

	table.foreach( cl_PPlay.streamList, function( key, value )
		if value[ "stream" ] == url then
			found = value[ "name" ]
		end
	end )

	if found == "" then
		table.foreach( cl_PPlay.privateStreamList, function( key, value )
			if value[ "stream" ] == url then
				found = value[ "name" ]
			end
		end )
	end

	if found == "" then	return url else return found end

end

-- STOP FUNCTOIN
function cl_PPlay.stop()

	cl_PPlay.station:Stop()
	cl_PPlay.showNotify( cl_PPlay.currentStream[ "name" ], "stop", 10 )
	
end
concommand.Add( "pplay_stopStreaming", cl_PPlay.stop )

function cl_PPlay.getSoundCloudInfo( rawURL )

	local entry = {}


	http.Fetch( "http://api.soundcloud.com/resolve.json?url="..rawURL.."&client_id=92373aa73cab62ccf53121163bb1246e",
		function( body, len, headers, code )
			entry = util.JSONToTable( body )
			if !entry.streamable then
				cl_PPlay.showNotify( "SoundCloud URL not streamable", "error", 10)
			end
		end,
		function( error )
			print("ERROR with fetching!")
		end
	);

	return entry

end



-----------------------
-- PRIVATE FUNCTIONS --
-----------------------

function cl_PPlay.switchToServer()
	cl_PPlay.play( cl_PPlay.serverStream["stream"], cl_PPlay.serverStream["name"], "server", true )
	cl_PPlay.UpdateMenus()
end
concommand.Add( "pplay_switchToServer", cl_PPlay.switchToServer )



----------------------
-- SERVER FUNCTIONS --
----------------------

function cl_PPlay.sendToServer( url, streamname, cmd )
	
	local streamInfo = {
		stream = url,
		command = cmd,
		name = streamname
	}

	net.Start( "pplay_sendtoserver" )
		net.WriteTable( streamInfo )
	net.SendToServer()

end

local function stopServerStreaming( ply, cmd, args )

	cl_PPlay.sendToServer( cl_PPlay.serverStream[ "stream" ], cl_PPlay.serverStream[ "name" ], "stop" )
	cl_PPlay.serverStream[ "playing" ] = false

end
concommand.Add( "pplay_stopServerStreaming", stopServerStreaming )



----------------
-- NETWORKING --
----------------

net.Receive( "pplay_sendstream", function( len, pl )

	local info = net.ReadTable()

	if info[ "command" ] == "stop" then
		if cl_PPlay.currentStream[ "stream_type" ] == "server" then cl_PPlay.stop() end
	else
		cl_PPlay.play( info[ "stream" ], info[ "name" ], "server" )
		cl_PPlay.serverStream[ "stream" ] = info[ "stream" ]
		cl_PPlay.serverStream[ "name" ] = info[ "name" ]
	end

end )

net.Receive( "pplay_sendstreamlist", function( len, pl )

	cl_PPlay.streamList = net.ReadTable()
	cl_PPlay.getStreamList()

end )
