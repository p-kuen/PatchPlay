-- CLIENT VARIABLES
cl_PPlay.currentStream = ""

-- PLAY FUNCTION
function cl_PPlay.play( url, name )

	if cl_PPlay.station != nil and cl_PPlay.station:IsValid() then cl_PPlay.station:Stop() end

	sound.PlayURL ( url, "play", function( station )

		if station:IsValid() then
			if name != "" then
				LocalPlayer():PrintMessage( HUD_PRINTTALK , "Playing now: " .. name )
			else
				LocalPlayer():PrintMessage( HUD_PRINTTALK , "Playing now: " .. url )
			end
			cl_PPlay.station = station
		else
			LocalPlayer():PrintMessage( HUD_PRINTTALK , "Invalid URL!" )
		end
		
	end )
	
end

-- STOP FUNCTOIN
function cl_PPlay.stop( url )

	cl_PPlay.station:Stop()
	
end

-- NETWORKING
net.Receive( "pplay_sendstream", function( len, pl )

	local info = net.ReadTable()
	cl_PPlay.currentStream = info[ "stream" ]

	if info[ "command" ] == "stop" then
		cl_PPlay.stop( info[ "stream" ] )
	else
		cl_PPlay.play( info[ "stream" ], info[ "name" ] )
	end

end )
