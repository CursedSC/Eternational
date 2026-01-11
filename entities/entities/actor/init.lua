AddCSLuaFile("shared.lua")
include("shared.lua")


function ENT:Initialize()
	self:SetModel(  "models/cloudteam/fantasy/custom/people_male.mdl" )
	self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
	self:SetUseType(SIMPLE_USE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_BBOX)
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end

	self:ResetSequence( self:LookupSequence("idle_all_01") )
end

function ENT:RunAnimation(anim)
	self:ResetSequence(
		self:LookupSequence(anim)
	)
end  


function ENT:Use(activator)

end
