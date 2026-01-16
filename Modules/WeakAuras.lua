local addonName, Private = ...

if select(4, GetBuildInfo()) < 120000 then
	return
end

if SlashCmdList["WA"] == nil then
	SlashCmdList["WA"] = function()
		CooldownViewerSettings:ShowUIPanel(false)
	end
end
