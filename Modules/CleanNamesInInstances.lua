local addonName, Private = ...

EventRegistry:RegisterFrameEventAndCallback("LOADING_SCREEN_DISABLED", function()
	if InCombatLockdown() then
		return
	end

	local inInstance = IsInInstance()

	C_CVar.SetCVar("UnitNamePlayerPVPTitle", inInstance and 0 or 1)
	C_CVar.SetCVar("UnitNamePlayerGuild", inInstance and 0 or 1)
	C_CVar.SetCVar("WorldTextMinSize", inInstance and (Private.IsMidnight and 12 or 8) or 0)
	C_CVar.SetCVar("WorldTextMinAlpha", inInstance and 1 or 0.5)
end)
