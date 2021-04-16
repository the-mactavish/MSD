-- ╔═╗╔═╦═══╦═══╗───────────────────────
-- ║║╚╝║║╔═╗║╔═╗║───────────────────────
-- ║╔╗╔╗║║─║║╚══╗───────────────────────
-- ║║║║║║║─║╠══╗║──By MacTavish <3──────
-- ║║║║║║╚═╝║╚═╝║───────────────────────
-- ╚╝╚╝╚╩══╗╠═══╝───────────────────────
-- ────────╚╝───────────────────────────

local files, folders = file.Find("msd/language/*", "LUA")

for k,v in pairs(files) do
	if (SERVER) then
		include("msd/language/" .. v)
		AddCSLuaFile("msd/language/" .. v)
		MsgC( Color(0, 0, 255), "[MQS] "..v.." language found\n" )
	else
		include("msd/language/" .. v)
	end
end

function MSD.GetPhrase(name, ...)
	
	local lang = MQS.Language[MQS.Config.Language] or MQS.Language["en"]
	
	local prase = lang[name]
	
	if !prase then prase = MQS.Language["en"][name] end
	
	if !prase then return name end
	
    return string.format(prase, ...)
	
end