util.AddNetworkString("fighting.StartCast")
util.AddNetworkString("fighting.ShowDamage")

-- Хук для биндов умений (1-4)
hook.Add("PlayerButtonDown", "fighting.Input.Skills", function(ply, btn)
    if ply.InCast then return end
    
    local keyMap = {
        [KEY_1] = 1,
        [KEY_2] = 2,
        [KEY_3] = 3,
        [KEY_4] = 4,
    }
    
    local slot = keyMap[btn]
    if slot then
        local wep = ply:GetActiveWeapon()
        if IsValid(wep) and wep.Skills and wep.Skills[slot] then
            fighting.Skill:Cast(ply, wep.Skills[slot])
        else
            if slot == 1 then fighting.Skill:Cast(ply, "sword_slash") end
            if slot == 2 then fighting.Skill:Cast(ply, "fireball") end
        end
    end
end)

-- Хук для базовой атаки (ЛКМ) и выносливости
hook.Add("StartCommand", "fighting.Input.Attack", function(ply, cmd)
    if cmd:KeyDown(IN_ATTACK) then
        local cost = 10 -- базовая стоимость удара
        if fighting.Resources and fighting.Resources.HasStamina and not fighting.Resources:HasStamina(ply, cost) then
            cmd:RemoveKey(IN_ATTACK)
        end
    end
end)

-- Универсальная функция удара для старой системы и новых формул урона
function doAttackDamage(ply, target, weapon, damage, NoEffect)
    if not IsValid(ply) or not IsValid(target) then return end
    if not (target:IsNPC() or target:IsPlayer() or target:IsNextBot()) then return end

    ply:LagCompensation(true)

    local base = damage or 0

    -- Основной стат оружия (strength / agility / и т.п.)
    local mainAttKey = (IsValid(weapon) and weapon.MainAtt) or "strength"
    local mainAttVal = 1
    if ply.GetAttribute then
        mainAttVal = ply:GetAttribute(mainAttKey) or 1
    end

    base = base + (mainAttVal * 2)

    -- Бонус остроты с оружия (sharp)
    local sharpBonus = 0
    local inv = ply.inventory
    if inv and inv.GetEquippedItem then
        local item = inv:GetEquippedItem("weapon")
        if item and item.getMeta then
            sharpBonus = item:getMeta("sharp") or 0
        end
    end

    base = base + sharpBonus

    local hitPos = target:GetPos() + Vector(0, 0, 50)

    if fighting.Damage and fighting.Damage.Phys then
        fighting.Damage:Phys(ply, target, base, hitPos, {
            -- сюда позже можно докинуть crit, powerMul и т.п.
        })
    else
        local d = DamageInfo()
        d:SetDamage(base)
        d:SetDamageType(DMG_SLASH)
        d:SetAttacker(ply)
        d:SetInflictor(IsValid(weapon) and weapon or ply)
        d:SetDamagePosition(hitPos)
        d:SetDamageCustom(1)
        target:TakeDamageInfo(d)
    end

    if not NoEffect then
        ParticleEffect("slashhit_helper_2", hitPos, Angle(0, 0, 0))
        --ParticleEffect("[*]_swordhit_add", hitPos, Angle(0, 0, 0))
        target:EmitSound("sword/accurate-hit-with-a-steel-sword.mp3", 100)
    end

    ply:LagCompensation(false)
end

-- Глобальные модификаторы входящего/исходящего урона
hook.Add("EntityTakeDamage", "fighting.Damage.Modifier", function(target, dmginfo)
    local attacker = dmginfo:GetAttacker()
    
    if IsValid(attacker) and attacker:IsPlayer() then
        local buff = attacker.GetPerStatus and attacker:GetPerStatus("damage_buff")
        if buff and buff > 0 then
            dmginfo:ScaleDamage(1 + (buff / 100))
        end
    end
    
    if IsValid(target) and target:IsPlayer() then
        local defense = target.GetPerStatus and target:GetPerStatus("defense_buff")
        if defense and defense > 0 then
            dmginfo:ScaleDamage(1 - (defense / 100))
        end
    end
end)

-- Логика движения во время кастов
hook.Add("SetupMove", "fighting.Movement", function(ply, mv, cmd)
    if ply.InCast then
        local spd = ply:GetWalkSpeed() * 0.5
        mv:SetMaxSpeed(spd)
        mv:SetMaxClientSpeed(spd)
    end
    
    if ply.InAction then
        mv:SetForwardSpeed(0)
        mv:SetSideSpeed(0)
        mv:SetUpSpeed(0)
    end
end)

hook.Add("PlayerDeath", "fighting.ResetState", function(ply)
    ply.InAction = false
    ply.InCast   = false
    ply.SetMove  = false
end)
