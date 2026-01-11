hook.Add("EntityTakeDamage", 'fantasy_fight/fight_system/all_bonuses_hook', function(entity, dmginfo)
    local attacker = dmginfo:GetAttacker()

    if entity:IsPlayer() and attacker:IsPlayer() then
        local resist = entity:GetResists()
        local buffdmg = attacker:GetBuffDmg()
        local resultbuff = buffdmg - resist

        dmginfo:ScaleDamage(1 + resultbuff)
    elseif attacker:IsPlayer() then
        local buffdmg = attacker:GetBuffDmg()

        dmginfo:ScaleDamage(1 + buffdmg)
    elseif not attacker:IsPlayer() and entity:IsPlayer() then
        local resist = entity:GetResists()

        dmginfo:ScaleDamage(1 - resist)
    end
end)

hook.Add( "SetupMove", "fighting/swep_attack", function( ply, mv, cmd )
	if ply.SetMove then
		local wep = ply:GetActiveWeapon()
		local movefunc = wep.AttackList[wep.AttackId].move
		movefunc(ply, mv, cmd)
	end

	if ply.InAction then
		mv:SetForwardSpeed(0)
		mv:SetSideSpeed(0)
		mv:SetUpSpeed(0)
	end
end )

hook.Add("PlayerDeath", "fighting/inaction_disable",function (ply)
	ply.InAction = false
	ply.SetMove = false
end)

function doAttackDamage(ply, target, weapon, damage, NoEffect)
    if !target:IsNPC() and !target:IsPlayer() and !target:IsNextBot() then return end
    ply:LagCompensation(true)
    local playerStatsAttacker
    local playerStatsTarget
    local weaponBonus = weapon.MainAtt or "strength"
    local weaponBonus = ply:GetAttribute(weaponBonus) or 1
    playerStatsAttacker = ply:GetAttributes()
    local item = ply.inventory:GetEquippedItem("weapon")
    local sharpBonus = item:getMeta("sharp") or 0
    if target:IsPlayer() then playerStatsTarget = target:GetAttributes() end
        local d = DamageInfo()
        d:SetDamage( damage + (weaponBonus * 2) + sharpBonus)
        d:SetDamageType(DMG_SLASH)
        d:SetAttacker( ply )
        d:SetInflictor(weapon) 
        d:SetDamagePosition(target:GetPos() + Vector(0,0,50))
        d:SetDamageCustom(1)
        target:TakeDamageInfo( d )
        if !NoEffect then 
            --slashhit_helper_2
        ParticleEffect( "slashhit_helper_2", target:GetPos() + Vector(0,0,50), Angle( 0, 0, 0 ) )
        --ParticleEffect( "[*]_swordhit_add", target:GetPos() + Vector(0,0,50), Angle( 0, 0, 0 ) )
        target:EmitSound("sword/accurate-hit-with-a-steel-sword.mp3", 100)
    end
    ply:LagCompensation(false)
end
 
 

hook.Add("PlayerButtonDown", "fight/skills/jump",function (ply, btn)
    --[[
    if ply.InSkill then return  end 
    local actWep = ply:GetActiveWeapon()
    local weaponSkillType = actWep.Type
    local skillBase = weaponSkillType.."_skill"
    local enumBase = "SKILL_"..string.upper(weaponSkillType).."_SKILL"

    for key = 1, 4 do 
        local enum = _G[enumBase..key]
        local skill = skillBase..key
        if btn == _G["KEY_"..key] and !ply:HasCooldown(enum)  then
            local s = skillList[skill]
            s.ServerFunc(ply, actWep)
            ply:AddCooldown(enum, s.CoolDown)
        end 
    end]]
end)

hook.Add( "SetupMove", "fight/skills/kick", function( player, mv, cmd )
	if player.Kick and player.KickPly then
		local dir = (player:GetPos() - player.KickPly:GetPos()):GetNormalized() * 400
		mv:SetVelocity(dir)
		player.Kick = nil
		player.KickPly = nil
	end
end )

hook.Add('SetupMove', 'fantasy/fight/forwes',function (player, mv, cmd)
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
    if wep.CanAttack and !wep:CanAttack() then
        mv:SetButtons(bit.band(mv:GetButtons(), bit.bnot(IN_JUMP)))
        mv:SetButtons(bit.band(mv:GetButtons(), bit.bnot(IN_ATTACK)))
    end
end)

hook.Add('SetupMove', 'fantasy/fight/dir',function (player, mv, cmd)
	if player and player.AddDir then
		local dir = player.AddDir
		mv:SetVelocity(dir)
		player.AddDir = false
	end
end)
local anims = {
    "b_block_weak_right",
    "b_block_weak_left"
}

