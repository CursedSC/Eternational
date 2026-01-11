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
	print("Use", activator)
	if !activator:FractionCan("storage") then return end
	local storage = fractions.List.impire:GetStorage()
	print("storage.id", storage.id)
	activator:SetNWEntity("Storage", self)
	activator:SetNWInt("StorageiD", storage.id)
	storage.listeners = storage.listeners or {}
	storage.listeners[activator:SteamID64()] = activator
	netstream.Start(activator, "fantasy/storage/open", storage)
end
