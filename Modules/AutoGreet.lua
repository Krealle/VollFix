local addonName, Private = ...

EventRegistry:RegisterFrameEventAndCallback("GROUP_JOINED", function()
	if IsInRaid() then
		return false
	end

	local function DoGreeting()
		if not InCombatLockdown() then
			C_ChatInfo.SendChatMessage("hi", "PARTY")
		end
	end

	if InCombatLockdown() then
		EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", function(ownerId)
			DoGreeting()
			EventRegistry:UnregisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", ownerId)
		end)
	else
		C_Timer.After(2, DoGreeting)
	end
end)
