-- only Evokers, see classID here: https://wago.tools/db2/ChrSpecialization
if select(3, UnitClass("player")) ~= 13 then
	return
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("CVAR_UPDATE")
frame:SetScript("OnEvent", function(self, event, name, value)
	if event == "CVAR_UPDATE" and name == "TurnSpeed" and value < 180 then
		C_CVar.SetCVar("TurnSpeed", 180)
	end
end)
