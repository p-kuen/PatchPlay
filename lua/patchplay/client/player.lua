cl_PPlay.currentStream = ""


function cl_PPlay.play( url )
	if cl_PPlay.station != nil and cl_PPlay.station:IsValid() then cl_PPlay.station:Stop() end
	sound.PlayURL ( url, "play", function( station )
		if ( IsValid( station ) ) then
			LocalPlayer():PrintMessage( HUD_PRINTTALK , "Playing the sound now!")
			cl_PPlay.station = station
		else

			LocalPlayer():PrintMessage( HUD_PRINTTALK , "INVALID!")

		end
	end )
	
end

function cl_PPlay.stop( url )
	cl_PPlay.station:Stop()
	
end

--NETWORKING
net.Receive("pplay_sendstream", function( len, pl )

	local info = net.ReadTable()
	cl_PPlay.currentStream = info["stream"]

	if info["command"] == "stop" then
		cl_PPlay.stop( info["stream"] )
	else
		cl_PPlay.play( info["stream"] )
	end
	

end)
