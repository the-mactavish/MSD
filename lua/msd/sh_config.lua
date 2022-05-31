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

MSD.Config.Language = "en"
MSD.Config.Rounded = 8
MSD.Config.Blur = false
MSD.Config.Vignette = false
MSD.Config.BgrColor = Color(45, 45, 45)
MSD.Config.MainColor = {
	["p"] = Color(0, 155, 255),
	["r"] = Color(255, 0, 0),
	["rd"] = Color(220, 0, 0),
}

MSD.Config.HUD = {
	ShowIcon = false,
	Icon = "https://i.imgur.com/ND3b6Do.png",
	Text = "MacNCo",
	X = 0.5,
	Y = 0.5,
	AlignX = 0,
	IconRight = false,
	IconSize = 48,
	FontSize = 28,
	ShowGroup = true,
	TeamColor = false,
	Follow = true,
	Dist = 200,
}

-- Util

function MSD.AddModule(name, menu, icon)
	local mod = {
		name = name,
		icon = icon,
		menu = menu
	}

	local id = MSD.ModuleIds[name]

	if id then
		MSD.Modules[id] = mod
	else
		id = table.insert(MSD.Modules, mod)
		MSD.ModuleIds[name] = id
	end

	return id
end

--──────────────────────────────────--
------------- CFG Saving -------------
--──────────────────────────────────--
local function SendConfig(ply)
	net.Start("MSD.GetConfigData")
		net.WriteTable(MSD.Config)
	net.Send(ply)
end

if CLIENT then
	net.Receive("MSD.GetConfigData", function()
		MSD.Config = net.ReadTable()
	end)
else
	local Received = {}

	net.Receive("MSD.GetConfigData", function(l, ply)
		if Received[ply] then return end
		Received[ply] = true

		SendConfig(ply)
	end)
end

if CLIENT then
	MSD.SaveConfig = function()
		local json_data = util.TableToJSON(MSD.Config, false)
		local cd = util.Compress(json_data)
		local bn = string.len(cd)

		net.Start("MSD.SaveConfig")
			net.WriteInt(bn, 32)
			net.WriteData(cd, bn)
		net.SendToServer()
	end
else
	MSD.SaveConfig = function()
		SendConfig(ply)
		file.Write("msd_data/config.txt",  util.TableToJSON(MSD.Config, true))
	end
end

function MSD.LoadConfig()
	if CLIENT then
		net.Start("MSD.GetConfigData")
		net.SendToServer()
	else
		local function SaveConfig()
			local compressed_data = net.ReadData(net.ReadInt(32))
			local json_data = util.Decompress(compressed_data)
			local config = util.JSONToTable(json_data)

			MSD.Config = config
			MSD.SaveConfig()
		end

		net.Receive("MSD.SaveConfig", function(l, ply)
			if ply:IsSuperAdmin() == false then return end

			if timer.Exists("MSD.SaveConfig") then
				timer.Create("MSD.SaveConfig", 1, 2, SaveConfig)
			else
				timer.Create("MSD.SaveConfig", 1, 2, function() end)
				SaveConfig()
			end
		end)

		if file.Exists("msd_data/config.txt", "DATA") then
			local config = util.JSONToTable(file.Read("msd_data/config.txt", "DATA"))

			for k, v in pairs(config) do
				if MSD.Config[k] != nil then
					MSD.Config[k] = v
				end
			end

			if #player.GetHumans() > 0 then
				net.Start("MSD.GetConfigData")
					net.WriteTable(MSD.Config)
				net.Broadcast()
			end
		else
			file.Write("msd_data/config.txt", util.TableToJSON(MSD.Config, true))
		end
	end
end

if SERVER then
	hook.Add("PostGamemodeLoaded", "MQMSDS.Load.SV", function()
		MSD.LoadConfig()
	end)
else
	hook.Add("InitPostEntity", "MSD.Load.CL", function()
		MSD.LoadConfig()
	end)
end

if GAMEMODE then
	MSD.LoadConfig()
end
