
MSD.Icons48 = {
	cross = Material("msd/icons/cross.png", "smooth"),
	cog = Material("msd/icons/cog.png", "smooth"),
	layers = Material("msd/icons/layers.png", "smooth"),
	layers_plus = Material("msd/icons/layers-plus.png", "smooth"),
	layers_remove = Material("msd/icons/layers-remove.png", "smooth"),
	account_edit = Material("msd/icons/account-edit.png", "smooth"),
	account_multiple = Material("msd/icons/account-multiple.png", "smooth"),
	menu = Material("msd/icons/menu.png", "smooth"),
	dot = Material("msd/icons/dot.png", "smooth"),
	pencil = Material("msd/icons/pencil.png", "smooth"),
	play = Material("msd/icons/play.png", "smooth"),
	plus = Material("msd/icons/plus.png", "smooth"),
	back = Material("msd/icons/back.png", "smooth"),
	calendar_check = Material("msd/icons/calendar-check.png", "smooth"),
	playlist_edit = Material("msd/icons/playlist-edit.png", "smooth"),
	seal = Material("msd/icons/seal.png", "smooth"),
	save = Material("msd/icons/content-save.png", "smooth"),
	copy = Material("msd/icons/content-copy.png", "smooth"),
	submit = Material("msd/icons/check-decagram.png", "smooth"),
	alert = Material("msd/icons/alert-circle.png", "smooth"),
	arrow_down_color = Material("msd/icons/arrow_down_color.png", "smooth")
}


MSD.Materials = {
	vignette = Material("mmd/vignette.png", "smooth"),
}

MSD.PinPoints = {
	[0] = Material("mqs/icons/pin.png", "smooth"),
}

local files, folders = file.Find("materials/mqs/map_markers/*", "GAME")

for k,v in pairs(files) do
	MSD.PinPoints[k] = Material("mqs/map_markers/"..v, "smooth")
end

MSD.ColorPresets = {
	Color(255,20,20),
	Color(255,115,0),
	Color(210,255,0),
	Color(0,170,25),
	Color(0,155,255),
	Color(0,100,200),
	Color(135,0,255),
	Color(255,0,100),
}

MSD.Theme = {
	["d"] = Color(0,5,10,165),
	["m"] = Color(0,5,10,120),
	["l"] = Color(0,5,10,85),
}

MSD.Text = {
	["n"] = Color(150,150,150),
	["d"] = Color(220,220,220),
	["s"] = Color(235,235,235),
	["m"] = Color(245,245,245),
	["l"] = Color(255,255,255),
}

local NewFont = surface.CreateFont

for i=0,20 do
	NewFont( "MSDFont.".. 16+i, { font = "AdihausDIN", extended = true, size = 16+i, weight = 500} )
end

NewFont( "MSDFont.Big", { font = "AdihausDIN", extended = true, size = 45, weight = 500} )
NewFont( "MSDFont.Biger", { font = "AdihausDIN", extended = true, size = 55, weight = 500} )

function MSD.DrawTexturedRect(x,y,w,h,mat,color)
	
	if isstring(mat) then
		mat = Material(mat)
	end
	
	surface.SetDrawColor(color)
	surface.SetMaterial(mat)
	surface.DrawTexturedRect(x,y,w,h)
end

function MSD.ColorAlpha(color, alfa)
	return Color(color.r,color.g,color.b,alfa)
end

local blur = Material( "pp/blurscreen" )

function MSD.Blur( panel, inn, density, alpha, back_alpha, w, h )

	local x, y = panel:LocalToScreen(0, 0)
	
	surface.SetDrawColor( 255, 255, 255, alpha )
	surface.SetMaterial( blur )

	for i = 1, 3 do
		blur:SetFloat( "$blur", ( i / inn ) * density )
		blur:Recompute()

		render.UpdateScreenEffectTexture()
		if w and h then
		render.SetScissorRect(-x, -y, x+w, y+h, true)
			surface.DrawTexturedRect( -x, -y, ScrW(), ScrH() )
		render.SetScissorRect(0, 0, 0, 0, false)
		else
			surface.DrawTexturedRect( -x, -y, ScrW(), ScrH() )
		end
	end
	
	if back_alpha and back_alpha > 0 then
		draw.RoundedBox( 0, 0, 0, w, h, Color( 10, 10, 10, back_alpha)) 
	end
	
end