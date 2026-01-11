local SKILL = {}
SKILL.Name = "Исцеление"
SKILL.Description = {color_white, "Исцеляет выбранного игрока на 10 + интелект * 2."}
SKILL.Animation = "arc_kyao1_medical"
SKILL.CoolDown = 20
SKILL.WeaponType = "catalisator"
SKILL.Mana = 80
SKILL.Icon = 2524

SKILL.ServerFunc = function(ply, weapon)
    ply.InSkill = true
    netstream.Start(nil, "fantasy/play/anim", ply, SKILL.Animation, 0, true)
    timer.Simple(0.3, function()
        if not ply:Alive() then return end
        local isRDown = ply:KeyDown(IN_RELOAD)
        local target = isRDown and ply or ply:GetNWEntity("target")
        if not IsValid(target) then return end
        local maxHp, hp = target:GetMaxHealth(), target:Health()
        local int = ply:GetAttribute("intelligence")
        local heal = 10 + (int * 2)
        target:SetHealth(math.min(maxHp, hp + heal))
        ParticleEffect( "ds3_cinder_heal", target:GetPos(), Angle( 0, 0, 0 ) )
        netstream.Start({ply, target}, "fnt/player/custom", target:GetPos(), "Исцеление! +"..heal, Color(73,204,69))
        ply.InSkill = false
    end)
end

return SKILL