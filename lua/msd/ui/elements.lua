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
        draw.RoundedBox(0, 0, 0, w, h, MSD.Theme["d"])
        MSD.Blur(self, 5, 5, 255, 50, w, h)
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
        draw.RoundedBox(0, 0, 0, w, h, MSD.Theme["d"])
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
            fixed_h = s + 16,
            minw = s * 2,
            minh = s + 16
        }
    end

    button:SetSize(s, s + 16)
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

        draw.DrawText(self:GetText(text), "MSDFont.16", w / 2, h - 16, color or MSD.Text.d, TEXT_ALIGN_CENTER)

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

        draw.RoundedBox(0, 0, 0, w, h, MSD.Theme.d)

        if self.alpha > 0 then
            draw.RoundedBox(0, 0, 0, w * self.alpha, h, MSD.Config.MainColor["p"])
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

function MSD.MenuButton(parent, mat, x, y, w, h, text, func, rfunc, small)
    local t_par

    if istable(text) then
        text, t_par = text[1], text[2]
    end

    local button = vgui.Create("DButton")
    button:SetSize(w, h)

    if x then
        button:SetParent(parent)
        button:SetPos(x, y)
    end

    button:SetText("")
    button.hovered = false
    button.alpha = 0
    button.mat = mat

    button.Paint = function(self, w, h)
        if self.hovered then
            draw.RoundedBox(0, 0, 0, w, h, MSD.Theme["d"])
        end

        if self.hover then
            self.alpha = Lerp(FrameTime() * 5, self.alpha, 1)
        else
            self.alpha = Lerp(FrameTime() * 5, self.alpha, 0)
        end

        if self.alpha > 0.01 then
            draw.RoundedBox(0, 0, 0, w * self.alpha, h, MSD.Config.MainColor["p"])
        end

        MSD.DrawTexturedRect(small and h / 2 - 8 or 10, small and h / 2 - 8 or 10, small and 16 or h - 20, small and 16 or h - 20, self.mat, color_white)
        draw.DrawText(MSD.GetPhrase(text, t_par), "MSDFont.22", 55, 12, color_white, TEXT_ALIGN_LEFT)

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

function MSD.Header(parent, text, back)
    local panel = vgui.Create("DPanel")

    panel.StaticScale = {
        w = 1,
        fixed_h = 50,
        minw = 250,
        minh = 50
    }

    panel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, MSD.Theme["l"])
        draw.DrawText(text, "MSDFont.25", w / 2, 12, color_white, TEXT_ALIGN_CENTER)
    end

    parent:AddItem(panel)

    if back then
        MSD.IconButton(panel, MSD.Icons48.back, 13, 13, 24, nil, nil, back)
    end

    return panel
end

function MSD.InfoHeader(parent, text)
    local panel = vgui.Create("DPanel")

    panel.StaticScale = {
        w = 1,
        fixed_h = 25,
        minw = 250,
        minh = 25
    }

    panel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, MSD.Theme["l"])
        draw.DrawText(text, "MSDFont.20", 5, h / 2 - 11, color_white, TEXT_ALIGN_LEFT)
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
            minw = 150,
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

    Entry.Paint = function(self, w, h)
        if self:HasFocus() then
            self.alpha = Lerp(FrameTime() * 5, self.alpha, 255)
        else
            self.alpha = Lerp(FrameTime() * 5, self.alpha, 0)
        end

        draw.RoundedBox(0, 0, 0, w, h, MSD.Theme["l"])
        draw.RoundedBox(0, 0, h - 1, w, 1, MSD.ColorAlpha(MSD.Text["n"], 255 - self.alpha))
        draw.RoundedBox(0, 0, h - 1, w, 1, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha))

        if self:GetValue() == "" then
            draw.SimpleText(text, "MSDFont.22", 3, multi and 1 or h / 2 - 10, MSD.ColorAlpha(MSD.Text["d"], 120), TEXT_ALIGN_LEFT)
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

        function Entry:OnValueChange(value)
            if func then
                func(self, value)
            end
        end
    end

    if not x or not y then
        parent:AddItem(Entry)
    end

    return Entry
