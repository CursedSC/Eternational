SWEP.Base = "sword_base"

if (SERVER) then
	AddCSLuaFile()
end

if (CLIENT) then
	SWEP.PrintName = "Укрепленный меч"
end

SWEP.Category = "Оружие"
SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/cloudteam/fantasy/weapons/sword17.mdl" -- models/cloudteam/fantasy/weapons/sword.mdl
SWEP.HoldType = "d_sword"
SWEP.Type = "sword"
SWEP.SphereSize = 60
SWEP.Spawnable = true
SWEP.AttackList = {
	[1] = {
		seq = "b_right_t2",
		cd = 0.7,
		Attack = function(self, player)
			if player:OnGround() then 
				--player:SetVelocity(player:GetForward() * -100) 
				timer.Simple(0.3, function()
					player:LagCompensation(true)
					local damagePos = self.Owner:GetPos() + Vector(0,0,50) + ( self:GetAttackAngle():Forward() * self:GetDistanseAttack())
					self:DoDamage(damagePos, 1)
					player:LagCompensation(false)
					if player:OnGround() then  
						--player:SetVelocity(player:GetForward() * 400)
						player.InAction = false 
					end
				end)
			end
		end
	},
	[2] = {
		seq = "b_left_t2",
		cd = 0.7,
		Attack = function(self, player)
			if player:OnGround() then 
				--player:SetVelocity(player:GetForward() * -100) 
				timer.Simple(0.3, function()
					player:LagCompensation(true)
					local damagePos = self.Owner:GetPos() + Vector(0,0,50) + ( self:GetAttackAngle():Forward() * self:GetDistanseAttack())
					self:DoDamage(damagePos, 1)
					player:LagCompensation(false)

					if player:OnGround() then  
						--player:SetVelocity(player:GetForward() * 400)
						player.InAction = false 
					end
				end)
			end
		end
	},
}

function SWEP:DoDamage(pos, comboInt)
	local entityAttacked = ents.FindInSphere(pos, self:GetDistanseAttack())
	for k, i in pairs(entityAttacked) do 
		if !i:IsNPC() and !i:IsPlayer() and !i:IsNextBot() then continue end 
		if i == self.Owner then continue end  
		doAttackDamage(self.Owner, i, self, 20)
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