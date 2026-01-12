AddCSLuaFile()

-- Конфигурация блока
local BLOCK_CONFIG = {
    SpeedPenalty = 0.75,     -- 75% от скорости (штраф 25%)
    DurabilityMax = 100,     -- Максимальная прочность
    RegenRate = 10,          -- Реген прочности в секунду (когда не в блоке)
    RegenDelay = 2.0,        -- Задержка регена после получения урона/блока
    CostPerDamage = 0.5,     -- Сколько прочности тратится на 1 ед. урона
    BlockAngle = 120,        -- Угол блокирования перед игроком
    ParryWindow = 0.5,       -- Окно парирования (сек)
}

util.AddNetworkString("fighting.BlockState") -- bool isBlocking, float durability

-- Инициализация переменных игрока
hook.Add("PlayerSpawn", "fighting.Block.Init", function(ply)
    ply.BlockDurability = BLOCK_CONFIG.DurabilityMax
    ply.BlockRegenTime = 0
    ply.IsBlocking = false
    ply:SetNW2Bool("IsBlocking", false)
    ply:SetNW2Int("BlockDurability", BLOCK_CONFIG.DurabilityMax)
end)

-- Логика нажатия ПКМ (StartCommand вместо PlayerButtonDown для удержания)
hook.Add("StartCommand", "fighting.Block.Input", function(ply, cmd)
    if not ply:Alive() then return end
    
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) or not wep.CanBlock then 
        if ply.IsBlocking then
            ply.IsBlocking = false
            ply:SetNW2Bool("IsBlocking", false)
            ply:SetRunSpeed(ply.OldRunSpeed or ply:GetRunSpeed())
            ply:SetWalkSpeed(ply.OldWalkSpeed or ply:GetWalkSpeed())
        end
        return 
    end

    if cmd:KeyDown(IN_ATTACK2) then
        if not ply.IsBlocking and ply.BlockDurability > 0 then
            -- Начало блока
            ply.IsBlocking = true
            ply.BlockStartTime = CurTime()
            ply:SetNW2Bool("IsBlocking", true)
            
            -- Сохраняем и режем скорость
            ply.OldRunSpeed = ply:GetRunSpeed()
            ply.OldWalkSpeed = ply:GetWalkSpeed()
            
            ply:SetRunSpeed(ply.OldRunSpeed * BLOCK_CONFIG.SpeedPenalty)
            ply:SetWalkSpeed(ply.OldWalkSpeed * BLOCK_CONFIG.SpeedPenalty)
            
            -- Анимация (если есть в weapon)
            if wep.BlockAnim then
                -- PlayCustomAnimation(ply, wep.BlockAnim, false) -- раскомментируй если есть система анимаций
            end
        end
    else
        if ply.IsBlocking then
            -- Конец блока
            ply.IsBlocking = false
            ply:SetNW2Bool("IsBlocking", false)
            ply.BlockRegenTime = CurTime() + BLOCK_CONFIG.RegenDelay
            
            ply:SetRunSpeed(ply.OldRunSpeed or ply:GetRunSpeed())
            ply:SetWalkSpeed(ply.OldWalkSpeed or ply:GetWalkSpeed())
        end
    end
end)

-- Регенерация прочности
hook.Add("Think", "fighting.Block.Regen", function()
    for _, ply in ipairs(player.GetAll()) do
        if not ply:Alive() then continue end
        
        -- Если блок сломан (0 прочности), ждём полного регена или таймера?
        -- Сделаем просто реген если не блокируем
        if not ply.IsBlocking and ply.BlockDurability < BLOCK_CONFIG.DurabilityMax then
            if CurTime() > (ply.BlockRegenTime or 0) then
                ply.BlockDurability = math.min(ply.BlockDurability + BLOCK_CONFIG.RegenRate * FrameTime(), BLOCK_CONFIG.DurabilityMax)
                ply:SetNW2Int("BlockDurability", math.floor(ply.BlockDurability))
            end
        end
        
        -- Если прочность кончилась в блоке - снимаем блок
        if ply.IsBlocking and ply.BlockDurability <= 0 then
            ply.IsBlocking = false
            ply:SetNW2Bool("IsBlocking", false)
            ply.BlockRegenTime = CurTime() + 4.0 -- Штраф за пробитие блока
            ply:EmitSound("physics/metal/metal_sheet_impact_hard1.wav")
            
            ply:SetRunSpeed(ply.OldRunSpeed or ply:GetRunSpeed())
            ply:SetWalkSpeed(ply.OldWalkSpeed or ply:GetWalkSpeed())
        end
    end
end)

