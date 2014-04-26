-- CLIENT VARIABLES

cl_PPlay.use = true
cl_PPlay.showNowPlaying = true

cl_PPlay.currentStream = {
	stream = "",
	name = "",
	stream_type = "",
	play_type = 0,
	playlist_id = 0
}

cl_PPlay.serverStream = {
	stream = "",
	name = "",
	stream_type = "",
	play_type = 0,
	playlist_id = 0,
	length = 0,
	playing = false
}

local currentServerPos

cl_PPlay.streamList = {}
cl_PPlay.privateStreamList = {}

-- PLAY FUNCTION
function cl_PPlay.play( url, name, mode, args )

	if mode == "server" and cl_PPlay.currentStream[ "stream_type" ] == "private" and args["switch"] == nil or !cl_PPlay.use then return end
	if cl_PPlay.station != nil and cl_PPlay.station:IsValid() then cl_PPlay.station:Stop() end

	sound.PlayURL( url, "play noblock", function( station )

		if station != nil and station:IsValid() then

			local notify_text
			if name != "" then
				notify_text = name
			else
				notify_text = url
			end

			if mode == "server" then

				if args != nil and args["play_type"] != nil then
					cl_PPlay.serverStream[ "play_type" ] = args["play_type"]
					cl_PPlay.serverStream[ "playlist_id" ] = 1
				else
					cl_PPlay.serverStream[ "play_type" ] = 0
					cl_PPlay.serverStream[ "playlist_id" ] = 0
				end

				cl_PPlay.serverStream[ "length" ] = station:GetLength()
				net.Start( "pplay_sendtrackinfo" )
					net.WriteTable( cl_PPlay.serverStream )
				net.SendToServer()

			end

			cl_PPlay.currentStream[ "stream" ] = url
			cl_PPlay.currentStream[ "name" ] = name
			cl_PPlay.currentStream[ "stream_type" ] = mode

			if args != nil and args["play_type"] != nil then
				cl_PPlay.currentStream[ "play_type" ] = args["play_type"]
				cl_PPlay.currentStream[ "playlist_id" ] = 1
			else
				cl_PPlay.currentStream[ "play_type" ] = 0
				cl_PPlay.currentStream[ "playlist_id" ] = 0
			end
			
			cl_PPlay.showNotify( notify_text, "play", 10 )

			cl_PPlay.station = station

			if args != nil and args["switch"] and cl_PPlay.station:GetLength() > 0 then
				net.Start( "pplay_askthetime" )
					net.WriteString( "" )
				net.SendToServer()
			end
		else
			cl_PPlay.showNotify( "INVALID URL!", "error", 10 )
			cl_PPlay.serverStream[ "playing" ] = false
		end
		
	end )
	
end

-- STOP FUNCTOIN
function cl_PPlay.stop()

	cl_PPlay.station:Stop()
	cl_PPlay.showNotify( cl_PPlay.currentStream[ "name" ], "stop", 10 )
	cl_PPlay.UpdateMenus()
	
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

concommand.Add( "pplay_stopStreaming", cl_PPlay.stop )

function cl_PPlay.getSoundCloudInfo( rawURL, cb )

	local entry = {}

	local url = "http://api.soundcloud.com/resolve.json?url="..rawURL.."&client_id=92373aa73cab62ccf53121163bb1246e"
	http.Fetch( url,
		function( body, len, headers, code )
			entry = util.JSONToTable( body )

			if entry == nil then
				cl_PPlay.showNotify( "Unknown error!", "error", 10)
				return
			elseif !entry.streamable or entry.original_format == "wav" then
				cl_PPlay.showNotify( "SoundCloud URL not streamable", "error", 10)
				return
			end

			cb(entry)
		end,
		function( error )
			print("ERROR with fetching!")
		end
	);

end

function cl_PPlay.playStream( url, name, server, args )

	if server == nil then server = false end

	if url != "" and url != nil then

		local fullStream = url .. "?client_id=92373aa73cab62ccf53121163bb1246e"

		if name != "" then

			if server then cl_PPlay.sendToServer( fullStream, name, "play", args ) else cl_PPlay.play( fullStream, name, "private", args ) end
		
		else
			
			if server then cl_PPlay.sendToServer( fullStream, "", "play", args ) else cl_PPlay.play( fullStream, "", "private" ) end
		
		end

	end

end

--------------
-- PLAYLIST --
--------------

function cl_PPlay.playPlaylist( server )

	if server == nil then server = false end

	if server then

		if cl_PPlay.serverPlaylist == nil then
			cl_PPlay.showNotify( "Server playlist is empty!", "error", 10)
			return
		end

		local firstTrack = cl_PPlay.serverPlaylist[1]

		cl_PPlay.playStream( firstTrack["stream"], firstTrack["name"], server, { play_type = 2 } )

	else

		if cl_PPlay.privatePlaylist == nil then
			cl_PPlay.showNotify( "Private playlist is empty!", "error", 10)
			return
		end

		local firstTrack = cl_PPlay.privatePlaylist[1]

		cl_PPlay.playStream( firstTrack["stream"], firstTrack["name"], server, { play_type = 2 } )

	end

end

