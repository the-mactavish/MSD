local function DrawKey(x, y, key, alpha)
	alpha = alpha or 200
	if not isstring(key) then return end
	key = string.upper(key)
	surface.SetFont("MSDFont.20")
	local w = surface.GetTextSize(key)
	MSDX.Draw(4, x + 2, y + 3, w + 8, 22, MSD.ColorAlpha(MSD.Theme.l, alpha))
	MSDX.Draw(4, x, y, w + 10, 25, MSD.ColorAlpha(MSD.Theme.d, alpha))
	draw.SimpleText(key, "MSDFont.20", x + 5, y + 3, MSD.ColorAlpha(color_white, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

	return w + 10
end

MSD.DrawKey = DrawKey

function MSD.DrawKeyIcon(x, y, key, w, alpha)
	alpha = alpha or 200
	w = w or 20
	MSDX.Draw(4, x, y, w + 8, w + 8, MSD.ColorAlpha(MSD.Theme.d, 210))
	MSD.DrawTexturedRect(x + 4, y + 4, w, w, key, MSD.ColorAlpha(color_white, alpha))

	return w + 5
end

function MSD.ShadowText(text, font, x, y, color, alingx, ss, scolor)
	draw.DrawText(text, font, x + (ss or 1), y + (ss or 1), scolor or color_black, alingx)
	draw.DrawText(text, font, x, y, color, alingx)
end

function MSD.PanelIcon(parent, text, icon, update)
	local panel = vgui.Create("DPanel")

	panel.StaticScale = {
		w = 1,
		fixed_h = 50,
		minw = 250,
		minh = 50
	}
	panel.text = text
	panel.update = update
	panel.icon = icon
	panel.Paint = function(self, w, h)
		MSDX.Draw(MSD.Config.Rounded, 0, 0, w, h, MSD.Theme["l"])
		draw.DrawText(self.text, "MSDFont.22", 48, h / 2 - 11, MSD.Text["s"], TEXT_ALIGN_LEFT)
		MSD.DrawTexturedRect(12, h / 2 - 12, 24, 24, self.icon, MSD.Text["l"])

		if self.update then self.update(self, w, h) end
	end

	parent:AddItem(panel)

	return panel
end

function MSD.BigButtonClean(parent, x, y, w, h, text, icon, func, color, color2, func2)
	local button = vgui.Create("DButton")
	button:SetText(text)

	if x and y then
		button:SetParent(parent)
		button:SetPos(x, y)
	end

	if x == "static" then
		button.StaticScale = {
			w = w,
			fixed_h = h,
			minw = 150,
			minh = h
		}
	else
		button:SetSize(w, h)
	end

	button.alpha = 0
	button.color_idle = color2

	button.Paint = function(self, wd, hd)
		if self.hover and not self.disable then
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 1)
		else
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 0)
		end

		if self.color_idle then
			if icon then MSD.DrawTexturedRect(wd / 2 - 24, hd / 2 - 36, 48, 48, icon, MSD.ColorAlpha(self.color_idle, 255 - self.alpha * 255)) end
			draw.DrawText(button:GetText(), "MSDFont.25", wd / 2, hd / 2 + 10, MSD.ColorAlpha(self.color_idle, 255 - self.alpha * 255), TEXT_ALIGN_CENTER)
		end

		if self.alpha > 0.01 then
			if icon then MSD.DrawTexturedRect(wd / 2 - 24, hd / 2 - 36, 48, 48, icon, MSD.ColorAlpha(color or MSD.Config.MainColor["p"], self.alpha * 255)) end
			draw.DrawText(button:GetText(), "MSDFont.25", wd / 2, hd / 2 + 10, MSD.ColorAlpha(color or MSD.Config.MainColor["p"], self.alpha * 255), TEXT_ALIGN_CENTER)
		end

		return true
	end

	button.OnCursorEntered = function(self)
		self.hover = true
	end

	button.OnCursorExited = function(self)
		self.hover = false
	end

	button.DoClick = function(self)
		if self.disable then return end
		func(self)
	end

	button.DoRightClick = function(self)
		if self.disable or not func2 then return end
		func2(self)
	end

	if not x or not y then
		parent:AddItem(button)
	end

	return button
end

