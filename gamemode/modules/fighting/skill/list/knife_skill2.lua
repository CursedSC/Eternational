local SKILL = {}
SKILL.Name = "Пинок"
SKILL.Description = {color_white, "Наносит урон всем врагам в радиусе 1.7 от игрока и отталкивает их замедляя на 30% в течении 3 секунд."}
SKILL.Animation = "wos_bs_shared_kick"
SKILL.CoolDown = 14
SKILL.WeaponType = "knife"
SKILL.Icon = 2311

SKILL.ServerFunc = function(ply, weapon)
    ply.InSkill = true
    netstream.Start(nil, "fantasy/play/anim", ply, SKILL.Animation,  0, true)
    timer.Create("swordSkill"..ply:Name(), 0.3, 1, function()
        if !ply:Alive() then return end
        ply:LagCompensation(true)
        local damagePos = ply:GetPos() + Vector(0,0,50) + ( weapon:GetAttackAngle():Forward() * weapon.SphereSize * 1.7)
        local entityAttacked = ents.FindInSphere(damagePos, weapon.SphereSize * 1.7)
        ply:LagCompensation(false)
        for k, i in pairs(entityAttacked) do 
            if !i:IsNPC() and !i:IsPlayer() and !i:IsNextBot() then continue end 
            if i == ply then continue end  
            i.Kick = true 
            i.KickPly = ply
            doAttackDamage(ply, i, weapon, 17, true)
            if i:IsPlayer() then
                i:AddPerStatus("debuffspeed", 30, 3)
            end
        end


        ply.InSkill = false
    end)
    
end

return SKILL