function cl_PPlay.fillPlaylist( filltable, server )

	if filltable == nil then return end
	if server == nil then server = false end

	if server then

		local added = 0

		cl_PPlay.clearServerPlaylist()

		table.foreach( filltable, function(id, track)

			if track.streamable and track.original_format != "wav" then
				cl_PPlay.addToServerPlaylist( track.stream_url, track.title )
				added = added + 1
			end

		end)
		cl_PPlay.showNotify( "Added " .. added .. " tracks to the server playlist!", "info", 5)

		cl_PPlay.getServerPlaylist()

	else

		local added = 0

		cl_PPlay.clearPlaylist()

		table.foreach( filltable, function(id, track)

			if track.streamable and track.original_format != "wav" then
				cl_PPlay.addToPlaylist( track.stream_url, track.title )
				added = added + 1
			end

		end)
		cl_PPlay.showNotify( "Added " .. added .. " to the playlist!", "info", 5)

		cl_PPlay.getPlaylist()

	end

end

function cl_PPlay.checkStationState()

	if cl_PPlay.station != nil and cl_PPlay.station:IsValid() then

		if cl_PPlay.currentStream["stream_type"] == "private" and cl_PPlay.currentStream["play_type"] == 2 and cl_PPlay.station:GetState() == 0 then

			local activeTrack = cl_PPlay.privatePlaylist[ cl_PPlay.currentStream["playlist_id"] ]
			cl_PPlay.removeFromPlaylist( activeTrack["stream"] )
			cl_PPlay.getPlaylist()

			local nextTrack = cl_PPlay.privatePlaylist[ cl_PPlay.currentStream["playlist_id"] ]
			if nextTrack != nil then
				cl_PPlay.playStream( nextTrack["stream"], nextTrack["name"], server, { play_type = 2 } )
			else
				cl_PPlay.currentStream["play_type"] = 0
			end

		end

	end

end
hook.Add("Think", "pplay_checkstationstate", cl_PPlay.checkStationState )



-----------------------
-- PRIVATE FUNCTIONS --
-----------------------

function cl_PPlay.switchToServer()

	cl_PPlay.play( cl_PPlay.serverStream["stream"], cl_PPlay.serverStream["name"], "server", { switch = true } )
	cl_PPlay.UpdateMenus()

end
concommand.Add( "pplay_switchToServer", cl_PPlay.switchToServer )



----------------------
-- SERVER FUNCTIONS --
----------------------

function cl_PPlay.sendToServer( url, streamname, cmd, arguments )
	
	local streamInfo = {
		stream = url,
		command = cmd,
		name = streamname,
		args = arguments
	}
	net.Start( "pplay_sendtoserver" )
		net.WriteTable( streamInfo )
	net.SendToServer()

end

local function stopServerStreaming( ply, cmd, args )

	cl_PPlay.sendToServer( cl_PPlay.serverStream[ "stream" ], cl_PPlay.serverStream[ "name" ], "stop" )
	cl_PPlay.serverStream[ "playing" ] = false
	cl_PPlay.UpdateMenus()

end
concommand.Add( "pplay_stopServerStreaming", stopServerStreaming )



-- Playlist --

function cl_PPlay.clearServerPlaylist()

	net.Start( "pplay_clearplaylist" )
		net.WriteString( "" )
	net.SendToServer()

end

function cl_PPlay.addToServerPlaylist( stream, streamname )

	local track = {

		url = stream,
		name = streamname
	}

	net.Start( "pplay_addtoplaylist" )
		net.WriteTable( track )
	net.SendToServer()

end

function cl_PPlay.deleteFromServerPlaylist( stream )

	net.Start( "pplay_addtoplaylist" )
		net.WriteString( stream )
	net.SendToServer()

end

function cl_PPlay.getServerPlaylist( )

	net.Start( "pplay_getplaylist" )
		net.WriteString( "" )
	net.SendToServer()

end

----------------
-- NETWORKING --
----------------

net.Receive( "pplay_sendstream", function( len, pl )

	local info = net.ReadTable()

	if info[ "command" ] == "stop" then
		if cl_PPlay.currentStream[ "stream_type" ] == "server" then cl_PPlay.stop() end
	else
		if info[ "args" ] == nil then
			cl_PPlay.play( info[ "stream" ], info[ "name" ], "server" )
		else
			cl_PPlay.play( info[ "stream" ], info[ "name" ], "server", info[ "args" ] )
		end
		cl_PPlay.serverStream[ "stream" ] = info[ "stream" ]
		cl_PPlay.serverStream[ "name" ] = info[ "name" ]
		cl_PPlay.serverStream[ "playing" ] = true
	end

end )

net.Receive( "pplay_sendstreamlist", function( len, pl )

	cl_PPlay.streamList = net.ReadTable()
	cl_PPlay.getStreamList()

end )

net.Receive( "pplay_sendthetime", function( len, pl )

	currentServerPos = cl_PPlay.station:GetLength() - net.ReadDouble(  )
	--cl_PPlay.station:SetTime( math.Round(currentServerPos) )

end )

net.Receive( "pplay_sendplaylist", function( len, pl )

	cl_PPlay.serverPlaylist = net.ReadTable()

end )