function MSD.InfoTextIcon(parent, text_big, text, icon, cl1)
	local panel = vgui.Create("DPanel")

	panel.StaticScale = {
		w = 1,
		fixed_h = 80,
		minw = 250,
		minh = 80
	}

	panel.Paint = function(self, w, h)
		if self.hidden then
			self.StaticScale.fixed_h = 1
			return
		end

		MSDX.Draw(MSD.Config.Rounded, 0, 0, w, h, MSD.Theme["l"])
		MSD.DrawTexturedRect(8, 8, 64, 64, icon, cl1 or color_white)
		draw.DrawText(text_big, "MSDFont.28", 80, 5, MSD.Config.MainColor["p"], TEXT_ALIGN_LEFT)

		local ts, _, th = MSD.TextWrap(text, "MSDFont.20", w - 85)
		draw.DrawText(ts, "MSDFont.20", 80, 40, MSD.Text.l, TEXT_ALIGN_LEFT)

		self.StaticScale.fixed_h = math.max(80, th + 45)
	end

	parent:AddItem(panel)

	return panel
end

-- Shared popup shell: blurred backdrop with a centred box, a title bar and an optional close button
local popup_bg = Color(61, 61, 61)

local function PopupShell(parent, title, hide_clsBut)
	local panel

	if parent then
		panel = vgui.Create("DPanel")
		panel:SetAlpha(0)
		panel:AlphaTo(255, 0.3)
	else
		panel = vgui.Create("MSDSimpleFrame")
		panel:SetSize(ScrW(), ScrH())
		panel:MakePopup()
	end

	panel.Paint = function(self, w, h)
		MSD.Blur(self, 5, 5, 255, 50, w, h)
	end

	panel.Close = function()
		panel:AlphaTo(0, 0.3, 0, function()
			panel:Remove()
		end)
	end

	if parent then
		parent:AddToWorkSpace(panel)
	end

	local child = vgui.Create("DPanel", panel)
	child:SetSize(panel:GetWide() / 3, 135)
	child:Center()

	child.Paint = function(self, w, h)
		MSDX.Draw(0, 0, 0, w, h, popup_bg)
		MSDX.Draw(0, 0, 0, w, 40, MSD.Theme["d"])
		draw.DrawText(title, "MSDFont.20", 10, 10, color_white, TEXT_ALIGN_LEFT)
	end

	child.PerformLayout = function(self)
		child:Center()

		if child.clsBut then
			child.clsBut:SetPos(child:GetWide() - 38, 5)
		end
	end

	if not hide_clsBut then
		child.clsBut = MSD.IconButton(child, MSD.Icons48.cross, child:GetWide() - 38, 5, 32, nil, nil, function()
			panel:Close()
		end)
	end

	return panel, child
end

local function DockBottom(pnl, bottom)
	pnl:DockPadding(10, 5, 10, bottom)
	pnl:DockMargin(10, 5, 10, bottom)
	pnl:Dock(BOTTOM)
end

-- but_1 / but_2 = {text, func(button)}
function MSD.AskPopup(parent, title, hide_clsBut, but_1, but_2)
	local panel, child = PopupShell(parent, title, hide_clsBut)

	if but_1 then
		DockBottom(MSD.Button(child, 10, 50, child:GetWide() - 20, 30, but_1[1], function(self)
			panel:Close()
			but_1[2](self)
		end), 10)
	end

	if but_2 then
		DockBottom(MSD.Button(child, 10, 50, child:GetWide() - 20, 30, but_2[1], function(self)
			panel:Close()
			but_2[2](self)
		end), 5)
	end

	return panel, child
end

-- Text input; entry = {placeholder, func(textentry)} runs on Enter
function MSD.AskPopupEntr(parent, title, hide_clsBut, entry)
	local panel, child = PopupShell(parent, title, hide_clsBut)
	local entr

	if entry then
		entr = MSD.TextEntry(child, 10, 10, child:GetWide() - 20, 40, entry[1], nil, "", function(self)
			panel:Close()
			entry[2](self)
		end)

		DockBottom(entr, 10)
		entr:RequestFocus()
	end

	return panel, child, entr
end

