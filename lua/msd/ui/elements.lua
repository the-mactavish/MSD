-- Shared hover handlers so every button doesn't allocate its own pair of closures
local function HoverOn(self) self.hover = true end
local function HoverOff(self) self.hover = false end

-- Faded label/placeholder color, rebuilt only if the theme color is swapped
local hint_src, hint_cl
local function HintColor()
	local src = MSD.Text["d"]
	if src ~= hint_src then
		hint_src, hint_cl = src, MSD.ColorAlpha(src, 120)
	end
	return hint_cl
end

function MSD.WorkSpacePanel(parent, title, wd, hd, a_ignore, opaque)
	if not wd or not hd then
		wd, hd = 1.1, 1.3
	end

	local panel = vgui.Create("DPanel")

	if not a_ignore then
		panel:SetAlpha(0)
		panel:AlphaTo(255, 0.3)
	end

	panel.Paint = function(self, w, h)
		MSDX.Draw(MSD.Config.Rounded, 0, 0, w, h, MSD.Theme["d"])
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
		MSDX.Draw(MSD.Config.Rounded, 0, 0, w, h, opaque and MSD.Config.BgrColor or MSD.Theme["d"])
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

function MSD.IconButton(parent, mat, x, y, s, color, color2, func, bg)
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
	button.bgpaint = bg

	button.Paint = function(self, w, h)
		if self.hover or self.hovered then
			self.alpha = self.noanim and 1 or Lerp(FrameTime() * 5, self.alpha, 1)
		else
			self.alpha = self.noanim and 0 or Lerp(FrameTime() * 5, self.alpha, 0)
		end

		if self.bgpaint then
			self.bgpaint(self, w, h)
		end

		MSD.DrawTexturedRect(0, 0, w, h, self.mat, MSD.CrossColor(self.alpha, color or MSD.Text.l, color2 or MSD.Config.MainColor["p"]))

		return true
	end

	button.DoClick = function(...)
		MSD.UISnd("msd/ui/click.wav")
		func(...)
	end

	button.OnCursorEntered = HoverOn

	button.OnCursorExited = HoverOff

	button.DoRightClick = function(...)
		MSD.UISnd("msd/ui/click.wav")
		func(...)
	end

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
		self.alpha = Lerp(FrameTime() * 5, self.alpha, (self.hover or self.hovered) and 1 or 0)

		MSD.DrawTexturedRect(w / 2 - s / 2, 0, s, s, self.mat, MSD.CrossColor(self.alpha, color or MSD.Text.d, color2 or MSD.Config.MainColor["p"]))

		local txt = self:GetText()
		if self.wrap_src ~= txt or self.wrap_w ~= w then
			self.wrap_src, self.wrap_w = txt, w
			self.wrap_txt = MSD.TextWrap(txt, "MSDFont.16", w - 4)
		end

		draw.DrawText(self.wrap_txt, "MSDFont.16", w / 2, s, color or MSD.Text.d, TEXT_ALIGN_CENTER)

		return true
	end

	button.DoClick = function(...)
		MSD.UISnd("msd/ui/click.wav")
		func(...)
	end

	button.OnCursorEntered = HoverOn

	button.OnCursorExited = HoverOff

	button.DoRightClick = function(...)
		MSD.UISnd("msd/ui/click.wav")
		func(...)
	end

	if not x or not y then
		parent:AddItem(button)
	end

	return button
end

