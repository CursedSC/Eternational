SWEP.Base = "sword_base"

if (SERVER) then
	AddCSLuaFile()
end

if (CLIENT) then
	SWEP.PrintName = "Меч"
end

SWEP.Category = "Оружие"
SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/cloudteam/fantasy/weapons/sword16.mdl" -- models/cloudteam/fantasy/weapons/sword.mdl
SWEP.HoldType = "d_sword"
SWEP.Type = "sword"
SWEP.SphereSize = 60
SWEP.Spawnable = true

local baseAttackFunc = function(self, player)
	if player:OnGround() then 
		timer.Simple(0.3, function()
			player:LagCompensation(true)
			local damagePos = self.Owner:GetPos() + Vector(0,0,50) + ( self:GetAttackAngle():Forward() * self:GetDistanseAttack())
			self:DoDamage(damagePos, 1)
			player:LagCompensation(false)
			if player:OnGround() then  
				player.InAction = false 
			end
		end)
	end
end

SWEP.AttackList = {
	[1] = {
		seq = "b_right_t2",
		cd = 0.7,
		Attack = baseAttackFunc,
	},
	[2] = {
		seq = "b_left_t2",
		cd = 0.7,
		Attack = baseAttackFunc,
	},
	[3] = {
		seq = "arc_atksword2",
		cd = 0.9,
		Attack = baseAttackFunc,
	},
}

function SWEP:DoDamage(pos, comboInt)
	local entityAttacked = ents.FindInSphere(pos, self:GetDistanseAttack())
	for k, i in pairs(entityAttacked) do 
		if !i:IsNPC() and !i:IsPlayer() and !i:IsNextBot() then continue end 
		if i == self.Owner then continue end  
		doAttackDamage(self.Owner, i, self, 10)
	end
end

function SWEP:PrimaryAttack()	
	if !self:CanAttack() then return end
	if self.cd and self.cd >= CurTime() then return end
	local player = self.Owner 
	local attackData = self.AttackList[self.AttackId]
	self.cd = CurTime() + attackData.cd
	if SERVER then netstream.Start(nil, "fantasy/play/anim", player, attackData.seq,  0, true) end

	
	if SERVER then 
		player:EmitSound("sword/sword_wooh.wav", 100)
		attackData.Attack(self, player)
	end
	self.AttackId = self.AttackId + 1 
	if self.AttackId > #self.AttackList then self.AttackId = 1 end
end

hook.Add( "StartCommand", "StartCommandExample", function( ply, cmd )
	if ply.InAction then 
		--cmd:ClearMovement() 
	end
end)