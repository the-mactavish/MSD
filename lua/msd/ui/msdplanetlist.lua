local PANEL = {}
AccessorFunc(PANEL, "m_bSizeToContents", "AutoSize")
AccessorFunc(PANEL, "m_bStretchHorizontally", "StretchHorizontally")
AccessorFunc(PANEL, "m_bNoSizing", "NoSizing")
AccessorFunc(PANEL, "m_bSortable", "Sortable")
AccessorFunc(PANEL, "m_fAnimTime", "AnimTime")
AccessorFunc(PANEL, "m_fAnimEase", "AnimEase")
AccessorFunc(PANEL, "m_strDraggableName", "DraggableName")
AccessorFunc(PANEL, "Spacing", "Spacing")
AccessorFunc(PANEL, "Padding", "Padding")

local clb = Color(0,0,99)

function PANEL:Init()
	self.pnlCanvas = vgui.Create("DPanel", self)
	self.pnlCanvas.Paint = function(s, w, h)
		draw.RoundedBox(0, 0, 0, w, h, clb)
		MSD.DrawTexturedRect(0, 0, w, h, MSD.Materials.vignette, color_black)
	end

	self.pnlCanvas.OnMousePressed = function(s, code)
		s:GetParent():OnMousePressed(code)
	end

	self.pnlCanvas.OnChildRemoved = function()
		self:OnChildRemoved()
	end

	self.pnlCanvas:SetMouseInputEnabled(true)

	self.pnlCanvas.InvalidateLayout = function()
		self:InvalidateLayout()
	end

	self.pnlCanvas.MasterPanel = self
	self.pnlCanvas:SetPos(500, 500)
	self.Items = {}
	self.YOffset = 0
	self.m_fAnimTime = 0
	self.m_fAnimEase = -1
	self.m_iBuilds = 0
	self.IgnoreVbar = true
	self:SetSpacing(0)
	self:SetPadding(0)
	self:EnableHorizontal(false)
	self:SetAutoSize(false)
	self:SetPaintBackground(true)
	self:SetNoSizing(false)
	self:SetMouseInputEnabled(true)
	self:SetPaintBackgroundEnabled(false)
	self:SetPaintBorderEnabled(false)
end

function PANEL:OnModified()
	-- Override me
end

function PANEL:SizeToContents()
	self:SetSize(self.pnlCanvas:GetSize())
end

function PANEL:GetItems()
	return self.Items
end

function PANEL:EnableHorizontal(bHoriz)
	self.Horizontal = bHoriz
end

function PANEL:GetCanvas()
	return self.pnlCanvas
end

function PANEL:Clear(nDelete)
	for k, panel in pairs(self.Items) do
		if (not IsValid(panel)) then continue end
		panel:Remove()

		if (nDelete) then
			panel:SetVisible(false)
		end
	end

	self.Items = {}
end

function PANEL:ClearEX(ex_panel)
	if (not IsValid(ex_panel)) then return end

	for k, panel in pairs(self.Items) do
		if (not IsValid(panel)) then continue end

		if (panel ~= ex_panel) then
			panel:Remove()
		end
	end

	self.Items = {}
	table.insert(self.Items, ex_panel)
end

function PANEL:AddItem(item, strLineState)
	if (not IsValid(item)) then return end
	item:SetVisible(true)
	item:SetParent(self:GetCanvas())
	item.m_strLineState = strLineState or item.m_strLineState
	table.insert(self.Items, item)
	item:SetSelectable(self.m_bSelectionCanvas)
	self:InvalidateLayout()
end

function PANEL:RemoveItem(item, bDontDelete)
	for k, panel in pairs(self.Items) do
		if (panel == item) then
			self.Items[k] = nil

			if (not bDontDelete) then
				panel:Remove()
			end

			self:InvalidateLayout()
		end
	end
end

function PANEL:CleanList()
	for k, panel in pairs(self.Items) do
		if (not IsValid(panel) or panel:GetParent() ~= self.pnlCanvas) then
			self.Items[k] = nil
		end
	end
end

function PANEL:HorizontalRebuild(Offset)
	for k, panel in pairs(self.Items) do
		if (panel:IsVisible()) then
			if not panel.Pos then
				panel.Pos = {5, 5}
			end

			panel:SetPos(panel.Pos[1], panel.Pos[2])
		end
	end

	return Offset
end

function PANEL:Rebuild()
	local Offset = 0
	self.m_iBuilds = self.m_iBuilds + 1
	self:CleanList()
	Offset = self:HorizontalRebuild(Offset)
end

function PANEL:OnMouseWheeled(dlta)
	if not self.XPos then return end

	local w, h = self:GetSize()

	if input.IsKeyDown( KEY_LCONTROL ) then
		self.XPos = math.Clamp(self.XPos + 5 * dlta, -w, 0)
	else
		self.YPos = math.Clamp(self.YPos + 5 * dlta, -h, 0)
	end

	print(self.XPos, self.YPos)

	self:PerformLayout()
end

function PANEL:Paint(w, h)
	return true
end

function PANEL:OnVScroll(iOffset)
	self.pnlCanvas:SetPos(0, iOffset)
end

function PANEL:PerformLayout()
	local YPos = self.YPos
	local XPos = self.XPos

	if (not self.Rebuild) then
		debug.Trace()
	end

	if self.CanvasSize then
		self.pnlCanvas:SetSize(self.CanvasSize[1], self.CanvasSize[2])
	end

	self:Rebuild()
	if not YPos and not XPos then
		self.pnlCanvas:Center()
		self.XPos, self.YPos = self.pnlCanvas:GetPos()
	else
		self.pnlCanvas:SetPos(XPos, YPos)
	end
end

function PANEL:OnChildRemoved()
	self:CleanList()
	self:InvalidateLayout()
end

function PANEL:ScrollToChild(panel)
	local _, y = self.pnlCanvas:GetChildPosition(panel)
	local _, h = panel:GetSize()
	y = y + h * 0.5
	y = y - self:GetTall() * 0.5
	self.VBar:AnimateTo(y, 0.5, 0, 0.5)
end

derma.DefineControl("SWPlanetList", "Fancy stuff", PANEL, "DPanel")