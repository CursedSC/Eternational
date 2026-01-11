local function getDirections(ply)
	return {
		[IN_FORWARD] = ply:GetForward() * 170,
		[IN_BACK] = -ply:GetForward() * 170,
		[IN_MOVELEFT] = -ply:GetRight() * 170,
		[IN_MOVERIGHT] = ply:GetRight() * 170
	}
end

function Fight.Skills.Dash(ply)
	if !ply:IsOnGround() then return end
	if !Fight.Skills.CanUse(ply) then return end
	if ply:HasCooldown(SKILL_DASH) then return end

	local jumppower = ply:GetJumpPower()
	local angles = ply:EyeAngles()
	local dir
	// ply:GodEnable() Перенести в обработчик урона
	--ply:GetActiveWeapon():SetNextPrimaryFire(CurTime() + 0.6)
	--ply:GetActiveWeapon():SetNextSecondaryFire(CurTime() + 0.6 + ply:GetNextPrimaryFire())

	local directions = getDirections(ply)
	for key, vector in pairs(directions) do
		if ply:KeyDown(key) then
			dir = vector
			--fantasy_fight.ParticleAttach(ply, "dust_dash_smoke", 'aoc_ValveBiped.Bip01_R_Foot')
			--fantasy_fight.ParticleAttach(ply, "dust_dash_smoke", 'aoc_ValveBiped.Bip01_L_Foot')
			--PlayCustomAnimation(ply, "wos_bs_shared_roll_" .. (key == IN_FORWARD and "forward" or key == IN_BACK and "back" or key == IN_MOVELEFT and "left" or "right"))
			break
		end
	end

	if not dir then return end

	ply.IsDash = {
		angles = angles,
		dir = dir
	}

	timer.Simple(0.1,function ()
		//ply:GodDisable()
		ply:SetJumpPower(jumppower)
		ply.IsDash = false
	end)

	ply:AddCooldown(SKILL_DASH, 3.5)
end

hook.Add('SetupMove', 'fantasy/fight/dashes',function (player, mv, cmd)
	if player and istable(player.IsDash) then
		player:SetEyeAngles(player.IsDash.angles)
		mv:SetVelocity(player:GetVelocity() + player.IsDash.dir*1.15)
		mv:SetSideSpeed(0)
		mv:SetForwardSpeed(0)
		if mv:KeyPressed(IN_JUMP) or mv:KeyPressed(IN_ATTACK) then
			mv:SetButtons(bit.band(mv:GetButtons(), bit.bnot(IN_JUMP)))
			mv:SetButtons(bit.band(mv:GetButtons(), bit.bnot(IN_ATTACK)))
		end
	end
end)
hook.Add('PlayerButtonDown', 'fantasy_fight/fight_system/dashes',function (ply, btn)
	if ply:Alive() and btn == KEY_G then
		Fight.Skills.Dash(ply)
	end
end)
