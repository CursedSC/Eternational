local SKILL = {}
SKILL.Name = "Удар в прыжке"
SKILL.Description = {color_white, "Персонаж резко прыгает вперед и вверх и по преземлению наносит отталкивающий урон по площади"}
SKILL.Animation = "1"
SKILL.CoolDown = 20
SKILL.WeaponType = "swordbig"
SKILL.Icon = 2325

SKILL.ServerFunc = function(ply, weapon)
    ply.InSkill = true
    Fight.Skills.Jump(ply)
end

return SKILL