local SKILL = {}
SKILL.Name = "Огненый Шар"
SKILL.Description = {color_white, "Выпускает огненый снаряд с уроном 30 + интеллект."}
SKILL.Animation = "arc_kyao1_koyoko2"
SKILL.CoolDown = 10
SKILL.WeaponType = "catalisator"
SKILL.Mana = 20
SKILL.Icon = 2509

local function CastFireball(ply, weapon)
    local fireball = ents.Create("pfx_[12]_fire")
    fireball:SetPos(ply:EyePos() + ply:GetAimVector() * 16)
    fireball:SetAngles(ply:EyeAngles())
    fireball:Spawn()
    fireball:SetOwner(ply)
    fireball.targets = {}
    local vec = ply:GetAimVector() * 1200
    timer.Simple(0.3, function(arguments)

        fireball:Activate()   
        fireball:SetVelocity(vec)
        fireball:SetMoveType(MOVETYPE_FLY)

        fireball:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
        fireball:SetTrigger(true)
        
        function fireball:Touch(ent)
            if ent == ply then return end
            local hitEnt = ent
            if IsValid(hitEnt) and (hitEnt:IsNPC() or hitEnt:IsPlayer() or hitEnt:IsNextBot()) and !fireball.targets[hitEnt] then
                local dmginfo = DamageInfo()
                dmginfo:SetAttacker(ply)
                dmginfo:SetInflictor(fireball)
                local dmg = 30
                local int = ply:GetAttribute("intelligence")
                dmg = dmg + int 

                dmginfo:SetDamage(dmg)
                hitEnt:TakeDamageInfo(dmginfo)
                fireball.targets[hitEnt] = true
            end
            fireball:Remove()
        end
    end)
end

SKILL.ServerFunc = function(ply, weapon)
    ply.InSkill = true
    netstream.Start(nil, "fantasy/play/anim", ply, SKILL.Animation, 0, true)
    timer.Simple(0.5, function()
        if not ply:Alive() then return end
        CastFireball(ply, weapon)
        ply.InSkill = false
    end)
end

return SKILL