-- Dropdown + confirm button; combo = {placeholder, button text, func(button)}.
-- Returns the DComboBox and the button: store the choice on the button (e.g. button.data) in OnSelect.
function MSD.AskPopupCombo(parent, title, hide_clsBut, combo)
	local panel, child = PopupShell(parent, title, hide_clsBut)
	local button, cbb

	if combo then
		button = MSD.Button(child, 10, 50, child:GetWide() - 20, 30, combo[2], function(self)
			panel:Close()
			combo[3](self)
		end)

		DockBottom(button, 5)

		cbb = MSD.ComboBox(child, 10, 10, child:GetWide() - 20, 30, nil, combo[1])
		DockBottom(cbb, 10)
	end

	return cbb, button, panel, child
end

function MSD.AskConfirmPopup(parent, question, acceptText, cancelText, acceptFunc)
	local panel
	local holdTime = 2

	if parent then
		panel = vgui.Create("DPanel")
		panel:SetAlpha(0)
		panel:AlphaTo(255, 0.3)
	else
		panel = vgui.Create("MSDSimpleFrame")
		panel:SetSize(ScrW(), ScrH())
		panel:MakePopup()
		panel:SetDraggable(false)
		panel:AlphaTo(255, 0.3)
	end

	panel.Paint = function(self, w, h)
		Derma_DrawBackgroundBlur(self, self.startTime)
	end

	panel.Close = function()
		panel:AlphaTo(0, 0.3, 0, function()
			panel:Remove()
		end)
	end

	if parent then
		parent:AddToWorkSpace(panel)
	end

	local child = vgui.Create("DPanel", panel)
	child:SetSize(panel:GetWide() / 3, 180)
	child:Center()

	child.Paint = function(self, w, h)
		MSDX.Draw(MSD.Config.Rounded, 0, 0, w, h, MSD.Theme["d"])
		draw.DrawText(MSD.TextWrap(question, "MSDFont.22", w - 20), "MSDFont.22", w / 2, 12, color_white, TEXT_ALIGN_CENTER)
	end

	-- Cancel button
	local cancelBut = vgui.Create("DButton", child)
	cancelBut:SetText(cancelText or "Cancel")
	cancelBut:SetSize(child:GetWide() / 2 - 15, 40)
	cancelBut:SetPos(10, 130)
	cancelBut.alpha = 0

	cancelBut.Paint = function(self, w, h)
		MSDX.Draw(MSD.Config.Rounded, 0, 0, w, h, MSD.Theme["l"])

		if self.hover then
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 1)
		else
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 0)
		end

		draw.DrawText(self:GetText(), "MSDFont.22", w / 2, h / 2 - 11, MSD.ColorAlpha(MSD.Text["s"], 255 - self.alpha * 255), TEXT_ALIGN_CENTER)
		draw.DrawText(self:GetText(), "MSDFont.22", w / 2, h / 2 - 11, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha * 255), TEXT_ALIGN_CENTER)
		MSDX.Draw(0, MSD.Config.Rounded, h - 1, w - MSD.Config.Rounded * 2, 1, MSD.ColorAlpha(MSD.Text["n"], 255 - self.alpha * 255))
		MSDX.Draw(0, MSD.Config.Rounded, h - 1, w - MSD.Config.Rounded * 2, 1, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha * 255))

		return true
	end

	cancelBut.OnCursorEntered = function(self) self.hover = true end
	cancelBut.OnCursorExited = function(self) self.hover = false end

	cancelBut.DoClick = function()
		MSD.UISnd("msd/ui/click.wav")
		panel.Close()
	end

	-- Accept (hold) button
	local acceptBut = vgui.Create("DButton", child)
	acceptBut:SetText(acceptText or "Accept")
	acceptBut:SetSize(child:GetWide() / 2 - 15, 40)
	acceptBut:SetPos(child:GetWide() / 2 + 5, 130)
	acceptBut.alpha = 0
	acceptBut.holdStart = nil
	acceptBut.holdProgress = 0
	acceptBut.holding = false
	acceptBut.Paint = function(self, w, h)
		MSDX.Draw(MSD.Config.Rounded, 0, 0, w, h, MSD.Theme["l"])

		if self.hover then
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 1)
		else
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 0)
		end

		-- Hold progress
		if self.holding and self.holdStart then
			self.holdProgress = math.Clamp((CurTime() - self.holdStart) / holdTime, 0, 1)

			if self.holdProgress >= 1 then
				self.holding = false
				self.holdStart = nil
				self.holdProgress = 0

				panel.Close()
				acceptFunc()

				return true
			end
		else
			self.holdProgress = Lerp(FrameTime() * 8, self.holdProgress, 0)
		end

		-- Progress bar fill
		if self.holdProgress > 0.01 then
			MSDX.Draw(MSD.Config.Rounded, 0, 0, w * self.holdProgress, h, MSD.ColorAlpha(MSD.Config.MainColor["p"], 80))
		end

		-- Text
		local textColor = self.holdProgress > 0.01 and color_white or MSD.ColorAlpha(MSD.Text["s"], 255 - self.alpha * 255)
		local textColorHover = MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha * 255)

		if self.holdProgress <= 0.01 then
			draw.DrawText(self:GetText(), "MSDFont.22", w / 2, h / 2 - 11, textColor, TEXT_ALIGN_CENTER)
			draw.DrawText(self:GetText(), "MSDFont.22", w / 2, h / 2 - 11, textColorHover, TEXT_ALIGN_CENTER)
		else
			draw.DrawText(self:GetText(), "MSDFont.22", w / 2, h / 2 - 11, color_white, TEXT_ALIGN_CENTER)
		end

		-- Bottom line
		local lineColor = self.holdProgress > 0.01 and MSD.Config.MainColor["p"] or MSD.ColorAlpha(MSD.Text["n"], 255 - self.alpha * 255)
		MSDX.Draw(0, MSD.Config.Rounded, h - 1, w - MSD.Config.Rounded * 2, 1, lineColor)

		if self.holdProgress <= 0.01 then
			MSDX.Draw(0, MSD.Config.Rounded, h - 1, w - MSD.Config.Rounded * 2, 1, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha * 255))
		end

		return true
	end
	acceptBut.OnCursorEntered = function(self) self.hover = true end
	acceptBut.OnCursorExited = function(self)
		self.hover = false
		self.holding = false
		self.holdStart = nil
	end
	acceptBut.OnMousePressed = function(self, keyCode)
		if keyCode == MOUSE_LEFT then
			self.holding = true
			self.holdStart = CurTime()
		end
	end
	acceptBut.OnMouseReleased = function(self, keyCode)
		if keyCode == MOUSE_LEFT then
			self.holding = false
			self.holdStart = nil
		end
	end
	acceptBut.DoClick = function() end

	return panel, child
