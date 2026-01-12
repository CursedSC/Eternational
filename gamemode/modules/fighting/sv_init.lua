util.AddNetworkString("fighting.StartCast")
util.AddNetworkString("fighting.ShowDamage")

--=============================================================================
-- КОНФИГ ПЕРЕКАТОВ (ROLL)
--=============================================================================
local ROLL = {
    Duration    = 0.35,  -- длительность переката
    Speed       = 520,   -- скорость рывка
    Cooldown    = 1.0,   -- кд между перекатами
    IFrameFrac  = 0.7,   -- какую часть анимации держать инфреймы (0.7 = 70%)
    StaminaCost = 20,    -- стоимость по выносливости
}

--=============================================================================
-- БИНДЫ (СКИЛЛЫ, АТАКА, ПЕРЕКАТ)
--=============================================================================

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

    -- Проверка выносливости
    if fighting.Resources and fighting.Resources.HasStamina then
        if not fighting.Resources:HasStamina(ply, ROLL.StaminaCost) then
            return
        end
    end

    local ang = ply:EyeAngles()
    ang.p = 0

    local dir = Vector(0, 0, 0)
    if ply:KeyDown(IN_FORWARD)   then dir = dir + ang:Forward() end
    if ply:KeyDown(IN_BACK)      then dir = dir - ang:Forward() end
    if ply:KeyDown(IN_MOVERIGHT) then dir = dir + ang:Right()   end
    if ply:KeyDown(IN_MOVELEFT)  then dir = dir - ang:Right()   end

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

    -- Списываем стамину
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
        local cost = 10 
        -- Если есть система ресурсов - проверяем
        if fighting.Resources and fighting.Resources.HasStamina and not fighting.Resources:HasStamina(ply, cost) then
            cmd:RemoveKey(IN_ATTACK)
        end
    end
end)

--=============================================================================
-- СИСТЕМА УРОНА (doAttackDamage + Hooks)
--=============================================================================

-- Гибридная функция: старые параметры -> новая математика
function doAttackDamage(ply, target, weapon, damage, NoEffect)
    if not IsValid(ply) or not IsValid(target) then return end
    if not (target:IsNPC() or target:IsPlayer() or target:IsNextBot()) then return end

    ply:LagCompensation(true)

    -- 1. Сбор базового урона из старой системы (атрибуты, sharp, weapon.MainAtt)
    local base = damage or 0

    -- Основной стат (по дефолту сила)
    local mainAttKey = (IsValid(weapon) and weapon.MainAtt) or "strength"
    local mainAttVal = 1
    if ply.GetAttribute then
        mainAttVal = ply:GetAttribute(mainAttKey) or 1
    end
    base = base + (mainAttVal * 2)

    -- Бонус заточки (sharp)
    local sharpBonus = 0
    if ply.inventory and ply.inventory.GetEquippedItem then
        local item = ply.inventory:GetEquippedItem("weapon")
        if item and item.getMeta then
            sharpBonus = item:getMeta("sharp") or 0
        end
    end
    base = base + sharpBonus

    local hitPos = target:GetPos() + Vector(0, 0, 50)

    -- 2. Нанесение через новую систему (fighting.Damage) с учётом всех резистов
    if fighting.Damage and fighting.Damage.Phys then
        -- Наносим ФИЗИЧЕСКИЙ урон (по умолчанию для обычных атак)
        fighting.Damage:Phys(ply, target, base, hitPos, {
            -- Сюда можно передать крит/множители, если нужно
        })
    else
        -- Fallback: если модуль урона отвалился, бьём по-старому
        local d = DamageInfo()
        d:SetDamage(base)
        d:SetDamageType(DMG_SLASH)
        d:SetAttacker(ply)
        d:SetInflictor(IsValid(weapon) and weapon or ply)
        d:SetDamagePosition(hitPos)
        d:SetDamageCustom(1) -- Можно использовать как флаг типа
        target:TakeDamageInfo(d)
    end

    -- 3. Эффекты
    if not NoEffect then
        ParticleEffect("slashhit_helper_2", hitPos, Angle(0, 0, 0))
        -- ParticleEffect("[*]_swordhit_add", hitPos, Angle(0, 0, 0))
        target:EmitSound("sword/accurate-hit-with-a-steel-sword.mp3", 100)
    end

    ply:LagCompensation(false)