function MSD.CloseButtonIcon(parent, x, y, w, h, text, func, icon)
	local button = vgui.Create("DButton")
	button:SetText(text)
	icon = icon or MSD.Icons48.close_box
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
		self.alpha = Lerp(FrameTime() * 5, self.alpha, ((self.hover or self.hovered) and not self.disabled) and 1 or 0)

		draw.DrawText(self:GetText(), "MSDFont.22", w - h, hd / 2 - 11, MSD.CrossColor(self.alpha, self.disabled and MSD.Text["n"] or MSD.Text["s"], MSD.Clr["red"]), TEXT_ALIGN_RIGHT)
		MSD.DrawTexturedRect(w - (h - 5), hd / 2 - 12, h - 10, h - 10, icon, MSD.CrossColor(self.alpha, MSD.Text["l"], MSD.Clr["red"]))

		return true
	end

	if func then
		button.OnCursorEntered = HoverOn

		button.OnCursorExited = HoverOff

		button.DoClick = function(...)
			MSD.UISnd("msd/ui/click.wav")
			func(...)
		end

		button.DoRightClick = function(...)
			MSD.UISnd("msd/ui/click.wav")
			func(...)
		end
	end

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
		self.alpha = Lerp(FrameTime() * 5, self.alpha, (self.hover or self.hovered) and 1 or 0)

		MSDX.Draw(MSD.Config.Rounded, 0, 0, w, h, MSD.Theme.d)

		if self.alpha > 0 then
			MSDX.Draw(MSD.Config.Rounded, 0, 0, w, h, MSD.ColorAlpha(MSD.Config.MainColor["p"], 255 * self.alpha))
		end

		MSD.DrawTexturedRect(w / 2 - 12, h / 2 - 12, 24, 24, self.mat, color_white)

		return true
	end

	button.DoClick = function(...)
		MSD.UISnd("msd/ui/click.wav")
		func(...)
	end

	button.OnCursorEntered = HoverOn

	button.OnCursorExited = HoverOff

	button.DoRightClick = function(...)
		MSD.UISnd("msd/ui/click.wav")
		func(...)
	end

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
			MSDX.Draw(MSD.Config.Rounded, 0, 0, w, h, MSD.Theme["d"])
		end

		self.alpha = Lerp(FrameTime() * 5, self.alpha, self.hover and 1 or 0)
		local rf = MSD.Config.Rounded
		if self.alpha > 0.01 then
			MSDX.Draw(rf, rf, rf, math.max((w - rf * 2) * self.alpha, icon_size + 12 - rf), h - rf * 2, MSD.ColorAlpha(MSD.Config.MainColor["p"], 255 * self.alpha))
		end

		MSD.DrawTexturedRect(small and h / 2 - rf or 10, small and h / 2 - rf or 10, icon_size, icon_size, self.mat, color_white)
		draw.DrawText(text, "MSDFont.22", 55, 12, color_white, TEXT_ALIGN_LEFT)

		return true
	end

	button.DoClick = function(...)
		MSD.UISnd("msd/ui/enter.wav")
		func(...)
	end

	button.OnCursorEntered = HoverOn

	button.OnCursorExited = HoverOff

	button.DoRightClick = function(...)
		MSD.UISnd("msd/ui/enter.wav")
		func(...)
	end

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
			MSDX.Draw(rf, 0, 0, w, h, MSD.Theme["d"])
		end

		self.alpha = Lerp(FrameTime() * 7, self.alpha, self.hover and 1 or 0)

		if self.alpha > 0.01 then
			MSDX.Draw(rf, rf, h - 5, w - rf * 2, 5 + rf, MSD.ColorAlpha(MSD.Config.MainColor["p"], 255 * self.alpha), MSDX.NO_BL + MSDX.NO_BR)
		end

		MSD.DrawTexturedRect(small and h / 2 - rf or 10, small and h / 2 - rf or 10, icon_size, icon_size, self.mat, color_white)
		draw.DrawText(text, "MSDFont.22", 55, 12, color_white, TEXT_ALIGN_LEFT)

		return true
	end

	button.DoClick = function(...)
		MSD.UISnd("msd/ui/enter.wav")
		func(...)
	end

	button.OnCursorEntered = HoverOn

	button.OnCursorExited = HoverOff

	button.DoRightClick = function(...)
		MSD.UISnd("msd/ui/enter.wav")
		func(...)
	end

	if not x then
		parent:AddItem(button)
	end

	return button
end

function MSD.Header(parent, text, back, icon, align, func)
	local panel = vgui.Create("DPanel")

	panel.StaticScale = {
		w = 1,
		fixed_h = 50,
		minw = 250,
		minh = 50
	}

	panel.Paint = function(self, w, h)
		MSDX.Draw(MSD.Config.Rounded, 0, 0, w, h, MSD.Theme["l"])
		draw.DrawText(text, "MSDFont.25", align and 50 or w / 2, 12, color_white, align and TEXT_ALIGN_LEFT or TEXT_ALIGN_CENTER)
		if func and isfunction(func) then func(self, w, h) end
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
		MSDX.Draw(MSD.Config.Rounded, 0, 0, w, h, MSD.Theme["l"])
		draw.DrawText(text, "MSDFont.20", 5, h / 2 - 11, color_white, TEXT_ALIGN_LEFT)
	end

	parent:AddItem(panel)

	return panel
