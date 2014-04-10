---------------------
--  CREATE TABLES  --
---------------------

sv_PPlay = {}
cl_PPlay = {}



-------------------------
--  LOAD CLIENT FILES  --
-------------------------

AddCSLuaFile()
AddCSLuaFile("patchplay/client/player.lua")
AddCSLuaFile("patchplay/client/panel_functions.lua")
AddCSLuaFile("patchplay/client/panel.lua")



--------------------------------
--  LOAD SERVER/CLIENT FILES  --
--------------------------------

if SERVER then

	-- NETWORK STRINGS
	util.AddNetworkString( "pplay_sendstream" )
	util.AddNetworkString( "pplay_sendtoserver" )

	-- INCLUDE FILES
	include( "patchplay/server/sender.lua" )

else

	include( "patchplay/client/player.lua" )
	include( "patchplay/client/panel_functions.lua" )
	include( "patchplay/client/panel.lua" )
	
end
