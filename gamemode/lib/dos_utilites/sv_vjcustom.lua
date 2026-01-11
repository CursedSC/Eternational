if SERVER then 
	local ent_base = scripted_ents.Get("npc_vj_creature_base")
	local IsProp = VJ_IsProp
	local CurTime = CurTime
	local IsValid = IsValid
	local GetConVar = GetConVar
	local isstring = isstring
	local isnumber = isnumber
	local tonumber = tonumber
	local math_clamp = math.Clamp
	local math_rad = math.rad 
	local math_cos = math.cos
	local math_angApproach = math.ApproachAngle
	local math_angDif = math.AngleDifference
	local destructibleEnts = {func_breakable=true, func_physbox=true, prop_door_rotating=true}
	local finishAttack = {
		[VJ_ATTACK_MELEE] = function(self, skipStopAttacks)
			if skipStopAttacks != true then
				timer.Create("timer_melee_finished"..self:EntIndex(), self:DecideAttackTimer(self.NextAnyAttackTime_Melee, self.NextAnyAttackTime_Melee_DoRand, self.TimeUntilMeleeAttackDamage, self.CurrentAttackAnimationDuration), 1, function()
					self:StopAttacks()
					self:DoChaseAnimation()
				end)
			end
			timer.Create("timer_melee_finished_abletomelee"..self:EntIndex(), self:DecideAttackTimer(self.NextMeleeAttackTime, self.NextMeleeAttackTime_DoRand), 1, function()
				self.IsAbleToMeleeAttack = true
			end)
		end,
		[VJ_ATTACK_RANGE] = function(self, skipStopAttacks)
			if skipStopAttacks != true then
				timer.Create("timer_range_finished"..self:EntIndex(), self:DecideAttackTimer(self.NextAnyAttackTime_Range, self.NextAnyAttackTime_Range_DoRand, self.TimeUntilRangeAttackProjectileRelease, self.CurrentAttackAnimationDuration), 1, function()
					self:StopAttacks()
					self:DoChaseAnimation()
				end)
			end
			timer.Create("timer_range_finished_abletorange"..self:EntIndex(), self:DecideAttackTimer(self.NextRangeAttackTime, self.NextRangeAttackTime_DoRand), 1, function()
				self.IsAbleToRangeAttack = true
			end)
		end,
		[VJ_ATTACK_LEAP] = function(self, skipStopAttacks)
			if skipStopAttacks != true then
				timer.Create("timer_leap_finished"..self:EntIndex(), self:DecideAttackTimer(self.NextAnyAttackTime_Leap, self.NextAnyAttackTime_Leap_DoRand, self.TimeUntilLeapAttackDamage, self.CurrentAttackAnimationDuration), 1, function()
					self:StopAttacks()
					self:DoChaseAnimation()
				end)
			end
			timer.Create("timer_leap_finished_abletoleap"..self:EntIndex(), self:DecideAttackTimer(self.NextLeapAttackTime, self.NextLeapAttackTime_DoRand), 1, function()
				self.IsAbleToLeapAttack = true
			end)
		end
	}

	function ent_base:MeleeAttackCode(isPropAttack, attackDist, customEnt)
		if self.Dead or self.vACT_StopAttacks or self.Flinching or (self.StopMeleeAttackAfterFirstHit && self.AttackStatus == VJ_ATTACK_STATUS_EXECUTED_HIT) then return end
		isPropAttack = isPropAttack or self.MeleeAttack_DoingPropAttack -- Is this a prop attack?
		attackDist = attackDist or self.MeleeAttackDamageDistance -- How far should the attack go?
		local curEnemy = customEnt or self:GetEnemy()
		if self.MeleeAttackAnimationFaceEnemy && !isPropAttack then self:FaceCertainEntity(curEnemy, true) end
		//self.MeleeAttacking = true
		self:CustomOnMeleeAttack_BeforeChecks()
		if self.DisableDefaultMeleeAttackCode then return end
		local myPos = self:GetPos()
		local hitRegistered = false
		for _, v in ipairs(ents.FindInSphere(self:GetMeleeAttackDamageOrigin(), attackDist)) do
			if (self.VJ_IsBeingControlled && self.VJ_TheControllerBullseye == v) or (v:IsPlayer() && v.IsControlingNPC == true) then continue end -- If controlled and v is the bullseye OR it's a player controlling then don't damage!
			if v != self && v:GetClass() != self:GetClass() && (((v:IsNPC() or (v:IsPlayer() && v:Alive() && !VJ_CVAR_IGNOREPLAYERS)) && self:Disposition(v) != D_LI) or IsProp(v) == true or v:GetClass() == "func_breakable_surf" or destructibleEnts[v:GetClass()] or v.VJ_AddEntityToSNPCAttackList == true) && self:GetSightDirection():Dot((Vector(v:GetPos().x, v:GetPos().y, 0) - Vector(myPos.x, myPos.y, 0)):GetNormalized()) > math_cos(math_rad(self.MeleeAttackDamageAngleRadius)) then
				if isPropAttack == true && (v:IsPlayer() or v:IsNPC()) && self:VJ_GetNearestPointToEntityDistance(v) > self.MeleeAttackDistance then continue end //if (self:GetPos():Distance(v:GetPos()) <= self:VJ_GetNearestPointToEntityDistance(v) && self:VJ_GetNearestPointToEntityDistance(v) <= self.MeleeAttackDistance) == false then
				local vProp = IsProp(v)
				if self:CustomOnMeleeAttack_AfterChecks(v, vProp) == true then continue end
				-- Remove prop constraints and push it (If possible)
				if vProp then
					local phys = v:GetPhysicsObject()
					if IsValid(phys) && self:DoPropAPCheck({v}, attackDist) then
						hitRegistered = true
						phys:EnableMotion(true)
						//phys:EnableGravity(true)
						phys:Wake()
						//constraint.RemoveAll(v)
						//if util.IsValidPhysicsObject(v, 1) then
						constraint.RemoveConstraints(v, "Weld") //end
						if self.PushProps then
							phys:ApplyForceCenter((curEnemy != nil and curEnemy:GetPos() or myPos) + self:GetForward()*(phys:GetMass() * 700) + self:GetUp()*(phys:GetMass() * 200))
						end
					end
				end
				-- Knockback
				if self.HasMeleeAttackKnockBack && v.MovementType != VJ_MOVETYPE_STATIONARY && (!v.VJ_IsHugeMonster or v.IsVJBaseSNPC_Tank) then
					v:SetGroundEntity(NULL)
					-- !!!!!!!!!!!!!! DO NOT USE THESE !!!!!!!!!!!!!! [Backwards Compatibility!]
					if self.MeleeAttackKnockBack_Forward1 or self.MeleeAttackKnockBack_Forward2 or self.MeleeAttackKnockBack_Up1 or self.MeleeAttackKnockBack_Up2 then
						v:SetVelocity(self:GetForward()*math.random(self.MeleeAttackKnockBack_Forward1 or 100, self.MeleeAttackKnockBack_Forward2 or 100) + self:GetUp()*math.random(self.MeleeAttackKnockBack_Up1 or 10, self.MeleeAttackKnockBack_Up2 or 10) + self:GetRight()*math.random(self.MeleeAttackKnockBack_Right1 or 0, self.MeleeAttackKnockBack_Right2 or 0))
					else
					-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!
						v:SetVelocity(self:MeleeAttackKnockbackVelocity(v))
					end
				end
				-- Apply actual damage
				if !self.DisableDefaultMeleeAttackDamageCode then
					local applyDmg = DamageInfo()
					applyDmg:SetDamage(self:VJ_GetDifficultyValue(self.MeleeAttackDamage))
					applyDmg:SetDamageType(self.MeleeAttackDamageType)
					local custdmg = hook.Run("VJbasePreDamage", self, applyDmg, isPropAttack, attackDist, customEnt) 
					local applyDmg = custdmg or applyDmg
					if v:IsNPC() or v:IsPlayer() then applyDmg:SetDamageForce(self:GetForward() * ((applyDmg:GetDamage() + 100) * 70)) end
					applyDmg:SetInflictor(self)
					applyDmg:SetAttacker(self)
					v:TakeDamageInfo(applyDmg, self)
				end
				-- Bleed Enemy
				if self.MeleeAttackBleedEnemy == true && math.random(1, self.MeleeAttackBleedEnemyChance) == 1 && ((v:IsNPC() && (!VJ_IsHugeMonster)) or v:IsPlayer()) then
					local tName = "timer_melee_bleedply"..v:EntIndex() -- Timer's name
					local tDmg = self.MeleeAttackBleedEnemyDamage -- How much damage each rep does
					timer.Create(tName, self.MeleeAttackBleedEnemyTime, self.MeleeAttackBleedEnemyReps, function()
						if IsValid(v) && v:Health() > 0 then
							v:TakeDamage(tDmg, self, self)
						else -- Remove the timer if the entity is dead in attempt to remove it before the entity respawns (Essential for players)
							timer.Remove(tName)
						end
					end)
				end
				if v:IsPlayer() then
					-- Apply DSP
					if self.MeleeAttackDSPSoundType != false && ((self.MeleeAttackDSPSoundUseDamage == false) or (self.MeleeAttackDSPSoundUseDamage == true && self.MeleeAttackDamage >= self.MeleeAttackDSPSoundUseDamageAmount && GetConVar("vj_npc_nomeleedmgdsp"):GetInt() == 0)) then
						v:SetDSP(self.MeleeAttackDSPSoundType, false)
					end
					v:ViewPunch(Angle(math.random(-1, 1) * self.MeleeAttackDamage, math.random(-1, 1) * self.MeleeAttackDamage, math.random(-1, 1) * self.MeleeAttackDamage))
					-- Slow Player
					if self.SlowPlayerOnMeleeAttack == true then
						self:VJ_DoSlowPlayer(v, self.SlowPlayerOnMeleeAttack_WalkSpeed, self.SlowPlayerOnMeleeAttack_RunSpeed, self.SlowPlayerOnMeleeAttackTime, {PlaySound=self.HasMeleeAttackSlowPlayerSound, SoundTable=self.SoundTbl_MeleeAttackSlowPlayer, SoundLevel=self.MeleeAttackSlowPlayerSoundLevel, FadeOutTime=self.MeleeAttackSlowPlayerSoundFadeOutTime})
					end
				end
				VJ_DestroyCombineTurret(self,v)
				if !vProp then -- Only for non-props...
					hitRegistered = true
				end
			end
		end
		if self.AttackStatus < VJ_ATTACK_STATUS_EXECUTED then
			self.AttackStatus = VJ_ATTACK_STATUS_EXECUTED
			if self.TimeUntilMeleeAttackDamage != false then
				finishAttack[VJ_ATTACK_MELEE](self)
			end
		end
		if hitRegistered == true then
			self:PlaySoundSystem("MeleeAttack")
			self.AttackStatus = VJ_ATTACK_STATUS_EXECUTED_HIT
		else
			self:CustomOnMeleeAttack_Miss()
			-- !!!!!!!!!!!!!! DO NOT USE THESE !!!!!!!!!!!!!! [Backwards Compatibility!]
			if self.MeleeAttackWorldShakeOnMiss then util.ScreenShake(myPos, self.MeleeAttackWorldShakeOnMissAmplitude or 16, 100, self.MeleeAttackWorldShakeOnMissDuration or 1, self.MeleeAttackWorldShakeOnMissRadius or 2000) end
			-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!
			self:PlaySoundSystem("MeleeAttackMiss", {}, VJ_EmitSound)
		end
	end

	scripted_ents.Register( ent_base, "npc_vj_creature_base" )
end