if select(4, GetBuildInfo()) >= 120000 then
	return
end

-- Challenge Mode In Progress Whisper
---@param seconds number
---@return string
local function FormatTime(seconds)
	local minutes = floor(mod(seconds, 3600) / 60)
	local sec = floor(mod(seconds, 60))

	return format("%02d:%02d", minutes, sec)
end

---@type number|nil
local startTime = nil

---@type string|nil
local formattedMaxTime = nil

---@type number|nil
local keyLevel = nil

---@type string|nil
local encounterName = nil

---@type table<string, number>
local whispers = {}

---@type string|nil
local difficulty = nil

local function ResetEncounterMeta()
	startTime = nil
	formattedMaxTime = nil
	encounterName = nil
	keyLevel = nil
	whispers = {}
	difficulty = nil
end

-- verification step to ignore abandoned keys by zoning out
local function IsActuallyInEncounter()
	if keyLevel ~= nil then
		return C_ChallengeMode.IsChallengeModeActive()
	end

	return encounterName ~= nil
end

--- @return string
local function CreateResponse()
	local timeSpent = FormatTime(GetTime() - startTime)

	if keyLevel ~= nil then
		return string.format("Busy doing %s + %d - [%s/%s]", encounterName, keyLevel, timeSpent, formattedMaxTime)
	end

	return string.format("In combat with %s [%s, %s]", encounterName, difficulty, timeSpent)
end

--- @param source string
--- @return boolean
local function MayRespond(source)
	return whispers[source] == nil or GetTime() - whispers[source] > 60
end

local function listener(event, ownerId, ...)
	if event == "ENCOUNTER_END" then
		-- ignore dungeon bosses
		if C_ChallengeMode.IsChallengeModeActive() then
			return
		end

		ResetEncounterMeta()
	elseif event == "ENCOUNTER_START" then
		-- ignore dungeon bosses
		if C_ChallengeMode.IsChallengeModeActive() then
			return
		end

		startTime = GetTime()

		local ownerId, _, name, difficultyId = ...

		local difficultyName = GetDifficultyInfo(difficultyId)
		difficulty = difficultyName
		encounterName = name
	elseif event == "CHAT_MSG_WHISPER" then
		if not startTime then
			return
		end

		local source = select(2, ...)

		if not source or not MayRespond(source) or not IsActuallyInEncounter() then
			return
		end

		whispers[source] = GetTime()

		C_ChatInfo.SendChatMessage(CreateResponse(), "WHISPER", nil, source)
	elseif event == "CHAT_MSG_BN_WHISPER" then
		if not startTime then
			return
		end

		local source = select(13, ...)

		if not source or not MayRespond(source) or not IsActuallyInEncounter() then
			return
		end

		whispers[source] = GetTime()

		BNSendWhisper(source, CreateResponse())
	elseif event == "CHALLENGE_MODE_START" then
		table.wipe(whispers)
		difficulty = nil

		local mapId = C_ChallengeMode.GetActiveChallengeMapID()

		if not mapId then
			return
		end

		startTime = GetTime()
		local name, _, timer = C_ChallengeMode.GetMapUIInfo(mapId)

		encounterName = name
		formattedMaxTime = FormatTime(timer)
		keyLevel = C_ChallengeMode.GetActiveKeystoneInfo()
	elseif event == "CHALLENGE_MODE_COMPLETED" then
		ResetEncounterMeta()
	end
end

EventRegistry:RegisterFrameEventAndCallback("ENCOUNTER_START", listener)
EventRegistry:RegisterFrameEventAndCallback("CHAT_MSG_BN_WHISPER", listener)
EventRegistry:RegisterFrameEventAndCallback("ENCOUNTER_END", listener)
EventRegistry:RegisterFrameEventAndCallback("CHAT_MSG_WHISPER", listener)
EventRegistry:RegisterFrameEventAndCallback("CHALLENGE_MODE_COMPLETED", listener)
EventRegistry:RegisterFrameEventAndCallback("CHALLENGE_MODE_START", listener)
