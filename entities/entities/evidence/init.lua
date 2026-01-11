AddCSLuaFile("shared.lua")

include("shared.lua")

util.AddNetworkString("dec.AddEvidence")

function ENT:Initialize()
	self:SetModel( "models/hunter/blocks/cube025x025x025.mdl" )
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:SetUseType(SIMPLE_USE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)         -- Toolbox

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end

	self.whouse = {}

end

function ENT:SetItem(name, desc, icon)
	self.data = {
		name = name,
		desc = desc,
		icon = icon,
	}
end


function ENT:Use(activator)

	if not self.whouse[activator] then

	self.whouse[activator] = true

	net.Start("dec.AddEvidence")
		net.WriteTable(self.data)
	net.Send(activator)

	end
end
