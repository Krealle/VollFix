local addonName, Private = ...

table.insert(Private.LoginFnQueue, function()
	if not Private.IsXeph then
		return
	end

	local function ExtractMarkerFromMacro()
		for i = 1, GetNumMacros() do
			local name, icon, body = GetMacroInfo(i)

			if name == "focus" then
				for line in body:gmatch("[^\n]+") do
					if string.find(line, "/tm") ~= nil then
						return tonumber(line:match("^/tm%s+(%d+)$"))
					end
				end
			end
		end

		error("Could not find /tm in macro")
	end

	local frame = CreateFrame("Frame")
	frame:RegisterEvent("READY_CHECK")
	frame:SetScript("OnEvent", function(self, event, ...)
		if event == "READY_CHECK" then
			C_ChatInfo.SendChatMessage(string.format("My Focus Marker is {rt%d}", ExtractMarkerFromMacro()), "PARTY")
		end
	end)
end)
