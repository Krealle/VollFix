local addonName, Private = ...

-- Gear Upgrade Rank Tooltip Renamer
local CRESTS = Private.IsMidnight
		and {
			[1] = { shortName = "Veteran", color = UNCOMMON_GREEN_COLOR, achievement = 0 },
			[2] = { shortName = "Champion", color = RARE_BLUE_COLOR, achievement = 0 },
			[3] = { shortName = "Hero", color = ITEM_EPIC_COLOR, achievement = 0 },
			[4] = { shortName = "Myth", color = ITEM_LEGENDARY_COLOR, achievement = 0 },
		}
	or {
		[0] = { shortName = "Valorstones", color = HEIRLOOM_BLUE_COLOR },
		[1] = { shortName = "Weathered", color = UNCOMMON_GREEN_COLOR, achievement = 41886 },
		[2] = { shortName = "Carved", color = RARE_BLUE_COLOR, achievement = 41887 },
		[3] = { shortName = "Runed", color = ITEM_EPIC_COLOR, achievement = 41888 },
		[4] = { shortName = "Gilded", color = ITEM_LEGENDARY_COLOR, achievement = 41892 },
	}

-- Upgrade tiers with crest change points
-- ([i]=CRESTS[x]) where i = the upgrade level where crest type changes
-- i=4 means to upgrade from rank 4 to the next rank.
local UPGRADE_TIERS = Private.IsMidnight
		and {
			{
				name = "Adventurer",
				minIlvl = 220,
				maxIlvl = 237,
				maxUpgrade = 6,
				color = WHITE_FONT_COLOR,
				crestLevels = { [1] = CRESTS[0], [3] = CRESTS[0], [6] = nil },
			},
			{
				name = "Veteran",
				minIlvl = 233,
				maxIlvl = 250,
				maxUpgrade = 6,
				color = UNCOMMON_GREEN_COLOR,
				crestLevels = { [1] = CRESTS[0], [3] = CRESTS[0], [6] = nil },
			},
			{
				name = "Champion",
				minIlvl = 246,
				maxIlvl = 263,
				maxUpgrade = 6,
				color = RARE_BLUE_COLOR,
				crestLevels = { [1] = CRESTS[0], [3] = CRESTS[0], [6] = nil },
			},
			{
				name = "Hero",
				minIlvl = 259,
				maxIlvl = 276,
				maxUpgrade = 6,
				color = ITEM_EPIC_COLOR,
				crestLevels = { [1] = CRESTS[0], [3] = CRESTS[0], [6] = nil },
			},
			{
				name = "Myth",
				minIlvl = 272,
				maxIlvl = 289,
				maxUpgrade = 6,
				color = ITEM_LEGENDARY_COLOR,
				crestLevels = { [1] = CRESTS[0], [3] = CRESTS[0], [6] = nil },
			},
		}
	or {
		{
			name = "Explorer",
			minIlvl = 642,
			maxIlvl = 665,
			maxUpgrade = 8,
			color = ITEM_POOR_COLOR,
			crestLevels = { [1] = CRESTS[0], [4] = CRESTS[0], [8] = nil },
		},
		{
			name = "Adventurer",
			minIlvl = 655,
			maxIlvl = 678,
			maxUpgrade = 8,
			color = WHITE_FONT_COLOR,
			crestLevels = { [1] = CRESTS[0], [4] = CRESTS[1], [8] = nil },
		},
		{
			name = "Veteran",
			minIlvl = 668,
			maxIlvl = 691,
			maxUpgrade = 8,
			color = UNCOMMON_GREEN_COLOR,
			crestLevels = { [1] = CRESTS[1], [4] = CRESTS[2], [8] = nil },
		},
		{
			name = "Champion",
			minIlvl = 681,
			maxIlvl = 704,
			maxUpgrade = 8,
			color = RARE_BLUE_COLOR,
			crestLevels = { [1] = CRESTS[2], [4] = CRESTS[3], [8] = nil },
		},
		{
			name = "Hero",
			minIlvl = 694,
			maxIlvl = 710,
			maxUpgrade = 6,
			color = ITEM_EPIC_COLOR,
			crestLevels = { [1] = CRESTS[3], [4] = CRESTS[4], [6] = nil },
		},
		{
			name = "Myth",
			minIlvl = 707,
			maxIlvl = 730,
			maxUpgrade = 8,
			color = ITEM_LEGENDARY_COLOR,
			crestLevels = { [1] = CRESTS[4], [8] = nil },
		},
	}