end

function MSD.InfoText(parent, text, font)
	font = font or "MSDFont.18"
	local panel = vgui.Create("DPanel")

	panel.StaticScale = {
		w = 1,
		fixed_h = 25,
		minw = 250,
		minh = 25
	}

	panel.Paint = function(self, w, h)
		draw.DrawText(self.txt or "", font, 5, 5, MSD.Text.d, TEXT_ALIGN_LEFT)

		if not self.txt or (self.sh and self.sh ~= h) or (self.sw and self.sw ~= w) then
			local ts, _, th = MSD.TextWrap(text, font, w - 10)
			self.txt = ts
			self.sw = w
			self.sh = h
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
		self.alpha = Lerp(FrameTime() * 5, self.alpha, self:HasFocus() and 255 or 0)
		local rf = MSD.Config.Rounded
		MSDX.Draw(rf, 0, 0, wd, hd, MSD.Theme["l"])
		MSDX.Draw(0, rf, hd - 1, wd - rf * 2, 1, MSD.CrossColor(self.alpha / 255, MSD.Text["n"], MSD.Config.MainColor["p"]))

		if self:GetValue() == "" then
			draw.DrawText(text, "MSDFont.22", 3, multi and 1 or hd / 2 - 10, HintColor(), TEXT_ALIGN_LEFT)
		end

		if label and not self.error then
			draw.SimpleText(label, "MSDFont.16", 3, 0, HintColor(), TEXT_ALIGN_LEFT)
		end

		if self.error then
			draw.SimpleText(self.error, "MSDFont.16", 3, 0, MSD.Config.MainColor["r"], TEXT_ALIGN_LEFT)
		end

		self:DrawTextEntryText(self.error and MSD.Config.MainColor["rd"] or MSD.Text["l"], MSD.Config.MainColor["p"], MSD.Text["d"])
	end

	Entry.OnEnter = function(...)
		MSD.UISnd("msd/ui/enter.wav")
		func(...)
	end

	if focuse_update then
		Entry.OnFocusChanged = function(self, gained)
			if not gained then
				MSD.UISnd("msd/ui/enter.wav")
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
		MSDX.Draw(MSD.Config.Rounded, 0, 0, sw, sh, MSD.Theme["l"])
		MSDX.Draw(0, MSD.Config.Rounded, sh - 1, sw - MSD.Config.Rounded * 2, 1, MSD.Text["n"])

		if text then
			draw.SimpleText(text, "MSDFont.16", 3, 0, HintColor(), TEXT_ALIGN_LEFT)
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

		MSD.UISnd("msd/ui/enter.wav")
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
		MSDX.Draw(MSD.Config.Rounded, 0, 0, sw, h, MSD.Theme["l"])
		MSDX.Draw(0, MSD.Config.Rounded, sh - 1, sw - MSD.Config.Rounded * 2, 1, MSD.Text["n"])

		if text then
			draw.SimpleText(text, "MSDFont.16", 3, 0, HintColor(), TEXT_ALIGN_LEFT)
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
		MSDX.Draw(MSD.Config.Rounded, 0, 0, wd, hd, color)

		self.alpha = Lerp(FrameTime() * 5, self.alpha, ((self.hover or self.hovered) and not self.disabled) and 1 or 0)

		return true
	end

	button.OnCursorEntered = HoverOn

	button.OnCursorExited = HoverOff

	button.DoClick = function(self)
		MSD.UISnd("msd/ui/click.wav")
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
		MSDX.Draw(rf, 0, 0, wd, hd, MSD.Theme["l"])

		self.alpha = Lerp(FrameTime() * 5, self.alpha, ((self.hover or self.hovered or self.Trapping) and not self.disabled) and 1 or 0)

		draw.DrawText(text, "MSDFont.22", 5, hd / 2 - 11, MSD.CrossColor(self.alpha, self.disabled and MSD.Text["n"] or MSD.Text["s"], MSD.Config.MainColor["p"]), TEXT_ALIGN_LEFT)
		draw.DrawText(self:GetText():upper(), "MSDFont.22", wd - wd / 3 / 2, hd / 2 - 11, MSD.CrossColor(self.alpha, self.disabled and MSD.Text["n"] or MSD.Text["s"], MSD.Config.MainColor["p"]), TEXT_ALIGN_CENTER)
		MSDX.Draw(0, rf, hd - 1, (wd / 3) * 2 - 5 - rf, 1, MSD.CrossColor(self.alpha, MSD.Text["n"], MSD.Config.MainColor["p"]))
		MSDX.Draw(0, wd - wd / 3, hd - 1, wd / 3 - rf, 1, MSD.CrossColor(self.alpha, MSD.Text["n"], MSD.Config.MainColor["p"]))

		return true
	end

	binder.OnCursorEntered = HoverOn

	binder.OnCursorExited = HoverOff

	function binder:OnChange(num)
		if num > 106 and num < 114 then
			MSD.UISnd("msd/ui/error.wav")
			binder:SetValue(var)
		else
			MSD.UISnd("msd/ui/enter.wav")
			func(num)
		end
	end

	if not x or not y then
		parent:AddItem(binder)
	end
