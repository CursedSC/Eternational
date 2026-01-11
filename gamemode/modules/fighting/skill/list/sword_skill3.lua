local SKILL = {}
SKILL.Name = "Удар с рывком"
SKILL.Description = {color_white, "Делает рывок и наносит урон всем врагам в радиусе 170 единиц."}
SKILL.Animation = "judge_r_s3_t1"
SKILL.CoolDown = 3
SKILL.WeaponType = "sword"
SKILL.Icon = 2328

SKILL.ServerFunc = function(ply, weapon)
    ply.InSkill = true
    netstream.Start(nil, "fantasy/play/anim", ply, SKILL.Animation,  0, true)

    ply.IsDash = {
		angles = ply:EyeAngles(),
		dir = ply:GetForward() * 170
	}

    
    local damage = 13
    timer.Create("swordSkill"..ply:Name(), 0.4, 1, function()
        ply:LagCompensation(true)
        local damagePos = ply:GetPos() + Vector(0,0,50) + ( weapon:GetAttackAngle():Forward() * weapon.SphereSize)
        local entityAttacked = ents.FindInSphere(damagePos, weapon.SphereSize)
        ply:LagCompensation(false)
        for k, i in pairs(entityAttacked) do 
            if ply == i then continue end
            doAttackDamage(ply, i, weapon, damage)
        end
    end)
    timer.Simple(0.1,function ()
		ply.IsDash = false
	end)

    ply.InSkill = false
end

return SKILL