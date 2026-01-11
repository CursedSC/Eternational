AddCSLuaFile("shared.lua")
include("shared.lua")

local bush_list = {
	model = "models/props/de_inferno/largebush01.mdl",
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
		[51] = {
			ch = 5,
			num = {1, 1},	
		},
	}
}


function ENT:Initialize()
	self:SetModel( bush_list.model )
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
	if not self:GetNWBool("CanUse") then return end
	self:SetNWBool("CanUse", false)
	activator:Freeze(true)
	activator:SetNWBool("InWorking", true)
	local timer_time = 5
	timer.Simple(timer_time, function() 
		activator:Freeze(false) 
		activator:SetNWBool("InWorking", false)
		AddOp( activator, 5 )

		for k, i in pairs(bush_list.drops) do 
			if math.random(1,100) <= i.ch then 
				inv.AddItem(k, math.random(i.num[1],i.num[2]), 0, activator)  
			end
		end
	end)

	timer.Simple(305, function() self:SetNWBool("CanUse", true)  end)
end