end

function MSD.ButtonScr(parent, x, y, w, h, text, func, al_left, aid)
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

	if aid then
		steamworks.FileInfo(aid, function(result)
			steamworks.Download( result.previewid, true, function( n )
				if n == nil then return end
				if not IsValid(button) then return end
				button.mat = AddonMaterial(n)
			end)
		end)
	end

	button.Paint = function(self, wd, hd)
		if self.mat then
			MSD.DrawTexturedRect(0, 0, wd, hd, self.mat, color_white)
		end

		if not self.ws or self.ws ~= wd then
			self.ws = wd
			self.text, _, self.th = MSD.TextWrap(self:GetText(), "MSDFont.20", wd - 20)
		end
		self.alpha = Lerp(FrameTime() * 5, self.alpha, ((self.hover or self.hovered) and not self.disabled) and 1 or 0)

		MSDX.Draw(MSD.Config.Rounded, 0, hd / 2 - self.th / 2 - 5, wd, self.th + 10, MSD.Theme["d"])

		draw.DrawText(self.text, "MSDFont.20", al_left and 5 or wd / 2, hd / 2 - 11, MSD.CrossColor(self.alpha, self.disabled and MSD.Text["n"] or MSD.Text["s"], MSD.Config.MainColor["p"]), al_left and TEXT_ALIGN_LEFT or TEXT_ALIGN_CENTER)
		MSDX.Draw(MSD.Config.Rounded, 0, hd - 1, wd, 1, MSD.CrossColor(self.alpha, MSD.Text["l"], MSD.Config.MainColor["p"]))

		return true
	end

	button.OnCursorEntered = HoverOn

	button.OnCursorExited = HoverOff

	button.DoClick = function(self)
		MSD.UISnd("msd/ui/click.wav")
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
	button:SetFont("MSDFont.22")

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
	button.bg = MSD.Theme["l"]

	button.Paint = function(self, wd, hd)
		MSDX.Draw(MSD.Config.Rounded, 0, 0, wd, hd, button.bg)

		self.alpha = Lerp(FrameTime() * 5, self.alpha, ((self.hover or self.hovered) and not self.disabled) and 1 or 0)

		draw.DrawText(self:GetText(), self:GetFont(), al_left and 5 or wd / 2, hd / 2 - 11, MSD.CrossColor(self.alpha, self.disabled and MSD.Text["n"] or MSD.Text["s"], MSD.Config.MainColor["p"]), al_left and TEXT_ALIGN_LEFT or TEXT_ALIGN_CENTER)
		MSDX.Draw(0, MSD.Config.Rounded, hd - 1, wd - MSD.Config.Rounded * 2, 1, MSD.CrossColor(self.alpha, MSD.Text["n"], MSD.Config.MainColor["p"]))

		return true
	end

	button.OnCursorEntered = HoverOn

	button.OnCursorExited = HoverOff

	button.DoClick = function(...)
		MSD.UISnd("msd/ui/click.wav")
		func(...)
	end

	if not x or not y then
		parent:AddItem(button)
	end

	return button
