local SKILL = {}
SKILL.Name = "Провокация"
SKILL.Description = {color_white, "Провоцирует ближайших врагов атаковать вас в течение 10 секунд. Все враги в радиусе 500 единиц будут сосредоточены только на вас."}
SKILL.Animation = "wos_bs_shared_taunt"
SKILL.CoolDown = 1
SKILL.WeaponType = nil  
SKILL.Mana = 30
SKILL.Icon = 2508  

SKILL.ServerFunc = function(ply, weapon)
    netstream.Start(nil, "fantasy/play/anim", ply, SKILL.Animation, 0, true)
    
    ParticleEffectAttach("[0]_teleport_red_main_add_2", PATTACH_POINT_FOLLOW, ply, 0)
    timer.Simple(1, function()
        if not IsValid(ply) then return end
        ply:StopParticles()
    end)

    local tauntRadius = 500
    local affectedEntities = {}
    
    timer.Simple(0.5, function()
        if not ply:Alive() then 
            ply.InSkill = false
            return 
        end
        
        local entities = ents.FindInSphere(ply:GetPos(), tauntRadius)
        
        for _, ent in pairs(entities) do
            if (ent:IsNPC() or ent:IsNextBot() or ent:IsPlayer()) and ent:Health() > 0 and ent != ply then
                affectedEntities[ent] = nil
                
                if ent.SetEnemy then
                    ent:SetEnemy(ply)
                end
                
                if ent.VJ_AddCertainEntityAsEnemy then
                    ent:VJ_AddCertainEntityAsEnemy(ply)
                end
                
                if ent.SetTarget then
                    ent:SetTarget(ply)
                end

                ent:SetNW2Bool("DrGBaseNemesis", true)

                timer.Create("fnt/taunt/" .. ent:EntIndex(), 0.1, 100, function()
                    if ent:IsPlayer() then 
                        local vec1 = ply:GetPos()
                        local vec2 = ent:GetPos()
                        ent:SetEyeAngles( ( vec1 - vec2 ):Angle() )
                    end
                end)
                
                ParticleEffectAttach("doom_hknight_blast", PATTACH_POINT_FOLLOW, ent, 1)
            end
        end
        
        netstream.Start(ply, "fnt/player/custom", ply:GetPos(), "Провокация!", Color(255, 50, 50))
        
        timer.Simple(10, function()
            if not ply:Alive() then return end
            
            for ent, originalEnemy in pairs(affectedEntities) do
                if IsValid(ent) and ent:Health() > 0 then
                    
                    if ent.VJ_ClearEntityRelationship then
                        ent:VJ_ClearEntityRelationship(ply)
                    end
                    
                    ent:SetNW2Bool("DrGBaseNemesis", false)
                    ent:StopParticles()
                end
            end
            
            netstream.Start(ply, "fnt/player/custom", ply:GetPos(), "Провокация закончилась", Color(100, 100, 100))
        end)
    end)
end

return SKILL