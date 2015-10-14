-- CLIENT VARIABLES

cl_PPlay.use = true
cl_PPlay.showNowPlaying = true

cl_PPlay.cStream = {}

cl_PPlay.sStream = {}

cl_PPlay.Queue = {}
cl_PPlay.currentPlaylist = {}

cl_PPlay.Volume = 100

-- PLAY FUNCTION
function cl_PPlay.play( info, server, specials )

	--[[

	SPECIALS
	0 -- Nothing
	1 -- Switch
	2 -- Go in playlist-mode

	]]

	if info == nil or info.streamurl == nil or info.streamurl == "" then 

		cl_PPlay.showNotify( "No streamurl" , "error", 10 )
		return

	end

	if specials == nil then specials = 0 end
	if specials != 1 and server and !cl_PPlay.cStream.server and cl_PPlay.isMusicPlaying() or server and !cl_PPlay.use then
		cl_PPlay.sStream.info = info
		cl_PPlay.sStream.playing = true
		return
	end
	if !cl_PPlay.use then return end

	cl_PPlay.showLoading = true

	cl_PPlay.stop()

	sound.PlayURL( info.streamurl, "play noblock", function( station, errorID, errorName )

		if station != nil and station:IsValid() then

			local notify_text
			if info.title != "" then
				notify_text = info.title
			else
				notify_text = info.streamurl
			end

			station:SetVolume( cl_PPlay.Volume / 100 )
			cl_PPlay.cStream.info = info
			cl_PPlay.cStream.server = server
			cl_PPlay.cStream.station = station
			if specials == 2 then
				cl_PPlay.cStream.playlist = true
			else
				cl_PPlay.cStream.playlist = false
			end

			if server then

				cl_PPlay.cStream.serverText = "server"
				cl_PPlay.sStream.info = info
				cl_PPlay.sStream.playing = true

			else
				cl_PPlay.cStream.serverText = "private"
			end
			
			cl_PPlay.showNotify( notify_text, "play", 10 )

			cl_PPlay.showLoading = false
		else
			print("url: " .. info.streamurl .. " was invalid")
			if errorID != nil and errorName != nil then

				cl_PPlay.showNotify( "ID " .. errorID .. " - " .. errorName , "error", 10 )

			elseif errorID != nil then

				cl_PPlay.showNotify( "ID " .. errorID , "error", 10 )

			else

				cl_PPlay.showNotify( "Unknown error - try again or use another stream - tried to play: " .. info.streamurl , "error", 10 )

			end
			
			cl_PPlay.showLoading = false
		end
		
	end )
	
end

function cl_PPlay.isMusicPlaying( server )

	if server == nil then server = false end

	if server then

		if cl_PPlay.sStream.playing then
			return true
		else
			return false
		end

	else

		if cl_PPlay.cStream.station != nil and cl_PPlay.cStream.station:IsValid() and cl_PPlay.cStream.station:GetState() != 0 then
			return true
		else
			return false
		end

	end

end

-- STOP FUNCTION
function cl_PPlay.stop()

	if cl_PPlay.cStream.station == nil or !cl_PPlay.cStream.station:IsValid() then return end

	cl_PPlay.cStream.station:Stop()
	--cl_PPlay.showNotify( cl_PPlay.cStream.name, "stop", 10 )
	cl_PPlay.cStream = {}
	cl_PPlay.UpdateMenus()
	
end

concommand.Add( "pplay_stopStreaming", cl_PPlay.stop )

function cl_PPlay.playStream( info, server, specials )

	if server == nil then server = false end

	--Playlist exception
	if server and info != nil and specials == 2 then

		cl_PPlay.sendToServer( "playPlaylist", {info, specials} )
		return

	end

	if info != nil and info.streamurl != nil and info.streamurl != "" then

		if string.find(info.streamurl, "soundcloud") and !string.find(info.streamurl, "?client_id") then

			info.streamurl = info.streamurl .. "?client_id=92373aa73cab62ccf53121163bb1246e"

		end

		if server then cl_PPlay.sendToServer( "play", { info, specials } ) else cl_PPlay.play( info, false, specials ) end

	end

end

hook.Add("PostCleanupMap", "ppFix", function()
	if IsValid(cl_PPlay.cStream.station) then
		if cl_PPlay.cStream.station:GetLength() < 0 or cl_PPlay.cStream.station:GetLength() > cl_PPlay.cStream.station:GetTime() then
			cl_PPlay.cStream.station:Play()
		end
	end
end)
