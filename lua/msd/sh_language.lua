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