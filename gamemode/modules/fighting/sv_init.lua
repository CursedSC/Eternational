util.AddNetworkString("fighting.StartCast")
util.AddNetworkString("fighting.ShowDamage")

-- Конфиг перекатов (роллов)
local ROLL = {
    Duration   = 0.35,  -- длительность переката
    Speed      = 520,   -- скорость рывка
    Cooldown   = 1.0,   -- кд между перекатами
    IFrameFrac = 0.7,   -- какую часть анимации держать инфреймы
    StaminaCost = 20,   -- стоимость по выносливости
}

-- Хук для биндов умений (1-4)
hook.Add("PlayerButtonDown", "fighting.Input.Skills", function(ply, btn)
    if ply.InCast then return end
    
    -- Пример маппинга клавиш на слоты скиллов
    local keyMap = {
        [KEY_1] = 1,
        [KEY_2] = 2,
        [KEY_3] = 3,
        [KEY_4] = 4
    }
    
    local slot = keyMap[btn]
    if slot then
        -- Получаем ID скилла из оружия или класса игрока
        local wep = ply:GetActiveWeapon()
        if IsValid(wep) and wep.Skills and wep.Skills[slot] then
            fighting.Skill:Cast(ply, wep.Skills[slot])
        else
            -- Тестовые скиллы по умолчанию для отладки
            if slot == 1 then fighting.Skill:Cast(ply, "sword_slash") end
            if slot == 2 then fighting.Skill:Cast(ply, "fireball") end
        end
    end
end)

-- Перекат на клавишу X
hook.Add("PlayerButtonDown", "fighting.Input.Roll", function(ply, btn)
    if btn ~= KEY_X then return end
    if not ply:Alive() then return end
    if ply.InCast or ply.InAction then return end
    if ply.InDodge then return end

    -- Кулдаун
    if ply.DodgeCD and ply.DodgeCD > CurTime() then return end

    -- Проверка выносливости, если система есть
    if fighting.Resources and fighting.Resources.HasStamina then
        if not fighting.Resources:HasStamina(ply, ROLL.StaminaCost) then
            return
        end
    end

    local ang = ply:EyeAngles()
    ang.p = 0

    local dir = Vector(0, 0, 0)
    if ply:KeyDown(IN_FORWARD) then dir = dir + ang:Forward() end
    if ply:KeyDown(IN_BACK) then dir = dir - ang:Forward() end
    if ply:KeyDown(IN_MOVERIGHT) then dir = dir + ang:Right() end
    if ply:KeyDown(IN_MOVELEFT) then dir = dir - ang:Right() end

    dir.z = 0
    if dir:LengthSqr() == 0 then
        dir = ang:Forward()
        dir.z = 0
    end

    dir:Normalize()

    ply.DodgeDir       = dir
    ply.DodgeEndTime   = CurTime() + ROLL.Duration
    ply.DodgeIFrameEnd = CurTime() + ROLL.Duration * ROLL.IFrameFrac
    ply.InDodge        = true
    ply.DodgeCD        = CurTime() + ROLL.Cooldown

    -- Списываем стамину уже по факту старта переката
    if fighting.Resources and fighting.Resources.ConsumeStamina then
        fighting.Resources:ConsumeStamina(ply, ROLL.StaminaCost)
    end

    -- Визуал: пыль и звук
    local pos = ply:GetPos() + Vector(0, 0, 2)
    ParticleEffect("fantasy_roll_dust", pos, Angle(0, 0, 0), ply)
    ply:EmitSound("player/footsteps/grass1.wav", 70, 95, 0.6, CHAN_BODY)
end)

