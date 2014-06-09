cl_PPlay.Notes = {}

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

surface.CreateFont( "NowPlaying_header", {
	font 		= "Roboto",
	size 		= 15,
	weight 		= 100,
	blursize 	= 0,
	scanlines 	= 0,
	antialias 	= true,
	shadow 		= false
} )

surface.CreateFont( "NowPlaying_text", {
	font 		= "Roboto",
	size 		= 17,
	weight 		= 300,
	blursize 	= 0,
	scanlines 	= 0,
	antialias 	= true,
	shadow 		= false
} )

surface.CreateFont( "NowPlaying_small", {
	font 		= "Roboto",
	size 		= 13,
	weight 		= 100,
	blursize 	= 0,
	scanlines 	= 0,
	antialias 	= true,
	shadow 		= false
} )

local function drawNotify(key, value)

	surface.SetFont( "NotificationFont_big" )

	local notify_text
	if string.len(value.text) > 35 then
		if value.style == "play" or value.style == "stop" then
			notify_text = string.sub(value.text, 0, 35) .. "..."
		else
			notify_text = value.text
		end
	else
		notify_text = value.text
	end

	local tw, th = surface.GetTextSize( notify_text )
	local w = 115 + tw
	if w < 400 then w = 400 end
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

	if value.style != "error" and value.style != "info" then

		draw.RoundedBox( 0, xpos, ypos, w, h, Color( 255, 255, 255, value.alpha ) )

	end

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
		draw.SimpleText( "Started following " .. cl_PPlay.currentStream["stream_type"] .. "-stream:", "NotificationFont_small", xpos + 110, ypos + 10 , Color( 75, 75, 75, value.alpha ), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )

	elseif value.style == "stop" then

		draw.RoundedBox( 0, xpos, ypos, h, h, Color( 255, 36, 0, value.alpha ) )
		draw.RoundedBox( 0, xpos + 20, ypos + 20, h - 40, h - 40, Color( 255, 255, 255, value.alpha ) )
		draw.SimpleText( "Stopped following Stream:", "NotificationFont_small", xpos + 110, ypos + 10 , Color( 75, 75, 75, value.alpha ), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )

	elseif value.style == "error" then

		draw.RoundedBox( 0, 0, 0, ScrW(), 27, Color( 255, 0, 0, value.alpha ) )
		draw.SimpleText( "ERROR: " .. notify_text, "NotificationFont_small", 5, 5 , Color( 255, 255, 255, value.alpha ), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )
		return

	elseif value.style == "info" then

		draw.RoundedBox( 0, 0, 0, ScrW(), 27, Color( 0, 191, 255, value.alpha ) )
		draw.SimpleText( "INFO: " .. notify_text, "NotificationFont_small", 5, 5 , Color( 255, 255, 255, value.alpha ), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )
		return

	end

	draw.SimpleText( notify_text, "NotificationFont_big", xpos + 107, ypos + 30 , Color( 75, 75, 75, value.alpha ), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )

end

local function formatTime( rawNumber )
	local time = string.FormattedTime( rawNumber, "%02i:%02i" )
	return time
end


local startpos = 1
local endpos = 17
local back = false
local repeater = 0
local temp = 0

function cl_PPlay.slideText( text, rate )

	local function pos_change( val )
		if repeater >= 1 then
			endpos = endpos + val
			startpos = startpos + val
			repeater = 0
		else
			repeater = repeater + (rate/100)
		end
	end

	if !back and endpos < string.len(text) then
		pos_change(1)
	elseif !back and endpos == string.len(text) then

		temp = temp + 1

		if temp >= 50 then
			back = true
			pos_change(-1)
			temp = 0
		end

	elseif back and startpos > 1 then
		pos_change(-1)
	elseif back and startpos == 1 then
		temp = temp + 1

		if temp >= 50 then
			back = false
			pos_change(1)
			temp = 0
		end
	end

	return string.sub(text, startpos, endpos)
