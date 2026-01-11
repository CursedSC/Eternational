AddCSLuaFile()

ENT.Base = "base_snpc"

ENT.PrintName = "Продавец #5"
ENT.Author = "Demit"
ENT.Category = "Fantasy - NPC"

ENT.Spawnable 	= true
ENT.AdminOnly 	= true

ENT.Model = "models/cloudteam/fantasy/custom/people_male.mdl"
ENT.Sequence = "menu_combine"

function ENT:Initialize()
	self:SetModel(self.Model)
	if SERVER then
		self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
		self:SetUseType(SIMPLE_USE)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_BBOX)
		self:SetBodyGroups("022600000")
		self:RunAnimation(self.Sequence)
		self.anim = self.Sequence
		self:SetNWString("Name", "Алестер")
		self:SetNWString("Job", "Продавец")

	end
end

if CLIENT then
	function ENT:OnUse()
		shopNPCDialog(self)
	end
end
