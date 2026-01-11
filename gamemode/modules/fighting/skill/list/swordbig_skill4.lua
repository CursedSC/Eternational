local SKILL = {}
SKILL.Name = "Разрубающий удар"
SKILL.Description = {color_white, "Резкий, но отточеный удар наносящий 25 урона"}
SKILL.Animation = "wos_ryoku_h_s1_t1"
SKILL.CoolDown = 9
SKILL.WeaponType = "swordbig"
SKILL.Icon = 2334

SKILL.ServerFunc = function(ply, weapon)
    ply.InSkill = true
    netstream.Start(nil, "fantasy/play/anim", ply, SKILL.Animation,  0, true)
    timer.Create("swordSkill"..ply:Name(), 0.5, 1, function()
        if !ply:Alive() then return end
        local pos = ply:GetPos() + ply:GetForward() * 50 + Vector(0, 0, 20)
        ParticleEffect( "doom_caco_blast_smoke", pos, Angle( 0, 0, 0 ) )
        ply:LagCompensation(true)
        local damagePos = ply:GetPos() + Vector(0,0,50) + ( weapon:GetAttackAngle():Forward() * weapon.SphereSize)
        local entityAttacked = ents.FindInSphere(damagePos, weapon.SphereSize)
        ply:LagCompensation(false)
        for k, i in pairs(entityAttacked) do 
            if !i:IsNPC() and !i:IsPlayer() and !i:IsNextBot() then continue end 
            if i == ply then continue end  
            doAttackDamage(ply, i, weapon, 25)
        end
    end)
    timer.Create("swordSkillEnd"..ply:Name(), 0.7, 1, function()
        ply.InSkill = false
    end)
    
end

return SKILL