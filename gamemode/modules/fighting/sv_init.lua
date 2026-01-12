util.AddNetworkString("fighting.StartCast")
util.AddNetworkString("fighting.ShowDamage")

--------------------------------------------------------------------------------
-- Глобальные модификаторы входящего/исходящего урона (fighting.Damage)
--------------------------------------------------------------------------------
hook.Add("EntityTakeDamage", 'fantasy_fight/fight_system/all_bonuses_hook', function(entity, dmginfo)
    local attacker = dmginfo:GetAttacker()

    -- Если у атакующего есть прямой бафф урона
    if IsValid(attacker) and attacker:IsPlayer() then
        local buffdmg = attacker.GetBuffDmg and attacker:GetBuffDmg() or 0
        if buffdmg ~= 0 then
            dmginfo:ScaleDamage(1 + buffdmg)
        end
    end

    -- Если у цели есть прямой резист
    if IsValid(entity) and entity:IsPlayer() then
        local resist = entity.GetResists and entity:GetResists() or 0
        if resist ~= 0 then
            dmginfo:ScaleDamage(1 - resist)
        end
    end
end)

--------------------------------------------------------------------------------
-- Движение во время атак (SWEP)
--------------------------------------------------------------------------------
hook.Add("SetupMove", "fighting/swep_attack", function(ply, mv, cmd)
    if ply.SetMove then
        local wep = ply:GetActiveWeapon()
        if IsValid(wep) and wep.AttackList and wep.AttackId and wep.AttackList[wep.AttackId] then
            local movefunc = wep.AttackList[wep.AttackId].move
            if movefunc then
                movefunc(ply, mv, cmd)
            end
        end
    end

    if ply.InAction then
        mv:SetForwardSpeed(0)
        mv:SetSideSpeed(0)
        mv:SetUpSpeed(0)
    end
end)

--------------------------------------------------------------------------------
-- Сброс состояния на смерть
--------------------------------------------------------------------------------
hook.Add("PlayerDeath", "fighting/inaction_disable", function(ply)
    ply.InAction = false
    ply.SetMove = false
    ply.InCast = false
end)

--------------------------------------------------------------------------------
-- ОСНОВНАЯ ФУНКЦИЯ НАНЕСЕНИЯ УРОНА (HYBRID)
--------------------------------------------------------------------------------
function doAttackDamage(ply, target, weapon, damage, NoEffect)
    if not IsValid(ply) or not IsValid(target) then return end
    if not (target:IsNPC() or target:IsPlayer() or target:IsNextBot()) then return end

    ply:LagCompensation(true)

    local base = damage or 0

    -- Старый расчет MainAtt ("strength" и т.п.)
    local mainAttKey = (IsValid(weapon) and weapon.MainAtt) or "strength"
    local mainAttVal = 1
    if ply.GetAttribute then
        mainAttVal = ply:GetAttribute(mainAttKey) or 1
    end

    base = base + (mainAttVal * 2)

    -- Старый расчет sharpBonus
    local sharpBonus = 0
    if ply.inventory and ply.inventory.GetEquippedItem then
        local item = ply.inventory:GetEquippedItem("weapon")
        if item and item.getMeta then
            sharpBonus = item:getMeta("sharp") or 0
        end
    end

    base = base + sharpBonus

    local hitPos = target:GetPos() + Vector(0, 0, 50)

    -- Используем новую систему, если она загружена, иначе фоллбэк
    if fighting.Damage and fighting.Damage.Phys then
        -- fighting.Damage сам учтет защиту цели и резисты
        fighting.Damage:Phys(ply, target, base, hitPos)
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
        target:EmitSound("sword/accurate-hit-with-a-steel-sword.mp3", 100)
    end

    ply:LagCompensation(false)
end

--------------------------------------------------------------------------------
-- Хуки управления скиллами / движением
--------------------------------------------------------------------------------
hook.Add("PlayerButtonDown", "fight/skills/jump", function(ply, btn)
    -- Оставлено пустым, как в оригинале (закомментировано)
end)

