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

	-- INCLUDE FILES
	include( "patchplay/server/sender.lua" )
	include( "patchplay/server/config.lua" )
	include( "patchplay/server/settings.lua" )
	

else

	include( "patchplay/client/player.lua" )
	include( "patchplay/client/panel_functions.lua" )
	include( "patchplay/client/panel.lua" )
	
end
