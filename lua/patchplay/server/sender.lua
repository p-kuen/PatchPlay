-- GLOBAL VARIABLES
sv_PPlay.currentStream = ""

-- SENDING FUNCTION
function sv_PPlay.sendStream( info )
	if info[ "stream" ] == "" or info[ "stream" ] == nil then return end
	if info[ "command" ] == "play" then sv_PPlay.currentStream = info[ "stream" ] end

	net.Start( "pplay_sendstream" )
		net.WriteTable( info )
	net.Broadcast()

end

-- NETWORKING
net.Receive( "pplay_sendtoserver", function( len, pl )
	sv_PPlay.sendStream( net.ReadTable() )

end )
