AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel( "models/props_junk/wood_crate001a.mdl" )
	--self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:SetUseType(SIMPLE_USE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)  

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	self:SetNWBool("CanUse", true)

end


function ENT:Use(activator)
	local activatorStorage = activator:GetNWEntity("Storage", nil)
	local activatorStorageiD = activator:GetNWInt("StorageiD", nil)

	local storageInventory = activator:GetPersonalStorage()
	print("storageInventory.id", storageInventory.id)
	activator:SetNWEntity("Storage", self)
	activator:SetNWInt("StorageiD", storageInventory.id)
	netstream.Start(activator, "fantasy/storage/open", storageInventory)
end