hook.Add("SetupMove", "fight/skills/kick", function(player, mv, cmd)
    if player.Kick and player.KickPly and IsValid(player.KickPly) then
        local dir = (player:GetPos() - player.KickPly:GetPos()):GetNormalized() * 400
        mv:SetVelocity(dir)
        player.Kick = nil
        player.KickPly = nil
    end
end)

hook.Add("SetupMove", "fantasy/fight/forwes", function(player, mv, cmd)
    if player and player.IsForward then
        mv:SetVelocity(player:GetVelocity() + player:GetForward() * 50)
        mv:SetSideSpeed(0)
        mv:SetForwardSpeed(0)
        if mv:KeyPressed(IN_JUMP) or mv:KeyPressed(IN_ATTACK) then
            mv:SetButtons(bit.band(mv:GetButtons(), bit.bnot(IN_JUMP)))
            mv:SetButtons(bit.band(mv:GetButtons(), bit.bnot(IN_ATTACK)))
        end
    end

    local wep = player:GetActiveWeapon()
    if IsValid(wep) and wep.CanAttack and not wep:CanAttack() then
        mv:SetButtons(bit.band(mv:GetButtons(), bit.bnot(IN_JUMP)))
        mv:SetButtons(bit.band(mv:GetButtons(), bit.bnot(IN_ATTACK)))
    end
end)

hook.Add("SetupMove", "fantasy/fight/dir", function(player, mv, cmd)
    if player and player.AddDir then
        local dir = player.AddDir
        mv:SetVelocity(dir)
        player.AddDir = false
    end
end)

--------------------------------------------------------------------------------
-- Парирование (InPari)
--------------------------------------------------------------------------------
local anims = {
    "b_block_weak_right",
    "b_block_weak_left"
}

hook.Add("EntityTakeDamage", "fantasy.EntityTakeDamage.InPari", function(ply, dmginfo)
    if not ply:IsPlayer() then return end

    if ply.InPari then
        local attacker = dmginfo:GetAttacker()
        if IsValid(attacker) then
            netstream.Start(ply, "fnt/player/blocked", attacker:GetPos())
            netstream.Start(nil, "fantasy/play/anim", ply, table.Random(anims), 0, true)
            
            local d = DamageInfo()
            d:SetDamage(dmginfo:GetDamage() * 0.5)
            d:SetDamageType(DMG_SLASH)
            d:SetAttacker(ply)
            d:SetInflictor(ply:GetActiveWeapon() or ply)
            d:SetDamagePosition(attacker:GetPos())
            d:SetDamageCustom(1)
            
            attacker:TakeDamageInfo(d)
        end
        
        dmginfo:SetDamage(0)
        return true
    end
end)

--------------------------------------------------------------------------------
-- Броня (Armor Reduction)
--------------------------------------------------------------------------------
hook.Add("EntityTakeDamage", "fantasy.EntityTakeDamage.Armor", function(ply, dmginfo)
    if not ply:IsPlayer() then return end

    local dmg = dmginfo:GetDamage()
    
    -- Базовая броня (buff)
    local armorBuff = ply.GetPerStatus and ply:GetPerStatus("addArmor") or 0
    local armorDamage = dmg - ((dmg / 100) * armorBuff)

    -- Резист брони (stat)
    local playerArmorResist = ply.GetArmorStat and ply:GetArmorStat("armor") or 0
    armorDamage = armorDamage - (armorDamage / 100) * playerArmorResist
    
    armorDamage = math.Round(armorDamage)

    -- Пробивание брони атакующим (sharpBonus["armor"])
    local attacker = dmginfo:GetAttacker()
    if IsValid(attacker) and attacker:IsPlayer() and attacker.inventory then
        local hasWeapon = attacker.inventory:GetEquippedItem("weapon")
        if hasWeapon and hasWeapon.getMeta then
            local bonus = hasWeapon:getMeta("sharpBonus")
            if bonus and bonus["armor"] then
                armorDamage = armorDamage - bonus["armor"]
                armorDamage = math.Round(armorDamage)
            end
        end
    end

    if armorDamage < 0 then armorDamage = 0 end
    dmginfo:SetDamage(armorDamage)
end)

