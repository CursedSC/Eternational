local SKILL = {}
SKILL.Name = "Подлый удар"
SKILL.Description = {color_white, "Наносит урон врагу и оставляет кровотечение на 5 секунд. Кровотчение наноситься раз в 1 секунду нанося урон в размере 5."}
SKILL.Animation = "1"
SKILL.CoolDown = 10
SKILL.WeaponType = "knife"
SKILL.Icon = 2554

SKILL.ServerFunc = function(ply, weapon)
   -- netstream.Start(nil, "fantasy/play/anim", ply, SKILL.Animation,  0, true)
    local attackData = weapon.AttackList[weapon.AttackId]
    weapon.cd = CurTime() + attackData.cd
    netstream.Start(nil, "fantasy/play/anim", ply, attackData.seq,  0, true)
    ply:EmitSound("sword/sword_wooh.wav", 100)
    ply.BloodAttack = true
    attackData.Attack(weapon, ply)
    timer.Simple(0.1, function()
        ply.BloodAttack = false
    end)
end

return SKILL