-- CLIENT VARIABLES
cl_PPlay.currentStream = ""
cl_PPlay.currentStreamName = ""
cl_PPlay.currentNotifyType = ""
showNotify = false

-- CREATING FONTS
surface.CreateFont( "NotificationFont_small", {
	font 		= "Roboto",
	size 		= 17,
	weight 		= 100,
	blursize 	= 0,
	scanlines 	= 0,
	antialias 	= true,
	shadow 		= false
} )

surface.CreateFont( "NotificationFont_big", {
	font 		= "Roboto",
	size 		= 60,
	weight 		= 1,
	blursize 	= 0,
	scanlines 	= 0,
	antialias 	= true,
	shadow 		= false
} )

-- STREAM NOTIFICATION
function cl_PPlay.notify()

	if !showNotify then return end

	surface.SetFont( "NotificationFont_big" )
	local tw, th = surface.GetTextSize( cl_PPlay.currentStreamName )
	local w = 115 + tw
	local h = 100
	local xpos = ( ScrW() - w ) / 2
	local ypos = ScrH() / 16

	draw.RoundedBox( 0, xpos, ypos, w, h, Color( 255, 255, 255, 255 ) )

	if cl_PPlay.currentNotifyType == "play" then

		draw.RoundedBox( 0, xpos, ypos, h, h, Color( 152, 243, 61, 255 ) )
		local triangle = {
			{ x = xpos + 20, y = ypos + 20 },
			{ x = xpos + 80, y = ypos + 50 },
			{ x = xpos + 20, y = ypos + 80 }
		}
		surface.SetDrawColor( 255, 255, 255, 255 )
		draw.NoTexture()
		surface.DrawPoly( triangle )
		draw.SimpleText( "Started following Stream:", "NotificationFont_small", xpos + 110, ypos + 10 , Color( 75, 75, 75, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )

	elseif cl_PPlay.currentNotifyType == "stop" then

		draw.RoundedBox( 0, xpos, ypos, h, h, Color( 255, 36, 0, 255 ) )
		draw.RoundedBox( 0, xpos + 20, ypos + 20, h - 40, h - 40, Color( 255, 255, 255, 255 ) )
		draw.SimpleText( "Stoped following Stream:", "NotificationFont_small", xpos + 110, ypos + 10 , Color( 75, 75, 75, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )

	end

	draw.SimpleText( cl_PPlay.currentStreamName, "NotificationFont_big", xpos + 107, ypos + 30 , Color( 75, 75, 75, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )

end
hook.Add( "HUDPaint", "ShowNotify", cl_PPlay.notify )

-- PLAY FUNCTION
function cl_PPlay.play( url, name )

	if cl_PPlay.station != nil and cl_PPlay.station:IsValid() then cl_PPlay.station:Stop() end

	sound.PlayURL ( url, "play", function( station )

		if station:IsValid() then
			if name != "" then
				LocalPlayer():PrintMessage( HUD_PRINTTALK , "Playing now: " .. name )
				cl_PPlay.currentStreamName = name
			else
				LocalPlayer():PrintMessage( HUD_PRINTTALK , "Playing now: " .. url )
				cl_PPlay.currentStreamName = url
			end
			cl_PPlay.currentNotifyType = "play"
			showNotify = true
			timer.Simple( 10, function()
				showNotify = false
			end )
			cl_PPlay.station = station
		else
			LocalPlayer():PrintMessage( HUD_PRINTTALK , "Invalid URL!" )
		end
		
	end )
	
end

-- STOP FUNCTOIN
function cl_PPlay.stop( url )

	cl_PPlay.currentNotifyType = "stop"
	cl_PPlay.station:Stop()
	showNotify = true
	timer.Simple( 10, function()
		showNotify = false
	end )
	
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
