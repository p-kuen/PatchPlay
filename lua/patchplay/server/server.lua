-- GLOBAL VARIABLES
sv_PPlay.currentStream = {}
sv_PPlay.trackFinishedTime = 0

-- SENDING FUNCTION
function sv_PPlay.sendStream( info )
	if info[ "stream" ] == "" or info[ "stream" ] == nil then return end

	net.Start( "pplay_sendstream" )
		net.WriteTable( info )
	net.Broadcast()

end

function cl_PPlay.checkServerTrack()

	if sv_PPlay.trackFinishedTime == 0 then return end

	if CurTime() >= sv_PPlay.trackFinishedTime and sv_PPlay.currentStream["play_type"] == 2 then

		local playlist = sql.Query("SELECT * FROM pplay_playlist")

		local activeTrack = playlist[ sv_PPlay.currentStream["playlist_id"] ]
		sv_PPlay.removeFromPlaylist( activeTrack["stream"] )
		playlist = sql.Query("SELECT * FROM pplay_playlist")

		if playlist != nil then
			local nextTrack = playlist[ sv_PPlay.currentStream["playlist_id"] ]
			if nextTrack != nil then
				sv_PPlay.sendStream( { stream = nextTrack["stream"] .."?client_id=92373aa73cab62ccf53121163bb1246e", command = "play", name = nextTrack["name"], args = { play_type = 2 } } )
			else
				sv_PPlay.currentStream["play_type"] = 0
			end
		else
			sv_PPlay.currentStream["play_type"] = 0
		end
		

		sv_PPlay.trackFinishedTime = 0

	end

end
hook.Add("Think", "pplay_checkservertrack", cl_PPlay.checkServerTrack )

-- NETWORKING
net.Receive( "pplay_sendtoserver", function( len, pl )

	sv_PPlay.sendStream( net.ReadTable() )

end )

net.Receive( "pplay_sendtrackinfo", function( len, pl )

	sv_PPlay.currentStream = net.ReadTable()

	if sv_PPlay.currentStream["length"] > 0 then
		sv_PPlay.trackFinishedTime = CurTime() + sv_PPlay.currentStream["length"]
	else
		sv_PPlay.trackFinishedTime = 0
	end

end )

net.Receive( "pplay_askthetime", function( len, pl )

	net.Start( "pplay_sendthetime" )
		net.WriteDouble( sv_PPlay.trackFinishedTime - CurTime() )
	net.Send( pl )

end )

net.Receive( "pplay_savestream", function( len, pl )

	sv_PPlay.saveNewStream( net.ReadTable() )
	sv_PPlay.sendStreamList( )

end )
