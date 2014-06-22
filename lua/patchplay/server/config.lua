

------------------
--  NETWORKING  --
------------------

-- General
util.AddNetworkString( "pplay_play" ) --used
util.AddNetworkString( "pplay_stop" ) --used
util.AddNetworkString( "pplay_playPlaylist" ) --used

-- SQL
util.AddNetworkString( "pplay_sendtable" ) --used
util.AddNetworkString( "pplay_addrow" ) --used
util.AddNetworkString( "pplay_deleterow" ) --used

util.AddNetworkString( "pplay_broadcast" ) --used
util.AddNetworkString( "pplay_sendtoserver" ) --used
util.AddNetworkString( "pplay_sendtrackinfo" ) --used
util.AddNetworkString( "pplay_askthetime" ) --used
util.AddNetworkString( "pplay_sendthetime" ) --used

-- Streamlist
util.AddNetworkString( "pplay_stream_remove" ) --used
util.AddNetworkString( "pplay_stream_save" ) --used
util.AddNetworkString( "pplay_sendstreamlist" ) --used


-- Playlist
util.AddNetworkString( "pplay_playlist_clear" ) --used
util.AddNetworkString( "pplay_playlist_remove" ) --used
util.AddNetworkString( "pplay_playlist_send" ) --used

-- Settings
util.AddNetworkString( "pplay_settings_change" ) --used
util.AddNetworkString( "pplay_sendsettings" ) --used
