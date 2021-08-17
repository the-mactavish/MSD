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

function PANEL:Init()
	self:SetDraggableName("GlobalDPanel")
	self.pnlCanvas = vgui.Create("DPanel", self)
	self.pnlCanvas:SetPaintBackground(false)

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

local sdw = Color(0, 0, 0, 70)

function PANEL:EnableVerticalScrollbar()
	if (self.VBar) then return end
	self.VBar = vgui.Create("DVScrollBar", self)

	self.VBar.Paint = function(s, w, h)
		draw.RoundedBox(4, 3, 13, 8, h - 24, sdw)
	end

	self.VBar.btnUp.Paint = function(s, w, h) end
	self.VBar.btnDown.Paint = function(s, w, h) end

	self.VBar.btnGrip.Paint = function(s, w, h)
		draw.RoundedBox(4, 5, 0, 4, h + 22, sdw)
	end
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

function PANEL:InsertBefore(before, insert, strLineState)
	table.RemoveByValue(self.Items, insert)
	self:AddItem(insert, strLineState)
	local key = table.KeyFromValue(self.Items, before)

	if (key) then
		table.RemoveByValue(self.Items, insert)
		table.insert(self.Items, key, insert)
	end
end

function PANEL:InsertAfter(before, insert, strLineState)
	table.RemoveByValue(self.Items, insert)
	self:AddItem(insert, strLineState)
	local key = table.KeyFromValue(self.Items, before)

	if (key) then
		table.RemoveByValue(self.Items, insert)
		table.insert(self.Items, key + 1, insert)
	end
end

function PANEL:InsertAtTop(insert, strLineState)
	table.RemoveByValue(self.Items, insert)
	self:AddItem(insert, strLineState)
	local key = 1

	if (key) then
		table.RemoveByValue(self.Items, insert)
		table.insert(self.Items, key, insert)
	end
end

function PANEL.DropAction(Slot, RcvSlot)
	local PanelToMove = Slot.Panel

	if (dragndrop.m_MenuData == "copy") then
		if (PanelToMove.Copy) then
			PanelToMove = Slot.Panel:Copy()
			PanelToMove.m_strLineState = Slot.Panel.m_strLineState
		else
			return
		end
	end

	PanelToMove:SetPos(RcvSlot.Data.pnlCanvas:ScreenToLocal(gui.MouseX() - dragndrop.m_MouseLocalX, gui.MouseY() - dragndrop.m_MouseLocalY))

	if (dragndrop.DropPos == 4 or dragndrop.DropPos == 8) then
		RcvSlot.Data:InsertBefore(RcvSlot.Panel, PanelToMove)
	else
		RcvSlot.Data:InsertAfter(RcvSlot.Panel, PanelToMove)
	end
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
	local x, y = self.Padding, self.Padding
	local l_highest = 0

	for k, panel in pairs(self.Items) do
		if (panel:IsVisible()) then
			if panel.StaticScale then
				local w, h

				if isstring(panel.StaticScale.w) then
					w = tonumber(panel.StaticScale.w)
					w = (self.pnlCanvas:GetWide() - (self.pnlCanvas:GetWide() / w)) - (self.Spacing + self.Padding)
				elseif panel.StaticScale.w == 1 then
					w = self.pnlCanvas:GetWide() / panel.StaticScale.w - (self.Spacing + self.Padding)
				else
					w = self.pnlCanvas:GetWide() / panel.StaticScale.w - (self.Spacing + self.Padding) / 1.5
				end

				if panel.StaticScale.fixed_h then
					h = panel.StaticScale.fixed_h
				elseif panel.StaticScale.h_w then
					h = w
				elseif panel.StaticScale.h then
					if isstring(panel.StaticScale.h) then
						h = tonumber(panel.StaticScale.h)
						h = (self:GetTall() - (self:GetTall() / h)) - (self.Spacing + self.Spacing / h + self.Padding)
					elseif panel.StaticScale.h == 1 then
						h = self:GetTall() / panel.StaticScale.h - (self.Spacing + self.Padding)
					else
						h = self:GetTall() / panel.StaticScale.h - (self.Spacing + self.Padding)
					end
				end

				if panel.StaticScale.minw > w then
					w = panel.StaticScale.minw
				end

				if panel.StaticScale.h and panel.StaticScale.minh > h then
					h = panel.StaticScale.minh
				end

				panel:SetSize(w, h)
			end

			local OwnLine = (panel.m_strLineState and panel.m_strLineState == "ownline")
			local w = panel:GetWide()
			local h = panel:GetTall()
			local vbar = 0

			if (self.VBar and self.VBar.Enabled and not self.IgnoreVbar) then
				vbar = 13
			end

			if (x > self.Padding and (x + w > (self:GetWide() - vbar) or OwnLine)) then
				x = self.Padding
				y = y + l_highest + self.Spacing
				l_highest = h
			end

			if h > l_highest then
				l_highest = h
			end

			if (self.m_fAnimTime > 0 and self.m_iBuilds > 1) then
				panel:MoveTo(x, y, self.m_fAnimTime, 0, self.m_fAnimEase)
			else
				panel:SetPos(x, y)
			end

			x = x + w + self.Spacing
			Offset = y + l_highest + self.Spacing

			if (OwnLine) then
				x = self.Padding
				y = y + h + self.Spacing
			end
		end
	end

	return Offset
