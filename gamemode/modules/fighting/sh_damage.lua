local DAMAGE = {}
fighting = fighting or {}

DAMAGE.Types = {
    PHYSICAL = 1,
    MAGICAL = 2,
    PURE = 3,
    DEBUFF = 4
}

-- Расчет урона
function DAMAGE:Calculate(dmgType, attacker, target, baseDamage)
    local finalDamage = baseDamage
    
    if dmgType == self.Types.PHYSICAL then
        local attackStat = attacker:GetAttribute("strength") or 10
        local defenseStat = target:GetAttribute("defense") or 10
        
        -- Пример формулы: Атака усиливает урон, Защита снижает процентно
        finalDamage = baseDamage + (attackStat * 2)
        local reduction = (defenseStat / (defenseStat + 100)) * 0.7 -- Макс 70% резиста
        finalDamage = finalDamage * (1 - reduction)
        
    elseif dmgType == self.Types.MAGICAL then
        local attackStat = attacker:GetAttribute("intelligence") or 10
        local defenseStat = target:GetAttribute("magic_resist") or 10
        
        finalDamage = baseDamage + (attackStat * 2.5)
        local reduction = (defenseStat / (defenseStat + 100)) * 0.6 -- Макс 60% резиста
        finalDamage = finalDamage * (1 - reduction)
        
    elseif dmgType == self.Types.PURE then
        -- Чистый урон игнорирует защиту и статы (или скейлится только от базы)
        finalDamage = baseDamage
        
    elseif dmgType == self.Types.DEBUFF then
        -- Дебафф урон фиксированный (например, яд)
        finalDamage = baseDamage
    end
    
    return math.Round(finalDamage)
end

-- Нанесение урона
function DAMAGE:Apply(attacker, target, dmgType, baseDamage, position)
    if not IsValid(attacker) or not IsValid(target) then return end
    
    local damage = self:Calculate(dmgType, attacker, target, baseDamage)
    local d = DamageInfo()
    
    d:SetDamage(damage)
    d:SetAttacker(attacker)
    d:SetInflictor(attacker:GetActiveWeapon() or attacker)
    d:SetDamagePosition(position or target:GetPos() + Vector(0,0,50))
    d:SetDamageCustom(dmgType) -- Используем Custom поле для передачи типа урона
    
    -- Визуальные типы для движка Source
    if dmgType == self.Types.PHYSICAL then
        d:SetDamageType(DMG_SLASH)
    elseif dmgType == self.Types.MAGICAL then
        d:SetDamageType(DMG_ENERGYBEAM)
    elseif dmgType == self.Types.PURE then
        d:SetDamageType(DMG_DIRECT)
    elseif dmgType == self.Types.DEBUFF then
        d:SetDamageType(DMG_POISON)
    end
    
    target:TakeDamageInfo(d)
    
    if SERVER then
        -- Визуализация цифр урона (нужна клиентская часть)
        netstream.Start(nil, "fighting.ShowDamage", {
            target = target,
            damage = damage,
            type = dmgType,
            position = target:GetPos() + Vector(0,0,50)
        })
    end
    
    return damage
end

fighting.Damage = DAMAGE