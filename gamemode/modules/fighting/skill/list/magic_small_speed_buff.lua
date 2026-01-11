local SKILL = {}
SKILL.Name = "Слабое Ускорение"
SKILL.Description = {color_white, "Ускоряет выбранного игрока, добавляя 20% скорости на 5 секунд."}
SKILL.Animation = "arc_kyao1_medical"
SKILL.CoolDown = 5
SKILL.WeaponType = nil
SKILL.Mana = 20
SKILL.Icon = 2696

SKILL.ServerFunc = function(ply, weapon)
    ply.InSkill = true
    netstream.Start(nil, "fantasy/play/anim", ply, SKILL.Animation, 0, true)
    timer.Simple(0.3, function()
        if not ply:Alive() then return end
        local isRDown = ply:KeyDown(IN_RELOAD)
        local target = isRDown and ply or ply:GetNWEntity("target")
        if not IsValid(target) then return end
        target:AddPerStatus("speed", 20, 5)
        netstream.Start({ply, target}, "fnt/player/custom", target:GetPos(), "Слабое Ускорение!", Color(87,129,221))
        ply.InSkill = false
    end)
end

return SKILL