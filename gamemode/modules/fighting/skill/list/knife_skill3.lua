local SKILL = {}
SKILL.Name = "Хитроумный финт"
SKILL.Description = {color_white, "Персонаж кидает кинжал и отпрыгивает назад."}
SKILL.Animation = "wos_bs_shared_roll_back"
SKILL.CoolDown = 12
SKILL.WeaponType = "knife"
SKILL.Icon = 2549

SKILL.ServerFunc = function(ply, weapon)
   netstream.Start(nil, "fantasy/play/anim", ply, SKILL.Animation,  0, true)
   ply.AddDir = ply:GetForward() * -1200
   
   local ang = ply:GetAimVector():Angle()
   local pos = ply:EyePos() 

   local arrow = ents.Create("huntingbow_arrow")
   arrow:SetOwner(ply)
   arrow:SetPos(pos)
   arrow:SetAngles(ang)
   arrow:Spawn()
   arrow:SetModel("models/props_c17/TrapPropeller_Lever.mdl")
   local dmg = 10
   local agi = ply:GetAttribute("agility")
   dmg = dmg + agi 

   arrow:SetDMG(dmg)
   arrow:Activate()
   arrow:SetNWBool("ReDraw", true)

   arrow:SetVelocity(ang:Forward() * 2500 * 1)
end

return SKILL