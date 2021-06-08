MSD.Icons48 = {
	cross = Material("msd/icons/cross.png", "smooth"),
	cog = Material("msd/icons/cog.png", "smooth"),
	layers = Material("msd/icons/layers.png", "smooth"),
	layers_plus = Material("msd/icons/layers-plus.png", "smooth"),
	layers_remove = Material("msd/icons/layers-remove.png", "smooth"),
	account = Material("msd/icons/account.png", "smooth"),
	account_plus = Material("msd/icons/account-plus.png", "smooth"),
	account_edit = Material("msd/icons/account-edit.png", "smooth"),
	account_multiple = Material("msd/icons/account-multiple.png", "smooth"),
	account_convert = Material("msd/icons/account-convert.png", "smooth"),
	folder_open = Material("msd/icons/folder-open.png", "smooth"),
	file_document = Material("msd/icons/file-document.png", "smooth"),
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
	arrow_down_color = Material("msd/icons/arrow_down_color.png", "smooth"),
	face_agent = Material("msd/icons/face-agent.png", "smooth"),
	swap = Material("msd/icons/swap.png", "smooth")
}

MSD.Materials = {
	vignette = Material("msd/vignette.png", "smooth"),
	gradient = Material("gui/gradient", "smooth"),
	gradient_right = Material("msd/gradient_right.png", "smooth"),
}

MSD.PinPoints = {
	[0] = Material("mqs/icons/pin.png", "smooth"),
}

local files = file.Find("materials/mqs/map_markers/*", "GAME")

for k, v in pairs(files) do
	MSD.PinPoints[k] = Material("mqs/map_markers/" .. v, "smooth")
end

MSD.ColorPresets = {Color(255, 20, 20), Color(255, 115, 0), Color(210, 255, 0), Color(0, 170, 25), Color(0, 155, 255), Color(0, 100, 200), Color(135, 0, 255), Color(255, 0, 100),}

MSD.Theme = {
	["d"] = Color(0, 5, 10, 165),
	["m"] = Color(0, 5, 10, 120),
	["l"] = Color(0, 5, 10, 85),
}

MSD.Text = {
	["n"] = Color(150, 150, 150),
	["d"] = Color(220, 220, 220),
	["s"] = Color(235, 235, 235),
	["m"] = Color(245, 245, 245),
	["l"] = Color(255, 255, 255),
}

local NewFont = surface.CreateFont

for i = 0, 20 do
	NewFont("MSDFont." .. 16 + i, {
		font = "AdihausDIN",
		extended = true,
		size = 16 + i,
		weight = 500
	})
end

NewFont("MSDFont.Big", {
	font = "AdihausDIN",
	extended = true,
	size = 45,
	weight = 500
})

NewFont("MSDFont.Biger", {
	font = "AdihausDIN",
	extended = true,
	size = 55,
	weight = 500
})

function MSD.DrawTexturedRect(x, y, w, h, mat, color)
	if isstring(mat) then
		mat = Material(mat)
	end

	surface.SetDrawColor(color)
	surface.SetMaterial(mat)
	surface.DrawTexturedRect(x, y, w, h)
end

function MSD.DrawTexturedRectRotated(rot, x, y, w, h, mat, color)
	if isstring(mat) then
		mat = Material(mat)
	end

	surface.SetDrawColor(color)
	surface.SetMaterial(mat)
	surface.DrawTexturedRectRotated(x, y, w, h, rot)
end

function MSD.ColorAlpha(color, alfa)
	return Color(color.r, color.g, color.b, alfa)
end

local blur = Material("pp/blurscreen")

function MSD.Blur(panel, inn, density, alpha, back_alpha, w, h)
	local x, y = panel:LocalToScreen(0, 0)
	surface.SetDrawColor(255, 255, 255, alpha)
	surface.SetMaterial(blur)

	for i = 1, 3 do
		blur:SetFloat("$blur", (i / inn) * density)
		blur:Recompute()
		render.UpdateScreenEffectTexture()

		if w and h then
			render.SetScissorRect(-x, -y, x + w, y + h, true)
			surface.DrawTexturedRect(-x, -y, ScrW(), ScrH())
			render.SetScissorRect(0, 0, 0, 0, false)
		else
			surface.DrawTexturedRect(-x, -y, ScrW(), ScrH())
		end
	end

	if back_alpha and back_alpha > 0 then
		draw.RoundedBox(0, 0, 0, w, h, Color(10, 10, 10, back_alpha))
	end
end

-- Same used in DarkRP, used it here so we can use it with any gamemodes
local function CharWrap(t, w)
	local a = 0

	t = t:gsub(".", function(c)
		a = a + surface.GetTextSize(c)

		if a >= w then
			a = 0

			return "\n" .. c
		end

		return c
	end)

	return t, a
end

function MSD.TextWrap(text, font, w)
	local total = 0
	surface.SetFont(font)
	local spaceSize = surface.GetTextSize(' ')

	text = text:gsub("(%s?[%S]+)", function(word)
		local char = string.sub(word, 1, 1)

		if char == "\n" or char == "\t" then
			total = 0
		end

		local wordlen = surface.GetTextSize(word)
		total = total + wordlen

		if wordlen >= w then
			local splitWord, splitPoint = CharWrap(word, w - (total - wordlen))
			total = splitPoint

			return splitWord
		elseif total < w then
			return word
		end

		if char == ' ' then
			total = wordlen - spaceSize

			return '\n' .. string.sub(word, 2)
		end

		total = wordlen

		return '\n' .. word
	end)

	local w_end, h_end =  surface.GetTextSize(text)

	return text, w_end, h_end
end

MSD.ImgLib = {}
MSD.ImgLib.Images = {}
MSD.ImgLib.PreCacheStarted = {}
MSD.ImgLib.NoMaterial = Material("msd/icons/file-hidden.png", "smooth noclamp")

function MSD.ImgLib.GetMaterial(url)
	local crc = util.CRC(url) .. ".png"
	if MSD.ImgLib.Images[crc] then return MSD.ImgLib.Images[crc] end

	if (file.Exists("msd_imgs/" .. crc, "DATA")) then
		MSD.ImgLib.Images[crc] = Material("data/msd_imgs/" .. crc, "smooth noclamp")

		return MSD.ImgLib.Images[crc]
	else
		return MSD.ImgLib.PreCacheMaterial(url, crc)
	end
end

function MSD.ImgLib.PreCacheMaterial(url, crc)
	if not crc then
		crc = util.CRC(url) .. ".png"
	end

	if not file.Exists("msd_imgs", "DATA") then
		file.CreateDir("msd_imgs")
	end

	if not MSD.ImgLib.PreCacheStarted[crc] then
		MSD.ImgLib.PreCacheStarted[crc] = true

		http.Fetch(url, function(body, size, headers, code)
			if (body:find("^.PNG")) then
				file.Write("msd_imgs/" .. crc, body)
				MSD.ImgLib.Images[crc] = Material("data/msd_imgs/" .. crc, "smooth noclamp")

				return MSD.ImgLib.Images[crc]
			else
				print("Image is not a PNG, url - " .. url)
			end
		end, function()
			print("Failed to get image, url - " .. url)
		end)
	end

	return MSD.ImgLib.NoMaterial
end