end


local function drawNowPlaying( streamType, state)

	--local tw, th = surface.GetTextSize( notify_text )
	local w = 150
	local h = 62
	local xpos = 0
	local ypos = ScrH() / 3

	local streamName = ""

	if cl_PPlay.currentStream["name"] != "" then

		streamName = cl_PPlay.currentStream["name"]

	else
		streamName = cl_PPlay.currentStream["stream"]
	end

	if string.len(streamName) > 17 then
		streamName = cl_PPlay.slideText( streamName, 4 )
	end	

	local streamType = ""

	if cl_PPlay.currentStream["stream_type"] == "server" then

		streamType = "Server-Stream"

	elseif cl_PPlay.currentStream["stream_type"] == "private" then

		streamType = "Private-Stream"

	end

	draw.RoundedBox( 0, xpos, ypos, w, h, Color( 255, 255, 255, 200 ) )
	draw.RoundedBox( 0, xpos + w, ypos, 5, h, Color( 255, 150, 0, 200 ) )

	draw.SimpleText( "Now Playing:", "NowPlaying_header", xpos + 5, ypos + 5 , Color( 75, 75, 75, 200 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )
	draw.SimpleText( streamName, "NowPlaying_text", xpos + 5, ypos + 25 , Color( 75, 75, 75, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )
	draw.SimpleText( streamType, "NowPlaying_small", xpos + 5, ypos + 25 + 14 , Color( 100, 100, 100, 200 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )

	if cl_PPlay.station:GetLength() != nil and cl_PPlay.station:GetLength() > 0 then
		local time_percent = cl_PPlay.station:GetTime() / cl_PPlay.station:GetLength()
		if state == 1 then
			draw.RoundedBox( 0, 0, ypos + 25 + 14 + 15, w * time_percent, 8, Color( 255, 150, 0, 200 ) )
		else
			draw.RoundedBox( 0, 0, ypos + 25 + 14 + 15, w * time_percent, 8, Color( 0, 0, 0, 200 ) )
		end
	else
		draw.SimpleText( formatTime(cl_PPlay.station:GetTime()), "NowPlaying_small", xpos + 6, ypos + 25 + 14 + 10 , Color( 100, 100, 100, 200 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )
	end

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

-- LOADING
local act = 0
local rewind = false
function cl_PPlay.loading()

	if !cl_PPlay.showLoading then return end

	local step = 3
	if act < 50 and !rewind then

		act = act + step

	elseif act >= 50 and !rewind then

		rewind = true

	elseif act > -50 and rewind then

		act = act - step

	elseif act <= -50 and rewind then

		rewind = false

	end

	draw.RoundedBox( 2, ScrW() / 2 - 70, ScrH() - 55, 140, 30, Color( 255, 255, 255, 150 ) )
	draw.RoundedBox( 2, ScrW() / 2 - 10 + act, ScrH() - 50, 20, 20, Color( 255, 150, 0, 255 ) )

end
hook.Add( "HUDPaint", "ShowLoading", cl_PPlay.loading )

-- STREAM NOTIFICATION
function cl_PPlay.nowPlaying()

	if !cl_PPlay.getSetting( "nowPlaying" ) then return end
	if cl_PPlay.station == nil or !cl_PPlay.station:IsValid() or cl_PPlay.currentStream == nil or cl_PPlay.station:GetState() == 0  then return end

	drawNowPlaying( cl_PPlay.currentStream["stream_type"], cl_PPlay.station:GetState() )

end
hook.Add( "HUDPaint", "ShowNowPlaying", cl_PPlay.nowPlaying )

function cl_PPlay.showNotify( text, style, length )

	if style == "play" and !cl_PPlay.getSetting( "bigNotification" ) then return end

	local curmsg = {}
	curmsg.text = text
	curmsg.style = style
	curmsg.time = SysTime() + length
	curmsg.alpha = 1

	table.insert( cl_PPlay.Notes, curmsg )

end