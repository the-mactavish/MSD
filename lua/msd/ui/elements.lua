function MSD.WorkSpacePanel(parent, title, wd, hd, a_ignore)
	if not wd or not hd then
		wd, hd = 1.1, 1.3
	end

	local panel = vgui.Create("DPanel")

	if not a_ignore then
		panel:SetAlpha(0)
		panel:AlphaTo(255, 0.3)
	end

	panel.Paint = function(self, w, h)
		draw.RoundedBox(MSD.Config.Rounded, 0, 0, w, h, MSD.Theme["d"])
		MSD.Blur(self, 3, 5, 255, 50, w, h)
	end

	panel.Close = function()
		panel:AlphaTo(0, 0.3, 0, function()
			panel:Remove()
		end)
	end

	panel.PerformLayout = function(self)
		local children = self:GetChildren()

		for k, v in pairs(children) do
			v:InvalidateLayout()
		end
	end

	parent:AddToWorkSpace(panel)
	local child = vgui.Create("DPanel", panel)
	child:SetSize(math.Clamp(panel:GetWide() / wd, 500, 900), panel:GetTall() / hd)
	child:Center()

	child.Paint = function(self, w, h)
		draw.RoundedBox(MSD.Config.Rounded, 0, 0, w, h, MSD.Theme["d"])
		draw.DrawText(title, "MSDFont.25", 10, 10, color_white, TEXT_ALIGN_LEFT)
	end

	child.PerformLayout = function(self)
		child:Center()

		if child.clsBut then
			child.clsBut:SetPos(child:GetWide() - 38, 5)
		end
	end

	child.clsBut = MSD.IconButton(child, MSD.Icons48.cross, child:GetWide() - 34, 10, 25, nil, MSD.Config.MainColor["r"], function()
		panel.Close()
	end)

	return panel, child
end

function MSD.IconButton(parent, mat, x, y, s, color, color2, func)
	local button = vgui.Create("DButton")

	if x and y then
		button:SetParent(parent)
		button:SetPos(x, y)
	end

	if x == "static" then
		button.StaticScale = {
			w = s,
			fixed_h = s,
			minw = s,
			minh = s
		}
	end

	button:SetSize(s, s)
	button:SetText("")
	button.hovered = false
	button.alpha = 0
	button.mat = mat

	button.Paint = function(self, w, h)
		if self.hover or self.hovered then
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 1)
		else
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 0)
		end

		MSD.DrawTexturedRect(0, 0, w, h, self.mat, MSD.ColorAlpha(color or MSD.Text.l, 255 - self.alpha * 255))

		if self.alpha > 0 then
			MSD.DrawTexturedRect(0, 0, w, h, self.mat, MSD.ColorAlpha(color2 or MSD.Config.MainColor["p"], self.alpha * 255))
		end

		return true
	end

	button.DoClick = func

	button.OnCursorEntered = function(self)
		self.hover = true
	end

	button.OnCursorExited = function(self)
		self.hover = false
	end

	button.DoRightClick = func

	if not x or not y then
		parent:AddItem(button)
	end

	return button
end

function MSD.IconButtonText(parent, text, mat, x, y, s, color, color2, func)
	local button = vgui.Create("DButton")

	if x and y then
		button:SetParent(parent)
		button:SetPos(x, y)
	end

	if x == "static" then
		button.StaticScale = {
			w = s * 2,
			fixed_h = s + 32,
			minw = s * 2,
			minh = s + 16
		}
	end

	button:SetSize(s, s + 32)
	button:SetText(text)
	button.hovered = false
	button.alpha = 0
	button.mat = mat

	button.Paint = function(self, w, h)
		if self.hover or self.hovered then
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 1)
		else
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 0)
		end

		MSD.DrawTexturedRect(w / 2 - s / 2, 0, s, s, self.mat, MSD.ColorAlpha(color or MSD.Text.d, 255 - self.alpha * 255))

		if self.alpha > 0 then
			MSD.DrawTexturedRect(w / 2 - s / 2, 0, s, s, self.mat, MSD.ColorAlpha(color2 or MSD.Config.MainColor["p"], self.alpha * 255))
		end

		draw.DrawText(MSD.TextWrap(self:GetText(), "MSDFont.16", w - 4), "MSDFont.16", w / 2, s, color or MSD.Text.d, TEXT_ALIGN_CENTER)

		return true
	end

	button.DoClick = func

	button.OnCursorEntered = function(self)
		self.hover = true
	end

	button.OnCursorExited = function(self)
		self.hover = false
	end

	button.DoRightClick = func

	if not x or not y then
		parent:AddItem(button)
	end

	return button
end

function MSD.IconButtonBG(parent, mat, x, y, s, color, color2, func)
	local button = vgui.Create("DButton")
	button:SetSize(s, s)

	if x then
		button:SetParent(parent)
		button:SetPos(x, y)
	end

	button:SetText("")
	button.hovered = false
	button.alpha = 0
	button.mat = mat

	button.Paint = function(self, w, h)
		if self.hover or self.hovered then
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 1)
		else
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 0)
		end

		draw.RoundedBox(MSD.Config.Rounded, 0, 0, w, h, MSD.Theme.d)

		if self.alpha > 0 then
			draw.RoundedBox(MSD.Config.Rounded, 0, 0, w, h, MSD.ColorAlpha(MSD.Config.MainColor["p"], 255 * self.alpha))
		end

		MSD.DrawTexturedRect(w / 2 - 12, h / 2 - 12, 24, 24, self.mat, color_white)

		return true
	end

	button.DoClick = func

	button.OnCursorEntered = function(self)
		self.hover = true
	end

	button.OnCursorExited = function(self)
		self.hover = false
	end

	button.DoRightClick = func

	if not x then
		parent:AddItem(button)
	end

	return button
end

function MSD.MenuButton(parent, mat, x, y, sw, sh, text, func, rfunc, small)
	local button = vgui.Create("DButton")
	button:SetSize(sw, sh)

	if x then
		button:SetParent(parent)
		button:SetPos(x, y)
	end

	button:SetText("")
	button.hovered = false
	button.alpha = 0
	button.mat = mat

	button.Paint = function(self, w, h)
		local icon_size = small and 16 or h - 20
		if self.hovered then
			draw.RoundedBox(MSD.Config.Rounded, 0, 0, w, h, MSD.Theme["d"])
		end

		if self.hover then
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 1)
		else
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 0)
		end
		local rf = MSD.Config.Rounded
		if self.alpha > 0.01 then
			draw.RoundedBox(rf, rf, rf, math.max((w - rf * 2) * self.alpha, icon_size + 12 - rf), h - rf * 2, MSD.ColorAlpha(MSD.Config.MainColor["p"], 255 * self.alpha))
		end

		MSD.DrawTexturedRect(small and h / 2 - rf or 10, small and h / 2 - rf or 10, icon_size, icon_size, self.mat, color_white)
		draw.DrawText(text, "MSDFont.22", 55, 12, color_white, TEXT_ALIGN_LEFT)

		return true
	end

	button.DoClick = func

	button.OnCursorEntered = function(self)
		self.hover = true
	end

	button.OnCursorExited = function(self)
		self.hover = false
	end

	button.DoRightClick = func

	if not x then
		parent:AddItem(button)
	end

	return button
end