end

function MSD.VectorDisplay(parent, x, y, w, h, text, vector)
    local Entry = vgui.Create("DPanel")

    if x and y then
        Entry:SetParent(parent)
        Entry:SetPos(x, y)
    end

    if x == "static" then
        Entry.StaticScale = {
            w = w,
            fixed_h = h,
            minw = 150,
            minh = h
        }
    else
        Entry:SetSize(w, h)
    end

    Entry.vector = vector or Vector(0, 0, 0)

    Entry.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, MSD.Theme["l"])
        draw.RoundedBox(0, 0, h - 1, w, 1, MSD.Text["n"])

        if text then
            draw.SimpleText(text, "MSDFont.16", 3, 0, MSD.ColorAlpha(MSD.Text["d"], 120), TEXT_ALIGN_LEFT)
        end

        draw.SimpleText("x: " .. self.vector.x .. " y: " .. self.vector.y .. " z: " .. self.vector.z, "MSDFont.22", 3, h / 2 - 10, MSD.Text["d"], TEXT_ALIGN_LEFT)
    end

    if not x or not y then
        parent:AddItem(Entry)
    end

    return Entry
end

function MSD.AngleDisplay(parent, x, y, w, h, text, angle)
    local Entry = vgui.Create("DPanel")

    if x and y then
        Entry:SetParent(parent)
        Entry:SetPos(x, y)
    end

    if x == "static" then
        Entry.StaticScale = {
            w = w,
            fixed_h = h,
            minw = 150,
            minh = h
        }
    else
        Entry:SetSize(w, h)
    end

    Entry.angle = angle or Angle(0, 0, 0)

    Entry.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, MSD.Theme["l"])
        draw.RoundedBox(0, 0, h - 1, w, 1, MSD.Text["n"])

        if text then
            draw.SimpleText(text, "MSDFont.16", 3, 0, MSD.ColorAlpha(MSD.Text["d"], 120), TEXT_ALIGN_LEFT)
        end

        draw.SimpleText("p: " .. self.angle.p .. " y: " .. self.angle.y .. " r: " .. self.angle.r, "MSDFont.22", 3, h / 2 - 10, MSD.Text["d"], TEXT_ALIGN_LEFT)
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

    button.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, color)

        if (self.hover or self.hovered) and not self.disabled then
            self.alpha = Lerp(FrameTime() * 5, self.alpha, 1)
        else
            self.alpha = Lerp(FrameTime() * 5, self.alpha, 0)
        end

        draw.RoundedBox(0, 0, h - 1, w, 1, MSD.ColorAlpha(MSD.Text["l"], 100 + self.alpha * 155))

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

    binder.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, MSD.Theme["l"])

        if (self.hover or self.hovered or self.Trapping) and not self.disabled then
            self.alpha = Lerp(FrameTime() * 5, self.alpha, 1)
        else
            self.alpha = Lerp(FrameTime() * 5, self.alpha, 0)
        end

        draw.DrawText(text, "MSDFont.22", 5, h / 2 - 11, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha * 255), TEXT_ALIGN_LEFT)
        draw.DrawText(text, "MSDFont.22", 5, h / 2 - 11, MSD.ColorAlpha(self.disabled and MSD.Text["n"] or MSD.Text["s"], 255 - self.alpha * 255), TEXT_ALIGN_LEFT)
        draw.DrawText(string.upper(self:GetText()), "MSDFont.22", w - w / 3 / 2, h / 2 - 11, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha * 255), TEXT_ALIGN_CENTER)
        draw.DrawText(string.upper(self:GetText()), "MSDFont.22", w - w / 3 / 2, h / 2 - 11, MSD.ColorAlpha(self.disabled and MSD.Text["n"] or MSD.Text["s"], 255 - self.alpha * 255), TEXT_ALIGN_CENTER)
        draw.RoundedBox(0, 0, h - 1, (w / 3) * 2 - 5, 1, MSD.ColorAlpha(MSD.Text["l"], 255 - self.alpha * 255))
        draw.RoundedBox(0, 0, h - 1, (w / 3) * 2 - 5, 1, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha * 255))
        draw.RoundedBox(0, w - w / 3, h - 1, w / 3, 1, MSD.ColorAlpha(MSD.Text["l"], 255 - self.alpha * 255))
        draw.RoundedBox(0, w - w / 3, h - 1, w / 3, 1, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha * 255))

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

    button.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, MSD.Theme["l"])

        if (self.hover or self.hovered) and not self.disabled then
            self.alpha = Lerp(FrameTime() * 5, self.alpha, 1)
        else
            self.alpha = Lerp(FrameTime() * 5, self.alpha, 0)
        end

        draw.DrawText(self:GetText(), "MSDFont.22", al_left and 5 or w / 2, h / 2 - 11, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha * 255), al_left and TEXT_ALIGN_LEFT or TEXT_ALIGN_CENTER)
        draw.DrawText(self:GetText(), "MSDFont.22", al_left and 5 or w / 2, h / 2 - 11, MSD.ColorAlpha(self.disabled and MSD.Text["n"] or MSD.Text["s"], 255 - self.alpha * 255), al_left and TEXT_ALIGN_LEFT or TEXT_ALIGN_CENTER)
        draw.RoundedBox(0, 0, h - 1, w, 1, MSD.ColorAlpha(MSD.Text["l"], 255 - self.alpha * 255))
        draw.RoundedBox(0, 0, h - 1, w, 1, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha * 255))

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
            minw = 150,
            minh = h
        }
    else
        button:SetSize(w, h)
    end

    button.alpha = 0
    button:SetFont("MSDFont.22")
    button:SetMin(min)
    button:SetMax(max)

    button.Paint = function(self, w, h)
        if self:HasFocus() then
            self.alpha = Lerp(FrameTime() * 5, self.alpha, 255)
        else
            self.alpha = Lerp(FrameTime() * 5, self.alpha, 0)
        end

        draw.RoundedBox(0, 0, 0, w, h, MSD.Theme["l"])
        draw.RoundedBox(0, 0, h - 1, w, 1, MSD.ColorAlpha(MSD.Text["n"], 255 - self.alpha))
        draw.RoundedBox(0, 0, h - 1, w, 1, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha))

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