-- Хук для базовой атаки (ЛКМ) и выносливости
hook.Add("StartCommand", "fighting.Input.Attack", function(ply, cmd)
    if cmd:KeyDown(IN_ATTACK) then
        -- Проверка выносливости для атаки
        local cost = 10 -- Базовая стоимость удара
        if not fighting.Resources:HasStamina(ply, cost) then
            cmd:RemoveKey(IN_ATTACK) -- Блокируем атаку
            -- Можно отправить уведомление раз в секунду
        else
            -- Если атака прошла успешно (это нужно чекать в оружии, но здесь предварительная проверка)
            -- fighting.Resources:ConsumeStamina(ply, cost) -- Расход лучше делать в самом SWEP'е при ударе
        end
    end
end)

-- Сохраняем старую функцию для совместимости, но перенаправляем на новую систему урона
function doAttackDamage(ply, target, weapon, damage, NoEffect)
    if not IsValid(target) or (not target:IsNPC() and not target:IsPlayer() and not target:IsNextBot()) then return end
    
    -- Используем физический урон по умолчанию для старых вызовов
    fighting.Damage:Apply(ply, target, fighting.Damage.Types.PHYSICAL, damage)
end

-- Хук модификации урона (EntityTakeDamage)
hook.Add("EntityTakeDamage", "fighting.Damage.Modifier", function(target, dmginfo)
    local attacker = dmginfo:GetAttacker()

    -- Инфреймы во время переката
    if IsValid(target) and target:IsPlayer() and target.InDodge and target.DodgeIFrameEnd and CurTime() <= target.DodgeIFrameEnd then
        dmginfo:SetDamage(0)
        return true
    end
    
    if IsValid(attacker) and attacker:IsPlayer() then
        -- Здесь можно добавить глобальные модификаторы, если они не учтены в sh_damage
        -- Например, баффы на урон
        local buff = attacker:GetPerStatus and attacker:GetPerStatus("damage_buff")
        if buff and buff > 0 then
            dmginfo:ScaleDamage(1 + (buff / 100))
        end
    end
    
    if IsValid(target) and target:IsPlayer() then
        -- Баффы на защиту
        local defense = target:GetPerStatus and target:GetPerStatus("defense_buff")
        if defense and defense > 0 then
            dmginfo:ScaleDamage(1 - (defense / 100))
        end
    end
end)

-- Логика движения во время атак и перекатов
hook.Add("SetupMove", "fighting.Movement", function(ply, mv, cmd)
    if ply.InCast then
        -- Замедление или остановка во время каста
        mv:SetMaxSpeed(ply:GetWalkSpeed() * 0.5)
        mv:SetMaxClientSpeed(ply:GetWalkSpeed() * 0.5)
    end
    
    if ply.InAction then
        mv:SetForwardSpeed(0)
        mv:SetSideSpeed(0)
        mv:SetUpSpeed(0)
    end

    if ply.InDodge and ply.DodgeEndTime then
        if CurTime() >= ply.DodgeEndTime then
            ply.InDodge     = false
            ply.DodgeDir    = nil
            ply.DodgeEndTime = nil
            ply.DodgeIFrameEnd = nil
            return
        end

        local dir = ply.DodgeDir or ply:GetForward()
        dir.z = 0
        if dir:LengthSqr() == 0 then
            dir = ply:GetForward()
            dir.z = 0
        end
        dir:Normalize()

        local vel = dir * ROLL.Speed
        vel.z = mv:GetVelocity().z

        mv:SetVelocity(vel)
        mv:SetForwardSpeed(0)
        mv:SetSideSpeed(0)

        -- во время переката нельзя прыгать/бить
        local buttons = mv:GetButtons()
        buttons = bit.band(buttons, bit.bnot(IN_JUMP))
        buttons = bit.band(buttons, bit.bnot(IN_ATTACK))
        mv:SetButtons(buttons)
    end
end)

hook.Add("PlayerDeath", "fighting.ResetState", function(ply)
    ply.InAction = false
    ply.InCast = false
    ply.SetMove = false

    ply.InDodge = false
    ply.DodgeDir = nil
    ply.DodgeEndTime = nil
    ply.DodgeIFrameEnd = nil
end)
