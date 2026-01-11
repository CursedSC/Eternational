local SKILL = {}
SKILL.Name = "Широкий удар"
SKILL.Description = {color_white, "Выполняет вращающийся удар, поражающий всех врагов вокруг."}
SKILL.Animation = "judge_h_right_t2"
SKILL.CoolDown = 10
SKILL.WeaponType = "sword"
SKILL.Icon = 2312

SKILL.ServerFunc = function(ply, weapon)
    ply.InSkill = true
    netstream.Start(nil, "fantasy/play/anim", ply, SKILL.Animation,  0, true)
    timer.Create("swordSkill"..ply:Name(), 0.2, 1, function()
        ply:LagCompensation(true)
        local damagePos = ply:GetPos() + Vector(0,0,50)
        local entityAttacked = ents.FindInSphere(damagePos, weapon.SphereSize * 2) 
        ply:LagCompensation(false)
        local damage = 25
        netstream.Start(nil, "ssss", damagePos, weapon.SphereSize * 2)
        for k, i in pairs(entityAttacked) do 
            if ply == i then continue end
            doAttackDamage(ply, i, weapon, damage)
        end
    end)
    ply.InSkill = false
end

return SKILL