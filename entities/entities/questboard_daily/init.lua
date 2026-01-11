AddCSLuaFile("shared.lua")

include("shared.lua")----

function ENT:Initialize()
	self:SetModel( "models/props_c17/FurnitureDresser001a.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType(SIMPLE_USE)

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
end

function ENT:Use(activator)
	local tbltosend = {}

	netstream.Start(activator, "questsystem/questboard_use")
end
