local ScrW, ScrH = ScrW, ScrH
local Ln = MSD.GetPhrase
local logo = Material("msd/macnco.png", "smooth")
CreateClientConVar("mmd_lastscr", 0, true, false)

function MSD.AdminAccess(ply)
	if MQS then
		return MQS.IsEditor(ply)
	end
	return ply:IsSuperAdmin()
end

function MSD.OpenMenuManager(parrent, mod_open)
	if not MSD.AdminAccess(LocalPlayer()) then return end

	if IsValid(MSD.SetupMenu) then
		if not MSD.SetupMenu:IsVisible() then
			MSD.SetupMenu:AlphaTo(255, 0.4)
			MSD.SetupMenu:Show()
			MSD.SetupMenu:Center()
			return
		end
		if parrent then
			MSD.SetupMenu:Center()
			return
		else
			MSD.SetupMenu:Close()
		end
	end

	local pnl_w, pnl_h = ScrW(), ScrH()
	pnl_w, pnl_h = pnl_w - pnl_w / 4, pnl_h - pnl_h / 6
	local panel, setbut

	if parrent then
		panel = parrent:Add("MSDSimpleFrame")
	else
		panel = vgui.Create("MSDSimpleFrame")
		panel:MakePopup()
	end

	panel:SetSize(pnl_w, pnl_h)
	panel:Center()
	panel:SetAlpha(0)
	panel:AlphaTo(255, 0.3)

	panel.Paint = function(self, w, h)
		MSD.DrawBG(self, w, h)

		draw.RoundedBox(MSD.Config.Rounded, 0, 0, w, 50, MSD.Theme["d"])
		draw.RoundedBox(MSD.Config.Rounded, 0, 52, w, h - 52, MSD.Theme["l"])
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
		if panel.ModuleSwitch then panel.ModuleSwitch() panel.ModuleSwitch = nil end
		MSD.SetupMenu = nil
	end

	if not parrent then
		panel.clsHide = MSD.IconButton(panel, MSD.Icons48.dot, panel:GetWide() - 64, 10, 25, nil, MSD.Config.MainColor.p, function()
			if panel.OnPress then
				panel.OnPress()

				return
			end

			panel:AlphaTo(0, .4, 0, function()
				MSD.SetupMenu:Hide()
			end)
		end)
	end

	panel.Menu = vgui.Create("MSDPanelList", panel)
	panel.Menu:SetSize(panel:GetWide() / 2, 50)
	panel.Menu:SetPos(0, 0)
	--panel.Menu:EnableVerticalScrollbar()
	panel.Menu:EnableHorizontal(true)
	panel.Menu:SetSpacing(2)
	panel.Menu.IgnoreVbar = true
	panel.Menu.Paint = function() end
	panel.Menu.Deselect = function(but)
		if not but then return end
		but.hovered = true

		for k, v in pairs(panel.Menu:GetItems()) do
			if v and v:IsValid() and v ~= but then
				v.hovered = false
			end
		end
	end

	function panel.ReOpenCanvas()
		if IsValid(panel.Canvas) then panel.Canvas:Remove() end
		panel.Canvas = vgui.Create("DPanel", panel)
		panel.Canvas:SetSize(panel:GetWide(), panel:GetTall() - 52)
		panel.Canvas:SetPos(0, 52)
		panel.Canvas.Paint = function() end
	end

	local cnv = GetConVar("mmd_lastscr")

	function panel.OpenSettings()
		cnv:SetInt(-1)
		panel.ReOpenCanvas()
		panel.Menu.Deselect(setbut)
		MSD.OpenSettingsMenu(panel.Canvas, panel)
	end

	for id, mod in ipairs(MSD.Modules) do
		local button = MSD.MenuButtonTop(panel.Menu, mod.icon, nil, nil, "auto", 50, mod.name, function(self)
			if panel.ModuleSwitch then panel.ModuleSwitch() panel.ModuleSwitch = nil end
			cnv:SetInt(id)
			panel.ReOpenCanvas()
			panel.Menu.Deselect(self)
			mod.menu(panel.Canvas, panel)
		end)

		if (mod_open and id == mod_open) or (cnv:GetInt() == 0 and id == 1) or cnv:GetInt() == id then
			panel.ReOpenCanvas()
			panel.Menu.Deselect(button)
			mod.menu(panel.Canvas, panel)
		end
	end

	setbut = MSD.MenuButtonTop(panel.Menu, MSD.Icons48.cog, nil, nil, "auto", 50, "", function(self)
		panel.OpenSettings()
	end)

	if cnv:GetInt() == -1 and not mod_open then
		panel.OpenSettings()
	end

	MSD.SetupMenu = panel

	return panel
