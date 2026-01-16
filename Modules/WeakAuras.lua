if select(4, GetBuildInfo()) < 120000 then
	return
end

SlashCmdList["WA"] = function()
	CooldownViewerSettings:ShowUIPanel(false)
end
