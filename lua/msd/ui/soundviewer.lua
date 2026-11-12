local MSB = {}
local splayer
local brows_history = {}

function MSB.Play(snd)
	SetClipboardText(string.Replace(snd, "sound/", "" ))

	if MSB.Sound then
		MSB.Sound:Stop()
		MSB.Sound = nil
	end

	sound.PlayFile(snd, "noblock", function(station)
		if (IsValid(station)) then
			MSB.Sound = station
			MSB.Sound:Play()

			if IsValid(splayer) then
				splayer.Update()
			end
		end
	end)
end

function MSB.Stop()
	if MSB.Sound then
		MSB.Sound:Stop()
		MSB.Sound = nil
	end
end

local Ln = MSD.GetPhrase

MSB.Open = function()
	local pnl_w, pnl_h = ScrW(), ScrH()
	pnl_w, pnl_h = pnl_w - pnl_w / 4, pnl_h - pnl_h / 6
	local bg = Color(33, 33, 33)
	local panel = vgui.Create("MSDSimpleFrame")
	panel:SetSize(pnl_w, pnl_h)
	panel:Center()
	panel:MakePopup()
	panel:SetDraggable(true)

	panel.Paint = function(self, w, h)
		MSDX.Draw(0, 0, 0, w, h, bg)
		MSDX.Draw(0, 0, 0, w, 50, MSD.Theme["l"])
		MSDX.Draw(0, 0, 0, w, 50, MSD.Theme["l"])
		MSDX.Draw(0, 0, 52, w, h - 52, MSD.Theme["l"])
		draw.DrawText(string.upper(Ln("Sound Viewer")), "MSDFont.25", 12, 12, color_white, TEXT_ALIGN_LEFT)
	end

	panel.clsBut = MSD.IconButton(panel, MSD.Icons48.cross, panel:GetWide() - 34, 10, 25, nil, MSD.Config.MainColor.p, function()
		if panel.OnPress then
			panel.OnPress()

			return
		end

		panel:AlphaTo(0, 0.4, 0, function()
			panel:Close()
		end)
	end)

	function panel:OnClose()
		MSB:Stop()
	end

	panel:InvalidateLayout()
	panel.Canvas = vgui.Create("MSDPanelList", panel)
	panel.Canvas:SetSize(panel:GetWide() - 252, panel:GetTall() - 52)
	panel.Canvas:SetPos(252, 52)
	panel.Canvas:EnableVerticalScrollbar()
	panel.Canvas:EnableHorizontal(true)
	panel.Canvas:SetSpacing(2)
	panel.Canvas.IgnoreVbar = true
	panel.Canvas.Paint = function() end
	local pages = {}
	local cur_page = nil

	local function openPage(id, animate, ...)
		panel.Canvas:Clear()
		back_page = cur_page
		pages[id](...)
		cur_page = id

		if animate then
			panel.Canvas:SetAlpha(1)
			panel.Canvas:AlphaTo(255, 0.2)
		end
	end

	local games = {
		["GAME"] = {
			folder = "GAME",
			title = "All",
		},
		["garrysmod"] = {
			folder = "garrysmod",
			title = "Garry's Mod",
		},
		["WORKSHOP"] = {
			folder = "WORKSHOP",
			title = "Addons",
		},
	}

	local buttons = {}

	buttons[1] = {
		Ln("All"), Material("games/16/all.png", "smooth"), function()
			openPage("soundview", true, "GAME")
		end,
		true
	}

	buttons[2] = {
		Ln("Garry's Mod"), Material("games/16/garrysmod.png", "smooth"), function()
			openPage("soundview", true, "garrysmod")
		end
	}

	local mgame = engine.GetGames()

	for _, game in SortedPairsByMemberValue(mgame, "title") do
		if (not game.mounted) then continue end

		table.insert(buttons, {
			Ln(game.title), Material("games/16/" .. (game.icon or game.folder) .. ".png", "smooth"), function()
				openPage("soundview", true, game.folder)
			end
		})

		games[game.folder] = {
			folder = game.folder,
			title = game.title,
		}
	end

	table.insert(buttons, {
		Ln("Addons"), Material("games/16/all.png", "smooth"), function()
			openPage("addons", true)
		end
	})

	panel.Menu = vgui.Create("MSDPanelList", panel)
	panel.Menu:SetSize(250, panel:GetTall() - 52)
	panel.Menu:SetPos(0, 52)
	panel.Menu:EnableVerticalScrollbar()
	panel.Menu:EnableHorizontal(false)
	panel.Menu:SetSpacing(0)
	panel.Menu.IgnoreVbar = true

	panel.Menu.Paint = function(self, w, h)
		MSDX.Draw(0, 0, 0, w, h, MSD.Theme["l"])
	end

	panel.Menu.Deselect = function(but)
		but.hovered = true

		for k, v in pairs(panel.Menu:GetItems()) do
			if v and v:IsValid() and v ~= but then
				v.hovered = false
			end
		end
	end

	pages["addons"] = function(path)
		MSD.Header(panel.Canvas, "Addons")

		for k, v in pairs(engine.GetAddons()) do

			--MSD.ButtonScr(parent, x, y, w, h, text, func, al_left)
			MSD.ButtonScr(panel.Canvas, "static", nil, 6, nil, v.title, function()
				openPage("soundview", true, v.title, function()
					openPage("addons", true)
				end)
			end, nil, v.wsid)

			games[v.title] = {
				folder = v.title,
				title = v.title,
			}
		end
	end

	pages["soundview"] = function(path, back)
		MSD.Header(panel.Canvas, games[path].title)
		local ops_panel = vgui.Create("DPanel")
		ops_panel:SetSize(panel.Canvas:GetWide(), panel.Canvas:GetTall() - 52)

		ops_panel.Paint = function(self, w, h)
			MSDX.Draw(0, 0, 0, (w / 3) * 2 - 4, h, MSD.Theme["l"])
			MSDX.Draw(0, (w / 3) * 2, 0, w / 3 - 4, h, MSD.Theme["l"])
			draw.DrawText(Ln("Player"), "MSDFont.25", w / 3 * 2 + 12, 12, color_white, TEXT_ALIGN_LEFT)
		end

		local browser, path_name = nil, ""
		local pnlw = ops_panel:GetWide() / 3
		browser = vgui.Create("MSDPanelList", ops_panel)
		browser:SetSize(pnlw * 2, ops_panel:GetTall())
		browser:SetPos(0, 2)
		browser:EnableVerticalScrollbar()
		browser:EnableHorizontal(true)
		browser:SetSpacing(2)
		browser:SetPadding(2)
		browser.IgnoreVbar = true
		browser.history = {}
		browser.cur = 0
		browser.Populate = function(main_path)
			if IsValid(splayer) then splayer.searchfun = main_path end
			browser:Clear()
			local fls, fld = file.Find(main_path .. "*", path)

			MSD.Header(browser, main_path, (browser.cur > 0 or back) and function()
				if browser.cur > 0 and browser.history[browser.cur] then
					browser.cur = browser.cur - 1
					browser.Populate(browser.history[browser.cur + 1])

					return
				end

				if back and isfunction(back) then
					back()
				end
			end)

			for k, v in pairs(fld) do
				if splayer and splayer.filter and splayer.filter ~= "" and not string.find(string.lower(v), string.lower(splayer.filter)) then continue end
				MSD.IconButtonText(browser, v, MSD.Icons48.folder_open, "static", nil, 48, brows_history[main_path .. v .. "/"] and MSD.Text.n or false, nil, function()
					browser.cur = browser.cur + 1
					browser.history[browser.cur] = main_path
					browser.Populate(main_path .. v .. "/")
					brows_history[main_path .. v .. "/"] = true
				end)
			end

			for k, v in pairs(fls) do
				if splayer and splayer.filter and splayer.filter ~= "" and not string.find(string.lower(v), string.lower(splayer.filter)) then continue end
				MSD.IconButtonText(browser, v, MSD.Icons48.file_document, "static", nil, 48, brows_history[main_path .. v] and MSD.Text.n or false, nil, function()
					MSB.Play(main_path .. v)
					path_name = v
					brows_history[main_path .. v] = true
				end)
			end
		end

		browser.Populate("sound/")
		splayer = vgui.Create("DPanel", ops_panel)
		splayer:SetSize(pnlw - 4, ops_panel:GetTall() - 52)
		splayer:SetPos(pnlw * 2, 52)
		splayer.text_pos = 0

		splayer.search = MSD.TextEntry(splayer, 5, 5, pnlw - 14, 45, Ln("search") .. "...", "", "", function(self, value)
			splayer.filter = value
			browser.Populate(splayer.searchfun)
		end, true)

		splayer.Paint = function(self, mx, h)
			if not MSB.Sound or not IsValid(MSB.Sound) then
				draw.DrawText("No file selected", "MSDFont.24", mx / 2, h / 2, MSD.Text.d, TEXT_ALIGN_CENTER)
				return
			end

			local font = "MSDFont.24"
			surface.SetFont(font)
			local w = surface.GetTextSize( path_name or "" )
			if w > mx then
				if self.text_dir and isnumber(self.text_dir) and self.text_dir < CurTime() then
					self.text_dir = nil
				end

				if self.text_pos > mx - w - 10 and not self.text_dir then
					self.text_pos = math.Approach(self.text_pos, mx - w - 10, FrameTime() * 50)
				else
					if self.text_pos >= 0 and not isnumber(self.text_dir) then
						self.text_dir = CurTime() + 2
					else
						self.text_pos = math.Approach(self.text_pos, 0, FrameTime() * 50)
					end

					if not self.text_dir then
						self.text_dir = true
					end

				end

				draw.SimpleText( path_name or "", font, self.text_pos, 60, MSD.Text["s"], TEXT_ALIGN_LEFT)
			else
				draw.SimpleText( path_name or "", font, 0, 60, MSD.Text["s"], TEXT_ALIGN_LEFT)
			end
			draw.SimpleText( "Length: " .. string.FormattedTime( MSB.Sound:GetLength(), "%02i:%02i.%02i" ), "MSDFont.20", 0, 85, MSD.Text["s"], TEXT_ALIGN_LEFT)
			draw.SimpleText( "Sampling Rate: " .. MSB.Sound:GetSamplingRate() .. "Hz", "MSDFont.20", 0, 105, MSD.Text["s"], TEXT_ALIGN_LEFT)
		end
		splayer.Update = function()
			for i, v in ipairs(splayer:GetChildren()) do
				if v == splayer.search then continue end
				v:Remove()
			end
			local length = MSB.Sound:GetLength()
			local pb = MSD.IconButton(splayer, MSD.Icons48.play_circle_outline, splayer:GetWide() / 2-24, splayer:GetTall() - 70, 48, MSD.Text.s, MSD.MainShade(8), function()
				if MSB.Sound then
					if MSB.Sound:GetState() == GMOD_CHANNEL_PLAYING then
						MSB.Sound:Pause()
					else
						MSB.Sound:Play()
					end
				end
			end)
			pb.Think = function()
				if MSB.Sound then
					if MSB.Sound:GetState() == GMOD_CHANNEL_PLAYING then
						pb.mat = MSD.Icons48.pause_circle_outline
					else
						pb.mat = MSD.Icons48.play_circle_outline
					end
				end
			end
			MSD.IconButton(splayer, MSD.Icons48.stop_circle_outline, splayer:GetWide() / 2 - 61, splayer:GetTall() - 64, 32, MSD.Text.s, MSD.MainShade(8), function()
				if MSB.Sound then
					MSB:Stop()
				end
			end)
			-- MSD.IconButton(splayer, MSD.Icons48.clipboard_arrow_up, splayer:GetWide() / 2 + 26, splayer:GetTall() - 64, 32, nil, nil, function()
			-- 	if path_name then SetClipboardText(path_name) surface.PlaySound( "garrysmod/balloon_pop_cute.wav" ) end
			-- end)
			local buton = vgui.Create("DButton", splayer)
			buton.pos = 0
			buton:SetSize(splayer:GetWide() - 10, 8)
			buton:SetPos(5, splayer:GetTall() - 20)
			buton:SetText("")
			buton.DoClick = function(self)
				if not MSB.Sound then return end

				local w = self:GetWide()
				local mx, my = gui.MousePos()
				local x = self:ScreenToLocal( mx, my )

				x = x / w
				self.pos = x
				MSB.Sound:SetTime(length * x)
			end
			buton.Paint = function(self, w, h)
				if not MSB.Sound then return end
				MSDX.Draw(0,0,0,w,h,color_black)
				MSDX.Draw(0,0,0,self.pos * w,h,MSD.Text.d)
				self.pos = MSB.Sound:GetTime() / length
			end
		end

		panel.Canvas:AddItem(ops_panel)
	end

	for k, v in pairs(buttons) do
		local button = MSD.MenuButton(panel.Menu, v[2], nil, nil, 250, 50, v[1], function(self)
			panel.Menu.Deselect(self)
			v[3]()
		end, nil, true)

		if v[4] then
			panel.Menu.Deselect(button)
			v[3]()
		end
	end
end

concommand.Add("soundviewer", MSB.Open)