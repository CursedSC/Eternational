AddCSLuaFile()

ENT.Type      = "anim"
ENT.Spawnable = true

ENT.Model = "models/cloudteam/fantasy/weapons/arrow10.mdl"

local ARROW_MINS = Vector(-0.25, -0.25, 0.25)
local ARROW_MAXS = Vector(0.25, 0.25, 0.25)

function ENT:Initialize()
	if SERVER then
		self:SetModel(self.Model)

		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_FLYGRAVITY)
		self:SetSolid(SOLID_BBOX)
		self:DrawShadow(true)

		if self.NoColl then self:SetCollisionBounds(ARROW_MINS, ARROW_MAXS) end
		self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)

		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
		end
		self.expl = true
	end
end

function ENT:Think()
	if SERVER then
		if self:GetMoveType() == MOVETYPE_FLYGRAVITY or self:GetMoveType() == MOVETYPE_FLYGRAVITY then
			if self.AimTarget then 
				local pos = (self.AimTarget:GetPos() + Vector(0,0,50)) - self:GetPos()
				local nor = pos:GetNormalized()
				arrow:SetVelocity(nor * 2500 )
			
			else 
				--self:SetAngles(self:GetVelocity():Angle())
			end
			self:SetAngles(self:GetVelocity():Angle())
		end
	end
end

function ENT:SetDMG(dmg)
	self.dmg = dmg
end

function ENT:Use(activator, caller)
	self:Remove() 
	activator:GiveAmmo(1,"huntingbow_arrows",false)
	return false
end

function ENT:OnRemove()
	return false
end

local StickSound = {
	"weapons/huntingbow/impact_arrow_stick_1.wav",
	"weapons/huntingbow/impact_arrow_stick_2.wav",
	"weapons/huntingbow/impact_arrow_stick_3.wav"
}

local FleshSound = {
	"weapons/huntingbow/impact_arrow_flesh_1.wav",
	"weapons/huntingbow/impact_arrow_flesh_2.wav",
	"weapons/huntingbow/impact_arrow_flesh_3.wav",
	"weapons/huntingbow/impact_arrow_flesh_4.wav"
}

function ENT:Touch(ent)
	--print("set", self:GetClass())
	--if "huntingbow_arrow" == self:GetClass() then return end
	if self:GetClass() == "trigger_multiple" then return end
	print("set2", self:GetClass())
	if self:GetMoveType() == MOVETYPE_NONE then
		return
	end
	local vel   = self:GetVelocity()
	local speed = vel:Length()

	local tr = self:GetTouchTrace()
	print("tr")
	if tr.Hit and (ent:IsPlayer() or ent:IsNPC()) then
		local damage = self.dmg 
		local d = DamageInfo()
        d:SetDamage( damage)
        d:SetAttacker( self.Owner )
        d:SetInflictor(self) 
        d:SetDamagePosition(ent:GetPos())
        d:SetDamageCustom(1)
		d:SetDamageType(DMG_SLASH)
        ent:TakeDamageInfo( d )
		self:Remove()
	end


		if self.expl and self.canexp then
			self.expl = false
			ply =  self


			local radius = 300

			util.BlastDamage( self, self:GetOwner(), self:GetPos(), radius, 150 )

			local effectdata = EffectData()
			effectdata:SetOrigin( self:GetPos() )
			effectdata:SetColor(105)
			util.Effect( "Explosion", effectdata, true, true )

			if ( self:GetShouldRemove() ) then self:Remove() return end
			if ( self:GetMaxHealth() > 0 && self:Health() <= 0 ) then self:SetHealth( self:GetMaxHealth() ) end
		end



	if ent:IsWorld() then
		print("IsWorld")
		sound.Play(table.Random(StickSound), tr.HitPos)

		self:SetMoveType(MOVETYPE_NONE)
		--self:PhysicsInit(SOLID_NONE)

		SafeRemoveEntityDelayed(self, 10)

		return
	end

	if ent:IsValid() and "huntingbow_arrow" != self:GetClass() then
		if self:GetOwner():GetNWBool("Ignite_") then 
			local ignite_use = self:GetOwner():GetNWInt("Ignite")
			if ignite_use == 1 then 
				ply:SetNWBool("Ignite_", false)	
			end
			self:GetOwner():SetNWInt("Ignite", ignite_use - 1)
			ent:Ignite(5)	
		end

		if self.StunOne then 
			ent:SetNWBool("NoMove", true) 
			timer.Simple(2.5, function()
				ent:SetNWBool("NoMove", false) 
			end)
		end
		if ent:IsNPC() or ent:IsPlayer() and istable(tr2) then
			if tr2 and tr2.Entity == ent then sound.Play(table.Random(FleshSound), tr.HitPos) end
			self:Remove()
		else
			self:SetParent(ent)
			sound.Play(table.Random(StickSound), tr.HitPos)

			self:SetMoveType(MOVETYPE_NONE)
			--self:SetSolid(SOLID_NONE)

			SafeRemoveEntityDelayed(self, 30)
		end
	end
end
if CLIENT then
	local arrow_mdl_s = ClientsideModel( "models/thrusters/jetpack.mdl" )
	arrow_mdl_s:SetNoDraw( true )
	function ENT:Draw()
		if self:GetNWBool("ReDraw") then 
			arrow_mdl_s:SetModel(self:GetModel())
			arrow_mdl_s:SetPos(self:GetPos()) 
			arrow_mdl_s:SetAngles(self:GetAngles() + Angle(0,90,0))
			arrow_mdl_s:DrawModel()	
			--self:DrawModel()
		else 
			self:DrawModel()
		end
	end
end