end

function MSD.OpenSettingsMenu(panel)

	oldcfg = MSD.Config

	panel.Canvas = vgui.Create("MSDPanelList", panel)
	panel.Canvas:SetSize(panel:GetWide() / 2 - 5, panel:GetTall())
	panel.Canvas:SetPos(panel:GetWide() / 2 + 5, 0)
	panel.Canvas:EnableVerticalScrollbar()
	panel.Canvas:EnableHorizontal(true)
	panel.Canvas:SetSpacing(2)
	panel.Canvas.IgnoreVbar = true
	panel.Canvas.Paint = function() end

	panel.Settings = vgui.Create("MSDPanelList", panel)
	panel.Settings:SetSize(panel:GetWide() / 2, panel:GetTall())
	panel.Settings:SetPos(0, 0)
	panel.Settings:EnableVerticalScrollbar()
	panel.Settings:EnableHorizontal(true)
	panel.Settings:SetSpacing(2)
	panel.Settings.IgnoreVbar = true
	panel.Settings.Paint = function() end

	panel.Settings.Update = function()
		panel.Settings:Clear()

		MSD.Header(panel.Settings, Ln("set_ui"))
		local combo = MSD.ComboBox(panel.Settings, "static", nil, 1, 50, "Language:", Ln("none"))

		combo.OnSelect = function(self, index, text, data)
			MSD.Config.Language = data
			panel.Settings.Update()
		end

		for k, v in pairs(MSD.Language) do
			combo:AddChoice(v.lang_name, k)
		end

		combo:SetValue(Ln("lang_name"))
		local sld1

		local function sliderCL(cl)
			local c = math.Clamp(math.Round(cl * 255), 30, 250)
			MSD.Config.BgrColor = Color(c, c, c)
		end

		MSD.DTextSlider(panel.Settings, "static", nil, 1, 50, Ln("set_ui_blur"), Ln("set_ui_mono"), MSD.Config.Blur, function(self, value)
			MSD.Config.Blur = value
			if value then
				sld1.value = 1
				sliderCL(sld1.value)
			else
				sld1.value = 0.18
				sliderCL(sld1.value)
			end
		end)

		sld1 = MSD.VolumeSlider(panel.Settings, "static", nil, 1, 50, Ln("set_ui_brightness"), MSD.Config.BgrColor.r / 255, function(self, var)
			sliderCL(var)
		end)

		MSD.ColorSelector(panel.Settings, "static", nil, 1, 50, Ln("set_ui_color"), MSD.Config.MainColor.p, function(self, color)
			MSD.Config.MainColor.p = color
		end)

		MSD.DTextSlider(panel.Settings, "static", nil, 1, 50, Ln("border_rounded"), Ln("border_square"), MSD.Config.Rounded == 8, function(self, value)
			if value then
				MSD.Config.Rounded = 8
			else
				MSD.Config.Rounded = 0
			end
		end)

		if LocalPlayer():IsSuperAdmin() then
			MSD.BigButton(panel.Settings, "static", nil, 2, 80, Ln("upl_changes"), MSD.Icons48.save, function()
				MSD.SaveConfig()
				panel.Settings.Update()
			end)

			MSD.BigButton(panel.Settings, "static", nil, 2, 80, Ln("res_changes"), MSD.Icons48.cross, function()
				MSD.Config = oldcfg
				panel.Settings.Update()
			end)
		end
	end

	panel.Settings.Update()

	local pnl = vgui.Create("DPanel")

	pnl.StaticScale = {
		w = 1,
		h = 1,
		minw = 150,
		minh = 150
	}

	pnl.Paint = function(self, w, h)
		MSD.DrawTexturedRect(w / 2 - 128, h / 2 - 128, 256, 236, logo, MSD.Text["l"])
		draw.DrawText("MSD UI version - " .. MSD.Version, "MSDFont.25", w / 2, h / 2 + 130, MSD.Text["l"], TEXT_ALIGN_CENTER)
	end

	panel.Canvas:AddItem(pnl)
end