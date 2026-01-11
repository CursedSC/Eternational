function Fight.Skills.Jump(ply)
	if !Fight.Skills.CanUse(ply) then return end
	if ply:HasCooldown(SKILL_JUMP) then return end

	ply.Fight_OnceActivateSkill = true
	ply.SkillJump = true
	--arc_jump1v2
	netstream.Start(nil, "fantasy/play/anim", ply, "arc_jump1v2",  0, true)
	timer.Simple(0.2,function ()
		ply.SkillJump = false
		local steamid = ply:SteamID()
		--doom_caco_blast_smoke
		hook.Add("Think", "fight/skills/jump"..ply:SteamID(),function ()
			if not IsValid(ply) then hook.Remove("Think", "fight/skills/jump"..steamid) end
			if ply:IsValid() and ply:IsOnGround() then
				local trace = util.TraceHull({
					start = ply:GetPos(),
					endpos = -ply:GetUp() * 10000,
					filter = ply,
					mins = Vector( -10, -10, -10 ),
					maxs = Vector( 10, 10, 10 ),
					mask = MASK_SHOT_HULL
				})

				if trace.Entity and trace.Entity:IsPlayer() then
					hook.Remove("Think", "fight/skills/jump"..ply:SteamID())
					ply.Fight_OnceActivateSkill = false
					ply.InSkill = false
					--ply:AddCooldown(SKILL_JUMP, 5)
					return
				end
				ParticleEffect( "doom_caco_blast_smoke", ply:GetPos(), Angle( 0, 0, 0 ) )
				local pos = ply:GetPos()
				hook.Remove("Think", "fight/skills/jump"..ply:SteamID())
				--ply:AddCooldown(SKILL_JUMP, 10)
				ply.Fight_OnceActivateSkill = false
				ply.InSkill = false
				local tableINSPHERE = ents.FindInSphere(ply:GetPos(), 100) // 150

				for k, v in pairs(tableINSPHERE) do
					--if !v:IsPlayer() then continue end
					if v == ply then continue end
					v:TakeDamage(50, ply, ply)
					v.SkillJumpImpact = true
					v.SkillJumpImpact_ply = ply
				end
			end
		end)
	end) 
end

hook.Add( "SetupMove", "fight/skills/jump", function( player, mv, cmd )
	if player.SkillJump then
		local forward = player:GetForward()
		local velocity = player:GetVelocity()
		velocity.z = 251
		mv:SetVelocity(Vector(forward.x, forward.y, velocity.z) * Vector(500, 500, 1))
	end

	if player.SkillJumpImpact then
		local dir = (player:GetPos() - player.SkillJumpImpact_ply:GetPos()):GetNormalized() * 500
		dir.z = 350
		mv:SetVelocity(dir)
		player.SkillJumpImpact = nil
		player.SkillJumpImpact_ply = nil
	end
end )

hook.Add("PlayerButtonDown", "fight/skills/jump",function (ply, btn)
	if btn == KEY_R and ply:IsOnGround() then
	--	Fight.Skills.Jump(ply)
	end
end)
