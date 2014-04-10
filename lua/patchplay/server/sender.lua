-- GLOBAL VARIABLES
sv_PPlay.currentStream = ""

-- SENDING FUNCTION
function sv_PPlay.sendStream( info )

	if info[ "stream" ] == "" then
		info[ "stream" ] = "http://mp3.stream.tb-group.fm/ht.mp3?"
	end

	sv_PPlay.currentStream = info[ "stream" ]

	net.Start( "pplay_sendstream" )
		net.WriteTable( info )
	net.Broadcast()

end

-- NETWORKING
net.Receive( "pplay_sendtoserver", function( len, pl )

	print("got from client")
	sv_PPlay.sendStream( net.ReadTable() )

end )
