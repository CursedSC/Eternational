local SKILL = {}
fighting = fighting or {}

SKILL.List = {}

-- Регистрация нового умения
function SKILL:Register(data)
    if not data.name or not data.id then return end
    
    SKILL.List[data.id] = {
        name = data.name,
        description = data.description or "",
        cooldown = data.cooldown or 5,
        manaCost = data.manaCost or 0,
        staminaCost = data.staminaCost or 0,
        castTime = data.castTime or 0,
        damageType = data.damageType or fighting.Damage.Types.PHYSICAL,
        baseDamage = data.baseDamage or 10,
        range = data.range or 100,
        angle = data.angle or 45, -- для конуса
        radius = data.radius or 50, -- для сферы
        innerRadius = data.innerRadius or 50, -- для торуса
        outerRadius = data.outerRadius or 150, -- для торуса
        hitboxType = data.hitboxType or fighting.Hitbox.Types.CONE,
        
        -- Кастомные функции
        onCast = data.onCast or function() end,
        onHit = data.onHit or function() end
    }
end

-- Использование умения
function SKILL:Cast(ply, skillId)
    local skill = SKILL.List[skillId]
    if not skill then return false end
    
    -- Проверка кулдауна
    if ply:HasCooldown(skillId) then
        if SERVER then
            ply:ChatPrint("Умение на откате: " .. math.ceil(ply:GetCooldown(skillId)) .. " сек.")
        end
        return false
    end
    
    -- Проверка ресурсов
    if not fighting.Resources:HasMana(ply, skill.manaCost) then
        if SERVER then ply:ChatPrint("Недостаточно маны!") end
        return false
    end
    
    if not fighting.Resources:HasStamina(ply, skill.staminaCost) then
        if SERVER then ply:ChatPrint("Недостаточно выносливости!") end
        return false
    end
    
    if SERVER then
        -- Потребление ресурсов
        fighting.Resources:ConsumeMana(ply, skill.manaCost)
        fighting.Resources:ConsumeStamina(ply, skill.staminaCost)
        
        -- Старт кулдауна
        ply:AddCooldown(skillId, skill.cooldown)
        
        -- Логика каста (время каста)
        if skill.castTime > 0 then
            ply.InCast = true
            -- Отправляем клиенту инфу о касте (бар каста)
            netstream.Start(ply, "fighting.StartCast", {skill = skillId, time = skill.castTime})
            
            -- Таймер завершения каста
            timer.Simple(skill.castTime, function()
                if IsValid(ply) and ply:Alive() then
                    ply.InCast = false
                    self:ExecuteSkill(ply, skill)
                end
            end)
        else
            self:ExecuteSkill(ply, skill)
        end
    end
    
    return true
end

function SKILL:ExecuteSkill(ply, skill)
    local hitEntities = {}
    
    -- Определение целей по хитбоксу
    if skill.hitboxType == fighting.Hitbox.Types.CONE then
        hitEntities = fighting.Hitbox:Cone(ply, skill.range, skill.angle)
    elseif skill.hitboxType == fighting.Hitbox.Types.SPHERE then
        -- Для сферы часто берется позиция курсора или выстрела, здесь упрощенно вокруг игрока или forward
        local pos = ply:GetPos() + ply:GetForward() * 50
        hitEntities = fighting.Hitbox:Sphere(pos, skill.radius, ply)
    elseif skill.hitboxType == fighting.Hitbox.Types.TORUS then
        hitEntities = fighting.Hitbox:Torus(ply, skill.innerRadius, skill.outerRadius)
    end
    
    -- Применение эффектов
    skill.onCast(ply, skill) -- Спецэффекты кастера
    
    for _, hit in ipairs(hitEntities) do
        if IsValid(hit.entity) then
            -- Нанесение урона
            fighting.Damage:Apply(ply, hit.entity, skill.damageType, skill.baseDamage, hit.position)
            -- Эффекты при попадании
            skill.onHit(ply, hit.entity, skill)
        end
    end
end

-- ==========================================
-- Примеры регистрации умений (для тестов)
-- ==========================================

-- 1. Мечевой удар (Melee, Cone, Stamina)
SKILL:Register({
    id = "sword_slash",
    name = "Рассекающий удар",
    description = "Базовая атака мечом",
    cooldown = 1.5,
    staminaCost = 15,
    damageType = fighting.Damage.Types.PHYSICAL,
    baseDamage = 25,
    range = 120,
    angle = 90,
    hitboxType = fighting.Hitbox.Types.CONE,
    onCast = function(ply, skill)
        ply:EmitSound("Weapon_Knife.Slash")
        ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE, true)
    end
})

-- 2. Огненный шар (Magic, Sphere, Mana)
SKILL:Register({
    id = "fireball",
    name = "Огненный шар",
    description = "Магический взрыв",
    cooldown = 4,
    manaCost = 30,
    castTime = 0.5,
    damageType = fighting.Damage.Types.MAGICAL,
    baseDamage = 45,
    radius = 100,
    hitboxType = fighting.Hitbox.Types.SPHERE,
    onCast = function(ply, skill)
        ply:EmitSound("Weapon_RPG.Single")
    end,
    onHit = function(ply, target, skill)
        -- Можно добавить поджог
        if target.Ignite then target:Ignite(2) end
    end
})

fighting.Skill = SKILL