function MSD.ButtonIcon(parent, x, y, w, h, text, icon, func, func2, color)
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

    button.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, MSD.Theme["l"])

        if (self.hover or self.hovered) and not self.disabled then
            self.alpha = Lerp(FrameTime() * 5, self.alpha, 1)
        else
            self.alpha = Lerp(FrameTime() * 5, self.alpha, 0)
        end

        draw.DrawText(self:GetText(), "MSDFont.22", 48, h / 2 - 11, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha * 255), TEXT_ALIGN_LEFT)
        draw.DrawText(self:GetText(), "MSDFont.22", 48, h / 2 - 11, MSD.ColorAlpha(self.disabled and MSD.Text["n"] or MSD.Text["s"], 255 - self.alpha * 255), TEXT_ALIGN_LEFT)
        draw.RoundedBox(0, 0, h - 1, w, 1, MSD.ColorAlpha(color or MSD.Text["l"], 255 - self.alpha * 255))
        draw.RoundedBox(0, 0, h - 1, w, 1, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha * 255))
        MSD.DrawTexturedRect(12, h / 2 - 12, 24, 24, icon, MSD.ColorAlpha(color or MSD.Text["l"], 255 - self.alpha * 255))
        MSD.DrawTexturedRect(12, h / 2 - 12, 24, 24, icon, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha * 255))

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
            minw = 150,
            minh = h
        }
    else
        button:SetSize(w, h)
    end

    button.var = var or 1
    button.value = var or 1
    button.alpha = 0
    button.disabled = false

    button.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, MSD.Theme["l"])

        if (self.hover or self.hovered) and not self.disabled then
            self.alpha = Lerp(FrameTime() * 5, self.alpha, 1)
        else
            self.alpha = Lerp(FrameTime() * 5, self.alpha, 0)
        end

        draw.DrawText(text, "MSDFont.22", 3, h / 2 - 11, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha * 255), TEXT_ALIGN_LEFT)
        draw.DrawText(text, "MSDFont.22", 3, h / 2 - 11, MSD.ColorAlpha(self.disabled and MSD.Text["n"] or MSD.Text["s"], 255 - self.alpha * 255), TEXT_ALIGN_LEFT)
        self.var = Lerp(FrameTime() * 7, self.var, self.value)
        draw.RoundedBox(0, w - w / 2 + 10, h / 2 - 10, w / 2 - 20, 20, MSD.Theme["d"])

        if self.disabled then
            draw.DrawText(MSD.GetPhrase("disabled"), "MSDFont.16", w - (w / 2) / 2, h / 2 - 8, MSD.Text["n"], TEXT_ALIGN_CENTER)
        else
            draw.RoundedBox(0, w - w / 2 + 10, h / 2 - 10, (w / 2 - 19) * self.var, 20, cl or MSD.Config.MainColor["p"])
            draw.DrawText(math.Round(self.value * 100) .. "%", "MSDFont.16", w - (w / 2) / 2, h / 2 - 8, MSD.Text["s"], TEXT_ALIGN_CENTER)
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
        local w = self:GetWide()
        local mx, my = gui.MousePos()
        local x = self:ScreenToLocal(mx, my)

        if x < w - w / 2 + 10 then
            self.value = 0
        elseif x > w - 10 then
            self.value = 1
        else
            x = x - ((w - w / 2) + 10)
            x = x / ((w / 2) - 20)
            self.value = x
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
            minw = 150,
            minh = h
        }
    else
        button:SetSize(w, h)
    end

    button.var = var or false
    button.pos = var and 1 or 0
    button.alpha = 0
    button.disabled = false

    button.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, MSD.Theme["l"])

        if (self.hover or self.hovered) and not self.disabled then
            self.alpha = Lerp(FrameTime() * 5, self.alpha, 1)
        else
            self.alpha = Lerp(FrameTime() * 5, self.alpha, 0)
        end

        draw.DrawText(text, "MSDFont.22", 3, h / 2 - 11, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha * 255), TEXT_ALIGN_LEFT)
        draw.DrawText(text, "MSDFont.22", 3, h / 2 - 11, MSD.ColorAlpha(self.disabled and MSD.Text["n"] or MSD.Text["s"], 255 - self.alpha * 255), TEXT_ALIGN_LEFT)

        if self.var then
            self.pos = Lerp(0.1, self.pos, 1)
        else
            self.pos = Lerp(0.1, self.pos, 0)
        end

        draw.RoundedBox(0, w - 75, h / 2 - 10, 68, 20, MSD.Theme["d"])

        if self.disabled then
            draw.DrawText(MSD.GetPhrase("disabled"), "MSDFont.16", w - 40, h / 2 - 8, MSD.Text["n"], TEXT_ALIGN_CENTER)
        else
            draw.DrawText(MSD.GetPhrase("off"), "MSDFont.16", w - 25, h / 2 - 8, MSD.ColorAlpha(MSD.Text["s"], 255 - self.pos * 255), TEXT_ALIGN_CENTER)
            draw.DrawText(MSD.GetPhrase("on"), "MSDFont.16", w - 60, h / 2 - 8, MSD.ColorAlpha(MSD.Text["s"], self.pos * 255), TEXT_ALIGN_CENTER)
            draw.RoundedBox(0, w - 75 + self.pos * 35, h / 2 - 10, 34, 20, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.pos * 255))
            draw.RoundedBox(0, w - 75 + self.pos * 35, h / 2 - 10, 34, 20, MSD.ColorAlpha(MSD.Text["n"], 255 - self.pos * 255))
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
            minw = 150,
            minh = h
        }
    else
        button:SetSize(w, h)
    end

    button.var = var or false
    button.pos = var and 1 or 0
    button.alpha = 0
    button.disabled = false

    button.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, MSD.Theme["l"])

        if (self.hover or self.hovered) and not self.disabled then
            self.alpha = Lerp(FrameTime() * 5, self.alpha, 1)
        else
            self.alpha = Lerp(FrameTime() * 5, self.alpha, 0)
        end

        draw.DrawText(self.var and text1 or text2, "MSDFont.22", 3, h / 2 - 10, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha * 255), TEXT_ALIGN_LEFT)
        draw.DrawText(self.var and text1 or text2, "MSDFont.22", 3, h / 2 - 10, MSD.ColorAlpha(MSD.Text["s"], 255 - self.alpha * 255), TEXT_ALIGN_LEFT)

        if self.var then
            self.pos = Lerp(0.1, self.pos, 1)
        else
            self.pos = Lerp(0.1, self.pos, 0)
        end

        draw.RoundedBox(0, w - 75, h / 2 - 10, 68, 20, MSD.Theme["d"])
        draw.RoundedBox(0, w - 75 + self.pos * 35, h / 2 - 10, 34, 20, MSD.Config.MainColor["p"])
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
            minw = 150,
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

    ComboBox.Paint = function(self, w, h)
        if self:IsMenuOpen() or self.pressed then
            self.alpha = Lerp(FrameTime() * 5, self.alpha, 255)
        else
            self.alpha = Lerp(FrameTime() * 5, self.alpha, 0)
        end

        draw.RoundedBox(0, 0, 0, w, h, MSD.Theme["l"])
        draw.RoundedBox(0, 0, h - 1, w, 1, MSD.ColorAlpha(MSD.Text["s"], 255 - self.alpha))
        draw.RoundedBox(0, 0, h - 1, w, 1, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha))
        draw.SimpleText(self:GetText(), "MSDFont.22", 3, h / 2 - 10, MSD.Text["d"], TEXT_ALIGN_LEFT)

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

        local x, y = self:LocalToScreen(0, self:GetTall())
        self.Menu:SetMinimumWidth(self:GetWide())
        self.Menu:Open(x, y, false, self)
    end

    if not x or not y then
        parent:AddItem(ComboBox)
    end

    return ComboBox