end

function MSD.ButtonSimple(parent, x, y, w, h, text, fsize, func)
	local font = "MSDFont." .. fsize
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
			MSDX.Draw(MSD.Config.Rounded, 0, 0, wd, hd, MSD.Theme["d"])
		end

		if (self.hover or self.hovered) and not self.disabled then
			draw.DrawText(self:GetText(), font, 5, hd / 2 - fsize / 2, MSD.Config.MainColor["p"], TEXT_ALIGN_LEFT)
		else
			draw.DrawText(self:GetText(), font, 5, hd / 2 - fsize / 2, self.disabled and MSD.Text["n"] or MSD.Text["s"], TEXT_ALIGN_LEFT)
		end
		return true
	end

	button.OnCursorEntered = HoverOn

	button.OnCursorExited = HoverOff

	button.DoClick = function(...)
		MSD.UISnd("msd/ui/click.wav")
		func(...)
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
		self.alpha = Lerp(FrameTime() * 5, self.alpha, self:HasFocus() and 255 or 0)

		MSDX.Draw(MSD.Config.Rounded, 0, 0, wd, hd, MSD.Theme["l"])
		MSDX.Draw(0, MSD.Config.Rounded, hd - 1, wd - MSD.Config.Rounded * 2, 1, MSD.CrossColor(self.alpha / 255, MSD.Text["n"], MSD.Config.MainColor["p"]))

		if label and not self.error then
			draw.SimpleText(label, "MSDFont.16", 3, 0, HintColor(), TEXT_ALIGN_LEFT)
		end

		if self.error then
			draw.SimpleText(self.error, "MSDFont.16", 3, 0, MSD.Config.MainColor["r"], TEXT_ALIGN_LEFT)
		end

		self:DrawTextEntryText(self.error and MSD.Config.MainColor["rd"] or MSD.Text["l"], MSD.Config.MainColor["p"], MSD.Text["d"])

		return true
	end

	button.OnValueChanged = function(...)
		MSD.UISnd("msd/ui/enter.wav")
		func(...)
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
		MSDX.Draw(MSD.Config.Rounded, 0, 0, wd, hd, MSD.Theme["l"])

		if drawf then drawf(self, wd, hd) end

		self.alpha = Lerp(FrameTime() * 5, self.alpha, ((self.hover or self.hovered) and not self.disabled) and 1 or 0)

		draw.DrawText(self:GetText(), "MSDFont.22", 48, hd / 2 - 11, MSD.CrossColor(self.alpha, self.disabled and MSD.Text["n"] or MSD.Text["s"], MSD.Config.MainColor["p"]), TEXT_ALIGN_LEFT)
		MSDX.Draw(0, MSD.Config.Rounded, hd - 1, wd - MSD.Config.Rounded * 2, 1, MSD.CrossColor(self.alpha, color or MSD.Text["n"], color2 or MSD.Config.MainColor["p"]))
		MSD.DrawTexturedRect(12, hd / 2 - 12, 24, 24, icon, MSD.CrossColor(self.alpha, color or MSD.Text["l"], color2 or MSD.Config.MainColor["p"]))

		return true
	end

	if func then
		button.OnCursorEntered = HoverOn

		button.OnCursorExited = HoverOff

		button.DoClick = function(...)
			MSD.UISnd("msd/ui/click.wav")
			func(...)
		end
	end

	if func2 then
		button.DoRightClick = function(...)
			MSD.UISnd("msd/ui/click.wav")
			func2(...)
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
		MSDX.Draw(MSD.Config.Rounded, 0, 0, wd, hd, MSD.Theme["l"])

		self.alpha = Lerp(FrameTime() * 5, self.alpha, ((self.hover or self.hovered) and not self.disabled) and 1 or 0)

		if self.bgpaint then
			self.bgpaint(self, wd, hd)
		end

		draw.DrawText(self.text, "MSDFont.22", wd - 5, hd / 2 - 11, self.disabled and MSD.Text["n"] or MSD.Text["s"], TEXT_ALIGN_RIGHT)
		draw.DrawText(self:GetText(), "MSDFont.22", 48, hd / 2 - 11, MSD.CrossColor(self.alpha, self.disabled and MSD.Text["n"] or MSD.Text["s"], MSD.Config.MainColor["p"]), TEXT_ALIGN_LEFT)
		MSDX.Draw(0, MSD.Config.Rounded, hd - 1, wd - MSD.Config.Rounded * 2, 1, MSD.CrossColor(self.alpha, MSD.Text["n"], MSD.Config.MainColor["p"]))
		MSD.DrawTexturedRect(12, hd / 2 - 12, 24, 24, icon, MSD.CrossColor(self.alpha, color or MSD.Text["l"], color or MSD.Config.MainColor["p"]))

		return true
	end

	if func then
		button.OnCursorEntered = HoverOn

		button.OnCursorExited = HoverOff

		button.DoClick = function(...)
			MSD.UISnd("msd/ui/click.wav")
			func(...)
		end
	end

	if func2 then
		button.DoRightClick = function(...)
			MSD.UISnd("msd/ui/click.wav")
			func2(...)
		end
	end

	if not x or not y then
		parent:AddItem(button)
	end

	return button
