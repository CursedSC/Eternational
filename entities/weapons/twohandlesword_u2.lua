if (SERVER) then
	AddCSLuaFile()
end

if (CLIENT) then
	SWEP.Slot = 1
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.PrintName = "Двуручный Меч с дополнительным покрытием"
	SWEP.DrawCrosshair = true
end

SWEP.UseHands = false
SWEP.Base = "sword_base"
SWEP.Category = "Оружие"
SWEP.Author = "Demit"
SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/cloudteam/fantasy/weapons/two_hand_sword2.mdl" -- заменить на двуручку
SWEP.AdminSpawnable = false
SWEP.Spawnable = true
SWEP.Primary.NeverRaised = true
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.Damage = 90
SWEP.Primary.Delay = 3
SWEP.Primary.Ammo = ""
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Delay = 0
SWEP.Secondary.Ammo = ""
SWEP.Damage = 40
SWEP.HoldType = "d_swordbig"
SWEP.HoldTypeBlock = "d_sword_block"
SWEP.BlockAnim = "wos_aoc_sword_block"
SWEP.CanBlock = true
SWEP.SphereSize = 60 
SWEP.Type = "swordbig"

SWEP.AttackList = {
	[1] = {
		seq = "arc_atk_berserk1",
		cd = 1.3,
		Attack = function(self, player)
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
		end,
	},
	[2] = {
		seq = "arc_atk_berserk10",
		cd = 1.3,
		Attack = function(self, player)
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
		end,
	}
}

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

function SWEP:DoDamage(pos, comboInt)
	local entityAttacked = ents.FindInSphere(pos, self:GetDistanseAttack())
	for k, i in pairs(entityAttacked) do 
		if !i:IsNPC() and !i:IsPlayer() and !i:IsNextBot() then continue end 
		if i == self.Owner then continue end  
		doAttackDamage(self.Owner, i, self, self.Damage)
	end
end