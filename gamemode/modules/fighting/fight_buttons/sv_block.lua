AddCSLuaFile()

function Fight.Skills.main_Block(ply)
	if ply:HasCooldown(SKILL_BLOCK) then return end
	if !ply.IsBlock then
		if !Fight.Skills.CanUse(ply) then return end
	end

	local wep = ply:GetActiveWeapon()

	if !ply.JumpBeforeBlock then
		ply.JumpBeforeBlock = ply:GetJumpPower()
		ply.SpeedBeforeBlock = ply:GetRunSpeed()
	end

	ply:SetJumpPower(0)
	if ply.IsBlock ~= nil then
		ply.IsBlock = !ply.IsBlock
		ply:AddCooldown(SKILL_BLOCK, 2)

		if ply.IsBlock then
			ply.Fight_CanParry = true

			timer.Simple(0.5,function ()
				ply.Fight_CanParry = false
			end)
			--PlayCustomAnimation(ply, wep.Animation_Block, false)
			ply:SetRunSpeed(ply:GetRunSpeed() * 0.5)
			hook.Add("Think",'Fight/fight_system/block/think',function ()
				ply:GetActiveWeapon():SetNextPrimaryFire(CurTime() + 1)
				if ply:GetActiveWeapon():GetNextSecondaryFire() > CurTime() then
					ply:GetActiveWeapon():SetNextSecondaryFire(CurTime() + 1)
				end
			end)
		else
			--PlayCustomAnimation(ply, wep.Animation_GoodBlock, true)
			ply:SetRunSpeed(ply.SpeedBeforeBlock)
			ply:SetJumpPower(ply.JumpBeforeBlock)
			hook.Remove("Think",'Fight/fight_system/block/think')
		end
	else
		ply.Fight_CanParry = true

		timer.Simple(0.5,function ()
			ply.Fight_CanParry = false
		end)

		ply:AddCooldown(SKILL_BLOCK, 2)
		ply.IsBlock = true
		--PlayCustomAnimation(ply, wep.Animation_Block, false)
		ply:SetRunSpeed(ply:GetRunSpeed() * 0.5)
		ply:SetJumpPower(0)
		hook.Add("Think",'Fight/fight_system/block/think',function ()
			ply:GetActiveWeapon():SetNextPrimaryFire(CurTime() + 1)
			if ply:GetActiveWeapon():GetNextSecondaryFire() > CurTime() then
				ply:GetActiveWeapon():SetNextSecondaryFire(CurTime() + 1)
			end
		end)
	end
end

hook.Add("PlayerButtonDown", 'Fight/fight_system/block',function (ply, btn)
	if btn == KEY_R then
	--	Fight.Skills.main_Block(ply)
	end
end)

hook.Add("PlayerDeath", 'Fight/fightsystem/block/death',function (ply)
	if ply.IsBlock then
		ply.IsBlock = false
		hook.Remove("Think",'Fight/fight_system/block/think')
	end
end)

hook.Add("EntityTakeDamage", 'Fight/fight_system/block/Parry',function (target, dmginfo)
	local attacker = dmginfo:GetAttacker()
	if target:IsPlayer() and !target:HasCooldown(SKILL_PARRY) and dmginfo:GetDamageType() == DMG_SLASH  then
		if target.Fight_CanParry then
			dmginfo:ScaleDamage(0)
			target:AddCooldown(SKILL_BLOCK, 0)
			Fight.Skills.main_Block(target)

			if attacker:IsPlayer() then
				if target:GetPos():Distance(attacker:GetPos()) < 250 then
					attacker:GetActiveWeapon():SetNextPrimaryFire(CurTime() + 1)
					attacker:GetActiveWeapon():SetNextSecondaryFire(CurTime() + 1 + attacker:GetActiveWeapon():GetNextSecondaryFire())
					target:AddCooldown(SKILL_PARRY, 10)
					target.Fight_CanParry = false
				end
			end
		end
	end
end)

hook.Add("EntityTakeDamage", 'Fight/Block',function (target, dmginfo)
	local attacker = dmginfo:GetAttacker()
	if target:IsPlayer() and dmginfo:GetDamageType() == DMG_SLASH then
		local weapon = target:GetActiveWeapon()
		if weapon and weapon.IsBlocking and weapon:IsBlocking() then 
			dmginfo:ScaleDamage(0)
			target:EmitSound("sword/SwordHitRingA1.wav", 100)
			ParticleEffectAttach( "[1]_bomb1_add_2", PATTACH_POINT_FOLLOW, target, 6 )
			netstream.Start(nil, "fnt/player/blocked", target:GetPos() + Vector(0,0,50))
		end
	end
end)
