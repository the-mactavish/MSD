MSD = {}

function MSD.Load()

	MsgC( Color(174, 0, 255), "[MSD] Initialization started\n" )
	
	if !file.Exists("msd_data", "DATA") then
		file.CreateDir("msd_data")
		MsgC( Color(174, 0, 255), "[MSD] Server DATA Dir created \n" )
	end

	MsgC( Color(174, 0, 255), "[MSD] Initialization started\n" )

	if SERVER then
		include("msd/sh_config.lua")
		include("msd/sh_language.lua")
		AddCSLuaFile("msd/sh_config.lua")
		AddCSLuaFile("msd/sh_language.lua")

		local f = file.Find( "msd/ui/*", "LUA" )
	
		for k,v in pairs( f ) do
			AddCSLuaFile( "msd/ui/" .. v )
		end

	else
		include("msd/sh_config.lua")
		include("msd/sh_language.lua")

		local f = file.Find( "msd/ui/*", "LUA" )
	
		for k,v in pairs( f ) do
			include( "msd/ui/" .. v )
		end
	end


	MsgC( Color(174, 0, 255), "[MSD] Initialization done\n" )
	
end

MSD.Load()