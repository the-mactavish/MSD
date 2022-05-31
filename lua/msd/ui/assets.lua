MSD.Icons48 = {
	cross = Material("msd/icons/cross.png", "smooth"),
	cog = Material("msd/icons/cog.png", "smooth"),
	eye = Material("msd/icons/eye.png", "smooth"),
	box = Material("mqs/map_markers/b5.png", "smooth"),
	box_open = Material("mqs/icons/box_open.png", "smooth"),
	layers = Material("msd/icons/layers.png", "smooth"),
	layers_plus = Material("msd/icons/layers-plus.png", "smooth"),
	layers_remove = Material("msd/icons/layers-remove.png", "smooth"),
	briefcase = Material("msd/icons/briefcase.png", "smooth"),
	account = Material("msd/icons/account.png", "smooth"),
	account_plus = Material("msd/icons/account-plus.png", "smooth"),
	account_edit = Material("msd/icons/account-edit.png", "smooth"),
	account_multiple = Material("msd/icons/account-multiple.png", "smooth"),
	account_convert = Material("msd/icons/account-convert.png", "smooth"),
	arrow_up = Material("msd/icons/arrow_up.png", "smooth"),
	arrow_down = Material("msd/icons/arrow_down.png", "smooth"),
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
	swap = Material("msd/icons/swap.png", "smooth"),
	search = Material("mqs/map_markers/c4.png", "smooth"),
	tools = Material("mqs/map_markers/t1.png", "smooth"),
	human_female = Material("msd/icons/human-female.png", "smooth"),
	human_male = Material("msd/icons/human-male.png", "smooth"),
	human_female_dance = Material("msd/icons/human-female-dance.png", "smooth"),
	hand_peace_variant = Material("msd/icons/hand-peace-variant.png", "smooth"),
	key = Material("msd/icons/key-variant.png", "smooth"),
	key_arrow_right = Material("msd/icons/key-arrow-right.png", "smooth"),
	key_link = Material("msd/icons/key-link.png", "smooth"),
	key_plus = Material("msd/icons/key-plus.png", "smooth"),
	key_remove = Material("msd/icons/key-remove.png", "smooth"),
	key_star = Material("msd/icons/key-star.png", "smooth"),
	door = Material("msd/icons/door.png", "smooth"),
	car = Material("mqs/map_markers/v1.png", "smooth"),
	cancel = Material("msd/icons/cancel.png", "smooth"),
	reload = Material("msd/icons/reload.png", "smooth"),
	reload_alert = Material("msd/icons/reload-alert.png", "smooth"),
	heart = Material("msd/icons/cards-heart.png", "smooth"),
	heart_outline = Material("msd/icons/cards-heart-outline.png", "smooth"),
	heart_broken = Material("msd/icons/heart-broken.png", "smooth"),
	heart_flash = Material("msd/icons/heart-flash.png", "smooth"),
	skip_to = Material("msd/icons/debug-step-over.png", "smooth"),
	food = Material("msd/icons/food.png", "smooth"),
	food_off = Material("msd/icons/food-off-outline.png", "smooth"),
	food_outline = Material("msd/icons/food-outline.png", "smooth"),
	cash = Material("msd/icons/cash.png", "smooth"),
	magazine = Material("msd/icons/magazine-pistol.png", "smooth"),
	ammo = Material("mqs/icons/ammo.png", "smooth"),
	armor = Material("mqs/map_markers/a1.png", "smooth"),
	armor_outline = Material("mqs/map_markers/a2.png", "smooth"),
	armor_broken = Material("mqs/map_markers/a4.png", "smooth"),
	armor_flash = Material("mqs/map_markers/a5.png", "smooth")
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
	["d_na"] = Color(25, 25, 26),
	["d"] = Color(0, 5, 10, 165),
	["m"] = Color(0, 5, 10, 120),
	["l"] = Color(0, 5, 10, 85),
}

MSD.Text = {
	["a"] = Color(150, 150, 150, 200),
	["n"] = Color(150, 150, 150),
	["d"] = Color(220, 220, 220),
	["s"] = Color(235, 235, 235),
	["m"] = Color(245, 245, 245),
	["l"] = Color(255, 255, 255),
}

local NewFont = surface.CreateFont

for i = 0, 40 do
	NewFont("MSDFont." .. 12 + i, {
		font = "AdihausDIN",
		extended = true,
		size = 12 + i,
		weight = 500
	})
end

