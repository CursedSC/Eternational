AddCSLuaFile("shared.lua")
--AddCSLuaFile("cl_init.lua")
include("shared.lua")
util.AddNetworkString("fnt.PlayAnim")
function ENT:Initialize()
	self:SetModel( "models/props_foliage/tree_dry02.mdl" )
	self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
	self:SetUseType(SIMPLE_USE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	--self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	self:SetNoDraw( false )

	self:SetNWBool("CanUse", true)
	self:SetPos(self:GetPos() - Vector(0,0,20))
end

--
function ENT:Use(activator)
	local Wtype = activator:GetActiveWeapon()
	print(Wtype)
	if Wtype:GetClass() != "tool_pix" then
		return 
	end
	if not self:GetNWBool("CanUse") then return end
	activator:Freeze(true)
    netstream.Start(activator, "lumber", self)  
end

function ENT:Restore()
	self:SetNWBool("CanUse", false)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	timer.Simple(300, function()
		if IsValid(ent) then
			self:SetNWBool("CanUse", true)
			self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
		end
	end)
end