-- Radial (pie) menu and a simple progress bar.
--
-- MSD.RadialMenu: fill panel.actions with {name, func, icon, check} entries, then call panel:Build().
-- Left click runs the hovered action; the mouse is kept near the centre while the menu is open.

local BLUR_STRENGTH = 5
local MOUSE_CHECK_DIST = 120
local EDGE_THICKNESS = 4

local Panel = {}

function Panel:Init()
	self.actions = {}
	self:SetCursor("blank")
	self:Build()
end

function Panel:Build()
	self.m_strSndHover = "msd/ui/click.wav"
	self.m_intCurAngle = 90
	self.m_intTargetAngle = 90
	self:InitializeButtons()
end

function Panel:InitializeButtons()
	self.m_tblButtons = {}

	for k, v in ipairs(self.actions) do
		if v[4] and not v[4]() then continue end

		self.m_tblButtons[k] = {
			Name = v[1],
			Cmd = v[2],
			icon = v[3],
		}
	end

	self.m_intBtnAng = math.pi * 2 / #self.m_tblButtons

	for k, v in pairs(self.m_tblButtons) do
		v.Angle = (k - 2) * self.m_intBtnAng - math.pi / 2

		while v.Angle < 0 do
			v.Angle = v.Angle + math.pi * 2
		end
	end
end

function Panel:Think()
	local mx, my = gui.MousePos()
	local cx, cy = ScrW() / 2, ScrH() / 2
	local dist = math.Distance(mx, my, cx, cy)

	if dist > 48 then
		local norm = Vector(mx - cx, cy - my, 0):GetNormal()
		self.m_intTargetAngle = norm:Angle().y

		if dist > MOUSE_CHECK_DIST then
			gui.SetMousePos(cx + norm.x * MOUSE_CHECK_DIST, cy - norm.y * MOUSE_CHECK_DIST)
		end
	end

	self.m_intCurAngle = math.ApproachAngle(self.m_intCurAngle, self.m_intTargetAngle, 55 * (math.AngleDifference(self.m_intCurAngle, self.m_intTargetAngle) / 180))
	self.m_intCurSelection = self:GetCurrentSelection()

	if self.m_intLastSelection and self.m_intCurSelection ~= self.m_intLastSelection then
		MSD.UISnd(self.m_strSndHover)
	end

	self.m_intLastSelection = self.m_intCurSelection

	if self.KeyThink then self.KeyThink() end
end

function Panel:GetCurrentSelection()
	local selectionAngle, selection = -1, nil
	local selectedAng = -1

	for k, v in pairs(self.m_tblButtons) do
		local ang = math.deg(v.Angle - self.m_intBtnAng / 2)
		local diff = math.AngleDifference(self.m_intCurAngle, ang)

		if selectionAngle == -1 or diff < selectionAngle then
			selectionAngle = diff
			selection = k
			selectedAng = math.deg(v.Angle) + 180
		end
	end

	return selection, math.NormalizeAngle(selectedAng)
end

function Panel:Paint(intW, intH)
	local sx, sy = intW / 2, intH / 2
	local center = intW / 2.66

	-- Blurred disc with a darker inner ring
	MSD.DrawBlurCircle(sx, sx, intW, BLUR_STRENGTH)
	MSDX.DrawCircle(sx, sx, intW, MSD.Theme.d)
	MSDX.DrawCircle(sx, sx, intW / 2, MSD.Theme.d)

	-- Edge along the rim of the highlighted slice. Buttons sit at angle pi - v.Angle (screen space).
	local selected = self.m_tblButtons[self.m_intCurSelection]

	if selected then
		local half = math.deg(self.m_intBtnAng / 2)
		local from = (math.deg(math.pi - selected.Angle) - half) % 360

		-- Darker slice between the inner circle and the rim, then the edge on top
		MSD.DrawArc(sx, sx, intW, from, from + half * 2, MSD.Theme.d, intW / 4)
		MSD.DrawArc(sx, sx, intW, from, from + half * 2, MSD.Config.MainColor["p"], EDGE_THICKNESS)
	end

	for k, v in pairs(self.m_tblButtons) do
		local sel = k == self.m_intCurSelection
		local ang = v.Angle
		local x, y = sx - math.cos(ang) * center, sy + math.sin(ang) * (center - 1)
		local color = sel and MSD.Config.MainColor["p"] or MSD.Text.s


		if v.icon then
			MSD.DrawTexturedRect(x - 24, y - 24, 48, 48, v.icon, color)
		else
			draw.DrawText(v.Name, "MSDFont.22", x, y, color, TEXT_ALIGN_CENTER)
		end
	end

	if selected then
		draw.DrawText(selected.Name, "MSDFont.28", sx, sy - sy / 4, MSD.Text.s, TEXT_ALIGN_CENTER)

		if selected.icon then
			local size = math.min(math.Round(intW * 0.1), 48)
			MSD.DrawTexturedRect(sx - size / 2, sy - size / 4, size, size, selected.icon, MSD.Config.MainColor["p"])
		end
	end
end

function Panel:OnMousePressed(code)
	if code ~= MOUSE_LEFT then return end

	local action = self.m_tblButtons[self:GetCurrentSelection()]

	if action then
		action.Cmd()
	end
end

vgui.Register("MSD.RadialMenu", Panel, "EditablePanel")

-- MSDProgressBar: SetMin/SetMax/SetValue; SetAnimated(true) eases the bar towards the value; SetColor() overrides the bar color

local PANEL = {}

AccessorFunc(PANEL, "Min", "Min")
AccessorFunc(PANEL, "Max", "Max")
AccessorFunc(PANEL, "Value", "Value")
AccessorFunc(PANEL, "OldValue", "OldValue")
AccessorFunc(PANEL, "Percentage", "Percentage")
AccessorFunc(PANEL, "Desc", "Desc")
AccessorFunc(PANEL, "Animated", "Animated")
AccessorFunc(PANEL, "Color", "Color") -- bar color, defaults to the main color

function PANEL:Init()
	self:SetSize(500, 32)
	self:SetMax(100)
	self:SetMin(0)
	self:SetValue(0)
end

function PANEL:SetValue(value)
	if self:GetAnimated() then
		self:SetOldValue(self:GetValue() or value)
	else
		self:SetOldValue(value)
	end

	self.Value = value
end

function PANEL:Paint(w, h)
	MSDX.Draw(MSD.Config.Rounded, 0, 0, w, h, MSD.Theme["d"])

	if self:GetAnimated() then
		self:SetOldValue(Lerp(0.1, self:GetOldValue(), self:GetValue()))
	end

	local width = math.min(math.Round(w * (self:GetOldValue() - self:GetMin()) / (self:GetMax() - self:GetMin())), w)
	MSDX.Draw(MSD.Config.Rounded, 2, 2, width - 4, h - 4, self:GetColor() or MSD.Config.MainColor["p"])
end

derma.DefineControl("MSDProgressBar", "", PANEL)
