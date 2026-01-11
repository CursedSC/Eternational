-- Include --
AddCSLuaFile()

-- Vars --
local swingSound = Sound("WeaponFrag.Throw")
local hitSound = Sound("Flesh.ImpactHard")

local handsModel = Model("models/weapons/c_medkit.mdl")
local fistsModel = Model("models/weapons/c_arms.mdl")

-- SWEP --
SWEP.PrintName = "Руки"
SWEP.Author = ""
SWEP.Instructions = "ЛКМ - взять вещь\nПКМ - закрыть/открыть дверь\nR - кулаки"
SWEP.Category = "Про че"

SWEP.Slot = 0
SWEP.SlotPos = 0

SWEP.Spawnable = true

SWEP.ViewModel = fistsModel
SWEP.WorldModel = "models/props_junk/cardboard_box004a.mdl"
SWEP.ViewModelFOV = 54
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.DrawAmmo = false

SWEP.HitDistance = 15

SWEP.DrawCrosshair = false

function SWEP:Initialize()
	self:SetHoldType("normal")

	self.time = 0
	self.range = 150


	self.cooldown = true

	if SERVER then
		self.reloaded = false
	end
end

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "NextMeleeAttack")
	self:NetworkVar("Float", 1, "NextIdle")
	self:NetworkVar("Float", 2, "NextReload")
	self:NetworkVar("Int", 2, "Combo")
	self:NetworkVar("String", 0, "HandsStatus")

	self:SetHandsStatus("hands")
end

function SWEP:DrawWorldModel( flags )
end

function SWEP:UpdateNextIdle()
	local vm = self.Owner:GetViewModel()

	if vm:IsValid() then
		self:SetNextIdle(CurTime() + vm:SequenceDuration() / vm:GetPlaybackRate())
	end
end

function SWEP:HandsStatusIs(handsStatus)
	return self:GetHandsStatus() == handsStatus
end

function SWEP:OnDrop()
	self:Remove()
end

function SWEP:Deploy()
	self.cooldown = true
	local speed = 2

	local vm = self.Owner:GetViewModel()

	if vm:IsValid() then
		vm:SendViewModelMatchingSequence(vm:LookupSequence("fists_draw"))
		vm:SetPlaybackRate(speed)

		self:SetNextPrimaryFire(CurTime() + vm:SequenceDuration() / speed)
		self:SetNextSecondaryFire(CurTime() + vm:SequenceDuration() / speed)
	end

	self:UpdateNextIdle()

	if SERVER then
		self:SetCombo(0)
	end

	return true
end

function SWEP:PrimaryAttack()
	local owner = self.Owner

	if self:HandsStatusIs("fists") then
		if owner:GetNWInt('Stamina', 0) > 10 then
			hook.Call( "dbt.OnPlayerAttack_melee", nil, owner, -5 )
		end


		self.Owner:SetAnimation(PLAYER_ATTACK1)

		local anim = "fists_left"

		if self:GetCombo() >= 2 then
			anim = "fists_uppercut"
		end

		local vm = self.Owner:GetViewModel()

		if vm:IsValid() then
			vm:SendViewModelMatchingSequence(vm:LookupSequence(anim))
		end

		self:EmitSound(swingSound)

		self:UpdateNextIdle()
		self:SetNextMeleeAttack(CurTime() + 0.2)

		self:SetNextPrimaryFire(CurTime() + 0.9)
		self:SetNextSecondaryFire(CurTime() + 0.9)

		return
	elseif self:HandsStatusIs("hands") then
		local pos = self.Owner:GetShootPos()
		local aim = self.Owner:GetAimVector()

		local tr = util.TraceLine{
			start = pos,
			endpos = pos + aim * self.range,
			filter = player.GetAll(),
		}

		local hitEnt = tr.Entity

		if self.drag then
			self:SetHoldType("pistol")

			hitEnt = self.drag.Entity

			if owner:IsOnGround() and owner:GetGroundEntity() == hitEnt then
				self.drag = nil
				hitEnt = NULL
			end
		else
			if	not IsValid(hitEnt) or
				hitEnt:GetMoveType() ~= MOVETYPE_VPHYSICS or
				hitEnt:IsVehicle() or
				hitEnt:GetNWBool("NoDrag", false) or
				hitEnt.BlockDrag or
				IsValid(hitEnt:GetParent()) or
				owner:IsOnGround() and owner:GetGroundEntity() == hitEnt
			then
				return
			end

			if not self.drag then
				self.drag = {
					OffPos = hitEnt:WorldToLocal(tr.HitPos),
					Entity = hitEnt,
					Fraction = tr.Fraction,
				}
			end
		end

		if CLIENT or not IsValid(hitEnt) then
			return
		end

		local phys = hitEnt:GetPhysicsObject()

		if IsValid(phys) then
			local pos2 = pos + aim * self.range * self.drag.Fraction
			local offPos = hitEnt:LocalToWorld(self.drag.OffPos)
			local dif = pos2 - offPos
			local nom = (dif:GetNormal() * math.min(1, dif:Length() / 100) * 500 - phys:GetVelocity()) * phys:GetMass()

			phys:ApplyForceOffset(nom, offPos)
			phys:AddAngleVelocity(-phys:GetAngleVelocity() / 4)
		end
	end