function MSD.MenuButtonTop(parent, mat, x, y, sw, sh, text, func, rfunc, small)
	local button = vgui.Create("DButton")

	if sw == "auto" and text ~= "" then
		surface.SetFont("MSDFont.22")
		local tw = surface.GetTextSize(text)
		button:SetSize(70 + tw, sh)
	elseif sw == "auto" and text == "" then
		button:SetSize(sh, sh)
	else
		button:SetSize(sw, sh)
	end

	if x then
		button:SetParent(parent)
		button:SetPos(x, y)
	end

	button:SetText("")
	button.hovered = false
	button.alpha = 0
	button.mat = mat

	button.Paint = function(self, w, h)
		local icon_size = small and 16 or h - 20
		local rf = MSD.Config.Rounded

		if self.hovered then
			draw.RoundedBox(rf, 0, 0, w, h, MSD.Theme["d"])
		end

		if self.hover then
			self.alpha = Lerp(FrameTime() * 7, self.alpha, 1)
		else
			self.alpha = Lerp(FrameTime() * 7, self.alpha, 0)
		end

		if self.alpha > 0.01 then
			draw.RoundedBoxEx(rf, rf, h - 5, w - rf * 2, 5 + rf, MSD.ColorAlpha(MSD.Config.MainColor["p"], 255 * self.alpha), true, true, false, false)
		end

		MSD.DrawTexturedRect(small and h / 2 - rf or 10, small and h / 2 - rf or 10, icon_size, icon_size, self.mat, color_white)
		draw.DrawText(text, "MSDFont.22", 55, 12, color_white, TEXT_ALIGN_LEFT)

		return true
	end

	button.DoClick = func

	button.OnCursorEntered = function(self)
		self.hover = true
	end

	button.OnCursorExited = function(self)
		self.hover = false
	end

	button.DoRightClick = func

	if not x then
		parent:AddItem(button)
	end

	return button
end

function MSD.Header(parent, text, back, icon, align)
	local panel = vgui.Create("DPanel")

	panel.StaticScale = {
		w = 1,
		fixed_h = 50,
		minw = 250,
		minh = 50
	}

	panel.Paint = function(self, w, h)
		draw.RoundedBox(MSD.Config.Rounded, 0, 0, w, h, MSD.Theme["l"])
		draw.DrawText(text, "MSDFont.25", align and 50 or w / 2, 12, color_white, align and TEXT_ALIGN_LEFT or TEXT_ALIGN_CENTER)
	end

	parent:AddItem(panel)

	if back then
		MSD.IconButton(panel, icon or MSD.Icons48.back, 13, 13, 24, nil, nil, back)
	end

	return panel
end

function MSD.InfoHeader(parent, text, wd)
	local panel = vgui.Create("DPanel")
	wd = wd or 1
	panel.StaticScale = {
		w = wd,
		fixed_h = 25,
		minw = 250,
		minh = 25
	}

	panel.Paint = function(self, w, h)
		draw.RoundedBox(MSD.Config.Rounded, 0, 0, w, h, MSD.Theme["l"])
		draw.DrawText(text, "MSDFont.20", 5, h / 2 - 11, color_white, TEXT_ALIGN_LEFT)
	end

	parent:AddItem(panel)

	return panel
end

function MSD.InfoText(parent, text)
	local panel = vgui.Create("DPanel")

	panel.StaticScale = {
		w = 1,
		fixed_h = 25,
		minw = 250,
		minh = 25
	}

	panel.Paint = function(self, w, h)
		local ts, _, th = MSD.TextWrap(text, "MSDFont.18", w - 10)
		draw.DrawText(ts, "MSDFont.18", 5, 5, MSD.Text.d, TEXT_ALIGN_LEFT)

		if th > h then
			self.StaticScale.fixed_h = th + 10
		end
	end

	parent:AddItem(panel)

	return panel
end

function MSD.TextEntry(parent, x, y, w, h, text, label, value, func, auto_update, focuse_update, multi, num)
	local Entry = vgui.Create("DTextEntry")

	if x and y then
		Entry:SetParent(parent)
		Entry:SetPos(x, y)
	end

	if x == "static" then
		Entry.StaticScale = {
			w = w,
			fixed_h = h,
			minw = 50,
			minh = h
		}
	else
		Entry:SetSize(w, h)
	end

	Entry:SetNumeric(num or false)
	Entry:SetText("")
	Entry:SetFont("MSDFont.22")
	Entry:SetMultiline(multi or false)
	Entry.alpha = 0
	Entry:SetDrawLanguageID(false)

	Entry.Paint = function(self, wd, hd)
		if self:HasFocus() then
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 255)
		else
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 0)
		end
		local rf = MSD.Config.Rounded
		draw.RoundedBox(rf, 0, 0, wd, hd, MSD.Theme["l"])
		draw.RoundedBox(0, rf, hd - 1, wd - rf * 2, 1, MSD.ColorAlpha(MSD.Text["n"], 255 - self.alpha))
		draw.RoundedBox(0, rf, hd - 1, wd - rf * 2, 1, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha))

		if self:GetValue() == "" then
			draw.SimpleText(text, "MSDFont.22", 3, multi and 1 or hd / 2 - 10, MSD.ColorAlpha(MSD.Text["d"], 120), TEXT_ALIGN_LEFT)
		end

		if label and not self.error then
			draw.SimpleText(label, "MSDFont.16", 3, 0, MSD.ColorAlpha(MSD.Text["d"], 120), TEXT_ALIGN_LEFT)
		end

		if self.error then
			draw.SimpleText(self.error, "MSDFont.16", 3, 0, MSD.Config.MainColor["r"], TEXT_ALIGN_LEFT)
		end

		self:DrawTextEntryText(self.error and MSD.Config.MainColor["rd"] or MSD.Text["l"], MSD.Config.MainColor["p"], MSD.Text["d"])
	end

	Entry.OnEnter = func

	if focuse_update then
		Entry.OnFocusChanged = function(self, gained)
			if not gained then
				func(self, self:GetValue())
			end
		end
	end

	Entry:SetText(value or "")

	if auto_update then
		Entry:SetUpdateOnType(true)

		function Entry:OnValueChange(vl)
			if func then
				func(self, vl)
			end
		end
	end

	if not x or not y then
		parent:AddItem(Entry)
	end

	return Entry
end

function MSD.VectorDisplay(parent, x, y, w, h, text, vector, func)
	local Entry = vgui.Create("DButton")
	Entry:SetText("")
	if x and y then
		Entry:SetParent(parent)
		Entry:SetPos(x, y)
	end

	if x == "static" then
		Entry.StaticScale = { w = w, fixed_h = h, minw = 50, minh = h }
	else
		Entry:SetSize(w, h)
	end
	Entry.vector = vector or Vector(0, 0, 0)
	Entry.Paint = function(self, sw, sh)
		draw.RoundedBox(MSD.Config.Rounded, 0, 0, sw, sh, MSD.Theme["l"])
		draw.RoundedBox(0, MSD.Config.Rounded, sh - 1, sw - MSD.Config.Rounded * 2, 1, MSD.Text["n"])

		if text then
			draw.SimpleText(text, "MSDFont.16", 3, 0, MSD.ColorAlpha(MSD.Text["d"], 120), TEXT_ALIGN_LEFT)
		end

		draw.SimpleText("x: " .. self.vector.x .. " y: " .. self.vector.y .. " z: " .. self.vector.z, "MSDFont.22", 3, h / 2 - 10, MSD.Text["d"], TEXT_ALIGN_LEFT)
	end
	Entry.DoClick = function(self)

		if self.rebuild or self.disabled then return end
		self.rebuild = true

		if IsValid(self.cpanel) then
			self.cpanel:Remove()
			self.cpanel = nil
			self:SizeTo(self:GetWide(), h, 0.2, 0, -1, function()
				Entry.StaticScale = { w = w, fixed_h = h, minw = 50, minh = h}
				parent:Rebuild()
				self.rebuild = nil
			end)
			return
		end

		Entry.StaticScale = {
			w = w,
			fixed_h = h + 50,
			minw = 50,
			minh = h + 50
		}
		parent:Rebuild()
		self:SetSize(self:GetWide(), h)
		self:SizeTo(self:GetWide(), h + 50, 0.2, 0, -1, function()
			self.rebuild = nil
		end)
		local mpw = self:GetWide()
		self.cpanel = vgui.Create("DPanel", self)
		self.cpanel:SetSize(mpw, 50)
		self.cpanel:SetPos(0, h)
		self.cpanel.Paint = function() end

		self.x = MSD.TextEntry(self.cpanel, 0, 0, mpw / 3, 45, "", "X", self.vector.x, function(sp, value)
			value = tonumber(value) or 0
			self.vector.x = value
			func(self.vector, self)
		end, true, nil, false, true)

		self.y = MSD.TextEntry(self.cpanel, mpw / 3, 0, mpw / 3, 45, "", "Y", self.vector.y, function(sp, value)
			value = tonumber(value) or 0
			self.vector.y = value
			func(self.vector, self)
		end, true, nil, false, true)

		self.z = MSD.TextEntry(self.cpanel, mpw - mpw / 3, 0, mpw / 3, 45, "", "Z", self.vector.z, function(sp, value)
			value = tonumber(value) or 0
			self.vector.z = value
			func(self.vector, self)
		end, true, nil, false, true)
	end

	if not x or not y then
		parent:AddItem(Entry)
	end

	return Entry