-- Обработка урона (блокирование)
hook.Add("EntityTakeDamage", "fighting.Block.Damage", function(target, dmginfo)
    if not target:IsPlayer() or not target.IsBlocking then return end
    
    -- Блок работает только против физ урона (SLASH/CLUB) и пуль? Настроим на всё кроме падения/радиации
    if dmginfo:IsFallDamage() or dmginfo:IsDamageType(DMG_DROWN) then return end

    local attacker = dmginfo:GetAttacker()
    local dmgPos = attacker:GetPos()
    if dmginfo:IsExplosionDamage() then dmgPos = dmginfo:GetDamagePosition() end
    
    -- Проверка угла (смотрим ли мы на источник урона)
    local vecToAttacker = (dmgPos - target:GetPos())
    vecToAttacker.z = 0
    vecToAttacker:Normalize()
    
    local forward = target:GetForward()
    forward.z = 0
    forward:Normalize()
    
    local dot = forward:Dot(vecToAttacker)
    local angle = math.deg(math.acos(dot))
    
    -- Если урон спереди (в пределах угла)
    if angle < (BLOCK_CONFIG.BlockAngle / 2) then
        local damage = dmginfo:GetDamage()
        
        -- Парирование (если блок нажат только что)
        local isParry = (CurTime() - (target.BlockStartTime or 0)) <= BLOCK_CONFIG.ParryWindow
        
        if isParry and attacker:IsPlayer() and target:GetPos():DistToSqr(attacker:GetPos()) < 62500 then -- 250^2
            -- ПАРИРОВАНИЕ
            dmginfo:ScaleDamage(0)
            target:EmitSound("sword/SwordHitRingA1.wav", 100, 120)
            ParticleEffect("hunter_shield_impact", target:GetPos() + Vector(0,0,50), Angle(0,0,0))
            
            -- Стан врага / эффект
            attacker:ViewPunch(Angle(-10, 0, 0))
            -- Можно добавить кулдаун на атаку врагу
            if attacker:GetActiveWeapon():IsValid() then
                attacker:GetActiveWeapon():SetNextPrimaryFire(CurTime() + 1.0)
            end
            
            netstream.Start(nil, "fnt/player/blocked", target:GetPos() + Vector(0,0,50)) -- Старый эффект
        else
            -- ОБЫЧНЫЙ БЛОК
            -- Расчет расхода прочности
            local durabilityCost = damage * BLOCK_CONFIG.CostPerDamage
            
            if target.BlockDurability >= durabilityCost then
                -- Полный блок
                target.BlockDurability = target.BlockDurability - durabilityCost
                target:SetNW2Int("BlockDurability", math.floor(target.BlockDurability))
                target.BlockRegenTime = CurTime() + BLOCK_CONFIG.RegenDelay
                
                dmginfo:ScaleDamage(0)
                target:EmitSound("physics/metal/metal_solid_impact_bullet2.wav", 75, 100)
                ParticleEffect("hunter_shield_impact", target:GetPos() + Vector(0,0,50), Angle(0,0,0))
            else
                -- Блок пробит (не хватает прочности)
                local blockedDmg = target.BlockDurability / BLOCK_CONFIG.CostPerDamage
                local remainingDmg = damage - blockedDmg
                
                target.BlockDurability = 0
                target:SetNW2Int("BlockDurability", 0)
                target.IsBlocking = false -- Снимаем блок
                target:SetNW2Bool("IsBlocking", false)
                target.BlockRegenTime = CurTime() + 4.0
                
                -- Пропускаем часть урона
                dmginfo:SetDamage(remainingDmg)
                target:EmitSound("physics/metal/metal_box_break1.wav")
                target:ViewPunch(Angle(-5, 5, 0))
            end
        end
        return true -- Применили логику блока
    end
end)
