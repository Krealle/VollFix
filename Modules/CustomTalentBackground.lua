local addonName, Private = ...

EventUtil.ContinueOnAddOnLoaded("Blizzard_PlayerSpells", function()
    -- Evoker Tech
    if select(2, UnitClass("player")) ~= "EVOKER" then return end

    local tempFrame = CreateFrame("Frame", nil, PlayerSpellsFrame)
    local frameParent = tempFrame:GetParent()
    if not frameParent then return end

    frameParent.Bg:Hide()

    frameParent.TalentsFrame.Background:SetAlpha(0.95)
    frameParent.TalentsFrame.BlackBG:Hide()
    frameParent.TalentsFrame.AirParticlesClose:SetAlpha(0)
    frameParent.TalentsFrame.AirParticlesFar:SetAlpha(0)
    frameParent.TalentsFrame.Clouds1:SetAlpha(0)
    frameParent.TalentsFrame.Clouds2:SetAlpha(0)
    frameParent.TalentsFrame.backgroundAnims = nil

    frameParent.backgroundPath = "Interface\\Addons\\VollFix\\Textures\\fatspyrowide.tga"

    local resetTextScript = function(self)
        self.Background:SetTexture(self:GetParent().backgroundPath)
    end

    frameParent.TalentsFrame:HookScript("OnShow", resetTextScript)
end)