--------------------------------------------------------------------------------
-- Sharp: playerDamage / npcDamage
--------------------------------------------------------------------------------
hook.Add("EntityTakeDamage", "fantasy.EntityTakeDamage.Sharp.playerDamage", function(ply, dmginfo)
    if not ply:IsPlayer() then return end
    
    local attacker = dmginfo:GetAttacker()
    if not (IsValid(attacker) and attacker:IsPlayer()) then return end
    
    if attacker.inventory then
        local hasWeapon = attacker.inventory:GetEquippedItem("weapon")
        if hasWeapon and hasWeapon.getMeta then
            local bonus = hasWeapon:getMeta("sharpBonus")
            if bonus and bonus["playerDamage"] then
                local newDamage = dmginfo:GetDamage() + bonus["playerDamage"]
                dmginfo:SetDamage(newDamage)
            end
        end
    end
end)

hook.Add("EntityTakeDamage", "fantasy.EntityTakeDamage.Sharp.npcDamage", function(ply, dmginfo)
    local isTargetNPC = ply:IsNextBot() or ply:IsNPC()
    if not isTargetNPC then return end
    
    local attacker = dmginfo:GetAttacker()
    if not (IsValid(attacker) and attacker:IsPlayer()) then return end
    
    if attacker.inventory then
        local hasWeapon = attacker.inventory:GetEquippedItem("weapon")
        if hasWeapon and hasWeapon.getMeta then
            local bonus = hasWeapon:getMeta("sharpBonus")
            if bonus and bonus["npcDamage"] then
                local newDamage = dmginfo:GetDamage() + bonus["npcDamage"]
                dmginfo:SetDamage(newDamage)
            end
        end
    end
end)

--------------------------------------------------------------------------------
-- Кровотечение (Blood Attack)
--------------------------------------------------------------------------------
function addBlood(ply, dmginfo)
    local attacker = dmginfo:GetAttacker()
    local wep = IsValid(attacker) and attacker:GetActiveWeapon() or attacker
    
    local timerID = "bloodEffect" .. ply:EntIndex()
    timer.Create(timerID, 1, 5, function()
        if not IsValid(ply) then timer.Remove(timerID) return end
        
        local d = DamageInfo()
        d:SetDamage(5)
        d:SetDamageType(DMG_BLOOD) -- Если DMG_BLOOD не определён, движок возьмет 0 или error
        d:SetAttacker(attacker)
        d:SetInflictor(wep)
        d:SetDamagePosition(ply:GetPos() + Vector(0,0,50))
        d:SetDamageCustom(1)
        
        ply:TakeDamageInfo(d)
        ParticleEffectAttach("[*]_blood_short", PATTACH_POINT_FOLLOW, ply, 1)
    end)
end

hook.Add("EntityTakeDamage", "fantasy.EntityTakeDamage.Blood", function(ply, dmginfo)
    local attacker = dmginfo:GetAttacker()
    if not (IsValid(attacker) and attacker:IsPlayer()) then return end
    
    if attacker.BloodAttack then
        addBlood(ply, dmginfo)
    end
end)

--------------------------------------------------------------------------------
-- Босс (Shielded + Boss Debuff)
--------------------------------------------------------------------------------
hook.Add("EntityTakeDamage", "fantasy.EntityTakeDamage.Shielded.Boss", function(ply, dmginfo)
    local attacker = dmginfo:GetAttacker()
    if not IsValid(attacker) then return end
    
    if attacker.Shielded and ply:IsPlayer() then
        if ply.AddPerStatus then
            ply:AddPerStatus("speed", -70, 5, "boss_debuff_freeze")
        end
    end
end)
