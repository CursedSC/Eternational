local SKILL = {}
SKILL.Name = "Парирование"
SKILL.Description = {color_white, "Полностью блокирует урон врага и наносит удар в ответ в размере 50% от первоначального урона. Во время способности нельзя бить или использовать другие способности."}
SKILL.Animation = "judge_r_s3_t1"
SKILL.CoolDown = 20
SKILL.WeaponType = "sword"
SKILL.Icon = 2321

SKILL.ServerFunc = function(ply, weapon)
    ply.InSkill = true
    ply.InPari = true
    ply:AddCooldown("В парировании", 4)
    timer.Create("swordSkill"..ply:Name(), 4, 1, function()
        ply.InPari = false
        ply.InSkill = false
    end)

end

return SKILL