end

function MSD.AngleDisplay(parent, x, y, w, h, text, angle, func)
	local Entry = vgui.Create("DButton")
	Entry:SetText("")
	if x and y then
		Entry:SetParent(parent)
		Entry:SetPos(x, y)
	end

	if x == "static" then
		Entry.StaticScale = { w = w, fixed_h = h, minw = 50, minh = h }
	else
		Entry:SetSize(w, h)
	end

	Entry.angle = angle or Angle(0, 0, 0)
	Entry.Paint = function(self, sw, sh)
		draw.RoundedBox(MSD.Config.Rounded, 0, 0, sw, h, MSD.Theme["l"])
		draw.RoundedBox(0, MSD.Config.Rounded, sh - 1, sw - MSD.Config.Rounded * 2, 1, MSD.Text["n"])

		if text then
			draw.SimpleText(text, "MSDFont.16", 3, 0, MSD.ColorAlpha(MSD.Text["d"], 120), TEXT_ALIGN_LEFT)
		end

		draw.SimpleText("p: " .. self.angle.p .. " y: " .. self.angle.y .. " r: " .. self.angle.r, "MSDFont.22", 3, h / 2 - 10, MSD.Text["d"], TEXT_ALIGN_LEFT)
	end
	Entry.DoClick = function(self)

		if self.rebuild or self.disabled then return end
		self.rebuild = true

		if IsValid(self.cpanel) then
			self.cpanel:Remove()
			self.cpanel = nil
			self:SizeTo(self:GetWide(), h, 0.2, 0, -1, function()
				Entry.StaticScale = { w = w, fixed_h = h, minw = 50, minh = h}
				parent:Rebuild()
				self.rebuild = nil
			end)
			return
		end

		Entry.StaticScale = {
			w = w,
			fixed_h = h + 50,
			minw = 50,
			minh = h + 50
		}
		parent:Rebuild()
		self:SetSize(self:GetWide(), h)
		self:SizeTo(self:GetWide(), h + 50, 0.2, 0, -1, function()
			self.rebuild = nil
		end)
		local mpw = self:GetWide()
		self.cpanel = vgui.Create("DPanel", self)
		self.cpanel:SetSize(mpw, 50)
		self.cpanel:SetPos(0, h)
		self.cpanel.Paint = function() end

		self.x = MSD.TextEntry(self.cpanel, 0, 0, mpw / 3, 45, "", "X", self.angle.p, function(sp, value)
			value = tonumber(value) or 0
			self.angle.p = value
			func(self.angle, self)
		end, true, nil, false, true)

		self.y = MSD.TextEntry(self.cpanel, mpw / 3, 0, mpw / 3, 45, "", "Y", self.angle.y, function(sp, value)
			value = tonumber(value) or 0
			self.angle.y = value
			func(self.angle, self)
		end, true, nil, false, true)

		self.z = MSD.TextEntry(self.cpanel, mpw - mpw / 3, 0, mpw / 3, 45, "", "Z", self.angle.r, function(sp, value)
			value = tonumber(value) or 0
			self.angle.r = value
			func(self.angle, self)
		end, true, nil, false, true)
	end

	if not x or not y then
		parent:AddItem(Entry)
	end

	return Entry
end

function MSD.ColorSelectBut(parent, x, y, w, h, color, func)
	local button = vgui.Create("DButton")
	button:SetText("")

	if x and y then
		button:SetParent(parent)
		button:SetPos(x, y)
	end

	if x == "static" then
		button.StaticScale = {
			w = w,
			fixed_h = h,
			minw = 10,
			minh = h
		}
	else
		button:SetSize(w, h)
	end

	button.alpha = 0

	button.Paint = function(self, wd, hd)
		draw.RoundedBox(MSD.Config.Rounded, 0, 0, wd, hd, color)

		if (self.hover or self.hovered) and not self.disabled then
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 1)
		else
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 0)
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
		func(self)
	end

	if not x or not y then
		parent:AddItem(button)
	end

	return button
end

function MSD.Binder(parent, x, y, w, h, text, var, func)
	local binder = vgui.Create("DBinder")

	if x and y then
		binder:SetParent(parent)
		binder:SetPos(x, y)
	end

	if x == "static" then
		binder.StaticScale = {
			w = w,
			fixed_h = h,
			minw = 150,
			minh = h
		}
	else
		binder:SetSize(w, h)
	end

	binder:SetValue(var)
	binder.alpha = 0

	binder.Paint = function(self, wd, hd)
		local rf = MSD.Config.Rounded
		draw.RoundedBox(rf, 0, 0, wd, hd, MSD.Theme["l"])

		if (self.hover or self.hovered or self.Trapping) and not self.disabled then
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 1)
		else
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 0)
		end

		draw.DrawText(text, "MSDFont.22", 5, hd / 2 - 11, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha * 255), TEXT_ALIGN_LEFT)
		draw.DrawText(text, "MSDFont.22", 5, hd / 2 - 11, MSD.ColorAlpha(self.disabled and MSD.Text["n"] or MSD.Text["s"], 255 - self.alpha * 255), TEXT_ALIGN_LEFT)
		draw.DrawText(string.upper(self:GetText()), "MSDFont.22", wd - wd / 3 / 2, hd / 2 - 11, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha * 255), TEXT_ALIGN_CENTER)
		draw.DrawText(string.upper(self:GetText()), "MSDFont.22", wd - wd / 3 / 2, hd / 2 - 11, MSD.ColorAlpha(self.disabled and MSD.Text["n"] or MSD.Text["s"], 255 - self.alpha * 255), TEXT_ALIGN_CENTER)
		draw.RoundedBox(0, rf, hd - 1, (wd / 3) * 2 - 5 - rf, 1, MSD.ColorAlpha(MSD.Text["n"], 255 - self.alpha * 255))
		draw.RoundedBox(0, rf, hd - 1, (wd / 3) * 2 - 5 - rf, 1, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha * 255))
		draw.RoundedBox(0, wd - wd / 3, hd - 1, wd / 3 - rf, 1, MSD.ColorAlpha(MSD.Text["n"], 255 - self.alpha * 255))
		draw.RoundedBox(0, wd - wd / 3, hd - 1, wd / 3 - rf, 1, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha * 255))

		return true
	end

	binder.OnCursorEntered = function(self)
		self.hover = true
	end

	binder.OnCursorExited = function(self)
		self.hover = false
	end

	function binder:OnChange(num)
		if num > 106 and num < 114 then
			binder:SetValue(var)
		else
			func(num)
		end
	end

	if not x or not y then
		parent:AddItem(binder)
	end
end

