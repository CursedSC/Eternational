local SKILL = {}
SKILL.Name = "Рывок сквозь"
SKILL.Description = {color_white, "Мгновенно телепортируется вперед на 500 единиц, нанося урон всем существам на пути."}
SKILL.Animation = "wos_ryoku_h_s1_t1"
SKILL.CoolDown = 2
SKILL.WeaponType = "sword"
SKILL.Mana = 35
SKILL.Icon = 2362  

SKILL.ServerFunc = function(ply, weapon)    
    ply.InSkill = true
    netstream.Start(nil, "fantasy/play/anim", ply, SKILL.Animation, 0, true)
    
    -- Visual effect for teleport start
    ParticleEffectAttach("kirakira_ryuko-3_floor", PATTACH_POINT_FOLLOW, ply, 0)
    
    
    timer.Simple(0.7, function()
        if not ply:Alive() then 
            ply.InSkill = false
            return 
        end
        ply:EmitSound("weapons/physcannon/energy_disintegrate4.wav", 100, 150)
        -- Get the forward direction and calculate target position
        local forward = ply:GetForward()
        local startPos = ply:GetPos() + Vector(0, 0, 10)
        local endPos = startPos + forward * 500
        
        -- Trace to find a valid position (avoid teleporting into walls)
        local tr = util.TraceHull({
            start = startPos,
            endpos = endPos,
            filter = function(ent)
                return !(ply:IsPlayer() or ply:IsNPC() or ply:IsNextBot()) and ent != ply
            end,
            mins = Vector(-16, -16, 0),
            maxs = Vector(16, 16, 72),
            mask = MASK_PLAYERSOLID
        })
        
        -- Find entities in the path between start and end
        local entitiesInPath = {}
        
        -- Create a series of points along the teleport path
        local direction = (tr.HitPos - startPos):GetNormalized()
        local distance = startPos:Distance(tr.HitPos)
        local steps = math.Clamp(math.floor(distance / 40), 1, 20) -- Check every 40 units, up to 20 checks
        
        -- Use multiple sphere traces along the path
        for i = 1, steps do
            local checkPos = startPos + direction * (distance * (i / steps))
            local entities = ents.FindInSphere(checkPos, 60)
            
            for _, ent in pairs(entities) do
                if IsValid(ent) and (ent:IsNPC() or ent:IsPlayer() or ent:IsNextBot()) and ent != ply then
                    entitiesInPath[ent] = true
                end
            end
        end
        
        -- Create teleport effect
        ParticleEffect("doom_caco_blast_smoke", startPos, Angle(0, 0, 0))
        
        -- Teleport player to the endpoint
        ply:SetPos(tr.HitPos)
        
        -- Create arrival effect
        ParticleEffect("doom_caco_blast_smoke", tr.HitPos, Angle(0, 0, 0))
        ply:EmitSound("weapons/physcannon/energy_sing_flyby2.wav", 100, 150)
        
        -- Deal damage to entities in path
        for ent, _ in pairs(entitiesInPath) do
            if IsValid(ent) and ent ~= ply then
                local damage = 25 * (1 + (ply:GetAttribute("agility") / 100))
                doAttackDamage(ply, ent, weapon, damage)
                
                -- Create slash effect on the entity
                local effectData = EffectData()
                effectData:SetOrigin(ent:GetPos() + Vector(0, 0, 30))
                effectData:SetScale(1)
                util.Effect("BloodImpact", effectData)
                
                netstream.Start(ply, "fnt/player/custom", ent:GetPos(), "Разрезан!", Color(255, 50, 50))
            end
        end
        
        -- End the skill
        timer.Simple(0.2, function()
            ply.InSkill = false
        end)
    end)
end

return SKILL