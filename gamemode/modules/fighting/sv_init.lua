util.AddNetworkString("fighting.StartCast")
util.AddNetworkString("fighting.ShowDamage")

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
    
    if IsValid(attacker) and attacker:IsPlayer() then
        -- Здесь можно добавить глобальные модификаторы, если они не учтены в sh_damage
        -- Например, баффы на урон
        local buff = attacker:GetPerStatus("damage_buff")
        if buff and buff > 0 then
            dmginfo:ScaleDamage(1 + (buff / 100))
        end
    end
    
    if IsValid(target) and target:IsPlayer() then
        -- Баффы на защиту
        local defense = target:GetPerStatus("defense_buff")
        if defense and defense > 0 then
            dmginfo:ScaleDamage(1 - (defense / 100))
        end
    end
end)

-- Логика движения во время атак (оставляем из старого кода, если нужно)
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
end)

hook.Add("PlayerDeath", "fighting.ResetState", function(ply)
    ply.InAction = false
    ply.InCast = false
    ply.SetMove = false
end)