function MSD.ButtonScr(parent, x, y, w, h, text, func, al_left)
	local button = vgui.Create("DButton")
	button:SetText(text)

	if x and y then
		button:SetParent(parent)
		button:SetPos(x, y)
	end

	if x == "static" then
		button.StaticScale = {
			w = w,
			h_w = true,
			minw = 150
		}
	else
		button:SetSize(w, h)
	end

	button.alpha = 0

	button.Paint = function(self, wd, hd)
		draw.RoundedBox(MSD.Config.Rounded, 0, 0, wd, hd, MSD.Theme["l"])

		if (self.hover or self.hovered) and not self.disabled then
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 1)
		else
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 0)
		end

		draw.DrawText(MSD.TextWrap(self:GetText(), "MSDFont.18", w - 20), "MSDFont.18", al_left and 5 or wd / 2, hd / 2 - 11, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha * 255), al_left and TEXT_ALIGN_LEFT or TEXT_ALIGN_CENTER)
		draw.DrawText(MSD.TextWrap(self:GetText(), "MSDFont.18", w - 20), "MSDFont.18", al_left and 5 or wd / 2, hd / 2 - 11, MSD.ColorAlpha(self.disabled and MSD.Text["n"] or MSD.Text["s"], 255 - self.alpha * 255), al_left and TEXT_ALIGN_LEFT or TEXT_ALIGN_CENTER)
		draw.RoundedBox(MSD.Config.Rounded, 0, hd - 1, wd, 1, MSD.ColorAlpha(MSD.Text["l"], 255 - self.alpha * 255))
		draw.RoundedBox(MSD.Config.Rounded, 0, hd - 1, wd, 1, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha * 255))

		return true
	end

	button.OnCursorEntered = function(self)
		self.hover = true
	end

	button.OnCursorExited = function(self)
		self.hover = false
	end

	button.DoClick = function(self)
		func(self)
	end

	if not x or not y then
		parent:AddItem(button)
	end

	return button
end

function MSD.Button(parent, x, y, w, h, text, func, al_left)
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

	button.Paint = function(self, wd, hd)
		draw.RoundedBox(MSD.Config.Rounded, 0, 0, wd, hd, MSD.Theme["l"])

		if (self.hover or self.hovered) and not self.disabled then
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 1)
		else
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 0)
		end

		draw.DrawText(self:GetText(), "MSDFont.22", al_left and 5 or wd / 2, hd / 2 - 11, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha * 255), al_left and TEXT_ALIGN_LEFT or TEXT_ALIGN_CENTER)
		draw.DrawText(self:GetText(), "MSDFont.22", al_left and 5 or wd / 2, hd / 2 - 11, MSD.ColorAlpha(self.disabled and MSD.Text["n"] or MSD.Text["s"], 255 - self.alpha * 255), al_left and TEXT_ALIGN_LEFT or TEXT_ALIGN_CENTER)
		draw.RoundedBox(0, MSD.Config.Rounded, hd - 1, wd - MSD.Config.Rounded * 2, 1, MSD.ColorAlpha(MSD.Text["n"], 255 - self.alpha * 255))
		draw.RoundedBox(0, MSD.Config.Rounded, hd - 1, wd - MSD.Config.Rounded * 2, 1, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha * 255))

		return true
	end

	button.OnCursorEntered = function(self)
		self.hover = true
	end

	button.OnCursorExited = function(self)
		self.hover = false
	end

	button.DoClick = function(self)
		func(self)
	end

	if not x or not y then
		parent:AddItem(button)
	end

	return button
end

function MSD.ButtonSimple(parent, x, y, w, h, text, fsize, func)
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

	button.Paint = function(self, wd, hd)
		if self.Check and self.Check() and not self.disabled then
			draw.RoundedBox(MSD.Config.Rounded, 0, 0, wd, hd, MSD.Theme["d"])
		end

		if (self.hover or self.hovered) and not self.disabled then
			draw.DrawText(self:GetText(), "MSDFont." .. fsize, 5, hd / 2 - fsize / 2, MSD.Config.MainColor["p"], TEXT_ALIGN_LEFT)
		else
			draw.DrawText(self:GetText(), "MSDFont." .. fsize, 5, hd / 2 - fsize / 2, self.disabled and MSD.Text["n"] or MSD.Text["s"], TEXT_ALIGN_LEFT)
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
		func(self)
	end

	if not x or not y then
		parent:AddItem(button)
	end

	return button
end

function MSD.NumberWang(parent, x, y, w, h, min, max, val, label, func)
	local button = vgui.Create("DNumberWang")
	button:SetValue(val)

	if x and y then
		button:SetParent(parent)
		button:SetPos(x, y)
	end

	if x == "static" then
		button.StaticScale = {
			w = w,
			fixed_h = h,
			minw = 50,
			minh = h
		}
	else
		button:SetSize(w, h)
	end

	button.alpha = 0
	button:SetFont("MSDFont.22")
	button:SetMin(min)
	button:SetMax(max)

	button.Paint = function(self, wd, hd)
		if self:HasFocus() then
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 255)
		else
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 0)
		end

		draw.RoundedBox(MSD.Config.Rounded, 0, 0, wd, hd, MSD.Theme["l"])
		draw.RoundedBox(0, MSD.Config.Rounded, hd - 1, wd - MSD.Config.Rounded * 2, 1, MSD.ColorAlpha(MSD.Text["n"], 255 - self.alpha))
		draw.RoundedBox(0, MSD.Config.Rounded, hd - 1, wd - MSD.Config.Rounded * 2, 1, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha))

		if label and not self.error then
			draw.SimpleText(label, "MSDFont.16", 3, 0, MSD.ColorAlpha(MSD.Text["d"], 120), TEXT_ALIGN_LEFT)
		end

		if self.error then
			draw.SimpleText(self.error, "MSDFont.16", 3, 0, MSD.Config.MainColor["r"], TEXT_ALIGN_LEFT)
		end

		self:DrawTextEntryText(self.error and MSD.Config.MainColor["rd"] or MSD.Text["l"], MSD.Config.MainColor["p"], MSD.Text["d"])

		return true
	end

	button.OnValueChanged = function(self)
		func(self)
	end

	if not x or not y then
		parent:AddItem(button)
	end

	return button
end

function MSD.ButtonIcon(parent, x, y, w, h, text, icon, func, func2, color, color2, drawf)
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
			minw = 50,
			minh = h
		}
	else
		button:SetSize(w, h)
	end

	button.alpha = 0

	button.Paint = function(self, wd, hd)
		draw.RoundedBox(MSD.Config.Rounded, 0, 0, wd, hd, MSD.Theme["l"])

		if drawf then drawf(self, wd, hd) end

		if (self.hover or self.hovered) and not self.disabled then
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 1)
		else
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 0)
		end

		draw.DrawText(self:GetText(), "MSDFont.22", 48, hd / 2 - 11, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha * 255), TEXT_ALIGN_LEFT)
		draw.DrawText(self:GetText(), "MSDFont.22", 48, hd / 2 - 11, MSD.ColorAlpha(self.disabled and MSD.Text["n"] or MSD.Text["s"], 255 - self.alpha * 255), TEXT_ALIGN_LEFT)
		draw.RoundedBox(0, MSD.Config.Rounded, hd - 1, wd - MSD.Config.Rounded * 2, 1, MSD.ColorAlpha(color or MSD.Text["n"], 255 - self.alpha * 255))
		draw.RoundedBox(0, MSD.Config.Rounded, hd - 1, wd - MSD.Config.Rounded * 2, 1, MSD.ColorAlpha(color2 or MSD.Config.MainColor["p"], self.alpha * 255))
		MSD.DrawTexturedRect(12, hd / 2 - 12, 24, 24, icon, MSD.ColorAlpha(color or MSD.Text["l"], 255 - self.alpha * 255))
		MSD.DrawTexturedRect(12, hd / 2 - 12, 24, 24, icon, MSD.ColorAlpha(color2 or MSD.Config.MainColor["p"], self.alpha * 255))

		return true
	end

	if func then
		button.OnCursorEntered = function(self)
			self.hover = true
		end

		button.OnCursorExited = function(self)
			self.hover = false
		end

		button.DoClick = function(self)
			func(self)
		end
	end

	if func2 then
		button.DoRightClick = function(self)
			func2(self)
		end
	end

	if not x or not y then
		parent:AddItem(button)
	end

	return button
end

