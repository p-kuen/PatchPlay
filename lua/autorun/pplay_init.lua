---------------------
--  CREATE TABLES  --
---------------------

sv_PPlay = {}
cl_PPlay = {}



-------------------------
--  LOAD CLIENT FILES  --
-------------------------

AddCSLuaFile()
--AddCSLuaFile("patchplay/client/hud.lua")
AddCSLuaFile("patchplay/client/player.lua")
AddCSLuaFile("patchplay/client/panel_functions.lua")
AddCSLuaFile("patchplay/client/panel.lua")
--AddCSLuaFile("patchplay/client/buddy.lua")


--------------------------------
--  LOAD SERVER/CLIENT FILES  --
--------------------------------

if SERVER then
	util.AddNetworkString( "pplay_sendstream" )
	util.AddNetworkString( "pplay_sendtoserver" )

	include( "patchplay/server/sender.lua" )

else

	--include( "patchprotect/client/hud.lua" )
	include( "patchplay/client/player.lua" )
	include( "patchplay/client/panel_functions.lua" )
	include( "patchplay/client/panel.lua" )
	--include( "patchprotect/client/buddy.lua" )
	
end