end

function MSD.BigButton(parent, x, y, w, h, text, icon, func, color, text2, func2, text3)
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
            minw = 150,
            minh = h
        }
    else
        button:SetSize(w, h)
    end

    button.alpha = 0
    button.color_idle = color_white

    button.Paint = function(self, w, h)
        if self.hover and not self.disable then
            self.alpha = Lerp(FrameTime() * 5, self.alpha, 1)
        else
            self.alpha = Lerp(FrameTime() * 5, self.alpha, 0)
        end

        draw.RoundedBox(0, 0, 0, w, h, MSD.Theme["d"])
        MSD.DrawTexturedRect(w / 2 - 24, h / 2 - 36, 48, 48, icon, MSD.ColorAlpha(self.color_idle, 255 - self.alpha * 255))
        draw.DrawText(text, "MSDFont.25", w / 2, h / 2 + 10, MSD.ColorAlpha(self.color_idle, 255 - self.alpha * 255), TEXT_ALIGN_CENTER)

        if self.alpha > 0.01 then
            MSD.DrawTexturedRect(w / 2 - 24, h / 2 - 36, 48, 48, icon, MSD.ColorAlpha(color or MSD.Config.MainColor["p"], self.alpha * 255))
            draw.DrawText(text, "MSDFont.25", w / 2, h / 2 + 10, MSD.ColorAlpha(color or MSD.Config.MainColor["p"], self.alpha * 255), TEXT_ALIGN_CENTER)
        end

        if text2 then
            draw.DrawText("id: " .. text2, "MSDFont.20", 10, 10, MSD.Text.d, TEXT_ALIGN_LEFT)
        end

        if text3 then
            draw.DrawText(text3, "MSDFont.20", w / 2, h - 20, MSD.Text.n, TEXT_ALIGN_CENTER)
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