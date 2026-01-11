local SKILL = {}
SKILL.Name = "Удар по земле"
SKILL.Description = {color_white, "Персонаж ударяет мечом по земле и выпускает волну урона в размере урона оружия"}
SKILL.Animation = "arc_atk10_igne"
SKILL.CoolDown = 17
SKILL.WeaponType = "swordbig"
local function Dodmg(pos, ply, weapon)
    netstream.Start(ply, "ssss", pos, 50)
    local entityAttacked = ents.FindInSphere(pos, 30)
    for k, i in pairs(entityAttacked) do 
		if !i:IsNPC() and !i:IsPlayer() and !i:IsNextBot() then continue end 
		if i == ply then continue end  
		doAttackDamage(ply, i, weapon, 10)
	end
end
SKILL.Icon = 2352
SKILL.ServerFunc = function(ply, weapon)
    ply.InSkill = true
    local spawnPos = {}
    netstream.Start(nil, "fantasy/play/anim", ply, SKILL.Animation,  0, true)
    timer.Create("swordSkill"..ply:Name(), 0.3, 1, function()
        if !ply:Alive() then return end
        local vecForward = ply:GetForward()
        local vecRight = ply:GetRight()
        local vecUp = ply:GetUp()
        spawnPos[1] = ply:GetPos() + vecForward * 30 + vecUp * 30
        spawnPos[2] = ply:GetPos() + vecForward * 140 + vecRight * 30 + vecUp * 30
        spawnPos[3] = ply:GetPos() + vecForward * 140 - vecRight * 30 + vecUp * 30
        spawnPos[4] = ply:GetPos() + vecForward * 240 + vecRight * 60 + vecUp * 30
        spawnPos[5] = ply:GetPos() + vecForward * 240  + vecUp * 30
        spawnPos[6] = ply:GetPos() + vecForward * 240 - vecRight * 60 + vecUp * 30

        timer.Simple(0, function() ParticleEffect( "dust_dash_shadow", spawnPos[1], Angle( 0, 0, 0 ) ) Dodmg(spawnPos[1], ply, weapon) end)
        timer.Simple(0.3, function() ParticleEffect( "dust_dash_shadow", spawnPos[2], Angle( 0, 0, 0 ) ) Dodmg(spawnPos[2], ply, weapon) end)
        timer.Simple(0.3, function() ParticleEffect( "dust_dash_shadow", spawnPos[3], Angle( 0, 0, 0 ) ) Dodmg(spawnPos[3], ply, weapon) end)
        timer.Simple(0.6, function() ParticleEffect( "dust_dash_shadow", spawnPos[4], Angle( 0, 0, 0 ) ) Dodmg(spawnPos[4], ply, weapon) end)
        timer.Simple(0.6, function() ParticleEffect( "dust_dash_shadow", spawnPos[5], Angle( 0, 0, 0 ) ) Dodmg(spawnPos[5], ply, weapon) end)
        timer.Simple(0.6, function() ParticleEffect( "dust_dash_shadow", spawnPos[6], Angle( 0, 0, 0 ) ) Dodmg(spawnPos[6], ply, weapon) end)
    end)
    timer.Create("swordSkillEnd"..ply:Name(), 0.5, 1, function()
        ply.InSkill = false
    end)

   -- ply.InSkill = false
end

return SKILL