function MSD.ButtonIconText(parent, x, y, w, h, text, text2, icon, func, func2, color)
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
			minw = 50,
			minh = h
		}
	else
		button:SetSize(w, h)
	end

	button.alpha = 0
	button.text = text2

	button.Paint = function(self, wd, hd)
		draw.RoundedBox(MSD.Config.Rounded, 0, 0, wd, hd, MSD.Theme["l"])

		if (self.hover or self.hovered) and not self.disabled then
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 1)
		else
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 0)
		end

		draw.DrawText(self.text, "MSDFont.22", wd - 5, hd / 2 - 11, self.disabled and MSD.Text["n"] or MSD.Text["s"], TEXT_ALIGN_RIGHT)
		draw.DrawText(self:GetText(), "MSDFont.22", 48, hd / 2 - 11, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha * 255), TEXT_ALIGN_LEFT)
		draw.DrawText(self:GetText(), "MSDFont.22", 48, hd / 2 - 11, MSD.ColorAlpha(self.disabled and MSD.Text["n"] or MSD.Text["s"], 255 - self.alpha * 255), TEXT_ALIGN_LEFT)
		draw.RoundedBox(0, MSD.Config.Rounded, hd - 1, wd - MSD.Config.Rounded * 2, 1, MSD.ColorAlpha(color or MSD.Text["n"], 255 - self.alpha * 255))
		draw.RoundedBox(0, MSD.Config.Rounded, hd - 1, wd - MSD.Config.Rounded * 2, 1, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha * 255))
		MSD.DrawTexturedRect(12, hd / 2 - 12, 24, 24, icon, MSD.ColorAlpha(color or MSD.Text["l"], 255 - self.alpha * 255))
		MSD.DrawTexturedRect(12, hd / 2 - 12, 24, 24, icon, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha * 255))

		return true
	end

	if func then
		button.OnCursorEntered = function(self)
			self.hover = true
		end

		button.OnCursorExited = function(self)
			self.hover = false
		end

		button.DoClick = function(self)
			func(self)
		end
	end

	if func2 then
		button.DoRightClick = function(self)
			func2(self)
		end
	end

	if not x or not y then
		parent:AddItem(button)
	end

	return button
end

function MSD.VolumeSlider(parent, x, y, w, h, text, var, func, cl)
	local button = vgui.Create("DButton")
	button:SetText("")

	if x and y then
		button:SetParent(parent)
		button:SetPos(x, y)
	end

	if x == "static" then
		button.StaticScale = {
			w = w,
			fixed_h = h,
			minw = 50,
			minh = h
		}
	else
		button:SetSize(w, h)
	end

	button.var = var or 1
	button.value = var or 1
	button.alpha = 0
	button.disabled = false

	button.Paint = function(self, wd, hd)
		draw.RoundedBox(MSD.Config.Rounded, 0, 0, wd, hd, MSD.Theme["l"])

		if (self.hover or self.hovered) and not self.disabled then
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 1)
		else
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 0)
		end

		draw.DrawText(text, "MSDFont.22", 3, hd / 2 - 11, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha * 255), TEXT_ALIGN_LEFT)
		draw.DrawText(text, "MSDFont.22", 3, hd / 2 - 11, MSD.ColorAlpha(self.disabled and MSD.Text["n"] or MSD.Text["s"], 255 - self.alpha * 255), TEXT_ALIGN_LEFT)
		self.var = Lerp(FrameTime() * 7, self.var, self.value)
		draw.RoundedBox(MSD.Config.Rounded, wd - wd / 2 + 10, hd / 2 - 10, wd / 2 - 20, 20, MSD.Theme["d"])

		if self.disabled then
			draw.DrawText(MSD.GetPhrase("disabled"), "MSDFont.16", wd - (wd / 2) / 2, hd / 2 - 8, MSD.Text["n"], TEXT_ALIGN_CENTER)
		else
			draw.RoundedBox(MSD.Config.Rounded, wd - wd / 2 + 10, hd / 2 - 10,  math.max((wd / 2 - 19) * self.var, 16), 20, cl or MSD.Config.MainColor["p"])
			draw.DrawText(math.Round(self.value * 100) .. "%", "MSDFont.16", wd - (wd / 2) / 2, hd / 2 - 8, MSD.Text["s"], TEXT_ALIGN_CENTER)
		end
	end

	button.OnCursorEntered = function(self)
		self.hover = true
	end

	button.OnCursorExited = function(self)
		self.hover = false
	end

	button.DoClick = function(self)
		if self.disabled then return end
		local wd = self:GetWide()
		local mx, my = gui.MousePos()
		mx, my = self:ScreenToLocal(mx, my)

		if mx < wd - wd / 2 + 10 then
			self.value = 0
		elseif mx > wd - 10 then
			self.value = 1
		else
			mx = mx - ((wd - wd / 2) + 10)
			mx = mx / ((wd / 2) - 20)
			self.value = mx
		end

		self.value = math.Round(self.value, 2)
		func(self, self.value)
	end

	if not x or not y then
		parent:AddItem(button)
	end

	return button
end

function MSD.VolumeScale(parent, x, y, w, h, text, var, func, cl)
	local button = vgui.Create("DButton")
	button:SetText("")

	if x and y then
		button:SetParent(parent)
		button:SetPos(x, y)
	end

	if x == "static" then
		button.StaticScale = {
			w = w,
			fixed_h = h,
			minw = 50,
			minh = h
		}
	else
		button:SetSize(w, h)
	end

	button.var = var or 1
	button.value = var or 1
	button.alpha = 0
	button.disabled = false

	button.Paint = function(self, wd, hd)
		draw.RoundedBox(MSD.Config.Rounded, 0, 0, wd, hd, MSD.Theme["l"])

		if (self.hover or self.hovered) and not self.disabled then
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 1)
		else
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 0)
		end

		draw.DrawText(text, "MSDFont.22", 3, hd / 2 - 11, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha * 255), TEXT_ALIGN_LEFT)
		draw.DrawText(text, "MSDFont.22", 3, hd / 2 - 11, MSD.ColorAlpha(self.disabled and MSD.Text["n"] or MSD.Text["s"], 255 - self.alpha * 255), TEXT_ALIGN_LEFT)
		self.var = Lerp(FrameTime() * 7, self.var, self.value)
		draw.RoundedBox(MSD.Config.Rounded, wd - wd / 2 + 10, hd / 2 - 10, wd / 2 - 20, 20, MSD.Theme["d"])

		if self.disabled then
			draw.DrawText(MSD.GetPhrase("disabled"), "MSDFont.16", wd - (wd / 2) / 2, hd / 2 - 8, MSD.Text["n"], TEXT_ALIGN_CENTER)
		else
			draw.RoundedBox(MSD.Config.Rounded, wd - wd / 2 + 10, hd / 2 - 10, (wd / 2 - 19) * ( self.var / 2), 20, cl or MSD.Config.MainColor["p"])
			draw.DrawText(math.Round(self.value * 100) .. "%", "MSDFont.16", wd - (wd / 2) / 2, hd / 2 - 8, MSD.Text["s"], TEXT_ALIGN_CENTER)
		end
	end

	button.OnCursorEntered = function(self)
		self.hover = true
	end

	button.OnCursorExited = function(self)
		self.hover = false
	end

	button.DoClick = function(self)
		if self.disabled then return end
		local wd = self:GetWide()
		local mx, my = gui.MousePos()
		mx, my = self:ScreenToLocal(mx, my)

		if mx < wd - wd / 2 + 10 then
			self.value = 1
		elseif mx > wd - 10 then
			self.value = 2
		else
			mx = mx - ((wd - wd / 2) + 10)
			mx = mx / ((wd / 2) - 20) * 2
			self.value = math.Clamp(mx, 0.01, 2)
		end

		self.value = math.Round(self.value, 2)
		func(self, self.value)
	end

	if not x or not y then
		parent:AddItem(button)
	end

	return button
end

