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
            elseif num <= 25 then
                greeting = "Selamat Pagi"
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
        C_Timer.After(3, DoGreeting)
    end
end)
