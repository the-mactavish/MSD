-- ┏━┓┏━┳━━━┳━━━┓───────────────────────
-- ┃┃┗┛┃┃┏━┓┣┓┏┓┃───────────────────────
-- ┃┏┓┏┓┃┗━━┓┃┃┃┃──By MacTavish <3──────
-- ┃┃┃┃┃┣━━┓┃┃┃┃┃───────────────────────
-- ┃┃┃┃┃┃┗━┛┣┛┗┛┃───────────────────────
-- ┗┛┗┛┗┻━━━┻━━━┛───────────────────────
local files = file.Find("msd/language/*", "LUA")

for k, v in ipairs(files) do
	if (SERVER) then
		include("msd/language/" .. v)
		AddCSLuaFile("msd/language/" .. v)
		MsgC(Color(174, 0, 255), "[MSD] " .. v .. " language found\n")
	else
		include("msd/language/" .. v)
	end
end

function MSD.GetPhrase(name, ...)
	local lang = MSD.Language[MSD.Config.Language] or MSD.Language["en"]
	local prase = lang[name]

	if not prase then
		prase = MSD.Language["en"][name]
	end

	if not prase then return name end

	return string.format(prase, ...)
end