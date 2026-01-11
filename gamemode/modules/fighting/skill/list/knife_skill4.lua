local SKILL = {}
SKILL.Name = "Подлый трюк"
SKILL.Description = {color_white, "Персонаж телепортируется за спину выбранного игрока."}
SKILL.Animation = ""
SKILL.CoolDown = 8
SKILL.CustomCD = true
SKILL.WeaponType = "knife"
SKILL.Icon = 2547


local function TeleportBehindPlayer(ply, target)
   if not IsValid(ply) or not IsValid(target) or not ply:IsPlayer() or not target:IsPlayer() then
       return false, "Invalid player or target"
   end

   -- Get the target's position and orientation
   local targetPos = target:GetPos()
   local targetAngles = target:EyeAngles()
   
   -- Calculate the position behind the target
   local distanceBehind = 50 -- Distance behind the target in units
   local behindPos = targetPos - targetAngles:Forward() * distanceBehind

   -- Check if there is enough space for the player
   local hullMins, hullMaxs = ply:GetHull()
   local tr = util.TraceHull({
       start = behindPos,
       endpos = behindPos,
       mins = hullMins,
       maxs = hullMaxs,
       filter = {ply, target}
   })

   -- If space is free, teleport the player
   if not tr.Hit then
       ply:SetPos(behindPos)
       ply:SetEyeAngles(targetAngles)
       return true, "Teleport successful"
   else
       return false, "No free space to teleport"
   end
end

SKILL.ServerFunc = function(ply, weapon, enum)
	local entTeleport = ply:GetNWEntity("target")
    local maxDistance = 300
    if entTeleport:GetPos():DistToSqr(ply:GetPos()) > maxDistance * maxDistance then
        return false, "Target is too far away"
    end
   TeleportBehindPlayer(ply, entTeleport)
end

return SKILL