end

local doors = {
    ["func_door"] = true,
    ["func_door_rotating"] = true,
    ["prop_door_rotating"] = true,
    ["func_movelinear"] = true,
    ["prop_dynamic"] = true
}

function isDoor(ent)
    local class = ent:GetClass()

    if doors[class] then
        return true
    end

    return false
end


function SWEP:SecondaryAttack()
	if self:HandsStatusIs("fists") then
		self.Owner:SetAnimation(PLAYER_ATTACK1)

		local anim = "fists_right"

		if self:GetCombo() >= 2 then
			anim = "fists_uppercut"
		end

		local vm = self.Owner:GetViewModel()

		if vm:IsValid() then
			vm:SendViewModelMatchingSequence(vm:LookupSequence(anim))
		end

		self:EmitSound(swingSound)

		self:UpdateNextIdle()
		self:SetNextMeleeAttack(CurTime() + 0.2)

		self:SetNextPrimaryFire(CurTime() + 0.9)
		self:SetNextSecondaryFire(CurTime() + 0.9)

		return
	elseif self:HandsStatusIs("hands") then

		if SERVER then

			local tr = self.Owner:GetEyeTrace()
			local ent = tr.Entity

		end

	end
end

function SWEP:DealDamage()
	local anim = self:GetSequenceName(self.Owner:GetViewModel():GetSequence())

	self:SetNextReload(CurTime() + 0.9)

	self.Owner:LagCompensation(true)

	local tr = util.TraceLine({
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDistance,
		filter = self.Owner,
		mask = MASK_SHOT_HULL
	})

	if !IsValid(tr.Entity) then
		tr = util.TraceHull({
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDistance,
			filter = self.Owner,
			mins = Vector(-10, -10, -8),
			maxs = Vector(10, 10, 8),
			mask = MASK_SHOT_HULL
		})
	end

	-- We need the second part for single player because SWEP:Think is ran shared in SP
	if tr.Hit and !(game.SinglePlayer() and CLIENT) then
		self:EmitSound(hitSound)
	end

	local hit = false

	if SERVER and IsValid(tr.Entity) and (tr.Entity:IsNPC() or tr.Entity:IsPlayer()) and tr.Entity:Health() > 20 then
		local dmginfo = DamageInfo()

		local attacker = self.Owner

		if !IsValid(attacker) then
			attacker = self
		end

		dmginfo:SetAttacker(attacker)

		dmginfo:SetInflictor(self)
		dmginfo:SetDamage(math.random(5, 10))


		if anim == "fists_left" then
			dmginfo:SetDamageForce(self.Owner:GetRight() * 4912 + self.Owner:GetForward() * 9998) -- Yes we need those specific numbers
		elseif anim == "fists_right" then
			dmginfo:SetDamageForce(self.Owner:GetRight() * -4912 + self.Owner:GetForward() * 9989)
		elseif anim == "fists_uppercut" then
			dmginfo:SetDamageForce(self.Owner:GetUp() * 5158 + self.Owner:GetForward() * 10012)
			-- dmginfo:SetDamage(math.random(12, 24))
		end

		tr.Entity:TakeDamageInfo(dmginfo)
		hit = true
	end

	if SERVER and IsValid(tr.Entity) and (tr.Entity:IsNPC() or tr.Entity:IsPlayer()) and tr.Entity:Health() <= 20 then
		tr.Entity:SetVelocity(self.Owner:GetAimVector() * 80)
	end

	if SERVER and IsValid(tr.Entity) then
		local phys = tr.Entity:GetPhysicsObject()

		if IsValid(phys) then
			phys:ApplyForceOffset(self.Owner:GetAimVector() * 80 * phys:GetMass(), tr.HitPos)
		end
	end

	if SERVER then
		if hit and anim != "fists_uppercut" then
			self:SetCombo(self:GetCombo() + 1)
		else
			self:SetCombo(0)
		end
	end

	self.Owner:LagCompensation( false )
