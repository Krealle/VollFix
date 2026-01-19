local classes = {}
local numSpecs = 0
local fakeEveryoneSpec = { { specIcon = 922035 } }
local cache = { items = {} }
local pool

local configPadding = 1
local showAllClasses = false

local ANCHOR_FLIP = {
    TOPRIGHT = "TOPLEFT",
    BOTTOMRIGHT = "BOTTOMLEFT",
}

local PADDING_FLIP = {
    TOPRIGHT = 1,
    BOTTOMRIGHT = 1,
    TOPLEFT = 1,
    BOTTOMLEFT = -1,
}

local anchor = "TOPRIGHT" -- "BOTTOMRIGHT"
local anchorFlip = ANCHOR_FLIP[anchor]
local paddingFlip = PADDING_FLIP[anchor]

for i = 1, GetNumClasses() do
    local classInfo = C_CreatureInfo.GetClassInfo(i)
    if classInfo then
        classes[classInfo.classID] = classInfo

        C_SpecializationInfo.GetNumSpecializationsForClassID(classInfo.classID)

        classInfo.specs = {}
        for j = 1, C_SpecializationInfo.GetNumSpecializationsForClassID(classInfo.classID) do
            local id, name, _, icon, role = GetSpecializationInfoForClassID(classInfo.classID, j)
            local spec = { id = id, name = name, icon = icon, role = role }
            classInfo.specs[id] = spec
            numSpecs = numSpecs + 1
        end
    end
end



local function SortByClassAndSpec(a, b)
    local x = a.className
    local y = b.className
    if x == y then
        return a.specName < b.specName
    end
    return x < y
end

local function GetSpecsForItem(item)
    local itemCache = cache.items[item.itemID]
    if not itemCache then
        return
    end
    if itemCache.everyone then
        return true
    end

    local _, _, playerClassID = UnitClass("player")
    local specs = {}
    local i = 0
    for specID, classID in pairs(itemCache.specs) do
        if showAllClasses or playerClassID == classID then
            local classInfo = classes[classID]
            local specInfo = classInfo.specs[specID]
            i = i + 1
            specs[i] = {
                classID = classID,
                className = classInfo.className,
                specID = specID,
                specName = specInfo.name,
                specIcon = specInfo.icon,
                specRole = specInfo.role,
            }
        end
    end
    if specs[2] then
        table.sort(specs, SortByClassAndSpec)
    end
    return specs
end

local function UpdateItem(item)
    local specs = GetSpecsForItem(item)
    if not specs then
        return
    end
    if specs == true then
        specs = fakeEveryoneSpec
    end

    local padding = paddingFlip * configPadding
    local xPrevOffset = (1 * paddingFlip) - (padding * paddingFlip)
    local yOffset = -6 * paddingFlip * PADDING_FLIP[anchorFlip]
    local prevTexture

    ---@cast specs -boolean
    for _, info in ipairs(specs) do
        local texture = pool:Acquire()
        if prevTexture then
            texture:SetPoint(anchor, prevTexture, anchorFlip, xPrevOffset, 0)
        else
            texture:SetPoint(anchor, item, anchor, 0, yOffset)
        end
        texture:SetSize(16, 16)
        -- texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        texture:SetTexture(info.specIcon)
        texture:Show()
        prevTexture = texture
    end
end

local function UpdateItems()
    local difficulty = EJ_GetDifficulty()
    if cache.difficulty and cache.difficulty == difficulty and cache.instanceID == EncounterJournal.instanceID and cache.encounterID == EncounterJournal.encounterID then
        return
    end
    cache.difficulty = difficulty
    cache.instanceID = EncounterJournal.instanceID
    cache.encounterID = EncounterJournal.encounterID
    cache.classID, cache.specID = EJ_GetLootFilter()
    EJ_SelectInstance(cache.instanceID)
    wipe(cache.items)
    for classID, class in pairs(classes) do
        for specID, spec in pairs(class.specs) do
            EJ_SetLootFilter(classID, specID)
            for i = 1, EJ_GetNumLoot() do
                local itemInfo = C_EncounterJournal.GetLootInfoByIndex(i)
                if itemInfo and itemInfo.itemID then
                    local itemCache = cache.items[itemInfo.itemID]
                    if not itemCache then
                        itemCache = itemInfo
                        cache.items[itemInfo.itemID] = itemCache
                    end
                    if not itemCache.specs then
                        itemCache.specs = {}
                    end
                    itemCache.specs[specID] = classID
                end
            end
        end
    end
    if cache.encounterID then
        EJ_SelectEncounter(cache.encounterID)
    end
    EJ_SetLootFilter(cache.classID, cache.specID)
    for itemID, itemCache in pairs(cache.items) do
        local count = 0
        for _, _ in pairs(itemCache.specs) do
            count = count + 1
        end
        itemCache.everyone = count == numSpecs
    end
end

local function UpdateLoot()
    pool:ReleaseAll()

    local scrollBox = EncounterJournal.encounter.info.LootContainer.ScrollBox
    local buttons = scrollBox:GetFrames()
    local hasUpdated

    for _, button in ipairs(buttons) do
        if button:IsShown() and button:IsVisible() then
            if not hasUpdated then
                hasUpdated = true
                UpdateItems()
            end
            UpdateItem(button)
        end
    end
end

EventUtil.ContinueOnAddOnLoaded("Blizzard_EncounterJournal", function()
    pool = CreateTexturePool(EncounterJournal.encounter.info.LootContainer.ScrollBox, "OVERLAY", 7)
    EncounterJournal.VollLootFrameSpecIconsLoaded = pool
    EncounterJournal.encounter.info.LootContainer.ScrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnUpdate,
        UpdateLoot)
    hooksecurefunc("EncounterJournal_LootUpdate", UpdateLoot)
end)
