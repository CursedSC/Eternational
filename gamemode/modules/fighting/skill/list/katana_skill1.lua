local SKILL = {}
SKILL.Name = "Двойной Разрез"
SKILL.Description = {color_white, "Мастерское владение катаной позволяет выполнить два молниеносных разреза, наносящих урон всем врагам на пути клинка."}
SKILL.Animation = "arc_atk17_lsword"
SKILL.CoolDown = 1
SKILL.WeaponType = "sword"  
SKILL.Mana = 35
SKILL.Icon = 2323  

SKILL.ServerFunc = function(ply, weapon)
    ply.InSkill = true
    netstream.Start(nil, "fantasy/play/anim", ply, SKILL.Animation, 0, true)
    
    -- Начальные визуальные эффекты
    timer.Simple(0.3, function()
        ParticleEffectAttach("kirakira_ryuko-3", PATTACH_POINT_FOLLOW, ply, 0)
    end)

    
    timer.Simple(0.5, function()
        if not ply:Alive() then 
            ply.InSkill = false
            return 
        end

        local pos1 = ply:GetPos() + ply:GetForward() * 60 + Vector(0, 0, 50)
        local angle1 = ply:GetAngles() + Angle(0, 45, 0)

        ply:LagCompensation(true)
        local damagePos = ply:GetPos() + Vector(0,0,50) + (ply:GetForward() * weapon.SphereSize * 1.2)
        local entityAttacked = ents.FindInSphere(damagePos, weapon.SphereSize)
        
        for _, ent in pairs(entityAttacked) do 
            if not (ent:IsNPC() or ent:IsPlayer() or ent:IsNextBot()) or ent == ply then continue end
            
            local damage = 18
            doAttackDamage(ply, ent, weapon, damage)
            
            ParticleEffect("kirakira_ryuko-3_floor", ent:GetPos() + Vector(0,0,30), Angle(0, 0, 0))
        end
        ply:LagCompensation(false)
    end)
    
    
    timer.Simple(1.2, function()
        if not IsValid(ply) then return end
        
        ply:StopParticles()
        ply.InSkill = false

        local finalPos = ply:GetPos() + Vector(0,0,40)
    end)
end

return SKILL