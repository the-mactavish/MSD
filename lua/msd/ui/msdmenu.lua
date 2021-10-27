if SERVER then return end
local tblOpenMenus = {}

function RegisterDermaMenuForClose(dmenu)
	table.insert(tblOpenMenus, dmenu)
end

function MSD.MenuOpen(parentmenu, parent, bg)
	if (not parentmenu) then
		CloseDermaMenus()
	end

	local dmenu = vgui.Create("MSD.DMenu", parent)
	dmenu.ShadowStatic = 0
	dmenu.ShadowInt = 1

	dmenu.Paint = function(self, w, h)
		if bg then
			draw.RoundedBox(MSD.Config.Rounded, 0, 0, w, h, MSD.Theme["d_na"])
		else
			MSD.Blur(self, 1, 2, 255, 55, w, h)
			draw.RoundedBox(MSD.Config.Rounded, 0, 0, w, h, MSD.Theme["d"])
		end
	end

	return dmenu
end

function CloseDermaMenus()
	for k, dmenu in pairs(tblOpenMenus) do
		if (IsValid(dmenu)) then
			dmenu:SetVisible(false)

			if (dmenu:GetDeleteSelf()) then
				dmenu:Remove()
			end
		end
	end

	tblOpenMenus = {}
	hook.Run("CloseDermaMenus")
end

local function DermaDetectMenuFocus(panel, mousecode)
	if (IsValid(panel)) then
		if (panel.m_bIsMenuComponent) then return end

		return DermaDetectMenuFocus(panel:GetParent(), mousecode)
	end

	CloseDermaMenus()
end

hook.Add("VGUIMousePressed", "MatDMenuDetectMenuFocus", DermaDetectMenuFocus)
local PANEL = {}
AccessorFunc(PANEL, "m_bBorder", "DrawBorder")
AccessorFunc(PANEL, "m_bDeleteSelf", "DeleteSelf")
AccessorFunc(PANEL, "m_iMinimumWidth", "MinimumWidth")
AccessorFunc(PANEL, "m_bDrawColumn", "DrawColumn")
AccessorFunc(PANEL, "m_iMaxHeight", "MaxHeight")
AccessorFunc(PANEL, "m_pOpenSubMenu", "OpenSubMenu")

function PANEL:Init()
	self:SetIsMenu(true)
	self:SetDrawBorder(true)
	self:SetPaintBackground(true)
	self:SetMinimumWidth(100)
	self:SetDrawOnTop(true)
	self:SetMaxHeight(ScrH() * 0.9)
	self:SetDeleteSelf(true)
	self:SetPadding(0)
	RegisterDermaMenuForClose(self)
end

function PANEL:AddOption(strText, funcFunction, icon, check)
	if check and not check() then return end

	local pnl = vgui.Create("MSD.DMenuOption", self)
	pnl:SetMenu(self)
	pnl:SetText(strText)
	if icon then
		pnl.icon = icon
		pnl:SetTextInset(38, 0)
	end

	if (funcFunction) then
		pnl.DoClick = funcFunction
	end

	self:AddPanel(pnl)

	return pnl
end

function PANEL:AddSubMenu(strText, funcFunction)
	local pnl = vgui.Create("MSD.DMenuOption", self)
	local SubMenu = pnl:AddSubMenu(strText, funcFunction)
	pnl:SetText(strText)

	if (funcFunction) then
		pnl.DoClick = funcFunction
	end

	self:AddPanel(pnl)

	return SubMenu, pnl
end

derma.DefineControl("MSD.DMenu", "A Menu 2", PANEL, "DMenu")

PANEL = {}
AccessorFunc(PANEL, "m_pMenu", "Menu")
AccessorFunc(PANEL, "m_bChecked", "Checked")
AccessorFunc(PANEL, "m_bCheckable", "IsCheckable")

function PANEL:Init()
	self:SetContentAlignment(4)
	self:SetTextInset(10, 0)
	self:SetFont("MSDFont.16")
	self:SetTextColor(MSD.Text["s"])
	self:SetChecked(false)
	self.ChangeCC = true
	self.ColorText = MSD.Text["s"]
end

function PANEL:OnCursorEntered()
	self.ColorText = MSD.Config.MainColor["p"]
	self.ChangeCC = true

	if (IsValid(self.ParentMenu)) then
		self.ParentMenu:OpenSubMenu(self, self.SubMenu)

		return
	end

	self:GetParent():OpenSubMenu(self, self.SubMenu)
end

function PANEL:OnCursorExited()
	self.ColorText = MSD.Text["l"]
	self.ChangeCC = true
end

function PANEL:AddSubMenu()
	local SubMenu = MSD.MenuOpen(true, self)
	SubMenu:SetVisible(false)
	SubMenu:SetParent(self)
	self:SetSubMenu(SubMenu)

	return SubMenu
end

function PANEL:Paint(w, h)
	if self.ChangeCC then
		self:SetTextColor(self.ColorText)
		self.ChangeCC = nil
	end

	if self.icon then
		local ih = h - 6
		MSD.DrawTexturedRect(5, 3, ih, ih, self.icon, self.ColorText)
	end
end

function PANEL:PerformLayout( w, h )

	self:SizeToContents()
	self:SetWide( self:GetWide() + 30 )

	w = math.max( self:GetParent():GetWide(), self:GetWide() )

	self:SetSize( w, self.icon and 30 or 22 )

	if ( IsValid( self.SubMenuArrow ) ) then

		self.SubMenuArrow:SetSize( 15, 15 )
		self.SubMenuArrow:CenterVertical()
		self.SubMenuArrow:AlignRight( 4 )

	end

	DButton.PerformLayout( self, w, h )

end

derma.DefineControl("MSD.DMenuOption", "Menu Option Line 2", PANEL, "DMenuOption")