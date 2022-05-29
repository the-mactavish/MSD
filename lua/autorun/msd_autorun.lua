-- ┏━┓┏━┳━━━┳━━━┓───────────────────────
-- ┃┃┗┛┃┃┏━┓┣┓┏┓┃───────────────────────
-- ┃┏┓┏┓┃┗━━┓┃┃┃┃──By MacTavish <3──────
-- ┃┃┃┃┃┣━━┓┃┃┃┃┃───────────────────────
-- ┃┃┃┃┃┃┗━┛┣┛┗┛┃───────────────────────
-- ┗┛┗┛┗┻━━━┻━━━┛───────────────────────

-- MIT License

-- Copyright (c) 2021 Ayden Mactavish

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

if MSD and MSD.Version ~= "1.0.3" then MsgC( Color(255, 8, 0), "[MSD] Another version of MSD detacted\n" ) return end

MSD = {}
MSD.Version = "1.0.3"
MSD.Config = {}
MSD.Modules = {}
MSD.ModuleIds = {}
MSD.Language = {}

if SERVER then
	util.AddNetworkString( "MSD.GetConfigData" )
	util.AddNetworkString( "MSD.SaveConfig" )
end

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
		for k,v in ipairs( f ) do
			AddCSLuaFile( "msd/ui/" .. v )
		end

	else
		include("msd/sh_config.lua")
		include("msd/sh_language.lua")

		local f = file.Find( "msd/ui/*", "LUA" )
		for k,v in ipairs( f ) do
			include( "msd/ui/" .. v )
		end

		list.Set( "DesktopWindows", "MSDModulesSetup", {
			title		= "Setup Menu",
			icon		= "msd/macnco.png",
			width		= 960,
			height		= 700,
			onewindow	= true,
			init		= function( icon, window )
				window:Close()
				icon.Window = MSD.OpenMenuManager(g_ContextMenu)
			end
		} )
	end


	MsgC( Color(174, 0, 255), "[MSD] Initialization done\n" )
end

MSD.Load()