function MSD.BoolSlider(parent, x, y, w, h, text, var, func)
	local button = vgui.Create("DButton")
	button:SetText("")

	if x and y then
		button:SetParent(parent)
		button:SetPos(x, y)
	end

	if x == "static" then
		button.StaticScale = {
			w = w,
			fixed_h = h,
			minw = 50,
			minh = h
		}
	else
		button:SetSize(w, h)
	end

	button.var = var or false
	button.pos = var and 1 or 0
	button.alpha = 0
	button.disabled = false

	button.Paint = function(self, wd, hd)
		draw.RoundedBox(MSD.Config.Rounded, 0, 0, wd, hd, MSD.Theme["l"])

		if (self.hover or self.hovered) and not self.disabled then
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 1)
		else
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 0)
		end

		draw.DrawText(text, "MSDFont.22", 3, hd / 2 - 11, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha * 255), TEXT_ALIGN_LEFT)
		draw.DrawText(text, "MSDFont.22", 3, hd / 2 - 11, MSD.ColorAlpha(self.disabled and MSD.Text["n"] or MSD.Text["s"], 255 - self.alpha * 255), TEXT_ALIGN_LEFT)

		if self.var then
			self.pos = Lerp(0.1, self.pos, 1)
		else
			self.pos = Lerp(0.1, self.pos, 0)
		end

		draw.RoundedBox(MSD.Config.Rounded, wd - 75, hd / 2 - 10, 68, 20, MSD.Theme["d"])

		if self.disabled then
			draw.DrawText(MSD.GetPhrase("disabled"), "MSDFont.16", wd - 40, hd / 2 - 8, MSD.Text["n"], TEXT_ALIGN_CENTER)
		else
			draw.DrawText(MSD.GetPhrase("off"), "MSDFont.16", wd - 25, hd / 2 - 8, MSD.ColorAlpha(MSD.Text["s"], 255 - self.pos * 255), TEXT_ALIGN_CENTER)
			draw.DrawText(MSD.GetPhrase("on"), "MSDFont.16", wd - 60, hd / 2 - 8, MSD.ColorAlpha(MSD.Text["s"], self.pos * 255), TEXT_ALIGN_CENTER)
			draw.RoundedBox(MSD.Config.Rounded, wd - 75 + self.pos * 35, hd / 2 - 10, 34, 20, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.pos * 255))
			draw.RoundedBox(MSD.Config.Rounded, wd - 75 + self.pos * 35, hd / 2 - 10, 34, 20, MSD.ColorAlpha(MSD.Text["n"], 255 - self.pos * 255))
		end
	end

	button.OnCursorEntered = function(self)
		self.hover = true
	end

	button.OnCursorExited = function(self)
		self.hover = false
	end

	button.DoClick = function(self)
		if self.disabled then return end
		self.var = not self.var
		func(self, self.var)
	end

	if not x or not y then
		parent:AddItem(button)
	end

	return button
end

function MSD.DTextSlider(parent, x, y, w, h, text1, text2, var, func)
	local button = vgui.Create("DButton")
	button:SetText("")

	if x and y then
		button:SetParent(parent)
		button:SetPos(x, y)
	end

	if x == "static" then
		button.StaticScale = {
			w = w,
			fixed_h = h,
			minw = 50,
			minh = h
		}
	else
		button:SetSize(w, h)
	end

	button.var = var or false
	button.pos = var and 1 or 0
	button.alpha = 0
	button.disabled = false

	button.Paint = function(self, wd, hd)
		draw.RoundedBox(MSD.Config.Rounded, 0, 0, wd, hd, MSD.Theme["l"])

		if (self.hover or self.hovered) and not self.disabled then
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 1)
		else
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 0)
		end

		draw.DrawText(self.var and text1 or text2, "MSDFont.22", 3, hd / 2 - 10, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha * 255), TEXT_ALIGN_LEFT)
		draw.DrawText(self.var and text1 or text2, "MSDFont.22", 3, hd / 2 - 10, MSD.ColorAlpha(self.disabled and MSD.Text["n"] or MSD.Text["s"], 255 - self.alpha * 255), TEXT_ALIGN_LEFT)

		if self.var then
			self.pos = Lerp(0.1, self.pos, 1)
		else
			self.pos = Lerp(0.1, self.pos, 0)
		end

		draw.RoundedBox(MSD.Config.Rounded, wd - 75, hd / 2 - 10, 68, 20, MSD.Theme["d"])
		draw.RoundedBox(MSD.Config.Rounded, wd - 75 + self.pos * 35, hd / 2 - 10, 34, 20, MSD.Config.MainColor["p"])
	end

	button.OnCursorEntered = function(self)
		self.hover = true
	end

	button.OnCursorExited = function(self)
		self.hover = false
	end

	button.DoClick = function(self)
		if self.disabled then return end
		self.var = not self.var
		func(self, self.var)
	end

	if not x or not y then
		parent:AddItem(button)
	end

	return button
end

function MSD.ComboBox(parent, x, y, w, h, label, val)
	local ComboBox = vgui.Create("DComboBox")

	if x and y then
		ComboBox:SetParent(parent)
		ComboBox:SetPos(x, y)
	end

	if x == "static" then
		ComboBox.StaticScale = {
			w = w,
			fixed_h = h,
			minw = 50,
			minh = h
		}
	else
		ComboBox:SetSize(w, h)
	end

	ComboBox:SetValue(val)
	ComboBox:SetFont("MSDFont.22")
	ComboBox.alpha = 0
	ComboBox.disabled = false
	ComboBox:SetTextColor(MSD.Text["s"])

	ComboBox.Paint = function(self, wd, hd)
		if ( self:IsMenuOpen() or self.pressed ) and not self.disabled then
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 255)
		else
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 0)
		end

		draw.RoundedBox(MSD.Config.Rounded, 0, 0, wd, hd, MSD.Theme["l"])
		draw.RoundedBox(0, MSD.Config.Rounded, hd - 1, wd - MSD.Config.Rounded * 2, 1, MSD.ColorAlpha(self.disabled and MSD.Text["n"] or MSD.Text["s"], 255 - self.alpha))
		draw.RoundedBox(0, MSD.Config.Rounded, hd - 1, wd - MSD.Config.Rounded * 2, 1, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha))
		draw.SimpleText(self:GetText(), "MSDFont.22", 3, hd / 2 - 10, self.disabled and MSD.Text["n"] or MSD.Text["d"], TEXT_ALIGN_LEFT)

		if label and not self.error then
			draw.SimpleText(label, "MSDFont.16", 3, 0, MSD.ColorAlpha(MSD.Text["d"], 120), TEXT_ALIGN_LEFT)
		end

		return true
	end

	ComboBox.OnCursorEntered = function(self)
		self.pressed = true
	end

	ComboBox.OnCursorExited = function(self)
		self.pressed = false
	end

	function ComboBox:OpenMenu(pControlOpener)
		if (pControlOpener and pControlOpener == self.TextEntry) then return end
		if (self.disabled) then return end
		if (#self.Choices == 0) then return end

		if (IsValid(self.Menu)) then
			self.Menu:Remove()
			self.Menu = nil
		end

		self.Menu = MSD.MenuOpen(false, self)

		for k, v in pairs(self.Choices) do
			self.Menu:AddOption(v, function()
				self:ChooseOption(v, k)
			end)
		end

		local mx, my = self:LocalToScreen(0, self:GetTall())
		self.Menu:SetMinimumWidth(self:GetWide())
		self.Menu:Open(mx, my, false, self)
	end

	if not x or not y then
		parent:AddItem(ComboBox)
	end

	return ComboBox
end

function MSD.BigButton(parent, x, y, w, h, text, icon, func, color, text2, func2, text3, func3)
	local button = vgui.Create("DButton")
	button:SetText("")

	if x and y then
		button:SetParent(parent)
		button:SetPos(x, y)
	end

	if x == "static" then
		button.StaticScale = {
			w = w,
			fixed_h = h,
			minw = 50,
			minh = h
		}
	else
		button:SetSize(w, h)
	end

	button.alpha = 0
	button.color_idle = color_white

	button.Paint = function(self, wd, hd)
		if self.hover and not self.disable then
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 1)
		else
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 0)
		end

		draw.RoundedBox(MSD.Config.Rounded, 0, 0, wd, hd, MSD.Theme["d"])

		if func3 then func3(self, wd, hd) end

		MSD.DrawTexturedRect(wd / 2 - 24, hd / 2 - 36, 48, 48, icon, MSD.ColorAlpha(self.color_idle, 255 - self.alpha * 255))
		draw.DrawText(text, "MSDFont.25", wd / 2, hd / 2 + 10, MSD.ColorAlpha(self.color_idle, 255 - self.alpha * 255), TEXT_ALIGN_CENTER)

		if self.alpha > 0.01 then
			MSD.DrawTexturedRect(wd / 2 - 24, hd / 2 - 36, 48, 48, icon, MSD.ColorAlpha(color or MSD.Config.MainColor["p"], self.alpha * 255))
			draw.DrawText(text, "MSDFont.25", wd / 2, hd / 2 + 10, MSD.ColorAlpha(color or MSD.Config.MainColor["p"], self.alpha * 255), TEXT_ALIGN_CENTER)
		end

		if text2 then
			draw.DrawText("id: " .. text2, "MSDFont.20", 10, 10, MSD.Text.d, TEXT_ALIGN_LEFT)
		end

		if text3 then
			draw.DrawText(text3, "MSDFont.20", wd / 2, hd - 20, MSD.Text.n, TEXT_ALIGN_CENTER)
		end
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