end


-- Хук модификации входящего урона (EntityTakeDamage)
-- Обрабатывает инфреймы, парирование, баффы/дебаффы и старые sharp-бонусы брони
hook.Add("EntityTakeDamage", "fighting.Damage.Modifier", function(target, dmginfo)
    local attacker = dmginfo:GetAttacker()

    -- 1. Инфреймы (перекат)
    if IsValid(target) and target:IsPlayer()
        and target.InDodge and target.DodgeIFrameEnd
        and CurTime() <= target.DodgeIFrameEnd then
        dmginfo:SetDamage(0)
        return true
    end

    -- 2. Парирование (старая логика)
    if IsValid(target) and target:IsPlayer() and target.InPari and IsValid(attacker) then
        local anims = {"b_block_weak_right", "b_block_weak_left"} -- можно вынести в конфиг
        
        if SERVER and netstream then
            netstream.Start(target, "fnt/player/blocked", attacker:GetPos())
            netstream.Start(nil, "fantasy/play/anim", target, table.Random(anims), 0, true)
        end

        -- Возврат урона атакующему (50%)
        local d = DamageInfo()
        d:SetDamage(dmginfo:GetDamage() * 0.5)
        d:SetDamageType(DMG_SLASH)
        d:SetAttacker(target)
        d:SetInflictor(target:GetActiveWeapon() or target)
        d:SetDamagePosition(attacker:GetPos())
        d:SetDamageCustom(1)
        attacker:TakeDamageInfo(d)

        dmginfo:SetDamage(0)
        return true
    end
    
    -- 3. Глобальные баффы урона (attacker)
    if IsValid(attacker) and attacker:IsPlayer() then
        local buff = attacker.GetPerStatus and attacker:GetPerStatus("damage_buff")
        if buff and buff > 0 then
            dmginfo:ScaleDamage(1 + (buff / 100))
        end
        
        -- Бонус урона по игрокам (sharp)
        if target:IsPlayer() and attacker.inventory then
            local item = attacker.inventory:GetEquippedItem("weapon")
            if item then
                local bonus = item:getMeta("sharpBonus")
                if bonus and bonus["playerDamage"] then
                    dmginfo:AddDamage(bonus["playerDamage"])
                end
            end
        end

        -- Бонус урона по NPC (sharp)
        if (target:IsNPC() or target:IsNextBot()) and attacker.inventory then
            local item = attacker.inventory:GetEquippedItem("weapon")
            if item then
                local bonus = item:getMeta("sharpBonus")
                if bonus and bonus["npcDamage"] then
                    dmginfo:AddDamage(bonus["npcDamage"])
                end
            end
        end
    end
    
    -- 4. Защита и броня (target)
    if IsValid(target) and target:IsPlayer() then
        -- Бафф защиты
        local defense = target.GetPerStatus and target:GetPerStatus("defense_buff")
        if defense and defense > 0 then
            dmginfo:ScaleDamage(1 - (defense / 100))
        end

        -- Бонусы брони (sharp)
        local armorBuff = target:GetPerStatus("addArmor") or 0
        if armorBuff > 0 then
             -- Процентное снижение от addArmor (примерная логика из старого кода)
             dmginfo:ScaleDamage(1 - (armorBuff / 100))
        end
        
        -- Доп. резист от заточки брони
        if target.inventory then
             local item = target.inventory:GetEquippedItem("weapon") -- Возможно тут должна быть armor? Оставил как было в старом коде, но проверь слот
             if item then
                 local bonus = item:getMeta("sharpBonus")
                 if bonus and bonus["armor"] then
                     dmginfo:SubtractDamage(bonus["armor"])
                 end
             end
        end
    end
    
    -- Кровь (BloodAttack)
    if IsValid(attacker) and attacker:IsPlayer() and attacker.BloodAttack then
        addBlood(target, dmginfo)
    end
end)

