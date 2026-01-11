AddCSLuaFile("shared.lua")
--AddCSLuaFile("cl_init.lua")
include("shared.lua")
util.AddNetworkString("fnt.PlayAnim")

local stoneType = {
	["normal"] = {
		color = Color(255, 255, 255, 255),
	},
	["iron"] = {
		color = Color(179, 154, 154),
	},
	["coal"] = {
		color = Color(31, 31, 31),
	},
	["bad"] = {
		color = Color(48, 37, 37),
	}
}
function ENT:GetNewStoneType()
	local r = math.random(1, 100)
	if r <= 25 then
		return "normal"
	elseif r <= 50 then
		return "coal"
	elseif r <= 75 then
		return "iron"
	else
		return "bad"
	end
end

function ENT:Initialize()
	self:SetModel( "models/props_foliage/rock_forest02.mdl" )
	self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
	self:SetUseType(SIMPLE_USE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	self:SetNoDraw( false )

	self:SetNWBool("CanUse", true)

	local key = self:GetNewStoneType()
	local type = stoneType[key]
	self:SetColor(type.color)
	self.stoneType = key

end

function ENT:Use(activator)
	local Wtype = activator:GetActiveWeapon()
	print(Wtype)
	if Wtype:GetClass() != "tool_axe" then
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
		if IsValid(self) then
			self:SetNWBool("CanUse", true)
			self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
			local key = self:GetNewStoneType()
			local type = stoneType[key]
			self:SetColor(type.color)
			self.stoneType = key
		end
	end)
end