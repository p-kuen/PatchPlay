---------------------
--  CREATE TABLES  --
---------------------

sv_PPlay = {}
cl_PPlay = {}



-------------------------
--  LOAD CLIENT FILES  --
-------------------------

AddCSLuaFile()
AddCSLuaFile("patchplay/client/core.lua")
AddCSLuaFile("patchplay/client/player.lua")
AddCSLuaFile("patchplay/client/playlist.lua")
AddCSLuaFile("patchplay/client/panel_functions.lua")
AddCSLuaFile("patchplay/client/panel_main.lua")
AddCSLuaFile("patchplay/client/sql.lua")
AddCSLuaFile("patchplay/client/panel_frames.lua")
AddCSLuaFile("patchplay/client/hud.lua")
AddCSLuaFile("patchplay/client/browser.lua")



--------------------------------
--  LOAD SERVER/CLIENT FILES  --
--------------------------------

if SERVER then

	-- INCLUDE FILES
	include( "patchplay/server/server.lua" )
	include( "patchplay/server/config.lua" )
	include( "patchplay/server/sql.lua" )
	

else

	include( "patchplay/client/core.lua" )
	include( "patchplay/client/player.lua" )
	include( "patchplay/client/playlist.lua" )
	include( "patchplay/client/panel_functions.lua" )
	include( "patchplay/client/panel_main.lua" )
	include( "patchplay/client/sql.lua" )
	include( "patchplay/client/panel_frames.lua" )
	include( "patchplay/client/hud.lua" )
	include( "patchplay/client/browser.lua" )
	
end