-- Хелпер для эффекта кровотечения
function addBlood(ply, dmginfo)
    local attacker = dmginfo:GetAttacker()
    local wep = attacker:GetActiveWeapon()
    
    timer.Create("bloodEffect"..ply:EntIndex(), 1, 5, function()
        if not IsValid(ply) then return end
        local d = DamageInfo()
        d:SetDamage(5)
        d:SetDamageType(DMG_BLOOD or DMG_POISON)
        d:SetAttacker(attacker)
        d:SetInflictor(wep or attacker)
        d:SetDamagePosition(ply:GetPos() + Vector(0,0,50))
        d:SetDamageCustom(1)
        ply:TakeDamageInfo(d)
        
        -- ParticleEffectAttach("[*]_blood_short", PATTACH_POINT_FOLLOW, ply, 1) 
    end)
end

--=============================================================================
-- ДВИЖЕНИЕ (Movement)
--=============================================================================

hook.Add("SetupMove", "fighting.Movement", function(ply, mv, cmd)
    -- 1. Каст (замедление)
    if ply.InCast then
        mv:SetMaxSpeed(ply:GetWalkSpeed() * 0.5)
        mv:SetMaxClientSpeed(ply:GetWalkSpeed() * 0.5)
    end
    
    -- 2. Полная блокировка движения (InAction / стан и т.д.)
    if ply.InAction then
        mv:SetForwardSpeed(0)
        mv:SetSideSpeed(0)
        mv:SetUpSpeed(0)
    end
    
    -- 3. Рывок оружия (movefunc из SWEP)
    if ply.SetMove then
        local wep = ply:GetActiveWeapon()
        if IsValid(wep) and wep.AttackList and wep.AttackId and wep.AttackList[wep.AttackId] then
            local movefunc = wep.AttackList[wep.AttackId].move
            if movefunc then movefunc(ply, mv, cmd) end
        end
    end

    -- 4. Перекат (ROLL)
    if ply.InDodge and ply.DodgeEndTime then
        if CurTime() >= ply.DodgeEndTime then
            ply.InDodge        = false
            ply.DodgeDir       = nil
            ply.DodgeEndTime   = nil
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

        -- Блокируем прыжки/атаку во время ролла
        local buttons = mv:GetButtons()
        buttons = bit.band(buttons, bit.bnot(IN_JUMP))
        buttons = bit.band(buttons, bit.bnot(IN_ATTACK))
        mv:SetButtons(buttons)
    end
    
    -- 5. Старый форс вперед (IsForward) - если нужен для скиллов
    if ply.IsForward then
        mv:SetVelocity(ply:GetVelocity() + ply:GetForward() * 50)
        mv:SetSideSpeed(0)
        mv:SetForwardSpeed(0)
        
        -- Блок кнопок
        local buttons = mv:GetButtons()
        buttons = bit.band(buttons, bit.bnot(IN_JUMP))
        buttons = bit.band(buttons, bit.bnot(IN_ATTACK))
        mv:SetButtons(buttons)
    end
    
    -- 6. Прямой вектор (AddDir)
    if ply.AddDir then
        mv:SetVelocity(ply.AddDir)
        ply.AddDir = false
    end
    
    -- 7. Пинок (Kick)
    if ply.Kick and IsValid(ply.KickPly) then
        local dir = (ply:GetPos() - ply.KickPly:GetPos()):GetNormalized() * 400
        mv:SetVelocity(dir)
        ply.Kick = nil
        ply.KickPly = nil
    end
end)

hook.Add("PlayerDeath", "fighting.ResetState", function(ply)
    ply.InAction = false
    ply.InCast   = false
    ply.SetMove  = false
    ply.IsForward = false
    ply.Kick      = nil

    ply.InDodge        = false
    ply.DodgeDir       = nil
    ply.DodgeEndTime   = nil
    ply.DodgeIFrameEnd = nil
end)
