local Private = select(2, ...)

-- https://www.raidbots.com/static/data/xptr/bonuses.json
-- copy(JSON.stringify(Object.values(JSON.parse($0.textContent)).filter(x => x.upgrade?.seasonId === 30).reduce((acc, data) => {
--     acc[data.id] = data.upgrade.name
--     return acc
-- }, {})))

local bonusToTierMap = Private.IsMidnight and {
	[13332] = "Raid Finder",
	[13334] = "Heroic",
	[13335] = "Mythic",
} or {
	[12265] = "Explorer",
	[12266] = "Explorer",
	[12267] = "Explorer",
	[12268] = "Explorer",
	[12269] = "Explorer",
	[12270] = "Explorer",
	[12271] = "Explorer",
	[12272] = "Explorer",
	[12274] = "Adventurer",
	[12275] = "Adventurer",
	[12276] = "Adventurer",
	[12277] = "Adventurer",
	[12278] = "Adventurer",
	[12279] = "Adventurer",
	[12280] = "Adventurer",
	[12281] = "Adventurer",
	[12282] = "Veteran",
	[12283] = "Veteran",
	[12284] = "Veteran",
	[12285] = "Veteran",
	[12286] = "Veteran",
	[12287] = "Veteran",
	[12288] = "Veteran",
	[12289] = "Veteran",
	[12290] = "Champion",
	[12291] = "Champion",
	[12292] = "Champion",
	[12293] = "Champion",
	[12294] = "Champion",
	[12295] = "Champion",
	[12296] = "Champion",
	[12297] = "Champion",
	[12350] = "Hero",
	[12351] = "Hero",
	[12352] = "Hero",
	[12353] = "Hero",
	[12354] = "Hero",
	[12355] = "Hero",
	[12356] = "Myth",
	[12357] = "Myth",
	[12358] = "Myth",
	[12359] = "Myth",
	[12360] = "Myth",
	[12361] = "Myth",
}

-- copy(JSON.stringify(Object.values(JSON.parse($0.textContent)).filter(x => x.upgrade?.seasonId === 30).reduce((acc, data) => {
--     const [tier] = data.upgrade.fullName.split(' ')
--     if (acc[tier]) {
--         if (data.upgrade.itemLevel > acc[tier].max) {
--             acc[tier].max = data.upgrade.itemLevel
--         } else if (data.upgrade.itemLevel < acc[tier].min) {
--             acc[tier].min = data.upgrade.itemLevel
--         }
--     } else {
--         acc[tier] = {
--             min: data.upgrade.itemLevel,
--             max: data.upgrade.itemLevel,
--         }
--     }

--     return acc
-- }, {})).replaceAll(':', '=').replaceAll('"', ''))

local tiers = Private.IsMidnight
		and {
			Adventurer = { min = 220, max = 237 },
			Veteran = { min = 233, max = 250 },
			Champion = { min = 246, max = 263 },
			Hero = { min = 259, max = 276 },
			Myth = { min = 272, max = 289 },
		}
	or {
		Explorer = { min = 642, max = 665 },
		Adventurer = { min = 655, max = 678 },
		Veteran = { min = 668, max = 691 },
		Champion = { min = 681, max = 704 },
		Hero = { min = 694, max = 710 },
		Myth = { min = 707, max = 730 },
	}

local craftedBonusIds = Private.IsMidnight
		and {
			[12066] = true, -- Radiance Crafted
			-- https://wago.tools/db2/ItemBonus?filter%5BValue_2%5D=2061%7C2062%7C2063&page=1
			-- presumably 15587?
		}
	or {
		[9498] = true, -- Dream Crafted
		[10249] = true, -- Awakened Crafted
		[10222] = true, -- Omen Crafted
		[12040] = true, -- Fortune Crafted
		[12050] = true, -- Starlight Crafted
	}

local crestFreeItemLevelUpgradeThreshold = Private.IsMidnight and 999 or 580

local function GetUpgradeTrack(bonusIds)
	for i = 1, #bonusIds do
		local id = tonumber(bonusIds[i])

		if craftedBonusIds[id] ~= nil then
			return
		end

		local key = bonusToTierMap[id]

		if key then
			return tiers[key]
		end
	end
end

local function GetBonusIds(link)
	local itemString = string.match(link, "item:([%-?%d:]+)")
	if not itemString then
		return {}
	end

	local bonuses = {}
	local itemSplit = {}

	for v in string.gmatch(itemString, "(%d*:?)") do
		if v == ":" then
			itemSplit[#itemSplit + 1] = 0
		else
			itemSplit[#itemSplit + 1] = string.gsub(v, ":", "")
		end
	end

	for index = 1, tonumber(itemSplit[13]) do
		bonuses[#bonuses + 1] = itemSplit[13 + index]
	end

	return bonuses
end

EventRegistry:RegisterFrameEventAndCallback("PLAYER_EQUIPMENT_CHANGED", function()
	local itemSlots = {
		INVSLOT_HEAD,
		INVSLOT_NECK,
		INVSLOT_SHOULDER,
		INVSLOT_CHEST,
		INVSLOT_WAIST,
		INVSLOT_LEGS,
		INVSLOT_FEET,
		INVSLOT_WRIST,
		INVSLOT_HAND,
		INVSLOT_FINGER1,
		INVSLOT_FINGER2,
		INVSLOT_TRINKET1,
		INVSLOT_TRINKET2,
		INVSLOT_BACK,
		INVSLOT_MAINHAND,
		INVSLOT_OFFHAND,
	}

	for i = 1, #itemSlots do
		local slot = itemSlots[i]
		local itemLoc = ItemLocation:CreateFromEquipmentSlot(slot)

		if itemLoc:IsValid() then
			local currentItemLevel = C_Item.GetCurrentItemLevel(itemLoc)

			if currentItemLevel >= (Private.IsMidnight and tiers.Adventurer.min or tiers.Explorer.min) then
				local itemLink = C_Item.GetItemLink(itemLoc)

				if itemLink then
					local bonusIds = GetBonusIds(itemLink)
					local upgradeTrack = GetUpgradeTrack(bonusIds)

					if upgradeTrack and currentItemLevel < upgradeTrack.max then
						local redundancySlot = slot == INVSLOT_OFFHAND and Enum.ItemRedundancySlot.Offhand
							or C_ItemUpgrade.GetHighWatermarkSlotForItem(C_Item.GetItemID(itemLoc))

						local characterWatermark, accountWatermark =
							C_ItemUpgrade.GetHighWatermarkForSlot(redundancySlot)

						local watermark = characterWatermark < accountWatermark and characterWatermark
							or accountWatermark

						local finalIlvlToCompareWith = upgradeTrack.max < watermark and upgradeTrack.max or watermark

						if currentItemLevel < finalIlvlToCompareWith then
							local msg = format(
								"%s can be upgraded to item level %d without using crests!",
								itemLink,
								finalIlvlToCompareWith
							)

							print(msg)
						elseif currentItemLevel < crestFreeItemLevelUpgradeThreshold then
							local msg = format(
								"%s can be upgraded to item level %d without crests!",
								itemLink,
								crestFreeItemLevelUpgradeThreshold
							)

							print(msg)
						end
					end
				end
			end
		end
	end
end)
