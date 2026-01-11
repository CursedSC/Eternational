-- incredible-gmod.ru

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Sequence = "idle01"
ENT.Model = "models/Barney.mdl"

util.AddNetworkString(ENT.NetID)

function ENT:Initialize()
  	self:SetModel(self.Model)
	self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
	self:SetUseType(SIMPLE_USE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_BBOX)

	self:RunAnimation(self.Sequence)
	self.anim = self.Sequence

	self:SetNWString("Name", "Неизвестный")
	self:SetNWString("Job", "Отсуствует")

	self.seed = math.Rand(1, 1000000000)

	local data = self:GetBodyGroups()

	local body = {}

	for i = 1, #data do 
		body[i] = {
			id = data[i].id,
			num = self:GetBodygroup( data[i].id )
		}
	end

	self.bg = body

end

function ENT:RunAnimation(anim)
	self:ResetSequence(
		self:LookupSequence(anim)
	)
	--self:SetCycle(0)
	--self:SetPlaybackRate(1)
end

function ENT:RunAnimationPiece(anim, pos) -- str sequence, 0-1 position
	self:ResetSequence(
		self:LookupSequence(anim)
	)
	--self:SetCycle(pos)
	--self:SetPlaybackRate(0)
end--

function ENT:Use(ply)
	net.Start(self.NetID)
		net.WriteEntity(self)
	net.Send(ply)
end