end

function MSD.InfoTextF1(parent, text, wide, font)
	font = font or "MSDFont.22"
	local panel = vgui.Create("DPanel")
	local ts, _, th = MSD.TextWrap(text, font, wide - 30)

	panel.StaticScale = {
		w = 1,
		fixed_h = th + 10,
		minw = 250,
		minh = th
	}

	panel.Paint = function(self, w, h)
		draw.DrawText(ts, font, 5, 0, MSD.Text.d, TEXT_ALIGN_LEFT)
	end

	parent:AddItem(panel)

	return panel
end

function MSD.InfoTextButton(parent, text, wide, func, font)
	font = font or "MSDFont.22"

	local ts, _, th = MSD.TextWrap(text, font, wide - 30)

	local panel = vgui.Create("DButton")
	panel:SetText("")
	panel.hovered = false
	panel.alpha = 0
	panel.StaticScale = {
		w = 1,
		fixed_h = th + 10,
		minw = 250,
		minh = th
	}

	panel.Paint = function(self, w, h)

		if self.hover then
			MSDX.Draw(0, 0, 0, w, h, MSD.Theme.l)
		end

		MSDX.Draw(0, 0, 0, self.hover and 3 or 2, h, MSD.Config.MainColor["p"])

		draw.DrawText(ts, font, 7, 0, MSD.Text.d, TEXT_ALIGN_LEFT)
		return true
	end

	panel.DoClick = func

	panel.OnCursorEntered = function(self)
		self.hover = true
	end

	panel.OnCursorExited = function(self)
		self.hover = false
	end

	panel.DoRightClick = func

	parent:AddItem(panel)
	return panel
end

