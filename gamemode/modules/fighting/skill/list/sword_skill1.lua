local SKILL = {}
SKILL.Name = "Клинок Ярости"
SKILL.Description = {color_white, "Мощная серия ударов, каждый следующий удар наносит больше урона [10, 20, 30]"}
SKILL.Animation = "arc_atk_berserk5"
SKILL.CoolDown = 10
SKILL.WeaponType = "sword"
SKILL.Icon = 2318

SKILL.ServerFunc = function(ply, weapon)
    netstream.Start(nil, "fantasy/play/anim", ply, SKILL.Animation,  0, true)
    ply.InSkill = true
    local damage = 10
    timer.Create("swordSkill"..ply:Name(), 0.3, 3, function()
        ply:LagCompensation(true)
        local damagePos = ply:GetPos() + Vector(0,0,50) + ( weapon:GetAttackAngle():Forward() * weapon.SphereSize)
        local entityAttacked = ents.FindInSphere(damagePos, weapon.SphereSize)
        ply:LagCompensation(false)
        for k, i in pairs(entityAttacked) do 
            if ply == i then continue end
            doAttackDamage(ply, i, weapon, damage)
        end
        damage = damage + 10
    end)
    timer.Simple(0.9, function()
        ply.InSkill = false
    end)
end

return SKILL