hook.Add( "EntityTakeDamage", "fantasy.EntityTakeDamage.InPari", function( ply, dmginfo )
    if not ply:IsPlayer() then return end

    if ply.InPari then 
        netstream.Start(ply, "fnt/player/blocked", dmginfo:GetAttacker():GetPos())

        netstream.Start(nil, "fantasy/play/anim", ply, table.Random(anims),  0, true)
        local d = DamageInfo()
        d:SetDamage( dmginfo:GetDamage() * 0.5 )
        d:SetDamageType(DMG_SLASH)
        d:SetAttacker(ply)
        d:SetInflictor(ply:GetActiveWeapon()) 
        d:SetDamagePosition(dmginfo:GetAttacker():GetPos())
        d:SetDamageCustom(1)
        dmginfo:GetAttacker():TakeDamageInfo( d )
        dmginfo:SetDamage( 0 )
        return true 
    end 
end)

hook.Add( "EntityTakeDamage", "fantasy.EntityTakeDamage.Armor", function( ply, dmginfo )
    if not ply:IsPlayer() then return end
    local dmg = dmginfo:GetDamage()
    local armorBuff = ply:GetPerStatus("addArmor")
    local armorDamage = dmg - ((dmg / 100) * armorBuff)
    local playerArmorResist = ply:GetArmorStat("armor")
    local armorDamage = armorDamage - (armorDamage / 100) * playerArmorResist
    local armorDamage = math.Round(armorDamage)
    local playerInventory = ply.inventory
    local hasWeapon = playerInventory:GetEquippedItem("weapon")

    if hasWeapon then 
        local bonus = hasWeapon:getMeta("sharpBonus") or nil
        if bonus and bonus["armor"] then 
            armorDamage = armorDamage - sharpBonus["armor"]
            armorDamage = math.Round(armorDamage)
        end 
    end

    dmginfo:SetDamage(armorDamage)
end)

hook.Add("EntityTakeDamage", "fantasy.EntityTakeDamage.Sharp.playerDamage", function(ply, dmginfo)
    if !ply:IsPlayer() then return end
    local attacker = dmginfo:GetAttacker()
    if !attacker:IsPlayer() then return end
    local playerInventory = attacker.inventory
    local hasWeapon = playerInventory:GetEquippedItem("weapon")
    if !hasWeapon then return end 
    local bonus = hasWeapon:getMeta("sharpBonus") or nil
    if !bonus then return end 
    local hasBonus = bonus["playerDamage"] or nil
    if !hasBonus then return end
    local damage = dmginfo:GetDamage()
    local newDamage = damage + sharpBonus["playerDamage"]
    dmginfo:SetDamage(newDamage)
end)

hook.Add("EntityTakeDamage", "fantasy.EntityTakeDamage.Sharp.npcDamage", function(ply, dmginfo)
    local IsTrue = ply:IsNextBot() or ply:IsNPC()
    if !IsTrue then return end
    local attacker = dmginfo:GetAttacker()
    if !attacker:IsPlayer() then return end
    local playerInventory = attacker.inventory
    local hasWeapon = playerInventory:GetEquippedItem("weapon")
    if !hasWeapon then return end 
    local bonus = hasWeapon:getMeta("sharpBonus") or nil
    if !bonus then return end 
    local hasBonus = bonus["npcDamage"] or nil
    if !hasBonus then return end
    local damage = dmginfo:GetDamage()
    local newDamage = damage + sharpBonus["npcDamage"]
    dmginfo:SetDamage(newDamage)
end)

function addBlood(ply, dmginfo)
    local attacker = dmginfo:GetAttacker()
    local wep = attacker:GetActiveWeapon()
    timer.Create("bloodEffect"..ply:EntIndex(), 1, 5, function()
        local d = DamageInfo()
        d:SetDamage( 5 )
        d:SetDamageType(DMG_BLOOD)
        d:SetAttacker(attacker)
        d:SetInflictor(wep) 
        d:SetDamagePosition(ply:GetPos() + Vector(0,0,50))
        d:SetDamageCustom(1)
        ply:TakeDamageInfo( d )
        ParticleEffectAttach( "[*]_blood_short", PATTACH_POINT_FOLLOW, ply, 1 )
    end)
end

hook.Add("EntityTakeDamage", "fantasy.EntityTakeDamage.Blood", function(ply, dmginfo)
    local attacker = dmginfo:GetAttacker()
    if !attacker:IsPlayer() then return end
    if !attacker.BloodAttack then return end 
    addBlood(ply, dmginfo)
end)


hook.Add("EntityTakeDamage", "fantasy.EntityTakeDamage.Shielded.Boss", function(ply, dmginfo)
    local attacker = dmginfo:GetAttacker()
    if !attacker.Shielded then return end
    if !ply:IsPlayer() then return end
    ply:AddPerStatus("speed", -70, 5, "boss_debuff_freeze")
end)