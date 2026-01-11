local SKILL = {}
SKILL.Name = "Вихрь ударов"
SKILL.Description = {color_white, "Наносит урон всем врагам в радиусе 100 единиц по 20 едениц урона."}
SKILL.Animation = "arc_atk_berserk13"
SKILL.CoolDown = 15
SKILL.WeaponType = "swordbig"
SKILL.Icon = 2353

SKILL.ServerFunc = function(ply, weapon)
    netstream.Start(nil, "fantasy/play/anim", ply, SKILL.Animation,  0, true)
    ply.InSkill = true
    ply.IsForward = true
    timer.Create("swordSkill"..ply:Name(), 0.3, 4, function()
        ply:LagCompensation(true)
        local damagePos = ply:GetPos() + Vector(0,0,50)
        local entityAttacked = ents.FindInSphere(damagePos, weapon.SphereSize)
        ply:LagCompensation(false)
        for k, i in pairs(entityAttacked) do 
            if ply == i then continue end
            doAttackDamage(ply, i, weapon, 20)
        end
    end)

    timer.Simple(1.2, function()
        ply.InSkill = false
        ply.IsForward = false
    end)
end

return SKILL