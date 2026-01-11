local SKILL = {}
SKILL.Name = "Укрепление"
SKILL.Description = {color_white, "Укрепляет выбранного игрока, добавляя 15% брони на 3 минуты."}
SKILL.Animation = "arc_kyao1_medical"
SKILL.CoolDown = 5
SKILL.WeaponType = "catalisator"
SKILL.Mana = 20
SKILL.Icon = 2492

SKILL.ServerFunc = function(ply, weapon)
    ply.InSkill = true
    netstream.Start(nil, "fantasy/play/anim", ply, SKILL.Animation, 0, true)
    timer.Simple(0.3, function()
        if not ply:Alive() then return end
        local isRDown = ply:KeyDown(IN_RELOAD)
        local target = isRDown and ply or ply:GetNWEntity("target")
        if not IsValid(target) then return end
        target:AddPerStatus("addArmor", 15, 180, "skill_armor_buff")
        netstream.Start({ply, target}, "fnt/player/custom", target:GetPos(), "Укрепление!", Color(165,93,021))
        ply.InSkill = false
    end)
end

return SKILL