end

function SWEP:Reload()
	if CLIENT then
		return
	end

	if self:GetNextReload() > CurTime() then
		return
	end

	if self.reloaded then
		return
	end

	self.reloaded = true

	local curTime = CurTime()

	if self:HandsStatusIs("hands") then
		self:SetHandsStatus("fists")

		self:SetHoldType("fist")
		self:SetNextPrimaryFire(curTime + (self.deltaNextPrimaryFire or 0))
		self:SetNextSecondaryFire(curTime + (self.deltaNextSecondaryFire or 0))
		self:Deploy()
	elseif self:HandsStatusIs("fists") then
		self:SetHandsStatus("hands")

		self.deltaNextPrimaryFire = self:GetNextPrimaryFire() - curTime
		self.deltaNextSecondaryFire = self:GetNextSecondaryFire() - curTime

		self:SetHoldType("normal")
		self:SetNextPrimaryFire(curTime)
		self:SetNextSecondaryFire(curTime)
	end
end

local canVoiceHooks = hook.GetTable()["drp.systems.chat.canVoice"]

function SWEP:Think()
	if self.drag and (not self.Owner:KeyDown(IN_ATTACK) or not IsValid(self.drag.Entity)) then
		self.drag = nil
		self:SetHoldType("normal")
	end

	local vm = self.Owner:GetViewModel()
	local curtime = CurTime()
	local idletime = self:GetNextIdle()

	if idletime > 0 and CurTime() > idletime then
		if vm:IsValid() then
			vm:SendViewModelMatchingSequence(vm:LookupSequence("fists_idle_0" .. math.random(1, 2)))
		end

		self:UpdateNextIdle()
	end

	local meleetime = self:GetNextMeleeAttack()

	if meleetime > 0 and CurTime() > meleetime then
		self:DealDamage()

		self:SetNextMeleeAttack(0)
	end

	if SERVER and CurTime() > self:GetNextPrimaryFire() + 0.1 then
		self:SetCombo(0)
	end

	if CLIENT then
		return
	end

	local owner = self:GetOwner()

	if not owner:IsValid() then
		return
	end

	if self.reloaded and not owner:KeyDown(IN_RELOAD) then
		self.reloaded = false
	end
end

if CLIENT then
	-- Vars --
	local x, y = ScrW() / 2, ScrH() / 2
	local mainColor = Color( 255, 255, 255, 255 )
	local color = Color( 255, 255, 255, 255 )

	-- SWEP --
	function SWEP:PreDrawViewModel(vm, player, weapon)
		if self:HandsStatusIs("fists") then
			return
		end

		return true
	end

	function SWEP:DrawHUD()
		if	IsValid(self.Owner:GetVehicle()) or
			not self:HandsStatusIs("hands")
		then
			return
		end

		local pos = self.Owner:GetShootPos()
		local aim = self.Owner:GetAimVector()

		local tr = util.TraceLine{
			start = pos,
			endpos = pos + aim * (self.range or 120),
			filter = player.GetAll(),
		}

		local hitEnt = tr.Entity

		if IsValid(hitEnt) and hitEnt:GetMoveType() == MOVETYPE_VPHYSICS and
			not self.rDag and
			not hitEnt:IsVehicle() and
			not IsValid(hitEnt:GetParent()) and
			not hitEnt:GetNWBool("NoDrag", false) then

			self.time = math.min(1, self.time + 2 * FrameTime())
		else
			self.time = math.max(0, self.time - 2 * FrameTime())
		end
/*
		if self.time > 0 then
			color.a = mainColor.a * self.time

			draw.SimpleText(
				"Взять",
				"DermaLarge",
				x,
				y,
				color,
				TEXT_ALIGN_CENTER
			)
		end
*/
		if self.drag then
			local pos2 = pos + aim * 100 * self.drag.Fraction
			if not IsValid(self.drag.Entity) then return end
			local offPos = self.drag.Entity:LocalToWorld(self.drag.OffPos)
			local dif = pos2 - offPos

			local a = offPos:ToScreen()
			local b = pos2:ToScreen()
			surface.SetDrawColor( 255, 255, 255, 255 )
		end
	end
end