-- UI feedback sounds (sound/msd/ui/*.wav), can be turned off in the UI settings
function MSD.UISnd(snd)
	if MSD.Config.UISounds == false then return end

	local vol = MSD.Config.SoundsVolume or 1
	if vol <= 0 then return end

	MSD.PlaySnd(snd, vol)
end

function MSD.PlaySnd(snd, vol)
	sound.PlayFile("sound/" .. snd, "noplay", function(stn, ec, er)
		if (IsValid(stn)) then
			stn:Play()
			stn:SetVolume(vol or 1)
		else
			print("[MSD] Error playing sound", snd, ec, er)
		end
	end)
end

function MSD.Anim(time, ease)
	local ANIM = {}
	ANIM.D = time
	ANIM.P = 0
	ANIM.Value = 0
	ANIM.From = 0
	ANIM.To = 1
	ANIM.E = ease
	ANIM.Stoped = false

	function ANIM:Lerp()
		if self.E and math.ease[ANIM.E] then
			return Lerp(math.ease[ANIM.E](self.P),self.From,self.To)
		end

		return Lerp(self.P,self.From,self.To)
	end

	function ANIM:Reset()
		self.S = CurTime()
		self.Stoped = nil
	end

	function ANIM:Start()
		if not self.Stoped and self.S then return end
		self.S = CurTime()
	end

	function ANIM:Done(reverced) end

	function ANIM:Finish()
		if self.Stoped then return end
		self.Value = self.To
		self.Stoped = true
		ANIM:Done(self.From > self.To)
	end

	function ANIM:Play()
		if not self.S or self.S + self.D < CurTime() then self:Finish() return end
		self.P = ( CurTime() - self.S ) / self.D
		self.Value = self:Lerp()
	end

	function ANIM:Reverse()
		self.From, self.To = self.To, self.From
	end

	function ANIM:FadeIn()
		self.From, self.To = 0, 1
	end

	function ANIM:FadeOut()
		self.From, self.To = 1, 0
	end

	function ANIM:Stop()
		self.S = nil
	end

	function ANIM:InProgress()
		return self.S and self.S + self.D > CurTime()
	end

	return ANIM
end

-- Short human readable duration, in the language selected in the MSD settings
function MSD.NiceTime(seconds)
	local Ln = MSD.GetPhrase

	if seconds == nil then return Ln("time_few_min") end

	if seconds < 60 then
		return Ln("time_sec", math.floor(seconds))
	end

	if seconds < 60 * 60 then
		return Ln("time_min", math.floor(seconds / 60))
	end

	if seconds < 60 * 60 * 24 then
		local t = math.floor(seconds / (60 * 60))
		local m = math.floor((seconds - t * 60 * 60) / 60)

		return Ln("time_hour", t) .. " " .. Ln("time_min", m)
	end

	if seconds < 60 * 60 * 24 * 7 then
		return Ln("time_day", math.floor(seconds / (60 * 60 * 24)))
	end

	if seconds < 60 * 60 * 24 * 365 then
		return Ln("time_week", math.floor(seconds / (60 * 60 * 24 * 7)))
	end

	return Ln("time_year", math.floor(seconds / (60 * 60 * 24 * 365)))
end

function MSD.DropIcon(parent, mat, s, color, func, descr)
	local button = vgui.Create("DButton")

	button.StaticScale = {
		w = s,
		h_w = true,
		minw = 64
	}

	button:SetSize(s, s)
	button:SetText("")
	button.hovered = false
	button.alpha = 0
	button.mat = mat
	button.showdsc = true
	button.descr = descr

	button.Paint = function(self, w, h)

		MSD.DrawTexturedRect(0, 0, w, h, self.mat, color_white)

		surface.SetDrawColor(color)
		surface.DrawOutlinedRect(0,0,w,h,3)

		return true
	end

	button.DoClick = function(...)
		MSD.UISnd("msd/ui/click.wav")
		func(...)
	end

	button.OnCursorEntered = function(self)
		self.hover = true
	end

	button.OnCursorExited = function(self)
		self.hover = false
	end

	button.DoRightClick = function(...)
		MSD.UISnd("msd/ui/click.wav")
		func(...)
	end

	parent:AddItem(button)


	return button
end

-- Left-rounded strip (only the left corners were ever drawn by the old texture-corner version)
function MSD.RoundedBoxEx( bordersize, x, y, w, h, color )
	if ( bordersize <= 0 ) then
		MSDX.Draw( 0, x, y, w, h, color )
		return
	end

	bordersize = math.min( bordersize, math.floor( w / 2 ), math.floor( h / 2 ) )
	MSDX.Draw( bordersize, x, y, bordersize, h, color, MSDX.NO_TR + MSDX.NO_BR )
end