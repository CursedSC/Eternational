local RESOURCES = {}
fighting = fighting or {}

RESOURCES.MaxMana = 100
RESOURCES.MaxStamina = 100

function RESOURCES:Setup(ply)
    ply:SetNWInt("Mana", RESOURCES.MaxMana)
    ply:SetNWInt("MaxMana", RESOURCES.MaxMana)
    ply:SetNWInt("Stamina", RESOURCES.MaxStamina)
    ply:SetNWInt("MaxStamina", RESOURCES.MaxStamina)
end

function RESOURCES:GetMana(ply)
    return ply:GetNWInt("Mana", 0)
end

function RESOURCES:GetStamina(ply)
    return ply:GetNWInt("Stamina", 0)
end

function RESOURCES:HasMana(ply, amount)
    return self:GetMana(ply) >= amount
end

function RESOURCES:HasStamina(ply, amount)
    return self:GetStamina(ply) >= amount
end

function RESOURCES:ConsumeMana(ply, amount)
    if not self:HasMana(ply, amount) then return false end
    local current = self:GetMana(ply)
    ply:SetNWInt("Mana", math.max(0, current - amount))
    return true
end

function RESOURCES:ConsumeStamina(ply, amount)
    if not self:HasStamina(ply, amount) then return false end
    local current = self:GetStamina(ply)
    ply:SetNWInt("Stamina", math.max(0, current - amount))
    return true
end

if SERVER then
    function RESOURCES:Regenerate(ply)
        local mana = self:GetMana(ply)
        local maxMana = ply:GetNWInt("MaxMana", RESOURCES.MaxMana)
        
        local stamina = self:GetStamina(ply)
        local maxStamina = ply:GetNWInt("MaxStamina", RESOURCES.MaxStamina)
        
        -- Базовая регенерация (можно усилить через атрибуты)
        if mana < maxMana then
            ply:SetNWInt("Mana", math.min(maxMana, mana + 5))
        end
        
        if stamina < maxStamina then
            ply:SetNWInt("Stamina", math.min(maxStamina, stamina + 10))
        end
    end

    hook.Add("PlayerSpawn", "fighting.Resources.Setup", function(ply)
        RESOURCES:Setup(ply)
    end)

    timer.Create("fighting.Resources.Regen", 1, 0, function()
        for _, ply in ipairs(player.GetAll()) do
            if ply:Alive() then
                RESOURCES:Regenerate(ply)
            end
        end
    end)
end

fighting.Resources = RESOURCES