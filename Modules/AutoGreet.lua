local addonName, Private = ...

EventRegistry:RegisterFrameEventAndCallback("GROUP_JOINED", function()
    if IsInRaid() then
        return false
    end

    local function DoGreeting()
        if not InCombatLockdown() then
            local num = math.random(1, 100)
            local greeting = "morning"
            if num <= 5 then
                greeting = "hello everypony"
            elseif num <= 10 then
                greeting = "meowdy"
            end

            C_ChatInfo.SendChatMessage(greeting, "PARTY")
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