for i = 0, 20 do
	NewFont("MSDFontB." .. 16 + i, {
		font = "AdihausDIN",
		extended = true,
		size = 16 + i,
		weight = 800
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

function MSD.DrawBG(panel, w, h)
	if MSD.Config.Blur then
		MSD.Blur(panel, 1, 3, 255, 250 - MSD.Config.BgrColor.r, w, h)
	else
		draw.RoundedBox(MSD.Config.Rounded, 0, 0, w, h, MSD.Config.BgrColor)
	end
end

function MSD.DrawTexturedOutlined(x, y, w, h, mat, color, outlinewidth, ocolor)
	if isstring(mat) then
		mat = Material(mat)
	end

	surface.SetMaterial(mat)
	surface.SetDrawColor(ocolor)
	local steps = ( outlinewidth * 2 ) / 3
	if ( steps < 1 ) then steps = 1 end

	for _x = -outlinewidth, outlinewidth, steps do
		for _y = -outlinewidth, outlinewidth, steps do
			surface.DrawTexturedRect(x + _x, y + _y, w, h)
		end
	end

	surface.SetDrawColor(color)
	surface.DrawTexturedRect(x, y, w, h)
end

local cached_mat = {}

function MSD.DrawTexturedRect(x, y, w, h, mat, color)
	if isstring(mat) then
		local crc = util.CRC(mat)
		if not cached_mat[crc] then
			cached_mat[crc] = Material(mat, "smooth")
		end
		mat = cached_mat[crc]
	end

	surface.SetDrawColor(color)
	surface.SetMaterial(mat)
	surface.DrawTexturedRect(x, y, w, h)
end

function MSD.DrawTexturedRectRotated(rot, x, y, w, h, mat, color)
	if isstring(mat) then
		local crc = util.CRC(mat)
		if not cached_mat[crc] then
			cached_mat[crc] = Material(mat, "smooth")
		end
		mat = cached_mat[crc]
	end

	surface.SetDrawColor(color)
	surface.SetMaterial(mat)
	surface.DrawTexturedRectRotated(x, y, w, h, rot)
end

function MSD.ColorAlpha(cl, al)
	local new_cl = table.Copy(cl)
	new_cl.a = al
	return new_cl
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
		draw.RoundedBox(MSD.Config.Rounded, 0, 0, w, h, MSD.ColorAlpha(color_black, back_alpha))
	end
end

-- subUTF8 functions
local function SubStringGetByteCount(str, index)
	local curByte = string.byte(str, index)
	local byteCount = 1

	if curByte == nil then
		byteCount = 0
	elseif curByte > 0 and curByte <= 127 then
		byteCount = 1
	elseif curByte >= 192 and curByte <= 223 then
		byteCount = 2
	elseif curByte >= 224 and curByte <= 239 then
		byteCount = 3
	elseif curByte >= 240 and curByte <= 247 then
		byteCount = 4
	end

	return byteCount
end

local function SubStringGetTotalIndex(str)
	local curIndex = 0
	local i = 1
	local lastCount = 1
	repeat
		lastCount = SubStringGetByteCount(str, i)
		i = i + lastCount
		curIndex = curIndex + 1
	until (lastCount == 0)

	return curIndex - 1
end

local function SubStringGetTrueIndex(str, index)
	local curIndex = 0
	local i = 1
	local lastCount = 1
	repeat
		lastCount = SubStringGetByteCount(str, i)
		i = i + lastCount
		curIndex = curIndex + 1
	until (curIndex >= index)

	return i - lastCount
end

function string.subUTF8(str, startIndex, endIndex)
	if startIndex < 0 then
		startIndex = SubStringGetTotalIndex(str) + startIndex + 1
	end

	if endIndex ~= nil and endIndex < 0 then
		endIndex = SubStringGetTotalIndex(str) + endIndex + 1
	end

	if endIndex == nil then
		return string.sub(str, SubStringGetTrueIndex(str, startIndex))
	else
		return string.sub(str, SubStringGetTrueIndex(str, startIndex), SubStringGetTrueIndex(str, endIndex + 1) - 1)
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
		local char = string.subUTF8(word, 1, 1)

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

			return '\n' .. string.subUTF8(word, 2)
		end

		total = wordlen

		return '\n' .. word
	end)

	local w_end, h_end =  surface.GetTextSize(text)

	return text, w_end, h_end
end

-- Image Lib
MSD.ImgLib = {}
MSD.ImgLib.Images = {}
MSD.ImgLib.PreCacheStarted = {}
MSD.ImgLib.Avatars = {}
MSD.ImgLib.NoMaterial = Material("msd/icons/file-hidden.png", "smooth noclamp")

function MSD.ImgLib.GetMaterial(url, jpg)
	if url == "" then
		return MSD.ImgLib.NoMaterial
	end

	local crc = util.CRC(url) .. ".png"

	if jpg then
		crc = util.CRC(url) .. ".jpg"
	end

	if MSD.ImgLib.Images[crc] then return MSD.ImgLib.Images[crc] end

	if (file.Exists("msd_imgs/" .. crc, "DATA")) then
		MSD.ImgLib.Images[crc] = Material("data/msd_imgs/" .. crc, "smooth noclamp")

		return MSD.ImgLib.Images[crc]
	else
		return MSD.ImgLib.PreCacheMaterial(url, crc, jpg)
	end
end

function MSD.ImgLib.PreCacheMaterial(url, crc, jpg)
	if not crc then
		crc = util.CRC(url) .. ".png"
	end

	if not file.Exists("msd_imgs", "DATA") then
		file.CreateDir("msd_imgs")
	end

	if not MSD.ImgLib.PreCacheStarted[crc] then
		MSD.ImgLib.PreCacheStarted[crc] = true

		http.Fetch(url, function(body, size, headers, code)
			if not jpg and (body:find("^.PNG")) then
				file.Write("msd_imgs/" .. crc, body)
				MSD.ImgLib.Images[crc] = Material("data/msd_imgs/" .. crc, "smooth noclamp")

				return MSD.ImgLib.Images[crc]
			elseif jpg then
				file.Write("msd_imgs/" .. crc, body)
				MSD.ImgLib.Images[crc] = Material("data/msd_imgs/" .. crc, "smooth noclamp")
			else
				print("Image is not a PNG, url - " .. url)
			end
		end, function()
			print("Failed to get image, url - " .. url)
		end)
	end

	return MSD.ImgLib.NoMaterial
end

function MSD.ImgLib.GetAvatar(crc)
	crc = tostring(crc)
	if not MSD.ImgLib.Avatars[crc] then
		MSD.ImgLib.Avatars[crc] = ""

		http.Fetch("https://macnco.one/steamid/avatar.php?input=" .. crc, function(body, size, headers, code)
			MSD.ImgLib.Avatars[crc] = body
		end, function()
			print("Failed to get link, url - " .. url)
		end)
	end

	return MSD.ImgLib.Avatars[crc] or ""
end