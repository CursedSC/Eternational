local SKILL = {}
SKILL.Name = "Молнии"
SKILL.Description = {color_white, "Наносит урон всем врагам в радиусе 200 от позиции главной молнии."}
SKILL.Animation = "arc_kyao2_doton"
SKILL.CoolDown = 30
SKILL.WeaponType = "catalisator"
SKILL.Mana = 100
SKILL.Icon = 2446

local function CastLightning(ply, weapon)
    local tr = util.TraceLine( {
        start = ply:EyePos(),
        endpos = ply:EyePos() + ply:GetAimVector() * 1000,
        filter = function( ent ) return ( ent:GetClass() == "prop_physics" ) end
    } )

    local tr = util.TraceLine( {
        start = tr.HitPos,
        endpos = tr.HitPos - Vector(0,0,1000),
        filter = function( ent ) return ( ent:GetClass() == "prop_physics" ) end
    } )

    local groundPos = tr.HitPos
 
    local lightning = ents.Create("pfx_doom_bfg_projectile")
    lightning:SetPos(groundPos  + Vector(0,0,120))
    lightning:Spawn()
    lightning:SetOwner(ply)

    local lightning2 = ents.Create("pfx_doom_bfg_explosion_swave_2a")
    lightning2:SetPos(groundPos  + Vector(0,0,1))
    lightning2:Spawn()
    lightning2:SetOwner(ply)

    local radius = 200 -- Adjust the radius as needed
    local dmg = 50
    local int = ply:GetAttribute("intelligence")
    dmg = dmg + int * 2
    local entities = ents.FindInSphere(groundPos, radius)
    for _, ent in ipairs(entities) do
        if ent:IsNPC() or ent:IsPlayer() or ent:IsNextBot() then
            local dmginfo = DamageInfo()
            dmginfo:SetAttacker(ply)
            dmginfo:SetInflictor(lightning)
            dmginfo:SetDamage(dmg)
            ent:TakeDamageInfo(dmginfo)
        end
    end
    timer.Simple(0.5, function() ply:Freeze(false) end)
    timer.Simple(1, function() lightning:Remove() lightning2:Remove() end)
end

SKILL.ServerFunc = function(ply, weapon)
    ply.InSkill = true
    netstream.Start(nil, "fantasy/play/anim", ply, SKILL.Animation, 0, true)
    timer.Simple(0.5, function()
        if not ply:Alive() then return end
        ply:Freeze(true)
        CastLightning(ply, weapon)
        ply.InSkill = false
    end)
end

return SKILL