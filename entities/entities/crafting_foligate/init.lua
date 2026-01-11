AddCSLuaFile("shared.lua")
include("shared.lua")

local bush_list = {
	model = "models/props/de_inferno/largebush02.mdl",
	drops = {
		[35] = {
			ch =100,
			num = {1, 3},
		},
		[39] = {
			ch =100,
			num = {1, 3},
		},
		[37] = {
			ch = 35,
			num = {1, 1},
		},
		[44] = {
			ch = 50,
			num = {1, 3},
		},
		[47] = {
			ch = 50,
			num = {1, 3},
		},
		[50] = {
			ch = 5,
			num = {1, 1},	
		},
		[54] = {
			ch = 45,
			num = {1, 1},	
		},
	}
}


function ENT:Initialize()
	self:SetModel( "models/blacksmith_forge.mdl" )
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
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
	netstream.Start(activator, "fnt/craft", "furnice")
end