-- Get crest dynamically based on upgrade level
---@param current number
---@param maxUpgrade number
local function GetCrestForLevel(crestLevels, current, maxUpgrade)
	-- If at max upgrade, no crest is required
	if current == maxUpgrade then
		return nil
	end

	local selectedCrest = nil
	for level, crest in pairs(crestLevels) do
		if current >= level then
			selectedCrest = crest -- Update to highest applicable crest
		end
	end

	return selectedCrest
end

-- Get tier data based on item level and upgrade level
---@param ilvl number
---@param current number
---@param total number
local function GetUpgradeTierData(ilvl, current, total)
	for _, tier in ipairs(UPGRADE_TIERS) do
		if ilvl >= tier.minIlvl and ilvl <= tier.maxIlvl and total == tier.maxUpgrade then
			-- Calculate expected ilvl for current upgrade level
			local step = (tier.maxIlvl - tier.minIlvl) / (tier.maxUpgrade - 1)
			local expectedIlvl = tier.minIlvl + (current - 1) * step
			local diff = math.abs(ilvl - expectedIlvl)

			if diff <= step then
				return {
					name = tier.name, -- english name
					minIlvl = tier.minIlvl,
					maxIlvl = tier.maxIlvl,
					color = tier.color,
					crest = GetCrestForLevel(tier.crestLevels, current, tier.maxUpgrade),
				}
			end
		end
	end

	return nil
end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
	local _, itemLink = TooltipUtil.GetDisplayedItem(tooltip)

	if not itemLink then
		return
	end

	--Create ItemMixin from itemLink
	local item = Item:CreateFromItemLink(itemLink)

	if item:IsItemEmpty() then
		return
	end

	local itemLevel = item:GetCurrentItemLevel()

	-- Loop over current tooltip lines
	for i = 1, tooltip:NumLines() do
		local line = _G[tooltip:GetName() .. "TextLeft" .. i]
		local text = line:GetText()

		if text and text:match(ITEM_UPGRADE_TOOLTIP_FORMAT_STRING:gsub("%%s %%d/%%d", "(%%D+ %%d+/%%d+)")) then
			local tier, current, total =
				text:match(ITEM_UPGRADE_TOOLTIP_FORMAT_STRING:gsub("%%s %%d/%%d", "(%%D+) (%%d+)/(%%d+)"))

			local tierData = GetUpgradeTierData(tonumber(itemLevel), tonumber(current), tonumber(total))

			if not tierData then
				return
			end

			-- Modify Upgrade Rank tooltip line
			local minIlvl = tierData.minIlvl
			local maxIlvl = tierData.maxIlvl
			if minIlvl and maxIlvl and itemLevel >= minIlvl and itemLevel <= maxIlvl then
				local tierHexColorMarkup = tierData.color:GenerateHexColorMarkup()
				local rangeHexColorMarkup = CreateColor(157 / 256, 157 / 256, 157 / 256):GenerateHexColorMarkup()

				local newLineText = string.format(
					"%s%d/%d %s|r %s(%d-%d)|r",
					tierHexColorMarkup,
					current,
					total,
					tier,
					rangeHexColorMarkup,
					minIlvl,
					maxIlvl
				)

				line:SetText(newLineText)
				line:Show()
			end

			-- Add Crest required to upgrade
			if tierData.crest then
				local crest = tierData.crest

				if crest then
					local crestName = crest.shortName
					local crestName_colored = crest.color:WrapTextInColorCode(crestName)
					local achievement = crest.achievement and select(13, GetAchievementInfo(crest.achievement))
					local rightLineText = "|A:2329:20:20:1:-1|a" .. (not achievement and crestName_colored or "")
					local rightLine = _G[tooltip:GetName() .. "TextRight" .. i]
					rightLine:SetText(rightLineText)
					rightLine:Show()
				end
			end
		end
	end
end)