end

function PANEL:NormalRebuild(Offset)
	for k, panel in pairs(self.Items) do
		if (panel:IsVisible()) then
			if (self.m_bNoSizing) then
				panel:SizeToContents()

				if (self.m_fAnimTime > 0 and self.m_iBuilds > 1) then
					panel:MoveTo((self:GetCanvas():GetWide() - panel:GetWide()) * 0.5, self.Padding + Offset, self.m_fAnimTime, 0, self.m_fAnimEase)
				else
					panel:SetPos((self:GetCanvas():GetWide() - panel:GetWide()) * 0.5, self.Padding + Offset)
				end
			else
				panel:SetWide(self:GetCanvas():GetWide() - self.Padding * 2)

				if (self.m_fAnimTime > 0 and self.m_iBuilds > 1) then
					panel:MoveTo(self.Padding, self.Padding + Offset, self.m_fAnimTime, self.m_fAnimEase)
				else
					panel:SetPos(self.Padding, self.Padding + Offset)
				end
			end

			panel:InvalidateLayout(true)
			Offset = Offset + panel:GetTall() + self.Spacing
		end
	end

	Offset = Offset + self.Padding

	return Offset
end

function PANEL:Rebuild()
	local Offset = 0
	self.m_iBuilds = self.m_iBuilds + 1
	self:CleanList()

	if (self.Horizontal) then
		Offset = self:HorizontalRebuild(Offset)
	else
		Offset = self:NormalRebuild(Offset)
	end

	self:GetCanvas():SetTall(Offset + self.Padding - self.Spacing)

	if (self.m_bNoSizing and self:GetCanvas():GetTall() < self:GetTall()) then
		self:GetCanvas():SetPos(0, (self:GetTall() - self:GetCanvas():GetTall()) * 0.5)
	end
end

function PANEL:OnMouseWheeled(dlta)
	if (self.VBar) then return self.VBar:OnMouseWheeled(dlta) end
end

function PANEL:Paint(w, h)
	derma.SkinHook("Paint", "PanelList", self, w, h)

	return true
end

function PANEL:OnVScroll(iOffset)
	self.pnlCanvas:SetPos(0, iOffset)
end

function PANEL:PerformLayout()
	local Wide = self:GetWide()
	local Tall = self.pnlCanvas:GetTall()
	local YPos = 0

	if (not self.Rebuild) then
		debug.Trace()
	end

	self:Rebuild()

	if (self.VBar) then
		self.VBar:SetPos(self:GetWide() - 13, 0)
		self.VBar:SetSize(13, self:GetTall())
		self.VBar:SetUp(self:GetTall(), self.pnlCanvas:GetTall())
		YPos = self.VBar:GetOffset()

		if not self.IgnoreVbar then
			Wide = Wide - 13
		end
	end

	self.pnlCanvas:SetPos(0, YPos)
	self.pnlCanvas:SetWide(Wide)

	if (self:GetAutoSize()) then
		self:SetTall(self.pnlCanvas:GetTall())
		self.pnlCanvas:SetPos(0, 0)
	end

	if (self.VBar and not self:GetAutoSize() and Tall ~= self.pnlCanvas:GetTall()) then
		self.VBar:SetScroll(self.VBar:GetScroll())
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

function PANEL:SortByMember(key, desc)
	desc = desc or true

	table.sort(self.Items, function(a, b)
		if (desc) then
			local ta = a
			local tb = b
			a = tb
			b = ta
		end

		if (a[key] == nil) then return false end
		if (b[key] == nil) then return true end

		return a[key] > b[key]
	end)
end

derma.DefineControl("MSDPanelList", "Fancy DpanelList", PANEL, "DPanel")