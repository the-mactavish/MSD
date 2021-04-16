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

MSD.Config.MainColor = {
	["p"] = Color(0,155,255),
	["r"] = Color(255,0,0),
	["rd"] = Color(220,0,0),
}

--──────────────────────────────────--
------------- CFG Saving -------------
--──────────────────────────────────--

net.Receive("MSD.GetConfigData", function(l, ply)
	if CLIENT then
		local config = net.ReadTable()
		MSD.Config = config
	else
		net.Start("MSD.GetConfigData")
			net.WriteTable(MSD.Config)
		net.Send(ply)
	end
end)

MSD.SaveConfig = function()
	if CLIENT then
		net.Start("MSD.SaveConfig")
			net.WriteTable(MSD.Config)
		net.SendToServer()
	else
		net.Start("MSD.GetConfigData")
			net.WriteTable(MSD.Config)
		net.Broadcast()
		json_table = util.TableToJSON(MSD.Config, true)
		file.Write("msd_data/config.txt", json_table)
	end
end

function MSD.LoadConfig()
	
	if CLIENT then
		net.Start("MSD.GetConfigData")
		net.SendToServer()
	end

	if SERVER then
		net.Receive("MSD.SaveConfig", function(l, ply)
			if not ply:IsSuperAdmin() then return end
			local config = net.ReadTable()
			MSD.Config = config
			MSD.SaveConfig()
		end)

		if not file.Exists("msd_data/config.txt", "DATA") then
			json_table = util.TableToJSON(MSD.Config, true)
			file.Write("msd_data/config.txt", json_table)
		else
			local config = util.JSONToTable(file.Read("msd_data/config.txt", "DATA"))

			for k, v in pairs(config) do
				if MSD.Config[k] then
					MSD.Config[k] = v
				end
			end

			if #player.GetAll() > 0 then
				net.Start("MSD.GetConfigData")
					net.WriteTable(config)
				net.Broadcast()
			end
		end
	end
end

if SERVER then
	hook.Add("PostGamemodeLoaded", "MQMSDS.Load.SV", function() MSD.LoadConfig() end)	
else
	hook.Add("InitPostEntity", "MSD.Load.CL", function() MSD.LoadConfig() end)
end

if GAMEMODE then
	MSD.LoadConfig()
end