end

-- fmt (optional): function(value) returning the value label, default is a percentage
function MSD.VolumeSlider(parent, x, y, w, h, text, var, func, cl, fmt)
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
		MSDX.Draw(MSD.Config.Rounded, 0, 0, wd, hd, MSD.Theme["l"])

		self.alpha = Lerp(FrameTime() * 5, self.alpha, ((self.hover or self.hovered) and not self.disabled) and 1 or 0)

		draw.DrawText(text, "MSDFont.22", 3, hd / 2 - 11, MSD.CrossColor(self.alpha, self.disabled and MSD.Text["n"] or MSD.Text["s"], MSD.Config.MainColor["p"]), TEXT_ALIGN_LEFT)
		self.var = Lerp(FrameTime() * 7, self.var, self.value)
		MSDX.Draw(MSD.Config.Rounded, wd - wd / 2 + 10, hd / 2 - 10, wd / 2 - 20, 20, MSD.Theme["d"])

		if self.disabled then
			draw.DrawText(MSD.GetPhrase("disabled"), "MSDFont.16", wd - (wd / 2) / 2, hd / 2 - 8, MSD.Text["n"], TEXT_ALIGN_CENTER)
		else
			MSDX.Draw(MSD.Config.Rounded, wd - wd / 2 + 10, hd / 2 - 10,  math.max((wd / 2 - 19) * self.var, 16), 20, cl or MSD.Config.MainColor["p"])
			draw.DrawText(fmt and fmt(self.value) or math.Round(self.value * 100) .. "%", "MSDFont.16", wd - (wd / 2) / 2, hd / 2 - 8, MSD.Text["s"], TEXT_ALIGN_CENTER)
		end
	end

	button.OnCursorEntered = HoverOn

	button.OnCursorExited = HoverOff

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
		MSD.UISnd("msd/ui/click.wav")
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
		MSDX.Draw(MSD.Config.Rounded, 0, 0, wd, hd, MSD.Theme["l"])

		self.alpha = Lerp(FrameTime() * 5, self.alpha, ((self.hover or self.hovered) and not self.disabled) and 1 or 0)

		draw.DrawText(text, "MSDFont.22", 3, hd / 2 - 11, MSD.CrossColor(self.alpha, self.disabled and MSD.Text["n"] or MSD.Text["s"], MSD.Config.MainColor["p"]), TEXT_ALIGN_LEFT)
		self.var = Lerp(FrameTime() * 7, self.var, self.value)
		MSDX.Draw(MSD.Config.Rounded, wd - wd / 2 + 10, hd / 2 - 10, wd / 2 - 20, 20, MSD.Theme["d"])

		if self.disabled then
			draw.DrawText(MSD.GetPhrase("disabled"), "MSDFont.16", wd - (wd / 2) / 2, hd / 2 - 8, MSD.Text["n"], TEXT_ALIGN_CENTER)
		else
			MSDX.Draw(MSD.Config.Rounded, wd - wd / 2 + 10, hd / 2 - 10, (wd / 2 - 19) * ( self.var / 2), 20, cl or MSD.Config.MainColor["p"])
			draw.DrawText(math.Round(self.value * 100) .. "%", "MSDFont.16", wd - (wd / 2) / 2, hd / 2 - 8, MSD.Text["s"], TEXT_ALIGN_CENTER)
		end
	end

	button.OnCursorEntered = HoverOn

	button.OnCursorExited = HoverOff

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
		MSD.UISnd("msd/ui/click.wav")
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
		MSDX.Draw(MSD.Config.Rounded, 0, 0, wd, hd, MSD.Theme["l"])

		self.alpha = Lerp(FrameTime() * 5, self.alpha, ((self.hover or self.hovered) and not self.disabled) and 1 or 0)

		draw.DrawText(text, "MSDFont.22", 3, hd / 2 - 11, MSD.CrossColor(self.alpha, self.disabled and MSD.Text["n"] or MSD.Text["s"], MSD.Config.MainColor["p"]), TEXT_ALIGN_LEFT)

		self.pos = Lerp(0.1, self.pos, self.var and 1 or 0)

		MSDX.Draw(MSD.Config.Rounded, wd - 75, hd / 2 - 10, 68, 20, MSD.Theme["d"])

		if self.disabled then
			draw.DrawText(MSD.GetPhrase("disabled"), "MSDFont.16", wd - 40, hd / 2 - 8, MSD.Text["n"], TEXT_ALIGN_CENTER)
		else
			draw.DrawText(MSD.GetPhrase("off"), "MSDFont.16", wd - 25, hd / 2 - 8, MSD.ColorAlpha(MSD.Text["s"], 255 - self.pos * 255), TEXT_ALIGN_CENTER)
			draw.DrawText(MSD.GetPhrase("on"), "MSDFont.16", wd - 60, hd / 2 - 8, MSD.ColorAlpha(MSD.Text["s"], self.pos * 255), TEXT_ALIGN_CENTER)
			MSDX.Draw(MSD.Config.Rounded, wd - 75 + self.pos * 35, hd / 2 - 10, 34, 20, MSD.CrossColor(self.pos, MSD.Text["n"], MSD.Config.MainColor["p"]))
		end
	end

	button.OnCursorEntered = HoverOn

	button.OnCursorExited = HoverOff

	button.DoClick = function(self)
		if self.disabled then return end
		self.var = not self.var
		func(self, self.var)
		MSD.UISnd("msd/ui/toggle.wav")
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
		MSDX.Draw(MSD.Config.Rounded, 0, 0, wd, hd, MSD.Theme["l"])

		self.alpha = Lerp(FrameTime() * 5, self.alpha, ((self.hover or self.hovered) and not self.disabled) and 1 or 0)

		draw.DrawText(self.var and text1 or text2, "MSDFont.22", 3, hd / 2 - 10, MSD.CrossColor(self.alpha, self.disabled and MSD.Text["n"] or MSD.Text["s"], MSD.Config.MainColor["p"]), TEXT_ALIGN_LEFT)

		self.pos = Lerp(0.1, self.pos, self.var and 1 or 0)

		MSDX.Draw(MSD.Config.Rounded, wd - 75, hd / 2 - 10, 68, 20, MSD.Theme["d"])
		MSDX.Draw(MSD.Config.Rounded, wd - 75 + self.pos * 35, hd / 2 - 10, 34, 20, MSD.Config.MainColor["p"])
	end

	button.OnCursorEntered = HoverOn

	button.OnCursorExited = HoverOff

	button.DoClick = function(self)
		if self.disabled then return end
		self.var = not self.var
		func(self, self.var)
		MSD.UISnd("msd/ui/toggle.wav")
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
		self.alpha = Lerp(FrameTime() * 5, self.alpha, (( self:IsMenuOpen() or self.pressed ) and not self.disabled) and 255 or 0)

		MSDX.Draw(MSD.Config.Rounded, 0, 0, wd, hd, MSD.Theme["l"])
		MSDX.Draw(0, MSD.Config.Rounded, hd - 1, wd - MSD.Config.Rounded * 2, 1, MSD.CrossColor(self.alpha / 255, self.disabled and MSD.Text["n"] or MSD.Text["s"], MSD.Config.MainColor["p"]))
		draw.SimpleText(self:GetText(), "MSDFont.22", 3, hd / 2 - 10, self.disabled and MSD.Text["n"] or MSD.Text["d"], TEXT_ALIGN_LEFT)

		if label and not self.error then
			draw.SimpleText(label, "MSDFont.16", 3, 0, HintColor(), TEXT_ALIGN_LEFT)
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

		MSD.UISnd("msd/ui/toggle.wav")
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
		self.alpha = Lerp(FrameTime() * 5, self.alpha, (self.hover and not self.disable) and 1 or 0)

		MSDX.Draw(MSD.Config.Rounded, 0, 0, wd, hd, MSD.Theme["d"])

		if func3 then func3(self, wd, hd) end

		local cl = MSD.CrossColor(self.alpha, self.color_idle, color or MSD.Config.MainColor["p"])
		MSD.DrawTexturedRect(wd / 2 - 24, hd / 2 - 36, 48, 48, icon, cl)
		draw.DrawText(text, "MSDFont.25", wd / 2, hd / 2 + 10, cl, TEXT_ALIGN_CENTER)

		if text2 then
			draw.DrawText("id: " .. text2, "MSDFont.20", 10, 10, MSD.Text.d, TEXT_ALIGN_LEFT)
		end

		if text3 then
			draw.DrawText(text3, "MSDFont.20", wd / 2, hd - 20, MSD.Text.n, TEXT_ALIGN_CENTER)
		end
	end

	button.OnCursorEntered = HoverOn

	button.OnCursorExited = HoverOff

	button.DoClick = function(self)
		if self.disable then return end
		func(self)
		MSD.UISnd("msd/ui/click.wav")
	end

	button.DoRightClick = function(self)
		if self.disable or not func2 then return end
		func2(self)
		MSD.UISnd("msd/ui/click.wav")
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
		MSDX.Draw(MSD.Config.Rounded, 0, 0, sw, sh, MSD.Theme["l"])

		self.alpha = Lerp(FrameTime() * 5, self.alpha, ((self.hover or self.hovered) and not self.disabled) and 1 or 0)

		draw.DrawText(self:GetText(), "MSDFont.22", 5, h / 2 - 11, MSD.CrossColor(self.alpha, self.disabled and MSD.Text["n"] or MSD.Text["s"], MSD.Config.MainColor["p"]), TEXT_ALIGN_LEFT)

		if not self.disabled then MSDX.Draw(MSD.Config.Rounded, sw - sw / 8, 0, sw / 8, h-1, button.color) end

		return true
	end
	button.OnCursorEntered = HoverOn
	button.OnCursorExited = HoverOff
	button.DoClick = function(self)

		if self.rebuild or self.disabled then return end

		self.rebuild = true

		MSD.UISnd("msd/ui/toggle.wav")

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
		MSD.UISnd("msd/ui/toggle.wav")
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
	pnl.Paint = function() end
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
		self.alpha = Lerp(FrameTime() * 7, self.alpha, (self.hover and not self.disable) and 1 or 0)
		local mida = pnl.Iconmdl and not tr
		MSDX.Draw(0, 0, 0, w, h, MSD.Theme["d"])

		local cl = MSD.CrossColor(self.alpha, self.color_idle, color or MSD.Config.MainColor["p"])

		if not pnl.Iconmdl then
			MSD.DrawTexturedRect(w / 2 - 24, h / 2 - 36, 48, 48, icon, cl)
		elseif self.alpha > 0.004 then
			MSDX.Draw(0, 0, 0, w * self.alpha, h, MSD.Theme["l"])
		end
		draw.DrawText(button.text, "MSDFont.25", w / 2, mida and h / 2 - 12 or h - 30, cl, mida and TEXT_ALIGN_LEFT or TEXT_ALIGN_CENTER)
		if text2 then draw.DrawText(text2, "MSDFont.21", w / 2, h / 2 + 12 , self.color_idle, TEXT_ALIGN_LEFT) end
	end
	button.OnCursorEntered = HoverOn
	button.OnCursorExited = HoverOff
	button.DoClick = function(self) if self.disable then return end func(self) MSD.UISnd("msd/ui/click.wav") end
	button.DoRightClick = function(self) if self.disable or not func2 then return end func2(self) MSD.UISnd("msd/ui/click.wav") end
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