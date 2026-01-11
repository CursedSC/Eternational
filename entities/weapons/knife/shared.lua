SWEP.Base = "sword_base"

if (SERVER) then
	AddCSLuaFile()
end 
 
if (CLIENT) then
	SWEP.PrintName = "Кинжал"
end
SWEP.Spawnable = true
SWEP.Category = "Оружие"
SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/cloudteam/fantasy/weapons/knife.mdl" -- models/cloudteam/fantasy/weapons/sword.mdl
SWEP.Damage = 5
SWEP.HoldType = "d_knife"
SWEP.Type = "knife"
SWEP.SphereSize = 20
SWEP.MainAtt = "agility"
SWEP.AttackList = {
	[1] = {
		seq = "ryoku_r_c1_t1",
		cd = 0.3,
		Attack = function(self, player)
			timer.Simple(0.1, function()
				
				player:LagCompensation(true)
				local damagePos = self.Owner:GetPos() + Vector(0,0,50) + ( self:GetAttackAngle():Forward() * self:GetDistanseAttack())
				self:DoDamage(damagePos, 1)
				player:LagCompensation(false)
				if player:OnGround() then  
					--player:SetVelocity(player:GetForward() * 400)
					player.InAction = false 
				end
			end)
		end,
	},
	[2] = {
		seq = "ryoku_r_c2_t1",
		cd = 0.3,
		Attack = function(self, player)
			timer.Simple(0.1, function()
				
				player:LagCompensation(true)
				local damagePos = self.Owner:GetPos() + Vector(0,0,50) + ( self:GetAttackAngle():Forward() * self:GetDistanseAttack())
				self:DoDamage(damagePos, 1)
				player:LagCompensation(false)
				if player:OnGround() then  
					--player:SetVelocity(player:GetForward() * 400)
					player.InAction = false 
				end
			end)
		end,
	}
}

function SWEP:PrimaryAttack(ignore)
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

function SWEP:DoDamage(pos, comboInt)
	local entityAttacked = ents.FindInSphere(pos, self:GetDistanseAttack())
	for k, i in pairs(entityAttacked) do 
		if !i:IsNPC() and !i:IsPlayer() and !i:IsNextBot() then continue end 
		if i == self.Owner then continue end  
		doAttackDamage(self.Owner, i, self, self.Damage)
	end
end