function MSD.ColorSelector(parent, x, y, w, h, text, color, func, alpha_chl)
	color = table.Copy(color)
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
			minw = 50,
			minh = h
		}
	else
		button:SetSize(w, h)
	end
	button.alpha = 0
	button.color = color
	button.Paint = function(self, sw, sh)
		draw.RoundedBox(MSD.Config.Rounded, 0, 0, sw, sh, MSD.Theme["l"])

		if (self.hover or self.hovered) and not self.disabled then
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 1)
		else
			self.alpha = Lerp(FrameTime() * 5, self.alpha, 0)
		end

		draw.DrawText(self:GetText(), "MSDFont.22", 5, h / 2 - 11, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha * 255), TEXT_ALIGN_LEFT)
		draw.DrawText(self:GetText(), "MSDFont.22", 5, h / 2 - 11, MSD.ColorAlpha(self.disabled and MSD.Text["n"] or MSD.Text["s"], 255 - self.alpha * 255), TEXT_ALIGN_LEFT)

		if not self.disabled then draw.RoundedBox(MSD.Config.Rounded, sw - sw / 8, 0, sw / 8, h-1, button.color) end

		return true
	end
	button.OnCursorEntered = function(self)
		self.hover = true
	end
	button.OnCursorExited = function(self)
		self.hover = false
	end
	button.DoClick = function(self)

		if self.rebuild or self.disabled then return end

		self.rebuild = true

		if IsValid(self.cpanel) then
			self.cpanel:Remove()
			self.cpanel = nil
			self:SizeTo(self:GetWide(), h, 0.2, 0, -1, function()
				button.StaticScale = {
					w = w,
					fixed_h = h,
					minw = 50,
					minh = h
				}
				parent:Rebuild()
				self.rebuild = nil
			end)
			return
		end

		local UpdateColors, SetColors
		button.StaticScale = {
			w = w,
			fixed_h = h + 200,
			minw = 50,
			minh = h + 200
		}
		parent:Rebuild()
		self:SetSize(self:GetWide(), h)
		self:SizeTo(self:GetWide(), h + 200, 0.2, 0, -1, function()
			self.rebuild = nil
		end)

		self.cpanel = vgui.Create("DPanel", self)
		self.cpanel:SetSize(self:GetWide(), 200)
		self.cpanel:SetPos(0, h)
		self.cpanel.Paint = function() end

		self.red = MSD.TextEntry(self.cpanel, 235, 5, 50, 60, "", MSD.GetPhrase("red"), 0, function(sp, value)
			value = tonumber(value) or 0
			local col = math.Clamp(value,0,255)
			self.color = Color(col, self.color.g, self.color.b)
			SetColors(self.color, {[sp] = true})
		end, true, nil, false, true)

		self.green = MSD.TextEntry(self.cpanel, 235, 70, 50, 60, "", MSD.GetPhrase("green"), 0, function(sp, value)
			value = tonumber(value) or 0
			local col = math.Clamp(value,0,255)
			self.color = Color(self.color.r, col, self.color.b)
			SetColors(self.color, {[sp] = true})
		end, true, nil, false, true)

		self.blue = MSD.TextEntry(self.cpanel, 235, 135, 50, 60, "", MSD.GetPhrase("blue"), 0, function(sp, value)
			value = tonumber(value) or 0
			local col = math.Clamp(value,0,255)
			self.color = Color(self.color.r, self.color.g, col)
			SetColors(self.color, {[sp] = true})
		end, true, nil, false, true)

		self.HSV = vgui.Create("DColorCube", self.cpanel)
		self.HSV:SetPos(alpha_chl and 55 or 40, 5)
		self.HSV:SetSize(alpha_chl and 175 or 190, 190)
		self.HSV:SetColor(self.color)
		self.HSV.OnUserChanged = function(pn, col)
			SetColors(col, {[pn] = true, [self.RGB] = true})
		end

		if alpha_chl then
			self.AlphaBar = vgui.Create( "DAlphaBar", self.cpanel)
			self.AlphaBar:SetPos( 30, 5 )
			self.AlphaBar:SetSize( 20, 190 )
			self.AlphaBar:SetValue( button.color.a / 255 )
			self.AlphaBar.OnChange = function(pn, al)
				button.color.a = al * 255
				UpdateColors(button.color)
			end
		end

		self.RGB = vgui.Create("DRGBPicker", self.cpanel)
		self.RGB:SetPos(5, 5)
		self.RGB:SetSize(alpha_chl and 20 or 30, 190)
		self.RGB.OnChange = function(pn, col)
			local oc = ColorToHSV(col)
			local _, s, v = ColorToHSV(self.HSV:GetRGB())
			col = HSVToColor(oc, s, v)
			self.HSV:SetColor(col)
			SetColors(col, {[pn] = true, [self.HSV] = true})
		end

		local rwd_set = vgui.Create("MSDPanelList", self.cpanel)
		rwd_set:SetSize(self.cpanel:GetWide() - 290, self.cpanel:GetTall() - 10)
		rwd_set:SetPos(290, 5)
		rwd_set:EnableVerticalScrollbar()
		rwd_set:EnableHorizontal(true)
		rwd_set:SetSpacing(1)
		rwd_set:SetPadding(1)
		rwd_set.IgnoreVbar = true

		for _, cl in pairs(MSD.ColorPresets) do
			MSD.ColorSelectBut(rwd_set, "static", nil, 8, 25, cl, function()
				SetColors(cl, {})
			end)
		end

		function UpdateColors(col)
			button.color = col
			func(self, col)
		end

		function SetColors(col, ignore)
			local sh = ColorToHSV( col )
			if not ignore[self.RGB] then self.RGB.LastY = ( 1 - sh / 360 ) * self.RGB:GetTall() end
			if not ignore[self.HSV] then self.HSV:SetColor( col ) end
			if not ignore[self.red] then self.red:SetText(col.r) end
			if not ignore[self.green] then self.green:SetText(col.g) end
			if not ignore[self.blue] then self.blue:SetText(col.b) end
			if self.AlphaBar and not ignore[self.AlphaBar] then self.AlphaBar:SetValue( col.a / 255 ) end
			UpdateColors(col)
		end

		SetColors(self.color, {})
	end

	if not x or not y then
		parent:AddItem(button)
	end

	return button
end

