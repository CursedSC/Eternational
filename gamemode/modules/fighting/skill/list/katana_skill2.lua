local SKILL = {}
SKILL.Name = "Слабые точки"
SKILL.Description = {color_white, "Точный удар катаной по уязвимым точкам противника, замедляющий его движения на 50% в течение 2 секунд."}
SKILL.Animation = "vanguard_r_right_t3"
SKILL.CoolDown = 1
SKILL.WeaponType = "sword"  
SKILL.Mana = 25
SKILL.Icon = 2322  

SKILL.ServerFunc = function(ply, weapon)
    ply.InSkill = true
    netstream.Start(nil, "fantasy/play/anim", ply, SKILL.Animation, 0, true)
    
    -- Визуальные эффекты начала атаки
    --ParticleEffectAttach("martialhit_star", PATTACH_POINT_FOLLOW, ply, 0)

    timer.Simple(0.2, function()
        if not ply:Alive() then 
            ply.InSkill = false
            return 
        end

        local pos = ply:GetPos() + ply:GetForward() * 60 + Vector(0, 0, 50)
        local angle = ply:GetAngles() + Angle(0, 0, 0)
        
        ply:LagCompensation(true)
        local damagePos = ply:GetPos() + Vector(0,0,50) + (ply:GetForward() * weapon.SphereSize * 1.2)
        local entityAttacked = ents.FindInSphere(damagePos, weapon.SphereSize)
        
        for _, ent in pairs(entityAttacked) do 
            if not (ent:IsNPC() or ent:IsPlayer() or ent:IsNextBot()) or ent == ply then continue end
            
            local damage = 15
            doAttackDamage(ply, ent, weapon, damage)
            
            if ent:IsPlayer() then
                ent:AddPerStatus("debuffspeed", 50, 2, "katana_weakpoint_slow")
            elseif ent:IsNPC() or ent:IsNextBot() then
                if ent.SetPlaybackRate then
                    local originalRate = ent:GetPlaybackRate() or 1
                    ent:SetPlaybackRate(originalRate * 0.5)
                    timer.Simple(2, function()
                        if IsValid(ent) and ent:Health() > 0 then
                            ent:SetPlaybackRate(originalRate)
                        end
                    end)
                end
            end
            
            ParticleEffect("martialhit_glow", ent:GetPos() + Vector(0,0,30), Angle(0, 0, 0))
            netstream.Start(ply, "fnt/player/custom", ent:GetPos(), "Замедление!", Color(50, 100, 255))
        end
        ply:LagCompensation(false)
        
    end)
    
    -- Завершение скилла
    timer.Simple(0.8, function()
        if not IsValid(ply) then return end
        
        ply:StopParticles()
        ply.InSkill = false
    end)
end

return SKILL