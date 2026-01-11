local baseregen = 1
local Player = FindMetaTable("Player") 
function Player:SetMana(int)
    self:SetNWInt("mana", int) 
end
function Player:GetMana()
    return self:GetNWInt("mana", 0)
end
function Player:GetMaxMana()
    return 100 + (self:GetAttribute("intelligence") * 5)
end 
function Player:RemoveMana(int)
    self:SetMana(self:GetMana() - int)
    if self:GetMana() < 0 then
        self:SetMana(0)
    end
end
local function manaControll(ply)
    local playerMana = ply:GetMana()
    local int = ply:GetAttribute("intelligence")
    local maxSize = ply:GetMaxMana()
    local regen = baseregen + (int * 1)
    ply:SetMana(math.min(playerMana + regen, maxSize))
end 

timer.Create("dbt/mana/tick", 2, 0, function() 
    for _, ply in ipairs(player.GetHumans()) do
        if not IsValid(ply) then
            continue
        end
        manaControll(ply)
    end
end) 