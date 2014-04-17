-- CLIENT VARIABLES
cl_PPlay.Notes = {}

cl_PPlay.currentStream = ""

cl_PPlay.streamList = {}

local showNotify = false
local notifyAlpha = 0

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

local function drawNotify(key, value)

	surface.SetFont( "NotificationFont_big" )

	local notify_text
	if string.len(value.text) > 35 then
		notify_text = string.sub(value.text, 0, 35) .. "..."
	else
		notify_text = value.text
	end

	local tw, th = surface.GetTextSize( notify_text )
	local w = 115 + tw
	local h = 100
	local xpos = ( ScrW() - w ) / 2
	local ypos = ScrH() / 16

	local timeDiff = value.time - SysTime()

	local fadeSpeed = 3
	local maxAlpha = 200

	if timeDiff > 0 and value.alpha < maxAlpha then
		value.alpha = value.alpha + fadeSpeed
	elseif timeDiff < 0 and value.alpha > 0 then
		value.alpha = value.alpha - fadeSpeed
	end

	draw.RoundedBox( 0, xpos, ypos, w, h, Color( 255, 255, 255, value.alpha ) )

	if value.style == "play" then

		draw.RoundedBox( 0, xpos, ypos, h, h, Color( 152, 243, 61, value.alpha ) )
		
		local triangle = {
			{ x = xpos + 20, y = ypos + 20 },
			{ x = xpos + 80, y = ypos + 50 },
			{ x = xpos + 20, y = ypos + 80 }
		}

		surface.SetDrawColor( 255, 255, 255, value.alpha )
		draw.NoTexture()
		surface.DrawPoly( triangle )
		draw.SimpleText( "Started following Stream:", "NotificationFont_small", xpos + 110, ypos + 10 , Color( 75, 75, 75, value.alpha ), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )

	elseif value.style == "stop" then

		draw.RoundedBox( 0, xpos, ypos, h, h, Color( 255, 36, 0, value.alpha ) )
		draw.RoundedBox( 0, xpos + 20, ypos + 20, h - 40, h - 40, Color( 255, 255, 255, value.alpha ) )
		draw.SimpleText( "Stopped following Stream:", "NotificationFont_small", xpos + 110, ypos + 10 , Color( 75, 75, 75, value.alpha ), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )

	elseif value.style == "error" then

		draw.RoundedBox( 0, xpos, ypos, h, h, Color( 255, 36, 0, value.alpha ) )
		draw.SimpleText( "ERROR:", "NotificationFont_small", xpos + 110, ypos + 10 , Color( 75, 75, 75, value.alpha ), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )

	end

	draw.SimpleText( notify_text, "NotificationFont_big", xpos + 107, ypos + 30 , Color( 75, 75, 75, value.alpha ), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )

end

-- STREAM NOTIFICATION
function cl_PPlay.notify()

	if not cl_PPlay.Notes then return end

	table.foreach( cl_PPlay.Notes, function( key, value )

		if SysTime() < value.time or value.alpha > 0 then
			drawNotify( key, value )
		else
			table.remove( cl_PPlay.Notes, key )
		end

	end )

end
hook.Add( "HUDPaint", "ShowNotify", cl_PPlay.notify )

function cl_PPlay.showNotify( text, style, length )

	local curmsg = {}
	curmsg.text = text
	curmsg.style = style
	curmsg.time = SysTime() + length
	curmsg.alpha = 1

	table.insert( cl_PPlay.Notes, curmsg )

end

-- PLAY FUNCTION
function cl_PPlay.play( url, name )

	if cl_PPlay.station != nil and cl_PPlay.station:IsValid() then cl_PPlay.station:Stop() end

	sound.PlayURL ( url, "play", function( station )

		if station != nil and station:IsValid() then
			local notify_text
			if name != "" then
				notify_text = name
			else
				notify_text = url
			end

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

	if found == "" then return url else return found end

end

-- STOP FUNCTOIN
function cl_PPlay.stop( url )

	cl_PPlay.station:Stop()
	cl_PPlay.showNotify( cl_PPlay.getNameFromURL( url ), "stop", 10)
	
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

net.Receive("pplay_sendstreamlist", function( len, pl )

	cl_PPlay.streamList = net.ReadTable()

end)