function MSD.VectorSelectorList(parent, text, vector, showa, angle, texta, copy_but, func)
	local vecd, amgl
	vecd = MSD.VectorDisplay(parent, "static", nil, 1, 50, text, vector, function(vec)
		func(vec, showa and amgl.angle)
	end)
	if showa then
		amgl = MSD.AngleDisplay(parent, "static", nil, 1, 50, texta, angle, function(ang)
			func(vecd.vector, ang)
		end)
	end

	if copy_but then
		MSD.Button(parent, "static", nil, 3, 50, MSD.GetPhrase("set_pos_self"), function()
			local vec = LocalPlayer():GetPos() vecd.vector = vec
			if showa then local ang = Angle(0, LocalPlayer():GetAngles().y, 0) amgl.angle = ang end
			func(vecd.vector, showa and amgl.angle)
		end)

		MSD.Button(parent, "static", nil, 3, 50, MSD.GetPhrase("set_pos_aim"), function()
			local vec = LocalPlayer():GetEyeTrace().HitPos
			if not vec then return end
			vecd.vector = vec
			if showa then local ang = Angle(0, LocalPlayer():GetAngles().y, 0) amgl.angle = ang end
			func(vecd.vector, showa and amgl.angle)
		end)

		MSD.Button(parent, "static", nil, 3, 50, MSD.GetPhrase("copy_from_ent"), function()
			local vec = LocalPlayer():GetEyeTrace().Entity
			if not vec then return end
			vecd.vector = vec:GetPos()
			if showa then local ang = vec:GetAngles() amgl.angle = ang end
			func(vecd.vector, showa and amgl.angle)
		end)
	end

end

function MSD.NPCModelFrame(parent, x, y, w, h, model, anim)
	if not model then
		model = "models/Humans/Group01/Male_01.mdl"
	end

	if ScrH() > 1000 then
		modelsize = 500
	end

	local icon = vgui.Create("DModelPanel")

	if x and y then
		icon:SetParent(parent)
		icon:SetPos(x, y)
	end

	if x == "static" then
		icon.StaticScale = {
			w = w,
			fixed_h = h,
			minw = 50,
			minh = h
		}
	else
		icon:SetSize(w, h)
	end

	icon:SetFOV(20)
	icon:SetCamPos(Vector(0, 0, 0))
	icon:SetDirectionalLight(BOX_RIGHT, Color(255, 160, 80, 255))
	icon:SetDirectionalLight(BOX_LEFT, Color(80, 160, 255, 255))
	icon:SetAmbientLight(Vector(-64, -64, -64))
	icon:SetAnimated(true)
	icon.Angles = Angle(0, 0, 0)
	icon:SetLookAt(Vector(-100, 0, -22))
	icon:SetModel(model)
	icon.Entity:ResetSequence(anim or 1)
	icon.Entity:SetPos(Vector(-100, 0, -61))
	function icon:DragMousePress()
		self.PressX, self.PressY = gui.MousePos()
		self.Pressed = true
	end
	function icon:DoDoubleClick()
		if icon:GetFOV() < 10 then
			icon:SetFOV(50)
		else
			icon:SetFOV(icon:GetFOV() - 5)
		end
	end
	function icon:DragMouseRelease()
		self.Pressed = false
	end
	function icon:LayoutEntity(ent)
		if (self.bAnimated) then
			self:RunAnimation()
		end

		if (self.Pressed) then
			local mx = gui.MousePos()
			self.Angles = self.Angles - Angle(0, (self.PressX or mx) - mx, 0)
			self.PressX, self.PressY = gui.MousePos()
		end

		ent:SetAngles(self.Angles)
	end

	function icon:UpdateModelValue(value)
		if value == "" then return end
		icon:SetModel(value)

		if icon.Entity then
			icon.Entity:ResetSequence("idle")
			icon.Entity:SetPos(Vector(-100, 0, -61))
		end
	end

	if not x or not y then
		parent:AddItem(icon)
	end

	return icon
end

function MSD.BigModelButton(parent, x, y, wd, hd, text, icon, func, text2, tr, color, func2)
	local pnl = vgui.Create("DPanel")
	if x and y then
		pnl:SetParent(parent)
		pnl:SetPos(x, y)
	end
	if x == "static" then
		pnl.StaticScale = { w = wd, fixed_h = hd, minw = 150, minh = hd }
	else
		pnl:SetSize(wd, hd)
	end
	pnl.Paint = function()
		if not IsValid(pnl.Icon.Entity) then return end
		local ent_color = pnl.Icon:GetColor()
		ent_color.a = pnl:GetAlpha()
	end
	pnl.SetCustomModel = function(mdl)
		pnl.Icon:SetModel( mdl )
		pnl.Iconmdl = mdl
		local mn, mx = pnl.Icon.Entity:GetRenderBounds()
		local size = 0
		size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
		size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
		size = math.max(size, math.abs(mn.z) + math.abs(mx.z))
		pnl.Icon:SetFOV(90 - size)
		pnl.Icon:SetCamPos(Vector(size, size + 5, 23))
		pnl.Icon:SetLookAt((mn + mx) * 0.95)
	end

	pnl.Icon = vgui.Create("DModelPanel", pnl)
	pnl.Icon:SetModel("")
	pnl.Icon:SetMouseInputEnabled(false)
	function pnl.Icon:LayoutEntity(Entity)
		return
	end

	local button = vgui.Create("DButton", pnl)
	button:SetText("")
	button.alpha = 0
	button.color_idle = color_white
	button.text = text
	button.Paint = function(self, w, h)
		if self.hover and not self.disable then
			self.alpha = Lerp(FrameTime() * 7, self.alpha, 1)
		else
			self.alpha = Lerp(FrameTime() * 7, self.alpha, 0)
		end
		local mida = pnl.Iconmdl and not tr
		draw.RoundedBox(0, 0, 0, w, h, MSD.Theme["d"])

		if not pnl.Iconmdl then
			MSD.DrawTexturedRect(w / 2 - 24, h / 2 - 36, 48, 48, icon, MSD.ColorAlpha(self.color_idle, 255 - self.alpha * 255))
		else
			draw.RoundedBox(0, 0, 0, w * self.alpha, h, MSD.Theme["l"])
		end
		draw.DrawText(button.text, "MSDFont.25", w / 2, mida and h / 2 - 12 or h - 30, MSD.ColorAlpha(self.color_idle, 255 - self.alpha * 255), mida and TEXT_ALIGN_LEFT or TEXT_ALIGN_CENTER)
		if text2 then draw.DrawText(text2, "MSDFont.21", w / 2, h / 2 + 12 , self.color_idle, TEXT_ALIGN_LEFT) end

		if self.alpha > 0.01 then
			if not pnl.Iconmdl then MSD.DrawTexturedRect(w / 2 - 24, h / 2 - 36, 48, 48, icon, MSD.ColorAlpha(color or MSD.Config.MainColor["p"], self.alpha * 255)) end
			draw.DrawText(button.text, "MSDFont.25", w / 2, mida and h / 2 - 12 or h - 30, MSD.ColorAlpha(color or MSD.Config.MainColor["p"], self.alpha * 255), mida and TEXT_ALIGN_LEFT or TEXT_ALIGN_CENTER)
		end
	end
	button.OnCursorEntered = function(self) self.hover = true end
	button.OnCursorExited = function(self) self.hover = false end
	button.DoClick = function(self) if self.disable then return end func(self) end
	button.DoRightClick = function(self) if self.disable or not func2 then return end func2(self) end
	pnl.button = button
	function pnl:PerformLayout()
		self.button:StretchToParent( 0, 0, 0, 0 )
		local mida = pnl.Iconmdl and not tr
		if not mida then
			self.Icon:StretchToParent( 5, 5, 5, 5 )
		else
			self.Icon:StretchToParent( 5, 5, self:GetWide() / 2, 5 )
		end
	end
	if not x or not y then parent:AddItem(pnl) end
	return pnl
end